local _, BGC = ...

-- GLOBALS: SLASH_Broker_Garbage1. SLASH_Broker_Garbage2, SLASH_Broker_Garbage3, Broker_Garbage, Broker_Garbage_LootManager
-- GLOBALS: InterfaceOptionsFrame_OpenToCategory, GetItemInfo, IsAddOnLoaded
local type = type
local select = select
local tonumber = tonumber
local ipairs = ipairs
local format = string.format

SLASH_Broker_Garbage1 = "/garbage"
SLASH_Broker_Garbage2 = "/garb"
SLASH_Broker_Garbage3 = "/junk"
local COMMAND_ALIAS = {
--	alias 		= 'original'
	options		= 'config',
	option		= 'config',
	menu		= 'config',
	display 	= 'format',
	glimit 		= 'globallimit',
	numlines 	= 'tooltiplines',
	height 		= 'tooltipheight',
	value 		= 'minvalue',
	freeslots 	= 'minfreeslots',
	minfree 	= 'minfreeslots',
	slots 		= 'minfreeslots',
	free 		= 'minfreeslots',
	category 	= 'categories',
	list 		= 'categories',
	lists 		= 'categories',
	updatecache = 'cache',
	resetcache 	= 'cache',
	update 		= 'cache',

	treasure 	= 'exclude',
	keep 		= 'exclude',
	garbage 	= 'include',
	junk 		= 'include',
	autosell 	= 'autoSellList',
	vendor 		= 'autoSellList',
	autoselllist = 'autoSellList',
	vendorprice	= 'forceVendorPrice',
	forceprice 	= 'forceVendorPrice',
	forcevendorprice = 'forceVendorPrice',
}
-- + = documented, implemented; - = not documented, implemented
local COMMAND_PARAMS = {
	-- + open config UI
	config = function(param)
		InterfaceOptionsFrame_OpenToCategory(BGC.options)
	end,

	-- + change LDB display format
	format = function(param)
		if param == "reset" then
			Broker_Garbage:SetOption("LDBformat", true, Broker_Garbage.defaultGlobalSettings.LDBformat)
		else
			Broker_Garbage:SetOption("LDBformat", true, param)
		end
		Broker_Garbage:ScanInventory()
	end,

	-- + set local limit for item
	limit = function(param)
		local itemID, count = param:match("^[^0-9]-([0-9]+).-([0-9]+)$")
		itemID 	= tonumber(itemID) or -1
		count 	= tonumber(count) or -1

		if itemID < 1 or count < 0 then
			BGC:Print(BGC.locale.invalidArgument)
			return
		end

		Broker_Garbage.itemsCache[itemID] = nil

		local table = Broker_Garbage:SetOption("include", false)
		table[itemID] = count

		local itemLink = select(2, GetItemInfo(itemID)) or BGC.locale.unknown
		BGC:Print(format(BGC.locale.limitSet, itemLink, count))
		BGC:ListOptionsUpdate("include")
	end,

	-- + set global limit for item
	globallimit = function(param)
		local itemID, count = param:match("^[^0-9]-([0-9]+).-([0-9]+)$")
		itemID 	= tonumber(itemID) or -1
		count 	= tonumber(count) or -1

		if itemID < 1 or count < 0 then
			BGC.Print(BGC.locale.invalidArgument)
			return
		end

		Broker_Garbage.itemsCache[itemID] = nil

		local table = Broker_Garbage:GetOption("include", true)
		table[itemID] = count

		local itemLink = select(2, GetItemInfo(itemID)) or BGC.locale.unknown
		BGC:Print(format(BGC.locale.limitSet, itemLink, count))
		BGC:ListOptionsUpdate("include")
	end,

	-- + set number of displayed LDB tooltip lines
	tooltiplines = function(param)
		param = tonumber(param)
		if not param then
			BGC:Print(BGC.locale.invalidArgument)
			return
		end
		Broker_Garbage:SetOption("tooltipNumItems", true, param)
		Broker_Garbage:ScanInventory()
		if BGC.options.currentTab and BGC.modules[BGC.options.currentTab].panel.Update then
			BGC.modules[BGC.options.currentTab].panel:Update()
		end
	end,

	-- + set pixel height of LDB tooltip
	tooltipheight = function(param)
		param = tonumber(param)
		if not param then
			BGC:Print(BGC.locale.invalidArgument)
			return
		end
		Broker_Garbage:SetOption("tooltipMaxHeight", true, param)
		if BGC.options.currentTab and BGC.modules[BGC.options.currentTab].panel.Update then
			BGC.modules[BGC.options.currentTab].panel:Update()
		end
	end,

	-- + set minimum item value for looting
	minvalue = function(param)
		if not IsAddOnLoaded('Broker_Garbage-LootManager') then
			Broker_Garbage.Print("This command requires Broker_Garbage-LootManager")
			return
		end

		param = tonumber(param) or -1
		if param < 0 then
			BGC:Print(BGC.locale.invalidArgument)
			return
		end

		Broker_Garbage_LootManager:Set("itemMinValue", param)
		BGC:Print(format(BGC.locale.minValueSet, Broker_Garbage.FormatMoney(Broker_Garbage:GetOption("itemMinValue", false))))
	end,

	-- + set minimum available bag slots for auto destroying
	minfreeslots = function(param)
		if not IsAddOnLoaded('Broker_Garbage-LootManager') then
			Broker_Garbage.Print("This command requires Broker_Garbage-LootManager")
			return
		end

		param = tonumber(param)
		if not param then
			BGC:Print(BGC.locale.invalidArgument)
			return
		end

		Broker_Garbage_LootManager:Set("tooFewSlots", param, true)
		BGC.Print(format(BGC.locale.minSlotsSet, Broker_Garbage:GetOption("tooFewSlots", false)))
	end,

	-- + list all listed categories an item belongs to
	categories = function(param)
		param = Broker_Garbage.GetItemID(param) or param
		if not param then
			BGC:Print(BGC.locale.invalidArgument)
			return
		end

		local itemLink = select(2, GetItemInfo(param))
		local result = Broker_Garbage.GetItemListCategories(Broker_Garbage.GetCached(param))
		if not result or #result < 1 then
			BGC:Print(format("%s is in no used category.", itemLink))
		else
			for _, listName in ipairs(result) do
				BGC:Print(format("%s is in category %s.", itemLink, listName))
			end
		end
	end,

	-- + add an <itemID/itemLink/category/...> to a <list>
	add = function(param)
		local list, item = param:match("^(%S*)%s*(.-)%s*$")
		if not (list and item) then
			BGC:Print(BGC.locale.invalidArgument)
			return
		end
		list = list:lower()

		local itemID = tonumber(item) or item
		if type(itemID) == "string" then
			itemID = Broker_Garbage.GetItemID(item) or itemID
		elseif type(itemID) == "number" then
			itemID = item
		end

		local itemList = COMMAND_ALIAS[list] or list
		local resetRequired = BGC.RemoteAddItemToList(item, itemList)
		if resetRequired then
			-- BGC:Print(BGC.locale.updateCache)
			Broker_Garbage.UpdateAllDynamicItems()
			Broker_Garbage:UpdateLDB()
		end
	end,
	remove = function(param)
		local list, item = param:match("^(%S*)%s*(.-)%s*$")
		if not (list and item) then
			BGC:Print(BGC.locale.invalidArgument)
			return
		end
		list = list:lower()

		local itemID = tonumber(item) or item
		if type(itemID) == "string" then
			itemID = Broker_Garbage.GetItemID(item) or itemID
		elseif type(itemID) == "number" then
			itemID = item
		end

		local itemList = COMMAND_ALIAS[list] or list
		local resetRequired = BGC.RemoteRemoveItemFromList(item, itemList)
		if resetRequired then
			-- BGC:Print(BGC.locale.updateCache)
			Broker_Garbage.UpdateAllDynamicItems()
			Broker_Garbage:UpdateLDB()
		end
	end,

	cache = function(item)
		local item = item and tonumber(item) or item
		if item and type(item) == "number" then
			Broker_Garbage.UpdateAllCaches(item)
		else
			Broker_Garbage.UpdateAllDynamicItems()
		end
	end
}

local function handler(msg)
	local command, param = msg:match("^(%S*)%s*(.-)%s*$")
	command = command:lower()

	if COMMAND_PARAMS[command] then
		COMMAND_PARAMS[command](param)
		return
	end
	if COMMAND_ALIAS[command] then
		local alias = COMMAND_ALIAS[command]
		if alias and COMMAND_PARAMS[alias] then
			COMMAND_PARAMS[alias](param)
			return
		end
	end

	-- commands don't match
	BGC:Print(BGC.locale.slashCommandHelp)
end
SlashCmdList["Broker_Garbage"] = handler
