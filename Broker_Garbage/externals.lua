local addonName, ns, _ = ...

-- GLOBALS: _G, ArkInventory, ArkInventoryRules, InitArkInvFilter, Bagnon, ElvUI
-- GLOBALS: IsAddOnLoaded, GetItemInfo
-- GLOBALS: string, tonumber, hooksecurefunc, pairs, strsplit, type

local disableKeys = {
	["NONE"] 	= function() return false end,
	["SHIFT"] 	= IsShiftKeyDown,
	["ALT"] 	= IsAltKeyDown,
	["CTRL"] 	= IsControlKeyDown,
}
function ns.IsDisabled()
	local disable = disableKeys[ns.db.global.disableKey]
	return (disable and disable())
end

-- character(optional): "Mychar - My Realm"
local emptyTable = {}
function ns:GetStatistics(character)
	local moneyEarned, moneyLost, numSold, numDeleted = 0, 0, 0, 0
	for char, variables in pairs(ns.db.sv.char or emptyTable) do
		if not character or char == character then
			moneyEarned = moneyEarned + (variables.moneyEarned or 0)
			moneyLost   = moneyLost   + (variables.moneyLost or 0)
			numSold     = numSold     + (variables.numSold or 0)
			numDeleted  = numDeleted  + (variables.numDeleted or 0)
		end
	end
	return moneyEarned, moneyLost, numSold, numDeleted
end

-- --------------------------------------------------------
--  Saved Variables: User Settings
-- --------------------------------------------------------
function ns:GetOption(optionName, global)
	local option, subOption = strsplit('.', optionName)
	local variable = global and self.db.global[option] or self.db.profile[option]
	if subOption then
		variable = variable[subOption]
	end
	return variable
end

function ns:SetOption(optionName, global, value)
	local option, subOption = strsplit('.', optionName)
	if global then
		local variable = subOption and ns.db.global[option] or ns.db.global
		variable[subOption or option] = value
	else
		local variable = subOption and ns.db.profile[option] or ns.db.profile
		variable[subOption or option] = value
	end
end

-- toggles an option true/false
function ns:ToggleOption(optionName, global)
	local value = ns:GetOption(optionName, global)
	ns:SetOption(optionName, global, not value)
end

-- resets an option entry to its default value
function ns.ResetOption(optionName)
	local default = ns.db.defaults.global[optionName] or ns.db.defaults.profile[optionName]
	ns:SetOption(optionName, ns.db.defaults.global[optionName], default)
end

-- --------------------------------------------------------
--  Saved Variables: Item List Settings
-- --------------------------------------------------------
-- add item or category to config lists. items may only ever live in local xor global list
-- <list>: "toss", "keep" or "prices"
function ns.Add(list, item, value, isGlobal, noUpdate)
	if list == "prices" then
		ns.db.global[list][item] = value or -1
	else
		ns.db.profile[list][item] = value or 0
	end

	if not noUpdate then
		ns:UpdateItem(item)
		ns:Scan()
		ns:UpdateLDB()
	end
end
function ns.Remove(list, item, noUpdate)
	if list == "prices" then
		ns.db.global[list][item] = nil
	else
		ns.db.profile[list][item] = nil
	end

	if not noUpdate then
		ns:UpdateItem(item)
		ns:Scan()
		ns:UpdateLDB()
	end
	-- ns.UpdateMerchantButton()
end
function ns.Get(list, item)
	return list == "prices" and ns.db.global[list][item] or ns.db.profile[list][item]
end
function ns.IsShared(list, item)
	return ns.db:GetCurrentProfile() == 'Default'
end
function ns.ToggleShared(list, item)
	local isGlobal = ns.IsShared(list, item)
	local value = ns.Get(list, item)
	ns.Remove(list, item)
	ns.Add(list, item, value, not isGlobal)
end

-- TODO: Extend LibCustomSearch https://github.com/ckaotik/Midget/blob/8f64139272d237fa8eadc5dffc7222f55d227c39/functions.lua#L314

-- --------------------------------------------------------
--  Integration with third party addons
-- --------------------------------------------------------
-- ArkInventory + ArkInventoryRules
function ns.ArkInventoryFilter(label)
	if not ArkInventoryRules.Object.loc_id or not ArkInventoryRules.Object.h or ArkInventoryRules.Object.class ~= "item" then
		return false
	end
	local container = ArkInventory.BagID_Blizzard(ArkInventoryRules.Object.loc_id, ArkInventoryRules.Object.bag_id)
	local slot = ArkInventoryRules.Object.slot_id
	label = label and string.upper(label)

	return ns.GetItemClassification(container, slot) == ns[label]
