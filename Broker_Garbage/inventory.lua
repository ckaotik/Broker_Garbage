local _, BG = ...

-- GLOBALS: BG_GlobalDB, BG_LocalDB, NUM_BAG_SLOTS, TopFit
-- GLOBALS: GetContainerNumSlots, GetContainerNumFreeSlots, GetContainerItemLink, GetContainerItemID, GetContainerItemInfo, GetItemInfo, GetInventoryItemsForSlot, GetItemFamily, IsEquippedItem
local type = type
local pairs = pairs
local ipairs = ipairs
local wipe = wipe
local select = select
local band = bit.band
local sort = table.sort
local concat = table.concat
local tinsert = table.insert
local tremove = table.remove
local format = string.format
local join = string.join
local find = string.find

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

		if freeSlots > 0 and band(itemFamily, bagType) > 0 and bagType ~= 0 then
			bestContainer = container
			bestFreeSlots, bestBagType = freeSlots, bagType
		end
	end
	return bestContainer, bestFreeSlots, bestBagType
end

-- order by: level ASC, vendorValue ASC, count ASC, itemID ASC
local function SortItemLocations(a, b)
	local itemA, itemB = BG.cheapestItems[a], BG.cheapestItems[b]

	local bagTypeA = select(2, GetContainerNumFreeSlots(itemA.bag))
	local bagTypeB = select(2, GetContainerNumFreeSlots(itemB.bag))

	if bagTypeA ~= bagTypeB then
		return bagTypeA < bagTypeB
	else
		local cacheA = BG.GetCached(itemA.itemID)
		local cacheB = BG.GetCached(itemB.itemID)

		if cacheA.level == cacheB.level then
			if cacheA.vendorValue == cacheB.vendorValue then
				if itemA.count == itemB.count then
					return itemA.itemID < itemB.itemID
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
end
-- finds all occurences of the given item or its category; returns table sorted by relevance (lowest first); item :: <itemTable>
-- if called with ignoreFullStacks == true, will return table copy instead of reference to cache
function BG.GetItemLocations(item, ignoreFullStacks)
	if not item then
		return nil
	elseif (type(item) == "number" or type(item) == "string") then
		-- in case we got an item link
		item = BG.GetItemID(item) or item
	elseif type(item) == "table" then
		item = item.itemID
	end

	local locations = BG.locationsCache[item]
	if locations then
		-- make use of locations cache
		if ignoreFullStacks then
			local tmp = {}
			for _,location in pairs(locations) do
				tinsert(tmp, location)
			end
			locations = tmp

			local location, cheapestItem, cachedItem
			for i = #(locations or {}), 1, -1 do
				location = locations[i]
				cheapestItem = BG.cheapestItems[location]
				cachedItem = BG.GetCached(cheapestItem.itemID)
				if cheapestItem.count == cachedItem.stackSize then
					tremove(locations, i)
				end
			end
		end
	else
		-- can't use cache, construct manually
		local cachedItem
		local isCategoryScan = type(item) ~= "number"

		for tableIndex, tableItem in pairs(BG.cheapestItems) do
			if not tableItem.invalid then
				cachedItem = BG.GetCached(tableItem.itemID)

				if (isCategoryScan and BG.IsItemInCategory(tableItem.itemID, item)) or (tableItem.itemID == item) then
					if not ignoreFullStacks or tableItem.count < cachedItem.stackSize then
						if not locations then locations = {} end
						tinsert(locations, tableIndex)
					end
				end
			end
		end
		--[[if not BG.locationsCache[item] then
			BG.locationsCache[item] = locations
		end--]]
	end

	-- tell them what we found
	if locations then
		sort(locations, SortItemLocations)
		return locations
	end
end

function BG.UpdateAllCaches(itemID)
	if not itemID or type(itemID) ~= "number" then
		BG.Debug("UpdateAllCaches - no or invalid argument!")
		return
	end
	BG.UpdateCache(itemID)

	local cheapestItem
	for _, itemIndex in pairs(BG.locationsCache[itemID] or {}) do
		cheapestItem = BG.cheapestItems[itemIndex]
		BG.SetDynamicLabelBySlot(cheapestItem.bag, cheapestItem.slot, itemIndex)
	end
	BG.ScanInventory()
	BG.UpdateLDB()
end

-- == Inventory Scanning ==
function BG.ScanInventory(firstScan)
	BG.containerInInventory = false
	for container = 0, NUM_BAG_SLOTS do
		_ = BG.ScanInventoryContainer(container, firstScan)
	end
	BG.SortItemList()
