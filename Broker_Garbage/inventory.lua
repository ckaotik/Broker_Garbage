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
	for tableIndex, tableItem in pairs(BG.cheapestItems) do
		if not tableItem.invalid then
			isLocked = select(3, GetContainerItemInfo(tableItem.bag, tableItem.slot))
			cachedItem = BG.GetCached(tableItem.itemID)

			itemIsRelevant = nil
			if tableItem.itemID == item.itemID then
				itemIsRelevant = true
			elseif scanCategory and itemCategories and BG.IsItemInCategories(tableItem.itemID, itemCategories) then
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
	for container = 0, 4 do
		numSlots = BG.ScanInventoryContainer(container, true)
		totalSlots = totalSlots + (numSlots or 0)
	end
	BG.SortItemList()
end

function BG.ScanInventoryContainer(container, waitForFullScan)
	local numSlots = GetContainerNumSlots(container)
	if not numSlots or select(2, GetContainerNumFreeSlots(container)) ~= 0 then return end -- no (scannable) bag -or- special bag

	local newItemCount, newItemLink, itemID
	for slot = 1, numSlots do
		_, newItemCount, _, _, _, _, newItemLink = GetContainerItemInfo(container, slot)
		itemID = GetContainerItemID(container, slot)
		_ = BG.GetCached(itemID)	-- if we don't have it cached yet, do so now

		BG.UpdateInventorySlot(container, slot, newItemLink, newItemCount)
	end
	if not waitForFullScan then
		BG.SortItemList()
	end

	return numSlots
end

-- only check a specific item in a specific location
function BG.UpdateInventorySlot(container, slot, newItemLink, newItemCount)
	local slotFound = nil
	for index, item in ipairs(BG.cheapestItems or {}) do
		if item.bag == container and item.slot == slot then
			slotFound = true
			if (item.itemLink and not newItemLink) or item.itemLink ~= newItemLink then	-- update the whole item slot
				BG.Debug("Update whole slot", newItemLink)
				BG.SetDynamicLabelBySlot(container, slot, index)
			elseif item.count ~= newItemCount then	-- update the item count
				BG.Debug("Update item count", newItemLink)
				BG.cheapestItems[index].value = (BG.cheapestItems[index].value / BG.cheapestItems[index].count) * newItemCount
				BG.cheapestItems[index].count = newItemCount
			elseif item.invalid then
				BG.Debug("New item in formerly invalid slot", newItemLink)
				slotFound = false
			else
				-- BG.Debug("Item is still the same", newItemLink)
			end
			break
		end
	end

	if not slotFound and newItemLink then
		-- was previously empty/non-existant
		BG.Debug("Add new item "..(newItemLink or "nil"))
		BG.SetDynamicLabelBySlot(container, slot)
	end
end

function BG.UpdateAllDynamicItems()
	BG.ClearCache()
	wipe(BG.cheapestItems)
	BG.ScanInventory()
end

-- == Pure Logic Ahead ==
function BG.SortCheapestItemsList(a, b)
	if not (a.source == BG.IGNORE or b.source == BG.IGNORE or a.invalid or b.invalid) then
		if (a.source == b.source) or (a.source ~= BG.INCLUDE and b.source ~= BG.INCLUDE) or BG_GlobalDB.useRealValues then
			if a.value == b.value then
				return a.count < b.count
			else
				return a.value < b.value
			end
		else 
			return a.source == BG.INCLUDE
		end
	else
		if a.source == BG.IGNORE or a.invalid then
			return false
		else
			return true
		end
	end
end

function BG.UpdateItemLocations()
	for k, v in pairs(BG.itemLocations) do
		wipe(v)
	end

	local itemID, location
	local numEntries = #BG.cheapestItems

	BG.junkValue = 0
	for tableIndex, item in ipairs(BG.cheapestItems) do
		itemID = item.itemID
		locations = BG.itemLocations[itemID]

		if not item.invalid then
			if not locations then	-- new item
				BG.itemLocations[itemID] = { tableIndex }
			else -- if not BG.Find(locations, tableIndex) then	-- item is known, slot is not
				tinsert(locations, tableIndex)
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
-- [TODO] do we need to scan freshly looted items so we can determine "outdated" state?
function BG.RescanEquipmentInBags()
	local currentSlot
	for itemIndex, item in pairs(BG.cheapestItems) do
		if BG.IsItemEquipment(item.itemLink) then
			BG.SetDynamicLabelBySlot(container, slot, itemIndex)
		end
	end
end