end

local function InitArkInventoryFIlters()
	if not ArkInventoryRules:IsEnabled() then
		-- hook for when AIR activates
		hooksecurefunc(ArkInventoryRules, "OnInitialize", ns.InitArkInvFilter)
		return
	else
		ArkInventoryRules.Register(ns, "brokergarbage", ns.ArkInventoryFilter, false)
	end
	-- make sure we only init once
	InitArkInvFilter = function() end
end

--[[ Status Icons
	these indicators need two handlers:
		1) the bag slot was changed by 'the addon', have BG react and update display if needed
		2) BG has changed labels for an item, have 'the addon' update its display
--]]

local function CreateIcon(button)
	local icon = button:CreateTexture(nil, 'OVERLAY')
	      icon:SetTexture('Interface\\Buttons\\UI-GroupLoot-Coin-Up')
	      icon:SetPoint('TOPLEFT', 2, -2)
	      icon:SetSize(16, 16)
  	button.JunkIcon = icon

	return icon
end

-- call with <itemLink>, <count> -or- <container>, <slot>
local function UpdateJunkIcon(button, container, slot)
	local sellItem, disenchantItem, itemQuality = false, false, nil
	if not container then
		-- slot is empty
	elseif type(container) == 'string' then
		-- probably an item link
		local _, _, quality = GetItemInfo(container)
		local priority, label, value, sell, reason = ns.GetUnownedItemInfo(container, slot or 1)
		disenchantItem  = label == ns.DISENCHANT
		sellItem        = disenchantItem or sell
		itemQuality     = quality
	else
		local location  = ns.GetLocation(container, slot)
		local cacheData = ns.containers[location]
		if cacheData and cacheData.item then
			sellItem        = cacheData.sell
			disenchantItem  = cacheData.label == ns.DISENCHANT
			itemQuality     = cacheData.item.q
		end
	end

	if ns.db.global.showJunkSellIcons then
		local icon = button.JunkIcon or (sellItem and CreateIcon(button))
		if sellItem then
			if disenchantItem then
				icon:SetVertexColor(1, 0.2, 1)
				icon:SetDesaturated(true)
			else
				icon:SetVertexColor(1, 1, 1)
				icon:SetDesaturated(false)
			end
			icon:Show()
		elseif icon then
			icon:Hide()
		end
	elseif button.JunkIcon and button.JunkIcon:IsShown() and itemQuality ~= _G.LE_ITEM_QUALITY_POOR then
		-- junk icon was shown by us
		button.JunkIcon:Hide()
	end
end

local plugin = ns:NewModule('Externals')

function plugin:OnEnable()
	-- Bagnon
	if IsAddOnLoaded('Bagnon') then
		-- FIXME: this approach fails on limited items
		-- Bagnon's updates fire earlier than our data updates, so we need to use unowned item data
		hooksecurefunc(Bagnon.ItemSlot, 'Update', function(button)
			local icon, count, locked, quality, readable, lootable, link = button:GetInfo()
			-- UpdateJunkIcon(button, link, count)
			UpdateJunkIcon(button, button:GetBag(), button:GetID())
		end)
		hooksecurefunc(ns, 'Scan', function() Bagnon:UpdateFrames() end)
	end

	-- ArkInventory
	if IsAddOnLoaded('ArkInventory') then
		-- junk icons
		hooksecurefunc(ArkInventory, 'Frame_Item_Update', function(location, bag, slot)
			if location ~= ArkInventory.Const.Location.Bag then return end
			local button = _G[ArkInventory.ContainerItemNameGet(location, bag, slot)]
			local data = ArkInventory.Frame_Item_GetDB(button)
			UpdateJunkIcon(button, data.h, data.count)
		end)

		-- custom rules
		InitArkInventoryFIlters()
	end

	-- ElvUI
	if IsAddOnLoaded('ElvUI') then
		local ElvUISetup = false
		local bagsModule = ElvUI[1]:GetModule('Bags')
		if bagsModule then
			hooksecurefunc(bagsModule, 'UpdateSlot', function(containerFrame, bagID, slotID)
				local button = containerFrame.Bags and containerFrame.Bags[bagID] and containerFrame.Bags[bagID][slotID]
				if not button then return end
				UpdateJunkIcon(button, bagID, slotID)

				if not ElvUISetup then
					hooksecurefunc(ns, 'Scan', function()
						containerFrame:UpdateAllSlots()
					end)
					ElvUISetup = true
				end
			end)
		end
	end
end
