local _, BG = ...

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

	local usedSlots = {}
	for container = 0, NUM_BAG_SLOTS do
		for slot = 1, GetContainerNumSlots(container) do
			BG.PutIntoBestContainer(container, slot, usedSlots)
		end
	end
	wipe(usedSlots); usedSlots = nil
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
function BG.MoveItem(itemID, fromBag, fromSlot, toBag, toSlot)
	BG.Debug("From", fromBag, fromSlot, "to", toBag, toSlot)
	if GetContainerItemID(fromBag, fromSlot) ~= itemID then
		BG.Print("Error! Item to move does not match requested item.")
		return nil
	end
	local targetLocked = select(3, GetContainerItemInfo(toBag, toSlot))
	if targetLocked then
		BG.Print("Error! Can't move item: Target location is locked.")
		-- BG.Debug("From", fromBag, fromSlot, "to", toBag, toSlot)
		return nil
	end
	ClearCursor()
	securecall(PickupContainerItem, fromBag, fromSlot)
	securecall(PickupContainerItem, toBag, toSlot)
	return true
end

-- register an item for restacking and manage each step
-- CAUTION: When called manually, make sure to wipe(BG.currentRestackItems) afterwards
-- [TODO] also restack when crafting (e.g. gems) and collecting mail items
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
	end

	local locations, _, hasItemLock = BG.GetItemLocations(BG.GetCached(itemID), true)
	if not itemID or not count or count <= 1 or not locations then
		tremove(BG.currentRestackItems, 1)
		return BG.RestackStep()
	else
		local maxLoc = #locations
		if maxLoc <= 1 then
			BG.Debug("Restacking", itemID, "complete.")
			tremove(BG.currentRestackItems, 1)
			return BG.RestackStep()
		end

		BG.Debug("RestackStep", itemID, count, maxLoc)
		local moveFrom, moveTo = BG.cheapestItems[ locations[1] ], BG.cheapestItems[ locations[maxLoc] ]
		if not moveFrom.invalid and not BG.MoveItem(itemID, moveFrom.bag, moveFrom.slot, moveTo.bag, moveTo.slot) then
			tremove(BG.currentRestackItems, 1)	-- couldn't move the item, so don't try this one again
		end
		return true, hasItemLock
	end
end