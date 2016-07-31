local addonName, BG, _ = ...

local LibDataBroker = LibStub("LibDataBroker-1.1")

-- GLOBALS: LibStub, NORMAL_FONT_COLOR
-- GLOBALS: GetItemInfo, GetContainerNumFreeSlots, GetContainerItemInfo, InterfaceOptionsFrame_OpenToCategory, LoadAddOn, IsAltKeyDown, IsShiftKeyDown, IsControlKeyDown, UseContainerItem, CreateFrame, ClearCursor, InCombatLockdown, GetCoinTextureString
-- GLOBALS: pairs, select, type, string, math

-- returns a red-to-green color depending on the given percentage
local function Colorize(minVal, maxVal)
	local color, r, g, b
	if not minVal then
		return ""
	elseif type(minVal) == "table" then
		r, g, b = minVal.r*255, minVal.g*255, minVal.b*255
	else
		local percentage = minVal/(maxVal and maxVal ~= 0 and maxVal or 1)
		if percentage <= 0.5 then
			r, g, b = 255, percentage*510, 0
		else
			r, g, b = 510 - percentage*510, 255, 0
		end
	end
	return string.format("|cff%02x%02x%02x", r, g, b)
end

local formatReplaceFuncs = {
	["[junkvalue]"] = function()
		return BG.FormatMoney(BG.junkValue or 0, nil, true) -- short display
	end,
	-- item based
	["[itemname]"] = function()
		local cacheData = BG.containers[ BG.list[1] ]
		if cacheData.item then
			local _, itemLink = GetItemInfo(cacheData.item.id)
			return itemLink
		end
	end,
	["[itemicon]"] = function()
		local cacheData = BG.containers[ BG.list[1] ]
		if cacheData.item then
			local icon = select(10, GetItemInfo(cacheData.item.id))
			return "|T"..icon..":0|t"
		end
	end,
	["[itemcount]"] = function()
		local cacheData = BG.containers[ BG.list[1] ]
		if cacheData.item then
			return cacheData.count
		end
	end,
	["[itemvalue]"] = function()
		local cacheData = BG.containers[ BG.list[1] ]
		if cacheData.item then
			return BG.FormatMoney(cacheData.value or 0, nil, true)
		end
	end,

	-- container counts
	["[freeslots]"] = function()
		return BG.totalFreeSlots + BG.freeSpecialSlots
	end,
	["[totalslots]"] = function()
		return BG.totalBagSpace + BG.specialSlots
	end,
	["[specialfree]"] = function()
		return BG.freeSpecialSlots
	end,
	["[specialslots]"] = function()
		return BG.specialSlots
	end,
	["[basicfree]"] = function()
		return BG.totalFreeSlots
	end,
	["[basicslots]"] = function()
		return BG.totalBagSpace
	end,

	-- colors
	["[bagspacecolor]"] = function()
		return Colorize(BG.totalFreeSlots + BG.freeSpecialSlots, BG.totalBagSpace + BG.specialSlots)
	end,
	["[basicbagcolor]"] = function()
		return Colorize(BG.totalFreeSlots, BG.totalBagSpace)
	end,
	["[specialbagcolor]"] = function()
		return Colorize(BG.freeSpecialSlots, BG.specialSlots)
	end,
}
local formatReplacements = setmetatable({
	-- save to table whatever is static
	["[endcolor]"] = '|r',
}, {
	__index = function(self, key)
		-- don't save to table as it's dynamic
		return formatReplaceFuncs[key] and formatReplaceFuncs[key]() or ""
	end
})

