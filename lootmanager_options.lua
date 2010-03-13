_, BrokerGarbage = ...

BrokerGarbage:CheckSettings()

local function Update(self)
	BrokerGarbage:lootManagerOptionsUpdate(self)
end

local function ShowOptions(frame)
	local title = LibStub("tekKonfig-Heading").new(BrokerGarbage.lootManagerOptions, "Broker_Garbage - " .. BrokerGarbage.locale.LMTitle)
	
	local subtitle = BrokerGarbage.lootManagerOptions:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
	subtitle:SetPoint("RIGHT", BrokerGarbage.lootManagerOptions, -32, 0)
	subtitle:SetHeight(45)
	subtitle:SetNonSpaceWrap(true)
	subtitle:SetJustifyH("LEFT")
	subtitle:SetJustifyV("TOP")
	subtitle:SetText(BrokerGarbage.locale.LMSubTitle)
	
	local enable = LibStub("tekKonfig-Checkbox").new(BrokerGarbage.lootManagerOptions, nil, BrokerGarbage.locale.LMEnableTitle, "TOPLEFT", subtitle, "BOTTOMLEFT", -2, -4)
	enable.tiptext = BrokerGarbage.locale.LMEnableTooltip
	enable:SetChecked(BG_GlobalDB.useLootManager)
	local checksound = enable:GetScript("OnClick")
	enable:SetScript("OnClick", function(enable)
		checksound(enable)
		BG_GlobalDB.useLootManager = not BG_GlobalDB.useLootManager
		Update()
	end)
	
	-- -- Selective Looting -------------------------------------------------------
	local selective = LibStub("tekKonfig-Checkbox").new(BrokerGarbage.lootManagerOptions, nil, BrokerGarbage.locale.LMSelectiveTitle, "TOPLEFT", enable, "BOTTOMLEFT", 14, -20)
	selective.tiptext = BrokerGarbage.locale.LMSelectiveTooltip
	selective:SetChecked(BG_LocalDB.selectiveLooting)
	selective:SetScript("OnClick", function(selective)
		checksound(selective)
		BG_LocalDB.selectiveLooting = not BG_LocalDB.selectiveLooting
		Update()
	end)
	
	
	local autoLoot = LibStub("tekKonfig-Checkbox").new(BrokerGarbage.lootManagerOptions, nil, BrokerGarbage.locale.LMAutoLootTitle, "TOPLEFT", selective, "BOTTOMLEFT", 14, 0)
	autoLoot.tiptext = BrokerGarbage.locale.LMAutoLootTooltip
	autoLoot:SetChecked(BG_GlobalDB.autoLoot)
	autoLoot:SetScript("OnClick", function(autoLoot)
		checksound(autoLoot)
		BG_GlobalDB.autoLoot = not BG_GlobalDB.autoLoot
		Update()
	end)
	
	local autoLoot_skinning = LibStub("tekKonfig-Checkbox").new(BrokerGarbage.lootManagerOptions, nil, BrokerGarbage.locale.LMAutoLootSkinningTitle, "TOPLEFT", autoLoot, "BOTTOMLEFT", 14, 0)
	autoLoot_skinning.tiptext = BrokerGarbage.locale.LMAutoLootSkinningTooltip
	autoLoot_skinning:SetChecked(BG_GlobalDB.autoLootSkinning)
	autoLoot_skinning:SetScript("OnClick", function(autoLoot_skinning)
		checksound(autoLoot_skinning)
		BG_GlobalDB.autoLootSkinning = not BG_GlobalDB.autoLootSkinning
	end)
	
	local autoLoot_pickpocket = LibStub("tekKonfig-Checkbox").new(BrokerGarbage.lootManagerOptions, nil, BrokerGarbage.locale.LMAutoLootPickpocketTitle, "TOPLEFT", autoLoot_skinning, "BOTTOMLEFT", 0, 0)
	autoLoot_pickpocket.tiptext = BrokerGarbage.locale.LMAutoLootPickpocketTooltip
	autoLoot_pickpocket:SetChecked(BG_GlobalDB.autoLootPickpocket)
	autoLoot_pickpocket:SetScript("OnClick", function(autoLoot_pickpocket)
		checksound(autoLoot_pickpocket)
		BG_GlobalDB.autoLootPickpocket = not BG_GlobalDB.autoLootPickpocket
	end)
	
	local autoLoot_fishing = LibStub("tekKonfig-Checkbox").new(BrokerGarbage.lootManagerOptions, nil, BrokerGarbage.locale.LMAutoLootFishingTitle, "TOPLEFT", autoLoot_pickpocket, "BOTTOMLEFT", 0, 0)
	autoLoot_fishing.tiptext = BrokerGarbage.locale.LMAutoLootFishingTooltip
	autoLoot_fishing:SetChecked(BG_GlobalDB.autoLootPickpocket)
	autoLoot_fishing:SetScript("OnClick", function(autoLoot_fishing)
		checksound(autoLoot_fishing)
		BG_GlobalDB.autoLootFishing = not BG_GlobalDB.autoLootFishing
	end)
	
	
	local autoDestroy = LibStub("tekKonfig-Checkbox").new(BrokerGarbage.lootManagerOptions, nil, BrokerGarbage.locale.LMAutoDestroyTitle, "TOPLEFT", autoLoot_fishing, "BOTTOMLEFT", -14, 0)
	autoDestroy.tiptext = BrokerGarbage.locale.LMAutoDestroyTooltip
	autoDestroy:SetChecked(BG_GlobalDB.autoDestroy)
	autoDestroy:SetScript("OnClick", function(autoDestroy)
		checksound(autoDestroy)
		BG_GlobalDB.autoDestroy = not BG_GlobalDB.autoDestroy
		Update()
	end)
	
	local minFreeSlots = LibStub("tekKonfig-Slider").new(BrokerGarbage.lootManagerOptions, BrokerGarbage.locale.LMFreeSlotsTitle, 0, 30, "TOPLEFT", autoDestroy, "BOTTOMLEFT", 0, -20)
	minFreeSlots.tiptext = BrokerGarbage.locale.LMFreeSlotsTooltip
	minFreeSlots:SetWidth(200)
	minFreeSlots:SetValueStep(1)
	minFreeSlots:SetValue(BG_GlobalDB.tooFewSlots)
	minFreeSlots.text = minFreeSlots:CreateFontString("$parentCenterText", "ARTWORK", "GameFontHighlightSmall")
	minFreeSlots.text:SetPoint("TOP", minFreeSlots, "BOTTOM", 0, 3)
	minFreeSlots.text:SetText(BG_GlobalDB.tooFewSlots)
	minFreeSlots:SetScript("OnValueChanged", function(minFreeSlots)
		BG_GlobalDB.tooFewSlots = minFreeSlots:GetValue()
		minFreeSlots.text:SetText(BG_GlobalDB.tooFewSlots)
		BrokerGarbage:ScanInventory()
	end)
	
	
	-- -- Restack -----------------------------------------------------------------
	local restack = LibStub("tekKonfig-Checkbox").new(BrokerGarbage.lootManagerOptions, nil, BrokerGarbage.locale.LMRestackTitle, "TOPLEFT", selective, "TOPLEFT", 200, 0)
	restack.tiptext = BrokerGarbage.locale.LMRestackTooltip
	restack:SetChecked(BG_GlobalDB.restackIfNeeded)
	restack:SetScript("OnClick", function(restack)
		checksound(restack)
		BG_GlobalDB.restackIfNeeded = not BG_GlobalDB.restackIfNeeded
		Update()
	end)
	
	local fullRestack = LibStub("tekKonfig-Checkbox").new(BrokerGarbage.lootManagerOptions, nil, BrokerGarbage.locale.LMFullRestackTitle, "TOPLEFT", restack, "BOTTOMLEFT", 14, 0)
	fullRestack.tiptext = BrokerGarbage.locale.LMFullRestackTooltip
	fullRestack:SetChecked(BG_GlobalDB.restackFullInventory)
	fullRestack:SetScript("OnClick", function(fullRestack)
		checksound(fullRestack)
		BG_GlobalDB.restackFullInventory = not BG_GlobalDB.restackFullInventory
	end)
	
	-- -- Opening Items -----------------------------------------------------------
	local openContainers = LibStub("tekKonfig-Checkbox").new(BrokerGarbage.lootManagerOptions, nil, BrokerGarbage.locale.LMOpenContainersTitle, "TOPLEFT", fullRestack, "BOTTOMLEFT", -14, -10)
	openContainers.tiptext = BrokerGarbage.locale.LMOpenContainersTooltip
	openContainers:SetChecked(BG_GlobalDB.openContainers)
	openContainers:SetScript("OnClick", function(openContainers)
		checksound(openContainers)
		BG_GlobalDB.openContainers = not BG_GlobalDB.openContainers
	end)
	
	local openClams = LibStub("tekKonfig-Checkbox").new(BrokerGarbage.lootManagerOptions, nil, BrokerGarbage.locale.LMOpenClamsTitle, "TOPLEFT", openContainers, "BOTTOMLEFT", 0, 0)
	openClams.tiptext = BrokerGarbage.locale.LMOpenClamsTooltip
	openClams:SetChecked(BG_GlobalDB.openClams)
	openClams:SetScript("OnClick", function(openClams)
		checksound(openClams)
		BG_GlobalDB.openClams = not BG_GlobalDB.openClams
	end)
	
	
	-- -- Loot Treshold -----------------------------------------------------------
	local editbox = CreateFrame("EditBox", nil, BrokerGarbage.lootManagerOptions)
	editbox:SetAutoFocus(false)
	editbox:SetWidth(100); editbox:SetHeight(32)
	editbox:SetFontObject("GameFontHighlightSmall")
	editbox:SetText(BrokerGarbage:FormatMoney(BG_LocalDB.itemMinValue))
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

	local minvalue = editbox:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
	minvalue:SetPoint("TOPLEFT", openClams, "BOTTOMLEFT", 0, -10)
	minvalue:SetText(BrokerGarbage.locale.LMItemMinValue)
	editbox:SetPoint("TOP", minvalue, "BOTTOM", 0, 0)
	local function ResetEditBox(self)
		self:SetText(BrokerGarbage:FormatMoney(BG_LocalDB.itemMinValue))
		self:ClearFocus()
	end
	local function UnFormatEditBox(self)
		self:SetText(BG_LocalDB.itemMinValue)
	end
	local function SubmitEditBox()
		BG_LocalDB.itemMinValue = tonumber(editbox:GetText())
		editbox:SetText(BrokerGarbage:FormatMoney(BG_LocalDB.itemMinValue))
		editbox:ClearFocus()
	end
	editbox:SetScript("OnEscapePressed", ResetEditBox)
	editbox:SetScript("OnEnterPressed", SubmitEditBox)
	editbox:SetScript("OnEditFocusGained", UnFormatEditBox)
	
	
	function BrokerGarbage.lootManagerOptionsUpdate(self)
		if BG_GlobalDB.useLootManager then
			restack:Enable()
			if BG_GlobalDB.restackIfNeeded then
				fullRestack:Enable()
			else
				fullRestack:Disable()
			end
			
			openContainers:Enable()
			openClams:Enable()
			
			selective:Enable()
			if BG_LocalDB.selectiveLooting then
				autoLoot:Enable()
				autoDestroy:Enable()
				
				if not BG_GlobalDB.autoLoot then
					autoLoot_skinning:Enable()
					autoLoot_pickpocket:Enable()
					autoLoot_fishing:Enable()
				else
					autoLoot_skinning:Disable()
					autoLoot_pickpocket:Disable()
					autoLoot_fishing:Disable()
				end
				
				if BG_GlobalDB.autoDestroy then
					minFreeSlots:Enable()
				else
					minFreeSlots:Disable()
				end
			else
				autoLoot:Disable()
				autoDestroy:Disable()
				autoLoot_skinning:Disable()
				autoLoot_pickpocket:Disable()
				autoLoot_fishing:Disable()
				minFreeSlots:Disable()
			end
			
		else
			restack:Disable()
				fullRestack:Disable()
			
			openContainers:Disable()
			openClams:Disable()
			
			selective:Disable()
				autoLoot:Disable()
					autoLoot_skinning:Disable()
					autoLoot_pickpocket:Disable()
					autoLoot_fishing:Disable()
				autoDestroy:Disable()
					minFreeSlots:Disable()
		end
	end
	
	BrokerGarbage:lootManagerOptionsUpdate()
	BrokerGarbage.lootManagerOptions:SetScript("OnShow", BrokerGarbage.lootManagerOptionsUpdate)
end

BrokerGarbage.lootManagerOptions:SetScript("OnShow", ShowOptions)