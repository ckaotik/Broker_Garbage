local _, BGC = ...

local function Options_BasicOptions(pluginID)
	local panel, tab = BGC:CreateOptionsTab(pluginID)
	
	local behavior = LibStub("tekKonfig-Group").new(panel, BGC.locale.GroupBehavior, "TOPLEFT", 21, -16)
	behavior:SetHeight(190); behavior:SetWidth(180)
	behavior:SetBackdropColor(0.1, 0.1, 0.1, 0.4)
	
	local sell = BGC.CreateCheckBox(behavior, nil, BGC.locale.autoSellTitle, "TOPLEFT", behavior, "TOPLEFT", 4, -2)
	sell.tiptext = BGC.locale.autoSellText .. BGC.locale.GlobalSetting
	sell:SetChecked( Broker_Garbage:GetOption("autoSellToVendor", true) )
	local checksound = sell:GetScript("OnClick")
	sell:SetScript("OnClick", function(sell)
		checksound(sell)
		Broker_Garbage:ToggleOption("autoSellToVendor", true)
	end)
	
	local nothingToSell = BGC.CreateCheckBox(behavior, nil, BGC.locale.showNothingToSellTitle, "TOPLEFT", sell, "BOTTOMLEFT", 14, 4)
	nothingToSell.tiptext = BGC.locale.showNothingToSellText .. BGC.locale.GlobalSetting
	nothingToSell:SetChecked( Broker_Garbage:GetOption("reportNothingToSell", true) )
	local checksound = nothingToSell:GetScript("OnClick")
	nothingToSell:SetScript("OnClick", function(nothingToSell)
		checksound(nothingToSell)
		Broker_Garbage:ToggleOption("reportNothingToSell", true)
	end)
	
	local repair = BGC.CreateCheckBox(behavior, nil, BGC.locale.autoRepairTitle, "TOPLEFT", nothingToSell, "BOTTOMLEFT", -14, 4)
	repair.tiptext = BGC.locale.autoRepairText .. BGC.locale.GlobalSetting
	repair:SetChecked( Broker_Garbage:GetOption("autoRepairAtVendor", true) )
	local checksound = repair:GetScript("OnClick")
	repair:SetScript("OnClick", function(repair)
		checksound(repair)
		Broker_Garbage:ToggleOption("autoRepairGuildTitle", true)
	end)

	local guildrepair = BGC.CreateCheckBox(behavior, nil, BGC.locale.autoRepairGuildTitle, "TOPLEFT", repair, "BOTTOMLEFT", 14, 4)
	guildrepair.tiptext = BGC.locale.autoRepairGuildText
	guildrepair:SetChecked( Broker_Garbage:GetOption("neverRepairGuildBank", true) )
	local checksound = guildrepair:GetScript("OnClick")
	guildrepair:SetScript("OnClick", function(guildrepair)
		checksound(guildrepair)
		Broker_Garbage:ToggleOption("neverRepairGuildBank", true)
	end)
	
	local sellGear = BGC.CreateCheckBox(behavior, nil, BGC.locale.sellNotUsableTitle, "TOPLEFT", guildrepair, "BOTTOMLEFT", -14, 4)
	sellGear.tiptext = BGC.locale.sellNotUsableText .. BGC.locale.GlobalSetting
	sellGear:SetChecked( Broker_Garbage:GetOption("sellNotWearable", true) )
	local checksound = sellGear:GetScript("OnClick")
	sellGear:SetScript("OnClick", function(sellGear)
		checksound(sellGear)
		Broker_Garbage:ToggleOption("sellNotWearable", true)
		Broker_Garbage:ScanInventory()
	end)
	
	local enchanter = BGC.CreateCheckBox(behavior, nil, BGC.locale.enchanterTitle, "TOPLEFT", sellGear, "BOTTOMLEFT", 0, 4)
	enchanter.tiptext = BGC.locale.enchanterTooltip .. BGC.locale.GlobalSetting
	enchanter:SetChecked( Broker_Garbage:GetOption("hasEnchanter", true) )
	local checksound = enchanter:GetScript("OnClick")
	enchanter:SetScript("OnClick", function(enchanter)
		checksound(enchanter)
		Broker_Garbage:ToggleOption("hasEnchanter", true)
	end)
	
	-- -----------------------------------------------------------------
	local line = BGC.CreateHorizontalRule(behavior)
	line:SetPoint("TOPLEFT", enchanter, "BOTTOMLEFT", 2, 2)
	line:SetPoint("RIGHT", -6, 2)
	-- -----------------------------------------------------------------
	
	local disableKey = CreateFrame("Frame", "BG_DisableKeyDropDown", behavior, "UIDropDownMenuTemplate")
	disableKey.tiptext = BGC.locale.DKTooltip .. BGC.locale.GlobalSetting
	disableKey.displayMode = "MENU"
	disableKey:SetScript("OnEnter", BGC.ShowTooltip)
	disableKey:SetScript("OnLeave", BGC.HideTooltip)
       disableKey:SetPoint("TOPLEFT", enchanter, "BOTTOMLEFT", -8, -20)
	local disableKeyLabel = disableKey:CreateFontString(nil, "BACKGROUND", "GameFontNormalSmall")
	disableKeyLabel:SetPoint("BOTTOMLEFT", disableKey, "TOPLEFT", 20, 2)
	disableKeyLabel:SetText(BGC.locale.DKTitle)
	_G[disableKey:GetName() .. "Button"]:SetPoint("LEFT", _G[disableKey:GetName().."Middle"])
	UIDropDownMenu_SetSelectedValue(disableKey, Broker_Garbage:GetOption("disableKey", true))
	UIDropDownMenu_SetText(disableKey, BGC.locale.disableKeys[Broker_Garbage:GetOption("disableKey", true)])
	
	local function DisableKeyOnSelect(self)
		UIDropDownMenu_SetSelectedValue(disableKey, self.value)
		Broker_Garbage:SetOption("disableKey", true, self.value)
	end
	UIDropDownMenu_Initialize(disableKey, function()
		local selected, info = UIDropDownMenu_GetSelectedValue(disableKey), UIDropDownMenu_CreateInfo()
		local keys = Broker_Garbage:GetVariable("disableKey")
		for name in pairs(keys) do
			info.text = BGC.locale.disableKeys[name]
			info.value = name
			info.func = DisableKeyOnSelect
			info.checked = name == selected
			UIDropDownMenu_AddButton(info)
		end
	end)
	
	local treshold = LibStub("tekKonfig-Group").new(panel, BGC.locale.GroupTresholds, "TOPLEFT", behavior, "BOTTOMLEFT", 0, -14)
	treshold:SetHeight(100); treshold:SetWidth(180)
	treshold:SetBackdropColor(0.1, 0.1, 0.1, 0.4)

	local qualityTreshold = CreateFrame("Frame", "BG_DropQualityDropDown", treshold, "UIDropDownMenuTemplate")
	qualityTreshold.displayMode = "MENU"
	qualityTreshold:SetPoint("TOPLEFT", treshold, -4, -20)
	_G[qualityTreshold:GetName() .. "Button"]:SetPoint("LEFT", _G[qualityTreshold:GetName().."Middle"])
	_G[qualityTreshold:GetName() .. "Button"].tiptext = BGC.locale.dropQualityText .. BGC.locale.GlobalSetting
	_G[qualityTreshold:GetName() .. "Button"]:SetScript("OnEnter", BGC.ShowTooltip)
	_G[qualityTreshold:GetName() .. "Button"]:SetScript("OnLeave", BGC.HideTooltip)
	
	local qualityTresholdLabel = qualityTreshold:CreateFontString(nil, "BACKGROUND", "GameFontNormalSmall")
	qualityTresholdLabel:SetPoint("BOTTOMLEFT", qualityTreshold, "TOPLEFT", 20, 2)
	qualityTresholdLabel:SetText(BGC.locale.dropQualityTitle)
	UIDropDownMenu_SetSelectedValue(qualityTreshold, Broker_Garbage:GetOption("dropQuality", true) )
	UIDropDownMenu_SetText(qualityTreshold, BGC.quality[ Broker_Garbage:GetOption("dropQuality", true) ])
	local function DropQualityOnSelect(self)
		UIDropDownMenu_SetSelectedValue(qualityTreshold, self.value)
		Broker_Garbage:SetOption("dropQuality", true, self.value)
		Broker_Garbage:ScanInventory()
	end
	UIDropDownMenu_Initialize(qualityTreshold, function(self)
		local selected, info = UIDropDownMenu_GetSelectedValue(self), UIDropDownMenu_CreateInfo()
		for i = 0, #BGC.quality do
			info.text = BGC.quality[i]
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
	_G[sellGearTeshold:GetName() .. "Button"].tiptext = BGC.locale.SNUMaxQualityText .. BGC.locale.GlobalSetting
	_G[sellGearTeshold:GetName() .. "Button"]:SetScript("OnEnter", BGC.ShowTooltip)
	_G[sellGearTeshold:GetName() .. "Button"]:SetScript("OnLeave", BGC.HideTooltip)
	
	local sellGearTesholdLabel = sellGearTeshold:CreateFontString(nil, "BACKGROUND", "GameFontNormalSmall")
	sellGearTesholdLabel:SetPoint("BOTTOMLEFT", sellGearTeshold, "TOPLEFT", 20, 2)
	sellGearTesholdLabel:SetText(BGC.locale.SNUMaxQualityTitle)
	UIDropDownMenu_SetSelectedValue(sellGearTeshold, Broker_Garbage:GetOption("sellNWQualityTreshold", true) )
	UIDropDownMenu_SetText(sellGearTeshold, BGC.quality[ Broker_Garbage:GetOption("sellNWQualityTreshold", true) ])
	local function SellQualityOnSelect(self)
		UIDropDownMenu_SetSelectedValue(sellGearTeshold, self.value)
		Broker_Garbage:SetOption("sellNWQualityTreshold", true, self.value)
		Broker_Garbage:ScanInventory()
	end
	UIDropDownMenu_Initialize(sellGearTeshold, function(self)
		local selected, info = UIDropDownMenu_GetSelectedValue(self), UIDropDownMenu_CreateInfo()
		for i = 0, #BGC.quality do
			info.text = BGC.quality[i]
			info.value = i
			info.func = SellQualityOnSelect
			info.checked = i == selected
			UIDropDownMenu_AddButton(info)
		end
	end)
	
	local display = LibStub("tekKonfig-Group").new(panel, BGC.locale.GroupDisplay, "TOPLEFT", behavior, "TOPRIGHT", 10, 0)
	display:SetHeight(150); display:SetWidth(180)
	display:SetBackdropColor(0.1, 0.1, 0.1, 0.4)

	local sellIcon = BGC.CreateCheckBox(display, nil, BGC.locale.showAutoSellIconTitle, "TOPLEFT", display, "TOPLEFT", 4, -2)
	sellIcon.tiptext = BGC.locale.showAutoSellIconText .. BGC.locale.GlobalSetting
	sellIcon:SetChecked( Broker_Garbage:GetOption("showAutoSellIcon", true) )
	local checksound = sellIcon:GetScript("OnClick")
	sellIcon:SetScript("OnClick", function(sellIcon)
		checksound(sellIcon)
		Broker_Garbage:ToggleOption("showAutoSellIcon", true)
		Broker_Garbage:UpdateRepairButton()
	end)
	
	-- -----------------------------------------------------------------
	local lineDisplay = BGC.CreateHorizontalRule(display)
	lineDisplay:SetPoint("TOPLEFT", sellIcon, "BOTTOMLEFT", 2, 2)
	lineDisplay:SetPoint("RIGHT", -6, 2)
	-- -----------------------------------------------------------------
	
	local function ResetEditBox(self)
		self:SetText( Broker_Garbage:GetOption(self.setting, true) )
		self:ClearFocus()
		Broker_Garbage:ScanInventory()
	end
	local function SubmitEditBox(self)
		Broker_Garbage:SetOption(self.setting, true, self:GetText())
		self:SetText(Broker_Garbage:GetOption(self.setting, true))
		self:ClearFocus()
		Broker_Garbage:ScanInventory()
	end
	local function ResetEditBoxDefault(self)
		local target = self:GetParent()
		local defaultValue = Broker_Garbage:GetVariable("defaultGlobalSettings")
		Broker_Garbage:SetOption(target.setting, true, defaultValue[target.setting])
		target:SetText( Broker_Garbage:GetOption(target.setting, true) )
		target:ClearFocus()
		Broker_Garbage:ScanInventory()
	end
	
	local LDBtitle = display:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
	LDBtitle:SetPoint("TOPLEFT", sellIcon, "BOTTOMLEFT", 8, -10)
	LDBtitle:SetText(BGC.locale.LDBDisplayTextTitle)
	
	local editHelp = CreateFrame("Button", nil, display)
	editHelp:SetPoint("LEFT", LDBtitle, "RIGHT", 2, 0)
	editHelp:SetWidth(12); editHelp:SetHeight(12)
	editHelp:SetNormalTexture("Interface\\RAIDFRAME\\ReadyCheck-Waiting")
	editHelp.tiptext = BGC.locale.LDBDisplayTextHelpTooltip
	editHelp:SetScript("OnEnter", BGC.ShowTooltip)
	editHelp:SetScript("OnLeave", BGC.HideTooltip)
	
	-- LDB format string for "Junk"
	local junkText = CreateFrame("EditBox", nil, display)
	BGC.CreateFrameBorders(junkText)
	junkText:SetPoint("TOPLEFT", LDBtitle, "BOTTOMLEFT", 2, 2)
	junkText:SetWidth(140); junkText:SetHeight(32)
	junkText:SetFontObject("GameFontHighlightSmall")
	junkText:SetAutoFocus(false)
	junkText:SetText( Broker_Garbage:GetOption("LDBformat", true) )
	junkText.tiptext = BGC.locale.LDBDisplayTextTooltip .. BGC.locale.GlobalSetting
	junkText.setting = "LDBformat"
	
	junkText:SetScript("OnEscapePressed", ResetEditBox)
	junkText:SetScript("OnEnterPressed", SubmitEditBox)
	junkText:SetScript("OnEnter", BGC.ShowTooltip)
	junkText:SetScript("OnLeave", BGC.HideTooltip)
	
	local editReset = CreateFrame("Button", nil, display)
	editReset:SetParent(junkText)
	editReset:SetPoint("LEFT", junkText, "RIGHT", 4, 0)
	editReset:SetWidth(16); editReset:SetHeight(16)
	editReset:SetNormalTexture("Interface\\RAIDFRAME\\ReadyCheck-NotReady")
	editReset.tiptext = BGC.locale.ResetToDefault
	editReset:SetScript("OnEnter", BGC.ShowTooltip)
	editReset:SetScript("OnLeave", BGC.HideTooltip)	
	editReset:SetScript("OnClick", ResetEditBoxDefault)
	
	-- LDB format string for "No Junk"
	local noJunkText = CreateFrame("EditBox", nil, display)
	BGC.CreateFrameBorders(noJunkText)
	noJunkText:SetPoint("TOPLEFT", junkText, "BOTTOMLEFT", 0, 12)
	noJunkText:SetAutoFocus(false)
	noJunkText:SetWidth(140); noJunkText:SetHeight(32)
	noJunkText:SetFontObject("GameFontHighlightSmall")
	noJunkText:SetText(  Broker_Garbage:GetOption("LDBNoJunk", true))
	noJunkText.tiptext = BGC.locale.LDBNoJunkTextTooltip .. BGC.locale.GlobalSetting
	noJunkText.setting = "LDBNoJunk"

	noJunkText:SetScript("OnEscapePressed", ResetEditBox)
	noJunkText:SetScript("OnEnterPressed", SubmitEditBox)
	noJunkText:SetScript("OnEnter", BGC.ShowTooltip)
	noJunkText:SetScript("OnLeave", BGC.HideTooltip)
	
	local editReset2 = CreateFrame("Button", nil, display)
	editReset2:SetParent(noJunkText)
	editReset2:SetPoint("LEFT", noJunkText, "RIGHT", 4, 0)
	editReset2:SetWidth(16); editReset2:SetHeight(16)
	editReset2:SetNormalTexture("Interface\\RAIDFRAME\\ReadyCheck-NotReady")
	editReset2.tiptext = BGC.locale.ResetToDefault
	editReset2:SetScript("OnEnter", BGC.ShowTooltip)
	editReset2:SetScript("OnLeave", BGC.HideTooltip)	
	editReset2:SetScript("OnClick", ResetEditBoxDefault)
	
	-- -----------------------------------------------------------------
	local lineDisplay2 = BGC.CreateHorizontalRule(display)
	lineDisplay2:SetPoint("TOPLEFT", noJunkText, "BOTTOMLEFT", -10, 2)
	lineDisplay2:SetPoint("RIGHT", -6, 2)
	-- -----------------------------------------------------------------
	
	local testValue = 130007
	local moneyFormat = CreateFrame("Frame", "BG_MoneyFormatDropDown", display, "UIDropDownMenuTemplate")
	moneyFormat.displayMode = "MENU"
	moneyFormat:SetPoint("TOPLEFT", noJunkText, "BOTTOMLEFT", -20, -20)
	_G[moneyFormat:GetName() .. "Button"]:SetPoint("LEFT", _G[moneyFormat:GetName().."Middle"])
	_G[moneyFormat:GetName() .. "Button"].tiptext = BGC.locale.moneyFormatText .. BGC.locale.GlobalSetting
	_G[moneyFormat:GetName() .. "Button"]:SetScript("OnEnter", BGC.ShowTooltip)
	_G[moneyFormat:GetName() .. "Button"]:SetScript("OnLeave", BGC.HideTooltip)
	
	local moneyFormatLabel = moneyFormat:CreateFontString(nil, "BACKGROUND", "GameFontNormalSmall")
	moneyFormatLabel:SetPoint("BOTTOMLEFT", moneyFormat, "TOPLEFT", 20, 2)
	moneyFormatLabel:SetText(BGC.locale.moneyFormatTitle)
	UIDropDownMenu_SetSelectedValue(moneyFormat, Broker_Garbage:GetOption("showMoney", true))
	UIDropDownMenu_SetText(moneyFormat, Broker_Garbage:FormatMoney(testValue))
	local function MoneyFormatOnSelect(self)
		UIDropDownMenu_SetSelectedValue(moneyFormat, self.value)
		Broker_Garbage:SetOption("showMoney", true, self.value)
		Broker_Garbage:ScanInventory()
	end
	UIDropDownMenu_Initialize(moneyFormat, function(self)
		local selected, info = UIDropDownMenu_GetSelectedValue(self), UIDropDownMenu_CreateInfo()
		for i = 0, 4 do	-- currently 4 formats are supported
			info.text = Broker_Garbage:FormatMoney(testValue, i)
			info.value = i
			info.func = MoneyFormatOnSelect
			info.checked = i == selected
			UIDropDownMenu_AddButton(info)
		end
	end)
	
	local tooltip = LibStub("tekKonfig-Group").new(panel, BGC.locale.GroupTooltip, "TOPLEFT", display, "BOTTOMLEFT", 0, -14)
	tooltip:SetHeight(140); tooltip:SetWidth(180)
	tooltip:SetBackdropColor(0.1, 0.1, 0.1, 0.4)

	local showSource = BGC.CreateCheckBox(tooltip, nil, BGC.locale.showSourceTitle, "TOPLEFT", tooltip, "TOPLEFT", 4, -2)
	showSource.tiptext = BGC.locale.showSourceText .. BGC.locale.GlobalSetting
	showSource:SetChecked( Broker_Garbage:GetOption("showSource", true) )
	local checksound = showSource:GetScript("OnClick")
	showSource:SetScript("OnClick", function(showSource)
		checksound(showSource)
		Broker_Garbage:ToggleOption("showSource", true)
	end)
	
	local showIcon = BGC.CreateCheckBox(tooltip, nil, BGC.locale.showIconTitle, "LEFT", showSource, "RIGHT", 70, 0)
	showIcon.tiptext = BGC.locale.showIconText .. BGC.locale.GlobalSetting
	showIcon:SetChecked( Broker_Garbage:GetOption("showIcon", true) )
	local checksound = showIcon:GetScript("OnClick")
	showIcon:SetScript("OnClick", function(showIcon)
		checksound(showIcon)
		Broker_Garbage:ToggleOption("showIcon", true)
	end)
	
	local showEarned = BGC.CreateCheckBox(tooltip, nil, BGC.locale.showEarnedTitle, "TOPLEFT", showSource, "BOTTOMLEFT", 0, 4)
	showEarned.tiptext = BGC.locale.showEarnedText .. BGC.locale.GlobalSetting
	showEarned:SetChecked( Broker_Garbage:GetOption("showEarned", true) )
	local checksound = showEarned:GetScript("OnClick")
	showEarned:SetScript("OnClick", function(showEarned)
		checksound(showEarned)
		Broker_Garbage:ToggleOption("showEarned", true)
	end)
	
	local showLost = BGC.CreateCheckBox(tooltip, nil, BGC.locale.showLostTitle, "LEFT", showEarned, "RIGHT", 70, 0) -- "TOPLEFT", showEarned, "BOTTOMLEFT", 0, 4)
	showLost.tiptext = BGC.locale.showLostText .. BGC.locale.GlobalSetting
	showLost:SetChecked( Broker_Garbage:GetOption("showLost", true) )
	local checksound = showLost:GetScript("OnClick")
	showLost:SetScript("OnClick", function(showLost)
		checksound(showLost)
		Broker_Garbage:ToggleOption("showLost", true)
	end)
	
	local showContainers = BGC.CreateCheckBox(tooltip, nil, BGC.locale.warnContainersTitle, "TOPLEFT", showEarned, "BOTTOMLEFT", 0, 4)
	showContainers.tiptext = BGC.locale.warnContainersText .. BGC.locale.GlobalSetting
	showContainers:SetChecked( Broker_Garbage:GetOption("showLost", true) )
	local checksound = showContainers:GetScript("OnClick")
	showContainers:SetScript("OnClick", function(showContainers)
		checksound(showContainers)
		Broker_Garbage:ToggleOption("showContainers", true)
	end)
	
	local showClams = BGC.CreateCheckBox(tooltip, nil, BGC.locale.warnClamsTitle, "LEFT", showContainers, "RIGHT", 70, 0)
	showClams.tiptext = BGC.locale.warnClamsText .. BGC.locale.GlobalSetting
	showClams:SetChecked( Broker_Garbage:GetOption("showLost", true) )
	local checksound = showClams:GetScript("OnClick")
	showClams:SetScript("OnClick", function(showClams)
		checksound(showClams)
		Broker_Garbage:ToggleOption("showClams", true)
	end)

	-- -----------------------------------------------------------------
	local lineTooltip = BGC.CreateHorizontalRule(tooltip)
	lineTooltip:SetPoint("TOPLEFT", showContainers, "BOTTOMLEFT", 2, 2)
	lineTooltip:SetPoint("RIGHT", -6, 2)
	-- -----------------------------------------------------------------
	
	local numItems, numItemsText, _, low, high = LibStub("tekKonfig-Slider").new(tooltip, 
		BGC.locale.maxItemsTitle .. ": " .. Broker_Garbage:GetOption("tooltipNumItems", true), 
		0, 50, "TOPLEFT", lineTooltip, "BOTTOMLEFT", 12, 0)
	numItems.tiptext = BGC.locale.maxItemsText .. BGC.locale.GlobalSetting
	numItems:SetWidth(165)
	numItems:SetValueStep(1);
	numItems:SetValue( Broker_Garbage:GetOption("tooltipNumItems", true) )
	numItems:SetScript("OnValueChanged", function(numItems)
		Broker_Garbage:SetOption("tooltipNumItems", true, numItems:GetValue())
		numItemsText:SetText(BGC.locale.maxItemsTitle .. ": " .. numItems:GetValue())
	end)
	low:Hide(); high:Hide()

	local tooltipHeight, tooltipHeightText, _, low, high = LibStub("tekKonfig-Slider").new(tooltip, 
		BGC.locale.maxHeightTitle .. ": " .. Broker_Garbage:GetOption("tooltipMaxHeight", true), 
		0, 500, "TOPLEFT", numItems, "BOTTOMLEFT", 0, -2)
	tooltipHeight.tiptext = BGC.locale.maxHeightText .. BGC.locale.GlobalSetting
	tooltipHeight:SetWidth(160)
	tooltipHeight:SetValueStep(10);
	tooltipHeight:SetValue( Broker_Garbage:GetOption("tooltipMaxHeight", true) )
	tooltipHeight:SetScript("OnValueChanged", function(tooltipHeight)
		Broker_Garbage:SetOption("tooltipMaxHeight", true, tooltipHeight:GetValue())
		tooltipHeightText:SetText(BGC.locale.maxHeightTitle .. ": " .. tooltipHeight:GetValue())
	end)
	low:Hide(); high:Hide()
	
	function panel:Update()
		junkText:SetText( Broker_Garbage:GetOption("LDBformat", true) )
		noJunkText:SetText( Broker_Garbage:GetOption("LDBNoJunk", true) )
		
		local min, max = numItems:GetMinMaxValues()
		local num = Broker_Garbage:GetOption("tooltipNumItems", true)
		if num > min and num < max then
			numItems:SetValue( num )
		end
		numItemsText:SetText(BGC.locale.maxItemsTitle .. ": " .. num)
		
		min, max = tooltipHeight:GetMinMaxValues()
		local ttHeight = Broker_Garbage:GetOption("tooltipMaxHeight", true)
		if ttHeight > min and ttHeight < max then
			tooltipHeight:SetValue( ttHeight )
		end
		tooltipHeightText:SetText(BGC.locale.maxHeightTitle .. ": " .. ttHeight)
	end
end
Broker_Garbage:RegisterPlugin(BGC.locale.BasicOptionsTitle, Options_BasicOptions)