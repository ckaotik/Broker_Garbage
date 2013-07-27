local _, BG = ...

-- default saved variables
BG.defaultGlobalSettings = {
	-- lists
	exclude = {},				-- Keep List
	include = {},				-- Junk List
	autoSellList = {},			-- Sell List
	forceVendorPrice = {},		-- Vendor Price List; no corresponding local list

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
	autoSellIncludeItems = nil,	-- toggle include list being sell list as well
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
	showMoney = 2,
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
	exclude = {},
	include = {},
	autoSellList = {},

	-- behavior
	repairGuildBank = nil,

	-- default values
	moneyLostByDeleting = 0,
	moneyEarned = 0,
}

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


BG.colors = {
	[BG.EXCLUDE]	= "|cFFffffff", -- white
	[BG.INCLUDE] 	= "|cFFb1b1b1",	-- grey
	[BG.VENDOR] 	= "|cFFff9c5a",	-- orange
	[BG.AUTOSELL] 	= "|cFFff592d",	-- dark orange
	[BG.CUSTOM] 	= "|cFFf3d91b",	-- yellow
	[BG.AUCTION] 	= "|cFF2bff58",	-- green
	[BG.DISENCHANT] = "|cFFe052ff",	-- purple
	[BG.UNUSABLE] 	= "|cFF3c73ab",	-- blue
	[BG.OUTDATED]   = "|cFF36BFA8",	-- turkoise
}
BG.labels = {
	[BG.EXCLUDE]	= BG.locale.listExclude,
	[BG.INCLUDE] 	= BG.locale.listInclude,
	[BG.VENDOR] 	= BG.locale.listVendor,
	[BG.AUTOSELL] 	= BG.locale.listSell,
	[BG.CUSTOM] 	= BG.locale.listCustom,
	[BG.AUCTION] 	= BG.locale.listAuction,
	[BG.DISENCHANT] = BG.locale.listDisenchant,
	[BG.UNUSABLE] 	= BG.locale.listUnusable,
	[BG.OUTDATED]   = BG.locale.listOutdated,
}
-- corresponding tags to be used in the LDB tooltip; EXCLUDE never shows up there!
BG.tag = {
	[BG.EXCLUDE]	= "K", -- keep
	[BG.INCLUDE] 	= "J", -- junk
	[BG.VENDOR] 	= "V",
	[BG.AUTOSELL] 	= "V",
	[BG.CUSTOM]		= "C",
	[BG.AUCTION] 	= "A",
	[BG.DISENCHANT] = "D",
	[BG.UNUSABLE] 	= "U",
	[BG.OUTDATED]   = "O",
}

-- do not change this! these are identifiers used in the code
BG.lists = {
	[BG.EXCLUDE] 	= "exclude",
	[BG.INCLUDE] 	= "include",
	[BG.AUTOSELL] 	= "autoSellList",
	[BG.VENDOR] 	= "forceVendorPrice",
}

BG.modules = {}		-- plugins get saved in here
BG.junkValue = 0	-- value to show on sell icon
BG.playerClass = select(2,UnitClass("player"))

BG.disableKey = {
	["None"] 	= function() return false end,
	["SHIFT"] 	= IsShiftKeyDown,
	["ALT"] 	= IsAltKeyDown,
	["CTRL"] 	= IsControlKeyDown,
}

BG.enchanting = GetSpellInfo(7411)
BG.disenchant = GetSpellInfo(87067)
BG.tradeSkills = {
	[2259] 	= "Alchemy",
	[2018] 	= "Blacksmithing",
	[7411] 	= "Enchanting",
	[4036] 	= "Engineering",
	[13614] = "Herbalism",		-- actually 2366 but this has the correct skill name
	[45357] = "Inscription",
	[25229] = "Jewelcrafting",
	[2108] 	= "Leatherworking",
	[2575] 	= "Mining",
	[8613] 	= "Skinning",
	[3908] 	= "Tailoring",

	[78670]	= "Archaeology",
	[2550] 	= "Cooking",
	[3273] 	= "First Aid",
	[7620] 	= "Fishing",
}
