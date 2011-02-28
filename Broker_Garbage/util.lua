-- to enable debug mode, run: /run BG_GlobalDB.debug = true
local _, BG = ...

-- Basic Functions
-- ---------------------------------------------------------
function BG:Print(text)
	DEFAULT_CHAT_FRAME:AddMessage("|cffee6622Broker_Garbage|r "..text)
end

-- prints debug messages only when debug mode is active
function BG:Debug(...)
  if BG_GlobalDB and BG_GlobalDB.debug then
	BG:Print("! "..string.join(", ", tostringall(...)))
  end
end

-- checks for and sets default settings
function BG:CheckSettings()
	local first
	if not BG_GlobalDB then BG_GlobalDB = {}; first = true end
	for key, value in pairs(BG.defaultGlobalSettings) do
		if BG_GlobalDB[key] == nil then
			BG_GlobalDB[key] = value
		end
	end
	
	if not BG_LocalDB then 
		BG_LocalDB = {}
		if not first then first = false end
	end
	for key, value in pairs(BG.defaultLocalSettings) do
		if BG_LocalDB[key] == nil then
			BG_LocalDB[key] = value
		end
	end
	
	if first ~= nil then
		BG:CreateDefaultLists(first)
	end
end

-- Table Manipulation
-- ---------------------------------------------------------
-- check if a given value can be found in a table
function BG:Find(table, value)
	for k, v in pairs(table) do
		if (v == value) then return true end
	end
	return false
end

-- counts table entries. for numerically indexed tables, use #table
function BG:Count(table)
  local i = 0
  for _, _ in pairs(table) do i = i + 1 end
  return i
end

-- joins any number of non-basic index tables together, one after the other. elements within the input-tables _will_ get mixed
function BG:JoinTables(...)
	local result = {}
	local tab
	
	for i=1,select("#", ...) do
		tab = select(i, ...)
		if tab then
			for index, value in pairs(tab) do
				result[index] = value
			end
		end
	end
	
	return result
end

-- joins numerically indexed tables
function BG:JoinSimpleTables(...)
	local result = {}
	local tab, i, j
	
	for i=1,select("#", ...) do
		tab = select(i, ...)
		if tab then
			for _, value in pairs(tab) do
				tinsert(result, value)
			end
		end
	end
	
	return result
end

-- Professions and default lists
-- ---------------------------------------------------------
-- returns the current and maximum rank of a given skill
function BG:GetProfessionSkill(skill)
	if not skill or (type(skill) ~= "number" and type(skill) ~= "string") then return end
	if type(skill) == "number" then
		skill = GetSpellInfo(skill)
	end
	
	local rank, maxRank
	local professions = { GetProfessions() }
	for _, profession in ipairs(professions) do
		local pName, _, pRank, pMaxRank = GetProfessionInfo(profession)
		if pName and pName == skill then
			rank = pRank
			maxRank = pMaxRank
			break
		end
	end
	return rank, maxRank
end

-- takes a tradeskill id (as returned in GetProfessions()) and returns its English name 
function BG:GetTradeSkill(id)
	if not id then return end
	local spellName
	local compareName = GetProfessionInfo(id) 
	for spellID, skillName in pairs(BG.tradeSkills) do
		spellName = GetSpellInfo(spellID)
		if spellName == compareName then
			return skillName
		end
	end
	return "Herbalism"
end

