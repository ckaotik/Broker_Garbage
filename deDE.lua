-- German localisation file
_, BrokerGarbage = ...

if GetLocale() == "deDE" then

BrokerGarbage.locale = {
	label = "Kein Junk",
	
	-- Chat Messages
	sellAndRepair = "Müll für %1$s verkauft, repariert für %2$s. Änderung: %3$s.",
	repair = "Repariert für %s.",
	sell = "Müll verkauft für %s.",
	
	addedToSaveList = "%s zur Ausnahmeliste hinzugefügt.",
	addedToPriceList = "Für %s wird nun nur der Händlerpreis genutzt.",
	addedToIncludeList = "%s zur Einschlussliste hinzugefügt.",
	addedToSellList = "%s wird bei Händlern automatisch verkauft.",
	itemDeleted = "%s wurde gelöscht.",
	
	openPlease = "Bitte öffne %s - es nimmt unnötig Platz weg.",
	
	-- Tooltip
	headerRightClick = "Rechts-Klick: Optionen",
	headerShiftClick = "SHIFT-Klick: Zerstören",
	headerCtrlClick = "STRG-Klick: Behalten",
	moneyLost = "Gold verloren:",
	moneyEarned = "Gold verdient:",
	noItems = "Keine Items zum Löschen.",
	increaseTreshold = "Erhöhe die Item Qualität",
	
	autoSellTooltip = "Graue Items verkaufen.",
	
	-- Options Frame
	subTitle = "Möchtest du einmal nicht automatisch verkaufen / reparieren? \nHalte SHIFT gedrückt, wenn du den Händler ansprichst!",
	autoSellTitle = "Automatisch Verkaufen",
	autoSellText = "Wenn ausgewählt, werden graue Gegenstände automatisch beim Händler verkauft.",
	
	showAutoSellIconTitle = "Icon anzeigen",
	showAutoSellIconText = "Wenn ausgewählt, wird bei Händlern ein Icon zum automatischen Verkaufen angezeigt.",
	
	autoRepairTitle = "Automatisch Reparieren",
	autoRepairText = "Wenn ausgewählt, wird deine Ausrüstung automatisch repariert wenn möglich.",
	
	autoRepairGuildTitle = "Reparatur selbst zahlen", 
	autoRepairGuildText = "Wenn ausgewählt, wird Broker_Garbage nicht auf Gildenkosten reparieren.",
	
	showLostTitle = "'Verlorenes Gold' zeigen",
	showLostText = "Wenn ausgewählt, wird im Tooltip die Zeile 'Verlorenes Gold' gezeigt.",
	
	showSourceTitle = "Quelle anzeigen",
	showSourceText = "Wenn ausgewählt, wird im Tooltip als letzte Spalte die Preisquelle gezeigt.",
	
	showEarnedTitle = "'Verdientes Gold' zeigen",
	showEarnedText = "Wenn ausgewählt, wird im Tooltip die Zeile 'Verdientes Gold' gezeigt.",
	
	dropQualityTitle = "Item Qualität",
	dropQualityText = "Wähle, bis zu welcher Qualität Items zum Löschen vorgeschlagen werden. Standard: Schlecht (0)",
	
	moneyFormatTitle = "Geldformat",
	moneyFormatText = "Ändere die Art, wie Geldbeträge angezeigt werden. Standard: 2",
	
	maxItemsTitle = "Max. Items",
	maxItemsText = "Lege fest, wie viele Zeilen im Tooltip angezeigt werden. Standard: 9",
	
	maxHeightTitle = "Max. Höhe",
	maxHeightText = "Lege fest, wie hoch der Tooltip sein darf. Standard: 220",
	
	rescanInventory = "Inventar neu scannen",
	rescanInventoryText = "Klicke um dein Inventar neu zu scannen. Dies sollte normalerweise nicht nötig sein!",
	
	resetMoneyLost = "'Verlorenes Geld' leeren",
	resetMoneyLostText = "Klicke um die Statistik 'Verlorenes Geld' zurückzusetzen.",
	
	resetMoneyEarned = "'Verdientes Geld' leeren",
	resetMoneyEarnedText = "Klicke um die Statistik 'Verdientes Geld' zurückzusetzen.",
	
	emptyExcludeList = "Ausschlussliste leeren",
	emptyExcludeListText = "Klicke um deine globale (!) Ausschlussliste zu leeren.",
	
	emptyIncludeList = "Einschlussliste leeren",
	emptyIncludeListText = "Klicke um deine globale (!) Einschlussliste zu leeren.",
	
	-- List Options Panel
	LOPTitle = "Positiv-Listen",
	LOPSubTitle = "Um Items hinzuzufügen, ziehe sie auf das jeweilige '+'. Um sie zu entfernen, wähle sie aus und klicke auf '-'.",
		
		-- Exclude List
	LOPExcludeHeader = "Ausschlussliste - Items hier werden nie verkauft/gelöscht.",
	LOPExcludePlusTT = "Items hinzufügen, indem du sie hierher ziehst/hier ablegst",
	LOPExcludeMinusTT = "Wähle Items, die du entfernen willst. Dann klicke hier.",
	LOPExcludePromoteTT = "Klicke um alle markierten Items in die globale Ausnahmeliste zu übernehmen.",
	LOPExcludeEmptyTT = "Klicke, um die lokale Ausschlussliste völlig zu leeren.\n|cffff0000Achtung!",
	
		-- Force Vendor Price List
	LOPForceHeader = "Händlerpreis-Liste - Für diese Items wird nur der Händlerpreis betrachtet.",
	LOPForcePlusTT = "Items hinzufügen, indem du sie hierher ziehst/hier ablegst",
	LOPForceMinusTT = "Wähle Items, die du entfernen willst. Dann klicke hier.",
	LOPForcePromoteTT = "Die Händlerpreis-Liste ist bereits global.",
	LOPForceEmptyTT = "Klicke, um die Händlerliste völlig zu leeren.\n|cffff0000Achtung!",
	
	-- AutoSell Options Panel
	LONTitle = "Negativ-Listen",
	LONSubTitle = "Um Items hinzuzufügen, ziehe sie auf das jeweilige '+'. Um sie zu entfernen, wähle sie aus und klicke auf '-'.",
	
		-- Include List
	LONIncludeHeader = "Einschlussliste - Items hier werden mit als erstes im Tooltip gezeigt.",
	LONIncludePlusTT = "Items hinzufügen, indem du sie hierher ziehst/hier ablegst",
	LONIncludeMinusTT = "Wähle Items, die du entfernen willst. Dann klicke hier.",
	LONIncludePromoteTT = "Klicke, um alle markierten Items in die globale Einschlussliste zu übernehmen.",
	LONIncludeEmptyTT = "Klicke, um die lokale Einschlussliste völlig zu leeren.\n|cffff0000Achtung!",
	
		-- Auto Sell List
	LONAutoSellHeader = "Verkaufsliste - Items hier werden bei Händlern automatisch verkauft.",
	LONAutoSellPlusTT = "Items hinzufügen, indem du sie hierher ziehst/hier ablegst",
	LONAutoSellMinusTT = "Wähle Items, die du entfernen willst. Dann klicke hier.",
	LONAutoSellPromoteTT = "Klicke, um alle markierten Items in die globale Verkaufsliste zu übernehmen.",
	LONAutoSellEmptyTT = "Klicke, um die lokale Verkaufsliste völlig zu leeren.\n|cffff0000Achtung!",
	
	-- LibPeriodicTable texts
	PTCategoryTooltipHeader = "Kategorien hinzufügen",
	PTCategoryTooltipText = "Füge Kategorien hinzu, indem du auf die entsprechenden Einträge clickst."
}

end