end

function BG.ScanInventoryContainer(container, firstScan)
	local numSlots = GetContainerNumSlots(container)
	if not numSlots then return end -- no (scannable) bag

	local isSpecialBag = select(2, GetContainerNumFreeSlots(container)) ~= 0
	local newItemCount, newItemLink, itemID, listIndex
	local otherLocations, otherLocation

	for slot = 1, numSlots do
		_, newItemCount, _, _, _, _, newItemLink = GetContainerItemInfo(container, slot)
		listIndex, otherLocations = BG.UpdateInventorySlot(container, slot, newItemLink, newItemCount)
		if listIndex then
			BG.SetDynamicLabelBySlot(container, slot, listIndex, isSpecialBag)
		end
		if otherLocations and not firstScan then
			for _, location in ipairs(otherLocations) do
				otherLocation = BG.cheapestItems[location]
				if otherLocation.bag ~= container and otherLocation.slot ~= slot then
					BG.Debug(container+slot/100, "changed, also update", location, (select(2, GetItemInfo(otherLocation.itemID))), "at", otherLocation.bag+otherLocation.slot/100)
					BG.SetDynamicLabelBySlot(otherLocation.bag, otherLocation.slot, location)
				end
			end
		end
	end

	return numSlots
end

-- only check a specific item in a specific location
function BG.UpdateInventorySlot(container, slot, newItemLink, newItemCount)
	local tableIndex, recheck, item = nil, nil, nil
	local changed, cachedItem, otherLocations = 0, nil, nil -- changed: update based on <-1:old|+1:new> item
	local newItemID = newItemLink and BG.GetItemID(newItemLink)

	local listIndex = BG.GetListIndex(container, slot, true)
	local slotString = container + slot/100

	if listIndex then
		item = BG.cheapestItems[listIndex]

		if newItemID and item.invalid then
			BG.Debug("Enable", slotString, newItemID)
			item.invalid = nil
			recheck = true
			changed = 1
		elseif item.itemID and not newItemID and not item.invalid then
			-- tag data as invalid
			BG.Debug("Disable", slotString, item.itemID)
			item.invalid = true
			changed = -1

		elseif item.itemID and newItemID then
			if item.itemID ~= newItemID then
				-- update the whole item slot
				BG.Debug("Update", slotString, newItemID)
				recheck = true
				changed = -1 -- new partners get updated anyway, so only focus on old partners
			elseif item.count ~= newItemCount then
				-- update the item count
				BG.Debug("Update count", slotString, newItemID)
				BG.cheapestItems[listIndex].value = (BG.cheapestItems[listIndex].value / BG.cheapestItems[listIndex].count) * newItemCount
				BG.cheapestItems[listIndex].count = newItemCount
				changed = -1
			else
				-- BG.Debug("Item unchanged", slotString, newItemID)
			end
		end

		if changed ~= 0 then
			-- scan correlating slots, too
			item = BG.GetCached(changed > 0 and newItemID or item.itemID)
			if item and item.limiter then
				otherLocations = BG.locationsCache[item.limiter]
				if otherLocations and #(otherLocations) == 1 then
					otherLocations = nil
				end
			end
		end
	end

	if newItemID and (not listIndex or recheck) then
		-- 0 as placeholder for previously invalid slots
		listIndex = listIndex or 0
	end

	return listIndex, otherLocations
end

function BG.UpdateAllDynamicItems()
	BG.ClearCache()
	wipe(BG.cheapestItems)
	BG.ScanInventory()
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

function BG.SyncItemLocations()
	BG.junkValue = 0

	local numEntries, itemID, cachedItem = #BG.cheapestItems, nil, nil

	wipe(BG.locationsCache)
	for tableIndex, cheapestItem in ipairs(BG.cheapestItems) do
		if not cheapestItem.invalid then
			itemID = cheapestItem.itemID
			-- caching per itemID
			if not BG.locationsCache[itemID] then
				BG.locationsCache[itemID] = {}
			end
			tinsert(BG.locationsCache[itemID], tableIndex)

			-- caching per itemLimit category
			cachedItem = BG.GetCached(itemID)
			if cachedItem.limiter then
				if not BG.locationsCache[cachedItem.limiter] then
					BG.locationsCache[cachedItem.limiter] = {}
				end
				tinsert(BG.locationsCache[cachedItem.limiter], tableIndex)
			end

			-- while we're at it, update junk/sell values
			if cheapestItem.sell and cheapestItem.value and cheapestItem.value ~= 0 and cheapestItem.count then
				BG.junkValue = BG.junkValue + cheapestItem.value
			end
		end
	end
