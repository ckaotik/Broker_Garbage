local addonName, BG, _ = ...

local LibDataBroker = LibStub("LibDataBroker-1.1")

-- GLOBALS: BG_GlobalDB, BG_LocalDB, LibStub, NORMAL_FONT_COLOR
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
		return BG.FormatMoney(BG.junkValue)
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
			return BG.FormatMoney(cacheData.value)
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

		-- TODO: checking bag type on every slot sucks ...
		local _, containerType = GetContainerNumFreeSlots(container)
		-- update slot stats
		if containerType == 0 then
			BG.totalBagSpace = BG.totalBagSpace + 1
			BG.totalFreeSlots = BG.totalFreeSlots + (cacheData.item and 1 or 0)
		else
			BG.specialSlots = BG.specialSlots + 1
			BG.freeSpecialSlots = BG.freeSpecialSlots + (cacheData.item and 1 or 0)
		end

		BG.containerInInventory = BG.containerInInventory or ( select(6, GetContainerItemInfo(container, slot)) )

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
		LDB.text = (BG_GlobalDB.LDBformat or ""):gsub("%b[]", formatReplacements)
		LDB.icon = select(10, GetItemInfo(cacheData.item.id))
	else
		LDB.text = (BG_GlobalDB.LDBNoJunk or ""):gsub("%b[]", formatReplacements)
		LDB.icon = "Interface\\Icons\\achievement_bg_returnxflags_def_wsg"
	end
end

local LibQTip = LibStub("LibQTip-1.0")
local disenchantButtonCell, disenchantCellPrototype = LibQTip:CreateCellProvider()
function disenchantCellPrototype:InitializeCell()
	local button = CreateFrame("Button", nil, self, "SecureActionButtonTemplate")
	      button:SetSize(12, 12)
	      button:SetNormalTexture("Interface\\ICONS\\INV_Enchant_Disenchant")
	      button:SetPoint("TOPLEFT", self)

	      button:SetAttribute("type", "spell")
	      button:SetAttribute("spell", BG.disenchant)

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
	local numColumns, lineNum = (BG_GlobalDB.showSource and 4 or 3) + 1, 0
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
	if BG_GlobalDB.openContainers and BG.containerInInventory then
		lineNum = tooltip:AddLine()
		          tooltip:SetCell(lineNum, 1, BG.locale.openPlease, nil, 'CENTER', numColumns)
		tooltip:AddSeperator(2)
	end

	-- shows up to n lines of deletable items
	local numLinesShown, location, cacheData
	for i = 1, BG_GlobalDB.tooltipNumItems do
		location = BG.list[i]
		cacheData = location and BG.containers[location]
		if not cacheData or not cacheData.item or cacheData.label == BG.IGNORE then
			-- not enough items to display
			numLinesShown = i - 1
			break
		end

		-- adds lines: itemLink, count, itemPrice, source
		local _, link, _, _, _, _, _, _, _, icon, _ = GetItemInfo(cacheData.item.id)
		local text = (BG_GlobalDB.showIcon and "|T"..icon..":0|t " or "") .. link
		local source = BG.GetInfo(cacheData.label, true) or ""

		lineNum = tooltip:AddLine(text, cacheData.count, BG.FormatMoney(cacheData.value), BG_GlobalDB.showSource and source or nil)
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
	if (BG_GlobalDB.showLost and BG_LocalDB.moneyLostByDeleting ~= 0)
		or (BG_GlobalDB.showEarned and BG_LocalDB.moneyEarned ~= 0) then

		tooltip:AddSeparator(2)
		if BG_GlobalDB.showLost and BG_LocalDB.moneyLostByDeleting ~= 0 then
			lineNum = tooltip:AddLine(BG.locale.moneyLost)
			          tooltip:SetCell(lineNum, 2, BG.FormatMoney(BG_LocalDB.moneyLostByDeleting), nil, "RIGHT", numColumns - 1)
		end
		if BG_GlobalDB.showEarned and BG_LocalDB.moneyEarned ~= 0 then
			lineNum = tooltip:AddLine(BG.locale.moneyEarned)
			          tooltip:SetCell(lineNum, 2, BG.FormatMoney(BG_LocalDB.moneyEarned), nil, "RIGHT", numColumns - 1)
		end
	end

	-- Use smart anchoring code to anchor the tooltip to our LDB frame
	tooltip:SmartAnchorTo(self)
	tooltip:SetAutoHideDelay(0.25, self)

	-- Show it, et voilà !
	tooltip:Show()
	tooltip:UpdateScrolling(BG_GlobalDB.tooltipMaxHeight)
end

-- OnClick function - works for both, the LDB plugin -and- tooltip lines
function BG.OnClick(location, btn)
	local isLDBclick = type(location) == "table" and true or false
	location = isLDBclick and BG.list[1] or location

	if btn == "RightButton" then
		if InCombatLockdown() then BG.Print('Please try again after combat.'); return end -- TODO: locale
		LoadAddOn("Broker_Garbage-Config")
		InterfaceOptionsFrame_OpenToCategory("Broker_Garbage")
		return
	else
		-- don't touch invalid/outdated items
		local cacheData = BG.containers[location]
		if not cacheData.item or cacheData.label == BG.IGNORE then -- TODO: use PRIORITY_IGNORE ?
			BG.Print(BG.locale.noItems)
			return
		end

		-- handle different clicks
		local itemID = cacheData.item.id
		if IsShiftKeyDown() then
			-- delete or sell item, depending on whether we're at a vendor or not
			if BG.isAtVendor and cacheData.value > 0 then
				BG_GlobalDB.moneyEarned	= BG_GlobalDB.moneyEarned + cacheData.value
				BG_LocalDB.moneyEarned 	= BG_LocalDB.moneyEarned + cacheData.value
				BG_GlobalDB.itemsSold 	= BG_GlobalDB.itemsSold + cacheData.count

				ClearCursor()
				UseContainerItem( BG.GetBagSlot(location) )
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

