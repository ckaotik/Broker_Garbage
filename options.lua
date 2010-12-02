_, BrokerGarbage = ...

-- create drop down menu table for PT sets	
local interestingPTSets = {"Consumable", "Misc", "Tradeskill"}

BrokerGarbage.PTSets = {}
for set, _ in pairs( BrokerGarbage.PT and BrokerGarbage.PT.sets or {} ) do
	local interesting = false
	local partials = { strsplit(".", set) }
	local maxParts = #partials
	
	for i = 1, #interestingPTSets do
		if strfind(partials[1], interestingPTSets[i]) then 
			interesting = true
			break
		end
	end
	
	if interesting then
		local pre = BrokerGarbage.PTSets
		
		for i = 1, maxParts do
			if i == maxParts then
				-- actual clickable entries
				pre[ partials[i] ] = set
			else
				-- all parts before that
				if not pre[ partials[i] ] or type(pre[ partials[i] ]) == "string" then
					pre[ partials[i] ] = {}
				end
				pre = pre[ partials[i] ]
			end
		end
	end
end

-- In case the addon is loaded from another condition, always call the remove interface options
if AddonLoader and AddonLoader.RemoveInterfaceOptions then
	AddonLoader:RemoveInterfaceOptions("Broker_Garbage")
end

-- options panel / statistics
BrokerGarbage.options = CreateFrame("Frame", "BG_Options", InterfaceOptionsFramePanelContainer)
BrokerGarbage.options.name = "Broker_Garbage"

-- list options
BrokerGarbage.listOptions = CreateFrame("Frame", "BG_ListOptions", InterfaceOptionsFramePanelContainer)
BrokerGarbage.listOptions.name = BrokerGarbage.locale.LOTitle
BrokerGarbage.listOptions.parent = "Broker_Garbage"

