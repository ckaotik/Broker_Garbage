local _, BGC = ...

-- GLOBALS: Broker_Garbage, LibStub, _G
-- GLOBALS: UIDropDownMenu_CreateInfo, UIDropDownMenu_GetSelectedValue, UIDropDownMenu_AddButton, UIDropDownMenu_SetSelectedValue, UIDropDownMenu_SetText, UIDropDownMenu_SetWidth, UIDropDownMenu_JustifyText, CreateFrame, IsAddOnLoaded

local pairs = pairs

local function Options_BasicOptions(pluginID)
	local panel, tab = BGC:CreateOptionsTab(pluginID)

	local behavior = LibStub("tekKonfig-Group").new(panel, BGC.locale.GroupBehavior, "TOPLEFT", 21, -16)
	behavior:SetHeight(333); behavior:SetWidth(180)
	behavior:SetBackdropColor(0.1, 0.1, 0.1, 0.4)

	local sell = BGC.CreateCheckBox(behavior, nil, BGC.locale.autoSellTitle, "TOPLEFT", behavior, "TOPLEFT", 4, -2)
	sell.tiptext = BGC.locale.autoSellText .. BGC.locale.GlobalSetting
	sell:SetChecked( Broker_Garbage:GetOption("autoSellToVendor", true) )
	local checksound = sell:GetScript("OnClick")
	sell:SetScript("OnClick", function(self)
		checksound(self)
		Broker_Garbage:ToggleOption("autoSellToVendor", true)
	end)

	local overrideLPT = BGC.CreateCheckBox(behavior, nil, BGC.locale.overrideLPTTitle, "TOPLEFT", sell, "BOTTOMLEFT", 0, 4)
	overrideLPT.tiptext = BGC.locale.overrideLPTTooltip .. BGC.locale.GlobalSetting
	overrideLPT:SetChecked( Broker_Garbage:GetOption("overrideLPT", true) )
	local checksound = overrideLPT:GetScript("OnClick")
	overrideLPT:SetScript("OnClick", function(self)
		checksound(self)
		Broker_Garbage:ToggleOption("overrideLPT", true)
		Broker_Garbage.ClearCache()
		Broker_Garbage.ScanInventory()
	end)

	local sellGear = BGC.CreateCheckBox(behavior, nil, BGC.locale.sellNotUsableTitle, "TOPLEFT", overrideLPT, "BOTTOMLEFT", 0, 4)
	sellGear.tiptext = BGC.locale.sellNotUsableText .. BGC.locale.GlobalSetting
	sellGear:SetChecked( Broker_Garbage:GetOption("sellNotWearable", true) )
	local checksound = sellGear:GetScript("OnClick")
	sellGear:SetScript("OnClick", function(self)
		checksound(self)
		Broker_Garbage:ToggleOption("sellNotWearable", true)
		Broker_Garbage.ClearCache()
		Broker_Garbage.ScanInventory()
	end)

	local sellOutdatedGear = BGC.CreateCheckBox(behavior, nil, BGC.locale.TopFitOldItem, "TOPLEFT", sellGear, "BOTTOMLEFT", 0, 4)
	sellOutdatedGear.tiptext = BGC.locale.TopFitOldItemText .. BGC.locale.GlobalSetting
	sellOutdatedGear:SetChecked( Broker_Garbage:GetOption("sellOldGear", true) )
	local checksound = sellOutdatedGear:GetScript("OnClick")
	sellOutdatedGear:SetScript("OnClick", function(self)
		checksound(self)
		Broker_Garbage:ToggleOption("sellOldGear", true)
		Broker_Garbage.UpdateAllDynamicItems()
		Broker_Garbage:UpdateLDB()
	end)
	if not IsAddOnLoaded("TopFit") then
		sellOutdatedGear:Disable()
	end

	local keepHighestItemLevel = BGC.CreateCheckBox(behavior, nil, BGC.locale.keepMaxItemLevelTitle, "TOPLEFT", sellOutdatedGear, "BOTTOMLEFT", 14, 4)
	keepHighestItemLevel.tiptext = BGC.locale.keepMaxItemLevelText .. BGC.locale.GlobalSetting
	keepHighestItemLevel:SetChecked( Broker_Garbage:GetOption("keepHighestItemLevel", true) )
	local checksound = keepHighestItemLevel:GetScript("OnClick")
	keepHighestItemLevel:SetScript("OnClick", function(self)
		checksound(self)
		Broker_Garbage:ToggleOption("keepHighestItemLevel", true)
	end)

	-- -----------------------------------------------------------------
	local line = BGC.CreateHorizontalRule(behavior)
	line:SetPoint("TOPLEFT", keepHighestItemLevel, "BOTTOMLEFT", 2-14, 2)
	line:SetPoint("RIGHT", -6, 2)
	-- -----------------------------------------------------------------

	local restack = BGC.CreateCheckBox(behavior, nil, BGC.locale.restackTitle, "TOPLEFT", line, "BOTTOMLEFT", 0, 0)
	restack.tiptext = BGC.locale.restackTooltip .. BGC.locale.GlobalSetting
	restack:SetChecked( Broker_Garbage:GetOption("restackInventory", true) )
	local checksound = restack:GetScript("OnClick")
	restack:SetScript("OnClick", function(self)
		checksound(self)
		Broker_Garbage:ToggleOption("restackInventory", true)
	end)

	local repair = BGC.CreateCheckBox(behavior, nil, BGC.locale.autoRepairTitle, "TOPLEFT", restack, "BOTTOMLEFT", 0, 4)
	repair.tiptext = BGC.locale.autoRepairText .. BGC.locale.GlobalSetting
	repair:SetChecked( Broker_Garbage:GetOption("autoRepairAtVendor", true) )
	local checksound = repair:GetScript("OnClick")
	repair:SetScript("OnClick", function(self)
		checksound(self)
		Broker_Garbage:ToggleOption("autoRepairAtVendor", true)
	end)

	local guildrepair = BGC.CreateCheckBox(behavior, nil, BGC.locale.autoRepairGuildTitle, "TOPLEFT", repair, "BOTTOMLEFT", 14, 4)
	guildrepair.tiptext = BGC.locale.autoRepairGuildText
	guildrepair:SetChecked( Broker_Garbage:GetOption("repairGuildBank") )
	local checksound = guildrepair:GetScript("OnClick")
	guildrepair:SetScript("OnClick", function(self)
		checksound(self)
		Broker_Garbage:ToggleOption("repairGuildBank")
	end)

	local enchanter = BGC.CreateCheckBox(behavior, nil, BGC.locale.enchanterTitle, "TOPLEFT", guildrepair, "BOTTOMLEFT", -14, 4)
	enchanter.tiptext = BGC.locale.enchanterTooltip .. BGC.locale.GlobalSetting
	enchanter:SetChecked( Broker_Garbage:GetOption("hasEnchanter", true) )
	local checksound = enchanter:GetScript("OnClick")
	enchanter:SetScript("OnClick", function(self)
		checksound(self)
		Broker_Garbage:ToggleOption("hasEnchanter", true)
	end)

	local maxSkillRank = PROFESSION_RANKS[#PROFESSION_RANKS][1]
	local laterDE, laterDEText, container, low, high = LibStub("tekKonfig-Slider").new(behavior, BGC.locale.keepForLaterDETitle .. ": " .. Broker_Garbage:GetOption("keepItemsForLaterDE", true), 0, maxSkillRank, "TOPLEFT", enchanter, "BOTTOMLEFT", 26, -2)
	laterDE.tiptext = BGC.locale.keepForLaterDETooltip .. BGC.locale.GlobalSetting
	laterDE:SetWidth(130); container:SetWidth(140);
	laterDEText:SetPoint("BOTTOMLEFT", laterDE, "TOPLEFT", 2, 0)
	laterDE:SetValueStep(5)
	laterDE:SetValue(Broker_Garbage:GetOption("keepItemsForLaterDE", true))
	laterDE:SetScript("OnValueChanged", function(self)
		Broker_Garbage:SetOption("keepItemsForLaterDE", true, self:GetValue())
		laterDEText:SetText(BGC.locale.keepForLaterDETitle .. ": " .. Broker_Garbage:GetOption("keepItemsForLaterDE", true))
		Broker_Garbage.ScanInventory()
	end)

	local hideZero = BGC.CreateCheckBox(behavior, nil, BGC.locale.hideZeroTitle, "TOPLEFT", enchanter, "BOTTOMLEFT", 0, -40)
	hideZero.tiptext = BGC.locale.hideZeroTooltip .. BGC.locale.GlobalSetting
	hideZero:SetChecked( Broker_Garbage:GetOption("hideZeroValue", true) )
	local checksound = hideZero:GetScript("OnClick")
	hideZero:SetScript("OnClick", function(self)
		checksound(self)
		Broker_Garbage:ToggleOption("hideZeroValue", true)
		Broker_Garbage.ScanInventory()
	end)

	-- -----------------------------------------------------------------
	local line2 = BGC.CreateHorizontalRule(behavior)
	line2:SetPoint("TOPLEFT", hideZero, "BOTTOMLEFT", 2, 2)
	line2:SetPoint("RIGHT", -6, 2)
	-- -----------------------------------------------------------------

	local disableKey = CreateFrame("Frame", "BG_DisableKeyDropDown", enchanter, "UIDropDownMenuTemplate")
	disableKey.tiptext = BGC.locale.DKTooltip .. BGC.locale.GlobalSetting
	disableKey.displayMode = "MENU"
	disableKey:SetPoint("TOPLEFT", line2, "BOTTOMLEFT", -18, -14)
	disableKey:SetScript("OnEnter", BGC.ShowTooltip)
	disableKey:SetScript("OnLeave", BGC.HideTooltip)
	local disableKeyLabel = disableKey:CreateFontString(nil, "BACKGROUND", "GameFontNormalSmall")
	disableKeyLabel:SetPoint("BOTTOMLEFT", disableKey, "TOPLEFT", 20, 2)
	disableKeyLabel:SetText(BGC.locale.DKTitle)
	_G[disableKey:GetName() .. "Button"]:SetPoint("LEFT", _G[disableKey:GetName().."Middle"])
	UIDropDownMenu_SetSelectedValue(disableKey, Broker_Garbage:GetOption("disableKey", true))
	UIDropDownMenu_SetText(disableKey, BGC.locale["disableKey_"..Broker_Garbage:GetOption("disableKey", true)])
	UIDropDownMenu_SetWidth(disableKey, 150, 0)
	UIDropDownMenu_JustifyText(disableKey, "LEFT")

	local function DisableKeyOnSelect(self)
		UIDropDownMenu_SetSelectedValue(disableKey, self.value)
		Broker_Garbage:SetOption("disableKey", true, self.value)
	end
	disableKey.initialize = function()
		local selected, info = UIDropDownMenu_GetSelectedValue(disableKey), UIDropDownMenu_CreateInfo()
		local keys = Broker_Garbage:GetVariable("disableKey")
		for name in pairs(keys) do
			info.text = BGC.locale["disableKey_"..name]
			info.value = name
			info.func = DisableKeyOnSelect
			info.checked = name == selected
			UIDropDownMenu_AddButton(info)
		end
	end

	local thresholds = LibStub("tekKonfig-Group").new(panel, BGC.locale.GroupTresholds, "TOPLEFT", behavior, "TOPRIGHT", 10, 0)
	thresholds:SetHeight(96); thresholds:SetWidth(180)
	thresholds:SetBackdropColor(0.1, 0.1, 0.1, 0.4)

	local qualityTreshold = CreateFrame("Frame", "BG_DropQualityDropDown", thresholds, "UIDropDownMenuTemplate")
	qualityTreshold.displayMode = "MENU"
	qualityTreshold:SetPoint("TOPLEFT", thresholds, "TOPLEFT", -10, -18)
	_G[qualityTreshold:GetName() .. "Button"]:SetPoint("LEFT", _G[qualityTreshold:GetName().."Middle"])
	_G[qualityTreshold:GetName() .. "Button"].tiptext = BGC.locale.dropQualityText .. BGC.locale.GlobalSetting
	_G[qualityTreshold:GetName() .. "Button"]:SetScript("OnEnter", BGC.ShowTooltip)
	_G[qualityTreshold:GetName() .. "Button"]:SetScript("OnLeave", BGC.HideTooltip)

	local qualityTresholdLabel = qualityTreshold:CreateFontString(nil, "BACKGROUND", "GameFontNormalSmall")
	qualityTresholdLabel:SetPoint("BOTTOMLEFT", qualityTreshold, "TOPLEFT", 20, 2)
	qualityTresholdLabel:SetText(BGC.locale.dropQualityTitle)
	UIDropDownMenu_SetSelectedValue(qualityTreshold, Broker_Garbage:GetOption("dropQuality", true) )
	UIDropDownMenu_SetText(qualityTreshold, BGC.quality[ Broker_Garbage:GetOption("dropQuality", true) ])
	UIDropDownMenu_SetWidth(qualityTreshold, 150, 0)
	UIDropDownMenu_JustifyText(qualityTreshold, "LEFT")
	local function DropQualityOnSelect(self)
		UIDropDownMenu_SetSelectedValue(qualityTreshold, self.value)
		Broker_Garbage:SetOption("dropQuality", true, self.value)
		Broker_Garbage.ScanInventory(true)
	end
	qualityTreshold.initialize = function(self)
		local selected, info = UIDropDownMenu_GetSelectedValue(self), UIDropDownMenu_CreateInfo()
		for i = 0, #BGC.quality do
			info.text = BGC.quality[i]
			info.value = i
			info.func = DropQualityOnSelect
			info.checked = i == selected
			UIDropDownMenu_AddButton(info)
		end
	end

	local sellGearTeshold = CreateFrame("Frame", "BG_SellQualityDropDown", thresholds, "UIDropDownMenuTemplate")
	sellGearTeshold.displayMode = "MENU"
	sellGearTeshold:SetPoint("TOPLEFT", qualityTreshold, "BOTTOMLEFT", 0, -12)
	_G[sellGearTeshold:GetName() .. "Button"]:SetPoint("LEFT", _G[sellGearTeshold:GetName().."Middle"])
	_G[sellGearTeshold:GetName() .. "Button"].tiptext = BGC.locale.SNUMaxQualityText .. BGC.locale.GlobalSetting
	_G[sellGearTeshold:GetName() .. "Button"]:SetScript("OnEnter", BGC.ShowTooltip)
	_G[sellGearTeshold:GetName() .. "Button"]:SetScript("OnLeave", BGC.HideTooltip)

	local sellGearTesholdLabel = sellGearTeshold:CreateFontString(nil, "BACKGROUND", "GameFontNormalSmall")
	sellGearTesholdLabel:SetPoint("BOTTOMLEFT", sellGearTeshold, "TOPLEFT", 20, 2)
	sellGearTesholdLabel:SetText(BGC.locale.SNUMaxQualityTitle)
	UIDropDownMenu_SetSelectedValue(sellGearTeshold, Broker_Garbage:GetOption("sellNWQualityTreshold", true) )
	UIDropDownMenu_SetText(sellGearTeshold, BGC.quality[ Broker_Garbage:GetOption("sellNWQualityTreshold", true) ])
	UIDropDownMenu_SetWidth(sellGearTeshold, 150, 0)
	UIDropDownMenu_JustifyText(sellGearTeshold, "LEFT")
	local function SellQualityOnSelect(self)
		UIDropDownMenu_SetSelectedValue(sellGearTeshold, self.value)
		Broker_Garbage:SetOption("sellNWQualityTreshold", true, self.value)
		Broker_Garbage.ScanInventory(true)
	end
	sellGearTeshold.initialize = function(self)
		local selected, info = UIDropDownMenu_GetSelectedValue(self), UIDropDownMenu_CreateInfo()
		for i = 0, #BGC.quality do
			info.text = BGC.quality[i]
			info.value = i
			info.func = SellQualityOnSelect
			info.checked = i == selected
			UIDropDownMenu_AddButton(info)
		end
	end

	local tooltip = LibStub("tekKonfig-Group").new(panel, BGC.locale.GroupTooltip, "TOPLEFT", thresholds, "BOTTOMLEFT", 0, -14)
	tooltip:SetHeight(215); tooltip:SetWidth(180)
	tooltip:SetBackdropColor(0.1, 0.1, 0.1, 0.4)

	local showSource = BGC.CreateCheckBox(tooltip, nil, BGC.locale.showSourceTitle, "TOPLEFT", tooltip, "TOPLEFT", 4, -2)
	showSource.tiptext = BGC.locale.showSourceText .. BGC.locale.GlobalSetting
	showSource:SetChecked( Broker_Garbage:GetOption("showSource", true) )
	local checksound = showSource:GetScript("OnClick")
	showSource:SetScript("OnClick", function(self)
		checksound(self)
		Broker_Garbage:ToggleOption("showSource", true)
	end)

	local showIcon = BGC.CreateCheckBox(tooltip, nil, BGC.locale.showIconTitle, "LEFT", showSource, "RIGHT", 70, 0)
	showIcon.tiptext = BGC.locale.showIconText .. BGC.locale.GlobalSetting
	showIcon:SetChecked( Broker_Garbage:GetOption("showIcon", true) )
	local checksound = showIcon:GetScript("OnClick")
	showIcon:SetScript("OnClick", function(self)
		checksound(self)
		Broker_Garbage:ToggleOption("showIcon", true)
	end)

	local showEarned = BGC.CreateCheckBox(tooltip, nil, BGC.locale.showEarnedTitle, "TOPLEFT", showSource, "BOTTOMLEFT", 0, 4)
	showEarned.tiptext = BGC.locale.showEarnedText .. BGC.locale.GlobalSetting
	showEarned:SetChecked( Broker_Garbage:GetOption("showEarned", true) )
	local checksound = showEarned:GetScript("OnClick")
	showEarned:SetScript("OnClick", function(self)
		checksound(self)
		Broker_Garbage:ToggleOption("showEarned", true)
	end)

	local showLost = BGC.CreateCheckBox(tooltip, nil, BGC.locale.showLostTitle, "LEFT", showEarned, "RIGHT", 70, 0) -- "TOPLEFT", showEarned, "BOTTOMLEFT", 0, 4)
	showLost.tiptext = BGC.locale.showLostText .. BGC.locale.GlobalSetting
	showLost:SetChecked( Broker_Garbage:GetOption("showLost", true) )
	local checksound = showLost:GetScript("OnClick")
	showLost:SetScript("OnClick", function(self)
		checksound(self)
		Broker_Garbage:ToggleOption("showLost", true)
	end)

	local showContainers = BGC.CreateCheckBox(tooltip, nil, BGC.locale.warnContainersTitle, "TOPLEFT", showEarned, "BOTTOMLEFT", 0, 4)
	showContainers.tiptext = BGC.locale.warnContainersText .. BGC.locale.GlobalSetting
	showContainers:SetChecked( Broker_Garbage:GetOption("showLost", true) )
	local checksound = showContainers:GetScript("OnClick")
	showContainers:SetScript("OnClick", function(self)
		checksound(self)
		Broker_Garbage:ToggleOption("showContainers", true)
	end)

	-- -----------------------------------------------------------------
	local lineTooltip = BGC.CreateHorizontalRule(tooltip)
	lineTooltip:SetPoint("TOPLEFT", showContainers, "BOTTOMLEFT", 2, 2)
	lineTooltip:SetPoint("RIGHT", -6, 2)
	-- -----------------------------------------------------------------

	local numItems, numItemsText, container, low, high = LibStub("tekKonfig-Slider").new(tooltip,
		BGC.locale.maxItemsTitle .. ": " .. Broker_Garbage:GetOption("tooltipNumItems", true),
		0, 50, "TOPLEFT", lineTooltip, "BOTTOMLEFT", 4, -4)
	numItems.tiptext = BGC.locale.maxItemsText .. BGC.locale.GlobalSetting
	numItems:SetWidth(150); container:SetWidth(160)
	numItemsText:SetPoint("BOTTOMLEFT", numItems, "TOPLEFT", 2, 0)
	numItems:SetValueStep(1);
	numItems:SetValue( Broker_Garbage:GetOption("tooltipNumItems", true) )
	numItems:SetScript("OnValueChanged", function(self)
		Broker_Garbage:SetOption("tooltipNumItems", true, self:GetValue())
		numItemsText:SetText(BGC.locale.maxItemsTitle .. ": " .. self:GetValue())
	end)
	low:Hide(); high:Hide()

	local tooltipHeight, tooltipHeightText, container, low, high = LibStub("tekKonfig-Slider").new(tooltip,
		BGC.locale.maxHeightTitle .. ": " .. Broker_Garbage:GetOption("tooltipMaxHeight", true),
		0, 500, "TOPLEFT", numItems, "BOTTOMLEFT", 0, -2)
	tooltipHeight.tiptext = BGC.locale.maxHeightText .. BGC.locale.GlobalSetting
	tooltipHeight:SetWidth(150); container:SetWidth(160);
	tooltipHeightText:SetPoint("BOTTOMLEFT", tooltipHeight, "TOPLEFT", 2, 0)
	tooltipHeight:SetValueStep(10);
	tooltipHeight:SetValue( Broker_Garbage:GetOption("tooltipMaxHeight", true) )
	tooltipHeight:SetScript("OnValueChanged", function(self)
		Broker_Garbage:SetOption("tooltipMaxHeight", true, self:GetValue())
		tooltipHeightText:SetText(BGC.locale.maxHeightTitle .. ": " .. self:GetValue())
	end)
	low:Hide(); high:Hide()

	-- -----------------------------------------------------------------
	local lineTooltip2 = BGC.CreateHorizontalRule(tooltip)
	lineTooltip2:SetPoint("TOPLEFT", tooltipHeight, "BOTTOMLEFT", -4, 0)
	lineTooltip2:SetPoint("RIGHT", -6, 2)
	-- -----------------------------------------------------------------

	local function ResetEditBox(self)
		self:SetText( Broker_Garbage:GetOption(self.setting, true) )
		self:ClearFocus()
		Broker_Garbage.ScanInventory()
	end
	local function SubmitEditBox(self)
		Broker_Garbage:SetOption(self.setting, true, self:GetText())
		self:SetText(Broker_Garbage:GetOption(self.setting, true))
		self:ClearFocus()
		Broker_Garbage.ScanInventory()
	end
	local function ResetEditBoxDefault(self)
		local target = self:GetParent()
		local defaultValue = Broker_Garbage:GetVariable("defaultGlobalSettings")
		Broker_Garbage:SetOption(target.setting, true, defaultValue[target.setting])
		target:SetText( Broker_Garbage:GetOption(target.setting, true) )
		target:ClearFocus()
		Broker_Garbage.ScanInventory()
	end

	local LDBtitle = tooltip:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
	LDBtitle:SetPoint("TOPLEFT", lineTooltip2, "BOTTOMLEFT", 6, -4)
	LDBtitle:SetText(BGC.locale.LDBDisplayTextTitle)

	local editHelp = CreateFrame("Button", nil, tooltip)
	editHelp:SetPoint("LEFT", LDBtitle, "RIGHT", 2, 0)
	editHelp:SetWidth(12); editHelp:SetHeight(12)
	editHelp:SetNormalTexture("Interface\\RAIDFRAME\\ReadyCheck-Waiting")
	editHelp.tiptext = BGC.locale.LDBDisplayTextHelpTooltip
	editHelp:SetScript("OnEnter", BGC.ShowTooltip)
	editHelp:SetScript("OnLeave", BGC.HideTooltip)

	-- LDB format string for "Junk"
	local junkText = CreateFrame("EditBox", nil, tooltip)
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

	local editReset = CreateFrame("Button", nil, tooltip)
	editReset:SetParent(junkText)
	editReset:SetPoint("LEFT", junkText, "RIGHT", 4, 0)
	editReset:SetWidth(16); editReset:SetHeight(16)
	editReset:SetNormalTexture("Interface\\RAIDFRAME\\ReadyCheck-NotReady")
	editReset.tiptext = BGC.locale.ResetToDefault
	editReset:SetScript("OnEnter", BGC.ShowTooltip)
	editReset:SetScript("OnLeave", BGC.HideTooltip)
	editReset:SetScript("OnClick", ResetEditBoxDefault)

	-- LDB format string for "No Junk"
	local noJunkText = CreateFrame("EditBox", nil, tooltip)
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

	local editReset2 = CreateFrame("Button", nil, tooltip)
	editReset2:SetParent(noJunkText)
	editReset2:SetPoint("LEFT", noJunkText, "RIGHT", 4, 0)
	editReset2:SetWidth(16); editReset2:SetHeight(16)
	editReset2:SetNormalTexture("Interface\\RAIDFRAME\\ReadyCheck-NotReady")
	editReset2.tiptext = BGC.locale.ResetToDefault
	editReset2:SetScript("OnEnter", BGC.ShowTooltip)
	editReset2:SetScript("OnLeave", BGC.HideTooltip)
	editReset2:SetScript("OnClick", ResetEditBoxDefault)

	-- ----------------------------------------------------------------------------------------------------

	local display = LibStub("tekKonfig-Group").new(panel, BGC.locale.GroupDisplay, "TOPLEFT", thresholds, "TOPRIGHT", 10, 0)
	display:SetHeight(125); display:SetWidth(180)
	display:SetBackdropColor(0.1, 0.1, 0.1, 0.4)

	local sellIcon = BGC.CreateCheckBox(display, nil, BGC.locale.showAutoSellIconTitle, "TOPLEFT", display, "TOPLEFT", 4, -2)
	sellIcon.tiptext = BGC.locale.showAutoSellIconText .. BGC.locale.GlobalSetting
	sellIcon:SetChecked( Broker_Garbage:GetOption("showAutoSellIcon", true) )
	local checksound = sellIcon:GetScript("OnClick")
	sellIcon:SetScript("OnClick", function(self)
		checksound(self)
		Broker_Garbage:ToggleOption("showAutoSellIcon", true)
		MerchantFrame_UpdateRepairButtons()
	end)

	local itemTooltipLabel = BGC.CreateCheckBox(panel, nil, BGC.locale.showItemTooltipLabelTitle, "TOPLEFT", sellIcon, "BOTTOMLEFT", 0, 4)
	itemTooltipLabel.tiptext = BGC.locale.showItemTooltipLabelText .. BGC.locale.GlobalSetting
	itemTooltipLabel:SetChecked( Broker_Garbage:GetOption("showItemTooltipLabel", true) )
	local checksound = itemTooltipLabel:GetScript("OnClick")
	itemTooltipLabel:SetScript("OnClick", function(self)
		checksound(self)
		Broker_Garbage:ToggleOption("showItemTooltipLabel", true)
	end)

	local itemTooltipLabelReason = BGC.CreateCheckBox(panel, nil, BGC.locale.showItemTooltipDetailTitle, "TOPLEFT", itemTooltipLabel, "BOTTOMLEFT", 0, 4)
	itemTooltipLabelReason.tiptext = BGC.locale.showItemTooltipDetailText .. BGC.locale.GlobalSetting
	itemTooltipLabelReason:SetChecked( Broker_Garbage:GetOption("showLabelReason", true) )
	local checksound = itemTooltipLabelReason:GetScript("OnClick")
	itemTooltipLabelReason:SetScript("OnClick", function(self)
		checksound(self)
		Broker_Garbage:ToggleOption("showLabelReason", true)
	end)

	-- -----------------------------------------------------------------
	local lineDisplay = BGC.CreateHorizontalRule(display)
	lineDisplay:SetPoint("TOPLEFT", itemTooltipLabelReason, "BOTTOMLEFT", 2, 2)
	lineDisplay:SetPoint("RIGHT", -6, 2)
	-- -----------------------------------------------------------------

	local testValue = 130007
	local moneyFormat = CreateFrame("Frame", "BG_MoneyFormatDropDown", display, "UIDropDownMenuTemplate")
	moneyFormat.displayMode = "MENU"
	moneyFormat:SetPoint("TOPLEFT", lineDisplay, "BOTTOMLEFT", -16, -14)
	_G[moneyFormat:GetName() .. "Button"]:SetPoint("LEFT", _G[moneyFormat:GetName().."Middle"])
	_G[moneyFormat:GetName() .. "Button"].tiptext = BGC.locale.moneyFormatText .. BGC.locale.GlobalSetting
	_G[moneyFormat:GetName() .. "Button"]:SetScript("OnEnter", BGC.ShowTooltip)
	_G[moneyFormat:GetName() .. "Button"]:SetScript("OnLeave", BGC.HideTooltip)

	local moneyFormatLabel = moneyFormat:CreateFontString(nil, "BACKGROUND", "GameFontNormalSmall")
	moneyFormatLabel:SetPoint("BOTTOMLEFT", moneyFormat, "TOPLEFT", 20, 2)
	moneyFormatLabel:SetText(BGC.locale.moneyFormatTitle)
	UIDropDownMenu_SetSelectedValue(moneyFormat, Broker_Garbage:GetOption("showMoney", true))
	UIDropDownMenu_SetText(moneyFormat, Broker_Garbage.FormatMoney(testValue))
	UIDropDownMenu_SetWidth(moneyFormat, 150, 0)
	UIDropDownMenu_JustifyText(moneyFormat, "LEFT")
	local function MoneyFormatOnSelect(self)
		UIDropDownMenu_SetSelectedValue(moneyFormat, self.value)
		Broker_Garbage:SetOption("showMoney", true, self.value)
		Broker_Garbage.ScanInventory()
	end
	moneyFormat.initialize = function(self)
		local selected, info = UIDropDownMenu_GetSelectedValue(self), UIDropDownMenu_CreateInfo()
		local index = 0
		local formatString = Broker_Garbage.FormatMoney(testValue, 0)
		while formatString do
			info.text = formatString
			info.value = index
			info.func = MoneyFormatOnSelect
			info.checked = (index == selected)
			UIDropDownMenu_AddButton(info)

			index = index + 1
			formatString = Broker_Garbage.FormatMoney(testValue, index)
		end
	end

	local output = LibStub("tekKonfig-Group").new(panel, BGC.locale.GroupOutput, "TOPLEFT", display, "BOTTOMLEFT", 0, -14)
	output:SetHeight(108); output:SetWidth(180)
	output:SetBackdropColor(0.1, 0.1, 0.1, 0.4)

	local debugMode = BGC.CreateCheckBox(output, nil, BGC.locale.debugTitle, "TOPLEFT", output, "TOPLEFT", 4, -2)
	debugMode.tiptext = BGC.locale.debugTooltip .. BGC.locale.GlobalSetting
	debugMode:SetChecked( Broker_Garbage:GetOption("debug", true) )
	local checksound = debugMode:GetScript("OnClick")
	debugMode:SetScript("OnClick", function(self)
		checksound(self)
		Broker_Garbage:ToggleOption("debug", true)
	end)

	local sellLog = BGC.CreateCheckBox(output, nil, BGC.locale.sellLogTitle, "TOPLEFT", debugMode, "BOTTOMLEFT", 0, 4)
	sellLog.tiptext = BGC.locale.sellLogTooltip .. BGC.locale.GlobalSetting
	sellLog:SetChecked( Broker_Garbage:GetOption("showSellLog", true) )
	local checksound = sellLog:GetScript("OnClick")
	sellLog:SetScript("OnClick", function(self)
		checksound(self)
		Broker_Garbage:ToggleOption("showSellLog", true)
	end)

	local nothingToSell = BGC.CreateCheckBox(output, nil, BGC.locale.showNothingToSellTitle, "TOPLEFT", sellLog, "BOTTOMLEFT", 0, 4)
	nothingToSell.tiptext = BGC.locale.showNothingToSellText .. BGC.locale.GlobalSetting
	nothingToSell:SetChecked( Broker_Garbage:GetOption("reportNothingToSell", true) )
	local checksound = nothingToSell:GetScript("OnClick")
	nothingToSell:SetScript("OnClick", function(self)
		checksound(self)
		Broker_Garbage:ToggleOption("reportNothingToSell", true)
	end)

	local reportDE, label = BGC.CreateCheckBox(output, nil, BGC.locale.reportDEGearTitle, "TOPLEFT", nothingToSell, "BOTTOMLEFT", 0, 4)
	label:SetHeight(50)
	reportDE.tiptext = BGC.locale.reportDEGearTooltip .. BGC.locale.GlobalSetting
	reportDE:SetChecked( Broker_Garbage:GetOption("reportDisenchantOutdated", true) )
	local checksound = reportDE:GetScript("OnClick")
	reportDE:SetScript("OnClick", function(self)
		checksound(self)
		Broker_Garbage:ToggleOption("reportDisenchantOutdated", true)
	end)

	function panel:Update()
		junkText:SetText( Broker_Garbage:GetOption("LDBformat", true) )
		noJunkText:SetText( Broker_Garbage:GetOption("LDBNoJunk", true) )

		local min, max = numItems:GetMinMaxValues()
		local num = Broker_Garbage:GetOption("tooltipNumItems", true)
		if num >= min and num <= max then
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
