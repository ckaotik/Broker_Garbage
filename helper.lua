-- to enable debug mode, run: /run BG_GlobalDB.debug = true
-- to disable debug mode (disabled by default) run: /run BG_GlobalDB.debug = false
_, BrokerGarbage = ...

-- Addon Basics
-- ---------------------------------------------------------
-- output functions
function BrokerGarbage:Print(text)
	DEFAULT_CHAT_FRAME:AddMessage("|cffee6622Broker_Garbage|r "..text)
end

-- prints debug messages only when debug mode is active
function BrokerGarbage:Debug(...)
  if BG_GlobalDB.debug then
	BrokerGarbage:Print("! "..string.join(", ", tostringall(...)))
  end
end

-- warn the player by displaying a warning message
function BrokerGarbage:Warning(text)
	if BG_GlobalDB.showWarnings and time() - lastReminder >= 5 then
		BrokerGarbage:Print("|cfff0000"..BrokerGarbage.locale.warningMessagePrefix.."!|r ", text)
		lastReminder = time()
	end
end

-- check if a given value can be found in a table
function BrokerGarbage:Find(table, value)
	for k, v in pairs(table) do
		if (v == value) then return true end
	end
	return false
end

-- joins any number of non-basic index tables together, one after the other. elements within the input-tables will get mixed, though
function BrokerGarbage:JoinTables(...)
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
function BrokerGarbage:JoinSimpleTables(...)
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

-- counts table entries. for numerically indexed tables, use #table
function BrokerGarbage:Count(table)
  local i = 0
  for _, _ in pairs(table) do i = i + 1 end
  return i
end

-- Saved Variables Management / API
-- ---------------------------------------------------------
function BrokerGarbage:CheckSettings()
	-- check for settings
	local first
	if not BG_GlobalDB then BG_GlobalDB = {}; first = true end
	for key, value in pairs(BrokerGarbage.defaultGlobalSettings) do
		if BG_GlobalDB[key] == nil then
			BG_GlobalDB[key] = value
		end
	end
	
	if not BG_LocalDB then 
		BG_LocalDB = {}
		if not first then first = false end
	end
	for key, value in pairs(BrokerGarbage.defaultLocalSettings) do
		if BG_LocalDB[key] == nil then
			BG_LocalDB[key] = value
		end
	end
	
	if first ~= nil then
		BrokerGarbage:CreateDefaultLists(first)
	end
	
	-- update LDB string for older versions
	if BG_GlobalDB.LDBformat == "%1$sx%2$d (%3$s)" or string.find(BG_GlobalDB.LDBformat, "%%%d%$[sd]") then
		BG_GlobalDB.LDBformat = BrokerGarbage.defaultGlobalSettings.LDBformat
		BrokerGarbage:Print(BrokerGarbage.locale.resetLDB)
	end
end

-- inserts some basic list settings
function BrokerGarbage:CreateDefaultLists(global)
	if global then
		BG_GlobalDB.include[46069] = true											-- argentum lance
		if BG_GlobalDB.include[6265] == nil then BG_GlobalDB.include[6265] = 20 end	-- soulshards
		BG_GlobalDB.include["Consumable.Water.Conjured"] = true
		BG_GlobalDB.include["Consumable.Food.Edible.Basic.Conjured"] = true
		BG_GlobalDB.forceVendorPrice["Consumable.Food.Edible.Basic"] = true
		BG_GlobalDB.forceVendorPrice["Consumable.Water.Basic"] = true
		BG_GlobalDB.forceVendorPrice["tradeSkill.Mat.BySource.Vendor"] = true
	end
	
	-- tradeskills
	local tradeSkills = BrokerGarbage:CheckSkills() or {}
	local numSkills = #tradeSkills
	for i = 1, numSkills do
		local englishSkill = BrokerGarbage:UnLocalize(tradeSkills[i][1])
		if englishSkill then
			if tradeSkills[i][2] then
				BG_LocalDB.exclude["Tradeskill.Gather."..englishSkill] = true
				if englishSkill ~= "Herbalism" then
					BG_LocalDB.exclude["Tradeskill.Tool."..englishSkill] = true
				end
			else
				BG_LocalDB.exclude["Tradeskill.Mat.ByProfession."..englishSkill] = true
				BG_LocalDB.exclude["Tradeskill.Tool."..englishSkill] = true
			end
		end
	end
	
	-- class specific
	if BrokerGarbage.playerClass == "HUNTER" then	
		BG_LocalDB.exclude["Misc.Reagent.Ammo"] = true
	
	elseif BrokerGarbage.playerClass == "WARRIOR" or BrokerGarbage.playerClass == "ROGUE" or BrokerGarbage.playerClass == "DEATHKNIGHT" then
		BG_LocalDB.autoSellList["Consumable.Water"] = true
	
	elseif BrokerGarbage.playerClass == "SHAMAN" then
		if not BG_LocalDB.include[17058] then BG_LocalDB.include[17058] = 20 end	-- fish oil
		if not BG_LocalDB.include[17057] then BG_LocalDB.include[17057] = 20 end	-- scales
	end
	BG_LocalDB.exclude["Misc.Reagent.Class."..string.gsub(string.lower(BrokerGarbage.playerClass), "^.", string.upper)] = true
	
	BrokerGarbage:Print(BrokerGarbage.locale.listsUpdatedPleaseCheck)
	BrokerGarbage.itemsCache = {}
	BrokerGarbage:ScanInventory()
