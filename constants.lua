_, BrokerGarbage = ...

-- default saved variables
BrokerGarbage.defaultGlobalSettings = {
	-- lists :: key is either the itemID -or- the PeriodicTable category string, value is true -or- limit number
	exclude = {},
	include = {},
	autoSellList = {},
	forceVendorPrice = {},		-- only global

	-- behavior
	autoSellToVendor = true,
	autoRepairAtVendor = true,
	disableKey = "SHIFT",
	hideZeroValue = true,		-- TODO: provide interface options. disable this to have zero value items (quest items, event items etc.) show up in BG tooltip, enable it to hide them
	sellNotWearable = false,
	sellNWQualityTreshold = 4,
	autoSellIncludeItems = false,
	
	-- default values
	tooltipMaxHeight = 220,
	tooltipNumItems = 9,
	dropQuality = 0,
	showMoney = 2,
	hasEnchanter = true,
	
	-- statistic values
	moneyLostByDeleting = 0,
	moneyEarned = 0,
	itemsSold = 0,
	itemsDropped = 0,
	
	-- display options
	showAutoSellIcon = true,
	reportNothingToSell = true,
	showLost = true,
	showEarned = true,
	LDBformat = "[itemname]x[itemcount] ([itemvalue])",
	LDBNoJunk = BrokerGarbage.locale.label,
	showSource = false,
}

