local addonName, addon, _ = ...

local function OpenConfiguration(self, args)
	-- remove placeholder configuration panel
	for i, panel in ipairs(_G.INTERFACEOPTIONS_ADDONCATEGORIES) do
		if panel == self then
			tremove(INTERFACEOPTIONS_ADDONCATEGORIES, i)
			break
		end
	end
	self:SetScript('OnShow', nil)
	self:Hide()

	-- initialize panel
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
	}
	for _, setting in pairs({'version', 'prices', 'keep', 'toss', 'moneyEarned', 'moneyLost', 'numDeleted', 'numSold'}) do
		types[setting] = '*none*'
	end

	LibStub('LibDualSpec-1.0'):EnhanceDatabase(addon.db, addonName)
	local AceConfig, AceConfigDialog = LibStub('AceConfig-3.0'), LibStub('AceConfigDialog-3.0')
	local optionsTable = LibStub('LibOptionsGenerate-1.0'):GetOptionsTable(addon.db, types, nil, false)
	      optionsTable.name = addonName
	AceConfig:RegisterOptionsTable(addonName, optionsTable)
	local panel = AceConfigDialog:AddToBlizOptions(addonName, nil, nil)

	-- add entries for submodules
	local AceConfigRegistry = LibStub('AceConfigRegistry-3.0')
	for name, subModule in addon:IterateModules() do
		if AceConfigRegistry.tables[subModule.name] then
			AceConfigDialog:AddToBlizOptions(subModule.name, name, addonName)
		end
	end --]]
	local profileOptions = LibStub('AceDBOptions-3.0'):GetOptionsTable(addon.db)
	      profileOptions.name = addonName .. ' - ' .. profileOptions.name
	AceConfig:RegisterOptionsTable(addonName..'_profiles', profileOptions)
	AceConfigDialog:AddToBlizOptions(addonName..'_profiles', 'Profiles', addonName)

	-- do all this only once. next time, only show this panel
	OpenConfiguration = function(panel, args)
		InterfaceOptionsFrame_OpenToCategory(addonName)
	end
	if not panel:IsVisible() then
		C_Timer.After(0.05, OpenConfiguration)
	end
end

-- create a fake configuration panel
local panel = CreateFrame('Frame')
      panel.name = addonName
      panel:Hide()
      panel:SetScript('OnShow', OpenConfiguration)
InterfaceOptions_AddCategory(panel)

-- use slash command to toggle config
local slashName = addonName:upper()
_G['SLASH_'..slashName..'1'] = '/'..addonName
_G.SlashCmdList[slashName] = function(args) OpenConfiguration(panel, args) end
