_, BrokerGarbage = ...

BrokerGarbage:CheckSettings()

-- rarity strings (no need to localize)
BrokerGarbage.quality = {
	[0] = select(4,GetItemQualityColor(0))..ITEM_QUALITY0_DESC.."|r",
	[1] = select(4,GetItemQualityColor(1))..ITEM_QUALITY1_DESC.."|r",
	[2] = select(4,GetItemQualityColor(2))..ITEM_QUALITY2_DESC.."|r",
	[3] = select(4,GetItemQualityColor(3))..ITEM_QUALITY3_DESC.."|r",
	[4] = select(4,GetItemQualityColor(4))..ITEM_QUALITY4_DESC.."|r",
	[5] = select(4,GetItemQualityColor(5))..ITEM_QUALITY5_DESC.."|r",
	[6] = select(4,GetItemQualityColor(6))..ITEM_QUALITY6_DESC.."|r",
	}

-- create drop down menu table for PT sets	
local interestingPTSets = {"Consumable", "Misc", "Tradeskill"}

BrokerGarbage.PTSets = {}
for set, _ in pairs(BrokerGarbage.PT.sets) do
	local interesting = false
	local partials = { strsplit(".", set) }
	local maxParts = #partials
	
	for i=1,#interestingPTSets do
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

-- options panel / statistics
BrokerGarbage.options = CreateFrame("Frame", "BrokerGarbageOptionsFrame", InterfaceOptionsFramePanelContainer)
BrokerGarbage.options.name = "Broker_Garbage"
BrokerGarbage.options:Hide()

-- default / main options
BrokerGarbage.basicOptions = CreateFrame("Frame", "BrokerGarbageOptionsPositiveFrame", InterfaceOptionsFramePanelContainer)
BrokerGarbage.basicOptions.name = BrokerGarbage.locale.BasicOptionsTitle
BrokerGarbage.basicOptions.parent = "Broker_Garbage"
BrokerGarbage.basicOptions:Hide()

-- Loot Manager options
if BrokerGarbage.lootManager then
	BrokerGarbage.lootManagerOptions = CreateFrame("Frame", "BrokerGarbageOptionsFrame", InterfaceOptionsFramePanelContainer)
	BrokerGarbage.lootManagerOptions.name = BrokerGarbage.locale.LMTitle
	BrokerGarbage.lootManagerOptions.parent = "Broker_Garbage"
	BrokerGarbage.lootManagerOptions:Hide()
end

-- list options: positive panel
BrokerGarbage.listOptionsPositive = CreateFrame("Frame", "BrokerGarbageOptionsPositiveFrame", InterfaceOptionsFramePanelContainer)
BrokerGarbage.listOptionsPositive.name = BrokerGarbage.locale.LOPTitle
BrokerGarbage.listOptionsPositive.parent = "Broker_Garbage"
BrokerGarbage.listOptionsPositive:Hide()

-- list options: negative panel
BrokerGarbage.listOptionsNegative = CreateFrame("Frame", "BrokerGarbageOptionsNegativeFrame", InterfaceOptionsFramePanelContainer)
BrokerGarbage.listOptionsNegative.name = BrokerGarbage.locale.LONTitle
BrokerGarbage.listOptionsNegative.parent = "Broker_Garbage"
BrokerGarbage.listOptionsNegative:Hide()

-- lists that hold our iconbuttons
BrokerGarbage.listButtons = {
	-- positive
	exclude = {},
	forceprice = {},
	-- negative
	autosell = {},
	include = {},
}

-- button tooltip infos
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

