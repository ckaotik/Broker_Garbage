_, BrokerGarbage = ...

-- create drop down menu table for PT sets	
local interestingPTSets = {"Consumable", "Misc", "Tradeskill"}

BrokerGarbage.PTSets = {}
local sets
if not BrokerGarbage.PT then
	sets = {}
else
	sets = BrokerGarbage.PT.sets
end
for set, _ in pairs(sets) do
	local interesting = false
	local partials = { strsplit(".", set) }
	local maxParts = #partials
	
	for i = 1, #interestingPTSets do
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
BrokerGarbage.options = CreateFrame("Frame", "BG_Statistics", InterfaceOptionsFramePanelContainer)
BrokerGarbage.options.name = "Broker_Garbage"
BrokerGarbage.options:Hide()

-- default / main options
BrokerGarbage.basicOptions = CreateFrame("Frame", "BG_BasicOptions", InterfaceOptionsFramePanelContainer)
BrokerGarbage.basicOptions.name = BrokerGarbage.locale.BasicOptionsTitle
BrokerGarbage.basicOptions.parent = "Broker_Garbage"
BrokerGarbage.basicOptions:Hide()

-- list options
BrokerGarbage.listOptions = CreateFrame("Frame", "BG_ListOptions", InterfaceOptionsFramePanelContainer)
BrokerGarbage.listOptions.name = BrokerGarbage.locale.LOTitle
BrokerGarbage.listOptions.parent = "Broker_Garbage"
BrokerGarbage.listOptions:Hide()

-- lists that hold our buttons
BrokerGarbage.listButtons = {}

