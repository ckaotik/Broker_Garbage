local _, BG = ...

-- == Finding things in your inventory ==
-- returns the first occurrence of a given item; item :: <itemID>|<itemLink>
function BG.FindItemInBags(item)
	for container = 0, NUM_BAG_SLOTS do
		local numSlots = GetContainerNumSlots(container)
		if numSlots then
			for slot = 0, numSlots do
				for slot = 1, numSlots do
					if item == GetContainerItemLink(container, slot) or item == GetContainerItemID(container, slot) then
						return container, slot
					end
				end
			end
		end
	end
end

function BG.FindBestContainerForItem(item, itemFamily)
	if type(item) == "table" then
		item = item.itemID
	elseif type(item) == "string" or type(item) == "number" then
		-- everything is alright
	else
		return nil
	end
	itemFamily = itemFamily or GetItemFamily(item)

	local bestContainer, bestFreeSlots, bestBagType, freeSlots, bagType
	for container = 0, NUM_BAG_SLOTS do
		freeSlots, bagType = GetContainerNumFreeSlots(container)

		if freeSlots > 0 and bit.band(itemFamily, bagType) > 0 and bagType ~= 0 then
			bestContainer = container
			bestFreeSlots, bestBagType = freeSlots, bagType
		end
	end
	return bestContainer, bestFreeSlots, bestBagType
end

-- finds all occurences of the given item or its category; returns table sorted by relevance (lowest first); item :: <itemTable>
function BG.GetItemLocations(item, ignoreFullStacks, includeLocked, scanCategory, useTable)
	if not item or type(item) ~= "table" then return end
	local locations
	if useTable and type(useTable) == "table" then
		wipe(useTable)
		locations = useTable
	end

	local itemCategories, maxLimit = BG.GetItemListCategories(item)
	local isLocked, itemIsRelevant, cachedItem, containsLockedSlots
	local inCategory, categoryName
	for tableIndex, tableItem in pairs(BG.cheapestItems) do
		if not tableItem.invalid then
			isLocked = select(3, GetContainerItemInfo(tableItem.bag, tableItem.slot))
			cachedItem = BG.GetCached(tableItem.itemID)

			itemIsRelevant = nil
			inCategory, categoryName = BG.IsItemInCategories(tableItem.itemID, itemCategories)
			if tableItem.itemID == item.itemID then
				itemIsRelevant = true

				if cachedItem and cachedItem.limit and cachedItem.limit > maxLimit then
					maxLimit = cachedItem.limit
				end
			elseif scanCategory and itemCategories and inCategory and not string.find(categoryName, "_") then
				itemIsRelevant = true
			end
			if itemIsRelevant then
				if not isLocked or includeLocked then
					if not ignoreFullStacks or tableItem.count < cachedItem.stackSize then
						if not locations then locations = {} end
						table.insert(locations, tableIndex)
					end
				end
				if isLocked then
					containsLockedSlots = true
				end
			end
		end
	end
	if locations then
		table.sort(locations, function(a,b)
			local itemA, itemB = BG.cheapestItems[a], BG.cheapestItems[b]
			local cacheA, cacheB = BG.GetCached(itemA.itemID), BG.GetCached(itemB.itemID)
			local bagTypeA = select(2, GetContainerNumFreeSlots(itemA.bag))
			local bagTypeB = select(2, GetContainerNumFreeSlots(itemB.bag))

			if bagTypeA ~= bagTypeB then
				return bagTypeA == 0
			else
				if cacheA.level == cacheB.level then
					if cacheA.vendorValue == cacheB.vendorValue then
						if itemA.count == itemB.count then
							return itemA.itemLink < itemB.itemLink
						else
							return itemA.count < itemB.count
						end
					else
						return cacheA.vendorValue < cacheB.vendorValue
					end
				else
					return cacheA.level < cacheB.level
				end
			end
		end)
	end
	return locations, maxLimit, containsLockedSlots
end

function BG.UpdateAllCaches(itemID)
	if not itemID or type(itemID) ~= "number" then
		BG.Debug("UpdateAllCaches - no or invalid argument!")
		return
	end
	local cheapestItem

	BG.UpdateCache(itemID)
	for _, itemIndex in pairs(BG.itemLocations[itemID] or {}) do
		cheapestItem = BG.cheapestItems[itemIndex]
		BG.SetDynamicLabelBySlot(cheapestItem.bag, cheapestItem.slot, itemIndex)
	end
	BG.ScanInventory()
	BG.UpdateLDB()
end

