local _, BG = ...

BG.enchanting = GetSpellInfo(7411)
BG.disenchant = GetSpellInfo(87067)

-- item classifications
BG.IGNORE = -1
-- static list types
BG.EXCLUDE = 0
BG.INCLUDE = 1
BG.AUTOSELL = 2
-- dynamic list types
BG.UNUSABLE = 4		-- unusable gear, e.g. mail for a priest
BG.OUTDATED = 5		-- item is gear but irrelevant (TopFit/Pawn)
-- price types
BG.AUCTION = 6
BG.VENDOR = 7
BG.DISENCHANT = 8
BG.CUSTOM = 9

BG.info = {
	[BG.EXCLUDE]    = {"|cFFffffff", "K", BG.locale.listExclude}, -- keep
	[BG.INCLUDE]    = {"|cFFb1b1b1", "J", BG.locale.listInclude}, -- junk
	[BG.VENDOR]     = {"|cFFff9c5a", "V", BG.locale.listVendor},
	[BG.AUTOSELL]   = {"|cFFff592d", "V", BG.locale.listSell},
	[BG.AUCTION]    = {"|cFF2bff58", "A", BG.locale.listAuction},
	[BG.DISENCHANT] = {"|cFFe052ff", "D", BG.locale.listDisenchant},
	[BG.UNUSABLE]   = {"|cFF3c73ab", "U", BG.locale.listUnusable},
	[BG.OUTDATED]   = {"|cFF36BFA8", "O", BG.locale.listOutdated},

	[BG.IGNORE]     = {"", "", ""},
	[BG.CUSTOM]     = {"|cFFf3d91b", "C", ""},
}

BG.disableKey = {
	["NONE"] 	= function() return false end,
	["SHIFT"] 	= IsShiftKeyDown,
	["ALT"] 	= IsAltKeyDown,
	["CTRL"] 	= IsControlKeyDown,
}

-- default saved variables
BG.defaultGlobalSettings = {
	-- lists
	keep = {},
	toss = {},
	prices = {},

	-- behavior
	autoSellToVendor = true,
	autoRepairAtVendor = true,
	sellNotWearable = nil,
	sellOldGear = nil,
	keepHighestItemLevel = true,
	showSellLog = nil,
	overrideLPT = nil,
	restackInventory = nil,

	disableKey = "SHIFT",
	autoSellIncludeItems = nil,
	keepItemsForLaterDE = 0,

	auctionAddonOrder = { buyout = {}, disenchant = {} },
	buyoutDisabledSources = {},
	disenchantDisabledSources = {},

	-- thresholds
	dropQuality = 0,
	sellNWQualityTreshold = 3,

	-- numeric values
	tooltipMaxHeight = 220,
	tooltipNumItems = 9,
	showMoney = nil,
	hasEnchanter = true,

	-- statistic values
	moneyLostByDeleting = 0,
	moneyEarned = 0,
	itemsSold = 0,
	itemsDropped = 0,

	-- display options
	useRealValues = nil,
	hideZeroValue = true,
	showAutoSellIcon = true,
	showItemTooltipLabel = true,
	showLabelReason = nil,
	showBagnonSellIcons = nil, -- [TODO] settings

	-- LibDataBroker Display
	LDBformat = "[itemname]x[itemcount] ([itemvalue])",
	LDBNoJunk = BG.locale.label,

	-- tooltip
	showIcon = true,
	showLost = true,
	showEarned = true,
	showSource = nil,
	showContainers = true,

	-- output options
	reportNothingToSell = true,
	reportDisenchantOutdated = nil,
}

BG.defaultLocalSettings = {
	-- lists
	keep = {},
	toss = {},

	-- behavior
	repairGuildBank = nil,

	-- default values
	moneyLostByDeleting = 0,
	moneyEarned = 0,
}
