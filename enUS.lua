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
	limitSet = "%s has been assigned a limit of %d.",
	itemDeleted = "%s has been deleted.",
	
	openPlease = "Please open your %s. It's in your bags, stealing your space!",
	openClams = "You own a %s. Maybe consider opening it.",
	couldNotLootValue = "Did not loot %s because it's too cheap.",
	couldNotLootLocked = "Could not loot %s because it is locked. Please loot manually.",
	couldNotLootSpace = "Could not loot %s because your inventory is full.",
	couldNotLootLM = "%s was not looted. You are the Loot Master so please distrivute the item manually.",
	slashCommandHelp = "The following commands are available: |cffc0c0c0/garbage|r\n|cffc0c0c0 config|r opens the options panel.\n|cffc0c0c0format |cffc0c0ffformatstring|r lets you customize the LDB display text, |cffc0c0c0 format reset|r resets it.\n|cffc0c0c0stats|r returns some statistics.\n|cffc0c0c0limit |cffc0c0ffitemLink/ID count|r sets a limit for the given item on the current character.\n|cffc0c0c0globallimit |cffc0c0ffitemLink/ID count|r sets a limit for all characters.\n|cffc0c0c0value |cffc0c0ffvalueInCopper|r sets the minimum value for items to be looted.",
	statistics = "Statistics:\nTotal earnings (all characters): %1$s\nTotal losses (all characters): %2$s",
	minValueSet = "Items with a value less than %s will not be looted anymore.",
	
	-- Tooltip
	headerRightClick = "Right-Click for options",
	headerShiftClick = "SHIFT-Click: Destroy",
	headerCtrlClick = "CTRL-Click: Keep",
	moneyLost = "Money Lost:",
	moneyEarned = "Money Earned:",
	noItems = "No items to delete.",
	increaseTreshold = "Increase quality treshold",
	
	autoSellTooltip = "Sell Items for %s",
	reportNothingToSell = "Nothing to sell!",
	
	-- Statistics Frame
	StatisticsHeading = "Statistics, everone needs them!\nTo delete any part of them, click the red x.",
	
	MemoryUsageText = "Please notice that especially after scanning your inventory the memory usage goes up a lot. It will automatically be reduced once the garbage collector kicks in.",
	MemoryUsageTitle = "Memory Usage (kB)",
	CollectMemoryUsageTooltip = "Click to start the garbage collection (Blizzard function).",
	
	GlobalStatisticsHeading = "Global Money statistics:",
	AverageSellValueTitle = "Average sell value",
	AverageDropValueTitle = "Average drop value",
	
	GlobalMoneyEarnedTitle = "Total amount earned",
	ResetGlobalMoneyEarnedTooltip = "Click to reset your (global) money earned data.",
	GlobalMoneyLostTitle = "Total amount lost",
	ResetGlobalMoneyLostTooltip = "Click to reset your (global) money lost data.",
	
	GlobalItemsSoldTitle = "Items sold",
	ResetGlobalItemsSoldTooltip = "Click to reset the number of items you sold so far.",
	ItemsDroppedTitle = "Items dropped",
	ResetGlobalItemsDroppedTooltip = "Click to reset the number of items you dropped so far.",
	
	LocalStatisticsHeading = "%s's statistics:",
	StatisticsLocalAmountEarned = "Amount earned",
	ResetLocalMoneyEarnedTooltip = "Click to reset your (local) money earned data.",
	StatisticsLocalAmountLost = "Amount lost",
	ResetLocalMoneyLostTooltip = "Click to reset your (local) money lost data.",
	
	ResetGlobalDataText = "Reset Global Statistics",
	ResetGlobalDataTooltip = "Click here to reset alls global statistics.",
	ResetLocalDataText = "Reset Local Statistics",
	ResetLocalDataTooltip = "Click here to reset all local statistics.",
	
	-- Basic Options Frame
	BasicOptionsTitle = "Basic Options",
	BasicOptionsText = "Don't want to auto-sell/repair? \nHold Shift when adressing the merchant!",
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
	
	enchanterTitle = "Enchanter",
	enchanterTooltip = "Check this if you have/know an enchanter. When checked, Broker_Garbage will use disenchant values for disenchantable items, which are usually higher than vendor prices.",
	
	rescanInventory = "Rescan Inventory",
	rescanInventoryText = "Click to manually rescan you inventory. Should generally not be needed.",
	
	emptyExcludeList = "Empty Exclude List",
	emptyExcludeListText = "Click to clear your exclude list.",
	
	emptyIncludeList = "Empty Include List",
	emptyIncludeListText = "Click to clear your include list.",
	
	LDBDisplayTextTitle = "LDB Display text:",
	LDBDisplayTextHelpTooltip = "Format string help:\n%1$s - item link\n%2$s - item count\n%3$s - item value\n%4$d - free bag slots\n%5$d - total bag slots",
	LDBDisplayTextResetTooltip = "Reset LDB string to default value.",
	
	-- List Options Panel
	LOPTitle = "Positive Lists",
	LOPSubTitle = "To add Items to lists, drag them over the corresponding '+' icon, to remove them select them and click the '-'. To add categories right-click on '+'.",
		
		-- Exclude List
	LOPExcludeHeader = "Exclude List - these items will never be sold/deleted.",
	LOPExcludePlusTT = "Add items to the Exclude List by dragging/placing them on me. Right click on me for categories!",
	LOPExcludeMinusTT = "Select items you want to remove, then click here.",
	LOPExcludePromoteTT = "Selected items will be written onto your global Exclude List, as seen by every character.",
	LOPExcludeEmptyTT = "Click to fully empty your local Exclude List.\n|cffff0000Caution!",
	
		-- Force Vendor Price List
	LOPForceHeader = "Vendor Price List - These items will only have their vendor price considered.",
	LOPForcePlusTT = "Add items to the Exclude List by dragging/placing them on me. Right click on me for categories!",
	LOPForceMinusTT = "Select items you want to remove, then click here.",
	LOPForcePromoteTT = "The Vendor Price List is already global and effects every character.",
	LOPForceEmptyTT = "Click to fully empty your Vendor Price List.\n|cffff0000Caution!",
	
	-- AutoSell Options Panel
	LONTitle = "Negative Lists",
	LONSubTitle = "Similar usage to Positive Lists. To set an item limit, use your mousewheel when over the item icon.",
	
		-- Include List
	LONIncludeHeader = "Include List - items will be shown first and not be looted by the Loot Manager.",
	LONIncludePlusTT = "Add items to the Exclude List by dragging/placing them on me. Right click on me for categories!",
	LONIncludeMinusTT = "Select items you want to remove, then click here.",
	LONIncludePromoteTT = "Selected items will be written onto your global Include List, as seen by every character.",
	LONIncludeEmptyTT = "Click to fully empty your local Include List.\n|cffff0000Caution!",
	
		-- Auto Sell List
	LONAutoSellHeader = "Sell List - These items will be sold automatically when at a vendor.",
	LONAutoSellPlusTT = "Add items to the Exclude List by dragging/placing them on me. Right click on me for categories!",
	LONAutoSellMinusTT = "Select items you want to remove, then click here.",
	LONAutoSellPromoteTT = "Selected items will be written onto your global Sell List, as seen by every character.",
	LONAutoSellEmptyTT = "Click to fully empty your local Sell List.\n|cffff0000Caution!",
	
	-- LibPeriodicTable texts
	PTCategoryTooltipHeader = "Add Categories",
	PTCategoryTooltipText = "Navigate through this menu and add any of these categories by clicking on them.",
	
	-- Loot Manager
	CreatureTypeBeast = "Beast",
	You = "You",			-- as in "You receive ..."
	
	LMTitle = "Loot Manager",
	LMSubTitle = "The Loot Manager takes control of your looting if you want it to do so.\nIf you usually autoloot, hold down SHIFT for a while when looting a corpse to disable it once.",
	
	LMEnableTitle = "Enable Loot Manager",
	LMEnableTooltip = "Check to enable the Loot Manager.",
	
	LMSelectiveTitle = "Selective Looting",
	LMSelectiveTooltip = "Check to let Broker_Garbage determine which items to loot.",
	
	LMAutoLootTitle = "Autoloot",
	LMAutoLootTooltip = "If unchecked, Broker_Garbage will only loot on special occations.",
	
	LMAutoLootSkinningTitle = "Skinning",
	LMAutoLootSkinningTooltip = "If checked, Broker_Garbage will loot if the creature is skinnable by you.",
	
	LMAutoLootPickpocketTitle = "Pickpocket",
	LMAutoLootPickpocketTooltip = "If checked, Broker_Garbage will loot if you are a Rogue and stealthed.",
	
	LMAutoLootFishingTitle = "Fishing",
	LMAutoLootFishingTooltip = "If checked, Broker_Garbage will loot if you are currently fishing.",
	
	LMAutoDestroyTitle = "Autodestroy",
	LMAutoDestroyTooltip = "If checked, Broker_Garbage will take actions when your inventory space is (almost) full.",
	
	LMFreeSlotsTitle = "Minimum free slots",
	LMFreeSlotsTooltip = "Set the minimum numer of free slots for autodestroy to take action.",
	
	LMRestackTitle = "Automatic restack",
	LMRestackTooltip = "Check to automatically compress your watched inventory items after looting.",
	
	LMFullRestackTitle = "Full inventory",
	LMFullRestackTooltip = "When checked will look at your whole inventory for restackable items, not just the watched items.",
	
	LMOpenContainersTitle = "Warn: Containers",
	LMOpenContainersTooltip = "When checked, Broker_Garbage will warn you when you have unopened containers in you inventory.",
	
	LMOpenClamsTitle = "Warn: Clams",
	LMOpenClamsTooltip = "When checked, Broker_Garbage will warn you when you have clams in you inventory. As these now do stack, you are not wasting any slots by unchecking this.",
	
	LMWarnLMTitle = "Warn: Loot Master",
	LMWarnLMTooltip = "When checked, Broker_Garbage will print a notice reminding you to assign loot.",
	
	LMItemMinValue = "Minimum item value",
}

