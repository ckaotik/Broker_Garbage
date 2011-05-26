--[[ Copyright (c) 2010-2011, ckaotik
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
Neither the name of ckaotik nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. ]]--
addonName, BG = ...

-- Libraries & setting up the LDB
-- ---------------------------------------------------------
BG.PT = LibStub("LibPeriodicTable-3.1", true)	-- don't scream if LPT isn't present

-- internal variables
local locked = false				-- set to true while selling stuff
local sellValue = 0					-- represents the actual value that we sold stuff for
local repairCost = 0				-- the amount of money that we repaired for
local itemCount = 0                 -- number of items we sold

-- Event Handler
-- ---------------------------------------------------------
local frame = CreateFrame("frame")
local function eventHandler(self, event, arg1, ...)
	if event == "ADDON_LOADED" and arg1 == addonName then
		BG.CheckSettings()
		BG.AdjustLists_4_1()

		-- some default values initialization
		BG.isAtVendor = false
		BG.sellLog = {}
		BG.totalBagSpace = 0
		BG.totalFreeSlots = 0
		
		-- inventory database
		BG.clamInInventory = false
		BG.containerInInventory = false

		-- full inventory scan to start with
		BG.itemsCache = {}
		BG.cheapestItems = {}
		BG.ScanInventory()	-- initializes and fills cache

		frame:UnregisterEvent("ADDON_LOADED")
	elseif event == "BAG_UPDATE" then
		if not arg1 or arg1 < 0 or arg1 > 4 then return end
		
		BG.Debug("Bag Update", arg1, ...)
		BG.ScanInventoryContainer(arg1)	-- partial inventory scan on the relevant container
		
	elseif event == "MERCHANT_SHOW" then
		BG.isAtVendor = true
		
		BG:UpdateRepairButton()
		local disable = BG.disableKey[BG_GlobalDB.disableKey]
		if not (disable and disable()) then
			BG:AutoRepair()
			BG:AutoSell()
		end
		
	elseif event == "MERCHANT_CLOSED" then
		BG.isAtVendor = false
		
		-- fallback unlock
		if locked then
			BG.isAtVendor = false
			locked = false
			BG.Debug("Fallback Unlock: Merchant window closed, scan lock released.")
		end
	
	elseif event == "AUCTION_HOUSE_CLOSED" then
		-- Update cached auction values in case anything changed
		BG.ScanInventory(true)	-- [TODO] this is actually incorrect now. what we want: clearcache and then re-order cheapest items table
	
	elseif (locked or repairCost ~=0) and event == "PLAYER_MONEY" then -- regular unlock
		if sellValue ~= 0 and repairCost ~= 0 and ((-1)*sellValue <= repairCost+2 and (-1)*sellValue >= repairCost-2) then
			-- wrong player_money event (resulting from repair, not sell)
			BG.Debug("Not yet ... Waiting for relevant money change.")
			return 
		end
		
		-- print transaction information
		if BG.didSell and BG.didRepair then
			BG.Print(format(BG.locale.sellAndRepair, 
					BG:FormatMoney(sellValue), 
					BG:FormatMoney(repairCost), 
					BG:FormatMoney(sellValue - repairCost)
			))
		elseif BG.didRepair then
			BG.Print(format(BG.locale.repair, BG:FormatMoney(repairCost)))
		elseif BG.didSell then
			BG.FinishSelling()
		end
		
		BG.didSell, BG.didRepair = nil, nil
		sellValue, itemCount, repairCost = 0, 0, 0
		
		locked = false
		BG.Debug("Regular Unlock: Money received, scan lock released.")
	elseif event == "UI_ERROR_MESSAGE" and arg1 and arg1 == ERR_VENDOR_DOESNT_BUY then
		-- this merchant does not buy things! Revert any statistics changes
		--BG_LocalDB.moneyEarned  = BG_LocalDB.moneyEarned    - sellValue
		--BG_GlobalDB.moneyEarned = BG_GlobalDB.moneyEarned   - sellValue
		--BG_GlobalDB.itemsSold   = BG_GlobalDB.itemsSold     - itemCount
		
		BG.didSell = nil
		sellValue, itemCount = 0, 0
		
		BG.Print(BG.locale.reportCannotSell)
	end	
end

-- register events
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("BAG_UPDATE")
frame:RegisterEvent("MERCHANT_SHOW")
frame:RegisterEvent("MERCHANT_CLOSED")
frame:RegisterEvent("AUCTION_HOUSE_CLOSED")
frame:RegisterEvent("PLAYER_MONEY")
frame:RegisterEvent("UI_ERROR_MESSAGE")

frame:SetScript("OnEvent", eventHandler)

-- [TODO] maybe add "restack now" button to bag frames



