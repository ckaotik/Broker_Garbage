local _, BG = ...

-- GLOBALS: BG_GlobalDB, BG_LocalDB, UIParent, ITEM_STARTS_QUEST, ITEM_BIND_QUEST, ITEM_BIND_ON_PICKUP, ITEM_SOULBOUND, TopFit, PawnIsItemIDAnUpgrade, Enchantrix, Wowecon, AuctionLite, AucAdvanced, AucMasGetCurrentAuctionInfo, Auctional, _G, PROFESSION_RANKS
-- GLOBALS: GetItemInfo, GetCursorInfo, DeleteCursorItem, ClearCursor, GetNumEquipmentSets, GetEquipmentSetInfo, GetEquipmentSetItemIDs, GetAuctionItemSubClasses, PickupContainerItem, GetContainerItemInfo, GetContainerItemID, GetContainerItemLink, IsAddOnLoaded, GetAuctionBuyout, GetDisenchantValue, Atr_GetAuctionBuyout, Atr_GetDisenchantValue, IsUsableSpell
local format = string.format
local gsub = string.gsub
local match = string.match
local find = string.find
local floor = math.floor
local ceil = math.ceil
local max = math.max

function BG.GetItemID(itemLink)
	if not itemLink or type(itemLink) ~= "string" then return end
	local linkType, id, data = itemLink:match("^.-H([^:]+):?([^:]*):?([^|]*)")
	if linkType == "item" then
		return tonumber(id)
	end
end

-- returns true if the item is equippable. **Trinkets don't count!**
-- not using IsEquippableItem for this, as there bags would be equippable too
function BG.IsItemEquipment(invType)	-- itemLink/itemID/invType
	if not invType or invType == "" then
		return nil
	elseif (type(invType) == "string" and not find(invType, "INVTYPE")) or type(invType) == "number" then
		invType = select(9, GetItemInfo(invType))
	end
	return invType ~= "" and not find(invType, "BAG") and not find(invType, "TRINKET")
end

-- == Misc Item Information ==
local scanTooltip = CreateFrame("GameTooltip", "BrokerGarbage_ItemScanTooltip", UIParent, "GameTooltipTemplate")
function BG.ScanTooltipFor(searchString, item, inBag, scanRightText, filterFunc)
	-- (String) searchString, (String|Int) item:ItemLink|BagSlotID, [(Boolean|Int) inBag:true|ContainerID], [(Function) filterFunc]
	if not item then return end
	scanTooltip:SetOwner(UIParent, "ANCHOR_NONE")

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

		if (find(leftLineText, searchString) or (scanRightText and find(rightLineText, searchString)))
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
		if IsAddOnLoaded("TopFit") and TopFit.IsInterestingItem then
			outdated = not TopFit:IsInterestingItem(itemLink)
		end
		if PawnIsItemIDAnUpgrade then
			local upgrade, best, secondBest = PawnIsItemIDAnUpgrade(itemID, true)
			outdated = not (upgrade or best or secondBest)
		end
	end

	return outdated
end

-- deletes the item in a given location of your bags
function BG.Delete(item, position)
	local itemID, itemCount, cursorType

	if type(item) == "string" and item == "cursor" then
		-- item on the cursor
		cursorType, itemID = GetCursorInfo()
		if cursorType ~= "item" then
			BG.Print("Error! Trying to delete an item from the cursor, but there is none.")
			return
		end
		itemCount = position	-- second argument is the item count

	elseif type(item) == "table" then
		-- item given as an itemTable
		itemID = item.itemID

	elseif type(item) == "number" then
		-- item given via its itemID
		itemID = item

	elseif item then
		-- item given via its itemLink
		itemID = BG.GetItemID(item)
	else
		BG.Print("Error! BG:Delete() no argument supplied.")
		return
	end

	-- security check
	local bag = position and position[1] or item.bag
	local slot = position and position[2] or item.slot
	if not cursorType and (not (bag and slot) or GetContainerItemID(bag, slot) ~= itemID) then
		BG.Print("Error! Item to be deleted is not the expected item.")
		BG.Debug("I got these parameters:", itemID, bag, slot)
		return
	end

	-- make sure there is nothing unwanted on the cursor
	if not cursorType then
		ClearCursor()
	end

	_, itemCount = GetContainerItemInfo(bag, slot)

	-- actual deleting happening after this
	PickupContainerItem(bag, slot)
	DeleteCursorItem()					-- comment this line to prevent item deletion

	local itemValue = (BG.GetCached(itemID).value or 0) * itemCount	-- if an item is unknown to the cache, statistics will not change
	-- statistics
	BG_GlobalDB.itemsDropped 		= BG_GlobalDB.itemsDropped + itemCount
	BG_GlobalDB.moneyLostByDeleting	= BG_GlobalDB.moneyLostByDeleting + itemValue
	BG_LocalDB.moneyLostByDeleting 	= BG_LocalDB.moneyLostByDeleting + itemValue

	local _, itemLink = GetItemInfo(itemID)
	BG.Print(format(BG.locale.itemDeleted, itemLink, itemCount))
end
