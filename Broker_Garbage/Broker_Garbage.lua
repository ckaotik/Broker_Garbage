local addonName, addon, _ = ...
addon = LibStub('AceAddon-3.0'):NewAddon(addon, addonName, 'AceEvent-3.0')
_G[addonName] = addon

-- GLOBALS: LibStub, NUM_BAG_SLOTS, ERR_VENDOR_DOESNT_BUY, ERR_SKILL_GAINED_S, INVSLOT_LAST_EQUIPPED
-- GLOBALS: ContainerIDToInventoryID, InCombatLockdown, GetItemInfo
-- GLOBALS: string, table, tonumber, setmetatable, math, pairs, ipairs

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

function addon:OnEnable()
	self.db = LibStub('AceDB-3.0'):New(addonName..'DB', self.defaults, true)
	self:PortSettings()

	self.prices = self.db.global.prices
	self.keep   = self.db.profile.keep
	self.toss   = self.db.profile.toss

	self.list = {} 		-- { <location>, <location>, ...} to reference self.container[<location>]
	self.locations = {} -- [<itemID|category>] = { <location>, ... }

	-- contains dynamic data
	self.containers = setmetatable({}, {
		__index = function(containerTable, location)
			containerTable[location] = {
				-- loc = location,
				-- item = self.item[itemID],
				-- count = count,
				-- priority = priority,
				-- value = value,
				-- label = label,
				-- sell = sell,
			}
			return containerTable[location]
		end
	})

	-- contains static item data (no categories!)
	self.item = setmetatable({}, {
		__mode = "kv",
		__index = function(itemTable, item)
			-- item info should be available, as we only check items we own
			local _, link, quality, iLevel, _, itemClass, _, _, equipSlot, _, vendorPrice = GetItemInfo(item)
			local itemID = link and tonumber(link:match('item:(%d+):') or '')

			if not itemID then
				return {}
			elseif itemID ~= item then
				return itemTable[itemID]
			end

			itemTable[itemID] = {
				id     = itemID,
				slot   = equipSlot,
				limit  = {}, 				-- list of categories that contain this item
				cl     = itemClass,
				l      = iLevel,
				q      = quality,
				v      = vendorPrice,
				bop    = self.IsItemBoP(itemID),
			}
			return itemTable[itemID]
		end
	})

	self.totalBagSpace = 0
	self.totalFreeSlots = 0

	self.InitArkInvFilter()
	self.InitPriceHandlers()

	-- initial scan
	self.updateAvailable = {}
	for i = 0, NUM_BAG_SLOTS do
		self.updateAvailable[i] = true
	end
	self:BAG_UPDATE_DELAYED()

	self:RegisterEvent('BAG_UPDATE')
	self:RegisterEvent('BAG_UPDATE_DELAYED')
	self:RegisterEvent('CHAT_MSG_SKILL')
	self:RegisterEvent('EQUIPMENT_SETS_CHANGED')
	-- hooksecurefunc('SaveEquipmentSet', self.EQUIPMENT_SETS_CHANGED)
end

-- --------------------------------------------------------
--  <stuff> update events
-- --------------------------------------------------------
local function UpdateEquipment()
	for location, cacheData in pairs(addon.containers) do
		if cacheData.item then
			local invSlot = cacheData.item.slot
			if invSlot ~= "" and invSlot ~= "INVTYPE_BAG" then
				local container, slot = addon.GetBagSlot(location)
				addon.UpdateBagSlot(container, slot, true)
			end
		end
	end
end
function addon:EQUIPMENT_SETS_CHANGED()
	self.Print("Rescan equipment in bags")
	self.Scan(UpdateEquipment)
end

function addon:CHAT_MSG_SKILL(event, msg)
	-- TODO: detect newly learned trade skills and create list entries accordingly
	--[[local skillName = string.match(msg, self.GetPatternFromFormat(ERR_SKILL_GAINED_S))
	if skillName then
		skillName = self.GetTradeSkill(skillName)
		if skillName then
			self.ModifyList_ExcludeSkill(skillName)
			self.Print(self.locale.listsUpdatedPleaseCheck)
		end
	end --]]
end

-- --------------------------------------------------------
--  Bag scanning
-- --------------------------------------------------------
function addon:BAG_UPDATE(event, container)
	if container >= 0 and container <= NUM_BAG_SLOTS then
		-- TODO: reagent bank, bank etc
		self.updateAvailable[container] = true
	end
end

function addon:BAG_UPDATE_DELAYED()
	if InCombatLockdown() then
		self:RegisterEvent("PLAYER_REGEN_ENABLED")
		return
	end
	self.Scan()
end

function addon:PLAYER_REGEN_ENABLED()
	self:UnregisterEvent("PLAYER_REGEN_ENABLED")
	self:BAG_UPDATE_DELAYED()
end


--[[
-- forceClear = false, -- use Blizzard's autoloot + inventory pruning instead
-- TODO: this is something Broker_Garbage itself needs to do
function plugin:ITEM_PUSH(event, arg1, ...)
	if BGLM_LocalDB.autoDestroy and BGLM_LocalDB.autoDestroyInstant then
		-- TODO
		print('This should now delete items in your inventory. But it doesn\'t. Yet.')
		if true then return end
		local numOverflowSlots = BGLM_GlobalDB.tooFewSlots - Broker_Garbage.totalFreeSlots
		if numOverflowSlots > 0 then
			for i = 1, numOverflowSlots do
				local success = self:DeleteCheapestItem(i)
				if not success then break end
			end
		end
	end
end

function plugin:DeleteCheapestItem(index)
	local item = Broker_Garbage.cheapestItems and Broker_Garbage.cheapestItems[index or 1]
	if item and not item.invalid and item.source ~= Broker_Garbage.IGNORE then
		Broker_Garbage.Delete(item)
		return true
	else
		self:Print(self.locale.LMAutoDestroy_ErrorNoItems)
		return nil
	end
end --]]
