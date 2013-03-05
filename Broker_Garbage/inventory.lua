local _, BG = ...

-- GLOBALS: BG_GlobalDB, BG_LocalDB, NUM_BAG_SLOTS, TopFit, PawnGetSlotsForItemType
-- GLOBALS: GetContainerNumSlots, GetContainerNumFreeSlots, GetContainerItemLink, GetContainerItemID, GetContainerItemInfo, GetItemInfo, GetInventoryItemsForSlot, GetItemFamily, IsEquippedItem, GetNumEquipmentSets, GetEquipmentSetInfo, GetEquipmentSetItemIDs
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
local match = string.match

-- == Finding things in your inventory ==
-- returns the first occurrence of a given item; item :: <itemID>|<itemLink>
function BG.FindItemInBags(item)
	if not item then return
	elseif type(item) == "number" then
		_, item = GetItemInfo(item)
	end
	for container = 0, NUM_BAG_SLOTS do
		local numSlots = GetContainerNumSlots(container)
		if numSlots then
			for slot = 0, numSlots do
				for slot = 1, numSlots do
					if item == GetContainerItemLink(container, slot) then
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

	local itemID_A = GetContainerItemID(itemA.bag, itemA.slot)
	local itemID_B = GetContainerItemID(itemB.bag, itemB.slot)
	local _, itemCount_A = GetContainerItemInfo(itemA.bag, itemA.slot)
	local _, itemCount_B = GetContainerItemInfo(itemB.bag, itemB.slot)

	if itemID_A == nil or itemID_B == nil then
		return itemCount_A ~= nil
	else
		local bagTypeA = select(2, GetContainerNumFreeSlots(itemA.bag))
		local cacheA = BG.GetCached(itemID_A)

		local bagTypeB = select(2, GetContainerNumFreeSlots(itemB.bag))
		local cacheB = BG.GetCached(itemID_B)

		if bagTypeA ~= bagTypeB then
			return bagTypeA < bagTypeB
		elseif cacheA.level ~= cacheB.level then
			return cacheA.level < cacheB.level
		elseif cacheA.vendorValue ~= cacheB.vendorValue then
			return cacheA.vendorValue < cacheB.vendorValue
		elseif itemCount_A ~= itemCount_B then
			return itemCount_A < itemCount_B
		elseif itemID_A ~= itemID_B then
			return itemID_A < itemID_B
		elseif itemA.bag ~= itemB.bag then
			return itemA.bag < itemB.bag
		else
			return itemA.slot < itemB.slot
		end
	end
end

-- finds all occurences of the given item/category; returns table sorted by relevance (lowest first); item :: <itemTable>
function BG.GetItemLocations(item, ignoreFullStacks)
	if not item then
		return nil
	elseif (type(item) == "number" or type(item) == "string") then
		-- in case we got an item link
		item = BG.GetItemID(item) or item
	elseif type(item) == "table" then
		item = item.itemID
	end

	local locations, cachedItem = {}, nil
	local isCategoryScan = type(item) ~= "number"

	for tableIndex, tableItem in pairs(BG.cheapestItems) do
		if not tableItem.invalid and tableItem.itemID ~= 0 then
			cachedItem = BG.GetCached(tableItem.itemID)
			if (isCategoryScan and BG.IsItemInCategory(tableItem.itemID, item)) or (tableItem.itemID == item) then
				if not ignoreFullStacks or tableItem.count < cachedItem.stackSize then
					tinsert(locations, tableIndex)
				end
			end
		end
	end

	-- return what we found
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
	BG.ScanInventory(true)
end

function BG.UpdateAllDynamicItems()
	BG.ClearCache()
	wipe(BG.cheapestItems)
	BG.ScanInventory()
	return
end

-- == Inventory Scanning ==
function BG.ScanInventory(forceUpdate)
	for container = 0, NUM_BAG_SLOTS do
		BG.ScanInventoryContainer(container, forceUpdate)
	end
	BG.ScanInventoryLimits()
	BG.SortItemList()
end

function BG.ScanInventoryContainer(container, forceUpdate)
	local isSpecialBag = select(2, GetContainerNumFreeSlots(container)) ~= 0
	local newItemCount, newItemLink, needsUpdate, listIndex

	for slot = 1, GetContainerNumSlots(container) or 0 do
		_, newItemCount, _, _, _, _, newItemLink = GetContainerItemInfo(container, slot)
		needsUpdate, listIndex = BG.UpdateInventorySlot(container, slot, newItemLink, newItemCount)
		if needsUpdate or forceUpdate then
			BG.SetDynamicLabelBySlot(container, slot, listIndex, isSpecialBag)
		end
	end
