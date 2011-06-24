local _, BG = ...

-- == Finding things in your inventory ==
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

-- finds all occurences of the given item; returns table sorted by relevance (lowest first)
function BG.GetItemLocations(item, ignoreFullStacks, includeLocked)	-- itemID/CategoryString[, bool/nil]
	local isCategory = type(item) == "string"
	local locations = {}
	
	local numSlots, freeSlots, ratio, bagType, locked
	local itemID, itemCount, itemLevel, itemLink, itemIsRelevant, isLocked
	local maxStack = select(8, GetItemInfo(item))
	if not maxStack then maxStack = 20 end
	
	for container = 0, NUM_BAG_SLOTS do
		numSlots = GetContainerNumSlots(container)
		freeSlots, bagType = GetContainerNumFreeSlots(container)
		
		if item and numSlots then
			ratio = freeSlots/numSlots
			for slot = 1, numSlots do
				_, itemCount, isLocked, _, _, _, itemLink = GetContainerItemInfo(container, slot)
				itemID = itemLink and BG.GetItemID(itemLink)

				if itemID then
					itemLevel = select(4, GetItemInfo(item))
					itemIsRelevant = ((isCategory and BG.IsItemInCategory(itemID, item)) or itemID == item)
					
					if itemIsRelevant and (not isLocked or includeLocked) and (not ignoreFullStacks or itemCount < maxStack) then
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
					if itemIsRelevant and isLocked then
						locked = true
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
	return locations, locked
end

-- moves an item from A to B
-- CAUTION: Call ClearCursor() straight after this!
function BG.MoveItem(itemID, fromBag, fromSlot, toBag, toSlot)
	if GetContainerItemID(fromBag, fromSlot) ~= itemID then
		BG.Print("Error! Item to move does not match requested item.")
		return
	end
	local targetLocked = select(3, GetContainerItemInfo(toBag, toSlot))
	if targetLocked then
		BG.Print("Error! Can't move item: Target location is locked.")
		BG.Debug("From", fromBag, fromSlot, "to", toBag, toSlot)
	end
	ClearCursor()
	securecall(PickupContainerItem, fromBag, fromSlot)
	securecall(PickupContainerItem, toBag, toSlot)
end

function BG.PutIntoBestContainer(curBag, curSlot)
	local itemID = GetContainerItemID(curBag, curSlot)
	local itemFamily = itemID and GetItemFamily(itemID)
	if not itemID or itemFamily == 0 then return end 	-- empty slots / general items

	local bestContainer, freeSlots, bagType
	for container = 0, NUM_BAG_SLOTS do
		freeSlots, bagType = GetContainerNumFreeSlots(container)

		if freeSlots > 0 and container ~= curBag and bit.band(itemFamily, bagType) > 0 and bagType ~= 0 then
			bestContainer = container
		end
	end
	if bestContainer then
		local targetSlots = GetContainerFreeSlots(bestContainer)
		BG.MoveItem(itemID, curBag, curSlot, bestContainer, targetSlots[1])
	end
end

-- initialize full inventory restacking
-- [TODO] maybe also check bank?
function BG.DoFullRestack()
	local numSlots = 0
	local justStacked = {}
	BG.locked = true
	
	local recursive = nil
	for container = 0, NUM_BAG_SLOTS do
		numSlots = GetContainerNumSlots(container)
		if numSlots then
			for slot = 1, numSlots do
				local itemID = GetContainerItemID(container, slot)
				local _, _, isLocked = GetContainerItemInfo(container, slot)

				if itemID and not BG.Find(justStacked, itemID) then
					recursive = recursive or BG.Restack(itemID)
					table.insert(justStacked, itemID)
				end
			end
		end
	end
	if recursive then
		BG.Debug("Restack: More work to do.")
		BG.CallWithDelay(BG.DoFullRestack, 1)
	else
		-- no extra scanning because ITEM_UNLOCKED fires rather late and causes scanning
		wipe(BG.currentRestackItems)
		BG.locked = nil
	end

	for container = 0, NUM_BAG_SLOTS do
		for slot = 1, GetContainerNumSlots(container) do
			BG.PutIntoBestContainer(container, slot)
		end
	end
