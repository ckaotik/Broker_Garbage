local addonName, plugin, _ = ...
local L = plugin.locale
local addon = _G.Broker_Garbage

plugin = addon:NewModule('Loot Manager', 'AceEvent-3.0', 'AceTimer-3.0')

-- GLOBALS: _G, LibStub
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
		local isInteresting, alwaysLoot = plugin:IsInteresting(itemLink, count)
		if isInteresting or alwaysLoot then
			_G['LootButton'..index..'IconTexture']:SetDesaturated(false)
			_G['LootButton'..index..'IconTexture']:SetAlpha(1)
		else
			_G['LootButton'..index..'IconTexture']:SetDesaturated(true)
			_G['LootButton'..index..'IconTexture']:SetAlpha(0.5)
		end
	end
end

-- --------------------------------------------------------
--  Addon Setup
-- --------------------------------------------------------
function plugin:OnInitialize()
	_, playerClass = UnitClass('player')
end

local defaults = {
	global = {
		enable = {
			general    = false,
			skinning   = true,
			fishing    = true,
			pickpocket = true,
		},
		lootTreasure = true,
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
function plugin:OnEnable()
	-- initialize database and settings
	self.db = addon.db:RegisterNamespace('LootManager', defaults)
	self:RegisterEvent('LOOT_READY')
	self:RegisterEvent('LOOT_BIND_CONFIRM')

	local types = {
		minValue   = 'money',
		minQuality = 'itemquality',
	}
	local optionsTable = LibStub('LibOptionsGenerate-1.0'):GetOptionsTable(self.db, types, L)
	      optionsTable.name = addon:GetName() .. ' - Loot Manager'
	LibStub('AceConfig-3.0'):RegisterOptionsTable(self.name, optionsTable)
	-- LibStub('AceConfigDialog-3.0'):AddToBlizOptions(self.name, 'Loot Manager', 'Broker_Garbage')

	-- TODO: could also consider LootFrame_InitAutoLootTable
	-- hooksecurefunc('LootFrame_UpdateButton', UpdateLootButton)
	-- TODO: adjust Blizzard's autoloot?
	-- local autoLootBliz = GetCVarBool('autoLootDefault')
	-- SetCVar('autoLootDefault', 0)
end

function plugin:OnDisable()
	self:UnregisterEvent('LOOT_READY')
	self:UnregisterEvent('LOOT_BIND_CONFIRM')
end

-- --------------------------------------------------------
--  Event Handlers
-- --------------------------------------------------------
function plugin:LOOT_BIND_CONFIRM()
	-- TODO
	if not self.db.global.confirmBind then
		self.keepWindowOpen = true
	end
end

function plugin:LOOT_READY(event)
	-- can't compete with Blizzard's autoloot
	if GetCVarBool('autoLootDefault') or addon.IsDisabled() then return end
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
					if self.db.global.notify.locked then
						self:Notify('%s is locked.', itemLink)
					end
				elseif loot.roll then
					if self.db.global.notify.lootRoll then
						self:Notify('%s is still being rolled for.', itemLink)
					end
				elseif loot.quality < self.db.global.minQuality then
					if self.db.global.notify.quality then
						self:Notify('%s is of poor quality.', itemLink)
					end
				elseif value and value > 0 and value < self.db.global.minValue then
					if self.db.global.notify.value then
						self:Notify('%s is worthless.', itemLink)
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
function plugin:Notify(reason, itemLink)
	local message = (L[reason] or reason):format(itemLink)
	addon.Print('[LootManager] '..message)
end

local SKINNING, MINING, HERBALISM = 393, 186, 182
function plugin:CanSkin()
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
function plugin:IsInteresting(item, count)
	local isInteresting, alwaysLoot
	local priority, label, value, sell, reason = addon.GetUnownedItemInfo(item, count)

	if priority == addon.priority.POSITIVE then
		isInteresting = true
		alwaysLoot = self.db.global.lootTreasure
	elseif priority == addon.priority.NEGATIVE and self.db.global.ignoreJunk then
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

-- returns <shouldAutoLoot:true|false>, <clearAll:true|false>
function plugin:ShouldAutoLoot()
	local autoLoot = self.db.global.enable.general
	autoLoot = autoLoot or (self.db.global.enable.fishing and IsFishingLoot())
	autoLoot = autoLoot or (playerClass == 'ROGUE' and IsStealthed() and self.db.global.enable.pickpocket)
	autoLoot = autoLoot or (self.db.global.enable.skinning and self:CanSkin()
		and UnitIsDead('target') and UnitCreatureType('target') == _G.BATTLE_PET_NAME_8)
	return autoLoot
end



-- TODO update and integrate slash command handling
-- TODO: extend BGC.locale.slashCommandHelp

--[[
Broker_Garbage:RegisterSlashCommand('minvalue', function(param)
	param = tonumber(param) or -1
	if param < 0 then
		BGC:Print(BGC.locale.invalidArgument)
		return
	end

	Broker_Garbage_LootManager:Set("itemMinValue", param)
	BGC:Print(format(BGC.locale.minValueSet, Broker_Garbage.FormatMoney(Broker_Garbage:GetOption("itemMinValue", false))))
end , 'value')

Broker_Garbage:RegisterSlashCommand('minfreeslots', function(param)
	param = tonumber(param)
	if not param then
		BGC:Print(BGC.locale.invalidArgument)
		return
	end

	Broker_Garbage_LootManager:Set("tooFewSlots", param, true)
	BGC.Print(format(BGC.locale.minSlotsSet, Broker_Garbage:GetOption("tooFewSlots", false)))
end , {'freeslots', 'minfree', 'slots', 'free'})

--]]
