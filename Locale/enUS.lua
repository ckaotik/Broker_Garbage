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
	itemDeleted = "%1$sx%2$d has been deleted.",
	couldNotRepair = "Could not repair because you don't have enough money. You need %s.",
	
	listsUpdatedPleaseCheck = "Your lists have been updated. Please have a look at your settings and check if they fit your needs.",
	slashCommandHelp = "The following commands are available: |cffc0c0c0/garbage|r\n"..
		"|cffc0c0c0config|r opens the options panel.\n"..
		"|cffc0c0c0format |cffc0c0ffformatstring|r lets you customize the LDB display text, |cffc0c0c0 format reset|r resets it.\n"..
		"|cffc0c0c0limit |cffc0c0ffitemLink/ID count|r sets a limit for the given item on the current character.\n"..
		"|cffc0c0c0globallimit |cffc0c0ffitemLink/ID count|r sets a limit for all characters.\n"..
		"|cffc0c0c0value |cffc0c0ffvalueInCopper|r sets the minimum value for items to be looted (Loot Manager needed).",
	minValueSet = "Items with a value less than %s will not be looted anymore.",
	
	warningMessagePrefit = "Warning",
	
	-- Tooltip
	headerRightClick = "Right-Click for options",
	headerShiftClick = "SHIFT-Click: Destroy",
	headerCtrlClick = "CTRL-Click: Keep",
	moneyLost = "Money Lost:",
	moneyEarned = "Money Earned:",
	noItems = "No items to delete.",
	increaseTreshold = "Increase quality treshold",
	
	categoriesHeading = "Categories",
	unknownAuctionAddon = "Unknown/None",
	LPTNotLoaded = "LibPeriodicTable not loaded",
	
	autoSellTooltip = "Sell Items for %s",
	reportNothingToSell = "Nothing to sell!",
	
	-- Statistics Frame
	StatisticsHeading = "Statistics, everone needs them!\n"..
		"To delete any part of them, click the red x.",
	
	LPTNoticeText = "|cffFF6600You don't seem to have LibPeriodicTable loaded. You will not be able to use category strings, but the addon should work just fine - with a few features less.|r",
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
	
	AuctionAddon = "Auction addon",
	AuctionAddonUnknown = "Unknown/None",
	
	-- Basic Options Frame
	BasicOptionsTitle = "Basic Options",
	BasicOptionsText = "Don't want to auto-sell/repair? "..
		"Hold Shift (depending on your settings) when adressing the merchant!",
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
	
	dropQualityTitle = "Quality Treshold",
	dropQualityText = "Select up to which treshold items may be listed as deletable. Default: Poor (0)",
	
	moneyFormatTitle = "Money Format",
	moneyFormatText = "Change the way money (i.e. gold/silver/copper) is being displayed. Default: 2",
	
	maxItemsTitle = "Max. Items",
	maxItemsText = "Set how many lines you would like to have displayed in the tooltip. Default: 9",
	
	maxHeightTitle = "Max. Height",
	maxHeightText = "Set the height of the tooltip. Default: 220",
	
	sellNotUsableTitle = "Sell gear",
	sellNotUsableText = "Check this to have Broker_Garbage sell all soulbound gear that you cannot wear.\n(Only applies if not an enchanter)",
	
	SNUMaxQualityTitle = "Max. Quality",
	SNUMaxQualityText = "Select the maximum quality to sell when 'Sell gear' is checked.",
	
	enchanterTitle = "Enchanter",
	enchanterTooltip = "Check this if you have/know an enchanter. When checked, Broker_Garbage will use disenchant values for disenchantable items, which are usually higher than vendor prices.",
	
	rescanInventory = "Rescan Inventory",
	rescanInventoryText = "Click to manually rescan you inventory. Should generally not be needed.",
	
	defaultListsText = "Create default lists",
	defaultListsTooltip = "Click to manually create default local list entries. Right-Click to also create default global lists.",
	
	DKTitle = "Temp. disable key",
	DKTooltip = "Set a key to temporarily disable BrokerGarbage.",
	disableKeys = {
		["None"] = "None",
		["SHIFT"] = "SHIFT",
		["ALT"] = "ALT",
		["CTRL"] = "CTRL",
	},
	
	LDBDisplayTextTitle = "LDB Display texts",
	LDBDisplayTextTooltip = "Use this to change the text you see in your LDB display.",
	LDBDisplayTextResetTooltip = "Reset LDB string to default value.",
	LDBNoJunkTextTooltip = "Use this to change the text you see when there is no junk to be displayed.",
	LDBNoJunkTextResetTooltip = "Reset 'No Junk' text to default value.",
	LDBDisplayTextHelpTooltip = "Format string help:\n"..
		"[itemname] - item link\n"..
		"[itemcount] - item count\n"..
		"[itemvalue] - item value\n"..
		"[freeslots] - free bag slots\n"..
		"[totalslots] - total bag slots\n"..
		"[junkvalue] - total autosell value\n"..
		"[bagspacecolor]...[endcolor] to colorize",
	
	-- List Options Panel
	LOPTitle = "Whitelist",
	LOPSubTitle = "To add Items to lists, drag them over the corresponding '+' icon, to remove them select them and click the '-'. To add categories right-click on '+'.",
		
		-- Exclude List
	LOPExcludeHeader = "Exclude List - these items will never be sold/deleted.",
	LOPExcludePlusTT = "Add items to the Exclude List by dragging/placing them on me. Right click on me for categories!",
	LOPExcludeMinusTT = "Select items you want to remove, then click here.",
	LOPExcludePromoteTT = "Selected items will be written onto your global Exclude List, as seen by every character.",
	LOPExcludeEmptyTT = "|cffff0000Caution! Click to empty your local Exclude List.\n"..
		"SHIFT-Click to empty your global Exclude List.",
	
		-- Force Vendor Price List
	LOPForceHeader = "Vendor Price List - These items will only have their vendor price considered.",
	LOPForcePlusTT = "Add items to the Exclude List by dragging/placing them on me. Right click on me for categories!",
	LOPForceMinusTT = "Select items you want to remove, then click here.",
	LOPForcePromoteTT = "The Vendor Price List is already global and effects every character.",
	LOPForceEmptyTT = "|cffff0000Caution! SHIFT-Click to empty your Vendor Price List.",
	
	-- AutoSell Options Panel
	LONTitle = "Blacklist",
	LONSubTitle = "Similar usage to Positive Lists. To set an item limit, use your mousewheel when over the item icon.",
	
		-- Include List
	LONIncludeHeader = "Include List - items will be shown first and not be looted by the Loot Manager.",
	LONIncludePlusTT = "Add items to the Exclude List by dragging/placing them on me. Right click on me for categories!",
	LONIncludeMinusTT = "Select items you want to remove, then click here.",
	LONIncludePromoteTT = "Selected items will be written onto your global Include List, as seen by every character.",
	LONIncludeEmptyTT = "|cffff0000Caution! Click to empty your local Include List.\n"..
		"SHIFT-Click to empty your global Include List.",
		
	LONIncludeAutoSellText = "Automatically sell include list items",
	LONIncludeAutoSellTooltip = "Check this to sell items on your include list when at a merchant.\nItems without a value will be ignored.",
	
		-- Auto Sell List
	LONAutoSellHeader = "Sell List - These items will be sold automatically when at a vendor.",
	LONAutoSellPlusTT = "Add items to the Exclude List by dragging/placing them on me. Right click on me for categories!",
	LONAutoSellMinusTT = "Select items you want to remove, then click here.",
	LONAutoSellPromoteTT = "Selected items will be written onto your global Sell List, as seen by every character.",
	LONAutoSellEmptyTT = "|cffff0000Caution! Click to empty your local Sell List.\n"..
		"SHIFT-Click to empty your global Sell List.",
	
	-- LibPeriodicTable category testing
	PTCategoryTest = "Test category strings",
	PTCategoryTestTitle = "LibPeriodicTable Category String Test",
	PTCategoryTestSubTitle = "If you're unsure why an item shows up as it does or which items are included in which category, you can test that here.",
	PTCategoryTestExplanation = "Simply select a category below and it will display all items in your inventory that match this category.\nCategory information comes from LPT and not Broker_Garbage.",
	PTCategoryTestDropdownTitle = "Category to check",
	PTCategoryTestDropdownText = "Choose a category string",
}