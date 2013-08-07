local _, BG = ...

-- GLOBALS: BG_GlobalDB, BG_LocalDB, ITEM_BIND_ON_PICKUP, ITEM_SOULBOUND, TopFit, PawnIsItemIDAnUpgrade, _G, UIParent
-- GLOBALS: GetItemInfo, GetCursorInfo, DeleteCursorItem, ClearCursor, PickupContainerItem, GetContainerItemInfo, GetContainerItemID, GetContainerItemLink, GetProfessions, GetProfessionInfo
-- GLOBALS: type, select, string, ipairs, math

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

function BG.IsItemBoP(itemID)
	return (GetItemBinding(itemID) == ITEM_BIND_ON_PICKUP)
end

function BG.IsItemSoulbound(location)
	local item = BG.containers[location].item
	if item then
		if item.bop then
			return true
		else
			scanTooltip:SetOwner(UIParent, "ANCHOR_NONE")
			scanTooltip:SetBagItem( BG.GetBagSlot(location) )
			local binding = _G[scanTooltip:GetName().."TextLeft2"]:GetText() == ITEM_SOULBOUND or
		                    _G[scanTooltip:GetName().."TextLeft3"]:GetText() == ITEM_SOULBOUND
			scanTooltip:Hide()
			return binding
		end
	end
end

function BG.GetAuctionValue(itemLink)
	local auctionPrice, auctionAddon
	for i, addonKey in ipairs(BG_GlobalDB.auctionAddonOrder.buyout) do
		auctionAddon = BG.auctionAddons[addonKey]
		if auctionAddon and auctionAddon.buyout then
			if auctionAddon.buyoutEnabled and auctionAddon.buyout then
				auctionPrice = auctionAddon.buyout(itemLink)
			end
			if auctionPrice then break end
		end
	end
	return auctionPrice
end

function BG.GetDisenchantValue(itemLink, noSkillReq)
	local canDisenchant = BG.CanDisenchant(itemLink)
	if not canDisenchant and not noSkillReq then return end

	local disenchantPrice, auctionAddon
	for i, addonKey in ipairs(BG_GlobalDB.auctionAddonOrder.disenchant) do
		auctionAddon = BG.auctionAddons[addonKey]
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
local notDisenchantable = {} -- TODO: fill with data
function BG.CanDisenchant(item)
	local item = BG.item[item]
	if notDisenchantable[item.id] or (item.cl ~= WEAPON and item.cl ~= ARMOR) or item.q < 2 or item.q > 4 then
		return false
	else
		local prof1, prof2 = GetProfessions()
		local name, _, mySkill = GetProfessionInfo(prof1)
		if name ~= BG.enchanting then name, _, mySkill = GetProfessionInfo(prof2) end
		if name ~= BG.enchanting then return false end

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

local itemLevel = setmetatable({ -- see http://www.wowinterface.com/forums/showthread.php?t=45388
    [1]   =  8, -- 1/1
    [373] =  4, -- 1/2
    [374] =  8, -- 2/2
    [375] =  4, -- 1/3
    [376] =  4, -- 2/3
    [377] =  4, -- 3/3
    [379] =  4, -- 1/2
    [380] =  4, -- 2/2
    [446] =  4, -- 1/2
    [447] =  8, -- 2/2
    [452] =  8, -- 1/1
    [454] =  4, -- 1/2
    [455] =  8, -- 2/2
    [457] =  8, -- 1/1
    [459] =  4, -- 1/4
    [460] =  8, -- 2/4
    [461] = 12, -- 3/4
    [462] = 16, -- 4/4
    [466] =  4, -- 1/2
    [467] =  8, -- 2/2
    [469] =  4, -- 1/4
    [470] =  8, -- 2/4
    [471] = 12, -- 3/4
    [472] = 16, -- 4/4
}, {
	__call = function(self, item)
		if type(item) == "number" then
			item = GetContainerItemLink( BG.GetBagSlot(item) )
		end
		local _, _, _, iLevel = GetItemInfo(item)
		local modifier = tonumber( select(12, strsplit(":", item)) or "" )
		return iLevel + (modifier and self[modifier] or 0)
	end
})

