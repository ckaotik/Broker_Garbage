local _, BG = ...

local Unfit = LibStub("Unfit-1.0")	-- library to determine unusable items

function BG.GetItemID(itemLink)
	if not itemLink then return end
	local itemID = string.gsub(itemLink, ".-Hitem:([0-9]*):.*", "%1")
	return tonumber(itemID)
end

-- /dump Broker_Garbage.GetItemListCategories(Broker_Garbage.GetCached(8766))
-- returns a list of (LPT) categories from the user's lists that an item belongs to
function BG.GetItemListCategories(item)
	if not item or type(item) ~= "table" then return end
	if item.bag then
		-- this is a cheapestList item, but we need cache data
		item = BG.GetCached(item.itemID)
	end

	local itemList, itemCategories, maxLimit = BG.lists[item.classification], {}, nil
	if itemList then
		local currentList = BG_GlobalDB[itemList]
		if currentList then
			for listItem, limit in pairs(currentList) do
				if type(listItem) == "string" and BG.IsItemInCategory(item.itemID, listItem) then
					table.insert(itemCategories, listItem)
					if not maxLimit or limit > maxLimit then
						maxLimit = limit
					end
				end
			end
		end
		currentList = BG_LocalDB[itemList]
		if currentList then
			for listItem, limit in pairs(currentList) do
				if type(listItem) == "string" and not BG.Find(itemCategories, listItem) and BG.IsItemInCategory(item.itemID, listItem) then
					table.insert(itemCategories, listItem)
					if not maxLimit or limit > maxLimit then
						maxLimit = limit
					end
				end
			end
		end
	end
	return itemCategories, maxLimit
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
	local categoryType, index = string.match(category, "^(.-)_(.+)")
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
			searchResult = itemName == index
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

