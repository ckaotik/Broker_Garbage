-- German localisation file
_, BrokerGarbage = ...

if GetLocale() == "deDE" then
	BrokerGarbage.locale.label = "Kein Müll"
	
	-- Chat Messages
	BrokerGarbage.locale.sellAndRepair = "Müll für %1$s verkauft, repariert für %2$s. Änderung: %3$s."
	BrokerGarbage.locale.repair = "Repariert für %s."
	BrokerGarbage.locale.sell = "Müll verkauft für %s."
	
	BrokerGarbage.locale.addedTo_exclude = "%s zur Behalten-Liste hinzugefügt."
	BrokerGarbage.locale.addedTo_forceVendorPrice = "Für %s wird nun nur der Händlerpreis genutzt."
	BrokerGarbage.locale.addedTo_include = "%s zur Müll-Liste hinzugefügt."
	BrokerGarbage.locale.addedTo_autoSellList = "%s wird bei Händlern automatisch verkauft."
	BrokerGarbage.locale.itemAlreadyOnList = "%s ist bereits auf dieser Liste!"
	BrokerGarbage.locale.limitSet = "Für %s wurde das Limit auf %d gesetzt."
	BrokerGarbage.locale.itemDeleted = "%1$sx%2$d wurde gelöscht."
	BrokerGarbage.locale.couldNotRepair = "Konnte nicht reparieren, da du nicht genug Geld hast. Du brauchst %s."
	
	BrokerGarbage.locale.listsUpdatedPleaseCheck = "Die Listeneinstellungen wurden geändert. Bitte sieh in den Einstellungen nach, ob sie für dich passend sind."
	BrokerGarbage.locale.slashCommandHelp = [[Folgende Kommandos werden unterstützt:
/garbage |cffc0c0c0config|r öffnet die Optionen.
/garbage |cffc0c0c0format |cffc0c0ffformatstring|r lässt dich das Format der LDB Anzeige anpassen, |cffc0c0c0 format reset|r setzt es zurück.
/garbage |cffc0c0c0limit |cffc0c0ffitemLink/ID Anzahl|r setzt ein Limit für das gewählte Item für den aktuellen Charakter.
/garbage |cffc0c0c0globallimit |cffc0c0ffitemLink/ID Anzahl|r setzt ein Limit für alle Charaktere.
/garbage |cffc0c0c0value |cffc0c0ffWertInKupfer|r setzt den Itemwert, ab dem Items gelootet werden (benötigt den Loot Manager).]]
	BrokerGarbage.locale.minValueSet = "Mindestwert für items wurde auf %s gesetzt."
	BrokerGarbage.locale.minSlotsSet = "Der Loot Manager wird versuchen, mindestens %s Inventarplätze frei halten."
	BrokerGarbage.locale.invalidArgument = "Ungültiges Argument. Bitte überprüfe deine Eingabe!"
	
	BrokerGarbage.locale.GlobalSetting = "\n|cffffff9aDiese Einstellung ist global."
	
	-- Tooltip
	BrokerGarbage.locale.headerRightClick = "Rechts-Klick: Optionen"
	BrokerGarbage.locale.headerShiftClick = "SHIFT-Klick: Zerstören"
	BrokerGarbage.locale.headerCtrlClick = "STRG-Klick: Behalten"
	BrokerGarbage.locale.moneyLost = "Gold verloren:"
	BrokerGarbage.locale.moneyEarned = "Gold verdient:"
	BrokerGarbage.locale.noItems = "Keine Items zum Löschen."
	BrokerGarbage.locale.increaseTreshold = "Erhöhe die Item Qualität"
	
	BrokerGarbage.locale.categoriesHeading = "Kategorien"
	BrokerGarbage.locale.LPTNotLoaded = "LibPeriodicTable nicht aktiv"
	
	BrokerGarbage.locale.autoSellTooltip = "Müll für %s verkaufen"
	BrokerGarbage.locale.reportNothingToSell = "Nichts zu verkaufen!"
	
	-- Statistics Frame
	BrokerGarbage.locale.StatisticsHeading = "Statistiken"
	BrokerGarbage.locale.ResetStatistic = "|cffffffffKlicke|r um diese Statistik zurückzusetzen.\n|cFFff0000Warnung: Dies lässt sich nicht tückgängig machen!."
	
	BrokerGarbage.locale.MemoryUsageTitle = "Speicherverbrauch (kB)"
	BrokerGarbage.locale.CollectMemoryUsageTooltip = "|cffffffffKlicke|r um Blizzards Garbage Collector manuell zu starten."
	
	BrokerGarbage.locale.GlobalStatisticsHeading = "Globale Geldstatistiken:"
	BrokerGarbage.locale.AverageSellValueTitle = "Durchschnittl. Verkaufswert"
	BrokerGarbage.locale.AverageSellValueTooltip = "Durchschnittswert, den du für ein Item erhalten hast. Berechnet aus Gesamtverdienst/Anzahl verkaufter Items"
	BrokerGarbage.locale.AverageDropValueTitle = "Durchschnittl. weggeworfen"
	BrokerGarbage.locale.AverageDropValueTooltip = "Durchschnittswert, den du durch Wegwerfen von Items verloren hast. Berechnet aus Gesamtverlust/Anzahl weggeworfener Items"
	BrokerGarbage.locale.GlobalMoneyEarnedTitle = "Gesamtverdienst"
	BrokerGarbage.locale.GlobalMoneyLostTitle = "Gesamtverlust"
	BrokerGarbage.locale.GlobalItemsSoldTitle = "Items verkauft"
	BrokerGarbage.locale.ItemsDroppedTitle = "Items weggeworfen"
	
	BrokerGarbage.locale.LocalStatisticsHeading = "Charakter-Statistik von %s:"
	BrokerGarbage.locale.StatisticsLocalAmountEarned = "Verdienst"
	BrokerGarbage.locale.StatisticsLocalAmountLost = "Verlust"
	
	BrokerGarbage.locale.ResetAllText = "Alle Zurücksetzen"
	BrokerGarbage.locale.ResetAllTooltip = "|cffffffffKlicke|r um alle charakterspezifischen Statistiken zu löschen. |cffffffffSHIFT-Klicke|r um alle globalen Statistiken zu löschen."
	
	BrokerGarbage.locale.AuctionAddon = "Auktionsaddon"
	BrokerGarbage.locale.AuctionAddonTooltip = "Broker_Garbage nutzt Auktionswerte von diesem Addon. Wurde kein Addon gefunden, kann es trotzdem sein, dass ein Addon vorhanden ist, das Broker_Garbage nicht kennt"
	BrokerGarbage.locale.unknown = "Unbekannt"	-- refers to auction addon
	BrokerGarbage.locale.na = "Nicht vorhanden"
	
	-- Basic Options Frame
	BrokerGarbage.locale.BasicOptionsTitle = "Allgemein"
	BrokerGarbage.locale.BasicOptionsText = "Möchtest du einmal nicht automatisch verkaufen/reparieren? Halte SHIFT (je nach Einstellung) gedrückt, wenn du den Händler ansprichst!"
	
	BrokerGarbage.locale.GroupBehavior = "Verhalten"
	BrokerGarbage.locale.GroupTresholds = "Grenzwerte"
	BrokerGarbage.locale.GroupDisplay = "Anzeige"
	BrokerGarbage.locale.GroupTooltip = "Tooltip"
	
	BrokerGarbage.locale.autoSellTitle = "Autom. Verkaufen"
	BrokerGarbage.locale.autoSellText = "Wenn ausgewählt, werden graue Gegenstände automatisch beim Händler verkauft."
	
	BrokerGarbage.locale.showAutoSellIconTitle = "Händlericon anzeigen"
	BrokerGarbage.locale.showAutoSellIconText = "Auswählen um bei Händlern ein Icon zum automatischen Verkaufen anzuzeigen"
	
	BrokerGarbage.locale.showNothingToSellTitle = "Nichts zu verkaufen"
	BrokerGarbage.locale.showNothingToSellText = "Auswählen um bei Besuch eines Händlers eine Nachricht auszugegeben, falls es nichts zu verkaufen gibt"
	
	BrokerGarbage.locale.autoRepairTitle = "Autom. Reparieren"
	BrokerGarbage.locale.autoRepairText = "Auswählen um deine Ausrüstung automatisch bei Händlern zu reparieren"
	
	BrokerGarbage.locale.autoRepairGuildTitle = "selbst zahlen"
	BrokerGarbage.locale.autoRepairGuildText = "Auswählen um niemals auf Gildenkosten zu reparieren"
	
	BrokerGarbage.locale.showLostTitle = "Zeige verlorenes Gold"
	BrokerGarbage.locale.showLostText = "Auswählen um im Tooltip die Zeile 'Verlorenes Gold' anzuzeigen"
	
	BrokerGarbage.locale.showSourceTitle = "Zeige Preisquelle"
	BrokerGarbage.locale.showSourceText = "Auswählen um im Tooltip als letzte Spalte die Preisquelle anzuzeigen"
	
	BrokerGarbage.locale.showEarnedTitle = "Zeige verdientes Gold"
	BrokerGarbage.locale.showEarnedText = "Auswählen um im Tooltip die Zeile 'Verdientes Gold' anzuzeigen"
	
	BrokerGarbage.locale.dropQualityTitle = "Höchstens wegwerfen bis"
	BrokerGarbage.locale.dropQualityText = "Wähle bis zu welcher Qualität Items zum Löschen vorgeschlagen werden. Standard: Schlecht"
	
	BrokerGarbage.locale.moneyFormatTitle = "Geld Anzeigeformat"
	BrokerGarbage.locale.moneyFormatText = "Ändere die Art, wie Geldbeträge angezeigt werden."
	
	BrokerGarbage.locale.maxItemsTitle = "Anzahl an Items"
	BrokerGarbage.locale.maxItemsText = "Lege fest, wie viele Zeilen im Tooltip angezeigt werden. Standard: 9"
	
	BrokerGarbage.locale.maxHeightTitle = "Max. Höhe"
	BrokerGarbage.locale.maxHeightText = "Lege fest, wie hoch der Tooltip sein darf. Standard: 220"
	
	BrokerGarbage.locale.sellNotUsableTitle = "Ausrüstung verkaufen"
	BrokerGarbage.locale.sellNotUsableText = "Auswählen um Broker_Garbage Ausrüstung, die du niemals tragen kannst, automatisch verkaufen zu lassen.\n(inaktiv bei Verzauberern, wirkt nur für seelengebundene Items)"
	
	BrokerGarbage.locale.SNUMaxQualityTitle = "Höchstens verkaufen bis"
	BrokerGarbage.locale.SNUMaxQualityText = "Wähle die maximale Itemqualität, bei der unnütze Ausrüstung verkauft werden soll."
	
	BrokerGarbage.locale.enchanterTitle = "Verzauberer"
	BrokerGarbage.locale.enchanterTooltip = "Auswählen wenn du einen Verzauberer hast/kennst. Wenn aktiviert, wird Broker_Garbage Entzauberpreise verwenden, welche in der Regel höher sind als Händlerpreise."
	
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
	BrokerGarbage.locale.LDBNoJunkTextTooltip = "Nutze diese Einstellung, um den Text zu ändern, der angezeigt wird, wenn du keinen Müll hast."
	BrokerGarbage.locale.ResetToDefault = "Auf den Standardwert zurücksetzen"
	BrokerGarbage.locale.LDBDisplayTextHelpTooltip = [[Schnellhilfe:
[itemname] - Itemlink
[itemcount] - Item Anzahl
[itemvalue] - Itemwert
[freeslots] - freier Taschenplatz
[totalslots] - Gesamttaschenplatz
[junkvalue] - Verkaufswert
[bagspacecolor]...[endcolor] zum färben]]
		
	-- List Options Panel
	BrokerGarbage.locale.LOTitle = "Listen"
	BrokerGarbage.locale.LOSubTitle = [[Wenn du Hilfe brauchst, klicke das "?"-Tab an.

|cffffd200Müll|r: Diese Liste beinhaltet Items, die weggeworfen werden können.
|cffffd200Behalten|r: Items auf dieser Liste werden nie weggeworfen.
|cffffd200Händlerpreis|r: Items nutzen keine Auktionspreise. (immer global!)
|cffffd200Verkaufen|r: Diese Items werden bei Händlern automatisch verkauft.]]

	BrokerGarbage.locale.defaultListsText = "Standardlisten"
	BrokerGarbage.locale.defaultListsTooltip = "|cffffffffKlicke|r, um manuell die lokalen Standardeinträge für Listen einzufügen.\n|cffffffffRechtsklick|r um auch die globalen Einträge zu erstellen."
	
	BrokerGarbage.locale.LOTabTitleInclude = "Müll"
	BrokerGarbage.locale.LOTabTitleExclude = "Behalten"
	BrokerGarbage.locale.LOTabTitleVendorPrice = "Händlerpreis"
	BrokerGarbage.locale.LOTabTitleAutoSell = "Verkaufen"
	
	BrokerGarbage.locale.LOIncludeAutoSellText = "Müll-Items verkaufen"
	BrokerGarbage.locale.LOIncludeAutoSellTooltip = "Aktivieren, um Items von deiner Müll-Liste automatisch beim Händler zu verkaufen. Items ohne Wert werden ignoriert."
	
	BrokerGarbage.locale.LOUseRealValues = "Echte Werte für Müll-Items"
	BrokerGarbage.locale.LOUseRealValuesTooltip = "Aktivieren, um für Müll-Items den tatsächlichen Preis zu nutzen, anstatt sie auf 0c zu setzen."

	BrokerGarbage.locale.listsBestUse = [[|cffffd200Listen-Beispiele|r
Die Standardlisten geben eine Hilfestellung, was auf welcher Liste nützlich sein könnte.
Setze erst alle Items, die du auf jeden Fall behalten möchtest, auf die |cffffd200Behalten-Liste|r. Denke auch daran, dass es Kategorien (s.u.) gibt! Ist der LootManager aktiv, wird er Items von dieser Liste immer plündern.
|cffAAAAAAz.B. Klassenreagenzien, Fläschchen|r
Dinge, von denen du weißt, dass sie sorglos weggeworfen werden können, gehören auf die |cffffd200Müll-Liste|r.
|cffAAAAAAz.B. Herbeigezauberter Manakeks, Argentumlanze|r
Sollte ein Item einen ungewollt hohen Wert zugewiesen bekommen, setze das Item auf die |cffffd200Händlerpreis-Liste|r. Diese Items werden nur den Händlerpreis nutzen.
|cffAAAAAAz.B. Fischöl|r
Auf die |cffffd200Verkaufen-Liste|r kannst du alles setzen, was Broker_Garbage verkaufen soll.
|cffAAAAAAz.B. Wasser (als Krieger), Alterachochkäse|r]]

	BrokerGarbage.locale.listsSpecialOptions = [[|cffffd200Spezielle Müll-Listen Optionen|r
|cffffd200Verkaufen|r: Diese Einstellung ist nützlich für all diejenigen, die keine Unterscheidung zwischen Müll und zu verkaufenden Items treffen wollen. Wenn ausgewählt, werden sowohl die Items aus der Müll-Liste als auch die aus der Verkaufen-Liste bei Händlern verkauft.
|cffffd200Echte Werte|r: Diese Einstellungen ändert das Verhalten der Müll-Liste. Standardmäßig (deaktiviert) bekommen Müll-Items einen Wert von 0c zugewiesen (beeinflusst nicht die Statistiken) und erscheinen damit als erstes im Tooltip. Wenn aktiviert, behalten diese Items ihren normalen Wert und tauchen entsprechend später in der Liste auf.]]
	
	BrokerGarbage.locale.iconButtonsUse = [[|cffffd200Item-Buttons|r
Angezeigt wird entweder das Icon des Items, ein Zahnrad, wenn es sich um eine Kategorie handelt, oder ein Fragezeichen, wenn der Server das Item nicht finden kann.
Oben links jedes Buttons kann ein "G" stehen. Ist dies der Fall, ist das entsprechende Item auf der |cffffd200globalen Liste|r, d.h. diese Regel gilt für alle Charaktere.
Items auf der Müll-Liste können ein |cffffd200Limit|r haben. Dies wird als kleine Zahl in der unteren rechten Ecke angezeigt. Zum Ändern nutze das |cffffd200Mausrad|r über dem Button. Diese Items werden erst gelöscht, sollte das Limit überschritten werden.]]
	
	BrokerGarbage.locale.actionButtonsUse = [[|cffffd200Aktions-Buttons|r
Unterhalb dieses Fensters siehst du 5 Buttons und eine Suchleiste.
|TInterface\Icons\Spell_ChargePositive:18|t |cffffd200Plus|r: Hier kannst du Items zu der angezeigten Liste hinzufügen. Ziehe dazu einfach ein Item auf das Plus. Um eine |cffffd200Kategorie|r hinzuzufügen, rechtsklicke das Plus und wähle dann in dem neuen Menü eine Kategorie aus.
|cffAAAAAAz.B. "Tradeskill > Recipe", "Misc > Key"|r
|TInterface\Icons\Spell_ChargeNegative:18|t |cffffd200Minus|r: Markiere Items aus der Liste (anklicken). Beim Klick auf das Minus werden diese Items von der Liste entfernt.
|TInterface\Icons\INV_Misc_GroupLooking:18|t |cffffd200Lokal|r: Markierte Items werden auf die lokale Liste gesetzt, gelten also nur für diesen Charakter.
|TInterface\Icons\INV_Misc_GroupNeedMore:18|t |cffffd200Global|r: Analog zu Lokal, nur werden hierbei die Items auf die globale Liste gesetzt, die Regeln gelten damit für alle Charaktere.
|TInterface\Buttons\UI-GroupLoot-Pass-UP:18|t |cffffd200Leeren|r: Ein Klick auf diesen Button leert die charakterspezifischen Regeln dieser Liste. Shift-Klick leert die accountweiten Regeln. |cffff0000Mit Vorsicht benutzen!|r]]
	
	BrokerGarbage.locale.LOPlus = "Füge Items zu dieser Liste hinzu, indem du sie hierher |cffffffffziehst|r/hier |cffffffffablegst|r.\n|cffffffffRechtsklick|r, um Kategorien hinzuzufügen!"
	BrokerGarbage.locale.LOMinus = "Wähle oben die Items, die du von dieser Liste entfernen willst. Dann |cffffffffklicke|r hier."
	BrokerGarbage.locale.LODemote = "|cffffffffKlicke|r um alle markierten Items als charakterspezifische Regel zu nutzen."
	BrokerGarbage.locale.LOPromote = "|cffffffffKlicke|r um alle markierten Items als globale Regel zu nutzen."
	BrokerGarbage.locale.LOEmptyList = "|cffff0000Achtung!|r\n|cffffffffKlicke|r, um die lokalen Einträge dieser Liste zu löschen.\n"..
		"|cffffffffShift-Klicke|r, um die globalen Einträge zu löschen."
	BrokerGarbage.locale.search = "Suchen..."
	
	-- LibPeriodicTable category testing
	BrokerGarbage.locale.PTCategoryTest = "Kategorientest"
	BrokerGarbage.locale.PTCategoryTestExplanation = "Wähle unten eine Kategorie aus um dir alle Gegenstände aus deinem Inventar anzeigen zu lassen, die dazuzählen.\nKategoriedaten kommen von LibPeriodicTable."
	BrokerGarbage.locale.PTCategoryTestDropdownTitle = "Kategorie, die getestet werden soll"
	BrokerGarbage.locale.PTCategoryTestDropdownText = "Wähle eine Kategorie"
end