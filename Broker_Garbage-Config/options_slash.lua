local _, BGC = ...

-- register slash commands
SLASH_Broker_Garbage1 = "/garbage"
SLASH_Broker_Garbage2 = "/garb"
function SlashCmdList.Broker_Garbage(msg, editbox)
	local command, rest = msg:match("^(%S*)%s*(.-)$")
	local command = strlower(command)
	local LootManager = IsAddOnLoaded("Broker_Garbage-LootManager")
	
	if command == "options" or command == "config" or command == "option" or command == "menu" then
		InterfaceOptionsFrame_OpenToCategory(BGC.options)
		
	elseif command == "format" then
		if strlower(rest) ~= "reset" then
			Broker_Garbage:SetOption("LDBformat", true, rest)
		else
			Broker_Garbage:SetOption("LDBformat", true, Broker_Garbage.defaultGlobalSettings.LDBformat)
		end
		Broker_Garbage:ScanInventory()

	elseif command == "limit" or command == "glimit" or command == "globallimit" then
		local itemID, count = rest:match("^[^0-9]-([0-9]+).-([0-9]+)$")
		itemID = tonumber(itemID) or -1
		count = tonumber(count) or -1
		
		if itemID < 1 or count < 0 then
			BGC.Print(BGC.locale.invalidArgument)
		end
		Broker_Garbage.itemsCache[itemID] = nil
		
		if string.find(command, "g") then
			local table = Broker_Garbage:GetOption("include", true)
			table[itemID] = count
		else
			local table = Broker_Garbage:SetOption("include", false)
			table[itemID] = count
		end
		local itemLink = select(2, GetItemInfo(itemID)) or BGC.locale.unknown
		Broker_Garbage.Print(format(BGC.locale.limitSet, itemLink, count))
		BGC:ListOptionsUpdate("include")
	
	elseif command == "tooltiplines" or command == "numlines" then
		rest = tonumber(rest)
		if not rest then 
			Broker_Garbage.Print(BGC.locale.invalidArgument)
			return
		end
		Broker_Garbage:SetOption("tooltipNumItems", true, rest)
		Broker_Garbage:ScanInventory()
		if BGC.options.currentTab and BGC.modules[BGC.options.currentTab].panel.Update then
			BGC.modules[BGC.options.currentTab].panel:Update()
		end
		
	elseif command == "tooltipheight" or command == "height" then
		rest = tonumber(rest)
		if not rest then 
			Broker_Garbage.Print(BGC.locale.invalidArgument)
			return
		end
		Broker_Garbage:SetOption("tooltipMaxHeight", true, rest)
		if BGC.options.currentTab and BGC.modules[BGC.options.currentTab].panel.Update then
			BGC.modules[BGC.options.currentTab].panel:Update()
		end
		
	elseif LootManager and (command == "value" or command == "minvalue") then
		rest = tonumber(rest) or -1
		if rest < 0 then
			Broker_Garbage.Print(BGC.locale.invalidArgument)
			return
		end
		
		Broker_Garbage_LootManager:SetMinValue(rest)
		Broker_Garbage.Print(format(BGC.locale.minValueSet, Broker_Garbage.FormatMoney(Broker_Garbage:GetOption("itemMinValue", false))))
		
	elseif LootManager and (command == "freeslots" or command == "slots" or command == "free" or command == "minfree") then
		rest = tonumber(rest)
		if not rest then 
			Broker_Garbage.Print(BGC.locale.invalidArgument)
			return
		end
		
		Broker_Garbage_LootManager:SetMinSlots(rest)
		BGC.Print(format(BGC.locale.minSlotsSet, Broker_Garbage:GetOption("tooFewSlots", false)))
		
	elseif command == "list" or command == "lists" then -- [TODO] add GUI options for this
		rest = Broker_Garbage.GetItemID(rest) or rest
		local itemLink = select(2, GetItemInfo(rest))
		local result = Broker_Garbage.GetItemListCategories(Broker_Garbage.GetCached(rest))
		for _, listName in ipairs(result) do
			Broker_Garbage.Print(string.format("%s is in category %s.", itemLink, listName))
		end

	else
		BGC.Print(BGC.locale.slashCommandHelp)
	end
end