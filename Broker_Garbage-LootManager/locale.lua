-- enUS / enGB / default localization file
local addonName, addon, _ = ...
local L = LibStub('AceLocale-3.0'):NewLocale(addonName, 'enUS', true)

L['enableName'] = 'Enable'
L['enableDesc'] = 'Select situations when the LootManager should take action.'
-- ------------------------------------
L['generalName'] = 'General'
L['generalDesc'] = 'Enable whenever a loot window is shown'
L['skinningName'] = '|TInterface\\Icons\\inv_misc_pelt_wolf_01:0|t Skinning'
L['skinningDesc'] = 'Enable target can be skinned.'
L['fishingName'] = '|TInterface\\Icons\\Trade_Fishing:0|t Fishing'
L['fishingDesc'] = 'Enable when reeling in fish.'
L['pickpocketName'] = '|TInterface\\Icons\\INV_Misc_Bag_11:0|t Pickpocket'
L['pickpocketDesc'] = 'Enable when emptying others\' pockets'

L['lootTreasureName'] = 'Loot treasures'
L['lootTreasureDesc'] = 'Loot items classified as treasure, even when their value is low.'
L['ignoreJunkName'] = 'Ignore junk'
L['ignoreJunkDesc'] = 'Never pick up items classified as junk.'
L['confirmBindName'] = 'Confirm Pickup'
L['confirmBindDesc'] = 'Confirm “Bind on Pickup” requests.'
L['minValueName'] = 'Minimum item value'
L['minValueDesc'] = 'Items below this value will not be automatically looted.'
L['minQualityName'] = 'Minimum item quality'
L['minQualityDesc'] = 'Items below this quality will not be automatically looted.'

L['notifyName'] = 'Notification Settings'
L['notifyDesc'] = 'Select when to send chat notifications.'
-- ------------------------------------
L['lockedName'] = 'Locked'
L['lockedDesc'] = 'Item is locked.'
L['lootRollName'] = 'Active Roll'
L['lootRollDesc'] = 'Item is still being rolled for.'
L['valueName'] = 'Low value'
L['valueDesc'] = 'Item value is below threshold.'
L['qualityName'] = 'Poor quality'
L['qualityDesc'] = 'Item quality is below threshold.'
-- ------------------------------------
L['%s is locked.'] = true
L['%s is still being rolled for.'] = true
L['%s is of poor quality.'] = true
L['%s is worthless.'] = true

local L = LibStub('AceLocale-3.0'):NewLocale(addonName, 'deDE')
--@localization(locale='deDE', format='lua_additive_table', namespace='LootManager', handle-unlocalized='ignore')@

local L = LibStub('AceLocale-3.0'):NewLocale(addonName, 'zhTW')
--@localization(locale='zhTW', format='lua_additive_table', namespace='LootManager', handle-unlocalized='ignore')@

local L = LibStub('AceLocale-3.0'):NewLocale(addonName, 'zhCN')
--@localization(locale='zhCN', format='lua_additive_table', namespace='LootManager', handle-unlocalized='ignore')@

local L = LibStub('AceLocale-3.0'):NewLocale(addonName, 'ruRU')
--@localization(locale='ruRU', format='lua_additive_table', namespace='LootManager', handle-unlocalized='ignore')@

local L = LibStub('AceLocale-3.0'):NewLocale(addonName, 'frFR')
--@localization(locale='frFR', format='lua_additive_table', namespace='LootManager', handle-unlocalized='ignore')@

local L = LibStub('AceLocale-3.0'):NewLocale(addonName, 'ptBR')
--@localization(locale='ptBR', format='lua_additive_table', namespace='LootManager', handle-unlocalized='ignore')@

local L = LibStub('AceLocale-3.0'):NewLocale(addonName, 'itIT')
--@localization(locale='itIT', format='lua_additive_table', namespace='LootManager', handle-unlocalized='ignore')@

local L = LibStub('AceLocale-3.0'):NewLocale(addonName, 'koKR')
--@localization(locale='koKR', format='lua_additive_table', namespace='LootManager', handle-unlocalized='ignore')@

local L = LibStub('AceLocale-3.0'):NewLocale(addonName, 'esMX')
--@localization(locale='esMX', format='lua_additive_table', namespace='LootManager', handle-unlocalized='ignore')@

local L = LibStub('AceLocale-3.0'):NewLocale(addonName, 'esES')
--@localization(locale='esES', format='lua_additive_table', namespace='LootManager', handle-unlocalized='ignore')@