function BG.UpdateLDB()
	BG.junkValue = 0
	BG.containerInInventory = false
	BG.totalBagSpace, BG.totalFreeSlots = 0, 0
	BG.specialSlots, BG.freeSpecialSlots = 0, 0

	for location, cacheData in pairs(BG.containers) do
		local container, slot = BG.GetBagSlot(location)
		if not container or not slot then print('location not parsed', location, container, slot) end
		-- TODO: checking bag type on every slot sucks ...
		local containerType = container and select(2, GetContainerNumFreeSlots(container)) or 0
		-- update slot stats
		if containerType == 0 then
			BG.totalBagSpace = BG.totalBagSpace + 1
			BG.totalFreeSlots = BG.totalFreeSlots + (cacheData.item and 0 or 1)
		else
			BG.specialSlots = BG.specialSlots + 1
			BG.freeSpecialSlots = BG.freeSpecialSlots + (cacheData.item and 0 or 1)
		end

		BG.containerInInventory = BG.containerInInventory or select(6, GetContainerItemInfo(container, slot))

		if cacheData.sell and cacheData.value > 0 then
			-- update junk value
			BG.junkValue = BG.junkValue + (cacheData.value * cacheData.count)
		end
	end

	-- once we've computed junkValue etc, update LDB text
	local cheapestItem = BG.list[1]
	local cacheData = cheapestItem and BG.containers[cheapestItem]

	local LDB = LibDataBroker:GetDataObjectByName(addonName)
	if cheapestItem and cacheData.item and cacheData.label ~= BG.IGNORE then
		-- update LDB text
		LDB.text = (BG.db.global.label or ""):gsub("%b[]", formatReplacements)
		LDB.icon = select(10, GetItemInfo(cacheData.item.id))
	else
		LDB.text = (BG.db.global.noJunkLabel or ""):gsub("%b[]", formatReplacements)
		LDB.icon = "Interface\\Icons\\achievement_bg_returnxflags_def_wsg"
	end
end

local LibQTip = LibStub("LibQTip-1.0")
local disenchanting = GetSpellInfo(13262)
local disenchantButtonCell, disenchantCellPrototype = LibQTip:CreateCellProvider()
function disenchantCellPrototype:InitializeCell()
	local button = CreateFrame("Button", addonName..'DisenchantButton', self, "SecureActionButtonTemplate")
	      button:SetSize(12, 12)
	      button:SetNormalTexture("Interface\\ICONS\\INV_Enchant_Disenchant")
	      button:SetPoint("TOPLEFT", self)

	      button:SetAttribute("type", "spell")
	      button:SetAttribute("spell", disenchanting)

	self.disenchant = button
end
function disenchantCellPrototype:ReleaseCell() end
function disenchantCellPrototype:getContentHeight()
	return 10
end
function disenchantCellPrototype:SetupCell(tooltip, location, justification, font, r, g, b)
	if not location then return 0, 0 end
	local container, slot = BG.GetBagSlot(location)
	local button = self.disenchant
	button:SetAttribute("target-bag", container)
	button:SetAttribute("target-slot", slot)

	return 10, 10
end

