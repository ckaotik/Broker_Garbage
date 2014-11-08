local _, BGC = ...

-- GLOBALS: Broker_Garbage, LibStub, _G, RAID_CLASS_COLORS, select
-- GLOBALS: UpdateAddOnMemoryUsage, GetAddOnMemoryUsage, IsShiftKeyDown, collectgarbage, CreateFrame, UnitName, UnitClass
local floor = math.floor
local match = string.match
local format = string.format

local function Options_Statistics(panel)
	local function ResetStatistics(self)
		if not self or not self.stat then return end
		Broker_Garbage.ResetOption(self.stat, self.isGlobal)
		panel:Hide()
		panel:Show()
	end

	local function AddStatistic(stat, label, value, tooltip, ...)
		if not (label and value) then return end
		local textLeft = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
		textLeft:SetWidth(150)
		textLeft:SetJustifyH("RIGHT")
		textLeft:SetText(label)

		local textRight = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
		textRight:SetPoint("LEFT", textLeft, "RIGHT", 4, 0)
		textRight:SetWidth(150)
		textRight:SetJustifyH("LEFT")
		textRight:SetText(value)

		if tooltip then
			local action = CreateFrame("Button", nil, panel)
			action:SetNormalTexture("Interface\\RAIDFRAME\\ReadyCheck-Waiting")
			action:SetPoint("LEFT", textRight, "RIGHT",4, 0)
			action:SetWidth(16); action:SetHeight(16)
			action.tiptext = tooltip

			action:SetScript("OnEnter", BGC.ShowTooltip)
			action:SetScript("OnLeave", BGC.HideTooltip)

			if stat then
				action.isGlobal = match(stat, "^_.*") and true or nil
				action.stat = match(stat, "^_?(.*)")
				if stat == "collectgarbage" then
					action:SetScript("OnClick", function() collectgarbage("collect"); panel:Hide(); panel:Show() end)
				else
					action:SetNormalTexture("Interface\\RAIDFRAME\\ReadyCheck-NotReady")
					action:SetScript("OnClick", ResetStatistics)
				end
			else

			end
		end
		if select('#',...) > 0 then	textLeft:SetPoint(...) end

		return textLeft, textRight
	end

	UpdateAddOnMemoryUsage()
	local memoryUsage, memoryUsageText = AddStatistic("collectgarbage", BGC.locale.MemoryUsageTitle, floor(GetAddOnMemoryUsage("Broker_Garbage")), BGC.locale.CollectMemoryUsageTooltip, "TOPRIGHT", panel, "TOP", -2, -120)

	local globalStatistics = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	globalStatistics:SetPoint("TOPLEFT", memoryUsage, "BOTTOMLEFT", 0, -12)
	globalStatistics:SetPoint("RIGHT", panel, -32, 0)
	globalStatistics:SetNonSpaceWrap(true)
	globalStatistics:SetJustifyH("LEFT")
	globalStatistics:SetJustifyV("TOP")
	globalStatistics:SetText(BGC.locale.GlobalStatisticsHeading)

	-- global statistics
	local moneyEarned, moneyLost, numSold, numDeleted = Broker_Garbage:GetStatistics()

	local globalEarned, globalEarnedText = AddStatistic("_moneyEarned", BGC.locale.GlobalMoneyEarnedTitle,
		Broker_Garbage.FormatMoney(moneyEarned),
		BGC.locale.ResetStatistic,
		"TOPLEFT", globalStatistics, "BOTTOMLEFT", 0, -15)

	local itemsSold, itemsSoldText = AddStatistic("_itemsSold", BGC.locale.GlobalItemsSoldTitle,
		numSold,
		BGC.locale.ResetStatistic,
		"TOPLEFT", globalEarned, "BOTTOMLEFT", 0, -6)

	local averageSellValue, averageSellValueText = AddStatistic(nil, BGC.locale.AverageSellValueTitle,
	 	Broker_Garbage.FormatMoney(floor(moneyEarned / (numSold ~= 0 and numSold or 1))),
		BGC.locale.AverageSellValueTooltip,
		"TOPLEFT", itemsSold, "BOTTOMLEFT", 0, -6)

	local globalLost, globalLostText = AddStatistic("_moneyLostByDeleting", BGC.locale.GlobalMoneyLostTitle,
		Broker_Garbage.FormatMoney(moneyLost),
		BGC.locale.ResetStatistic,
		"TOPLEFT", averageSellValue, "BOTTOMLEFT", 0, -15)

	local itemsDropped, itemsDroppedText = AddStatistic("_itemsDropped", BGC.locale.ItemsDroppedTitle,
		numDeleted,
		BGC.locale.ResetStatistic,
		"TOPLEFT", globalLost, "BOTTOMLEFT", 0, -6)

	local averageValueLost, averageValueLostText = AddStatistic(nil, BGC.locale.AverageDropValueTitle,
		Broker_Garbage.FormatMoney(floor(moneyLost / (numDeleted ~= 0 and numDeleted or 1))),
		BGC.locale.AverageDropValueTooltip,
		"TOPLEFT", itemsDropped, "BOTTOMLEFT", 0, -6)

	local localStatistics = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	localStatistics:SetPoint("TOPLEFT", averageValueLost, "BOTTOMLEFT", 0, -12)
	localStatistics:SetPoint("RIGHT", panel, -32, 0)
	localStatistics:SetNonSpaceWrap(true)
	localStatistics:SetJustifyH("LEFT")
	localStatistics:SetJustifyV("TOP")
	local _, playerClass = UnitClass("player")
	localStatistics:SetText(format(BGC.locale.LocalStatisticsHeading, "|c"..RAID_CLASS_COLORS[playerClass].colorStr .. UnitName("player") .. "|r"))

	-- character statistics
	local realmName, unitName = GetRealmName(), UnitName('player')
	local moneyEarned, moneyLost, numSold, numDeleted = Broker_Garbage:GetStatistics(unitName .. ' - ' .. realmName)

	local localEarned, localEarnedText = AddStatistic("moneyEarned", BGC.locale.StatisticsLocalAmountEarned,
	 	Broker_Garbage.FormatMoney(moneyEarned),
		BGC.locale.ResetStatistic,
		"TOPLEFT", localStatistics, "BOTTOMLEFT", 0, -15)

	local localLost, localLostText = AddStatistic("moneyLostByDeleting", BGC.locale.StatisticsLocalAmountLost,
		Broker_Garbage.FormatMoney(moneyLost),
		BGC.locale.ResetStatistic,
		"TOPLEFT", localEarned, "BOTTOMLEFT", 0, -6)

	local resetAll = LibStub("tekKonfig-Button").new(panel, "TOPLEFT", localLostText, "BOTTOMLEFT", 0, -24)
	resetAll:SetText(BGC.locale.ResetAllText)
	resetAll.tiptext = BGC.locale.ResetAllTooltip
	resetAll:SetWidth(150)
	resetAll:SetScript("OnClick", function()
		local isGlobal = IsShiftKeyDown()
		Broker_Garbage.ResetOption("moneyEarned", isGlobal)
		Broker_Garbage.ResetOption("moneyLostByDeleting", isGlobal)
		Broker_Garbage.ResetOption("itemsDropped", isGlobal)
		Broker_Garbage.ResetOption("itemsSold", isGlobal)

		panel:Update()
	end)

	panel:SetScript("OnShow", function()
		UpdateAddOnMemoryUsage()
		memoryUsageText:SetText(floor(GetAddOnMemoryUsage("Broker_Garbage")))

		-- global statistics
		local moneyEarned, moneyLost, numSold, numDeleted = Broker_Garbage:GetStatistics()

		globalEarnedText:SetText(Broker_Garbage.FormatMoney(moneyEarned))
		itemsSoldText:SetText(numSold)
		globalLostText:SetText(Broker_Garbage.FormatMoney(moneyLost))
		itemsDroppedText:SetText(numDeleted)

		averageSellValueText:SetText(Broker_Garbage.FormatMoney(
			floor(moneyEarned / (numSold ~= 0 and numSold or 1))
		))
		averageValueLostText:SetText(Broker_Garbage.FormatMoney(
			floor(moneyLost / (numDeleted ~= 0 and numDeleted or 1))
		))

		-- character statistics
		local realmName, unitName = GetRealmName(), UnitName('player')
		local moneyEarned, moneyLost = Broker_Garbage:GetStatistics(unitName .. ' - ' .. realmName)
		localEarnedText:SetText(Broker_Garbage.FormatMoney(moneyEarned))
		localLostText:SetText(Broker_Garbage.FormatMoney(moneyLost))
	end)
end

local frame = CreateFrame("Frame", nil, InterfaceOptionsFramePanelContainer)
frame.name, frame.parent = BGC.locale.StatisticsHeading, "Broker_Garbage"
frame:Hide()
frame:SetScript("OnShow", Options_Statistics)
InterfaceOptions_AddCategory(frame)
