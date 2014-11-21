local addonName, BG = ...

-- GLOBALS: Broker_Garbage_Config, DEFAULT_CHAT_FRAME
-- GLOBALS: GetProfessions, GetProfessionInfo, GetSpellInfo, UnitClass
-- GLOBALS: setmetatable, getmetatable, pairs, type, select, wipe, tostringall, tonumber, string, math, table

function BG.Print(text)
	DEFAULT_CHAT_FRAME:AddMessage("|cffee6622"..addonName.."|r "..text)
end

function BG.GetItemID(itemLink)
	if not itemLink or type(itemLink) ~= "string" then return end
	local linkType, id, data = itemLink:match("\124H([^:\124]+):([^:\124]+)")
	return id and tonumber(id) or nil, linkType, data
end

function BG.GetInfo(label, short)
	if BG.info[label] then
		return BG.info[label][1] .. BG.info[label][ short and 2 or 3 ] .. "|r"
	end
end

-- --------------------------------------------------------
--  Saved Variables
-- --------------------------------------------------------
local emptyTable = {}
-- migrate old database to new AceDB structure
function BG:PortSettings()
	local currentProfile = self.db:GetCurrentProfile()
	if not self.db.sv.namespaces then self.db.sv.namespaces = {} end
	if not self.db.sv.namespaces.Vendor then self.db.sv.namespaces.Vendor = {} end
	local vendor = self.db.sv.namespaces.Vendor -- self.db:GetNamespace('Vendor', true) is not yet available


	local db = _G['BG_GlobalDB']
	if db and currentProfile == 'Default' and db.version then
		self.db.profile.keep = {}
		for k, v in pairs(db.keep or emptyTable) do self.db.profile.keep[k] = v end
		self.db.profile.toss = {}
		for k, v in pairs(db.toss or emptyTable) do self.db.profile.toss[k] = v end
		self.db.global.prices = {}
		for k, v in pairs(db.prices or emptyTable) do self.db.global.prices[k] = v end
		db.keep, db.toss, db.prices = nil, nil, nil

		local unchanged = {'disableKey', 'dropQuality', 'keepHighestItemLevel', 'keepQuestItems', 'sellUnusable', 'sellUnusableQuality', 'sellOutdated', 'sellOutdatedQuality'}
		local mappings = {
			showJunkSellIcons = 'showBagnonSellIcons',
			disenchantValues = 'hasEnchanter',
			disenchantSkillOffset = 'keepItemsForLaterDE',
			disenchantSuggestions = 'reportDisenchantOutdated',
			sellJunk = 'autoSellIncludeItems',
			LPTJunkIsJunk = 'overrideLPT',
			ignoreZeroValue = 'hideZeroValue',
			label = 'LDBformat',
			noJunkLabel = 'LDBNoJunk',
			['tooltip.height'] = 'tooltipMaxHeight',
			['tooltip.numLines'] = 'tooltipNumItems',
			['tooltip.showIcon'] = 'showIcon',
			['tooltip.showMoneyLost'] = 'showLost',
			['tooltip.showMoneyEarned'] = 'showEarned',
			['tooltip.showReason'] = 'showSource',
			['tooltip.showUnopenedContainers'] = 'showContainers',
			['itemTooltip.showClassification'] = 'showItemTooltipLabel',
			['itemTooltip.showReason'] = 'showLabelReason',
			['dataSources.buyout'] = 'auctionAddonOrder.buyout',
			['dataSources.disenchant'] = 'auctionAddonOrder.disenchant',
			['dataSources.buyoutDisabled'] = 'buyoutDisabledSources',
			['dataSources.disenchantDisabled'] = 'disenchantDisabledSources',
		}
		for _, variable in pairs(unchanged) do
			self.db.global[variable] = db[variable] or nil
			db[variable] = nil
		end
		-- moneyFormat = 'showMoney',
		self.db.global['moneyFormat'] = (db['showMoney'] <= 3 and 'dot') or (db['showMoney'] <= 5 and 'gsc') or 'icon'
		for new, old in pairs(mappings) do
			local new1, new2 = strsplit('.', new)
			if new2 and not self.db.global[new1] then self.db.global[new1] = {} end
			local newVar = new2 and self.db.global[new1] or self.db.global
			local old1, old2 = strsplit('.', old)
			local oldVar = old2 and db[old1] or db
			newVar[new2 or new1] = oldVar[old2 or old1] or nil
			oldVar[old2 or old1] = nil
			if old2 and oldVar[old1] and not next(oldVar[old1]) then
				oldVar[old1] = nil
			end
		end
		db.version = nil

		-- namespace settings
		local vendorMappings = {
			autoSell = 'autoSellToVendor',
			autoRepair = 'autoRepairAtVendor',
			sellLog = 'showSellLog',
			reportNothingToSell = 'reportNothingToSell',
			addSellButton = 'showAutoSellIcon',
		}
		for new, old in pairs(vendorMappings) do
			if not vendor.global then vendor.global = {} end
			vendor.global[new] = vendor.global[new] or db[old] or nil
			db[old] = nil
		end
	end

	local realmName, unitName = GetRealmName(), UnitName('player')
	local characterProfile = unitName .. ' - ' .. realmName

	local db = _G['BG_LocalDB']
	if db and not tContains(self.db:GetProfiles(), characterProfile) then
		if next(db.keep or emptyTable) or next(db.toss or emptyTable) then
			-- create character profile based on Default
			self.db:SetProfile(characterProfile)
			self.db:CopyProfile('Default')
			-- merge character lists into global lists
			for k, v in pairs(db.keep) do self.db.profile.keep[k] = v end
			for k, v in pairs(db.toss) do self.db.profile.toss[k] = v end
			db.keep, db.toss = nil, nil
		end

		self.db.char.moneyLost   = self.db.char.moneyLost   or db.moneyLostByDeleting or nil
		self.db.char.moneyEarned = self.db.char.moneyEarned or db.moneyEarned or nil
		db.moneyLostByDeleting = nil
		db.moneyEarned = nil

		-- namespace settings
		if not vendor.char then vendor.char = {} end
		if not vendor.char[characterProfile] then vendor.char[characterProfile] = {} end
		vendor.char.repairGuildBank = vendor.char[characterProfile].repairGuildBank or db.repairGuildBank or nil
		db.repairGuildBank = nil
	end
end

-- inserts some basic list settings
function BG.CreateDefaultLists(includeGlobals)
	if includeGlobals then
		BG.db.profile.toss[46069] = 0 -- argentum lance
		BG.db.profile.keep["Consumable.Water.Conjured"] = 20
		BG.db.profile.toss["Consumable.Water.Conjured"] = 0
		BG.db.profile.toss["Consumable.Food.Edible.Basic.Conjured"] = 0
		BG.db.global.prices["Consumable.Food.Edible.Basic"] = BG.db.global.prices["Consumable.Food.Edible.Basic"] or -1
		BG.db.global.prices["Consumable.Water.Basic"] = BG.db.global.prices["Consumable.Water.Basic"] or -1
		BG.db.global.prices["Tradeskill.Mat.BySource.Vendor"] = BG.db.global.prices["Tradeskill.Mat.BySource.Vendor"] or -1
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
		BG.db.profile.toss["Consumable.Water"] = 1
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
	BG.db.profile.keep[ "Tradeskill.Tool."..skillName ] = 0

	if tradeskillIsGather[skillLine] then
		BG.db.profile.keep[ "Tradeskill.Gather."..skillName ] = 0
	else
		BG.db.profile.keep[ "Tradeskill.Mat.ByProfession."..skillName ] = 0
	end
end
