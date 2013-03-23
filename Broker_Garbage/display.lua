local _, BG = ...

-- GLOBALS: BG_GlobalDB, BG_LocalDB, NUM_BAG_SLOTS, Broker_Garbage_Config, UIParent, LibStub, GameTooltipText
-- GLOBALS: GetItemInfo, GetContainerNumSlots, GetContainerNumFreeSlots, InterfaceOptionsFrame_OpenToCategory, IsAddOnLoaded, LoadAddOn, IsAltKeyDown, IsShiftKeyDown, IsControlKeyDown, UseContainerItem, CreateFrame, CreateFont, ClearCursor
local select = select
local type = type
local ipairs = ipairs
local format = string.format
local gsub = string.gsub
local abs = math.abs
local fmod = math.fmod
local floor = math.floor
local _G = _G

local LibQTip = LibStub("LibQTip-1.0")
local LibDataBroker = LibStub("LibDataBroker-1.1")

-- == LDB Display ==
BG.LDB = LibDataBroker:NewDataObject("Broker_Garbage", {
	type	= "data source",
	icon	= "Interface\\Icons\\achievement_bg_returnxflags_def_wsg",
	label	= "Garbage",
	text 	= "",

	OnClick = function(...) BG:OnClick(...) end,
	OnEnter = function(...) BG:ShowTooltip(...) end,
	OnLeave = function() end, -- placeholder, required for e.g. ninja panel
})

function BG:UpdateLDB()
	BG.totalBagSpace, BG.totalFreeSlots, BG.specialSlots, BG.freeSpecialSlots = BG:GetBagSlots()

	BG.junkValue = 0
	for _, item in ipairs(BG.cheapestItems) do
		if not item.invalid and item.sell and item.value > 0 then
			BG.junkValue = BG.junkValue + item.value
		end
	end

	local cheapestItem = BG.cheapestItems[1]
	if cheapestItem and cheapestItem.source ~= BG.IGNORE and not cheapestItem.invalid then
		BG.LDB.text = BG:FormatString(BG_GlobalDB.LDBformat)
		BG.LDB.icon = select(10, GetItemInfo(cheapestItem.itemID))
	else
		BG.LDB.text = BG:FormatString(BG_GlobalDB.LDBNoJunk)
		BG.LDB.icon = "Interface\\Icons\\achievement_bg_returnxflags_def_wsg"
	end
end

local disenchantButtonCell, disenchantCellPrototype = LibQTip:CreateCellProvider()
function disenchantCellPrototype:InitializeCell()
	-- nothing
end
function disenchantCellPrototype:ReleaseCell()
	-- nothing
end
function disenchantCellPrototype:getContentHeight()
	return 10
end
function disenchantCellPrototype:SetupCell(tooltip, value, justification, font, r, g, b)
	if value then
		local index, bag, slot = value[1], value[2], value[3]

		local button = _G["BG_TT_DisenchantBtn"..index]
		if not button then
			button = CreateFrame("Button", "BG_TT_DisenchantBtn"..index, UIParent, "SecureActionButtonTemplate")
			button:SetNormalTexture("Interface\\ICONS\\INV_Enchant_Disenchant")
		end
		button:SetParent(self)
		button:SetPoint("TOPLEFT", self)

		button:SetAttribute("type", "spell")
		button:SetAttribute("spell", BG.disenchant)
		button:SetAttribute("target-bag", bag)
		button:SetAttribute("target-slot", slot)

		button:SetSize(12, 12)
		button:Show()
	else
		button:SetSize(0, 0)
		button:Hide()
	end
	return value and 10 or 0, 10
end

