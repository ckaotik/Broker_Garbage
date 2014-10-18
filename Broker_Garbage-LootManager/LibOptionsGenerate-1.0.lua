local MAJOR, MINOR = 'LibOptionsGenerate-1.0', 6
local lib = LibStub:NewLibrary(MAJOR, MINOR)
if not lib then return end

-- GLOBALS: _G, type, pairs, ipairs, wipe, strsplit

local SharedMedia     = LibStub('LibSharedMedia-3.0', true)
local AceConfig       = LibStub('AceConfig-3.0')
local AceConfigDialog = LibStub('AceConfigDialog-3.0')
if not AceConfig or not AceConfigDialog then return end

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

local function GetSettingDefault(info, dataPath)
	local db = GetVariableFromPath(dataPath)
	local data = db
	for i = 2, #info do
		data = data[ info[i] ]
	end
	return data
end
local function SetSettingDefault(info, value, dataPath)
	local db = GetVariableFromPath(dataPath)
	local data = db
	for i = 2, #info - 1 do
		data = data[ info[i] ]
	end
	data[ info[#info] ] = value
end

local function GetMediaKey(mediaType, value)
	local keyList = SharedMedia:List(mediaType)
	for _, key in pairs(keyList) do
		if SharedMedia:Fetch(mediaType, key) == value then
			return key
		end
	end
end
local function GetFontSetting(info)
	local getter = info.options.args[ info[1] ].get
	return GetMediaKey('font', getter(info))
end
local function SetFontSetting(info, value)
	local setter = info.options.args[ info[1] ].set
	setter(info, SharedMedia:Fetch('font', value))
end

local function GetTableFromList(dataString, seperator)
	return { strsplit(seperator, dataString) }
end
local function GetListFromTable(dataTable, seperator)
	local output = ''
	for _, value in pairs(dataTable) do
		output = (output ~= '' and output..seperator or '') .. value
	end
	return output
end
local function GetListSetting(info)
	local getter = info.options.args[ info[1] ].get
	return GetListFromTable(getter(info), '\n')
end
local function SetListSetting(info, value)
	local setter = info.options.args[ info[1] ].set
	setter(info, GetTableFromList(value, '\n'))
end

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
	elseif key == 'font' and SharedMedia then
		widget = {
			type = 'select',
			dialogControl = 'LSM30_Font',
			name = 'Font Family',
			values = SharedMedia:HashTable('font'),
			get = GetFontSetting,
			set = SetFontSetting,
		}
	elseif key == 'fontstyle' then
		widget = {
			type = 'select',
			name = 'Font Style',
			values = {['NONE'] = 'NONE', ['OUTLINE'] = 'OUTLINE', ['THICKOUTLINE'] = 'THICKOUTLINE', ['MONOCHROME'] = 'MONOCHROME'},
		}
	elseif key == 'itemquality' or (key:find('quality') and type(option) == 'number') then
		widget = {
			type = 'select',
			values = itemQualities,
		}
	elseif key == 'money' then
		-- TODO: this needs some more intuition. Use GetCoinTextureString(amount)?
		widget = {
			type = 'input',
			multiline = false,
			usage = 'Insert value in coppers, e.g. 10000 for 1|TInterface\\MoneyFrame\\UI-GoldIcon:0|t.',
			pattern = '%d',
		}
	elseif key == 'values' or key:find('list$') then
		widget = {
			type = 'input',
			multiline = true,
			usage = 'Insert one entry per line',
			get = GetListSetting,
			set = SetListSetting,
		}
	elseif type(option) == 'string' then
		widget = {
			type = 'input',
		}
	end

	return widget
end

local function ParseOption(key, option, L, typeMappings)
	if type(key) ~= 'string' or key == '*' or key == '**' then return end
	-- if key == 'profileKeys' then return end

	local widget = Widget(key, option, typeMappings)
	if widget == true then
		return nil
	elseif widget then
		widget.name = widget.name or key
	elseif type(option) == 'boolean' then
		widget = {
			type = 'toggle',
			name = key,
			-- desc = '',
		}
	elseif type(option) == 'number' then
		widget = {
			type = 'range',
			name = key,
			-- desc = '',
			min = -200,
			max = 200,
			bigStep = 10,
		}
	elseif type(option) == 'table' then
		widget = {
			type 	= 'group',
			inline 	= true,
			name 	= key,
			args 	= {},
			order   = -1,
		}

		for subkey, value in pairs(option) do
			widget.args[subkey] = ParseOption(subkey, value, L, typeMappings)
		end
	end

	if L and type(L) == 'table' then
		widget.name = L[key..'Name'] or widget.name
		widget.desc = L[key..'Desc'] or widget.desc
	end

	return widget
end

function lib:GetOptionsTable(variables, typeMappings, L)
	local dataPath
	if type(variables) == 'string' then
		dataPath = variables
		variables = GetVariableFromPath(dataPath)
	end

	local optionsTable = {
		name = 'Options',
		type = 'group',
		args = {},
		get = function(info) return GetSettingDefault(info, dataPath or info[1]) end,
		set = function(info, value) return SetSettingDefault(info, value, dataPath or info[1]) end,
	}

	for key, value in pairs(variables) do
		optionsTable.args[key] = ParseOption(key, value, L, typeMappings)
	end

	return optionsTable
end