-- inserts some basic list settings
function BG:CreateDefaultLists(global)
	if global then
		BG_GlobalDB.include[46069] = true											-- argentum lance
		BG_GlobalDB.include["Consumable.Water.Conjured"] = true
		BG_GlobalDB.include["Consumable.Food.Edible.Basic.Conjured"] = true
		BG_GlobalDB.exclude["Misc.StartsQuest"] = true
		BG_GlobalDB.forceVendorPrice["Consumable.Food.Edible.Basic"] = true
		BG_GlobalDB.forceVendorPrice["Consumable.Water.Basic"] = true
		BG_GlobalDB.forceVendorPrice["Tradeskill.Mat.BySource.Vendor"] = true
	end
	
	-- tradeskills
	local tradeSkills =  { GetProfessions() }
	for i = 1, 6 do	-- we get at most 6 professions (2x primary, cooking, fishing, first aid, archeology)
		local englishSkill = BG:GetTradeSkill(tradeSkills[i])
		if englishSkill then
			if englishSkill == "Herbalism" or englishSkill == "Skinning" or englishSkill == "Mining" or englishSkill == "Fishing" then
				BG_LocalDB.exclude["Tradeskill.Gather." .. englishSkill] = true
			else
				BG_LocalDB.exclude["Tradeskill.Mat.ByProfession." .. englishSkill] = true
			end
			
			if englishSkill ~= "Herbalism" and englishSkill ~= "Archaeology" then
				BG_LocalDB.exclude["Tradeskill.Tool." .. englishSkill] = true
			end
		end
	end
	
	-- class specific
	if BG.playerClass == "WARRIOR" or BG.playerClass == "ROGUE" or BG.playerClass == "DEATHKNIGHT" or BG.playerClass == "HUNTER" then
		BG_LocalDB.autoSellList["Consumable.Water"] = true
	
	elseif BG.playerClass == "SHAMAN" then
		if not BG_LocalDB.include[17058] then BG_LocalDB.include[17058] = 20 end	-- fish oil
		if not BG_LocalDB.include[17057] then BG_LocalDB.include[17057] = 20 end	-- scales
	end
	BG_LocalDB.exclude["Misc.Reagent.Class."..string.gsub(string.lower(BG.playerClass), "^.", string.upper)] = true
	
	BG:Print(BG.locale.listsUpdatedPleaseCheck)

	BG.itemsCache = {}
	BG:ScanInventory()
	if BG.ListOptionsUpdate then
		BG:ListOptionsUpdate()
	end
end

-- Helpers
-- ---------------------------------------------------------
-- returns an item's itemID
function BG:GetItemID(itemLink)
	if not itemLink then return end
	local itemID = string.gsub(itemLink, ".-Hitem:([0-9]*):.*", "%1")
	return tonumber(itemID)
end

local scanTooltip = CreateFrame('GameTooltip', 'BGItemScanTooltip', UIParent, 'GameTooltipTemplate')
-- returns true if the given item is soulbound
function BG:IsItemSoulbound(itemLink, bag, slot)
	scanTooltip:SetOwner(UIParent, 'ANCHOR_NONE')
	local searchString
	
	if not (bag and slot) then
		-- check if item is BOP
		scanTooltip:SetHyperlink(itemLink)
		searchString = ITEM_BIND_ON_PICKUP
	else
		-- check if item is soulbound
		scanTooltip:SetBagItem(bag, slot)
		searchString = ITEM_SOULBOUND
	end

	local numLines = scanTooltip:NumLines()
	for i = 1, numLines do
		local leftLine = getglobal("BGItemScanTooltip".."TextLeft"..i)
		local leftLineText = leftLine:GetText()
		
		if string.find(leftLineText, searchString) then
			return true
		end
	end
	return false
end

-- misc: either "true" to check only for the current character, or a table {container, slot} for reference
function BG:CanDisenchant(itemLink, location)
	if not itemLink then return end
	
	local required, skillRank = 0	-- required disenchant skill
	if IsAddOnLoaded("Enchantrix") then
		required = Enchantrix.Util.DisenchantSkillRequiredForItem(itemLink)	-- might be more accurate/up to date in case I miss something
		skillRank = Enchantrix.Util.GetUserEnchantingSkill()	-- Enchantrix caches this. So let's use it!
	else
		local _, _, quality, level, _, _, _, stackSize, invType = GetItemInfo(itemLink)

		-- stackables are not DE-able, legendary/heirlooms are not DE-able
		if quality >= 2 and quality < 5 and stackSize == 1 
			and string.find(invType, "INVTYPE") and not string.find(invType, "BAG") then

			skillRank = BG:GetProfessionSkill(BG.enchanting) or 0
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
	elseif BG_GlobalDB.hasEnchanter then
		if location and type(location) == "boolean" then
			-- misc = true => Only regard this character. Exit.
			return false
		elseif location and type(location) == "table" then
			-- misc = {bag, slot} => Can we mail this item?
			return not BG:IsItemSoulbound(itemLink, location.bag, location.slot)
		else
			return not BG:IsItemSoulbound(itemLink)
		end
	else
		return false
	end
end