BrokerGarbage.defaultLocalSettings = {
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

BrokerGarbage.toSellValue = {}	-- value to show on sell icon

-- item classification
BrokerGarbage.EXCLUDE = 0		-- item is excluded. Nothing happened...
BrokerGarbage.INCLUDE = 1		-- item is on include list
BrokerGarbage.LIMITED = 2		-- item is on include list, but has a limit value
BrokerGarbage.UNUSABLE = 3		-- item is gear but not usable

BrokerGarbage.AUCTION = 4		-- auction price is highest value
BrokerGarbage.VENDOR = 5		-- vendor price is highest value
BrokerGarbage.VENDORLIST = 6	-- item is on sell list
BrokerGarbage.DISENCHANT = 7	-- disenchant price is highest value

-- corresponding tags to be used in the LDB tooltip
BrokerGarbage.tag = {
	-- exclude doesn't show up on tooltip, so it's not needed here
	[BrokerGarbage.INCLUDE] 	= "|cFFffffffI",	-- white
	[BrokerGarbage.LIMITED] 	= "|cFFffffffL",	-- white
	[BrokerGarbage.UNUSABLE] 	= "|cFF3c73abG",	-- blue
	[BrokerGarbage.AUCTION] 	= "|cFF2bff58A",	-- green
	[BrokerGarbage.VENDOR] 		= "|cFFff9c5aV",	-- orange
	[BrokerGarbage.VENDORLIST] 	= "|cFFff592dV",	-- dark orange
	[BrokerGarbage.DISENCHANT] 	= "|cFFe052ffD",	-- purple
}
-- |cffffd200 Blizzard Orange; textures: Spell_Holy_HolyGuidance, achievement_bg_returnxflags_def_wsg

BrokerGarbage.clams = {15874, 5523, 5524, 7973, 24476, 36781, 45909}
BrokerGarbage.playerClass = select(2,UnitClass("player"))
BrokerGarbage.enchanting = GetSpellInfo(7411)

BrokerGarbage.disableKey = {
	["None"] 	= function() return false end,
	["SHIFT"] 	= IsShiftKeyDown,
	["ALT"] 	= IsAltKeyDown,
	["CTRL"] 	= IsControlKeyDown,
}

-- rarity strings (no need to localize)
BrokerGarbage.quality = {
	[0] = select(4,GetItemQualityColor(0))..ITEM_QUALITY0_DESC.."|r",	-- gray (junk)
	[1] = select(4,GetItemQualityColor(1))..ITEM_QUALITY1_DESC.."|r",	-- white
	[2] = select(4,GetItemQualityColor(2))..ITEM_QUALITY2_DESC.."|r",	-- green
	[3] = select(4,GetItemQualityColor(3))..ITEM_QUALITY3_DESC.."|r",	-- blue
	[4] = select(4,GetItemQualityColor(4))..ITEM_QUALITY4_DESC.."|r",	-- purple
	[5] = select(4,GetItemQualityColor(5))..ITEM_QUALITY5_DESC.."|r",	-- legendary
	[6] = select(4,GetItemQualityColor(6))..ITEM_QUALITY6_DESC.."|r",	-- heirloom
	[7] = select(4,GetItemQualityColor(7))..ITEM_QUALITY7_DESC.."|r",	-- artifact
}

BrokerGarbage.tradeSkills = {
	[2] = "Leatherworking",
	[3] = "Tailoring",
	[4] = "Engineering",
	[5] = "Blacksmithing",
	[6] = "Cooking",
	[7] = "Alchemy",
	[8] = "First Aid",
	[9] = "Enchanting",
	[10] = "Fishing",
	[11] = "Jewelcrafting",
	[12] = "Inscription",
}

local armorTypes = { GetAuctionItemSubClasses(2) }
local weaponTypes = { GetAuctionItemSubClasses(1) }
local ammoTypes = { GetAuctionItemSubClasses(7) }
BrokerGarbage.usableByClass = {
-- ------------- TODO ---------------------------
	["DEATHKNIGHT"] = {
		[armorTypes[1]] = true,		-- misc, e.g. tabards
		[armorTypes[2]] = true,		-- cloth
		[armorTypes[3]] = true,		-- leather
		[armorTypes[4]] = true,		-- mail
		[armorTypes[5]] = true,		-- plate
		[armorTypes[10]] = true,	-- seal
		
		[weaponTypes[1]] = true,	-- 1H axes
		[weaponTypes[2]] = true,	-- 2H axes
		[weaponTypes[5]] = true,	-- 1H maces
		[weaponTypes[6]] = true,	-- 2H maces
		[weaponTypes[7]] = true,	-- polearms
		[weaponTypes[8]] = true,	-- 1H swords
		[weaponTypes[9]] = true,	-- 2H swords
		--[weaponTypes[12]] = true,	-- misc
		[weaponTypes[17]] = true,	-- fishing rod
	},
	["DRUID"] = {
		[armorTypes[1]] = true,		-- misc, e.g. tabards
		[armorTypes[2]] = true,		-- cloth
		[armorTypes[3]] = true,		-- leather
		[armorTypes[8]] = true,		-- relic
		
		[weaponTypes[5]] = true,	-- 1H maces
		[weaponTypes[6]] = true,	-- 2H maces
		[weaponTypes[7]] = true,	-- polearms
		[weaponTypes[10]] = true,	-- staves
		[weaponTypes[11]] = true,	-- fist weapons
		--[weaponTypes[12]] = true,	-- misc
		[weaponTypes[13]] = true,	-- daggers
		[weaponTypes[17]] = true,	-- fishing rod
	},
	["HUNTER"] = {
		[armorTypes[1]] = true,		-- misc, e.g. tabards
		[armorTypes[2]] = true,		-- cloth
		[armorTypes[3]] = true,		-- leather
		[armorTypes[4]] = true,		-- mail
		
		[weaponTypes[1]] = true,	-- 1H axes
		[weaponTypes[2]] = true,	-- 2H axes
		[weaponTypes[3]] = true,	-- bows
		[weaponTypes[4]] = true,	-- guns
		[weaponTypes[7]] = true,	-- polearms
		[weaponTypes[8]] = true,	-- 1H swords
		[weaponTypes[9]] = true,	-- 2H swords
		[weaponTypes[10]] = true,	-- staves
		[weaponTypes[11]] = true,	-- fist weapons
		--[weaponTypes[12]] = true,	-- misc
		[weaponTypes[13]] = true,	-- daggers
		[weaponTypes[15]] = true,	-- crossbows
		[weaponTypes[17]] = true,	-- fishing rod
		
		[ammoTypes[1]] = true,		-- arrow
		[ammoTypes[2]] = true,		-- bullet
	},
	["MAGE"] = {
		[armorTypes[1]] = true,		-- misc, e.g. tabards
		[armorTypes[2]] = true,		-- cloth
		
		[weaponTypes[8]] = true,	-- 1H swords
		[weaponTypes[10]] = true,	-- staves
		--[weaponTypes[12]] = true,	-- misc
		[weaponTypes[13]] = true,	-- daggers
		[weaponTypes[16]] = true,	-- wands
		[weaponTypes[17]] = true,	-- fishing rod
	},
	["PALADIN"] = {
		[armorTypes[1]] = true,		-- misc, e.g. tabards
		[armorTypes[2]] = true,		-- cloth
		[armorTypes[3]] = true,		-- leather
		[armorTypes[4]] = true,		-- mail
		[armorTypes[5]] = true,		-- plate
		[armorTypes[6]] = true,		-- shields
		[armorTypes[7]] = true,		-- librams
		
		[weaponTypes[1]] = true,	-- 1H axes
		[weaponTypes[2]] = true,	-- 2H axes
		[weaponTypes[5]] = true,	-- 1H maces
		[weaponTypes[6]] = true,	-- 2H maces
		[weaponTypes[7]] = true,	-- polearms
		[weaponTypes[8]] = true,	-- 1H swords
		[weaponTypes[9]] = true,	-- 2H swords
		--[weaponTypes[12]] = true,	-- misc
		[weaponTypes[17]] = true,	-- fishing rod
	},
	["PRIEST"] = {
		[armorTypes[1]] = true,		-- misc, e.g. tabards
		[armorTypes[2]] = true,		-- cloth
		
		[weaponTypes[5]] = true,	-- 1H maces
		[weaponTypes[10]] = true,	-- staves
		--[weaponTypes[12]] = true,	-- misc
		[weaponTypes[13]] = true,	-- daggers
		[weaponTypes[16]] = true,	-- wands
		[weaponTypes[17]] = true,	-- fishing rod
	},
	["ROGUE"] = {
		[armorTypes[1]] = true,		-- misc, e.g. tabards
		[armorTypes[2]] = true,		-- cloth
		[armorTypes[3]] = true,		-- leather
		
		[weaponTypes[1]] = true,	-- 1H axes
		[weaponTypes[3]] = true,	-- bows
		[weaponTypes[4]] = true,	-- guns
		[weaponTypes[5]] = true,	-- 1H maces
		[weaponTypes[8]] = true,	-- 1H swords
		[weaponTypes[11]] = true,	-- fist weapons
		--[weaponTypes[12]] = true,	-- misc
		[weaponTypes[13]] = true,	-- daggers
		[weaponTypes[14]] = true,	-- thrown weapons
		[weaponTypes[15]] = true,	-- crossbows
		[weaponTypes[17]] = true,	-- fishing rod
		
		[ammoTypes[1]] = true,		-- arrow
		[ammoTypes[2]] = true,		-- bullet
	},
	["SHAMAN"] = {
		[armorTypes[1]] = true,		-- misc, e.g. tabards
		[armorTypes[2]] = true,		-- cloth
		[armorTypes[3]] = true,		-- leather
		[armorTypes[4]] = true,		-- mail
		[armorTypes[6]] = true,		-- shields
		[armorTypes[9]] = true,		-- totems
		
		[weaponTypes[1]] = true,	-- 1H axes
		[weaponTypes[2]] = true,	-- 2H axes
		[weaponTypes[5]] = true,	-- 1H maces
		[weaponTypes[6]] = true,	-- 2H maces
		[weaponTypes[10]] = true,	-- staves
		[weaponTypes[11]] = true,	-- fist weapons
		--[weaponTypes[12]] = true,	-- misc
		[weaponTypes[13]] = true,	-- daggers
		[weaponTypes[17]] = true,	-- fishing rod
	},
	["WARLOCK"] = {
		[armorTypes[1]] = true,		-- misc, e.g. tabards
		[armorTypes[2]] = true,		-- cloth
		
		[weaponTypes[8]] = true,	-- 1H swords
		[weaponTypes[10]] = true,	-- staves
		--[weaponTypes[12]] = true,	-- misc
		[weaponTypes[13]] = true,	-- daggers
		[weaponTypes[16]] = true,	-- wands
		[weaponTypes[17]] = true,	-- fishing rod
	},
	["WARRIOR"] = {
		[armorTypes[1]] = true,		-- misc, e.g. tabards
		[armorTypes[2]] = true,		-- cloth
		[armorTypes[3]] = true,		-- leather
		[armorTypes[4]] = true,		-- mail
		[armorTypes[5]] = true,		-- plate
		[armorTypes[6]] = true,		-- shields
		
		[weaponTypes[1]] = true,	-- 1H axes
		[weaponTypes[2]] = true,	-- 2H axes
		[weaponTypes[3]] = true,	-- bows
		[weaponTypes[4]] = true,	-- guns
		[weaponTypes[5]] = true,	-- 1H maces
		[weaponTypes[6]] = true,	-- 2H maces
		[weaponTypes[7]] = true,	-- polearms
		[weaponTypes[8]] = true,	-- 1H swords
		[weaponTypes[9]] = true,	-- 2H swords
		[weaponTypes[10]] = true,	-- staves
		[weaponTypes[11]] = true,	-- fist weapons
		--[weaponTypes[12]] = true,	-- misc
		[weaponTypes[13]] = true,	-- daggers
		[weaponTypes[14]] = true,	-- thrown weapons
		[weaponTypes[15]] = true,	-- crossbows
		[weaponTypes[17]] = true,	-- fishing rod
		
		[ammoTypes[1]] = true,		-- arrow
		[ammoTypes[2]] = true,		-- bullet
	},
}

BrokerGarbage.usableByAll = {
	["INVTYPE_NECK"] = true,
	["INVTYPE_FINGER"] = true,
	["INVTYPE_TRINKET"] = true,
	["INVTYPE_HOLDABLE"] = true,
}