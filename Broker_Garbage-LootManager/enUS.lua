-- enUS / enGB / default localization file
local _, addon = ...
local L = {}
addon.locale = L

-- if GetLocale() == "enUS" then

	L['enableName'] = 'Enable'
	L['enableDesc'] = 'Select situations when the LootManager should take action.'
	-- ------------------------------------
	L['generalName'] = 'General'
	L['generalDesc'] = 'Enable whenever a loot window is shown.\nChecking this overrides all other options.'
	L['skinningName'] = '|TInterface\\Icons\\inv_misc_pelt_wolf_01:0|t Skinning'
	L['skinningDesc'] = 'Enable when the target can be skinned.'
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

-- end