-- return true if item is found in LPT/Equipment list, nil otherwise
function BG:IsItemInList(itemID, itemList)
	local temp
	if type(itemList) == "string" and string.match(itemList, "^BEQ_(%d+)") then
		-- equipment set
		local setID = string.match(itemList, "^BEQ_(%d+)")
		setID = tonumber(setID) 
		if setID and setID <= GetNumEquipmentSets() then
			itemList = GetEquipmentSetInfo(setID)
			itemList = GetEquipmentSetItemIDs(itemList)
			temp = BG:Find(itemList, itemID)
		end
    elseif type(itemList) == "string" and string.match(itemList, "^AC_(%d+)") then
		-- armor class
		local armorClass = string.match(itemList, "^AC_(%d+)")
		local index = tonumber(armorClass) 
		armorClass = select(index, GetAuctionItemSubClasses(2))
		temp = select(7, GetItemInfo(itemID)) == armorClass
	elseif BG.PT and type(itemList) == "string" then
		-- LPT category
		_, temp = BG.PT:ItemInSet(itemID, itemList)
	end
	return temp and true or nil
end

-- gets an item's classification and saves it to the item cache
function BG:UpdateCache(itemID)
	if not itemID then return nil end
	local class, temp, limit
	
	local hasData, itemLink, quality, itemLevel, _, _, subClass, stackSize, invType, _, value = GetItemInfo(itemID)
	local family = GetItemFamily(itemID)
	if not hasData then
		BG:Debug("UpdateCache("..(itemID or "<none>")..") failed - no GetItemInfo() data available!")
		return nil
	end
	
	-- check if item is excluded by itemID
	if BG_GlobalDB.exclude[itemID] or BG_LocalDB.exclude[itemID] then
		BG:Debug("Item "..itemID.." is excluded via its itemID.")
		class = BG.EXCLUDE
	end
	
	-- check if the item is classified by its itemID
	if not class or class ~= BG.EXCLUDE then
		if BG_GlobalDB.include[itemID] or BG_LocalDB.include[itemID] then
			
			if BG_LocalDB.include[itemID] and type(BG_LocalDB.include[itemID]) ~= "boolean" then
				-- limited item, local rule
				BG:Debug("Item "..itemID.." is locally limited via its itemID.")
				class = BG.LIMITED
				limit = BG_LocalDB.include[itemID]
			
			elseif BG_GlobalDB.include[itemID] and type(BG_GlobalDB.include[itemID]) ~= "boolean" then
				-- limited item, global rule
				BG:Debug("Item "..itemID.." is globally limited via its itemID.")
				class = BG.LIMITED
				limit = BG_GlobalDB.include[itemID]
			
			else
				BG:Debug("Item "..itemID.." is included via its itemID.")
				class = BG.INCLUDE
			end
		
		elseif BG_GlobalDB.forceVendorPrice[itemID] then
			BG:Debug("Item "..itemID.." has a forced vendor price via its itemID.")
			class = BG.VENDOR
		
		elseif BG_GlobalDB.autoSellList[itemID] or BG_LocalDB.autoSellList[itemID] then
			BG:Debug("Item "..itemID.." is to be auto-sold via its itemID.")
			class = BG.SELL
		
		elseif quality 
			and not IsUsableSpell(BG.enchanting) and BG:IsItemSoulbound(itemLink)
			and string.find(invType, "INVTYPE") and not string.find(invType, "BAG") 
			and (not BG.usableGear[subClass] or not BG:Find(BG.usableGear[subClass], BG.playerClass))
			and not BG.usableByAll[invType] then
			
			BG:Debug("Item "..itemID.." should be sold as we can't ever wear it.")
			class = BG.UNUSABLE
		
		elseif quality -- and BG_GlobalDB.sellOldGear
		    and string.find(invType, "INVTYPE") and not string.find(invType, "BAG")
		    and IsAddOnLoaded("TopFit") and TopFit.IsInterestingItem and not TopFit:IsInterestingItem(itemID) then
		    BG:Debug("Item "..itemID.." is classified OUTDATED by TopFit.", invType)
		    class = BG.OUTDATED
			
		-- check if the item is classified by its category
		else
			-- check if item is excluded by its category
			for setName,_ in pairs(BG:JoinTables(BG_GlobalDB.exclude, BG_LocalDB.exclude)) do
				if BG:IsItemInList(itemID, setName) then
					BG:Debug("Item "..itemID.." is EXCLUDED via its category.")
					class = BG.EXCLUDE
					break
				end
			end
			
			-- Include List
			if not class then
				for setName,_ in pairs(BG:JoinTables(BG_LocalDB.include, BG_GlobalDB.include)) do
					if BG:IsItemInList(itemID, setName) then
						BG:Debug("Item "..itemID.." in INCLUDED via its item category.")
						class = BG.INCLUDE
						break
					end
				end
			end
			
			-- Sell List
			if not class then
				for setName,_ in pairs(BG:JoinTables(BG_GlobalDB.autoSellList, BG_LocalDB.autoSellList)) do
					if BG:IsItemInList(itemID, setName) then
						BG:Debug("Item "..itemID.." is on the sell list via its item category.")
						class = BG.SELL
						break
					end
				end
			end
			
			-- Force Vendor Price List
			if not class then
				for setName,_ in pairs(BG_GlobalDB.forceVendorPrice) do
					if BG:IsItemInList(itemID, setName) then
						BG:Debug("Item "..itemID.." has a forced vendor price via its item category.")
						class = BG.VENDOR
						break
					end
				end
			end
		end
	end
	
	local tvalue, tclass = BG:GetSingleItemValue(itemID)
	if not class then class = tclass end
	if not (class == BG.VENDOR or class == BG.SELL or (class == BG.INCLUDE and BG_GlobalDB.autoSellIncludeItems)) then 
		value = tvalue
	end
	
	-- save to items cache
	if not class or not quality or not value then
		BG:Debug("Error! Caching item "..itemID.." failed!", class, quality, value)
		return
	end
	if not BG.itemsCache[itemID] then
		BG.itemsCache[itemID] = {
			classification = class,
			quality = quality,
			family = family,
			itemType = itemType,
			level = itemLevel,
			value = value or 0,
			limit = limit,
			stackSize = stackSize,
			isClam = BG:Find(BG.clams, itemID),
		}
	else
		BG.itemsCache[itemID].classification = class
		BG.itemsCache[itemID].quality = quality
		BG.itemsCache[itemID].family = family
		BG.itemsCache[itemID].itemType = itemType
		BG.itemsCache[itemID].value = value or 0
		BG.itemsCache[itemID].limit = limit
		BG.itemsCache[itemID].level = itemLevel
		BG.itemsCache[itemID].stackSize = stackSize
		BG.itemsCache[itemID].isClam = BG:Find(BG.clams, itemID)
	end