function BG:ShowTooltip(self)
	local numColumns, lineNum = (BG_GlobalDB.showSource and 4 or 3) + 1, 0
	local tooltip = LibQTip:Acquire("Broker_Garbage", numColumns, "LEFT", "RIGHT", "RIGHT", numColumns >= 4 and "CENTER" or nil)
	BG.tooltip = tooltip

	tooltip:Clear()
	tooltip:GetFont():SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)

	-- add header lines: these don't span across disenchant column!
	lineNum = tooltip:AddHeader('Broker_Garbage')
			  tooltip:SetCell(lineNum, 2, BG.locale.headerAltClick, tooltip.regularFont, numColumns - 1 -1)
	lineNum = tooltip:AddLine(BG.locale.headerShiftClick)
			  tooltip:SetCell(lineNum, 2, BG.locale.headerCtrlClick, nil, 'RIGHT', numColumns - 1 -1)
	tooltip:AddSeparator(2)

	-- add clam information
	if BG_GlobalDB.openContainers and BG.containerInInventory then
		lineNum = tooltip:AddLine()
				  tooltip:SetCell(lineNum, 1, BG.locale.openPlease, nil, 'CENTER', numColumns)
		tooltip:AddSeperator(2)
	end

	-- shows up to n lines of deletable items
	local itemEntry, numLinesShown, link, icon, text, source, canDisenchant
	for i = 1, BG_GlobalDB.tooltipNumItems do
		itemEntry = BG.cheapestItems and BG.cheapestItems[i]
		if not itemEntry or itemEntry.source == BG.IGNORE or itemEntry.invalid then
			-- not enough items to display
			numLinesShown = i - 1
			break
		end

		-- adds lines: itemLink, count, itemPrice, source
		_, link, _, _, _, _, _, _, _, icon, _ = GetItemInfo(itemEntry.itemID)
		text = (BG_GlobalDB.showIcon and "|T"..icon..":0|t " or "") .. link
		source = BG.colors[itemEntry.source] .. BG.tag[itemEntry.source] .. "|r"
		canDisenchant = BG.CanDisenchant(link)

		lineNum = tooltip:AddLine(text, itemEntry.count, BG.FormatMoney(itemEntry.value), BG_GlobalDB.showSource and source or nil)
				  tooltip:SetLineScript(lineNum, "OnMouseDown", BG.OnClick, itemEntry)
				  tooltip:SetCell(lineNum, numColumns, canDisenchant and {lineNum, itemEntry.bag, itemEntry.slot} or nil, disenchantButtonCell)
	end
	if numLinesShown == 0 then
		text = BG.locale.noItems .. "\n" .. BG.locale.increaseTreshold
		lineNum = tooltip:AddLine()
				  tooltip:SetCell(lineNum, 1, text, nil, "CENTER", numColumns)
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
function BG:OnClick(itemTable, button)
	-- itemTable is present = tooltip line clicked
	local isLDBclick = nil
	if not itemTable or not itemTable.itemID then
		itemTable = BG.cheapestItems[1]
		isLDBclick = true
	end

	-- don't touch invalid/outdated items
	if itemTable and (itemTable.invalid or itemTable.itemID == 0 or itemTable.source == BG.IGNORE) then
		itemTable = nil
	end

	-- handle different clicks
	if button == "RightButton" then
		if not IsAddOnLoaded("Broker_Garbage-Config") then
			LoadAddOn("Broker_Garbage-Config")
		end
		InterfaceOptionsFrame_OpenToCategory("Broker_Garbage")
		return

	elseif IsShiftKeyDown() then
		-- delete or sell item, depending on if we're at a vendor or not
		if not itemTable then
			BG.Print(BG.locale.noItems)
		elseif BG.isAtVendor and itemTable.value > 0 then
			BG.Debug("At vendor, selling "..itemTable.itemID)
			BG_GlobalDB.moneyEarned	= BG_GlobalDB.moneyEarned + itemTable.value
			BG_LocalDB.moneyEarned 	= BG_LocalDB.moneyEarned + itemTable.value
			BG_GlobalDB.itemsSold 	= BG_GlobalDB.itemsSold + itemTable.count

			ClearCursor()
			UseContainerItem(itemTable.bag, itemTable.slot)
		else
			BG.Debug("Not at vendor", "Deleting")
			BG.Delete(itemTable)
		end

	elseif IsControlKeyDown() and itemTable then
		-- add to exclude list
		if not BG_LocalDB.exclude[itemTable.itemID] then
			-- TODO: add public wrapper function!
			BG_LocalDB.exclude[itemTable.itemID] = 0
		end
		BG.Print(format(BG.locale.addedTo_exclude, select(2,GetItemInfo(itemTable.itemID))))

		if _G["BG_Options"] and _G["BG_Options"]:IsVisible() then
			Broker_Garbage_Config:ListOptionsUpdate("exclude")
		end
		BG.UpdateAllCaches(itemTable.itemID)

	elseif IsAltKeyDown() and itemTable then
		-- add to force vendor price list
		BG_GlobalDB.forceVendorPrice[itemTable.itemID] = -1
		BG.Print(format(BG.locale.addedTo_forceVendorPrice, select(2,GetItemInfo(itemTable.itemID))))

		if _G["BG_Options"] and _G["BG_Options"]:IsVisible() then
			Broker_Garbage_Config:ListOptionsUpdate("forceprice")
		end
		BG.UpdateAllCaches(itemTable.itemID)

	elseif isLDBclick then
		-- click on the LDB to rescan
		-- see below
	else
		-- no scanning in any other case
		return
	end

	BG.ScanInventory()
