local _, ns = ...

-- GLOBALS: BG_GlobalDB, BG_LocalDB, ITEM_BIND_ON_PICKUP, ITEM_SOULBOUND, ITEM_LEVEL, TopFit, PawnIsItemAnUpgrade, PawnGetItemData, PawnGetSlotsForItemType, _G, UIParent
-- GLOBALS: GetItemInfo, GetCursorInfo, DeleteCursorItem, ClearCursor, PickupContainerItem, GetContainerItemInfo, GetContainerItemID, GetContainerItemLink, GetInventoryItemLink, GetProfessions, GetProfessionInfo, GetContainerItemEquipmentSetInfo, GetInventoryItemsForSlot, EquipmentManager_UnpackLocation
-- GLOBALS: type, select, string, ipairs, math, tonumber, wipe, pairs, table, strsplit

local emptyTable = {}
local EXTERNAL_ITEM = 0

-- --------------------------------------------------------
--  LPT caching
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
		if LPT then GetExpandedLPTData(self[category], LPT:GetSetTable(category)) end
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
--  Item Binding
-- --------------------------------------------------------
local scanTooltip = CreateFrame("GameTooltip", "BrokerGarbageScanTooltip", nil, "GameTooltipTemplate")
local GetItemBinding = setmetatable({}, {
	__index = function(self, id)
		scanTooltip:SetOwner(UIParent, "ANCHOR_NONE")
		scanTooltip:SetHyperlink("item:"..id)
		local binding = _G[scanTooltip:GetName().."TextLeft2"]:GetText()
		if not binding or binding:find(ITEM_LEVEL) then
			binding = _G[scanTooltip:GetName().."TextLeft3"]:GetText()
		end
		scanTooltip:Hide()
		if binding then
			self[id] = binding
			return binding
		end
	end ,
	__call = function(self, itemID)
		return self[itemID]
	end
})

function ns.IsItemBoP(itemID)
	return (GetItemBinding(itemID) == ITEM_BIND_ON_PICKUP)
end

function ns.IsItemSoulbound(location)
	local item = ns.containers[location].item
	if item then
		if item.bop then
			return true
		else
			scanTooltip:SetOwner(UIParent, "ANCHOR_NONE")
			if location ~= EXTERNAL_ITEM then
				scanTooltip:SetBagItem( ns.GetBagSlot(location) )
			elseif item.link then
				scanTooltip:SetHyperlink(item.link)
			else
				return
			end
			local binding = _G[scanTooltip:GetName().."TextLeft2"]:GetText() == ITEM_SOULBOUND or
		                    _G[scanTooltip:GetName().."TextLeft3"]:GetText() == ITEM_SOULBOUND
			scanTooltip:Hide()
			return binding
		end
	end
end

-- --------------------------------------------------------
--  Item Values
-- --------------------------------------------------------
function ns.GetAuctionValue(itemLink)
	local auctionPrice, auctionAddon
	for i, addonKey in ipairs(BG_GlobalDB.auctionAddonOrder.buyout) do
		auctionAddon = ns.auctionAddons[addonKey]
		if auctionAddon and auctionAddon.buyout then
			if auctionAddon.buyoutEnabled and auctionAddon.buyout then
				auctionPrice = auctionAddon.buyout(itemLink)
			end
			if auctionPrice then break end
		end
	end
	return auctionPrice
end

function ns.GetDisenchantValue(itemLink, noSkillReq)
	local canDisenchant = ns.CanDisenchant(itemLink)
	if not canDisenchant and not noSkillReq then return end

	local disenchantPrice, auctionAddon
	for i, addonKey in ipairs(BG_GlobalDB.auctionAddonOrder.disenchant) do
		auctionAddon = ns.auctionAddons[addonKey]
		if auctionAddon and auctionAddon.disenchant then
			if canDisenchant and auctionAddon.disenchantEnabled and auctionAddon.disenchant then
				disenchantPrice = auctionAddon.disenchant(itemLink)
			end
			if disenchantPrice then break end
		end
	end
	return disenchantPrice
end

local WEAPON, ARMOR = GetAuctionItemClasses()
local ENCHANTING = GetSpellInfo(7411)
local notDisenchantable = {} -- TODO: fill with data
function ns.CanDisenchant(item)
	local item = ns.item[item]
	if notDisenchantable[item.id] or (item.cl ~= WEAPON and item.cl ~= ARMOR) or item.q < 2 or item.q > 4 then
		return false
	else
		local prof1, prof2 = GetProfessions()
		if not prof1 then return false end
		local name, _, mySkill = GetProfessionInfo(prof1)
		if name ~= ENCHANTING and prof2 then name, _, mySkill = GetProfessionInfo(prof2) end
		if name ~= ENCHANTING then return false end

		local requiredSkill
		-- see http://www.wowpedia.org/Disenchanting#Required_Enchanting_skill
		if     item.l <=  20 then requiredSkill = 1
		elseif item.l <   60 then requiredSkill = (math.floor(item.l / 5) - 3) * 25
		elseif item.q == 2 then -- uncommon
			if     item.l <=  99 then requiredSkill = 225
			elseif item.l <= 120 then requiredSkill = 275
			elseif item.l <= 150 then requiredSkill = 325
			elseif item.l <= 182 then requiredSkill = 350
			elseif item.l <= 318 then requiredSkill = 425
			elseif item.l <= 437 then requiredSkill = 475
			else
				-- ??
			end
		elseif item.q == 3 then -- rare
			if     item.l <=  97 then requiredSkill = 225
			elseif item.l <= 115 then requiredSkill = 275
			elseif item.l <= 200 then requiredSkill = 325
			elseif item.l <= 346 then requiredSkill = 450
			elseif item.l <= 424 then requiredSkill = 525
			elseif item.l <= 463 then requiredSkill = 550
			else
				-- ??
			end
		elseif item.q == 4 then -- epic
			if     item.l <=  95 then requiredSkill = 225
			elseif item.l <= 164 then requiredSkill = 300
			elseif item.l <= 277 then requiredSkill = 375
			elseif item.l <= 416 then requiredSkill = 475
			elseif item.l <= 575 then requiredSkill = 575
			else
				-- ??
			end
		end

		return (mySkill + BG_GlobalDB.keepItemsForLaterDE) >= (requiredSkill or 1)
	end
