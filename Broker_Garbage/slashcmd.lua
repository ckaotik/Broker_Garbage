local addonName, addon, _ = ...

-- GLOBALS: _G, LibStub
-- GLOBALS: InterfaceAddOnsList_Update, InterfaceOptionsList_DisplayPanel, InterfaceOptionsFrame_OpenToCategory, GetItemInfo
-- GLOBALS: ipairs, type, tonumber, select

local L = {
	['invalidArgument'] = 'You supplied an invalid argument. Please check your input and try again.',
	['slashCommandHelp'] = [[supports |cffee6622/garbage|r, |cffee6622/garb|r, |cffee6622/junk|r with these commands:
    |cFF36BFA8config|r opens the options panel.
    |cFF36BFA8add|r |cFF2bff58<list>|r |cFF2bff58<item>|r Add an item/category to a list.
    |cFF36BFA8remove|r |cFF2bff58<list>|r |cFF2bff58<item>|r Remove item/category from a given list.
        Possible list names: |cFF2bff58keep|r, |cFF2bff58junk|r, |cFF2bff58vendor|r, |cFF2bff58forceprice|r
    |cFF36BFA8update|r |cFF2bff58<itemID>|r Refresh saved data
    |cFF36BFA8format|r |cFF2bff58<text>|r lets you customize the LDB display text, |cFF2bff58reset|r resets it.
    |cFF36BFA8categories|r |cFF2bff58<item>|r list of used categories with this item.]],
}

local function GetListName(list)
	if list == 'keep' or list == 'exclude' or list == 'treasure' then
		return 'keep'
	elseif list == 'toss' or list == 'junk' or list =='include' or list == 'garbage' then
		return 'toss'
	elseif list == 'sell' or list == 'autosell' or list == 'vendor' or list == 'autoselllist' then
		return 'toss', 1
	elseif list == 'vendorprice' or list == 'forceprice' or list == 'forcevendorprice' then
		return 'prices'
	end
end

local COMMAND_ALIAS = { -- map of alias => command
	options		= 'config',
	option		= 'config',
	menu		= 'config',
	display 	= 'format',
	glimit 		= 'globallimit',
	numlines 	= 'tooltiplines',
	height 		= 'tooltipheight',
	category 	= 'categories',
	list 		= 'categories',
	lists 		= 'categories',
	updatecache = 'cache',
	resetcache 	= 'cache',
	update 		= 'cache',
}

-- + = documented, implemented; - = not documented, implemented
local COMMAND_PARAMS = {
	-- + open config UI
	config = function(param)
		InterfaceOptionsFrame_OpenToCategory(addonName)
	end,

	-- + change LDB display format
	format = function(param)
		if param == "reset" then
			addon:SetOption("label", true, addon.db.defaults.global.label)
		else
			addon:SetOption("label", true, param)
		end
		addon:ScanInventory()
	end,

	-- + set local limit for item
	limit = function(param)
		local itemID, count = param:match("^[^0-9]-([0-9]+).-([0-9]+)$")
		itemID 	= tonumber(itemID) or -1
		count 	= tonumber(count) or -1

		if itemID < 1 or count < 0 then
			return false
		end

		addon.itemsCache[itemID] = nil

		local table = addon:SetOption("include", false)
		table[itemID] = count

		local itemLink = select(2, GetItemInfo(itemID)) or _G.UNKNOWN
		addon.Print(("%s has been assigned a limit of %d."):format(itemLink, count))
		-- BGC:ListOptionsUpdate("include")
	end,

	-- + set global limit for item
	globallimit = function(param)
		local itemID, count = param:match("^[^0-9]-([0-9]+).-([0-9]+)$")
		itemID 	= tonumber(itemID) or -1
		count 	= tonumber(count) or -1

		if itemID < 1 or count < 0 then
			return false
		end

		addon.itemsCache[itemID] = nil

		local table = addon:GetOption("include", true)
		table[itemID] = count

		local itemLink = select(2, GetItemInfo(itemID)) or _G.UNKNOWN
		addon.Print(("%s has been assigned a limit of %d."):format(itemLink, count))
		-- BGC:ListOptionsUpdate("include")
	end,

	-- + set number of displayed LDB tooltip lines
	tooltiplines = function(param)
		param = tonumber(param)
		if not param then
			return false
		end
		addon:SetOption("tooltipNumItems", true, param)
		addon:ScanInventory()
		-- TODO: update config panel
	end,

	-- + set pixel height of LDB tooltip
	tooltipheight = function(param)
		param = tonumber(param)
		if not param then
			return false
		end
		addon:SetOption("tooltipMaxHeight", true, param)
		-- TODO: update config panel
	end,

	-- + list all listed categories an item belongs to
	categories = function(param)
		param = addon.GetItemID(param) or param
		if not param then
			return false
		end

		local itemLink = select(2, GetItemInfo(param))
		-- TODO: FIXME
		local result = addon.GetItemListCategories(addon.GetCached(param))
		if not result or #result < 1 then
			addon.Print(("%s is in no used category."):format(itemLink))
		else
			for _, listName in ipairs(result) do
				addon.Print(("%s is in category %s."):format(itemLink, listName))
			end
		end
	end,

	-- + add an <itemID/itemLink/category/...> to a <list>
	add = function(param)
		-- TODO: allow limit count?
		local list, item = param:match("^(%S*)%s*(.-)%s*$")
		local list, listValue = GetListName(list and list:lower() or '')
		if not list or not item then
			return false
		end
		local itemID = tonumber(item) or addon.GetItemID(item) or item
		addon.Add(list, itemID, listValue)
	end,
	remove = function(param)
		local list, item = param:match("^(%S*)%s*(.-)%s*$")
		      list = GetListName(list and list:lower() or '')
		if not list or not item then
			return false
		end
		local itemID = tonumber(item) or addon.GetItemID(item) or item
		addon.Remove(list, itemID)
	end,

	cache = function(item)
		local item = item and tonumber(item) or item
		if item and type(item) == "number" then
			addon.UpdateAllCaches(item)
		else
			addon.UpdateAllDynamicItems()
		end
	end
}

function addon:RegisterSlashCommand(command, handler, aliases, helpText)
	if COMMAND_PARAMS[command] then
		return false, 'Command is already registered.'
	end

	if type(aliases) == 'table' then
		for _, alias in ipairs(aliases) do
			COMMAND_ALIAS[alias] = command
		end
	elseif aliases then
		COMMAND_ALIAS[aliases] = command
	end
	COMMAND_PARAMS[command] = handler

	if helpText and helpText ~= '' then
		L['slashCommandHelp'] = L['slashCommandHelp'] .. '\n    |cFF36BFA8' .. command .. '|r ' .. helpText
	end

	return true
end

local function handler(msg)
	local command, param = msg:match("^(%S*)%s*(.-)%s*$")
	command = command:lower()

	local baseCommand = COMMAND_ALIAS[command] or command
	if COMMAND_PARAMS[baseCommand] then
		-- command can be handled
		if COMMAND_PARAMS[baseCommand](param) == false then
			addon.Print(L['invalidArgument'])
		end
		return
	end

	-- commands don't match
	addon.Print(L['slashCommandHelp'])
end

local slashName = addonName:upper()
_G['SLASH_' .. addonName .. '1'] = "/garbage"
_G['SLASH_' .. addonName .. '2'] = "/junk"

SlashCmdList[addonName] = handler