end

-- fetch an item from the item cache, or insert if it doesn't exist yet
function BG:GetCached(itemID)
	if not itemID then return end
	if not BG.itemsCache[itemID] then
		BG:UpdateCache(itemID)
	end
	return BG.itemsCache[itemID]
end

-- LDB formating
-- ---------------------------------------------------------
-- returns total bag slots and free bag slots of your whole inventory
function BG:GetBagSlots()
	local numSlots, freeSlots = 0, 0
	local specialSlots, specialFree = 0, 0
	local bagSlots, emptySlots, bagType
	
	for i = 0, 4 do
		bagSlots = GetContainerNumSlots(i) or 0
		emptySlots, bagType = GetContainerNumFreeSlots(i)
		
		if bagType and bagType == 0 then
			numSlots = numSlots + bagSlots
			freeSlots = freeSlots + emptySlots
		else
			specialSlots = specialSlots + bagSlots
			specialFree = specialFree + emptySlots
		end
	end
	return numSlots, freeSlots, specialSlots, specialFree
end

-- returns a red-to-green color depending on the given percentage
function BG:Colorize(min, max)
	local color
	if not min then
		return ""
	elseif type(min) == "table" then
		color = { min.r*255, min.g*255, min.b*255}
	else
		local percentage = min/(max and max ~= 0 and max or 1)
		if percentage <= 0.5 then
			color =  {255, percentage*510, 0}
		else
			color =  {510 - percentage*510, 255, 0}
		end
	end
	
	color = string.format("|cff%02x%02x%02x", color[1], color[2], color[3])
	return color
end

