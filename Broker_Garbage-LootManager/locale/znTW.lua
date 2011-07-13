-- chinese localization file by a9012456 @Curse.com and google ;)
local _, BGC = ...

if GetLocale() == "zhTW" then
	BGC.locale.CreatureTypeBeast = "野獸"
	BGC.locale.GlobalSetting = "\n|cffffff9aThis setting is global."
	
	-- Chat Messages
	BGC.locale.couldNotLootValue = "沒有捨取%s，因為太便宜。"
	-- BGC.locale.couldNotLootCompareValue = "Did not loot %s. It's cheaper than all we've got. Inventory is full!"
	-- BGC.locale.couldNotLootBlacklist = "Did not loot %s because it's on your Junk List."
	BGC.locale.couldNotLootLocked = "無法捨取%s，因為它被鎖定。請手動捨取。"
	BGC.locale.couldNotLootSpace = "無法捨取%s，因為你的背包滿了。"
	BGC.locale.couldNotLootLM = "%s沒有被捨取。你是Loot Master所以請手動分配。"
	
	-- BGC.locale.errorInventoryFull = "Something was not looted because your inventory is full. Please loot manually!"
	
	-- Loot Manager
	-- BGC.locale.LMTitle = "Loot Manager"
	-- BGC.locale.LMSubTitle = "The Loot Manager can take control of your looting and inventory space."
	
	-- BGC.locale.GroupLooting = "Looting"
	-- BGC.locale.GroupInventory = "Inventory"
	-- BGC.locale.GroupNotices = "Notices"
	-- BGC.locale.GroupTreshold = "Tresholds"
	
	-- BGC.locale.LMEnableInCombatTitle = "Enable in combat"
	-- BGC.locale.LMEnableInCombatTooltip = "If checked, Broker_Garbage will try to loot even if you're in combat.\n|cffff0000Caution|r: This may cause 'Addon Blocked' issues."
	
	BGC.locale.LMAutoLootTitle = "自動捨取"
	BGC.locale.LMAutoLootTooltip = "如果未勾選，Broker_Garbage就只會在特別場合捨取。"
	
	BGC.locale.LMAutoLootSkinningTitle = "皮膚"
	BGC.locale.LMAutoLootSkinningTooltip = "如果勾選，Broker_Garbage將不會捨取如果創造物是由你一個可更換皮膚。"
	
	BGC.locale.LMAutoLootPickpocketTitle = "偷竊"
	BGC.locale.LMAutoLootPickpocketTooltip = "如果勾選，Broker_Garbag將捨取如果你是盜賊和和潛行。"
	
	BGC.locale.LMAutoLootFishingTitle = "釣魚"
	BGC.locale.LMAutoLootFishingTooltip = "如果勾選，Broker_Garbage將捨取如果你正在釣魚。"
	
	-- BGC.locale.LMAutoAcceptLootTitle = "Auto-Confirm BoP"
	-- BGC.locale.LMAutoAcceptLootTooltip = "Check to automatically confirm loot that is BoP."
	
	-- BGC.locale.LMCloseLootTitle = "Close Window"
	-- BGC.locale.LMCloseLootTooltip = "Check to automatically close the loot window once no interesting items are left inside.\n|cffff0000Caution|r: This may interfere with other addons."
	
	-- BGC.locale.LMForceClearTitle = "Force Clearing Mobs"
	-- BGC.locale.LMForceClearTooltip = "Check to clear mobs (even if you aren't a skinner). You may loose money with this setting!"
	
	BGC.locale.LMAutoDestroyTitle = "自動摧毀"
	BGC.locale.LMAutoDestroyTooltip = "如果勾選，Broker_Garbage將會採取行動當你背包空間(幾乎)滿。"
	
	BGC.locale.LMAutoDestroyInstantTitle = "立刻"
	BGC.locale.LMAutoDestroyInstantTooltip = "如果勾選，Broker_Garbage將會刪除超額物品捨取東西那時刻。如果沒勾選，刪除將會代替你是我們的空間。"
	
	BGC.locale.LMFreeSlotsTitle = "最小釋放槽"
	BGC.locale.LMFreeSlotsTooltip = "設定釋放槽最小數字來自動作摧毀。"
	
	BGC.locale.LMWarnLMTitle = "Loot Master"
	BGC.locale.LMWarnLMTooltip = "當已勾選時，Broker_Garbage將會印出一個通知提醒你分配捨取。"
	
	-- BGC.locale.LMWarnInventoryFullTitle = "Inventory Full"
	-- BGC.locale.LMWarnInventoryFullTooltip = "Check to have Broker_Garbage display a chat message whenever the 'Inventory is full.' error triggers."
	
	-- BGC.locale.printValueTitle = "Is below treshold"
	-- BGC.locale.printValueText = "Check to get a chat message whenever Broker_Garbage doesn't loot an item due to its value being less than the minimum loot value (see below)."
	
	-- BGC.locale.printCompareValueTitle = "Is too cheap"
	-- BGC.locale.printCompareValueText = "Check to get a chat message whenever Broker_Garbage doesn't loot an item because it is less valuable than all you've already got."
	
	-- BGC.locale.printJunkTitle = "Is on Junk List"
	-- BGC.locale.printJunkText = "Check to get a chat message whenever Broker_Garbage doesn't loot an item because it is on your junk list."
	
	-- BGC.locale.printSpaceTitle = "Out of space"
	-- BGC.locale.printSpaceText = "Check to get a chat message whenever Broker_Garbage doesn't loot an item because your bags are full and auto destroy is disabled."
	
	-- BGC.locale.printLockedTitle = "Is Locked"
	-- BGC.locale.printLockedText = "Check to get a chat message whenever Broker_Garbage doesn't loot an item because it is locked (e.g. someone else already loots this)."
		
	BGC.locale.LMItemMinValue = "最小物品價值"
end