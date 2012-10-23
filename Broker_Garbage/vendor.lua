local _, BG = ...

-- GLOBALS: BG_GlobalDB, BG_LocalDB, _G
-- GLOBALS: GameTooltip, MerchantFrameInset, MerchantRepairAllButton, MerchantRepairText, CreateFrame, MerchantFrame
-- GLOBALS: SetItemButtonTexture, SetItemButtonDesaturated, MerchantFrame_UpdateRepairButtons, RepairAllItems, GetMoney, GetGuildBankWithdrawMoney, GetRepairAllCost, CanMerchantRepair, CanGuildBankRepair, GetContainerItemInfo, ClearCursor, UseContainerItem
local wipe = wipe
local pairs = pairs
local ipairs = ipairs
local select = select
local tinsert = table.insert
local tremove = table.remove
local format = string.format

function BG.ManualAutoSell()
	local sellValue, numItems = BG.AutoSell(true)

	if sellValue ~= 0 then
		BG.CallWithDelay(BG.ReportSelling, 0.3, 0, 0, numItems)
	end
end

function BG.AutoSell(manualSell)
	if not BG.isAtVendor or (not manualSell and not BG_GlobalDB.autoSellToVendor) then return 0, 0 end
	wipe(BG.sellLog)    -- reset data for refilling

	local sellValue = 0
	local cachedItem
	for tableIndex, item in ipairs(BG.cheapestItems) do
		if item.sell and not item.invalid then
			if sellValue == 0 then
				BG.Debug("Selling items, scans locked")
				BG.locked = true
			end
			BG.Debug("Selling", item.itemID, item.bag, item.slot)
			sellValue = sellValue + item.value

			ClearCursor()
			UseContainerItem(item.bag, item.slot)
			tinsert(BG.sellLog, tableIndex)
		end
	end

	if #(BG.sellLog) == 0 and BG_GlobalDB.reportNothingToSell then
		BG.Print(BG.locale.reportNothingToSell)
	end

	return sellValue, #(BG.sellLog)
end

function BG.ReportSelling(repairCost, iteration, maxIteration, isGuildRepair)
	BG.Debug("ReportSelling", repairCost, iteration)
	local sellValue, numItems, isLocked = BG.CheckSoldItems()

	if isLocked and iteration < (maxIteration or 10)+5 then
		BG.CallWithDelay(BG.ReportSelling, 0.3, repairCost, iteration+1, maxIteration, isGuildRepair)
	elseif isLocked then
		BG.Print("Error! Was waiting too long for items to unlock after selling, but they are still locked.")
	else
		if sellValue > 0 and repairCost > 0 then
			BG.Print(format(BG.locale.sellAndRepair,
				BG.FormatMoney(sellValue),
				BG.FormatMoney(repairCost),
				isGuildRepair and BG.locale.guildRepair or "",
				BG.FormatMoney(sellValue - repairCost)
			))
		elseif sellValue > 0 then
			BG.Print(format(BG.locale.sell, BG.FormatMoney(sellValue)))
		end

		-- regular sell unlock
		BG.UpdateStatistics(sellValue, numItems)

		BG.locked = nil
		BG.Debug("Scanning unlocked")

		BG.sellValue, BG.repairCost = 0, 0
		BG.ScanInventory()

		BG.UpdateMerchantButton()
	end
end

function BG.CheckSoldItems()
	local item, isLocked, itemLocked, itemLink, vendorValue, slotString
	local actualSellValue, numItemsSold = 0, 0

	for sellIndex, tableIndex in ipairs(BG.sellLog) do
		item = BG.cheapestItems[tableIndex]
		_, _, isLocked, _, _, _, itemLink = GetContainerItemInfo(item.bag, item.slot)
		slotString = item.bag*100 + item.slot

		if itemLink and isLocked then
			itemLocked = true
			BG.Debug("Item not sold: "..itemLink..", "..slotString)
		elseif itemLink then
			-- can't sell this item (but tried to!)
			BG.Debug("Can't sell item "..itemLink..", "..slotString)
			tremove(BG.sellLog, sellIndex)
		else
			_, itemLink, _, _, _, _, _, _, _, _, vendorValue = GetItemInfo(item.itemID)
			actualSellValue = actualSellValue + (vendorValue * item.count)
			numItemsSold = numItemsSold + item.count

			if BG_GlobalDB.showSellLog then
				BG.Print(format(BG.locale.sellItem, itemLink, item.count, BG.FormatMoney(item.value)))
			end
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
	local repairCost, guildRepair = 0, nil
	if BG_GlobalDB.autoRepairAtVendor and CanMerchantRepair() then
		repairCost = GetRepairAllCost()
		local guildRepairFunds = CanGuildBankRepair() and GetGuildBankWithdrawMoney()

		if repairCost > 0 then
			if BG_LocalDB.repairGuildBank and guildRepairFunds and (guildRepairFunds == -1 or guildRepairFunds >= repairCost) then
				-- guild repair if we're allowed to and the user wants it
				guildRepair = true
				RepairAllItems(1)
			elseif GetMoney() >= repairCost then
				-- not enough allowance to guild bank repair, pay ourselves
				RepairAllItems(0)
			else
				-- oops. give us your moneys!
				BG.Print(format(BG.locale.couldNotRepair, BG.FormatMoney(repairCost)))
				repairCost = 0
			end
		end
	end
	return repairCost, guildRepair
end


-- == Merchant Sell Icon ==
function BG.UpdateMerchantButton(forceUpdate)
	local sellIcon = _G["BG_SellIcon"]

	if MerchantFrame.selectedTab ~= 1 or not BG_GlobalDB.showAutoSellIcon then
		if sellIcon then
			sellIcon:Hide()
		end

		if not BG_GlobalDB.showAutoSellIcon then
			if forceUpdate then
				MerchantFrame_UpdateRepairButtons()
			end
		end
	else
		if not sellIcon then
			sellIcon = CreateFrame("Button", "BG_SellIcon", MerchantFrame, "ItemButtonTemplate")
			SetItemButtonTexture(sellIcon, "Interface\\Icons\\achievement_bg_returnxflags_def_wsg")

			sellIcon:SetFrameStrata("HIGH")
			sellIcon:SetScript("OnClick", BG.ManualAutoSell)
			sellIcon:SetScript("OnEnter", function(self)
				GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
				GameTooltip:SetText(BG.junkValue ~= 0 and format(BG.locale.autoSellTooltip, BG.FormatMoney(BG.junkValue))
						or BG.locale.reportNothingToSell, nil, nil, nil, nil, true)
			end)
			sellIcon:SetScript("OnLeave", function() GameTooltip:Hide() end)
		end

		if MerchantRepairAllButton:IsShown() then
			MerchantRepairAllButton:ClearAllPoints()
			MerchantRepairAllButton:SetPoint("BOTTOMLEFT", 51, 33)
			MerchantRepairText:Hide()
		end

		-- update tooltip value
		SetItemButtonDesaturated(sellIcon, BG.junkValue == 0)

		local iconSize = MerchantRepairAllButton:GetHeight()
		sellIcon:SetHeight(iconSize)
		sellIcon:SetWidth(iconSize)
		_G[sellIcon:GetName().."NormalTexture"]:SetHeight(64/37 * iconSize)
		_G[sellIcon:GetName().."NormalTexture"]:SetWidth(64/37 * iconSize)

		sellIcon:SetPoint("BOTTOMRIGHT", MerchantFrameInset, "BOTTOM", -10, 8)
		sellIcon:Show()
	end
end
hooksecurefunc("MerchantFrame_Update", BG.UpdateMerchantButton)