-- checks current inventory state and assigns labels depending on limits, binding etc.
function BG.SetDynamicLabelBySlot(container, slot, itemIndex, noCheckOtherSlots)
	if not container and not slot then return end
	local item, maxValue, insert
	local _, count, _, _, _, canOpen, itemLink = GetContainerItemInfo(container, slot)
	local itemID = itemLink and BG.GetItemID(itemLink)
	local item = itemID and BG.GetCached(itemID)

	if item then
		local value = item.value
		local classification = item.classification
		
		-- remember lootable items
		BG.containerInInventory = BG.containerInInventory or canOpen

		local insert, sellItem = true, nil
		local itemOverLimit = BG.IsItemOverLimit(item, container, slot)
		if itemOverLimit and item.limit > 0 and classification == BG.EXCLUDE then
			-- inverse logic: KEEP items over limit are handled like regular items
			value, classification = BG.GetSingleItemValue(item)
			insert = true
		elseif not itemOverLimit and item.limit > 0 then
			-- limit exists, but is not yet reached
			insert = nil
		else
			-- regular list behaviour
			if classification == BG.EXCLUDE then
				insert = nil
			elseif classification == BG.INCLUDE then
				value = BG_GlobalDB.useRealValues and value or 0
				insert = true
				sellItem = BG_GlobalDB.autoSellIncludeItems
			elseif classification == BG.AUTOSELL then
				value = item.vendorValue
				insert = true
				sellItem = true
			end
		end
		
		if item.classification == BG.AUCTION and BG.IsItemSoulbound(itemLink, container, slot) then
			-- e.g. BoEs that have become soulbound
			local tempDE = BG.GetSingleItemValue(item, BG.DISENCHANT)
			local tempV = BG.GetSingleItemValue(item, BG.VENDOR)
			if tempDE and tempDE >= tempV then
				value = tempDE
				classification = BG.DISENCHANT
			else
				value = item.vendorValue
				classification = BG.VENDOR
			end
		end

		if item.classification ~= BG.EXCLUDE and BG_GlobalDB.sellOldGear 
			and item.quality <= BG_GlobalDB.sellNWQualityTreshold and BG.IsOutdatedItem(itemLink) then

			insert = true
			if item.classification == BG.DISENCHANT and BG_GlobalDB.reportDisenchantOutdated then
				BG.Print(string.format(BG.locale.disenchantOutdated, itemLink))
			else
				BG.Debug("Item is OUTDATED by TopFit.", itemID, itemLink)
				classification = BG.OUTDATED
				sellItem = true
			end
		end

		-- allowed tresholds
		if item.quality <= BG_GlobalDB.sellNWQualityTreshold and 
			((item.classification == BG.AUTOSELL and insert) or 
			(item.classification == BG.UNUSABLE and BG_GlobalDB.sellNotWearable) or
			(classification == BG.OUTDATED and BG_GlobalDB.sellNotWearable)) then
			
			insert = true
			sellItem = true
		elseif item.quality > BG_GlobalDB.dropQuality then
			-- JUNK LIST items may always show up
			if item.classification == BG.INCLUDE then
				insert = true
			else
				-- not allowed, treshold surpassed
				BG.Debug("quality too high and not junk "..itemLink)
				insert = nil
			end
		else
			-- all is well, but keep existing preference
		end
		
		if value == 0 and BG_GlobalDB.hideZeroValue and item.classification == BG.VENDOR then
			insert = nil
			BG.Debug("zero value, hidden "..itemLink)
		end	

		-- sell irrelevant gray items
		if item.classification ~= BG.EXCLUDE and item.quality == 0 then
			sellItem = true
		end

		-- insert data
		if not insert then
			classification = BG.IGNORE
		end

		BG.Debug("Adding item to table "..itemLink)
		if not BG.cheapestItems then
			BG.cheapestItems = {}
		end
		if not itemIndex then
			-- create new item entry
			itemIndex = #BG.cheapestItems + 1
		end
		if not BG.cheapestItems[itemIndex] then
			BG.cheapestItems[itemIndex] = {}
		end
		local updateItem = BG.cheapestItems[itemIndex]
		local slotValue = value * count

		updateItem.itemID = itemID
		updateItem.itemLink = itemLink
		updateItem.bag = container
		updateItem.slot = slot
		updateItem.count = count
		updateItem.value = slotValue
		updateItem.source = classification
		updateItem.sell = (slotValue and slotValue > 0) and sellItem or nil
		updateItem.invalid = nil
	else
		-- there is no item in this slot (any more)!
		if itemIndex and BG.cheapestItems[itemIndex] then
			BG.cheapestItems[itemIndex].invalid = true
		end
	end

	if not noCheckOtherSlots and itemIndex then
		local otherLocations, maxLimit, hasLock = BG.GetItemLocations(BG.cheapestItems[itemIndex], nil, true, true, nil)
		local otherItem
		for _, otherIndex in ipairs(otherLocations) do
			otherItem = BG.cheapestItems[otherIndex]
			BG.SetDynamicLabelBySlot(otherItem.bag, otherItem.slot, otherIndex, true)
		end
	end

	return itemIndex
end