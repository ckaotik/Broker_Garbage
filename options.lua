addonName, BrokerGarbage = ...

BrokerGarbage.quality = {
	[0] = "|cff9D9D9D"..ITEM_QUALITY0_DESC.."|r",
	[1] = "|cffFFFFFF"..ITEM_QUALITY1_DESC.."|r",
	[2] = "|cff1EFF00"..ITEM_QUALITY2_DESC.."|r",
	[3] = "|cff0070FF"..ITEM_QUALITY3_DESC.."|r",
	[4] = "|cffa335ee"..ITEM_QUALITY4_DESC.."|r",
	[5] = "|cffff8000"..ITEM_QUALITY5_DESC.."|r",
	[6] = "|cffE6CC80"..ITEM_QUALITY6_DESC.."|r",
	}

-- main options panel
BrokerGarbage.options = CreateFrame("Frame", "BrokerGarbageOptionsFrame", InterfaceOptionsFramePanelContainer)
BrokerGarbage.options.name = addonName
BrokerGarbage.options:Hide()

-- list options panel
BrokerGarbage.listOptions = CreateFrame("Frame", "BrokerGarbageOptionsFrame", InterfaceOptionsFramePanelContainer)
BrokerGarbage.listOptions.name = BrokerGarbage.locale.LOTitle
BrokerGarbage.listOptions.parent = addonName
BrokerGarbage.listOptions:Hide()
BrokerGarbage.optionRows = {}
BrokerGarbage.listButtons = {
	include = {},
	exclude = {},
}

