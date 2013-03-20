local _, BGC = ...

-- GLOBALS: Broker_Garbage, LibStub, _G
-- GLOBALS: UpdateAddOnMemoryUsage, GetAddOnMemoryUsage, IsShiftKeyDown, collectgarbage, CreateFrame, UnitName

local select = select
local floor = math.floor
local match = string.match
local format = string.format

local function Options_Statistics(pluginID)
	local panel, tab = BGC:CreateOptionsTab(pluginID)

	local function ResetStatistics(self)
		if not self or not self.stat then return end
		Broker_Garbage.ResetOption(self.stat, self.isGlobal)
		BGC.UpdateOptionsPanel()
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
					action:SetScript("OnClick", function() collectgarbage("collect"); BGC.UpdateOptionsPanel() end)
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
	local memoryUsage, memoryUsageText = AddStatistic("collectgarbage", BGC.locale.MemoryUsageTitle, floor(GetAddOnMemoryUsage("Broker_Garbage")), BGC.locale.CollectMemoryUsageTooltip, "TOPRIGHT", panel, "TOP", -2, -40)

	-- local auctionAddon, auctionAddonText = AddStatistic(nil, BGC.locale.AuctionAddon, Broker_Garbage:GetVariable("auctionAddon") or BGC.locale.na, BGC.locale.AuctionAddonTooltip, "TOPLEFT", memoryUsage, "BOTTOMLEFT", 0, -6)

	local globalStatistics = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	globalStatistics:SetPoint("TOPLEFT", memoryUsage, "BOTTOMLEFT", 0, -12)
	globalStatistics:SetPoint("RIGHT", panel, -32, 0)
	globalStatistics:SetNonSpaceWrap(true)
	globalStatistics:SetJustifyH("LEFT")
	globalStatistics:SetJustifyV("TOP")
	globalStatistics:SetText(BGC.locale.GlobalStatisticsHeading)

	local var1 = Broker_Garbage:GetOption("moneyEarned", true)
	local globalEarned, globalEarnedText = AddStatistic("_moneyEarned", BGC.locale.GlobalMoneyEarnedTitle,
		Broker_Garbage.FormatMoney(var1),
		BGC.locale.ResetStatistic,
		"TOPLEFT", globalStatistics, "BOTTOMLEFT", 0, -15)

	local var2 = Broker_Garbage:GetOption("itemsSold", true)
	local itemsSold, itemsSoldText = AddStatistic("_itemsSold", BGC.locale.GlobalItemsSoldTitle,
		var1,
		BGC.locale.ResetStatistic,
		"TOPLEFT", globalEarned, "BOTTOMLEFT", 0, -6)

	local averageSellValue, averageSellValueText = AddStatistic(nil, BGC.locale.AverageSellValueTitle,
	 	Broker_Garbage.FormatMoney(floor(var1 / (var2 ~= 0 and var2 or 1))),
		BGC.locale.AverageSellValueTooltip,
		"TOPLEFT", itemsSold, "BOTTOMLEFT", 0, -6)

	var1 = Broker_Garbage:GetOption("moneyLostByDeleting", true)
	local globalLost, globalLostText = AddStatistic("_moneyLostByDeleting", BGC.locale.GlobalMoneyLostTitle,
		Broker_Garbage.FormatMoney(var1),
		BGC.locale.ResetStatistic,
		"TOPLEFT", averageSellValue, "BOTTOMLEFT", 0, -15)

	var2 = Broker_Garbage:GetOption("itemsDropped", true)
	local itemsDropped, itemsDroppedText = AddStatistic("_itemsDropped", BGC.locale.ItemsDroppedTitle,
		var2,
		BGC.locale.ResetStatistic,
		"TOPLEFT", globalLost, "BOTTOMLEFT", 0, -6)

	local averageValueLost, averageValueLostText = AddStatistic(nil, BGC.locale.AverageDropValueTitle,
		Broker_Garbage.FormatMoney(floor(var1 / (var2 ~= 0 and var2 or 1))),
		BGC.locale.AverageDropValueTooltip,
		"TOPLEFT", itemsDropped, "BOTTOMLEFT", 0, -6)

	local localStatistics = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	localStatistics:SetPoint("TOPLEFT", averageValueLost, "BOTTOMLEFT", 0, -12)
	localStatistics:SetPoint("RIGHT", panel, -32, 0)
	localStatistics:SetNonSpaceWrap(true)
	localStatistics:SetJustifyH("LEFT")
	localStatistics:SetJustifyV("TOP")
	localStatistics:SetText(format(BGC.locale.LocalStatisticsHeading, Broker_Garbage:Colorize(_G.RAID_CLASS_COLORS[Broker_Garbage:GetVariable("playerClass")]) .. UnitName("player") .. "|r"))

	var1 = Broker_Garbage:GetOption("moneyEarned", false)
	local localEarned, localEarnedText = AddStatistic("moneyEarned", BGC.locale.StatisticsLocalAmountEarned,
	 	Broker_Garbage.FormatMoney(var1),
		BGC.locale.ResetStatistic,
		"TOPLEFT", localStatistics, "BOTTOMLEFT", 0, -15)

	var2 = Broker_Garbage:GetOption("moneyLostByDeleting", false)
	local localLost, localLostText = AddStatistic("moneyLostByDeleting", BGC.locale.StatisticsLocalAmountLost,
		Broker_Garbage.FormatMoney(var2),
		BGC.locale.ResetStatistic,
		"TOPLEFT", localEarned, "BOTTOMLEFT", 0, -6)

	local resetAll = LibStub("tekKonfig-Button").new(panel, "TOPLEFT", localLostText, "BOTTOMLEFT", 0, -24)
	resetAll:SetText(BGC.locale.ResetAllText)
	resetAll.tiptext = BGC.locale.ResetAllTooltip
	resetAll:SetWidth(150)
	resetAll:SetScript("OnClick", function()
		Broker_Garbage.ResetStatistics( IsShiftKeyDown() )
		panel:Update()
	end)

	function panel:Update()
		UpdateAddOnMemoryUsage()
		memoryUsageText:SetText(floor(GetAddOnMemoryUsage("Broker_Garbage")))

		globalEarnedText:SetText(Broker_Garbage.FormatMoney( Broker_Garbage:GetOption("moneyEarned", true) ))
		itemsSoldText:SetText( Broker_Garbage:GetOption("itemsSold", true) )
		globalLostText:SetText(Broker_Garbage.FormatMoney( Broker_Garbage:GetOption("moneyLostByDeleting", true) ))
		itemsDroppedText:SetText( Broker_Garbage:GetOption("itemsDropped", true) )

		averageSellValueText:SetText(Broker_Garbage.FormatMoney(
			floor(Broker_Garbage:GetOption("moneyEarned", true) / (Broker_Garbage:GetOption("itemsSold", true) ~= 0 and Broker_Garbage:GetOption("itemsSold", true) or 1))
		))
		averageValueLostText:SetText(Broker_Garbage.FormatMoney(
			floor(Broker_Garbage:GetOption("moneyLostByDeleting", true) / (Broker_Garbage:GetOption("itemsDropped", true) ~= 0 and Broker_Garbage:GetOption("itemsDropped", true) or 1))
		))

		localEarnedText:SetText(Broker_Garbage.FormatMoney( Broker_Garbage:GetOption("moneyEarned", false) ))
		localLostText:SetText(Broker_Garbage.FormatMoney( Broker_Garbage:GetOption("moneyLostByDeleting", false) ))
	end
end
local _ = Broker_Garbage:RegisterPlugin(BGC.locale.StatisticsHeading, Options_Statistics)
