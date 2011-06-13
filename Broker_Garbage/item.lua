local _, BG = ...

local Unfit = LibStub("Unfit-1.0")	-- library to determine unusable items

function BG.GetItemID(itemLink)
	if not itemLink then return end
	local itemID = string.gsub(itemLink, ".-Hitem:([0-9]*):.*", "%1")
	return tonumber(itemID)
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
	
	local searchResult
	local isNotLPT = type(category) ~= "string"
	if isNotLPT then
		local categoryType, index = string.match(category, "^(%S+)_(%d+)")
		index = tonumber(index) 
		if categoryType == "BEQ" and index then	-- equipment set
			if index <= GetNumEquipmentSets() then
				category = GetEquipmentSetInfo(index)
				searchResult = BG.Find(GetEquipmentSetItemIDs(category), itemID)
			end
		elseif categoryType == "AC" and index then	-- armor class
			local armorClass = select(index, GetAuctionItemSubClasses(2))
			searchResult = select(7, GetItemInfo(itemID)) == armorClass
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

function BG.IsItemOverLimit(item, bag, slot)
	-- [TODO] Update sizes and stuff for list items!
	local saveStacks = ceil(item.limit/item.stackSize)
	local locations = BG.GetItemLocations(item.itemID)
	
	if #locations > saveStacks then
		local itemCount = 0
		
		for i = #locations, 1, -1 do
			if itemCount < item.limit then
				-- keep this amount
				itemCount = itemCount + locations[i].count
				if locations[i].bag == bag and locations[i].slot == slot then
					return nil
				end
			else
				return true
			end
		end
	else
		return nil
	end
end

-- returns true if the item is equippable. **Trinkets don't count!**
function BG.IsItemEquipment(invType)	-- itemLink/itemID/invType
	if not invType or invType == "" then
		return nil
	elseif type(invType) == "string" and not string.find(invType, "INVTYPE") then
		invType = select(9, GetItemInfo(invType))
	end
	return not string.find(invType, "BAG") and not string.find(invType, "TRINKET")
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
	local itemID
	if not item then
		return nil
	elseif type(item) == "number" then
		itemID = item
	elseif type(item) == "string" then
		itemID = BG.GetItemID(item)
		if not itemID then return end
	elseif type(item) == "table" then
		itemID = item.itemID
	end
	local _, itemLink, itemQuality, itemLevel, _, _, _, _, itemType, _, vendorPrice = GetItemInfo(itemID)
	
	BG.Debug("BG.GetSingleItemValue", item, itemID, label, itemLink)
	if not itemQuality then		-- invalid argument
	   	BG.Debug("Error! GetSingleItemValue: Failed on "..(itemLink or itemID or "<unknown>").."."..(itemQuality or "no quality"))
	   	return nil
	end

	-- handle special cases
	-- ignore AH prices for gray or BOP items
	if itemQuality == 0 or label == BG.VENDOR or label == BG.UNUSABLE 
		or (BG.IsItemSoulbound(itemLink) and not IsUsableSpell(BG.enchanting)) then
		return vendorPrice, vendorPrice and BG.VENDOR
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

	-- simply return the highest value price
	local maximum = math.max((disenchantPrice or 0), (auctionPrice or 0), (vendorPrice or 0))
	if disenchantPrice and maximum == disenchantPrice then
		return disenchantPrice, BG.DISENCHANT
	elseif vendorPrice and maximum == vendorPrice then
		return vendorPrice, BG.VENDOR
	elseif auctionPrice and maximum == auctionPrice then
		return auctionPrice, BG.AUCTION
	else
		return nil, nil
	end
end

