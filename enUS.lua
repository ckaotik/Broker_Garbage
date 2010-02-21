-- enUS / enGB / default localization file
_, BrokerGarbage = ...



BrokerGarbage.locale = {
	label = "Junk, be gone!",
	
	-- Chat Messages
	sellAndRepair = "Sold trash for %1$s, repaired for %2$s. Change: %3$s.",
	repair = "Repaired for %s.",
	sell = "Sold trash for %s.",
	
	addedToSaveList = "%s has been added to the save list.",
	addedToPriceList = "%s will only have its vendor price considered.",
	addedToIncludeList = "%s has been added to the Include List.",
	addedToSellList = "%s will be automatically sold when at a merchant.",
	itemDeleted = "%s has been deleted.",
	
	openPlease = "Please open your %s. It's in your bags, stealing your space!",
	slashCommandHelp = "Use |cffc0c0c0/garbage config|r to open the config menu or |cffc0c0c0/garbage format |cc0c0c0ffformatstring|r to change the LDB display style or |cffc0c0c0/garbage format reset|r to reset it. For statistics type |cffc0c0c0/garbage stats|r.",
	statistics = "Statistics:\nTotal earnings (all characters): %1$s\nTotal losses (all characters): %2$s",
	
	-- Tooltip
	headerRightClick = "Right-Click for options",
	headerShiftClick = "SHIFT-Click: Destroy",
	headerCtrlClick = "CTRL-Click: Keep",
	moneyLost = "Money Lost:",
	moneyEarned = "Money Earned:",
	noItems = "No items to delete.",
	increaseTreshold = "Increase quality treshold",
	
	autoSellTooltip = "Sell gray items",
	reportNothingToSell = "Nothing to sell!",
	
	-- Options Frame
	subTitle = "Don't want to auto-sell/repair? \nHold Shift when adressing the merchant!",
	autoSellTitle = "Auto Sell",
	autoSellText = "Toggles whether to automatically sell your gray items when at a vendor.",
	
	showAutoSellIconTitle = "Show Icon",
	showAutoSellIconText = "Toggles whether to show an icon to manually auto-sell when at a vendor.",
	
	showNothingToSellTitle = "'Nothing to sell'",
	showNothingToSellText = "Toggles whether to show a notice when at a vendor and there is nothing to sell.",
	
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
	LOPTitle = "Positive Lists",
	LOPSubTitle = "To add Items to lists, drag them over the corresponding '+' icon, to remove them select them and click the '-'.",
		
		-- Exclude List
	LOPExcludeHeader = "Exclude List - these items will never be sold/deleted.",
	LOPExcludePlusTT = "Add items to the Exclude List by dragging/placing them on me!",
	LOPExcludeMinusTT = "Select items you want to remove, then click here.",
	LOPExcludePromoteTT = "Selected items will be written onto your global Exclude List, as seen by every character.",
	LOPExcludeEmptyTT = "Click to fully empty your local Exclude List.\n|cffff0000Caution!",
	
		-- Force Vendor Price List
	LOPForceHeader = "Vendor Price List - These items will only have their vendor price considered.",
	LOPForcePlusTT = "Add items to the Vendor Price List by dragging/placing them on me!",
	LOPForceMinusTT = "Select items you want to remove, then click here.",
	LOPForcePromoteTT = "The Vendor Price List is already global and effects every character.",
	LOPForceEmptyTT = "Click to fully empty your Vendor Price List.\n|cffff0000Caution!",
	
	-- AutoSell Options Panel
	LONTitle = "Negative Lists",
	LONSubTitle = "To add Items to lists, drag them over the corresponding '+' icon, to remove them select them and click the '-'.",
	
		-- Include List
	LONIncludeHeader = "Include List - these items will shown first in the tooltip.",
	LONIncludePlusTT = "Add items to your Include List by dragging/placing them on me!",
	LONIncludeMinusTT = "Select items you want to remove, then click here.",
	LONIncludePromoteTT = "Selected items will be written onto your global Include List, as seen by every character.",
	LONIncludeEmptyTT = "Click to fully empty your local Include List.\n|cffff0000Caution!",
	
		-- Auto Sell List
	LONAutoSellHeader = "Sell List - These items will me automatically sold when at a vendor.",
	LONAutoSellPlusTT = "Add items to your Sell List by dragging/placing them on me!",
	LONAutoSellMinusTT = "Select items you want to remove, then click here.",
	LONAutoSellPromoteTT = "Selected items will be written onto your global Sell List, as seen by every character.",
	LONAutoSellEmptyTT = "Click to fully empty your local Sell List.\n|cffff0000Caution!",
	
	-- LibPeriodicTable texts
	PTCategoryTooltipHeader = "Add Categories",
	PTCategoryTooltipText = "Navigate through this menu and add any of these categories by clicking on them."
}

