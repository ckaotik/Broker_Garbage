local _, ns = ...

-- GLOBALS: NUM_BAG_SLOTS, GetContainerNumSlots, GetContainerItemID, GetContainerItemInfo, GetItemInfo, GetNumEquipmentSets, GetEquipmentSetInfo, GetEquipmentSetItemIDs, GetAuctionItemSubClasses, IsEquippedItem, GetContainerItemEquipmentSetInfo, GetContainerItemLink
-- GLOBALS: type, string, table, pairs, ipairs, wipe, print, tonumber, select, math

local Unfit = LibStub("Unfit-1.0")
local QUEST = select(10, GetAuctionItemClasses())
local EXTERNAL_ITEM = 0
local emptyTable = {}

--[[-- TODO --
	* handle specialty bags
	* update Config addon
	* fix statistics/assurance when selling items
	* display reasons in item/ldb tooltip?
	* update list presets
	* move code to proper files
	* local X for frequently used funcs
	* "fix" namespacing (BG. is dumb, use ns.)
--]]

-- --------------------------------------------------------
--  Container Utils
-- --------------------------------------------------------
local function LocationSort(locationA, locationB)
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
			if ns.isItemInCategory(itemID, category) then
				for _, location in pairs(locations) do
					table.insert(myLocations, location)
				end
			end
		end
		table.sort(myLocations, LocationSort)
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
	-- we expect these tables to be sorted already
	if type(limiter) == "string" then
		locations = categoryLocations[limiter]
	else
		locations = ns.locations[limiter]
	end

	local index, count = 1, 0
	while count < limit do
		if index > #locations or locations[index] == location then
			return false
		end
		count = count + ns.containers[ locations[index] ].count
		index = index + 1
	end
	return true
end

function ns.GetBagSlot(location)
	local container = math.floor(location)
	local slot = math.floor((location - container) * 100 + 0.5)
	return container, slot
end

function ns.GetLocation(container, slot)
	return tonumber(string.format("%d.%.2d", container, slot) or '')
end

function ns.GetItemClassification(container, slot)
	local location = ns.GetLocation(container, slot)
	local cacheData = ns.containers[location]

	if cacheData.item then
		return cacheData.label or ns.IGNORE
	end
end

-- --------------------------------------------------------
--  Namespaced functions
-- --------------------------------------------------------
local function Classify(location)
	local cacheData = ns.containers[location]

	local priority, doSell, priorityReason
	if not cacheData.item then
		priority = ns.priority.IGNORE
		priorityReason = ns.reason.EMPTY_SLOT
	else
		priority, doSell, priorityReason = ns.GetItemPriority(location)
		if doSell then
			cacheData.label = ns.AUTOSELL
			cacheData.value = cacheData.item.v
		elseif priority == ns.priority.NEGATIVE and cacheData.label == ns.IGNORE then
			-- FIXME: conflict
			cacheData.label = ns.INCLUDE
		end
	end

	cacheData.priority = priority or ns.priority.NEUTRAL
	cacheData.reason   = priorityReason
	cacheData.sell     = doSell

	-- ns:SendMessage('ITEM_SLOT_UPDATE', location, cacheData.item and cacheData.item.id, cacheData.label, cacheData.priority, cacheData.reason, cacheData.sell)

	return cacheData
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
				local oldLocation = tContains(itemLocations, location)
				if itemLocations and oldLocation then
					table.remove(itemLocations, oldLocation)
				end
			end
			if newItem then
				-- add new item to locations
				if not ns.locations[ newItem ] then
					ns.locations[ newItem ] = {}
				end
				table.insert(ns.locations[ newItem ], location)
				table.sort(ns.locations, LocationSort)
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
			cacheData.priority = ns.priority.NEUTRAL
		else
			cacheData.label = ns.IGNORE
			cacheData.value = 0
			cacheData.priority = ns.priority.IGNORE
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
	for _, location in pairs(ns.locations[item] or emptyTable) do
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
		Classify(location)
	end
	for _, limiter in pairs(changedLimits) do
		for _, location in pairs( categoryLocations[limiter] ) do
			Classify(location)
		end
	end

	wipe(ns.list)
	for location, data in pairs(ns.containers) do
		if data.item and data.priority ~= ns.priority.IGNORE then
			-- only interested in slots with items
			table.insert(ns.list, location)
		end
	end
	table.sort(ns.list, ns.ItemSort)
	ns.UpdateLDB()
end

