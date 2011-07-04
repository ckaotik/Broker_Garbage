local _, BG = ...

function BG.ManualAutoSell()
	local sellValue = BG.AutoSell()
	
	-- create output if needed
	if not sellValue then
		-- nothing, we weren't at a merchant!
	elseif sellValue == 0 and BG_GlobalDB.reportNothingToSell then
		BG.Print(BG.locale.reportNothingToSell)
	elseif sellValue ~= 0 and not BG_GlobalDB.autoSellToVendor then
		BG.Print(format(BG.locale.sell, BG.FormatMoney(sellValue)))
	end

	-- [TODO] Check what actions are needed
	-- _G["BG_SellIcon"]:GetNormalTexture():SetDesaturated(true)
	-- BG.junkValue = 0

	BG.UpdateMerchantButton()
	BG.ScanInventory()
end

function BG.AutoSell()
	if not BG.isAtVendor then return end
	BG.frame:RegisterEvent("PLAYER_MONEY")

	wipe(BG.sellLog)    -- reset data for refilling
	
	sellValue = 0
	local cachedItem
	for tableIndex, item in ipairs(BG.cheapestItems) do
		-- [TODO] to be replaced by: if item.sell then ... end


		cachedItem = BG.GetCached(item.itemID)
		if not item.invalid and (item.source == BG.AUTOSELL
			or (item.source ~= BG.EXCLUDE and cachedItem.quality == 0)
			or (item.source == BG.INCLUDE and BG_GlobalDB.autoSellIncludeItems)
			or (item.source == BG.OUTDATED and BG_GlobalDB.sellOldGear)
			or (item.source == BG.UNUSABLE and BG_GlobalDB.sellNotWearable) ) then
			BG.Debug("AutoSell", item.invalid,
				item.source == BG.AUTOSELL, 
				item.source ~= BG.EXCLUDE and cachedItem.quality == 0, 
				item.source == BG.INCLUDE and BG_GlobalDB.autoSellIncludeItems,
				item.source == BG.OUTDATED and BG_GlobalDB.sellOldGear,
				item.source == BG.UNUSABLE and BG_GlobalDB.sellNotWearable)
			if item.value ~= nil then
				if not BG.locked then					
					BG.Debug("Inventory scans locked")
					BG.locked = true
				end

				if not item.sell then
					BG.Print("WRONG SELL TAG! "..item.itemLink.." (Source: "..item.source..")")	-- [TODO] remove prior to release
				end
				BG.Debug("Selling", item.itemID, item.bag, item.slot)
				sellValue = sellValue + item.value

				ClearCursor()
				UseContainerItem(item.bag, item.slot)
				table.insert(BG.sellLog, tableIndex)
			end
		end
	end
	return sellValue
end

function BG.ReportSelling(repairCost, iteration)
	BG.Debug("ReportSelling", repairCost, iteration)
	local sellValue, numItems, isLocked = BG.CheckSoldItems()
	if isLocked and iteration < 5 then
		BG.CallWithDelay(BG.ReportSelling, 0.3, repairCost, iteration+1)
	elseif isLocked then
		BG.Print("Error! Was waiting for items to unlock after selling, but they are still locked.")
	else
		if sellValue > 0 and repairCost > 0 then
			BG.Print(format(BG.locale.sellAndRepair, 
				BG.FormatMoney(sellValue), 
				BG.FormatMoney(repairCost), 
				BG.FormatMoney(sellValue - repairCost)
			))
		--elseif repairCost > 0 then
			-- no selling happening
			-- BG.Print(format(BG.locale.repair, BG.FormatMoney(BG.repairCost)))
		elseif sellValue > 0 then
			BG.Print(format(BG.locale.sell, BG.FormatMoney(sellValue)))
		end

		-- regular sell unlock
		BG.UpdateStatistics(sellValue, numItems)

		BG.locked = nil
		BG.sellValue, BG.repairCost = 0, 0
		BG.ScanInventory()
	end
end

function BG.CheckSoldItems()
	local item, isLocked, curItem, itemLocked
	local actualSellValue, numItemsSold = 0, 0
	for sellIndex, tableIndex in ipairs(BG.sellLog) do
		item = BG.cheapestItems[tableIndex]
		curItem, _, isLocked = GetContainerItemInfo(item.bag, item.slot)

		if curItem and isLocked then
			itemLocked = true
			BG.Debug("Item not sold: "..item.itemLink..", ("..item.bag..", "..item.slot)
		elseif curItem and not isLocked then
			-- can't sell this item (but tried to!)
			tremove(BG.sellLog, sellIndex)
		else
			actualSellValue = actualSellValue + item.value
			numItemsSold = numItemsSold + item.count

			if BG_GlobalDB.showSellLog then
				BG.Print(BG.locale.sellItem, item.itemLink, item.count, BG.FormatMoney(item.value))
			end
		end
	end
	return actualSellValue, numItemsSold, isLocked
end

function BG.UpdateStatistics(sellValue, numItems)
	if not sellValue or not numItems then return end
	BG_LocalDB.moneyEarned  = BG_LocalDB.moneyEarned    + sellValue
	BG_GlobalDB.moneyEarned = BG_GlobalDB.moneyEarned   + sellValue
	BG_GlobalDB.itemsSold   = BG_GlobalDB.itemsSold     + numItems
end

-- automatically repair at a vendor
function BG.AutoRepair()
	if BG_GlobalDB.autoRepairAtVendor and CanMerchantRepair() then
		repairCost = GetRepairAllCost()
		local guildRepairFunds = CanGuildBankRepair() and GetGuildBankWithdrawMoney()
		
		if repairCost > 0 then
			if BG_LocalDB.repairGuildBank and guildRepairFunds and (guildRepairFunds == -1 or guildRepairFunds >= repairCost) then
				-- guild repair if we're allowed to and the user wants it
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
	else
		repairCost = 0
	end
	return repairCost
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
		
		-- update tooltip value
		SetItemButtonDesaturated(sellIcon, BG.junkValue == 0)

		local iconSize = MerchantRepairAllButton:GetHeight()
		sellIcon:SetHeight(iconSize)
		sellIcon:SetWidth(iconSize)
		_G[sellIcon:GetName().."NormalTexture"]:SetHeight(64/37 * iconSize)
		_G[sellIcon:GetName().."NormalTexture"]:SetWidth(64/37 * iconSize)
		
		if CanGuildBankRepair() then
			MerchantRepairAllButton:SetPoint("BOTTOMRIGHT", MerchantFrame, "BOTTOMLEFT", 115 + 18, 89 + 4);
		else
			MerchantRepairAllButton:SetPoint("BOTTOMRIGHT", MerchantFrame, "BOTTOMLEFT", 172 - 18, 91);
		end
		sellIcon:SetPoint("RIGHT", MerchantRepairAllButton, "LEFT", -4 - 36, 0)
		MerchantRepairText:Hide()
		sellIcon:Show()
	end
end
hooksecurefunc("MerchantFrame_Update", BG.UpdateMerchantButton)