local MAJOR, MINOR = 'LibOptionsGenerate-1.0', 14
local lib = LibStub:NewLibrary(MAJOR, MINOR)
if not lib then return end

-- GLOBALS: _G, type, pairs, ipairs, wipe, strsplit
local SharedMedia = LibStub('LibSharedMedia-3.0', true)

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
	for i = 1, #info - 1 do
		if data[ info[i] ] then -- might have a container group
			data = data[ info[i] ]
		end
	end
	return data[ info[#info] ]
end
local function SetSettingDefault(info, value, variable)
	local data = type(variable) == 'string' and GetVariableFromPath(variable) or variable
	for i = 1, #info - 1 do
		if data[ info[i] ] then -- might not have a container group
			data = data[ info[i] ]
		end
	end
	data[ info[#info] ] = value
end
local function GetAncestorProperty(info, property)
	local data, propertyValue = info.options.args, info.options[property]
	for i = 1, #info - 1 do
		data = data[ info[i] ]
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

local function GetTableFromList(dataString, seperator) return { strsplit(seperator, dataString) } end
local function GetListFromTable(dataTable, seperator)
	local output = ''
	for _, value in pairs(dataTable) do
		output = (output ~= '' and output..seperator or '') .. value
	end
	return output
end
local function GetListSetting(info) return GetListFromTable(info.options.args[ info[1] ].get(info), '\n') end
local function SetListSetting(info, value) info.options.args[ info[1] ].set(info, GetTableFromList(value, '\n')) end

local function Widget(key, option, typeMappings)
	local key, widget = typeMappings and typeMappings[key] or key:lower(), nil

	if type(key) == 'table' then
		widget = {
			type = 'select',
			values = key,
		}
	elseif key == '*none*' then
		-- hidden from display
		return true
	elseif key == 'justifyh' then
		widget = {
			type = 'select',
			name = 'Horiz. Justification',
			values = {['LEFT'] = 'LEFT', ['CENTER'] = 'CENTER', ['RIGHT'] = 'RIGHT'},
		}
	elseif key == 'justifyv' then
		widget = {
			type = 'select',
			name = 'Vert. Justification',
			values = {['TOP'] = 'TOP', ['MIDDLE'] = 'MIDDLE', ['BOTTOM'] = 'BOTTOM'},
		}
	elseif key == 'fontsize' or (key:find('font') and type(option) == 'number') then
		widget = {
			type = 'range',
			name = 'Font Size',
			step = 1,
			min = 5,
			max = 24, -- Blizz won't go any larger
		}
	elseif key == 'fontstyle' then
		widget = {
			type = 'select',
			name = 'Font Style',
			values = {['NONE'] = 'NONE', ['OUTLINE'] = 'OUTLINE', ['THICKOUTLINE'] = 'THICKOUTLINE', ['MONOCHROME'] = 'MONOCHROME'},
		}
	elseif key == 'font'          and type(option) == 'string' and SharedMedia then
		widget = {
			type = 'select',
			dialogControl = 'LSM30_Font',
			name = 'Font Family',
			values = SharedMedia:HashTable('font'),
			get = GetFontSetting,
			set = SetFontSetting,
		}
	elseif key:find('border')     and type(option) == 'string' and SharedMedia then
		widget = {
			type = 'select',
			dialogControl = 'LSM30_Border',
			name = 'Border Texture',
			values = SharedMedia:HashTable('border'),
			get = GetBorderSetting,
			set = SetBorderSetting,
		}
	elseif key:find('background') and type(option) == 'string' and SharedMedia then
		widget = {
			type = 'select',
			dialogControl = 'LSM30_Background',
			name = 'Background Texture',
			values = SharedMedia:HashTable('background'),
			get = GetBackgroundSetting,
			set = SetBackgroundSetting,
		}
	elseif key:find('statusbar')  and type(option) == 'string' and SharedMedia then
		widget = {
			type = 'select',
			dialogControl = 'LSM30_Statusbar',
			name = 'Statusbar Texture',
			values = SharedMedia:HashTable('statusbar'),
			get = GetBarTexSetting,
			set = SetBarTexSetting,
		}
	elseif key:find('sound')      and type(option) == 'string' and SharedMedia then
		widget = {
			type = 'select',
			dialogControl = 'LSM30_Sound',
			name = 'Sound',
			values = SharedMedia:HashTable('sound'),
			get = GetSoundSetting,
			set = SetSoundSetting,
		}
	elseif key:find('color')      and type(option) == 'table' then
		widget = {
			type = 'color',
			hasAlpha = true,
			get = GetColorSetting,
			set = SetColorSetting,
		}
	elseif key:find('percent')    and type(option) == 'number' and option >= 0 and option <= 1 then
		widget = {
			type = 'range',
			name = 'Percent',
			step = 1,
			min = 0,
			max = 100,
			get = GetPercentSetting,
			set = SetPercentSetting,
		}
	elseif key == 'money' then
		-- TODO: this needs some more intuition. Use GetCoinTextureString(amount)?
		widget = {
			type = 'input',
			multiline = false,
			usage = 'Insert value in coppers, e.g. 10000 for 1|TInterface\\MoneyFrame\\UI-GoldIcon:0|t.',
			pattern = '%d',
			get = GetNumberSetting,
			set = SetNumberSetting,
		}
	elseif key == 'itemquality' or (key:find('quality') and type(option) == 'number') then
		widget = {
			type = 'select',
			values = itemQualities,
		}
	elseif key == 'values' or key:find('list$') then
		widget = {
			type = 'input',
			multiline = true,
			usage = 'Insert one entry per line',
			get = GetListSetting,
			set = SetListSetting,
		}
	end

	return widget
end

local AceDBScopes = { 'global', 'profile', 'char', 'class', a = 'race', b = 'realm', c = 'faction', d = 'factionrealm' }
local function ParseOption(key, option, L, typeMappings)
	if type(key) ~= 'string' or key == '*' or key == '**' then return end

	local widget = Widget(key, option, typeMappings)
	if widget == true then
		return nil
	elseif widget then
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
		local hasContents = false
		for subkey, value in pairs(option) do
			widget.args[subkey] = ParseOption(subkey, value, L, typeMappings)
			if widget.args[subkey] then
				hasContents = true
			end
		end
		if not hasContents then widget = nil end
	end

	if widget then
		widget.order = widget.order or 1
	end
	if widget and L and type(L) == 'table' and not tContains(AceDBScopes, key) then
		widget.name = L[key..'Name'] or widget.name
		widget.desc = L[key..'Desc'] or widget.desc
		if widget.type == 'group' and widget.desc then
			widget.args.groupDescription = {
				type = 'description',
				name = widget.desc,
				order = 0,
			}
		end
	end

	return widget
end

local function AddScopeHeaders(optionsTable)
	-- TODO: also available: race, realm, faction, factionrealm (remove keys in AceDBScopes table)
	local playerName, playerRealm = UnitFullName('player')
	local className, class = UnitClass('player')

	local lastScope, hasMultipleScopes = nil, false
	for weight, scope in ipairs(AceDBScopes) do
		if optionsTable.args[scope] then
			if lastScope then hasMultipleScopes = true end
			lastScope = scope

			optionsTable.args[scope..'Header'] = {
				type = 'header',
				name = scope:gsub('^.', string.upper)..' Settings',
				order = weight*10 - 1,
			}
			optionsTable.args[scope].order = weight*10
			optionsTable.args[scope].name = ''

			if scope == 'char' then
				optionsTable.args[scope..'Header'].name = ('Settings for |c%s%s-%s|r'):format((CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[class].colorStr, playerName, playerRealm)
			elseif scope == 'class' then
				optionsTable.args[scope..'Header'].name = ('Settings for |c%s%s|r'):format((CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[class].colorStr, className)
			end
		end
	end

	if not hasMultipleScopes and lastScope then
		-- don't show header for single scope
		optionsTable.args[lastScope..'Header'] = nil
	end
end

local emptyTable = {}
local function AddNamespaces(optionsTable, variable, typeMappings, L)
	for namespace, options in pairs(variable.children or emptyTable) do
		-- we need to access different data
		local get = function(info) return GetSettingDefault(info, options) end
		local set = function(info, value) return SetSettingDefault(info, value, options) end
		for weight, scope in pairs(AceDBScopes) do
			if options[scope] then
				local key = scope .. '_' .. namespace
				local option = ParseOption(key, options[scope], L, typeMappings)
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
end

local AceDBExcludes = {'sv', 'callbacks', 'children', 'parent', 'keys', 'profiles', 'defaults'}
function lib:GetOptionsTable(variable, typeMappings, L, includeNamespaces)
	if type(variable) == 'string' then
		variable = GetVariableFromPath(variable)
	end

	local optionsTable = {
		name = 'Settings',
		type = 'group',
		args = {},
		get = function(info) return GetSettingDefault(info, variable or info[1]) end,
		set = function(info, value) return SetSettingDefault(info, value, variable or info[1]) end,
	}

	local isAceDB = variable.sv and variable.defaults
	if isAceDB then
		-- trigger initialization: tables might not exist when we iterate
		for _, scope in pairs(AceDBScopes) do if not next(variable[scope]) then variable[scope] = nil end end
	end

	for key, value in pairs(variable) do
		if not isAceDB or not tContains(AceDBExcludes, key) then
			optionsTable.args[key] = ParseOption(key, value, L, typeMappings)
		end
	end

	if isAceDB then
		if includeNamespaces then
			-- add namespace settings to core addon's scopes
			AddNamespaces(optionsTable, variable, typeMappings, L)
		end
		AddScopeHeaders(optionsTable)
	end
	return optionsTable
end