end

-- sort item list and updates LDB accordingly
function BG.SortItemList()
	sort(BG.cheapestItems, BG.SortCheapestItemsList)
	BG.SyncItemLocations()
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
function BG.SetDynamicLabelBySlot(container, slot, itemIndex, isSpecialBag)
	if not (container and slot) then return end

	local insert, reason, classificationReason
	local _, count, _, _, _, canOpen, itemLink = GetContainerItemInfo(container, slot)
	local itemID = itemLink and BG.GetItemID(itemLink)
	local item = itemID and BG.GetCached(itemID)

	if not itemIndex or itemIndex < 1 then
		-- create new item entry
		itemIndex = #BG.cheapestItems + 1
	end
	local updateItem = BG.cheapestItems[itemIndex]

	-- relevant when called from somewhere else
	if not item or (updateItem and updateItem.invalid) then
		return itemIndex
	end

	-- initial values, will get overridden if necessary
	local value = item.value
	local classification = item.classification

	-- remember lootable items
	BG.containerInInventory = BG.containerInInventory or canOpen

	local insert, sellItem = true, nil
	-- update: limits
	local itemOverLimit = BG.IsItemOverLimit(container, slot, item.limit)
	if item.limit > 0 and not itemOverLimit then
		-- limit exists, but is not yet reached
		insert = nil
		classification = BG.EXCLUDE
		reason = (item.reason and item.reason.." " or "") .. "(under limit)"
	elseif item.limit > 0 and itemOverLimit and classification == BG.EXCLUDE then
		-- inverse logic: KEEP items over limit are handled like regular items
		value, classification, classificationReason = BG.GetSingleItemValue(item, classification)
		insert = true
		reason = join(", ", item.reason.." (over limit)", classificationReason)
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
		if item.limit > 0 then
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
				if not BG.Find(itemsForSlot, itemID) then
					tinsert(itemsForSlot, itemID)
				end
			end
			sort(itemsForSlot, function(a, b) -- sort by itemLevel, descending
				if not a or not GetItemInfo(a) then
					BG.Dump(itemsForSlot, true)
				end
				local itemNameA, _, _, itemLevelA = GetItemInfo(a)
				local itemNameB, _, _, itemLevelB = GetItemInfo(b)

				if itemLevelA == itemLevelB then
					if IsEquippedItem(itemNameA) == IsEquippedItem(itemNameB) then
						return itemNameA < itemNameB
					else
						-- equipped item has priority
						return IsEquippedItem(itemNameA)
					end
				else
					return itemLevelA > itemLevelB
				end
			end)
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
	if (item.classification == BG.AUCTION or classification == BG.UNUSABLE or classification == BG.OUTDATED)
		and (canDE or (missing and missing <= BG_GlobalDB.keepItemsForLaterDE)) and BG.IsItemSoulbound(itemLink, container, slot) then
		-- e.g. BoEs that have become soulbound
		local tempDE = BG.GetSingleItemValue(item, BG.DISENCHANT)
		local tempV  = BG.GetSingleItemValue(item, BG.VENDOR)
		if tempDE and tempDE >= tempV then
			value = tempDE
			sellItem = nil
			classification = BG.DISENCHANT

			if classification == BG.OUTDATED or classification == BG.UNUSABLE then
				if BG_GlobalDB.reportDisenchantOutdated then
					BG.Print(format(BG.locale.disenchantOutdated, itemLink))
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
	elseif classification == BG.INCLUDE then
		-- JUNK LIST items may always show up
		insert = true
	elseif insert and classification == BG.AUTOSELL and item.quality <= BG_GlobalDB.sellNWQualityTreshold then
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
	if classification ~= BG.EXCLUDE and item.quality == 0 then
		sellItem = true
	end

	-- ignore things that are in special bags
	if isSpecialBag == nil then
		isSpecialBag = select(2, GetContainerNumFreeSlots(container)) ~= 0
	end
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
	updateItem.bag = container
	updateItem.slot = slot
	updateItem.count = count
	updateItem.value = slotValue
	updateItem.source = classification
	updateItem.reason = reason or item.reason
	updateItem.sell = (slotValue and slotValue > 0) and sellItem or nil
	updateItem.invalid = nil
end
