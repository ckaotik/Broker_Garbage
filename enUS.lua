_, BrokerGarbage = ...

BrokerGarbage.locale = {
	label = "Junk, be gone!",
	
	-- Chat Messages
	sellAndRepair = "Sold trash for %1$s, repaired for %2$s. Change: %3$s.",
	repair = "Repaired for %s.",
	sell = "Sold trash for %s.",
	
	addedToSaveList = "%s has been added to the save list.",
	addedToDestroyList = "%s has been added to the destroy list.",
	itemDeleted = "%s has been deleted.",
	
	openPlease = "Please open your %s. It's in your bags, stealing your space!",
	
	-- Tooltip
	headerRightClick = "Right-Click for options",
	headerShiftClick = "SHIFT-Click: Destroy",
	headerCtrlClick = "CTRL-Click: Keep",
	moneyLost = "Money Lost:",
	
	-- Options Frame
	subTitle = "Don't want to auto-sell/repair? \nHold Shift when adressing the merchant!",
	autoSellTitle = "Auto Sell",
	autoSellText = "Toggles whether to automatically sell your gray items when at a vendor.",
	
	autoRepairTitle = "Auto Repair",
	autoRepairText = "Toggles whether to automatically repair your gear when at a vendor.",
	
	autoRepairGuildTitle = "No Guild Repair", 
	autoRepairGuildText = "If selected, Broker_Garbage will never try to repair using the guild bank's money",
	
	dropQualityTitle = "Drop Quality",
	dropQualityText = "Select up to which treshold items may be listed as deletable. Default: Poor (0)",
	
	moneyFormatTitle = "Money Format",
	moneyFormatText = "Change the way money (i.e. gold/silver/copper) is being displayed. Default: 2",
	
	maxItemsTitle = "Max. Items",
	maxItemsText = "Set how many lines you would like to have displayed in the tooltip. Default: 10",
	
	maxHeightTitle = "Max. Height",
	maxHeightText = "Set the height of the tooltip. Default: 220",
	
	rescanInventory = "Rescan Inventory",
	rescanInventoryText = "Click to manually rescan you inventory. Should generally not be needed.",
	
	resetMoneyLost = "Reset Money Lost Data",
	resetMoneyLostText = "Click to reset the amount of money lost by deleting items.",
	
	emptyExcludeList = "Empty Exclude List",
	emptyExcludeListText = "Click to clear your exclude list.",
	
	emptyIncludeList = "Empty Include List",
	emptyIncludeListText = "Click to clear your include list.",
	
	-- List Options Panel
	LOTitle = "List Options",
	LOSubTitle = "Set up your master lists here. To add Items, drag them over the corresponding '+' icon, to remove them select them and klick the '-'.",
	
	LOExcludeHeader = "Exclude List - these items will never be sold/deleted.",
	LOExcludePlusTT = "Add items to the list by dragging/placing them on me!",
	LOExcludeRefreshTT = "Click to refresh the Exclude List display",
	LOExcludeMinusTT = "Select items you want to remove, then click here.",
	LOExcludeEmptyTT = "Click to fully empty your Exclude List. Caution!",
	
	LOIncludeHeader = "Include List - these items will be suggested to be deleted.",
	LOIncludePlusTT = "Add items to the list by dragging/placing them on me!",
	LOIncludeRefreshTT = "Click to refresh the Include List display",
	LOIncludeMinusTT = "Select items you want to remove, then click here.",
	LOIncludeEmptyTT = "Click to fully empty your Include List. Caution!",
}