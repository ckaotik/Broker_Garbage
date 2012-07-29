-- enUS / enGB / default localization file
local _, BGC = ...

BGC.locale = {
	GlobalSetting = "\n|cffffff9aThis setting is global.",

	-- Chat Messages
	addedTo_exclude = "%s has been added to the Keep List.",
	addedTo_forceVendorPrice = "%s will only have its vendor price considered.",
	addedTo_include = "%s has been added to the Junk List.",
	addedTo_autoSellList = "%s will be automatically sold when at a merchant.",

	itemAlreadyOnList = "%s is already on this list!",
	limitSet = "%s has been assigned a limit of %d.",
	minValueSet = "Items with a value less than %s will not be looted anymore.",
	minSlotsSet = "The Loot Manager will try to keep at least %s slots free.",

	slashCommandHelp = [[The following commands are available:
/garbage |cffc0c0c0config|r opens the options panel.
/garbage |cffc0c0c0format |cffc0c0ffformatstring|r lets you customize the LDB display text, |cffc0c0c0 format reset|r resets it.
/garbage |cffc0c0c0limit |cffc0c0ffitemLink/ID count|r sets a limit for the given item on the current character.
/garbage |cffc0c0c0globallimit |cffc0c0ffitemLink/ID count|r sets a limit for all characters.
/garbage |cffc0c0c0value |cffc0c0ffvalueInCopper|r sets the minimum value for items to be looted (Loot Manager needed).
/garbage |cffc0c0c0freeslots |cffc0c0ffnumber|r sets the number of inventory slots to keep empty.]],
	requiresLootManager = "This command requires the Loot Manager.",
	invalidArgument = "You supplied an invalid argument. Please check your input and try again.",

	-- Tooltip
	categoriesHeading = "Categories",
	LPTNotLoaded = "LibPeriodicTable not loaded",

	-- Special types
	tooltipHeadingOther = "Other",
	equipmentManager = "Equipment Manager",
	armorClass = "Armor Class",
	anythingCalled = "Items named",

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
	GroupOutput = "Text Output",

	autoSellTitle = "Auto Sell",
	autoSellText = "Check to have Broker_Garbage automatically sell your gray and junk items.",

	showAutoSellIconTitle = "Show Merchant Icon",
	showAutoSellIconText = "Check to show an icon to manually auto-sell when at a vendor.",

	showItemTooltipLabelTitle = "Show labels",
	showItemTooltipLabelText = "Check to show the label assigned by Broker_Garbage in the item's tooltip.",

	showItemTooltipDetailTitle = "Show reasoning",
	showItemTooltipDetailText = "Check to show detailed information of Broker_Garbage's assigned label in the item's tooltip.",

	showNothingToSellTitle = "'Nothing to sell'",
	showNothingToSellText = "Check to get a chat message when at a merchant but there is nothing to sell.",

	autoRepairTitle = "Auto Repair",
	autoRepairText = "Check to automatically repair when at a vendor.",

	autoRepairGuildTitle = "Use Guild Funds",
	autoRepairGuildText = "Check to allow Broker_Garbage to repair using guild funds.",

	showSourceTitle = "Source",
	showSourceText = "Check to show the last column in the tooltip, displaying the item value source.",

	showIconTitle = "Icon",
	showIconText = "Check to show the item's icon in front of the item link on the tooltip.",

	showEarnedTitle = "Earned",
	showEarnedText = "Check to show the character's earned money (by selling junk items).",

	showLostTitle = "Lost",
	showLostText = "Check to show the character's lost money on the tooltip",

	warnContainersTitle = "Containers",
	warnContainersText = "When checked, Broker_Garbage will warn you of unopened containers.",

	warnClamsTitle = "Clams",
	warnClamsText = "When checked, Broker_Garbage will warn you when you have clams in your inventory.\nAs clams stack, you are not wasting any slots by unchecking this.",

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

	TopFitOldItem = "Outdated Armor",
	TopFitOldItemText = "If the addon TopFit is loaded, BG can ask for outdated gear and directly sell it.",

	keepMaxItemLevelTitle = "Keep highest iLvl",
	keepMaxItemLevelText = "Check to keep the highest item level gear when selling outdated gear.",

	SNUMaxQualityTitle = "Sell Quality",
	SNUMaxQualityText = "Select the maximum item quality to sell when 'Sell Unusable Gear' or 'Outdated Armor' is checked.",

	enchanterTitle = "Enchanter",
	enchanterTooltip = "Check this if you have/know an enchanter.\nWhen checked disenchant values are considered, which are higher than vendor prices.",

	restackTitle = "Automatic restack",
	restackTooltip = "Check to automatically compress your inventory items after looting.",

	inDev = "Under Development",

	sellLogTitle = "Print Sell Log",
	sellLogTooltip = "Check to print any item that gets sold by Broker_Garbage into your chat.",

	overrideLPTTitle = "Override LPT junk",
	overrideLPTTooltip = "Check to ignore any LibPeriodicTable category data for grey items.\nSome items are no longer needed (grey) but still listed as e.g. reagents in LPT.",

	hideZeroTitle = "Hide items worth 0c",
	hideZeroTooltip = "Check to hide items that are not worth anything. Enabled by default.",

	debugTitle = "Print debug output",
	debugTooltip = "Check to display Broker_Garbage's debug information. Tends to spam your chat frame, you have been warned.",

	reportDEGearTitle = "Report outdated gear for disenchanting",
	reportDEGearTooltip = "Check to print a message when an item becomes outdated (by means of TopFit) so you may disenchant it.",

	keepForLaterDETitle = "DE skill difference",
	keepForLaterDETooltip = "Keep items that require at most <x> more skill points to be disenchanted by your character.",

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
	LDBDisplayTextHelpTooltip = [[|cffffffffBasic tags:|r
[itemname] - item link
[itemicon] - item icon
[itemcount] - item count
[itemvalue] - item value
[junkvalue] - total autosell value

|cffffffffInventory space tags:|r
[freeslots] - free bag slots
[totalslots] - total bag slots
[basicfree],[specialfree] - free
[basicslots],[specialslots] - total

|cffffffffColor tags:|r
[bagspacecolor]... - all bags
[basicbagcolor]... - basic only
[specialbagcolor]... - special only
...[endcolor] ends a color section]],

	-- List Options Panel
	LOTitle = "Lists",
	LOSubTitle = [[|cffffd200Junk|r: Items on this list can be thrown away if inventory space is needed.
|cffffd200Keep|r: Items on this list will never be deleted or sold.
|cffffd200Vendor Price|r: Items on this list only use vendor values. (This list is always global)
|cffffd200Sell|r: Items on this list will be sold when at a merchant. They also only use vendor prices.

!! Always use the 'Rescan Inventory' button after you make changes !!]],

	defaultListsText = "Default Lists",
	defaultListsTooltip = "|cffffffffClick|r to manually create default local list entries.\n |cffffffffShift-Click|r to also create default global lists.", -- changed

	rescanInventoryText = "Update Inventory",
	rescanInventoryTooltip = "|cffffffffClick|r to have Broker_Garbage rescan your inventory. Do this whenever you change list entries!",

	LOTabTitleInclude = "Junk",
	LOTabTitleExclude = "Keep",
	LOTabTitleVendorPrice = "Fixed Price",
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

	LOSetPrice = "|cffffffffClick|r to set a custom price for all selected entries.",
	setPriceInfo = "|cffffd200Set custom price|r|nClick on vendor price to use merchant values.",

	namedItems = "|TInterface\\Icons\\Spell_chargepositive:15:15|t item with name ...",
	namedItemsInfo = "|cffffd200Add Item Name Rule|r|nInsert an item name or a pattern:|ne.g. \"|cFF36BFA8Scroll of *|r\" will match \"|cFF2bff58Scroll of Agility|r\" or \"|cFF2bff58Scroll of the Tiger|r\"",
	search = "Search...",

	-- LibPeriodicTable category testing
	PTCategoryTest = "Category Test",
	PTCategoryTestExplanation = "Simply select a category below and it will display all items in your inventory that match this category.\nCategory information is provided by LibPeriodicTable.",
	PTCategoryTestDropdownTitle = "Category to check",
	PTCategoryTestDropdownText = "Choose a category string",

	categoryTestItemSlot = "Drop an item into this slot to search for any used category containing it.",
	categoryTestItemTitle = "%s is already in these categories...\n",
	categoryTestItemEntry = "%s is not in any used category.",
}
