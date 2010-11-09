﻿-- enUS / enGB / default localization file
_, BrokerGarbage = ...

BrokerGarbage.locale = {
	label = "Junk, be gone!",
	
	-- Chat Messages
	sellAndRepair = "Sold trash for %1$s, repaired for %2$s. Change: %3$s.",
	repair = "Repaired for %s.",
	sell = "Sold trash for %s.",
	
	addedTo_exclude = "%s has been added to the Keep List.",
	addedTo_forceVendorPrice = "%s will only have its vendor price considered.",
	addedTo_include = "%s has been added to the Junk List.",
	addedTo_autoSellList = "%s will be automatically sold when at a merchant.",
	itemAlreadyOnList = "%s is already on this list!",
	limitSet = "%s has been assigned a limit of %d.",
	itemDeleted = "%1$sx%2$d has been deleted.",
	couldNotRepair = "Could not repair because you don't have enough money. You need %s.",
	
	listsUpdatedPleaseCheck = "Your lists have been updated. Please have a look at your settings and check if they fit your needs.",
	slashCommandHelp = [[The following commands are available:
/garbage |cffc0c0c0config|r opens the options panel.
/garbage |cffc0c0c0format |cffc0c0ffformatstring|r lets you customize the LDB display text, |cffc0c0c0 format reset|r resets it.
/garbage |cffc0c0c0limit |cffc0c0ffitemLink/ID count|r sets a limit for the given item on the current character.
/garbage |cffc0c0c0globallimit |cffc0c0ffitemLink/ID count|r sets a limit for all characters.
/garbage |cffc0c0c0value |cffc0c0ffvalueInCopper|r sets the minimum value for items to be looted (Loot Manager needed).
/garbage |cffc0c0c0freeslots |cffc0c0ffnumber|r sets the number of inventory slots to keep empty.]],
	minValueSet = "Items with a value less than %s will not be looted anymore.",
	minSlotsSet = "The Loot Manager will try to keep at least %s slots free.",
	invalidArgument = "You supplied an invalid argument. Please check your input and try again.",
	
	GlobalSetting = "\n|cffffff9aThis setting is global.",
	
	-- Tooltip
	headerRightClick = "Right-Click for options",
	headerShiftClick = "SHIFT-Click: Destroy",
	headerCtrlClick = "CTRL-Click: Keep",
	moneyLost = "Money Lost:",
	moneyEarned = "Money Earned:",
	noItems = "No items to delete.",
	increaseTreshold = "Increase quality treshold",
	
	categoriesHeading = "Categories",
	LPTNotLoaded = "LibPeriodicTable not loaded",
	
	autoSellTooltip = "Sell Items for %s",
	reportNothingToSell = "Nothing to sell!",
	
	-- Statistics Frame
	StatisticsHeading = "Statistics",
	ResetStatistic = "|cffffffffClick|r to reset this statistic.\n|cFFff0000Warning: This cannot be undone.",
	
	MemoryUsageTitle = "Memory Usage (kB)",
	CollectMemoryUsageTooltip = "|cffffffffClick|r to start the Blizzard's garbage collection.",
	
	GlobalStatisticsHeading = "Account wide statistics:",
	AverageSellValueTitle = "Average sell value",
	AverageSellValueTooltip = "The average value an item earned you. Calculated as Money Earned/Items Sold.",
	AverageDropValueTitle = "Average drop value",
	AverageDropValueTooltip = "The average value of dropped/deleted items. Calculated as Money Lost/Items Dropped.",
	GlobalMoneyEarnedTitle = "Total amount earned",
	GlobalMoneyLostTitle = "Total amount lost",
	GlobalItemsSoldTitle = "Items sold",
	ItemsDroppedTitle = "Items dropped",
	
	LocalStatisticsHeading = "This character's (%s) statistics:",
	StatisticsLocalAmountEarned = "Amount earned",
	StatisticsLocalAmountLost = "Amount lost",
	
	ResetAllText = "Reset All",
	ResetAllTooltip = "|cffffffffClick|r here to reset all character specific statistics. |cffffffffSHIFT-Click|r to clear all global statistics.",
	
	AuctionAddon = "Auction addon",
	AuctionAddonTooltip = "Broker_Garbage will take auction values from this addon. If none is listed, you may still have auction values available by an addon that Broker_Garbage doesn't know.",
	unknown = "Unknown",	-- refers to auction addon
	na = "Not Available",
	
	-- Basic Options Frame
	BasicOptionsTitle = "Basic Options",
	BasicOptionsText = "Don't want to auto-sell/repair? Hold Shift (depending on your settings) when adressing the merchant!",
	
	GroupBehavior = "Behavior",
	GroupTresholds = "Tresholds",
	GroupDisplay = "Display",
	GroupTooltip = "Tooltip",
	
	autoSellTitle = "Auto Sell",
	autoSellText = "Check to have Broker_Garbage automatically sell your gray and junk items.",
	
	showAutoSellIconTitle = "Show Merchant Icon",
	showAutoSellIconText = "Check to show an icon to manually auto-sell when at a vendor.",
	
	showNothingToSellTitle = "'Nothing to sell'",
	showNothingToSellText = "Check to get a chat message when at a merchant but there is nothing to sell.",
	
	autoRepairTitle = "Auto Repair",
	autoRepairText = "Check to automatically repair when at a vendor.",
	
	autoRepairGuildTitle = "No Guild Repair", 
	autoRepairGuildText = "Check to never repair using guild funds.",
	
	showLostTitle = "Show Money Lost",
	showLostText = "Check to show the character's lost money on the tooltip",
	
	showSourceTitle = "Show Price Source",
	showSourceText = "Check to show the last column in the tooltip, displaying the item value source.",
	
	showEarnedTitle = "Show Money Earned",
	showEarnedText = "Check to show the character's earned money (by selling junk items).",
	
	dropQualityTitle = "Drop Quality",
	dropQualityText = "Select up to which treshold items may be listed as deletable. Default: Poor",
	
	moneyFormatTitle = "Money Format",
	moneyFormatText = "Change the way money is being displayed.",
	
	maxItemsTitle = "Max. Items",
	maxItemsText = "Set how many lines you would like to have displayed in the tooltip. Default: 9",
	
	maxHeightTitle = "Max. Height",
	maxHeightText = "Set the height of the tooltip. Default: 220",
	
	sellNotUsableTitle = "Sell Unusable Gear",
	sellNotUsableText = "Check this to have Broker_Garbage sell all soulbound gear you cannot wear.\n(Only applies if not an enchanter)",
	
	SNUMaxQualityTitle = "Sell Quality",
	SNUMaxQualityText = "Select the maximum item quality to sell when 'Sell Unusable Gear' is checked.",
	
	enchanterTitle = "Enchanter",
	enchanterTooltip = "Check this if you have/know an enchanter. When checked, Broker_Garbage will use disenchant values for disenchantable items, which are usually higher than vendor prices.",
	
	DKTitle = "Temporary disable key",
	DKTooltip = "Set a key to temporarily disable BrokerGarbage.",
	disableKeys = {
		["None"] = "None",
		["SHIFT"] = "SHIFT",
		["ALT"] = "ALT",
		["CTRL"] = "CTRL",
	},
	
	LDBDisplayTextTitle = "LDB Display texts",
	LDBDisplayTextTooltip = "Set the text to display in the LDB plugin.",
	LDBNoJunkTextTooltip = "Set the text to display when no junk was found.",
	ResetToDefault = "Reset to default value.",
	LDBDisplayTextHelpTooltip = [[Format string help:
[itemname] - item link
[itemcount] - item count
[itemvalue] - item value
[freeslots] - free bag slots
[totalslots] - total bag slots
[junkvalue] - total autosell value
[bagspacecolor]...[endcolor] to colorize]],
	
	-- List Options Panel
	LOTitle = "Lists",
	LOSubTitle = [[If you need help click the "?"-tab.

|cffffd200Junk|r: Items on this list can be thrown away if needed.
|cffffd200Keep|r: Items on this list will never be deleted.
|cffffd200Vendor Price|r: Items only use vendor values. (always global)
|cffffd200Sell|r: Items on this list will be sold when at a merchant.]],
	
	defaultListsText = "Default Lists",
	defaultListsTooltip = "|cffffffffClick|r to manually create default local list entries.\n |cffffffffShift-Click|r to also create default global lists.", -- changed
	
	LOTabTitleInclude = "Junk",
	LOTabTitleExclude = "Keep",
	LOTabTitleVendorPrice = "Vendor Price",
	LOTabTitleAutoSell = "Sell",
	
	LOIncludeAutoSellText = "Sell Junk List items",
	LOIncludeAutoSellTooltip = "Check this to automatically sell items on your include list when at a merchant. Items without a value will be ignored.",
	
	LOUseRealValues = "Use actual value for junk items",
	LOUseRealValuesTooltip = "Check this to have junk items considered with their actual value, rather than 0c.",
	
	listsBestUse = [[|cffffd200List Examples|r
Don't forget to use the default lists! They provide a great example.
First, put any items you don't want to lose on your |cffffd200Keep List|r. Make good use of categories (see below)! If the LootManager is active it will alwas try to loot these items.
|cffAAAAAAe.g. class reagents, flasks|r
Items which may be thrown away any time belong on the |cffffd200Junk List|r.
|cffAAAAAAe.g. summoned food & drink, argent lance|r
In case you encounter highly overrated items, put them on your |cffffd200Vendor Price List|r. They will only have their vendor value used instead of auction or disenchant values.
|cffAAAAAAe.g. fish oil|r
Put items on your |cffffd200Sell List|r that should be sold when visiting a merchant.
|cffAAAAAAe.g. water as a warrior, cheese|r]],

	listsSpecialOptions = [[|cffffd200Junk List special options|r
|cffffd200Sell Junk List items|r: This setting is useful for those who do not want to distinguish between the Sell List and the Junk List. If you check this, any items on your Junk -or- Sell List will be sold when you visit a vendor.
|cffffd200Use actual values|r: This setting changes the behavior of the Junk List. By default (disabled) Junk List items will get their value set to 0c (statistics will still work just fine!) and they will be shown first in the tooltip. If you enable this setting, these items will retain their regular value and will only show up in the tooltip once their value is reached.]],
	
	iconButtonsUse = [[|cffffd200Item Buttons|r
For any item you'll either see its icon, a gear if it's a category or a question mark in case the server doesn't know this item.
In the top left of each button you'll see a "G" (or not). If it's there, the item is on your |cffffd200global list|r meaning this rule is effective for every character.
Items on your Junk List may also have a |cffffd200limit|r. This will be shown as a small number in the lower right corner. By using the |cffffd200mousewheel|r on this button you can change this number. Limited items will only be dropped/destroyed if you have more than their limit indicates.]],
	
	actionButtonsUse = [[|cffffd200Action Buttons|r
Below this window you'll see five buttons and a search bar.
|TInterface\Icons\Spell_ChargePositive:18|t |cffffd200Plus|r: Use this to add items to the currently shown list. Simply drag/drop them onto the plus. To add a |cffffd200category|r, right-click the plus and then choose a category.
|cffAAAAAAe.g. "Tradeskill > Recipe", "Misc > Key"|r
|TInterface\Icons\Spell_ChargeNegative:18|t |cffffd200Minus|r: Mark items on the list (by clicking them). When you click the minus, they will be removed from this list.
|TInterface\Icons\INV_Misc_GroupLooking:18|t |cffffd200Local|r: Marked items will be put on your local list, meaning the rule is only active for the current character.
|TInterface\Icons\INV_Misc_GroupNeedMore:18|t |cffffd200Global|r: Same as local, only this time items will be put on your global list. Those rules are active for all your characters.
|TInterface\Buttons\UI-GroupLoot-Pass-UP:18|t |cffffd200Empty|r: Click this button to remove any character specific (local) items from it. Shift-click empties any account wide (global) rules. |cffff0000Use with caution!|r]],

	LOPlus = "Add items to this list by |cffffffffdragging|r/ |cffffffffdropping|r them onto this button.\n|cffffffffRight-click|r to add categories!",
	LOMinus = "Choose items to be removed from the list, then |cffffffffclick|r here.",
	LODemote = "|cffffffffClick|r to have any marked items used as character specific rules.",
	LOPromote = "|cffffffffClick|r to use any marked item as account wide rule.",
	LOEmptyList = "|cffff0000Caution!|r\n|cffffffffClick|r to empty any local entries on this list.\n"..
		"|cffffffffShift-Click|r to empty any global entries.",
	search = "Search...",
	
	-- LibPeriodicTable category testing
	PTCategoryTest = "Category Test",
	PTCategoryTestExplanation = "Simply select a category below and it will display all items in your inventory that match this category.\nCategory information is provided by LibPeriodicTable.",
	PTCategoryTestDropdownTitle = "Category to check",
	PTCategoryTestDropdownText = "Choose a category string",
}