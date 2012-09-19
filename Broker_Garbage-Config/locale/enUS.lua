-- enUS / enGB / default localization file
local _, BGC = ...
BGC.locale = {}
local L = BGC.locale

L["disableKey_None"] = "None"
L["disableKey_SHIFT"] = "SHIFT"
L["disableKey_ALT"] = "ALT"
L["disableKey_CTRL"] = "CTRL"

L["GlobalSetting"] = "\n|cffffff9aThis setting is global."

-- Chat Messages
L["addedTo_exclude"] = "%s has been added to the Keep List."
L["addedTo_forceVendorPrice"] = "%s will only have its vendor price considered."
L["addedTo_include"] = "%s has been added to the Junk List."
L["addedTo_autoSellList"] = "%s will be automatically sold when at a merchant."

L["itemAlreadyOnList"] = "%s is already on this list!"
L["limitSet"] = "%s has been assigned a limit of %d."
L["minValueSet"] = "Items with a value less than %s will not be looted anymore."
L["minSlotsSet"] = "The Loot Manager will try to keep at least %s slots free."

L["slashCommandHelp"] = [[supports |cffee6622/garbage|r, |cffee6622/garb|r, |cffee6622/junk|r with these commands:
|cFF36BFA8config|r opens the options panel.
|cFF36BFA8add|r |cFF2bff58<list>|r |cFF2bff58<item>|r Add an item/category to a list.
|cFF36BFA8remove|r |cFF2bff58<list>|r |cFF2bff58<item>|r Remove item/category from a given list.
    Possible list names: |cFF2bff58keep|r, |cFF2bff58junk|r, |cFF2bff58vendor|r, |cFF2bff58forceprice|r
|cFF36BFA8update|r |cFF2bff58<itemID>|r Refresh saved data
|cFF36BFA8format|r |cFF2bff58<text>|r lets you customize the LDB display text, |cFF2bff58reset|r resets it.
|cFF36BFA8categories|r |cFF2bff58<item>|r list of used categories with this item.]]
L["requiresLootManager"] = "This command requires the Loot Manager."
L["updateCache"] = "Please update the item caches via /garbage update"
L["invalidArgument"] = "You supplied an invalid argument. Please check your input and try again."

-- Tooltip
L["categoriesHeading"] = "Categories"
L["LPTNotLoaded"] = "LibPeriodicTable not loaded"

-- Special types
L["tooltipHeadingOther"] = "Other"
L["equipmentManager"] = "Equipment Manager"
L["armorClass"] = "Armor Class"
L["anythingCalled"] = "Items named"

-- Statistics Frame
L["StatisticsHeading"] = "Statistics"
L["ResetStatistic"] = "|cffffffffClick|r to reset this statistic.\n|cFFff0000Warning: This cannot be undone."

L["MemoryUsageTitle"] = "Memory Usage (kB)"
L["CollectMemoryUsageTooltip"] = "|cffffffffClick|r to start the Blizzard's garbage collection."

L["GlobalStatisticsHeading"] = "Account wide statistics:"
L["AverageSellValueTitle"] = "Average sell value"
L["AverageSellValueTooltip"] = "The average value an item earned you. Calculated as Money Earned/Items Sold."
L["AverageDropValueTitle"] = "Average drop value"
L["AverageDropValueTooltip"] = "The average value of dropped/deleted items. Calculated as Money Lost/Items Dropped."
L["GlobalMoneyEarnedTitle"] = "Total amount earned"
L["GlobalMoneyLostTitle"] = "Total amount lost"
L["GlobalItemsSoldTitle"] = "Items sold"
L["ItemsDroppedTitle"] = "Items dropped"

L["LocalStatisticsHeading"] = "This character's (%s) statistics:"
L["StatisticsLocalAmountEarned"] = "Amount earned"
L["StatisticsLocalAmountLost"] = "Amount lost"

L["ResetAllText"] = "Reset All"
L["ResetAllTooltip"] = "|cffffffffClick|r here to reset all character specific statistics. |cffffffffSHIFT-Click|r to clear all global statistics."

L["AuctionAddon"] = "Auction addon"
L["AuctionAddonTooltip"] = "Broker_Garbage will take auction values from this addon. If none is listed, you may still have auction values available by an addon that Broker_Garbage doesn't know."
L["unknown"] = "Unknown"	-- refers to auction addon
L["na"] = "Not Available"

