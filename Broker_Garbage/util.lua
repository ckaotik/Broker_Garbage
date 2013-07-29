local addonName, BG = ...

-- GLOBALS: BG_GlobalDB, BG_LocalDB, Broker_Garbage_Config, DEFAULT_CHAT_FRAME
-- GLOBALS: GetProfessions, GetProfessionInfo, GetSpellInfo, UnitClass
-- GLOBALS: setmetatable, getmetatable, pairs, type, select, wipe, tostringall, tonumber, string, math, table

function BG.Print(text)
	DEFAULT_CHAT_FRAME:AddMessage("|cffee6622"..addonName.."|r "..text)
end

function BG.PrintFormat(formatString, ...)
	BG.Print(string.format(formatString, ...))
end

function BG.Find(where, value)
	if not where then return end
	for k, v in pairs(where) do
		if v == value then
			return k
		end
	end
end

function BG.Debug(...)
	if BG_GlobalDB and BG_GlobalDB.debug then
		BG.Print("! "..string.join(", ", tostringall(...)))
	end
end

function BG.GetItemID(itemLink)
	if not itemLink or type(itemLink) ~= "string" then return end
	local linkType, id, data = itemLink:find("\124H([^:]+):([^:\124]+)")
	if linkType == "item" then
		return tonumber(id)
	end
end

function BG.GetPatternFromFormat(globalString)
	if not globalString then return "" end
	local returnString = globalString:gsub("%%[().]", "%%%1")
	      returnString = returnString:gsub("%%[1-9]?$?s", "(.+)")
	      returnString = returnString:gsub("%%[1-9]?$?c", "([+-]?)")
	      returnString = returnString:gsub("%%[1-9]?$?d", "(%%d+)")
	return returnString
end


-- --------------------------------------------------------
--  Saved Variables
-- --------------------------------------------------------
local emptyTable = {}
local function AdjustLists_4_1(localOnly)
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
local function AdjustLists_4_3(localOnly)
	BG_LocalDB.version = 2
	if localOnly then return end

	for key, value in pairs(BG_GlobalDB.forceVendorPrice) do
		if value == 0 then
			BG_GlobalDB.forceVendorPrice[key] = -1
		end
	end
	BG_GlobalDB.version = 2
end
local function AdjustLists_5_4(localOnly)
	-- local lists
	for i,v in pairs(BG_LocalDB.exclude or emptyTable) do
		BG_LocalDB.keep[i] = v
	end
	BG_LocalDB.exclude = nil

	for item, v in pairs(BG_LocalDB.include or emptyTable) do
		BG_LocalDB.toss[item] = 0
		if v > 0 then
			BG_LocalDB.keep[item] = v
		end
	end
	BG_LocalDB.include = nil

	for item, v in pairs(BG_LocalDB.autoSellList or emptyTable) do
		BG_LocalDB.toss[item] = 1
		if v > 0 then
			BG_LocalDB.keep[item] = math.max(BG_LocalDB.keep[item] or 0, v)
		end
	end
	BG_LocalDB.autoSellList = nil

	BG_LocalDB.version = 3
	if localOnly then return end

	-- global lists
	for i,v in pairs(BG_GlobalDB.exclude or emptyTable) do
		BG_GlobalDB.keep[i] = v
	end
	BG_GlobalDB.exclude = nil

	for item, v in pairs(BG_GlobalDB.include or emptyTable) do
		BG_GlobalDB.toss[item] = 0
		if v > 0 then
			BG_GlobalDB.keep[item] = v
		end
	end
	BG_GlobalDB.include = nil

	for item, v in pairs(BG_GlobalDB.autoSellList or emptyTable) do
		BG_GlobalDB.toss[item] = 1
		if v > 0 then
			BG_GlobalDB.keep[item] = math.max(BG_GlobalDB.keep[item] or 0, v)
		end
	end
	BG_GlobalDB.autoSellList = nil

	-- global-only lists
	for item, v in pairs(BG_GlobalDB.forceVendorPrice or emptyTable) do
		BG_GlobalDB.prices[item] = v
	end
	BG_GlobalDB.forceVendorPrice = nil

	BG_GlobalDB.version = 3
end

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

	-- variables update functions
	if not BG_GlobalDB.version or BG_GlobalDB.version < 1 then
		AdjustLists_4_1()
	elseif not BG_LocalDB.version or BG_LocalDB.version < 1 then
		AdjustLists_4_1(true)
	end

	if BG_GlobalDB.version < 2 then
		AdjustLists_4_3()
	elseif BG_LocalDB.version < 2 then
		AdjustLists_4_3(true)
	end

	if BG_GlobalDB.version < 3 then
		AdjustLists_5_4()
	elseif BG_LocalDB.version < 3 then
		AdjustLists_5_4(true)
	end
end

-- inserts some basic list settings
function BG.CreateDefaultLists(includeGlobals)
	if includeGlobals then
		BG_GlobalDB.toss[46069] = 0											-- argentum lance
		BG_GlobalDB.keep["Consumable.Water.Conjured"] = 20
		BG_GlobalDB.toss["Consumable.Water.Conjured"] = 0
		BG_GlobalDB.toss["Consumable.Food.Edible.Basic.Conjured"] = 0
		BG_GlobalDB.prices["Consumable.Food.Edible.Basic"] = -1
		BG_GlobalDB.prices["Consumable.Water.Basic"] = -1
		BG_GlobalDB.prices["Tradeskill.Mat.BySource.Vendor"] = -1
	end

	-- tradeskills
	local tradeSkills =  { GetProfessions() }
	for i, profession in pairs( { GetProfessions() } ) do
		local _, _, _, _, _, _, skillLine = GetProfessionInfo(profession)
		BG.AddTradeSkill(skillLine)
	end

	-- class specific
	local _, playerClass = UnitClass("player")
	if playerClass == "WARRIOR" or playerClass == "ROGUE" or playerClass == "DEATHKNIGHT" or playerClass == "HUNTER" then
		BG_LocalDB.toss["Consumable.Water"] = 1
	end

	BG.Print(BG.locale.listsUpdatedPleaseCheck)

	if Broker_Garbage_Config and Broker_Garbage_Config.ListOptionsUpdate then
		Broker_Garbage_Config:ListOptionsUpdate()
	end
end

-- english names needed for LPT category names
local tradeskillNames = {
	-- [skillLine] = "skillName",
	[164]  = "Blacksmithing",
	[165]  = "Leatherworking",
	[171]  = "Alchemy",
	[182]  = "Herbalism",
	[186]  = "Mining",
	[197]  = "Tailoring",
	[202]  = "Engineering",
	[333]  = "Enchanting",
	[393]  = "Skinning",
	[755]  = "Jewelcrafting",
	[773]  = "Inscription",

	[129]  = "First Aid",
	[185]  = "Cooking",
	[356]  = "Fishing",
	[794]  = "Archaeology",
}
local tradeskillIsGather = {
	[182] = true,
	[186] = true,
	[356] = true,
	[393] = true,
}

function BG.AddTradeSkill(skillLine)
	local skillName = tradeskillNames[skillLine]
	BG_LocalDB.keep[ "Tradeskill.Tool."..skillName ] = 0

	if tradeskillIsGather[skillLine] then
		BG_LocalDB.keep[ "Tradeskill.Gather."..skillName ] = 0
	else
		BG_LocalDB.keep[ "Tradeskill.Mat.ByProfession."..skillName ] = 0
	end
end
