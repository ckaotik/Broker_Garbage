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
	sellNotWearable = false,
	sellOldGear = false,
	showSellLog = false,
	overrideLPT = false,
	restackInventory = false,
	
	disableKey = "SHIFT",
	autoSellIncludeItems = false,	-- toggle include list being sell list as well
	keepItemsForLaterDE = 0,

	-- tresholds
	dropQuality = 0,
	sellNWQualityTreshold = 4,
		
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
	useRealValues = false,
	hideZeroValue = true,
	showAutoSellIcon = true,
	
	-- LibDataBroker Display
	LDBformat = "[itemname]x[itemcount] ([itemvalue])",
	LDBNoJunk = BG.locale.label,
	
	-- tooltip
	showIcon = true,
	showLost = true,
	showEarned = true,
	showSource = false,
	showContainers = true,
	
	-- output options
	reportNothingToSell = true,
	reportDisenchantOutdated = false,
}

BG.defaultLocalSettings = {
	-- lists
	exclude = {},
	include = {},
	autoSellList = {},

	-- behavior
	repairGuildBank = true,

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
BG.OUTDATED = 5		-- item is gear but irrelevant (TopFit)
-- price types
BG.AUCTION = 6
BG.VENDOR = 7
BG.DISENCHANT = 8

-- corresponding tags to be used in the LDB tooltip; EXCLUDE never shows up there!
BG.tag = {
	[BG.INCLUDE] 	= "|cFFffffffI",	-- white
	[BG.VENDOR] 	= "|cFFff9c5aV",	-- orange
	[BG.AUTOSELL] 	= "|cFFff592dV",	-- dark orange
	[BG.AUCTION] 	= "|cFF2bff58A",	-- green
	[BG.DISENCHANT] = "|cFFe052ffD",	-- purple
	[BG.UNUSABLE] 	= "|cFF3c73abG",	-- blue
	[BG.OUTDATED]   = "|cFF3c73abO",	-- blue
}

BG.lists = {
	[BG.EXCLUDE] = "exclude",
	[BG.INCLUDE] = "include",
	[BG.AUTOSELL] = "autoSellList",
	[BG.VENDOR] = "forceVendorPrice",
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
BG.tradeSkills = {
	[2259] = "Alchemy",
	[2018] = "Blacksmithing",
	[7411] = "Enchanting",
	[4036] = "Engineering",
	[13614] = "Herbalism",		-- actually 2366 but this has the correct skill name
	[45357] = "Inscription",
	[25229] = "Jewelcrafting",
	[2108] = "Leatherworking",
	[2575] = "Mining",
	[8613] = "Skinning",
	[3908] = "Tailoring",
		
	[78670] = "Archaeology",
	[2550] = "Cooking",
	[3273] = "First Aid",
	[7620] = "Fishing",
}