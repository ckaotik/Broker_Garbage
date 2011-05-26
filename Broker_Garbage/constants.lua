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
	overrideLPT = false,			-- [TODO] add options dialog
	
	disableKey = "SHIFT",
	autoSellIncludeItems = false,	-- toggle include list being sell list as well
	keepItemsForLaterDE = true,		-- [TODO] new!

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
	hideZeroValue = true,		-- [TODO]: add options dialog; shows/hides any items with '0c' value (quest, event items etc.)
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
	showClams = true,
	
	-- output options
	reportNothingToSell = true,
	reportDisenchantOutdated = false,	-- TODO: add options dialog
}

BG.defaultLocalSettings = {
	-- lists
	exclude = {},
	include = {},
	autoSellList = {},

	-- behavior
	neverRepairGuildBank = false,

	-- default values
	moneyLostByDeleting = 0,
	moneyEarned = 0,
}

-- item classifications
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

BG.modules = {}		-- plugins get saved in here
BG.toSellValue = {}	-- value to show on sell icon
BG.clams = {15874, 5523, 5524, 7973, 24476, 36781, 45909, 32724, 52340}
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
	[2366] = "Herbalism",		-- Really? Call its skill Herbaslism as well then!
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

local armorTypes = { GetAuctionItemSubClasses(2) }
local weaponTypes = { GetAuctionItemSubClasses(1) }
BG.usableGear = {
	[armorTypes[1]] = {"DEATHKNIGHT", "DRUID", "HUNTER", "MAGE", "PALADIN", "PRIEST", "ROGUE", "SHAMAN", "WARLOCK", "WARRIOR"},		-- misc, e.g. tabards
	[armorTypes[2]] = {"DEATHKNIGHT", "DRUID", "HUNTER", "MAGE", "PALADIN", "PRIEST", "ROGUE", "SHAMAN", "WARLOCK", "WARRIOR"},		-- cloth
	[armorTypes[3]] = {"DEATHKNIGHT", "DRUID", "HUNTER", "PALADIN", "ROGUE", "SHAMAN", "WARRIOR"},		-- leather
	[armorTypes[4]] = {"DEATHKNIGHT", "HUNTER", "PALADIN", "SHAMAN", "WARRIOR"},		-- mail
	[armorTypes[5]] = {"DEATHKNIGHT", "PALADIN", "WARRIOR"},		-- plate
	[armorTypes[6]] = {"PALADIN", "SHAMAN", "WARRIOR"},		-- shields
	[armorTypes[7]] = {"DEATHKNIGHT", "DRUID", "PALADIN", "SHAMAN"},	-- relic
	
	[weaponTypes[1]] = {"DEATHKNIGHT", "HUNTER", "PALADIN", "ROGUE", "SHAMAN", "WARRIOR"},	-- 1H axes
	[weaponTypes[2]] = {"DEATHKNIGHT", "HUNTER", "PALADIN", "SHAMAN", "WARRIOR"},	-- 2H axes
	[weaponTypes[3]] = {"HUNTER", "ROGUE", "WARRIOR"},	-- bows
	[weaponTypes[4]] = {"HUNTER", "ROGUE", "WARRIOR"},	-- guns
	[weaponTypes[5]] = {"DEATHKNIGHT", "DRUID", "PALADIN", "PRIEST", "ROGUE", "SHAMAN", "WARRIOR"},	-- 1H maces
	[weaponTypes[6]] = {"DEATHKNIGHT", "DRUID", "PALADIN", "SHAMAN", "WARRIOR"},	-- 2H maces
	[weaponTypes[7]] = {"DEATHKNIGHT", "DRUID", "HUNTER", "PALADIN", "WARRIOR"},	-- polearms
	[weaponTypes[8]] = {"DEATHKNIGHT", "HUNTER", "MAGE", "PALADIN", "ROGUE", "WARLOCK", "WARRIOR"},	-- 1H swords
	[weaponTypes[9]] = {"DEATHKNIGHT", "HUNTER", "PALADIN", "WARRIOR"},	-- 2H swords
	[weaponTypes[10]] = {"DRUID", "HUNTER", "MAGE", "PRIEST", "SHAMAN", "WARLOCK", "WARRIOR"},	-- staves
	[weaponTypes[11]] = {"DRUID", "HUNTER", "ROGUE", "SHAMAN", "WARRIOR"},	-- fist weapons
	--[weaponTypes[12]] = true,	-- misc
	[weaponTypes[13]] = {"DRUID", "HUNTER", "MAGE", "PRIEST", "ROGUE", "SHAMAN", "WARLOCK", "WARRIOR"},	-- daggers
	[weaponTypes[14]] = {"HUNTER", "ROGUE", "WARRIOR"},	-- thrown weapons
	[weaponTypes[15]] = {"HUNTER", "ROGUE", "WARRIOR"},	-- crossbows
	[weaponTypes[16]] = {"MAGE", "PRIEST", "WARLOCK"},	-- wands
	[weaponTypes[17]] = {"DEATHKNIGHT", "DRUID", "HUNTER", "MAGE", "PALADIN", "PRIEST", "ROGUE", "SHAMAN", "WARLOCK", "WARRIOR"},	-- fishing rod
}

BG.usableByAll = {
	["INVTYPE_NECK"] = true,
	["INVTYPE_FINGER"] = true,
	["INVTYPE_TRINKET"] = true,
	["INVTYPE_HOLDABLE"] = true,
}