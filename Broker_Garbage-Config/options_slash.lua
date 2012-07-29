local _, BGC = ...


SLASH_Broker_Garbage1 = "/garbage"
SLASH_Broker_Garbage2 = "/garb"
SLASH_Broker_Garbage3 = "/junk"
local COMMAND_LISTADDACTION = {
	-- [FIXME] access issues? update issues
	keep = function(item)
		BG_LocalDB.exclude[item] = true
	end,
	junk = function(item)
		BG_LocalDB.include[item] = true
	end,
	sell = function(item)
		BG_LocalDB.autoSellList[item] = true
	end,
	price = function(item)
		BG_GlobalDB.forceVendorPrice[item] = -1
	end
}
-- * = TODO; + = documented, implemented; - = not documented, implemented
local COMMAND_PARAMS = {
	-- + open config UI
	config = function(param)
		InterfaceOptionsFrame_OpenToCategory(BGC.options)
	end,

	-- - add item/category/... to lists
	quickadd = function(param)
		-- [TODO] quick add ui?
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

	-- - set number of displayed LDB tooltip lines
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

	-- - set pixel height of LDB tooltip
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
			print("This command requires Broker_Garbage-LootManager")
			return
		end

		param = tonumber(param) or -1
		if param < 0 then
			BGC:Print(BGC.locale.invalidArgument)
			return
		end

		Broker_Garbage_LootManager:SetMinValue(param)
		BGC:Print(format(BGC.locale.minValueSet, Broker_Garbage.FormatMoney(Broker_Garbage:GetOption("itemMinValue", false))))
	end,

	-- + set minimum available bag slots for auto destroying
	minfreeslots = function(param)
		if not IsAddOnLoaded('Broker_Garbage-LootManager') then
			print("This command requires Broker_Garbage-LootManager")
			return
		end

		param = tonumber(param)
		if not param then
			BGC:Print(BGC.locale.invalidArgument)
			return
		end

		Broker_Garbage_LootManager:SetMinSlots(param)
		BGC.Print(format(BGC.locale.minSlotsSet, Broker_Garbage:GetOption("tooFewSlots", false)))
	end,

	-- * list all listed categories an item belongs to
	categories = function(param)
		param = Broker_Garbage.GetItemID(param) or param
		if not param then
			BGC:Print(BGC.locale.invalidArgument)
			return
		end

		local itemLink = select(2, GetItemInfo(param))
		local result = Broker_Garbage.GetItemListCategories(Broker_Garbage.GetCached(param))
		if not result or #result < 1 then
			BGC:Print(string.format("%s is in no used category.", itemLink))
		else
			for _, listName in ipairs(result) do
				BGC:Print(string.format("%s is in category %s.", itemLink, listName))
			end
		end
	end,

	--
	add = function(param)
		local list, item, itemID = string.split(" ", param)
		if not (list and item) then
			BGC:Print(BGC.locale.invalidArgument)
			return
		end

		if type(item) == "string" then
			itemID = Broker_Garbage.GetItemID(item) or item
		elseif type(item) == "number" then
			itemID = item
		end

		if COMMAND_LISTADDACTION[list] then
			COMMAND_LISTADDACTION[list](itemID)
		elseif COMMAND_ALIAS[list] and COMMAND_LISTADDACTION[ COMMAND_ALIAS[list] ] then
			COMMAND_LISTADDACTION[ COMMAND_ALIAS[list] ](itemID)
		end
	end
}
local COMMAND_ALIAS = {
--	alias 		= 'original'
	options		= 'config',
	option		= 'config',
	menu		= 'config',
	qa 			= 'quickadd',
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

	treasure 	= 'keep',
	exclude 	= 'keep',
	garbage 	= 'junk',
	include 	= 'junk',
	autosell 	= 'sell',
	vendor 		= 'sell',
	vendorprice	= 'price',
	forceprice 	= 'price',
}

local function handler(msg)
	msg = msg:lower()
	local command, param = msg:match("^(%S*)%s*(.-)$")

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
