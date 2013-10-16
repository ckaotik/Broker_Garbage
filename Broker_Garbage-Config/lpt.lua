local _, ns = ...

-- GLOBALS: UIDROPDOWNMENU_MENU_VALUE, UIDropDownMenu_CreateInfo, UIDropDownMenu_AddButton
-- GLOBALS: type, pairs, strsplit

ns.PT = LibStub("LibPeriodicTable-3.1", true)	-- don't scream if LPT isn't present
-- constructs a DropDown ready table
local function CreateLPTTable()
	ns.PTSets = {}
	for set, _ in pairs( ns.PT and ns.PT.sets or {} ) do
		local partials = { strsplit(".", set) }
		local maxParts = #partials
		local pre = ns.PTSets

		for i = 1, maxParts do
			if i == maxParts then
				-- actual clickable entries
				pre[ partials[i] ] = set
			else
				-- all parts before that
				if not pre[ partials[i] ] or type(pre[ partials[i] ]) == "string" then
					pre[ partials[i] ] = {}
				end
				pre = pre[ partials[i] ]
			end
		end
	end
end

function ns:LPTDropDown(self, level, functionHandler, notChecked)
	if not ns.PTSets then
		CreateLPTTable()
	end
	local dataTable = ns.PTSets or {}
	if UIDROPDOWNMENU_MENU_VALUE and UIDROPDOWNMENU_MENU_VALUE:find(".") then
		local parts = { strsplit(".", UIDROPDOWNMENU_MENU_VALUE) } or {}
		for k = 1, #parts do
			dataTable = dataTable[ parts[k] ] or {}
		end
	elseif UIDROPDOWNMENU_MENU_VALUE then
		dataTable = dataTable[ UIDROPDOWNMENU_MENU_VALUE ] or {}
	end

	-- display a heading
	if (level == 1) then
		local info = UIDropDownMenu_CreateInfo()
		info.isTitle = true
		info.notCheckable = true
		info.text = ns.locale.categoriesHeading
		UIDropDownMenu_AddButton(info, level)

		-- and some warning text, in case LPT is not available
		if not ns.PT then
			local info = UIDropDownMenu_CreateInfo()
			info.isTitle = true
			info.notCheckable = true
			info.text = ns.locale.LPTNotLoaded
			UIDropDownMenu_AddButton(info, level)
		end
	end

	for key, value in pairs(dataTable or {}) do
		local info = UIDropDownMenu_CreateInfo()
		local prefix = ""
		if UIDROPDOWNMENU_MENU_VALUE then
			prefix = UIDROPDOWNMENU_MENU_VALUE .. "."
		end

		info.text = key
		info.value = prefix .. key
		info.notCheckable = true -- notChecked
		info.hasArrow = type(value) == "table" and true or false
		info.func = functionHandler

		UIDropDownMenu_AddButton(info, level);
	end
end

-- Broker_Garbage:GetItemListCategories(itemTable)
-- returns list of an item's LPT/other categories from user's lists
