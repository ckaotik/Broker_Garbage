local addonName, ns, _ = ...

-- GLOBALS: BG_GlobalDB, BG_LocalDB, NUM_BAG_SLOTS, ERR_VENDOR_DOESNT_BUY, ERR_SKILL_GAINED_S, INVSLOT_LAST_EQUIPPED
-- GLOBALS: ContainerIDToInventoryID, InCombatLockdown, GetItemInfo
-- GLOBALS: string, table, tonumber, setmetatable, math, pairs, ipairs

-- --------------------------------------------------------
--  Event Handler
-- --------------------------------------------------------
local events = CreateFrame("Frame")
events:RegisterEvent("ADDON_LOADED")
events:SetScript("OnEvent", function(self, event, ...)
   return self[event] and self[event](self, event, ...)
end)
ns.events = events

-- --------------------------------------------------------
--  Initialize
-- --------------------------------------------------------
local function Merge(tableA, tableB)
	local useTable = {}
	for k, v in pairs(tableA) do
		useTable[k] = math.max(v, useTable[k] or 0)
	end
	for k, v in pairs(tableB) do
		useTable[k] = math.max(v, useTable[k] or 0)
	end
	return useTable
end

function events:ADDON_LOADED(event, addon)
	if addon ~= addonName then return end
	ns.CheckSettings()

	ns.prices = BG_GlobalDB.prices
	ns.keep   = Merge(BG_GlobalDB.keep, BG_LocalDB.keep)
	ns.toss   = Merge(BG_GlobalDB.toss, BG_LocalDB.toss)

	ns.list = {} 								-- { <location>, <location>, ...} to reference ns.container[<location>]
	ns.locations = {} 							-- [<itemID|category>] = { <location>, ... }

	-- contains dynamic data
	ns.containers = setmetatable({}, {
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
			local itemID = link and tonumber(link:match('item:(%d+):') or '')

			if not itemID then
				return {}
			elseif itemID ~= item then
				return self[itemID]
			end

			self[itemID] = {
				id     = itemID,
				slot   = equipSlot,
				limit  = {}, 				-- list of categories that contain this item
				cl     = itemClass,
				l      = iLevel,
				q      = quality,
				v      = vendorPrice,
				bop    = ns.IsItemBoP(itemID),
			}
			return self[itemID]
		end
	})

	ns.totalBagSpace = 0
	ns.totalFreeSlots = 0

	ns.InitArkInvFilter()
	ns.InitPriceHandlers()

	-- initial scan
	ns.updateAvailable = {}
	for i = 0, NUM_BAG_SLOTS do
		ns.updateAvailable[i] = true
	end
	self:BAG_UPDATE_DELAYED()

	self:RegisterEvent("BAG_UPDATE")
	self:RegisterEvent("BAG_UPDATE_DELAYED")
	self:RegisterEvent("CHAT_MSG_SKILL")
	self:RegisterEvent("EQUIPMENT_SETS_CHANGED")
	-- hooksecurefunc("SaveEquipmentSet", self.EQUIPMENT_SETS_CHANGED)

	self:UnregisterEvent("ADDON_LOADED")
end

-- --------------------------------------------------------
--  <stuff> update events
-- --------------------------------------------------------
local function UpdateEquipment()
	for location, cacheData in pairs(ns.containers) do
		if cacheData.item then
			local invSlot = cacheData.item.slot
			if invSlot ~= "" and invSlot ~= "INVTYPE_BAG" then
				local container, slot = ns.GetBagSlot(location)
				ns.UpdateBagSlot(container, slot, true)
			end
		end
	end
end
function events:EQUIPMENT_SETS_CHANGED()
	ns.Print("Rescan equipment in bags")
	ns.Scan(UpdateEquipment)
end

function events:CHAT_MSG_SKILL(event, msg)
	-- TODO: detect newly learned skills
	--[[local skillName = string.match(msg, ns.GetPatternFromFormat(ERR_SKILL_GAINED_S))
	if skillName then
		skillName = ns.GetTradeSkill(skillName)
		if skillName then
			ns.ModifyList_ExcludeSkill(skillName)
			ns.Print(ns.locale.listsUpdatedPleaseCheck)
		end
	end --]]
end

-- --------------------------------------------------------
--  Bag scanning
-- --------------------------------------------------------
function events:BAG_UPDATE(event, bagID)
	if ns.locked then return end
	if bagID < 0 or bagID > NUM_BAG_SLOTS then
		return
	end
	ns.updateAvailable[bagID] = true
end

function events:BAG_UPDATE_DELAYED()
	if ns.locked then return end
	if InCombatLockdown() then
		-- postpone
		self:RegisterEvent("PLAYER_REGEN_ENABLED")
		return
	end

	ns.Scan()
end

function events:PLAYER_REGEN_ENABLED()
	self:UnregisterEvent("PLAYER_REGEN_ENABLED")
	self:BAG_UPDATE_DELAYED()
end