end

-- returns options for plugin use
function BrokerGarbage:GetOption(optionName, global)
	if global == nil then
		return BG_LocalDB[optionName], BG_GlobalDB[optionName]
	elseif global == false then
		return BG_LocalDB[optionName]
	else
		return BG_GlobalDB[optionName]
	end
end

-- Helpers
-- ---------------------------------------------------------
-- returns an item's itemID
function BrokerGarbage:GetItemID(itemLink)
	if not itemLink then return end
	local itemID = string.gsub(itemLink, ".-Hitem:([0-9]*):.*", "%1")
	return tonumber(itemID)
end

-- returns original English names for non-English locales
function BrokerGarbage:UnLocalize(skillName)
	if not skillName then return nil end
	if string.find(GetLocale(), "en") then return skillName end
	
	-- crafting skills
	local searchString = ""
	for i=2,12 do
		searchString = select(i, GetAuctionItemSubClasses(9))
		if string.find(skillName, searchString) then
			return BrokerGarbage.tradeSkills[i]
		end
	end
	
	-- gathering skills
	local skill
	if skillName == GetSpellInfo(8613) then
		skill = "Skinning"
	elseif skillName == GetSpellInfo(2575) then
		skill = "Mining"
	else
		-- herbalism sucks
		searchString = select(6, GetAuctionItemSubClasses(6))
		if string.find(skillName, searchString) then
			skill = "Herbalism"
		end
	end
	
	return skill
end

-- easier syntax for LDB display strings
function BrokerGarbage:FormatString(text)
	local item
	if not BrokerGarbage.cheapestItems or not BrokerGarbage.cheapestItems[1] then
		item = {
			itemID = 0,
			count = 0,
			value = 0,
		}
	else
		item = BrokerGarbage.cheapestItems[1]
	end
	
	-- [junkvalue]
	local junkValue = 0
	for i = 0, 4 do
		junkValue = junkValue + (BrokerGarbage.toSellValue[i] or 0)
	end
	text = string.gsub(text, "%[junkvalue%]", BrokerGarbage:FormatMoney(junkValue))
	
	-- [itemname][itemcount][itemvalue]
	text = string.gsub(text, "%[itemname%]", (select(2,GetItemInfo(item.itemID)) or ""))
	text = string.gsub(text, "%[itemcount%]", item.count)
	text = string.gsub(text, "%[itemvalue%]", BrokerGarbage:FormatMoney(item.value))
	
	-- [freeslots][totalslots]
	text = string.gsub(text, "%[freeslots%]", BrokerGarbage.totalFreeSlots)
	text = string.gsub(text, "%[totalslots%]", BrokerGarbage.totalBagSpace)
	
	-- [bagspacecolor][endcolor]
	text = string.gsub(text, "%[bagspacecolor%]", 
		BrokerGarbage:Colorize(BrokerGarbage.totalFreeSlots, BrokerGarbage.totalBagSpace))
	text = string.gsub(text, "%[endcolor%]", "|r")
	
	return text
end

-- returns a red-to-green color depending on the given percentage
function BrokerGarbage:Colorize(top, bottom)
	if not bottom and (top >= 1 or top < 0) then return "" end
	local percentage = top/(bottom ~= 0 and bottom or 1)
	local color
	if percentage <= 0.5 then
		color =  {255, percentage*510, 0}
	else
		color =  {510 - percentage*510, 255, 0}
	end
	
	color = string.format("|cff%02x%02x%02x", color[1], color[2], color[3])
	
	return color
end