local function ShowOptions(frame)
	-- ----------------------------------
	-- Statistics / Introductory frame
	-- ----------------------------------
	local title, subtitle = LibStub("tekKonfig-Heading").new(BrokerGarbage.options, "Broker_Garbage", BrokerGarbage.locale.StatisticsHeading)

	local memoryinfo = BrokerGarbage.options:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	memoryinfo:SetPoint("TOPLEFT", subtitle, "BOTTOMLEFT", 0, 0)
	memoryinfo:SetPoint("RIGHT", BrokerGarbage.options, -32, 0)
	memoryinfo:SetHeight(40)
	memoryinfo:SetNonSpaceWrap(true)
	memoryinfo:SetJustifyH("LEFT")
	memoryinfo:SetJustifyV("TOP")
	memoryinfo:SetText(BrokerGarbage.locale.MemoryUsageText)
	
	UpdateAddOnMemoryUsage()
	local memoryusage = BrokerGarbage.options:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
	memoryusage:SetWidth(150)
	memoryusage:SetPoint("TOPLEFT", memoryinfo, "BOTTOMLEFT", -2, 0)
	memoryusage:SetJustifyH("RIGHT")
	memoryusage:SetText(BrokerGarbage.locale.MemoryUsageTitle)
	local mutext = BrokerGarbage.options:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	mutext:SetWidth(120)
	mutext:SetPoint("LEFT", memoryusage, "RIGHT", 4, 0)
	mutext:SetJustifyH("LEFT")
	mutext:SetText(math.floor(GetAddOnMemoryUsage("Broker_Garbage")))	
	local muaction = CreateFrame("Button", nil, BrokerGarbage.options)
	muaction:SetPoint("LEFT", mutext, "RIGHT", 4, 0)
	muaction:SetWidth(16); muaction:SetHeight(16)
	muaction:SetNormalTexture("Interface\\RAIDFRAME\\ReadyCheck-Waiting")
	muaction.tiptext = BrokerGarbage.locale.CollectMemoryUsageTooltip
	muaction:SetScript("OnEnter", ShowTooltip)
	muaction:SetScript("OnLeave", HideTooltip)
	
	-- ----------------------------------------------------------------------------
	local globalmoneyinfo = BrokerGarbage.options:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	globalmoneyinfo:SetPoint("TOPLEFT", memoryusage, "BOTTOMLEFT", 0, -12)
	globalmoneyinfo:SetPoint("RIGHT", BrokerGarbage.options, -32, 0)
	globalmoneyinfo:SetNonSpaceWrap(true)
	globalmoneyinfo:SetJustifyH("LEFT")
	globalmoneyinfo:SetJustifyV("TOP")
	globalmoneyinfo:SetText(BrokerGarbage.locale.GlobalStatisticsHeading)
	
	local globalearned = BrokerGarbage.options:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
	globalearned:SetWidth(150)
	globalearned:SetPoint("TOPLEFT", globalmoneyinfo, "BOTTOMLEFT", 0, -15)
	globalearned:SetJustifyH("RIGHT")
	globalearned:SetText(BrokerGarbage.locale.GlobalMoneyEarnedTitle)
	local getext = BrokerGarbage.options:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	getext:SetWidth(120)
	getext:SetPoint("LEFT", globalearned, "RIGHT", 4, 0)
	getext:SetJustifyH("LEFT")
	getext:SetText(BrokerGarbage:FormatMoney(BG_GlobalDB.moneyEarned))
	local geaction = CreateFrame("Button", nil, BrokerGarbage.options)
	geaction:SetPoint("LEFT", getext, "RIGHT", 4, 0)
	geaction:SetWidth(16); geaction:SetHeight(16)
	geaction:SetNormalTexture("Interface\\RAIDFRAME\\ReadyCheck-NotReady")
	geaction.tiptext = BrokerGarbage.locale.ResetGlobalMoneyEarnedTooltip
	geaction:SetScript("OnEnter", ShowTooltip)
	geaction:SetScript("OnLeave", HideTooltip)
	
	local itemssold = BrokerGarbage.options:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
	itemssold:SetWidth(150)
	itemssold:SetPoint("TOPLEFT", globalearned, "BOTTOMLEFT", 0, -6)
	itemssold:SetJustifyH("RIGHT")
	itemssold:SetText(BrokerGarbage.locale.GlobalItemsSoldTitle)
	local istext = BrokerGarbage.options:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	istext:SetWidth(120)
	istext:SetPoint("LEFT", itemssold, "RIGHT", 4, 0)
	istext:SetJustifyH("LEFT")
	istext:SetText(BG_GlobalDB.itemsSold)
	local isaction = CreateFrame("Button", nil, BrokerGarbage.options)
	isaction:SetPoint("LEFT", istext, "RIGHT", 4, 0)
	isaction:SetWidth(16); isaction:SetHeight(16)
	isaction:SetNormalTexture("Interface\\RAIDFRAME\\ReadyCheck-NotReady")
	isaction.tiptext = BrokerGarbage.locale.ResetGlobalItemsSoldTooltip
	isaction:SetScript("OnEnter", ShowTooltip)
	isaction:SetScript("OnLeave", HideTooltip)
	
	local avgsold = BrokerGarbage.options:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
	avgsold:SetWidth(150)
	avgsold:SetPoint("TOPLEFT", itemssold, "BOTTOMLEFT", 0, -6)
	avgsold:SetJustifyH("RIGHT")
	avgsold:SetText(BrokerGarbage.locale.AverageSellValueTitle)
	local astext = BrokerGarbage.options:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	astext:SetWidth(120)
	astext:SetPoint("LEFT", avgsold, "RIGHT", 4, 0)
	astext:SetJustifyH("LEFT")
	astext:SetText(BrokerGarbage:FormatMoney(math.floor(BG_GlobalDB.moneyEarned / (BG_GlobalDB.itemsSold ~= 0 and BG_GlobalDB.itemsSold or 1))))
	
	-- ----------------------------------------------------------------------------	
	local globallost = BrokerGarbage.options:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
	globallost:SetWidth(150)
	globallost:SetPoint("TOPLEFT", avgsold, "BOTTOMLEFT", 0, -15)
	globallost:SetJustifyH("RIGHT")
	globallost:SetText(BrokerGarbage.locale.GlobalMoneyLostTitle)
	local gltext = BrokerGarbage.options:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	gltext:SetWidth(120)
	gltext:SetPoint("LEFT", globallost, "RIGHT", 4, 0)
	gltext:SetJustifyH("LEFT")
	gltext:SetText(BrokerGarbage:FormatMoney(BG_GlobalDB.moneyLostByDeleting))
	local glaction = CreateFrame("Button", nil, BrokerGarbage.options)
	glaction:SetPoint("LEFT", gltext, "RIGHT", 4, 0)
	glaction:SetWidth(16); glaction:SetHeight(16)
	glaction:SetNormalTexture("Interface\\RAIDFRAME\\ReadyCheck-NotReady")
	glaction.tiptext = BrokerGarbage.locale.ResetGlobalMoneyLostTooltip
	glaction:SetScript("OnEnter", ShowTooltip)
	glaction:SetScript("OnLeave", HideTooltip)
	
	local itemsdropped = BrokerGarbage.options:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
	itemsdropped:SetWidth(150)
	itemsdropped:SetPoint("TOPLEFT", globallost, "BOTTOMLEFT", 0, -6)
	itemsdropped:SetJustifyH("RIGHT")
	itemsdropped:SetText(BrokerGarbage.locale.ItemsDroppedTitle)
	local idtext = BrokerGarbage.options:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	idtext:SetWidth(120)
	idtext:SetPoint("LEFT", itemsdropped, "RIGHT", 4, 0)
	idtext:SetJustifyH("LEFT")
	idtext:SetText(BG_GlobalDB.itemsDropped)
	local idaction = CreateFrame("Button", nil, BrokerGarbage.options)
	idaction:SetPoint("LEFT", idtext, "RIGHT", 4, 0)
	idaction:SetWidth(16); idaction:SetHeight(16)
	idaction:SetNormalTexture("Interface\\RAIDFRAME\\ReadyCheck-NotReady")
	idaction.tiptext = BrokerGarbage.locale.ResetGlobalItemsDroppedTooltip
	idaction:SetScript("OnEnter", ShowTooltip)
	idaction:SetScript("OnLeave", HideTooltip)

	local avglost = BrokerGarbage.options:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
	avglost:SetWidth(150)
	avglost:SetPoint("TOPLEFT", itemsdropped, "BOTTOMLEFT", 0, -6)
	avglost:SetJustifyH("RIGHT")
	avglost:SetText(BrokerGarbage.locale.AverageDropValueTitle)
	local altext = BrokerGarbage.options:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	altext:SetWidth(120)
	altext:SetPoint("LEFT", avglost, "RIGHT", 4, 0)
	altext:SetJustifyH("LEFT")
	altext:SetText(BrokerGarbage:FormatMoney(math.floor(BG_GlobalDB.moneyLostByDeleting / (BG_GlobalDB.itemsDropped ~= 0 and BG_GlobalDB.itemsDropped or 1))))
	
	-- ----------------------------------------------------------------------------
	local localmoneyinfo = BrokerGarbage.options:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	localmoneyinfo:SetPoint("TOPLEFT", avglost, "BOTTOMLEFT", 0, -12)
	localmoneyinfo:SetPoint("RIGHT", BrokerGarbage.options, -32, 0)
	localmoneyinfo:SetNonSpaceWrap(true)
	localmoneyinfo:SetJustifyH("LEFT")
	localmoneyinfo:SetJustifyV("TOP")
	localmoneyinfo:SetText(format(BrokerGarbage.locale.LocalStatisticsHeading, UnitName("player")))
	
	local localearned = BrokerGarbage.options:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
	localearned:SetWidth(150)
	localearned:SetPoint("TOPLEFT", localmoneyinfo, "BOTTOMLEFT", 0, -15)
	localearned:SetJustifyH("RIGHT")
	localearned:SetText(BrokerGarbage.locale.StatisticsLocalAmountEarned)
	local letext = BrokerGarbage.options:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	letext:SetWidth(120)
	letext:SetPoint("LEFT", localearned, "RIGHT", 4, 0)
	letext:SetJustifyH("LEFT")
	letext:SetText(BrokerGarbage:FormatMoney(BG_LocalDB.moneyEarned))
	local leaction = CreateFrame("Button", nil, BrokerGarbage.options)
	leaction:SetPoint("LEFT", letext, "RIGHT", 4, 0)
	leaction:SetWidth(16); leaction:SetHeight(16)
	leaction:SetNormalTexture("Interface\\RAIDFRAME\\ReadyCheck-NotReady")
	leaction.tiptext = BrokerGarbage.locale.ResetLocalMoneyEarnedTooltip
	leaction:SetScript("OnEnter", ShowTooltip)
	leaction:SetScript("OnLeave", HideTooltip)
	
	local locallost = BrokerGarbage.options:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
	locallost:SetWidth(150)
	locallost:SetPoint("TOPLEFT", localearned, "BOTTOMLEFT", 0, -15)
	locallost:SetJustifyH("RIGHT")
	locallost:SetText(BrokerGarbage.locale.StatisticsLocalAmountLost)
	local lltext = BrokerGarbage.options:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	lltext:SetWidth(120)
	lltext:SetPoint("LEFT", locallost, "RIGHT", 4, 0)
	lltext:SetJustifyH("LEFT")
	lltext:SetText(BrokerGarbage:FormatMoney(BG_LocalDB.moneyLostByDeleting))
	local llaction = CreateFrame("Button", nil, BrokerGarbage.options)
	llaction:SetPoint("LEFT", lltext, "RIGHT", 4, 0)
	llaction:SetWidth(16); llaction:SetHeight(16)
	llaction:SetNormalTexture("Interface\\RAIDFRAME\\ReadyCheck-NotReady")
	llaction.tiptext = BrokerGarbage.locale.ResetLocalMoneyLostTooltip
	llaction:SetScript("OnEnter", ShowTooltip)
	llaction:SetScript("OnLeave", HideTooltip)
	
	-- ----------------------------------------------------------------------------
	-- omg-i-reset-everything!!!!!! buttons
	local globalreset = LibStub("tekKonfig-Button").new(BrokerGarbage.options, "TOPLEFT", locallost, "BOTTOMLEFT", 0, -30)
	globalreset:SetText(BrokerGarbage.locale.ResetGlobalDataText)
	globalreset.tiptext = BrokerGarbage.locale.ResetGlobalDataTooltip
	globalreset:SetWidth(150)
	globalreset:SetScript("OnClick", function()
		BrokerGarbage:ResetAll(true)
		UpdateStats()
	end)
	
	local localreset = LibStub("tekKonfig-Button").new(BrokerGarbage.options, "TOPLEFT", globalreset, "TOPRIGHT", 20, 0)
	localreset:SetText(BrokerGarbage.locale.ResetLocalDataText)
	localreset.tiptext = BrokerGarbage.locale.ResetLocalDataTooltip
	localreset:SetWidth(150)
	localreset:SetScript("OnClick", function()
		BrokerGarbage:ResetAll(false)
		UpdateStats()
	end)
	
	-- when panel is shown this will update the statistics data
	local function UpdateStats()
		UpdateAddOnMemoryUsage()
		mutext:SetText(math.floor(GetAddOnMemoryUsage("Broker_Garbage")))
		
		getext:SetText(BrokerGarbage:FormatMoney(BG_GlobalDB.moneyEarned))
		istext:SetText(BG_GlobalDB.itemsSold)
		gltext:SetText(BrokerGarbage:FormatMoney(BG_GlobalDB.moneyLostByDeleting))
		idtext:SetText(BG_GlobalDB.itemsDropped)
		
		astext:SetText(BrokerGarbage:FormatMoney(math.floor(BG_GlobalDB.moneyEarned / (BG_GlobalDB.itemsSold ~= 0 and BG_GlobalDB.itemsSold or 1))))
		altext:SetText(BrokerGarbage:FormatMoney(math.floor(BG_GlobalDB.moneyLostByDeleting / (BG_GlobalDB.itemsDropped ~= 0 and BG_GlobalDB.itemsDropped or 1))))
		
		letext:SetText(BrokerGarbage:FormatMoney(BG_LocalDB.moneyEarned))
		lltext:SetText(BrokerGarbage:FormatMoney(BG_LocalDB.moneyLostByDeleting))
	end
	
	local function OnClick(self)
		if self == muaction then
			collectgarbage("collect")
		elseif self == geaction then
			BrokerGarbage:ResetMoney("earned", true)
		elseif self == glaction then
			BrokerGarbage:ResetMoney("lost", true)
		elseif self == idaction then
			BG_GlobalDB.itemsDropped = 0
		elseif self == isaction then
			BG_GlobalDB.itemsSold = 0
		elseif self == leaction then
			BG_LocalDB.moneyEarned = 0
		elseif self == llaction then
			BG_LocalDB.moneyLostByDeleting = 0
		end
		
		UpdateStats()
	end
	muaction:SetScript("OnClick", OnClick)
	geaction:SetScript("OnClick", OnClick)
	isaction:SetScript("OnClick", OnClick)
	glaction:SetScript("OnClick", OnClick)
	idaction:SetScript("OnClick", OnClick)
	leaction:SetScript("OnClick", OnClick)
	llaction:SetScript("OnClick", OnClick)
	
	-- ----------------------------------
	-- Basic Options
	-- ----------------------------------
	local title0, subtitle0 = LibStub("tekKonfig-Heading").new(BrokerGarbage.basicOptions, "Broker_Garbage - "..BrokerGarbage.locale.BasicOptionsTitle, BrokerGarbage.locale.BasicOptionsText)

	local autosell = LibStub("tekKonfig-Checkbox").new(BrokerGarbage.basicOptions, nil, BrokerGarbage.locale.autoSellTitle, "TOPLEFT", subtitle0, "BOTTOMLEFT", -2, -4)
	autosell.tiptext = BrokerGarbage.locale.autoSellText
	autosell:SetChecked(BG_GlobalDB.autoSellToVendor)
	local checksound = autosell:GetScript("OnClick")
	autosell:SetScript("OnClick", function(autosell)
		checksound(autosell)
		BG_GlobalDB.autoSellToVendor = not BG_GlobalDB.autoSellToVendor
	end)
	
	local autosellicon = LibStub("tekKonfig-Checkbox").new(BrokerGarbage.basicOptions, nil, BrokerGarbage.locale.showAutoSellIconTitle, "TOPLEFT", autosell, "BOTTOMLEFT", 14, 0)
	autosellicon.tiptext = BrokerGarbage.locale.showAutoSellIconText
	autosellicon:SetChecked(BG_GlobalDB.showAutoSellIcon)
	local checksound = autosellicon:GetScript("OnClick")
	autosellicon:SetScript("OnClick", function(autosellicon)
		checksound(autosellicon)
		BG_GlobalDB.showAutoSellIcon = not BG_GlobalDB.showAutoSellIcon
	end)
	
	local nothingtext = LibStub("tekKonfig-Checkbox").new(BrokerGarbage.basicOptions, nil, BrokerGarbage.locale.showNothingToSellTitle, "TOPLEFT", autosellicon, "BOTTOMLEFT", 0, 0)
	nothingtext.tiptext = BrokerGarbage.locale.showNothingToSellText
	nothingtext:SetChecked(BG_GlobalDB.reportNothingToSell)
	local checksound = nothingtext:GetScript("OnClick")
	nothingtext:SetScript("OnClick", function(nothingtext)
		checksound(nothingtext)
		BG_GlobalDB.reportNothingToSell = not BG_GlobalDB.reportNothingToSell
	end)

	local autorepair = LibStub("tekKonfig-Checkbox").new(BrokerGarbage.basicOptions, nil, BrokerGarbage.locale.autoRepairTitle, "LEFT", autosell, "LEFT", 200, 0)
	autorepair.tiptext = BrokerGarbage.locale.autoRepairText
	autorepair:SetChecked(BG_GlobalDB.autoRepairAtVendor)
	local checksound = autorepair:GetScript("OnClick")
	autorepair:SetScript("OnClick", function(autorepair)
		checksound(autorepair)
		BG_GlobalDB.autoRepairAtVendor = not BG_GlobalDB.autoRepairAtVendor
	end)

	local guildrepair = LibStub("tekKonfig-Checkbox").new(BrokerGarbage.basicOptions, nil, BrokerGarbage.locale.autoRepairGuildTitle, "TOPLEFT", autorepair, "BOTTOMLEFT", 14, 0)
	guildrepair.tiptext = BrokerGarbage.locale.autoRepairGuildText
	guildrepair:SetChecked(BG_LocalDB.neverRepairGuildBank)
	local checksound = guildrepair:GetScript("OnClick")
	guildrepair:SetScript("OnClick", function(guildrepair)
		checksound(guildrepair)
		BG_LocalDB.neverRepairGuildBank = not BG_LocalDB.neverRepairGuildBank
	end)
	
	local showlost = LibStub("tekKonfig-Checkbox").new(BrokerGarbage.basicOptions, nil, BrokerGarbage.locale.showLostTitle, "TOPLEFT", nothingtext, "BOTTOMLEFT", -14, -10)
	showlost.tiptext = BrokerGarbage.locale.showLostText
	showlost:SetChecked(BG_GlobalDB.showLost)
	local checksound = showlost:GetScript("OnClick")
	showlost:SetScript("OnClick", function(showlost)
		checksound(showlost)
		BG_GlobalDB.showLost = not BG_GlobalDB.showLost
	end)
	
	local showearned = LibStub("tekKonfig-Checkbox").new(BrokerGarbage.basicOptions, nil, BrokerGarbage.locale.showEarnedTitle, "LEFT", showlost, "LEFT", 200, 0)
	showearned.tiptext = BrokerGarbage.locale.showEarnedText
	showearned:SetChecked(BG_GlobalDB.showEarned)
	local checksound = showearned:GetScript("OnClick")
	showearned:SetScript("OnClick", function(showearned)
		checksound(showearned)
		BG_GlobalDB.showEarned = not BG_GlobalDB.showEarned
	end)

	local quality = LibStub("tekKonfig-Slider").new(BrokerGarbage.basicOptions, BrokerGarbage.locale.dropQualityTitle, 0, 6, "TOPLEFT", showlost, "BOTTOMLEFT", 5, -20)
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
	local moneyFormat = LibStub("tekKonfig-Slider").new(BrokerGarbage.basicOptions, BrokerGarbage.locale.moneyFormatTitle, 0, 4, "LEFT", quality, "LEFT", 200, 0)
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

	local ttMaxItems = LibStub("tekKonfig-Slider").new(BrokerGarbage.basicOptions, BrokerGarbage.locale.maxItemsTitle, 0, 50, "TOPLEFT", quality, "BOTTOMLEFT", 0, -15)
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

	local ttMaxHeight = LibStub("tekKonfig-Slider").new(BrokerGarbage.basicOptions, BrokerGarbage.locale.maxHeightTitle, 0, 400, "LEFT", ttMaxItems, "LEFT", 200, 0)
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
	
	local rescan = LibStub("tekKonfig-Button").new(BrokerGarbage.basicOptions, "TOPLEFT", ttMaxItems, "BOTTOMLEFT", 0, -20)
	rescan:SetText(BrokerGarbage.locale.rescanInventory)
	rescan.tiptext = BrokerGarbage.locale.rescanInventoryText
	rescan:SetWidth(150)
	rescan:SetScript("OnClick", function()
		BrokerGarbage:ScanInventory()
	end)
	
	local showsource = LibStub("tekKonfig-Checkbox").new(BrokerGarbage.basicOptions, nil, BrokerGarbage.locale.showSourceTitle, "TOPLEFT", rescan, "TOPRIGHT", 50, 0)
	showsource.tiptext = BrokerGarbage.locale.showSourceText
	showsource:SetChecked(BG_GlobalDB.showSource)
	local checksound = showsource:GetScript("OnClick")
	showsource:SetScript("OnClick", function(showsource)
		checksound(showsource)
		BG_GlobalDB.showSource = not BG_GlobalDB.showSource
	end)
	
	local resetexclude = LibStub("tekKonfig-Button").new(BrokerGarbage.basicOptions, "TOPLEFT", rescan, "BOTTOMLEFT", 0, -10)
	resetexclude:SetText(BrokerGarbage.locale.emptyExcludeList)
	resetexclude.tiptext = BrokerGarbage.locale.emptyExcludeListText
	resetexclude:SetWidth(150)
	resetexclude:SetScript("OnClick", function()
		BrokerGarbage:ResetList("exclude")
	end)
	
	local resetinclude = LibStub("tekKonfig-Button").new(BrokerGarbage.basicOptions, "TOPLEFT", showsource, "BOTTOMLEFT", 0, -10)
	resetinclude:SetText(BrokerGarbage.locale.emptyIncludeList)
	resetinclude.tiptext = BrokerGarbage.locale.emptyIncludeListText
	resetinclude:SetWidth(150)
	resetinclude:SetScript("OnClick", function()
		BrokerGarbage:ResetList("include")
	end)
	
	local editbox = CreateFrame("EditBox", nil, BrokerGarbage.basicOptions)
	editbox:SetAutoFocus(false)
	editbox:SetWidth(150); editbox:SetHeight(32)
	editbox:SetFontObject("GameFontHighlightSmall")
	editbox:SetText(BG_GlobalDB.LDBformat)
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

	local LDBtext = editbox:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
	LDBtext:SetPoint("TOPLEFT", resetexclude, "BOTTOMLEFT", 0, -20)
	LDBtext:SetText(BrokerGarbage.locale.LDBDisplayTextTitle)
	editbox:SetPoint("LEFT", LDBtext, "RIGHT", 20, 0)
	local function ResetEditBox(self)
		self:SetText(BG_GlobalDB.LDBformat)
		self:ClearFocus()
		BrokerGarbage:ScanInventory()
	end
	local function SubmitEditBox()
		BG_GlobalDB.LDBformat = editbox:GetText()
		editbox:ClearFocus()
		BrokerGarbage:ScanInventory()
	end
	local function ResetEditBoxDefault()
		BG_GlobalDB.LDBformat = "%1$sx%2$d (%3$s)"
		editbox:SetText(BG_GlobalDB.LDBformat)
		editbox:ClearFocus()
		BrokerGarbage:ScanInventory()
	end
	editbox:SetScript("OnEscapePressed", ResetEditBox)
	editbox:SetScript("OnEnterPressed", SubmitEditBox)
	
	local editHelp = CreateFrame("Button", nil, BrokerGarbage.basicOptions)
	editHelp:SetPoint("LEFT", editbox, "RIGHT", 4, 0)
	editHelp:SetWidth(16); editHelp:SetHeight(16)
	editHelp:SetNormalTexture("Interface\\RAIDFRAME\\ReadyCheck-Waiting")
	editHelp.tiptext = BrokerGarbage.locale.LDBDisplayTextHelpTooltip
	editHelp:SetScript("OnEnter", ShowTooltip)
	editHelp:SetScript("OnLeave", HideTooltip)
	local editReset = CreateFrame("Button", nil, BrokerGarbage.basicOptions)
	editReset:SetPoint("LEFT", editHelp, "RIGHT", 2, 0)
	editReset:SetWidth(16); editReset:SetHeight(16)
	editReset:SetNormalTexture("Interface\\RAIDFRAME\\ReadyCheck-NotReady")
	editReset.tiptext = BrokerGarbage.locale.LDBDisplayTextResetTooltip
	editReset:SetScript("OnEnter", ShowTooltip)
	editReset:SetScript("OnLeave", HideTooltip)	
	editReset:SetScript("OnClick", ResetEditBoxDefault)	
	
	BrokerGarbage.options:SetScript("OnShow", UpdateStats)
	BrokerGarbage.basicOptions:SetScript("OnShow", UpdateStats)