end

function BG.ScanInventoryLimits()
	local cachedItem, itemID, canOpen
	BG.containerInInventory = false

	for container = 0, NUM_BAG_SLOTS do
		for slot = 1, GetContainerNumSlots(container) or 0 do
			itemID = GetContainerItemID(container, slot)
			cachedItem = itemID and BG.GetCached(itemID)
			if cachedItem and cachedItem.limiter then
				BG.UpdateInventorySlotLimit(container, slot, itemID)
			end

			-- remember lootable items
			canOpen = select(6, GetContainerItemInfo(container, slot))
			BG.containerInInventory = BG.containerInInventory or canOpen
		end
	end
end

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

-- == Pure Logic Ahead ==
function BG.SortCheapestItemsList(a, b)
	local a_sortStatus = (a.source == BG.IGNORE or a.hide or a.invalid) and 1 or -1
	local b_sortStatus = (b.source == BG.IGNORE or b.hide or b.invalid) and 1 or -1

	if a_sortStatus ~= b_sortStatus then
		-- move non-invalid to front
		return a_sortStatus < b_sortStatus
	else
		for _, attribute in ipairs({'value', 'count', 'bag', 'slot'}) do
			if a[attribute] ~= b[attribute] then
				return a[attribute] < b[attribute]
			end
		end
	end
end

-- sort item list and updates LDB accordingly
function BG.SortItemList()
	sort(BG.cheapestItems, BG.SortCheapestItemsList)
	BG.UpdateLDB()
end

-- forces a rescan on all items qualifying as equipment
function BG.RescanEquipmentInBags()
	local invType
	for itemIndex, item in pairs(BG.cheapestItems) do
		invType = item.itemID and select(9, GetItemInfo(item.itemID))
		if invType and BG.IsItemEquipment(invType) then
			BG.SetDynamicLabelBySlot(item.bag, item.slot, itemIndex)
		end
	end
end