-- easier syntax for LDB display strings
function BG:FormatString(text)
	local item
	if not BG.cheapestItems or not BG.cheapestItems[1] then
		item = { itemID = 0, count = 0, value = 0 }
	else
		item = BG.cheapestItems[1]
	end
	
	-- [junkvalue]
	local junkValue = 0
	for i = 0, 4 do
		junkValue = junkValue + (BG.toSellValue[i] or 0)
	end
	text = string.gsub(text, "%[junkvalue%]", BG:FormatMoney(junkValue))
	
	-- [itemname][itemcount][itemvalue]
	text = string.gsub(text, "%[itemname%]", (select(2,GetItemInfo(item.itemID)) or ""))
	text = string.gsub(text, "%[itemicon%]", "|T"..(select(10,GetItemInfo(item.itemID)) or "")..":0|t")
	text = string.gsub(text, "%[itemcount%]", item.count)
	text = string.gsub(text, "%[itemvalue%]", BG:FormatMoney(item.value))
	
	-- [freeslots][totalslots]
	text = string.gsub(text, "%[freeslots%]", BG.totalFreeSlots + BG.freeSpecialSlots)
	text = string.gsub(text, "%[totalslots%]", BG.totalBagSpace + BG.specialSlots)

	-- [specialfree][specialslots][specialslots][basicslots]
	text = string.gsub(text, "%[specialfree%]", BG.freeSpecialSlots)
	text = string.gsub(text, "%[specialslots%]", BG.specialSlots)
	text = string.gsub(text, "%[basicfree%]", BG.totalFreeSlots)
	text = string.gsub(text, "%[basicslots%]", BG.totalBagSpace)
	
	-- [bagspacecolor][basicbagcolor][specialbagcolor][endcolor]
	text = string.gsub(text, "%[bagspacecolor%]", 
		BG:Colorize(BG.totalFreeSlots + BG.freeSpecialSlots, BG.totalBagSpace + BG.specialSlots))
	text = string.gsub(text, "%[basicbagcolor%]", 
			BG:Colorize(BG.totalFreeSlots, BG.totalBagSpace))
	text = string.gsub(text, "%[specialbagcolor%]", 
			BG:Colorize(BG.freeSpecialSlots, BG.specialSlots))
	text = string.gsub(text, "%[endcolor%]", "|r")
	
	return text
end

-- formats money int values, depending on settings
function BG:FormatMoney(amount, displayMode)
	if not amount then return "" end
	displayMode = displayMode or BG_GlobalDB.showMoney
	
	local signum
	if amount < 0 then 
		signum = "-"
		amount = -amount
	else 
		signum = "" 
	end
	
	local gold   = floor(amount / (100 * 100))
	local silver = math.fmod(floor(amount / 100), 100)
	local copper = math.fmod(floor(amount), 100)
	
	if displayMode == 0 then
		return format(signum.."%i.%i.%i", gold, silver,copper)

	elseif displayMode == 1 then
		return format(signum.."|cffffd700%i|r.|cffc7c7cf%.2i|r.|cffeda55f%.2i|r", gold, silver, copper)

	-- copied from Ara Broker Money
	elseif displayMode == 2 then
		if amount>9999 then
			return format(signum.."|cffeeeeee%i|r|cffffd700g|r |cffeeeeee%.2i|r|cffc7c7cfs|r |cffeeeeee%.2i|r|cffeda55fc|r", floor(amount*.0001), floor(amount*.01)%100, amount%100 )
		
		elseif amount > 99 then
			return format(signum.."|cffeeeeee%i|r|cffc7c7cfs|r |cffeeeeee%.2i|r|cffeda55fc|r", floor(amount*.01), amount%100 )
		
		else
			return format(signum.."|cffeeeeee%i|r|cffeda55fc|r", amount)
		end
	
	-- copied from Haggler
	elseif displayMode == 3 then
		gold         = gold   > 0 and gold  .."|TInterface\\MoneyFrame\\UI-GoldIcon:0|t" or ""
		silver       = silver > 0 and silver.."|TInterface\\MoneyFrame\\UI-SilverIcon:0|t" or ""
		copper       = copper > 0 and copper.."|TInterface\\MoneyFrame\\UI-CopperIcon:0|t" or ""
		-- add spaces if needed
		copper       = (silver ~= "" and copper ~= "") and " "..copper or copper
		silver       = (gold   ~= "" and silver ~= "") and " "..silver or silver
	
		return signum..gold..silver..copper
		
	elseif displayMode == 4 then		
		gold         = gold   > 0 and "|cffeeeeee"..gold  .."|r|cffffd700g|r" or ""
		silver       = silver > 0 and "|cffeeeeee"..silver.."|r|cffc7c7cfs|r" or ""
		copper       = copper > 0 and "|cffeeeeee"..copper.."|r|cffeda55fc|r" or ""
		-- add spaces if needed
		copper       = (silver ~= "" and copper ~= "") and " "..copper or copper
		silver       = (gold   ~= "" and silver ~= "") and " "..silver or silver
	
		return signum..gold..silver..copper
	end
end