-- == Inventory Scanning ==
function BG.ScanInventory(resetCache)
	if resetCache then BG.ClearCache() end
	BG.containerInInventory = false

	local totalSlots, numSlots = 0, 0
	for container = 0, NUM_BAG_SLOTS do
		numSlots = BG.ScanInventoryContainer(container, true)
		totalSlots = totalSlots + (numSlots or 0)
	end
	BG.SortItemList()
end

local changedItems = {}
function BG.ScanInventoryContainer(container, waitForFullScan)
	local numSlots = GetContainerNumSlots(container)
	if not numSlots then return end -- no (scannable) bag

	local isSpecialBag = select(2, GetContainerNumFreeSlots(container)) ~= 0
	local newItemCount, newItemLink, itemID, listIndex
	wipe(changedItems)

	for slot = 1, numSlots do
		_, newItemCount, _, _, _, _, newItemLink = GetContainerItemInfo(container, slot)
		itemID = GetContainerItemID(container, slot)
		_ = BG.GetCached(itemID)	-- if we don't have it cached yet, do so now

		listIndex = BG.UpdateInventorySlot(container, slot, newItemLink, newItemCount)
		if listIndex then
			table.insert(changedItems, {container, slot, listIndex, isSpecialBag})
		end
	end

	for _, data in ipairs(changedItems) do
		BG.SetDynamicLabelBySlot(unpack(data))
	end

	if not waitForFullScan then
		BG.SortItemList()
	end

	return numSlots
end

-- only check a specific item in a specific location
function BG.UpdateInventorySlot(container, slot, newItemLink, newItemCount)
	local slotFound, recheck = nil, nil
	for index, item in ipairs(BG.cheapestItems or {}) do
		if item.bag == container and item.slot == slot then
			slotFound = index

			if item.invalid and newItemLink then
				BG.Debug("Reactivating "..container.."."..slot, newItemLink)
				recheck = true
			elseif item.itemLink and not newItemLink then 	-- tag data as invalid
				BG.Debug("Deactivating "..container.."."..slot, item.itemLink)
				item.invalid = true
			elseif item.itemLink ~= newItemLink then	-- update the whole item slot
				BG.Debug("Update slot "..container.."."..slot, newItemLink)
				recheck = true
			elseif item.count ~= newItemCount then	-- update the item count
				BG.Debug("Update item count", newItemLink)
				BG.cheapestItems[index].value = (BG.cheapestItems[index].value / BG.cheapestItems[index].count) * newItemCount
				BG.cheapestItems[index].count = newItemCount
			else
				-- BG.Debug("Item unchanged", newItemLink)
			end
		end
	end

	if (not slotFound or recheck) and newItemLink then
		-- BG.Debug("New item slot with new item", recheck and slotFound or "nil")
		return slotFound or 0
	end
end

-- [TODO] FIXME!
function BG.UpdateAllDynamicItems()
	BG.ClearCache()
	wipe(BG.cheapestItems)
	BG.ScanInventory() --]]
	return
end

-- == Pure Logic Ahead ==
function BG.SortCheapestItemsList(a, b)
	if a.source == BG.IGNORE or a.invalid then
		return false
	elseif b.source == BG.IGNORE or b.invalid then
		return true
	else
		for _, attribute in ipairs({'value', 'count', 'bag', 'slot'}) do
			if a[attribute] ~= b[attribute] then
				return a[attribute] < b[attribute]
			end
		end
	end
end

function BG.UpdateItemLocations()
	for k, v in pairs(BG.itemLocations) do
		wipe(v)
	end

	local itemID, locations
	local numEntries = #BG.cheapestItems

	BG.junkValue = 0
	for tableIndex, item in ipairs(BG.cheapestItems) do
		itemID = item.itemID
		locations = BG.itemLocations[itemID]

		if not item.invalid then
			if not locations then	-- new item
				BG.itemLocations[itemID] = { tableIndex }
			else -- if not BG.Find(locations, tableIndex) then	-- item is known, slot is not
				table.insert(locations, tableIndex)
			end

			if item.sell and item.value and item.value ~= 0 and item.count then
				BG.junkValue = BG.junkValue + item.value
			end
		end
	end
end

-- sort item list and updates LDB accordingly
function BG.SortItemList()
	table.sort(BG.cheapestItems, BG.SortCheapestItemsList)
	BG.UpdateItemLocations()
	BG.UpdateLDB()
end

