local _, BG = ...

-- GLOBALS: BG_GlobalDB, BG_LocalDB, UIParent, ITEM_STARTS_QUEST, ITEM_BIND_QUEST, ITEM_BIND_ON_PICKUP, ITEM_SOULBOUND, TopFit, PawnIsItemIDAnUpgrade, Enchantrix, Wowecon, AuctionLite, AucAdvanced, AucMasGetCurrentAuctionInfo, Auctional, _G, PROFESSION_RANKS
-- GLOBALS: GetItemInfo, GetCursorInfo, DeleteCursorItem, ClearCursor, GetNumEquipmentSets, GetEquipmentSetInfo, GetEquipmentSetItemIDs, GetAuctionItemSubClasses, PickupContainerItem, GetContainerItemInfo, GetContainerItemID, GetContainerItemLink, IsAddOnLoaded, GetAuctionBuyout, GetDisenchantValue, Atr_GetAuctionBuyout, Atr_GetDisenchantValue, IsUsableSpell
local type = type
local select = select
local tonumber = tonumber
local pairs = pairs
local ipairs = ipairs
local unpack = unpack
local tinsert = table.insert
local wipe = table.wipe
local format = string.format
local gsub = string.gsub
local match = string.match
local find = string.find
local floor = math.floor
local ceil = math.ceil
local max = math.max

local Unfit = LibStub("Unfit-1.0")	-- library to determine unusable items

function BG.GetItemID(itemLink)
	if not itemLink or type(itemLink) ~= "string" then return end
	local linkType, id, data = itemLink:match("^.-H([^:]+):?([^:]*):?([^|]*)")
	if linkType == "item" then
		return tonumber(id)
	end
end

-- /dump Broker_Garbage.GetItemListCategories(Broker_Garbage.GetCached(8766))
-- returns a list of (LPT or other) categories from the user's lists that an item belongs to
function BG.GetItemListCategories(item)
	if not item or type(item) ~= "table" then return end
	if item.count then
		-- this is a cheapestList item, but we need cache data
		item = BG.GetCached(item.itemID)
	end

	local itemList, itemCategories, maxLimit, maxCategory = BG.lists[item.classification], {}, 0
	if itemList then
		local currentList = BG_GlobalDB[itemList]
		if currentList then
			for listItem, limit in pairs(currentList) do
				if type(listItem) == "string" and BG.IsItemInCategory(item.itemID, listItem) then
					tinsert(itemCategories, listItem)
					if limit > maxLimit then
						maxCategory = listItem
						maxLimit = limit
					end
				end
			end
		end
		currentList = BG_LocalDB[itemList]
		if currentList then
			for listItem, limit in pairs(currentList) do
				if type(listItem) == "string" and not BG.Find(itemCategories, listItem) and BG.IsItemInCategory(item.itemID, listItem) then
					tinsert(itemCategories, listItem)
					if limit > maxLimit then
						maxCategory = listItem
						maxLimit = limit
					end
				end
			end
		end
	end
	return itemCategories, maxLimit, maxCategory
end

-- checks multiple category strings at once
function BG.IsItemInCategories(item, categoryList)
	if not categoryList or type(categoryList) ~= "table" then return end
	for _, category in pairs(categoryList) do
		if BG.IsItemInCategory(item, category) then
			return true, category
		end
	end
end

-- return true if item is found in LPT/Equipment category, nil otherwise
function BG.IsItemInCategory(item, category)	-- itemID/itemLink/itemTable, categoryString
	local itemID
	if not item then
		return
	elseif type(item) == "number" then
		itemID = item
	elseif type(item) == "string" then
		itemID = BG.GetItemID(item)
	elseif type(item) == "table" then
		itemID = item.itemID
	end

	local searchResult, itemName
	local categoryType, index = match(category, "^(.-)_(.+)")
	if categoryType and index then -- not a LPT category
		if categoryType == "BEQ" then	-- equipment set
			index = tonumber(index)
			if index <= GetNumEquipmentSets() then
				category = GetEquipmentSetInfo(index)
				searchResult = BG.Find(GetEquipmentSetItemIDs(category), itemID)
			end
		elseif categoryType == "AC" then	-- armor class
			index = tonumber(index)
			local armorClass = select(index, GetAuctionItemSubClasses(2))
			searchResult = select(7, GetItemInfo(itemID)) == armorClass
		elseif categoryType == "NAME" then 	-- item name
			itemName = GetItemInfo(itemID)
			-- create pattern
			index = gsub(index, "%*", ".-")
			index = "^" .. index .. "$"
			searchResult = match(itemName, index)
			-- searchResult = itemName == index
		end
	elseif BG.PT then	-- LPT category
		_, searchResult = BG.PT:ItemInSet(itemID, category)
	end
	return searchResult and true or nil
