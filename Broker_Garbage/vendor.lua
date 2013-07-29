local _, BG = ...

-- GLOBALS: BG_GlobalDB, BG_LocalDB, _G
-- GLOBALS: GameTooltip, MerchantFrameInset, MerchantRepairAllButton, CreateFrame, MerchantFrame
-- GLOBALS: SetItemButtonTexture, SetItemButtonDesaturated, MerchantFrame_UpdateRepairButtons, RepairAllItems, GetMoney, GetGuildBankWithdrawMoney, GetRepairAllCost, CanMerchantRepair, CanGuildBankRepair, GetContainerItemInfo, ClearCursor, UseContainerItem
-- GLOBALS: wipe, pairs, table, string

local AceTimer = LibStub("AceTimer-3.0")

-- --------------------------------------------------------
--  Merchant: auto sell, auto repair
-- --------------------------------------------------------
local sellLog = {}
local sellValue, repairCost, guildRepair
function BG.AutoSell(manualSell)
	if not BG_GlobalDB.autoSellToVendor and not manualSell then
		return
	end

	sellValue = 0
	wipe(sellLog)    -- reset data for refilling
	for location, cacheData in pairs(BG.containers) do
		if cacheData.sell then
			sellValue = sellValue + cacheData.item.v

			ClearCursor()
			UseContainerItem(BG.GetBagSlot(location))
			table.insert(sellLog, location)
		end
	end

	if #sellLog > 0 then
		AceTimer:ScheduleTimer(BG.ReportSelling, 0.3, 0, 0, #sellLog)
	elseif BG_GlobalDB.reportNothingToSell then
		BG.Print(BG.locale.reportNothingToSell)
	end
end

function BG.ReportSelling(repairCost, iteration, maxIteration, isGuildRepair)
	local sellValue, numItems, isLocked = BG.CheckSoldItems()

	if isLocked and iteration < (maxIteration or 10)+5 then
		AceTimer:ScheduleTimer(BG.ReportSelling, 0.3, repairCost, iteration+1, maxIteration, isGuildRepair)
	elseif sellValue > 0 then
		BG.Print(string.format(BG.locale.sell, BG.FormatMoney(sellValue)))

		-- regular sell unlock
		BG.UpdateStatistics(sellValue, numItems)
	end
	--[[if sellValue > 0 and repairCost > 0 then
		BG.Print(string.format(BG.locale.sellAndRepair,
			BG.FormatMoney(sellValue),
			BG.FormatMoney(repairCost),
			isGuildRepair and BG.locale.guildRepair or "",
			BG.FormatMoney(sellValue - repairCost)
		))
	else--]]
end

function BG.CheckSoldItems()
	local cacheData, isLocked, itemLocked, itemLink, vendorValue, slotString
	local actualSellValue, numItemsSold = 0, 0

	for index, location in pairs(sellLog) do
		cacheData = BG.containers[location]
		_, _, isLocked, _, _, _, itemLink = GetContainerItemInfo( BG.GetBagSlot(location) )

		if itemLink and isLocked then
			-- didn't sell item so far
			itemLocked = isLocked
			table.remove(sellLog, index)
			actualSellValue = 0 -- beh.
		else -- TODO: I broke it T.T
			--[[ _, itemLink, _, _, _, _, _, _, _, _, vendorValue = GetItemInfo( cacheData.item.id )

			local sellValue, count = vendorValue * cacheData.count, cacheData.count
			BG.UpdateStatistics(sellValue, count)

			actualSellValue = actualSellValue + sellValue
			numItemsSold = numItemsSold + count
			if BG_GlobalDB.showSellLog then
				BG.Print(string.format(BG.locale.sellItem, itemLink, cacheData.count or '0', BG.FormatMoney(cacheData.value or '0')))
			end--]]
			actualSellValue = sellValue
		end
	end
	return actualSellValue, numItemsSold, itemLocked
end

function BG.UpdateStatistics(sellValue, numItems)
	if not sellValue or not numItems then return end
	BG_LocalDB.moneyEarned  = BG_LocalDB.moneyEarned    + sellValue
	BG_GlobalDB.moneyEarned = BG_GlobalDB.moneyEarned   + sellValue
	BG_GlobalDB.itemsSold   = BG_GlobalDB.itemsSold     + numItems
end

-- automatically repair at a vendor
function BG.AutoRepair()
	repairCost, guildRepair = 0, nil
	if BG_GlobalDB.autoRepairAtVendor and CanMerchantRepair() then
		local repairCost = GetRepairAllCost()
		local guildRepairFunds = CanGuildBankRepair() and GetGuildBankWithdrawMoney()
		local guildRepair = BG_LocalDB.repairGuildBank and guildRepairFunds and (guildRepairFunds == -1 or guildRepairFunds >= repairCost)

		if repairCost > 0 then
			if guildRepair then
				-- guild repair if we're allowed to and the user wants it
				RepairAllItems(1)
			elseif GetMoney() >= repairCost then
				-- not enough allowance to guild bank repair, pay ourselves
				RepairAllItems(0)
			else
				-- oops, guess we're broke
				BG.Print(string.format(BG.locale.couldNotRepair, BG.FormatMoney(repairCost)))
				repairCost = 0
			end

			BG.Print(string.format(BG.locale.repair, BG.FormatMoney(repairCost), guildRepair and BG.locale.guildRepair or ""))
		end
	end
end


-- == Merchant Sell Icon ==
local function UpdateMerchantButton()
	local sellIcon = _G["BrokerGarbageSellIcon"]

	if MerchantFrame.selectedTab ~= 1 or not BG_GlobalDB.showAutoSellIcon then
		if sellIcon and sellIcon:IsShown() then
			sellIcon:Hide()
		end
	else
		if not sellIcon then
			sellIcon = CreateFrame("Button", "BrokerGarbageSellIcon", MerchantFrame, "ItemButtonTemplate")
			sellIcon:SetScale(32/37)
			sellIcon:SetScript("OnClick", BG.AutoSell)
			sellIcon:SetScript("OnEnter", function(self)
				GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
				GameTooltip:SetText(BG.junkValue ~= 0 and string.format(BG.locale.autoSellTooltip, BG.FormatMoney(BG.junkValue))
						or BG.locale.reportNothingToSell, nil, nil, nil, nil, true)
			end)
			sellIcon:SetScript("OnLeave", function() GameTooltip:Hide() end)
			SetItemButtonTexture(sellIcon, "Interface\\Icons\\achievement_bg_returnxflags_def_wsg")
		end

		SetItemButtonDesaturated(sellIcon, BG.junkValue == 0)

		MerchantRepairAllButton:SetPoint("BOTTOMRIGHT", MerchantFrame, "BOTTOMLEFT", 100-18, 30)
		if MerchantRepairAllButton:IsShown() then
			sellIcon:SetPoint("BOTTOMRIGHT", MerchantFrameInset, "BOTTOM", -12, 5)
		else
			sellIcon:SetPoint("BOTTOMRIGHT", MerchantFrameInset, "BOTTOM", -12, 10)
		end
		sellIcon:Show()
	end
end
hooksecurefunc("MerchantFrame_UpdateRepairButtons", UpdateMerchantButton)
hooksecurefunc("MerchantFrame_UpdateBuybackInfo", function()
	local sellIcon = _G["BrokerGarbageSellIcon"]
	if sellIcon then
		sellIcon:Hide()
	end
end)

-- --------------------------------------------------------
--  Merchant events
-- --------------------------------------------------------
local events = BG.events
events:RegisterEvent("MERCHANT_SHOW")
events:RegisterEvent("MERCHANT_CLOSED")

function events:MERCHANT_SHOW()
	BG.isAtVendor = true
	local disable = BG.disableKey[BG_GlobalDB.disableKey]
	if not (disable and disable()) then
		BG.AutoSell()
		BG.AutoRepair()
	end
end

function events:MERCHANT_CLOSED(event)
	BG.isAtVendor = nil
end
