-- German localisation file
local _, BG = ...
local L = BG.locale

if GetLocale() == "deDE" then
	L["label"] = "Kein Müll"

	-- Chat Messages
	L["addedTo_exclude"] = "%s zur Behalten-Liste hinzugefügt."
	L["addedTo_forceVendorPrice"] = "Für %s wird nun nur der Händlerpreis genutzt."

	L["reportNothingToSell"] = "Nichts zu verkaufen!"
	L["reportCannotSell"] = "Dieser Händler kauft nichts."
	L["sellItem"] = "%1$sx%2$d für %3$s verkauft."
	L["sell"] = "Müll verkauft für %s."
	L["sellAndRepair"] = "Müll für %1$s verkauft, repariert für %2$s%3$s. Änderung: %4$s."
	L["repair"] = "Repariert für %1$s%2$s."
	L["guildRepair"] = " (Gilde)"
	L["couldNotRepair"] = "Konnte nicht reparieren, da du nicht genug Geld hast. Du brauchst %s."
	L["itemDeleted"] = "%1$sx%2$d wurde gelöscht."
	L["listsUpdatedPleaseCheck"] = "Die Listeneinstellungen wurden geändert. Bitte sieh in den Einstellungen nach, ob sie für dich passend sind."
	L["disenchantOutdated"] = "%1$s ist veraltet und sollte entzaubert werden."
	L["couldNotMoveItem"] = "Fehler! Der zu bewegende Gegenstand ist nicht der erwartete."

	-- Tooltip
	L["headerAltClick"] = "ALT-Klick: Händlerpreis nutzen"
	L["headerRightClick"] = "Rechts-Klick: Optionen" -- unused
	L["headerShiftClick"] = "SHIFT-Klick: Zerstören"
	L["headerCtrlClick"] = "STRG-Klick: Behalten"
	L["moneyLost"] = "Gold verloren:"
	L["moneyEarned"] = "Gold verdient:"
	L["noItems"] = "Keine Items zum Löschen."
	L["increaseTreshold"] = "Erhöhe die Item Qualität"
	L["openPlease"] = "Ungeöffnete Behälter im Inventar"

	-- Sell button tooltip
	L["autoSellTooltip"] = "Müll für %s verkaufen"

	-- List names
	L["listExclude"]= "Behalten"
	L["listInclude"] = "Müll"
	L["listVendor"] = "Händlerpreis"
	L["listSell"] = "Verkaufen"
	L["listCustom"] = "Eigener Preis"
	L["listAuction"] = "Auktion"
	L["listDisenchant"] = "Entzaubern"
	L["listUnusable"] = "Nicht anlegbar"
	L["listOutdated"] = "Alte Ausrüstung"

	-- classification reasons
	L["reason_KEEP_ID"] = "Schatz (ItemID)"
	L["reason_KEEP_CAT"] = "Schatz (Kategorie)"
	L["reason_TOSS_ID"] = "Plunder (ItemID)"
	L["reason_TOSS_CAT"] = "Plunder (Kategorie)"
	L["reason_QUEST_ITEM"] = "Questgegenstand"
	L["reason_UNUSABLE_ITEM"] = "Nicht verwendbar"
	L["reason_OUTDATED_ITEM"] = "Veraltet"
	L["reason_GRAY_ITEM"] = "Graue Qualität"
	L["reason_PRICE_ITEM"] = "Eigener Preis (ItemID)"
	L["reason_PRICE_CAT"] = "Eigener Preis (Kategorie)"
	L["reason_WORTHLESS"] = "Wertlos"
	L["reason_EMPTY_SLOT"] = "Leerer Platz"
	L["reason_HIGHEST_VALUE"] = "Höchster Wert"
	L["reason_SOULBOUND"] = "Seelengebunden"
	L["reason_QUALITY"] = "Qualität zu hoch"
	L["reason_HIGHEST_LEVEL"] = "Veraltet aber höchste Stufe"

	BG.locale = L
end
