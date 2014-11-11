local addonName, addon, _ = ...
addonName = addonName..'2'

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
	local types = {}
	types.ldbFormat = types.tooltipFormat

	LibStub('LibDualSpec-1.0'):EnhanceDatabase(addon.db, addonName)
	local AceConfig,AceConfigDialog = LibStub('AceConfig-3.0'), LibStub('AceConfigDialog-3.0')
	local optionsTable = LibStub('LibOptionsGenerate-1.0'):GetOptionsTable(addon.db, types, nil, true)
	      optionsTable.name = addonName
	AceConfig:RegisterOptionsTable(addonName, optionsTable)
	AceConfigDialog:AddToBlizOptions(addonName, nil, nil)

	-- add entries for submodules
	local AceConfigRegistry = LibStub('AceConfigRegistry-3.0')
	for name, subModule in addon:IterateModules() do
		if AceConfigRegistry.tables[subModule.name] then
			AceConfigDialog:AddToBlizOptions(subModule.name, name, addonName)
		end
		for subName, subSubModule in subModule:IterateModules() do
			if AceConfigRegistry.tables[subSubModule.name] then
				AceConfigDialog:AddToBlizOptions(subSubModule.name, subName, addonName)
			end
		end
	end
	local optionsTable = LibStub('AceDBOptions-3.0'):GetOptionsTable(addon.db)
	      optionsTable.name = addonName .. ' - ' .. optionsTable.name
	AceConfig:RegisterOptionsTable(addonName..'_profiles', optionsTable)
	AceConfigDialog:AddToBlizOptions(addonName..'_profiles', 'Profiles', addonName)

	-- do all this only once. next time, only show this panel
	OpenConfiguration = function(panel, args)
		InterfaceOptionsFrame_OpenToCategory(addonName)
	end
	OpenConfiguration(self, args)
end

-- create a fake configuration panel
local panel = CreateFrame('Frame')
      panel.name = addonName
      panel:Hide()
      panel:SetScript('OnShow', OpenConfiguration)
InterfaceOptions_AddCategory(panel)

-- use slash command to toggle config
-- local slashName = addonName:upper()
-- _G['SLASH_'..slashName..'1'] = '/'..addonName
-- _G.SlashCmdList[slashName] = function(args) OpenConfiguration(panel, args) end
