-- German localisation file
local _, BG = ...

if GetLocale() == "deDE" then
	BG.locale.label = "Kein Müll"

	-- Chat Messages
	BG.locale.addedTo_exclude = "%s zur Behalten-Liste hinzugefügt."
	BG.locale.addedTo_forceVendorPrice = "Für %s wird nun nur der Händlerpreis genutzt."

	BG.locale.reportNothingToSell = "Nichts zu verkaufen!"
	BG.locale.reportCannotSell = "Dieser Händler kauft nichts."
	BG.locale.sellItem = "%1$sx%2$d für %3$s verkauft."
	BG.locale.sell = "Müll verkauft für %s."
	BG.locale.sellAndRepair = "Müll für %1$s verkauft, repariert für %2$s%3$s. Änderung: %4$s."
	BG.locale.repair = "Repariert für %1$s%2$s."
	BG.locale.guildRepair = " (Gilde)"
	BG.locale.couldNotRepair = "Konnte nicht reparieren, da du nicht genug Geld hast. Du brauchst %s."
	BG.locale.itemDeleted = "%1$sx%2$d wurde gelöscht."
	BG.locale.listsUpdatedPleaseCheck = "Die Listeneinstellungen wurden geändert. Bitte sieh in den Einstellungen nach, ob sie für dich passend sind."
	BG.locale.disenchantOutdated = "%1$s ist veraltet und sollte entzaubert werden."
	BG.locale.couldNotMoveItem = "Fehler! Der zu bewegende Gegenstand ist nicht der erwartete."

	-- Tooltip
	BG.locale.headerAltClick = "Alt-Klick: Händlerpreis nutzen"
	BG.locale.headerRightClick = "Rechts-Klick: Optionen" -- unused
	BG.locale.headerShiftClick = "SHIFT-Klick: Zerstören"
	BG.locale.headerCtrlClick = "STRG-Klick: Behalten"
	BG.locale.moneyLost = "Gold verloren:"
	BG.locale.moneyEarned = "Gold verdient:"
	BG.locale.noItems = "Keine Items zum Löschen."
	BG.locale.increaseTreshold = "Erhöhe die Item Qualität"
	BG.locale.openPlease = "Ungeöffnete Behälter im Inventar"

	-- Sell button tooltip
	BG.locale.autoSellTooltip = "Müll für %s verkaufen"

	-- List names
	BG.locale.listExclude= "Behalten"
	BG.locale.listInclude = "Müll"
	BG.locale.listVendor = "Händlerpreis"
	BG.locale.listSell = "Verkaufen"
	BG.locale.listCustom = "Eigener Preis"
	BG.locale.listAuction = "Auktion"
	BG.locale.listDisenchant = "Entzaubern"
	BG.locale.listUnusable = "Nicht anlegbar"
	BG.locale.listOutdated = "Alte Ausrüstung"
end
