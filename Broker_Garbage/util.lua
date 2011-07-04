local _, BG = ...

-- == Debugging Functions ==
function BG.Print(text)
	DEFAULT_CHAT_FRAME:AddMessage("|cffee6622Broker_Garbage|r "..text)
end

-- prints debug messages only when debug mode is active
function BG.Debug(...)
	if BG_GlobalDB and BG_GlobalDB.debug then
		BG.Print("! "..string.join(", ", tostringall(...)))
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
	
	if newGlobals or newLocals then
		-- this is the first load (either this or all character)
		BG.CreateDefaultLists(newGlobals)
	end
end

function BG.AdjustLists_4_1()
	for key, value in pairs(BG_GlobalDB.exclude) do
		if value == true then
			BG_GlobalDB.exclude[key] = 0
		end
	end
	for key, value in pairs(BG_GlobalDB.include) do
		if value == true then
			BG_GlobalDB.include[key] = 0
		end
	end
	for key, value in pairs(BG_GlobalDB.autoSellList) do
		if value == true then
			BG_GlobalDB.autoSellList[key] = 0
		end
	end
	for key, value in pairs(BG_GlobalDB.forceVendorPrice) do
		if value == true then
			BG_GlobalDB.forceVendorPrice[key] = 0
		end
	end

	for key, value in pairs(BG_LocalDB.exclude) do
		if value == true then
			BG_LocalDB.exclude[key] = 0
		end
	end
	for key, value in pairs(BG_LocalDB.include) do
		if value == true then
			BG_LocalDB.include[key] = 0
		end
	end
	for key, value in pairs(BG_LocalDB.autoSellList) do
		if value == true then
			BG_LocalDB.autoSellList[key] = 0
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
end

-- inserts some basic list settings
function BG.CreateDefaultLists(global)
	if global then
		BG_GlobalDB.include[46069] = 0											-- argentum lance
		BG_GlobalDB.include["Consumable.Water.Conjured"] = 20
		BG_GlobalDB.include["Consumable.Food.Edible.Basic.Conjured"] = 0
		BG_GlobalDB.exclude["Misc.StartsQuest"] = 0
		BG_GlobalDB.forceVendorPrice["Consumable.Food.Edible.Basic"] = 0
		BG_GlobalDB.forceVendorPrice["Consumable.Water.Basic"] = 0
		BG_GlobalDB.forceVendorPrice["Tradeskill.Mat.BySource.Vendor"] = 0
	end
	
	-- tradeskills
	local tradeSkills =  { GetProfessions() }
	for i = 1, 6 do	-- we get at most 6 professions (2x primary, cooking, fishing, first aid, archeology)
		local englishSkill = BG.GetTradeSkill(tradeSkills[i])
		if englishSkill then
			if englishSkill == "Herbalism" or englishSkill == "Skinning" or englishSkill == "Mining" or englishSkill == "Fishing" then
				BG_LocalDB.exclude["Tradeskill.Gather." .. englishSkill] = 0
			else
				BG_LocalDB.exclude["Tradeskill.Mat.ByProfession." .. englishSkill] = 0
			end
			
			if englishSkill ~= "Herbalism" and englishSkill ~= "Archaeology" then
				BG_LocalDB.exclude["Tradeskill.Tool." .. englishSkill] = 0
			end
		end
	end
	
	-- class specific
	if BG.playerClass == "WARRIOR" or BG.playerClass == "ROGUE" or BG.playerClass == "DEATHKNIGHT" or BG.playerClass == "HUNTER" then
		BG_LocalDB.autoSellList["Consumable.Water"] = 0
	
	elseif BG.playerClass == "SHAMAN" then
		if not BG_LocalDB.include[17058] then BG_LocalDB.include[17058] = 20 end	-- fish oil
		if not BG_LocalDB.include[17057] then BG_LocalDB.include[17057] = 20 end	-- scales
	end
	BG_LocalDB.exclude["Misc.Reagent.Class."..string.gsub(string.lower(BG.playerClass), "^.", string.upper)] = 0
	
	BG.Print(BG.locale.listsUpdatedPleaseCheck)

	Broker_Garbage.UpdateAllCaches()
	Broker_Garbage.UpdateAllDynamicItems()
	Broker_Garbage:UpdateLDB()

	if Broker_Garbage_Config and Broker_Garbage_Config.ListOptionsUpdate then
		Broker_Garbage_Config:ListOptionsUpdate()
	end
end


-- == Profession Infos ==
-- takes a tradeskill id (as returned in GetProfessions()) and returns its English name 
function BG.GetTradeSkill(id)
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
		if (v == value) then return true end
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