end

-- --------------------------------------------------------
--  Interesting/Outdated items
-- --------------------------------------------------------
local LibItemUpgrade = LibStub("LibItemUpgradeInfo-1.0")
local itemsForInvType = {}
local function IsHighestItemLevel(location)
	local item = ns.containers[ location ].item
	local equipSlot = item.slot
	local slots = (TopFit and TopFit.GetEquipLocationsByInvType and TopFit:GetEquipLocationsByInvType(equipSlot)) or
		(PawnGetSlotsForItemType and { PawnGetSlotsForItemType(equipSlot) }) or
		{}

	local numSlots = #slots
	local locationLevel = LibItemUpgrade:GetUpgradedItemLevel(item.link or GetContainerItemLink(ns.GetBagSlot(location)))

	wipe(itemsForInvType)
	-- compare with equipped item levels
	for _, slot in ipairs(slots) do
		local itemLink = GetInventoryItemLink("player", slot)
		local itemLevel = itemLink and LibItemUpgrade:GetUpgradedItemLevel(itemLink)
		if itemLevel and locationLevel and itemLevel > locationLevel then
			numSlots = numSlots - 1
		end
		if numSlots <= 0 then return false end

		GetInventoryItemsForSlot(slot, itemsForInvType)
	end

	-- compare with other equipment in bags
	for location, inventoryItemID in pairs(itemsForInvType) do
		local isEquipped, _, isInBags, _, slot, container = EquipmentManager_UnpackLocation(location)
		-- use actual link for upgraded item levels
		local itemLink = isInBags and GetContainerItemLink(container, slot)
		local itemLevel = itemLink and LibItemUpgrade:GetUpgradedItemLevel(itemLink)
		if itemLink and itemLevel > locationLevel then
			numSlots = numSlots - 1
		end
		if numSlots <= 0 then return false end
	end
	return true
end

local function IsInterestingItem(itemLink)
	local isInteresting = true
	if TopFit and TopFit.IsInterestingItem then
		isInteresting = TopFit:IsInterestingItem(itemLink)
	end
	if PawnGetItemData and PawnIsItemAnUpgrade then
		local upgrade, best, secondBest = PawnIsItemAnUpgrade( PawnGetItemData(itemLink), true )
		isInteresting = isInteresting or upgrade or best or secondBest
	end
	return isInteresting
end

function ns.IsOutdatedItem(location)
	local item = ns.containers[ location ].item
	local invSlot = item and item.slot

	if not item or invSlot == "" or invSlot == "INVTYPE_BAG" then
		return
	else
		local itemLink = item.link or GetContainerItemLink( ns.GetBagSlot(location) )
		local isInteresting = IsInterestingItem(itemLink)
		local isHighestItemLevel = not isInteresting and BG_GlobalDB.keepHighestItemLevel and IsHighestItemLevel(location)

		return not (isInteresting or isHighestItemLevel), isHighestItemLevel
	end
end

-- --------------------------------------------------------
--  Item Deletion
-- --------------------------------------------------------
local function Deleted(item, count)
	local _, link, _, _, _, _, _, _, _, _, vendorPrice = GetItemInfo(item)
	local itemValue = count * vendorPrice

	-- statistics
	BG_GlobalDB.itemsDropped 		= BG_GlobalDB.itemsDropped + count
	BG_GlobalDB.moneyLostByDeleting	= BG_GlobalDB.moneyLostByDeleting + itemValue
	BG_LocalDB.moneyLostByDeleting 	= BG_LocalDB.moneyLostByDeleting + itemValue

	ns.PrintFormat(ns.locale.itemDeleted, link, count)
end
-- deletes the item in a given location of your bags
function ns.Delete(location, ...)
	if not location then
		ns.Print("Error! Broker_Garbage Delete: no argument supplied.")
		return
	elseif location == "cursor" then
		-- item on the cursor
		local cursorType, itemID = GetCursorInfo()
		if cursorType ~= "item" then
			-- TODO: localize
			ns.Print("Error! Trying to delete an item from the cursor, but there is none.")
			return
		end
		DeleteCursorItem()
		Deleted(itemID, ...)
	else
		-- security check
		local container, slot = ns.GetBagSlot(location)
		local cacheData = ns.containers[location]

		-- TODO: also check item count?
		if cacheData.item and GetContainerItemID(container, slot) == cacheData.item.id then
			-- actually delete the item
			ClearCursor()
			PickupContainerItem(container, slot)
			DeleteCursorItem()
			Deleted(cacheData.item.id, cacheData.count)
		else
			-- TODO: localize
			ns.PrintFormat("Error! Item to be deleted is not the expected item (%s in %d)",
				cacheData.item and cacheData.item.id or "?",
				location)
		end
	end
end