-- Basic Options Frame
L["BasicOptionsTitle"] = "Basic Options"
L["BasicOptionsText"] = "Don't want to auto-sell/repair? Hold Shift (depending on your settings) when adressing the merchant!"

L["GroupBehavior"] = "Behavior"
L["GroupTresholds"] = "Tresholds"
L["GroupDisplay"] = "Display"
L["GroupTooltip"] = "Tooltip"
L["GroupOutput"] = "Text Output"

L["autoSellTitle"] = "Auto Sell"
L["autoSellText"] = "Check to have Broker_Garbage automatically sell your gray and junk items."

L["showAutoSellIconTitle"] = "Show Merchant Icon"
L["showAutoSellIconText"] = "Check to show an icon to manually auto-sell when at a vendor."

L["showItemTooltipLabelTitle"] = "Show labels"
L["showItemTooltipLabelText"] = "Check to show the label assigned by Broker_Garbage in the item's tooltip."

L["showItemTooltipDetailTitle"] = "Show reasoning"
L["showItemTooltipDetailText"] = "Check to show detailed information of Broker_Garbage's assigned label in the item's tooltip."

L["showNothingToSellTitle"] = "'Nothing to sell'"
L["showNothingToSellText"] = "Check to get a chat message when at a merchant but there is nothing to sell."

L["autoRepairTitle"] = "Auto Repair"
L["autoRepairText"] = "Check to automatically repair when at a vendor."

L["autoRepairGuildTitle"] = "Use Guild Funds"
L["autoRepairGuildText"] = "Check to allow Broker_Garbage to repair using guild funds."

L["showSourceTitle"] = "Source"
L["showSourceText"] = "Check to show the last column in the tooltip, displaying the item value source."

L["showIconTitle"] = "Icon"
L["showIconText"] = "Check to show the item's icon in front of the item link on the tooltip."

L["showEarnedTitle"] = "Earned"
L["showEarnedText"] = "Check to show the character's earned money (by selling junk items)."

L["showLostTitle"] = "Lost"
L["showLostText"] = "Check to show the character's lost money on the tooltip"

L["warnContainersTitle"] = "Containers"
L["warnContainersText"] = "When checked, Broker_Garbage will warn you of unopened containers."

L["warnClamsTitle"] = "Clams"
L["warnClamsText"] = "When checked, Broker_Garbage will warn you when you have clams in your inventory.\nAs clams stack, you are not wasting any slots by unchecking this."

L["dropQualityTitle"] = "Drop Quality"
L["dropQualityText"] = "Select up to which treshold items may be listed as deletable. Default: Poor"

L["moneyFormatTitle"] = "Money Format"
L["moneyFormatText"] = "Change the way money is being displayed."

L["maxItemsTitle"] = "Max. Items"
L["maxItemsText"] = "Set how many lines you would like to have displayed in the tooltip. Default: 9"

L["maxHeightTitle"] = "Max. Height"
L["maxHeightText"] = "Set the height of the tooltip. Default: 220"

L["sellNotUsableTitle"] = "Sell Unusable Gear"
L["sellNotUsableText"] = "Check this to have Broker_Garbage sell all soulbound gear you cannot wear.\n(Only applies if not an enchanter)"

L["TopFitOldItem"] = "Outdated Armor"
L["TopFitOldItemText"] = "If the addon TopFit is loaded, BG can ask for outdated gear and directly sell it."

L["keepMaxItemLevelTitle"] = "Keep highest iLvl"
L["keepMaxItemLevelText"] = "Check to keep the highest item level gear when selling outdated gear."

L["SNUMaxQualityTitle"] = "Sell Quality"
L["SNUMaxQualityText"] = "Select the maximum item quality to sell when 'Sell Unusable Gear' or 'Outdated Armor' is checked."

L["enchanterTitle"] = "Enchanter"
L["enchanterTooltip"] = "Check this if you have/know an enchanter.\nWhen checked disenchant values are considered, which are higher than vendor prices."

L["restackTitle"] = "Automatic restack"
L["restackTooltip"] = "Check to automatically compress your inventory items after looting."

L["inDev"] = "Under Development"

