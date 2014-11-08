local _, BGC = ...

-- GLOBALS: Broker_Garbage, LibStub, _G
-- GLOBALS: UIDropDownMenu_CreateInfo, UIDropDownMenu_GetSelectedValue, UIDropDownMenu_AddButton, UIDropDownMenu_SetSelectedValue, UIDropDownMenu_SetText, UIDropDownMenu_SetWidth, UIDropDownMenu_JustifyText, CreateFrame, IsAddOnLoaded

-- declare so it's usable ...
local UpdateAuctionAddonList = function() end

local function EnableDisable(self, button)
	local name = self:GetParent().addonName:GetText()
	if self:GetParent().displayType == 'buyout' then
		Broker_Garbage.EnablePriceHandler(name, self:GetChecked() and true or false)
	else
		Broker_Garbage.EnablePriceHandler(name, nil, self:GetChecked() and true or false)
	end
end

local function ChangeOrder(self, button)
	local index = self:GetParent():GetID()
	local displayType = self:GetParent().displayType
	local name = self:GetParent().addonName:GetText()

	Broker_Garbage.ReOrderPriceHandler(name, displayType, index + (self.direction == 1 and 0 or 1))
	UpdateAuctionAddonList()
end

local frames = { buyout = {}, disenchant = {} }
local displayTypes = { 'buyout', 'disenchant' }
local function UpdateAuctionAddonList(panel)
	local auctionAddonOrder, auctionAddon, addonLine, bgTex
	for _, displayType in ipairs(displayTypes) do
		local numShown = 0
		auctionAddonOrder = Broker_Garbage.GetPriceHandlerOrder(displayType)
		for i, addonKey in ipairs(auctionAddonOrder) do
			auctionAddon = Broker_Garbage.GetPriceHandler(addonKey, true)
			if auctionAddon and auctionAddon[displayType] then
				addonLine = frames[displayType][i]
				if not addonLine then
					addonLine = CreateFrame('Frame', nil, panel)
					addonLine:SetSize(260, 16)
					addonLine:SetID(i)
					addonLine.displayType = displayType
					frames[displayType][i] = addonLine

					if i == 1 then
						-- addonLine:SetPoint('TOPLEFT', 16 + (displayType == 'buyout' and 0 or 260 + 40), -426)
						addonLine:SetPoint('TOPLEFT', panel.prioritiesExplain, 'BOTTOMLEFT', (displayType == 'buyout' and 0 or 260+40), -12)
					else
						addonLine:SetPoint('TOPLEFT', frames[displayType][i-1], 'BOTTOMLEFT', 0, 0)
					end
					if i%2 ~= 0 then
						bgTex = addonLine:CreateTexture(nil, 'BACKGROUND')
						bgTex:SetTexture(1, 1, 1, 0.1)
						bgTex:SetHorizTile(true)
						bgTex:SetVertTile(true)
						bgTex:SetAllPoints()
					end

					addonLine.enabled, addonLine.addonName = LibStub("tekKonfig-Checkbox").new(addonLine, 20, '', 'LEFT', -1, 0)
					addonLine.addonName:SetFontObject('GameFontNormalSmall')
					addonLine.enabled.tiptext = BGC.locale.AuctionAddonsEnableTT
					addonLine.enabled:SetScript('OnClick', EnableDisable)

					addonLine.moveUp = CreateFrame('Button', '$parentUpButton', addonLine)
					addonLine.moveUp.direction = 1
					addonLine.moveUp:SetScript('OnClick', ChangeOrder)
					addonLine.moveUp:SetPoint('TOPLEFT', 224, 2)
					addonLine.moveUp:SetSize(20, 20)
					addonLine.moveUp:SetNormalTexture('Interface\\ChatFrame\\UI-ChatIcon-ScrollUp-Up')
					addonLine.moveUp:SetPushedTexture('Interface\\ChatFrame\\UI-ChatIcon-ScrollUp-Down')
					addonLine.moveUp:SetDisabledTexture('Interface\\ChatFrame\\UI-ChatIcon-ScrollUp-Disabled')
					addonLine.moveUp:SetHighlightTexture('Interface\\PaperDollInfoFrame\\UI-Character-Tab-Highlight', 'ADD')

					addonLine.moveDown = CreateFrame('Button', '$parentDownButton', addonLine)
					addonLine.moveDown.direction = -1
					addonLine.moveDown:SetScript('OnClick', ChangeOrder)
					addonLine.moveDown:SetPoint('TOPLEFT', 224+18, 2)
					addonLine.moveDown:SetSize(20, 20)
					addonLine.moveDown:SetNormalTexture('Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Up')
					addonLine.moveDown:SetPushedTexture('Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Down')
					addonLine.moveDown:SetDisabledTexture('Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Disabled')
					addonLine.moveDown:SetHighlightTexture('Interface\\PaperDollInfoFrame\\UI-Character-Tab-Highlight', 'ADD')
				end
				addonLine.enabled:SetChecked(auctionAddon[displayType .. 'Enabled'])
				addonLine.addonName:SetText(addonKey)
				addonLine.moveDown:Show()
				if i == 1 then addonLine.moveUp:Hide()
				else addonLine.moveUp:Show() end


				numShown = numShown + 1
				addonLine:Show()
			end
		end
		if numShown > 0 and frames[displayType] and frames[displayType][numShown] then
			frames[displayType][numShown].moveDown:Hide()
		end
		for i = numShown + 1, #frames[displayType] do
			frames[i]:Hide()
		end
	end
