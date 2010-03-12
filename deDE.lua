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
	itemDeleted = "%s wurde gelöscht.",
	
	openPlease = "Bitte öffne %s - es nimmt unnötig Platz weg.",
	openClams = "Du hast eine %s im Inventar!",
	couldNotLoot = "%s wurde nicht geplündert, da es zu billig ist.",
	slashCommandHelp = "Nutze |cffc0c0c0/garbage config|r um die Einstellungen zu öffnen oder |cffc0c0c0/garbage format |cffc0c0ffformatstring|r um das Format der LDB Anzeige anzupassen. |cffc0c0c0/garbage format reset|r setzt das LDB Format zurück. Für Statistiken, gib |cffc0c0c0/garbage stats|r ein.",
	statistics = "Statistik:\nGesamtverdienst (alle Charaktere): %1$s\nGesamtverlust (alle Charaktere): %2$s",
	
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
	StatisticsHeading = "Statistiken, jeder braucht sie!\nUm Teile davon zu löschen, klicke auf das jeweilige 'x'.",
	
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
	BasicOptionsText = "Möchtest du einmal nicht automatisch verkaufen / reparieren? \nHalte SHIFT gedrückt, wenn du den Händler ansprichst!",
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
	
	rescanInventory = "Inventar neu scannen",
	rescanInventoryText = "Klicke um dein Inventar neu zu scannen. Dies sollte normalerweise nicht nötig sein!",
	
	emptyExcludeList = "Ausschlussliste leeren",
	emptyExcludeListText = "Klicke um deine globale (!) Ausschlussliste zu leeren.",
	
	emptyIncludeList = "Einschlussliste leeren",
	emptyIncludeListText = "Klicke um deine globale (!) Einschlussliste zu leeren.",
	
	LDBDisplayTextTitle = "LDB Anzeige:",
	LDBDisplayTextHelpTooltip = "Schnellhilfe:\n%1$s - Itemlink\n%2$s - Item Anzahl\n%3$s - Itemwert\n%4$d - freier Taschenplatz\n%5$d - Gesamttaschenplatz",
	LDBDisplayTextResetTooltip = "Setze den LDB Anzeigetext auf den Standardwert zurück.",
	
	-- List Options Panel
	LOPTitle = "Positiv-Listen",
	LOPSubTitle = "Zum Hinzufügen ziehe Items auf das jeweilige '+'. Zum Entfernen wähle sie aus und klicke auf '-'. Nutze Kategorien per Rechts-Klick auf '+'.",
		
		-- Exclude List
	LOPExcludeHeader = "Ausschlussliste - Items hier werden nie verkauft/gelöscht.",
	LOPExcludePlusTT = "Items hinzufügen, indem du sie hierher ziehst/hier ablegst. Rechtsklick, um Kategorien hinzuzufügen!",
	LOPExcludeMinusTT = "Wähle Items, die du entfernen willst. Dann klicke hier.",
	LOPExcludePromoteTT = "Klicke um alle markierten Items in die globale Ausnahmeliste zu übernehmen.",
	LOPExcludeEmptyTT = "Klicke, um die lokale Ausschlussliste völlig zu leeren.\n|cffff0000Achtung!",
	
		-- Force Vendor Price List
	LOPForceHeader = "Händlerpreis-Liste - Für diese Items wird nur der Händlerpreis betrachtet.",
	LOPForcePlusTT = "Items hinzufügen, indem du sie hierher ziehst/hier ablegst. Rechtsklick, um Kategorien hinzuzufügen!",
	LOPForceMinusTT = "Wähle Items, die du entfernen willst. Dann klicke hier.",
	LOPForcePromoteTT = "Die Händlerpreis-Liste ist bereits global.",
	LOPForceEmptyTT = "Klicke, um die Händlerliste völlig zu leeren.\n|cffff0000Achtung!",
	
	-- AutoSell Options Panel
	LONTitle = "Negativ-Listen",
	LONSubTitle = "Analog zu den Positiv-Listen. Um eine maximale Anzahl für ein bestimmtes Item festzulegen, nutze das Mausrad über dem Item-Icon.",
	
		-- Include List
	LONIncludeHeader = "Einschlussliste - Items werden zuerst angezeigt und vom LM nicht geplündert.",
	LONIncludePlusTT = "Items hinzufügen, indem du sie hierher ziehst/hier ablegst. Rechtsklick, um Kategorien hinzuzufügen!",
	LONIncludeMinusTT = "Wähle Items, die du entfernen willst. Dann klicke hier.",
	LONIncludePromoteTT = "Klicke, um alle markierten Items in die globale Einschlussliste zu übernehmen.",
	LONIncludeEmptyTT = "Klicke, um die lokale Einschlussliste völlig zu leeren.\n|cffff0000Achtung!",
	
		-- Auto Sell List
	LONAutoSellHeader = "Verkaufsliste - Items hier werden bei Händlern automatisch verkauft.",
	LONAutoSellPlusTT = "Items hinzufügen, indem du sie hierher ziehst/hier ablegst. Rechtsklick, um Kategorien hinzuzufügen!",
	LONAutoSellMinusTT = "Wähle Items, die du entfernen willst. Dann klicke hier.",
	LONAutoSellPromoteTT = "Klicke, um alle markierten Items in die globale Verkaufsliste zu übernehmen.",
	LONAutoSellEmptyTT = "Klicke, um die lokale Verkaufsliste völlig zu leeren.\n|cffff0000Achtung!",
	
	-- LibPeriodicTable texts
	PTCategoryTooltipHeader = "Kategorien hinzufügen",
	PTCategoryTooltipText = "Füge Kategorien hinzu, indem du auf die entsprechenden Einträge clickst.",
	
	-- Loot Manager
	CreatureTypeBeast = "Wildtier",
	Quest = "Quest",
	You = "Ihr",
	
	LMTitle = "Loot Manager",
	LMSubTitle = "Der Loot Manager kann den gesamten Lootvorgang verwalten, wenn du ihn lässt.\nHalte SHIFT beim Plündern lange gedrückt, wenn du sonst Autoloot an hast, aber einmalig 'per Hand' plündern möchtest.",
	
	LMEnableTitle = "Loot Manager aktivieren",
	LMEnableTooltip = "Aktiviert den Loot Manager.",
	
	LMSelectiveTitle = "Selektives Looten",
	LMSelectiveTooltip = "Wenn ausgewählt, entscheidet Broker_Garbage von selbst, welche Items gelootet werden.",
	
	LMAutoLootTitle = "Autoloot",
	LMAutoLootTooltip = "Wenn nicht ausgewählt, wird Broker_Garbage nur bei bestimmten Gelegenheiten looten.",
	
	LMAutoLootSkinningTitle = "Kürschnern",
	LMAutoLootSkinningTooltip = "Wenn ausgewählt, wird Broker_Garbage versuchen, durch dich kürschnerbare Kreaturen zu looten.",
	
	LMAutoLootPickpocketTitle = "Taschendiebstahl",
	LMAutoLootPickpocketTooltip = "Wenn ausgewählt, wird Broker_Garbage automatisch plündern, wenn du ein Schurke in Verstohlenheit bist.",
	
	LMAutoLootFishingTitle = "Angeln",
	LMAutoLootFishingTooltip = "Wenn ausgewählt, wird Broker_Garbage automatisch plündern, wenn du gerade angelst.",
	
	LMAutoDestroyTitle = "Auto-Zerstören",
	LMAutoDestroyTooltip = "Wenn ausgewählt, wird Broker_Garbage bei zu wenig Platz versuchen, welchen zu schaffen.",
	
	LMFreeSlotsTitle = "Min. freier Inventarplatz",
	LMFreeSlotsTooltip = "Setze das Minimum an freien Taschenplätzen, bei dem Broker_Garbage automatisch Platz schaffen soll.",
	
	LMRestackTitle = "Automatisch stapeln",
	LMRestackTooltip = "Wenn ausgewählt, wird Broker_Garbage automatisch die von dir beobachteten Gegenstände nach dem Plündern stapeln, um Platz zu schaffen.",
	
	LMFullRestackTitle = "Gesamtes Inventar",
	LMFullRestackTooltip = "Wenn ausgewählt, wird Broker_Garbage dein gesamtes Inventar zum Restacken beobachten.",
	
	LMOpenContainersTitle = "Warne: Behälter",
	LMOpenContainersTooltip = "Wenn ausgewählt, wird Broker_Garbage eine Warnung ausgeben, solltest du ungeöffnete Behälter bei dir haben.",
	
	LMOpenClamsTitle = "Warne: Muscheln",
	LMOpenClamsTooltip = "Wenn ausgewählt, wird Broker_Garbage eine Warnung ausgeben, wenn du ungeöffnete Muscheln im Inventar hast. Da diese aber nun stapelbar sind, verlierst du durch deaktivieren dieser Option keinen Taschenplatz.",
}

end