local _, BG = ...

-- GLOBALS: BG_GlobalDB, BG_LocalDB, ITEM_BIND_ON_PICKUP, ITEM_SOULBOUND, TopFit, PawnIsItemIDAnUpgrade, _G
-- GLOBALS: GetItemInfo, GetCursorInfo, DeleteCursorItem, ClearCursor, PickupContainerItem, GetContainerItemInfo, GetContainerItemID, GetContainerItemLink
-- GLOBALS: type, select, string

-- returns true if the item is equippable. **Trinkets don't count!**
-- not using IsEquippableItem for this, as there bags would be equippable too
function BG.IsItemEquipment(invType)	-- itemLink/itemID/invType
	if not invType or invType == "" then
		return nil
	elseif (type(invType) == "string" and not invType:find("INVTYPE")) or type(invType) == "number" then
		invType = select(9, GetItemInfo(invType))
	end
	return invType ~= "" and not invType:find("BAG") and not invType:find("TRINKET")
end

-- == Misc Item Information ==
local scanTooltip = _G["BrokerGarbageScanTooltip"]
function BG.ScanTooltipFor(searchString, item, inBag, scanRightText, filterFunc)
	-- (String) searchString, (String|Int) item:ItemLink|BagSlotID, [(Boolean|Int) inBag:true|ContainerID], [(Function) filterFunc]
	if not item then return end
	scanTooltip:SetOwner(BG, "ANCHOR_NONE")

	local slot
	if inBag and type(item) == "number" then
		scanTooltip:SetBagItem(inBag, item)
	elseif inBag then
		inBag, slot = BG.FindItemInBags(item)
		scanTooltip:SetBagItem(inBag, slot)
	else
		scanTooltip:SetHyperlink(item)
	end
	return BG.FindInTooltip(searchString, scanRightText, filterFunc)
end

function BG.FindInTooltip(searchString, scanRightText, filterFunc)
	local numLines = scanTooltip:NumLines()
	local leftLine, leftLineText, rightLine, rightLineText
	for i = 1, numLines do
		leftLine = _G[scanTooltip:GetName().."TextLeft"..i]
		leftLineText = leftLine and leftLine:GetText()
		rightLine = _G[scanTooltip:GetName().."TextRight"..i]
		rightLineText = rightLine and rightLine:GetText()

		if (leftLineText:find(searchString) or (scanRightText and rightLineText:find(searchString)))
			and (not filterFunc or filterFunc(leftLineText, rightLineText)) then
			return leftLineText, rightLineText
		end
	end
end

-- returns whether an item is BoP/Soulbound
function BG.IsItemSoulbound(itemLink, bag, slot)	-- itemLink/itemID, bag, slot -OR- itemLink/itemID, checkMine -OR- itemTable
	if not itemLink then
		return nil
	elseif type(itemLink) == "number" then
		itemLink = select(2, GetItemInfo(itemLink))
	elseif type(itemLink) == "table" then
		if itemLink.itemLink then
			itemLink = itemLink.itemLink
		elseif itemLink.itemID then
			itemLink = select(2, GetItemInfo(itemLink.itemID))
		else
			return nil
		end
	end

	local searchString
	-- check needed to distinguish between BoP/Soulbound
	if bag and type(bag) == "boolean" then
		bag, slot = BG.FindItemInBags(itemLink)
	end

	if not bag and not slot then	-- check if item is BOP
		searchString = ITEM_BIND_ON_PICKUP
	else	-- check if item is soulbound
		searchString = ITEM_SOULBOUND
	end

	return BG.ScanTooltipFor(searchString, itemLink or slot, bag)
end

function BG.IsOutdatedItem(item)	-- itemID/itemLink/itemTable
	local itemID, itemLink, quality, outdated
	if not item then return nil end

	if type(item) == "table" then
		itemID = item.itemID
		quality = item.quality

		-- get itemlinks that include gems & enchants, if possible
		if item.bag and item.slot then
			itemLink = GetContainerItemLink(item.bag, item.slot)
		else
			local bag, slot = BG.FindItemInBags(item.itemID)
			if bag and slot then
				itemLink = GetContainerItemLink(bag, slot)
			else
				_, itemLink = GetItemInfo(item.itemID)
			end
		end
	else
		_, itemLink, quality = GetItemInfo(item)
		itemID = itemLink and BG.GetItemID(itemLink)
	end
	if not itemID then return end

	-- check if this is even an item we can make decisions for
	if not BG_GlobalDB.sellOldGear or quality > BG_GlobalDB.sellNWQualityTreshold then return end
	if not BG.IsItemEquipment( (select(9, GetItemInfo(itemLink))) ) then return end

	if BG.IsItemSoulbound(itemLink, true) then
		-- handle different source of outdated data
		if TopFit and TopFit.IsInterestingItem then
			outdated = not TopFit:IsInterestingItem(itemLink)
		end
		if PawnIsItemIDAnUpgrade then
			local upgrade, best, secondBest = PawnIsItemIDAnUpgrade(itemID, true)
			outdated = not (upgrade or best or secondBest)
		end
	end

	return outdated
end

function BG.IsItemBoP(item)
	local itemData = BG.item[item]
	return item.bop
end

local function Deleted(item, count)
	local _, link, _, _, _, _, _, _, _, _, vendorPrice = GetItemInfo(item)
	local itemValue = count * vendorPrice

	-- statistics
	BG_GlobalDB.itemsDropped 		= BG_GlobalDB.itemsDropped + count
	BG_GlobalDB.moneyLostByDeleting	= BG_GlobalDB.moneyLostByDeleting + itemValue
	BG_LocalDB.moneyLostByDeleting 	= BG_LocalDB.moneyLostByDeleting + itemValue

	BG.PrintFormat(BG.locale.itemDeleted, link, count)
end
-- deletes the item in a given location of your bags
function BG.Delete(location, ...)
	if not location then
		BG.Print("Error! Broker_Garbage Delete: no argument supplied.")
		return
	elseif location == "cursor" then
		-- item on the cursor
		local cursorType, itemID = GetCursorInfo()
		if cursorType ~= "item" then
			-- TODO: localize
			BG.Print("Error! Trying to delete an item from the cursor, but there is none.")
			return
		end
		DeleteCursorItem()
		Deleted(itemID, ...)
	else
		-- security check
		local container, slot = BG.GetBagSlot(location)
		local cacheData = BG.containers[location]

		-- TODO: also check item count?
		if cacheData.item and GetContainerItemID(container, slot) == cacheData.item.id then
			-- actually delete the item
			ClearCursor()
			PickupContainerItem(container, slot)
			DeleteCursorItem()
			Deleted(cacheData.item.id, cacheData.count)
		else
			-- TODO: localize
			BG.PrintFormat("Error! Item to be deleted is not the expected item (%s in %d)",
				cacheData.item and cacheData.item.id or "?",
				location)
		end
	end
end
