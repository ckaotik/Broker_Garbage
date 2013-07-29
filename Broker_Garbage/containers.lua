local _, ns = ...

-- GLOBALS: BG_GlobalDB, BG_LocalDB, NUM_BAG_SLOTS
-- GLOBALS: GetContainerNumSlots, GetContainerItemID, GetContainerItemInfo, GetItemInfo, GetNumEquipmentSets, GetEquipmentSetInfo, GetEquipmentSetItemIDs, GetAuctionItemSubClasses, IsEquippedItem, GetContainerItemEquipmentSetInfo
-- GLOBALS: type, string, table, pairs, ipairs, wipe, print, tonumber, select, math

local Unfit = LibStub("Unfit-1.0")
local QUEST = select(10, GetAuctionItemClasses())
local emptyTable = {}

--[[--  TODO --
	* handle specialty bags
	* handle outdated equipment
	* handle thresholds
	* update Config addon
	* fix statistics/assurance when selling items
	* fix upgraded items' itemlevels?
	* display reasons in item/ldb tooltip?
	* update list presets
	* move code to proper files
	* constants clean up
	* local X for frequently used funcs
	* "fix" namespacing (BG. is dumb, use ns.)
	- restack
--]]

-- --------------------------------------------------------
--  Saved Variables (lists)
-- --------------------------------------------------------
-- add item or category to config lists. items may only ever live in local xor global list
-- <list>: "toss" or "keep"
function ns.Add(list, item, value, isGlobal, noUpdate)
	if list == "price" then
		BG_GlobalDB[list][item] = value or -1
	else
		if isGlobal then
			BG_LocalDB[list][item] = nil
			BG_GlobalDB[list][item] = value or 0
		else
			BG_GlobalDB[list][item] = nil
			BG_LocalDB[list][item] = value or 0
		end
		ns[list][item] = value or 0
	end
	if not noUpdate then
		ns.Scan(ns.UpdateItem, ns.locations[item])
	end
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
--  Cache LPT requests
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

local tmpTable = {}
local isItemInCategory = setmetatable({}, {
	__index = function(self, category)
		self[category] = {}
		GetExpandedLPTData(self[category], LPT:GetSetTable(category))
		return self[category]
	end,
	__call = function(self, itemID, category)
		local categoryType, categoryValue = category:match("^(.-)_(.+)")
		if not categoryType then
			-- plain LPT request
			return self[category][itemID]
		elseif categoryType == "BEQ" then
			-- equipment set
			categoryValue = tonumber(categoryValue)
			if categoryValue and categoryValue <= GetNumEquipmentSets() then
				wipe(tmpTable)
				category = GetEquipmentSetInfo(categoryValue, tmpTable)
			end
			return ns.Find(GetEquipmentSetItemIDs(category), itemID)
		elseif categoryType == "AC" then
			-- armor class
			categoryValue = tonumber(categoryValue)
			return ( select(7, GetItemInfo(itemID)) ) == ( select(categoryValue, GetAuctionItemSubClasses(2)) )
		elseif categoryType == "NAME" then
			-- item name filter
			categoryValue = categoryValue:gsub("%*", ".-")
			return ( GetItemInfo(itemID) or "" ):match("^"..categoryValue.."$")
		end
	end
})
ns.isItemInCategory = isItemInCategory

-- --------------------------------------------------------
--  Container Utils
-- --------------------------------------------------------
function ns.LocationSort(locationA, locationB)
	local itemA = ns.containers[locationA]
	local itemB = ns.containers[locationB]
	if itemA.value ~= itemB.value then
		return itemA.value > itemB.value
	elseif itemA.count ~= itemB.count then
		return itemA.count > itemB.count
	else
		return locationA < locationB
	end
