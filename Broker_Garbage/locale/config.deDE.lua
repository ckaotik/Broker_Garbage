-- German config localization file
local _, addon = ...
local L = addon.configLocale

if GetLocale() == "deDE" then
	L["dropQualityName"] = "Wegwerf-Grenze"
	L["dropQualityDesc"] = "Wähle bis zu welcher Qualität Gegenstände zum Wegwerfen vorgeschlagen werden. Standard: Schlecht"
	L["disableKeyName"] = "Deaktivieren-Taste"
	L["disableKeyDesc"] = "Wähle eine Taste, die das Verhalten von BrokerGarbage vorübergehend deaktiviert."
	L["showJunkSellIconsName"] = "Verkaufen-Icon in Taschen"
	L["showJunkSellIconsDesc"] = "Aktivieren um an Taschen-Slots ein Hinweis-Icon anzuzeigen."
	L["LPTJunkIsJunkName"] = "Müll trumpft LPT-Kategorie"
	L["LPTJunkIsJunkDesc"] = "Aktivieren um LibPeriodicTable Kategorie-Daten für graue Gegenstände zu ignorieren.\nManches ist nicht länger von Nutzen (graue Qualität), aber weiterhin in LPT-Kategorien enthalten, z.B. Reagenzien."
	L["ignoreZeroValueName"] = "Wertloses ausblenden"
	L["ignoreZeroValueDesc"] = "Aktivieren um Gegenstände ohne Wert auszublenden. Standard: Aktiviert."

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
end