local itemsForInvType = {}
local itemsForSlot = {}
local function SortEquipmentItems(locationA, locationB)
	local levelA = itemLevel(locationA)
	local levelB = itemLevel(locationB)
	local isAInSet = GetContainerItemEquipmentSetInfo( BG.GetBagSlot(locationA) )
	local isBInSet = GetContainerItemEquipmentSetInfo( BG.GetBagSlot(locationB) )

	if levelA ~= levelB then
		return levelA > levelB
	elseif isAInSet ~= isBInSet then
		return isAInSet
	else
		return locationA < locationB
	end
end

local function IsHighestItemLevel(location)
	local item = BG.containers[ location ].item
	local slots = (TopFit and TopFit.GetEquipLocationsByInvType and TopFit:GetEquipLocationsByInvType(item.slot)) or
		(PawnGetSlotsForItemType and { PawnGetSlotsForItemType(item.slot) }) or
		{}

	wipe(itemsForInvType)
	for _, slot in ipairs(slots) do
		GetInventoryItemsForSlot(slot, itemsForInvType)
	end
	wipe(itemsForSlot)
	for location, inventoryItemID in pairs(itemsForInvType) do
		local isEquipped, _, isInBags, _, slot, container = EquipmentManager_UnpackLocation(location)
		if isInBags then
			table.insert(itemsForSlot, BG.GetLocation(container, slot))
		end
	end
	sort(itemsForSlot, SortEquipmentItems)

	for i = 1, #slots do
		if itemsForSlot[i] and itemsForSlot[i] == location then
			return true
		end
	end
end

function BG.IsOutdatedItem(location)
	local item = BG.containers[ location ].item
	local invSlot = item and item.slot

	if not item or invSlot == "" or invSlot == "INVTYPE_BAG" --[[or invSlot:find("TRINKET")--]] then
		return
	else
		local isInteresting = true
		if TopFit and TopFit.IsInterestingItem then
			isInteresting = TopFit:IsInterestingItem(item.id)
		end
		if PawnIsItemIDAnUpgrade then
			local upgrade, best, secondBest = PawnIsItemIDAnUpgrade(item.id, true)
			isInteresting = isInteresting or upgrade or best or secondBest
		end

		local isHighestItemLevel = not isInteresting and BG_GlobalDB.keepHighestItemLevel and IsHighestItemLevel(location, item)
		return not (isInteresting or isHighestItemLevel), isHighestItemLevel
	end
end

local function Deleted(item, count)
	local _, link, _, _, _, _, _, _, _, _, vendorPrice = GetItemInfo(item)
	local itemValue = count * vendorPrice

	-- statistics
	BG_GlobalDB.itemsDropped 		= BG_GlobalDB.itemsDropped + count
	BG_GlobalDB.moneyLostByDeleting	= BG_GlobalDB.moneyLostByDeleting + itemValue
	BG_LocalDB.moneyLostByDeleting 	= BG_LocalDB.moneyLostByDeleting + itemValue

	BG.PrintFormat(BG.locale.itemDeleted, link, count)
end
-- deletes the item in a given location of your bags
function BG.Delete(location, ...)
	if not location then
		BG.Print("Error! Broker_Garbage Delete: no argument supplied.")
		return
	elseif location == "cursor" then
		-- item on the cursor
		local cursorType, itemID = GetCursorInfo()
		if cursorType ~= "item" then
			-- TODO: localize
			BG.Print("Error! Trying to delete an item from the cursor, but there is none.")
			return
		end
		DeleteCursorItem()
		Deleted(itemID, ...)
	else
		-- security check
		local container, slot = BG.GetBagSlot(location)
		local cacheData = BG.containers[location]

		-- TODO: also check item count?
		if cacheData.item and GetContainerItemID(container, slot) == cacheData.item.id then
			-- actually delete the item
			ClearCursor()
			PickupContainerItem(container, slot)
			DeleteCursorItem()
			Deleted(cacheData.item.id, cacheData.count)
		else
			-- TODO: localize
			BG.PrintFormat("Error! Item to be deleted is not the expected item (%s in %d)",
				cacheData.item and cacheData.item.id or "?",
				location)
		end
	end
end
