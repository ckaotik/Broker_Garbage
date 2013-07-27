local _, BG = ...

-- GLOBALS: GetItemInfo, IsEquippedItem, GetNumEquipmentSets, GetEquipmentSetInfo, GetEquipmentSetItemIDs

-- forces a rescan on all items qualifying as equipment
function BG.RescanEquipmentInBags()
	local invType
	for location, cacheData in pairs(BG.containers) do
		invType = cacheData.item and cacheData.item.id and select(9, GetItemInfo(cacheData.item.id))
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