-- button tooltip infos
local function ShowTooltip(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	-- LibPeriodicTable pretty tooltips
	if self.tiptext and self:GetParent() == _G["BG_ListOptions_ScrollFrame"] and 
		not (self.itemID and string.find(self.tiptext, self.itemID)) then
		local text = string.gsub(self.tiptext, "%.", " |cffffd200>|r ")
		
		GameTooltip:ClearLines() 
		GameTooltip:AddLine("LibPeriodicTable")
		GameTooltip:AddLine(text, 1, 1, 1, true)
	else	-- all other tooltips
		local itemLink = self.itemLink or (self.itemID and select(2,GetItemInfo(self.itemID)))
		if itemLink then
			GameTooltip:SetHyperlink(itemLink)
			if not self.itemLink and self:GetParent() == _G["BG_ListOptions_ScrollFrame"] then
				-- we just got new data for this tooltip!
				BrokerGarbage:ListOptionsUpdate()
			end
		elseif self.tiptext then
			GameTooltip:SetText(self.tiptext, nil, nil, nil, nil, true)
		end
	end
	GameTooltip:Show()
end
local function HideTooltip() GameTooltip:Hide() end

local function CreateHorizontalRule(parent)
	local line = parent:CreateTexture(nil, "ARTWORK")
	line:SetHeight(8)
	line:SetTexture("Interface\\Tooltips\\UI-Tooltip-Border")
	line:SetTexCoord(0.81, 0.94, 0.5, 1)
	
	return line
end

local function CreateFrameBorders(frame)
	local left = frame:CreateTexture(nil, "BACKGROUND")
	left:SetWidth(8) left:SetHeight(20)
	left:SetPoint("LEFT", -5, 0)
	left:SetTexture("Interface\\Common\\Common-Input-Border")
	left:SetTexCoord(0, 0.0625, 0, 0.625)
	local right = frame:CreateTexture(nil, "BACKGROUND")
	right:SetWidth(8) right:SetHeight(20)
	right:SetPoint("RIGHT", 0, 0)
	right:SetTexture("Interface\\Common\\Common-Input-Border")
	right:SetTexCoord(0.9375, 1, 0, 0.625)
	local center = frame:CreateTexture(nil, "BACKGROUND")
	center:SetHeight(20)
	center:SetPoint("RIGHT", right, "LEFT", 0, 0)
	center:SetPoint("LEFT", left, "RIGHT", 0, 0)
	center:SetTexture("Interface\\Common\\Common-Input-Border")
	center:SetTexCoord(0.0625, 0.9375, 0, 0.625)
	
	return left, center, right
end

local function UpdateOptionsPanel(frame)
	if not BrokerGarbage.options.currentTab then return end
	local panel = BrokerGarbage.tabs[ BrokerGarbage.options.currentTab ].panel
	if panel and panel.Update then
		panel:Update()
	end
end

local function ChangeView(pluginID)
	table.sort(BrokerGarbage.tabs, function(a, b)
		return a.name < b.name
	end)
	for i, plugin in ipairs(BrokerGarbage.tabs) do
		if not plugin.panel then
			if not plugin.init then
				BrokerGarbage:Print("Error! Panel " .. (name or "nil") .. " doesn't have an init script!")
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
			
			BrokerGarbage.options.currentTab = pluginID
		else
			plugin.tab:Deactivate()
			plugin.panel:Hide()
		end
	end
	UpdateOptionsPanel()
end

function BrokerGarbage:RegisterPlugin(name, init)
	if not name or not init then
		BrokerGarbage:Print("Error! Cannot register a plugin without a name and initialize function.")
		return
	end
	
	table.insert(BrokerGarbage.tabs, {
		name = name,
		init = init
	})
	return #BrokerGarbage.tabs
end

local topTab = LibStub("tekKonfig-TopTab")
function BrokerGarbage:CreateOptionsTab(id)
	if not id then BrokerGarbage:Print("Error creating options tab: No id supplied."); return end
	local plugin = BrokerGarbage.tabs[id]

	local tab
	if id == 1 then
		tab = topTab.new(BrokerGarbage.options, plugin.name, "BOTTOMLEFT", BrokerGarbage.options.group, "TOPLEFT", 0, -4)
	else
		tab = topTab.new(BrokerGarbage.options, plugin.name, "BOTTOMLEFT", BrokerGarbage.tabs[ id - 1 ].tab, "BOTTOMRIGHT", -15, 0)
	end
	
	panel = CreateFrame("Frame", nil, BrokerGarbage.options.group)
	panel:SetAllPoints()
	panel.tab = tab
	
	tab.panel = panel
	tab:SetID(id)
	tab:SetScript("OnClick", function(self)
		ChangeView(self:GetID())
	end)
	tab:Deactivate()
	
	plugin.panel = panel
	plugin.tab = tab
	
	return panel, tab
end

local function Options_BasicOptions(pluginID)
	local panel, tab = BrokerGarbage:CreateOptionsTab(pluginID)
	
	local behavior = LibStub("tekKonfig-Group").new(panel, BrokerGarbage.locale.GroupBehavior, "TOPLEFT", 21, -16)
	behavior:SetHeight(190); behavior:SetWidth(180)
	behavior:SetBackdropColor(0.1, 0.1, 0.1, 0.4)
	
	local sell = LibStub("tekKonfig-Checkbox").new(behavior, nil, BrokerGarbage.locale.autoSellTitle, "TOPLEFT", behavior, "TOPLEFT", 4, -2)
	sell.tiptext = BrokerGarbage.locale.autoSellText .. BrokerGarbage.locale.GlobalSetting
	sell:SetChecked(BG_GlobalDB.autoSellToVendor)
	local checksound = sell:GetScript("OnClick")
	sell:SetScript("OnClick", function(sell)
		checksound(sell)
		BG_GlobalDB.autoSellToVendor = not BG_GlobalDB.autoSellToVendor
	end)
	
	local nothingToSell = LibStub("tekKonfig-Checkbox").new(behavior, nil, BrokerGarbage.locale.showNothingToSellTitle, "TOPLEFT", sell, "BOTTOMLEFT", 14, 4)
	nothingToSell.tiptext = BrokerGarbage.locale.showNothingToSellText .. BrokerGarbage.locale.GlobalSetting
	nothingToSell:SetChecked(BG_GlobalDB.reportNothingToSell)
	local checksound = nothingToSell:GetScript("OnClick")
	nothingToSell:SetScript("OnClick", function(nothingToSell)
		checksound(nothingToSell)
		BG_GlobalDB.reportNothingToSell = not BG_GlobalDB.reportNothingToSell
	end)
	
	local repair = LibStub("tekKonfig-Checkbox").new(behavior, nil, BrokerGarbage.locale.autoRepairTitle, "TOPLEFT", nothingToSell, "BOTTOMLEFT", -14, 4)
	repair.tiptext = BrokerGarbage.locale.autoRepairText .. BrokerGarbage.locale.GlobalSetting
	repair:SetChecked(BG_GlobalDB.autoRepairAtVendor)
	local checksound = repair:GetScript("OnClick")
	repair:SetScript("OnClick", function(repair)
		checksound(repair)
		BG_GlobalDB.autoRepairAtVendor = not BG_GlobalDB.autoRepairAtVendor
	end)

	local guildrepair = LibStub("tekKonfig-Checkbox").new(behavior, nil, BrokerGarbage.locale.autoRepairGuildTitle, "TOPLEFT", repair, "BOTTOMLEFT", 14, 4)
	guildrepair.tiptext = BrokerGarbage.locale.autoRepairGuildText
	guildrepair:SetChecked(BG_LocalDB.neverRepairGuildBank)
	local checksound = guildrepair:GetScript("OnClick")
	guildrepair:SetScript("OnClick", function(guildrepair)
		checksound(guildrepair)
		BG_LocalDB.neverRepairGuildBank = not BG_LocalDB.neverRepairGuildBank
	end)
	
	local sellGear = LibStub("tekKonfig-Checkbox").new(behavior, nil, BrokerGarbage.locale.sellNotUsableTitle, "TOPLEFT", guildrepair, "BOTTOMLEFT", -14, 4)
	sellGear.tiptext = BrokerGarbage.locale.sellNotUsableText .. BrokerGarbage.locale.GlobalSetting
	sellGear:SetChecked(BG_GlobalDB.sellNotWearable)
	local checksound = sellGear:GetScript("OnClick")
	sellGear:SetScript("OnClick", function(sellGear)
		checksound(sellGear)
		BG_GlobalDB.sellNotWearable = not BG_GlobalDB.sellNotWearable
		BrokerGarbage:ScanInventory()
	end)
	
	local enchanter = LibStub("tekKonfig-Checkbox").new(behavior, nil, BrokerGarbage.locale.enchanterTitle, "TOPLEFT", sellGear, "BOTTOMLEFT", 0, 4)
	enchanter.tiptext = BrokerGarbage.locale.enchanterTooltip .. BrokerGarbage.locale.GlobalSetting
	enchanter:SetChecked(BG_GlobalDB.hasEnchanter)
	local checksound = enchanter:GetScript("OnClick")
	enchanter:SetScript("OnClick", function(enchanter)
		checksound(enchanter)
		BG_GlobalDB.hasEnchanter = not BG_GlobalDB.hasEnchanter
	end)
	
	-- -----------------------------------------------------------------
	local line = CreateHorizontalRule(behavior)
	line:SetPoint("TOPLEFT", enchanter, "BOTTOMLEFT", 2, 2)
	line:SetPoint("RIGHT", -6, 2)
	-- -----------------------------------------------------------------
	
	local disableKey = CreateFrame("Frame", "BG_DisableKeyDropDown", behavior, "UIDropDownMenuTemplate")
	disableKey.tiptext = BrokerGarbage.locale.DKTooltip .. BrokerGarbage.locale.GlobalSetting
	disableKey.displayMode = "MENU"
	disableKey:SetScript("OnEnter", ShowTooltip)
	disableKey:SetScript("OnLeave", HideTooltip)
       disableKey:SetPoint("TOPLEFT", enchanter, "BOTTOMLEFT", -8, -20)
	local disableKeyLabel = disableKey:CreateFontString(nil, "BACKGROUND", "GameFontNormalSmall")
	disableKeyLabel:SetPoint("BOTTOMLEFT", disableKey, "TOPLEFT", 20, 2)
	disableKeyLabel:SetText(BrokerGarbage.locale.DKTitle)
	_G[disableKey:GetName() .. "Button"]:SetPoint("LEFT", _G[disableKey:GetName().."Middle"])
	UIDropDownMenu_SetSelectedValue(disableKey, BG_GlobalDB.disableKey)
	UIDropDownMenu_SetText(disableKey, BrokerGarbage.locale.disableKeys[BG_GlobalDB.disableKey])
	
	local function DisableKeyOnSelect(self)
		UIDropDownMenu_SetSelectedValue(disableKey, self.value)
		BG_GlobalDB.disableKey = self.value
	end
	UIDropDownMenu_Initialize(disableKey, function()
		local selected, info = UIDropDownMenu_GetSelectedValue(disableKey), UIDropDownMenu_CreateInfo()
		for name in pairs(BrokerGarbage.disableKey) do
			info.text = BrokerGarbage.locale.disableKeys[name]
			info.value = name
			info.func = DisableKeyOnSelect
			info.checked = name == selected
			UIDropDownMenu_AddButton(info)
		end
	end)
	
	local treshold = LibStub("tekKonfig-Group").new(panel, BrokerGarbage.locale.GroupTresholds, "TOPLEFT", behavior, "BOTTOMLEFT", 0, -14)
	treshold:SetHeight(100); treshold:SetWidth(180)
	treshold:SetBackdropColor(0.1, 0.1, 0.1, 0.4)

	local qualityTreshold = CreateFrame("Frame", "BG_DropQualityDropDown", treshold, "UIDropDownMenuTemplate")
	qualityTreshold.displayMode = "MENU"
	qualityTreshold:SetPoint("TOPLEFT", treshold, -4, -20)
	_G[qualityTreshold:GetName() .. "Button"]:SetPoint("LEFT", _G[qualityTreshold:GetName().."Middle"])
	_G[qualityTreshold:GetName() .. "Button"].tiptext = BrokerGarbage.locale.dropQualityText .. BrokerGarbage.locale.GlobalSetting
	_G[qualityTreshold:GetName() .. "Button"]:SetScript("OnEnter", ShowTooltip)
	_G[qualityTreshold:GetName() .. "Button"]:SetScript("OnLeave", HideTooltip)
	
	local qualityTresholdLabel = qualityTreshold:CreateFontString(nil, "BACKGROUND", "GameFontNormalSmall")
	qualityTresholdLabel:SetPoint("BOTTOMLEFT", qualityTreshold, "TOPLEFT", 20, 2)
	qualityTresholdLabel:SetText(BrokerGarbage.locale.dropQualityTitle)
	UIDropDownMenu_SetSelectedValue(qualityTreshold, BG_GlobalDB.dropQuality)
	UIDropDownMenu_SetText(qualityTreshold, BrokerGarbage.quality[BG_GlobalDB.dropQuality])
	local function DropQualityOnSelect(self)
		UIDropDownMenu_SetSelectedValue(qualityTreshold, self.value)
		BG_GlobalDB.dropQuality = self.value
		BrokerGarbage:ScanInventory()
	end
	UIDropDownMenu_Initialize(qualityTreshold, function(self)
		local selected, info = UIDropDownMenu_GetSelectedValue(self), UIDropDownMenu_CreateInfo()
		for i = 0, #BrokerGarbage.quality do
			info.text = BrokerGarbage.quality[i]
			info.value = i
			info.func = DropQualityOnSelect
			info.checked = i == selected
			UIDropDownMenu_AddButton(info)
		end
	end)
	
	
	local sellGearTeshold = CreateFrame("Frame", "BG_SellQualityDropDown", treshold, "UIDropDownMenuTemplate")
	sellGearTeshold.displayMode = "MENU"
	sellGearTeshold:SetPoint("TOPLEFT", qualityTreshold, "BOTTOMLEFT", 0, -15)
	_G[sellGearTeshold:GetName() .. "Button"]:SetPoint("LEFT", _G[sellGearTeshold:GetName().."Middle"])
	_G[sellGearTeshold:GetName() .. "Button"].tiptext = BrokerGarbage.locale.SNUMaxQualityText .. BrokerGarbage.locale.GlobalSetting
	_G[sellGearTeshold:GetName() .. "Button"]:SetScript("OnEnter", ShowTooltip)
	_G[sellGearTeshold:GetName() .. "Button"]:SetScript("OnLeave", HideTooltip)
	
	local sellGearTesholdLabel = sellGearTeshold:CreateFontString(nil, "BACKGROUND", "GameFontNormalSmall")
	sellGearTesholdLabel:SetPoint("BOTTOMLEFT", sellGearTeshold, "TOPLEFT", 20, 2)
	sellGearTesholdLabel:SetText(BrokerGarbage.locale.SNUMaxQualityTitle)
	UIDropDownMenu_SetSelectedValue(sellGearTeshold, BG_GlobalDB.sellNWQualityTreshold)
	UIDropDownMenu_SetText(sellGearTeshold, BrokerGarbage.quality[BG_GlobalDB.sellNWQualityTreshold])
	local function SellQualityOnSelect(self)
		UIDropDownMenu_SetSelectedValue(sellGearTeshold, self.value)
		BG_GlobalDB.sellNWQualityTreshold = self.value
		BrokerGarbage:ScanInventory()
	end
	UIDropDownMenu_Initialize(sellGearTeshold, function(self)
		local selected, info = UIDropDownMenu_GetSelectedValue(self), UIDropDownMenu_CreateInfo()
		for i = 0, #BrokerGarbage.quality do
			info.text = BrokerGarbage.quality[i]
			info.value = i
			info.func = SellQualityOnSelect
			info.checked = i == selected
			UIDropDownMenu_AddButton(info)
		end
	end)
	
	local display = LibStub("tekKonfig-Group").new(panel, BrokerGarbage.locale.GroupDisplay, "TOPLEFT", behavior, "TOPRIGHT", 10, 0)
	display:SetHeight(150); display:SetWidth(180)
	display:SetBackdropColor(0.1, 0.1, 0.1, 0.4)

	local sellIcon = LibStub("tekKonfig-Checkbox").new(display, nil, BrokerGarbage.locale.showAutoSellIconTitle, "TOPLEFT", display, "TOPLEFT", 4, -2)
	sellIcon.tiptext = BrokerGarbage.locale.showAutoSellIconText .. BrokerGarbage.locale.GlobalSetting
	sellIcon:SetChecked(BG_GlobalDB.showAutoSellIcon)
	local checksound = sellIcon:GetScript("OnClick")
	sellIcon:SetScript("OnClick", function(sellIcon)
		checksound(sellIcon)
		BG_GlobalDB.showAutoSellIcon = not BG_GlobalDB.showAutoSellIcon
		BrokerGarbage:UpdateRepairButton()
	end)
	
	-- -----------------------------------------------------------------
	local lineDisplay = CreateHorizontalRule(display)
	lineDisplay:SetPoint("TOPLEFT", sellIcon, "BOTTOMLEFT", 2, 2)
	lineDisplay:SetPoint("RIGHT", -6, 2)
	-- -----------------------------------------------------------------
	
	local function ResetEditBox(self)
		self:SetText(BG_GlobalDB[self.setting])
		self:ClearFocus()
		BrokerGarbage:ScanInventory()
	end
	local function SubmitEditBox(self)
		BG_GlobalDB[self.setting] = self:GetText()
		self:SetText(BG_GlobalDB[self.setting])
		self:ClearFocus()
		BrokerGarbage:ScanInventory()
	end
	local function ResetEditBoxDefault(self)
		BG_GlobalDB[self.setting] = BrokerGarbage.defaultGlobalSettings[self.setting]
		self:SetText(BG_GlobalDB[self.setting])
		self:ClearFocus()
		BrokerGarbage:ScanInventory()
	end
	
	local LDBtitle = display:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
	LDBtitle:SetPoint("TOPLEFT", sellIcon, "BOTTOMLEFT", 8, -10)
	LDBtitle:SetText(BrokerGarbage.locale.LDBDisplayTextTitle)
	
	local editHelp = CreateFrame("Button", nil, display)
	editHelp:SetPoint("LEFT", LDBtitle, "RIGHT", 2, 0)
	editHelp:SetWidth(12); editHelp:SetHeight(12)
	editHelp:SetNormalTexture("Interface\\RAIDFRAME\\ReadyCheck-Waiting")
	editHelp.tiptext = BrokerGarbage.locale.LDBDisplayTextHelpTooltip
	editHelp:SetScript("OnEnter", ShowTooltip)
	editHelp:SetScript("OnLeave", HideTooltip)
	
	-- LDB format string for "Junk"
	local junkText = CreateFrame("EditBox", nil, display)
	CreateFrameBorders(junkText)
	junkText:SetPoint("TOPLEFT", LDBtitle, "BOTTOMLEFT", 2, 2)
	junkText:SetWidth(140); junkText:SetHeight(32)
	junkText:SetFontObject("GameFontHighlightSmall")
	junkText:SetAutoFocus(false)
	junkText:SetText(BG_GlobalDB.LDBformat)
	junkText.tiptext = BrokerGarbage.locale.LDBDisplayTextTooltip .. BrokerGarbage.locale.GlobalSetting
	junkText.setting = "LDBformat"
	
	junkText:SetScript("OnEscapePressed", ResetEditBox)
	junkText:SetScript("OnEnterPressed", SubmitEditBox)
	junkText:SetScript("OnEnter", ShowTooltip)
	junkText:SetScript("OnLeave", HideTooltip)
	
	local editReset = CreateFrame("Button", nil, display)
	editReset:SetPoint("LEFT", junkText, "RIGHT", 4, 0)
	editReset:SetWidth(16); editReset:SetHeight(16)
	editReset:SetNormalTexture("Interface\\RAIDFRAME\\ReadyCheck-NotReady")
	editReset.tiptext = BrokerGarbage.locale.ResetToDefault
	editReset:SetScript("OnEnter", ShowTooltip)
	editReset:SetScript("OnLeave", HideTooltip)	
	editReset:SetScript("OnClick", ResetEditBoxDefault)
	
	-- LDB format string for "No Junk"
	local noJunkText = CreateFrame("EditBox", nil, display)
	CreateFrameBorders(noJunkText)
	noJunkText:SetPoint("TOPLEFT", junkText, "BOTTOMLEFT", 0, 12)
	noJunkText:SetAutoFocus(false)
	noJunkText:SetWidth(140); noJunkText:SetHeight(32)
	noJunkText:SetFontObject("GameFontHighlightSmall")
	noJunkText:SetText(BG_GlobalDB.LDBNoJunk)
	noJunkText.tiptext = BrokerGarbage.locale.LDBNoJunkTextTooltip .. BrokerGarbage.locale.GlobalSetting
	noJunkText.setting = "LDBNoJunk"

	noJunkText:SetScript("OnEscapePressed", ResetEditBox)
	noJunkText:SetScript("OnEnterPressed", SubmitEditBox)
	noJunkText:SetScript("OnEnter", ShowTooltip)
	noJunkText:SetScript("OnLeave", HideTooltip)
	
	local editReset2 = CreateFrame("Button", nil, display)
	editReset2:SetPoint("LEFT", noJunkText, "RIGHT", 4, 0)
	editReset2:SetWidth(16); editReset2:SetHeight(16)
	editReset2:SetNormalTexture("Interface\\RAIDFRAME\\ReadyCheck-NotReady")
	editReset2.tiptext = BrokerGarbage.locale.ResetToDefault
	editReset2:SetScript("OnEnter", ShowTooltip)
	editReset2:SetScript("OnLeave", HideTooltip)	
	editReset2:SetScript("OnClick", ResetEditBoxDefault)
	
	-- -----------------------------------------------------------------
	local lineDisplay2 = CreateHorizontalRule(display)
	lineDisplay2:SetPoint("TOPLEFT", noJunkText, "BOTTOMLEFT", -10, 2)
	lineDisplay2:SetPoint("RIGHT", -6, 2)
	-- -----------------------------------------------------------------
	
	local testValue = 130007
	local moneyFormat = CreateFrame("Frame", "BG_MoneyFormatDropDown", display, "UIDropDownMenuTemplate")
	moneyFormat.displayMode = "MENU"
	moneyFormat:SetPoint("TOPLEFT", noJunkText, "BOTTOMLEFT", -20, -20)
	_G[moneyFormat:GetName() .. "Button"]:SetPoint("LEFT", _G[moneyFormat:GetName().."Middle"])
	_G[moneyFormat:GetName() .. "Button"].tiptext = BrokerGarbage.locale.moneyFormatText .. BrokerGarbage.locale.GlobalSetting
	_G[moneyFormat:GetName() .. "Button"]:SetScript("OnEnter", ShowTooltip)
	_G[moneyFormat:GetName() .. "Button"]:SetScript("OnLeave", HideTooltip)
	
	local moneyFormatLabel = moneyFormat:CreateFontString(nil, "BACKGROUND", "GameFontNormalSmall")
	moneyFormatLabel:SetPoint("BOTTOMLEFT", moneyFormat, "TOPLEFT", 20, 2)
	moneyFormatLabel:SetText(BrokerGarbage.locale.moneyFormatTitle)
	UIDropDownMenu_SetSelectedValue(moneyFormat, BG_GlobalDB.showMoney)
	UIDropDownMenu_SetText(moneyFormat, BrokerGarbage:FormatMoney(testValue))
	local function MoneyFormatOnSelect(self)
		UIDropDownMenu_SetSelectedValue(moneyFormat, self.value)
		BG_GlobalDB.showMoney = self.value
		BrokerGarbage:ScanInventory()
	end
	UIDropDownMenu_Initialize(moneyFormat, function(self)
		local selected, info = UIDropDownMenu_GetSelectedValue(self), UIDropDownMenu_CreateInfo()
		for i = 0, 4 do	-- currently 4 formats are supported
			info.text = BrokerGarbage:FormatMoney(testValue, i)
			info.value = i
			info.func = MoneyFormatOnSelect
			info.checked = i == selected
			UIDropDownMenu_AddButton(info)
		end
	end)
	
	local tooltip = LibStub("tekKonfig-Group").new(panel, BrokerGarbage.locale.GroupTooltip, "TOPLEFT", display, "BOTTOMLEFT", 0, -14)
	tooltip:SetHeight(140); tooltip:SetWidth(180)
	tooltip:SetBackdropColor(0.1, 0.1, 0.1, 0.4)

	local showSource = LibStub("tekKonfig-Checkbox").new(tooltip, nil, BrokerGarbage.locale.showSourceTitle, "TOPLEFT", tooltip, "TOPLEFT", 4, -2)
	showSource.tiptext = BrokerGarbage.locale.showSourceText .. BrokerGarbage.locale.GlobalSetting
	showSource:SetChecked(BG_GlobalDB.showSource)
	local checksound = showSource:GetScript("OnClick")
	showSource:SetScript("OnClick", function(showSource)
		checksound(showSource)
		BG_GlobalDB.showSource = not BG_GlobalDB.showSource
	end)
	
	local showEarned = LibStub("tekKonfig-Checkbox").new(tooltip, nil, BrokerGarbage.locale.showEarnedTitle, "TOPLEFT", showSource, "BOTTOMLEFT", 0, 4)
	showEarned.tiptext = BrokerGarbage.locale.showEarnedText .. BrokerGarbage.locale.GlobalSetting
	showEarned:SetChecked(BG_GlobalDB.showEarned)
	local checksound = showEarned:GetScript("OnClick")
	showEarned:SetScript("OnClick", function(showEarned)
		checksound(showEarned)
		BG_GlobalDB.showEarned = not BG_GlobalDB.showEarned
	end)
	
	local showLost = LibStub("tekKonfig-Checkbox").new(tooltip, nil, BrokerGarbage.locale.showLostTitle, "TOPLEFT", showEarned, "BOTTOMLEFT", 0, 4)
	showLost.tiptext = BrokerGarbage.locale.showLostText .. BrokerGarbage.locale.GlobalSetting
	showLost:SetChecked(BG_GlobalDB.showLost)
	local checksound = showLost:GetScript("OnClick")
	showLost:SetScript("OnClick", function(showLost)
		checksound(showLost)
		BG_GlobalDB.showLost = not BG_GlobalDB.showLost
	end)

	-- -----------------------------------------------------------------
	local lineTooltip = CreateHorizontalRule(tooltip)
	lineTooltip:SetPoint("TOPLEFT", showLost, "BOTTOMLEFT", 2, 2)
	lineTooltip:SetPoint("RIGHT", -6, 2)
	-- -----------------------------------------------------------------
	
	local numItems, numItemsText, _, low, high = LibStub("tekKonfig-Slider").new(tooltip, 
		BrokerGarbage.locale.maxItemsTitle .. ": " .. BG_GlobalDB.tooltipNumItems, 
		0, 50, "TOPLEFT", showLost, "BOTTOMLEFT", 12, -5)
	numItems.tiptext = BrokerGarbage.locale.maxItemsText .. BrokerGarbage.locale.GlobalSetting
	numItems:SetWidth(165)
	numItems:SetValueStep(1);
	numItems:SetValue(BG_GlobalDB.tooltipNumItems)
	numItems:SetScript("OnValueChanged", function(numItems)
		BG_GlobalDB.tooltipNumItems = numItems:GetValue()
		numItemsText:SetText(BrokerGarbage.locale.maxItemsTitle .. ": " .. numItems:GetValue())
	end)
	low:Hide(); high:Hide()

	local tooltipHeight, tooltipHeightText, _, low, high = LibStub("tekKonfig-Slider").new(tooltip, 
		BrokerGarbage.locale.maxHeightTitle .. ": " .. BG_GlobalDB.tooltipMaxHeight, 
		0, 500, "TOPLEFT", numItems, "BOTTOMLEFT", 0, -2)
	tooltipHeight.tiptext = BrokerGarbage.locale.maxHeightText .. BrokerGarbage.locale.GlobalSetting
	tooltipHeight:SetWidth(160)
	tooltipHeight:SetValueStep(10);
	tooltipHeight:SetValue(BG_GlobalDB.tooltipMaxHeight)
	tooltipHeight:SetScript("OnValueChanged", function(tooltipHeight)
		BG_GlobalDB.tooltipMaxHeight = tooltipHeight:GetValue()
		tooltipHeightText:SetText(BrokerGarbage.locale.maxHeightTitle .. ": " .. tooltipHeight:GetValue())
	end)
	low:Hide(); high:Hide()
	
	function panel:Update()
		junkText:SetText(BG_GlobalDB.LDBformat)
		noJunkText:SetText(BG_GlobalDB.LDBNoJunk)
		
		local min, max = numItems:GetMinMaxValues()
		if BG_GlobalDB.tooltipNumItems > min and BG_GlobalDB.tooltipNumItems < max then
			numItems:SetValue(BG_GlobalDB.tooltipNumItems)
		end
		numItemsText:SetText(BrokerGarbage.locale.maxItemsTitle .. ": " .. BG_GlobalDB.tooltipNumItems)
		
		min, max = tooltipHeight:GetMinMaxValues()
		if BG_GlobalDB.tooltipMaxHeight > min and BG_GlobalDB.tooltipMaxHeight < max then
			tooltipHeight:SetValue(BG_GlobalDB.tooltipMaxHeight)
		end
		tooltipHeightText:SetText(BrokerGarbage.locale.maxHeightTitle .. ": " .. BG_GlobalDB.tooltipMaxHeight)
	end
end
local defaultTab = BrokerGarbage:RegisterPlugin(BrokerGarbage.locale.BasicOptionsTitle, Options_BasicOptions)

local function Options_Statistics(pluginID)
	local panel, tab = BrokerGarbage:CreateOptionsTab(pluginID)
	
	local function ResetStatistics(self)
		if not self or not self.stat then return end
		if self.isGlobal then
			variable = BG_GlobalDB[self.stat]
		else
			variable = BG_LocalDB[self.stat]
		end
		
		if variable then
			variable = 0
		end
	end
	
	local function AddStatistic(stat, label, value, tooltip, ...)
		if not (label and value) then return end
		local textLeft = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
		textLeft:SetWidth(150)
		textLeft:SetJustifyH("RIGHT")
		textLeft:SetText(label)
		
		local textRight = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
		textRight:SetPoint("LEFT", textLeft, "RIGHT", 4, 0)
		textRight:SetWidth(150)
		textRight:SetJustifyH("LEFT")
		textRight:SetText(value)
		
		if tooltip then
			local action = CreateFrame("Button", nil, panel)
			action:SetNormalTexture("Interface\\RAIDFRAME\\ReadyCheck-Waiting")
			action:SetPoint("LEFT", textRight, "RIGHT",4, 0)
			action:SetWidth(16); action:SetHeight(16)
			action.tiptext = tooltip
			
			action:SetScript("OnEnter", ShowTooltip)
			action:SetScript("OnLeave", HideTooltip)
			
			if stat then
				action.isGlobal = string.match(stat, "^_.*") and true or nil
				action.stat = string.match(stat, "^_?(.*)")
				if stat == "collectgarbage" then
					action:SetScript("OnClick", function() collectgarbage("collect"); UpdateOptionsPanel() end)
				else
					action:SetNormalTexture("Interface\\RAIDFRAME\\ReadyCheck-NotReady")
					action:SetScript("OnClick", ResetStatistics)
				end
			else
				
			end
		end
		if select('#',...) > 0 then	textLeft:SetPoint(...) end

		return textLeft, textRight
	end
	
	UpdateAddOnMemoryUsage()
	local memoryUsage, memoryUsageText = AddStatistic("collectgarbage", BrokerGarbage.locale.MemoryUsageTitle, math.floor(GetAddOnMemoryUsage("Broker_Garbage")), BrokerGarbage.locale.CollectMemoryUsageTooltip, "TOPRIGHT", panel, "TOP", -2, -40)

	local auctionAddon, auctionAddonText = AddStatistic(nil, BrokerGarbage.locale.AuctionAddon, BrokerGarbage.auctionAddon, BrokerGarbage.locale.AuctionAddonTooltip, "TOPLEFT", memoryUsage, "BOTTOMLEFT", 0, -6)

	local globalStatistics = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	globalStatistics:SetPoint("TOPLEFT", auctionAddon, "BOTTOMLEFT", 0, -12)
	globalStatistics:SetPoint("RIGHT", panel, -32, 0)
	globalStatistics:SetNonSpaceWrap(true)
	globalStatistics:SetJustifyH("LEFT")
	globalStatistics:SetJustifyV("TOP")
	globalStatistics:SetText(BrokerGarbage.locale.GlobalStatisticsHeading)

	local globalEarned, globalEarnedText = AddStatistic("_moneyEarned", BrokerGarbage.locale.GlobalMoneyEarnedTitle, BrokerGarbage:FormatMoney(BG_GlobalDB.moneyEarned), BrokerGarbage.locale.ResetStatistic, "TOPLEFT", globalStatistics, "BOTTOMLEFT", 0, -15)
	
	local itemsSold, itemsSoldText = AddStatistic("_itemsSold", BrokerGarbage.locale.GlobalItemsSoldTitle, BG_GlobalDB.itemsSold, BrokerGarbage.locale.ResetStatistic, "TOPLEFT", globalEarned, "BOTTOMLEFT", 0, -6)
	
	local averageSellValue, averageSellValueText = AddStatistic(nil, BrokerGarbage.locale.AverageSellValueTitle, BrokerGarbage:FormatMoney(math.floor(BG_GlobalDB.moneyEarned / (BG_GlobalDB.itemsSold ~= 0 and BG_GlobalDB.itemsSold or 1))), BrokerGarbage.locale.AverageSellValueTooltip, "TOPLEFT", itemsSold, "BOTTOMLEFT", 0, -6)
	
	local globalLost, globalLostText = AddStatistic("_moneyLostByDeleting", BrokerGarbage.locale.GlobalMoneyLostTitle, BrokerGarbage:FormatMoney(BG_GlobalDB.moneyLostByDeleting), BrokerGarbage.locale.ResetStatistic, "TOPLEFT", averageSellValue, "BOTTOMLEFT", 0, -15)
	
	local itemsDropped, itemsDroppedText = AddStatistic("_itemsDropped", BrokerGarbage.locale.ItemsDroppedTitle, BG_GlobalDB.itemsDropped, BrokerGarbage.locale.ResetStatistic, "TOPLEFT", globalLost, "BOTTOMLEFT", 0, -6)
	
	local averageValueLost, averageValueLostText = AddStatistic(nil, BrokerGarbage.locale.AverageDropValueTitle, BrokerGarbage:FormatMoney(math.floor(BG_GlobalDB.moneyLostByDeleting / (BG_GlobalDB.itemsDropped ~= 0 and BG_GlobalDB.itemsDropped or 1))), BrokerGarbage.locale.AverageDropValueTooltip, "TOPLEFT", itemsDropped, "BOTTOMLEFT", 0, -6)
	
	local localStatistics = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	localStatistics:SetPoint("TOPLEFT", averageValueLost, "BOTTOMLEFT", 0, -12)
	localStatistics:SetPoint("RIGHT", panel, -32, 0)
	localStatistics:SetNonSpaceWrap(true)
	localStatistics:SetJustifyH("LEFT")
	localStatistics:SetJustifyV("TOP")
	localStatistics:SetText(format(BrokerGarbage.locale.LocalStatisticsHeading, BrokerGarbage:Colorize(RAID_CLASS_COLORS[BrokerGarbage.playerClass]) .. UnitName("player") .. "|r"))

	local localEarned, localEarnedText = AddStatistic("moneyEarned", BrokerGarbage.locale.StatisticsLocalAmountEarned, BrokerGarbage:FormatMoney(BG_LocalDB.moneyEarned), BrokerGarbage.locale.ResetStatistic, "TOPLEFT", localStatistics, "BOTTOMLEFT", 0, -15)
	
	local localLost, localLostText = AddStatistic("moneyLostByDeleting", BrokerGarbage.locale.StatisticsLocalAmountLost, BrokerGarbage:FormatMoney(BG_LocalDB.moneyLostByDeleting), BrokerGarbage.locale.ResetStatistic, "TOPLEFT", localEarned, "BOTTOMLEFT", 0, -6)
	
	local resetAll = LibStub("tekKonfig-Button").new(panel, "TOPLEFT", localLostText, "BOTTOMLEFT", 0, -24)
	resetAll:SetText(BrokerGarbage.locale.ResetAllText)
	resetAll.tiptext = BrokerGarbage.locale.ResetAllTooltip
	resetAll:SetWidth(150)
	resetAll:SetScript("OnClick", function()
		BrokerGarbage:ResetAll( IsShiftKeyDown() )
		UpdateStats()
	end)
	
	function panel:Update()
		UpdateAddOnMemoryUsage()
		memoryUsageText:SetText(math.floor(GetAddOnMemoryUsage("Broker_Garbage")))

		globalEarnedText:SetText(BrokerGarbage:FormatMoney(BG_GlobalDB.moneyEarned))
		itemsSoldText:SetText(BG_GlobalDB.itemsSold)
		globalLostText:SetText(BrokerGarbage:FormatMoney(BG_GlobalDB.moneyLostByDeleting))
		itemsDroppedText:SetText(BG_GlobalDB.itemsDropped)

		averageSellValueText:SetText(BrokerGarbage:FormatMoney(math.floor(BG_GlobalDB.moneyEarned / (BG_GlobalDB.itemsSold ~= 0 and BG_GlobalDB.itemsSold or 1))))
		averageValueLostText:SetText(BrokerGarbage:FormatMoney(math.floor(BG_GlobalDB.moneyLostByDeleting / (BG_GlobalDB.itemsDropped ~= 0 and BG_GlobalDB.itemsDropped or 1))))

		localEarnedText:SetText(BrokerGarbage:FormatMoney(BG_LocalDB.moneyEarned))
		localLostText:SetText(BrokerGarbage:FormatMoney(BG_LocalDB.moneyLostByDeleting))
	end
end
local _ = BrokerGarbage:RegisterPlugin(BrokerGarbage.locale.StatisticsHeading, Options_Statistics)

-- creates child options frame for setting up one's lists
local function ShowListOptions(frame)
	local title = LibStub("tekKonfig-Heading").new(frame, "Broker_Garbage - " .. BrokerGarbage.locale.LOTitle)
	
	local explanation = frame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	explanation:SetHeight(70)
	explanation:SetPoint("TOPLEFT", title, "TOPLEFT", 0, -20)
	explanation:SetPoint("RIGHT", frame, -4, 0)
	explanation:SetNonSpaceWrap(true)
	explanation:SetJustifyH("LEFT")
	explanation:SetJustifyV("TOP")
	explanation:SetText(BrokerGarbage.locale.LOSubTitle)

	local default = LibStub("tekKonfig-Button").new(frame, "TOPLEFT", explanation, "BOTTOMLEFT", 0, -4)
	default:SetText(BrokerGarbage.locale.defaultListsText)
	default.tiptext = BrokerGarbage.locale.defaultListsTooltip
	default:SetWidth(150)
	default:RegisterForClicks("RightButtonUp", "LeftButtonUp")
	default:SetScript("OnClick", function(self, button)
		BrokerGarbage:CreateDefaultLists(IsShiftKeyDown())
	end)
	
	local autoSellIncludeItems = LibStub("tekKonfig-Checkbox").new(frame, nil, BrokerGarbage.locale.LOIncludeAutoSellText, "LEFT", default, "RIGHT", 10, 8)
	autoSellIncludeItems.tiptext = BrokerGarbage.locale.LOIncludeAutoSellTooltip .. BrokerGarbage.locale.GlobalSetting
	autoSellIncludeItems:SetChecked(BG_GlobalDB.autoSellIncludeItems)
	local checksound = autoSellIncludeItems:GetScript("OnClick")
	autoSellIncludeItems:SetScript("OnClick", function(autoSellIncludeItems)
		checksound(autoSellIncludeItems)
		BG_GlobalDB.autoSellIncludeItems = not BG_GlobalDB.autoSellIncludeItems
		BrokerGarbage.itemsCache = {}
		BrokerGarbage:ScanInventory()
	end)
	
	local includeMode = LibStub("tekKonfig-Checkbox").new(frame, nil, BrokerGarbage.locale.LOUseRealValues, "TOPLEFT", autoSellIncludeItems, "BOTTOMLEFT", 0, 8)
	includeMode.tiptext = BrokerGarbage.locale.LOUseRealValuesTooltip .. BrokerGarbage.locale.GlobalSetting
	includeMode:SetChecked(BG_GlobalDB.useRealValues)
	local checksound = includeMode:GetScript("OnClick")
	includeMode:SetScript("OnClick", function(includeMode)
		checksound(includeMode)
		BG_GlobalDB.useRealValues = not BG_GlobalDB.useRealValues
		BrokerGarbage.itemsCache = {}
		BrokerGarbage:ScanInventory()
		-- maybe: Update LDB
	end)
	
	local panel = LibStub("tekKonfig-Group").new(frame, nil, "TOP", default, "BOTTOM", 0, -28)
	panel:SetPoint("LEFT", 8 + 3, 0)
	panel:SetPoint("BOTTOMRIGHT", -8 -4, 34)
	
	local include = topTab.new(frame, BrokerGarbage.locale.LOTabTitleInclude, "BOTTOMLEFT", panel, "TOPLEFT", 0, -4)
	frame.current = "include"
	local exclude = topTab.new(frame, BrokerGarbage.locale.LOTabTitleExclude, "LEFT", include, "RIGHT", -15, 0)
	exclude:Deactivate()
	local vendorPrice = topTab.new(frame, BrokerGarbage.locale.LOTabTitleVendorPrice, "LEFT", exclude, "RIGHT", -15, 0)
	vendorPrice:Deactivate()
	local autoSell = topTab.new(frame, BrokerGarbage.locale.LOTabTitleAutoSell, "LEFT", vendorPrice, "RIGHT", -15, 0)
	autoSell:Deactivate()
	local help = topTab.new(frame, "?", "LEFT", autoSell, "RIGHT", -15, 0)
	help:Deactivate()
	
	local scrollFrame = CreateFrame("ScrollFrame", frame:GetName().."_Scroll", panel, "UIPanelScrollFrameTemplate")
	scrollFrame:SetPoint("TOPLEFT", panel, "TOPLEFT", 0, -4)
	scrollFrame:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -26, 3)
	local scrollContent = CreateFrame("Frame", scrollFrame:GetName().."Frame", scrollFrame)
	scrollFrame:SetScrollChild(scrollContent)
	scrollContent:SetHeight(300); scrollContent:SetWidth(400)	-- will be replaced when used
	scrollContent:SetAllPoints()
	
	-- action buttons
	local plus = CreateFrame("Button", "BrokerGarbage_AddButton", frame)
	plus:SetPoint("TOPLEFT", panel, "BOTTOMLEFT", 4, -2)
	plus:SetWidth(25); plus:SetHeight(25)
	plus:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square")
	plus:SetNormalTexture("Interface\\Icons\\Spell_chargepositive")
	plus.tiptext = BrokerGarbage.locale.LOPlus
	plus:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	local minus = CreateFrame("Button", "BrokerGarbage_RemoveButton", frame)
	minus:SetPoint("LEFT", plus, "RIGHT", 4, 0)
	minus:SetWidth(25);	minus:SetHeight(25)
	minus:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square")
	minus:SetNormalTexture("Interface\\Icons\\Spell_chargenegative")
	minus.tiptext = BrokerGarbage.locale.LOMinus
	local demote = CreateFrame("Button", "BrokerGarbage_DemoteButton", frame)
	demote:SetPoint("LEFT", minus, "RIGHT", 14, 0)
	demote:SetWidth(25) demote:SetHeight(25)
	demote:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square")
	demote:SetNormalTexture("Interface\\Icons\\INV_Misc_GroupLooking")
	demote.tiptext = BrokerGarbage.locale.LODemote
	local promote = CreateFrame("Button", "BrokerGarbage_PromoteButton", frame)
	promote:SetPoint("LEFT", demote, "RIGHT", 4, 0)
	promote:SetWidth(25) promote:SetHeight(25)
	promote:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square")
	promote:SetNormalTexture("Interface\\Icons\\INV_Misc_GroupNeedMore")
	promote.tiptext = BrokerGarbage.locale.LOPromote
	local emptyList = CreateFrame("Button", "BrokerGarbage_EmptyListButton", frame)
	emptyList:SetPoint("LEFT", promote, "RIGHT", 14, 0)
	emptyList:SetWidth(25); emptyList:SetHeight(25)
	emptyList:SetNormalTexture("Interface\\Buttons\\UI-GroupLoot-Pass-UP")
	emptyList.tiptext = BrokerGarbage.locale.LOEmptyList
	
	-- editbox curtesy of Tekkub
	local searchbox = CreateFrame("EditBox", frame:GetName().."SearchBox", frame)
	searchbox:SetAutoFocus(false)
	searchbox:SetPoint("TOPRIGHT", panel, "BOTTOMRIGHT", -4, 2)
	searchbox:SetWidth(160)
	searchbox:SetHeight(32)
	searchbox:SetFontObject("GameFontHighlightSmall")
	CreateFrameBorders(searchbox)

	searchbox:SetTextColor(0.75, 0.75, 0.75, 1)
	searchbox:SetText(BrokerGarbage.locale.search)
	
	searchbox:SetScript("OnEscapePressed", searchbox.ClearFocus)
	searchbox:SetScript("OnEnterPressed", searchbox.ClearFocus)
	searchbox:SetScript("OnEditFocusGained", function(self)
		if not self.searchString then
			self:SetText("")
			self:SetTextColor(1,1,1,1)
		end
	end)
	searchbox:SetScript("OnEditFocusLost", function(self)
		if self:GetText() == "" then
			self:SetText(BrokerGarbage.locale.search)
			self:SetTextColor(0.75, 0.75, 0.75, 1)
		end
	end)
	searchbox:SetScript("OnTextChanged", function(self)
		local t = self:GetText()
		self.searchString = t ~= "" and t ~= BrokerGarbage.locale.search and t:lower() or nil
		BrokerGarbage:UpdateSearch(self.searchString)
	end)
	
	-- tab changing actions
	include:SetScript("OnClick", function(self)
		self:Activate()
		exclude:Deactivate()
		vendorPrice:Deactivate()
		autoSell:Deactivate()
		help:Deactivate()
		promote:Enable(); promote:GetNormalTexture():SetDesaturated(false)
		demote:Enable(); demote:GetNormalTexture():SetDesaturated(false)
		frame.current = "include"
		scrollFrame:SetVerticalScroll(0)
		BrokerGarbage:ListOptionsUpdate()
	end)
	exclude:SetScript("OnClick", function(self)
		self:Activate()
		include:Deactivate()
		vendorPrice:Deactivate()
		autoSell:Deactivate()
		help:Deactivate()
		promote:Enable(); promote:GetNormalTexture():SetDesaturated(false)
		demote:Enable(); demote:GetNormalTexture():SetDesaturated(false)
		frame.current = "exclude"
		scrollFrame:SetVerticalScroll(0)
		BrokerGarbage:ListOptionsUpdate()
	end)
	vendorPrice:SetScript("OnClick", function(self)
		self:Activate()
		include:Deactivate()
		exclude:Deactivate()
		autoSell:Deactivate()
		help:Deactivate()
		promote:Disable(); promote:GetNormalTexture():SetDesaturated(true)
		demote:Disable(); demote:GetNormalTexture():SetDesaturated(true)
		frame.current = "forceVendorPrice"
		scrollFrame:SetVerticalScroll(0)
		BrokerGarbage:ListOptionsUpdate()
	end)
	autoSell:SetScript("OnClick", function(self)
		self:Activate()
		include:Deactivate()
		exclude:Deactivate()
		vendorPrice:Deactivate()
		help:Deactivate()
		promote:Enable(); promote:GetNormalTexture():SetDesaturated(false)
		demote:Enable(); demote:GetNormalTexture():SetDesaturated(false)
		frame.current = "autoSellList"
		scrollFrame:SetVerticalScroll(0)
		BrokerGarbage:ListOptionsUpdate()
	end)
	help:SetScript("OnClick", function(self)
		self:Activate()
		include:Deactivate()
		exclude:Deactivate()
		autoSell:Deactivate()
		vendorPrice:Deactivate()
		promote:Enable(); promote:GetNormalTexture():SetDesaturated(false)
		demote:Enable(); demote:GetNormalTexture():SetDesaturated(false)
		frame.current = nil
		scrollFrame:SetVerticalScroll(0)
		BrokerGarbage:ListOptionsUpdate()
	end)
	
	-- function to set the drop treshold (limit) via the mousewheel
	local function OnMouseWheel(self, dir)
		if type(self.itemID) ~= "number" then return end
		BrokerGarbage.itemsCache[self.itemID] = nil		-- clear item from cache
		
		local text, limit = self.limit:GetText()
		if self.isGlobal then
			list = BG_GlobalDB[frame.current]
		else
			list = BG_LocalDB[frame.current]
		end
		
		local change = IsShiftKeyDown() and 10 or 1
		if dir == 1 then	-- up
			if list[self.itemID] == true then
				list[self.itemID] = change
			else
				list[self.itemID] = list[self.itemID] + change
			end
			text = list[self.itemID]
		else				-- down
			if list[self.itemID] == true then	-- no change
				text = ""
			else
				list[self.itemID] = list[self.itemID] - change
				text = list[self.itemID]
			end
			
			if type(list[self.itemID]) == "number" and list[self.itemID] <= 0 then
				list[self.itemID] = true
				text = ""
			end
		end
		self.limit:SetText(text)
	end
	
	-- function that updates & shows items from various lists
	-- local numCols
	function BrokerGarbage:ListOptionsUpdate()
		scrollContent:SetWidth(scrollFrame:GetWidth())	-- update scrollframe content to full width
		if frame.current == nil then
			local index = 1
			while _G["BG_ListOptions_ScrollFrame_Item"..index] do
				_G["BG_ListOptions_ScrollFrame_Item"..index]:Hide()
				index = index + 1
			end
			BrokerGarbage:ShowHelp()
			return
		elseif _G["BG_HelpFrame"] then
			_G["BG_HelpFrame"]:Hide()
		end
		
		local globalList = BG_GlobalDB[frame.current]
		local localList = BG_LocalDB[frame.current] or {}
		local dataList = BrokerGarbage:JoinTables(globalList, localList)
		
		-- make this table sortable
		data = {}
		for key, value in pairs(dataList) do
			table.insert(data, key)
		end
		table.sort(data, function(a,b)
			if type(a) == "string" and type(b) == "string" then
				return a < b
			elseif type(a) == "number" and type(b) == "number" then
				return (GetItemInfo(a) or "z") < (GetItemInfo(b) or "z")
			else
				return type(a) == "string"
			end
		end)

		local numCols = math.floor((scrollContent:GetWidth() - 20 - 2)/(36 + 2))	-- or is it panel's width we want?
		for index, itemID in ipairs(data) do
			local button = _G[scrollContent:GetName().."_Item"..index]
			if not button then	-- create another button
				button = CreateFrame("CheckButton", scrollContent:GetName().."_Item"..index, scrollContent)
				button:SetWidth(36)
				button:SetHeight(36)

				button.limit = button:CreateFontString(nil, "ARTWORK", "NumberFontNormal")
				button.limit:SetPoint("BOTTOMLEFT", button, "BOTTOMLEFT", 2, 2)
				button.limit:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -2, 2)
				button.limit:SetHeight(20)
				button.limit:SetJustifyH("RIGHT")
				button.limit:SetJustifyV("BOTTOM")
				button.limit:SetText("")
				
				button.global = button:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
				button.global:SetPoint("TOPLEFT", button, "TOPLEFT", 2, -2)
				button.global:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -3, 1)
				button.global:SetJustifyH("LEFT")
				button.global:SetJustifyV("TOP")
				button.global:SetText("")
				
				button:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square")
				button:SetCheckedTexture("Interface\\Buttons\\UI-Button-Outline")
				button:SetChecked(false)
				local tex = button:GetCheckedTexture()
				tex:ClearAllPoints()
				tex:SetPoint("CENTER")
				tex:SetWidth(36/37*66) tex:SetHeight(36/37*66)
				
				button:SetScript("OnClick", function(self)
					local check = self:GetChecked()
					if IsModifiedClick() then	-- this handles chat linking as well as dress-up
						local linkText = type(self.itemID) == "string" and self.itemID or BrokerGarbage.locale.AuctionAddonUnknown
						HandleModifiedItemClick(self.itemLink or linkText)
						self:SetChecked(not check)
					elseif not IsModifierKeyDown() then
						self:SetChecked(check)
					else
						self:SetChecked(not check)
					end
				end)
				button:SetScript("OnEnter", ShowTooltip)
				button:SetScript("OnLeave", HideTooltip)				
			end
			
			-- update button positions
			if index == 1 then		-- place first icon
				button:SetPoint("TOPLEFT", scrollContent, "TOPLEFT", 6, -6)
			elseif mod(index, numCols) == 1 then	-- new row
				button:SetPoint("TOPLEFT", _G[scrollContent:GetName().."_Item" .. index - numCols], "BOTTOMLEFT", 0, -6)
			else					-- new button next to the old one
				button:SetPoint("LEFT", _G[scrollContent:GetName().."_Item" .. index - 1], "RIGHT", 4, 0)
			end
			
			-- update this button with data
			local itemLink, texture
			if type(itemID) ~= "number" then	-- this is an item category
				itemLink = nil
				button.tiptext = itemID			-- category description string
				button.itemID = nil
				texture = "Interface\\Icons\\Trade_engineering"
			else	-- this is an explicit item
				_, itemLink, _, _, _, _, _, _, _, texture, _ = GetItemInfo(itemID)
				button.itemID = itemID
				button.tiptext = nil
			end
			
			if texture then	-- everything's fine
				button.itemLink = itemLink
				
				if globalList[itemID] then
					button.global:SetText("G")
					button.isGlobal = true
				else
					button.global:SetText("")
					button.isGlobal = false
				end
				if button.isGlobal and globalList[itemID] ~= true then
					button.limit:SetText(globalList[itemID])
				elseif localList[itemID] ~= true then
					button.limit:SetText(localList[itemID])
				else
					button.limit:SetText("")
				end
				
				if not itemLink and not BrokerGarbage.PT then
					button:SetAlpha(0.2)
					button.tiptext = button.tiptext .. "\n|cffff0000"..BrokerGarbage.locale.LPTNotLoaded
				end
			else	-- an item the server has not seen
				button.tiptext = "ID: "..itemID
			end
			button:SetNormalTexture(texture or "Interface\\Icons\\Inv_misc_questionmark")
			
			if BrokerGarbage.listOptions.current == "include" then
				button:EnableMouseWheel(true)
				button:SetScript("OnMouseWheel", OnMouseWheel)
			else
				button:EnableMouseWheel(false)
			end
			button:SetChecked(false)
			button:Show()
		end
		-- hide unnessessary buttons
		local index = #data + 1
		while _G[scrollContent:GetName().."_Item"..index] do
			_G[scrollContent:GetName().."_Item"..index]:Hide()
			index = index + 1
		end
	end
	
	-- shows some help strings for setting up the lists
	function BrokerGarbage:ShowHelp()
		if not _G["BG_HelpFrame"] then
			local helpFrame = CreateFrame("Frame", "BG_HelpFrame", scrollContent)
			helpFrame:SetAllPoints()
			
			local helpTexts = helpFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
			helpTexts:SetPoint("TOPLEFT", helpFrame, "TOPLEFT", 8, -4)
			helpTexts:SetWidth(helpFrame:GetWidth() - 8)	-- substract the offset we added to the left
			helpTexts:SetWordWrap(true)
			helpTexts:SetJustifyH("LEFT")
			helpTexts:SetJustifyV("TOP")
			helpTexts:SetText(BrokerGarbage.locale.listsBestUse .. "\n\n" ..
				BrokerGarbage.locale.listsSpecialOptions .. "\n\n" ..
				BrokerGarbage.locale.iconButtonsUse .. "\n\n" ..
				BrokerGarbage.locale.actionButtonsUse .. "\n")
		else
			_G["BG_HelpFrame"]:Show()
		end
	end
	
	-- when a search string is passed, suitable items will be shown while the rest is grayed out
	function BrokerGarbage:UpdateSearch(searchString)
		local index = 1
		local button = _G[scrollContent:GetName().."_Item"..index]
		while button and button:IsVisible() do
			local name = button.itemID and GetItemInfo(button.itemID) or button.tiptext
			name = (button.itemID or "") .. " " .. (name or "")
			name = name:lower()
			
			if not searchString or string.match(name, searchString) then
				button:SetAlpha(1)
			else
				button:SetAlpha(0.3)
			end
			index = index + 1
			button = _G[scrollContent:GetName().."_Item"..index]
		end
	end
	
	local function AddItem(item)
		BrokerGarbage:Debug("Add Item", item)
		local cursorType, itemID, link = GetCursorInfo()
		if not item and not (cursorType and itemID and link) then
			return
		end
		
		-- find the item we want to add
		if itemID then	-- real items
			itemID = itemID
			BrokerGarbage.itemsCache[itemID] = nil
		else			-- category strings
			itemID = item
			BrokerGarbage.itemsCache = {}
		end
		
		-- create "link" for output
		if type(itemID) == "number" then
			link = select(2, GetItemInfo(itemID))
		else
			link = itemID
		end
		
		if BG_LocalDB[frame.current] and BG_LocalDB[frame.current][itemID] == nil then
			BG_LocalDB[frame.current][itemID] = true
			BrokerGarbage:Print(format(BrokerGarbage.locale["addedTo_" .. frame.current], link))
			BrokerGarbage:ListOptionsUpdate()
			ClearCursor()
		elseif BG_LocalDB[frame.current] == nil and 
			BG_GlobalDB[frame.current] and BG_GlobalDB[frame.current][itemID] == nil then
			BG_GlobalDB[frame.current][itemID] = true
			BrokerGarbage:Print(format(BrokerGarbage.locale["addedTo_" .. frame.current], link))
			BrokerGarbage:ListOptionsUpdate()
			ClearCursor()
		else
			BrokerGarbage:Print(string.format(BrokerGarbage.locale.itemAlreadyOnList, link))
		end
		BrokerGarbage:ScanInventory()
		BrokerGarbage:UpdateRepairButton()
	end
	
	if not _G["BG_LPTMenuFrame"] then		
		--initialize dropdown menu for adding setstrings
		BrokerGarbage.menuFrame = CreateFrame("Frame", "BG_LPTMenuFrame", UIParent, "UIDropDownMenuTemplate")
		UIDropDownMenu_Initialize(BrokerGarbage.menuFrame, function(self, level)
			BrokerGarbage:LPTDropDown(self, level, function(self)
				AddItem(self.value)
				BrokerGarbage:ListOptionsUpdate()
			end)
		end, "MENU")
	end
	
	local function OnClick(self, button)
		if frame.current == nil then return end
		if button == "RightButton" then
			-- toggle LibPeriodicTable menu
			BrokerGarbage.menuFrame.clickTarget = self
			ToggleDropDownMenu(1, nil, BrokerGarbage.menuFrame, self, -20, 0)
			return
		end
		
		-- add action
		if self == plus then			
			AddItem()
		-- remove action
		elseif self == minus then
			BrokerGarbage:Debug("Clicked on Minus: Remove items")
			local index = 1
			while _G["BG_ListOptions_ScrollFrame_Item"..index] do
				local button = _G["BG_ListOptions_ScrollFrame_Item"..index]
				if button:IsVisible() and button:GetChecked() then
					BrokerGarbage:Debug("Button visible & checked. removing")
					local item = button.itemID or button.tiptext
					if BG_LocalDB[frame.current] then
						BrokerGarbage:Debug("is local")
						BG_LocalDB[frame.current][item] = nil
					end
					if BG_GlobalDB[frame.current] then
						BrokerGarbage:Debug("is global")
						BG_GlobalDB[frame.current][item] = nil
					end
					
					if type(item) == "number" then	-- regular item
						BrokerGarbage.itemsCache[item] = nil
					else							-- category string
						BrokerGarbage.itemsCache = {}
					end
				end
				index = index + 1
			end
		-- demote action
		elseif self == demote then
			local index = 1
			while _G["BG_ListOptions_ScrollFrame_Item"..index] do
				local button = _G["BG_ListOptions_ScrollFrame_Item"..index]
				if button:IsVisible() and button:GetChecked() then
					local item = button.itemID or button.tiptext
					if BG_GlobalDB[frame.current][item] and BG_LocalDB[frame.current] then
						BG_LocalDB[frame.current][item] = BG_GlobalDB[frame.current][item]
						BG_GlobalDB[frame.current][item] = nil
					end
				end
				index = index + 1
			end
		-- promote action
		elseif self == promote then
			local index = 1
			while _G["BG_ListOptions_ScrollFrame_Item"..index] do
				local button = _G["BG_ListOptions_ScrollFrame_Item"..index]
				if button:IsVisible() and button:GetChecked() then
					local item = button.itemID or button.tiptext
					if not BG_GlobalDB[frame.current][item] then
						BG_GlobalDB[frame.current][item] = BG_LocalDB[frame.current][item]
						BG_LocalDB[frame.current][item] = nil
					end
				end
				index = index + 1
			end
		-- empty action
		elseif self == emptyList then
			BrokerGarbage.itemsCache = {}
			if IsShiftKeyDown() then
				BG_GlobalDB[frame.current] = {}
			elseif BG_LocalDB[frame.current] then
				BG_LocalDB[frame.current] = {}
			end
		end
		
		BrokerGarbage:ScanInventory()
		BrokerGarbage:ListOptionsUpdate()
		BrokerGarbage:UpdateRepairButton()
	end
	
	plus:SetScript("OnClick", OnClick)
	plus:SetScript("OnEnter", ShowTooltip)
	plus:SetScript("OnLeave", HideTooltip)
	minus:SetScript("OnClick", OnClick)
	minus:SetScript("OnEnter", ShowTooltip)
	minus:SetScript("OnLeave", HideTooltip)
	demote:SetScript("OnClick", OnClick)
	demote:SetScript("OnEnter", ShowTooltip)
	demote:SetScript("OnLeave", HideTooltip)
	promote:SetScript("OnClick", OnClick)
	promote:SetScript("OnEnter", ShowTooltip)
	promote:SetScript("OnLeave", HideTooltip)
	emptyList:SetScript("OnClick", OnClick)
	emptyList:SetScript("OnEnter", ShowTooltip)
	emptyList:SetScript("OnLeave", HideTooltip)
	
	-- support for add-mechanism
	plus:RegisterForDrag("LeftButton")
	plus:SetScript("OnReceiveDrag", ItemDrop)
	plus:SetScript("OnMouseDown", ItemDrop)
	
	BrokerGarbage:ListOptionsUpdate()
	BrokerGarbage.listOptions:SetScript("OnShow", BrokerGarbage.ListOptionsUpdate)
