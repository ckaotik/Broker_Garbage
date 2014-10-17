local addonName, addon, _ = ...
LibStub('AceAddon-3.0'):NewAddon(addon, addonName, 'AceEvent-3.0')
local L = LibStub('AceLocale-3.0'):GetLocale(addonName)

-- GLOBALS: _G, BGLM_GlobalDB, BGLM_LocalDB, Broker_Garbage
-- GLOBALS: GetCVarBool, GetLootInfo, GetLootSlotLink, GetLootSlotInfo, GetLootSlotType, LootSlot, ConfirmLootSlot
-- GLOBALS: GetProfessions, GetProfessionInfo, IsStealthed, IsFishingLoot, UnitClass, UnitIsDead, UnitCreatureType, GetItemInfo
-- GLOBALS: pairs, table, print, select

local playerClass

local function SortLoot(a, b)
	if (a.slotID or a.slot) ~= (b.slotID or b.slot) then
		return (a.slotID or a.slot) < (b.slotID or b.slot)
	elseif (a.clear or a.autoloot) ~= (b.clear or b.autoloot) then
		return a.clear or a.autoloot
	elseif (a.quest or a.isQuestItem) ~= (b.quest or b.isQuestItem) then
		return a.quest or a.isQuestItem
	elseif a.value ~= b.value then
		return a.value > b.value
	else
		return a.value ~= nil
	end
end

local function UpdateLootButton(index)
	local button = index and _G['LootButton'..index]
	if not button or not button:IsShown() then return end

	local slot = button.slot
	local itemLink = GetLootSlotLink(slot)
	if itemLink then
		local _, _, count = GetLootSlotInfo(slot)
		local isInteresting, alwaysLoot = addon:IsInteresting(itemLink, count)
		if isInteresting or alwaysLoot then
			_G["LootButton"..index.."IconTexture"]:SetDesaturated(false)
			_G["LootButton"..index.."IconTexture"]:SetAlpha(1)
		else
			_G["LootButton"..index.."IconTexture"]:SetDesaturated(true)
			_G["LootButton"..index.."IconTexture"]:SetAlpha(0.5)
		end
	end
end

-- --------------------------------------------------------
--  Addon Setup
-- --------------------------------------------------------
function addon:OnInitialize()
	_, playerClass = UnitClass('player')
end

local defaults = {
	profile = {
		enable = {
			general      = false,
			skinning     =  true,
			fishing      =  true,
			pickpocket   =  true,
		},
		lootTreasure =  true,
		ignoreJunk   = false,
		confirmBind  = false,
		minValue     = 0,
		minQuality   = 0,
		notify = {
			locked   = true,
			lootRoll = true,
			value    = true,
			quality  = true,
			-- bagsFull = false,
		},
	},
}
function addon:OnEnable()
	-- initialize database and settings
	self.db = Broker_Garbage.db:RegisterNamespace('LootManager', defaults)
	self:RegisterEvent('LOOT_READY')
	self:RegisterEvent('LOOT_BIND_CONFIRM')

	local dataPath, types = 'Broker_Garbage.db.children.LootManager.profile', {
		minValue   = 'money',
		minQuality = 'itemquality',
	}
	LibStub('AceConfig-3.0'):RegisterOptionsTable(self.name, {
		type = 'group',
		args = {
			main = LibStub('LibOptionsGenerate-1.0'):GetOptionsTable(dataPath, types, L),
		},
	})
	local AceConfigDialog = LibStub('AceConfigDialog-3.0')
	      AceConfigDialog:AddToBlizOptions(self.name, 'Loot Manager', 'Broker_Garbage', 'main')

	-- TODO: could also consider LootFrame_InitAutoLootTable
	-- hooksecurefunc('LootFrame_UpdateButton', UpdateLootButton)
end

function addon:OnDisable()
	self:UnregisterEvent('LOOT_READY')
	self:UnregisterEvent('LOOT_BIND_CONFIRM')
end

-- --------------------------------------------------------
--  Event Handlers
-- --------------------------------------------------------
function addon:LOOT_BIND_CONFIRM()
	-- TODO
	if not self.db.profile.confirmBind then
		self.keepWindowOpen = true
	end
end

