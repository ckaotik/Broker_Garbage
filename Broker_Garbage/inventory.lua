local _, BG = ...

-- == Finding things in your inventory ==
function BG.FindItemInBags(item)
	for container = 0, 4 do
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

-- finds all occurences of the given item; returns table sorted by relevance (lowest first)
function BG.GetItemLocations(item, ignoreFullStacks)	-- itemID/CategoryString[, bool/nil]
	local isCategory = type(item) == "string"
	local locations = {}
	
	local numSlots, freeSlots, ratio, bagType
	local itemID, itemCount, itemLevel, itemLink, itemIsRelevant, isLocked
	local maxStack = select(8, GetItemInfo(item))
	if not maxStack then maxStack = 20 end
	
	for container = 0,4 do
		numSlots = GetContainerNumSlots(container)
		freeSlots, bagType = GetContainerFreeSlots(container)
		freeSlots = freeSlots and #freeSlots or 0
		
		if item and numSlots then
			ratio = freeSlots/numSlots
			for slot = 1, numSlots do
				_, itemCount, isLocked, _, _, _, itemLink = GetContainerItemInfo(container, slot)
				itemID = itemLink and BG.GetItemID(itemLink)

				if itemID then
					itemLevel = select(4, GetItemInfo(item))
					itemIsRelevant = ((isCategory and BG.IsItemInCategory(itemID, item)) or itemID == item)
					
					if itemIsRelevant and not isLocked and (not ignoreFullStacks or itemCount < maxStack) then
						-- found a slot with relevant items
						table.insert(locations, {
							slot = slot, 
							bag = container, 
							count = itemCount, 
							ratio = ratio, 
							level = itemLevel,
							bagType = (bagType or 0)
						})
					end
				end
			end
		end
	end
	
	-- recommend the location with the largest count or ratio that is NOT a specialty bag
	table.sort(locations, function(a,b)
		if a.bagType ~= b.bagType then
			return a.bagType == 0
		else
			if a.itemLevel == b.itemLevel then
				if a.count == b.count then
					return a.ratio > b.ratio
				else
					return a.count < b.count
				end
			else
				return a.itemLevel < b.itemLevel
			end
		end
	end)
	return locations
end

function BG.UpdateAllCaches(itemID)
	local cheapestItem

	BG.UpdateCache(itemID)
	for _, itemIndex in pairs(BG.itemLocations[itemID]) do
		cheapestItem = BG.cheapestItems[itemIndex]
		BG.SetDynamicLabelBySlot(cheapestItem.bag, cheapestItem.slot, itemIndex)
	end
	BG.ScanInventory()
	BG.UpdateLDB()
end

-- == Inventory Scanning ==
-- [TODO] also update whenever the number/size/?? of bags change!
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
			if not newItemLink or item.itemLink ~= newItemLink then	-- update the whole item slot
				BG.Debug("Update whole slot", newItemLink)
				BG.SetDynamicLabelBySlot(container, slot, index)
			elseif item.count ~= newItemCount then	-- update the item count
				BG.Debug("Update item count", newItemLink)
				BG.cheapestItems[index].count = newItemCount
			elseif item.invalid then
				BG.Debug("New item in formerly invalid slot", newItemLink)
				slotFound = false
			else
				BG.Debug("Item is still the same", newItemLink)
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

			if item.sell and item.value and item.count then
				BG.junkValue = BG.junkValue + (item.value * item.count)
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

-- [TODO] update all slots of the same item!! otherwise limits will be incorrect
function BG.SetDynamicLabelBySlot(container, slot, itemIndex)
	if not container and not slot then return end
	local item, maxValue, insert
	local _, count, _, _, _, canOpen, itemLink = GetContainerItemInfo(container, slot)
	local itemID = itemLink and BG.GetItemID(itemLink)
	local item = itemID and BG.GetCached(itemID)

	if item then
		local value = item.value
		local vendorValue = select(11, GetItemInfo(itemID)) * count
		local classification = item.classification
		
		-- remember lootable items
		BG.containerInInventory = BG.containerInInventory or canOpen

		local insert, sellItem = true, nil
		if item.limit == 0 then
			-- items without limits are regular items
			insert = item.classification ~= BG.EXCLUDE
		
		elseif BG.IsItemOverLimit(item, container, slot) then
			-- over limit items are handled according to their lists
			if item.classification == BG.EXCLUDE then	-- Caution! Inverse logic!
				value, label = BG.GetSingleItemValue(item)
				value = value * count
				insert = true

			elseif item.classification == BG.INCLUDE then
				value = BG_GlobalDB.useRealValues and (value * count) or 0
				insert = true
				sellItem = BG_GlobalDB.autoSellIncludeItems
				
			elseif item.classification == BG.AUTOSELL then
				value = vendorValue
				insert = true
				sellItem = true
			end
		else
			-- items under limit are kept, no matter what
			BG.Debug("limit not yet reached "..itemLink)
			insert = false
		end
		
		-- [TODO] check whether DISENCHANT would be a better option
		if item.classification == BG.AUCTION and BG.IsItemSoulbound(itemLink, container, slot) then
			value = vendorValue
			classification = BG.VENDOR
		end

		-- [TODO] Alternative: Listen for EQUIPMENT_SETS_CHANGED / PLAYER_EQUIPMENT_CHANGED and re-check all equipment items in the inventory; Also check when new equipment is looted ... iergs
		if BG_GlobalDB.sellOldGear and item.quality <= BG_GlobalDB.sellNWQualityTreshold and BG.IsOutdatedItem(itemLink) then
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
		if item.quality <= BG_GlobalDB.sellNWQualityTreshold and BG_GlobalDB.sellNotWearable and 
			(item.classification == BG.UNUSABLE or classification == BG.OUTDATED) then	-- don't add "item." here!
			insert = true
			sellItem = true
		elseif item.quality > BG_GlobalDB.dropQuality and 
			(item.classification == BG.INCLUDE) then
			insert = true
		elseif item.quality > BG_GlobalDB.dropQuality then
			-- not allowed, treshold surpassed
			BG.Debug("quality too high and not junk "..itemLink)
			insert = false
		else
			-- all is well, but keep existing preference
		end
		
		if value == 0 and BG_GlobalDB.hideZeroValue and item.classification == BG.VENDOR then
			insert = false
			BG.Debug("zero value, hidden "..itemLink)
		end	

		if item.classification ~= BG.EXCLUDE and item.quality == 0 then
			sellItem = true
		end

		-- insert data
		if not insert then
			classification = BG.IGNORE
		end

		BG.Debug("Adding item to table "..itemLink)
		if not itemIndex then
			-- create new item entry
			itemIndex = #BG.cheapestItems + 1
		end
		if not BG.cheapestItems[itemIndex] then
			BG.cheapestItems[itemIndex] = {}
		end
		local updateItem = BG.cheapestItems[itemIndex]

		updateItem.itemID = itemID
		updateItem.itemLink = itemLink
		updateItem.bag = container
		updateItem.slot = slot
		updateItem.count = count
		updateItem.value = value
		updateItem.source = classification
		updateItem.sell = sellItem
		updateItem.invalid = nil
	else
		-- there is no item in this slot (any more)!
		if itemIndex and BG.cheapestItems[itemIndex] then
			BG.cheapestItems[itemIndex].invalid = true
		end
	end
	return itemIndex
end