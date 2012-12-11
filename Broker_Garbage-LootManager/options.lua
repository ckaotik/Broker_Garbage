local _, BGLM = ...

-- GLOBALS: BGLM_GlobalDB, BGLM_LocalDB, Broker_Garbage, Broker_Garbage_Config, LibStub, _G
-- GLOBALS: GetCVarBool, UIDropDownMenu_GetSelectedValue, UIDropDownMenu_CreateInfo, UIDropDownMenu_AddButton, UIDropDownMenu_SetText, UIDropDownMenu_SetWidth, UIDropDownMenu_JustifyText, UIDropDownMenu_SetSelectedValue, CreateFrame
local tonumber = tonumber

local function Options_LootManager(pluginID)
	local function Toggle(self)
		if not (self and self.stat) then return end

		if self.global then
			BGLM_GlobalDB[self.stat] = not BGLM_GlobalDB[self.stat]
		else
			BGLM_LocalDB[self.stat] = not BGLM_LocalDB[self.stat]
		end
	end

	local panel, tab = Broker_Garbage_Config:CreateOptionsTab(pluginID)

	local subtitle = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	subtitle:SetPoint("TOPLEFT", 16, -16)
	subtitle:SetPoint("RIGHT", panel, -16, 0)
	subtitle:SetHeight(50)
	subtitle:SetNonSpaceWrap(true)
	subtitle:SetJustifyH("LEFT")
	subtitle:SetJustifyV("TOP")
	subtitle:SetText(BGLM.locale.LMSubTitle)

	--[[ Looting Group ]]--
	local looting = LibStub("tekKonfig-Group").new(panel, BGLM.locale.GroupLooting, "TOPLEFT", subtitle, "BOTTOMLEFT", 0, 5)
	looting:SetHeight(230); looting:SetWidth(180)
	looting:SetBackdropColor(0.1, 0.1, 0.1, 0.4)

	local autoLootTitle = BGLM.locale.LMAutoLootTitle
	local autoLootTooltip = BGLM.locale.LMAutoLootTooltip
	if GetCVarBool("autoLootDefault") then
		autoLootTitle = autoLootTitle .. "|TInterface\\OptionsFrame\\UI-OptionsFrame-NewFeatureIcon:0:0:0:-1|t"
		autoLootTooltip = autoLootTooltip .. BGLM.locale.disableBlizzAutoLoot
	end

	local autoLoot, autoLootLabel = LibStub("tekKonfig-Checkbox").new(looting, nil, autoLootTitle, "TOPLEFT", 4, -2)
	autoLoot.tiptext = autoLootTooltip .. BGLM.locale.GlobalSetting
	autoLoot.stat = "autoLoot"
	autoLoot.global = true
	autoLoot:SetChecked(BGLM_GlobalDB.autoLoot)
	autoLoot:SetScript("OnClick", Toggle)

	local iconSize = 26
	local skinning = CreateFrame("CheckButton", nil, looting)
	skinning:SetPoint("TOPLEFT", autoLoot, "BOTTOMRIGHT", 14, 2)
	skinning:SetWidth(iconSize); skinning:SetHeight(iconSize)
	skinning:SetChecked(BGLM_GlobalDB.autoLootSkinning)
	skinning.tiptext = BGLM.locale.LMAutoLootSkinningTooltip .. BGLM.locale.GlobalSetting
	skinning.stat = "autoLootSkinning"
	skinning.global = true
	skinning:SetNormalTexture("Interface\\Icons\\inv_misc_pelt_wolf_01")
	skinning:SetPushedTexture("Interface\\Buttons\\UI-Quickslot-Depress")
	skinning:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square")
	skinning:SetCheckedTexture("Interface\\Buttons\\CheckButtonHilight")
	skinning:SetScript("OnClick", Toggle)
	skinning:SetScript("OnEnter", BGLM.ShowTooltip)
	skinning:SetScript("OnLeave", BGLM.HideTooltip)

	local fishing = CreateFrame("CheckButton", nil, looting)
	fishing:SetPoint("TOPLEFT", skinning, "TOPRIGHT", 2, 0)
	fishing:SetWidth(iconSize); fishing:SetHeight(iconSize)
	fishing:SetChecked(BGLM_GlobalDB.autoLootFishing)
	fishing.tiptext = BGLM.locale.LMAutoLootFishingTooltip .. BGLM.locale.GlobalSetting
	fishing.stat = "autoLootFishing"
	fishing.global = true
	fishing:SetNormalTexture("Interface\\Icons\\Trade_Fishing")
	fishing:SetPushedTexture("Interface\\Buttons\\UI-Quickslot-Depress")
	fishing:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square")
	fishing:SetCheckedTexture("Interface\\Buttons\\CheckButtonHilight")
	fishing:SetScript("OnClick", Toggle)
	fishing:SetScript("OnEnter", BGLM.ShowTooltip)
	fishing:SetScript("OnLeave", BGLM.HideTooltip)

	local stealing = CreateFrame("CheckButton", nil, looting)
	stealing:SetPoint("TOPLEFT", fishing, "TOPRIGHT", 2, 0)
	stealing:SetWidth(iconSize); stealing:SetHeight(iconSize)
	stealing:SetChecked(BGLM_GlobalDB.autoLootPickpocket)
	stealing.tiptext = BGLM.locale.LMAutoLootPickpocketTooltip .. BGLM.locale.GlobalSetting
	stealing.stat = "autoLootPickpocket"
	stealing.global = true
	stealing:SetNormalTexture("Interface\\Icons\\INV_Misc_Bag_11")
	stealing:SetPushedTexture("Interface\\Buttons\\UI-Quickslot-Depress")
	stealing:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square")
	stealing:SetCheckedTexture("Interface\\Buttons\\CheckButtonHilight")
	stealing:SetScript("OnClick", Toggle)
	stealing:SetScript("OnEnter", BGLM.ShowTooltip)
	stealing:SetScript("OnLeave", BGLM.HideTooltip)

	-- -----------------------------------------------------------------
	local line = Broker_Garbage_Config.CreateHorizontalRule(looting)
	line:SetPoint("TOPLEFT", autoLoot, "BOTTOMLEFT", 2, -24)
	line:SetPoint("RIGHT", -6, 2)
	-- -----------------------------------------------------------------

	local inCombat = LibStub("tekKonfig-Checkbox").new(looting, nil, BGLM.locale.LMEnableInCombatTitle, "TOPLEFT", autoLoot, "BOTTOMLEFT", 0, -30)
	inCombat.tiptext = BGLM.locale.LMEnableInCombatTooltip .. BGLM.locale.GlobalSetting
	inCombat.stat = "useInCombat"
	inCombat.global = true
	inCombat:SetChecked(BGLM_GlobalDB.useInCombat)
	inCombat:SetScript("OnClick", Toggle)

	local closeLoot = LibStub("tekKonfig-Checkbox").new(looting, nil, BGLM.locale.LMCloseLootTitle, "TOPLEFT", inCombat, "BOTTOMLEFT", 0, 4)
	closeLoot.tiptext = BGLM.locale.LMCloseLootTooltip .. BGLM.locale.GlobalSetting
	closeLoot.stat = "closeLootWindow"
	closeLoot.global = true
	closeLoot:SetChecked(BGLM_GlobalDB.closeLootWindow)
	closeLoot:SetScript("OnClick", Toggle)

	local keepPLOpen = LibStub("tekKonfig-Checkbox").new(looting, nil, BGLM.locale.LMKeepPLOpenTitle, "TOPLEFT", closeLoot, "BOTTOMLEFT", 14, 4)
	keepPLOpen.tiptext = BGLM.locale.LMKeepPLOpenTooltip .. BGLM.locale.GlobalSetting
	keepPLOpen.stat = "keepPrivateLootOpen"
	keepPLOpen.global = true
	keepPLOpen:SetChecked(BGLM_GlobalDB.keepPrivateLootOpen)
	keepPLOpen:SetScript("OnClick", Toggle)

	local forceClear = LibStub("tekKonfig-Checkbox").new(looting, nil, BGLM.locale.LMForceClearTitle, "TOPLEFT", keepPLOpen, "BOTTOMLEFT", -14, 4)
	forceClear.tiptext = BGLM.locale.LMForceClearTooltip .. BGLM.locale.GlobalSetting
	forceClear.stat = "forceClear"
	forceClear.global = true
	forceClear:SetChecked(BGLM_GlobalDB.forceClear)
	forceClear:SetScript("OnClick", Toggle)

	local autoAcceptLoot = LibStub("tekKonfig-Checkbox").new(looting, nil, BGLM.locale.LMAutoAcceptLootTitle, "TOPLEFT", forceClear, "BOTTOMLEFT", 0, 4)
	autoAcceptLoot.tiptext =  BGLM.locale.LMAutoAcceptLootTooltip .. BGLM.locale.GlobalSetting
	autoAcceptLoot.stat = "autoConfirmBoP"
	autoAcceptLoot.global = true
	autoAcceptLoot:SetChecked(BGLM_GlobalDB.autoConfirmBoP)
	autoAcceptLoot:SetScript("OnClick", Toggle)

	-- -----------------------------------------------------------------
	local line2 = Broker_Garbage_Config.CreateHorizontalRule(looting)
	line2:SetPoint("TOPLEFT", autoAcceptLoot, "BOTTOMLEFT", 2, 0)
	line2:SetPoint("RIGHT", -6, 2)
	-- -----------------------------------------------------------------

	local lootJunk = LibStub("tekKonfig-Checkbox").new(looting, nil, BGLM.locale.lootJunkTitle, "TOPLEFT", autoAcceptLoot, "BOTTOMLEFT", 0, -8)
	lootJunk.tiptext = BGLM.locale.lootJunkTooltip .. BGLM.locale.GlobalSetting
	lootJunk.stat = "lootIncludeItems"
	lootJunk.global = true
	lootJunk:SetChecked(BGLM_GlobalDB.lootIncludeItems)
	lootJunk:SetScript("OnClick", Toggle)

	local lootKeep = LibStub("tekKonfig-Checkbox").new(looting, nil, BGLM.locale.lootKeepTitle, "TOPLEFT", lootJunk, "BOTTOMLEFT", 0, 4)
	lootKeep.tiptext = BGLM.locale.lootKeepTooltip .. BGLM.locale.GlobalSetting
	lootKeep.stat = "lootExcludeItems"
	lootKeep.global = true
	lootKeep:SetChecked(BGLM_GlobalDB.lootExcludeItems)
	lootKeep:SetScript("OnClick", Toggle)

	--[[ Inventory Group ]]--
	local inventory = LibStub("tekKonfig-Group").new(panel, BGLM.locale.GroupInventory, "TOPLEFT", looting, "TOPRIGHT", 10, 0)
	inventory:SetHeight(88); inventory:SetWidth(180)
	inventory:SetBackdropColor(0.1, 0.1, 0.1, 0.4)

	local autoDestroy = LibStub("tekKonfig-Checkbox").new(inventory, nil, BGLM.locale.LMAutoDestroyTitle, "TOPLEFT", 4, -2)
	autoDestroy.tiptext = BGLM.locale.LMAutoDestroyTooltip
	autoDestroy.stat = "autoDestroy"
	autoDestroy:SetChecked(BGLM_LocalDB.autoDestroy)
	autoDestroy:SetScript("OnClick", Toggle)

	local autoDestroyInstant = LibStub("tekKonfig-Checkbox").new(inventory, nil, BGLM.locale.LMAutoDestroyInstantTitle, "TOPLEFT", autoDestroy, "BOTTOMLEFT", 14, 4)
	autoDestroyInstant.tiptext = BGLM.locale.LMAutoDestroyInstantTooltip
	autoDestroyInstant.stat = "autoDestroyInstant"
	autoDestroyInstant:SetChecked(BGLM_LocalDB.autoDestroyInstant)
	autoDestroyInstant:SetScript("OnClick", Toggle)

	local minFreeSlots, minFreeSlotsText, _, low, high = LibStub("tekKonfig-Slider").new(inventory, BGLM.locale.LMFreeSlotsTitle .. ": " .. BGLM_GlobalDB.tooFewSlots, 0, 30, "TOPLEFT", autoDestroyInstant, "BOTTOMLEFT", 0, -4)
	minFreeSlots.tiptext = BGLM.locale.LMFreeSlotsTooltip .. BGLM.locale.GlobalSetting
	minFreeSlots:SetWidth(160)
	minFreeSlots:SetValueStep(1)
	minFreeSlots:SetValue(BGLM_GlobalDB.tooFewSlots)
	minFreeSlots:SetScript("OnValueChanged", function(minFreeSlots)
		BGLM_GlobalDB.tooFewSlots = minFreeSlots:GetValue()
		minFreeSlotsText:SetText(BGLM.locale.LMFreeSlotsTitle .. ": " .. BGLM_GlobalDB.tooFewSlots)
		Broker_Garbage.ScanInventory()
	end)
	low:Hide(); high:Hide()

	--[[ Thresholds Group ]]--
	local threshold = LibStub("tekKonfig-Group").new(panel, BGLM.locale.GroupThreshold, "TOPLEFT", inventory, "BOTTOMLEFT", 0, -14)
	threshold:SetHeight(94); threshold:SetWidth(180)
	threshold:SetBackdropColor(0.1, 0.1, 0.1, 0.4)

	local editbox = CreateFrame("EditBox", nil, threshold)
	editbox:SetPoint("TOPLEFT", 13, -16)
	editbox:SetAutoFocus(false)
	editbox:SetWidth(160); editbox:SetHeight(32)
	editbox:SetFontObject("GameFontHighlightSmall")
	editbox:SetJustifyH("CENTER")
	editbox:SetText(Broker_Garbage.FormatMoney(BGLM_LocalDB.itemMinValue))
	local left = editbox:CreateTexture(nil, "BACKGROUND")
	left:SetWidth(8) left:SetHeight(20)
	left:SetPoint("LEFT", -5, 0)
	left:SetTexture("Interface\\Common\\Common-Input-Border")
	left:SetTexCoord(0, 0.0625, 0, 0.625)
	local right = editbox:CreateTexture(nil, "BACKGROUND")
	right:SetWidth(8) right:SetHeight(20)
	right:SetPoint("RIGHT", 0, 0)
	right:SetTexture("Interface\\Common\\Common-Input-Border")
	right:SetTexCoord(0.9375, 1, 0, 0.625)
	local center = editbox:CreateTexture(nil, "BACKGROUND")
	center:SetHeight(20)
	center:SetPoint("RIGHT", right, "LEFT", 0, 0)
	center:SetPoint("LEFT", left, "RIGHT", 0, 0)
	center:SetTexture("Interface\\Common\\Common-Input-Border")
	center:SetTexCoord(0.0625, 0.9375, 0, 0.625)

	local minValueLabel = editbox:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	minValueLabel:SetPoint("BOTTOM", editbox, "TOP", 0, -4)
	minValueLabel:SetText(BGLM.locale.LMItemMinValue)

	local function ResetEditBox(self)
		self:SetText(Broker_Garbage.FormatMoney(BGLM_LocalDB.itemMinValue))
		self:ClearFocus()
	end
	local function UnFormatEditBox(self)
		self:SetText(BGLM_LocalDB.itemMinValue)
	end
	local function SubmitEditBox()
		BGLM_LocalDB.itemMinValue = tonumber(editbox:GetText())
		editbox:SetText(Broker_Garbage.FormatMoney(BGLM_LocalDB.itemMinValue))
		editbox:ClearFocus()
	end
	editbox:SetScript("OnEscapePressed", ResetEditBox)
	editbox:SetScript("OnEnterPressed", SubmitEditBox)
	editbox:SetScript("OnEditFocusGained", UnFormatEditBox)

	local qualitythreshold = CreateFrame("Frame", "BGLM_LootQualityDropDown", threshold, "UIDropDownMenuTemplate")
	qualitythreshold.displayMode = "MENU"
	qualitythreshold:SetPoint("TOPLEFT", editbox, "BOTTOMLEFT", -23, -12)
	_G[qualitythreshold:GetName() .. "Button"]:SetPoint("LEFT", _G[qualitythreshold:GetName().."Middle"])
	_G[qualitythreshold:GetName() .. "Button"].tiptext = BGLM.locale.minLootQualityTooltip
	_G[qualitythreshold:GetName() .. "Button"]:SetScript("OnEnter", BGLM.ShowTooltip)
	_G[qualitythreshold:GetName() .. "Button"]:SetScript("OnLeave", BGLM.HideTooltip)

	local qualitythresholdLabel = qualitythreshold:CreateFontString(nil, "BACKGROUND", "GameFontNormalSmall")
	qualitythresholdLabel:SetPoint("BOTTOMLEFT", qualitythreshold, "TOPLEFT", 20, 2)
	qualitythresholdLabel:SetText(BGLM.locale.minLootQualityTitle)
	UIDropDownMenu_SetSelectedValue(qualitythreshold, BGLM_LocalDB.minItemQuality )
	UIDropDownMenu_SetText(qualitythreshold, Broker_Garbage_Config.quality[ BGLM_LocalDB.minItemQuality ])
	UIDropDownMenu_SetWidth(qualitythreshold, 150, 0)
	UIDropDownMenu_JustifyText(qualitythreshold, "LEFT")
	local function DropQualityOnSelect(self)
		UIDropDownMenu_SetSelectedValue(qualitythreshold, self.value)
		BGLM_LocalDB.minItemQuality = self.value
	end
	qualitythreshold.initialize = function(self)
		local selected, info = UIDropDownMenu_GetSelectedValue(self), UIDropDownMenu_CreateInfo()
		for i = 0, #Broker_Garbage_Config.quality do
			info.text = Broker_Garbage_Config.quality[i]
			info.value = i
			info.func = DropQualityOnSelect
			info.checked = i == selected
			UIDropDownMenu_AddButton(info)
		end
	end

	--[[ Notices Group ]]--
	local notices = LibStub("tekKonfig-Group").new(panel, BGLM.locale.GroupNotices, "TOPLEFT", inventory, "TOPRIGHT", 10, 0)
	notices:SetHeight(185); notices:SetWidth(180)
	notices:SetBackdropColor(0.1, 0.1, 0.1, 0.4)

	local warnLM = LibStub("tekKonfig-Checkbox").new(notices, nil, BGLM.locale.LMWarnLMTitle, "TOPLEFT", 4, -2)
	warnLM.tiptext = BGLM.locale.LMWarnLMTooltip .. BGLM.locale.GlobalSetting
	warnLM.stat = "warnLM"
	warnLM.global = true
	warnLM:SetChecked(BGLM_GlobalDB.warnLM)
	warnLM:SetScript("OnClick", Toggle)

	local inventoryFull = LibStub("tekKonfig-Checkbox").new(notices, nil, BGLM.locale.LMWarnInventoryFullTitle, "TOPLEFT", warnLM, "BOTTOMLEFT", 0, 4)
	inventoryFull.tiptext = BGLM.locale.LMWarnInventoryFullTooltip .. BGLM.locale.GlobalSetting
	inventoryFull.stat = "warnInvFull"
	inventoryFull.global = true
	inventoryFull:SetChecked(BGLM_GlobalDB.warnInvFull)
	inventoryFull:SetScript("OnClick", Toggle)

	local printSpace = LibStub("tekKonfig-Checkbox").new(notices, nil, BGLM.locale.printSpaceTitle, "TOPLEFT", inventoryFull, "BOTTOMLEFT", 0, 4)
	printSpace.tiptext = BGLM.locale.printSpaceText .. BGLM.locale.GlobalSetting
	printSpace.stat = "printSpace"
	printSpace.global = true
	printSpace:SetChecked(BGLM_GlobalDB.printSpace)
	printSpace:SetScript("OnClick", Toggle)

	local printValue = LibStub("tekKonfig-Checkbox").new(notices, nil, BGLM.locale.printValueTitle, "TOPLEFT", printSpace, "BOTTOMLEFT", 0, 4)
	printValue.tiptext = BGLM.locale.printValueText .. BGLM.locale.GlobalSetting
	printValue.stat = "printValue"
	printValue.global = true
	printValue:SetChecked(BGLM_GlobalDB.printValue)
	printValue:SetScript("OnClick", Toggle)

	local printCompareValue = LibStub("tekKonfig-Checkbox").new(notices, nil, BGLM.locale.printCompareValueTitle, "TOPLEFT", printValue, "BOTTOMLEFT", 0, 4)
	printCompareValue.tiptext = BGLM.locale.printCompareValueText .. BGLM.locale.GlobalSetting
	printCompareValue.stat = "printCompareValue"
	printCompareValue.global = true
	printCompareValue:SetChecked(BGLM_GlobalDB.printCompareValue)
	printCompareValue:SetScript("OnClick", Toggle)

	local printLocked = LibStub("tekKonfig-Checkbox").new(notices, nil, BGLM.locale.printLockedTitle, "TOPLEFT", printCompareValue, "BOTTOMLEFT", 0, 4)
	printLocked.tiptext = BGLM.locale.printLockedText .. BGLM.locale.GlobalSetting
	printLocked.stat = "printLocked"
	printLocked.global = true
	printLocked:SetChecked(BGLM_GlobalDB.printLocked)
	printLocked:SetScript("OnClick", Toggle)

	local printJunk = LibStub("tekKonfig-Checkbox").new(notices, nil, BGLM.locale.printJunkTitle, "TOPLEFT", printLocked, "BOTTOMLEFT", 0, 4)
	printJunk.tiptext = BGLM.locale.printJunkText .. BGLM.locale.GlobalSetting
	printJunk.stat = "printJunk"
	printJunk.global = true
	printJunk:SetChecked(BGLM_GlobalDB.printValue)
	printJunk:SetScript("OnClick", Toggle)

	local debug = LibStub("tekKonfig-Checkbox").new(notices, nil, BGLM.locale.printDebugTitle, "TOPLEFT", printJunk, "BOTTOMLEFT", 0, 4)
	debug.tiptext = BGLM.locale.printDebugTooltip
	debug.global = true
	debug.stat = "debug"
	debug:SetChecked(BGLM_GlobalDB.debug)
	debug:SetScript("OnClick", Toggle)

	--[[ Panel Management ]]--
	function panel:Update()
		editbox:SetText(Broker_Garbage.FormatMoney(BGLM_LocalDB.itemMinValue))

		local min, max = minFreeSlots:GetMinMaxValues()
		if BGLM_GlobalDB.tooFewSlots > min and BGLM_GlobalDB.tooFewSlots < max then
			minFreeSlots:SetValue(BGLM_GlobalDB.tooFewSlots)
		end
		minFreeSlotsText:SetText(BGLM.locale.LMFreeSlotsTitle .. ": " .. BGLM_GlobalDB.tooFewSlots)

		local autoLootTitle = BGLM.locale.LMAutoLootTitle
		local autoLootTooltip = BGLM.locale.LMAutoLootTooltip
		if GetCVarBool("autoLootDefault") then
			autoLootTitle = autoLootTitle .. "|TInterface\\OptionsFrame\\UI-OptionsFrame-NewFeatureIcon:0:0:0:-1|t"
			autoLootTooltip = autoLootTooltip .. BGLM.locale.disableBlizzAutoLoot
		end
		autoLootLabel:SetText(autoLootTitle)
		autoLoot.tiptext = autoLootTooltip .. BGLM.locale.GlobalSetting
	end
end
BGLM.options = panel

local _ = Broker_Garbage:RegisterPlugin(BGLM.locale.LMTitle, Options_LootManager)
