local _, BG = ...

local restackQueue = {}
function BG.QueryRestackForItem(itemID)
	local tableItem
	if itemID and type(itemID) == "number" and restackQueue[itemID] == nil then
		local locations = BG.GetItemLocations(BG.GetCached(itemID), true)
		-- if it's only one, there's nothing to do
		if #(locations or {}) > 1 then
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
	local success, event, eventCounter
	if not restackRoutine then
		restackRoutine = coroutine.create(BG.RestackIteration)
		success, event, eventCounter = coroutine.resume(restackRoutine, 1)
	else
		success, event, eventCounter = coroutine.resume(restackRoutine)
	end
	BG.restackEventCounter = eventCounter

	if coroutine.status(restackRoutine) == "dead" then
		restackRoutine = nil
	else
		BG.frame:RegisterEvent(event)
	end
end

function BG.RestackIteration(stepCount)
	while true do
		stepCount = stepCount + 1

		local count, isLocked, targetCount, targetLocked, targetIndex
		local success, stackSize
		local numMoves = 0

		for itemID, locations in pairs(restackQueue) do
			stackSize = select(8, GetItemInfo(itemID))

			for currentIndex = 1, math.floor(#(locations)/2) do
				targetIndex = #(locations) - currentIndex + 1
				if currentIndex == targetIndex then break end

				_, count, isLocked = GetContainerItemInfo(locations[currentIndex][1], locations[currentIndex][2])
				_, targetCount, targetLocked = GetContainerItemInfo(locations[targetIndex][1], locations[targetIndex][2])

				if not isLocked and not targetLocked
					and BG.MoveItem(itemID, locations[currentIndex][1], locations[currentIndex][2],
						locations[targetIndex][1], locations[targetIndex][2]) then
					numMoves = numMoves + 2
				end

				if count + targetCount <= stackSize then
					numMoves = numMoves - 1
					table.insert(restackQueue[itemID][currentIndex], true)
				end
				if count + targetCount >= stackSize then
					table.insert(restackQueue[itemID][targetIndex], true)
				end
			end
			-- update locations: remove empty/full slots
			for currentIndex = #(locations), 1, -1 do
				if locations[currentIndex][3] then
					table.remove(locations, currentIndex)
				end
			end
		end
		for itemID, locations in pairs(restackQueue) do
			if #(locations) < 2 then
				-- done with this itemID
				table.wipe(restackQueue[itemID])
				table.remove(restackQueue, itemID)
			end
		end

		if BG.Count(restackQueue) > 0 then
			-- more to do
			coroutine.yield("ITEM_UNLOCKED", numMoves)
		else
			-- done with all items
			break
		end
	end
end


function BG.MoveItem(itemID, fromBag, fromSlot, toBag, toSlot)
	if not (fromBag and fromSlot and toBag and toSlot) then return nil end
	print("From", fromBag.."."..fromSlot, "to", toBag.."."..toSlot)

	if GetContainerItemID(fromBag, fromSlot) ~= itemID then
		print("Error! Item to move does not match requested item.")
		return nil
	end
	ClearCursor()
	securecall(PickupContainerItem, fromBag, fromSlot)
	securecall(PickupContainerItem, toBag, toSlot)
	return true
end