-- button tooltip infos
local function ShowTooltip(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	if self.tiptext and self.itemID and self.tiptext ~= "ID: "..self.itemID then
		local text = string.gsub(self.tiptext, "%.", " |cffffd200>|r ")
		
		GameTooltip:ClearLines() 
		GameTooltip:AddLine("LibPeriodicTable")
		GameTooltip:AddLine(text, 1, 1, 1, true)
	elseif self.tiptext then
		GameTooltip:SetText(self.tiptext, nil, nil, nil, nil, true)
	elseif self.itemLink then
		GameTooltip:SetHyperlink(self.itemLink)
	end
	GameTooltip:Show()
end
local function HideTooltip() GameTooltip:Hide() end

local function ShowOptions()
	-- ----------------------------------
	-- Statistics / Introductory frame
	-- ----------------------------------
	local title, subtitle = LibStub("tekKonfig-Heading").new(BrokerGarbage.options, "Broker_Garbage", BrokerGarbage.locale.StatisticsHeading)

	local noticetext = BrokerGarbage.options:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	noticetext:SetPoint("TOPLEFT", subtitle, "BOTTOMLEFT", 0, 0)
	noticetext:SetPoint("RIGHT", BrokerGarbage.options, -32, 0)
	noticetext:SetHeight(40)
	noticetext:SetNonSpaceWrap(true)
	noticetext:SetJustifyH("LEFT")
	noticetext:SetJustifyV("TOP")
	noticetext:SetText(BrokerGarbage.PT and "" or BrokerGarbage.locale.LPTNoticeText)
	
	UpdateAddOnMemoryUsage()
	local memoryusage = BrokerGarbage.options:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
	memoryusage:SetWidth(150)
	memoryusage:SetPoint("TOPLEFT", noticetext, "BOTTOMLEFT", -2, 0)
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
	
	local auctionaddon = BrokerGarbage.options:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
	auctionaddon:SetWidth(150)
	auctionaddon:SetPoint("TOPLEFT", memoryusage, "BOTTOMLEFT", 0, -6)
	auctionaddon:SetJustifyH("RIGHT")
	auctionaddon:SetText(BrokerGarbage.locale.AuctionAddon)
	local aatext = BrokerGarbage.options:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	aatext:SetWidth(120)
	aatext:SetPoint("LEFT", auctionaddon, "RIGHT", 4, 0)
	aatext:SetJustifyH("LEFT")
	aatext:SetText(BrokerGarbage.auctionAddon)
	
	-- ----------------------------------------------------------------------------
	local globalmoneyinfo = BrokerGarbage.options:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	globalmoneyinfo:SetPoint("TOPLEFT", auctionaddon, "BOTTOMLEFT", 0, -12)
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
	
	BrokerGarbage.options:SetScript("OnShow", UpdateStats)
end

local function ShowBasicOptions()
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
	
	local showsource = LibStub("tekKonfig-Checkbox").new(BrokerGarbage.basicOptions, nil, BrokerGarbage.locale.showSourceTitle, "TOPLEFT", guildrepair, "BOTTOMLEFT", -14, 0)
	showsource.tiptext = BrokerGarbage.locale.showSourceText
	showsource:SetChecked(BG_GlobalDB.showSource)
	local checksound = showsource:GetScript("OnClick")
	showsource:SetScript("OnClick", function(showsource)
		checksound(showsource)
		BG_GlobalDB.showSource = not BG_GlobalDB.showSource
	end)
	
	local showlost = LibStub("tekKonfig-Checkbox").new(BrokerGarbage.basicOptions, nil, BrokerGarbage.locale.showLostTitle, "TOPLEFT", nothingtext, "BOTTOMLEFT", -14, 0)
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

	local quality = LibStub("tekKonfig-Slider").new(BrokerGarbage.basicOptions, BrokerGarbage.locale.dropQualityTitle, 0, 7, "TOPLEFT", showlost, "BOTTOMLEFT", 5, -10)
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
	
	local sellNotUsable = LibStub("tekKonfig-Checkbox").new(BrokerGarbage.basicOptions, nil, BrokerGarbage.locale.sellNotUsableTitle, "TOPLEFT", ttMaxItems, "BOTTOMLEFT", 0, -10)
	sellNotUsable.tiptext = BrokerGarbage.locale.sellNotUsableText
	sellNotUsable:SetChecked(BG_GlobalDB.sellNotWearable)
	local checksound = sellNotUsable:GetScript("OnClick")
	sellNotUsable:SetScript("OnClick", function(sellNotUsable)
		checksound(sellNotUsable)
		BG_GlobalDB.sellNotWearable = not BG_GlobalDB.sellNotWearable
		BrokerGarbage:ScanInventory()
	end)
	local sellNUQuality = LibStub("tekKonfig-Slider").new(BrokerGarbage.basicOptions, BrokerGarbage.locale.SNUMaxQualityTitle, 0, 6, "TOPLEFT", sellNotUsable, "BOTTOMLEFT", 25, -4)
	sellNUQuality.tiptext = BrokerGarbage.locale.SNUMaxQualityText
	sellNUQuality:SetWidth(200)
	sellNUQuality:SetValueStep(1);
	sellNUQuality:SetValue(BG_GlobalDB.sellNWQualityTreshold)
	sellNUQuality.text = sellNUQuality:CreateFontString("$parentCenterText", "ARTWORK", "GameFontHighlightSmall")
	sellNUQuality.text:SetPoint("TOP", sellNUQuality, "BOTTOM", 0, 3)
	sellNUQuality.text:SetText(BrokerGarbage.quality[sellNUQuality:GetValue()])
	sellNUQuality:SetScript("OnValueChanged", function(sellNUQuality)
		BG_GlobalDB.sellNWQualityTreshold = sellNUQuality:GetValue()
		sellNUQuality.text:SetText(BrokerGarbage.quality[sellNUQuality:GetValue()])
		BrokerGarbage:ScanInventory()
	end)	
	
	local disableKey, disableKeytext, disableKeycontainer = LibStub("tekKonfig-Dropdown").new(BrokerGarbage.basicOptions, BrokerGarbage.locale.DKTitle, "TOPLEFT", sellNUQuality, "BOTTOMLEFT", -25, -16)
	disableKeytext:SetText(BrokerGarbage.locale.disableKeys[BG_GlobalDB.disableKey])
	disableKey.tiptext = BrokerGarbage.locale.DKTooltip
	
	local function OnClick()
		UIDropDownMenu_SetSelectedValue(disableKey, this.value)
		disableKeytext:SetText(BrokerGarbage.locale.disableKeys[this.value])
		BG_GlobalDB.disableKey = this.value
	end
	UIDropDownMenu_Initialize(disableKey, function()
		local selected, info = UIDropDownMenu_GetSelectedValue(disableKey), UIDropDownMenu_CreateInfo()
		
		for name in pairs(BrokerGarbage.disableKey) do
			info.text = BrokerGarbage.locale.disableKeys[name]
			info.value = name
			info.func = OnClick
			info.checked = name == selected
			UIDropDownMenu_AddButton(info)
		end
	end)
	
	local enchanter = LibStub("tekKonfig-Checkbox").new(BrokerGarbage.basicOptions, nil, BrokerGarbage.locale.enchanterTitle, "LEFT", sellNotUsable, "LEFT", 200, 0)
	enchanter.tiptext = BrokerGarbage.locale.enchanterTooltip
	enchanter:SetChecked(BG_GlobalDB.hasEnchanter)
	local checksound = enchanter:GetScript("OnClick")
	enchanter:SetScript("OnClick", function(enchanter)
		checksound(enchanter)
		BG_GlobalDB.hasEnchanter = not BG_GlobalDB.hasEnchanter
	end)
	
	-- LDB format string for "Junk"
	local editbox = CreateFrame("EditBox", nil, BrokerGarbage.basicOptions)
	editbox:SetAutoFocus(false)
	editbox:SetWidth(150); editbox:SetHeight(32)
	editbox:SetFontObject("GameFontHighlightSmall")
	editbox:SetText(BG_GlobalDB.LDBformat)
	editbox.tiptext = BrokerGarbage.locale.LDBDisplayTextTooltip
	
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

	local LDBtitle = editbox:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	LDBtitle:SetPoint("TOPLEFT", enchanter, "BOTTOMLEFT", 0, -10)
	LDBtitle:SetText(BrokerGarbage.locale.LDBDisplayTextTitle)
	
	editbox:SetPoint("TOPLEFT", LDBtitle, "BOTTOMLEFT", 14, 0)
	local function ResetEditBox(self)
		self:SetText(BG_GlobalDB.LDBformat)
		self:ClearFocus()
		BrokerGarbage:ScanInventory()
	end
	local function SubmitEditBox()
		BG_GlobalDB.LDBformat = editbox:GetText()
		editbox:SetText(BG_GlobalDB.LDBformat)
		editbox:ClearFocus()
		BrokerGarbage:ScanInventory()
	end
	local function ResetEditBoxDefault()
		BG_GlobalDB.LDBformat = BrokerGarbage.defaultGlobalSettings.LDBformat
		editbox:SetText(BG_GlobalDB.LDBformat)
		editbox:ClearFocus()
		BrokerGarbage:ScanInventory()
	end
	editbox:SetScript("OnEscapePressed", ResetEditBox)
	editbox:SetScript("OnEnterPressed", SubmitEditBox)
	editbox:SetScript("OnEnter", ShowTooltip)
	
	local editReset = CreateFrame("Button", nil, BrokerGarbage.basicOptions)
	editReset:SetPoint("LEFT", editbox, "RIGHT", 4, 0)
	editReset:SetWidth(16); editReset:SetHeight(16)
	editReset:SetNormalTexture("Interface\\RAIDFRAME\\ReadyCheck-NotReady")
	editReset.tiptext = BrokerGarbage.locale.LDBDisplayTextResetTooltip
	editReset:SetScript("OnEnter", ShowTooltip)
	editReset:SetScript("OnLeave", HideTooltip)	
	editReset:SetScript("OnClick", ResetEditBoxDefault)
	local editHelp = CreateFrame("Button", nil, BrokerGarbage.basicOptions)
	editHelp:SetPoint("LEFT", LDBtitle, "RIGHT", 2, 0)
	editHelp:SetWidth(16); editHelp:SetHeight(16)
	editHelp:SetNormalTexture("Interface\\RAIDFRAME\\ReadyCheck-Waiting")
	editHelp.tiptext = BrokerGarbage.locale.LDBDisplayTextHelpTooltip
	editHelp:SetScript("OnEnter", ShowTooltip)
	editHelp:SetScript("OnLeave", HideTooltip)
	
	-- LDB format string for "No Junk"
	local editbox2 = CreateFrame("EditBox", nil, BrokerGarbage.basicOptions)
	editbox2:SetAutoFocus(false)
	editbox2:SetWidth(150); editbox2:SetHeight(32)
	editbox2:SetFontObject("GameFontHighlightSmall")
	editbox2:SetText(BG_GlobalDB.LDBNoJunk)
	editbox2.tiptext = BrokerGarbage.locale.LDBNoJunkTextTooltip
	
	local left2 = editbox2:CreateTexture(nil, "BACKGROUND")
	left2:SetWidth(8) left2:SetHeight(20)
	left2:SetPoint("LEFT", -5, 0)
	left2:SetTexture("Interface\\Common\\Common-Input-Border")
	left2:SetTexCoord(0, 0.0625, 0, 0.625)
	local right2 = editbox2:CreateTexture(nil, "BACKGROUND")
	right2:SetWidth(8) right2:SetHeight(20)
	right2:SetPoint("RIGHT", 0, 0)
	right2:SetTexture("Interface\\Common\\Common-Input-Border")
	right2:SetTexCoord(0.9375, 1, 0, 0.625)
	local center2 = editbox2:CreateTexture(nil, "BACKGROUND")
	center2:SetHeight(20)
	center2:SetPoint("RIGHT", right2, "LEFT", 0, 0)
	center2:SetPoint("LEFT", left2, "RIGHT", 0, 0)
	center2:SetTexture("Interface\\Common\\Common-Input-Border")
	center2:SetTexCoord(0.0625, 0.9375, 0, 0.625)

	editbox2:SetPoint("TOPLEFT", editbox, "BOTTOMLEFT", 0, 12)
	local function ResetEditBox(self)
		self:SetText(BG_GlobalDB.LDBNoJunk)
		self:ClearFocus()
		BrokerGarbage:ScanInventory()
	end
	local function SubmitEditBox()
		BG_GlobalDB.LDBNoJunk = editbox2:GetText()
		editbox2:SetText(BG_GlobalDB.LDBNoJunk)
		editbox2:ClearFocus()
		BrokerGarbage:ScanInventory()
	end
	local function ResetEditBoxDefault()
		BG_GlobalDB.LDBNoJunk = BrokerGarbage.locale.label
		editbox2:SetText(BG_GlobalDB.LDBNoJunk)
		editbox2:ClearFocus()
		BrokerGarbage:ScanInventory()
	end
	editbox2:SetScript("OnEscapePressed", ResetEditBox)
	editbox2:SetScript("OnEnterPressed", SubmitEditBox)
	editbox2:SetScript("OnEnter", ShowTooltip)
	editbox2:SetScript("OnLeave", HideTooltip)
	
	local editReset2 = CreateFrame("Button", nil, BrokerGarbage.basicOptions)
	editReset2:SetPoint("LEFT", editbox2, "RIGHT", 4, 0)
	editReset2:SetWidth(16); editReset2:SetHeight(16)
	editReset2:SetNormalTexture("Interface\\RAIDFRAME\\ReadyCheck-NotReady")
	editReset2.tiptext = BrokerGarbage.locale.LDBNoJunkTextResetTooltip
	editReset2:SetScript("OnEnter", ShowTooltip)
	editReset2:SetScript("OnLeave", HideTooltip)	
	editReset2:SetScript("OnClick", ResetEditBoxDefault)
	
	local rescan = LibStub("tekKonfig-Button").new(BrokerGarbage.basicOptions, "TOP", editbox2, "BOTTOM", 0, -4)
	rescan:SetText(BrokerGarbage.locale.rescanInventory)
	rescan.tiptext = BrokerGarbage.locale.rescanInventoryText
	rescan:SetWidth(150)
	rescan:SetScript("OnClick", function()
		BrokerGarbage:ScanInventory()
	end)
	
	BrokerGarbage.basicOptions:SetScript("OnShow", nil)
end

local function ShowListOptions(frame)
	-- ----------------------------------
	-- List Options
	-- ----------------------------------
	local title = LibStub("tekKonfig-Heading").new(frame, "Broker_Garbage - " .. BrokerGarbage.locale.LOTitle)
	
	local explanation = frame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	explanation:SetHeight(70)
	explanation:SetPoint("TOPLEFT", title, "TOPLEFT", 0, -20)
	explanation:SetPoint("RIGHT", frame, -4, 0)
	explanation:SetNonSpaceWrap(true)
	explanation:SetJustifyH("LEFT")
	explanation:SetJustifyV("TOP")
	explanation:SetText(BrokerGarbage.locale.LOSubTitle)

	local default = LibStub("tekKonfig-Button").new(frame, "TOPLEFT", explanation, "BOTTOMLEFT", 0, -4)
	default:SetText(BrokerGarbage.locale.defaultListsText)
	default.tiptext = BrokerGarbage.locale.defaultListsTooltip
	default:SetWidth(150)
	default:RegisterForClicks("RightButtonUp", "LeftButtonUp")
	default:SetScript("OnClick", function(self, button)
		BrokerGarbage:CreateDefaultLists(button == "RightButton")
	end)
	
	local autoSellIncludeItems = LibStub("tekKonfig-Checkbox").new(frame, nil, BrokerGarbage.locale.LOIncludeAutoSellText, "LEFT", default, "RIGHT", 10, 0)
	autoSellIncludeItems.tiptext = BrokerGarbage.locale.LOIncludeAutoSellTooltip
	autoSellIncludeItems:SetChecked(BG_GlobalDB.autoSellIncludeItems)
	local checksound = autoSellIncludeItems:GetScript("OnClick")
	autoSellIncludeItems:SetScript("OnClick", function(autoSellIncludeItems)
		checksound(autoSellIncludeItems)
		BG_GlobalDB.autoSellIncludeItems = not BG_GlobalDB.autoSellIncludeItems
	end)
	
	local topTab = LibStub("tekKonfig-TopTab")
	local panel = LibStub("tekKonfig-Group").new(frame, nil, "TOP", default, "BOTTOM", 0, -24)
	panel:SetPoint("LEFT", 8 + 3, 0)
	panel:SetPoint("BOTTOMRIGHT", -8 -4, 34)
	
	local include = topTab.new(frame, BrokerGarbage.locale.LOTabTitleInclude, "BOTTOMLEFT", panel, "TOPLEFT", 0, -4)
	frame.current = "include"
	local exclude = topTab.new(frame, BrokerGarbage.locale.LOTabTitleExclude, "LEFT", include, "RIGHT", -15, 0)
	exclude:Deactivate()
	local vendorPrice = topTab.new(frame, BrokerGarbage.locale.LOTabTitleVendorPrice, "LEFT", exclude, "RIGHT", -15, 0)
	vendorPrice:Deactivate()
	local autoSell = topTab.new(frame, BrokerGarbage.locale.LOTabTitleAutoSell, "LEFT", vendorPrice, "RIGHT", -15, 0)
	autoSell:Deactivate()
	local help = topTab.new(frame, "?", "LEFT", autoSell, "RIGHT", -15, 0)
	help:Deactivate()
	
	local scrollFrame = CreateFrame("ScrollFrame", frame:GetName().."ScrollFrame", panel, "UIPanelScrollFrameTemplate")
	scrollFrame:SetPoint("TOPLEFT", panel, "TOPLEFT", 0, -4)
	scrollFrame:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -26, 3)
	local scrollContent = CreateFrame("Frame", scrollFrame:GetName().."Content", scrollFrame)
	scrollFrame:SetScrollChild(scrollContent)
	scrollContent:SetHeight(300); scrollContent:SetWidth(400)	-- will be replaced when used
	scrollContent:SetAllPoints()
	
	-- action buttons
	local plus = CreateFrame("Button", "BrokerGarbage_AddButton", frame)
	plus:SetPoint("TOPLEFT", panel, "BOTTOMLEFT", 4, -2)
	plus:SetWidth(25); plus:SetHeight(25)
	plus:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square")
	plus:SetNormalTexture("Interface\\Icons\\Spell_chargepositive")
	plus.tiptext = BrokerGarbage.locale.LOPlus
	plus:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	local minus = CreateFrame("Button", "BrokerGarbage_RemoveButton", frame)
	minus:SetPoint("LEFT", plus, "RIGHT", 4, 0)
	minus:SetWidth(25);	minus:SetHeight(25)
	minus:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square")
	minus:SetNormalTexture("Interface\\Icons\\Spell_chargenegative")
	minus.tiptext = BrokerGarbage.locale.LOMinus
	local demote = CreateFrame("Button", "BrokerGarbage_DemoteButton", frame)
	demote:SetPoint("LEFT", minus, "RIGHT", 14, 0)
	demote:SetWidth(25) demote:SetHeight(25)
	demote:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square")
	demote:SetNormalTexture("Interface\\Icons\\INV_Misc_GroupLooking")
	demote.tiptext = BrokerGarbage.locale.LODemote
	local promote = CreateFrame("Button", "BrokerGarbage_PromoteButton", frame)
	promote:SetPoint("LEFT", demote, "RIGHT", 4, 0)
	promote:SetWidth(25) promote:SetHeight(25)
	promote:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square")
	promote:SetNormalTexture("Interface\\Icons\\INV_Misc_GroupNeedMore")
	promote.tiptext = BrokerGarbage.locale.LOPromote
	local emptyList = CreateFrame("Button", "BrokerGarbage_EmptyListButton", frame)
	emptyList:SetPoint("LEFT", promote, "RIGHT", 14, 0)
	emptyList:SetWidth(25); emptyList:SetHeight(25)
	emptyList:SetNormalTexture("Interface\\Buttons\\Ui-grouploot-pass-up")
	emptyList.tiptext = BrokerGarbage.locale.LOEmptyList
	
	-- editbox curtesy of Tekkub
	local searchbox = CreateFrame("EditBox", nil, frame)
	searchbox:SetAutoFocus(false)
	searchbox:SetPoint("TOPRIGHT", panel, "BOTTOMRIGHT", -4, 2)
	searchbox:SetWidth(160)
	searchbox:SetHeight(32)
	searchbox:SetFontObject("GameFontHighlightSmall")

	local left = searchbox:CreateTexture(nil, "BACKGROUND")
	left:SetWidth(8) left:SetHeight(20)
	left:SetPoint("LEFT", -5, 0)
	left:SetTexture("Interface\\Common\\Common-Input-Border")
	left:SetTexCoord(0, 0.0625, 0, 0.625)
	local right = searchbox:CreateTexture(nil, "BACKGROUND")
	right:SetWidth(8) right:SetHeight(20)
	right:SetPoint("RIGHT", 0, 0)
	right:SetTexture("Interface\\Common\\Common-Input-Border")
	right:SetTexCoord(0.9375, 1, 0, 0.625)
	local center = searchbox:CreateTexture(nil, "BACKGROUND")
	center:SetHeight(20)
	center:SetPoint("RIGHT", right, "LEFT", 0, 0)
	center:SetPoint("LEFT", left, "RIGHT", 0, 0)
	center:SetTexture("Interface\\Common\\Common-Input-Border")
	center:SetTexCoord(0.0625, 0.9375, 0, 0.625)

	searchbox:SetScript("OnEscapePressed", searchbox.ClearFocus)
	searchbox:SetScript("OnEnterPressed", searchbox.ClearFocus)
	searchbox:SetScript("OnEditFocusGained", function(self)
		if not self.searchString then
			self:SetText("")
			self:SetTextColor(1,1,1,1)
		end
	end)
	searchbox:SetScript("OnEditFocusLost", function(self)
		if self:GetText() == "" then
			self:SetText(BrokerGarbage.locale.search)
			self:SetTextColor(0.75, 0.75, 0.75, 1)
		end
	end)
	searchbox:SetScript("OnTextChanged", function(self)
		local t = self:GetText()
		self.searchString = t ~= "" and t ~= BrokerGarbage.locale.search and t:lower() or nil
		BrokerGarbage:UpdateSearch(self.searchString)
	end)
	searchbox:SetText(BrokerGarbage.locale.search)
	searchbox:SetTextColor(0.75, 0.75, 0.75, 1)
	
	-- tab changing actions
	include:SetScript("OnClick", function(self)
		self:Activate()
		exclude:Deactivate()
		vendorPrice:Deactivate()
		autoSell:Deactivate()
		help:Deactivate()
		promote:Enable(); promote:GetNormalTexture():SetDesaturated(false)
		demote:Enable(); demote:GetNormalTexture():SetDesaturated(false)
		frame.current = "include"
		scrollFrame:SetVerticalScroll(0)
		BrokerGarbage:ListOptionsUpdate()
	end)
	exclude:SetScript("OnClick", function(self)
		self:Activate()
		include:Deactivate()
		vendorPrice:Deactivate()
		autoSell:Deactivate()
		help:Deactivate()
		promote:Enable(); promote:GetNormalTexture():SetDesaturated(false)
		demote:Enable(); demote:GetNormalTexture():SetDesaturated(false)
		frame.current = "exclude"
		scrollFrame:SetVerticalScroll(0)
		BrokerGarbage:ListOptionsUpdate()
	end)
	vendorPrice:SetScript("OnClick", function(self)
		self:Activate()
		include:Deactivate()
		exclude:Deactivate()
		autoSell:Deactivate()
		help:Deactivate()
		promote:Disable(); promote:GetNormalTexture():SetDesaturated(true)
		demote:Disable(); demote:GetNormalTexture():SetDesaturated(true)
		frame.current = "forceVendorPrice"
		scrollFrame:SetVerticalScroll(0)
		BrokerGarbage:ListOptionsUpdate()
	end)
	autoSell:SetScript("OnClick", function(self)
		self:Activate()
		include:Deactivate()
		exclude:Deactivate()
		vendorPrice:Deactivate()
		help:Deactivate()
		promote:Enable(); promote:GetNormalTexture():SetDesaturated(false)
		demote:Enable(); demote:GetNormalTexture():SetDesaturated(false)
		frame.current = "autoSellList"
		scrollFrame:SetVerticalScroll(0)
		BrokerGarbage:ListOptionsUpdate()
	end)
	help:SetScript("OnClick", function(self)
		self:Activate()
		include:Deactivate()
		exclude:Deactivate()
		autoSell:Deactivate()
		vendorPrice:Deactivate()
		promote:Enable(); promote:GetNormalTexture():SetDesaturated(false)
		demote:Enable(); demote:GetNormalTexture():SetDesaturated(false)
		frame.current = nil
		scrollFrame:SetVerticalScroll(0)
		BrokerGarbage:ShowHelp()
	end)
	
	-- function to set the drop treshold (limit) via the mousewheel
	local function OnMouseWheel(self, dir)
		if type(self.itemID) ~= "number" then return end
		BrokerGarbage.itemsCache[self.itemID] = nil		-- clear item from cache
		
		local text, limit = self.limit:GetText()
		if self.isGlobal then
			list = BG_GlobalDB[frame.current]
		else
			list = BG_LocalDB[frame.current]
		end
		
		if dir == 1 then	-- up
			if list[self.itemID] == true then
				list[self.itemID] = 1
			else
				list[self.itemID] = list[self.itemID] + 1
			end
			text = list[self.itemID]
		else				-- down
			if list[self.itemID] == true then
				text = ""
			elseif list[self.itemID] == 1 then
				list[self.itemID] = true
				text = ""
			else
				list[self.itemID] = list[self.itemID] - 1
				text = list[self.itemID]
			end
		end
		self.limit:SetText(text)
	end
	
	-- function that updates & shows items from various lists
	local numCols
	function BrokerGarbage:ListOptionsUpdate()
		-- update scrollframe content to full width
		scrollContent:SetWidth(scrollFrame:GetWidth())
		if frame.current == nil then
			BrokerGarbage:ShowHelp()
		elseif _G["BrokerGarbageHelpFrame"] then
			_G["BrokerGarbageHelpFrame"]:Hide()
		end
		local globalList = BG_GlobalDB[frame.current]
		local localList = BG_LocalDB[frame.current] or {}
		local dataList = BrokerGarbage:JoinTables(globalList, localList)
		
		-- make this table sortable
		data = {}
		for key, value in pairs(dataList) do
			table.insert(data, key)
		end
		table.sort(data, function(a,b)
			if type(a) == "string" and type(b) == "string" then
				return a < b
			elseif type(a) == "number" and type(b) == "number" then
				return (GetItemInfo(a) or "z") < (GetItemInfo(b) or "z")
			else
				return type(a) == "string"
			end
		end)

		if not BrokerGarbage.listButtons then BrokerGarbage.listButtons = {} end
		for index, itemID in ipairs(data) do
			if BrokerGarbage.listButtons[index] then
				-- use available button
				local button = BrokerGarbage.listButtons[index]
				local itemLink, texture
				if type(itemID) ~= "number" then	-- this is an item category
					itemLink = nil
					button.tiptext = itemID			-- category description string
					texture = "Interface\\Icons\\Trade_engineering"
				else	-- this is an explicit item
					_, itemLink, _, _, _, _, _, _, _, texture, _ = GetItemInfo(itemID)
					button.tiptext = nil
				end
				
				if texture then	-- everything's fine
					button.itemID = itemID
					button.itemLink = itemLink
					button:SetNormalTexture(texture)
					
					if globalList[itemID] then
						button.global:SetText("G")
						button.isGlobal = true
					else
						button.global:SetText("")
						button.isGlobal = false
					end
					if button.isGlobal and globalList[itemID] ~= true then
						button.limit:SetText(globalList[itemID])
					elseif localList[itemID] ~= true then
						button.limit:SetText(localList[itemID])
					else
						button.limit:SetText("")
					end
					
					if not itemLink and not BrokerGarbage.PT then
						button:SetAlpha(0.2)
						button.tiptext = button.tiptext .. "\n|cffff0000"..BrokerGarbage.locale.LPTNotLoaded
					end
				else	-- an item the server has not seen
					button.itemID = itemID
					button.tiptext = "ID: "..itemID
					button:SetNormalTexture("Interface\\Icons\\Inv_misc_questionmark")
				end
				if BrokerGarbage.listOptions.current == "include" then
					button:EnableMouseWheel(true)
					button:SetScript("OnMouseWheel", OnMouseWheel)
				else
					button:EnableMouseWheel(false)
				end
				button:SetChecked(false)
				button:Show()
			else
				-- create another button
				local button = CreateFrame("CheckButton", scrollContent:GetName().."Item"..index, scrollContent)
				button:Hide()
				button:SetWidth(36)
				button:SetHeight(36)

				local limit = button:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
				limit:SetPoint("BOTTOMLEFT", button, "BOTTOMLEFT", 2, 1)
				limit:SetPoint("BOTTOMLEFT", button, "BOTTOMLEFT", 2, 1)
				limit:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -3, 1)
				limit:SetHeight(20)
				limit:SetJustifyH("RIGHT")
				limit:SetJustifyV("BOTTOM")
				limit:SetText("")
				button.limit = limit
				
				local global = button:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
				global:SetPoint("TOPLEFT", button, "TOPLEFT", 2, -2)
				global:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -3, 1)
				global:SetJustifyH("LEFT")
				global:SetJustifyV("TOP")
				global:SetText("")
				button.global = global
				
				button:SetNormalTexture("Interface\\Icons\\Inv_misc_questionmark")
				button:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square")
				button:SetCheckedTexture("Interface\\Buttons\\UI-Button-Outline")
				button:SetChecked(false)
				local tex = button:GetCheckedTexture()
				tex:ClearAllPoints()
				tex:SetPoint("CENTER")
				tex:SetWidth(36/37*66) tex:SetHeight(36/37*66)
				
				button:SetScript("OnClick", function(self)
					local check = self:GetChecked()
					BrokerGarbage:Debug("OnClick", check)
					
					if IsModifiedClick() then
						-- this handles chat linking as well as dress-up
						local linkText = type(self.itemID) == "string" and self.itemID or BrokerGarbage.locale.AuctionAddonUnknown
						HandleModifiedItemClick(self.itemLink or linkText)
						self:SetChecked(not check)
					elseif not IsModifierKeyDown() then
						self:SetChecked(check)
					else
						self:SetChecked(not check)
					end
				end)
				button:SetScript("OnEnter", ShowTooltip)
				button:SetScript("OnLeave", HideTooltip)				
				
				if not numCols and panel:GetWidth() - (index+1)*button:GetWidth() < 2 then
					-- we found the width limit, set the column count
					numCols = index - 1
				end
				if index == 1 then		-- place first icon
					button:SetPoint("TOPLEFT", scrollContent, "TOPLEFT", 6, -6)
				elseif numCols and mod(index, numCols) == 1 then	-- new row
					button:SetPoint("TOPLEFT", BrokerGarbage.listButtons[index-numCols], "BOTTOMLEFT", 0, -6)
				else					-- new button next to the old one
					button:SetPoint("LEFT", BrokerGarbage.listButtons[index-1], "RIGHT", 4, 0)
				end
				
				BrokerGarbage.listButtons[index] = button
				BrokerGarbage:ListOptionsUpdate(listName)	-- update, so we get item data & texture
			end
		end
		-- hide unnessessary buttons
		local index = #data + 1
		while BrokerGarbage.listButtons[index] do
			BrokerGarbage.listButtons[index]:Hide()
			index = index + 1
		end
	end
	
	-- shows some help strings for setting up the lists
	function BrokerGarbage:ShowHelp()
		for i, button in ipairs(BrokerGarbage.listButtons) do
			button:Hide()
		end
		if not _G["BrokerGarbageHelpFrame"] then
			local helpFrame = CreateFrame("Frame", "BrokerGarbageHelpFrame", scrollContent)
			helpFrame:SetAllPoints()
			
			local bestUse = helpFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
			bestUse:SetHeight(190)
			bestUse:SetPoint("TOPLEFT", helpFrame, "TOPLEFT", 8, -4)
			bestUse:SetPoint("RIGHT", helpFrame, -4, 0)
			bestUse:SetNonSpaceWrap(true)
			bestUse:SetJustifyH("LEFT"); bestUse:SetJustifyV("TOP")
			bestUse:SetText(BrokerGarbage.locale.listsBestUse)
			
			local iconButtons = helpFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
			iconButtons:SetHeight(124)
			iconButtons:SetPoint("TOPLEFT", bestUse, "BOTTOMLEFT", 0, -10)
			iconButtons:SetPoint("RIGHT", helpFrame, -4, 0)
			iconButtons:SetNonSpaceWrap(true)
			iconButtons:SetJustifyH("LEFT"); iconButtons:SetJustifyV("TOP")
			iconButtons:SetText(BrokerGarbage.locale.iconButtonsUse)
			
			local actionButtons = helpFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
			actionButtons:SetHeight(180)
			actionButtons:SetPoint("TOPLEFT", iconButtons, "BOTTOMLEFT", 0, -10)
			actionButtons:SetPoint("RIGHT", helpFrame, -4, 0)
			actionButtons:SetNonSpaceWrap(true)
			actionButtons:SetJustifyH("LEFT"); actionButtons:SetJustifyV("TOP")
			actionButtons:SetText(BrokerGarbage.locale.actionButtonsUse)
		else
			_G["BrokerGarbageHelpFrame"]:Show()
		end
	end
	
	-- when a search string is passed, suitable items will be shown while the rest is grayed out
	function BrokerGarbage:UpdateSearch(searchString)
		for i, button in ipairs(BrokerGarbage.listButtons) do
			if button:IsVisible() then
				local itemName = button.itemID and GetItemInfo(button.itemID) or button.tiptext
				local name = (button.itemID or "") .. " " .. (itemName or "")
				name = name:lower()
				
				if not searchString or string.match(name, searchString) then
					button:SetAlpha(1)
				else
					button:SetAlpha(0.3)
				end
			end
		end
	end
	
	local function AddItem(self, item)
		local cursorType, itemID, link = GetCursorInfo()
		if self == plus and not (cursorType and itemID and link) then
			return
		end
		
		-- find the item we want to add
		if itemID then	-- real items
			itemID = itemID
			BrokerGarbage.itemsCache[itemID] = nil
		else			-- category strings
			itemID = item
			BrokerGarbage.itemsCache = {}
		end
		
		-- create "link" for output
		if type(itemID) == "number" then
			link = select(2, GetItemInfo(itemID))
		else
			link = itemID
		end
		
		if BG_LocalDB[frame.current] and BG_LocalDB[frame.current][itemID] == nil then
			BG_LocalDB[frame.current][itemID] = true
			BrokerGarbage:Print(format(BrokerGarbage.locale["addedTo_" .. frame.current], link))
			BrokerGarbage:ListOptionsUpdate()
			ClearCursor()
		elseif BG_LocalDB[frame.current] == nil and 
			BG_GlobalDB[frame.current] and BG_GlobalDB[frame.current][itemID] == nil then
			BG_GlobalDB[frame.current][itemID] = true
			BrokerGarbage:Print(format(BrokerGarbage.locale["addedTo_" .. frame.current], link))
			BrokerGarbage:ListOptionsUpdate()
			ClearCursor()
		else
			BrokerGarbage:Print(string.format(BrokerGarbage.locale.itemAlreadyOnList, link))
		end
		
		BrokerGarbage:ScanInventory()
		BrokerGarbage:UpdateRepairButton()
	end
	
	if not _G["BrokerGarbagePTMenuFrame"] then		
		--initialize dropdown menu for adding setstrings
		BrokerGarbage.menuFrame = CreateFrame("Frame", "BrokerGarbagePTMenuFrame", UIParent, "UIDropDownMenuTemplate")
		
		-- menu create function
		function DropDown_Initialize(self,level)
			level = level or 1
			if (level == 1) then		
				local info = UIDropDownMenu_CreateInfo()
				info.hasArrow = false -- no submenu
				info.notCheckable = true
				info.text = BrokerGarbage.locale.categoriesHeading
				info.isTitle = true
				UIDropDownMenu_AddButton(info, level)

				if not BrokerGarbage.PT then
					local info = UIDropDownMenu_CreateInfo()
					info.hasArrow = false
					info.notCheckable = true
					info.text = BrokerGarbage.locale.LPTNotLoaded
					info.isTitle = true
					UIDropDownMenu_AddButton(info, level)
				end
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
						AddItem(BrokerGarbage.menuFrame.clickTarget, key)
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
							AddItem(BrokerGarbage.menuFrame.clickTarget, valueString)
							BrokerGarbage:ListOptionsUpdate()
						end
					else
						-- end node
						info.hasArrow = false; -- no submenues this time
						info.notCheckable = true;
						info.text = key
						info.func = function(...) 
							AddItem(BrokerGarbage.menuFrame.clickTarget, value)
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
		if frame.current == nil then return end
		if button == "RightButton" then
			-- toggle LibPeriodicTable menu
			BrokerGarbage.menuFrame.clickTarget = self
			ToggleDropDownMenu(1, nil, BrokerGarbage.menuFrame, self, -20, 0)
			BrokerGarbage:Debug("LPT menu opened", self, button)
			return
		end
		
		-- add action
		if self == plus then			
			AddItem(self)
		-- remove action
		elseif self == minus then
			for i, button in pairs(BrokerGarbage.listButtons) do
				if button:GetChecked() then
					if type(button.itemID) == "number" then
						BrokerGarbage.itemsCache[button.itemID] = nil
					else
						BrokerGarbage.itemsCache = {}
					end
					if BG_LocalDB[frame.current] then
						BG_LocalDB[frame.current][button.itemID] = nil
					end
					if BG_GlobalDB[frame.current] then
						BG_GlobalDB[frame.current][button.itemID] = nil
					end
				end
			end
		-- demote action
		elseif self == demote then
			for i, button in pairs(BrokerGarbage.listButtons) do
				if button:GetChecked() then
					if BG_GlobalDB[frame.current][button.itemID] and BG_LocalDB[frame.current] then
						BG_LocalDB[frame.current][button.itemID] = BG_GlobalDB[frame.current][button.itemID]
						BG_GlobalDB[frame.current][button.itemID] = nil
					end
				end
			end
		-- promote action
		elseif self == promote then
			for i, button in pairs(BrokerGarbage.listButtons) do
				if button:GetChecked() then
					if not BG_GlobalDB[frame.current][button.itemID] then
						BG_GlobalDB[frame.current][button.itemID] = BG_LocalDB[frame.current][button.itemID]
						BG_LocalDB[frame.current][button.itemID] = nil
					end
				end
			end
		-- empty action
		elseif self == emptyList then
			BrokerGarbage.itemsCache = {}
			if IsShiftKeyDown() then
				BG_GlobalDB[frame.current] = {}
			elseif BG_LocalDB[frame.current] then
				BG_LocalDB[frame.current] = {}
			end
		end
		
		BrokerGarbage:ScanInventory()
		BrokerGarbage:ListOptionsUpdate()
		BrokerGarbage:UpdateRepairButton()
	end
	
	plus:SetScript("OnClick", OnClick)
	plus:SetScript("OnEnter", ShowTooltip)
	plus:SetScript("OnLeave", HideTooltip)
	minus:SetScript("OnClick", OnClick)
	minus:SetScript("OnEnter", ShowTooltip)
	minus:SetScript("OnLeave", HideTooltip)
	demote:SetScript("OnClick", OnClick)
	demote:SetScript("OnEnter", ShowTooltip)
	demote:SetScript("OnLeave", HideTooltip)
	promote:SetScript("OnClick", OnClick)
	promote:SetScript("OnEnter", ShowTooltip)
	promote:SetScript("OnLeave", HideTooltip)
	emptyList:SetScript("OnClick", OnClick)
	emptyList:SetScript("OnEnter", ShowTooltip)
	emptyList:SetScript("OnLeave", HideTooltip)
	
	-- support for add-mechanism
	plus:RegisterForDrag("LeftButton")
	plus:SetScript("OnReceiveDrag", ItemDrop)
	plus:SetScript("OnMouseDown", ItemDrop)
	
	BrokerGarbage:ListOptionsUpdate()
	BrokerGarbage.listOptions:SetScript("OnShow", BrokerGarbage.ListOptionsUpdate)
