local _, BG = ...

-- register as a plugin to gain acced to BG's options panel
function BG:RegisterPlugin(name, init)
	if not name or not init then
		BG:Print("Error! Cannot register a plugin without a name and initialize function.")
		return
	end
	
	table.insert(BG.modules, {
		name = name,
		init = init
	})
	return #BG.modules
end

function BG:GetVariable(name)
	return BG[name]
end

-- returns the requested option
function BG:GetOption(optionName, global)
	if global == nil then
		return BG_LocalDB[optionName], BG_GlobalDB[optionName]
	elseif global == false then
		return BG_LocalDB[optionName]
	else
		return BG_GlobalDB[optionName]
	end
end

-- writes back an option
function BG:SetOption(optionName, global, value)
	if not global then
		BG_LocalDB[optionName] = value
	else
		BG_GlobalDB[optionName] = value
	end
end

-- toggles an option true/false
function BG:ToggleOption(optionName, global)
	if not global then
		BG_LocalDB[optionName] = not BG_LocalDB[optionName]
	else
		BG_GlobalDB[optionName] = not BG_GlobalDB[optionName]
	end
end

-- resets an option entry to its default value
function BG:ResetOption(name, isGlobal)
	local optionsTable = isGlobal and BG_GlobalDB or BG_LocalDB
	local defaultOptions = isGlobal and BG.defaultGlobalSettings or BG.defaultLocalSettings

	if optionsTable[name] then
		optionsTable[name] = defaultOptions[name]
	end
end

-- resets statistics. global = true -> global, otherwise local
function BG:ResetStatistics(isGlobal)
	BG:ResetOption("moneyEarned", isGlobal)
	BG:ResetOption("moneyLostByDeleting", isGlobal)
	BG:ResetOption("itemsDropped", isGlobal)
	BG:ResetOption("itemsSold", isGlobal)
end

-- gets an item's classification and saves it to the item cache
-- function BG:UpdateCache(itemID)

-- fetch an item from the item cache, or insert if it doesn't exist yet
-- function BG:GetCached(itemID)

-- returns total bag slots and free bag slots of your whole inventory
-- function BG:GetBagSlots()

Broker_Garbage = {
	RegisterPlugin = BG.RegisterPlugin,
	
	GetVariable = BG.GetVariable,
	GetOption = BG.GetOption,
	SetOption = BG.SetOption,
	ToggleOption = BG.ToggleOption,
	ResetOption = BG.ResetOption,
	ResetStatustics = BG.ResetStatistics,
	
	GetCached = BG.GetCached,
	UpdateCache = BG.UpdateCache,
	GetBagSlots = BG.GetBagSlots,
	ScanInventory = BG.ScanInventory,
	GetItemValue = BG.GetItemValue,
	Delete = BG.Delete,
	FindSlotsToDelete = BG.FindSlotToDelete,
	
	UpdateRepairButton = BG.UpdateRepairButton,
	CreateDefaultLists = BG.CreateDefaultLists,
	GetProfessionSkill = BG.GetProfessionSkill,
	FormatMoney = BG.FormatMoney,
	Colorize = BG.Colorize,
}