-- supply either <bag, slot, itemTable> or <bag, slot, itemTable/limit, locationsTable>
function BG.IsItemOverLimit(bag, slot, item, locations)
	-- BG.IsItemOverLimit(container, slot, itemLimit, itemLocations)
	if not (bag and slot) then return end

	local limit = (type(item) == "table" and item.limit or item)
	if not (locations and limit) then
		locations, limit = BG.GetItemLocations(item, nil, true, true)
	end
	if not (locations and limit) or limit < 1 then return end

	local itemCount, currentItem = 0, nil
	for i = #locations, 1, -1 do
		currentItem = BG.cheapestItems[ locations[i] ]

		if itemCount < limit then
			-- keep this amount
			itemCount = itemCount + currentItem.count
			if currentItem.bag == bag and currentItem.slot == slot then
				return nil
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
	elseif (type(invType) == "string" and not string.find(invType, "INVTYPE")) or type(invType) == "number" then
		invType = select(9, GetItemInfo(invType))
	end
	return invType ~= "" and not string.find(invType, "BAG") and not string.find(invType, "TRINKET")
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
	local _, itemLink, itemQuality, itemLevel, _, _, _, _, itemType, _, vendorPrice = GetItemInfo(itemID)

	if not itemQuality then		-- invalid argument
	   	BG.Debug("Error! GetSingleItemValue: Failed on "..(itemLink or itemID or "<unknown>").."."..(itemQuality or "no quality"))
	   	return nil
	end

	-- == handle special cases ========
	-- handle custom pricing
	if type(item) == "table" and item.priceLabel then
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

	-- check auction data
	BG.auctionAddon = nil	-- forcefully reset this!
	local disenchantPrice, auctionPrice, source = 0, 0, nil
	local canDE, missingSkillPoints = BG.CanDisenchant(itemLink)
	canDE = canDE or (missingSkillPoints and missingSkillPoints <= BG_GlobalDB.keepItemsForLaterDE)

	-- calculate auction value: choose the highest auction/disenchant value
	if IsAddOnLoaded("Auctionator") then
		BG.auctionAddon = "Auctionator"
		auctionPrice = Atr_GetAuctionBuyout(itemLink) or 0
		disenchantPrice = canDE and Atr_GetDisenchantValue(itemLink)
	end

	if IsAddOnLoaded("Auc-Advanced") then	-- uses Market Value in any case
		BG.auctionAddon = (BG.auctionAddon and BG.auctionAddon..", " or "") .. "Auc-Advanced"
		auctionPrice = math.max(auctionPrice, AucAdvanced.API.GetMarketValue(itemLink))

		if IsAddOnLoaded("Enchantrix") then
			disenchantPrice = canDE and math.max(disenchantPrice or 0, select(3, Enchantrix.Storage.GetItemDisenchantTotals(itemLink)) or 0)
		end
	end

	if IsAddOnLoaded("AuctionLite") then
		BG.auctionAddon = (BG.auctionAddon and BG.auctionAddon..", " or "") .. "AuctionLite"
		auctionPrice = math.max(auctionPrice, AuctionLite:GetAuctionValue(itemLink) or 0)
		disenchantPrice = canDE and math.max(disenchantPrice or 0, AuctionLite:GetDisenchantValue(itemLink) or 0)
	end

	if IsAddOnLoaded("WOWEcon_PriceMod") then
		BG.auctionAddon = (BG.auctionAddon and BG.auctionAddon..", " or "") .. "WoWecon"
		auctionPrice = math.max(auctionPrice, Wowecon.API.GetAuctionPrice_ByLink(itemLink) or 0)

		if canDE and not disenchantPrice then
			local tmpPrice = 0
			local DEData = Wowecon.API.GetDisenchant_ByLink(itemLink)
			for i, data in pairs(DEData) do	-- [1] = item link, [2] = quantity, [3] = chance
				tmpPrice = tmpPrice + ((Wowecon.API.GetAuctionPrice_ByLink(data[1] or 0)) * data[2] * data[3])
			end
			disenchantPrice = math.max(disenchantPrice or 0, math.floor(tmpPrice or 0))
		end
	end

	-- last chance to get auction values
	if GetAuctionBuyout then
		BG.auctionAddon = BG.auctionAddon or BG.locale.unknown
		auctionPrice = math.max(auctionPrice, GetAuctionBuyout(itemLink) or 0)
	else
		BG.auctionAddon = BG.auctionAddon or BG.locale.na
	end
	if GetDisenchantValue then
		disenchantPrice = canDE and math.max(disenchantPrice or 0, GetDisenchantValue(itemLink) or 0)
	end

	if label == BG.AUCTION then
		return auctionPrice, BG.AUCTION, reason
	elseif label == BG.DISENCHANT or (label == BG.UNUSABLE and IsUsableSpell(BG.enchanting)) then
		return disenchantPrice, BG.DISENCHANT, reason
	end

	-- simply return the highest value price
	local maximum = math.max((disenchantPrice or 0), (auctionPrice or 0), (vendorPrice or 0))
	if disenchantPrice and maximum == disenchantPrice then
		return disenchantPrice, BG.DISENCHANT, reason
	elseif vendorPrice and maximum == vendorPrice then
		return vendorPrice, BG.VENDOR, reason
	elseif auctionPrice and maximum == auctionPrice then
		return auctionPrice, BG.AUCTION, reason
	else
		return nil, nil, nil
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
		leftLine = getglobal("BrokerGarbage_ItemScanTooltipTextLeft"..i)
		leftLineText = leftLine and leftLine:GetText()
		rightLine = getglobal("Broker_Garbage_ItemScanTooltipTextRight"..i)
		rightLineText = rightLine and rightLine:GetText()

		if (string.find(leftLineText, searchString) or (scanRightText and string.find(rightLineText, searchString)))
			and (not filterFunc or filterFunc(leftLineText, rightLineText)) then
			return leftLineText, rightLineText
		end
	end
end

