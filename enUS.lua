-- enUS / enGB / default localization file
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
	moneyEarned = "Money Earned:",
	noItems = "No items to delete.",
	increaseTreshold = "Increase quality treshold",
	
	autoSellTooltip = "Sell gray items.",
	
	-- Options Frame
	subTitle = "Don't want to auto-sell/repair? \nHold Shift when adressing the merchant!",
	autoSellTitle = "Auto Sell",
	autoSellText = "Toggles whether to automatically sell your gray items when at a vendor.",
	
	showAutoSellIconTitle = "Show Icon",
	showAutoSellIconText = "Toggles whether to show an icon to manually auto-sell when at a vendor.",
	
	autoRepairTitle = "Auto Repair",
	autoRepairText = "Toggles whether to automatically repair your gear when at a vendor.",
	
	autoRepairGuildTitle = "No Guild Repair", 
	autoRepairGuildText = "If selected, Broker_Garbage will never try to repair using the guild bank's money",
	
	showLostTitle = "Show Money Lost",
	showLostText = "Toggles whether to show the tooltip line 'Money Lost'.",
	
	showSourceTitle = "Show Source",
	showSourceText = "Toggles whether to show the last column in the tooltip, displaying the item value source.",
	
	showEarnedTitle = "Show Money Earned",
	showEarnedText = "Toggles whether to show the tooltip line 'Money Earned'.",
	
	dropQualityTitle = "Drop Quality",
	dropQualityText = "Select up to which treshold items may be listed as deletable. Default: Poor (0)",
	
	moneyFormatTitle = "Money Format",
	moneyFormatText = "Change the way money (i.e. gold/silver/copper) is being displayed. Default: 2",
	
	maxItemsTitle = "Max. Items",
	maxItemsText = "Set how many lines you would like to have displayed in the tooltip. Default: 9",
	
	maxHeightTitle = "Max. Height",
	maxHeightText = "Set the height of the tooltip. Default: 220",
	
	rescanInventory = "Rescan Inventory",
	rescanInventoryText = "Click to manually rescan you inventory. Should generally not be needed.",
	
	resetMoneyLost = "Reset Money Lost Data",
	resetMoneyLostText = "Click to reset the amount of money lost by deleting items.",
	
	resetMoneyEarned = "Reset Money Earned Data",
	resetMoneyEarnedText = "Click to reset the amount of money earned by auto-selling items.",
	
	emptyExcludeList = "Empty Exclude List",
	emptyExcludeListText = "Click to clear your exclude list.",
	
	emptyIncludeList = "Empty Include List",
	emptyIncludeListText = "Click to clear your include list.",
	
	-- List Options Panel
	LOTitle = "List Options",
	LOSubTitle = "Set up your master lists here. To add Items, drag them over the corresponding '+' icon, to remove them select them and klick the '-'.",
	
	LOExcludeHeader = "Exclude List - these items will never be sold/deleted.",
	LOExcludePlusTT = "Add items to the Exclude List by dragging/placing them on me!",
	LOExcludeMinusTT = "Select items you want to remove, then click here.",
	LOExcludePromoteTT = "Selected items will be written onto your global Exclude List, as seen by every character.",
	LOExcludeEmptyTT = "Click to fully empty your local Exclude List. Caution!",
	
	LOIncludeHeader = "Include List - these items will be suggested to be deleted.",
	LOIncludePlusTT = "Add items to your Include List by dragging/placing them on me!",
	LOIncludeMinusTT = "Select items you want to remove, then click here.",
	LOIncludePromoteTT = "Selected items will be written onto your global Include List, as seen by every character.",
	LOIncludeEmptyTT = "Click to fully empty your local Include List. Caution!",
}