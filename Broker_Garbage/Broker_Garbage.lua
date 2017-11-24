local addonName, addon, _ = ...
addon = LibStub('AceAddon-3.0'):NewAddon(addon, addonName, 'AceEvent-3.0')
_G[addonName] = addon

-- GLOBALS: _G, LibStub, NUM_BAG_SLOTS, ERR_VENDOR_DOESNT_BUY, ERR_SKILL_GAINED_S, INVSLOT_LAST_EQUIPPED
-- GLOBALS: GetItemInfoInstant, GetContainerNumSlots, ContainerIDToInventoryID, InCombatLockdown, GetItemInfo
-- GLOBALS: string, table, tonumber, setmetatable, math, pairs, ipairs, rawget
local requiresFullScan = false

-- --------------------------------------------------------
--  Addon Setup
-- --------------------------------------------------------
local defaults = {
	global = {
		version = 1,
		dropQuality = 0,
		disableKey = "SHIFT",
		showJunkSellIcons = false,

		disenchantValues = true,
		disenchantSkillOffset = 0,
		disenchantSuggestions = false,

		-- behavior
		keepHighestItemLevel = true,
		keepQuestItems = true,
		sellJunk = false, -- was: autoSellIncludeItems
		sellUnusableQuality = 3,
		sellOutdatedQuality = 3,

		LPTJunkIsJunk   = false,
		ignoreZeroValue = true,
		moneyFormat     = 'icon',

		-- LibDataBroker Display
		label = "[itemname]x[itemcount] ([itemvalue])",
		noJunkLabel = addon.locale.label,
		tooltip = {
			height = 220,
			numLines = 9,
			showIcon = true,
			showMoneyLost = true,
			showMoneyEarned = true,
			showReason = true,
			showUnopenedContainers = true, -- FIXME: deprecated
		},
		itemTooltip = {
			showClassification = true,
			showReason = false,
		},

		dataSources = {
			buyout = {},
			buyoutDisabled = {},
			disenchant = {},
			disenchantDisabled = {},
		},
		prices = {},
	},
	profile = {
		keep = {},
		toss = {},
	},
	char = {
		moneyLost   = 0,
		moneyEarned = 0,
		numSold     = 0,
		numDeleted  = 0,
	},
}

function addon:OnInitialize()
	self.list = {} 		-- { <location>, <location>, ...} to reference self.container[<location>]
	self.locations = {} -- [<itemID -or- category>] = { <location>, ... }
	self.EXTERNAL_ITEM_LOCATION = 0
	self.externalItem = {
		loc = self.EXTERNAL_ITEM_LOCATION,
	}

	-- contains dynamic data
	self.containers = setmetatable({}, {
		__index = function(containerTable, location)
			if not location then return end
			if location == self.EXTERNAL_ITEM_LOCATION then return self.externalItem end
			-- TODO: do not create empty tables when slot is empty
			containerTable[location] = {
				loc = location,
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
			local itemID, _, _, equipSlot, _, itemClassID = GetItemInfoInstant(item)
			if not itemID then
				return {}
			elseif itemID ~= item then
				return itemTable[itemID]
			end

			itemTable[itemID] = {
				id     = itemID,
				slot   = equipSlot,
				limit  = {}, 				-- list of categories that contain this item
				bop    = self.IsItemBoP(itemID),
			}
			return itemTable[itemID]
		end
	})

	self.totalBagSpace = 0
	self.totalFreeSlots = 0
end

function addon:OnEnable()
	self.db = LibStub('AceDB-3.0'):New(addonName..'DB', defaults, true)
	self:PortSettings()

	self.prices = self.db.global.prices
	self.keep   = self.db.profile.keep
	self.toss   = self.db.profile.toss

	self.InitPriceHandlers()
	self:Update()

	self:RegisterEvent('BAG_UPDATE')
	self:RegisterEvent('BAG_UPDATE_DELAYED')
	self:RegisterEvent('ITEM_PUSH')
	self:RegisterEvent('GET_ITEM_INFO_RECEIVED')
	-- TODO This gets triggered for new items by TopFit
	self:RegisterEvent('EQUIPMENT_SETS_CHANGED', 'Update')
end

-- --------------------------------------------------------
--  <stuff> update events
-- --------------------------------------------------------
function addon:BAG_UPDATE(event, container)
	self:UpdateContainer(container)
end

function addon:BAG_UPDATE_DELAYED(event, ...)
	if true or requiresFullScan then
		requiresFullScan = false
		self:Scan()
	end
	self:UpdateLDB()
end

-- TODO This is a very instable approach, can we find a better solution to
-- properly mark newly received refundable items?
function addon:ITEM_PUSH(event, containerID, icon)
	local container = containerID - _G.INVSLOT_LAST_EQUIPPED
	-- Refund information is delayed, so we need to check again later.
	C_Timer.After(0.5, function()
		local requiresUpdate = false
		for slot = 1, GetContainerNumSlots(container) do
			local money, items, timeLeft, currencies, hasEnchants = GetContainerItemPurchaseInfo(container, slot)
			if C_NewItems.IsNewItem(container, slot) and timeLeft then
				local hasChanged, isLimitedItem = addon:UpdateBagSlot(container, slot, true)
				requiresUpdate = requiresUpdate or hasChanged
			end
		end

		if requiresUpdate then
			-- At least one refundable was found in the container.
			addon:Scan()
			addon:UpdateLDB()
		end
	end)
end

function addon:GET_ITEM_INFO_RECEIVED(event, itemID)
	if not rawget(self.item, itemID) or #self.locations[itemID] == 0 then return end
	self.item[itemID].bop = self.IsItemBoP(itemID)
	self:UpdateItem(itemID)

	-- update limits and display
	self:Scan()
	self:UpdateLDB()
end

-- --------------------------------------------------------
--  Bag scanning
-- --------------------------------------------------------
-- TODO: split scan into "static" (BAG_UPDATE for itemID/category) and "dynamic" (BAG_UPDATE_DELAYED for limits)
function addon:UpdateContainer(container, force)
	-- TODO: reagent bank, bank etc
	if not container or container < 0 or container > _G.NUM_BAG_SLOTS then return end
	local hasItemLimit = false
	for slot = 1, GetContainerNumSlots(container) do
		local hasChanged, isLimitedItem = self:UpdateBagSlot(container, slot, force)
		hasItemLimit = hasItemLimit or isLimitedItem
	end

	requiresFullScan = requiresFullScan or hasItemLimit
	-- self.updateAvailable[container] = hasItemLimit -- TODO: deprecated

	return hasItemLimit
end

-- perform a full update, rescanning everything
function addon:Update()
	-- scan containers
	for container = 1, _G.NUM_BAG_SLOTS do
		self:UpdateContainer(container, true)
	end

	-- update dynamic limits and display
	self:Scan()
	self:UpdateLDB()
end

function addon:UpdateItem(item)
	local itemID = GetItemInfoInstant(item) or item
	local locations = self.locations[itemID]
	if not locations then return end

	-- scan affected item locations
	for _, location in pairs(locations) do
		local container, slot = self.GetBagSlot(location)
		self:UpdateBagSlot(container, slot, true)
	end
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
