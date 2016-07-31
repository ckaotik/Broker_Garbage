-- enUS / enGB / default localization file
local _, addon = ...
local L = {}
addon.configLocale = L

-- if GetLocale() == "enUS" then

	L["dropQualityName"] = "Drop quality"
	L["dropQualityDesc"] = "Select up to which threshold items may be listed as deletable. Default: Poor"
	L["disableKeyName"] = "Disable key"
	L["disableKeyDesc"] = "Set a key to temporarily disable BrokerGarbage."
	L["showJunkSellIconsName"] = "Show junk icons"
	L["showJunkSellIconsDesc"] = "Check to show an indicator on bag slots."
	L["LPTJunkIsJunkName"] = "Override LPT junk"
	L["LPTJunkIsJunkDesc"] = "Check to ignore any LibPeriodicTable category data for grey items.\nSome items are no longer needed (grey) but still listed as e.g. reagents in LPT."
	L["ignoreZeroValueName"] = "Hide worthless items"
	L["ignoreZeroValueDesc"] = "Check to hide items that are not worth anything. Enabled by default."

	L["disenchantValuesName"] = "Disenchant values"
	L["disenchantValuesDesc"] = "Check this if you have/know an enchanter.\nWhen checked, disenchant values are considered which tend to be higher than vendor prices."
	L["disenchantSkillOffsetName"] = "Disenchant range"
	L["disenchantSkillOffsetDesc"] = "Keep items that require at most <x> more skill points to be disenchanted by your character."
	L["disenchantSuggestionsName"] = "Disenchant reports"
	L["disenchantSuggestionsDesc"] = "Check to print a message when an item becomes outdated (by means of TopFit) so you may disenchant it."

	-- Behavior
	L["keepHighestItemLevelName"] = "Keep highest iLvl"
	L["keepHighestItemLevelDesc"] = "Check to keep the highest item level gear when selling outdated gear."
	L["keepQuestItemsName"] = "Keep quest items"
	L["keepQuestItemsDesc"] = ""
	L["sellJunkName"] = "Sell junk items"
	L["sellJunkDesc"] = "Check to automatically sell items on your junk list when at a merchant. Items without a value will be ignored."
	L["sellUnusableQualityName"] = "Sell unusable equipment"
	L["sellUnusableQualityDesc"] = "Select the maximum item quality allowed to be sold for unusable but soulbound equipment."
	L["sellOutdatedQualityName"] = "Sell outdated equipment"
	L["sellOutdatedQualityDesc"] = "Select the maximum item quality allowed to be sold for soulbound equipment that TopFit deems uninteresting."

	-- LDB
	L["labelName"] = "Broker label"
	L["labelDesc"] = "Set the text to display in the LDB plugin.\n\n|cffffffffBasic tags:|r\n[itemname] - item link\n[itemicon] - item icon\n[itemcount] - item count\n[itemvalue] - item value\n[junkvalue] - total autosell value\n|cffffffffInventory space tags:|r\n[freeslots] - free bag slots\n[totalslots] - total bag slots\n[basicfree],[specialfree] - free\n[basicslots],[specialslots] - total\n|cffffffffColor tags:|r\n[bagspacecolor]... - all bags\n[basicbagcolor]... - basic only\n[specialbagcolor]... - special only\n...[endcolor] ends a color section\n"
	L["noJunkLabelName"] = "Broker label 'No Junk'"
	L["noJunkLabelDesc"] = "Set the text to display in the LDB plugin when no junk was found."
	L["moneyFormatName"] = "Money format"
	L["moneyFormatDesc"] = "Change the way money is being displayed."

	-- Tooltip
	L["itemTooltipName"] = "Item tooltip"
	L["tooltipName"] = "LDB tooltip"
	L["heightName"] = "Max. height"
	L["heightDesc"] = "Set the height of the tooltip. Default: 220"
	L["numLinesName"] = "Max. items"
	L["numLinesDesc"] = "Set how many lines you would like to have displayed in the tooltip. Default: 9"
	L["showIconName"] = "Icon"
	L["showIconDesc"] = "Check to show the item's icon in front of the item link on the tooltip."
	L["showMoneyLostName"] = "Money lost"
	L["showMoneyLostDesc"] = "Check to show the character's lost money on the tooltip."
	L["showMoneyEarnedName"] = "Money earned"
	L["showMoneyEarnedDesc"] = "Check to show the character's earned money (by selling junk items)."
	L["showReasonName"] = "Show reasoning"
	L["showReasonDesc"] = "Check to show detailed information of Broker_Garbage's assigned label in the item's tooltip."
	L["showUnopenedContainersName"] = "Show containers"
	L["showUnopenedContainersDesc"] = "When checked, Broker_Garbage will warn you of unopened containers."
	L["showClassificationName"] = "Show classification"
	L["showClassificationDesc"] = "Check to show the label assigned to the item by the addon."

	L["moneyEarned"] = "Money earned"
	L["moneyLost"] = "Money lost"
	L["numDeleted"] = "Number of items deleted"
	L["numSold"] = "Number of items sold"

	-- prices
	-- keep
	-- toss

-- end
