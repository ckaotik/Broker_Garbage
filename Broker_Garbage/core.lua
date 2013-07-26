local addonName, ns, _ = ...
local BG = ns -- FIXME

-- GLOBALS: BG_GlobalDB, BG_LocalDB, NUM_BAG_SLOTS, ERR_VENDOR_DOESNT_BUY, ERR_SKILL_GAINED_S, INVSLOT_LAST_EQUIPPED
-- GLOBALS: ContainerIDToInventoryID, InCombatLockdown
local pairs = pairs
local ipairs = ipairs
local format = string.format
local match = string.match

-- --------------------------------------------------------
--  Libraries & setting up the LDB
-- --------------------------------------------------------
BG.PT = LibStub("LibPeriodicTable-3.1", true)	-- don't scream if LPT isn't present
BG.callbacks = BG.callbacks or LibStub("CallbackHandler-1.0"):New(BG)

-- internal variables
BG.version = tonumber(GetAddOnMetadata(addonName, "X-Version"))

-- --------------------------------------------------------
--  Event Handler
-- --------------------------------------------------------
local events = CreateFrame("frame")
events:RegisterEvent("ADDON_LOADED")
events:SetScript("OnEvent", function(self, event, ...)
   return self[event] and self[event](self, event, ...)
end)
ns.events = events
ns.frame = events -- FIXME

-- --------------------------------------------------------
--  Initialize
-- --------------------------------------------------------
local function Merge(tableA, tableB)
	local useTable = {}
	for k, v in pairs(tableA) do
		useTable[k] = v == true and 0 or v
	end
	for k, v in pairs(tableB) do
		useTable[k] = true and 0 or v
	end
	return useTable
end

function events:ADDON_LOADED(event, addon)
	if addon ~= addonName then return end

	-- beware of <new!> things!
	BG_GlobalDB.keep = BG_GlobalDB.keep or {}
	BG_GlobalDB.toss = BG_GlobalDB.toss or {}
	BG_LocalDB.keep  = BG_LocalDB.keep  or {}
	BG_LocalDB.toss  = BG_LocalDB.toss  or {}
	-- addon assumes lists are { <itemID/category> = <number>, ... } 0: unrestriced, else: restricted
	ns.keep = Merge(BG_GlobalDB.keep, BG_LocalDB.keep)
	ns.toss = Merge(BG_GlobalDB.toss, BG_LocalDB.toss)

	ns.list = {} 								-- { <location>, <location>, ...} to reference ns.container[<location]
	ns.locations = {} 							-- [<itemID|category>] = { <location>, ... }
	-- contains dynamic data
	ns.containers = setmetatable({}, { 			-- [<location>] = { ns.item[itemID], <count ~= 1> } --]]
		__index = function(self, location)
			self[location] = {
				-- id = itemID,
				-- c = count,
				-- p = priority,
				-- a = action,
				-- v = value,
				-- l = location,
			}
			return self[location]
		end
	})
	-- contains static item data (no categories!)
	ns.item = setmetatable({}, {
		__mode = "kv",
		__index = function(self, item)
			-- item info should be available, as we only check items we own
			local _, link, quality, iLevel, _, _, _, _, _, _, vendorPrice = GetItemInfo(item)
			local limiters = {}
			self[item] = {
				id = tonumber(link:match('item:(%d+):') or ''),
				q  = quality,
				v  = vendorPrice,
				il = iLevel,
				l  = limiters,
			}
			return self[item]
		end
	})
	-- kay, stop <new!> now

	BG.isAtVendor = nil
	BG.totalBagSpace = 0
	BG.totalFreeSlots = 0
	BG.containerInInventory = nil

	BG.itemsCache = {}		-- contains static item data, e.g. price, stack size
	BG.locationsCache = {}	-- itemID = { cheapestItems-ListIndex }
	BG.cheapestItems = {}	-- contains up-to-date labeled data

	BG.locked = nil
	BG.sellValue = 0		-- represents the actual value that we sold stuff for
	BG.repairCost = 0		-- the amount of money that we repaired for
	BG.sellLog = {}

	BG.CheckSettings()
	BG.InitArkInvFilter()
	BG.InitPriceHandlers()

	BG.updateAvailable = {}
	for i = 0, NUM_BAG_SLOTS do
		BG.updateAvailable[i] = true
	end

	if not ns.DelayInCombat(ns.ScanInventory) then
		ns.ScanInventory()
	end

	for _, event in pairs({ "ITEM_PUSH", "BAG_UPDATE", "BAG_UPDATE_DELAYED", "MERCHANT_SHOW", "MERCHANT_CLOSED", "UI_ERROR_MESSAGE", "CHAT_MSG_SKILL", "EQUIPMENT_SETS_CHANGED", "PLAYER_EQUIPMENT_CHANGED" }) do
		self:RegisterEvent(event)
	end
	self:UnregisterEvent("ADDON_LOADED")
end

