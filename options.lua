_, BrokerGarbage = ...

BrokerGarbage.options = CreateFrame("Frame", "BrokerGarbageOptionsFrame", InterfaceOptionsFramePanelContainer)
BrokerGarbage.options.name = "Broker_Garbage"
-- no, you don't want to see this until it's done
BrokerGarbage.options:Hide()

BrokerGarbage.quality = {
	[0] = "|cff9D9D9D"..ITEM_QUALITY0_DESC.."|r",
	[1] = "|cffFFFFFF"..ITEM_QUALITY1_DESC.."|r",
	[2] = "|cff1EFF00"..ITEM_QUALITY2_DESC.."|r",
	[3] = "|cff0070FF"..ITEM_QUALITY3_DESC.."|r",
	[4] = "|cffa335ee"..ITEM_QUALITY4_DESC.."|r",
	[5] = "|cffff8000"..ITEM_QUALITY5_DESC.."|r",
	[6] = "|cffE6CC80"..ITEM_QUALITY6_DESC.."|r",
	}

BrokerGarbage.options:SetScript("OnShow", function(self)
	local title, subtitle = LibStub("tekKonfig-Heading").new(self, "Broker_Garbage", BrokerGarbage.locale.subTitle)

	local autosell = LibStub("tekKonfig-Checkbox").new(self, nil, BrokerGarbage.locale.autoSellTitle, "TOPLEFT", subtitle, "BOTTOMLEFT", -2, -4)
	autosell.tiptext = BrokerGarbage.locale.autoSellText
	autosell:SetChecked(BG_GlobalDB.autoSellToVendor)
	local checksound = autosell:GetScript("OnClick")
	autosell:SetScript("OnClick", function(self)
		checksound(self)
		BG_GlobalDB.autoSellToVendor = not BG_GlobalDB.autoSellToVendor
	end)
	
	local autorepair = LibStub("tekKonfig-Checkbox").new(self, nil, BrokerGarbage.locale.autoRepairTitle, "TOPLEFT", subtitle, "BOTTOMLEFT", 178, -4)
	autorepair.tiptext = BrokerGarbage.locale.autoRepairText
	autorepair:SetChecked(BG_GlobalDB.autoRepairAtVendor)
	local checksound = autorepair:GetScript("OnClick")
	autorepair:SetScript("OnClick", function(self)
		checksound(self)
		BG_GlobalDB.autoRepairAtVendor = not BG_GlobalDB.autoRepairAtVendor
	end)

	local quality = LibStub("tekKonfig-Slider").new(self, BrokerGarbage.locale.dropQualityTitle, 0, 6, "TOPLEFT", autosell, "BOTTOMLEFT", 2, -10)
	quality.tiptext = BrokerGarbage.locale.dropQualityText
	quality:SetWidth(200)
	quality:SetValueStep(1);
	quality:SetValue(BG_GlobalDB.dropQuality)
	quality.text = quality:CreateFontString("$parentCenterText", "ARTWORK", "GameFontHighlightSmall")
	quality.text:SetPoint("TOP", quality, "BOTTOM", 0, 3)
	quality.text:SetText(BrokerGarbage.quality[BG_GlobalDB.dropQuality])
	quality:SetScript("OnValueChanged", function(self)
		BG_GlobalDB.dropQuality = self:GetValue()
		self.text:SetText(BrokerGarbage.quality[self:GetValue()])
		BrokerGarbage:ScanInventory()
	end)
	
	local testValue = 130007
	local moneyFormat = LibStub("tekKonfig-Slider").new(self, BrokerGarbage.locale.moneyFormatTitle, 0, 4, "LEFT", quality, "RIGHT", 40, 0)
	moneyFormat.tiptext = BrokerGarbage.locale.moneyFormatText
	moneyFormat:SetWidth(200)
	moneyFormat:SetValueStep(1);
	moneyFormat:SetValue(BG_GlobalDB.showMoney)
	moneyFormat.text = moneyFormat:CreateFontString("$parentCenterText", "ARTWORK", "GameFontHighlightSmall")
	moneyFormat.text:SetPoint("TOP", moneyFormat, "BOTTOM", 0, 3)
	moneyFormat.text:SetText(BrokerGarbage:FormatMoney(testValue))
	moneyFormat:SetScript("OnValueChanged", function(self)
		BG_GlobalDB.showMoney = self:GetValue()
		self.text:SetText(BrokerGarbage:FormatMoney(testValue))
	end)
	
	
	local ttMaxItems = LibStub("tekKonfig-Slider").new(self, BrokerGarbage.locale.maxItemsTitle, 0, 50, "TOPLEFT", quality, "BOTTOMLEFT", 2, -15)
	ttMaxItems.tiptext = BrokerGarbage.locale.maxItemsText
	ttMaxItems:SetWidth(200)
	ttMaxItems:SetValueStep(1);
	ttMaxItems:SetValue(BG_GlobalDB.tooltipNumItems)
	ttMaxItems.text = ttMaxItems:CreateFontString("$parentCenterText", "ARTWORK", "GameFontHighlightSmall")
	ttMaxItems.text:SetPoint("TOP", ttMaxItems, "BOTTOM", 0, 3)
	ttMaxItems.text:SetText(ttMaxItems:GetValue())
	ttMaxItems:SetScript("OnValueChanged", function(self)
		BG_GlobalDB.tooltipNumItems = self:GetValue()
		self.text:SetText(self:GetValue())
	end)
	
	
	local ttMaxHeight = LibStub("tekKonfig-Slider").new(self, BrokerGarbage.locale.maxHeightTitle, 0, 400, "LEFT", ttMaxItems, "RIGHT", 40, 0)
	ttMaxHeight.tiptext = BrokerGarbage.locale.maxHeightText
	ttMaxHeight:SetWidth(200)
	ttMaxHeight:SetValueStep(10);
	ttMaxHeight:SetValue(BG_GlobalDB.tooltipMaxHeight)
	ttMaxHeight.text = ttMaxHeight:CreateFontString("$parentCenterText", "ARTWORK", "GameFontHighlightSmall")
	ttMaxHeight.text:SetPoint("TOP", ttMaxHeight, "BOTTOM", 0, 3)
	ttMaxHeight.text:SetText(ttMaxHeight:GetValue())
	ttMaxHeight:SetScript("OnValueChanged", function(self)
		BG_GlobalDB.tooltipMaxHeight = self:GetValue()
		self.text:SetText(self:GetValue())
	end)
	
	
	local rescan = LibStub("tekKonfig-Button").new_small(self, "TOPLEFT", ttMaxItems, "BOTTOMLEFT", 0, -50)
	rescan:SetText(BrokerGarbage.locale.rescanInventory)
	rescan.tiptext = BrokerGarbage.locale.rescanInventoryText
	rescan:SetWidth(150) rescan:SetHeight(18)
	rescan:SetScript("OnClick", function()
		BrokerGarbage:ScanInventory()
	end)
	
	local resetmoneylost = LibStub("tekKonfig-Button").new_small(self, "LEFT", rescan, "RIGHT", 40, 0)
	resetmoneylost:SetText(BrokerGarbage.locale.resetMoneyLost)
	resetmoneylost.tiptext = BrokerGarbage.locale.resetMoneyLostText
	resetmoneylost:SetWidth(150) resetmoneylost:SetHeight(18)
	resetmoneylost:SetScript("OnClick", function()
		BrokerGarbage:ResetMoneyLost()
	end)
	
	
	local excludeReset = LibStub("tekKonfig-Button").new_small(self, "TOPLEFT", rescan, "BOTTOMLEFT", 0, -50)
	excludeReset:SetText(BrokerGarbage.locale.emptyExcludeList)
	excludeReset.tiptext = BrokerGarbage.locale.emptyExcludeListText
	excludeReset:SetWidth(150) excludeReset:SetHeight(18)
	excludeReset:SetScript("OnClick", function()
		BG_GlobalDB.exclude = {}
	end)

	local includeReset = LibStub("tekKonfig-Button").new_small(self, "TOPLEFT", excludeReset, "BOTTOMLEFT", 0, -10)
	includeReset:SetText(BrokerGarbage.locale.emptyIncludeList)
	includeReset.tiptext = BrokerGarbage.locale.emptyIncludeListText
	includeReset:SetWidth(150) includeReset:SetHeight(18)
	includeReset:SetScript("OnClick", function()
		BG_GlobalDB.include = {}
	end)
	
	-- ----------------------------------
	

	self:SetScript("OnShow", nil)
end)	


InterfaceOptions_AddCategory(BrokerGarbage.options)
LibStub("tekKonfig-AboutPanel").new("Broker_Garbage", "Broker_Garbage")