end

-- ----------------------------------------------------------------------------

local function Options_BasicOptions(panel)
	local behavior = LibStub("tekKonfig-Group").new(panel, BGC.locale.GroupBehavior, "TOPLEFT", 20, -20)
	behavior:SetSize(185, 285)
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
	overrideLPT:SetChecked( Broker_Garbage:GetOption("LPTJunkIsJunk", true) )
	local checksound = overrideLPT:GetScript("OnClick")
	overrideLPT:SetScript("OnClick", function(self)
		checksound(self)
		Broker_Garbage:ToggleOption("LPTJunkIsJunk", true)
		Broker_Garbage.Scan()
	end)

	local sellGear = BGC.CreateCheckBox(behavior, nil, BGC.locale.sellNotUsableTitle, "TOPLEFT", overrideLPT, "BOTTOMLEFT", 0, 4)
	sellGear.tiptext = BGC.locale.sellNotUsableText .. BGC.locale.GlobalSetting
	sellGear:SetChecked( Broker_Garbage:GetOption("sellUnusable", true) )
	local checksound = sellGear:GetScript("OnClick")
	sellGear:SetScript("OnClick", function(self)
		checksound(self)
		Broker_Garbage:ToggleOption("sellUnusable", true)
		Broker_Garbage.Scan()
	end)

	local sellOutdatedGear = BGC.CreateCheckBox(behavior, nil, BGC.locale.TopFitOldItem, "TOPLEFT", sellGear, "BOTTOMLEFT", 0, 4)
	sellOutdatedGear.tiptext = BGC.locale.TopFitOldItemText .. BGC.locale.GlobalSetting
	sellOutdatedGear:SetChecked( Broker_Garbage:GetOption("sellOutdated", true) )
	local checksound = sellOutdatedGear:GetScript("OnClick")
	sellOutdatedGear:SetScript("OnClick", function(self)
		checksound(self)
		Broker_Garbage:ToggleOption("sellOutdated", true)
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

	local repair = BGC.CreateCheckBox(behavior, nil, BGC.locale.autoRepairTitle, "TOPLEFT", line, "BOTTOMLEFT", 0, 0)
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
	enchanter:SetChecked( Broker_Garbage:GetOption("disenchantValues", true) )
	local checksound = enchanter:GetScript("OnClick")
	enchanter:SetScript("OnClick", function(self)
		checksound(self)
		Broker_Garbage:ToggleOption("disenchantValues", true)
	end)

	local maxSkillRank = PROFESSION_RANKS[#PROFESSION_RANKS][1]
	local laterDE, laterDEText, container, low, high = LibStub("tekKonfig-Slider").new(behavior, BGC.locale.keepForLaterDETitle .. ": " .. Broker_Garbage:GetOption("disenchantSkillOffset", true), 0, maxSkillRank, "TOPLEFT", enchanter, "BOTTOMLEFT", 26, -2)
	laterDE.tiptext = BGC.locale.keepForLaterDETooltip .. BGC.locale.GlobalSetting
	laterDE:SetWidth(130); container:SetWidth(140);
	laterDEText:SetPoint("BOTTOMLEFT", laterDE, "TOPLEFT", 2, 0)
	laterDE:SetValueStep(5)
	laterDE:SetValue(Broker_Garbage:GetOption("disenchantSkillOffset", true))
	laterDE:SetScript("OnValueChanged", function(self)
		Broker_Garbage:SetOption("disenchantSkillOffset", true, self:GetValue())
		laterDEText:SetText(BGC.locale.keepForLaterDETitle .. ": " .. Broker_Garbage:GetOption("disenchantSkillOffset", true))
		Broker_Garbage.Scan()
	end)

	-- -----------------------------------------------------------------
	local line2 = BGC.CreateHorizontalRule(behavior)
	line2:SetPoint("TOPLEFT", enchanter, "BOTTOMLEFT", 2, 2-40)
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

	local function DisableKeyOnSelect(self)
		UIDropDownMenu_SetSelectedValue(disableKey, self.value)
		Broker_Garbage:SetOption("disableKey", true, self.value)
	end
	disableKey.initialize = function()
		local selected, info = UIDropDownMenu_GetSelectedValue(disableKey), UIDropDownMenu_CreateInfo()
		for name in pairs( Broker_Garbage.disableKey ) do
			info.text = _G[name.."_KEY"]
			info.value = name
			info.func = DisableKeyOnSelect
			info.checked = name == selected
			UIDropDownMenu_AddButton(info)
		end
	end
	UIDropDownMenu_SetWidth(disableKey, 150, 0)
	UIDropDownMenu_JustifyText(disableKey, "LEFT")
	UIDropDownMenu_SetSelectedValue(disableKey, Broker_Garbage:GetOption("disableKey", true))
	UIDropDownMenu_SetText(disableKey, _G[Broker_Garbage:GetOption("disableKey", true).."_KEY"])

	local thresholds = LibStub("tekKonfig-Group").new(panel, BGC.locale.GroupTresholds, "TOPLEFT", behavior, "TOPRIGHT", 10, 0)
	thresholds:SetSize(185, 96)
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
		Broker_Garbage.Scan(true)
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
	UIDropDownMenu_SetSelectedValue(sellGearTeshold, Broker_Garbage:GetOption("sellUnusableQuality", true) )
	UIDropDownMenu_SetText(sellGearTeshold, BGC.quality[ Broker_Garbage:GetOption("sellUnusableQuality", true) ])
	UIDropDownMenu_SetWidth(sellGearTeshold, 150, 0)
	UIDropDownMenu_JustifyText(sellGearTeshold, "LEFT")
	local function SellQualityOnSelect(self)
		UIDropDownMenu_SetSelectedValue(sellGearTeshold, self.value)
		Broker_Garbage:SetOption("sellUnusableQuality", true, self.value)
		Broker_Garbage.Scan(true)
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
	tooltip:SetSize(185, 215)
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
		BGC.locale.maxItemsTitle .. ": " .. Broker_Garbage:GetOption("tooltip.numLines", true),
		0, 50, "TOPLEFT", lineTooltip, "BOTTOMLEFT", 4, -4)
	numItems.tiptext = BGC.locale.maxItemsText .. BGC.locale.GlobalSetting
	numItems:SetWidth(150); container:SetWidth(160)
	numItemsText:SetPoint("BOTTOMLEFT", numItems, "TOPLEFT", 2, 0)
	numItems:SetValueStep(1);
	numItems:SetValue( Broker_Garbage:GetOption("tooltip.numLines", true) )
	numItems:SetScript("OnValueChanged", function(self)
		Broker_Garbage:SetOption("tooltip.numLines", true, self:GetValue())
		numItemsText:SetText(BGC.locale.maxItemsTitle .. ": " .. self:GetValue())
	end)
	low:Hide(); high:Hide()

	local tooltipHeight, tooltipHeightText, container, low, high = LibStub("tekKonfig-Slider").new(tooltip,
		BGC.locale.maxHeightTitle .. ": " .. Broker_Garbage:GetOption("tooltip.height", true),
		0, 500, "TOPLEFT", numItems, "BOTTOMLEFT", 0, -2)
	tooltipHeight.tiptext = BGC.locale.maxHeightText .. BGC.locale.GlobalSetting
	tooltipHeight:SetWidth(150); container:SetWidth(160);
	tooltipHeightText:SetPoint("BOTTOMLEFT", tooltipHeight, "TOPLEFT", 2, 0)
	tooltipHeight:SetValueStep(10);
	tooltipHeight:SetValue( Broker_Garbage:GetOption("tooltip.height", true) )
	tooltipHeight:SetScript("OnValueChanged", function(self)
		Broker_Garbage:SetOption("tooltip.height", true, self:GetValue())
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
		Broker_Garbage.Scan()
	end
	local function SubmitEditBox(self)
		Broker_Garbage:SetOption(self.setting, true, self:GetText())
		self:SetText(Broker_Garbage:GetOption(self.setting, true))
		self:ClearFocus()
		Broker_Garbage.Scan()
	end
	local function ResetEditBoxDefault(self)
		local target = self:GetParent()
		Broker_Garbage.ResetOption(target.setting)

		local value = Broker_Garbage:GetOption(target.setting, true)
		target:SetText(value)
		target:ClearFocus()
		Broker_Garbage.Scan()
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
	local junkText = CreateFrame("EditBox", "BGCEditBoxJunk", tooltip, "InputBoxTemplate")
	junkText:SetPoint("TOPLEFT", LDBtitle, "BOTTOMLEFT", 2, 2)
	junkText:SetSize(140, 32)
	junkText:SetFontObject("GameFontHighlightSmall")
	junkText:SetAutoFocus(false)
	junkText:SetText( Broker_Garbage:GetOption("label", true) )
	junkText.tiptext = BGC.locale.LDBDisplayTextTooltip .. BGC.locale.GlobalSetting
	junkText.setting = "label"

	junkText:SetScript("OnEscapePressed", ResetEditBox)
	junkText:SetScript("OnEnterPressed", SubmitEditBox)
	junkText:SetScript("OnEnter", BGC.ShowTooltip)
	junkText:SetScript("OnLeave", BGC.HideTooltip)

	local editReset = CreateFrame("Button", nil, tooltip)
	editReset:SetParent(junkText)
	editReset:SetPoint("LEFT", junkText, "RIGHT", 4, 0)
	editReset:SetSize(16, 16)
	editReset:SetNormalTexture("Interface\\RAIDFRAME\\ReadyCheck-NotReady")
	editReset.tiptext = BGC.locale.ResetToDefault
	editReset:SetScript("OnEnter", BGC.ShowTooltip)
	editReset:SetScript("OnLeave", BGC.HideTooltip)
	editReset:SetScript("OnClick", ResetEditBoxDefault)

	-- LDB format string for "No Junk"
	local noJunkText = CreateFrame("EditBox", "BGCEditBoxNoJunk", tooltip, "InputBoxTemplate")
	noJunkText:SetPoint("TOPLEFT", junkText, "BOTTOMLEFT", 0, 12)
	noJunkText:SetAutoFocus(false)
	noJunkText:SetSize(140, 32)
	noJunkText:SetFontObject("GameFontHighlightSmall")
	noJunkText:SetText(  Broker_Garbage:GetOption("noJunkLabel", true))
	noJunkText.tiptext = BGC.locale.LDBNoJunkTextTooltip .. BGC.locale.GlobalSetting
	noJunkText.setting = "noJunkLabel"

	noJunkText:SetScript("OnEscapePressed", ResetEditBox)
	noJunkText:SetScript("OnEnterPressed", SubmitEditBox)
	noJunkText:SetScript("OnEnter", BGC.ShowTooltip)
	noJunkText:SetScript("OnLeave", BGC.HideTooltip)

	local editReset2 = CreateFrame("Button", nil, tooltip)
	editReset2:SetParent(noJunkText)
	editReset2:SetPoint("LEFT", noJunkText, "RIGHT", 4, 0)
	editReset2:SetSize(16, 16)
	editReset2:SetNormalTexture("Interface\\RAIDFRAME\\ReadyCheck-NotReady")
	editReset2.tiptext = BGC.locale.ResetToDefault
	editReset2:SetScript("OnEnter", BGC.ShowTooltip)
	editReset2:SetScript("OnLeave", BGC.HideTooltip)
	editReset2:SetScript("OnClick", ResetEditBoxDefault)

	-- ----------------------------------------------------------------------------------------------------

	local display = LibStub("tekKonfig-Group").new(panel, BGC.locale.GroupDisplay, "TOPLEFT", thresholds, "TOPRIGHT", 10, 0)
	display:SetSize(185, 150)
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
	itemTooltipLabel:SetChecked( Broker_Garbage:GetOption("itemTooltip.showClassification", true) )
	local checksound = itemTooltipLabel:GetScript("OnClick")
	itemTooltipLabel:SetScript("OnClick", function(self)
		checksound(self)
		Broker_Garbage:ToggleOption("itemTooltip.showClassification", true)
	end)

	local itemTooltipLabelReason = BGC.CreateCheckBox(panel, nil, BGC.locale.showItemTooltipDetailTitle, "TOPLEFT", itemTooltipLabel, "BOTTOMLEFT", 0, 4)
	itemTooltipLabelReason.tiptext = BGC.locale.showItemTooltipDetailText .. BGC.locale.GlobalSetting
	itemTooltipLabelReason:SetChecked( Broker_Garbage:GetOption("itemTooltip.showReason", true) )
	local checksound = itemTooltipLabelReason:GetScript("OnClick")
	itemTooltipLabelReason:SetScript("OnClick", function(self)
		checksound(self)
		Broker_Garbage:ToggleOption("itemTooltip.showReason", true)
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
	UIDropDownMenu_SetSelectedValue(moneyFormat, Broker_Garbage:GetOption("moneyFormat", true))
	UIDropDownMenu_SetText(moneyFormat, Broker_Garbage.FormatMoney(testValue))
	UIDropDownMenu_SetWidth(moneyFormat, 150, 0)
	UIDropDownMenu_JustifyText(moneyFormat, "LEFT")
	local function MoneyFormatOnSelect(self)
		UIDropDownMenu_SetSelectedValue(moneyFormat, self.value)
		Broker_Garbage:SetOption("moneyFormat", true, self.value)
		Broker_Garbage.Scan()
	end
	moneyFormat.initialize = function(self)
		local selected, info = UIDropDownMenu_GetSelectedValue(self), UIDropDownMenu_CreateInfo()
		for index = 0, 8 do
			info.text = Broker_Garbage.FormatMoney(testValue, index)
			info.value = index
			info.func = MoneyFormatOnSelect
			info.checked = (index == selected)
			UIDropDownMenu_AddButton(info)
		end
	end

	local hideZero = BGC.CreateCheckBox(display, nil, BGC.locale.hideZeroTitle, "TOPLEFT", moneyFormatLabel, "BOTTOMLEFT", -6, -30)
	hideZero.tiptext = BGC.locale.hideZeroTooltip .. BGC.locale.GlobalSetting
	hideZero:SetChecked( Broker_Garbage:GetOption("ignoreZeroValue", true) )
	local checksound = hideZero:GetScript("OnClick")
	hideZero:SetScript("OnClick", function(self)
		checksound(self)
		Broker_Garbage:ToggleOption("ignoreZeroValue", true)
		Broker_Garbage.Scan()
	end)

	local output = LibStub("tekKonfig-Group").new(panel, BGC.locale.GroupOutput, "TOPLEFT", display, "BOTTOMLEFT", 0, -14)
	output:SetSize(185, 108)
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
	reportDE:SetChecked( Broker_Garbage:GetOption("disenchantSuggestions", true) )
	local checksound = reportDE:GetScript("OnClick")
	reportDE:SetScript("OnClick", function(self)
		checksound(self)
		Broker_Garbage:ToggleOption("disenchantSuggestions", true)
	end)

	-- ------------------------------------------------------------------------
	local explainText = panel:CreateFontString(nil, 'ARTWORK', 'GameFontHighlightSmall')
	explainText:SetPoint('LEFT', panel, 'LEFT', 24, 0)
	explainText:SetPoint('RIGHT', panel, 'RIGHT', -24, 0)
	explainText:SetPoint('TOP', tooltip, 'BOTTOM', 0, -16)
	explainText:SetHeight(40)
	explainText:SetNonSpaceWrap(true)
	explainText:SetJustifyH('LEFT')
	explainText:SetJustifyV('TOP')
	explainText:SetText(BGC.locale.AuctionAddonsExplanation)
	panel.prioritiesExplain = explainText

	local buyoutHeading = panel:CreateFontString(nil, 'ARTWORK', 'GameFontNormalSmall')
	buyoutHeading:SetPoint('TOP', explainText, 'BOTTOMLEFT', 0.5*260, 0)
	buyoutHeading:SetText(BGC.locale.AuctionAddonsBuyout)

	local disenchantHeading = panel:CreateFontString(nil, 'ARTWORK', 'GameFontNormalSmall')
	disenchantHeading:SetPoint('TOP', explainText, 'BOTTOMLEFT', (1.5*260)+40, 0)
	disenchantHeading:SetText(BGC.locale.AuctionAddonsDisenchant)

	UpdateAuctionAddonList(panel)

	panel:SetScript("OnShow", function(self)
		junkText:SetText( Broker_Garbage:GetOption("label", true) )
		noJunkText:SetText( Broker_Garbage:GetOption("noJunkLabel", true) )

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

		UpdateAuctionAddonList(self)
	end)
end

-- In case the addon is loaded from another condition, always call the remove interface options
if AddonLoader and AddonLoader.RemoveInterfaceOptions then
	AddonLoader:RemoveInterfaceOptions("Broker_Garbage")
end

local frame = CreateFrame("Frame", nil, InterfaceOptionsFramePanelContainer)
frame.name = "Broker_Garbage"
frame:Hide()
frame:SetScript("OnShow", Options_BasicOptions)
InterfaceOptions_AddCategory(frame)
