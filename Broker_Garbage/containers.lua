local _, ns = ...

-- GLOBALS: BG_GlobalDB, BG_LocalDB, NUM_BAG_SLOTS, SlashCmdList
-- GLOBALS: GetContainerNumSlots, GetContainerItemID, GetContainerItemInfo
-- GLOBALS: type, string, table, pairs, ipairs, wipe, print, tonumber
local emptyTable = {}

--[[--  TODO --
	* fix item deletion!!!!
	* handle specialty bags
	* handle outdated equipment
	* fix statistics/assurance when selling items
	* check thresholds
	* display reasons in item/ldb tooltip?
	* convert user settings, incl. default lists
	* lootable items, clams?
	* update Config addon
	* local X for frequently used funcs
	* fix updated items itemlevels?
	* restack?
	* move code to proper files
	* update profession scanning + check if preset categories even exist
	* constants clean up
	* "fix" namespacing (BG. is dumb, use ns.)
--]]

-- --------------------------------------------------------
--  Saved Variables (lists)
-- --------------------------------------------------------
-- add item or category to config lists. items may only ever live in local xor global list
-- <list>: "toss" or "keep"
function ns.Add(list, item, limit, isGlobal)
	if isGlobal then
		BG_LocalDB[list][item] = nil
		BG_GlobalDB[list][item] = limit or 0
	else
		BG_GlobalDB[list][item] = nil
		BG_LocalDB[list][item] = limit or 0
	end
	ns[list][item] = limit or 0
end
function ns.Remove(list, item)
	BG_LocalDB[list][item] = nil
	BG_GlobalDB[list][item] = nil
	ns[list][item] = nil
end
function ns.Get(list, item)
	return BG_LocalDB[list][item] or BG_GlobalDB[list][item]
end
function ns.IsShared(list, item)
	return BG_GlobalDB[list][item] ~= nil
end
function ns.ToggleShared(list, item)
	local isGlobal = ns.IsShared(list, item)
	local value = ns.Get(list, item)
	ns.Remove(list, item)
	ns.Add(list, item, value, not isGlobal)
end

-- --------------------------------------------------------
--  Cache LPT requests /spew Broker_Garbage.ITEMCAT("Consumable.Bandage", 72986)
-- --------------------------------------------------------
local LPT = LibStub("LibPeriodicTable-3.1", true)
local function GetExpandedLPTData(destination, source)
	for k, v in pairs(source or emptyTable) do
		if type(v) == "table" then
			-- subset table
			GetExpandedLPTData(destination, v)
		elseif type(k) == "number" then
			-- single item
			destination[k] = tonumber(v) or v
		end
	end
end

-- smart, self-caching table <3
local isItemInCategory = setmetatable({}, {
	__index = function(self, category)
		self[category] = {}
		GetExpandedLPTData(self[category], LPT:GetSetTable(category))
		return self[category]
	end,
	__call = function(self, itemID, category)
		return self[category][itemID]
	end
})
ns.isItemInCategory = isItemInCategory

-- --------------------------------------------------------
--  Container Utils
-- --------------------------------------------------------
local function Find(where, what)
	for k, v in pairs(where) do
		if v == what then
			return k
		end
	end
end

function ns.LocationSort(locationA, locationB)
	local itemA = ns.containers[locationA]
	local itemB = ns.containers[locationB]
	if itemA.count ~= itemB.count then
		return itemA.count > itemB.count
	else
		return itemA.l < itemB.l
	end
end
local categoryLocations = setmetatable({}, {
	__index = function(self, category)
		-- build locations info
		local myLocations = {}
		for itemID, locations in pairs(ns.locations) do
			for _, location in pairs(locations) do
				table.insert(myLocations, location)
			end
		end
		table.sort(myLocations, ns.LocationSort)
		self[category] = myLocations
		return self[category]
	end
})