-- deletes the item in a given location of your bags
function BG:Delete(item, position)
	local itemID, itemCount, cursorType
	
	if type(item) == "string" and item == "cursor" then
		-- item on the cursor
		cursorType, itemID = GetCursorInfo()
		if cursorType ~= "item" then
			BG.Print("Error! Trying to delete an item from the cursor, but there is none.")
			return
		end
		itemCount = position	-- second argument is the item count

	elseif type(item) == "table" then
		-- item given as an itemTable
		itemID = item.itemID
		position = {item.bag, item.slot}
	
	elseif type(item) == "number" then
		-- item given via its itemID
		itemID = item
	
	elseif item then
		-- item given via its itemLink
		itemID = BG.GetItemID(item)
	else
		BG.Print("Error! BG:Delete() no argument supplied.")
		return
	end

	-- security check
	local bag = position[1] or item.bag
	local slot = position[2] or item.slot
	if not cursorType and (not (bag and slot) or GetContainerItemID(bag, slot) ~= itemID) then
		BG.Print("Error! Item to be deleted is not the expected item.")
		BG.Debug("I got these parameters:", item, bag, slot)
		return
	end
	
	-- make sure there is nothing unwanted on the cursor
	if not cursorType then
		ClearCursor()
	end
	
	_, itemCount = GetContainerItemInfo(bag, slot)
	
	-- actual deleting happening after this
	securecall(PickupContainerItem, bag, slot)
	securecall(DeleteCursorItem)					-- comment this line to prevent item deletion
	
	local itemValue = (BG.GetCached(itemID).value or 0) * itemCount	-- if an item is unknown to the cache, statistics will not change
	-- statistics
	BG_GlobalDB.itemsDropped 		= BG_GlobalDB.itemsDropped + itemCount
	BG_GlobalDB.moneyLostByDeleting	= BG_GlobalDB.moneyLostByDeleting + itemValue
	BG_LocalDB.moneyLostByDeleting 	= BG_LocalDB.moneyLostByDeleting + itemValue
	
	local _, itemLink = GetItemInfo(itemID)
	BG.Print(format(BG.locale.itemDeleted, itemLink, itemCount))
end

-- special functionality
-- ---------------------------------------------------------
-- when at a merchant this will clear your bags of junk (gray quality) and items on your autoSellList
function BG:AutoSell()
	if not BG.isAtVendor then
		return
	end
	
	if self == _G["BG_SellIcon"] then
		BG.Debug("AutoSell was triggered by a click on Sell Icon.")
	
	elseif not BG_GlobalDB.autoSellToVendor then
		-- we're not supposed to sell. jump out
		return
	end
	
	BG.PrepareAutoSell()
	BG.GatherSellStatistics()
	BG.FinishSelling(self == _G["BG_SellIcon"])
end

function BG.PrepareAutoSell()
	wipe(BG.sellLog)    -- reset data for refilling
	
	sellValue = 0
	local cachedItem
	for _, item in ipairs(BG.cheapestItems) do
		cachedItem = BG.GetCached(item.itemID)
		if item.isValid and (item.source == BG.AUTOSELL
			or (item.source ~= BG.EXCLUDE and cachedItem.quality == 0)
			or (item.source == BG.INCLUDE and BG_GlobalDB.autoSellIncludeItems)
			or (item.source == BG.OUTDATED and BG_GlobalDB.sellOldGear)
			or (item.source == BG.UNUSABLE and BG_GlobalDB.sellNotWearable) ) then
			BG.Debug("AutoSell", item.isValid,
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
				BG.Debug("Selling", item.itemID, item.bag, item.slot)

				ClearCursor()
				UseContainerItem(item.bag, item.slot)
				table.insert(BG.sellLog, item)
			end
		end
	end
	if locked then BG.didSell = true end    -- otherwise we didn't sell anything
end

function BG.GatherSellStatistics()
	if not BG.didSell then return end       -- in case something went wrong, e.g. merchant doesn't buy
	sellValue, itemCount = 0, 0
	for _, data in ipairs(BG.sellLog) do
		if BG_GlobalDB.showSellLog then
			BG.Print(BG.locale.sellItem, data.item, data.count, BG:FormatMoney(data.count * data.value))
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
			BG.Print(format(BG.locale.sell, BG:FormatMoney(sellValue)))
		end
		_G["BG_SellIcon"]:GetNormalTexture():SetDesaturated(true)
	end
	
	BG:UpdateRepairButton()
end

-- automatically repair at a vendor
function BG:AutoRepair()
	if BG_GlobalDB.autoRepairAtVendor and CanMerchantRepair() then
		repairCost = GetRepairAllCost()
		
		if repairCost > 0 and not BG_LocalDB.neverRepairGuildBank and CanGuildBankRepair()
			and (GetGuildBankWithdrawMoney() == -1 or GetGuildBankWithdrawMoney() >= repairCost) then
			-- guild repair if we're allowed to and the user wants it
			RepairAllItems(1)
			BG.didRepair = true
		elseif repairCost > 0 and GetMoney() >= repairCost then
			-- not enough allowance to guild bank repair, pay ourselves
			RepairAllItems(0)
			BG.didRepair = true
		elseif repairCost > 0 then
			-- oops. give us your moneys!
			BG.Print(format(BG.locale.couldNotRepair, BG:FormatMoney(repairCost)))
		end
	else
		repairCost = 0
	end
end