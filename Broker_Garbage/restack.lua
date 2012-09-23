local _, BG = ...

-- GLOBALS: NUM_BAG_SLOTS
-- GLOBALS: GetContainerNumSlots, GetContainerItemID, GetContainerItemInfo, ClearCursor, PickupContainerItem, GetItemInfo
local type = type
local select = select
local pairs = pairs
local ipairs = ipairs
local floor = math.floor
local tinsert = table.insert
local tremove = table.remove
local format = string.format

local restackQueue = {}
function BG.QueryRestackForItem(itemID)
	local tableItem
	if itemID and type(itemID) == "number" and restackQueue[itemID] == nil then
		local locations = BG.GetItemLocations(BG.GetCached(itemID), true)
		if locations and #(locations) > 1 then
			-- fetch proper location data
			for index, tableIndex in ipairs(locations) do
				tableItem = BG.cheapestItems[tableIndex]
				locations[index] = {tableItem.bag, tableItem.slot}
			end
			restackQueue[itemID] = locations
		end
	end
end

function BG.DoFullRestack()
	for container = 0, NUM_BAG_SLOTS do
		for slot = 1, (GetContainerNumSlots(container) or 0) do
			local itemID = GetContainerItemID(container, slot)
			BG.QueryRestackForItem(itemID)
		end
	end

	BG.Restack()
end
function BG.DoContainerRestack(container)
	for slot = 1, (GetContainerNumSlots(container) or 0) do
		local itemID = GetContainerItemID(container, slot)
		BG.QueryRestackForItem(itemID)
	end
	BG.Restack()
end

local restackRoutine = nil
BG.restackEventCounter = 0
function BG.Restack()
	if not restackRoutine then
		restackRoutine = BG.RestackIteration
	end
	local event, eventCounter = restackRoutine()
	BG.restackEventCounter = eventCounter

	if event == nil then
		restackRoutine = nil
		BG.callbacks:Fire("RESTACK_COMPLETE")
	else
		BG.frame:RegisterEvent(event)
	end
end

function BG.RestackIteration()
	local sourceCount, sourceLocked, targetCount, targetLocked, targetIndex
	local fromSlot, toSlot, fromBag, toBag, stackSize
	local numMoves = 0

	for itemID, locations in pairs(restackQueue) do
		stackSize = select(8, GetItemInfo(itemID))

		for currentIndex = 1, floor(#(locations)/2) do
			targetIndex = #(locations) - currentIndex + 1
			if currentIndex == targetIndex then break end

			fromBag, fromSlot 	= locations[currentIndex][1], locations[currentIndex][2]
			toBag, toSlot 		= locations[targetIndex][1], locations[targetIndex][2]

			_, sourceCount, sourceLocked = GetContainerItemInfo(fromBag, fromSlot)
			_, targetCount, targetLocked = GetContainerItemInfo(toBag, toSlot)

			if sourceCount and targetCount then
				if not sourceLocked and not targetLocked and BG.MoveItem(itemID, fromBag, fromSlot, toBag, toSlot) then
					numMoves = numMoves + 2

					if sourceCount + targetCount <= stackSize then
						numMoves = numMoves - 1
						tinsert(restackQueue[itemID][currentIndex], true)
					end
					if sourceCount + targetCount >= stackSize then
						tinsert(restackQueue[itemID][targetIndex], true)
					end
				end
			else
				if not sourceCount then
					BG.Debug(format("source slot %d.%d is empty", fromBag, fromSlot))
					tinsert(restackQueue[itemID][currentIndex], true)
				end
				if not targetCount then
					BG.Debug(format("target slot %d.%d is empty", toBag, toSlot))
					tinsert(restackQueue[itemID][targetIndex], true)
				end
			end
		end
		-- update locations: remove empty/full slots
		for currentIndex = #(locations), 1, -1 do
			if locations[currentIndex][3] then
				tremove(locations, currentIndex)
			end
		end
	end
	for itemID, locations in pairs(restackQueue) do
		if #(locations) < 2 then
			table.wipe(restackQueue[itemID])
			restackQueue[itemID] = nil
		end
	end

	if BG.Count(restackQueue) > 0 then
		-- more to do
		return "ITEM_UNLOCKED", numMoves
	else
		-- done with all items
		return nil
	end
end

--[[function BG.PutIntoBestContainer(curBag, curSlot, usedSlots)
	local itemID = GetContainerItemID(curBag, curSlot)
	local itemFamily = itemID and GetItemFamily(itemID)
	if not itemID or itemFamily == 0 then return end 	-- empty slots / general items

	local bestContainer = BG.FindBestContainerForItem(itemID, itemFamily)
	if bestContainer and bestContainer ~= curBag then
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
end --]]

function BG.MoveItem(itemID, fromBag, fromSlot, toBag, toSlot)
	if not (fromBag and fromSlot and toBag and toSlot) then return nil end
	BG.Debug("From", fromBag.."."..fromSlot, "to", toBag.."."..toSlot)

	if GetContainerItemID(fromBag, fromSlot) ~= itemID then
		BG.Print(BG.locale.couldNotMoveItem)
		return nil
	end

	ClearCursor()
	PickupContainerItem(fromBag, fromSlot)
	PickupContainerItem(toBag, toSlot)
	ClearCursor()

	return true
end
