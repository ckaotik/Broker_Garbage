local _, BG = ...

-- item classifications
BG.IGNORE = -1
-- static list types
BG.EXCLUDE = 0 -- unused
BG.INCLUDE = 1 -- mostly unused
BG.AUTOSELL = 2
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

	[BG.IGNORE]     = {"", "", ""},
	[BG.CUSTOM]     = {"|cFFf3d91b", "C", ""},
}

BG.priority = { "NEGATIVE", "NEUTRAL", "POSITIVE", "IGNORE" }
for i, priority in ipairs(BG.priority) do
	BG.priority[ priority ] = i
end

BG.reason = { "KEEP_ID", "KEEP_CAT", "TOSS_ID", "TOSS_CAT", "QUEST_ITEM", "UNUSABLE_ITEM", "OUTDATED_ITEM", "GRAY_ITEM", "PRICE_ITEM", "PRICE_CAT", "WORTHLESS", "EMPTY_SLOT", "HIGHEST_VALUE", "SOULBOUND", "QUALITY", "HIGHEST_LEVEL" }
for i, reason in ipairs(BG.reason) do
	BG.reason[ reason ] = i
end

BG.disableKey = {
	["NONE"] 	= function() return false end,
	["SHIFT"] 	= IsShiftKeyDown,
	["ALT"] 	= IsAltKeyDown,
	["CTRL"] 	= IsControlKeyDown,
}

BG.defaults = {
	global = {
		version = 1,
		dropQuality = 0,
		disableKey = "SHIFT",
		prices = {}, -- item/category preset prices
		showJunkSellIcons = false,

		disenchantValues = true,
		disenchantSkillOffset = 0,
		disenchantSuggestions = false,

		-- behavior
		keepHighestItemLevel = true,
		keepQuestItems = true,
		sellJunk = false, -- was: autoSellIncludeItems
		sellUnusable = false,
		sellUnusableQuality = 3,
		sellOutdated = false,
		sellOutdatedQuality = 3,

		LPTJunkIsJunk   = false,
		ignoreZeroValue = true,
		moneyFormat     = 'icon',

		-- LibDataBroker Display
		label = "[itemname]x[itemcount] ([itemvalue])",
		noJunkLabel = BG.locale.label,
		tooltip = {
			height = 220,
			numLines = 9,
			showIcon = true,
			showMoneyLost = true,
			showMoneyEarned = true,
			showReason = true,
			showUnopenedContainers = true, -- FIXME: deprecated
		},

		itemTooltip = {
			showClassification = true,
			showReason = false,
		},

		dataSources = {
			buyout = {}, 				-- was: auctionAddonOrder.buyout
			buyoutDisabled = {}, 		-- was: buyoutDisabledSources
			disenchant = {}, 			-- was: auctionAddonOrder.disenchant
			disenchantDisabled = {}, 	-- was: disenchantDisabledSources
		},
	},
	profile = {
		keep = {},
		toss = {},
	},
	char = {
		moneyLost   = 0,
		moneyEarned = 0,
		numSold     = 0,
		numDeleted  = 0,
	},
}
