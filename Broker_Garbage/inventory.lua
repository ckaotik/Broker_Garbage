local _, BG = ...

-- GLOBALS: GetItemInfo, IsEquippedItem, GetNumEquipmentSets, GetEquipmentSetInfo, GetEquipmentSetItemIDs

-- only check a specific item in a specific location
function BG.UpdateInventorySlot(container, slot, newItemLink, newItemCount)
	local tableIndex, recheck, item, needsUpdate = nil, nil, nil, nil
	local changed, cachedItem, otherLocations = 0, nil, nil -- changed: update based on <-1:old|+1:new> item

	local oldItemID, newItemID
	newItemID = newItemLink and BG.GetItemID(newItemLink)

	local listIndex = BG.GetListIndex(container, slot, true)
	local slotString = '@'..(container*100 + slot)

	if listIndex then
		item = BG.cheapestItems[listIndex]
		oldItemID = item.itemID

		if newItemID and item.invalid then
			BG.Debug("Enable", slotString, newItemID)

			item.invalid = nil
			recheck = true

		elseif oldItemID and not newItemID and not item.invalid then
			-- tag data as invalid
			BG.Debug("Disable", slotString, item.itemID)

			item.invalid = true
			item.reason = nil
			item.itemID = 0

		elseif oldItemID and newItemID then
			if oldItemID ~= newItemID then
				-- update the whole item slot
				BG.Debug("Update", slotString, newItemID)
				recheck = true

			elseif item.count ~= newItemCount then
				-- update the item count
				BG.Debug("Update count", slotString, newItemID)

				BG.cheapestItems[listIndex].value = (BG.cheapestItems[listIndex].value / BG.cheapestItems[listIndex].count) * newItemCount
				BG.cheapestItems[listIndex].count = newItemCount
			else
				-- BG.Debug("Item unchanged", slotString, newItemID)
			end
		end
	end

	if newItemID and (not listIndex or recheck) then
		needsUpdate = true
	end

	return needsUpdate, listIndex
end

-- forces a rescan on all items qualifying as equipment
function BG.RescanEquipmentInBags()
	local invType
	for itemIndex, item in pairs(BG.cheapestItems) do
		invType = item.itemID and select(9, GetItemInfo(item.itemID))
		if invType and BG.IsItemEquipment(invType) then
			-- BG.SetDynamicLabelBySlot(item.bag, item.slot, itemIndex)
		end
	end
end

local function IsItemUsedInEquimentSet(itemID)
	local setName
	for setID = 1, GetNumEquipmentSets() do
		setName = GetEquipmentSetInfo(setID)
		if BG.Find(GetEquipmentSetItemIDs(setName), itemID) then
			return true
		end
	end
end
local function SortEquipItems(a, b)
	-- sorts by itemLevel, descending
	local itemNameA, _, _, itemLevelA = GetItemInfo(a)
	local itemNameB, _, _, itemLevelB = GetItemInfo(b)

	if itemLevelA ~= itemLevelB then
		return itemLevelA > itemLevelB
	elseif IsEquippedItem(itemNameA) ~= IsEquippedItem(itemNameB) then
		-- equipped item has priority
		return IsEquippedItem(itemNameA)
	elseif IsItemUsedInEquimentSet(a) ~= IsItemUsedInEquimentSet(b) then
		return IsItemUsedInEquimentSet(a)
	else
		return itemNameA < itemNameB
	end
end
