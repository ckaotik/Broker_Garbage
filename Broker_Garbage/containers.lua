local _, ns = ...

-- GLOBALS: BG_GlobalDB, BG_LocalDB, NUM_BAG_SLOTS
-- GLOBALS: GetContainerNumSlots, GetContainerItemID, GetContainerItemInfo
-- GLOBALS: type, string, table, pairs, wipe, print, tonumber
local emptyTable = {}

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
local function GetExpandedLPTString(category)
	local category = LPT:GetSetString(category)
	if category:sub(1,2) == "m," then
		return category:gsub("([^,]+)(,?)", function(subSet)
			if subSet == "m" then
				return ","
			else
				return GetExpandedLPTString(subSet) .. ","
			end
		end)
	else
		return category
	end
end

-- smart, self-caching table <3
local isItemInCategory = setmetatable({}, {
	__index = function(self, category)
		local LPTString = LPT and GetExpandedLPTString(category) or ""
		self[category] = LPTString
		return self[category]
	end,
	__call = function(self, category, item)
		if type(item) ~= "number" then return end
		return (self[category]):find(","..item.."[:,]") and true or false
	end
})

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

local function LocationSort(locationA, locationB)
	local itemA = ns.containers[locationA].c
	local itemB = ns.containers[locationB].c
	if itemA.c ~= itemB.c then
		return itemA.c > itemB.c
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
		table.sort(myLocations, LocationSort)
		self[category] = myLocations
		return self[category]
	end
})

-- may only be called once inventory scan is complete
local function SlotIsOverLimit(limiter, location, limit)
	local slot = ns.containers[location]
	if limit == 0 or not slot or not slot.id then return end
	if slot then
		-- update limiter cache
		ns.item[ slot.id ].l[limiter] = limit
	end

	local locations
	if type(limiter) == "string" then
		-- only needs to be sorted once on creation
		locations = categoryLocations[limiter]
	else
		locations = ns.itemLocations[limiter]
		table.sort(locations, LocationSort) -- TODO: we can do better than sort every time!
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
local changedLocations, changedLimits = {}, {}
local function Scan(container, forced)
	-- updates item/location caches, categories are built on the fly when the need arrives, not here
	local numSlots = GetContainerNumSlots(container)
	local oldData
	for slot = 1, numSlots or 0 do
		local location = tonumber(string.format("%d.%.2d", container, slot) or '')
		local cacheData = ns.containers[location]

		local newItem = GetContainerItemID(container, slot)
		local _, newCount = GetContainerItemInfo(container, slot)

		local itemChanged  = forced or not cacheData.id or newItem ~= cacheData.id
		local countChanged = forced or itemChanged or newCount ~= cacheData.c
		if itemChanged or countChanged then
			local limiters = cacheData.id and ns.item[ cacheData.id ].l
			if #limiters > 0 then
				-- limited items must be fully checked, in more than 1 slot
				for limiter, _ in pairs(limiters) do
					table.insert(changedLimits, limiter)
				end
			else
				-- just this one slot affected
				table.insert(changedLocations, location)
			end

			-- get rid of old prioriy data etc
			wipe(cacheData)
			if itemChanged then
				if cacheData.id then
					-- remove old item from locations
					local itemLocations = ns.locations[ cacheData.id ]
					table.remove(itemLocations, Find(itemLocations, location))
				end
				-- add new item to locations
				table.insert(ns.locations, location)
			end

			-- fill in new data
			cacheData.id = newItem
			cacheData.c = newCount
			cacheData.l = location
		end
	end
end

local function ItemSort(a, b)
	-- TODO: make more sophisticated
	-- priority, value, count, location
	return ns.containers[a][2] > ns.containers[b][2]
end

function ns._ScanInventory(forced)
	wipe(changedLocations)
	wipe(changedLimits)
	for container = 0, NUM_BAG_SLOTS do
		if forced or ns.updateAvailable[container] then
			Scan(container, forced)
		end
	end

	-- TODO: for limited/changed items do ns.GetItemPriority() end
	for _, location in pairs(changedLocations) do
		local cacheData = ns.containers[location]
		if cacheData.l then end
		--      cacheData.p = priority
		--      cacheData.a = action
		--      cacheData.v = value
	end
	for _, limiter in pairs(changedLimits) do
		for _, location in pairs( categoryLocations[limiter] ) do
			-- TODO: update
		end
	end

	-- TODO: this sucks!
	wipe(ns.list)
	for location, data in pairs(ns.containers) do
		table.insert(ns.list, location)
	end
	table.sort(ns.list, ItemSort)

	-- TODO: update display
end

local PRIORITY_NEGATIVE = -1
local PRIORITY_NEUTRAL = 0
local PRIORITY_POSITIVE = 1

local REASON_KEEP_ID = 0
local REASON_TOSS_ID = 1
local REASON_KEEP_CAT = 2
local REASON_TOSS_CAT = 3

-- returns: priority, sell, reason
function ns.GetItemPriority(itemID, location)
	local priority, reason, listed = PRIORITY_NEUTRAL, nil, nil

	listed = ns.keep[itemID]
	if listed then
		local overLimit = listed > 0 and SlotIsOverLimit(itemID, location, listed)
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

	for category, value in pairs(ns.keep) do
		if type(category) == "string" and isItemInCategory(itemID, category) then
			local overLimit = value > 0 and SlotIsOverLimit(category, location, value)
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

	return PRIORITY_NEUTRAL
end