end

-- == Misc. stuff ==
-- tiny launcher for manual restacking! yay!
local restackButton = LibStub:GetLibrary("LibDataBroker-1.1"):NewDataObject("Broker_Garbage-Restack", {
	type = "launcher",
	icon = "Interface\\Icons\\achievement_bg_returnxflags_def_wsg",
	OnClick = function(self, button)
		BG.DoFullRestack()
	end,
	text = "Restack Inventory",
	label = "Restack Inventory",
})

-- == LDB formating ==
-- returns total bag slots and free bag slots of your whole inventory
function BG:GetBagSlots()
	local numSlots, freeSlots = 0, 0
	local specialSlots, specialFree = 0, 0
	local bagSlots, emptySlots, bagType

	for bag = 0, NUM_BAG_SLOTS do
		bagSlots = GetContainerNumSlots(bag) or 0
		emptySlots, bagType = GetContainerNumFreeSlots(bag)

		if bagType and bagType == 0 then
			numSlots = numSlots + bagSlots
			freeSlots = freeSlots + emptySlots
		else
			specialSlots = specialSlots + bagSlots
			specialFree = specialFree + emptySlots
		end
	end
	return numSlots, freeSlots, specialSlots, specialFree
end

-- returns a red-to-green color depending on the given percentage
function BG:Colorize(min, max)
	local color
	if not min then
		return ""
	elseif type(min) == "table" then
		color = { min.r*255, min.g*255, min.b*255}
	else
		local percentage = min/(max and max ~= 0 and max or 1)
		if percentage <= 0.5 then
			color =  {255, percentage*510, 0}
		else
			color =  {510 - percentage*510, 255, 0}
		end
	end

	color = format("|cff%02x%02x%02x", color[1], color[2], color[3])
	return color
end

-- easier syntax for LDB display strings
function BG:FormatString(text)
	local item = BG.cheapestItems and BG.cheapestItems[1] or { itemID = 0, count = 0, value = 0 }
	local _, itemLink, _, _, _, _, _, _, _, texture = GetItemInfo(item.itemID)

	-- [junkvalue]
	text = gsub(text, "%[junkvalue%]", BG.FormatMoney(BG.junkValue))

	-- [itemname][itemcount][itemvalue]
	text = gsub(text, "%[itemname%]", (itemLink or ""))
	text = gsub(text, "%[itemicon%]", "|T"..(texture or "")..":0|t")
	text = gsub(text, "%[itemcount%]", item.count)
	text = gsub(text, "%[itemvalue%]", BG.FormatMoney(item.value))

	-- [freeslots][totalslots]
	text = gsub(text, "%[freeslots%]", BG.totalFreeSlots + BG.freeSpecialSlots)
	text = gsub(text, "%[totalslots%]", BG.totalBagSpace + BG.specialSlots)

	-- [specialfree][specialslots][specialslots][basicslots]
	text = gsub(text, "%[specialfree%]", BG.freeSpecialSlots)
	text = gsub(text, "%[specialslots%]", BG.specialSlots)
	text = gsub(text, "%[basicfree%]", BG.totalFreeSlots)
	text = gsub(text, "%[basicslots%]", BG.totalBagSpace)

	-- [bagspacecolor][basicbagcolor][specialbagcolor][endcolor]
	text = gsub(text, "%[bagspacecolor%]",
		BG:Colorize(BG.totalFreeSlots + BG.freeSpecialSlots, BG.totalBagSpace + BG.specialSlots))
	text = gsub(text, "%[basicbagcolor%]",
			BG:Colorize(BG.totalFreeSlots, BG.totalBagSpace))
	text = gsub(text, "%[specialbagcolor%]",
			BG:Colorize(BG.freeSpecialSlots, BG.specialSlots))
	text = gsub(text, "%[endcolor%]", "|r")

	return text