function addon:LOOT_READY(event)
	-- can't compete with Blizzard's autoloot
	if GetCVarBool('autoLootDefault') then return end
	local shouldAutoLoot, clearAll = self:ShouldAutoLoot()
	if not shouldAutoLoot then return end

	local lootInfo = GetLootInfo()
	for lootSlot, loot in pairs(lootInfo) do
		-- this data would get lost when sorting table
		loot.slot = lootSlot

		local itemLink = GetLootSlotLink(lootSlot)
		if itemLink then
			local isInteresting, alwaysLoot, value = self:IsInteresting(itemLink, loot.quantity)
			value = value or select(11, GetItemInfo(itemLink))

			if clearAll or alwaysLoot or clearAll or loot.isQuestItem or loot.questId then
				loot.autoloot = true
			elseif isInteresting then
				if loot.locked then
					if self.db.profile.notify.locked then
						self:Notify('Not looting %s because it\'s locked.', itemLink)
					end
				elseif loot.roll then
					if self.db.profile.notify.lootRoll then
						self:Notify('Not looting %s because it\'s still being rolled for.', itemLink)
					end
				elseif loot.quality < self.db.profile.minQuality then
					if self.db.profile.notify.quality then
						self:Notify('Not looting %s because it\'s of poor quality.', itemLink)
					end
				elseif value and value > 0 and value < self.db.profile.minValue then
					if self.db.profile.notify.value then
						self:Notify('Not looting %s because it\'s worthless.', itemLink)
					end
				else
					loot.autoloot = true
				end
			end
			loot.value = value
		elseif GetLootSlotType(lootSlot) ~= _G.LOOT_SLOT_ITEM then
			-- gold coins, currency and archaeology fragments
			loot.autoloot = true
			loot.value = -1
		else
			print('No item link for loot slot', lootSlot, loot.item)
		end
	end

	table.sort(lootInfo, SortLoot)

	for _, loot in pairs(lootInfo) do
		if loot.autoloot then
			LootSlot(loot.slot)
			-- TODO: what about ConfirmLootSlot(loot.slot)
		end
	end
end

-- --------------------------------------------------------
--  Utility Functions
-- --------------------------------------------------------
function addon:Notify(reason, itemLink)
	local message = (L[reason] or reason):format(itemLink)
	Broker_Garbage.Print('[LootManager] '..message)
end

local SKINNING, MINING, HERBALISM = 393, 186, 182
function addon:CanSkin()
	local prof1, prof2 = GetProfessions()
	local name, _, rank, _, _, _, skillLine = GetProfessionInfo(prof1)
	local skillRank = skillLine == SKINNING and rank or nil
	if not skillRank then
		name, _, rank, _, _, _, skillLine = GetProfessionInfo(prof2)
		skillRank = skillLine == SKINNING and rank or nil
	end
	return skillRank and skillRank > 0
end

-- determines if an item should be looted. item: id or link, [count], [lootType]
function addon:IsInteresting(item, count)
	local isInteresting, alwaysLoot
	local priority, label, value, sell, reason = Broker_Garbage.GetUnownedItemInfo(item, count)

	if priority == Broker_Garbage.priority.POSITIVE then
		isInteresting = true
		alwaysLoot = self.db.profile.lootTreasure
	elseif priority == Broker_Garbage.priority.NEGATIVE and self.db.profile.ignoreJunk then
		isInteresting = false
	else
		isInteresting = true
	end

	if alwaysLoot then
		return isInteresting, true,  value
	else
		return isInteresting, false, value
	end
end

-- returns <shouldAL:true|false>, <clearAll:true|false>
function addon:ShouldAutoLoot()
	local autoLoot = self.db.profile.enable.general
	autoLoot = autoLoot or (self.db.profile.enable.fishing and IsFishingLoot())
	autoLoot = autoLoot or (playerClass == 'ROGUE' and IsStealthed() and self.db.profile.enable.pickpocket)
	autoLoot = autoLoot or (self.db.profile.enable.skinning and self:CanSkin()
		and UnitIsDead('target') and UnitCreatureType('target') == _G.BATTLE_PET_NAME_8)
	return autoLoot
end

--[[
-- forceClear = false, -- use Blizzard's autoloot + inventory pruning instead
-- TODO: this is something Broker_Garbage itself needs to do
function addon:ITEM_PUSH(event, arg1, ...)
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

function addon:DeleteCheapestItem(index)
	local item = Broker_Garbage.cheapestItems and Broker_Garbage.cheapestItems[index or 1]
	if item and not item.invalid and item.source ~= Broker_Garbage.IGNORE then
		Broker_Garbage.Delete(item)
		return true
	else
		self:Print(self.locale.LMAutoDestroy_ErrorNoItems)
		return nil
	end
end --]]