end

local function ShowListOptions(frame)
	-- List Options
	-- ----------------------------------
	local boxHeight = 150
	local boxWidth = 330
	
	local backdrop = {
		bgFile = "Interface\\ChatFrame\\ChatFrameBackground", insets = {left = 4, right = 4, top = 4, bottom = 4},
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 16
	}
	
	-- ----------------------------------
	--	Positive Lists
	-- ----------------------------------
	local title, subtitle = LibStub("tekKonfig-Heading").new(BrokerGarbage.listOptionsPositive, "Broker_Garbage - " .. BrokerGarbage.locale.LOPTitle , BrokerGarbage.locale.LOPSubTitle)
	
	-- list frame: exclude
	local excludeListHeader = BrokerGarbage.listOptionsPositive:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	excludeListHeader:SetHeight(32)
	excludeListHeader:SetPoint("TOPLEFT", subtitle, "BOTTOMLEFT", 0, 14)
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
	local title2, subtitle2 = LibStub("tekKonfig-Heading").new(BrokerGarbage.listOptionsNegative, "Broker_Garbage - " .. BrokerGarbage.locale.LONTitle , BrokerGarbage.locale.LONSubTitle)
	
	-- list frame: include
	local includeListHeader = BrokerGarbage.listOptionsNegative:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	includeListHeader:SetHeight(32)
	includeListHeader:SetPoint("TOPLEFT", subtitle2, "BOTTOMLEFT", 0, 14)
	includeListHeader:SetText(BrokerGarbage.locale.LONIncludeHeader)
	
	local includeBox = CreateFrame("ScrollFrame", "BG_IncludeListBox", BrokerGarbage.listOptionsNegative, "UIPanelScrollFrameTemplate")
	includeBox:SetPoint("TOPLEFT", includeListHeader, "BOTTOMLEFT", 0, 4)
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
	plus3:SetPoint("TOPLEFT", "BG_IncludeListBoxScrollBar", "TOPRIGHT", 8, -3)
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
	autosellListHeader:SetPoint("TOPLEFT", includeBox, "BOTTOMLEFT", 0, -8)
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
	
	-- function to set the drop treshold (limit) via the mousewheel
	local function OnMouseWheel(self, dir)
		if type(self.itemID) ~= "number" then return end
		BrokerGarbage.debug = self
		local list, text
		
		if dir == 1 then
			-- up
			if self.isGlobal then
				list = BG_GlobalDB[self.list]
			else
				list = BG_LocalDB[self.list]
			end
			
			-- change stuff
			if list[self.itemID] == true then
				list[self.itemID] = 1
			else
				list[self.itemID] = list[self.itemID] + 1
			end
			self.limit:SetText(list[self.itemID])
			
		else
			-- down
			if self.isGlobal then
				list = BG_GlobalDB[self.list]
			else
				list = BG_LocalDB[self.list]
			end
			
			-- change stuff
			if list[self.itemID] == true then
				text = ""
			elseif list[self.itemID] == 1 then
				list[self.itemID] = true
				text = ""
			else
				list[self.itemID] = list[self.itemID] - 1
				text = list[self.itemID]
			end
			self.limit:SetText(text)
		end
	end
	
	local numCols = 8
	-- function that updates & shows items from various lists
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
		
		-- make this table sortable
		data = {}
		for key, value in pairs(dataList) do
			table.insert(data, key)
		end
		
		table.sort(data, function(a,b)
			if type(a) == "string" and type(b) == "string" then
				return a<b
			elseif type(a) == "number" and type(b) == "number" then
				return (GetItemInfo(a) or "z") < (GetItemInfo(b) or "z")
			else
				return type(a) == "string"
			end
		end)

		if not buttonList then buttonList = {} end
		
		local index = 1
		--for itemID,_ in pairs(dataList) do
		for i=1, #data do
			local itemID = data[i]
			if buttonList[index] then
				-- use available button
				local button = buttonList[index]
				local itemLink, texture
				if type(itemID) ~= "number" then
					-- this is an item category
					itemLink = nil
					button.tiptext = itemID		-- category description string
					texture = "Interface\\Icons\\Trade_engineering"
					
				else
					-- this is an explicit item
					_, itemLink, _, _, _, _, _, _, _, texture, _ = GetItemInfo(itemID)
				end
				
				if texture then
					-- everything's fine
					button.itemID = itemID
					button.itemLink = itemLink
					button.isGlobal = globalList[itemID] or false
					button.limit:SetText((button.isGlobal and globalList[itemID] ~= true and globalList[itemID]) 
						or (localList[itemID] ~= true and localList[itemID]) or "")
					button:SetNormalTexture(texture)
					button:GetNormalTexture():SetDesaturated(button.isGlobal)		-- desaturate global list items
				else
					-- an item the server has not seen
					button.itemID = itemID
					button.tiptext = "ID: "..itemID
					button:SetNormalTexture("Interface\\Icons\\Inv_misc_questionmark")
				end
				button.list = listName
				button:SetChecked(false)
				button:Show()
			else
				-- create another button
				local iconbutton = CreateFrame("CheckButton", nil, parent)
				iconbutton:Hide()
				iconbutton:SetWidth(36)
				iconbutton:SetHeight(36)

				local limit = iconbutton:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
				limit:SetPoint("BOTTOMLEFT", iconbutton, "BOTTOMLEFT", 2, 1)
				limit:SetPoint("BOTTOMLEFT", iconbutton, "BOTTOMLEFT", 2, 1)
				limit:SetPoint("BOTTOMRIGHT", iconbutton, "BOTTOMRIGHT", -3, 1)
				limit:SetHeight(20)
				limit:SetJustifyH("RIGHT")
				limit:SetJustifyV("BOTTOM")
				limit:SetText("")
				
				iconbutton.limit = limit
				
				iconbutton:SetNormalTexture("Interface\\Icons\\Inv_misc_questionmark")
				iconbutton:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square")
				iconbutton:SetCheckedTexture("Interface\\Buttons\\UI-Button-Outline")
				iconbutton:SetChecked(false)
				local tex = iconbutton:GetCheckedTexture()
				tex:ClearAllPoints()
				tex:SetPoint("CENTER")
				tex:SetWidth(36/37*66) tex:SetHeight(36/37*66)
				
				iconbutton:SetScript("OnClick", function(self)
					local check = self:GetChecked()
					BrokerGarbage:Debug("OnClick", check)
					
					if IsModifiedClick("CHATLINK") and ChatFrameEditBox:IsVisible() then
						-- post item link
						ChatFrameEditBox:Insert(self.itemLink)
						self:SetChecked(not check)
					elseif not IsModifierKeyDown() then
						self:SetChecked(check)
					else
						self:SetChecked(not check)
					end
				end)
				iconbutton:SetScript("OnEnter", ShowTooltip)
				iconbutton:SetScript("OnLeave", HideTooltip)
				if listName == "include" then
					iconbutton:EnableMouseWheel(true)
					iconbutton:SetScript("OnMouseWheel", OnMouseWheel)
				end
				
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
		local cursorType, itemID, link = GetCursorInfo()
		
		if (not itemID and (item == "RightButton" or item == "LeftButton" or item == "MiddleButton")) then
			return
		end
		
		-- find the item we want to add
		if itemID then
			-- real items
			itemID = itemID
		else
			-- category strings
			itemID = item
		end
		
		-- create "link" for output
		if type(itemID) == "number" then
			link = select(2, GetItemInfo(itemID))
		else
			link = itemID
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
		
		BrokerGarbage:ScanInventory()
		MerchantFrame_UpdateRepairButtons()
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
		elseif self == emptyForcePriceList then
			BG_LocalDB.forceVendorPrice = {}
			BrokerGarbage:ListOptionsUpdate("forceprice")
		elseif self == emptyIncludeList then
			BG_LocalDB.include = {}
			BrokerGarbage:ListOptionsUpdate("include")
		elseif self == emptyAutoSellList then
			BG_LocalDB.autoSellList = {}
			BrokerGarbage:ListOptionsUpdate("autosell")
		
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
					BG_GlobalDB.exclude[button.itemID] = BG_LocalDB.exclude[button.itemID]
				end
			end
			BrokerGarbage:ListOptionsUpdate("exclude")
		elseif self == promote3 then
			for i, button in pairs(BrokerGarbage.listButtons.include) do
				if button:GetChecked() then
					BG_GlobalDB.include[button.itemID] = BG_LocalDB.include[button.itemID]
				end
			end
			BrokerGarbage:ListOptionsUpdate("include")
		elseif self == promote3 then
			for i, button in pairs(BrokerGarbage.listButtons.autosell) do
				if button:GetChecked() then
					BG_GlobalDB.autoSellList[button.itemID] = BG_LocalDB.autoSellList[button.itemID]
				end
			end
			BrokerGarbage:ListOptionsUpdate("autosell")
		end
		
		BrokerGarbage:ScanInventory()
		MerchantFrame_UpdateRepairButtons()
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
	
	BrokerGarbage:ListOptionsUpdate()
	BrokerGarbage.listOptionsPositive:SetScript("OnShow", BrokerGarbage.ListOptionsUpdate)
	BrokerGarbage.listOptionsNegative:SetScript("OnShow", BrokerGarbage.ListOptionsUpdate)
	BrokerGarbage.optionsLoaded = true