-- may only be called once inventory scan is complete
function ns.SlotIsOverLimit(location, limiter, limit)
	if not location or not limit or limit == 0 then return end
	local cacheData = ns.containers[location]
	if not cacheData.item then
		return
	end

	-- update limiter cache
	cacheData.item.limit[limiter] = limit

	local locations
	if type(limiter) == "string" then
		-- only needs to be sorted once on creation
		locations = categoryLocations[limiter]
	else
		locations = ns.itemLocations[limiter]
		table.sort(locations, ns.LocationSort) -- TODO: we can do better than sort every time!
	end

	local index, count = 1, 0
	while count < limit do
		if locations[index] == location or index > #locations then
			return false
		end
		count = count + ns.containers[ locations[index] ][2]
		index = index + 1
	end
	return true
end

-- --------------------------------------------------------
--  Namespaced functions
-- --------------------------------------------------------
function ns.GetBagSlot(location)
	local container = math.floor(location)
	local slot = math.floor((location - container) * 100 + 0.5)
	return container, slot
end
function ns.GetLocation(container, slot)
	return tonumber(string.format("%d.%.2d", container, slot) or '')
end

local PRIORITY_NEGATIVE = -1
local PRIORITY_NEUTRAL = 0
local PRIORITY_POSITIVE = 1
local PRIORITY_IGNORE = 2

local REASON_KEEP_ID = 0
local REASON_TOSS_ID = 1
local REASON_KEEP_CAT = 2
local REASON_TOSS_CAT = 3
local REASON_QUEST_ITEM = 4
local REASON_UNUSABLE_ITEM = 5
local REASON_OUTDATED_ITEM = 6
local REASON_GRAY_ITEM = 7
local REASON_CUSTOM_PRICE = 8

function ns.Classify(location)
	local cacheData = ns.containers[location]
	local itemID = cacheData.item and cacheData.item.id

	if itemID then
		local priority, doSell, priorityReason = ns.GetItemPriority(itemID, location)
		local label, actionValue, actionReason = ns.GetItemAction(itemID, location)

		if not actionValue or (actionValue == 0 and BG_GlobalDB.hideZeroValue) then
			priority = PRIORITY_IGNORE
		end

		-- TODO: do something with reasons?
		cacheData.priority = priority or PRIORITY_IGNORE
		cacheData.label = label or ns.IGNORE
		cacheData.value = (actionValue * cacheData.count) or math.huge
		cacheData.sell = doSell
	else
		cacheData.priority = PRIORITY_IGNORE
		cacheData.label = ns.IGNORE
		cacheData.value = nil
		cacheData.sell = nil
	end
end

function ns.ItemSort(locationA, locationB)
	local itemA = ns.containers[locationA]
	local itemB = ns.containers[locationB]

	-- order by priority, value, count, location
	if itemA.priority ~= itemB.priority then
		return itemA.priority < itemB.priority
	elseif itemA.value ~= itemB.value then
		return itemA.value < itemB.value
	elseif itemA.count ~= itemB.count then
		return itemA.count < itemB.count
	else
		return itemA.loc > itemB.loc
	end
end

local changedLocations, changedLimits = {}, {}
-- returns true if something changed, nil otherwise
function ns.UpdateBagSlot(container, slot, forced)
	local location = ns.GetLocation(container, slot)
	local cacheData = ns.containers[location]
	local container, slot = ns.GetBagSlot(location)

	local newItem = GetContainerItemID(container, slot)
	local _, newCount = GetContainerItemInfo(container, slot)

	local itemChanged  = forced or not cacheData.item or newItem ~= cacheData.item.id
	local countChanged = forced or itemChanged or newCount ~= cacheData.count
	if itemChanged or countChanged then
		local limiters = cacheData.item and cacheData.item.limit
		if limiters and #limiters > 0 then
			-- limited items must be fully checked, in more than 1 slot
			for limiter, _ in pairs(limiters) do
				table.insert(changedLimits, limiter)
			end
		else
			-- just this one slot affected
			table.insert(changedLocations, location)
		end

		-- get rid of old priority data etc
		wipe(cacheData)
		if itemChanged then
			if cacheData.item then
				-- remove old item from locations
				local itemLocations = ns.locations[ cacheData.item.id ]
				table.remove(itemLocations, Find(itemLocations, location))
			end
			-- add new item to locations
			table.insert(ns.locations, location)
		end

		-- fill in new data
		cacheData.item = newItem and ns.item[ newItem ] or nil
		cacheData.count = newCount
		cacheData.loc = location

		return true
	end
