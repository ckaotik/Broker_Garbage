--[[ German localisation file
Ä = \195\132	ä = \195\164
Ö = \195\150	ö = \195\182
Ü = \195\156	ü = \195\188	ß = \195\159 ]]--
_, BrokerGarbage = ...

if GetLocale() == "deDE" then

BrokerGarbage.locale = {
	label = "Kein Junk",
	
	-- Chat Messages
	sellAndRepair = "M\195\188ll f\195\188r %1$s verkauft, repariert f\195\188r %2$s. \195\132nderung: %3$s.",
	repair = "Repariert f\195\188r %s.",
	sell = "M\195\188ll verkauft f\195\188r %s.",
	
	addedToSaveList = "%s zur Ausnahmeliste hinzugef\195\188gt.",
	addedToDestroyList = "%s zur Einschlussliste hinzugef\195\188gt.",
	itemDeleted = "%s wurde gel\195\182scht.",
	
	openPlease = "Bitte \195\182ffne %s - es nimmt unn\195\182tig Platz weg.",
	
	-- Tooltip
	headerRightClick = "Rechts-Klick \195\182ffnet Optionen",
	headerShiftClick = "SHIFT-Klick: Zerst\195\182ren",
	headerCtrlClick = "STRG-Klick: Behalten",
	moneyLost = "Geld verloren:",
	
	-- Options Frame
	subTitle = "M\195\182chtest du einmal nicht automatisch verkaufen / reparieren? \nHalte SHIFT gedr\195\188ckt, wenn du den H\195\164ndler ansprichst!",
	autoSellTitle = "Automatisch Verkaufen",
	autoSellText = "Wenn ausgew\195\164hlt, werden graue Gegenst\195\164nde automatisch beim H\195\164ndler verkauft.",
	
	autoRepairTitle = "Automatisch Reparieren",
	autoRepairText = "Wenn ausgew\195\164hlt, wird deine Ausr\195\188stung automatisch repariert wenn m\195\182glich.",
	
	autoRepairGuildTitle = "Reparatur selbst zahlen", 
	autoRepairGuildText = "Wenn ausgew\195\164hlt wird Broker_Garbage nicht auf Gildenkosten reparieren.",
	
	dropQualityTitle = "Item Qualit\195\164t",
	dropQualityText = "W\195\164hle, bis zu welcher Qualit\195\164t Items zum L\195\182schen vorgeschlagen werden. Standard: Schlecht (0)",
	
	moneyFormatTitle = "Geldformat",
	moneyFormatText = "\195\132ndere die Art, wie Geldbetr\195\164ge angezeigt werden. Standard: 2",
	
	maxItemsTitle = "Max. Items",
	maxItemsText = "Lege fest, wie viele Zeilen im Tooltip angezeigt werden. Standard: 10",
	
	maxHeightTitle = "Max. H\195\182he",
	maxHeightText = "Lege fest, wie hoch der Tooltip sein darf. Standard: 220",
	
	rescanInventory = "Inventar neu scannen",
	rescanInventoryText = "Klicke um dein Inventar neu zu scannen. Dies sollte normalerweise nicht n\195\182tig sein!",
	
	resetMoneyLost = "'Verlorenes Geld' leeren",
	resetMoneyLostText = "Klicke um die Statistik 'Verlorenes Geld' zur\195\188ckzusetzen.",
	
	emptyExcludeList = "Ausschlussliste leeren",
	emptyExcludeListText = "Klicke um deine Ausschlussliste zu leeren.",
	
	emptyIncludeList = "Einschlussliste leeren",
	emptyIncludeListText = "Klicke um deine Einschlussliste zu leeren.",
	
	-- List Options Panel
	LOTitle = "Listen-Optionen",
	LOSubTitle = "Stelle hier deine Listen ein. Um Items hinzuzuf\195\188gen, zieh sie auf das jeweilige '+'. Um sie zu entfernen, w\195\164hle sie aus und klicke auf '-'.",
	
	LOExcludeHeader = "Ausschlussliste - Items hier werden nie verkauft/gel\195\182scht.",
	LOExcludePlusTT = "Items hinzuf\195\188gen, indem du sie hierher ziehst/hier ablegst",
	LOExcludeRefreshTT = "Klicke, um die Anzeige zu aktualisieren",
	LOExcludeMinusTT = "W\195\164hle Items, die du entfernen willst. Dann klicke hier.",
	LOExcludeEmptyTT = "Klicke, um die Ausschlussliste v\195\182llig zu leeren.\nAchtung!",
	
	LOIncludeHeader = "Einschlussliste - Items hier werden zum L\195\182schen vorgeschlagen.",
	LOIncludePlusTT = "Items hinzuf\195\188gen, indem du sie hierher ziehst/hier ablegst",
	LOIncludeRefreshTT = "Klicke, um die Anzeige zu aktualisieren",
	LOIncludeMinusTT = "W\195\164hle Items, die du entfernen willst. Dann klicke hier.",
	LOIncludeEmptyTT = "Klicke, um die Einschlussliste v\195\182llig zu leeren.\nAchtung!",
}

end