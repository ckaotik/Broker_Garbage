-- German localisation file
_, BrokerGarbage = ...

if GetLocale() == "deDE" then

BrokerGarbage.locale = {
	label = "Kein Müll",
	
	-- Chat Messages
	sellAndRepair = "Müll für %1$s verkauft, repariert für %2$s. Änderung: %3$s.",
	repair = "Repariert für %s.",
	sell = "Müll verkauft für %s.",
	
	addedToSaveList = "%s zur Ausnahmeliste hinzugefügt.",
	addedToPriceList = "Für %s wird nun nur der Händlerpreis genutzt.",
	addedToIncludeList = "%s zur Einschlussliste hinzugefügt.",
	addedToSellList = "%s wird bei Händlern automatisch verkauft.",
	limitSet = "Für %s wurde das Limit auf %d gesetzt.",
	itemDeleted = "%1$sx%2$d wurde gelöscht.",
	
	slashCommandHelp = "Folgende Kommandos werden unterstützt: |cffc0c0c0/garbage|r\n"..
		"|cffc0c0c0config|r öffnet die Optionen.\n"..
		"|cffc0c0c0format |cffc0c0ffformatstring|r lässt dich das Format der LDB Anzeige anpassen, |cffc0c0c0 format reset|r setzt es zurück.\n"..
		"|cffc0c0c0stats|r gibt dir eine Kurzstatistik aus.\n"..
		"|cffc0c0c0limit |cffc0c0ffitemLink/ID Anzahl|r setzt ein Limit für das gewählte Item für den aktuellen Charakter.\n"..
		"|cffc0c0c0globallimit |cffc0c0ffitemLink/ID Anzahl|r setzt ein Limit für alle Charaktere.\n"..
		"|cffc0c0c0value |cffc0c0ffWertInKupfer|r setzt den Itemwert, ab dem Items gelootet werden (benötigt den Loot Manager).",
	statistics = "Statistik:\n"..
		"Gesamtverdienst (alle Charaktere): %1$s\n"..
		"Gesamtverlust (alle Charaktere): %2$s",
	minValueSet = "Mindestwert für items wurde auf %s gesetzt.",
	
	-- Tooltip
	headerRightClick = "Rechts-Klick: Optionen",
	headerShiftClick = "SHIFT-Klick: Zerstören",
	headerCtrlClick = "STRG-Klick: Behalten",
	moneyLost = "Gold verloren:",
	moneyEarned = "Gold verdient:",
	noItems = "Keine Items zum Löschen.",
	increaseTreshold = "Erhöhe die Item Qualität",
	
	autoSellTooltip = "Müll für %s verkaufen",
	reportNothingToSell = "Nichts zu verkaufen!",
	
	-- Statistics Frame
	StatisticsHeading = "Statistiken, jeder braucht sie!\n"..
		"Um Teile davon zu löschen, klicke auf das jeweilige 'x'.",
	
	MemoryUsageText = "Bitte beachte, dass insbesondere nach dem Inventarscan der Speicherbedarf stark zunimmt. Er schrumpft wieder, wenn der 'Garbage Collector' ans Werk geht.",
	MemoryUsageTitle = "Speicherverbrauch (kB)",
	CollectMemoryUsageTooltip = "Klicke um den 'Garbage Collector' (Blizzard Funktion) manuell zu starten.",
	
	GlobalStatisticsHeading = "Globale Geldstatistiken:",
	AverageSellValueTitle = "Durchschnittl. Verkaufswert",
	AverageDropValueTitle = "Durchschnittl. weggeworfen",
	
	GlobalMoneyEarnedTitle = "Gesamtverdienst",
	ResetGlobalMoneyEarnedTooltip = "Klicke um deinen Gesamtverdienst zurückzusetzen.",
	GlobalMoneyLostTitle = "Gesamtverlust",
	ResetGlobalMoneyLostTooltip = "Klicke um deinen Gesamtverlust zurückzusetzen.",
	
	GlobalItemsSoldTitle = "Items verkauft",
	ResetGlobalItemsSoldTooltip = "Klicke um die Anzahl an verkauften Items zurückzusetzen.",
	ItemsDroppedTitle = "Items weggeworfen",
	ResetGlobalItemsDroppedTooltip = "Klicke um die Anzahl der weggeworfenen Items zurückzusetzen.",
	
	LocalStatisticsHeading = "Statistiken von %s:",
	StatisticsLocalAmountEarned = "Verdienst",
	ResetLocalMoneyEarnedTooltip = "Klicke um deinen (lokalen) Verdienst zurückzusetzen.",
	StatisticsLocalAmountLost = "Verlust",
	ResetLocalMoneyLostTooltip = "Klicke um deinen (lokalen) Verlust zurückzusetzen.",
	
	ResetGlobalDataText = "Reset: Global",
	ResetGlobalDataTooltip = "Klicke hier um alle globalen Statistikdaten zurückzusetzen.",
	ResetLocalDataText = "Reset: Lokal",
	ResetLocalDataTooltip = "Klicke um alle charakterspezifischen Statistiken zurückzusetzen.",
	
	-- Basic Options Frame
	BasicOptionsTitle = "Grundeinstellungen",
	BasicOptionsText = "Möchtest du einmal nicht automatisch verkaufen/reparieren? "..
		"Halte SHIFT (je nach Einstellung) gedrückt, wenn du den Händler ansprichst!",
	autoSellTitle = "Automatisch Verkaufen",
	autoSellText = "Wenn ausgewählt, werden graue Gegenstände automatisch beim Händler verkauft.",
	
	showAutoSellIconTitle = "Icon anzeigen",
	showAutoSellIconText = "Wenn ausgewählt, wird bei Händlern ein Icon zum automatischen Verkaufen angezeigt.",
	
	showNothingToSellTitle = "'Nichts zu verkaufen'",
	showNothingToSellText = "Wenn ausgewählt, wird bei Besuch eines Händlers eine Nachricht ausgegeben, falls es nichts zu verkaufen gibt.",
	
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
	
	sellNotUsableTitle = "Verkaufe Ausrüstung",
	sellNotUsableText = "Wenn ausgewählt, wird Broker_Garbage seelengebundene Ausrüstung, die du niemals tragen kannst, automatisch verkaufen.\n(inaktiv bei Verzauberern)",
	
	SNUMaxQualityTitle = "Max. Qualität",
	SNUMaxQualityText = "Wähle die maximale Itemqualität, bei der von 'Verkaufe Ausrüstung' verkauft werden soll.",
	
	enchanterTitle = "Verzauberer",
	enchanterTooltip = "Setze das Häkchen, wenn du einen Verzauberer besitzt/kennst. Wenn aktiviert, wird Broker_Garbage Entzauberpreise verwenden, welche in der Regel höher sind als Händlerpreise.",
	
	rescanInventory = "Inventar neu scannen",
	rescanInventoryText = "Klicke um dein Inventar neu zu scannen. Dies sollte normalerweise nicht nötig sein!",
	
	defaultListsText = "Standardlisten",
	defaultListsTooltip = "Klicke, um manuell die lokalen Standardeinträge für Listen einzufügen. Rechtsklick um auch die globalen Einträge zu erstellen.",
	
	DKTitle = "Temp. deaktivieren mit",
	DKTooltip = "Wähle die Taste, die die Aktionen von BrokerGarbage temporär deaktiviert.",
	disableKeys = {
		["None"] = "Kein",
		["SHIFT"] = "SHIFT",
		["ALT"] = "ALT",
		["CTRL"] = "STRG",
	},
	
	LDBDisplayTextTitle = "LDB Anzeigetexte",
	LDBDisplayTextTooltip = "Nutze diese Einstellung, um den Text zu ändern, den du in deinem LDB Display siehst.",
	LDBDisplayTextResetTooltip = "Setze den LDB Anzeigetext auf den Standardwert zurück.",
	LDBNoJunkTextTooltip = "Nutze diese Einstellung, um den Text zu ändern, der angezeigt wird, wenn du keinen Müll hast.",
	LDBNoJunkTextResetTooltip = "Setze den 'Kein Müll' Text auf den Standardwert zurück.",
	LDBDisplayTextHelpTooltip = "Schnellhilfe:\n"..
		"[itemname] - Itemlink\n"..
		"[itemcount] - Item Anzahl\n"..
		"[itemvalue] - Itemwert\n"..
		"[freeslots] - freier Taschenplatz\n"..
		"[totalslots] - Gesamttaschenplatz\n"..
		"[junkvalue] - Verkaufswert\n"..
		"[bagspacecolor]...[endcolor] zum färben",
		
	-- List Options Panel
	LOPTitle = "Positiv-Listen",
	LOPSubTitle = "Zum Hinzufügen ziehe Items auf das jeweilige '+'. Zum Entfernen wähle sie aus und klicke auf '-'. Nutze Kategorien per Rechts-Klick auf '+'.",
		
		-- Exclude List
	LOPExcludeHeader = "Ausschlussliste - Items hier werden nie verkauft/gelöscht.",
	LOPExcludePlusTT = "Items hinzufügen, indem du sie hierher ziehst/hier ablegst. Rechtsklick, um Kategorien hinzuzufügen!",
	LOPExcludeMinusTT = "Wähle Items, die du entfernen willst. Dann klicke hier.",
	LOPExcludePromoteTT = "Klicke um alle markierten Items in die globale Ausnahmeliste zu übernehmen.",
	LOPExcludeEmptyTT = "|cffff0000Achtung! Klicke, um die lokale Ausschlussliste zu leeren.\n"..
		"Shift-Klicke, um die globale Ausschlussliste zu leeren",
	
		-- Force Vendor Price List
	LOPForceHeader = "Händlerpreis-Liste - Für diese Items wird nur der Händlerpreis betrachtet.",
	LOPForcePlusTT = "Items hinzufügen, indem du sie hierher ziehst/hier ablegst. Rechtsklick, um Kategorien hinzuzufügen!",
	LOPForceMinusTT = "Wähle Items, die du entfernen willst. Dann klicke hier.",
	LOPForcePromoteTT = "Die Händlerpreis-Liste ist bereits global.",
	LOPForceEmptyTT = "|cffff0000Achtung! Shift-Klicke, um die Händlerpreisliste zu leeren",
	
	-- AutoSell Options Panel
	LONTitle = "Negativ-Listen",
	LONSubTitle = "Analog zu den Positiv-Listen. Um eine maximale Anzahl für ein bestimmtes Item festzulegen, nutze das Mausrad über dem Item-Icon.",
	
		-- Include List
	LONIncludeHeader = "Einschlussliste - Items werden zuerst angezeigt und vom LM nicht geplündert.",
	LONIncludePlusTT = "Items hinzufügen, indem du sie hierher ziehst/hier ablegst. Rechtsklick, um Kategorien hinzuzufügen!",
	LONIncludeMinusTT = "Wähle Items, die du entfernen willst. Dann klicke hier.",
	LONIncludePromoteTT = "Klicke, um alle markierten Items in die globale Einschlussliste zu übernehmen.",
	LONIncludeEmptyTT = "|cffff0000Achtung! Klicke, um die lokale Einschlussliste zu leeren.\n"..
		"Shift-Klicke, um die globale Einschlussliste zu leeren",
	
		-- Auto Sell List
	LONAutoSellHeader = "Verkaufsliste - Items hier werden bei Händlern automatisch verkauft.",
	LONAutoSellPlusTT = "Items hinzufügen, indem du sie hierher ziehst/hier ablegst. Rechtsklick, um Kategorien hinzuzufügen!",
	LONAutoSellMinusTT = "Wähle Items, die du entfernen willst. Dann klicke hier.",
	LONAutoSellPromoteTT = "Klicke, um alle markierten Items in die globale Verkaufsliste zu übernehmen.",
	LONAutoSellEmptyTT = "|cffff0000Achtung! Klicke, um die lokale Verkaufsliste zu leeren.\n"..
		"Shift-Klicke, um die globale Verkaufsliste zu leeren",
	
	-- LibPeriodicTable texts
	PTCategoryTooltipHeader = "Kategorien hinzufügen",
	PTCategoryTooltipText = "Füge Kategorien hinzu, indem du auf die entsprechenden Einträge clickst.",
}

end