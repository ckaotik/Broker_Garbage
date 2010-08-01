-- enUS / enGB / default localization file
_, BrokerGarbage = ...

BrokerGarbage.locale = {
	label = "Junk, be gone!",
	
	-- Chat Messages
	sellAndRepair = "Sold trash for %1$s, repaired for %2$s. Change: %3$s.",
	repair = "Repaired for %s.",
	sell = "Sold trash for %s.",
	
	addedTo_exclude = "%s has been added to the save list.",
	addedTo_forceVendorPrice = "%s will only have its vendor price considered.",
	addedTo_include = "%s has been added to the Include List.",
	addedTo_autoSellList = "%s will be automatically sold when at a merchant.",
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
	defaultListsText = "Default Lists",
	defaultListsTooltip = "|cffffffffClick|r to manually create default local list entries.\n |cffffffffRight-Click|r to also create default global lists.",
	
	LOTabTitleInclude = "Junk",
	LOTabTitleExclude = "Keep",
	LOTabTitleVendorPrice = "Vendor Price",
	LOTabTitleAutoSell = "Sell",
	
	LOIncludeAutoSellText = "Sell Junk List items",
	LOIncludeAutoSellTooltip = "Check this to automatically sell items on your include list when at a merchant. Items without a value will be ignored.",
	
	LOTitle = "List Options",
	LOSubTitle = "If you need help click the \"?\"-tab.\n\n" .. 
		"|cffffd200Junk|r: Items on this list can be thrown away if needed.\n" ..
		"|cffffd200Keep|r: Items on this list will never be deleted.\n" ..
		"|cffffd200Vendor Price|r: Items only use vendor values. (always global)\n" ..
		"|cffffd200Sell|r: Items on this list will be sold when at a merchant.",
	
	listsBestUse = "|cffffd200List Examples|r\n" .. 
		"Don't forget to use the standard lists! They provide a great example.\n" ..
		"First, put any items you don't want to lose on your |cffffd200Keep List|r. Make good use of categories (see below)! If the LootManager is active it will alwas try to loot these items. \n|cffAAAAAAe.g. class reagents, flasks|r\n" .. 
		"Items which may be thrown away any time belong on the |cffffd200Junk List|r. \n|cffAAAAAAe.g. summoned food & drink, argent lance|r\n" .. 
		"In case you encounter highly overrated items, put them on your |cffffd200Vendor Price List|r. They will only have their vendor value used instead of auction or disenchant values.\n|cffAAAAAAe.g. fish oil|r\n" .. 
		"Put items on your |cffffd200Sell List|r that should be sold when visiting a merchant. \n|cffAAAAAAe.g. water as a warrior, cheese|r",
	
	iconButtonsUse = "|cffffd200Item Buttons|r\n" .. 
		"For any item you'll either see its icon, a gear if it's a category or a question mark in case the server doesn't know this item.\n" .. 
		"In the top left of each button you'll see a \"G\" (or not). If it's there, the item is on your |cffffd200global list|r meaning this rule is effective for every character.\n" .. 
		"Items on your Junk List may also have a |cffffd200limit|r. This will be shown as a small number in the lower right corner. By using the |cffffd200mousewheel|r on this button you can change this number. Limited items will only be dropped/destroyed if you have more than their limit indicates.",
	
	actionButtonsUse = "|cffffd200Action Buttons|r\n" .. 
		"Below this window you'll see five buttons and a search bar.\n" ..
		"|cffffd200Plus|r: Use this to add items to the currently shown list. Simply drag/drop them onto the plus. To add a |cffffd200category|r, right-click the plus and then choose a category. \n|cffAAAAAAe.g. \"Tradeskill > Recipe\", \"Misc > Key\"|r\n" ..
		"|cffffd200Minus|r: Mark items on the list (by clicking them). When you click the minus, they will be removed from this list.\n" ..
		"|cffffd200Local|r: Marked items will be put on your local list, meaning the rule is only active for the current character.\n" ..
		"|cffffd200Global|r: Same as local, only this time items will be put on your global list. Those rules are active for all your characters.\n" .. 
		"|cffffd200Empty|r: Click this button to remove any character specific (local) items from it. Shift-click empties any account wide (global) rules. |cffff0000Use with caution!|r",
	
	LOPlus = "Add items to this list by |cffffffffdragging|r/ |cffffffffdropping|r them onto this button.\n|cffffffffRight-click|r to add categories!",
	LOMinus = "Choose items to be removed from the list, then |cffffffffclick|r here.",
	LODemote = "|cffffffffClick|r to have any marked items used as character specific rules.",
	LOPromote = "|cffffffffClick|r to use any marked item as account wide rule.",
	LOEmptyList = "|cffff0000Caution!|r\n|cffffffffClick|r to empty any local entries on this list.\n"..
		"|cffffffffShift-Click|r to empty any global entries.",
	search = "Search...",
	
	-- LibPeriodicTable category testing
	PTCategoryTest = "Test category strings",
	PTCategoryTestTitle = "LibPeriodicTable Category String Test",
	PTCategoryTestSubTitle = "If you're unsure why an item shows up as it does or which items are included in which category, you can test that here.",
	PTCategoryTestExplanation = "Simply select a category below and it will display all items in your inventory that match this category.\nCategory information comes from LPT and not Broker_Garbage.",
	PTCategoryTestDropdownTitle = "Category to check",
	PTCategoryTestDropdownText = "Choose a category string",
}