--
function BG.UpdateInventorySlotLimit(container, slot, itemID)
	local listIndex = BG.GetListIndex(container, slot)
	local cheapestItem = listIndex and BG.cheapestItems[listIndex]
	if not cheapestItem or cheapestItem.invalid then return end

	if match(cheapestItem.reason, " %(.+ limit%)$") then
		-- this entry hasn't been changed since we last decided on limits, revert to useful attributes
		BG.SetDynamicLabelBySlot(container, slot, listIndex)
	end

	local value = cheapestItem.value
	local reason = cheapestItem.reason
	local sell = cheapestItem.sell
	local insert = cheapestItem.source ~= BG.IGNORE

	local classification, simpleReason, myReason
	local itemOverLimit = BG.IsItemOverLimit(container, slot)
	if not itemOverLimit then
		-- limit exists, but is not yet reached
		insert = nil
		sell = nil

		classification = BG.EXCLUDE
		myReason = " (under limit)"
	elseif itemOverLimit and classification == BG.EXCLUDE then
		-- inverse logic: KEEP items over limit are handled like regular items
		value, classification, simpleReason = BG.GetSingleItemValue(itemID, classification)
		value = cheapestItem.count * value

		insert = true
		myReason = " (over limit)" .. simpleReason
	else
		myReason = " (over limit)"
	end

	BG.Debug("Checking item limit", container*100+slot, itemID, myReason)

	-- override pre-determined values
	cheapestItem.value = value
	cheapestItem.source = insert and (classification or cheapestItem.source) or BG.IGNORE
	cheapestItem.reason = (reason or "") .. myReason
	cheapestItem.sell = sell
	BG.cheapestItems[listIndex] = cheapestItem
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
-- checks current inventory state and assigns labels depending on limits, binding etc.
local itemsForInvType, itemsForSlot = {}, {}
function BG.SetDynamicLabelBySlot(container, slot, listIndex, isSpecialBag)
	if not (container and slot) then return end

	local _, count, _, _, _, _, itemLink = GetContainerItemInfo(container, slot)
	local itemID = itemLink and BG.GetItemID(itemLink)
	local item = itemID and BG.GetCached(itemID)

	if not item or (BG.cheapestItems[listIndex] and BG.cheapestItems[listIndex].invalid) then
		return nil
	end

	--[[ determine classification ]]--
	-- initial values, will get overridden if necessary
	local classification, reason = item.classification, item.reason
	local value = item.value
	local origin

	-- regular list behaviour: no limit or non-keep over limit
	if classification == BG.EXCLUDE then
		classification = BG.IGNORE
	elseif classification == BG.INCLUDE then
		value = BG_GlobalDB.useRealValues and value or 0
	elseif classification == BG.AUTOSELL then
		value = item.vendorValue
	end

	-- ignore things that are in special bags
	if isSpecialBag == nil then
		isSpecialBag = select(2, GetContainerNumFreeSlots(container)) ~= 0
	end
	classification = isSpecialBag and BG.IGNORE or classification

	-- update: unusable / outdated gear
	if item.classification == BG.UNUSABLE and BG_GlobalDB.sellNotWearable then
		classification = BG.UNUSABLE
	elseif item.classification ~= BG.EXCLUDE and BG_GlobalDB.sellOldGear and BG.IsOutdatedItem(itemLink) then
		local saveItem = false

		if BG_GlobalDB.keepHighestItemLevel then
			local invType = select(9, GetItemInfo(itemLink))
			local slots = (TopFit and TopFit.GetEquipLocationsByInvType and TopFit:GetEquipLocationsByInvType(invType))
				or (PawnGetSlotsForItemType and { PawnGetSlotsForItemType(invType) }) or {}

			local keepItems = 1
			if #slots > 1 then
				keepItems = 2
				if slots[1] == 16 and slots[2] == 17 and TopFit.PlayerCanDualWield and not TopFit:PlayerCanDualWield() then
					keepItems = 1
				end
			end

			wipe(itemsForInvType)
			wipe(itemsForSlot)
			for _, slot in ipairs(slots) do
				GetInventoryItemsForSlot(slot, itemsForInvType)
			end
			for _, inventoryItemID in pairs(itemsForInvType) do
				if not BG.Find(itemsForSlot, inventoryItemID) then
					tinsert(itemsForSlot, inventoryItemID)
				end
			end
			sort(itemsForSlot, SortEquipItems)

			for i = 1, keepItems do
				if itemsForSlot[i] and itemsForSlot[i] == itemID then
					saveItem = true
					break
				end
			end
		end

		if saveItem then
			BG.Debug("Item is OUTDATED but saved for its item level", itemID, itemLink)
			classification = BG.EXCLUDE
			reason = "OUTDATED but highest iLvl"
		else
			BG.Debug("Item is OUTDATED", itemID, itemLink)
			classification = BG.OUTDATED
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

	--[[ Set data flags ]]--
	if value == 0 and BG_GlobalDB.hideZeroValue
		and (item.classification == BG.VENDOR or item.classification == BG.OUTDATED  or item.classification == BG.UNUSABLE) then
		BG.Debug("item has zero value")
		classification = BG.IGNORE
	end

	-- sell flag
	local sellItem = nil
	if (classification ~= BG.EXCLUDE and item.quality == 0)
		or (classification == BG.INCLUDE and BG_GlobalDB.autoSellIncludeItems) then

		value = BG.GetSingleItemValue(item, BG.VENDOR)
		sellItem = value and count and (value*count) > 0
	elseif classification == BG.OUTDATED or classification == BG.UNUSABLE then

		if item.quality <= BG_GlobalDB.sellNWQualityTreshold then
			value = BG.GetSingleItemValue(item, BG.VENDOR)
			sellItem = value and count and (value*count) > 0
		else
			item.reason = (item.reason or "") .. " (over threshold)"
		end
	end

	-- visibility in tooltip
	if classification ~= BG.INCLUDE and classification ~= BG.IGNORE and item.quality > BG_GlobalDB.dropQuality then
		-- not allowed, treshold surpassed
		BG.Debug("quality too high and not junk listed")
		origin = classification
		classification = BG.IGNORE
	end

	-- save to cheapest list. create new entry if needed
	local listIndex = listIndex or #BG.cheapestItems+1
	local updateItem = BG.cheapestItems[listIndex] or {}
		  updateItem.itemID = itemID
		  updateItem.bag = container
		  updateItem.slot = slot
		  updateItem.count = count
		  updateItem.value = value * count
		  updateItem.source = classification
		  updateItem.origin = origin
		  updateItem.reason = reason or item.reason
		  updateItem.sell = sellItem
		  updateItem.invalid = nil

	BG.cheapestItems[listIndex] = updateItem

	return listIndex
end