-- returns whether an item is BoP/Soulbound
function BG.IsItemSoulbound(itemLink, bag, slot)	-- itemLink/itemID, bag, slot -OR- itemLink/itemID, checkMine -OR- itemTable
	if not itemLink then
		return nil
	elseif type(itemLink) == "number" or type(itemLink) == "table" then
		itemLink = select(2, GetItemInfo(itemLink))
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
	if not itemLink then return end

	local required, skillRank
	if IsAddOnLoaded("Enchantrix") then
		required = Enchantrix.Util.DisenchantSkillRequiredForItem(itemLink)	-- might be more accurate/up to date in case I miss something
		skillRank = Enchantrix.Util.GetUserEnchantingSkill()	-- Enchantrix caches this. So let's use it!
	else
		local _, _, quality, level, _, _, _, stackSize, invType = GetItemInfo(itemLink)

		-- stackables are not DE-able, legendary/heirlooms are not DE-able
		if quality > 1 and quality < 5 and stackSize == 1 and BG.IsItemEquipment(invType) then
			skillRank = BG.GetProfessionSkill(BG.enchanting) or 0

			if skillRank > 0 then
				if level <= 20 then required = 1
				elseif level <= 60 then required = 5*5*math.ceil(level/5)-100
				elseif level <= 89 or (level <=  99 and quality <= 3) then required = 225
				elseif level <= 120 then required = 275
				else
					if quality == 2 then		-- green
						if     level <= 150 then required = 325
						elseif level <= 182 then required = 350
						elseif level <= 333 then required = 425
						else required = nil	end
					elseif quality == 3 then	-- blue
						if     level <= 200 then required = 325
						elseif level <= 346 then required = 450
						else required = 450 end
					elseif quality == 4 then	-- purple
						if     level <= 199 then required = 300
						elseif level <= 277 then required = 375
						elseif level <= 379 then required = 525
						else required = 525	end
					end
				end
			end
		end
	end

	if not skillRank or not required then
		return false
	elseif skillRank >= required then
		return true
	elseif skillRank < required then
		return false, (required - skillRank)
	elseif BG_GlobalDB.hasEnchanter then
		if onlyMe then
			return false
		else
			-- check whether we can mail this item
			return not BG.IsItemSoulbound(itemLink, true)
		end
	else
		return false
	end
end

function BG.IsOutdatedItem(item)	-- itemID/itemLink/itemTable
	local _, itemLink, quality
	if not item then
		return nil
	elseif type(item) == "table" then
		itemLink = select(2, GetItemInfo(item.itemID))
		quality = item.quality
	else
		_, itemLink, quality = GetItemInfo(item)
	end

	if BG_GlobalDB.sellOldGear and quality <= BG_GlobalDB.sellNWQualityTreshold
		and BG.IsItemSoulbound(itemLink, true) and BG.IsTopFitOutdatedItem(itemLink) then
		return true
	end
end

-- returns true if, by TopFit's standards, the given item is "outdated"
function BG.IsTopFitOutdatedItem(item)
	local _, itemLink
	if not item then
		return nil
	elseif type(item) == "table" then
		itemLink = GetContainerItemLink(BG.FindItemInBags(item.itemID))
	else
		_, itemLink = GetItemInfo(item)
	end

	if IsAddOnLoaded("TopFit") and TopFit.IsInterestingItem then
		local invType = select(9, GetItemInfo(itemLink))
		if BG.IsItemEquipment(invType) and not TopFit:IsInterestingItem(itemLink) then
			return true
		end
	else
		BG.Debug("TopFit is not loaded or too old.")
		return nil
	end
end

-- deletes the item in a given location of your bags
function BG:Delete(item, position)
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
		position = {item.bag, item.slot}

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
	local bag = position[1] or item.bag
	local slot = position[2] or item.slot
	if not cursorType and (not (bag and slot) or GetContainerItemID(bag, slot) ~= itemID) then
		BG.Print("Error! Item to be deleted is not the expected item.")
		BG.Debug("I got these parameters:", item, bag, slot)
		return
	end

	-- make sure there is nothing unwanted on the cursor
	if not cursorType then
		ClearCursor()
	end

	_, itemCount = GetContainerItemInfo(bag, slot)

	-- actual deleting happening after this
	securecall(PickupContainerItem, bag, slot)
	securecall(DeleteCursorItem)					-- comment this line to prevent item deletion

	local itemValue = (BG.GetCached(itemID).value or 0) * itemCount	-- if an item is unknown to the cache, statistics will not change
	-- statistics
	BG_GlobalDB.itemsDropped 		= BG_GlobalDB.itemsDropped + itemCount
	BG_GlobalDB.moneyLostByDeleting	= BG_GlobalDB.moneyLostByDeleting + itemValue
	BG_LocalDB.moneyLostByDeleting 	= BG_LocalDB.moneyLostByDeleting + itemValue

	local _, itemLink = GetItemInfo(itemID)
	BG.Print(format(BG.locale.itemDeleted, itemLink, itemCount))