L["sellLogTitle"] = "Print Sell Log"
L["sellLogTooltip"] = "Check to print any item that gets sold by Broker_Garbage into your chat."

L["overrideLPTTitle"] = "Override LPT junk"
L["overrideLPTTooltip"] = "Check to ignore any LibPeriodicTable category data for grey items.\nSome items are no longer needed (grey) but still listed as e.g. reagents in LPT."

L["hideZeroTitle"] = "Hide items worth 0c"
L["hideZeroTooltip"] = "Check to hide items that are not worth anything. Enabled by default."

L["debugTitle"] = "Print debug output"
L["debugTooltip"] = "Check to display Broker_Garbage's debug information. Tends to spam your chat frame, you have been warned."

L["reportDEGearTitle"] = "Report outdated gear for disenchanting"
L["reportDEGearTooltip"] = "Check to print a message when an item becomes outdated (by means of TopFit) so you may disenchant it."

L["keepForLaterDETitle"] = "DE skill difference"
L["keepForLaterDETooltip"] = "Keep items that require at most <x> more skill points to be disenchanted by your character."

L["DKTitle"] = "Temporary disable key"
L["DKTooltip"] = "Set a key to temporarily disable BrokerGarbage."

L["LDBDisplayTextTitle"] = "LDB Display texts"
L["LDBDisplayTextTooltip"] = "Set the text to display in the LDB plugin."
L["LDBNoJunkTextTooltip"] = "Set the text to display when no junk was found."
L["ResetToDefault"] = "Reset to default value."
L["LDBDisplayTextHelpTooltip"] = [[|cffffffffBasic tags:|r
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
...[endcolor] ends a color section]]

-- List Options Panel
L["LOTitle"] = "Lists"
L["LOSubTitle"] = [[|cffffd200Junk|r: Items on this list can be thrown away if inventory space is needed.
|cffffd200Keep|r: Items on this list will never be deleted or sold.
|cffffd200Vendor Price|r: Items on this list only use vendor values. (This list is always global)
|cffffd200Sell|r: Items on this list will be sold when at a merchant. They also only use vendor prices.

!! Always use the 'Rescan Inventory' button after you make changes !!]]

L["defaultListsText"] = "Default Lists"
L["defaultListsTooltip"] = "|cffffffffClick|r to manually create default local list entries.\n |cffffffffShift-Click|r to also create default global lists." -- changed

L["rescanInventoryText"] = "Update Inventory"
L["rescanInventoryTooltip"] = "|cffffffffClick|r to have Broker_Garbage rescan your inventory. Do this whenever you change list entries!"

L["LOTabTitleInclude"] = "Junk"
L["LOTabTitleExclude"] = "Keep"
L["LOTabTitleVendorPrice"] = "Fixed Price"
L["LOTabTitleAutoSell"] = "Sell"

L["LOIncludeAutoSellText"] = "Sell Junk List items"
L["LOIncludeAutoSellTooltip"] = "Check this to automatically sell items on your include list when at a merchant. Items without a value will be ignored."

L["LOUseRealValues"] = "Use actual value for junk items"
L["LOUseRealValuesTooltip"] = "Check this to have junk items considered with their actual value, rather than 0c."

L["listsBestUse"] = [[|cffffd200List Examples|r
Don't forget to use the default lists! They provide a great example.
First, put any items you don't want to lose on your |cffffd200Keep List|r. Make good use of categories (see below)! If the LootManager is active it will by default alwas try to loot these items (changable in LM settings).
|cffAAAAAAe.g. class reagents, flasks|r
Items which may be thrown away any time belong on the |cffffd200Junk List|r.
|cffAAAAAAe.g. summoned food & drink, argent lance|r
In case you encounter highly overvalued items, put them on your |cffffd200Fixed Price List|r. They will only have their vendor value used instead of auction or disenchant values. Alternatively, you can set a custom price by using |TInterface\Icons\INV_Misc_Coin_02:18|t.
|cffAAAAAAe.g. fish oil (vendor price), Broiled Dragon Feast (custom price of e.g. 20g)|r
Put items on your |cffffd200Sell List|r that should be sold when visiting a merchant.
|cffAAAAAAe.g. water as a warrior, cheese|r]]

