--[[
	This file imports localization data from curse.com
	If you wish to get your language and/or translations used, submit them at http://wow.curseforge.com/addons/broker_garbage/localization and inform me via private message or an addon issue ticket
--]]
local _, BG = ...
local L = BG.locale

local current = GetLocale()
if current == "zhTW" then
	--@localization(locale="zhTW", format="lua_additive_table", namespace="Core", handle-unlocalized="ignore")@
elseif current == "zhCN" then
	--@localization(locale="zhCN", format="lua_additive_table", namespace="Core", handle-unlocalized="ignore")@
elseif current == "ruRU" then
	--@localization(locale="ruRU", format="lua_additive_table", namespace="Core", handle-unlocalized="ignore")@
elseif current == "frFR" then
	--@localization(locale="frFR", format="lua_additive_table", namespace="Core", handle-unlocalized="ignore")@
elseif current == "ptBR" then
	--@localization(locale="ptBR", format="lua_additive_table", namespace="Core", handle-unlocalized="ignore")@
elseif current == "itIT" then
	--@localization(locale="itIT", format="lua_additive_table", namespace="Core", handle-unlocalized="ignore")@
elseif current == "koKR" then
	--@localization(locale="koKR", format="lua_additive_table", namespace="Core", handle-unlocalized="ignore")@
elseif current == "esMX" then
	--@localization(locale="esMX", format="lua_additive_table", namespace="Core", handle-unlocalized="ignore")@
elseif current == "esES" then
	--@localization(locale="esES", format="lua_additive_table", namespace="Core", handle-unlocalized="ignore")@
end