end
local categoryLocations = setmetatable({}, {
	__index = function(self, category)
		-- build locations info
		local myLocations = {}
		for itemID, locations in pairs(ns.locations) do
			if isItemInCategory(itemID, category) then
				for _, location in pairs(locations) do
					table.insert(myLocations, location)
				end
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
		locations = ns.locations[limiter]
		table.sort(locations, ns.LocationSort) -- TODO: we can do better than sort every time!
	end

	local index, count = 1, 0
	while count < limit do
		if locations[index] == location or index > #locations then
			return false
		end
		count = count + ns.containers[ locations[index] ].count
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

local PRIORITY_NEGATIVE    = -1
local PRIORITY_NEUTRAL     = 0
local PRIORITY_POSITIVE    = 1
local PRIORITY_IGNORE      = math.huge

local REASON_KEEP_ID       = 0
local REASON_TOSS_ID       = 1
local REASON_KEEP_CAT      = 2
local REASON_TOSS_CAT      = 3
local REASON_QUEST_ITEM    = 4
local REASON_UNUSABLE_ITEM = 5
local REASON_OUTDATED_ITEM = 6
local REASON_GRAY_ITEM     = 7
local REASON_PRICE_ITEM    = 8
local REASON_PRICE_CAT     = 9
local REASON_WORTHLESS     = 10
local REASON_EMPTY_SLOT    = 11
local REASON_HIGHEST_VALUE = 12
local REASON_SOULBOUND     = 13

function ns.Classify(location)
	local cacheData = ns.containers[location]

	local priority, doSell, priorityReason
	if cacheData.value == 0 then
		priority = PRIORITY_IGNORE
		priorityReason = REASON_WORTHLESS
	else
		priority, doSell, priorityReason = ns.GetItemPriority(location)
	end
	cacheData.priority = priority or PRIORITY_NEUTRAL
	cacheData.sell = doSell
	cacheData.reason = priorityReason
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

		if itemChanged then
			if cacheData.item then
				-- remove old item from locations
				local itemLocations = ns.locations[ cacheData.item.id ]
				table.remove(itemLocations, ns.Find(itemLocations, location))
			end
			if newItem then
				-- add new item to locations
				if not ns.locations[ newItem ] then
					ns.locations[ newItem ] = {}
				end
				table.insert(ns.locations[ newItem ], location)
			end
		end

		-- make sure to set all possible fields, otherwise you risk corrupt data
		cacheData.loc = location
		cacheData.item = newItem and ns.item[ newItem ] or nil
		cacheData.count = newCount or 0
		cacheData.sell = nil

		if newItem then
			-- update fields
			local label, actionValue, actionReason = ns.GetItemAction(location)
			cacheData.label = label or ns.IGNORE
			cacheData.value = (actionValue or 0) * (newCount or 0)
			cacheData.priority = PRIORITY_NEUTRAL
		else
			cacheData.label = ns.IGNORE
			cacheData.value = 0
			cacheData.priority = PRIORITY_IGNORE
		end

		return true
	end
end

function ns.Update(forced)
	-- update bag caches
	for container = 0, NUM_BAG_SLOTS do
		if forced or ns.updateAvailable[container] then
			for slot = 1, GetContainerNumSlots(container) or 0 do
				ns.UpdateBagSlot(container, slot, forced)
			end
		end
		ns.updateAvailable[container] = false
	end
end

-- updates all slots associated with item (itemID or category)
function ns.UpdateItem(item)
	for _, location in pairs(ns.locations[item]) do
		local container, slot = ns.GetBagSlot(location)
		-- saves changed items to changedLocations list
		ns.UpdateBagSlot(container, slot, true)
	end
end

function ns.Scan(scanFunc, ...)
	wipe(categoryLocations)
	wipe(changedLocations)
	wipe(changedLimits)

	-- do whatever
	if type(scanFunc) == "function" then
		scanFunc(...)
	else
		ns.Update(scanFunc, ...)
	end

	for _, location in pairs(changedLocations) do
		ns.Classify(location)
	end
	for _, limiter in pairs(changedLimits) do
		for _, location in pairs( categoryLocations[limiter] ) do
			ns.Classify(location)
		end
	end

	wipe(ns.list)
	for location, data in pairs(ns.containers) do
		if data.item and data.priority ~= PRIORITY_IGNORE then
			-- only interested in slots with items
			table.insert(ns.list, location)
		end
	end
	table.sort(ns.list, ns.ItemSort)
	ns.UpdateLDB()
end

-- returns: priority, autoSell, reason
function ns.GetItemPriority(location)
	local priority, reason
	local item = ns.containers[location].item
	if not item then
		return PRIORITY_IGNORE, false, REASON_EMPTY_SLOT
	end

	-- check list config by itemID
	local listed = ns.keep[ item.id ]
	if listed then
		local overLimit = listed > 0 and ns.SlotIsOverLimit(location, item.id, listed)
		if not overLimit then
			priority = PRIORITY_POSITIVE
			reason = REASON_KEEP_ID
			return priority, false, reason
		end
	end

	listed = ns.toss[ item.id ]
	if listed then
		priority = PRIORITY_NEGATIVE
		reason = REASON_TOSS_ID
		return priority, listed == 1, reason
	end

	-- check list config by category
	for category, value in pairs(ns.keep) do
		if type(category) == "string" and isItemInCategory(item.id, category) then
			local overLimit = value > 0 and ns.SlotIsOverLimit(location, category, value)
			if not overLimit then
				priority = PRIORITY_POSITIVE
				reason = REASON_KEEP_CAT
				return priority, false, reason
			end
		end
	end

	for category, value in pairs(ns.toss) do
		if type(category) == "string" and isItemInCategory(item.id, category) then
			priority = PRIORITY_NEGATIVE
			reason = REASON_TOSS_CAT
			return priority, value == 1, reason
		end
	end

	-- quest items
	if item.cl == QUEST then -- FIXME: config
		priority = PRIORITY_POSITIVE
		reason = REASON_QUEST_ITEM
		return priority, false, reason
	end

	-- gray quality items
	if item.q == 0 then
		priority = PRIORITY_NEUTRAL
		reason = REASON_GRAY_ITEM
		return priority, true, reason
	end

	-- unusable gear
	if item.slot ~= "" and ns.IsItemSoulbound(location) and Unfit:IsItemUnusable(item.id) then
		priority = PRIORITY_NEUTRAL -- FIXME: config
		reason = REASON_UNUSABLE_ITEM
		return priority, true, reason
	end

	-- outdated gear
	if ns.containers[ location ].label == ns.VENDOR and ns.IsOutdatedItem(location) then
		return priority, true, REASON_OUTDATED_ITEM
	end

	return PRIORITY_NEUTRAL
end

-- TODO: maybe store to ns.item, but needs update when DE skill changes or auctions scanned
function ns.GetBestPrice(itemID, itemLink)
	local item = ns.item[itemID]
	local itemLink = itemLink or select(2, GetItemInfo(itemID))

	local auctionPrice = ns.GetAuctionValue(itemLink) or -1
	local disenchantPrice = ns.GetDisenchantValue(itemLink) or -1

	local maxPrice = math.max(disenchantPrice, auctionPrice, item.v or 0, 0)
	local action = (maxPrice == 0 and BG_GlobalDB.hideZeroValue and ns.IGNORE) or
	               (maxPrice == disenchantPrice and ns.DISENCHANT) or
	               (maxPrice == item.v and ns.VENDOR) or
	               (maxPrice == auctionPrice and ns.AUCTION) or
	               ns.IGNORE

	return action, maxPrice
end

function ns.GetItemAction(location)
	local item = ns.containers[ location ].item

	-- custom prices for either this item or one of its categories
	local userPrice = BG_GlobalDB.prices[item.id]
	if userPrice then
		local value = userPrice == -1 and item.v or userPrice
		return ns.VENDOR, value, REASON_PRICE_ITEM
	end
	for limiter, limit in pairs(item.limit) do
		userPrice = BG_GlobalDB.prices[limiter]
		if userPrice then
			local value = userPrice == -1 and item.v or userPrice
			return ns.VENDOR, value, REASON_PRICE_CAT
		end
	end

	if item.q == 0 then
		-- FIXME: config, do we really want to ignore grays? Maybe check transmog sets ...
		return ns.VENDOR, item.v, REASON_GRAY_ITEM

	elseif item.v <= 0 then
		return ns.IGNORE, 0, REASON_WORTHLESS

	elseif ns.IsItemSoulbound(location) then
		local _, itemLink = GetItemInfo(item.id)
		local disenchantPrice = ns.GetDisenchantValue(itemLink) or 0

		if disenchantPrice >= item.v then
			return ns.DISENCHANT, disenchantPrice, REASON_OUTDATED_ITEM
		else
			return ns.VENDOR, item.v, REASON_SOULBOUND
		end
	end

	local label, value = ns.GetBestPrice(item.id)
	return label, value, REASON_HIGHEST_VALUE
end