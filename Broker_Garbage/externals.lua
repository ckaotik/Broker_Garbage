local addonName, BG, _ = ...

-- GLOBALS: Broker_Garbage, BG_GlobalDB, BG_LocalDB
local tinsert = table.insert

-- register as a plugin to gain acced to BG's options panel
function BG:RegisterPlugin(name, init)
	if not name or not init then
		BG.Print("Error! Cannot register a plugin without a name and initialize function.")
		return
	end

	tinsert(BG.modules, {
		name = name,
		init = init
	})
	return #BG.modules
end

function BG:GetName()
	return addonName
end

function BG:IsDisabled()
	local disable = BG.disableKey[BG_GlobalDB.disableKey]
	return (disable and disable())
end

function BG:GetVariable(name)
	return BG[name]
end

-- returns the requested option
function BG:GetOption(optionName, global)
	if global == nil then
		return BG_LocalDB[optionName], BG_GlobalDB[optionName]
	elseif global == false then
		return BG_LocalDB[optionName]
	else
		return BG_GlobalDB[optionName]
	end
end

-- writes back an option
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
function BG.ResetOption(name, isGlobal)
	local optionsTable = isGlobal and BG_GlobalDB or BG_LocalDB
	local defaultOptions = isGlobal and BG.defaultGlobalSettings or BG.defaultLocalSettings

	if optionsTable[name] then
		optionsTable[name] = defaultOptions[name]
	end
end

-- resets statistics. global = true -> global, otherwise local
function BG.ResetStatistics(isGlobal)
	BG.ResetOption("moneyEarned", isGlobal)
	BG.ResetOption("moneyLostByDeleting", isGlobal)
	BG.ResetOption("itemsDropped", isGlobal)
	BG.ResetOption("itemsSold", isGlobal)
end

function BG.GetContainerItemClassification(bag, slot)
	local listIndex = BG.GetListIndex(bag, slot)
	if not listIndex then return BG.IGNORE end

	local cheapestItem = BG.cheapestItems[listIndex]
	if not cheapestItem then return BG.IGNORE end

	if cheapestItem.source == BG.IGNORE then
		return cheapestItem.origin or BG.IGNORE
	else
		return cheapestItem.source
	end
end

--[[ Interaction with other addons ]]--
-- ArkInventory + ArkInventoryRules
function BG.ArkInventoryFilter(label)
	if not ArkInventoryRules.Object.h or ArkInventoryRules.Object.class ~= "item" then
		return false
	end
	local bag = ArkInventory.BagID_Blizzard(ArkInventoryRules.Object.loc_id, ArkInventoryRules.Object.bag_id)
	local slot = ArkInventoryRules.Object.slot_id
	label = label and string.upper(label)

	return BG.GetContainerItemClassification(bag, slot) == BG[label]
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

-- Bagnon
local function CreateIcon(slot)
	local icon = slot:CreateTexture(nil, 'OVERLAY')
	icon:SetTexture('Interface\\Buttons\\UI-GroupLoot-Coin-Up')
	icon:SetPoint('TOPLEFT', 2, -2)
	icon:SetSize(16, 16)

  	slot.scrapIcon = icon
	return icon
end
local function UpdateJunkIcon(self, listIndex)
	if not BG_GlobalDB.showBagnonSellIcons then
		if self.scrapIcon and self.scrapIcon:IsShown() then self.scrapIcon:Hide() end
		return
	end
	local icon = self.scrapIcon or CreateIcon(self)
	icon:Hide()

	local item = listIndex and BG.cheapestItems[listIndex]
	if item and not item.invalid then
		if item.sell then
			icon:SetVertexColor(1, 1, 1)
			icon:SetDesaturated(false)
			icon:Show()
		elseif item.origin == BG.DISENCHANT then
			icon:SetVertexColor(1, 0.2, 1)
			icon:SetDesaturated(true)
			icon:Show()
		end
	end
end
-- these indicators need two handlers:
-- 		1) the slot was changed by 'the addon', have BG react and update display if needed
-- 		2) BG has changed labels for an item, have 'the addon' update its display
if IsAddOnLoaded("Bagnon") then
	hooksecurefunc(Bagnon.ItemSlot, "Update", function(self, ...)
		local index = BG.GetListIndex(self:GetBag(), self:GetID())
		UpdateJunkIcon(self, index)
	end)
	hooksecurefunc(BG, "UpdateLDB", function()
		Bagnon:UpdateFrames()
	end)
end
if IsAddOnLoaded("ElvUI") then
	local ElvUISetup = false
	local bagsModule = ElvUI[1]:GetModule('Bags')
	if bagsModule then
		hooksecurefunc(bagsModule, "UpdateSlot", function(containerFrame, bagID, slotID)
			local index = BG.GetListIndex(bagID, slotID)
			local button = containerFrame.Bags and containerFrame.Bags[bagID] and containerFrame.Bags[bagID][slotID]
			if not button then return end
			UpdateJunkIcon(button, index)

			if not ElvUISetup then
				hooksecurefunc(BG, "UpdateLDB", function()
					containerFrame:UpdateAllSlots()
				end)
				ElvUISetup = true
			end
		end)
	end
end

-- external access, for modules etc.
Broker_Garbage = BG