function BG.ShowTooltip(self)
	local numColumns, lineNum = (BG.db.global.tooltip.showReason and 4 or 3) + 1, 0
	local tooltip = LibQTip:Acquire(addonName, numColumns, "LEFT", "RIGHT", "RIGHT", numColumns >= 4 and "CENTER" or nil)
	BG.tooltip = tooltip

	tooltip:Clear()
	tooltip:GetFont():SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)

	-- add header lines: these don't span across disenchant column!
	lineNum = tooltip:AddHeader(addonName)
			  tooltip:SetCell(lineNum, 2, BG.locale.headerAltClick, tooltip.regularFont, numColumns - 1 -1)
	lineNum = tooltip:AddLine(BG.locale.headerShiftClick)
			  tooltip:SetCell(lineNum, 2, BG.locale.headerCtrlClick, nil, 'RIGHT', numColumns - 1 -1)
	tooltip:AddSeparator(2)

	-- add container slots information
	if BG.db.global.tooltip.showUnopenedContainers and BG.containerInInventory then
		lineNum = tooltip:AddLine()
		          tooltip:SetCell(lineNum, 1, BG.locale.openPlease, nil, 'CENTER', numColumns)
		tooltip:AddSeparator(2)
	end

	-- shows up to n lines of deletable items
	local numLinesShown, location, cacheData
	for i = 1, BG.db.global.tooltip.numLines do
		location = BG.list[i]
		cacheData = location and BG.containers[location]
		if not cacheData or not cacheData.item or cacheData.label == BG.IGNORE then
			-- not enough items to display
			numLinesShown = i - 1
			break
		end

		-- adds lines: itemLink, count, itemPrice, source
		local _, link, _, _, _, _, _, _, _, icon, _ = GetItemInfo(cacheData.item.id)
		local text = (BG.db.global.tooltip.showIcon and "|T" .. (icon or 'Interface\\Icons\\INV_Misc_QuestionMark') .. ":0|t " or "") .. (link or _G.UNKNOWN)
		local source = BG.GetInfo(cacheData.label, true) or ""

		lineNum = tooltip:AddLine(text, cacheData.count, BG.FormatMoney(cacheData.value*cacheData.count), BG.db.global.tooltip.showReason and source or nil)
		          tooltip:SetLineScript(lineNum, "OnMouseDown", BG.OnClick, location)

		if BG.CanDisenchant(cacheData.item.id) then
			tooltip:SetCell(lineNum, numColumns, location, disenchantButtonCell)
		else
			tooltip:SetCell(lineNum, numColumns, nil, nil)
		end
	end
	if numLinesShown == 0 then
		lineNum = tooltip:AddLine()
				  tooltip:SetCell(lineNum, 1, BG.locale.noItems .. "\n" .. BG.locale.increaseTreshold, nil, "CENTER", numColumns)
	end

	-- add statistics information
	local moneyEarned, moneyLost = BG:GetStatistics(BG.db.keys.char)
	if (BG.db.global.tooltip.showMoneyLost and moneyLost ~= 0)
		or (BG.db.global.tooltip.showMoneyEarned and moneyEarned ~= 0) then

		tooltip:AddSeparator(2)
		if BG.db.global.tooltip.showMoneyLost and moneyLost ~= 0 then
			lineNum = tooltip:AddLine(BG.locale.moneyLost)
			          tooltip:SetCell(lineNum, 2, BG.FormatMoney(moneyLost), nil, "RIGHT", numColumns - 1)
		end
		if BG.db.global.tooltip.showMoneyEarned and moneyEarned ~= 0 then
			lineNum = tooltip:AddLine(BG.locale.moneyEarned)
			          tooltip:SetCell(lineNum, 2, BG.FormatMoney(moneyEarned), nil, "RIGHT", numColumns - 1)
		end
	end

	-- Use smart anchoring code to anchor the tooltip to our LDB frame
	tooltip:SmartAnchorTo(self)
	tooltip:SetAutoHideDelay(0.25, self)

	-- Show it, et voilà !
	tooltip:Show()
	tooltip:UpdateScrolling(BG.db.global.tooltip.height)
end

-- OnClick function - works for both, the LDB plugin -and- tooltip lines
function BG.OnClick(self, location, btn)
	local isLDBclick = type(location) ~= "number" and true or false
	if isLDBclick then
		-- shift arguments
		btn = location
		location = BG.list[1]
	end

	if isLDBclick and btn == "RightButton" then
		if InCombatLockdown() then BG.Print('Please try again after combat.'); return end -- TODO: locale
		LoadAddOn("Broker_Garbage-Config")
		InterfaceOptionsFrame_OpenToCategory("Broker_Garbage")
		return
	else
		-- don't touch invalid/outdated items
		local cacheData = BG.containers[location]
		if not cacheData or not cacheData.item or cacheData.priority == BG.priority.IGNORE then
			BG.Print(BG.locale.noItems)
			return
		end

		-- handle different clicks
		local itemID = cacheData.item.id
		if IsShiftKeyDown() then
			-- delete or sell item, depending on whether we're at a vendor or not
			if MerchantFrame:IsShown() and cacheData.value > 0 then
				BG.Sell(location)
			else
				BG.Delete(location)
			end

		elseif IsControlKeyDown() then
			BG.Add("keep", itemID)
			BG.Print(string.format(BG.locale.addedTo_exclude, select(2, GetItemInfo(itemID))))

		elseif IsAltKeyDown() then
			BG.Add("price", itemID)
			BG.Print(string.format(BG.locale.addedTo_forceVendorPrice, select(2,GetItemInfo(itemID))))
		end
		-- FIXME: if config ui is shown, update. delete/sell: statistics, or list options
	end
end