end

-- check if a given item is on a given Broker_Garbage lists
function BG.IsItemInBGList(item, itemList, onlyLocal)	-- itemID/itemLink/itemTable, BG list name
	if not item then
		return
	elseif type(item) == "table" then
		item = item.itemID
	elseif type(item) == "string" then
		-- strings are either itemLinks or categoryStrings
		if BG.GetItemID(item) then
			item = BG.GetItemID(item)
		end
	end

	local onLocalList, onGlobalList
	if BG_LocalDB[itemList] and BG_LocalDB[itemList][item] then
		onLocalList = true
	end
	if not onlyLocal and BG_GlobalDB[itemList] and BG_GlobalDB[itemList][item] then
		onGlobalList = true
	end
	return onLocalList or onGlobalList
end

-- bag, slot, limit -or- itemTable, limit -or- itemTable, if .limit is available
function BG.IsItemOverLimit(bag, slot, limit)
	local itemID
	if bag and type(bag) == "number" and slot and type(slot) == "number" then
		itemID = GetContainerItemID(bag, slot)
	elseif bag and type(bag) == "table" then
		itemID = bag.itemID
		limit = slot or bag.limit
		slot = bag.slot
		bag  = bag.bag
	else
		return nil
	end

	local cachedItem = BG.GetCached(itemID)
	limit = limit or (cachedItem and cachedItem.limit) or 0
	if limit < 1 then
		return false
	end

	local locations = BG.GetItemLocations(cachedItem.limiter or itemID)
	if not locations or #locations <= 1 then
		return false
	end

	local itemCount, currentItem = 0, nil
	for i = #locations, 1, -1 do
		currentItem = BG.cheapestItems[ locations[i] ]

		if itemCount < limit then
			-- keep this amount
			itemCount = itemCount + currentItem.count
			if currentItem.bag == bag and currentItem.slot == slot then
				return false
			end
		else
			return true
		end
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


-- == Item Values ==
-- calculates the value of a stack/partial stack of an item
function BG.GetItemValue(item, count)	-- itemID/itemLink/itemTable
	local itemID
	if not item then
		BG.Debug("BG.GetItemValue", "Invalid Argument", item, count)
		return nil
	elseif type(item) == "number" then
		itemID = item
	elseif type(item) == "string" then
		itemID = BG.GetItemID(item)
	elseif type(item) == "table" then
		itemID = item.itemID
	end

	local cachedItem = BG.GetCached(itemID)
	if cachedItem then
		return cachedItem.value * (count or 1)
	else
		local value = BG.GetSingleItemValue(itemID)
		return value and value * (count or 1) or nil
	end
end

