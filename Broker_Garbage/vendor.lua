local addonName, addon, _ = ...
local plugin = addon:NewModule('Vendor', 'AceEvent-3.0', 'AceTimer-3.0')

-- GLOBALS: _G, LibStub
-- GLOBALS: GameTooltip, MerchantFrameInset, MerchantRepairAllButton, CreateFrame, MerchantFrame
-- GLOBALS: SetItemButtonTexture, SetItemButtonDesaturated, MerchantFrame_UpdateRepairButtons, RepairAllItems, GetMoney, GetGuildBankWithdrawMoney, GetRepairAllCost, CanMerchantRepair, CanGuildBankRepair, GetContainerItemInfo, ClearCursor, UseContainerItem
-- GLOBALS: wipe, pairs, table, string, hooksecurefunc

-- TODO: change sellLog/report to use events instead of timers

-- --------------------------------------------------------
--  Merchant: auto sell, auto repair
-- --------------------------------------------------------
local sellLog = {}
local sellValue, repairCost, guildRepair
function plugin:AutoSell(manualTrigger)
	if not self.db.global.autoSell and not manualTrigger then
		return
	end

	sellValue = 0
	wipe(sellLog) -- reset data for refilling
	for location, cacheData in pairs(addon.containers) do
		if cacheData.sell then
			sellValue = sellValue + (cacheData.item.v * cacheData.count)

			ClearCursor()
			UseContainerItem(addon.GetBagSlot(location))
			table.insert(sellLog, location)
		end
	end

	if #sellLog > 0 then
		self:ScheduleTimer(self.ReportSelling, 0.3, self, 0, #sellLog)
	elseif self.db.global.reportNothingToSell then
		addon.Print(addon.locale.reportNothingToSell)
	end
end

function plugin:ReportSelling(iteration, maxIteration)
	local checkedSellValue, numItems, isLocked = self:CheckSoldItems()

	if isLocked and iteration < (maxIteration or 10)+5 then
		self:ScheduleTimer(self.ReportSelling, 0.3, self, iteration+1, maxIteration)
		return
	elseif sellValue > 0 and repairCost > 0 then
		-- reports use short money format
		addon.Print(string.format(addon.locale.sellAndRepair,
			addon.FormatMoney(sellValue, nil, true),
			addon.FormatMoney(repairCost, nil, true),
			guildRepair and addon.locale.guildRepair or '',
			addon.FormatMoney(guildRepair and sellValue or (sellValue - repairCost), nil, true)
		))
	elseif sellValue > 0 then
		addon.Print(string.format(addon.locale.sell, addon.FormatMoney(sellValue, nil, true)))
	end

	-- regular sell unlock
	addon.UpdateSellStatistics(sellValue, numItems)
end

function plugin:CheckSoldItems()
	local cacheData, isLocked, itemLocked, itemLink, vendorValue, slotString
	local actualSellValue, numItemsSold = 0, 0

	for index, location in pairs(sellLog) do
		-- cacheData = addon.containers[location]
		_, _, isLocked, _, _, _, itemLink = GetContainerItemInfo( addon.GetBagSlot(location) )

		if itemLink and isLocked then
			-- didn't sell item so far
			itemLocked = isLocked
			table.remove(sellLog, index)
			actualSellValue = 0 -- beh.
		else -- TODO: I broke it T.T
			--[[ _, itemLink, _, _, _, _, _, _, _, _, vendorValue = GetItemInfo( cacheData.item.id )

			local sellValue, count = vendorValue * cacheData.count, cacheData.count
			addon.UpdateSellStatistics(sellValue, count)

			actualSellValue = actualSellValue + sellValue
			numItemsSold = numItemsSold + count
			if plugin.db.global.sellLog then
				addon.Print(string.format(addon.locale.sellItem, itemLink, cacheData.count or '0', addon.FormatMoney(cacheData.value or '0', nil, true)))
			end--]]
			actualSellValue = sellValue
		end
	end
	return actualSellValue, numItemsSold, itemLocked
end

-- automatically repair at a vendor
function plugin:AutoRepair()
	repairCost, guildRepair = 0, nil
	if self.db.global.autoRepair and CanMerchantRepair() then
		repairCost = GetRepairAllCost()
		guildRepair = self.db.char.repairGuildBank and CanGuildBankRepair()
		guildRepair = guildRepair and (GetGuildBankWithdrawMoney() == -1 or GetGuildBankWithdrawMoney() >= repairCost)

		if repairCost > 0 then
			if guildRepair then
				-- guild repair if we're allowed to and the user wants it
				RepairAllItems(true)
			elseif GetMoney() >= repairCost then
				-- not enough allowance to guild bank repair, pay ourselves
				RepairAllItems(false)
			else
				-- oops, guess we're broke
				addon.Print(string.format(addon.locale.couldNotRepair, addon.FormatMoney(repairCost, nil, true)))
				repairCost = 0
			end

			if sellValue == 0 and repairCost > 0 then
				addon.Print(string.format(addon.locale.repair, addon.FormatMoney(repairCost, nil, true), guildRepair and addon.locale.guildRepair or ""))
			end
		end
	end
end

-- == Merchant Sell Icon ==
local function GetSellButton(noCreate)
	local button = _G[addonName..'SellIcon']
	if button or noCreate then return button end

	button = CreateFrame("Button", addonName.."SellIcon", MerchantFrame, "ItemButtonTemplate")
	button:SetScale(32/37)
	button:SetScript("OnClick", function() plugin:AutoSell(true) end)
	button:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText(addon.junkValue == 0 and addon.locale.reportNothingToSell
			or string.format(addon.locale.autoSellTooltip, addon.FormatMoney(addon.junkValue, nil, true)),
			nil, nil, nil, nil, true)
	end)
	button:SetScript("OnLeave", GameTooltip_Hide)
	SetItemButtonTexture(button, "Interface\\Icons\\achievement_bg_returnxflags_def_wsg")

	return button
