_, BrokerGarbage = ...

BrokerGarbage:CheckSettings()

-- rarity strings (no need to localize)
BrokerGarbage.quality = {
	[0] = "|cff9D9D9D"..ITEM_QUALITY0_DESC.."|r",
	[1] = "|cffFFFFFF"..ITEM_QUALITY1_DESC.."|r",
	[2] = "|cff1EFF00"..ITEM_QUALITY2_DESC.."|r",
	[3] = "|cff0070FF"..ITEM_QUALITY3_DESC.."|r",
	[4] = "|cffa335ee"..ITEM_QUALITY4_DESC.."|r",
	[5] = "|cffff8000"..ITEM_QUALITY5_DESC.."|r",
	[6] = "|cffE6CC80"..ITEM_QUALITY6_DESC.."|r",
	}

-- create drop down menu table for PT sets	
BrokerGarbage.PTSets = {}		
for set, _ in pairs(BrokerGarbage.PT.sets) do
	local partials = { strsplit(".", set) }
	local maxParts = #partials
	local pre = BrokerGarbage.PTSets
	
	for i = 1, maxParts do
		if i == maxParts then
			-- actual clickable entries
			pre[ partials[i] ] = set
		else
			-- all parts before that
			if not pre[ partials[i] ] then
				pre[ partials[i] ] = {}
			end
			pre = pre[ partials[i] ]
		end
	end
end

-- main options panel
BrokerGarbage.options = CreateFrame("Frame", "BrokerGarbageOptionsFrame", InterfaceOptionsFramePanelContainer)
BrokerGarbage.options.name = "Broker_Garbage"
BrokerGarbage.options:Hide()

-- list options: positive panel
BrokerGarbage.listOptionsPositive = CreateFrame("Frame", "BrokerGarbageOptionsFrame", InterfaceOptionsFramePanelContainer)
BrokerGarbage.listOptionsPositive.name = BrokerGarbage.locale.LOPTitle
BrokerGarbage.listOptionsPositive.parent = "Broker_Garbage"
BrokerGarbage.listOptionsPositive:Hide()

-- list options: negative panel
BrokerGarbage.listOptionsNegative = CreateFrame("Frame", "BrokerGarbageOptionsFrame", InterfaceOptionsFramePanelContainer)
BrokerGarbage.listOptionsNegative.name = BrokerGarbage.locale.LONTitle
BrokerGarbage.listOptionsNegative.parent = "Broker_Garbage"
BrokerGarbage.listOptionsNegative:Hide()

-- list options
BrokerGarbage.listButtons = {
	-- positive
	exclude = {},
	forceprice = {},
	-- negative
	autosell = {},
	include = {},
}