function BrokerGarbage:ResetMoney(which, global)
	if not global then
		if which == "lost" then
			BG_LocalDB.moneyLostByDeleting = 0
		elseif which == "earned" then
			BG_LocalDB.moneyEarned = 0
		end
	else
		if which == "lost" then
			BG_GlobalDB.moneyLostByDeleting = 0
		elseif which == "earned" then
			BG_GlobalDB.moneyEarned = 0
		end
	end
end

function BrokerGarbage:ResetList(which)
	if which == "exclude" then
		BG_GlobalDB.exclude = {}
	elseif which == "include" then
		BG_GlobalDB.include = {}
	elseif which == "autosell" then
		-- TODO: add to options
		BG_GlobalDB.autoSellList = {}
	end
end

-- resets statistics. global = true -> global, otherwise local
function BrokerGarbage:ResetAll(global)
	if global then
		BG_GlobalDB.moneyEarned = 0
		BG_GlobalDB.moneyLostByDeleting = 0
		BG_GlobalDB.itemsDropped = 0
		BG_GlobalDB.itemsSold = 0
	else
		BG_LocalDB.moneyEarned = 0
		BG_LocalDB.moneyLostByDeleting = 0
	end
end

-- returns the skill rank of a given tradeskill, or nil
function BrokerGarbage:GetTradeSkill(skillName)
	for i=1, GetNumSkillLines() do
		local name, _, _, skillRank, _, _, _, _, _, _, _, _, _ = GetSkillLineInfo(i)
		if name == skillName then 
			return skillRank
		end
	end
	return nil
end

-- returns all tradeskills found
function BrokerGarbage:CheckSkills()
	local result = {}
	for i=1, GetNumSkillLines() do
		local name, _, _, skillRank, _, _, _, tradeSkill = GetSkillLineInfo(i)
		if tradeSkill then
			local isGather = true
			if name == GetSpellInfo(2259) or name == GetSpellInfo(2018) or name == GetSpellInfo(7411) or name == GetSpellInfo(4036) or name == GetSpellInfo(45357) or name == GetSpellInfo(25229) or name == GetSpellInfo(2108) or name == GetSpellInfo(3908) then 
				-- crafting skill
				isGather = false
			end
			tinsert(result, {name, isGather, skillRank})
		end
	end
	if result == {} then return nil else return result end
end

local scanTooltip = CreateFrame('GameTooltip', 'BGItemScanTooltip', UIParent, 'GameTooltipTemplate')
-- misc: either "true" to check only for the current character, or a table {container, slot} for reference
function BrokerGarbage:CanDisenchant(itemLink, misc)
	if (itemLink) then
		local _, _, quality, level, _, _, _, count, bagSlot = GetItemInfo(itemLink)

		-- stackables are not DE-able, legendary/heirlooms are not DE-able
		if quality and quality >= 2 and quality < 5 and 
			string.find(bagSlot, "INVTYPE") and not string.find(bagSlot, "BAG") 
			and (not count or count == 1) then
			
			-- can we DE ourself?
			if IsUsableSpell(BrokerGarbage.enchanting) then
				local skill = BrokerGarbage:GetTradeSkill(BrokerGarbage.enchanting) or 0
				
				local requiredSkill = 0
				if level <= 20 then
					requiredSkill = 1
				elseif level <= 60 then
					requiredSkill = 5*5*math.ceil(level/5)-100
				elseif level < 100 then		-- BC starts here
					requiredSkill = 225
				elseif level <= 115 then
					requiredSkill = 275
				elseif level <= 130 then
					requiredSkill = 300
				elseif level <= 200 and quality <= 3 then	-- WotLK starts here
					requiredSkill = 325
				else
					requiredSkill = 375
				end

				if skill >= requiredSkill then
					return true
				end
				-- if skill is too low, still check if we can send it
			end
			-- misc = "true" => we only care if we ourselves can DE. no twink mail etc.
			if misc and type(misc) == "boolean" then return false end
			
			-- so we can't DE, but can we send it to someone who may? i.e. is the item not soulbound?
			if not BG_GlobalDB.hasEnchanter then return false end
			if misc and type(misc) == "table" then
				return not BrokerGarbage:IsItemSoulbound(itemLink, misc.bag, misc.slot)
			else 
				return not BrokerGarbage:IsItemSoulbound(itemLink)
			end
		end
	end
	return false
end

-- returns true if the given item is soulbound
function BrokerGarbage:IsItemSoulbound(itemLink, bag, slot)
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

