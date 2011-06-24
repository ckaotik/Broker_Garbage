local _, BGC = ...

Broker_Garbage_Config = BGC	-- allow external access
-- In case the addon is loaded from another condition, always call the remove interface options
if AddonLoader and AddonLoader.RemoveInterfaceOptions then
	AddonLoader:RemoveInterfaceOptions("Broker_Garbage")
end

-- options panel / statistics
BGC.options = CreateFrame("Frame", "BG_Options", InterfaceOptionsFramePanelContainer)
BGC.options.name = "Broker_Garbage"

-- list options
BGC.listOptions = CreateFrame("Frame", "BG_ListOptions", InterfaceOptionsFramePanelContainer)
BGC.listOptions.name = BGC.locale.LOTitle
BGC.listOptions.parent = "Broker_Garbage"

function BGC.UpdateOptionsPanel(frame)
	if not BGC.options.currentTab then return end
	local panel = BGC.modules[ BGC.options.currentTab ].panel
	if panel and panel.Update then
		panel:Update()
	end
end

function BGC.ChangeView(pluginID)
	table.sort(BGC.modules, function(a, b)
		return a.name < b.name
	end)
	for i, plugin in ipairs(BGC.modules) do
		if not plugin.panel then
			if not plugin.init then
				BGC:Print("Error! Panel " .. (name or "nil") .. " doesn't have an init script!")
				return
			end
			plugin.init(i)	-- supply the plugin's ID just in case
		end
		
		if i == pluginID then
			plugin.tab:Activate()
			if plugin.panel.Update then
				plugin.panel:Update()
			end
			plugin.panel:Show()
			
			BGC.options.currentTab = pluginID
		else
			plugin.tab:Deactivate()
			plugin.panel:Hide()
		end
	end
	BGC.UpdateOptionsPanel()
end

function BGC:CreateOptionsPanel()
	local title, subtitle = LibStub("tekKonfig-Heading").new(self, "Broker_Garbage", BGC.locale.BasicOptionsText)

	local group = LibStub("tekKonfig-Group").new(self, nil, "TOP", subtitle, "BOTTOM", 0, -24)
	group:SetPoint("LEFT")
	group:SetPoint("BOTTOMRIGHT")
	group:SetBackdropColor(0.1, 0.1, 0.1, 0.3)
	self.group = group
	
	BGC.ChangeView(1)
	BGC:ShowListOptions(BGC.listOptions)
	collectgarbage()
	self:SetScript("OnShow", BGC.UpdateOptionsPanel)
end

BGC.options:SetScript("OnShow", BGC.CreateOptionsPanel)
InterfaceOptions_AddCategory(BGC.options)

InterfaceOptions_AddCategory(BGC.listOptions)

LibStub("tekKonfig-AboutPanel").new("Broker_Garbage", "Broker_Garbage")

if InterfaceOptionsFrame:IsVisible() then
	InterfaceOptionsFrame_OpenToCategory("Broker_Garbage")
end
Broker_Garbage.optionsLoaded = true