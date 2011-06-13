local _, BG = ...

function BG.ManualAutoSell()
	BG.AutoSell(true)
	-- [TODO] report statistics
end

-- when at a merchant this will clear your bags of junk (gray quality) and items on your autoSellList
function BG.AutoSell(manual)
	if not BG.isAtVendor or not (manual or BG_GlobalDB.autoSellToVendor) then return end
	
	BG.PrepareAutoSell()
	BG.GatherSellStatistics()
	BG.FinishSelling(manual)
end

function BG.PrepareAutoSell()
	wipe(BG.sellLog)    -- reset data for refilling
	
	sellValue = 0
	local cachedItem
	for _, item in ipairs(BG.cheapestItems) do
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
				if not locked then					
					BG.Debug("Inventory scans locked")
					locked = true
				end

				if not item.sell and GetUnitName("player") == "Thany" and GetRealmName() == "Die Aldor" then
					BG.Print("WRONG SELL TAG! "..item.itemLink.." (Source: "..item.source..")")	-- [TODO] remove prior to release
				end
				BG.Debug("Selling", item.itemID, item.bag, item.slot)

				ClearCursor()
				UseContainerItem(item.bag, item.slot)
				table.insert(BG.sellLog, item)
			end
		end
	end
	if locked then BG.didSell = true end    -- otherwise we didn't sell anything
	BG.ScanInventory()
end

function BG.GatherSellStatistics()
	if not BG.didSell then return end       -- in case something went wrong, e.g. merchant doesn't buy
	sellValue, itemCount = 0, 0
	for _, data in ipairs(BG.sellLog) do
		if BG_GlobalDB.showSellLog then
			BG.Print(BG.locale.sellItem, data.item, data.count, BG.FormatMoney(data.count * data.value))
		end
		
		sellValue = sellValue + (data.count * data.value)
		itemCount = itemCount + data.count
	end

	-- update statistics
	BG_LocalDB.moneyEarned  = BG_LocalDB.moneyEarned    + sellValue
	BG_GlobalDB.moneyEarned = BG_GlobalDB.moneyEarned   + sellValue
	BG_GlobalDB.itemsSold   = BG_GlobalDB.itemsSold     + itemCount
end

function BG.FinishSelling(isUserStarted)
	-- create output if needed
	if isUserStarted then
		if sellValue == 0 and BG_GlobalDB.reportNothingToSell then
			BG.Print(BG.locale.reportNothingToSell)
		elseif sellValue ~= 0 and not BG_GlobalDB.autoSellToVendor then
			BG.Print(format(BG.locale.sell, BG.FormatMoney(sellValue)))
		end
		_G["BG_SellIcon"]:GetNormalTexture():SetDesaturated(true)
	end
	BG.junkValue = 0

	BG:UpdateRepairButton()
end

-- automatically repair at a vendor
function BG.AutoRepair()
	if BG_GlobalDB.autoRepairAtVendor and CanMerchantRepair() then
		repairCost = GetRepairAllCost()
		local guildRepairFunds = CanGuildBankRepair() and GetGuildBankWithdrawMoney()
		
		if repairCost > 0 then
			if BG_LocalDB.repairGuildBank and guildRepairFunds and (guildRepairFunds == -1 or guildRepairFunds >= repairCost) then
				-- guild repair if we're allowed to and the user wants it
				if GetUnitName("player") == "Thany" and GetRealmName() == "Die Aldor" then
					BG.Print("Repair using guild funds "..guildRepairFunds) -- [TODO] remove prior to release!
				end
				RepairAllItems(1)
				BG.didRepair = true
			elseif GetMoney() >= repairCost then
				-- not enough allowance to guild bank repair, pay ourselves
				RepairAllItems(0)
				BG.didRepair = true
			else
				-- oops. give us your moneys!
				BG.Print(format(BG.locale.couldNotRepair, BG.FormatMoney(repairCost)))
			end
		end
	else
		repairCost = 0
	end
end