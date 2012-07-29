local _, BGC = ...


SLASH_Broker_Garbage1 = "/garbage"
SLASH_Broker_Garbage2 = "/garb"
SLASH_Broker_Garbage3 = "/junk"
-- * = TODO; + = documented, implemented; - = not documented, implemented
local COMMAND_PARAMS = {
	-- + open config UI
	config = function(param)
		InterfaceOptionsFrame_OpenToCategory(BGC.options)
	end,

	-- * [TODO] open item quick add UI
	quickadd = function(param)
		-- Broker_Garbage:ShowQuickAddUI()
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
}

local function handler(msg)
	msg = msg:lower()
	local command, param = msg:match("^(%S*)%s*(.-)$")

	if COMMAND_PARAMS[command] then
		COMMAND_PARAMS[command](param)
		return
	end
	if COMMAND_ALIAS[command] then
		COMMAND_PARAMS[ COMMAND_ALIAS[command] ](param)
		return
	end

	-- commands don't match
	BGC:Print(BGC.locale.slashCommandHelp)
end
SlashCmdList["Broker_Garbage"] = handler
