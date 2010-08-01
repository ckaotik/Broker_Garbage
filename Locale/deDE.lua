-- German localisation file
_, BrokerGarbage = ...

if GetLocale() == "deDE" then
	BrokerGarbage.locale.label = "Kein Müll"
	
	-- Chat Messages
	BrokerGarbage.locale.sellAndRepair = "Müll für %1$s verkauft, repariert für %2$s. Änderung: %3$s."
	BrokerGarbage.locale.repair = "Repariert für %s."
	BrokerGarbage.locale.sell = "Müll verkauft für %s."
	
	BrokerGarbage.locale.addedTo_exclude = "%s zur Ausnahmeliste hinzugefügt."
	BrokerGarbage.locale.addedTo_forceVendorPrice = "Für %s wird nun nur der Händlerpreis genutzt."
	BrokerGarbage.locale.addedTo_include = "%s zur Einschlussliste hinzugefügt."
	BrokerGarbage.locale.addedTo_autoSellList = "%s wird bei Händlern automatisch verkauft."
	BrokerGarbage.locale.limitSet = "Für %s wurde das Limit auf %d gesetzt."
	BrokerGarbage.locale.itemDeleted = "%1$sx%2$d wurde gelöscht."
	BrokerGarbage.locale.couldNotRepair = "Konnte nicht reparieren, da du nicht genug Geld hast. Du brauchst %s."
	
	BrokerGarbage.locale.listsUpdatedPleaseCheck = "Die Listeneinstellungen wurden geändert. Bitte sieh in den Einstellungen nach, ob sie für dich passend sind."
	BrokerGarbage.locale.slashCommandHelp = "Folgende Kommandos werden unterstützt: |cffc0c0c0/garbage|r\n"..
		"|cffc0c0c0config|r öffnet die Optionen.\n"..
		"|cffc0c0c0format |cffc0c0ffformatstring|r lässt dich das Format der LDB Anzeige anpassen, |cffc0c0c0 format reset|r setzt es zurück.\n"..
		"|cffc0c0c0limit |cffc0c0ffitemLink/ID Anzahl|r setzt ein Limit für das gewählte Item für den aktuellen Charakter.\n"..
		"|cffc0c0c0globallimit |cffc0c0ffitemLink/ID Anzahl|r setzt ein Limit für alle Charaktere.\n"..
		"|cffc0c0c0value |cffc0c0ffWertInKupfer|r setzt den Itemwert, ab dem Items gelootet werden (benötigt den Loot Manager)."
	BrokerGarbage.locale.minValueSet = "Mindestwert für items wurde auf %s gesetzt."
	
	BrokerGarbage.locale.warningMessagePrefit = "Warnung"
	
	-- Tooltip
	BrokerGarbage.locale.headerRightClick = "Rechts-Klick: Optionen"
	BrokerGarbage.locale.headerShiftClick = "SHIFT-Klick: Zerstören"
	BrokerGarbage.locale.headerCtrlClick = "STRG-Klick: Behalten"
	BrokerGarbage.locale.moneyLost = "Gold verloren:"
	BrokerGarbage.locale.moneyEarned = "Gold verdient:"
	BrokerGarbage.locale.noItems = "Keine Items zum Löschen."
	BrokerGarbage.locale.increaseTreshold = "Erhöhe die Item Qualität"
	
	BrokerGarbage.locale.categoriesHeading = "Kategorien"
	BrokerGarbage.locale.unknownAuctionAddon = "Unbekannt/Keins"
	BrokerGarbage.locale.LPTNotLoaded = "LibPeriodicTable nicht aktiv"
	
	BrokerGarbage.locale.autoSellTooltip = "Müll für %s verkaufen"
	BrokerGarbage.locale.reportNothingToSell = "Nichts zu verkaufen!"
	
	-- Statistics Frame
	BrokerGarbage.locale.StatisticsHeading = "Statistiken, jeder braucht sie!\n"..
		"Um Teile davon zu löschen, klicke auf das jeweilige 'x'."
	
	BrokerGarbage.locale.LPTNoticeText = "|cffFF6600Es scheint, als hättest du kein LibPeriodicTable aktiv. Du wirst keine Kategorien nutzen können, aber sonst sollte das Addon einwandfrei funktionieren - mit ein paar Features weniger.|r"
	BrokerGarbage.locale.MemoryUsageTitle = "Speicherverbrauch (kB)"
	BrokerGarbage.locale.CollectMemoryUsageTooltip = "Klicke um den Garbage Collector (Blizzard Funktion) manuell zu starten."
	
	BrokerGarbage.locale.GlobalStatisticsHeading = "Globale Geldstatistiken:"
	BrokerGarbage.locale.AverageSellValueTitle = "Durchschnittl. Verkaufswert"
	BrokerGarbage.locale.AverageDropValueTitle = "Durchschnittl. weggeworfen"
	
	BrokerGarbage.locale.GlobalMoneyEarnedTitle = "Gesamtverdienst"
	BrokerGarbage.locale.ResetGlobalMoneyEarnedTooltip = "Klicke um deinen Gesamtverdienst zurückzusetzen."
	BrokerGarbage.locale.GlobalMoneyLostTitle = "Gesamtverlust"
	BrokerGarbage.locale.ResetGlobalMoneyLostTooltip = "Klicke um deinen Gesamtverlust zurückzusetzen."
	
	BrokerGarbage.locale.GlobalItemsSoldTitle = "Items verkauft"
	BrokerGarbage.locale.ResetGlobalItemsSoldTooltip = "Klicke um die Anzahl an verkauften Items zurückzusetzen."
	BrokerGarbage.locale.ItemsDroppedTitle = "Items weggeworfen"
	BrokerGarbage.locale.ResetGlobalItemsDroppedTooltip = "Klicke um die Anzahl der weggeworfenen Items zurückzusetzen."
	
	BrokerGarbage.locale.LocalStatisticsHeading = "Statistiken von %s:"
	BrokerGarbage.locale.StatisticsLocalAmountEarned = "Verdienst"
	BrokerGarbage.locale.ResetLocalMoneyEarnedTooltip = "Klicke um deinen (lokalen) Verdienst zurückzusetzen."
	BrokerGarbage.locale.StatisticsLocalAmountLost = "Verlust"
	BrokerGarbage.locale.ResetLocalMoneyLostTooltip = "Klicke um deinen (lokalen) Verlust zurückzusetzen."
	
	BrokerGarbage.locale.ResetGlobalDataText = "Reset: Global"
	BrokerGarbage.locale.ResetGlobalDataTooltip = "Klicke hier um alle globalen Statistikdaten zurückzusetzen."
	BrokerGarbage.locale.ResetLocalDataText = "Reset: Lokal"
	BrokerGarbage.locale.ResetLocalDataTooltip = "Klicke um alle charakterspezifischen Statistiken zurückzusetzen."
	
	BrokerGarbage.locale.AuctionAddon = "Auktionsaddon"
	BrokerGarbage.locale.AuctionAddonUnknown = "Unbekannt/Keins"
	
	-- Basic Options Frame
	BrokerGarbage.locale.BasicOptionsTitle = "Grundeinstellungen"
	BrokerGarbage.locale.BasicOptionsText = "Möchtest du einmal nicht automatisch verkaufen/reparieren? "..
		"Halte SHIFT (je nach Einstellung) gedrückt, wenn du den Händler ansprichst!"
	BrokerGarbage.locale.autoSellTitle = "Automatisch Verkaufen"
	BrokerGarbage.locale.autoSellText = "Wenn ausgewählt, werden graue Gegenstände automatisch beim Händler verkauft."
	
	BrokerGarbage.locale.showAutoSellIconTitle = "Icon anzeigen"
	BrokerGarbage.locale.showAutoSellIconText = "Wenn ausgewählt, wird bei Händlern ein Icon zum automatischen Verkaufen angezeigt."
	
	BrokerGarbage.locale.showNothingToSellTitle = "'Nichts zu verkaufen'"
	BrokerGarbage.locale.showNothingToSellText = "Wenn ausgewählt, wird bei Besuch eines Händlers eine Nachricht ausgegeben, falls es nichts zu verkaufen gibt."
	
	BrokerGarbage.locale.autoRepairTitle = "Automatisch Reparieren"
	BrokerGarbage.locale.autoRepairText = "Wenn ausgewählt, wird deine Ausrüstung automatisch repariert wenn möglich."
	
	BrokerGarbage.locale.autoRepairGuildTitle = "Reparatur selbst zahlen" 
	BrokerGarbage.locale.autoRepairGuildText = "Wenn ausgewählt, wird Broker_Garbage nicht auf Gildenkosten reparieren."
	
	BrokerGarbage.locale.showLostTitle = "'Verlorenes Gold' zeigen"
	BrokerGarbage.locale.showLostText = "Wenn ausgewählt, wird im Tooltip die Zeile 'Verlorenes Gold' gezeigt."
	
	BrokerGarbage.locale.showSourceTitle = "Quelle anzeigen"
	BrokerGarbage.locale.showSourceText = "Wenn ausgewählt, wird im Tooltip als letzte Spalte die Preisquelle gezeigt."
	
	BrokerGarbage.locale.showEarnedTitle = "'Verdientes Gold' zeigen"
	BrokerGarbage.locale.showEarnedText = "Wenn ausgewählt, wird im Tooltip die Zeile 'Verdientes Gold' gezeigt."
	
	BrokerGarbage.locale.dropQualityTitle = "Item Qualität"
	BrokerGarbage.locale.dropQualityText = "Wähle, bis zu welcher Qualität Items zum Löschen vorgeschlagen werden. Standard: Schlecht (0)"
	
	BrokerGarbage.locale.moneyFormatTitle = "Geldformat"
	BrokerGarbage.locale.moneyFormatText = "Ändere die Art, wie Geldbeträge angezeigt werden. Standard: 2"
	
	BrokerGarbage.locale.maxItemsTitle = "Max. Items"
	BrokerGarbage.locale.maxItemsText = "Lege fest, wie viele Zeilen im Tooltip angezeigt werden. Standard: 9"
	
	BrokerGarbage.locale.maxHeightTitle = "Max. Höhe"
	BrokerGarbage.locale.maxHeightText = "Lege fest, wie hoch der Tooltip sein darf. Standard: 220"
	
	BrokerGarbage.locale.sellNotUsableTitle = "Verkaufe Ausrüstung"
	BrokerGarbage.locale.sellNotUsableText = "Wenn ausgewählt, wird Broker_Garbage seelengebundene Ausrüstung, die du niemals tragen kannst, automatisch verkaufen.\n(inaktiv bei Verzauberern)"
	
	BrokerGarbage.locale.SNUMaxQualityTitle = "Max. Qualität"
	BrokerGarbage.locale.SNUMaxQualityText = "Wähle die maximale Itemqualität, bei der von 'Verkaufe Ausrüstung' verkauft werden soll."
	
	BrokerGarbage.locale.enchanterTitle = "Verzauberer"
	BrokerGarbage.locale.enchanterTooltip = "Setze das Häkchen, wenn du einen Verzauberer besitzt/kennst. Wenn aktiviert, wird Broker_Garbage Entzauberpreise verwenden, welche in der Regel höher sind als Händlerpreise."
	
	BrokerGarbage.locale.rescanInventory = "Inventar neu scannen"
	BrokerGarbage.locale.rescanInventoryText = "Klicke um dein Inventar neu zu scannen. Dies sollte normalerweise nicht nötig sein!"
	
	BrokerGarbage.locale.DKTitle = "Temp. deaktivieren mit"
	BrokerGarbage.locale.DKTooltip = "Wähle die Taste, die die Aktionen von BrokerGarbage temporär deaktiviert."
	BrokerGarbage.locale.disableKeys = {
		["None"] = "Kein",
		["SHIFT"] = "SHIFT",
		["ALT"] = "ALT",
		["CTRL"] = "STRG",
	}
	
	BrokerGarbage.locale.LDBDisplayTextTitle = "LDB Anzeigetexte"
	BrokerGarbage.locale.LDBDisplayTextTooltip = "Nutze diese Einstellung, um den Text zu ändern, den du in deinem LDB Display siehst."
	BrokerGarbage.locale.LDBDisplayTextResetTooltip = "Setze den LDB Anzeigetext auf den Standardwert zurück."
	BrokerGarbage.locale.LDBNoJunkTextTooltip = "Nutze diese Einstellung, um den Text zu ändern, der angezeigt wird, wenn du keinen Müll hast."
	BrokerGarbage.locale.LDBNoJunkTextResetTooltip = "Setze den 'Kein Müll' Text auf den Standardwert zurück."
	BrokerGarbage.locale.LDBDisplayTextHelpTooltip = "Schnellhilfe:\n"..
		"[itemname] - Itemlink\n"..
		"[itemcount] - Item Anzahl\n"..
		"[itemvalue] - Itemwert\n"..
		"[freeslots] - freier Taschenplatz\n"..
		"[totalslots] - Gesamttaschenplatz\n"..
		"[junkvalue] - Verkaufswert\n"..
		"[bagspacecolor]...[endcolor] zum färben"
		
	-- List Options Panel
	BrokerGarbage.locale.defaultListsText = "Standardlisten"
	BrokerGarbage.locale.defaultListsTooltip = "|cffffffffKlicke|r, um manuell die lokalen Standardeinträge für Listen einzufügen.\n|cffffffffRechtsklick|r um auch die globalen Einträge zu erstellen."
	
	BrokerGarbage.locale.LOTabTitleInclude = "Müll"
	BrokerGarbage.locale.LOTabTitleExclude = "Behalten"
	BrokerGarbage.locale.LOTabTitleVendorPrice = "Händlerpreis"
	BrokerGarbage.locale.LOTabTitleAutoSell = "Verkaufen"
	
	BrokerGarbage.locale.LOIncludeAutoSellText = "Müll-Items verkaufen"
	BrokerGarbage.locale.LOIncludeAutoSellTooltip = "Aktivieren, um Items von deiner Müll-Liste automatisch beim Händler zu verkaufen. Items ohne Wert werden ignoriert."
	
	BrokerGarbage.locale.LOTitle = "Listeneinstellungen"
	BrokerGarbage.locale.LOSubTitle = "Wenn du Hilfe brauchst, klicke das \"?\"-Tab an.\n\n" .. 
		"|cffffd200" .. BrokerGarbage.locale.LOTabTitleInclude .. "|r: Diese Liste beinhaltet Items, die  weggeworfen werden können.\n" ..
		"|cffffd200" .. BrokerGarbage.locale.LOTabTitleExclude .. "|r: Items auf dieser Liste werden nie weggeworfen.\n" ..
		"|cffffd200" .. BrokerGarbage.locale.LOTabTitleVendorPrice .. "|r: Items nutzen keine Auktionspreise. (immer global)\n" ..
		"|cffffd200" .. BrokerGarbage.locale.LOTabTitleAutoSell .. "|r: Diese Items werden bei Händlern automatisch verkauft."
	
	BrokerGarbage.locale.listsBestUse = "|cffffd200Listen-Beispiele|r\n" .. 
		"Die Standardlisten geben eine Hilfestellung, was auf welcher Liste nützlich sein könnte.\n" ..
		"Setze erst alle Items, die du auf jeden Fall behalten möchtest, auf die |cffffd200Behalten-Liste|r. Denke auch daran, dass es Kategorien (s.u.) gibt! Ist der LootManager aktiv, wird er Items von dieser Liste immer plündern. \n|cffAAAAAAz.B. Klassenreagenzien, Fläschchen|r\n" .. 
		"Dinge, von denen du weißt, dass sie sorglos weggeworfen werden können, gehören auf die |cffffd200Müll-Liste|r. \n|cffAAAAAAz.B. Herbeigezauberter Manakeks, Argentumlanze|r\n" .. 
		"Sollte ein Item ungewollt einen exorbitant hohen Wert zugewiesen bekommen, setze das Item auf die |cffffd200Händlerpreis-Liste|r. Diese Items werden nur den Händlerpreis nutzen. \n|cffAAAAAAz.B. Fischöl|r\n" .. 
		"Auf die |cffffd200Verkaufen-Liste|r kannst du alles setzen, was Broker_Garbage verkaufen soll. \n|cffAAAAAAz.B. Wasser (als Krieger), Alterachochkäse|r"
	
	BrokerGarbage.locale.iconButtonsUse = "|cffffd200Item-Buttons|r\n" .. 
		"Angezeigt wird entweder das Icon des Items, ein Zahnrad, wenn es sich um eine Kategorie handelt, oder ein Fragezeichen, wenn der Server das Item nicht finden kann.\n" .. 
		"Oben links jedes Buttons befindet sich ein \"G\" (oder auch nicht). Steht es dort, ist dieses Item auf der |cffffd200globalen Liste|r, d.h. diese Regel gilt für alle Charaktere.\n" .. 
		"Items auf der Müll-Liste können ein |cffffd200Limit|r haben. Dies wird als kleine Zahl in der unteren rechten Ecke angezeigt. Zum Ändern nutze das |cffffd200Mausrad|r über dem Button. Diese Items werden erst gelöscht, sollte das Limit überschritten werden."
	
	BrokerGarbage.locale.actionButtonsUse = "|cffffd200Aktions-Buttons|r\n" .. 
		"Unterhalb dieses Fensters siehst du 5 Buttons und eine Suchleiste.\n" ..
		"|cffffd200Plus|r: Hier kannst du Items zu der angezeigten Liste hinzufügen. Ziehe dazu einfach ein Item auf das Plus. Um eine |cffffd200Kategorie|r hinzuzufügen, rechtsklicke das Plus und wähle dann in dem neuen Menü eine Kategorie aus. \n|cffAAAAAAz.B. \"Tradeskill > Recipe\", \"Misc > Key\"|r\n" ..
		"|cffffd200Minus|r: Markiere Items aus der Liste (anklicken). Beim Klick auf das Minus werden diese Items von der Liste entfernt.\n" ..
		"|cffffd200Lokal|r: Markierte Items werden auf die lokale Liste gesetzt, gelten also nur für diesen Charakter.\n" ..
		"|cffffd200Global|r: Analog zu Lokal, nur werden hierbei die Items auf die globale Liste gesetzt, die Regeln gelten damit für alle Charaktere.\n" .. 
		"|cffffd200Leeren|r: Ein Klick auf diesen Button leert die charakterspezifischen Regeln dieser Liste. Shift-Klick leert die accountweiten Regeln. |cffff0000Mit Vorsicht benutzen!|r"
	
	BrokerGarbage.locale.LOPlus = "Füge Items zu dieser Liste hinzu, indem du sie hierher |cffffffffziehst|r/hier |cffffffffablegst|r.\n|cffffffffRechtsklick|r, um Kategorien hinzuzufügen!"
	BrokerGarbage.locale.LOMinus = "Wähle oben die Items, die du von dieser Liste entfernen willst. Dann |cffffffffklicke|r hier."
	BrokerGarbage.locale.LODemote = "|cffffffffKlicke|r um alle markierten Items als charakterspezifische Regel zu nutzen."
	BrokerGarbage.locale.LOPromote = "|cffffffffKlicke|r um alle markierten Items als globale Regel zu nutzen."
	BrokerGarbage.locale.LOEmptyList = "|cffff0000Achtung!|r\n|cffffffffKlicke|r, um die lokalen Einträge dieser Liste zu löschen.\n"..
		"|cffffffffShift-Klicke|r, um die globalen Einträge zu löschen."
	BrokerGarbage.locale.search = "Suchen..."
	
	-- LibPeriodicTable category testing
	BrokerGarbage.locale.PTCategoryTest = "Teste Kategorien"
	BrokerGarbage.locale.PTCategoryTestTitle = "LibPeriodicTable Kategorietest"
	BrokerGarbage.locale.PTCategoryTestSubTitle = "Wenn du unsicher bist, warum ein Item irgendwo auftaucht oder welche Items zu welcher Kategorie zählen, kannst du das hier testen."
	BrokerGarbage.locale.PTCategoryTestExplanation = "Wähle einfach unten eine Kategorie aus und es wird dir alle Gegenstände aus deinem Inventar anzeigen, die dazuzählen.\nKategoriedaten kommen von LPT und nicht Broker_Garbage."
	BrokerGarbage.locale.PTCategoryTestDropdownTitle = "Kategorie, die getestet werden soll"
	BrokerGarbage.locale.PTCategoryTestDropdownText = "Wähle eine Kategorie"
end