end

local function UpdateMerchantButton()
	local sellIcon = GetSellButton()

	if MerchantFrame.selectedTab ~= 1 or not plugin.db.global.addSellButton then
		if sellIcon and sellIcon:IsShown() then
			sellIcon:Hide()
		end
	else
		-- sellIcon:SetEnabled(addon.junkValue > 0)
		SetItemButtonDesaturated(sellIcon, addon.junkValue == 0)
		MerchantRepairAllButton:SetPoint("BOTTOMRIGHT", MerchantFrame, "BOTTOMLEFT", 100-18, 30)
		if MerchantRepairAllButton:IsShown() then
			sellIcon:SetPoint("BOTTOMRIGHT", MerchantFrameInset, "BOTTOM", -12, 5)
		else
			sellIcon:SetPoint("BOTTOMRIGHT", MerchantFrameInset, "BOTTOM", -12, 10)
		end
		sellIcon:Show()
	end
end

local defaults = {
	global = {
		autoSell = true,
		autoRepair = true,
		sellLog = false,
		reportActions = true, -- TODO
		reportNothingToSell = true,
		addSellButton = true,
	},
	char = {
		repairGuildBank = false,
	}
}

function plugin:OnEnable()
	self.db = addon.db:RegisterNamespace('Vendor', defaults)

	hooksecurefunc(addon, 'UpdateLDB', UpdateMerchantButton)
	hooksecurefunc('MerchantFrame_UpdateRepairButtons', UpdateMerchantButton)
	hooksecurefunc('MerchantFrame_UpdateBuybackInfo', function()
		local sellIcon = GetSellButton(true)
		if sellIcon then
			sellIcon:Hide()
		end
	end)

	self:RegisterEvent('MERCHANT_SHOW')

	local optionsTable = LibStub('LibOptionsGenerate-1.0'):GetOptionsTable(self.db, nil, addon.configLocale)
	      optionsTable.name = addonName .. ' - ' .. self:GetName()
	LibStub('AceConfig-3.0'):RegisterOptionsTable(self.name, optionsTable)
end

function plugin:MERCHANT_SHOW()
	if not addon:IsDisabled() then
		self:AutoSell()
		self:AutoRepair()
	end
end