local gColor, sColor, cColor = "ffd700", "c7c7cf", "eda55f"
local separators = {
	{'.', '.', ''},
	{'|cff'..gColor..'.|r',  '|cff'..sColor..'.|r',  ''},
	{'|cff'..gColor..'g|r ', '|cff'..sColor..'s|r ', '|cff'..cColor..'c|r '},
	{'|TInterface\\MoneyFrame\\UI-GoldIcon:0|t ', '|TInterface\\MoneyFrame\\UI-SilverIcon:0|t ', '|TInterface\\MoneyFrame\\UI-CopperIcon:0|t '},
}

function BG.FormatMoney(value, style, short)
	style = style or BG.db.global.moneyFormat
	local negative, amount = value < 0, tostring(math.abs(value))
	local gold, silver, copper = amount:sub(1, -5), amount:sub(-4, -3), amount:sub(-2, -1)
	      gold, silver, copper = tonumber(gold) or 0, tonumber(silver) or 0, tonumber(copper) or 0

	local prefix, goldSep, silverSep, copperSep = '', ' ', ' ', ''
	if not style or style == 'icon' then
		goldSep   = '|TInterface\\MoneyFrame\\UI-GoldIcon:0:0:2:0|t '
		silverSep = '|TInterface\\MoneyFrame\\UI-SilverIcon:0:0:2:0|t '
		copperSep = '|TInterface\\MoneyFrame\\UI-CopperIcon:0:0:2:0|t'
	elseif style == 'gsc' then
		prefix    = _G.HIGHLIGHT_FONT_COLOR_CODE
		goldSep   = '|cffffd700g|r '.._G.HIGHLIGHT_FONT_COLOR_CODE
		silverSep = '|cffc7c7cfs|r '.._G.HIGHLIGHT_FONT_COLOR_CODE
		copperSep = '|cffeda55fc|r'
	elseif style == 'dot' then
		prefix    = '|cffffd700'
		goldSep   = '|r.|cffc7c7cf'
		silverSep = '|r.|cffeda55f'
		copperSep = '|r'
	end

	local stringFormat = ''
	if short then
		-- w/o padding, w/o empty components, e.g. 1g 1c -or- 1s -or- 0c
		stringFormat = string.join('', prefix,
			(  gold > 0) and '%1$s' or '', gold > 0 and goldSep or '',
			(silver > 0) and '%2$d' or '', silver > 0 and silverSep or '',
			(copper > 0 or (amount == copper)) and '%3$d' or '', (copper > 0 or amount == copper) and copperSep or '')
	else
		-- w/ padding, w/ empty components, e.g. 1g 00s 01c -or- 1s 00c -or- 0c
		stringFormat = string.join('', prefix,
			(gold > 0 and '%1$s') or '', gold > 0 and goldSep or '',
			(gold > 0 and '%2$02d') or (silver > 0 and '%2$d') or '', (gold > 0 or silver > 0) and silverSep or '',
			(gold > 0 or silver > 0) and '%3$02d' or '%3$d', copperSep)
	end
	return (negative and '-' or '') .. string.format(stringFormat, BreakUpLargeNumbers(gold), silver, copper)
end

local LDB = LibDataBroker:NewDataObject(addonName, {
	type	= "data source",
	icon	= "Interface\\Icons\\achievement_bg_returnxflags_def_wsg",
	label	= "Garbage",
	text 	= "",

	OnClick = BG.OnClick,
	OnEnter = BG.ShowTooltip,
	OnLeave = function() end, -- placeholder, required for e.g. ninja panel, but LibQTip takes care of that for us
})

hooksecurefunc(GameTooltip, "SetBagItem", function(tooltip, container, slot)
	local location = BG.GetLocation(container, slot)
	local cacheData = BG.containers[location]

	if BG.db.global.itemTooltip.showClassification and cacheData and cacheData.item then
		tooltip:AddDoubleLine(
			string.format("|cffee6622%s|r", addonName),
			(cacheData.sell and "|TInterface\\BUTTONS\\UI-GroupLoot-Coin-Up:0|t " or "")..(BG.GetInfo(cacheData.label) or "") )

		if BG.db.global.itemTooltip.showReason then
			local reason = BG.reason[ cacheData.reason ]
			tooltip:AddDoubleLine(cacheData.priority, BG.locale["reason_"..reason])
		end
		tooltip:Show()
	end
end)
