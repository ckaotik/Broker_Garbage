local addonName, ns, _ = ...
_G[addonName] = ns

local BG = ns

-- GLOBALS: BG_GlobalDB, BG_LocalDB, ArkInventory, ArkInventoryRules, Bagnon
-- GLOBALS: IsAddOnLoaded
-- GLOBALS: string, tonumber, hooksecurefunc

function ns.IsDisabled()
	local disable = ns.disableKey[BG_GlobalDB.disableKey]
	return (disable and disable())
end

-- --------------------------------------------------------
--  Saved Variables: User Settings
-- --------------------------------------------------------
function BG:GetOption(optionName, global)
	if global == nil then
		return BG_LocalDB[optionName], BG_GlobalDB[optionName]
	elseif global == false then
		return BG_LocalDB[optionName]
	else
		return BG_GlobalDB[optionName]
	end
end

function BG:SetOption(optionName, global, value)
	if not global then
		BG_LocalDB[optionName] = value
	else
		BG_GlobalDB[optionName] = value
	end
end

-- toggles an option true/false
function BG:ToggleOption(optionName, global)
	if not global then
		BG_LocalDB[optionName] = not BG_LocalDB[optionName]
	else
		BG_GlobalDB[optionName] = not BG_GlobalDB[optionName]
	end
end

-- resets an option entry to its default value
function ns.ResetOption(name)
	if ns.defaultLocalSettings[name] ~= nil then
		BG_LocalDB[name]  = ns.defaultLocalSettings[name]
	elseif ns.defaultGlobalSettings[name] ~= nil then
		BG_GlobalDB[name] = ns.defaultGlobalSettings[name]
	else
		ns.Print('Error: No setting named "'..name..'" found.')
	end
end

-- --------------------------------------------------------
--  Saved Variables: Item List Settings
-- --------------------------------------------------------
-- add item or category to config lists. items may only ever live in local xor global list
-- <list>: "toss", "keep" or "prices"
function ns.Add(list, item, value, isGlobal, noUpdate)
	if list == "prices" then
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
		ns.Print("Update locations of "..item)
		ns.Scan(ns.UpdateItem, ns.locations[item])
	end
end
function ns.Remove(list, item)
	if list ~= "prices" then
		BG_LocalDB[list][item] = nil
	end
	BG_GlobalDB[list][item] = nil
	ns[list][item] = nil

	-- TODO: update lists etc
	-- Broker_Garbage:UpdateLDB()
	-- Broker_Garbage.UpdateMerchantButton()
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
--  Integration with third party addons
-- --------------------------------------------------------
-- ArkInventory + ArkInventoryRules
function BG.ArkInventoryFilter(label)
	if not ArkInventoryRules.Object.h or ArkInventoryRules.Object.class ~= "item" then
		return false
	end
	local container = ArkInventory.BagID_Blizzard(ArkInventoryRules.Object.loc_id, ArkInventoryRules.Object.bag_id)
	local slot = ArkInventoryRules.Object.slot_id
	label = label and string.upper(label)

	return BG.GetItemClassification(container, slot) == BG[label]
end
function BG.InitArkInvFilter()
	if not IsAddOnLoaded("ArkInventoryRules") then return end
	if not ArkInventoryRules:IsEnabled() then
		-- hook for when AIR activates
		hooksecurefunc(ArkInventoryRules, "OnInitialize", BG.InitArkInvFilter) -- [TODO] make sure we only init once
		return
	else
		ArkInventoryRules.Register(BG, "brokergarbage", BG.ArkInventoryFilter, false)
	end
end

--[[ Status Icons
	these indicators need two handlers:
		1) the bag slot was changed by 'the addon', have BG react and update display if needed
		2) BG has changed labels for an item, have 'the addon' update its display
--]]

local function CreateIcon(slot)
	local icon = slot:CreateTexture(nil, 'OVERLAY')
	icon:SetTexture('Interface\\Buttons\\UI-GroupLoot-Coin-Up')
	icon:SetPoint('TOPLEFT', 2, -2)
	icon:SetSize(16, 16)

  	slot.scrapIcon = icon
	return icon
end
local function UpdateJunkIcon(button, container, slot)
	if not BG_GlobalDB.showBagnonSellIcons then
		if button.scrapIcon and button.scrapIcon:IsShown() then
			button.scrapIcon:Hide()
		end
		return
	end
	local icon = button.scrapIcon or CreateIcon(button)
	icon:Hide()

	local location = BG.GetLocation(container, slot)
	local cacheData = BG.containers[location]
	if cacheData.item then
		if cacheData.sell then
			if cacheData.label == BG.DISENCHANT then
				icon:SetVertexColor(1, 0.2, 1)
				icon:SetDesaturated(true)
			else
				icon:SetVertexColor(1, 1, 1)
				icon:SetDesaturated(false)
			end
			icon:Show()
		end
	end
end

-- Bagnon
if IsAddOnLoaded("Bagnon") then
	hooksecurefunc(Bagnon.ItemSlot, "Update", function(self, ...)
		UpdateJunkIcon(self, self:GetBag(), self:GetID())
	end)
	hooksecurefunc(BG, "Scan", function()
		Bagnon:UpdateFrames()
	end)
end

-- ElvUI
if IsAddOnLoaded("ElvUI") then
	local ElvUISetup = false
	local bagsModule = ElvUI[1]:GetModule('Bags')
	if bagsModule then
		hooksecurefunc(bagsModule, "UpdateSlot", function(containerFrame, bagID, slotID)
			local button = containerFrame.Bags and containerFrame.Bags[bagID] and containerFrame.Bags[bagID][slotID]
			if not button then return end
			UpdateJunkIcon(button, bagID, slotID)

			if not ElvUISetup then
				hooksecurefunc(BG, "Scan", function()
					containerFrame:UpdateAllSlots()
				end)
				ElvUISetup = true
			end
		end)
	end
end
