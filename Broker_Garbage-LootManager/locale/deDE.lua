-- German localisation file
local _, BGLM = ...
local L = BGLM.locale

if GetLocale() == "deDE" then
	L["CreatureTypeBeast"] = "Wildtier"
	L["GlobalSetting"] = "\n|cffffff9aDiese Einstellung ist global."

	-- Chat Messages
	L["couldNotLootValue"] = "%sx%d wurde nicht geplündert, da es zu billig ist."
	L["couldNotLootCompareValue"] = "%sx%d wurde nicht geplündert, da es zu billig ist. Inventar ist voll!"
	L["couldNotLootBlacklist"] = "%sx%d wurde nicht geplündert, da es auf deiner Blacklist steht."
	L["couldNotLootLocked"] = "Konnte %sx%d nicht plündern, da es gesperrt ist. Bitte plündere es manuell."
	L["couldNotLootSpace"] = "Konnte %sx%d nicht plündern, da dein Inventar voll ist."
	L["couldNotLootLM"] = "Du bist Plündermeister, bitte verteile %s manuell."

	L["errorInventoryFull"] = "Etwas konnte nicht geplündert werden, da dein Inventar voll ist. Bitte manuell plündern!"

	-- Loot Manager
	L["LMTitle"] = "Loot Manager"
	L["LMSubTitle"] = "Der Loot Manager kann den gesamten Lootvorgang sowie deinen Inventarplatz verwalten, wenn du ihn lässt."

	L["GroupLooting"] = "Lootverhalten"
	L["GroupInventory"] = "Inventar"
	L["GroupNotices"] = " Benachrichtigungen"
	L["GroupThreshold"] = "Grenzwerte"

	L["LMEnableInCombatTitle"] = "Im Kampf aktivieren"
	L["LMEnableInCombatTooltip"] = "Wenn ausgewählt wird der Loot Manager auch im Kampf versuchen, Beute zu plündern."

	L["LMAutoLootTitle"] = "Autoloot"
	L["LMAutoLootTooltip"] = "Wenn nicht ausgewählt wird Broker_Garbage nur in bestimmten Situationen looten (s.u.)."
	L["disableBlizzAutoLoot"] = "\n|cffff0000Warnung:|r Bitte deaktiviere Blizzards Schnell-Plündern."

	L["LMAutoLootSkinningTitle"] = "Kürschnern"
	L["LMAutoLootSkinningTooltip"] = "Wenn ausgewählt wird Broker_Garbage versuchen, von dir kürschnerbare Kreaturen zu plündern."

	L["LMAutoLootPickpocketTitle"] = "Taschendiebstahl"
	L["LMAutoLootPickpocketTooltip"] = "Wenn ausgewählt wird Broker_Garbage automatisch plündern, wenn du ein Schurke in Verstohlenheit bist."

	L["LMAutoLootFishingTitle"] = "Angeln"
	L["LMAutoLootFishingTooltip"] = "Wenn ausgewählt wird Broker_Garbage automatisch plündern, wenn du angelst."

	L["LMAutoAcceptLootTitle"] = "BoP autom. annehmen"
	L["LMAutoAcceptLootTooltip"] = "Auswählen, um beim Aufheben gebundene Gegestände anzunehmen."

	L["LMCloseLootTitle"] = "Fenster schließen"
	L["LMCloseLootTooltip"] = "Auswählen, um das Lootfenster automatisch zu schließen, sobald keine interessanten Items mehr enthalten sind.\n|cffff0000Achtung|r: Dies kann Probleme mit anderen Addons verursachen."

	L["LMKeepPLOpenTitle"] = "Eigenes offen lassen"
	L["LMKeepPLOpenTooltip"] = "Auswählen, um das Lootfenster offen zu lassen, wenn ein relevantes Item nicht geplündert werden kann und es sich um persönliche Beute handelt (z.B. Item-Beutel aus den Taschen, Bergbau-Vorkommen)."

	L["LMForceClearTitle"] = "Immer alles leeren"
	L["LMForceClearTooltip"] = "Wenn ausgewählt wird Broker_Garbage immer alle Items plündern, auch wenn du kein Kürschner bist. Diese Einstellung kann zu Verlusten führen!"

	L["lootJunkTitle"] = "'Müll' plündern"
	L["lootJunkTooltip"] = "Wenn ausgewählt werden Items von der 'Müll'-Liste ganz regulär geplündert."

	L["lootKeepTitle"] = "'Behalten' plündern"
	L["lootKeepTooltip"] = "Wenn ausgewählt werden Items von der 'Behalten'-Liste immer geplündert."

	L["LMAutoDestroyTitle"] = "Auto-Zerstören"
	L["LMAutoDestroyTooltip"] = "Wenn ausgewählt wird Broker_Garbage bei zu wenig Platz versuchen, welchen zu schaffen."

	L["LMAutoDestroyInstantTitle"] = "Platz Erzwingen"
	L["LMAutoDestroyInstantTooltip"] = "Wenn ausgewählt können Items sofort gelöscht werden. Ansonsten erfolgt das Löschen erst, sobald du etwas besseres findest und keinen Platz hast."
	L["LMAutoDestroy_ErrorNoItems"] = "Fehler! Es gibt keine Möglichkeit, durch Zerstören weiteren Platz zu schaffen."

	L["printDebugTitle"] = "Debugausgabe zeigen"
	L["printDebugTooltip"] = "Auswählen um LootManager Debug-Informationen im Chat auszugeben. Tendiert dazu, den Chat vollzuspammen."

	L["LMFreeSlotsTitle"] = "Min. freier Inventarplatz"
	L["LMFreeSlotsTooltip"] = "Setze das Minimum an freien Taschenplätzen, bei dem Broker_Garbage automatisch Platz schaffen soll."

	L["LMWarnLMTitle"] = "Plündermeister"
	L["LMWarnLMTooltip"] = "Wenn ausgewählt wird Broker_Garbage eine Meldung zeigen, die dich auffordert, die Beute zu verteilen."

	L["LMWarnInventoryFullTitle"] = "Inventar ist voll"
	L["LMWarnInventoryFullTooltip"] = "Auswählen um eine Chatnachricht zu erhalten, wann immer ein 'Inventar ist voll.'-Fehler erscheint."

	L["printValueTitle"] = "Ist zu billig"
	L["printValueText"] = "Wenn ausgewählt wird Broker_Garbage eine Meldung ausgeben wenn ein Item nicht geplündert wird, da es billiger als der Mindestwert zum Plündern ist (siehe unten)."

	L["printCompareValueTitle"] = "Ist billiger als alles"
	L["printCompareValueText"] = "Wenn ausgewählt wird Broker_Garbage eine Meldung ausgeben wenn ein Item nicht geplündert wird, da es billiger ist als alles, was wir dafür wegwerfen könnten."

	L["printJunkTitle"] = "Ist Müll"
	L["printJunkText"] = "Wenn ausgewählt wird Broker_Garbage eine Meldung ausgeben wenn ein Item nicht geplündert wird, da es auf der Müllliste steht."

	L["printSpaceTitle"] = "Taschen sind voll"
	L["printSpaceText"] = "Wenn ausgewählt wird Broker_Garbage eine Meldung ausgeben wenn ein Item nicht geplündert wird, da kein Platz mehr in deinen Taschen ist, autozerstören aber deaktiviert ist."

	L["printLockedTitle"] = "Ist gesperrt"
	L["printLockedText"] = "Wenn ausgewählt wird Broker_Garbage eine Meldung ausgeben wenn ein Item nicht geplündert wird, da es gesperrt ist (z.B. wenn jemand anderes bereits plündert)."

	L["LMItemMinValue"] = "Mindestwert zum Looten"

	L["minLootQualityTitle"] = "Mindestqualität"
	L["minLootQualityTooltip"] = "Der LootManager wird keine Gegenstände unterhalb der hier angegebenen Qualität plündern."
end