function BG.FormatMoney(amount, displayMode)
	if not amount then return "" end
	local signum = amount < 0 and "-" or ""
		  amount = amount < 0 and -1*amount or amount

	local copper = amount%100
	      amount = math.floor(amount/100)
	local silver = amount%100
	local gold   = math.floor(amount/100)

	local formatGold, formatSilver, formatCopper
	displayMode = displayMode or BG_GlobalDB.showMoney
	if displayMode == 0 then
		-- 1337.09.09
		formatGold   = "%i.%.2i.%.2i"
		formatSilver = "%i.%.2i"
		formatCopper = "%i"
	elseif displayMode == 1 then
		-- 1337.9.9
		formatGold   = "%i.%i.%i"
		formatSilver = "%i.%i"
		formatCopper = "%i"
	elseif displayMode == 2 then
		-- 1337.09.09 (colored)
		formatGold   = "|cffffd700%i|r.|cffc7c7cf%.2i|r.|cffeda55f%.2i|r"
		formatSilver = "|cffc7c7cf%i|r.|cffeda55f%.2i|r"
		formatCopper = "|cffeda55f%i|r"
	elseif displayMode == 3 then
		-- 1337.9.9 (colored)
		formatGold   = "|cffffd700%i|r.|cffc7c7cf%i|r.|cffeda55f%i|r"
		formatSilver = "|cffc7c7cf%i|r.|cffeda55f%i|r"
		formatCopper = "|cffeda55f%i|r"
	-- Ara Broker Money
	elseif displayMode == 4 then
		-- 1337g 09s 09c (colored)
		formatGold   = "|cffeeeeee%i|r|cffffd700g|r |cffeeeeee%.2i|r|cffc7c7cfs|r |cffeeeeee%.2i|r|cffeda55fc|r"
		formatSilver = "|cffeeeeee%i|r|cffc7c7cfs|r |cffeeeeee%.2i|r|cffeda55fc|r"
		formatCopper = "|cffeeeeee%i|r|cffeda55fc|r"
	elseif displayMode == 5 then
		-- 1337g 9s 9c (colored)
		formatGold   = "|cffeeeeee%i|r|cffffd700g|r |cffeeeeee%i|r|cffc7c7cfs|r |cffeeeeee%i|r|cffeda55fc|r"
		formatSilver = "|cffeeeeee%i|r|cffc7c7cfs|r |cffeeeeee%i|r|cffeda55fc|r"
		formatCopper = "|cffeeeeee%i|r|cffeda55fc|r"
	-- Haggler
	elseif displayMode == 6 then
		-- 1337* 09* 09* (icons)
		formatGold   = "%i|TInterface\\MoneyFrame\\UI-GoldIcon:0|t %.2i|TInterface\\MoneyFrame\\UI-SilverIcon:0|t %.2i|TInterface\\MoneyFrame\\UI-CopperIcon:0|t"
		formatSilver = "%i|TInterface\\MoneyFrame\\UI-SilverIcon:0|t %.2i|TInterface\\MoneyFrame\\UI-CopperIcon:0|t"
		formatCopper = "%i|TInterface\\MoneyFrame\\UI-CopperIcon:0|t"
	elseif displayMode == 7 then
		-- 1337* 9* 9* (icons)
		formatGold   = "%i|TInterface\\MoneyFrame\\UI-GoldIcon:0|t %i|TInterface\\MoneyFrame\\UI-SilverIcon:0|t %i|TInterface\\MoneyFrame\\UI-CopperIcon:0|t"
		formatSilver = "%i|TInterface\\MoneyFrame\\UI-SilverIcon:0|t %i|TInterface\\MoneyFrame\\UI-CopperIcon:0|t"
		formatCopper = "%i|TInterface\\MoneyFrame\\UI-CopperIcon:0|t"
	else
		return amount and GetCoinTextureString(amount)
	end

	if gold > 0 then
		return string.format(signum .. formatGold, gold, silver, copper)
	elseif silver > 0 then
		return string.format(signum .. formatSilver, silver, copper)
	else
		return string.format(signum .. formatCopper, copper)
	end
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

	if BG_GlobalDB.showItemTooltipLabel and cacheData.item then
		tooltip:AddDoubleLine(
			string.format("|cffee6622%s|r%s", addonName, BG_LocalDB.debug and " "..location or ""),
			(cacheData.sell and "|TInterface\\BUTTONS\\UI-GroupLoot-Coin-Up:0|t " or "")..(BG.GetInfo(cacheData.label) or "")
		)

		if BG_GlobalDB.showLabelReason then
			-- TODO: prettify
			tooltip:AddDoubleLine(cacheData.priority, cacheData.reason)
		end
		tooltip:Show()
	end
end)
