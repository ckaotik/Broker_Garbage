_, BrokerGarbage = ...

local debug = false		-- set this to 'true' to get your chatframe spammed :D


-- Addon Basics
-- ---------------------------------------------------------
-- output functions
function BrokerGarbage:Print(text)
	DEFAULT_CHAT_FRAME:AddMessage("|cffee6622Broker_Garbage|r "..text)
end

function BrokerGarbage:Debug(...)
  if debug then
	BrokerGarbage:Print("! "..string.join(", ", tostringall(...)))
  end
end

-- warn the player by displaying a warning message
function BrokerGarbage:Warning(text)
	if BG_GlobalDB.showWarnings and time() - lastReminder >= 5 then
		BrokerGarbage:Print("|cfff0000Warning:|r ", text)
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

-- joins any number of tables together, one after the other. elements within the input-tables will get mixed, though
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

function BrokerGarbage:Count(table)
  local i = 0
  for _, _ in pairs(table) do i = i + 1 end
  return i
end

function BrokerGarbage:ErrorReport()
	-- TODO
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
	
	if not BG_LocalDB then BG_LocalDB = {}; first = false end
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
		if not BG_GlobalDB.include[6265] then BG_GlobalDB.include[6265] = 20 end	-- soulshards
		BG_GlobalDB.include["Consumable.Water.Conjured"] = true
		BG_GlobalDB.forceVendorPrice["Consumable.Food.Edible.Basic"] = true
		BG_GlobalDB.forceVendorPrice["Consumable.Water.Basic"] = true
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
		-- herbalism sucks /dump BrokerGarbage:UnLocalize("Krauterkunde")
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
	if not BrokerGarbage.cheapestItem or BrokerGarbage.cheapestItem == {} then
		item = {
			itemID = 0,
			count = 0,
			value = 0,
		}
	else
		item = BrokerGarbage.cheapestItem
	end
	-- [junkvalue]
	text = string.gsub(text, "%[junkvalue%]", BrokerGarbage:FormatMoney(BrokerGarbage.toSellValue))
	
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
function BrokerGarbage:CanDisenchant(itemLink, myself)
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
			if myself then return false end		-- we can't diss ourselves. hrm. maybe we can!
			
			-- so we can't DE, but can we send it to someone who may? i.e. is the item not soulbound?
			if not BG_GlobalDB.hasEnchanter then return false end
			if BrokerGarbage.checkItem then
				return not BrokerGarbage:IsItemSoulbound(itemLink, BrokerGarbage.checkItem.bag, BrokerGarbage.checkItem.slot)
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