-- returns which of the items' values is the highest (value, type)
function BG.GetSingleItemValue(item, label)	-- itemID/itemLink/itemTable
	local itemID, reason
	if not item then return nil
	elseif type(item) == "table" then
		itemID = item.itemID
		reason = item.reason
	elseif type(item) == "number" then itemID = item
	elseif type(item) == "string" then
		itemID = BG.GetItemID(item)
		if not itemID then return end
	end
	local _, itemLink, itemQuality, _, _, _, _, _, _, _, vendorPrice = GetItemInfo(itemID)

	if not itemQuality then		-- invalid argument
	   	BG.Debug("Error! GetSingleItemValue: Failed on "..(itemLink or itemID or "<unknown>").."."..(itemQuality or "no quality"))
	   	return nil
	end

	-- == handle special cases ========
	-- handle custom pricing
	if type(item) == "table" and item.priceLabel and item.priceLabel > 0 then
		if label and label == BG.EXCLUDE then
			-- fallback for over-limit keep items
			return item.priceLabel, BG.VENDOR, item.priceReason
		else
			return item.priceLabel, BG.CUSTOM, item.priceReason
		end
	end

	-- ignore AH prices for gray or BoP items
	if itemQuality == 0 or label == BG.VENDOR or ( BG.IsItemSoulbound(itemLink) and not IsUsableSpell(BG.enchanting) ) then
		return vendorPrice, vendorPrice and BG.VENDOR, reason
	end

	local auctionAddon, auctionPrice, disenchantPrice
	local canDisenchant, missingSkillPoints = BG.CanDisenchant(itemLink)
	canDisenchant = canDisenchant or (missingSkillPoints and missingSkillPoints <= BG_GlobalDB.keepItemsForLaterDE)

	-- check auction data
	for i, addonKey in ipairs(BG_GlobalDB.auctionAddonOrder.buyout) do
		auctionAddon = BG.auctionAddons[addonKey]
		if auctionAddon and auctionAddon.buyout then
			if not auctionPrice
				and auctionAddon.buyoutEnabled and auctionAddon.buyout then
				auctionPrice = auctionAddon.buyout(itemLink)
			end
			if auctionPrice then break end
		end
	end
	if not auctionPrice then auctionPrice = 0 end

	-- check disenchant data
	for i, addonKey in ipairs(BG_GlobalDB.auctionAddonOrder.disenchant) do
		auctionAddon = BG.auctionAddons[addonKey]
		if auctionAddon and auctionAddon.disenchant then
			if not disenchantPrice and canDisenchant
				and auctionAddon.disenchantEnabled and auctionAddon.disenchant then
				disenchantPrice = auctionAddon.disenchant(itemLink)
			end
			if disenchantPrice then break end
		end
	end

	if label == BG.AUCTION then
		return auctionPrice, BG.AUCTION, reason
	elseif label == BG.DISENCHANT or (label == BG.UNUSABLE and IsUsableSpell(BG.enchanting)) then
		return disenchantPrice, BG.DISENCHANT, reason
	end

	-- simply return the highest value price
	local maximum = max((disenchantPrice or 0), (auctionPrice or 0), (vendorPrice or 0))
	if disenchantPrice and disenchantPrice ~= 0 and maximum == disenchantPrice then
		return disenchantPrice, BG.DISENCHANT, reason
	elseif vendorPrice and vendorPrice ~= 0 and maximum == vendorPrice then
		return vendorPrice, BG.VENDOR, reason
	elseif auctionPrice and auctionPrice ~= 0 and maximum == auctionPrice then
		return auctionPrice, BG.AUCTION, reason
	else
		return 0, BG.IGNORE, "No price available"
	end
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

