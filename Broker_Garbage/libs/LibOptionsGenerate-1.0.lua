local MAJOR, MINOR = 'LibOptionsGenerate-1.0', 23
local lib = LibStub:NewLibrary(MAJOR, MINOR)
if not lib then return end

-- GLOBALS: _G, type, pairs, ipairs, wipe, strsplit
local SharedMedia = LibStub('LibSharedMedia-3.0', true)

local AceDBScopes = {'global', 'profile', 'char', 'realm', 'factionrealm', 'faction', 'class', 'race'}
local AceDBExcludes = {'sv', 'callbacks', 'children', 'parent', 'keys', 'profiles', 'defaults'}
local emptyTable = {}

local itemQualities = {}
for quality, color in pairs(_G.ITEM_QUALITY_COLORS) do
	if quality >= 0 then
		itemQualities[quality] = color.hex .. _G['ITEM_QUALITY'..quality..'_DESC'] .. '|r'
	end
end

local function GetVariableFromPath(path)
	local variable
	local parts = { strsplit('.', path) }
	for index, part in ipairs(parts) do
		if index == 1 then variable = _G[part]
		else variable = variable[part] end
		if not variable then return end
	end
	return variable
end

local function GetSettingDefault(info, variable)
	local data = type(variable) == 'string' and GetVariableFromPath(variable) or variable
	for i = 1, #info.arg - 1 do
		data = data[ info.arg[i] ]
	end
	return data[ info.arg[#info.arg] ]
end
local function SetSettingDefault(info, value, variable)
	local data = type(variable) == 'string' and GetVariableFromPath(variable) or variable
	for i = 1, #info.arg - 1 do
		data = data[ info.arg[i] ]
	end
	data[ info.arg[#info.arg] ] = value
end
local function GetAncestorProperty(info, property)
	local data, propertyValue = info.options.args, info.options[property]
	for i = 1, #info - 1 do
		data = data[ info[i] ] or data.args[ info[i] ]
		propertyValue = data[property] or propertyValue
	end
	return propertyValue
end

-- LibSharedMedia Widgets
local function GetMediaKey(mediaType, value)
	local keyList = SharedMedia:List(mediaType)
	for _, key in pairs(keyList) do
		if SharedMedia:Fetch(mediaType, key) == value then
			return key
		end
	end
end
local function GetMediaSetting(info, mediaType)
	local get = GetAncestorProperty(info, 'get')
	return GetMediaKey(mediaType, get(info))
end
local function SetMediaSetting(info, value, mediaType)
	local set = GetAncestorProperty(info, 'set')
	set(info, SharedMedia:Fetch(mediaType, value))
end

local function GetFontSetting(info)              return GetMediaSetting(info, 'font') end
local function SetFontSetting(info, value)       SetMediaSetting(info, value, 'font') end
local function GetBarTexSetting(info)            return GetMediaSetting(info, 'statusbar') end
local function SetBarTexSetting(info, value)     SetMediaSetting(info, value, 'statusbar') end
local function GetBorderSetting(info)            return GetMediaSetting(info, 'border') end
local function SetBorderSetting(info, value)     SetMediaSetting(info, value, 'border') end
local function GetBackgroundSetting(info)        return GetMediaSetting(info, 'background') end
local function SetBackgroundSetting(info, value) SetMediaSetting(info, value, 'background') end
local function GetSoundSetting(info)             return GetMediaSetting(info, 'sound') end
local function SetSoundSetting(info, value)      SetMediaSetting(info, value, 'sound') end

-- other widget handlers
local function GetColorSetting(info)
	local get = GetAncestorProperty(info, 'get')
	return unpack(get(info))
end
local function SetColorSetting(info, r, g, b, a)
	local get = GetAncestorProperty(info, 'get')
	local set = GetAncestorProperty(info, 'set')
	local color = get(info)
	color[1], color[2], color[3], color[4] = r, g, b, a
	set(info, color)
end
local function GetPercentSetting(info)        local get = GetAncestorProperty(info, 'get'); return get(info) * 100 end
local function SetPercentSetting(info, value) local set = GetAncestorProperty(info, 'set'); set(info, value/100) end
local function GetNumberSetting(info)         local get = GetAncestorProperty(info, 'get'); return tostring(get(info)) end
local function SetNumberSetting(info, value)  local set = GetAncestorProperty(info, 'set'); set(info, tonumber(value)) end
local function GetMultiSelectSetting(info, key) local get = GetAncestorProperty(info, 'get'); return get(info)[key] end
local function SetMultiSelectSetting(info, key, value)
	-- we get the container table and then set the specific value
	local get = GetAncestorProperty(info, 'get')
	get(info)[key] = value
end

local function GetTableFromList(dataString, seperator) return { strsplit(seperator, dataString) } end
local function GetListFromTable(dataTable, seperator)
	local output = ''
	for _, value in pairs(dataTable) do
		output = (output ~= '' and output..seperator or '') .. value
	end
	return output
end
local function GetListSetting(info)
	local get = GetAncestorProperty(info, 'get'); return GetListFromTable(get(info), '\n')
end
local function SetListSetting(info, value) local set = GetAncestorProperty(info, 'set'); set(info, GetTableFromList(value, '\n')) end

local function Widget(key, option, widgetInfo)
	-- trigger callback
	if type(widgetInfo) == 'function' then
		widgetInfo = widgetInfo(key, option)
		if type(widgetInfo) == 'table' and widgetInfo.type then
			return widgetInfo
		end
	end

	local widget
	key = tostring(key):lower()
	local widgetType = key
	if type(widgetInfo) == 'string' then
		widgetType = widgetInfo:lower()
	end

	-- detect multiselect table structures
	if type(option) == 'table' and next(option) then
		local isMultiSelect = true
		for k, v in pairs(option) do
			if type(k) ~= 'number' or type(v) ~= 'boolean' then
				isMultiSelect = false
				break
			end
		end
		if isMultiSelect then
			widgetType = 'multiselect'
		end
	end

	if type(widgetInfo) == 'table' then
		-- preset select options
		widget = {
			type = 'select',
			values = widgetInfo,
		}
	elseif widgetType == '*none*' then
		-- hidden from display
		return true
	elseif widgetType == 'multiselect' then
		local labels = {}
		for k, v in pairs(option) do
			labels[k] = k
		end
		widget = {
			type = 'multiselect',
			values = labels,
			get = GetMultiSelectSetting,
			set = SetMultiSelectSetting,
		}
	elseif (widgetType == 'justifyh' or key:find('justifyh')) then
		widget = {
			type = 'select',
			name = 'Horiz. Justification',
			values = {['LEFT'] = 'LEFT', ['CENTER'] = 'CENTER', ['RIGHT'] = 'RIGHT'},
		}
	elseif (widgetType == 'justifyv' or key:find('justifyv')) then
		widget = {
			type = 'select',
			name = 'Vert. Justification',
			values = {['TOP'] = 'TOP', ['MIDDLE'] = 'MIDDLE', ['BOTTOM'] = 'BOTTOM'},
		}
	elseif (widgetType == 'fontstyle' or key:find('fontstyle') or key:find('outline')) then
		widget = {
			type = 'select',
			name = 'Font Style',
			values = {['NONE'] = 'NONE', ['OUTLINE'] = 'OUTLINE', ['THICKOUTLINE'] = 'THICKOUTLINE', ['MONOCHROME'] = 'MONOCHROME'},
		}
	elseif (widgetType == 'fontsize' or key:find('fontsize')) and type(option) == 'number' then
		widget = {
			type = 'range',
			name = 'Font Size',
			step = 1,
			min = 5,
			max = 32, -- Blizz won't go any larger
		}
	elseif (widgetType == 'font' or key:find('font')) and type(option) == 'string' and SharedMedia then
		widget = {
			type = 'select',
			dialogControl = 'LSM30_Font',
			name = 'Font Family',
			values = SharedMedia:HashTable('font'),
			get = GetFontSetting,
			set = SetFontSetting,
		}
	elseif (widgetType == 'border' or key:find('border')) and type(option) == 'string' and SharedMedia then
		widget = {
			type = 'select',
			dialogControl = 'LSM30_Border',
			name = 'Border Texture',
			values = SharedMedia:HashTable('border'),
			get = GetBorderSetting,
			set = SetBorderSetting,
		}
	elseif (widgetType == 'background' or key:find('background')) and type(option) == 'string' and SharedMedia then
		widget = {
			type = 'select',
			dialogControl = 'LSM30_Background',
			name = 'Background Texture',
			values = SharedMedia:HashTable('background'),
			get = GetBackgroundSetting,
			set = SetBackgroundSetting,
		}
	elseif (widgetType == 'statusbar' or key:find('statusbar')) and type(option) == 'string' and SharedMedia then
		widget = {
			type = 'select',
			dialogControl = 'LSM30_Statusbar',
			name = 'Statusbar Texture',
			values = SharedMedia:HashTable('statusbar'),
			get = GetBarTexSetting,
			set = SetBarTexSetting,
		}
	elseif (widgetType == 'sound' or key:find('sound')) and type(option) == 'string' and SharedMedia then
		widget = {
			type = 'select',
			dialogControl = 'LSM30_Sound',
			name = 'Sound',
			values = SharedMedia:HashTable('sound'),
			get = GetSoundSetting,
			set = SetSoundSetting,
		}
	elseif (widgetType == 'color' or key:find('color')) and type(option) == 'table' then
		widget = {
			type = 'color',
			hasAlpha = true,
			get = GetColorSetting,
			set = SetColorSetting,
		}
	elseif (widgetType == 'percent' or key:find('percent')) and type(option) == 'number' and option >= 0 and option <= 1 then
		widget = {
			type = 'range',
			name = 'Percent',
			step = 1,
			min = 0,
			max = 100,
			get = GetPercentSetting,
			set = SetPercentSetting,
		}
	elseif (widgetType == 'unsigned' or key:find('size')) and type(option) == 'number' and option >= 0 then
		widget = {
			type = 'range',
			name = key,
			min = 0,
			softMax = 200,
			bigStep = 10,
		}
	elseif (widgetType == 'itemquality' or key:find('quality')) and type(option) == 'number' then
		widget = {
			type = 'select',
			values = itemQualities,
		}
	elseif widgetType == 'money' then
		-- TODO: this needs some more intuition. Use GetCoinTextureString(amount)?
		widget = {
			type = 'input',
			multiline = false,
			usage = 'Insert value in coppers, e.g. 10000 for 1|TInterface\\MoneyFrame\\UI-GoldIcon:0|t.',
			pattern = '%d',
			get = GetNumberSetting,
			set = SetNumberSetting,
		}
	elseif widgetType == 'values' or key:find('list$') then
		widget = {
			type = 'input',
			multiline = true,
			usage = 'Insert one entry per line',
			get = GetListSetting,
			set = SetListSetting,
			order = 70,
		}
	elseif widgetType == 'text' then
		widget = {
			type = 'input',
			name = key,
		}
	end

	return widget
end

local function ParseOption(key, option, L, typeMappings, path)
	if type(key) ~= 'string' or (key == '*' or key == '**') then return end

	local widget = Widget(key, option, typeMappings and typeMappings[key])
	if widget == true then return nil end

	-- create our own path table, we need table ownership
	local arg = {}
	for index, component in ipairs(path or emptyTable) do
		table.insert(arg, component)
	end
	table.insert(arg, key)

	if widget then
		widget.name = widget.name or key
	elseif type(option) == 'string' then
		widget = {
			type = 'input',
			name = key,
		}
	elseif type(option) == 'boolean' then
		widget = {
			type = 'toggle',
			name = key,
		}
	elseif type(option) == 'number' then
		widget = {
			type = 'range',
			name = key,
			softMin = -200,
			softMax = 200,
			bigStep = 10,
		}
	elseif type(option) == 'table' then
		widget = {
			type 	= 'group',
			inline 	= true,
			name 	= key,
			args 	= {},
			order 	= 80,
		}
		for subkey, subOption in pairs(option) do
			widget.args[subkey] = ParseOption(subkey, subOption, L, typeMappings, arg)
		end
	end

	if not widget then return nil end
	widget.arg   = widget.arg or arg
	widget.order = widget.order or 1

	if L and type(L) == 'table' and not tContains(AceDBScopes, key) then
		-- apply localization
		widget.name = L[key..'Name'] or widget.name
		widget.desc = L[key..'Desc'] or widget.desc
		if widget.type == 'group' and widget.desc then
			widget.args.groupDescription = {
				type = 'description',
				name = widget.desc,
				order = 0,
			}
		end
		local valuesHandler = widget.values and rawget(L, key..'Values') or nil
		if type(valuesHandler) == 'function' then
			for k, v in pairs(widget.values) do
				local key, value = valuesHandler(k, v)
				widget.values[k] = nil
				widget.values[key] = value
			end
		end
	end

	return widget
end

local function GetScopeLabel(scope)
	local character, realm = UnitFullName('player')
	local className, class = UnitClass('player')
	local classColor = (_G.CUSTOM_CLASS_COLORS or _G.RAID_CLASS_COLORS)[class].colorStr
	local faction = UnitFactionGroup('player')

	local label = ('%s Settings'):format(scope:gsub('^.', string.upper))
	if scope == 'char' then
		label = ('Settings for |c%s%s-%s|r'):format(classColor, character, realm)
	elseif scope == 'class' then
		label = ('Settings for |c%s%s|r'):format(classColor, className)
	elseif scope == 'faction' then
		local factionColor = faction == 'Alliance' and BATTLENET_FONT_COLOR_CODE or RED_FONT_COLOR_CODE
		label = ('Settings for %s%s|r'):format(factionColor, faction)
	elseif scope == 'realm' then
		label = ('Settings for %s'):format(realm)
	elseif scope == 'factionrealm' then
		label = ('Settings for %s (%s)'):format(realm, faction)
	elseif scope == 'race' then
		local race = UnitRace('player')
		label = ('Settings for %s'):format(race)
	end
	return label
end

local function AddNamespaces(optionsTable, variable, L, typeMappings, callback)
	for namespace, options in pairs(variable.children or emptyTable) do
		-- we need to access different data
		local get = function(info) return GetSettingDefault(info, options) end
		local set = function(info, value)
			SetSettingDefault(info, value, options)
			if callback then callback(info, value, options) end
		end
		for scope in pairs(options.defaults or emptyTable) do
			-- note: this will create empty groups when empty defaults are defined
			local key = scope .. '_' .. namespace
			-- allow to separate settings with equal names in different namespaces
			local namespaceMappings = typeMappings and (typeMappings[key] or typeMappings[namespace] or typeMappings)
			local namespaceLocale = L and (L[key] or L[namespace] or L)
			local option = ParseOption(scope, options[scope], namespaceLocale, namespaceMappings)
			if option and next(option.args) then
				optionsTable.args[scope] = optionsTable.args[scope] or {
					type 	= 'group',
					inline 	= true,
					name 	= scope,
					args 	= {},
					order 	= -1,
				}

				option.name = namespace
				option.order = 90
				option.get = get
				option.set = set
				optionsTable.args[scope].args[namespace] = option
			end
		end
	end
end

function lib:GetOptionsTable(variable, typeMappings, L, includeNamespaces, callback)
	if type(variable) == 'string' then
		variable = GetVariableFromPath(variable)
	end
	if type(callback) ~= 'function' then
		callback = nil
	end

	local optionsTable = {
		name = 'Settings',
		type = 'group',
		args = {},
		get = function(info) return GetSettingDefault(info, variable or info[1]) end,
		set = function(info, value)
			SetSettingDefault(info, value, variable or info[1])
			if callback then callback(info, value, variable or info[1]) end
		end,
	}

	local isAceDB = variable.sv and variable.defaults
	if isAceDB then
		-- trigger initialization: tables might not exist when we iterate
		for scope in pairs(variable.defaults) do
			if variable[scope] then --[[ do nothing --]] end
		end
	end

	for key, value in pairs(variable) do
		if not isAceDB or not tContains(AceDBExcludes, key) then
			optionsTable.args[key] = ParseOption(key, value, L, typeMappings)
		end
	end

	if isAceDB then
		if includeNamespaces then
			-- Add namespace settings to core addon's scopes.
			AddNamespaces(optionsTable, variable, L, typeMappings, callback)
		end

		local lastScope, numScopes = nil, 0
		for weight, scope in ipairs(AceDBScopes) do
			if optionsTable.args[scope] then
				if not next(optionsTable.args[scope].args) then
					-- Remove empty scopes.
					optionsTable.args[scope] = nil
				else
					-- Add scope header.
					optionsTable.args[scope..'Header'] = {
						type = 'header',
						name = GetScopeLabel(scope),
						order = weight*10 - 1,
					}
					optionsTable.args[scope].order = weight*10
					optionsTable.args[scope].name = ''

					numScopes = numScopes + 1
					lastScope = scope
				end
			end
		end
		if numScopes < 2 and lastScope then
			-- Don't show header for single scope.
			optionsTable.args[lastScope..'Header'] = nil
		end
	end
	return optionsTable
end