end

function BrokerGarbage.CreateOptionsPanel(frame)
	local title, subtitle = LibStub("tekKonfig-Heading").new(frame, "Broker_Garbage", BrokerGarbage.locale.BasicOptionsText)

	local group = LibStub("tekKonfig-Group").new(frame, nil, "TOP", subtitle, "BOTTOM", 0, -24)
	group:SetPoint("LEFT")
	group:SetPoint("BOTTOMRIGHT")
	group:SetBackdropColor(0.1, 0.1, 0.1, 0.3)
	frame.group = group
	
	ChangeView(defaultTab)
	ShowListOptions(BrokerGarbage.listOptions)
	collectgarbage()
	frame:SetScript("OnShow", UpdateOptionsPanel)
end

BrokerGarbage.options:SetScript("OnShow", BrokerGarbage.CreateOptionsPanel)
InterfaceOptions_AddCategory(BrokerGarbage.options)

-- BrokerGarbage.listOptions:SetScript("OnShow", ShowListOptions)
InterfaceOptions_AddCategory(BrokerGarbage.listOptions)

LibStub("tekKonfig-AboutPanel").new("Broker_Garbage", "Broker_Garbage")

-- register slash commands
SLASH_BROKERGARBAGE1 = "/garbage"
SLASH_BROKERGARBAGE2 = "/garb"
function SlashCmdList.BROKERGARBAGE(msg, editbox)
	local command, rest = msg:match("^(%S*)%s*(.-)$")
	local command = strlower(command)
	local LootManager = IsAddOnLoaded("Broker_Garbage-LootManager")
	
	if command == "options" or command == "config" or command == "option" or command == "menu" then
		BrokerGarbage:OptionsFirstLoad()
		InterfaceOptionsFrame_OpenToCategory(BrokerGarbage.options)
		
	elseif command == "format" then
		if strlower(rest) ~= "reset" then
			BG_GlobalDB.LDBformat = rest
		else
			BG_GlobalDB.LDBformat = BrokerGarbage.defaultGlobalSettings.LDBformat
		end
		BrokerGarbage:ScanInventory()

	elseif command == "limit" or command == "glimit" or command == "globallimit" then
		local itemID, count = rest:match("^[^0-9]-([0-9]+).-([0-9]+)$")
		itemID = tonumber(itemID) or -1
		count = tonumber(count) or -1
		
		if itemID < 1 or count < 0 then
			BrokerGarbage:Print(BrokerGarbage.locale.invalidArgument)
		end
		BrokerGarbage.itemsCache[itemID] = nil
		
		if string.find(command, "g") then
			BG_GlobalDB.include[itemID] = count
		else
			BG_LocalDB.include[itemID] = count
		end
		local itemLink = select(2,GetItemInfo(itemID)) or BrokerGarbage.locale.unknown
		BrokerGarbage:Print(format(BrokerGarbage.locale.limitSet, itemLink, count))
		BrokerGarbage:ListOptionsUpdate("include")
	
	elseif command == "tooltiplines" or command == "numlines" then
		rest = tonumber(rest)
		if not rest then 
			BrokerGarbage:Print(BrokerGarbage.locale.invalidArgument)
			return
		end
		BG_GlobalDB.tooltipNumItems = rest
		BrokerGarbage:ScanInventory()
		if BrokerGarbage.options.currentTab and BrokerGarbage.tabs[BrokerGarbage.options.currentTab].panel.Update then
			BrokerGarbage.tabs[BrokerGarbage.options.currentTab].panel:Update()
		end
		
	elseif command == "tooltipheight" or command == "height" then
		rest = tonumber(rest)
		if not rest then 
			BrokerGarbage:Print(BrokerGarbage.locale.invalidArgument)
			return
		end
		BG_GlobalDB.tooltipMaxHeight = rest
		if BrokerGarbage.options.currentTab and BrokerGarbage.tabs[BrokerGarbage.options.currentTab].panel.Update then
			BrokerGarbage.tabs[BrokerGarbage.options.currentTab].panel:Update()
		end
		
	elseif LootManager and (command == "value" or command == "minvalue") then
		rest = tonumber(rest) or -1
		if rest < 0 then
			BrokerGarbage:Print(BrokerGarbage.locale.invalidArgument)
			return
		end
		
		BrokerGarbage_LootManager:SetMinValue(rest)
		BrokerGarbage:Print(format(BrokerGarbage.locale.minValueSet, BrokerGarbage:FormatMoney(BGLM_LocalDB.itemMinValue)))
		
	elseif LootManager and (command == "freeslots" or command == "slots" or command == "free" or command == "minfree") then
		rest = tonumber(rest)
		if not rest then 
			BrokerGarbage:Print(BrokerGarbage.locale.invalidArgument)
			return
		end
		
		BrokerGarbage_LootManager:SetMinSlots(rest)
		BrokerGarbage:Print(format(BrokerGarbage.locale.minSlotsSet, BGLM_GlobalDB.tooFewSlots))
		
	else
		BrokerGarbage:Print(BrokerGarbage.locale.slashCommandHelp)
	end
end