end

function ns.Scan(container, forced)
	-- updates item/location caches, categories are built on the fly when the need arrives, not here
	for slot = 1, GetContainerNumSlots(container) or 0 do
		ns.UpdateBagSlot(container, slot, forced)
	end
end

function ns.ScanInventory(forced)
	wipe(changedLocations)
	wipe(changedLimits)
	-- update bag caches
	for container = 0, NUM_BAG_SLOTS do
		if forced or ns.updateAvailable[container] then
			ns.Scan(container, forced)
			ns.updateAvailable[container] = false
		end
	end

	-- update all items that were affected
	for _, location in pairs(changedLocations) do
		ns.Classify(location)
	end
	for _, limiter in pairs(changedLimits) do
		for _, location in pairs( categoryLocations[limiter] ) do
			ns.Classify(location)
		end
	end

	-- TODO: this sucks!
	wipe(ns.list)
	for location, data in pairs(ns.containers) do
		if data.item and data.p ~= PRIORITY_IGNORE then
			-- only interested in slots with items
			table.insert(ns.list, location)
		end
	end
	table.sort(ns.list, ns.ItemSort)
	ns:UpdateLDB()
end

local QUEST = select(10, GetAuctionItemClasses())
local Unfit = LibStub("Unfit-1.0")

-- returns: priority, sell, reason
function ns.GetItemPriority(itemID, location)
	local priority, reason
	local item = ns.item[itemID]
	-- local itemID = item.id

	-- quest items
	if item.cl == QUEST then -- FIXME: config
		priority = PRIORITY_POSITIVE
		reason = REASON_QUEST_ITEM
		return priority, false, reason
	end

	-- unusable gear
	if item.slot ~= "" and Unfit:IsItemUnusable(itemID) then -- TODO: and ns.IsItemSoulbound(itemLink) then
		priority = PRIORITY_NEUTRAL -- FIXME: config
		reason = REASON_UNUSABLE_ITEM
		return priority, true, reason
	end

	-- check list config by itemID
	local listed = ns.keep[itemID]
	if listed then
		local overLimit = listed > 0 and ns.SlotIsOverLimit(location, itemID, listed)
		if not overLimit then
			priority = PRIORITY_POSITIVE
			reason = REASON_KEEP_ID
			return priority, false, reason
		end
	end

	listed = ns.toss[itemID]
	if listed then
		priority = PRIORITY_NEGATIVE
		reason = REASON_TOSS_ID
		return priority, listed == 1, reason
	end

	-- check list config by category
	for category, value in pairs(ns.keep) do
		if type(category) == "string" and isItemInCategory(itemID, category) then
			local overLimit = value > 0 and ns.SlotIsOverLimit(location, category, value)
			if not overLimit then
				priority = PRIORITY_POSITIVE
				reason = REASON_KEEP_CAT
				return priority, false, reason
			end
		end
	end

	for category, value in pairs(ns.toss) do
		if type(category) == "string" and isItemInCategory(itemID, category) then
			priority = PRIORITY_NEGATIVE
			reason = REASON_TOSS_CAT
			return priority, value == 1, reason
		end
	end

	if item.q == 0 then
		priority = PRIORITY_NEGATIVE
		reason = REASON_GRAY_ITEM
		return priority, true, reason
	end

	return PRIORITY_NEUTRAL
end

