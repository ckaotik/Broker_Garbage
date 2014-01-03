local _, ns = ...
local LibPeriodicTable = LibStub("LibPeriodicTable-3.1", true)	-- don't scream if LPT isn't present

-- GLOBALS: UIDropDownMenu_CreateInfo, UIDropDownMenu_AddButton
-- GLOBALS: type, pairs, ipairs, strsplit, wipe
local tinsert, tsort, gsub, match, find = table.insert, table.sort, string.gsub, string.match, string.find

local function IsMultiSet(setPath)
	local category = LibPeriodicTable:GetSetString(setPath)
	local isMulti, hasMultiple = match(category, "^m,([^,]+)(,?.*)")
	return isMulti and true or false, hasMultiple ~= ''
end

local sortTable = {}
function ns.InitializeLPTDropdown(self, menuLevel, menuList, clickFunc)
	local level = menuLevel or 1
	local selectedValue = UIDropDownMenu_GetSelectedValue(self)
	local info = UIDropDownMenu_CreateInfo()
	      info.func = clickFunc

	local prefix = menuList or ''
	wipe(sortTable)

	if level == 1 then
		-- add some header texts
		info.isTitle = true
		info.notCheckable = true
		info.text = ns.locale.categoriesHeading
		UIDropDownMenu_AddButton(info, level)

		if not LibPeriodicTable then
			info.text = ns.locale.LPTNotLoaded
			UIDropDownMenu_AddButton(info, level)
		end

		info.isTitle = nil
		info.disabled = nil

		-- generate top level
		for category, version in pairs(LibPeriodicTable.embedversions) do
			tinsert(sortTable, category)
		end
	else
		-- generate sublevel
		gsub(LibPeriodicTable:GetSetString(prefix) or '', '[^,]+', function(category)
			if category ~= 'm' then
				local _, _, subSet = find(category, "^"..prefix.."%.([^.]+)")
				if subSet and not ns.Find(sortTable, subSet) then
					tinsert(sortTable, subSet)
				end
			end
		end)
	end

	tsort(sortTable)
	local isMultiSet, hasMultipleEntries, setPath
	for i, category in ipairs(sortTable) do
		setPath = (prefix == '' and '' or prefix..'.') .. category
		isMultiSet, hasMultipleEntries = IsMultiSet(setPath)
		if not isMultiSet or hasMultipleEntries then
			-- not just a symlink
			info.text     = category
			info.hasArrow = isMultiSet
			info.value    = setPath
			info.menuList = setPath
			info.checked  = setPath == selectedValue

			UIDropDownMenu_AddButton(info, level)
		end
	end
end
