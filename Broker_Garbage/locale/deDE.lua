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
	BG.locale.sellAndRepair = "Müll für %1$s verkauft, repariert für %2$s. Änderung: %3$s."
	BG.locale.repair = "Repariert für %s."
	BG.locale.couldNotRepair = "Konnte nicht reparieren, da du nicht genug Geld hast. Du brauchst %s."
	BG.locale.itemDeleted = "%1$sx%2$d wurde gelöscht."
	BG.locale.listsUpdatedPleaseCheck = "Die Listeneinstellungen wurden geändert. Bitte sieh in den Einstellungen nach, ob sie für dich passend sind."
	BG.locale.disenchantOutdated = "%1$s ist veraltet und sollte entzaubert werden."
	
	-- Tooltip
	BG.locale.headerRightClick = "Rechts-Klick: Optionen"
	BG.locale.headerShiftClick = "SHIFT-Klick: Zerstören"
	BG.locale.headerCtrlClick = "STRG-Klick: Behalten"
	BG.locale.moneyLost = "Gold verloren:"
	BG.locale.moneyEarned = "Gold verdient:"
	BG.locale.noItems = "Keine Items zum Löschen."
	BG.locale.increaseTreshold = "Erhöhe die Item Qualität"
	BG.locale.openPlease = "Ungeöffnete Behälter im Inventar"
	BG.locale.openClams = "Du hast Muscheln im Inventar."
	
	-- Sell button tooltip
	BG.locale.autoSellTooltip = "Müll für %s verkaufen"
end