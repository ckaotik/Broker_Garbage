-- enUS / enGB / default localization file
local _, BG = ...
BG.locale = {}
local L = BG.locale

-- if GetLocale() == "enUS" then
	L["label"] = "Junk, be gone!"

	-- Chat Messages
	L["addedTo_exclude"] = "%s has been added to the Keep List."
	L["addedTo_forceVendorPrice"] = "%s will only have its vendor price considered."

	L["reportNothingToSell"] = "Nothing to sell!"
	L["reportCannotSell"] = "This vendor doesn't buy items."
	L["sellItem"] = "Sold %1$sx%2$d for %3$s."
	L["sell"] = "Sold trash for %s."
	L["sellAndRepair"] = "Sold trash for %1$s, repaired for %2$s%3$s. Change: %4$s."
	L["repair"] = "Repaired for %1$s%2$s."
	L["guildRepair"] = " (guild)"
	L["couldNotRepair"] = "Could not repair because you don't have enough money. You need %s."
	L["itemDeleted"] = "%1$sx%2$d has been deleted."
	L["listsUpdatedPleaseCheck"] = "Your lists have been updated. Please have a look at your settings and check if they fit your needs."
	L["disenchantOutdated"] = "%1$s is outdated and should get disenchanted."
	L["couldNotMoveItem"] = "Error! Item to move does not match requested item."

	-- Tooltip
	L["headerAltClick"] = "Alt-Click: Use Vendor Price"
	L["headerRightClick"] = "Right-Click for options" -- unused
	L["headerShiftClick"] = "SHIFT-Click: Destroy"
	L["headerCtrlClick"] = "CTRL-Click: Keep"
	L["moneyLost"] = "Money Lost:"
	L["moneyEarned"] = "Money Earned:"
	L["noItems"] = "No items to delete."
	L["increaseTreshold"] = "Increase quality treshold"
	L["openPlease"] = "Unopened containers in your bags"

	-- Sell button tooltip
	L["autoSellTooltip"] = "Sell Items for %s"

	-- List names
	L["listExclude"]= "Keep"
	L["listInclude"] = "Include"
	L["listVendor"] = "Vendor"
	L["listSell"] = "Auto sell"
	L["listCustom"] = "Custom price"
	L["listAuction"] = "Auction"
	L["listDisenchant"] = "Disenchant"
	L["listUnusable"] = "Unusable Gear"
	L["listOutdated"] = "Outdated"


-- end
