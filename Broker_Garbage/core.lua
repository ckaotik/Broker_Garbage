local addonName, ns, _ = ...
local BG = ns -- FIXME

-- GLOBALS: BG_GlobalDB, BG_LocalDB, NUM_BAG_SLOTS, ERR_VENDOR_DOESNT_BUY, ERR_SKILL_GAINED_S, INVSLOT_LAST_EQUIPPED
-- GLOBALS: ContainerIDToInventoryID, InCombatLockdown, GetItemInfo
-- GLOBALS: string, table, tonumber, setmetatable
local pairs = pairs
local format = string.format

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
	-- /run for i,v in pairs(BG_GlobalDB.exclude) do BG_GlobalDB.keep[i] = v end
	-- /run for i,v in pairs(BG_LocalDB.exclude) do BG_LocalDB.keep[i] = v end
	-- TODO: convert non-keep limits to keep limits + non-keep entry
	-- TODO: convert sell-list entries to toss w/ value = 1
	-- TODO: when converting, check if categories exist
	-- /run for i,v in pairs(BG_GlobalDB.include) do BG_GlobalDB.toss[i] = v end
	-- /run for i,v in pairs(BG_LocalDB.include) do BG_LocalDB.toss[i] = v end
	BG_GlobalDB.keep = BG_GlobalDB.keep or {}
	BG_GlobalDB.toss = BG_GlobalDB.toss or {}
	BG_LocalDB.keep  = BG_LocalDB.keep  or {}
	BG_LocalDB.toss  = BG_LocalDB.toss  or {}
	ns.keep = Merge(BG_GlobalDB.keep, BG_LocalDB.keep)
	ns.toss = Merge(BG_GlobalDB.toss, BG_LocalDB.toss)

	ns.list = {} 								-- { <location>, <location>, ...} to reference ns.container[<location]
	ns.locations = {} 							-- [<itemID|category>] = { <location>, ... }
	-- contains dynamic data
	ns.containers = setmetatable({}, { 			-- [<location>] = { ns.item[itemID], <count ~= 1> } --]]
		__index = function(self, location)
			self[location] = {
				-- loc = location,
				-- item = ns.item[itemID],
				-- count = count,
				-- priority = priority,
				-- value = value,
				-- label = label,
				-- sell = sell,
			}
			return self[location]
		end
	})
	-- contains static item data (no categories!)
	ns.item = setmetatable({}, {
		__mode = "kv",
		__index = function(self, item)
			-- item info should be available, as we only check items we own
			local _, link, quality, iLevel, _, itemClass, _, _, equipSlot, _, vendorPrice = GetItemInfo(item)
			local itemID = tonumber(link:match('item:(%d+):') or '')
			-- if self[itemID] then return self[itemID] end

			local limiters = {}
			self[itemID] = {
				id = itemID,
				slot = equipSlot,
				limit  = limiters, 		-- will grow with more limits, but who cares ;)
				cl = itemClass,
				l  = iLevel, 			-- TODO: fix upgraded items
				q  = quality,
				v  = vendorPrice,
			}
			return self[itemID]
		end
	})
	-- kay, stop <new!> now

	BG.totalBagSpace = 0
	BG.totalFreeSlots = 0

	BG.CheckSettings()
	BG.InitArkInvFilter()
	BG.InitPriceHandlers()

	-- initial scan
	BG.updateAvailable = {}
	for i = 0, NUM_BAG_SLOTS do
		BG.updateAvailable[i] = true
	end
	self:BAG_UPDATE_DELAYED()

	for _, event in pairs({ "BAG_UPDATE", "BAG_UPDATE_DELAYED", "CHAT_MSG_SKILL", "EQUIPMENT_SETS_CHANGED" }) do
		self:RegisterEvent(event)
	end

	self:UnregisterEvent("ADDON_LOADED")
end

-- --------------------------------------------------------
--  <stuff> update events
-- --------------------------------------------------------
function events:AUCTION_HOUSE_CLOSED()
	-- Update cached auction values in case anything changed
	BG.ScanInventory(true)
end

function events:EQUIPMENT_SETS_CHANGED()
	BG.RescanEquipmentInBags()
end

function events:CHAT_MSG_SKILL(event, msg)
	local skillName = string.match(msg, BG.ReformatGlobalString(ERR_SKILL_GAINED_S))
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
	if InCombatLockdown() then
		-- postpone ...
		self:RegisterEvent("PLAYER_REGEN_ENABLED")
		return
	end

	ns.ScanInventory()
end

function events:PLAYER_REGEN_ENABLED()
	self:UnregisterEvent("PLAYER_REGEN_ENABLED")
	self:BAG_UPDATE_DELAYED()
end
