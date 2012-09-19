-- German localisation file
local _, BGC = ...
local L = BGC.locale

if GetLocale() == "deDE" then
	L["disableKey_None"] = "Kein"
	L["disableKey_SHIFT"] = "SHIFT"
	L["disableKey_ALT"] = "ALT"
	L["disableKey_CTRL"] = "STRG"

	L["GlobalSetting"] = "\n|cffffff9aDiese Einstellung ist global."

	-- Chat Messages
	L["addedTo_exclude"] = "%s zur Behalten-Liste hinzugefügt."
	L["addedTo_forceVendorPrice"] = "Für %s wird nun nur der Händlerpreis genutzt."
	L["addedTo_include"] = "%s zur Müll-Liste hinzugefügt."
	L["addedTo_autoSellList"] = "%s wird bei Händlern automatisch verkauft."

	L["itemAlreadyOnList"] = "%s ist bereits auf dieser Liste!"
	L["limitSet"] = "Für %s wurde das Limit auf %d gesetzt."
	L["minValueSet"] = "Mindestwert für items wurde auf %s gesetzt."
	L["minSlotsSet"] = "Der Loot Manager wird versuchen, mindestens %s Inventarplätze frei halten."

	L["slashCommandHelp"] = [[unterstützt |cffee6622/garbage|r, |cffee6622/garb|r, |cffee6622/junk|r mit diesen Befehlen:
    |cFF36BFA8config|r öffnet die Optionen.
    |cFF36BFA8add|r |cFF2bff58<Liste>|r |cFF2bff58<Item>|r Item/Kategorie in eine Liste eintragen.
    |cFF36BFA8remove|r |cFF2bff58<Liste>|r |cFF2bff58<Item>|r Item/Kategorie von einer Liste entfernen.
        Mögliche Listen: |cFF2bff58keep|r (Behalten), |cFF2bff58junk|r (Müll), |cFF2bff58vendor|r (Verkaufen), |cFF2bff58forceprice|r (Festpreis)
    |cFF36BFA8update|r |cFF2bff58<itemID>|r Aktualisiere gespeicherte Daten
    |cFF36BFA8format|r |cFF2bff58<Text>|r setzt das LDB-Anzeigeformat, |cFF2bff58reset|r setzt es zurück.
    |cFF36BFA8categories|r |cFF2bff58<Item>|r Liste genutzter Kategorien mit diesem Item]]
	L["requiresLootManager"] = "Dieser Befehl benötigt den Loot Manager."
	L["updateCache"] = "Bitte aktualisiere die Item Caches via /garbage update"
	L["invalidArgument"] = "Ungültiges Argument. Bitte überprüfe deine Eingabe!"

	-- Tooltip
	L["categoriesHeading"] = "Kategorien"
	L["LPTNotLoaded"] = "LibPeriodicTable nicht aktiv"

	-- Special types
	L["tooltipHeadingOther"] = "Anderes"
	L["equipmentManager"] = "Equipment Manager"
	L["armorClass"] = "Rüstungsklasse"
	L["anythingCalled"] = "Items mit Namen"

	-- Statistics Frame
	L["StatisticsHeading"] = "Statistiken"
	L["ResetStatistic"] = "|cffffffffKlicke|r um diese Statistik zurückzusetzen.\n|cFFff0000Warnung: Dies lässt sich nicht rückgängig machen!."

	L["MemoryUsageTitle"] = "Speicherverbrauch (kB)"
	L["CollectMemoryUsageTooltip"] = "|cffffffffKlicke|r um Blizzards Garbage Collector manuell zu starten."

	L["GlobalStatisticsHeading"] = "Globale Geldstatistiken:"
	L["AverageSellValueTitle"] = "Durchschnittl. Verkaufswert"
	L["AverageSellValueTooltip"] = "Durchschnittswert, den du für ein Item erhalten hast. Berechnet aus Gesamtverdienst/Anzahl verkaufter Items"
	L["AverageDropValueTitle"] = "Durchschnittl. weggeworfen"
	L["AverageDropValueTooltip"] = "Durchschnittswert, den du durch Wegwerfen von Items verloren hast. Berechnet aus Gesamtverlust/Anzahl weggeworfener Items"
	L["GlobalMoneyEarnedTitle"] = "Gesamtverdienst"
	L["GlobalMoneyLostTitle"] = "Gesamtverlust"
	L["GlobalItemsSoldTitle"] = "Items verkauft"
	L["ItemsDroppedTitle"] = "Items weggeworfen"

	L["LocalStatisticsHeading"] = "Charakter-Statistik von %s:"
	L["StatisticsLocalAmountEarned"] = "Verdienst"
	L["StatisticsLocalAmountLost"] = "Verlust"

	L["ResetAllText"] = "Alle Zurücksetzen"
	L["ResetAllTooltip"] = "|cffffffffKlicke|r um alle charakterspezifischen Statistiken zu löschen. |cffffffffSHIFT-Klicke|r um alle globalen Statistiken zu löschen."

	L["AuctionAddon"] = "Auktionsaddon"
	L["AuctionAddonTooltip"] = "Broker_Garbage nutzt Auktionswerte von diesem Addon. Wurde kein Addon gefunden, kann es trotzdem sein, dass ein Addon vorhanden ist, das Broker_Garbage nicht kennt"
	L["unknown"] = "Unbekannt"	-- refers to auction addon
	L["na"] = "Nicht vorhanden"

	-- Basic Options Frame
	L["BasicOptionsTitle"] = "Allgemein"
	L["BasicOptionsText"] = "Möchtest du einmal nicht automatisch verkaufen/reparieren? Halte SHIFT (je nach Einstellung) gedrückt, wenn du den Händler ansprichst!"

	L["GroupBehavior"] = "Verhalten"
	L["GroupTresholds"] = "Schwellwerte"
	L["GroupDisplay"] = "Allg. Anzeige"
	L["GroupTooltip"] = "LDB Anzeige"
	L["GroupOutput"] = "Textausgabe"

	L["autoSellTitle"] = "Autom. Verkaufen"
	L["autoSellText"] = "Wenn ausgewählt, werden graue Gegenstände automatisch beim Händler verkauft."

	L["showAutoSellIconTitle"] = "Händlericon anzeigen"
	L["showAutoSellIconText"] = "Auswählen um bei Händlern ein Icon zum automatischen Verkaufen anzuzeigen"

	L["showItemTooltipLabelTitle"] = "Einordnung anzeigen"
	L["showItemTooltipLabelText"] = "Auswählen um die Einordnung von Broker_Garbage im Tooltip eines Gegenstands anzuzeigen."

	L["showItemTooltipDetailTitle"] = "Begründung anzeigen"
	L["showItemTooltipDetailText"] = "Auswählen um detaillierte Informationen von Broker_Garbage's Einordnung im Tooltip eines Gegenstands anzuzeigen."

	L["showNothingToSellTitle"] = "Nichts zu verkaufen"
	L["showNothingToSellText"] = "Auswählen um bei Besuch eines Händlers eine Nachricht auszugegeben, falls es nichts zu verkaufen gibt"

	L["autoRepairTitle"] = "Autom. Reparieren"
	L["autoRepairText"] = "Auswählen um deine Ausrüstung automatisch bei Händlern zu reparieren"

	L["autoRepairGuildTitle"] = "Gildengold nutzen"
	L["autoRepairGuildText"] = "Auswählen um wenn möglich auf Gildenkosten zu reparieren"

	L["showSourceTitle"] = "Quelle"
	L["showSourceText"] = "Auswählen um im Tooltip als letzte Spalte die Preisquelle anzuzeigen"

	L["showIconTitle"] = "Icon"
	L["showIconText"] = "Auswählen um im Tooltip vor dem Itemlink das jeweilige Icon anzuzeigen"

	L["showEarnedTitle"] = "Gewinn"
	L["showEarnedText"] = "Auswählen um im Tooltip die Zeile 'Verdientes Gold' anzuzeigen"

	L["showLostTitle"] = "Verlust"
	L["showLostText"] = "Auswählen um im Tooltip die Zeile 'Verlorenes Gold' anzuzeigen"

	L["warnContainersTitle"] = "Behälter"
	L["warnContainersText"] = "Wenn ausgewählt wird Broker_Garbage eine Warnung ausgeben, solltest du ungeöffnete Behälter bei dir haben."

	L["warnClamsTitle"] = "Muschel"
	L["warnClamsText"] = "Wenn ausgewählt wird Broker_Garbage eine Warnung ausgeben, wenn du ungeöffnete Muscheln im Inventar hast.\nMuscheln lassen sich stapeln, du verlierst durch deaktivieren dieser Option keinen Taschenplatz."

	L["dropQualityTitle"] = "Höchstens wegwerfen bis"
	L["dropQualityText"] = "Wähle bis zu welcher Qualität Items zum Löschen vorgeschlagen werden. Standard: Schlecht"

	L["moneyFormatTitle"] = "Geld Anzeigeformat"
	L["moneyFormatText"] = "Ändere die Art, wie Geldbeträge angezeigt werden."

	L["maxItemsTitle"] = "Anzahl an Items"
	L["maxItemsText"] = "Lege fest, wie viele Zeilen im Tooltip angezeigt werden. Standard: 9"

	L["maxHeightTitle"] = "Max. Höhe"
	L["maxHeightText"] = "Lege fest, wie hoch der Tooltip sein darf. Standard: 220"

	L["sellNotUsableTitle"] = "Unnützes verkaufen"
	L["sellNotUsableText"] = "Auswählen um Broker_Garbage seelengebundene Ausrüstung, die du niemals tragen kannst, automatisch verkaufen zu lassen.\n(inaktiv bei Verzauberern)"

	L["TopFitOldItem"] = "Altes verkaufen"
	L["TopFitOldItemText"] = "Wenn das Addon TopFit geladen ist, kann BG Items, die dir in keinem Rüstungsset Vorteile bringen, automatisch verkaufen."

	L["keepMaxItemLevelTitle"] = "Höchste GS behalten"
	L["keepMaxItemLevelText"] = "Auswählen um bei überholter Ausrüstung diejenige der höchsten Gegenstandsstufe nicht zu verkaufen."

	L["SNUMaxQualityTitle"] = "Höchstens verkaufen bis"
	L["SNUMaxQualityText"] = "Wähle die maximale Itemqualität, bei der unnütze/überholte Ausrüstung verkauft werden soll."

	L["enchanterTitle"] = "Entzauberpreise"
	L["enchanterTooltip"] = "Auswählen wenn du einen Verzauberer hast/kennst. Wenn aktiviert, wird Broker_Garbage Entzauberpreise verwenden, welche in der Regel höher sind als Händlerpreise."

	L["restackTitle"] = "Automatisch stapeln"
	L["restackTooltip"] = "Wenn ausgewählt wird Broker_Garbage automatisch die von dir beobachteten Gegenstände nach dem Plündern stapeln, um Platz zu schaffen."

	L["inDev"] = "In Entwicklung"

	L["sellLogTitle"] = "Verkäufe ausgeben"
	L["sellLogTooltip"] = "Auswählen, um beim automatischen Verkaufen jedes einzelne Item im Chat auszugeben."

	L["overrideLPTTitle"] = "LPT Müll verkaufen"
	L["overrideLPTTooltip"] = "Auswählen, um LibPeriodicTable Daten für graue Items zu ignorieren.\nEinige Gegenstände sind nicht mehr benötigt (graue Qualität), aber noch fehlerhaft als nützlich gelistet."

	L["hideZeroTitle"] = "Verstecke 0c Items"
	L["hideZeroTooltip"] = "Auswählen, um Gegenstände ohne Wert aus der Anzeige auszublenden. Standardmäßig aktiviert."

	L["debugTitle"] = "Debugausgabe zeigen"
	L["debugTooltip"] = "Auswählen, um Broker_Garbage's Debug-Informationen im Chat auszugeben. Tendiert dazu, den Chatframe vollzuspammen."

	L["reportDEGearTitle"] = "Hinweis zum Entzaubern alter Items"
	L["reportDEGearTooltip"] = "Auswählen, um eine Nachricht im Chat zu zeigen, wenn ein Item überholt ist (von TopFit), und du es entzaubern solltest."

	L["keepForLaterDETitle"] = "Später entzaubern"
	L["keepForLaterDETooltip"] = "Behalte Items, die höchstens <x> weitere Skillpunkte brauchen, um von deinem Charakter entzaubert werden zu können."

	L["DKTitle"] = "Temp. deaktivieren mit"
	L["DKTooltip"] = "Wähle die Taste, die Aktionen von Broker_Garbage temporär deaktiviert."

	L["LDBDisplayTextTitle"] = "LDB Anzeigetexte"
	L["LDBDisplayTextTooltip"] = "Nutze diese Einstellung, um den Text zu ändern, den du in deinem LDB Display siehst."
	L["LDBNoJunkTextTooltip"] = "Nutze diese Einstellung, um den Text zu ändern, der angezeigt wird, wenn du keinen Müll hast."
	L["ResetToDefault"] = "Auf den Standardwert zurücksetzen"
	L["LDBDisplayTextHelpTooltip"] = [[|cffffffffBasistags:|r
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
	L["LOTitle"] = "Listen"
	L["LOSubTitle"] = [[|cffffd200Müll|r: Diese Liste beinhaltet Items, die weggeworfen werden können, solltest du keinen Inventarplatz mehr haben.
|cffffd200Behalten|r: Items auf dieser Liste werden nie weggeworfen oder verkauft.
|cffffd200Händlerpreis|r: Items auf dieser Liste nutzen nur den Händlerpreis. (Diese Liste ist für alle Charaktere gleich)
|cffffd200Verkaufen|r: Diese Items werden bei Händlern automatisch verkauft, ihr Wert ist der Händlerpreis.

!! Wenn du Änderungen machst, musst du dein 'Inventar aktualisieren' !!]]

	L["defaultListsText"] = "Standardlisten"
	L["defaultListsTooltip"] = "|cffffffffKlicke|r, um manuell die lokalen Standardeinträge für Listen einzufügen.\n|cffffffffRechtsklick|r um auch die globalen Einträge zu erstellen."

	L["rescanInventoryText"] = "Inventar aktualisieren"
	L["rescanInventoryTooltip"] = "|cffffffffKlicke|r um Broker_Garbage dein Inventar neu scannen zu lassen. Wichtig nach jeder Änderung der Listen!"

	L["LOTabTitleInclude"] = "Müll"
	L["LOTabTitleExclude"] = "Behalten"
	L["LOTabTitleVendorPrice"] = "Festpreis"
	L["LOTabTitleAutoSell"] = "Verkaufen"

	L["LOIncludeAutoSellText"] = "Müll-Items verkaufen"
	L["LOIncludeAutoSellTooltip"] = "Aktivieren, um Items von deiner Müll-Liste automatisch beim Händler zu verkaufen. Items ohne Wert werden ignoriert."

	L["LOUseRealValues"] = "Echte Werte für Müll-Items"
	L["LOUseRealValuesTooltip"] = "Aktivieren, um für Müll-Items den tatsächlichen Preis zu nutzen, anstatt sie auf 0c zu setzen."

	L["listsBestUse"] = [[|cffffd200Listen-Beispiele|r
Die Standardlisten geben eine Hilfestellung, was auf welcher Liste nützlich sein könnte.
Setze erst alle Items, die du auf jeden Fall behalten möchtest, auf die |cffffd200Behalten-Liste|r. Denke auch daran, dass es Kategorien (s.u.) gibt! Ist der LootManager aktiv, wird er Items von dieser Liste standardmäßig immer plündern (änderbar in den LM-Einstellungen).
|cffAAAAAAz.B. Klassenreagenzien, Fläschchen|r
Dinge, von denen du weißt, dass sie sorglos weggeworfen werden können, gehören auf die |cffffd200Müll-Liste|r.
|cffAAAAAAz.B. Herbeigezauberter Manakeks, Argentumlanze|r
Sollte ein Item einen ungewollt hohen Wert zugewiesen bekommen, setze das Item auf die |cffffd200Festpreis-Liste|r. Diese Items werden nur den Händlerpreis nutzen. Alternativ kannst du hier auch mit |TInterface\Icons\INV_Misc_Coin_02:18|t einen eigenen Preis festlegen.
|cffAAAAAAz.B. Fischöl (Händlerpreis), Gebratenes Drachenfestmahl (eigener Preis, z.B. 20g)|r
Auf die |cffffd200Verkaufen-Liste|r kannst du alles setzen, was Broker_Garbage automatisch verkaufen soll.
|cffAAAAAAz.B. Wasser (als Krieger), Alterachochkäse|r]]

	L["listsSpecialOptions"] = [[|cffffd200Spezielle Müll-Listen Optionen|r
|cffffd200Verkaufen|r: Diese Einstellung ist nützlich für all diejenigen, die keine Unterscheidung zwischen Müll und zu verkaufenden Items treffen wollen. Wenn ausgewählt, werden sowohl die Items aus der Müll-Liste als auch die aus der Verkaufen-Liste bei Händlern verkauft.
|cffffd200Echte Werte|r: Diese Einstellungen ändert das Verhalten der Müll-Liste. Standardmäßig (deaktiviert) bekommen Müll-Items einen Wert von 0c zugewiesen (beeinflusst nicht die Statistiken) und erscheinen damit als erstes im Tooltip. Wenn aktiviert, behalten diese Items ihren normalen Wert und tauchen entsprechend später in der Liste auf.]]

	L["iconButtonsUse"] = [[|cffffd200Item-Buttons|r
Angezeigt wird entweder das Icon des Items, ein Zahnrad, wenn es sich um eine Kategorie handelt, oder ein Fragezeichen, wenn der Server das Item nicht finden kann.
Oben links jedes Buttons kann ein "G" stehen. Ist dies der Fall, ist das entsprechende Item auf der |cffffd200globalen Liste|r, d.h. diese Regel gilt für alle Charaktere.
Items oder Kategorien (mit Ausnahme der Festpreis-Liste) können ein |cffffd200Limit|r haben. Dies wird als kleine Zahl in der unteren rechten Ecke angezeigt. Zum Ändern nutze das |cffffd200Mausrad|r über dem Button. Für Kategorien wird die Anzahl aller zugehörigen Items aufaddiert.
Sollte das Limit überschritten werden, werden Items als löschbar bzw. wie reguläre Items (falls dieses Limit aus der Behalten-Liste stammt) behandelt.]]

	L["actionButtonsUse"] = [[|cffffd200Aktions-Buttons|r
Unterhalb dieses Fensters siehst du 5 Buttons und eine Suchleiste.
|TInterface\Icons\Spell_ChargePositive:18|t |cffffd200Plus|r: Hier kannst du Items zu der angezeigten Liste hinzufügen. Ziehe dazu einfach ein Item auf das Plus. Um eine |cffffd200Kategorie|r hinzuzufügen, rechtsklicke das Plus und wähle dann in dem neuen Menü eine Kategorie aus.
|cffAAAAAAz.B. "Tradeskill > Recipe", "Misc > Key"|r
|TInterface\Icons\Spell_ChargeNegative:18|t |cffffd200Minus|r: Markiere Items aus der Liste (anklicken). Beim Klick auf das Minus werden diese Items von der Liste entfernt.
|TInterface\Icons\INV_Misc_GroupLooking:18|t |cffffd200Lokal|r: Markierte Items werden auf die lokale Liste gesetzt, gelten also nur für diesen Charakter.
|TInterface\Icons\INV_Misc_GroupNeedMore:18|t |cffffd200Global|r: Analog zu Lokal, nur werden hierbei die Items auf die globale Liste gesetzt, die Regeln gelten damit für alle Charaktere.
|TInterface\Icons\INV_Misc_Coin_02:18|t |cffffd200Wert festlegen|r: Markierte Items bekommen den im folgenden Dialog gesetzten Wert zugewiesen.
|TInterface\Buttons\UI-GroupLoot-Pass-UP:18|t |cffffd200Leeren|r: Ein Klick auf diesen Button leert die charakterspezifischen Regeln dieser Liste. Shift-Klick leert die accountweiten Regeln. |cffff0000Mit Vorsicht benutzen!|r]]

	L["LOPlus"] = "Füge Items zu dieser Liste hinzu, indem du sie hierher |cffffffffziehst|r/hier |cffffffffablegst|r.\n|cffffffffRechtsklick|r, um Kategorien hinzuzufügen!"
	L["LOMinus"] = "Wähle oben die Items, die du von dieser Liste entfernen willst. Dann |cffffffffklicke|r hier."
	L["LODemote"] = "|cffffffffKlicke|r um alle markierten Items als charakterspezifische Regel zu nutzen."
	L["LOPromote"] = "|cffffffffKlicke|r um alle markierten Items als globale Regel zu nutzen."
	L["LOEmptyList"] = "|cffff0000Achtung!|r\n|cffffffffKlicke|r, um die lokalen Einträge dieser Liste zu löschen.\n|cffffffffShift-Klicke|r, um die globalen Einträge zu löschen."

	L["LOSetPrice"] = "|cffffffffKlicke|r um allen markierten Items einen speziellen Preis zuzuweisen."
	L["setPriceInfo"] = "|cffffd200Preis manuell festlegen|r|nKlicke auf Verkaufspreis um immer den Händlerpreis zu nutzen."

	L["namedItems"] = "Item mit Namen ..."
	L["namedItemsInfo"] = "|cffffd200Namensregel hinzufügen|r|nGib einen Itemnamen oder ein Muster ein:|nz.B. \"|cFF36BFA8Rolle de*|r\" für \"|cFF2bff58Rolle der Stärke|r\" oder \"|cFF2bff58Rolle des Bären|r\""
	L["search"] = "Suchen..."

	-- LibPeriodicTable category testing
	L["PTCategoryTest"] = "Kategorientest"
	L["PTCategoryTestExplanation"] = "Wähle unten eine Kategorie aus um dir alle Gegenstände aus deinem Inventar anzeigen zu lassen, die dazuzählen.\nKategoriedaten kommen von LibPeriodicTable."
	L["PTCategoryTestDropdownTitle"] = "Kategorie, die getestet werden soll"
	L["PTCategoryTestDropdownText"] = "Wähle eine Kategorie"

	L["categoryTestItemSlot"] = "Lege ein Item hier ab um alle genutzten Kategorien zu suchen, die es enthalten."
	L["categoryTestItemTitle"] = "%s ist bereits in diesen Kategorien...\n"
	L["categoryTestItemEntry"] = "%s ist bisher in keiner Kategorie."
end
