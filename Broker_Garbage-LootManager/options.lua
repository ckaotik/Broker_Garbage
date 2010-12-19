local _, BGLM = ...

local function Options_LootManager(pluginID)
	local function Toggle(self)
		if not (self and self.stat) then return end

		local variable
		if self.global then
			if BGLM_GlobalDB[self.stat] ~= nil then
				BGLM_GlobalDB[self.stat] = not BGLM_GlobalDB[self.stat]
			end
		else
			variable = BGLM_LocalDB[self.stat]
			
			if BGLM_LocalDB[self.stat] ~= nil then
				BGLM_LocalDB[self.stat] = not BGLM_LocalDB[self.stat]
			end
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
	
	local looting = LibStub("tekKonfig-Group").new(panel, BGLM.locale.GroupLooting, "TOPLEFT", subtitle, "BOTTOMLEFT", 0, 5)--panel, 21, -16)
	looting:SetHeight(150); looting:SetWidth(180)
	looting:SetBackdropColor(0.1, 0.1, 0.1, 0.4)

	local autoLoot = LibStub("tekKonfig-Checkbox").new(looting, nil, BGLM.locale.LMAutoLootTitle, "TOPLEFT", 4, -2)
	autoLoot.tiptext = BGLM.locale.LMAutoLootTooltip .. BGLM.locale.GlobalSetting
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
	
	local forceClear = LibStub("tekKonfig-Checkbox").new(looting, nil, BGLM.locale.LMForceClearTitle, "TOPLEFT", closeLoot, "BOTTOMLEFT", 0, 4)
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
	
	local notices = LibStub("tekKonfig-Group").new(panel, BGLM.locale.GroupNotices, "TOPLEFT", looting, "TOPRIGHT", 10, 0)
	notices:SetHeight(160); notices:SetWidth(180)
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
	
	local inventory = LibStub("tekKonfig-Group").new(panel, BGLM.locale.GroupInventory, "TOPLEFT", looting, "BOTTOMLEFT", 0, -14)
	inventory:SetHeight(75); inventory:SetWidth(180)
	inventory:SetBackdropColor(0.1, 0.1, 0.1, 0.4)

	local restack = LibStub("tekKonfig-Checkbox").new(inventory, nil, BGLM.locale.LMRestackTitle, "TOPLEFT", 4, -2)
	restack.tiptext = BGLM.locale.LMRestackTooltip .. BGLM.locale.GlobalSetting
	restack.stat = "restackInventory"
	restack.global = true
	restack:SetChecked(BGLM_GlobalDB.restackInventory)
	restack:SetScript("OnClick", Toggle)

	local autoDestroy = LibStub("tekKonfig-Checkbox").new(inventory, nil, BGLM.locale.LMAutoDestroyTitle, "TOPLEFT", restack, "BOTTOMLEFT", 0, 4)
	autoDestroy.tiptext = BGLM.locale.LMAutoDestroyTooltip
	autoDestroy.stat = "autoDestroy"
	autoDestroy:SetChecked(BGLM_LocalDB.autoDestroy)
	autoDestroy:SetScript("OnClick", Toggle)

	local autoDestroyInstant = LibStub("tekKonfig-Checkbox").new(inventory, nil, BGLM.locale.LMAutoDestroyInstantTitle, "TOPLEFT", autoDestroy, "BOTTOMLEFT", 14, 4)
	autoDestroyInstant.tiptext = BGLM.locale.LMAutoDestroyInstantTooltip
	autoDestroyInstant.stat = "autoDestroyInstant"
	autoDestroyInstant:SetChecked(BGLM_LocalDB.autoDestroyInstant)
	autoDestroyInstant:SetScript("OnClick", Toggle)
	
	local treshold = LibStub("tekKonfig-Group").new(panel, BGLM.locale.GroupTreshold, "TOPLEFT", notices, "BOTTOMLEFT", 0, -14)
	treshold:SetHeight(90); treshold:SetWidth(180)
	treshold:SetBackdropColor(0.1, 0.1, 0.1, 0.4)

	local editbox = CreateFrame("EditBox", nil, treshold)
	editbox:SetPoint("TOPLEFT", 13, -16)
	editbox:SetAutoFocus(false)
	editbox:SetWidth(160); editbox:SetHeight(32)
	editbox:SetFontObject("GameFontHighlightSmall")
	editbox:SetJustifyH("CENTER")
	editbox:SetText(Broker_Garbage:FormatMoney(BGLM_LocalDB.itemMinValue))
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
		self:SetText(Broker_Garbage:FormatMoney(BGLM_LocalDB.itemMinValue))
		self:ClearFocus()
	end
	local function UnFormatEditBox(self)
		self:SetText(BGLM_LocalDB.itemMinValue)
	end
	local function SubmitEditBox()
		BGLM_LocalDB.itemMinValue = tonumber(editbox:GetText())
		editbox:SetText(Broker_Garbage:FormatMoney(BGLM_LocalDB.itemMinValue))
		editbox:ClearFocus()
	end
	editbox:SetScript("OnEscapePressed", ResetEditBox)
	editbox:SetScript("OnEnterPressed", SubmitEditBox)
	editbox:SetScript("OnEditFocusGained", UnFormatEditBox)

	local minFreeSlots, minFreeSlotsText, _, low, high = LibStub("tekKonfig-Slider").new(treshold, BGLM.locale.LMFreeSlotsTitle .. ": " .. BGLM_GlobalDB.tooFewSlots, 0, 30, "TOPLEFT", editbox, "BOTTOMLEFT", 6, -8)
	minFreeSlots.tiptext = BGLM.locale.LMFreeSlotsTooltip .. BGLM.locale.GlobalSetting
	minFreeSlots:SetWidth(160)
	minFreeSlots:SetValueStep(1)
	minFreeSlots:SetValue(BGLM_GlobalDB.tooFewSlots)
	minFreeSlots:SetScript("OnValueChanged", function(minFreeSlots)
		BGLM_GlobalDB.tooFewSlots = minFreeSlots:GetValue()
		minFreeSlotsText:SetText(BGLM.locale.LMFreeSlotsTitle .. ": " .. BGLM_GlobalDB.tooFewSlots)
		Broker_Garbage:ScanInventory()
	end)
	low:Hide(); high:Hide()
	
	function panel:Update()
		editbox:SetText(Broker_Garbage:FormatMoney(BGLM_LocalDB.itemMinValue))
		
		local min, max = minFreeSlots:GetMinMaxValues()
		if BGLM_GlobalDB.tooFewSlots > min and BGLM_GlobalDB.tooFewSlots < max then
			minFreeSlots:SetValue(BGLM_GlobalDB.tooFewSlots)
		end
		minFreeSlotsText:SetText(BGLM.locale.LMFreeSlotsTitle .. ": " .. BGLM_GlobalDB.tooFewSlots)
	end
end
BGLM.options = panel

local _ = Broker_Garbage:RegisterPlugin(BGLM.locale.LMTitle, Options_LootManager)