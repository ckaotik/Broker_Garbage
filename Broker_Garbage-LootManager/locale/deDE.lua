-- German localisation file
local _, BGLM = ...

if GetLocale() == "deDE" then
	BGLM.locale.CreatureTypeBeast = "Wildtier"
	BGLM.locale.GlobalSetting = "\n|cffffff9aDiese Einstellung ist global."

	-- Chat Messages
	BGLM.locale.couldNotLootValue = "%sx%d wurde nicht geplündert, da es zu billig ist."
	BGLM.locale.couldNotLootCompareValue = "%sx%d wurde nicht geplündert, da es zu billig ist. Inventar ist voll!"
	BGLM.locale.couldNotLootBlacklist = "%sx%d wurde nicht geplündert, da es auf deiner Blacklist steht."
	BGLM.locale.couldNotLootLocked = "Konnte %sx%d nicht plündern, da es gesperrt ist. Bitte plündere es manuell."
	BGLM.locale.couldNotLootSpace = "Konnte %sx%d nicht plündern, da dein Inventar voll ist."
	BGLM.locale.couldNotLootLM = "Du bist Plündermeister, bitte verteile %s manuell."

	BGLM.locale.errorInventoryFull = "Etwas konnte nicht geplündert werden, da dein Inventar voll ist. Bitte manuell plündern!"

	-- Loot Manager
	BGLM.locale.LMTitle = "Loot Manager"
	BGLM.locale.LMSubTitle = "Der Loot Manager kann den gesamten Lootvorgang sowie deinen Inventarplatz verwalten, wenn du ihn lässt."

	BGLM.locale.GroupLooting = "Lootverhalten"
	BGLM.locale.GroupInventory = "Inventar"
	BGLM.locale.GroupNotices = " Benachrichtigungen"
	BGLM.locale.GroupTreshold = "Grenzwerte"

	BGLM.locale.LMEnableInCombatTitle = "Im Kampf aktivieren"
	BGLM.locale.LMEnableInCombatTooltip = "Wenn ausgewählt wird der Loot Manager auch im Kampf versuchen, Beute zu plündern."

	BGLM.locale.LMAutoLootTitle = "Autoloot"
	BGLM.locale.LMAutoLootTooltip = "Wenn nicht ausgewählt wird Broker_Garbage nur in bestimmten Situationen looten (s.u.)."

	BGLM.locale.LMAutoLootSkinningTitle = "Kürschnern"
	BGLM.locale.LMAutoLootSkinningTooltip = "Wenn ausgewählt wird Broker_Garbage versuchen, von dir kürschnerbare Kreaturen zu plündern."

	BGLM.locale.LMAutoLootPickpocketTitle = "Taschendiebstahl"
	BGLM.locale.LMAutoLootPickpocketTooltip = "Wenn ausgewählt wird Broker_Garbage automatisch plündern, wenn du ein Schurke in Verstohlenheit bist."

	BGLM.locale.LMAutoLootFishingTitle = "Angeln"
	BGLM.locale.LMAutoLootFishingTooltip = "Wenn ausgewählt wird Broker_Garbage automatisch plündern, wenn du angelst."

	BGLM.locale.LMAutoAcceptLootTitle = "BoP autom. annehmen"
	BGLM.locale.LMAutoAcceptLootTooltip = "Auswählen, um beim Aufheben gebundene Gegestände anzunehmen."

	BGLM.locale.LMCloseLootTitle = "Fenster schließen"
	BGLM.locale.LMCloseLootTooltip = "Auswählen, um das Lootfenster automatisch zu schließen, sobald keine interessanten Items mehr enthalten sind.\n|cffff0000Achtung|r: Dies kann Probleme mit anderen Addons verursachen."

	BGLM.locale.LMForceClearTitle = "Immer alles leeren"
	BGLM.locale.LMForceClearTooltip = "Wenn ausgewählt wird Broker_Garbage immer alle Items plündern, auch wenn du kein Kürschner bist. Diese Einstellung kann zu Verlusten führen!"

	BGLM.locale.lootJunkTitle = "'Müll' plündern"
	BGLM.locale.lootJunkTooltip = "Wenn ausgewählt werden Items von der 'Müll'-Liste ganz regulär geplündert."

	BGLM.locale.lootKeepTitle = "'Behalten' plündern"
	BGLM.locale.lootKeepTooltip = "Wenn ausgewählt werden Items von der 'Behalten'-Liste immer geplündert."

	BGLM.locale.LMAutoDestroyTitle = "Auto-Zerstören"
	BGLM.locale.LMAutoDestroyTooltip = "Wenn ausgewählt wird Broker_Garbage bei zu wenig Platz versuchen, welchen zu schaffen."

	BGLM.locale.LMAutoDestroyInstantTitle = "Platz Erzwingen"
	BGLM.locale.LMAutoDestroyInstantTooltip = "Wenn ausgewählt können Items sofort gelöscht werden. Ansonsten erfolgt das Löschen erst, sobald du etwas besseres findest und keinen Platz hast."
	BGLM.locale.LMAutoDestroy_ErrorNoItems = "Fehler! Es gibt keine Möglichkeit, durch Zerstören weiteren Platz zu schaffen."

	BGLM.locale.printDebugTitle = "Debugausgabe zeigen"
	BGLM.locale.printDebugTooltip = "Auswählen um LootManager Debug-Informationen im Chat auszugeben. Tendiert dazu, den Chat vollzuspammen."

	BGLM.locale.LMFreeSlotsTitle = "Min. freier Inventarplatz"
	BGLM.locale.LMFreeSlotsTooltip = "Setze das Minimum an freien Taschenplätzen, bei dem Broker_Garbage automatisch Platz schaffen soll."

	BGLM.locale.LMWarnLMTitle = "Plündermeister"
	BGLM.locale.LMWarnLMTooltip = "Wenn ausgewählt wird Broker_Garbage eine Meldung zeigen, die dich auffordert, die Beute zu verteilen."

	BGLM.locale.LMWarnInventoryFullTitle = "Inventar ist voll"
	BGLM.locale.LMWarnInventoryFullTooltip = "Auswählen um eine Chatnachricht zu erhalten, wann immer ein 'Inventar ist voll.'-Fehler erscheint."

	BGLM.locale.printValueTitle = "Ist zu billig"
	BGLM.locale.printValueText = "Wenn ausgewählt wird Broker_Garbage eine Meldung ausgeben wenn ein Item nicht geplündert wird, da es billiger als der Mindestwert zum Plündern ist (siehe unten)."

	BGLM.locale.printCompareValueTitle = "Ist billiger als alles"
	BGLM.locale.printCompareValueText = "Wenn ausgewählt wird Broker_Garbage eine Meldung ausgeben wenn ein Item nicht geplündert wird, da es billiger ist als alles, was wir dafür wegwerfen könnten."

	BGLM.locale.printJunkTitle = "Ist Müll"
	BGLM.locale.printJunkText = "Wenn ausgewählt wird Broker_Garbage eine Meldung ausgeben wenn ein Item nicht geplündert wird, da es auf der Müllliste steht."

	BGLM.locale.printSpaceTitle = "Taschen sind voll"
	BGLM.locale.printSpaceText = "Wenn ausgewählt wird Broker_Garbage eine Meldung ausgeben wenn ein Item nicht geplündert wird, da kein Platz mehr in deinen Taschen ist, autozerstören aber deaktiviert ist."

	BGLM.locale.printLockedTitle = "Ist gesperrt"
	BGLM.locale.printLockedText = "Wenn ausgewählt wird Broker_Garbage eine Meldung ausgeben wenn ein Item nicht geplündert wird, da es gesperrt ist (z.B. wenn jemand anderes bereits plündert)."

	BGLM.locale.LMItemMinValue = "Mindestwert zum Looten"
end
