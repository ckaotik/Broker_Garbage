-- enUS / enGB / default localization file
local _, BG = ...

BG.locale = {
	label = "Junk, be gone!",

	-- Chat Messages
	addedTo_exclude = "%s has been added to the Keep List.",
	addedTo_forceVendorPrice = "%s will only have its vendor price considered.",

	reportNothingToSell = "Nothing to sell!",
	reportCannotSell = "This vendor doesn't buy items.",
	sellItem = "Sold %1$sx%2$d for %3$s.",
	sell = "Sold trash for %s.",
	sellAndRepair = "Sold trash for %1$s, repaired for %2$s%3$s. Change: %4$s.",
	repair = "Repaired for %1$s%2$s.",
	guildRepair = " (guild)",
	couldNotRepair = "Could not repair because you don't have enough money. You need %s.",

	itemDeleted = "%1$sx%2$d has been deleted.",
	listsUpdatedPleaseCheck = "Your lists have been updated. Please have a look at your settings and check if they fit your needs.",
	disenchantOutdated = "%1$s is outdated and should get disenchanted.",

	-- Tooltip
	headerAltClick = "Alt-Click: Use Vendor Price",
	headerRightClick = "Right-Click for options", -- unused
	headerShiftClick = "SHIFT-Click: Destroy",
	headerCtrlClick = "CTRL-Click: Keep",
	moneyLost = "Money Lost:",
	moneyEarned = "Money Earned:",
	noItems = "No items to delete.",
	increaseTreshold = "Increase quality treshold",
	openPlease = "Unopened containers in your bags",

	-- Sell button tooltip
	autoSellTooltip = "Sell Items for %s",

	-- List names
	listExclude= "Keep",
	listInclude = "Include",
	listVendor = "Vendor",
	listSell = "Auto sell",
	listCustom = "Custom price",
	listAuction = "Auction",
	listDisenchant = "Disenchant",
	listUnusable = "Unusable Gear",
	listOutdated = "Outdated",
}