-- gets an item's classification and saves it to the item cache
function BrokerGarbage:UpdateCache(itemID)
	if not itemID then return nil end
	local class, temp, limit
	
	local _, itemLink, quality, _, _, _, subClass, stackSize, invType, _, value = GetItemInfo(itemID)
	
	-- weird ...
	if not quality then
		BrokerGarbage:Debug("Could not retrieve quality information for "..(itemID or "<none>").." ("..(itemLink or "")..")")
		return nil
	end
	
	-- check if item is excluded by itemID
	if BG_GlobalDB.exclude[itemID] or BG_LocalDB.exclude[itemID] then
		BrokerGarbage:Debug("Item "..itemID.." is excluded via its itemID.")
		class = BrokerGarbage.EXCLUDE
	end
	
	-- check if the item is classified by its itemID
	if not class or class ~= BrokerGarbage.EXCLUDE then
		if BG_GlobalDB.include[itemID] or BG_LocalDB.include[itemID] then
			
			if BG_LocalDB.include[itemID] and type(BG_LocalDB.include[itemID]) ~= "boolean" then
				-- limited item, local rule
				BrokerGarbage:Debug("Item "..itemID.." is locally limited via its itemID.")
				class = BrokerGarbage.LIMITED
				limit = BG_LocalDB.include[itemID]
			
			elseif BG_GlobalDB.include[itemID] and type(BG_GlobalDB.include[itemID]) ~= "boolean" then
				-- limited item, global rule
				BrokerGarbage:Debug("Item "..itemID.." is globally limited via its itemID.")
				class = BrokerGarbage.LIMITED
				limit = BG_GlobalDB.include[itemID]
			
			else
				BrokerGarbage:Debug("Item "..itemID.." is included via its itemID.")
				class = BrokerGarbage.INCLUDE
			end
		
		elseif BG_GlobalDB.forceVendorPrice[itemID] then
			BrokerGarbage:Debug("Item "..itemID.." has a forced vendor price via its itemID.")
			class = BrokerGarbage.VENDOR
		
		elseif BG_GlobalDB.autoSellList[itemID] or BG_LocalDB.autoSellList[itemID] then
			BrokerGarbage:Debug("Item "..itemID.." is to be auto-sold via its itemID.")
			class = BrokerGarbage.VENDORLIST
		
		elseif quality 
			and not IsUsableSpell(BrokerGarbage.enchanting)	and BrokerGarbage:IsItemSoulbound(itemLink)
			and string.find(invType, "INVTYPE") and not string.find(invType, "BAG") 
			and not BrokerGarbage.usableByClass[BrokerGarbage.playerClass][subClass]
			and not BrokerGarbage.usableByAll[invType] then
			
			BrokerGarbage:Debug("Item "..itemID.." should be sold as we can't ever wear it.")
			class = BrokerGarbage.UNUSABLE
			
		-- check if the item is classified by its category
		elseif BrokerGarbage.PT then
			-- check if item is excluded by its category
			for setName,_ in pairs(BrokerGarbage:JoinTables(BG_GlobalDB.exclude, BG_LocalDB.exclude)) do
				if type(setName) == "string" then
					_, temp = BrokerGarbage.PT:ItemInSet(itemID, setName)
				end
				if temp then
					BrokerGarbage:Debug("Item "..itemID.." is excluded via its category.")
					class = BrokerGarbage.EXCLUDE
					break
				end
			end
			
			-- Include List
			if not class then
				for setName,_ in pairs(BrokerGarbage:JoinTables(BG_LocalDB.include, BG_GlobalDB.include)) do
					if type(setName) == "string" then
						_, temp = BrokerGarbage.PT:ItemInSet(itemID, setName)
					end
					if temp then
						BrokerGarbage:Debug("Item "..itemID.." in included via its item category.")
						class = BrokerGarbage.INCLUDE
						break
					end
				end
			end
			
			-- Sell List
			if not class then
				for setName,_ in pairs(BrokerGarbage:JoinTables(BG_GlobalDB.autoSellList, BG_LocalDB.autoSellList)) do
					if type(setName) == "string" then
						_, temp = BrokerGarbage.PT:ItemInSet(itemID, setName)
					end
					if temp then
						BrokerGarbage:Debug("Item "..itemID.." is on the sell list via its item category.")
						class = BrokerGarbage.VENDORLIST
						break
					end
				end
			end
			
			-- Force Vendor Price List
			if not class then
				for setName,_ in pairs(BG_GlobalDB.forceVendorPrice) do
					if type(setName) == "string" then
						_, temp = BrokerGarbage.PT:ItemInSet(itemID, setName)
					end
					if temp then
						BrokerGarbage:Debug("Item "..itemID.." has a forced vendor price via its item category.")
						class = BrokerGarbage.VENDOR
						break
					end
				end
			end
		end
	end
	
	local tvalue, tclass = BrokerGarbage:GetSingleItemValue(itemID)
	if not class then class = tclass end
	if not (class == BrokerGarbage.VENDOR or class == BrokerGarbage.VENDORLIST) then value = tvalue end
	
	-- save to items cache
	if not class or not quality then
		BrokerGarbage:Print("Error! Caching item "..itemID.." failed!")
		return
	end
	if not BrokerGarbage.itemsCache[itemID] then
		BrokerGarbage.itemsCache[itemID] = {
			classification = class,
			quality = quality,
			value = value or 0,
			limit = limit,
			stackSize = stackSize,
			isClam = BrokerGarbage:Find(BrokerGarbage.clams, itemID),
		}
	else
		BrokerGarbage.itemsCache[itemID].classification = class
		BrokerGarbage.itemsCache[itemID].quality = quality
		BrokerGarbage.itemsCache[itemID].value = value or 0
		BrokerGarbage.itemsCache[itemID].limit = limit
		BrokerGarbage.itemsCache[itemID].stackSize = stackSize
		BrokerGarbage.itemsCache[itemID].isClam = BrokerGarbage:Find(BrokerGarbage.clams, itemID)
	end