end

-- register an item for restacking and manage each step
-- CAUTION: When called manually, make sure to wipe(BG.currentRestackItems) afterwards
function BG.Restack(itemID)
	if itemID then tinsert(BG.currentRestackItems, itemID) end

	-- run one restack step and handle results
	local stillRestacking, hasItemLock = BG.RestackStep()
	if stillRestacking then
		BG.frame:RegisterEvent("ITEM_UNLOCKED")
	else
		-- BG.Debug("Nothing left to restack", "Unregistered ITEM_UNLOCKED")
		BG.frame:UnregisterEvent("ITEM_UNLOCKED")

		ClearCursor()	-- sometimes items get stuck, eww
		if BG.afterRestack ~= nil then
			BG.afterRestack()
			BG.afterRestack = nil
		end
	end
	return hasItemLock
end

-- single restack step, moves one item from A to B
function BG.RestackStep()
	local itemID = BG.currentRestackItems[1]
	local count = itemID and GetItemCount(itemID)

	if #(BG.currentRestackItems) <= 0 then
		return false
	elseif not itemID or not count or count <= 1 then
		-- BG.Debug("No need to restack", itemID)
		tremove(BG.currentRestackItems, 1)
		return BG.RestackStep()
	else
		local locations, hasItemLock = BG.GetItemLocations(itemID, true)
		local maxLoc = #locations
		if maxLoc <= 1 then
			BG.Debug("Restacking", itemID, "complete.")
			tremove(BG.currentRestackItems, 1)
			return BG.RestackStep()
		end

		BG.Debug("RestackStep", itemID, count, maxLoc)
		if GetContainerItemInfo(locations[1].bag, locations[1].slot) then
			BG.MoveItem(itemID, locations[1].bag, locations[1].slot, locations[maxLoc].bag, locations[maxLoc].slot)
			BG.Debug("Restack from/to", locations[1].count, locations[maxLoc].count)
		end
		return true, hasItemLock
	end
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
		local vendorValue = select(11, GetItemInfo(itemID))
		local classification = item.classification
		
		-- remember lootable items
		BG.containerInInventory = BG.containerInInventory or canOpen

		local insert, sellItem = true, nil
		if BG.IsItemOverLimit(item, container, slot) and (item.classification ~= BG.EXCLUDE or item.limit ~= 0) then
			-- over limit items are handled according to their lists
			if item.classification == BG.EXCLUDE then	
				-- Inverse logic! KEEP items over limit are handled like regular items
				value, label = BG.GetSingleItemValue(item)
				insert = true

			elseif item.classification == BG.INCLUDE then
				value = BG_GlobalDB.useRealValues and value or 0
				insert = true
				sellItem = BG_GlobalDB.autoSellIncludeItems
				
			elseif item.classification == BG.AUTOSELL then
				value = vendorValue
				insert = true
				sellItem = true
			end
		else
			-- items on KEEP LIST w/o a limit or on other lists, under limit, are kept
			BG.Debug("limit not yet reached "..itemLink)
			insert = false
		end
		
		-- [TODO] check whether DISENCHANT would be a better option
		if item.classification == BG.AUCTION and BG.IsItemSoulbound(itemLink, container, slot) then
			value = vendorValue
			classification = BG.VENDOR
		end

		-- [TODO] Alternative: Listen for EQUIPMENT_SETS_CHANGED / PLAYER_EQUIPMENT_CHANGED and re-check all equipment items in the inventory; Also check when new equipment is looted ... iergs
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
		updateItem.sell = (slotValue and slotValue>0 and sellItem or nil)
		updateItem.invalid = nil
	else
		-- there is no item in this slot (any more)!
		if itemIndex and BG.cheapestItems[itemIndex] then
			BG.cheapestItems[itemIndex].invalid = true
		end
	end
	return itemIndex
end