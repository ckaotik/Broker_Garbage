local addonName, addon, _ = ...

-- GLOBALS: _G, LibStub
-- GLOBALS: InterfaceAddOnsList_Update, InterfaceOptionsList_DisplayPanel, GetItemInfo, GetCoinTextureString
-- GLOBALS: ipairs, type, select, setmetatable, math, tostring

local AceConfigDialog = LibStub('AceConfigDialog-3.0')

local function GetConfigurationVariables()
	local itemQualities = {}
	itemQualities[-1] = '- Do not sell -' -- TODO localize
	for quality, color in pairs(_G.ITEM_QUALITY_COLORS) do
		if quality >= 0 then
			itemQualities[quality] = color.hex .. _G['ITEM_QUALITY'..quality..'_DESC'] .. '|r'
		end
	end

	local function GetDescriptionWidget(key, option)
		local value = math.abs(option)
		return {
			type = 'description',
			fontSize = 'medium',
			name = ('%s: %s'):format(
				addon.configLocale[key] or key,
				key:find('money') and GetCoinTextureString(value) or value
			),
		}
	end
	local function GetItemListLabels(key, value)
		local label = tostring(value)
		if type(key) == 'number' then
			local itemName, itemLink, _, _, _, _, _, _, _, icon, _ = GetItemInfo(key)
			label = ('|T%s:0|t %s'):format(icon or 'Interface\\Icons\\INV_Misc_QuestionMark', itemLink or key)
		else
			-- TODO this needs fixing, table.sort dies on string + number values
			return key, nil
		end
		return key, label
	end

	local types = {
		disableKey = {
			NONE  = _G['NONE_KEY'],
			SHIFT = _G['SHIFT_KEY'],
			ALT   = _G['ALT_KEY'],
			CTRL  = _G['CTRL_KEY'],
		},
		moneyFormat = {
			gsc  = addon.FormatMoney(540321, 'gsc'),
			icon = addon.FormatMoney(540321, 'icon'),
			dot  = addon.FormatMoney(540321, 'dot'),
		},
		disenchantSkillOffset = 'unsigned',
		sellUnusableQuality = itemQualities,
		sellOutdatedQuality = itemQualities,
		-- keep = 'multiselect',
		-- toss = 'multiselect',
		moneyEarned = GetDescriptionWidget,
		moneyLost   = GetDescriptionWidget,
		numDeleted  = GetDescriptionWidget,
		numSold     = GetDescriptionWidget,
	}

	-- Hide various settings ... for now.
	for _, setting in ipairs({
		'version',
		'dataSources',
		'prices',
		'keep',
		'toss',
	}) do
		types[setting] = '*none*'
	end

	local locale = setmetatable({}, {
		__index = addon.configLocale,
	})
	locale.keepValues = GetItemListLabels
	locale.tossValues = GetItemListLabels

	-- variable, typeMappings, L, includeNamespaces, callback
	return addon.db, types, locale, false, nil
end

-- Blizzard configuration panel
local function InitializeConfiguration(self, args)
	local AceConfig = LibStub('AceConfig-3.0')
	LibStub('LibDualSpec-1.0'):EnhanceDatabase(addon.db, addonName)

	-- Initialize main panel.
	local optionsTable = LibStub('LibOptionsGenerate-1.0'):GetOptionsTable(GetConfigurationVariables())
	      optionsTable.name = addonName
	AceConfig:RegisterOptionsTable(addonName, optionsTable)

	-- Add panels for submodules.
	local AceConfigRegistry = LibStub('AceConfigRegistry-3.0')
	for name, subModule in addon:IterateModules() do
		if AceConfigRegistry.tables[subModule.name] then
			AceConfigDialog:AddToBlizOptions(subModule.name, name, addonName)
		end
	end

	if addon.db.defaults and addon.db.defaults.profile and next(addon.db.defaults.profile) then
		-- Add panel for profile settings.
		local profileOptions = LibStub('AceDBOptions-3.0'):GetOptionsTable(addon.db)
		      profileOptions.name = addonName .. ' - ' .. profileOptions.name
		AceConfig:RegisterOptionsTable(addonName..'_profiles', profileOptions)
		AceConfigDialog:AddToBlizOptions(addonName..'_profiles', 'Profiles', addonName)
	end

	-- Restore original OnShow handler.
	self:SetScript('OnShow', self.origOnShow)
	self.origOnShow = nil

	InterfaceAddOnsList_Update()
	InterfaceOptionsList_DisplayPanel(self)
end

-- Create a placeholder configuration panel.
local panel = AceConfigDialog:AddToBlizOptions(addonName)
panel.origOnShow = panel:GetScript('OnShow')
panel:SetScript('OnShow', InitializeConfiguration)