-- == Misc Item Information ==
local scanTooltip = CreateFrame("GameTooltip", "BrokerGarbage_ItemScanTooltip", UIParent, "GameTooltipTemplate")
function BG.ScanTooltipFor(searchString, itemLink, inBag, slot)
	-- call only with searchString, itemLink -or- inBag := true -or- inBag := bagID, slot := slotID
	if not itemLink then return end
	scanTooltip:SetOwner(UIParent, "ANCHOR_NONE")

	local slot
	if inBag and slot then
		scanTooltip:SetBagItem(inBag, slot)
	elseif inBag then
		bag, slot = BG.FindItemInBags(itemLink)
		scanTooltip:SetBagItem(bag, slot)
	else
		scanTooltip:SetHyperlink(itemLink)
	end
	
	local numLines = scanTooltip:NumLines()
	for i = 1, numLines do
		local leftLine = getglobal("BrokerGarbage_ItemScanTooltipTextLeft"..i)
		local leftLineText = leftLine:GetText()
		
		if string.find(leftLineText, searchString) then
			return true
		end
	end
	return nil
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

	return BG.ScanTooltipFor(searchString, itemLink, bag, slot)
end

-- [TODO] update for cataclysm
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
		if quality >= 2 and quality < 5 and stackSize == 1 
			and string.find(invType, "INVTYPE") and not string.find(invType, "BAG") then

			skillRank = BG.GetProfessionSkill(BG.enchanting) or 0
			if skillRank > 0 then
				if level <=  20 then
					required = 1
				elseif level <=  60 then
					required = 5*5*math.ceil(level/5)-100
				elseif level <=  99 then
					required = 225
				elseif level <= 120 then
					required = 275
				else
					if quality == 2 then		-- green
						if level <= 150 then
							required = 325
						elseif level <= 200 then
							required = 350
						elseif level <= 305 then
							required = 425
						else
							required = 475
						end
					elseif quality == 3 then	-- blue
						if level <= 200 then
							required = 325
						elseif level <= 325 then
							required = 450
						else
							required = 500
						end
					elseif quality == 4 then	-- purple
						if level <= 199 then
							required = 300
						elseif level <= 277 then
							required = 375
						else
							required = 500
						end
					end
				end
			end
		end
	end
	
	if not skillRank or not required then
		-- this item is not disenchantable
		return false
	elseif skillRank >= required then
		-- this character can disenchant the item. Perfect!
		return true
	elseif skillRank < required then
		return false, (required - skillRank)
	elseif BG_GlobalDB.hasEnchanter then
		if onlyMe then
			-- we can't disenchant this ourselves
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
	local itemLink, quality
	if not item then
		return nil
	elseif type(item) == "number" then
		_, itemLink, quality = GetItemInfo(item)
	elseif type(item) == "string" then
		itemLink = item
		quality = select(3, GetItemInfo(item))
	else
		itemLink = select(2, GetItemInfo(item.itemID))
		quality = item.quality
	end

	if BG_GlobalDB.sellOldGear and quality <= BG_GlobalDB.sellNWQualityTreshold
		and BG.IsItemSoulbound(itemLink, true) and BG.IsTopFitOutdatedItem(itemLink) then
		return true
	end
end