end

-- == Items Cache Management ==
function BG.ClearCache()
	BG.itemsCache = {}
end

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

-- gets an item's static information and saves it to the BG.itemsCache
function BG.UpdateCache(itemID) -- itemID/itemLink/itemTable
	if not itemID then return nil
	elseif type(itemID) == table then itemID = itemID.itemID
	elseif type(itemID) == "number" then itemID = itemID
	elseif type(itemID) == "string" then itemID = BG.GetItemID(itemID)
	else return nil
	end

	-- recheck, we might not have gotten what we wanted
	if not itemID then return nil
	else
		BG.Debug("|cffffd700> Updating cache for "..itemID.."|r", itemLink)
	end

	local _, itemLink, quality, itemLevel, _, _, subClass, stackSize, _, _, vendorValue = GetItemInfo(itemID)
	if not quality then
		BG.Debug("UpdateCache("..itemID..") failed - no GetItemInfo() data available!")
		return nil
	end

	local itemLimit = 0
	local label, reason = nil, nil
	local priceLabel, priceReason = nil, nil

	-- check if item is classified by its itemID
	if not label and BG.IsItemInBGList(itemID, "exclude") then
		label = BG.EXCLUDE
		reason = "ItemID is KEEP"
		itemLimit = BG_LocalDB.exclude[itemID] or BG_GlobalDB.exclude[itemID] or 0
	end
	if not label and BG.IsItemInBGList(itemID, "autoSellList") then
		label = BG.AUTOSELL
		reason = "ItemID is SELL"
		itemLimit = BG_LocalDB.autoSellList[itemID] or BG_GlobalDB.autoSellList[itemID] or 0
	end
	if not label and BG.IsItemInBGList(itemID, "include") then
		label = BG.INCLUDE
		reason = "ItemID is JUNK"
		itemLimit = BG_LocalDB.include[itemID] or BG_GlobalDB.include[itemID] or 0
	end
	--[[ if not label and BG.IsItemInBGList(itemID, "forceVendorPrice") then
		label = BG.VENDOR
		reason = "ItemID is VendorPrice"
	end --]]

	if BG.IsItemInBGList(itemID, "forceVendorPrice") then
		if not label then
			label = BG.VENDOR
			reason = "ItemID is VendorPrice"
		end
		if not priceLabel then
			priceLabel = priceLabel or BG.VENDOR
			priceReason = priceReason or "ItemID is VendorPrice"
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
	end --]]

	if not priceLabel then
		-- Vendor Price List
		for category,_ in pairs(BG_GlobalDB.forceVendorPrice) do
			if type(category) == "string" and BG.IsItemInCategory(itemID, category) then
				priceLabel = BG.VENDOR
				priceReason = "Category is VendorPrice"
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
		-- and BG_GlobalDB.sellNotWearable and quality <= BG_GlobalDB.sellNWQualityTreshold
		-- and (quality < 2 or not IsUsableSpell(BG.enchanting)) then
		label = BG.UNUSABLE
		reason = "Item is UNUSABLE"
	end

	local value, itemLabel = BG.GetSingleItemValue(itemID, label)
	if not label then
		BG.Debug("Assigning simple label", itemLabel, BG.FormatMoney(value))
		label = itemLabel
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
	itemCache.level = itemLevel -- used for sorting, e.g. when using limits

	return itemCache
end