-- show me!
BrokerGarbage.options:SetScript("OnShow", function(frame)

	local title, subtitle = LibStub("tekKonfig-Heading").new(BrokerGarbage.options, addonName, BrokerGarbage.locale.subTitle)

	local autosell = LibStub("tekKonfig-Checkbox").new(BrokerGarbage.options, nil, BrokerGarbage.locale.autoSellTitle, "TOPLEFT", subtitle, "BOTTOMLEFT", -2, -4)
	autosell.tiptext = BrokerGarbage.locale.autoSellText
	autosell:SetChecked(BG_GlobalDB.autoSellToVendor)
	local checksound = autosell:GetScript("OnClick")
	autosell:SetScript("OnClick", function(checksound)
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
	quality:SetValueStep(1);
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
		BG_GlobalDB.showsource = not BG_GlobalDB.showsource
	end)

	-- ----------------------------------
	-- List Options panel

	local title, subtitle = LibStub("tekKonfig-Heading").new(BrokerGarbage.listOptions, addonName .. " - " .. BrokerGarbage.locale.LOTitle , BrokerGarbage.locale.LOSubTitle)
	
	-- list frame: excludes
	local boxHeight = 150
	local boxWidth = 330

	local excludeListHeader = BrokerGarbage.listOptions:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	excludeListHeader:SetHeight(32)
	excludeListHeader:SetPoint("TOPLEFT", subtitle, "BOTTOMLEFT", 0, 15)
	excludeListHeader:SetText(BrokerGarbage.locale.LOExcludeHeader)
	
	local excludeBox = CreateFrame("ScrollFrame", "BG_ExcludeListBox", BrokerGarbage.listOptions, "UIPanelScrollFrameTemplate")
	excludeBox:SetPoint("TOPLEFT", excludeListHeader, "BOTTOMLEFT", 0, 2)
	excludeBox:SetHeight(boxHeight)
	excludeBox:SetWidth(boxWidth)
	local group = CreateFrame("Frame", nil, excludeBox)
	excludeBox:SetScrollChild(group)
	group:SetAllPoints()
	group:SetHeight(boxHeight)
	group:SetWidth(boxWidth)
	
	local backdrop = {bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
		tile = false,
		tileSize = 32,
		insets = { left = 0, right = -22, top = 0, bottom = 0 }}
	excludeBox:SetBackdrop(backdrop)
	excludeBox:SetBackdropBorderColor(0.4, 0.4, 0.4)
	excludeBox:SetBackdropColor(0.1, 0.1, 0.1)
	
	-- action buttons
	local plus = CreateFrame("Button", nil, BrokerGarbage.listOptions)
	plus:SetPoint("TOPLEFT", "BG_ExcludeListBoxScrollBar", "TOPRIGHT", 8, -3)
	plus:SetWidth(25); plus:SetHeight(25)
	plus:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square")
	plus:SetNormalTexture("Interface\\Icons\\Spell_chargepositive")
	plus.tiptext = BrokerGarbage.locale.LOExcludePlusTT

	local minus = CreateFrame("Button", nil, BrokerGarbage.listOptions)
	minus:SetPoint("TOP", plus, "BOTTOM", 0, -6)
	minus:SetWidth(25);	minus:SetHeight(25)
	minus:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square")
	minus:SetNormalTexture("Interface\\Icons\\Spell_chargenegative")
	minus.tiptext = BrokerGarbage.locale.LOExcludeMinusTT
	
	local promote = CreateFrame("Button", nil, BrokerGarbage.listOptions)
	promote:SetPoint("TOP", minus, "BOTTOM", 0, -6)
	promote:SetWidth(25) promote:SetHeight(25)
	promote:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square")
	promote:SetNormalTexture("Interface\\Icons\\achievement_bg_returnxflags_def_wsg")
	promote.tiptext = BrokerGarbage.locale.LOExcludePromoteTT
	
	local emptyExcludeList = CreateFrame("Button", nil, BrokerGarbage.listOptions)
	emptyExcludeList:SetPoint("TOP", promote, "BOTTOM", 0, -6)
	emptyExcludeList:SetWidth(25); emptyExcludeList:SetHeight(25)
	emptyExcludeList:SetNormalTexture("Interface\\Buttons\\Ui-grouploot-pass-up")
	emptyExcludeList.tiptext = BrokerGarbage.locale.LOExcludeEmptyTT
	
	-- list frame: includes
	local includeListHeader = BrokerGarbage.listOptions:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	includeListHeader:SetHeight(32)
	includeListHeader:SetPoint("TOPLEFT", excludeBox, "BOTTOMLEFT", 0, -8)
	includeListHeader:SetText(BrokerGarbage.locale.LOIncludeHeader)
	
	local includeBox = CreateFrame("ScrollFrame", "BG_IncludeListBox", BrokerGarbage.listOptions, "UIPanelScrollFrameTemplate")
	includeBox:SetPoint("TOPLEFT", includeListHeader, "BOTTOMLEFT", 0, 2)
	includeBox:SetHeight(boxHeight)
	includeBox:SetWidth(boxWidth)
	local group2 = CreateFrame("Frame", nil, excludeBox)
	group2:SetAllPoints()
	group2:SetHeight(boxHeight)
	group2:SetWidth(boxWidth)
	includeBox:SetScrollChild(group2)
	
	includeBox:SetBackdrop(backdrop)
	includeBox:SetBackdropBorderColor(0.4, 0.4, 0.4)
	includeBox:SetBackdropColor(0.1, 0.1, 0.1)

	-- action buttons
	local plus2 = CreateFrame("Button", nil, BrokerGarbage.listOptions)
	plus2:SetPoint("TOPLEFT", "BG_IncludeListBoxScrollBar", "TOPRIGHT", 8, -3)
	plus2:SetWidth(25); plus2:SetHeight(25)
	plus2:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square")
	plus2:SetNormalTexture("Interface\\Icons\\Spell_chargepositive")
	plus2.tiptext = BrokerGarbage.locale.LOIncludePlusTT
	
	local minus2 = CreateFrame("Button", nil, BrokerGarbage.listOptions)
	minus2:SetPoint("TOP", plus2, "BOTTOM", 0, -6)
	minus2:SetWidth(25); minus2:SetHeight(25)
	minus2:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square")
	minus2:SetNormalTexture("Interface\\Icons\\Spell_chargenegative")
	minus2.tiptext = BrokerGarbage.locale.LOIncludeMinusTT
	
	local promote2 = CreateFrame("Button", nil, BrokerGarbage.listOptions)
	promote2:SetPoint("TOP", minus2, "BOTTOM", 0, -6)
	promote2:SetWidth(25); promote2:SetHeight(25)
	promote2:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square")
	promote2:SetNormalTexture("Interface\\Icons\\achievement_bg_returnxflags_def_wsg")
	promote2.tiptext = BrokerGarbage.locale.LOIncludePromoteTT

	local emptyIncludeList = CreateFrame("Button", nil, BrokerGarbage.listOptions)
	emptyIncludeList:SetPoint("TOP", promote2, "BOTTOM", 0, -6)
	emptyIncludeList:SetWidth(25); emptyIncludeList:SetHeight(25)
	emptyIncludeList:SetNormalTexture("Interface\\Buttons\\Ui-grouploot-pass-up")
	emptyIncludeList.tiptext = BrokerGarbage.locale.LOIncludeEmptyTT
	
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
	
	
	local function JoinTables(t1, t2)
		result = {}
		
		if t1 then
			for index, value in pairs (t1) do
				result[index] = value
			end
		end
		if t2 then
			for index, value in pairs (t2) do
				result[index] = value
			end
		end

		return result
	end
	
	local numCols = 8
	local function ListOptionsUpdate(listName)
		local globalList, localList, dataList, box, parent, buttonList
		if listName == "include" then
			globalList = BG_GlobalDB.include
			localList = BG_LocalDB.include

			box = includeBox
			parent = group2
			buttonList = BrokerGarbage.listButtons.include
		else
			globalList = BG_GlobalDB.exclude
			localList = BG_LocalDB.exclude

			box = excludeBox
			parent = group
			buttonList = BrokerGarbage.listButtons.exclude
		end
		dataList = JoinTables(globalList, localList)
		
		local index = 1
		for itemID,_ in pairs(dataList) do
			if buttonList[index] then
				-- use available button
				local button = buttonList[index]
				local itemName, itemLink, _, _, _, _, _, _, _, texture, _ = GetItemInfo(itemID)
				button.name = itemName
				button.itemID = itemID
				button.itemLink = itemLink
				button:SetNormalTexture(texture)
				button:GetNormalTexture():SetDesaturated(globalList[itemID])		-- desaturate global list items
				button:SetChecked(false)
				button:Show()
			else
				-- create another button
				local iconbutton = CreateFrame("CheckButton", nil, parent)
				iconbutton:Hide()
				iconbutton:SetWidth(36)
				iconbutton:SetHeight(36)

				iconbutton:SetNormalTexture("Interface\\Icons\\achievement_bg_returnxflags_def_wsg")
				iconbutton:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square")
				iconbutton:SetCheckedTexture("Interface\\Buttons\\UI-Button-Outline")
				iconbutton:SetChecked(false)
				local tex = iconbutton:GetCheckedTexture()
				tex:ClearAllPoints()
				tex:SetPoint("CENTER")
				tex:SetWidth(36/37*66) tex:SetHeight(36/37*66)
				
				iconbutton:GetNormalTexture():SetDesaturated(globalList[itemID])		-- desaturate global list items

				iconbutton:SetScript("OnEnter", ShowTooltip)
				iconbutton:SetScript("OnLeave", HideTooltip)

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
				ListOptionsUpdate(listName)
			end
			
			index = index + 1
		end
		-- hide unnessessary buttons
		while buttonList[index] do
			buttonList[index]:Hide()
			index = index + 1
		end
		
		box:UpdateScrollChildRect()
	end
	
	local function ItemDrop(self)
		local type, itemID, link = GetCursorInfo()
		if not type == "item" then return end
		
		if self == group2 or self == includeBox or self == plus2 then
			BG_LocalDB.include[itemID] = true
			BrokerGarbage:Print(format(BrokerGarbage.locale.addedToDestroyList, link))
			ListOptionsUpdate("include")
			ClearCursor()
		elseif self == group or self == excludeBox or self == plus then
			BG_LocalDB.exclude[itemID] = true
			BrokerGarbage:Print(format(BrokerGarbage.locale.addedToSaveList, link))
			ListOptionsUpdate("exclude")
			ClearCursor()
		end
	end
	
	local function OnClick(self, button)
		if self == emptyExcludeList then
			BG_LocalDB.exclude = {}
			ListOptionsUpdate("exclude")
			BrokerGarbage:ScanInventory()
		elseif self == emptyIncludeList then
			BG_LocalDB.include = {}
			ListOptionsUpdate("include")
			BrokerGarbage:ScanInventory()
			
		elseif self == minus then
			for i, button in pairs(BrokerGarbage.listButtons.exclude) do
				if button:GetChecked() then
					BG_LocalDB.exclude[button.itemID] = nil
					BG_GlobalDB.exclude[button.itemID] = nil
				end
			end
			ListOptionsUpdate("exclude")
			BrokerGarbage:ScanInventory()
		elseif self == minus2 then
			for i, button in pairs(BrokerGarbage.listButtons.include) do
				if button:GetChecked() then
					BG_LocalDB.include[button.itemID] = nil
					BG_GlobalDB.include[button.itemID] = nil
				end
			end
			ListOptionsUpdate("include")
			BrokerGarbage:ScanInventory()
			
		elseif self == plus then
			BrokerGarbage:Debug("Include1")
			ItemDrop(self)
			ListOptionsUpdate("exclude")
		elseif self == plus2 then
			BrokerGarbage:Debug("Include2")
			ItemDrop(self)
			ListOptionsUpdate("include")
		
		elseif self == promote then
			BrokerGarbage:Debug("Promote")
			for i, button in pairs(BrokerGarbage.listButtons.exclude) do
				if button:GetChecked() then
					BG_GlobalDB.exclude[button.itemID] = true
				end
			end
			
			ListOptionsUpdate("exclude")
		elseif self == promote2 then
			BrokerGarbage:Debug("Promote2")
			for i, button in pairs(BrokerGarbage.listButtons.include) do
				if button:GetChecked() then
					BG_GlobalDB.include[button.itemID] = true
				end
			end
			
			ListOptionsUpdate("exclude")
		end
		
		--ListOptionsUpdate("include")
		--ListOptionsUpdate("exclude")
	end
	
	emptyExcludeList:SetScript("OnClick", OnClick)
	emptyExcludeList:SetScript("OnEnter", ShowTooltip)
	emptyExcludeList:SetScript("OnLeave", HideTooltip)
	
	emptyIncludeList:SetScript("OnClick", OnClick)
	emptyIncludeList:SetScript("OnEnter", ShowTooltip)
	emptyIncludeList:SetScript("OnLeave", HideTooltip)
	
	minus:SetScript("OnClick", OnClick)
	minus:SetScript("OnEnter", ShowTooltip)
	minus:SetScript("OnLeave", HideTooltip)
	
	minus2:SetScript("OnClick", OnClick)
	minus2:SetScript("OnEnter", ShowTooltip)
	minus2:SetScript("OnLeave", HideTooltip)
	
	plus:SetScript("OnClick", OnClick)
	plus:SetScript("OnEnter", ShowTooltip)
	plus:SetScript("OnLeave", HideTooltip)
	
	plus2:SetScript("OnClick", OnClick)
	plus2:SetScript("OnEnter", ShowTooltip)
	plus2:SetScript("OnLeave", HideTooltip)
	
	promote:SetScript("OnClick", OnClick)
	promote:SetScript("OnEnter", ShowTooltip)
	promote:SetScript("OnLeave", HideTooltip)
	
	promote2:SetScript("OnClick", OnClick)
	promote2:SetScript("OnEnter", ShowTooltip)
	promote2:SetScript("OnLeave", HideTooltip)
	
	-- ----------------------------------	
	plus:RegisterForDrag("LeftButton")
	plus:SetScript("OnReceiveDrag", ItemDrop)
	plus:SetScript("OnMouseDown", ItemDrop)
	plus2:RegisterForDrag("LeftButton")
	plus2:SetScript("OnReceiveDrag", ItemDrop)
	plus2:SetScript("OnMouseDown", ItemDrop)
	
	buttons = {}
	ListOptionsUpdate("include")
	ListOptionsUpdate("exclude")
	frame:SetScript("OnShow", nil)
	BrokerGarbage.listOptions:SetScript("OnShow", ListOptionsUpdate)
end)

InterfaceOptions_AddCategory(BrokerGarbage.options)
InterfaceOptions_AddCategory(BrokerGarbage.listOptions)
LibStub("tekKonfig-AboutPanel").new("Broker_Garbage", "Broker_Garbage")