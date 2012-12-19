local _, BG = ...

-- GLOBALS: BG_GlobalDB, BG_LocalDB, Broker_Garbage, Broker_Garbage_Config, UIParentLoadAddOn, DEFAULT_CHAT_FRAME
-- GLOBALS: GetContainerItemInfo, GetProfessions, GetProfessionInfo, GetSpellInfo, DevTools_Dump
local getmetatable = getmetatable
local setmetatable = setmetatable
local type = type
local pairs = pairs
local ipairs = ipairs
local tinsert = table.insert
local select = select
local unpack = unpack
local gsub = string.gsub
local upper = string.upper
local lower = string.lower
local tonumber = tonumber
local tostringall = tostringall
local join = string.join

-- == Debugging Functions ==
function BG.Print(text)
	DEFAULT_CHAT_FRAME:AddMessage(BG.name.." "..text)
end

hooksecurefunc(GameTooltip, "SetBagItem", function(tip, bag, slot)
	local index = BG.GetListIndex(bag, slot)
	local item = BG.cheapestItems[index]
	local cacheData = item and BG.GetCached(item.itemID)
	local sell = (item and item.sell) and "|TInterface\\BUTTONS\\UI-GroupLoot-Coin-Up:0|t " or ""

	if GetContainerItemInfo(bag, slot) and item and cacheData then
		if BG_GlobalDB and BG_GlobalDB.showItemTooltipLabel and item.source then
			if item.source and item.source >= 0 then
				tip:AddDoubleLine(BG.name, sell .. BG.colors[item.source] .. BG.labels[item.source] .. "|r")
			end
			if item.reason and BG_GlobalDB.showLabelReason then
				tip:AddDoubleLine(BG.name, item.reason)
			end
			tip:Show()
		end

		if BG_GlobalDB and BG_GlobalDB.debug then
			tip:AddDoubleLine(BG.name, "Index "..index..
				(cacheData and ", label "..cacheData.classification or "")..
				(item and ", source "..item.source or "")
			)
			tip:Show()
		end
	end
end)

-- prints debug messages only when debug mode is active
function BG.Debug(...)
	if BG_GlobalDB and BG_GlobalDB.debug then
		BG.Print("! "..join(", ", tostringall(...)))
	end
end

local dumpCount = 0
function BG.Dump(arg, force)
	if (BG_GlobalDB and BG_GlobalDB.debug) or force then
		UIParentLoadAddOn("Blizzard_DebugTools")
		DevTools_Dump(arg, "BrokerGarbage_"..dumpCount)
		dumpCount = dumpCount + 1
	end
end

local waitFrame = CreateFrame("Frame")
function BG.CallWithDelay(callFunc, delay, ...)
	if waitFrame:GetScript("OnUpdate") ~= nil then
		BG.Debug("Ooopsie, already running a timer!")
	end
	local args = {...}
	waitFrame:SetScript("OnUpdate", function(self, elapsed)
		delay = delay - elapsed
		if delay <= 0 then
			waitFrame:SetScript("OnUpdate", nil)
			callFunc( unpack(args) )
		end
	end)
end

function BG.ReformatGlobalString(globalString)
	if not globalString then return "" end
	local returnString = globalString
	returnString = gsub(returnString, "%(", "%%(")
	returnString = gsub(returnString, "%)", "%%)")
	returnString = gsub(returnString, "%.", "%%.")
	returnString = gsub(returnString, "%%[1-9]?$?s", "(.+)")
	returnString = gsub(returnString, "%%[1-9]?$?c", "([+-]?)")
	returnString = gsub(returnString, "%%[1-9]?$?d", "(%%d+)")
	return returnString
end

function BG.GetListIndex(bag, slot, includeInvalid)
	for tableIndex, tableItem in pairs(BG.cheapestItems) do
		if tableItem.bag == bag and tableItem.slot == slot then
			if includeInvalid or not tableItem.invalid then
				return tableIndex
			end
			break
		end
	end
end

-- == Saved Variables ==
-- checks for and sets default settings
function BG.CheckSettings()
	local newGlobals, newLocals
	if not BG_GlobalDB then BG_GlobalDB = {}; newGlobals = true end
	for key, value in pairs(BG.defaultGlobalSettings) do
		if BG_GlobalDB[key] == nil then
			BG_GlobalDB[key] = value
		end
	end

	if not BG_LocalDB then BG_LocalDB = {}; newLocals = true end
	for key, value in pairs(BG.defaultLocalSettings) do
		if BG_LocalDB[key] == nil then
			BG_LocalDB[key] = value
		end
	end

	if newGlobals then
		-- first load ever of Broker_Garbage
		BG_GlobalDB.version = BG.version
		BG.CreateDefaultLists(true)
	elseif newLocals then
		-- first load on this character
		BG.CreateDefaultLists()
	end

	if BG_GlobalDB.version and type(BG_GlobalDB.version) ~= "number" then
		BG_GlobalDB.version = tonumber(BG_GlobalDB.version)
	end

	if not BG_GlobalDB.version or BG_GlobalDB.version < 1 then BG.AdjustLists_4_1()
	elseif not BG_LocalDB.version or BG_LocalDB.version < 1 then BG.AdjustLists_4_1(true) end

	if BG_GlobalDB.version < 2 then BG.AdjustLists_4_3()
	elseif BG_LocalDB.version < 2 then BG.AdjustLists_4_3(true) end
end