end

-- fetch an item from the item cache, or insert if it doesn't exist yet
function BrokerGarbage:GetCached(itemID)
	if not BrokerGarbage.itemsCache[itemID] then
		BrokerGarbage:UpdateCache(itemID)
	end
	return BrokerGarbage.itemsCache[itemID]
end

-- returns total bag slots and free bag slots of your whole inventory
function BrokerGarbage:GetBagSlots()
	local total, free = 0, 0
	local num
	
	for i = 0, 4 do
		num = GetContainerNumSlots(i)
		if num then
			total = total + num
			free = free + (GetContainerFreeSlots(i) and #GetContainerFreeSlots(i) or 0)
		end
	end
	
	return total, free
end

-- formats money int values, depending on settings
function BrokerGarbage:FormatMoney(amount)
	if not amount then return "" end
	
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
	
	if BG_GlobalDB.showMoney == 0 then
		return format(signum.."%i.%i.%i", gold, silver,copper)

	elseif BG_GlobalDB.showMoney == 1 then
		return format(signum.."|cffffd700%i|r.|cffc7c7cf%.2i|r.|cffeda55f%.2i|r", gold, silver, copper)

	-- copied from Ara Broker Money
	elseif BG_GlobalDB.showMoney == 2 then
		if amount>9999 then
			return format(signum.."|cffeeeeee%i|r|cffffd700g|r |cffeeeeee%.2i|r|cffc7c7cfs|r |cffeeeeee%.2i|r|cffeda55fc|r", floor(amount*.0001), floor(amount*.01)%100, amount%100 )
		
		elseif amount > 99 then
			return format(signum.."|cffeeeeee%i|r|cffc7c7cfs|r |cffeeeeee%.2i|r|cffeda55fc|r", floor(amount*.01), amount%100 )
		
		else
			return format(signum.."|cffeeeeee%i|r|cffeda55fc|r", amount)
		end
	
	-- copied from Haggler
	elseif BG_GlobalDB.showMoney == 3 then
		gold         = gold   > 0 and gold  .."|TInterface\\MoneyFrame\\UI-GoldIcon:12:12:4:0|t" or ""
		silver       = silver > 0 and silver.."|TInterface\\MoneyFrame\\UI-SilverIcon:12:12:4:0|t" or ""
		copper       = copper > 0 and copper.."|TInterface\\MoneyFrame\\UI-CopperIcon:12:12:4:0|t" or ""
		-- add spaces if needed
		copper       = (silver ~= "" and copper ~= "") and " "..copper or copper
		silver       = (gold   ~= "" and silver ~= "") and " "..silver or silver
	
		return signum..gold..silver..copper
		
	elseif BG_GlobalDB.showMoney == 4 then		
		gold         = gold   > 0 and "|cffeeeeee"..gold  .."|r|cffffd700g|r" or ""
		silver       = silver > 0 and "|cffeeeeee"..silver.."|r|cffc7c7cfs|r" or ""
		copper       = copper > 0 and "|cffeeeeee"..copper.."|r|cffeda55fc|r" or ""
		-- add spaces if needed
		copper       = (silver ~= "" and copper ~= "") and " "..copper or copper
		silver       = (gold   ~= "" and silver ~= "") and " "..silver or silver
	
		return signum..gold..silver..copper
	end
end