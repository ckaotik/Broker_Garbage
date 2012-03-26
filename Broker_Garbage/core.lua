--[[ Copyright (c) 2010-2012, ckaotik
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
BG.locked = nil						-- is set to true while selling stuff
BG.sellValue = 0					-- represents the actual value that we sold stuff for
BG.repairCost = 0					-- the amount of money that we repaired for

-- Event Handler
-- ---------------------------------------------------------
local frame = CreateFrame("frame")
local function eventHandler(self, event, arg1, ...)
	if event == "ADDON_LOADED" and arg1 == addonName then
		-- some default values initialization
		BG.isAtVendor = nil
		BG.totalBagSpace = 0
		BG.totalFreeSlots = 0

		-- inventory database
		BG.containerInInventory = nil
		BG.itemsCache = {}		-- contains static item data, e.g. price, stack size
		BG.itemLocations = {}	-- itemID = { cheapestList-index }
		BG.cheapestItems = {}	-- contains up-to-date labeled data
		BG.sellLog = {}
		BG.currentRestackItems = {}	-- contains itemIDs when restacking

		BG.CheckSettings()
		BG.AdjustLists_4_1()

		BG.ScanInventory()	-- initializes and fills caches

		frame:RegisterEvent("BAG_UPDATE")
		frame:RegisterEvent("MERCHANT_SHOW")
		frame:RegisterEvent("MERCHANT_CLOSED")
		frame:RegisterEvent("AUCTION_HOUSE_CLOSED")
		frame:RegisterEvent("UI_ERROR_MESSAGE")
		frame:RegisterEvent("LOOT_OPENED")
		frame:RegisterEvent("EQUIPMENT_SETS_CHANGED")
		frame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
		frame:RegisterEvent("CHAT_MSG_SKILL")

		frame:UnregisterEvent("ADDON_LOADED")

	elseif event == "MERCHANT_SHOW" then
		BG.isAtVendor = true
		BG.UpdateMerchantButton()

		local disable = BG.disableKey[BG_GlobalDB.disableKey]
		if not (disable and disable()) then
			local numSellItems
			BG.sellValue, numSellItems = BG.AutoSell()
			BG.repairCost = BG.AutoRepair()

			if BG.sellValue > 0 then
				BG.CallWithDelay(BG.ReportSelling, 0.3, BG.repairCost, 0, numSellItems)
			elseif BG.repairCost > 0 then
				BG.Print(format(BG.locale.repair, BG.FormatMoney(BG.repairCost)))
			end
		end

	elseif event == "MERCHANT_CLOSED" then
		BG.isAtVendor = nil
		-- fallback unlock
		if BG.locked then
			BG.Debug("Fallback Unlock: Merchant window closed, scan lock released.")
			if BG.sellValue > 0 then
				BG.ReportSelling(BG.repairCost, 0, 10)
			else
				BG.locked = nil
				BG.sellValue, BG.repairCost = 0, 0
			end
		end

	elseif event == "LOOT_OPENED" then	-- [TODO] choose proper events
		if BG_GlobalDB.restackInventory then
			-- BG.DoFullRestack()
		end

	elseif event == "ITEM_UNLOCKED" then	-- only registered during restack
		BG.Restack()

	elseif not BG.locked and event == "BAG_UPDATE" then
		if not arg1 or arg1 < 0 or arg1 > 4 then return end

		BG.Debug("Bag Update", arg1, ...)
		BG.ScanInventoryContainer(arg1)	-- partial inventory scan on the relevant container

	elseif event == "AUCTION_HOUSE_CLOSED" then
		-- Update cached auction values in case anything changed
		BG.ClearCache()
		BG.ScanInventory()

	elseif event == "UI_ERROR_MESSAGE" and arg1 and arg1 == ERR_VENDOR_DOESNT_BUY then
		if BG.repairCost > 0 then
			BG.Print(format(BG.locale.repair, BG.FormatMoney(BG.repairCost)))
		end
		BG.sellValue, BG.repairCost = 0, 0

	elseif event == "EQUIPMENT_SETS_CHANGED" then
		BG.RescanEquipmentInBags()
	elseif event == "PLAYER_EQUIPMENT_CHANGED" then
		for i = 1, NUM_BAG_SLOTS do
			if ContainerIDToInventoryID(i) and arg1 == ContainerIDToInventoryID(i) then
				BG.Debug("One of the player's bags changed! "..arg1)
				BG.ScanInventory()
				return
			end
		end
	elseif event == "CHAT_MSG_SKILL" then
		local skillName = string.match(arg1, BG.ReformatGlobalString(ERR_SKILL_GAINED_S))
		if skillName then
			skillName = BG.GetTradeSkill(skillName)
			if skillName then
				BG.ModifyList_ExcludeSkill(skillName)
				BG.Print(BG.locale.listsUpdatedPleaseCheck)
			end
		end
	-- elseif event == "" then
		-- [TODO] items left inventory without bag_update event
		-- [TODO] sometimes lists don't update properly which causes "re-selling" the same items over and over again, inflating statistics
	end
end
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", eventHandler)
BG.frame = frame