function ns.GetBestPrice(itemID, itemLink)
	local auctionAddon
	local item = ns.item[itemID]

	-- check auction data
	local auctionPrice
	for i, addonKey in ipairs(BG_GlobalDB.auctionAddonOrder.buyout) do
		auctionAddon = ns.auctionAddons[addonKey]
		if auctionAddon and auctionAddon.buyout then
			if auctionAddon.buyoutEnabled and auctionAddon.buyout then
				auctionPrice = auctionAddon.buyout(itemLink)
			end
			if auctionPrice then break end
		end
	end
	auctionPrice = auctionPrice or -2

	local canDisenchant, missingSkillPoints = false, math.huge -- ns.CanDisenchant(itemLink) -- TODO
	canDisenchant = canDisenchant or (missingSkillPoints and missingSkillPoints <= BG_GlobalDB.keepItemsForLaterDE)
	-- check disenchant data
	local disenchantPrice
	for i, addonKey in ipairs(BG_GlobalDB.auctionAddonOrder.disenchant) do
		auctionAddon = ns.auctionAddons[addonKey]
		if auctionAddon and auctionAddon.disenchant then
			if canDisenchant and auctionAddon.disenchantEnabled and auctionAddon.disenchant then
				disenchantPrice = auctionAddon.disenchant(itemLink)
			end
			if disenchantPrice then break end
		end
	end
	disenchantPrice = disenchantPrice or -1

	local maxPrice = math.max(disenchantPrice, auctionPrice, item.v or 0)
	local action = (maxPrice == 0 and BG_GlobalDB.hideZeroValue) and ns.IGNORE or
	               (maxPrice == disenchantPrice and ns.DISENCHANT) or
	               (maxPrice == item.v and ns.VENDOR) or
	               (maxPrice == auctionPrice and ns.AUCTION) or
	               ns.IGNORE

	-- TODO: maybe store to ns.item, but needs update when DE skill changes or auctions scanned
	return action, maxPrice
end

-- returns: action, value
function ns.GetItemAction(itemID, location)
	local item = ns.item[itemID]

	-- FIXME: config, do we really want to ignore grays? Maybe check transmog sets ...
	--if item.q == 0 then -- or (ns.IsItemSoulbound(itemLink) and not IsUsableSpell(ns.enchanting)) then
	--	return ns.VENDOR, item.v, REASON_GRAY_ITEM
	--end

	if BG_GlobalDB.forceVendorPrice[itemID] then
		return ns.VENDOR, BG_GlobalDB.forceVendorPrice[itemID], REASON_CUSTOM_PRICE
	end

	--[[-- TODO: outdated gear + threshold check
	if BG_GlobalDB.sellOldGear and item.q  <= BG_GlobalDB.sellNWQualityTreshold and ns.IsOutdatedItem(itemLink) then
		local saveItem = false

		if BG_GlobalDB.keepHighestItemLevel then
			local invType = select(9, GetItemInfo(itemLink))
			local slots = (TopFit and TopFit.GetEquipLocationsByInvType and TopFit:GetEquipLocationsByInvType(invType))
				or (PawnGetSlotsForItemType and { PawnGetSlotsForItemType(invType) }) or {}

			local keepItems = 1
			if #slots > 1 then
				keepItems = 2
				if slots[1] == 16 and slots[2] == 17 and TopFit.PlayerCanDualWield and not TopFit:PlayerCanDualWield() then
					keepItems = 1
				end
			end

			wipe(itemsForInvType)
			wipe(itemsForSlot)
			for _, slot in ipairs(slots) do
				GetInventoryItemsForSlot(slot, itemsForInvType)
			end
			for _, inventoryItemID in pairs(itemsForInvType) do
				if not BG.Find(itemsForSlot, inventoryItemID) then
					tinsert(itemsForSlot, inventoryItemID)
				end
			end
			sort(itemsForSlot, SortEquipItems)

			for i = 1, keepItems do
				if itemsForSlot[i] and itemsForSlot[i] == itemID then
					saveItem = true
					break
				end
			end
		end

		if saveItem then
			BG.Debug("Item is OUTDATED but saved for its item level", itemID, itemLink)
			classification = BG.EXCLUDE
			reason = "OUTDATED but highest iLvl"
		else
			BG.Debug("Item is OUTDATED", itemID, itemLink)
			classification = BG.OUTDATED
		end
	end --]]

	local _, itemLink = GetItemInfo(item.id) -- TODO
	return ns.GetBestPrice(itemID, itemLink)
end