L["listsSpecialOptions"] = [[|cffffd200Junk List special options|r
|cffffd200Sell Junk List items|r: This setting is useful for those who do not want to distinguish between the Sell List and the Junk List. If you check this, any items on your Junk -or- Sell List will be sold when you visit a vendor.
|cffffd200Use actual values|r: This setting changes the behavior of the Junk List. By default (disabled) Junk List items will get their value set to 0c (statistics will still work just fine!) and they will be shown first in the tooltip. If you enable this setting, these items will retain their regular value and will only show up in the tooltip once their value is reached.]]

L["iconButtonsUse"] = [[|cffffd200Item Buttons|r
For any item you'll either see its icon, a gear if it's a category or a question mark in case the server doesn't know this item.
In the top left of each button you'll see a "G" (or not). If it's there, the item is on your |cffffd200global list|r meaning this rule is effective for every character.
Items on your Junk List may also have a |cffffd200limit|r. This will be shown as a small number in the lower right corner. By using the |cffffd200mousewheel|r on this button you can change this number. For categories, the number of all corresponding items will be added up.
If a limit is surpassed, items will be considered expendable, or in case of Keep-List limits regarded as regular items.]]

L["actionButtonsUse"] = [[|cffffd200Action Buttons|r
Below this window you'll see five buttons and a search bar.
|TInterface\Icons\Spell_ChargePositive:18|t |cffffd200Plus|r: Use this to add items to the currently shown list. Simply drag/drop them onto the plus. To add a |cffffd200category|r, right-click the plus and then choose a category.
|cffAAAAAAe.g. "Tradeskill > Recipe", "Misc > Key"|r
|TInterface\Icons\Spell_ChargeNegative:18|t |cffffd200Minus|r: Mark items on the list (by clicking them). When you click the minus, they will be removed from this list.
|TInterface\Icons\INV_Misc_GroupLooking:18|t |cffffd200Local|r: Marked items will be put on your local list, meaning the rule is only active for the current character.
|TInterface\Icons\INV_Misc_GroupNeedMore:18|t |cffffd200Global|r: Same as local, only this time items will be put on your global list. Those rules are active for all your characters.
|TInterface\Icons\INV_Misc_Coin_02:18|t |cffffd200Set Price|r: Marked items will get their value set to whatever is specified in the following popup dialogue.
|TInterface\Buttons\UI-GroupLoot-Pass-UP:18|t |cffffd200Empty|r: Click this button to remove any character specific (local) items from it. Shift-click empties any account wide (global) rules. |cffff0000Use with caution!|r]]

L["LOPlus"] = "Add items to this list by |cffffffffdragging|r/ |cffffffffdropping|r them onto this button.\n|cffffffffRight-click|r to add categories!"
L["LOMinus"] = "Choose items to be removed from the list, then |cffffffffclick|r here."
L["LODemote"] = "|cffffffffClick|r to have any marked items used as character specific rules."
L["LOPromote"] = "|cffffffffClick|r to use any marked item as account wide rule."
L["LOEmptyList"] = "|cffff0000Caution!|r\n|cffffffffClick|r to empty any local entries on this list.\n|cffffffffShift-Click|r to empty any global entries."

L["LOSetPrice"] = "|cffffffffClick|r to set a custom price for all selected entries."
L["setPriceInfo"] = "|cffffd200Set custom price|r|nClick on vendor price to use merchant values."

L["namedItems"] = "|TInterface\\Icons\\Spell_chargepositive:15:15|t item with name ..."
L["namedItemsInfo"] = "|cffffd200Add Item Name Rule|r|nInsert an item name or a pattern:|ne.g. \"|cFF36BFA8Scroll of *|r\" will match \"|cFF2bff58Scroll of Agility|r\" or \"|cFF2bff58Scroll of the Tiger|r\""
L["search"] = "Search..."

-- LibPeriodicTable category testing
L["PTCategoryTest"] = "Category Test"
L["PTCategoryTestExplanation"] = "Simply select a category below and it will display all items in your inventory that match this category.\nCategory information is provided by LibPeriodicTable."
L["PTCategoryTestDropdownTitle"] = "Category to check"
L["PTCategoryTestDropdownText"] = "Choose a category string"

L["categoryTestItemSlot"] = "Drop an item into this slot to search for any used category containing it."
L["categoryTestItemTitle"] = "%s is already in these categories...\n"
L["categoryTestItemEntry"] = "%s is not in any used category."
