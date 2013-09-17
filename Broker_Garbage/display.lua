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
		return BG.FormatMoney(BG.junkValue or 0)
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
			return BG.FormatMoney(cacheData.value or 0)
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

local gColor, sColor, cColor = "ffd700", "c7c7cf", "eda55f"
local separators = {
	{'.', '.', ''},
	{'|cff'..gColor..'.|r',  '|cff'..sColor..'.|r',  ''},
	{'|cff'..gColor..'g|r ', '|cff'..sColor..'s|r ', '|cff'..cColor..'c|r '},
	{'|TInterface\\MoneyFrame\\UI-GoldIcon:0|t ', '|TInterface\\MoneyFrame\\UI-SilverIcon:0|t ', '|TInterface\\MoneyFrame\\UI-CopperIcon:0|t '},
}

local parts = {}
function BG.FormatMoney(amount, displayMode)
	if not amount then return '' end
	local signum = amount < 0 and '-' or ''
		  amount = math.abs(amount)

	local copper = amount%100
	local tmp    = math.floor(amount/100)
	local silver = tmp%100
	local gold   = math.floor(tmp/100)

	displayMode = displayMode or BG_GlobalDB.showMoney

	local text
	local template = displayMode%2 == 0 and '%1$.2i' or '%1$i'
	local goldTemplate = '%1$i' -- gold does not need padding
	if displayMode == 2 or displayMode == 3 then
		template = "|cff%3$s"..template.."|r%2$s"
		goldTemplate = "|cff%3$s"..goldTemplate.."|r%2$s"
	else
		template = template.."%2$s"
		goldTemplate = goldTemplate.."%2$s"
	end
	local showEmptyDenominators = true -- TODO, only applies to inner values
	local style = math.floor(displayMode/2)+1
	if separators[style] then
		wipe(parts)
		if gold > 0 then table.insert(parts, goldTemplate:format(gold, separators[style][1], gColor)) end
		if silver > 0 or (showEmptyDenominators and #parts > 0) then table.insert(parts, template:format(silver, separators[style][2], sColor)) end
		if copper > 0 or (showEmptyDenominators and #parts > 0) then table.insert(parts, template:format(copper, separators[style][3], cColor)) end
		text = signum .. table.concat(parts, '')
		text = strtrim(text, " ")
	else
		text = signum .. GetCoinTextureString(amount)
	end

	return text or ''
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

-- FIXME
local reasonNames = {"keep (itemID)", "keep (category)", "toss (itemID)", "toss (category)", "quest item", "unusable gear", "outdated gear", "gray item", "custom price (itemID)", "custom price (category)", "worthless", "slot is empty", "highest value", "soulbound", "quality above threshold", "outdated but highest ilvl"}

hooksecurefunc(GameTooltip, "SetBagItem", function(tooltip, container, slot)
	local location = BG.GetLocation(container, slot)
	local cacheData = BG.containers[location]

	if BG_GlobalDB.showItemTooltipLabel and cacheData.item then
		tooltip:AddDoubleLine(string.format("|cffee6622%s|r%s", addonName, BG_LocalDB.debug and " "..location or ""),
			(cacheData.sell and "|TInterface\\BUTTONS\\UI-GroupLoot-Coin-Up:0|t " or "")..(BG.GetInfo(cacheData.label) or "") )

		if BG_GlobalDB.showLabelReason then
			-- TODO: prettify
			tooltip:AddDoubleLine(cacheData.priority, reasonNames[ cacheData.reason ])
		end
		tooltip:Show()
	end
end)
