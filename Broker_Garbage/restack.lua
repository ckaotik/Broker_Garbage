local _, BG = ...

BG.currentRestackItem = nil

-- initialize full inventory restacking
-- [TODO] maybe also check bank?
local restackIDs = {}
function BG.DoFullRestack(isRecursion)
	if not isRecursion then
		-- fill list of inventory itemIDs so we know what to restack
		for container = 0, NUM_BAG_SLOTS do
			for slot = 1, (GetContainerNumSlots(container) or 0) do
				local itemID = GetContainerItemID(container, slot)

				if itemID and not restackIDs[itemID] then
					restackIDs[itemID] = true
				end
			end
		end
	end

	-- do restacking for each itemID
	local recursive = nil
	for itemID, _ in pairs(restackIDs) do
		BG.currentRestackItem = itemID
		recursive = recursive or BG.Restack(itemID)
	end

	if recursive then
		BG.Debug("Restack: More work to do.")
		BG.CallWithDelay(BG.DoFullRestack, 1, true)

	else
		-- almost done; move appropriate stacks into specialty bags
		local usedSlots = {}
		for container = 0, NUM_BAG_SLOTS do
			for slot = 1, GetContainerNumSlots(container) do
				BG.PutIntoBestContainer(container, slot, usedSlots)
			end
		end
		wipe(usedSlots); usedSlots = nil
		wipe(restackIDs)

		if BG.afterRestack ~= nil then
			BG.afterRestack()
			BG.afterRestack = nil
		end
		BG.Debug("Full restack completed.")
	end
end

-- register an item for restacking and manage each step
-- [TODO] also restack when crafting (e.g. gems) and collecting mail items
function BG.Restack(itemID)
	itemID = itemID or BG.currentRestackItem
	local item = itemID and BG.GetCached(itemID)
	if not itemID or not item then
		return nil
	end

	local locations = BG.GetItemLocations(item, true, true)
	local stillRestacking = BG.RestackStep(itemID, locations, item.stackSize)

	if stillRestacking then
		-- ITEM_UNLOCKED provokes BG.RestackStep()
		BG.frame:RegisterEvent("ITEM_UNLOCKED")
	else
		BG.Debug("All done for "..itemID)
		BG.frame:UnregisterEvent("ITEM_UNLOCKED")
		BG.currentRestackItem = nil
	end
	_, _, hasItemLock = BG.GetItemLocations(BG.GetCached(itemID), true)
	return hasItemLock
end

-- single restack step, moves one item from A to B, returns true if more moving actions are required for this item
function BG.RestackStep(itemID, locations, stackSize)
	if not itemID then
		BG.Print("Error! Don't know which item to restack")
		return nil
	end
	local maxLoc = locations and #(locations)

	if not maxLoc or maxLoc <= 1 then
		restackIDs[ itemID ] = nil
		return nil
	else
		local moveFrom, moveTo = BG.cheapestItems[ locations[1] ], BG.cheapestItems[ locations[maxLoc] ]
		local _, sourceCount = GetContainerItemInfo(moveFrom.bag, moveFrom.slot)
		local _, targetCount = GetContainerItemInfo(moveTo.bag, moveTo.slot)

		-- BG.Dump(locations)
		-- BG.Dump({bag = moveFrom.bag, slot = moveFrom.slot, count = sourceCount})
		-- BG.Dump({bag = moveTo.bag, slot = moveTo.slot, count = targetCount})

		if not sourceCount then
			tremove(locations, 1)
			return BG.RestackStep(itemID, locations, stackSize)
		end
		-- remove full/empty target steps
		if not targetCount or targetCount == stackSize then
			tremove(locations, maxLoc)
			return BG.RestackStep(itemID, locations, stackSize)
		end

		local itemWasMoved = BG.MoveItem(itemID, moveFrom.bag, moveFrom.slot, moveTo.bag, moveTo.slot, locations[1])
		-- only remove location if it's now empty
		if sourceCount + targetCount <= stackSize then
			tremove(locations, 1)
		end

		if not moveFrom.invalid and itemWasMoved == nil then
			BG.Debug("Moving failed", itemID, moveFrom.bag.."."..moveFrom.slot, 'to', moveTo.bag.."."..moveTo.slot)
			tremove(locations, 1)	-- couldn't move the item, so don't try this one again
		else
			tremove(locations, 1)
		end
		return true
	end
end

function BG.PutIntoBestContainer(curBag, curSlot, usedSlots)
	local itemID = GetContainerItemID(curBag, curSlot)
	local itemFamily = itemID and GetItemFamily(itemID)
	if not itemID or itemFamily == 0 then return end 	-- empty slots / general items

	local bestContainer = BG.FindBestContainerForItem(itemID, itemFamily)
	if bestContainer then
		local targetSlots = GetContainerFreeSlots(bestContainer)
		for i, slot in pairs(targetSlots) do
			if BG.Find(usedSlots, bestContainer..slot) then
				table.remove(targetSlots, i)
			end
		end
		if #targetSlots ~= 0 then
			BG.MoveItem(itemID, curBag, curSlot, bestContainer, targetSlots[1])
			table.insert(usedSlots, bestContainer..targetSlots[1])
		else
			BG.Debug("No more room in target bag!")
		end
	end
	return bestContainer, bestSlot
end

-- moves an item from A to B
-- CAUTION: Call ClearCursor() straight after this!
function BG.MoveItem(itemID, fromBag, fromSlot, toBag, toSlot, listIndex)
	if not (fromBag and fromSlot and toBag and toSlot) then return nil end
	BG.Debug("From", fromBag.."."..fromSlot, "to", toBag.."."..toSlot)
	if GetContainerItemID(fromBag, fromSlot) ~= itemID then
		BG.Print("Error! Item to move does not match requested item.")
		return nil
	end
	local targetLocked = select(3, GetContainerItemInfo(toBag, toSlot))
	if targetLocked then
		BG.Print("Error! Can't move item: Target location is locked.")
		return false
	end
	ClearCursor()
	securecall(PickupContainerItem, fromBag, fromSlot)
	securecall(PickupContainerItem, toBag, toSlot)

	-- this slot was modified, mark it as invalid
	BG.cheapestItems[ listIndex ].invalid = true
	return true
end