end

-- show me!
BrokerGarbage.options:SetScript("OnShow", ShowOptions)
BrokerGarbage.basicOptions:SetScript("OnShow", ShowOptions)
BrokerGarbage.listOptionsPositive:SetScript("OnShow", ShowListOptions)
BrokerGarbage.listOptionsNegative:SetScript("OnShow", ShowListOptions)

InterfaceOptions_AddCategory(BrokerGarbage.options)
InterfaceOptions_AddCategory(BrokerGarbage.basicOptions)
InterfaceOptions_AddCategory(BrokerGarbage.lootManagerOptions)
InterfaceOptions_AddCategory(BrokerGarbage.listOptionsPositive)
InterfaceOptions_AddCategory(BrokerGarbage.listOptionsNegative)
LibStub("tekKonfig-AboutPanel").new("Broker_Garbage", "Broker_Garbage")

-- register slash commands
SLASH_BROKERGARBAGE1 = "/garbage"
SLASH_BROKERGARBAGE2 = "/garb"
function SlashCmdList.BROKERGARBAGE(msg, editbox)
	local command, rest = msg:match("^(%S*)%s*(.-)$")
	local command = strlower(command)
	
	if command == "format" then
		if strlower(rest) ~= "reset" then
			BG_GlobalDB.LDBformat = rest
		else
			BG_GlobalDB.LDBformat = "%1$sx%2$d (%3$s)"
		end
		BrokerGarbage:ScanInventory()
	elseif command == "trash" or command == "stats" or command == "total" then
		BrokerGarbage:Print(format(BrokerGarbage.locale.statistics, 
			BrokerGarbage:FormatMoney(BG_GlobalDB.moneyEarned), 
			BrokerGarbage:FormatMoney(BG_GlobalDB.moneyLostByDeleting)))
		
	elseif command == "options" or command == "config" or command == "option" or command == "menu" then
		InterfaceOptionsFrame_OpenToCategory(BrokerGarbage.options)
		
	elseif command == "limit" or command == "glimit" or command == "globallimit" then
		local itemID, count = rest:match("^[^0-9]-([0-9]+).-([0-9]+)$")
		itemID = tonumber(itemID)
		count = tonumber(count)
		
		if string.find(command, "g") then
			BG_GlobalDB.include[itemID] = count
		else
			BG_LocalDB.include[itemID] = count
		end
		local itemLink = select(2,GetItemInfo(itemID))
		BrokerGarbage:Print(format(BrokerGarbage.locale.limitSet, itemLink, count))
		BrokerGarbage:ListOptionsUpdate("include")
		
	else
		BrokerGarbage:Print(BrokerGarbage.locale.slashCommandHelp)
	end
end