-- returns true if, by TopFit's standards, the given item is "outdated"
function BG.IsTopFitOutdatedItem(item)
	local invType
	if not item then
		return nil
	elseif type(item) == "number" or type(item) == "string" then
		_, item, _, _, _, _, _, _, invType = GetItemInfo(item)
	else
		invType = item.itemType
		item = GetContainerItemLink(BG.FindItemInBags(item.itemID))
	end

	if IsAddOnLoaded("TopFit") and TopFit.IsInterestingItem then
		if not TopFit:IsInterestingItem(item) and BG.IsItemEquipment(invType) then
			return true
		end
	else
		BG.Debug("TopFit is not loaded or too old.")
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
function BG.UpdateCache(item) -- itemID/itemLink
	local itemID
	if item and type(item) == "number" then
		itemID = item
	elseif type(item) == "string" then
		itemID = BG.GetItemID(item)
	else
		return nil
	end
	
	BG.Debug("Updating cache for "..itemID)
	local _, itemLink, quality, itemLevel, _, _, subClass, stackSize, invType, _, value = GetItemInfo(itemID)
	local family = GetItemFamily(itemID)
	if not quality then
		BG.Debug("UpdateCache("..(itemID or "<none>")..") failed - no GetItemInfo() data available!")
		return nil
	end

	local itemLimit, label = 0, nil
	-- check if item is classified by its itemID
	if BG.ScanTooltipFor(ITEM_STARTS_QUEST, itemLink) or BG.ScanTooltipFor(ITEM_BIND_QUEST, itemLink) then
		BG.Debug("Item is a quest starter/quest item.", itemID, itemLink)
		label = BG.EXCLUDE
	end

	if not label and BG.IsItemInBGList(itemID, "exclude") then
		BG.Debug("Item's ITEMID is on the KEEP LIST.", itemID, itemLink)
		label = BG.EXCLUDE
		itemLimit = BG_LocalDB.exclude[itemID] or BG_GlobalDB.exclude[itemID] or 0
	end
	if not label and BG.IsItemInBGList(itemID, "autoSellList") then
		BG.Debug("Item's ITEMID is on the SELL LIST.", itemID, itemLink)
		label = BG.AUTOSELL
		itemLimit = BG_LocalDB.autoSellList[itemID] or BG_GlobalDB.autoSellList[itemID] or 0
	end
	if not label and BG.IsItemInBGList(itemID, "include") then
		BG.Debug("Item's ITEMID is on the JUNK LIST.", itemID, itemLink)
		label = BG.INCLUDE
		itemLimit = BG_LocalDB.include[itemID] or BG_GlobalDB.include[itemID] or 0
	end
	if not label and BG.IsItemInBGList(itemID, "forceVendorPrice") then
		BG.Debug("Item's ITEMID is on the VENDOR PRICE LIST.", itemID, itemLink)
		label = BG.VENDOR
	end
	
	-- check if item is classified by its category
	if not label then
		-- Exclude List
		for category,_ in pairs(BG.JoinTables(BG_GlobalDB.exclude, BG_LocalDB.exclude)) do
			if type(category) == "string" and BG.IsItemInCategory(itemID, category) then
				if BG_GlobalDB.overrideLPT and quality == 0 then
					BG.Debug("Item's CATEGORY is on the KEEP LIST but the item is JUNK!", itemID, itemLink)
				else
					BG.Debug("Item' CATEGORY is on the KEEP LIST.", itemID, itemLink)
					label = BG.EXCLUDE
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
				BG.Debug("Item' CATEGORY is on the AUTO SELL LIST.", itemID, itemLink)
				label = BG.AUTOSELL
				itemLimit = BG_LocalDB.autoSellList[category] or BG_GlobalDB.autoSellList[category] or 0
				break
			end
		end
	end
	if not label then
		-- Include List
		for category,_ in pairs(BG.JoinTables(BG_GlobalDB.include, BG_LocalDB.include)) do
			if type(category) == "string" and BG.IsItemInCategory(itemID, category) then
				BG.Debug("Item's CATEGORY is on the JUNK LIST.", itemID, itemLink)
				label = BG.INCLUDE
				itemLimit = BG_LocalDB.include[category] or BG_GlobalDB.include[category] or 0
				break
			end
		end
	end
	if not label then
		-- Vendor Price List
		for category,_ in pairs(BG_GlobalDB.forceVendorPrice) do
			if type(category) == "string" and BG.IsItemInCategory(itemID, category) then
				BG.Debug("Item's CATEGORY is on the VENDOR PRICE LIST.", itemID, itemLink)
				label = BG.VENDOR
				break
			end
		end
	end

	-- unusable gear
	if not label
		and Unfit:IsItemUnusable(itemLink) and BG_GlobalDB.sellNotWearable
		and quality >= 2 and quality <= BG_GlobalDB.sellNWQualityTreshold
		and not IsUsableSpell(BG.enchanting) and BG.IsItemSoulbound(itemLink) then
		BG.Debug("Item is UNUSABLE; We can't ever wear it.", itemID, itemLink)
		label = BG.UNUSABLE
	end

	local value, itemLabel = BG.GetSingleItemValue(itemID, label)	-- [TODO] make sure it's correct!!! value might be wrong
	if not label then
		BG.Debug("Assigning simple label.", itemID, itemLink, itemLabel)
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

	itemCache.level = itemLevel
	itemCache.value = value or 0
	itemCache.limit = itemLimit
	itemCache.quality = quality
	itemCache.family = family
	itemCache.itemType = invType
	itemCache.stackSize = stackSize or 1

	return itemCache
end