-- --------------------------------------------------------
--  Merchant: auto sell, auto repair
-- --------------------------------------------------------
function events:MERCHANT_SHOW(event)
	BG.isAtVendor = true
	BG.UpdateMerchantButton()

	local disable = BG.disableKey[BG_GlobalDB.disableKey]
	if not (disable and disable()) then
		local numSellItems, guildRepair
		BG.sellValue, numSellItems = BG.AutoSell()
		BG.repairCost, guildRepair = BG.AutoRepair()

		if BG.sellValue > 0 then
			BG.CallWithDelay(BG.ReportSelling, 0.3, BG.repairCost, 0, numSellItems, guildRepair)
		elseif BG.repairCost > 0 then
			BG.Print(format(BG.locale.repair, BG.FormatMoney(BG.repairCost), guildRepair and BG.locale.guildRepair or ""))
		end
	end
end

function events:MERCHANT_CLOSED(event)
	BG.isAtVendor = nil
	if BG.locked then
		BG.Debug("Fallback unlock: Merchant window closed, scan lock released.")
		if BG.sellValue > 0 then
			BG.ReportSelling(BG.repairCost, 0, 10)
		else
			BG.sellValue, BG.repairCost = 0, 0
			BG.locked = nil
		end
	end
end

function events:UI_ERROR_MESSAGE(event, msg)
	if msg ~= ERR_VENDOR_DOESNT_BUY then return end
	if BG.repairCost > 0 then
		BG.Print(format(BG.locale.repair, BG.FormatMoney(BG.repairCost)))
	end
	BG.sellValue, BG.repairCost = 0, 0
end

-- --------------------------------------------------------
--  <stuff> update events
-- --------------------------------------------------------
function events:AUCTION_HOUSE_CLOSED()
	-- Update cached auction values in case anything changed
	BG.ClearCache()
	BG.ScanInventory()
end

function events:PLAYER_EQUIPMENT_CHANGED(event, containerID)
	for i = 1, NUM_BAG_SLOTS do
		local location = ContainerIDToInventoryID(i)
		if location and location == containerID then
			-- TODO: remove itemslots we had before. rare situation, but possible (e.g. alt sending huge bag to main)
			BG.Debug("One of the player's bags changed! "..containerID)
			BG.ScanInventory()
			return
		end
	end
end

function events:EQUIPMENT_SETS_CHANGED()
	BG.RescanEquipmentInBags()
end

function events:CHAT_MSG_SKILL(event, msg)
	local skillName = match(msg, BG.ReformatGlobalString(ERR_SKILL_GAINED_S))
	if skillName then
		skillName = BG.GetTradeSkill(skillName)
		if skillName then
			BG.ModifyList_ExcludeSkill(skillName)
			BG.Print(BG.locale.listsUpdatedPleaseCheck)
		end
	end
end

function events:GET_ITEM_INFO_RECEIVED()
	BG.UpdateCache(BG.requestedItemID)
	BG.requestedItemID = nil
	self:UnregisterEvent("GET_ITEM_INFO_RECEIVED")
end

-- --------------------------------------------------------
--  Bag scanning
-- --------------------------------------------------------
function events:BAG_UPDATE(event, bagID)
	if ns.locked then return end
	if bagID < 0 or bagID > NUM_BAG_SLOTS then
		return
	end
	BG.updateAvailable[bagID] = true
end

function events:BAG_UPDATE_DELAYED()
	if ns.locked then return end

	-- new! just testing for now
	if not ns.DelayInCombat(ns._ScanInventory) then
		ns._ScanInventory()
	end

	-- inventory scanning while in combat causes issues, postpone
	if InCombatLockdown() then
		self:RegisterEvent("PLAYER_REGEN_ENABLED")
		return
	end

	for container, needsUpdate in pairs(BG.updateAvailable) do
		if needsUpdate then
			BG.ScanInventoryContainer(container)
			BG.updateAvailable[container] = false
		end
	end
	BG.ScanInventoryLimits()
	BG.SortItemList()
end

function events:PLAYER_REGEN_ENABLED()
	-- ns.RunAfterCombat()
	self:UnregisterEvent("PLAYER_REGEN_ENABLED")
	self:BAG_UPDATE_DELAYED()
end

-- --------------------------------------------------------
--  Restacking
-- --------------------------------------------------------
function events:ITEM_UNLOCKED()
	BG.restackEventCounter = BG.restackEventCounter - 1
	if BG.restackEventCounter < 1 then
		self:UnregisterEvent('ITEM_UNLOCKED')
		BG.Restack()
	end
end

function events:ITEM_PUSH(event, containerID)
	local container = containerID - INVSLOT_LAST_EQUIPPED
	if BG_GlobalDB.restackInventory and container >= 0 then
		BG.DoContainerRestack(container)
	end
end

-- --------------------------------------------------------
--  FIXME: Some things shouldn't happen in combat!
--  Usage: function myFunc(foo, bar) if ns.DelayInCombat(frame, myFunc) then return end --[[do stuff--]] end
-- --------------------------------------------------------
local afterCombat = {}
function ns.RunAfterCombat()
	for i = #afterCombat, 1, -1 do
		afterCombat[i]()
		afterCombat[i] = nil
	end
end
function ns.DelayInCombat(func)
	if InCombatLockdown() then
		tinsert(afterCombat, func)
		events:RegisterEvent("PLAYER_REGEN_ENABLED")
		return true
	end
end
