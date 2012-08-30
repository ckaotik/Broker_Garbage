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
BG.callbacks = LibStub("CallbackHandler-1.0"):New(BG)

-- internal variables
BG.version = tonumber(GetAddOnMetadata(addonName, "X-Version"))
BG.locked = nil						-- is set to true while selling stuff
BG.sellValue = 0					-- represents the actual value that we sold stuff for
BG.repairCost = 0					-- the amount of money that we repaired for

-- Event Handler
-- ---------------------------------------------------------
local frame = CreateFrame("frame")
local changedBag -- for restack triggering
local function eventHandler(self, event, arg1, ...)
	-- == Initialize ==
	if event == "ADDON_LOADED" and arg1 == addonName then
		BG.isAtVendor = nil
		BG.totalBagSpace = 0
		BG.totalFreeSlots = 0
		BG.containerInInventory = nil

		BG.itemsCache = {}		-- contains static item data, e.g. price, stack size
		BG.itemLocations = {}	-- itemID = { cheapestItems-ListIndex }
		BG.cheapestItems = {}	-- contains up-to-date labeled data
		BG.sellLog = {}

		BG.updateAvailable = {}
		for i=1,NUM_BAG_SLOTS do
			BG.updateAvailable[i] = false
		end

		BG.CheckSettings()

		BG.ScanInventory()	-- initializes and fills caches

		local events = {
			"ITEM_PUSH", "BAG_UPDATE", "BAG_UPDATE_DELAYED",
			"MERCHANT_SHOW", "MERCHANT_CLOSED",
			"UI_ERROR_MESSAGE", "CHAT_MSG_SKILL",
			"EQUIPMENT_SETS_CHANGED", "PLAYER_EQUIPMENT_CHANGED"
		}
		for _, event in ipairs(events) do
			frame:RegisterEvent(event)
		end
		frame:UnregisterEvent("ADDON_LOADED")
	elseif event == "GET_ITEM_INFO_RECEIVED" then
		BG.UpdateCache(BG.requestedItemID)
		BG.requestedItemID = nil
		frame:UnregisterEvent("GET_ITEM_INFO_RECEIVED")

	-- == Auto Repair/Auto Sell ==
	elseif event == "MERCHANT_SHOW" then
		BG.isAtVendor = true
		BG.UpdateMerchantButton()

		local disable = BG.disableKey[BG_GlobalDB.disableKey]
		if not (disable and disable()) then
			local numSellItems
			BG.sellValue, numSellItems = BG.AutoSell()
			BG.repairCost, guildRepair = BG.AutoRepair()

			if BG.sellValue > 0 then
				BG.CallWithDelay(BG.ReportSelling, 0.3, BG.repairCost, 0, numSellItems, guildRepair)
			elseif BG.repairCost > 0 then
				BG.Print(format(BG.locale.repair, BG.FormatMoney(BG.repairCost), guildRepair and BG.locale.guildRepair or ""))
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

	elseif not BG.locked and event == "BAG_UPDATE" then
		if not arg1 or arg1 < 0 or arg1 > NUM_BAG_SLOTS then return end

		BG.Debug("Bag Update", arg1, ...)
		BG.updateAvailable[arg1] = true
		-- BG.ScanInventoryContainer(arg1)	-- partial inventory scan on the relevant container

	elseif event == "BAG_UPDATE_DELAYED" then
		-- no locking required, aye?
		for container, needsUpdate in ipairs(BG.updateAvailable) do
			if needsUpdate then
				BG.ScanInventoryContainer(container)
				BG.updateAvailable[container] = false
			end
		end

	elseif event == "AUCTION_HOUSE_CLOSED" then
		-- Update cached auction values in case anything changed
		BG.ClearCache()
		BG.ScanInventory()

	elseif event == "UI_ERROR_MESSAGE" and arg1 and arg1 == ERR_VENDOR_DOESNT_BUY then
		if BG.repairCost > 0 then
			BG.Print(format(BG.locale.repair, BG.FormatMoney(BG.repairCost)))
		end
		BG.sellValue, BG.repairCost = 0, 0

	-- == Equipment/Sets ==
	elseif event == "PLAYER_EQUIPMENT_CHANGED" then
		for i = 1, NUM_BAG_SLOTS do
			if ContainerIDToInventoryID(i) and arg1 == ContainerIDToInventoryID(i) then
				BG.Debug("One of the player's bags changed! "..arg1)
				BG.ScanInventory()
				return
			end
		end
	elseif event == "EQUIPMENT_SETS_CHANGED" then
		BG.RescanEquipmentInBags()

	-- == Default List Updates ==
	elseif event == "CHAT_MSG_SKILL" then
		local skillName = string.match(arg1, BG.ReformatGlobalString(ERR_SKILL_GAINED_S))
		if skillName then
			skillName = BG.GetTradeSkill(skillName)
			if skillName then
				BG.ModifyList_ExcludeSkill(skillName)
				BG.Print(BG.locale.listsUpdatedPleaseCheck)
			end
		end

	-- == Restack ==
	elseif event == "ITEM_UNLOCKED" then
		BG.restackEventCounter = BG.restackEventCounter - 1
		if BG.restackEventCounter < 1 then
			frame:UnregisterEvent('ITEM_UNLOCKED')
			BG.Restack()
		end
	-- [TODO] suspecting ITEM_PUSH to always fire before UNIT_INVENTORY_CHANGED
	elseif event == "ITEM_PUSH" and arg1 then
		if BG_GlobalDB.restackInventory then
			changedBag = arg1 - INVSLOT_LAST_EQUIPPED
			frame:RegisterEvent("UNIT_INVENTORY_CHANGED")
		end
	elseif event == "UNIT_INVENTORY_CHANGED" and arg1 == "player" then
		if BG_GlobalDB.restackInventory then
			BG.DoContainerRestack(changedBag)
			changedBag = nil
			frame:UnregisterEvent("UNIT_INVENTORY_CHANGED")
		end
	end
end
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", eventHandler)
BG.frame = frame
