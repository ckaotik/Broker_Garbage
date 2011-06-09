-- German localisation file
local _, BGC = ...

if GetLocale() == "deDE" then
	BGC.locale.GlobalSetting = "\n|cffffff9aDiese Einstellung ist global."
	
	-- Chat Messages
	BGC.locale.addedTo_exclude = "%s zur Behalten-Liste hinzugefügt."
	BGC.locale.addedTo_forceVendorPrice = "Für %s wird nun nur der Händlerpreis genutzt."
	BGC.locale.addedTo_include = "%s zur Müll-Liste hinzugefügt."
	BGC.locale.addedTo_autoSellList = "%s wird bei Händlern automatisch verkauft."
	
	BGC.locale.itemAlreadyOnList = "%s ist bereits auf dieser Liste!"
	BGC.locale.limitSet = "Für %s wurde das Limit auf %d gesetzt."
	BGC.locale.minValueSet = "Mindestwert für items wurde auf %s gesetzt."
	BGC.locale.minSlotsSet = "Der Loot Manager wird versuchen, mindestens %s Inventarplätze frei halten."
	
	BGC.locale.slashCommandHelp = [[Folgende Kommandos werden unterstützt:
/garbage |cffc0c0c0config|r öffnet die Optionen.
/garbage |cffc0c0c0format |cffc0c0ffformatstring|r lässt dich das Format der LDB Anzeige anpassen, |cffc0c0c0 format reset|r setzt es zurück.
/garbage |cffc0c0c0limit |cffc0c0ffitemLink/ID Anzahl|r setzt ein Limit für das gewählte Item für den aktuellen Charakter.
/garbage |cffc0c0c0globallimit |cffc0c0ffitemLink/ID Anzahl|r setzt ein Limit für alle Charaktere.
/garbage |cffc0c0c0value |cffc0c0ffWertInKupfer|r setzt den Itemwert, ab dem Items gelootet werden (benötigt den Loot Manager).
/garbage |cffc0c0c0freeslots |cffc0c0ffnumber|r setzt die Anzahl an Taschenplätzen, die frei bleiben sollen.]]
	BGC.locale.invalidArgument = "Ungültiges Argument. Bitte überprüfe deine Eingabe!"
	
	-- Tooltip
	BGC.locale.categoriesHeading = "Kategorien"
	BGC.locale.LPTNotLoaded = "LibPeriodicTable nicht aktiv"
	
	-- Special types
	BGC.locale.tooltipHeadingOther = "Anderes"
	BGC.locale.equipmentManager = "Equipment Manager"
	BGC.locale.armorClass = "Rüstungsklasse"
	
	-- Statistics Frame
	BGC.locale.StatisticsHeading = "Statistiken"
	BGC.locale.ResetStatistic = "|cffffffffKlicke|r um diese Statistik zurückzusetzen.\n|cFFff0000Warnung: Dies lässt sich nicht rückgängig machen!."
	
	BGC.locale.MemoryUsageTitle = "Speicherverbrauch (kB)"
	BGC.locale.CollectMemoryUsageTooltip = "|cffffffffKlicke|r um Blizzards Garbage Collector manuell zu starten."
	
	BGC.locale.GlobalStatisticsHeading = "Globale Geldstatistiken:"
	BGC.locale.AverageSellValueTitle = "Durchschnittl. Verkaufswert"
	BGC.locale.AverageSellValueTooltip = "Durchschnittswert, den du für ein Item erhalten hast. Berechnet aus Gesamtverdienst/Anzahl verkaufter Items"
	BGC.locale.AverageDropValueTitle = "Durchschnittl. weggeworfen"
	BGC.locale.AverageDropValueTooltip = "Durchschnittswert, den du durch Wegwerfen von Items verloren hast. Berechnet aus Gesamtverlust/Anzahl weggeworfener Items"
	BGC.locale.GlobalMoneyEarnedTitle = "Gesamtverdienst"
	BGC.locale.GlobalMoneyLostTitle = "Gesamtverlust"
	BGC.locale.GlobalItemsSoldTitle = "Items verkauft"
	BGC.locale.ItemsDroppedTitle = "Items weggeworfen"
	
	BGC.locale.LocalStatisticsHeading = "Charakter-Statistik von %s:"
	BGC.locale.StatisticsLocalAmountEarned = "Verdienst"
	BGC.locale.StatisticsLocalAmountLost = "Verlust"
	
	BGC.locale.ResetAllText = "Alle Zurücksetzen"
	BGC.locale.ResetAllTooltip = "|cffffffffKlicke|r um alle charakterspezifischen Statistiken zu löschen. |cffffffffSHIFT-Klicke|r um alle globalen Statistiken zu löschen."
	
	BGC.locale.AuctionAddon = "Auktionsaddon"
	BGC.locale.AuctionAddonTooltip = "Broker_Garbage nutzt Auktionswerte von diesem Addon. Wurde kein Addon gefunden, kann es trotzdem sein, dass ein Addon vorhanden ist, das Broker_Garbage nicht kennt"
	BGC.locale.unknown = "Unbekannt"	-- refers to auction addon
	BGC.locale.na = "Nicht vorhanden"
	
	-- Basic Options Frame
	BGC.locale.BasicOptionsTitle = "Allgemein"
	BGC.locale.BasicOptionsText = "Möchtest du einmal nicht automatisch verkaufen/reparieren? Halte SHIFT (je nach Einstellung) gedrückt, wenn du den Händler ansprichst!"
	
	BGC.locale.GroupBehavior = "Verhalten"
	BGC.locale.GroupTresholds = "Grenzwerte"
	BGC.locale.GroupDisplay = "Anzeige"
	BGC.locale.GroupTooltip = "Tooltip"
	
	BGC.locale.autoSellTitle = "Autom. Verkaufen"
	BGC.locale.autoSellText = "Wenn ausgewählt, werden graue Gegenstände automatisch beim Händler verkauft."
	
	BGC.locale.showAutoSellIconTitle = "Händlericon anzeigen"
	BGC.locale.showAutoSellIconText = "Auswählen um bei Händlern ein Icon zum automatischen Verkaufen anzuzeigen"
	
	BGC.locale.showNothingToSellTitle = "Nichts zu verkaufen"
	BGC.locale.showNothingToSellText = "Auswählen um bei Besuch eines Händlers eine Nachricht auszugegeben, falls es nichts zu verkaufen gibt"
	
	BGC.locale.autoRepairTitle = "Autom. Reparieren"
	BGC.locale.autoRepairText = "Auswählen um deine Ausrüstung automatisch bei Händlern zu reparieren"
	
	BGC.locale.autoRepairGuildTitle = "Gildengold nutzen"
	BGC.locale.autoRepairGuildText = "Auswählen um wenn möglich auf Gildenkosten zu reparieren"
	
	BGC.locale.showSourceTitle = "Quelle"
	BGC.locale.showSourceText = "Auswählen um im Tooltip als letzte Spalte die Preisquelle anzuzeigen"
	
	BGC.locale.showIconTitle = "Icon"
	BGC.locale.showIconText = "Auswählen um im Tooltip vor dem Itemlink das jeweilige Icon anzuzeigen"
		
	BGC.locale.showEarnedTitle = "Gewinn"
	BGC.locale.showEarnedText = "Auswählen um im Tooltip die Zeile 'Verdientes Gold' anzuzeigen"
	
	BGC.locale.showLostTitle = "Verlust"
	BGC.locale.showLostText = "Auswählen um im Tooltip die Zeile 'Verlorenes Gold' anzuzeigen"
	
	BGC.locale.warnContainersTitle = "Behälter"
	BGC.locale.warnContainersText = "Wenn ausgewählt wird Broker_Garbage eine Warnung ausgeben, solltest du ungeöffnete Behälter bei dir haben."
	
	BGC.locale.warnClamsTitle = "Muschel"
	BGC.locale.warnClamsText = "Wenn ausgewählt wird Broker_Garbage eine Warnung ausgeben, wenn du ungeöffnete Muscheln im Inventar hast.\nMuscheln lassen sich stapeln, du verlierst durch deaktivieren dieser Option keinen Taschenplatz."
	
	BGC.locale.dropQualityTitle = "Höchstens wegwerfen bis"
	BGC.locale.dropQualityText = "Wähle bis zu welcher Qualität Items zum Löschen vorgeschlagen werden. Standard: Schlecht"
	
	BGC.locale.moneyFormatTitle = "Geld Anzeigeformat"
	BGC.locale.moneyFormatText = "Ändere die Art, wie Geldbeträge angezeigt werden."
	
	BGC.locale.maxItemsTitle = "Anzahl an Items"
	BGC.locale.maxItemsText = "Lege fest, wie viele Zeilen im Tooltip angezeigt werden. Standard: 9"
	
	BGC.locale.maxHeightTitle = "Max. Höhe"
	BGC.locale.maxHeightText = "Lege fest, wie hoch der Tooltip sein darf. Standard: 220"
	
	BGC.locale.sellNotUsableTitle = "Ausrüstung verkaufen"
	BGC.locale.sellNotUsableText = "Auswählen um Broker_Garbage seelengebundene Ausrüstung, die du niemals tragen kannst, automatisch verkaufen zu lassen.\n(inaktiv bei Verzauberern)"
	
	BGC.locale.TopFitOldItem = "Überholte Rüstung"
	BGC.locale.TopFitOldItemText = "Wenn das Addon TopFit geladen ist, kann BG Items, die dir in keinem Rüstungsset Vorteile bringen, automatisch verkaufen."
	
	BGC.locale.SNUMaxQualityTitle = "Höchstens verkaufen bis"
	BGC.locale.SNUMaxQualityText = "Wähle die maximale Itemqualität, bei der unnütze/überholte Ausrüstung verkauft werden soll."
	
	BGC.locale.enchanterTitle = "Verzauberer"
	BGC.locale.enchanterTooltip = "Auswählen wenn du einen Verzauberer hast/kennst. Wenn aktiviert, wird Broker_Garbage Entzauberpreise verwenden, welche in der Regel höher sind als Händlerpreise."
	
	BGC.locale.DKTitle = "Temp. deaktivieren mit"
	BGC.locale.DKTooltip = "Wähle die Taste, die Aktionen von Broker_Garbage temporär deaktiviert."
	BGC.locale.disableKeys = {
		["None"] = "Kein",
		["SHIFT"] = "SHIFT",
		["ALT"] = "ALT",
		["CTRL"] = "STRG",
	}
	
	BGC.locale.LDBDisplayTextTitle = "LDB Anzeigetexte"
	BGC.locale.LDBDisplayTextTooltip = "Nutze diese Einstellung, um den Text zu ändern, den du in deinem LDB Display siehst."
	BGC.locale.LDBNoJunkTextTooltip = "Nutze diese Einstellung, um den Text zu ändern, der angezeigt wird, wenn du keinen Müll hast."
	BGC.locale.ResetToDefault = "Auf den Standardwert zurücksetzen"
	BGC.locale.LDBDisplayTextHelpTooltip = [[|cffffffffBasistags:|r
[itemname] - Itemlink
[itemicon] - Itemicon
[itemcount] - Item Anzahl
[itemvalue] - Itemwert
[junkvalue] - Verkaufswert

|cffffffffInventarplatz Tags:|r
[freeslots] - freier Taschenplatz
[totalslots] - Gesamttaschenplatz
[basicfree],[specialfree] - frei
[basicslots],[specialslots] - total

|cffffffffFarbtags:|r
[bagspacecolor]... - alle Taschen
[basicbagcolor]... - nur allgemein
[specialbagcolor]... - nur spezial
...[endcolor] beendet Textfärbung]]

	-- List Options Panel
	BGC.locale.LOTitle = "Listen"
	BGC.locale.LOSubTitle = [[Wenn du Hilfe brauchst, klicke das "?"-Tab an.

|cffffd200Müll|r: Diese Liste beinhaltet Items, die weggeworfen werden können.
|cffffd200Behalten|r: Items auf dieser Liste werden nie weggeworfen.
|cffffd200Händlerpreis|r: Items nutzen keine Auktionspreise. (immer global!)
|cffffd200Verkaufen|r: Diese Items werden bei Händlern automatisch verkauft.]]

	BGC.locale.defaultListsText = "Standardlisten"
	BGC.locale.defaultListsTooltip = "|cffffffffKlicke|r, um manuell die lokalen Standardeinträge für Listen einzufügen.\n|cffffffffRechtsklick|r um auch die globalen Einträge zu erstellen."
	
	BGC.locale.LOTabTitleInclude = "Müll"
	BGC.locale.LOTabTitleExclude = "Behalten"
	BGC.locale.LOTabTitleVendorPrice = "Händlerpreis"
	BGC.locale.LOTabTitleAutoSell = "Verkaufen"
	
	BGC.locale.LOIncludeAutoSellText = "Müll-Items verkaufen"
	BGC.locale.LOIncludeAutoSellTooltip = "Aktivieren, um Items von deiner Müll-Liste automatisch beim Händler zu verkaufen. Items ohne Wert werden ignoriert."
	
	BGC.locale.LOUseRealValues = "Echte Werte für Müll-Items"
	BGC.locale.LOUseRealValuesTooltip = "Aktivieren, um für Müll-Items den tatsächlichen Preis zu nutzen, anstatt sie auf 0c zu setzen."

	BGC.locale.listsBestUse = [[|cffffd200Listen-Beispiele|r
Die Standardlisten geben eine Hilfestellung, was auf welcher Liste nützlich sein könnte.
Setze erst alle Items, die du auf jeden Fall behalten möchtest, auf die |cffffd200Behalten-Liste|r. Denke auch daran, dass es Kategorien (s.u.) gibt! Ist der LootManager aktiv, wird er Items von dieser Liste immer plündern.
|cffAAAAAAz.B. Klassenreagenzien, Fläschchen|r
Dinge, von denen du weißt, dass sie sorglos weggeworfen werden können, gehören auf die |cffffd200Müll-Liste|r.
|cffAAAAAAz.B. Herbeigezauberter Manakeks, Argentumlanze|r
Sollte ein Item einen ungewollt hohen Wert zugewiesen bekommen, setze das Item auf die |cffffd200Händlerpreis-Liste|r. Diese Items werden nur den Händlerpreis nutzen.
|cffAAAAAAz.B. Fischöl|r
Auf die |cffffd200Verkaufen-Liste|r kannst du alles setzen, was Broker_Garbage verkaufen soll.
|cffAAAAAAz.B. Wasser (als Krieger), Alterachochkäse|r]]

	BGC.locale.listsSpecialOptions = [[|cffffd200Spezielle Müll-Listen Optionen|r
|cffffd200Verkaufen|r: Diese Einstellung ist nützlich für all diejenigen, die keine Unterscheidung zwischen Müll und zu verkaufenden Items treffen wollen. Wenn ausgewählt, werden sowohl die Items aus der Müll-Liste als auch die aus der Verkaufen-Liste bei Händlern verkauft.
|cffffd200Echte Werte|r: Diese Einstellungen ändert das Verhalten der Müll-Liste. Standardmäßig (deaktiviert) bekommen Müll-Items einen Wert von 0c zugewiesen (beeinflusst nicht die Statistiken) und erscheinen damit als erstes im Tooltip. Wenn aktiviert, behalten diese Items ihren normalen Wert und tauchen entsprechend später in der Liste auf.]]
	
	BGC.locale.iconButtonsUse = [[|cffffd200Item-Buttons|r
Angezeigt wird entweder das Icon des Items, ein Zahnrad, wenn es sich um eine Kategorie handelt, oder ein Fragezeichen, wenn der Server das Item nicht finden kann.
Oben links jedes Buttons kann ein "G" stehen. Ist dies der Fall, ist das entsprechende Item auf der |cffffd200globalen Liste|r, d.h. diese Regel gilt für alle Charaktere.
Items auf der Müll-Liste können ein |cffffd200Limit|r haben. Dies wird als kleine Zahl in der unteren rechten Ecke angezeigt. Zum Ändern nutze das |cffffd200Mausrad|r über dem Button. Diese Items werden erst gelöscht, sollte das Limit überschritten werden.]]
	
	BGC.locale.actionButtonsUse = [[|cffffd200Aktions-Buttons|r
Unterhalb dieses Fensters siehst du 5 Buttons und eine Suchleiste.
|TInterface\Icons\Spell_ChargePositive:18|t |cffffd200Plus|r: Hier kannst du Items zu der angezeigten Liste hinzufügen. Ziehe dazu einfach ein Item auf das Plus. Um eine |cffffd200Kategorie|r hinzuzufügen, rechtsklicke das Plus und wähle dann in dem neuen Menü eine Kategorie aus.
|cffAAAAAAz.B. "Tradeskill > Recipe", "Misc > Key"|r
|TInterface\Icons\Spell_ChargeNegative:18|t |cffffd200Minus|r: Markiere Items aus der Liste (anklicken). Beim Klick auf das Minus werden diese Items von der Liste entfernt.
|TInterface\Icons\INV_Misc_GroupLooking:18|t |cffffd200Lokal|r: Markierte Items werden auf die lokale Liste gesetzt, gelten also nur für diesen Charakter.
|TInterface\Icons\INV_Misc_GroupNeedMore:18|t |cffffd200Global|r: Analog zu Lokal, nur werden hierbei die Items auf die globale Liste gesetzt, die Regeln gelten damit für alle Charaktere.
|TInterface\Buttons\UI-GroupLoot-Pass-UP:18|t |cffffd200Leeren|r: Ein Klick auf diesen Button leert die charakterspezifischen Regeln dieser Liste. Shift-Klick leert die accountweiten Regeln. |cffff0000Mit Vorsicht benutzen!|r]]
	
	BGC.locale.LOPlus = "Füge Items zu dieser Liste hinzu, indem du sie hierher |cffffffffziehst|r/hier |cffffffffablegst|r.\n|cffffffffRechtsklick|r, um Kategorien hinzuzufügen!"
	BGC.locale.LOMinus = "Wähle oben die Items, die du von dieser Liste entfernen willst. Dann |cffffffffklicke|r hier."
	BGC.locale.LODemote = "|cffffffffKlicke|r um alle markierten Items als charakterspezifische Regel zu nutzen."
	BGC.locale.LOPromote = "|cffffffffKlicke|r um alle markierten Items als globale Regel zu nutzen."
	BGC.locale.LOEmptyList = "|cffff0000Achtung!|r\n|cffffffffKlicke|r, um die lokalen Einträge dieser Liste zu löschen.\n"..
		"|cffffffffShift-Klicke|r, um die globalen Einträge zu löschen."
	BGC.locale.search = "Suchen..."
	
	-- LibPeriodicTable category testing
	BGC.locale.PTCategoryTest = "Kategorientest"
	BGC.locale.PTCategoryTestExplanation = "Wähle unten eine Kategorie aus um dir alle Gegenstände aus deinem Inventar anzeigen zu lassen, die dazuzählen.\nKategoriedaten kommen von LibPeriodicTable."
	BGC.locale.PTCategoryTestDropdownTitle = "Kategorie, die getestet werden soll"
	BGC.locale.PTCategoryTestDropdownText = "Wähle eine Kategorie"
end