-- updated data taken from tekkub's Panda
-- player can disenchant this item: [true/false]; skill difference until DE is possible [nil/number]
function BG.CanDisenchant(itemLink, onlyMe)
	if not itemLink or itemLink:find("battlepet") then return end

	local required, skillRank
	if IsAddOnLoaded("Enchantrix") then
		required = Enchantrix.Util.DisenchantSkillRequiredForItem(itemLink)	-- might be more accurate/up to date in case I miss something
		skillRank = Enchantrix.Util.GetUserEnchantingSkill()	-- Enchantrix caches this. So let's use it!
	else
		local _, _, quality, ilvl, _, _, _, stackSize, invType = GetItemInfo(itemLink)

		-- stackables are not DE-able, legendary/heirlooms are not DE-able
		if quality <= 1 or quality > 5 or stackSize > 1 or not BG.IsItemEquipment(invType) then return end
		skillRank = BG.GetProfessionSkill(BG.enchanting) or 0

		if 	   ilvl <= 20 then required = 1
		elseif ilvl <= 60 then required = (floor(ilvl/5) - 3) * 25
		elseif ilvl <= 89 or (quality <= 3 and ilvl <= 99) then required = 225
		else
			if quality == 2 then -- uncommon
				if ilvl <= 120 then required = 275 end
				if ilvl <= 150 then required = 325 end
				if ilvl <= 182 then required = 350 end
				if ilvl <= 333 then required = 425 end
				if ilvl <= 437 then required = 475 end
			elseif quality == 3 then -- rare
				if ilvl <= 120 then required = 275 end
				if ilvl <= 200 then required = 325 end
				if ilvl <= 377 then required = 450 end
				if ilvl <= 424 then required = 525 end
				if ilvl <= 463 then required = 550 end
			elseif quality == 4 then -- epic
				if ilvl <= 151 then required = 300 end
				if ilvl <= 277 then required = 375 end
				if ilvl <= 416 then required = 475 end
				if ilvl <= 516 then required = 575 end
			end
		end
		if not required then required = PROFESSION_RANKS[#PROFESSION_RANKS][1] end
	end

	if not skillRank or not required then
		return false
	elseif skillRank >= required then
		return true
	elseif skillRank < required then
		return false, (required - skillRank)
	elseif BG_GlobalDB.hasEnchanter then
		return not onlyMe and not BG.IsItemSoulbound(itemLink, true)
	else
		return false
	end
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

-- == Items Cache Management ==
-- fetch an item from the item cache, or insert if it doesn't exist yet
function BG.GetCached(item)	-- itemID/itemLink
	if not item then
		return
	elseif type(item) == "string" then
		item = BG.GetItemID(item)
	end

	if not BG.itemsCache[item] then
		return BG.UpdateCache(item)
	end
	return BG.itemsCache[item]
end

function BG.ClearCache(itemID)
	if itemID then
		wipe(BG.itemsCache[itemID])
	else
		wipe(BG.itemsCache)
	end
end

-- gets an item's static information and saves it to the BG.itemsCache
function BG.UpdateCache(itemID) -- itemID/itemLink/itemTable
	if itemID and type(itemID) == "table" then itemID = itemID.itemID
	elseif itemID and type(itemID) == "number" then itemID = itemID
	elseif itemID and type(itemID) == "string" then itemID = BG.GetItemID(itemID)
	else return nil
	end

	-- recheck, we might not have gotten what we wanted
	if not itemID or itemID == 0 then return nil end

	local _, itemLink, quality, itemLevel, _, _, subClass, stackSize, _, _, vendorValue = GetItemInfo(itemID)
	if not itemLink then
		BG.Debug("UpdateCache("..itemID..") failed - no GetItemInfo() data available!")
		BG.requestedItemID = itemID
		BG.frame:RegisterEvent("GET_ITEM_INFO_RECEIVED")
		return nil
	end
	BG.Debug("|cffffd700> Updating cache for "..itemID.."|r ", itemLink)

	local itemLimit, itemLimitation = 0, nil
	local label, reason = nil, nil
	local priceLabel, priceReason = nil, nil

	-- check if item is classified by its itemID
	if BG.IsItemInBGList(itemID, "exclude") then
		label = BG.EXCLUDE
		reason = "ItemID is KEEP"
		itemLimit = BG_LocalDB.exclude[itemID] or BG_GlobalDB.exclude[itemID] or 0
		itemLimitation = itemLimit > 0 and itemID or nil
	end
	if not label and BG.IsItemInBGList(itemID, "autoSellList") then
		label = BG.AUTOSELL
		reason = "ItemID is SELL"
		itemLimit = BG_LocalDB.autoSellList[itemID] or BG_GlobalDB.autoSellList[itemID] or 0
		itemLimitation = itemLimit > 0 and itemID or nil
	end
	if not label and BG.IsItemInBGList(itemID, "include") then
		label = BG.INCLUDE
		reason = "ItemID is JUNK"
		itemLimit = BG_LocalDB.include[itemID] or BG_GlobalDB.include[itemID] or 0
		itemLimitation = itemLimit > 0 and itemID or nil
	end

	if BG.IsItemInBGList(itemID, "forceVendorPrice") then
		if not label then
			label = BG.VENDOR
			reason = "ItemID is VendorPrice"
		end
		if not priceLabel then
			priceLabel = BG_GlobalDB.forceVendorPrice[itemID]
			priceReason = "ItemID custom value"
		end
	end

	-- check if item is classified by its category
	if not label then
		-- Exclude List
		for category,_ in pairs(BG.JoinTables(BG_GlobalDB.exclude, BG_LocalDB.exclude)) do
			if type(category) == "string" and BG.IsItemInCategory(itemID, category) then
				if BG_GlobalDB.overrideLPT and quality == 0 then
					BG.Debug("Item's CATEGORY is on the KEEP LIST but the item is JUNK!")
				else
					label = BG.EXCLUDE
					reason = "Category is KEEP"
					itemLimit = BG_LocalDB.exclude[category] or BG_GlobalDB.exclude[category] or 0
					itemLimitation = itemLimit > 0 and category or nil
					break
				end
			end
		end
	end
	if not label then
		-- Auto Sell List
		for category,_ in pairs(BG.JoinTables(BG_GlobalDB.autoSellList, BG_LocalDB.autoSellList)) do
			if type(category) == "string" and BG.IsItemInCategory(itemID, category) then
				label = BG.AUTOSELL
				reason = "Category is SELL"
				itemLimit = BG_LocalDB.autoSellList[category] or BG_GlobalDB.autoSellList[category] or 0
				itemLimitation = itemLimit > 0 and category or nil
				break
			end
		end
	end
	if not label then
		-- Include List
		for category,_ in pairs(BG.JoinTables(BG_GlobalDB.include, BG_LocalDB.include)) do
			if type(category) == "string" and BG.IsItemInCategory(itemID, category) then
				label = BG.INCLUDE
				reason = "Category is JUNK"
				itemLimit = BG_LocalDB.include[category] or BG_GlobalDB.include[category] or 0
				itemLimitation = itemLimit > 0 and category or nil
				break
			end
		end
	end
	if not label then
		-- Vendor Price List
		for category,_ in pairs(BG_GlobalDB.forceVendorPrice) do
			if type(category) == "string" and BG.IsItemInCategory(itemID, category) then
				label = BG.VENDOR
				reason = "Category is VendorPrice"
				break
			end
		end
	end

	if not priceLabel then
		-- Vendor Price List
		for category,_ in pairs(BG_GlobalDB.forceVendorPrice) do
			if type(category) == "string" and BG.IsItemInCategory(itemID, category) then
				priceLabel = BG_GlobalDB.forceVendorPrice[category]
				priceReason = "Category custom value"
				break
			end
		end
	end

	-- quest items
	if not label and (BG.ScanTooltipFor(ITEM_STARTS_QUEST, itemLink) or BG.ScanTooltipFor(ITEM_BIND_QUEST, itemLink)) then
		label = BG.EXCLUDE
		reason = "Item is QUEST"
	end

	-- unusable gear
	if not label and Unfit:IsItemUnusable(itemLink) and BG.IsItemSoulbound(itemLink) then
		label = BG.UNUSABLE
		reason = "Item is UNUSABLE"
	end

	local value, itemLabel, tempReason = BG.GetSingleItemValue(itemID, label)
	if not label then
		BG.Debug("Assigning simple label", itemLabel, BG.FormatMoney(value))
		label = itemLabel
		reason = tempReason
	end

	if priceLabel then
		if priceLabel < 0 then
			value = vendorValue
			label = label or BG.VENDOR
		else
			value = priceLabel
			label = label or BG.CUSTOM
		end
	end

	-- still no data?
	if not (label and quality and value) then
		BG.Debug("Error! Caching item failed!", itemID, itemLink, label, quality, value)
		return
	end
	-- save to items cache
	if not BG.itemsCache[itemID] then
		BG.itemsCache[itemID] = {}
	end
	local itemCache = BG.itemsCache[itemID]

	itemCache.itemID = itemID
	itemCache.classification = label
	itemCache.reason = reason
	itemCache.priceLabel = priceLabel
	itemCache.priceReason = priceReason
	itemCache.vendorValue = vendorValue
	itemCache.value = value or 0 -- auction/DE/... value
	itemCache.quality = quality
	itemCache.stackSize = stackSize or 1
	itemCache.limit = itemLimit -- as configured in user lists
	itemCache.limiter = itemLimitation
	itemCache.level = itemLevel -- used for sorting, e.g. when using limits

	return itemCache
end