end

-- formats money int values, depending on settings
function BG.FormatMoney(amount, displayMode)
	if not amount then return "" end
	displayMode = displayMode or BG_GlobalDB.showMoney

	local signum = amount < 0 and "-" or ""
		  amount = abs(amount)

	local gold   = floor(amount / (100 * 100))
	local silver = fmod(floor(amount / 100), 100)
	local copper = fmod(floor(amount), 100)

	local formatGold, formatSilver, formatCopper
	-- plain, dot-seperated
	if displayMode == 0 then
		formatGold = "%i.%.2i.%.2i"
		formatSilver = "%i.%.2i"
		formatCopper = "%i"

	elseif displayMode == 1 then
		formatGold = "%i.%i.%i"
		formatSilver = "%i.%i"
		formatCopper = "%i"

	-- colored, dot-seperated
	elseif displayMode == 2 then
		formatGold = "|cffffd700%i|r.|cffc7c7cf%.2i|r.|cffeda55f%.2i|r"
		formatSilver = "|cffc7c7cf%i|r.|cffeda55f%.2i|r"
		formatCopper = "|cffeda55f%i|r"

	elseif displayMode == 3 then
		formatGold = "|cffffd700%i|r.|cffc7c7cf%i|r.|cffeda55f%i|r"
		formatSilver = "|cffc7c7cf%i|r.|cffeda55f%i|r"
		formatCopper = "|cffeda55f%i|r"

	-- Ara Broker Money
	elseif displayMode == 4 then
		formatGold = "|cffeeeeee%i|r|cffffd700g|r |cffeeeeee%.2i|r|cffc7c7cfs|r |cffeeeeee%.2i|r|cffeda55fc|r"
		formatSilver = "|cffeeeeee%i|r|cffc7c7cfs|r |cffeeeeee%.2i|r|cffeda55fc|r"
		formatCopper = "|cffeeeeee%i|r|cffeda55fc|r"

	elseif displayMode == 5 then
		formatGold = "|cffeeeeee%i|r|cffffd700g|r |cffeeeeee%i|r|cffc7c7cfs|r |cffeeeeee%i|r|cffeda55fc|r"
		formatSilver = "|cffeeeeee%i|r|cffc7c7cfs|r |cffeeeeee%i|r|cffeda55fc|r"
		formatCopper = "|cffeeeeee%i|r|cffeda55fc|r"

	-- Haggler
	elseif displayMode == 6 then
		formatGold = "%i|TInterface\\MoneyFrame\\UI-GoldIcon:0|t %.2i|TInterface\\MoneyFrame\\UI-SilverIcon:0|t %.2i|TInterface\\MoneyFrame\\UI-CopperIcon:0|t"
		formatSilver = "%i|TInterface\\MoneyFrame\\UI-SilverIcon:0|t %.2i|TInterface\\MoneyFrame\\UI-CopperIcon:0|t"
		formatCopper = "%i|TInterface\\MoneyFrame\\UI-CopperIcon:0|t"

	elseif displayMode == 7 then
		formatGold = "%i|TInterface\\MoneyFrame\\UI-GoldIcon:0|t %i|TInterface\\MoneyFrame\\UI-SilverIcon:0|t %i|TInterface\\MoneyFrame\\UI-CopperIcon:0|t"
		formatSilver = "%i|TInterface\\MoneyFrame\\UI-SilverIcon:0|t %i|TInterface\\MoneyFrame\\UI-CopperIcon:0|t"
		formatCopper = "%i|TInterface\\MoneyFrame\\UI-CopperIcon:0|t"
	else
		return nil
	end

	if gold > 0 then
		return format(signum .. formatGold, gold, silver, copper)
	elseif silver > 0 then
		return format(signum .. formatSilver, silver, copper)
	else
		return format(signum .. formatCopper, copper)
	end
end