end

local index = #BrokerGarbage.optionsModules
table.insert(BrokerGarbage.optionsModules, BrokerGarbage.options)
BrokerGarbage.optionsModules[index+1].OnShow = ShowOptions
table.insert(BrokerGarbage.optionsModules, BrokerGarbage.basicOptions)
BrokerGarbage.optionsModules[index+2].OnShow = ShowBasicOptions
table.insert(BrokerGarbage.optionsModules, BrokerGarbage.listOptions)
BrokerGarbage.optionsModules[index+3].OnShow = ShowListOptions

local firstLoad = true
function BrokerGarbage:OptionsFirstLoad()
	if not firstLoad then return end
	
	for i, options in ipairs(BrokerGarbage.optionsModules) do
		BrokerGarbage:Debug("Loading options: ", options.name)
		InterfaceOptions_AddCategory(options)
		options:SetScript("OnShow", options.OnShow)
	end
	LibStub("tekKonfig-AboutPanel").new("Broker_Garbage", "Broker_Garbage")
	
	collectgarbage()
	firstLoad = false
end

-- show me!
InterfaceOptionsFrame:HookScript("OnShow", BrokerGarbage.OptionsFirstLoad)

-- register slash commands
SLASH_BROKERGARBAGE1 = "/garbage"
SLASH_BROKERGARBAGE2 = "/garb"
function SlashCmdList.BROKERGARBAGE(msg, editbox)
	local command, rest = msg:match("^(%S*)%s*(.-)$")
	local command = strlower(command)
	local LootManager = IsAddOnLoaded("Broker_Garbage-LootManager")
	
	if command == "format" then
		if strlower(rest) ~= "reset" then
			BG_GlobalDB.LDBformat = rest
		else
			BG_GlobalDB.LDBformat = BrokerGarbage.defaultGlobalSettings.LDBformat
		end
		BrokerGarbage:ScanInventory()
	
	elseif command == "options" or command == "config" or command == "option" or command == "menu" then
		BrokerGarbage:OptionsFirstLoad()
		InterfaceOptionsFrame_OpenToCategory(BrokerGarbage.options)
		
	elseif command == "limit" or command == "glimit" or command == "globallimit" then
		local itemID, count = rest:match("^[^0-9]-([0-9]+).-([0-9]+)$")
		itemID = tonumber(itemID)
		count = tonumber(count)
		
		BrokerGarbage.itemsCache[itemID] = nil
		
		if string.find(command, "g") then
			BG_GlobalDB.include[itemID] = count
		else
			BG_LocalDB.include[itemID] = count
		end
		local itemLink = select(2,GetItemInfo(itemID))
		BrokerGarbage:Print(format(BrokerGarbage.locale.limitSet, itemLink, count))
		BrokerGarbage:ListOptionsUpdate("include")
		
	elseif command == "value" or command == "minvalue" and LootManager then
		rest = tonumber(rest)
		if not rest then return end
		
		BrokerGarbage_LootManager:SetMinValue(rest)
		BrokerGarbage:Print(format(BrokerGarbage.locale.minValueSet, BrokerGarbage:FormatMoney(BG_LocalDB.itemMinValue)))
		
	else
		BrokerGarbage:Print(BrokerGarbage.locale.slashCommandHelp)
	end
end