function BG.AdjustLists_4_1(localOnly)
	for _, subtable in pairs({"exclude", "include", "autoSellList", "forceVendorPrice"}) do
		for key, value in pairs(BG_LocalDB[ subtable ] or {}) do
			if value == true then
				BG_LocalDB[subtable][key] = 0
			end
		end
	end
	BG_LocalDB.version = 1
	if localOnly then return end

	for _, subtable in pairs({"exclude", "include", "autoSellList", "forceVendorPrice"}) do
		for key, value in pairs(BG_GlobalDB[ subtable ] or {}) do
			if value == true then
				BG_GlobalDB[subtable][key] = 0
			end
		end
	end

	if BG_GlobalDB.neverRepairGuildBank ~= nil and
		(BG_GlobalDB.neverRepairGuildBank ~= BG_GlobalDB.repairGuildBank or BG_GlobalDB.repairGuildBank == nil) then
		BG_GlobalDB.repairGuildBank = BG_GlobalDB.neverRepairGuildBank
		BG_GlobalDB.neverRepairGuildBank = nil
	end

	if BG_GlobalDB.keepItemsForLaterDE and type(BG_GlobalDB.keepItemsForLaterDE) ~= "number" then
		BG_GlobalDB.keepItemsForLaterDE = 0
	end

	BG_GlobalDB.version = 1
end
function BG.AdjustLists_4_3(localOnly)
	BG_LocalDB.version = 2
	if localOnly then return end

	for key, value in pairs(BG_GlobalDB.forceVendorPrice) do
		if value == 0 then
			BG_GlobalDB.forceVendorPrice[key] = -1
		end
	end
	BG_GlobalDB.version = 2
end

-- inserts some basic list settings
function BG.CreateDefaultLists(global)
	if global then
		BG_GlobalDB.include[46069] = 0											-- argentum lance
		BG_GlobalDB.include["Consumable.Water.Conjured"] = 20
		BG_GlobalDB.include["Consumable.Food.Edible.Basic.Conjured"] = 0
		BG_GlobalDB.exclude["Misc.StartsQuest"] = 0
		BG_GlobalDB.forceVendorPrice["Consumable.Food.Edible.Basic"] = -1
		BG_GlobalDB.forceVendorPrice["Consumable.Water.Basic"] = -1
		BG_GlobalDB.forceVendorPrice["Tradeskill.Mat.BySource.Vendor"] = -1
	end

	-- tradeskills
	local tradeSkills =  { GetProfessions() }
	for i = 1, 6 do	-- we get at most 6 professions (2x primary, cooking, fishing, first aid, archaeology)
		local englishSkill = BG.GetTradeSkill(tradeSkills[i])
		if englishSkill then
			BG.ModifyList_ExcludeSkill(englishSkill)
		end
	end

	-- class specific
	if BG.playerClass == "WARRIOR" or BG.playerClass == "ROGUE" or BG.playerClass == "DEATHKNIGHT" or BG.playerClass == "HUNTER" or BG.playerClass == "MONK" then
		BG_LocalDB.autoSellList["Consumable.Water"] = 0
	end
	BG_LocalDB.exclude["Misc.Reagent.Class."..gsub(lower(BG.playerClass), "^.", upper)] = 0

	BG.Print(BG.locale.listsUpdatedPleaseCheck)

	-- Broker_Garbage.UpdateAllCaches()
	Broker_Garbage.UpdateAllDynamicItems()
	Broker_Garbage:UpdateLDB()

	if Broker_Garbage_Config and Broker_Garbage_Config.ListOptionsUpdate then
		Broker_Garbage_Config:ListOptionsUpdate()
	end
end


-- == Profession Infos ==
function BG.ModifyList_ExcludeSkill(englishSkill)
	if englishSkill == "Herbalism" or englishSkill == "Skinning" or englishSkill == "Mining" or englishSkill == "Fishing" then
		BG_LocalDB.exclude["Tradeskill.Gather." .. englishSkill] = 0
	else
		BG_LocalDB.exclude["Tradeskill.Mat.ByProfession." .. englishSkill] = 0
	end

	if englishSkill ~= "Herbalism" and englishSkill ~= "Archaeology" and englishSkill ~= "Cooking" then
		BG_LocalDB.exclude["Tradeskill.Tool." .. englishSkill] = 0
	end
end

-- takes a tradeskill id (as returned in GetProfessions()) or localized name and returns its English name
function BG.GetTradeSkill(skill)
	if not skill then return end
	if type(skill) == "number" then
		skill = GetProfessionInfo(skill)
	end
	for spellID, skillName in pairs(BG.tradeSkills) do
		if ( GetSpellInfo(spellID) ) == skill then
			return skillName
		end
	end
	return nil
end

-- returns the current and maximum rank of a given skill
function BG.GetProfessionSkill(skill)
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

-- == Table Functions ==
function BG.Find(table, value)
	if not table then return end
	for k, v in pairs(table) do
		if (v == value) then return k end
	end
	return false
end

-- counts table entries. for numerically indexed tables, use #table
function BG.Count(table)
	if not table then return 0 end
	local i = 0
	for _, _ in pairs(table) do
		i = i + 1
	end
	return i
end

-- joins any number of non-basic index tables together, one after the other. elements within the input-tables _will_ get mixed
function BG.JoinTables(...)
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
function BG.JoinSimpleTables(...)
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

function BG.GetTableCopy(t)
	local u = { }
	for k, v in pairs(t) do u[k] = v end
	return setmetatable(u, getmetatable(t))
end
