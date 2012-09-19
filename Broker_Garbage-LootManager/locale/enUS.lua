-- enUS / enGB / default localization file
local _, BGLM = ...
BGLM.locale = {}
local L = BGLM.locale

L["CreatureTypeBeast"] = "Beast"
L["GlobalSetting"] = "\n|cffffff9aThis setting is global."

-- Chat Messages
L["couldNotLootValue"] = "Did not loot %sx%d because it's too cheap."
L["couldNotLootCompareValue"] = "Did not loot %sx%d. It's cheaper than all we've got. Inventory is full!"
L["couldNotLootBlacklist"] = "Did not loot %sx%d because it's on your Junk List."
L["couldNotLootLocked"] = "Could not loot %sx%d because it is locked. Please loot manually."
L["couldNotLootSpace"] = "Could not loot %sx%d, you don't have any space!"
L["couldNotLootLM"] = "You are the Loot Master, please distribute %s manually."

L["errorInventoryFull"] = "Something was not looted because your inventory is full. Please loot manually!"

-- Loot Manager
L["LMTitle"] = "Loot Manager"
L["LMSubTitle"] = "The Loot Manager can take control of your looting and inventory space."

L["GroupLooting"] = "Looting"
L["GroupInventory"] = "Inventory"
L["GroupNotices"] = "Notices"
L["GroupThreshold"] = "Tresholds"

L["LMEnableInCombatTitle"] = "Enable in combat"
L["LMEnableInCombatTooltip"] = "If checked, Broker_Garbage will try to loot even if you're in combat."

L["LMAutoLootTitle"] = "Autoloot"
L["LMAutoLootTooltip"] = "Use this setting or any combination of the settings below to decide how/if Broker_Garbage handles looting."
L["disableBlizzAutoLoot"] = "\n|cffff0000Warning:|r Please disable Blizzard's Auto Loot."

L["LMAutoLootSkinningTitle"] = "Skinning"
L["LMAutoLootSkinningTooltip"] = "Check to loot if you can skin this creature."

L["LMAutoLootPickpocketTitle"] = "Pickpocket"
L["LMAutoLootPickpocketTooltip"] = "Check to loot if you are a Rogue and stealthed."

L["LMAutoLootFishingTitle"] = "Fishing"
L["LMAutoLootFishingTooltip"] = "Check to loot if this is fishing loot."

L["LMAutoAcceptLootTitle"] = "Auto-Confirm BoP"
L["LMAutoAcceptLootTooltip"] = "Check to automatically confirm loot that is BoP."

L["LMCloseLootTitle"] = "Close Window"
L["LMCloseLootTooltip"] = "Check to automatically close the loot window once no interesting items are left inside.\n|cffff0000Caution|r: This may interfere with other addons."

L["LMKeepPLOpenTitle"] = "Keep open when personal"
L["LMKeepPLOpenTooltip"] = "Check this to keep the loot window open when you can't loot something relevant in case you are currently dealing with personal loot (e.g. containers from your inventory, mining nodes)."

L["LMForceClearTitle"] = "Force Clearing Mobs"
L["LMForceClearTooltip"] = "Check to clear mobs (even if you aren't a skinner). You may loose money with this setting!"

L["lootJunkTitle"] = "Loot 'Junk'"
L["lootJunkTooltip"] = "Check to loot items on your 'Junk' list like regular items."

L["lootKeepTitle"] = "Loot 'Keep'"
L["lootKeepTooltip"] = "Check to always loot items on your 'Keep' list"

L["LMAutoDestroyTitle"] = "Autodestroy"
L["LMAutoDestroyTooltip"] = "If checked, Broker_Garbage will take actions when your inventory space is (almost) full."

L["LMAutoDestroyInstantTitle"] = "enforce"
L["LMAutoDestroyInstantTooltip"] = "If checked, Broker_Garbage may delete items the moment it loots them, otherwise deletion will take place only when you find something better to loot and need space."
L["LMAutoDestroy_ErrorNoItems"] = "Error! I tried to make space but there is nothing left for me to delete!"

L["printDebugTitle"] = "Print debug output"
L["printDebugTooltip"] = "Check to display the LootManager's debug information. Tends to spam your chat frame, you have been warned."

L["LMFreeSlotsTitle"] = "Minimum free slots"
L["LMFreeSlotsTooltip"] = "Set the minimum numer of free slots for autodestroy to take action."

L["LMWarnLMTitle"] = "Loot Master"
L["LMWarnLMTooltip"] = "When checked, Broker_Garbage will print a notice reminding you to assign loot."

L["LMWarnInventoryFullTitle"] = "Inventory Full"
L["LMWarnInventoryFullTooltip"] = "Check to have Broker_Garbage display a chat message whenever the 'Inventory is full.' error triggers."

L["printValueTitle"] = "Is below treshold"
L["printValueText"] = "Check to get a chat message whenever Broker_Garbage doesn't loot an item due to its value being less than the minimum loot value (see below)."

L["printCompareValueTitle"] = "Is too cheap"
L["printCompareValueText"] = "Check to get a chat message whenever Broker_Garbage doesn't loot an item because it is less valuable than all you've already got."

L["printJunkTitle"] = "Is on Junk List"
L["printJunkText"] = "Check to get a chat message whenever Broker_Garbage doesn't loot an item because it is on your junk list."

L["printSpaceTitle"] = "Out of space"
L["printSpaceText"] = "Check to get a chat message whenever Broker_Garbage doesn't loot an item because your bags are full and auto destroy is disabled."

L["printLockedTitle"] = "Is Locked"
L["printLockedText"] = "Check to get a chat message whenever Broker_Garbage doesn't loot an item because it is locked (e.g. someone else already loots this)."

L["LMItemMinValue"] = "Min. item value to loot"

L["minLootQualityTitle"] = "Minimum item quality"
L["minLootQualityTooltip"] = "The LootManager will not loot any items below this threshold."