-- returns: priority, autoSell, reason
function ns.GetItemPriority(location)
	-- TODO: allow calling with itemLink instead
	--  get item info from ns.item[itemID] cache
	--  allow SlotIsOverLimit with only checking *other* locations
	--  adjust IsItemSoulbound to only use .bop if no location
	local priority, reason
	local item = ns.containers[location].item
	if not item or not item.id then return
		ns.priority.IGNORE, false, ns.reason.EMPTY_SLOT
	end

	-- check list config by itemID
	local listed = ns.keep[ item.id ]
	if listed then
		local overLimit = listed > 0 and ns.SlotIsOverLimit(location, item.id, listed)
		if not overLimit then
			priority = ns.priority.POSITIVE
			reason = ns.reason.KEEP_ID
			return priority, false, reason
		end
	end

	listed = ns.toss[ item.id ]
	if listed then
		priority = ns.priority.NEGATIVE
		reason = ns.reason.TOSS_ID
		return priority, listed == 1, reason
	end

	if ns.db.global.LPTJunkIsJunk and item.q == 0 then
		-- override categories that include gray items
		priority = ns.priority.NEUTRAL
		reason = ns.reason.GRAY_ITEM
		return priority, item.v and item.v > 0, reason
	end

	-- check list config by category
	for category, value in pairs(ns.keep) do
		if type(category) == "string" and ns.isItemInCategory(item.id, category) then
			local overLimit = value > 0 and ns.SlotIsOverLimit(location, category, value)
			if not overLimit then
				priority = ns.priority.POSITIVE
				reason = ns.reason.KEEP_CAT
				return priority, false, reason
			end
		end
	end

	for category, value in pairs(ns.toss) do
		if type(category) == "string" and ns.isItemInCategory(item.id, category) then
			priority = ns.priority.NEGATIVE
			reason = ns.reason.TOSS_CAT
			return priority, value == 1, reason
		end
	end

	-- quest items
	if ns.db.global.keepQuestItems and item.cl == QUEST then
		priority = ns.priority.POSITIVE
		reason = ns.reason.QUEST_ITEM
		return priority, false, reason
	end

	-- unusable gear
	if ns.db.global.sellUnusable and item.q <= ns.db.global.sellUnusableQuality and
		item.slot ~= "" and item.slot ~= "INVTYPE_BAG" and item.bop and Unfit:IsItemUnusable(item.id) then
		-- soulbound boe can't be unusable!
		priority = ns.priority.NEUTRAL
		reason = ns.reason.UNUSABLE_ITEM
		return priority, true, reason
	end

	-- outdated gear
	if ns.db.global.sellOutdated and item.q <= ns.db.global.sellOutdatedQuality and
		item.slot ~= "" and item.slot ~= "INVTYPE_BAG" and ns.IsItemSoulbound(location) then
		local isOutdated, isHighestLevel = ns.IsOutdatedItem(location)
		if isOutdated then
			priority = ns.priority.NEUTRAL
			return priority, true, ns.reason.OUTDATED_ITEM
		elseif isHighestLevel then
			priority = ns.priority.POSITIVE
			return priority, false, ns.reason.HIGHEST_LEVEL
		end
	end

	-- items without value
	if item.v == 0 and ns.db.global.ignoreZeroValue then
		priority = ns.priority.IGNORE
		reason = ns.reason.WORTHLESS
		return priority, false, reason
	end

	-- gray quality items
	if item.q == 0 then -- TODO: config "autosell greys"
		priority = ns.priority.NEUTRAL
		reason = ns.reason.GRAY_ITEM
		return priority, true, reason
	end

	-- respect thresholds
	if item.q > ns.db.global.dropQuality then
		priority = ns.priority.IGNORE
		reason = ns.reason.QUALITY
		return priority, false, reason
	end

	return ns.priority.NEUTRAL, false
end

function ns.GetItemAction(location)
	-- TODO: we should probably cache this to item ...
	local item = ns.containers[ location ].item
	local label, reason

	-- custom prices for either this item or one of its categories
	local userPrice = ns.db.global.prices[item.id]
	if userPrice then
		userPrice = userPrice == -1 and item.v or userPrice
		reason = ns.reason.PRICE_ITEM
	else
		local maxCustomValue
		for limiter, limit in pairs(item.limit or emptyTable) do
			userPrice = ns.db.global.prices[limiter]
			if userPrice then
				local value = (userPrice == -1) and item.v or userPrice
				if not maxCustomValue or value > maxCustomValue then
					maxCustomValue = value
				end
			end
		end
		if maxCustomValue then
			userPrice = maxCustomValue
			reason = ns.reason.PRICE_CAT
		end
	end

	local itemLink = GetContainerItemLink( ns.GetBagSlot(location) )
	local unbound = not ns.IsItemSoulbound(location)

	local disenchantPrice = ns.GetDisenchantValue(itemLink, unbound and ns.db.global.disenchantValues) or -1
	local auctionPrice

	-- custom price rules override auction values
	if userPrice then
		auctionPrice = -1
	else
		auctionPrice = (not userPrice and unbound) and ns.GetAuctionValue(itemLink) or -1
		userPrice = -1
	end

	local maxPrice = math.max(disenchantPrice, auctionPrice, userPrice, item.v or 0, 0)
	if maxPrice == 0 and ns.db.global.ignoreZeroValue then
		label = ns.IGNORE
		reason = ns.reason.WORTHLESS
	elseif maxPrice == userPrice then
		label = ns.CUSTOM
		reason = reason
	else
		label = (maxPrice == item.v and ns.VENDOR) or
	            (maxPrice == disenchantPrice and ns.DISENCHANT) or
	            (maxPrice == auctionPrice and ns.AUCTION) or
	            ns.IGNORE
		reason = ns.reason.HIGHEST_VALUE
	end

	return label, maxPrice, reason
end

function ns.GetUnownedItemInfo(item, count)
	local itemID, itemLink
	if not item then
		return
	elseif type(item) == 'string' then
		itemID = ns.GetItemID(item)
		itemLink = item
	elseif type(item) == 'number' then
		itemID = item
		_, itemLink = GetItemInfo(itemID)
	end

	-- pretend to have this item in inventory
	local location = EXTERNAL_ITEM
	ns.containers[location].loc   = EXTERNAL_ITEM
	ns.containers[location].count = count or 1
	ns.containers[location].item  = ns.item[itemID]
	ns.containers[location].item.link = itemLink

	-- get classification data
	local data = Classify(location)
	local priority, label, value, autoSell, reason = data.priority, data.label, data.value, data.sell, data.reason

	-- remove item from fake inventory
	ns.containers[location].item.link = nil
	ns.containers[location].item = nil
	Classify(location)

	return priority, label, value, autoSell, reason
end