local function ShowOptions(frame)
	-- ----------------------------------
	-- Basic Options
	-- ----------------------------------
	local title, subtitle = LibStub("tekKonfig-Heading").new(BrokerGarbage.options, "Broker_Garbage", BrokerGarbage.locale.subTitle)

	local autosell = LibStub("tekKonfig-Checkbox").new(BrokerGarbage.options, nil, BrokerGarbage.locale.autoSellTitle, "TOPLEFT", subtitle, "BOTTOMLEFT", -2, -4)
	autosell.tiptext = BrokerGarbage.locale.autoSellText
	autosell:SetChecked(BG_GlobalDB.autoSellToVendor)
	local checksound = autosell:GetScript("OnClick")
	autosell:SetScript("OnClick", function(autosell)
		checksound(autosell)
		BG_GlobalDB.autoSellToVendor = not BG_GlobalDB.autoSellToVendor
	end)
	
	local autosellicon = LibStub("tekKonfig-Checkbox").new(BrokerGarbage.options, nil, BrokerGarbage.locale.showAutoSellIconTitle, "TOPLEFT", autosell, "BOTTOMLEFT", 14, 0)
	autosellicon.tiptext = BrokerGarbage.locale.showAutoSellIconText
	autosellicon:SetChecked(BG_GlobalDB.showAutoSellIcon)
	local checksound = autosellicon:GetScript("OnClick")
	autosellicon:SetScript("OnClick", function(autosellicon)
		checksound(autosellicon)
		BG_GlobalDB.showAutoSellIcon = not BG_GlobalDB.showAutoSellIcon
	end)

	local autorepair = LibStub("tekKonfig-Checkbox").new(BrokerGarbage.options, nil, BrokerGarbage.locale.autoRepairTitle, "LEFT", autosell, "LEFT", 200, 0)
	autorepair.tiptext = BrokerGarbage.locale.autoRepairText
	autorepair:SetChecked(BG_GlobalDB.autoRepairAtVendor)
	local checksound = autorepair:GetScript("OnClick")
	autorepair:SetScript("OnClick", function(autorepair)
		checksound(autorepair)
		BG_GlobalDB.autoRepairAtVendor = not BG_GlobalDB.autoRepairAtVendor
	end)

	local guildrepair = LibStub("tekKonfig-Checkbox").new(BrokerGarbage.options, nil, BrokerGarbage.locale.autoRepairGuildTitle, "TOPLEFT", autorepair, "BOTTOMLEFT", 14, 0)
	guildrepair.tiptext = BrokerGarbage.locale.autoRepairGuildText
	guildrepair:SetChecked(BG_LocalDB.neverRepairGuildBank)
	local checksound = guildrepair:GetScript("OnClick")
	guildrepair:SetScript("OnClick", function(guildrepair)
		checksound(guildrepair)
		BG_LocalDB.neverRepairGuildBank = not BG_LocalDB.neverRepairGuildBank
	end)
	
	local showlost = LibStub("tekKonfig-Checkbox").new(BrokerGarbage.options, nil, BrokerGarbage.locale.showLostTitle, "TOPLEFT", autosellicon, "BOTTOMLEFT", -14, -10)
	showlost.tiptext = BrokerGarbage.locale.showLostText
	showlost:SetChecked(BG_GlobalDB.showLost)
	local checksound = showlost:GetScript("OnClick")
	showlost:SetScript("OnClick", function(showlost)
		checksound(showlost)
		BG_GlobalDB.showLost = not BG_GlobalDB.showLost
	end)
	
	local showearned = LibStub("tekKonfig-Checkbox").new(BrokerGarbage.options, nil, BrokerGarbage.locale.showEarnedTitle, "LEFT", showlost, "LEFT", 200, 0)
	showearned.tiptext = BrokerGarbage.locale.showEarnedText
	showearned:SetChecked(BG_GlobalDB.showEarned)
	local checksound = showearned:GetScript("OnClick")
	showearned:SetScript("OnClick", function(showearned)
		checksound(showearned)
		BG_GlobalDB.showEarned = not BG_GlobalDB.showEarned
	end)

	local quality = LibStub("tekKonfig-Slider").new(BrokerGarbage.options, BrokerGarbage.locale.dropQualityTitle, 0, 6, "TOPLEFT", showlost, "BOTTOMLEFT", 5, -40)
	quality.tiptext = BrokerGarbage.locale.dropQualityText
	quality:SetWidth(200)
	quality:SetValueStep(1)
	quality:SetValue(BG_GlobalDB.dropQuality)
	quality.text = quality:CreateFontString("$parentCenterText", "ARTWORK", "GameFontHighlightSmall")
	quality.text:SetPoint("TOP", quality, "BOTTOM", 0, 3)
	quality.text:SetText(BrokerGarbage.quality[BG_GlobalDB.dropQuality])
	quality:SetScript("OnValueChanged", function(quality)
		BG_GlobalDB.dropQuality = quality:GetValue()
		quality.text:SetText(BrokerGarbage.quality[quality:GetValue()])
		BrokerGarbage:ScanInventory()
	end)

	local testValue = 130007
	local moneyFormat = LibStub("tekKonfig-Slider").new(BrokerGarbage.options, BrokerGarbage.locale.moneyFormatTitle, 0, 4, "LEFT", quality, "LEFT", 200, 0)
	moneyFormat.tiptext = BrokerGarbage.locale.moneyFormatText
	moneyFormat:SetWidth(200)
	moneyFormat:SetValueStep(1);
	moneyFormat:SetValue(BG_GlobalDB.showMoney)
	moneyFormat.text = moneyFormat:CreateFontString("$parentCenterText", "ARTWORK", "GameFontHighlightSmall")
	moneyFormat.text:SetPoint("TOP", moneyFormat, "BOTTOM", 0, 3)
	moneyFormat.text:SetText(BrokerGarbage:FormatMoney(testValue))
	moneyFormat:SetScript("OnValueChanged", function(moneyFormat)
		BG_GlobalDB.showMoney = moneyFormat:GetValue()
		moneyFormat.text:SetText(BrokerGarbage:FormatMoney(testValue))
	end)


	local ttMaxItems = LibStub("tekKonfig-Slider").new(BrokerGarbage.options, BrokerGarbage.locale.maxItemsTitle, 0, 50, "TOPLEFT", quality, "BOTTOMLEFT", 0, -15)
	ttMaxItems.tiptext = BrokerGarbage.locale.maxItemsText
	ttMaxItems:SetWidth(200)
	ttMaxItems:SetValueStep(1);
	ttMaxItems:SetValue(BG_GlobalDB.tooltipNumItems)
	ttMaxItems.text = ttMaxItems:CreateFontString("$parentCenterText", "ARTWORK", "GameFontHighlightSmall")
	ttMaxItems.text:SetPoint("TOP", ttMaxItems, "BOTTOM", 0, 3)
	ttMaxItems.text:SetText(ttMaxItems:GetValue())
	ttMaxItems:SetScript("OnValueChanged", function(ttMaxItems)
		BG_GlobalDB.tooltipNumItems = ttMaxItems:GetValue()
		ttMaxItems.text:SetText(ttMaxItems:GetValue())
	end)


	local ttMaxHeight = LibStub("tekKonfig-Slider").new(BrokerGarbage.options, BrokerGarbage.locale.maxHeightTitle, 0, 400, "LEFT", ttMaxItems, "LEFT", 200, 0)
	ttMaxHeight.tiptext = BrokerGarbage.locale.maxHeightText
	ttMaxHeight:SetWidth(200)
	ttMaxHeight:SetValueStep(10);
	ttMaxHeight:SetValue(BG_GlobalDB.tooltipMaxHeight)
	ttMaxHeight.text = ttMaxHeight:CreateFontString("$parentCenterText", "ARTWORK", "GameFontHighlightSmall")
	ttMaxHeight.text:SetPoint("TOP", ttMaxHeight, "BOTTOM", 0, 3)
	ttMaxHeight.text:SetText(ttMaxHeight:GetValue())
	ttMaxHeight:SetScript("OnValueChanged", function(ttMaxHeight)
		BG_GlobalDB.tooltipMaxHeight = ttMaxHeight:GetValue()
		ttMaxHeight.text:SetText(ttMaxHeight:GetValue())
	end)
	
	local resetexclude = LibStub("tekKonfig-Button").new_small(BrokerGarbage.options, "TOPLEFT", ttMaxItems, "BOTTOMLEFT", 0, -50)
	resetexclude:SetText(BrokerGarbage.locale.emptyExcludeList)
	resetexclude.tiptext = BrokerGarbage.locale.emptyExcludeListText
	resetexclude:SetWidth(150) resetexclude:SetHeight(18)
	resetexclude:SetScript("OnClick", function()
		BrokerGarbage:ResetList("exclude")
	end)
	
	local resetinclude = LibStub("tekKonfig-Button").new_small(BrokerGarbage.options, "TOPLEFT", resetexclude, "BOTTOMLEFT", 0, 0)
	resetinclude:SetText(BrokerGarbage.locale.emptyIncludeList)
	resetinclude.tiptext = BrokerGarbage.locale.emptyIncludeListText
	resetinclude:SetWidth(150) resetinclude:SetHeight(18)
	resetinclude:SetScript("OnClick", function()
		BrokerGarbage:ResetList("include")
	end)
	
	local rescan = LibStub("tekKonfig-Button").new_small(BrokerGarbage.options, "TOPLEFT", resetinclude, "BOTTOMLEFT", 0, -20)
	rescan:SetText(BrokerGarbage.locale.rescanInventory)
	rescan.tiptext = BrokerGarbage.locale.rescanInventoryText
	rescan:SetWidth(150) rescan:SetHeight(18)
	rescan:SetScript("OnClick", function()
		BrokerGarbage:ScanInventory()
	end)

	local resetmoneylost = LibStub("tekKonfig-Button").new_small(BrokerGarbage.options, "LEFT", resetexclude, "LEFT", 200, 0)
	resetmoneylost:SetText(BrokerGarbage.locale.resetMoneyLost)
	resetmoneylost.tiptext = BrokerGarbage.locale.resetMoneyLostText
	resetmoneylost:SetWidth(150) resetmoneylost:SetHeight(18)
	resetmoneylost:SetScript("OnClick", function()
		BrokerGarbage:ResetMoney(0)
	end)
	
	local resetmoneyearned = LibStub("tekKonfig-Button").new_small(BrokerGarbage.options, "TOPLEFT", resetmoneylost, "BOTTOMLEFT", 0, 0)
	resetmoneyearned:SetText(BrokerGarbage.locale.resetMoneyEarned)
	resetmoneyearned.tiptext = BrokerGarbage.locale.resetMoneyEarnedText
	resetmoneyearned:SetWidth(150) resetmoneyearned:SetHeight(18)
	resetmoneyearned:SetScript("OnClick", function()
		BrokerGarbage:ResetMoney(1)
	end)
	
	local showsource = LibStub("tekKonfig-Checkbox").new(BrokerGarbage.options, nil, BrokerGarbage.locale.showSourceTitle, "TOPLEFT", resetmoneyearned, "BOTTOMLEFT", 0, -20)
	showsource.tiptext = BrokerGarbage.locale.showSourceText
	showsource:SetChecked(BG_GlobalDB.showSource)
	local checksound = showsource:GetScript("OnClick")
	showsource:SetScript("OnClick", function(showsource)
		checksound(showsource)
		BG_GlobalDB.showSource = not BG_GlobalDB.showSource
	end)

	-- List Options
	-- ----------------------------------
	local boxHeight = 150
	local boxWidth = 330
	
	--local backdrop = {
		--bgFile = "Interface\\ChatFrame\\ChatFrameBackground", insets = {left = 4, right = 4, top = 4, bottom = 4},
		--edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 16
	--}
	local backdrop = {bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
		tile = false,
		tileSize = 32,
		insets = { left = 0, right = -22, top = 0, bottom = 0 }
	}
		
	local function ShowTooltip(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		if self.tiptext then
			GameTooltip:SetText(self.tiptext, nil, nil, nil, nil, true)
		elseif self.itemLink then
			GameTooltip:SetHyperlink(self.itemLink)
		end
		GameTooltip:Show()
	end
	local function HideTooltip() GameTooltip:Hide() end
	
	-- ----------------------------------
	--	Positive Lists
	-- ----------------------------------
	local title2, subtitle2 = LibStub("tekKonfig-Heading").new(BrokerGarbage.listOptionsPositive, "Broker_Garbage" .. " - " .. BrokerGarbage.locale.LOPTitle , BrokerGarbage.locale.LOPSubTitle)
	
	-- list frame: exclude
	local excludeListHeader = BrokerGarbage.listOptionsPositive:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	excludeListHeader:SetHeight(32)
	excludeListHeader:SetPoint("TOPLEFT", subtitle2, "BOTTOMLEFT", 0, 14)
	excludeListHeader:SetText(BrokerGarbage.locale.LOPExcludeHeader)
	
	local excludeBox = CreateFrame("ScrollFrame", "BG_ExcludeListBox", BrokerGarbage.listOptionsPositive, "UIPanelScrollFrameTemplate")
	excludeBox:SetPoint("TOPLEFT", excludeListHeader, "BOTTOMLEFT", 0, 4)
	excludeBox:SetHeight(boxHeight)
	excludeBox:SetWidth(boxWidth)
	local group_exclude = CreateFrame("Frame", nil, excludeBox)
	excludeBox:SetScrollChild(group_exclude)
	group_exclude:SetAllPoints()
	group_exclude:SetHeight(boxHeight)
	group_exclude:SetWidth(boxWidth)
	
	excludeBox:SetBackdrop(backdrop)
	excludeBox:SetBackdropBorderColor(0.4, 0.4, 0.4)
	excludeBox:SetBackdropColor(0.1, 0.1, 0.1)
	
	-- action buttons
	local plus = CreateFrame("Button", nil, BrokerGarbage.listOptionsPositive)
	plus:SetPoint("TOPLEFT", "BG_ExcludeListBoxScrollBar", "TOPRIGHT", 8, -3)
	plus:SetWidth(25); plus:SetHeight(25)
	plus:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square")
	plus:SetNormalTexture("Interface\\Icons\\Spell_chargepositive")
	plus.tiptext = BrokerGarbage.locale.LOPExcludePlusTT
	plus:RegisterForClicks("RightButtonUp")

	local minus = CreateFrame("Button", nil, BrokerGarbage.listOptionsPositive)
	minus:SetPoint("TOP", plus, "BOTTOM", 0, -6)
	minus:SetWidth(25);	minus:SetHeight(25)
	minus:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square")
	minus:SetNormalTexture("Interface\\Icons\\Spell_chargenegative")
	minus.tiptext = BrokerGarbage.locale.LOPExcludeMinusTT
	
	local promote = CreateFrame("Button", nil, BrokerGarbage.listOptionsPositive)
	promote:SetPoint("TOP", minus, "BOTTOM", 0, -6)
	promote:SetWidth(25) promote:SetHeight(25)
	promote:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square")
	promote:SetNormalTexture("Interface\\Icons\\achievement_bg_returnxflags_def_wsg")
	promote.tiptext = BrokerGarbage.locale.LOPExcludePromoteTT
	
	local emptyExcludeList = CreateFrame("Button", nil, BrokerGarbage.listOptionsPositive)
	emptyExcludeList:SetPoint("TOP", promote, "BOTTOM", 0, -6)
	emptyExcludeList:SetWidth(25); emptyExcludeList:SetHeight(25)
	emptyExcludeList:SetNormalTexture("Interface\\Buttons\\Ui-grouploot-pass-up")
	emptyExcludeList.tiptext = BrokerGarbage.locale.LOPExcludeEmptyTT
	
	-- list frame: force price
	local forcepriceListHeader = BrokerGarbage.listOptionsPositive:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	forcepriceListHeader:SetHeight(32)
	forcepriceListHeader:SetPoint("TOPLEFT", excludeBox, "BOTTOMLEFT", 0, -8)
	forcepriceListHeader:SetText(BrokerGarbage.locale.LOPForceHeader)
	
	local forcepriceBox = CreateFrame("ScrollFrame", "BG_ForcePriceListBox", BrokerGarbage.listOptionsPositive, "UIPanelScrollFrameTemplate")
	forcepriceBox:SetPoint("TOPLEFT", forcepriceListHeader, "BOTTOMLEFT", 0, 4)
	forcepriceBox:SetHeight(boxHeight)
	forcepriceBox:SetWidth(boxWidth)
	local group_forceprice = CreateFrame("Frame", nil, forcepriceBox)
	group_forceprice:SetAllPoints()
	group_forceprice:SetHeight(boxHeight)
	group_forceprice:SetWidth(boxWidth)
	forcepriceBox:SetScrollChild(group_forceprice)
	
	forcepriceBox:SetBackdrop(backdrop)
	forcepriceBox:SetBackdropBorderColor(0.4, 0.4, 0.4)
	forcepriceBox:SetBackdropColor(0.1, 0.1, 0.1)

	-- action buttons
	local plus2 = CreateFrame("Button", nil, BrokerGarbage.listOptionsPositive)
	plus2:SetPoint("TOPLEFT", "BG_ForcePriceListBoxScrollBar", "TOPRIGHT", 8, -3)
	plus2:SetWidth(25); plus2:SetHeight(25)
	plus2:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square")
	plus2:SetNormalTexture("Interface\\Icons\\Spell_chargepositive")
	plus2.tiptext = BrokerGarbage.locale.LOPForcePlusTT
	plus2:RegisterForClicks("RightButtonUp")
	
	local minus2 = CreateFrame("Button", nil, BrokerGarbage.listOptionsPositive)
	minus2:SetPoint("TOP", plus2, "BOTTOM", 0, -6)
	minus2:SetWidth(25); minus2:SetHeight(25)
	minus2:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square")
	minus2:SetNormalTexture("Interface\\Icons\\Spell_chargenegative")
	minus2.tiptext = BrokerGarbage.locale.LOPForceMinusTT
	
	local promote2 = CreateFrame("Button", nil, BrokerGarbage.listOptionsPositive)
	promote2:SetPoint("TOP", minus2, "BOTTOM", 0, -6)
	promote2:SetWidth(25); promote2:SetHeight(25)
	promote2:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square")
	promote2:SetNormalTexture("Interface\\Icons\\achievement_bg_returnxflags_def_wsg")
	promote2:Enable(false)		-- we only have a global force vendor price list
	promote2:GetNormalTexture():SetDesaturated(true)
	promote2.tiptext = BrokerGarbage.locale.LOPForcePromoteTT

	local emptyForcePriceList = CreateFrame("Button", nil, BrokerGarbage.listOptionsPositive)
	emptyForcePriceList:SetPoint("TOP", promote2, "BOTTOM", 0, -6)
	emptyForcePriceList:SetWidth(25); emptyForcePriceList:SetHeight(25)
	emptyForcePriceList:SetNormalTexture("Interface\\Buttons\\Ui-grouploot-pass-up")
	emptyForcePriceList.tiptext = BrokerGarbage.locale.LOPForceEmptyTT
	
	-- ----------------------------------
	--	Negative Lists
	-- ----------------------------------
	local title3, subtitle3 = LibStub("tekKonfig-Heading").new(BrokerGarbage.listOptionsNegative, "Broker_Garbage" .. " - " .. BrokerGarbage.locale.LONTitle , BrokerGarbage.locale.LONSubTitle)
	
	-- list frame: include
	local includeListHeader = BrokerGarbage.listOptionsNegative:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	includeListHeader:SetHeight(32)
	includeListHeader:SetPoint("TOPLEFT", subtitle3, "BOTTOMLEFT", 0, 14)
	includeListHeader:SetText(BrokerGarbage.locale.LONIncludeHeader)
	
	local includeBox = CreateFrame("ScrollFrame", "BG_IncludeListBox", BrokerGarbage.listOptionsNegative, "UIPanelScrollFrameTemplate")
	includeBox:SetPoint("TOPLEFT", excludeListHeader, "BOTTOMLEFT", 0, 4)
	includeBox:SetHeight(boxHeight)
	includeBox:SetWidth(boxWidth)
	local group_include = CreateFrame("Frame", nil, includeBox)
	includeBox:SetScrollChild(group_include)
	group_include:SetAllPoints()
	group_include:SetHeight(boxHeight)
	group_include:SetWidth(boxWidth)
	
	includeBox:SetBackdrop(backdrop)
	includeBox:SetBackdropBorderColor(0.4, 0.4, 0.4)
	includeBox:SetBackdropColor(0.1, 0.1, 0.1)
	
	-- action buttons
	local plus3 = CreateFrame("Button", nil, BrokerGarbage.listOptionsNegative)
	plus3:SetPoint("TOPLEFT", "BG_ExcludeListBoxScrollBar", "TOPRIGHT", 8, -3)
	plus3:SetWidth(25); plus3:SetHeight(25)
	plus3:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square")
	plus3:SetNormalTexture("Interface\\Icons\\Spell_chargepositive")
	plus3.tiptext = BrokerGarbage.locale.LONIncludePlusTT
	plus3:RegisterForClicks("RightButtonUp")

	local minus3 = CreateFrame("Button", nil, BrokerGarbage.listOptionsNegative)
	minus3:SetPoint("TOP", plus3, "BOTTOM", 0, -6)
	minus3:SetWidth(25); minus3:SetHeight(25)
	minus3:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square")
	minus3:SetNormalTexture("Interface\\Icons\\Spell_chargenegative")
	minus3.tiptext = BrokerGarbage.locale.LONIncludeMinusTT
	
	local promote3 = CreateFrame("Button", nil, BrokerGarbage.listOptionsNegative)
	promote3:SetPoint("TOP", minus3, "BOTTOM", 0, -6)
	promote3:SetWidth(25) promote3:SetHeight(25)
	promote3:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square")
	promote3:SetNormalTexture("Interface\\Icons\\achievement_bg_returnxflags_def_wsg")
	promote3.tiptext = BrokerGarbage.locale.LONIncludePromoteTT
	
	local emptyIncludeList = CreateFrame("Button", nil, BrokerGarbage.listOptionsNegative)
	emptyIncludeList:SetPoint("TOP", promote3, "BOTTOM", 0, -6)
	emptyIncludeList:SetWidth(25); emptyIncludeList:SetHeight(25)
	emptyIncludeList:SetNormalTexture("Interface\\Buttons\\Ui-grouploot-pass-up")
	emptyIncludeList.tiptext = BrokerGarbage.locale.LONIncludeEmptyTT
	
	-- list frame: auto sell
	local autosellListHeader = BrokerGarbage.listOptionsNegative:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	autosellListHeader:SetHeight(32)
	autosellListHeader:SetPoint("TOPLEFT", excludeBox, "BOTTOMLEFT", 0, -8)
	autosellListHeader:SetText(BrokerGarbage.locale.LONAutoSellHeader)
	
	local autosellBox = CreateFrame("ScrollFrame", "BG_AutosellListBox", BrokerGarbage.listOptionsNegative, "UIPanelScrollFrameTemplate")
	autosellBox:SetPoint("TOPLEFT", autosellListHeader, "BOTTOMLEFT", 0, 4)
	autosellBox:SetHeight(boxHeight)
	autosellBox:SetWidth(boxWidth)
	local group_autosell = CreateFrame("Frame", nil, autosellBox)
	group_autosell:SetAllPoints()
	group_autosell:SetHeight(boxHeight)
	group_autosell:SetWidth(boxWidth)
	autosellBox:SetScrollChild(group_autosell)
	
	autosellBox:SetBackdrop(backdrop)
	autosellBox:SetBackdropBorderColor(0.4, 0.4, 0.4)
	autosellBox:SetBackdropColor(0.1, 0.1, 0.1)

	-- action buttons
	local plus4 = CreateFrame("Button", nil, BrokerGarbage.listOptionsNegative)
	plus4:SetPoint("TOPLEFT", "BG_AutosellListBoxScrollBar", "TOPRIGHT", 8, -3)
	plus4:SetWidth(25); plus4:SetHeight(25)
	plus4:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square")
	plus4:SetNormalTexture("Interface\\Icons\\Spell_chargepositive")
	plus4.tiptext = BrokerGarbage.locale.LONAutoSellPlusTT
	plus4:RegisterForClicks("RightButtonUp")
	
	local minus4 = CreateFrame("Button", nil, BrokerGarbage.listOptionsNegative)
	minus4:SetPoint("TOP", plus4, "BOTTOM", 0, -6)
	minus4:SetWidth(25); minus4:SetHeight(25)
	minus4:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square")
	minus4:SetNormalTexture("Interface\\Icons\\Spell_chargenegative")
	minus4.tiptext = BrokerGarbage.locale.LONAutoSellMinusTT
	
	local promote4 = CreateFrame("Button", nil, BrokerGarbage.listOptionsNegative)
	promote4:SetPoint("TOP", minus4, "BOTTOM", 0, -6)
	promote4:SetWidth(25); promote4:SetHeight(25)
	promote4:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square")
	promote4:SetNormalTexture("Interface\\Icons\\achievement_bg_returnxflags_def_wsg")
	promote4.tiptext = BrokerGarbage.locale.LONAutoSellPromoteTT

	local emptyAutoSellList = CreateFrame("Button", nil, BrokerGarbage.listOptionsNegative)
	emptyAutoSellList:SetPoint("TOP", promote4, "BOTTOM", 0, -6)
	emptyAutoSellList:SetWidth(25); emptyAutoSellList:SetHeight(25)
	emptyAutoSellList:SetNormalTexture("Interface\\Buttons\\Ui-grouploot-pass-up")
	emptyAutoSellList.tiptext = BrokerGarbage.locale.LONAutoSellEmptyTT
	
	-- function that updates & shows items from various lists
	local numCols = 8
	function BrokerGarbage:ListOptionsUpdate(listName)
		if not listName then
			BrokerGarbage:ListOptionsUpdate("include")
			BrokerGarbage:ListOptionsUpdate("exclude")
			BrokerGarbage:ListOptionsUpdate("autosell")
			BrokerGarbage:ListOptionsUpdate("forceprice")
			return
		end
		
		local globalList, localList, dataList, box, parent, buttonList
		if listName == "include" then
			globalList = BG_GlobalDB.include
			localList = BG_LocalDB.include

			box = includeBox
			parent = group_include
			buttonList = BrokerGarbage.listButtons.include
		
		elseif listName == "exclude" then
			globalList = BG_GlobalDB.exclude
			localList = BG_LocalDB.exclude

			box = excludeBox
			parent = group_exclude
			buttonList = BrokerGarbage.listButtons.exclude
		
		elseif listName == "autosell" then
			globalList = BG_GlobalDB.autoSellList
			localList = BG_LocalDB.autoSellList

			box = autosellBox
			parent = group_autosell
			buttonList = BrokerGarbage.listButtons.autosell
		
		elseif listName == "forceprice" then
			globalList = BG_GlobalDB.forceVendorPrice
			localList = {}

			box = forcepriceBox
			parent = group_forceprice
			buttonList = BrokerGarbage.listButtons.forceprice
		end
		dataList = BrokerGarbage:JoinTables(globalList, localList)
		if not buttonList then buttonList = {} end
		
		local index = 1
		for itemID,_ in pairs(dataList) do
			if buttonList[index] then
				-- use available button
				local button = buttonList[index]
				local itemLink, texture
				if type(itemID) ~= "number" then
					-- this is an item category
					BrokerGarbage:Debug("Encountered Category String!", itemID)
					itemLink = nil
					button.tiptext = itemID		-- category description string
					texture = "Interface\\Icons\\Trade_engineering"
				else
					-- this is an explicit item
					_, itemLink, _, _, _, _, _, _, _, texture, _ = GetItemInfo(itemID)
				end
				
				-- blizzard removes GetItemInfo for seasonal items ...
				if texture then
					button.itemID = itemID
					button.itemLink = itemLink
					button:SetNormalTexture(texture)
					button:GetNormalTexture():SetDesaturated(globalList[itemID] or false)		-- desaturate global list items
				else
					button.itemID = itemID
					button.tiptext = "ID: "..itemID
				end
				button:SetChecked(false)
				button:Show()
			else
				-- create another button
				local iconbutton = CreateFrame("CheckButton", nil, parent)
				iconbutton:Hide()
				iconbutton:SetWidth(36)
				iconbutton:SetHeight(36)

				iconbutton:SetNormalTexture("Interface\\Icons\\Inv_misc_questionmark")
				iconbutton:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square")
				iconbutton:SetCheckedTexture("Interface\\Buttons\\UI-Button-Outline")
				iconbutton:SetChecked(false)
				local tex = iconbutton:GetCheckedTexture()
				tex:ClearAllPoints()
				tex:SetPoint("CENTER")
				tex:SetWidth(36/37*66) tex:SetHeight(36/37*66)
				
				iconbutton:SetScript("OnEnter", ShowTooltip)
				iconbutton:SetScript("OnLeave", HideTooltip)
				-- TODO: iconbutton:RegisterForClicks("Rightclick")

				if index == 1 then
					-- place first icon
					iconbutton:SetPoint("TOPLEFT", parent, "TOPLEFT", 6, -6)
				elseif mod(index, numCols) == 1 then
					-- new row
					iconbutton:SetPoint("TOPLEFT", buttonList[index-numCols], "BOTTOMLEFT", 0, -6)
				else
					-- new button next to the old one
					iconbutton:SetPoint("LEFT", buttonList[index-1], "RIGHT", 4, 0)
				end
				
				buttonList[index] = iconbutton
				-- update, so we get item data & texture
				BrokerGarbage:ListOptionsUpdate(listName)
			end
			index = index + 1
		end
		-- hide unnessessary buttons
		while buttonList[index] do
			buttonList[index]:Hide()
			index = index + 1
		end
	end
	
	local function ItemDrop(self, item)
		local type, itemID, link = GetCursorInfo()
		if not type == "item" and not item then return end
		
		-- to fix category strings
		if item then 
			if item == "RightButton" then return end
			itemID = item
			link = item 
		end
		
		if self == group_exclude or self == excludeBox or self == plus then
			BG_LocalDB.exclude[itemID] = true
			BrokerGarbage:Print(format(BrokerGarbage.locale.addedToSaveList, link))
			BrokerGarbage:ListOptionsUpdate("exclude")
			ClearCursor()
		elseif self == group_forceprice or self == forcepriceBox or self == plus2 then
			BG_GlobalDB.forceVendorPrice[itemID] = true
			BrokerGarbage:Print(format(BrokerGarbage.locale.addedToPriceList, link))
			BrokerGarbage:ListOptionsUpdate("forceprice")
			ClearCursor()
		elseif self == group_include or self == includeBox or self == plus3 then
			BG_LocalDB.include[itemID] = true
			BrokerGarbage:Print(format(BrokerGarbage.locale.addedToIncludeList, link))
			BrokerGarbage:ListOptionsUpdate("include")
			ClearCursor()
		elseif self == group_autosell or self == autosellBox or self == plus4 then
			BG_LocalDB.autoSellList[itemID] = true
			BrokerGarbage:Print(format(BrokerGarbage.locale.addedToSellList, link))
			BrokerGarbage:ListOptionsUpdate("autosell")
			ClearCursor()
		end
	end
	
	if not _G["BrokerGarbagePTMenuFrame"] then		
		--initialize dropdown menu for adding setstrings
		BrokerGarbage.menuFrame = CreateFrame("Frame", "BrokerGarbagePTMenuFrame", UIParent, "UIDropDownMenuTemplate")
		
		-- menu create function
		function DropDown_Initialize(self,level)
			level = level or 1;
			if (level == 1) then		
				local info = UIDropDownMenu_CreateInfo();
				info.hasArrow = false; -- no submenu
				info.notCheckable = true;
				info.text = "Categories";
				info.isTitle = true;
				info.tooltipTitle = BrokerGarbage.locale.PTCategoryTooltipHeader
				info.tooltipText = BrokerGarbage.locale.PTCategoryTooltipText
				UIDropDownMenu_AddButton(info, level);

				for key, subarray in pairs(BrokerGarbage.PTSets) do
					-- submenus
					local info = UIDropDownMenu_CreateInfo()
					info.hasArrow = true
					info.notCheckable = true
					info.text = key
					info.value = {
						[1] = key
					}
					info.func = function(...) 
						ItemDrop(BrokerGarbage.menuFrame.clickTarget, key)
						BrokerGarbage:ListOptionsUpdate()
					end
					UIDropDownMenu_AddButton(info, level)
				end
			end

			if (level > 1) then
				-- getting values of first menu
				local parentValue = UIDROPDOWNMENU_MENU_VALUE
				local PTSets = BrokerGarbage.PTSets
				for i = 1, level - 1 do
					PTSets = PTSets[ parentValue[i] ]
				end
				
				for key, value in pairs(PTSets) do
					local newValue = {}
					for i = 1, level - 1 do
						newValue[i] = parentValue[i]
					end
					newValue[level] = key
					
					local info = UIDropDownMenu_CreateInfo();
					if type(value) == "table" then
						-- submenu
						local valueString = newValue[1]
						for i = 2, level do
							valueString = valueString.."."..newValue[i]
						end
						
						info.hasArrow = true;
						info.notCheckable = true;
						info.text = key
						info.value = newValue
						info.func = function(...) 
							ItemDrop(BrokerGarbage.menuFrame.clickTarget, valueString)
							BrokerGarbage:ListOptionsUpdate()
						end
					else
						-- end node
						info.hasArrow = false; -- no submenues this time
						info.notCheckable = true;
						info.text = key
						info.func = function(...) 
							ItemDrop(BrokerGarbage.menuFrame.clickTarget, value)
							BrokerGarbage:ListOptionsUpdate()
						end
					end
					UIDropDownMenu_AddButton(info, level);
				end
			end
		end
		UIDropDownMenu_Initialize(BrokerGarbage.menuFrame, DropDown_Initialize, "MENU")
	end
	
	local function OnClick(self, button)
		if button == "RightButton" then
			-- toggle right click menu
			BrokerGarbage.menuFrame.clickTarget = self
			ToggleDropDownMenu(1, nil, BrokerGarbage.menuFrame, self, -20, 0)
			BrokerGarbage:Debug("Rightclick on plus", self, button)
			return
		end
		
		-- empty action
		if self == emptyExcludeList then
			BG_LocalDB.exclude = {}
			BrokerGarbage:ListOptionsUpdate("exclude")
			BrokerGarbage:ScanInventory()
		elseif self == emptyForcePriceList then
			BG_LocalDB.forceVendorPrice = {}
			BrokerGarbage:ListOptionsUpdate("forceprice")
			BrokerGarbage:ScanInventory()
		elseif self == emptyIncludeList then
			BG_LocalDB.include = {}
			BrokerGarbage:ListOptionsUpdate("include")
			BrokerGarbage:ScanInventory()
		elseif self == emptyAutoSellList then
			BG_LocalDB.autoSellList = {}
			BrokerGarbage:ListOptionsUpdate("autosell")
			BrokerGarbage:ScanInventory()
			
		-- remove action
		elseif self == minus then
			for i, button in pairs(BrokerGarbage.listButtons.exclude) do
				if button:GetChecked() then
					BG_LocalDB.exclude[button.itemID] = nil
					BG_GlobalDB.exclude[button.itemID] = nil
				end
			end
			BrokerGarbage:ListOptionsUpdate("exclude")
			BrokerGarbage:ScanInventory()
		elseif self == minus2 then
			for i, button in pairs(BrokerGarbage.listButtons.forceprice) do
				if button:GetChecked() then
					BG_GlobalDB.forceVendorPrice[button.itemID] = nil
				end
			end
			BrokerGarbage:ListOptionsUpdate("forceprice")
			BrokerGarbage:ScanInventory()
		elseif self == minus3 then
			for i, button in pairs(BrokerGarbage.listButtons.include) do
				if button:GetChecked() then
					BG_LocalDB.include[button.itemID] = nil
					BG_GlobalDB.include[button.itemID] = nil
				end
			end
			BrokerGarbage:ListOptionsUpdate("include")
			BrokerGarbage:ScanInventory()
		elseif self == minus4 then
			for i, button in pairs(BrokerGarbage.listButtons.autosell) do
				if button:GetChecked() then
					BG_LocalDB.autoSellList[button.itemID] = nil
					BG_GlobalDB.autoSellList[button.itemID] = nil
				end
			end
			BrokerGarbage:ListOptionsUpdate("autosell")
			BrokerGarbage:ScanInventory()
		
		-- add action
		elseif self == plus or self == plus2 or self == plus3 or self == plus4 then			
			if button == "RightButton" then
				BrokerGarbage:Debug("Right click on plusses")
				return
			end
			if self == plus then
				ItemDrop(self)
				BrokerGarbage:ListOptionsUpdate("exclude")
			elseif self == plus2 then
				ItemDrop(self)
				BrokerGarbage:ListOptionsUpdate("forceprice")
			elseif self == plus3 then
				ItemDrop(self)
				BrokerGarbage:ListOptionsUpdate("include")
			elseif self == plus4 then
				ItemDrop(self)
				BrokerGarbage:ListOptionsUpdate("autosell")
			end
		
		-- promote action
		elseif self == promote then
			for i, button in pairs(BrokerGarbage.listButtons.exclude) do
				if button:GetChecked() then
					BG_GlobalDB.exclude[button.itemID] = true
				end
			end
			BrokerGarbage:ListOptionsUpdate("exclude")
		elseif self == promote3 then
			for i, button in pairs(BrokerGarbage.listButtons.include) do
				if button:GetChecked() then
					BG_GlobalDB.include[button.itemID] = true
				end
			end
			BrokerGarbage:ListOptionsUpdate("include")
		elseif self == promote3 then
			for i, button in pairs(BrokerGarbage.listButtons.autosell) do
				if button:GetChecked() then
					BG_GlobalDB.autoSellList[button.itemID] = true
				end
			end
			BrokerGarbage:ListOptionsUpdate("autosell")
		end
		
		BrokerGarbage:ScanInventory()
	end
	
	emptyExcludeList:SetScript("OnClick", OnClick)
	emptyExcludeList:SetScript("OnEnter", ShowTooltip)
	emptyExcludeList:SetScript("OnLeave", HideTooltip)
	emptyForcePriceList:SetScript("OnClick", OnClick)
	emptyForcePriceList:SetScript("OnEnter", ShowTooltip)
	emptyForcePriceList:SetScript("OnLeave", HideTooltip)
	emptyIncludeList:SetScript("OnClick", OnClick)
	emptyIncludeList:SetScript("OnEnter", ShowTooltip)
	emptyIncludeList:SetScript("OnLeave", HideTooltip)
	emptyAutoSellList:SetScript("OnClick", OnClick)
	emptyAutoSellList:SetScript("OnEnter", ShowTooltip)
	emptyAutoSellList:SetScript("OnLeave", HideTooltip)
	
	minus:SetScript("OnClick", OnClick)
	minus:SetScript("OnEnter", ShowTooltip)
	minus:SetScript("OnLeave", HideTooltip)
	minus2:SetScript("OnClick", OnClick)
	minus2:SetScript("OnEnter", ShowTooltip)
	minus2:SetScript("OnLeave", HideTooltip)
	minus3:SetScript("OnClick", OnClick)
	minus3:SetScript("OnEnter", ShowTooltip)
	minus3:SetScript("OnLeave", HideTooltip)
	minus4:SetScript("OnClick", OnClick)
	minus4:SetScript("OnEnter", ShowTooltip)
	minus4:SetScript("OnLeave", HideTooltip)
	
	plus:SetScript("OnClick", OnClick)
	plus:SetScript("OnEnter", ShowTooltip)
	plus:SetScript("OnLeave", HideTooltip)
	plus2:SetScript("OnClick", OnClick)
	plus2:SetScript("OnEnter", ShowTooltip)
	plus2:SetScript("OnLeave", HideTooltip)
	plus3:SetScript("OnClick", OnClick)
	plus3:SetScript("OnEnter", ShowTooltip)
	plus3:SetScript("OnLeave", HideTooltip)
	plus4:SetScript("OnClick", OnClick)
	plus4:SetScript("OnEnter", ShowTooltip)
	plus4:SetScript("OnLeave", HideTooltip)
	
	promote:SetScript("OnClick", OnClick)
	promote:SetScript("OnEnter", ShowTooltip)
	promote:SetScript("OnLeave", HideTooltip)
	promote2:SetScript("OnClick", OnClick)
	promote2:SetScript("OnEnter", ShowTooltip)
	promote2:SetScript("OnLeave", HideTooltip)
	promote3:SetScript("OnClick", OnClick)
	promote3:SetScript("OnEnter", ShowTooltip)
	promote3:SetScript("OnLeave", HideTooltip)
	promote4:SetScript("OnClick", OnClick)
	promote4:SetScript("OnEnter", ShowTooltip)
	promote4:SetScript("OnLeave", HideTooltip)
	
	-- support for add-mechanism
	plus:RegisterForDrag("LeftButton")
	plus:SetScript("OnReceiveDrag", ItemDrop)
	plus:SetScript("OnMouseDown", ItemDrop)
	plus2:RegisterForDrag("LeftButton")
	plus2:SetScript("OnReceiveDrag", ItemDrop)
	plus2:SetScript("OnMouseDown", ItemDrop)
	plus3:RegisterForDrag("LeftButton")
	plus3:SetScript("OnReceiveDrag", ItemDrop)
	plus3:SetScript("OnMouseDown", ItemDrop)
	plus4:RegisterForDrag("LeftButton")
	plus4:SetScript("OnReceiveDrag", ItemDrop)
	plus4:SetScript("OnMouseDown", ItemDrop)
	
	buttons = {}
	BrokerGarbage:ListOptionsUpdate()
	BrokerGarbage.options:SetScript("OnShow", nil)
	BrokerGarbage.listOptionsPositive:SetScript("OnShow", BrokerGarbage.ListOptionsUpdate)
	BrokerGarbage.listOptionsNegative:SetScript("OnShow", BrokerGarbage.ListOptionsUpdate)
	BrokerGarbage.optionsLoaded = true
end

-- show me!
BrokerGarbage.options:SetScript("OnShow", ShowOptions)
BrokerGarbage.listOptionsPositive:SetScript("OnShow", ShowOptions)
BrokerGarbage.listOptionsNegative:SetScript("OnShow", ShowOptions)

InterfaceOptions_AddCategory(BrokerGarbage.options)
InterfaceOptions_AddCategory(BrokerGarbage.listOptionsPositive)
InterfaceOptions_AddCategory(BrokerGarbage.listOptionsNegative)
LibStub("tekKonfig-AboutPanel").new("Broker_Garbage", "Broker_Garbage")