-- forces a rescan on all items qualifying as equipment
function BG.RescanEquipmentInBags()
	local invType
	for itemIndex, item in pairs(BG.cheapestItems) do
		invType = select(9, GetItemInfo(item.itemID))
		if BG.IsItemEquipment(invType) then
			BG.SetDynamicLabelBySlot(item.bag, item.slot, itemIndex)
		end
	end
end

-- checks current inventory state and assigns labels depending on limits, binding etc.
local currentItem = { locations = nil, limit = nil }
function BG.SetDynamicLabelBySlot(container, slot, itemIndex, isSpecialBag, noCheckOtherSlots)
	if not (container and slot) then return end
	local maxValue, insert, reason
	local _, count, _, _, _, canOpen, itemLink = GetContainerItemInfo(container, slot)
	local itemID = itemLink and BG.GetItemID(itemLink)
	local item = itemID and BG.GetCached(itemID)

	if not BG.cheapestItems then
		BG.cheapestItems = {}
	end
	if not itemIndex or itemIndex < 1 then -- create new item entry
		itemIndex = #BG.cheapestItems + 1
	end
	local updateItem = BG.cheapestItems[itemIndex]

	if item then
		local itemLimit, itemLocations
		if noCheckOtherSlots then
			if updateItem and updateItem.invalid then
				return itemIndex
			end
			itemLimit = currentItem.limit
			itemLocations = currentItem.locations
		else
			itemLimit = item.limit
		end

		-- initial values, will get overridden if necessary
		local value = item.value
		local classification = item.classification

		-- remember lootable items
		BG.containerInInventory = BG.containerInInventory or canOpen

		local insert, sellItem = true, nil
		-- update: limits
		local itemOverLimit = BG.IsItemOverLimit(container, slot, itemLimit, itemLocations)
		if itemLimit > 0 and not itemOverLimit then
			-- limit exists, but is not yet reached
			insert = nil
			classification = BG.EXCLUDE
			reason = item.reason.." (under limit)"
		elseif itemLimit > 0 and itemOverLimit and classification == BG.EXCLUDE then
			-- inverse logic: KEEP items over limit are handled like regular items
			value, classification, classificationReason = BG.GetSingleItemValue(item, classification)
			insert = true
			reason = string.join(", ", item.reason.." (over limit)", classificationReason)
		else -- regular list behaviour: no limit or non-keep over limit
			if classification == BG.EXCLUDE then
				insert = nil
				reason = item.reason
			elseif classification == BG.INCLUDE then
				value = BG_GlobalDB.useRealValues and value or 0
				insert = true
				reason = item.reason
				sellItem = BG_GlobalDB.autoSellIncludeItems
			elseif classification == BG.AUTOSELL then
				value = item.vendorValue
				insert = true
				reason = item.reason
				sellItem = true
			end

			-- add info
			if itemLimit > 0 then
				reason = reason.." (over limit)"
			end
		end

		-- update: unusable / outdated gear
		if item.classification == BG.UNUSABLE and BG_GlobalDB.sellNotWearable and item.quality <= BG_GlobalDB.sellNWQualityTreshold then
			insert = true
			sellItem = true
			classification = BG.UNUSABLE
		elseif item.classification ~= BG.EXCLUDE and BG_GlobalDB.sellOldGear and item.quality <= BG_GlobalDB.sellNWQualityTreshold and BG.IsOutdatedItem(itemLink) then
			insert = true -- might be overridden later

			if BG_GlobalDB.keepHighestItemLevel and TopFit.GetEquipLocationsByInvType then
				local invType = select(9, GetItemInfo(itemLink))
				local slots = TopFit:GetEquipLocationsByInvType(invType)

				local keepItems = 1
				if #(slots) > 1 then
					keepItems = 2
					if slots[1] == 16 and slots[2] == 17 and TopFit.PlayerCanDualWield and not TopFit:PlayerCanDualWield() then
						keepItems = 1
					end
				end

				local itemsForInvType = {}
				for _, slot in ipairs(slots) do
					GetInventoryItemsForSlot(slot, itemsForInvType)
				end
				local itemsForSlot = {}
				for _, itemID in pairs(itemsForInvType) do
					table.insert(itemsForSlot, itemID)
				end
				table.sort(itemsForSlot, function(a, b) -- sort by itemLevel, descending
					local itemNameA, _, _, itemLevelA = GetItemInfo(a)
					local itemNameB, _, _, itemLevelB = GetItemInfo(b)
					if itemLevelA == itemLevelB then
						return itemNameA < itemNameB
					else
						return itemLevelA > itemLevelB
					end
				end)
				-- [TODO] fix situation where item is kept even though same ilvl item is equipped
				for i = 1, keepItems do
					if itemsForSlot[i] and itemsForSlot[i] == itemID then
						insert = false
						break
					end
				end
			end

			if insert then
				BG.Debug("Item is OUTDATED by TopFit.", itemID, itemLink)
				sellItem = true
				classification = BG.OUTDATED
			else
				BG.Debug("Item is OUTDATED but saved for its item level", itemID, itemLink)
				classification = BG.EXCLUDE
				reason = "OUTDATED but highest iLvl"
			end
		end

		-- update: disenchanting
		local canDE, missing = BG.CanDisenchant(itemLink)
		if BG.IsItemSoulbound(itemLink, container, slot) and (canDE or (missing and missing <= BG_GlobalDB.keepItemsForLaterDE))
			and (item.classification == BG.AUCTION or classification == BG.UNUSABLE or classification == BG.OUTDATED) then
			-- e.g. BoEs that have become soulbound
			local tempDE = BG.GetSingleItemValue(item, BG.DISENCHANT)
			local tempV  = BG.GetSingleItemValue(item, BG.VENDOR)
			if tempDE and tempDE >= tempV then
				value = tempDE
				sellItem = nil
				classification = BG.DISENCHANT

				if classification == BG.OUTDATED or classification == BG.UNUSABLE then
					if BG_GlobalDB.reportDisenchantOutdated then
						BG.Print(string.format(BG.locale.disenchantOutdated, itemLink))
					end
					reason = reason and reason.."(DE)" or nil
				end
			else
				value = item.vendorValue
				classification = BG.VENDOR
			end
		end

		-- update: visibility thresholds and sell tags
		if classification == BG.UNUSABLE or classification == BG.OUTDATED then
			-- don't handle again
		elseif classification == BG.INCLUDE then -- used to be item.classification
			-- JUNK LIST items may always show up
			insert = true
		elseif insert and item.classification == BG.AUTOSELL and item.quality <= BG_GlobalDB.sellNWQualityTreshold then
			-- use "sell threshold" for autosell items
			insert = true
			sellItem = true
		elseif insert and item.quality > BG_GlobalDB.dropQuality then
			-- not allowed, treshold surpassed
			BG.Debug("quality too high and not junk listed")
			insert = nil
		else
			-- all is well, but keep existing preference
		end

		if value == 0 and BG_GlobalDB.hideZeroValue and item.classification == BG.VENDOR then
			BG.Debug("item has zero value")
			insert = nil
		end

		-- sell irrelevant gray items
		if item.classification ~= BG.EXCLUDE and item.quality == 0 then
			sellItem = true
		end

		-- special bag? [TODO] do some thinking
		if isSpecialBag and insert and not sellItem then
			insert = nil
		end

		-- insert data
		if not insert then
			classification = BG.IGNORE
		end

		local slotValue = value * count

		if not BG.cheapestItems[itemIndex] then
			BG.cheapestItems[itemIndex] = {}
		end
		if not updateItem then
			updateItem = BG.cheapestItems[itemIndex]
		end

		updateItem.itemID = itemID
		updateItem.itemLink = itemLink
		updateItem.bag = container
		updateItem.slot = slot
		updateItem.count = count
		updateItem.value = slotValue
		updateItem.source = classification
		updateItem.reason = reason or item.reason
		updateItem.sell = (slotValue and slotValue > 0) and sellItem or nil
		updateItem.invalid = nil
	else
		-- there is no item in this slot (any more)!
		if itemIndex and BG.cheapestItems[itemIndex] then
			BG.cheapestItems[itemIndex].invalid = true
		end
	end

	-- also check other slots with this item, to update category limits etc
	if not noCheckOtherSlots and itemIndex then
		BG.Debug("Location "..container.."."..slot, "Index "..itemIndex)

		local otherLocations, maxLimit, hasLock = BG.GetItemLocations(BG.cheapestItems[itemIndex], nil, true, true, nil)
		if otherLocations and #otherLocations > 1 then
			currentItem.locations = otherLocations
			currentItem.limit = maxLimit

			BG.Debug("Also check other indices: "..table.concat(otherLocations, ", "))
			local otherItem
			for _, otherIndex in pairs(otherLocations) do
				if otherIndex ~= itemIndex then
					otherItem = BG.cheapestItems[otherIndex]
					BG.SetDynamicLabelBySlot(otherItem.bag, otherItem.slot, otherIndex, isSpecialBag, true)
				end
			end
		end
	end

	return itemIndex
end
