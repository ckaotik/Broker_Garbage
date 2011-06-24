--[[ Copyright (c) 2010-2011, ckaotik
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
Neither the name of ckaotik nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. ]]--
local addonName, BG = ...

-- Libraries & setting up the LDB
-- ---------------------------------------------------------
BG.PT = LibStub("LibPeriodicTable-3.1", true)	-- don't scream if LPT isn't present

-- internal variables
BG.locked = nil						-- set to true while selling stuff
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
		BG.isAtVendor = nil
		BG.sellLog = {}
		BG.totalBagSpace = 0
		BG.totalFreeSlots = 0
		
		-- inventory database
		BG.containerInInventory = nil
		BG.itemsCache = {}		-- contains static item data, e.g. price, stack size
		BG.itemLocations = {}	-- itemID = { cheapestList-index }
		BG.cheapestItems = {}	-- contains up-to-date labeled data
		BG.currentRestackItems = {}	-- contains itemIDs when restacking
		
		BG.ScanInventory()	-- initializes and fills caches

		frame:RegisterEvent("BAG_UPDATE")
		frame:RegisterEvent("MERCHANT_SHOW")
		frame:RegisterEvent("MERCHANT_CLOSED")
		frame:RegisterEvent("AUCTION_HOUSE_CLOSED")
		frame:RegisterEvent("PLAYER_MONEY")
		frame:RegisterEvent("UI_ERROR_MESSAGE")
		frame:RegisterEvent("LOOT_OPENED")
		frame:RegisterEvent("ITEM_PUSH")

		frame:UnregisterEvent("ADDON_LOADED")

	elseif event == "BAG_UPDATE" and not BG.locked then
		if not arg1 or arg1 < 0 or arg1 > 4 then return end
		
		BG.Debug("Bag Update", arg1, ...)
		BG.ScanInventoryContainer(arg1)	-- partial inventory scan on the relevant container
	
	elseif event == "LOOT_OPENED" or event == "ITEM_PUSH" then	-- [TODO] choose proper events
		if BG_GlobalDB.restackInventory then
			BG.DoFullRestack()
		end

	elseif event == "MERCHANT_SHOW" then
		BG.isAtVendor = true
		
		BG:UpdateRepairButton()
		local disable = BG.disableKey[BG_GlobalDB.disableKey]
		if not (disable and disable()) then
			BG.AutoRepair()
			BG.AutoSell()
		end
	
	elseif event == "ITEM_UNLOCKED" then	-- only registered during restack
		BG.Restack()
	
	elseif event == "MERCHANT_CLOSED" then
		BG.isAtVendor = nil
		
		-- fallback unlock
		if BG.locked then
			BG.locked = nil
			BG.Debug("Fallback Unlock: Merchant window closed, scan lock released.")
		end
	
	elseif event == "AUCTION_HOUSE_CLOSED" then
		-- Update cached auction values in case anything changed
		BG.ClearCache()	-- auction prices may change associated labels!
		BG.ScanInventory()
	
	elseif (BG.locked or repairCost ~=0) and event == "PLAYER_MONEY" then -- regular unlock
		if sellValue ~= 0 and repairCost ~= 0 and ((-1)*sellValue <= repairCost+2 and (-1)*sellValue >= repairCost-2) then
			-- wrong player_money event (resulting from repair, not sell)
			BG.Debug("Not yet ... Waiting for relevant money change.")
			return 
		end
		
		-- print transaction information
		if BG.didSell and BG.didRepair then
			BG.Print(format(BG.locale.sellAndRepair, 
					BG.FormatMoney(BG.junkValue), 
					BG.FormatMoney(repairCost), 
					BG.FormatMoney(BG.junkValue - repairCost)
			))
		elseif BG.didRepair then
			BG.Print(format(BG.locale.repair, BG.FormatMoney(repairCost)))
		elseif BG.didSell then
			BG.FinishSelling()
		end
		
		BG.didSell, BG.didRepair = nil, nil
		sellValue, itemCount, repairCost = 0, 0, 0
		
		BG.locked = false
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
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", eventHandler)
BG.frame = frame

-- [TODO] maybe add "restack now" button to bag frames
-- [TODO] fix memory load on logon!