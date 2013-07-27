local _, BG = ...

-- GLOBALS: BG_GlobalDB, BG_LocalDB, NUM_BAG_SLOTS, Broker_Garbage_Config, UIParent, LibStub, GameTooltipText, NORMAL_FONT_COLOR
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
local LDB = LibDataBroker:NewDataObject("Broker_Garbage", {
	type	= "data source",
	icon	= "Interface\\Icons\\achievement_bg_returnxflags_def_wsg",
	label	= "Garbage",
	text 	= "",

	OnClick = function(...) BG:OnClick(...) end,
	OnEnter = function(...) BG:ShowTooltip(...) end,
	OnLeave = function() end, -- placeholder, required for e.g. ninja panel
})

function BG:UpdateLDB()
	BG.junkValue = 0
	BG.totalBagSpace, BG.totalFreeSlots = 0, 0
	BG.specialSlots, BG.freeSpecialSlots = 0, 0 -- TODO

	-- TODO: remember lootable items
	-- canOpen = select(6, GetContainerItemInfo(container, slot))
	-- BG.containerInInventory = BG.containerInInventory or canOpen

	for location, cacheData in pairs(BG.containers) do
		-- update slot stats
		BG.totalBagSpace = BG.totalBagSpace + 1
		if not cacheData.item then
			BG.totalFreeSlots = BG.totalFreeSlots + 1
		end
		if cacheData.sell and cacheData.value > 0 then
			-- update junk value
			BG.junkValue = BG.junkValue + cacheData.value
		end
	end

	-- once we've computed junkValue etc, update LDB text
	local cheapestItem = BG.list[1]
	local cacheData = cheapestItem and BG.containers[cheapestItem]
	if cheapestItem and cacheData.item and cacheData.label ~= BG.IGNORE then
		-- update LDB text
		LDB.text = BG:FormatString(BG_GlobalDB.LDBformat)
		LDB.icon = select(10, GetItemInfo(cacheData.item.id))
	else
		LDB.text = BG:FormatString(BG_GlobalDB.LDBNoJunk)
		LDB.icon = "Interface\\Icons\\achievement_bg_returnxflags_def_wsg"
	end
end

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
	local container = math.floor(location)
	local slot = (location - container) * 100
	local button = self.disenchant
	button:SetAttribute("target-bag", container)
	button:SetAttribute("target-slot", slot)

	return 10, 10
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
	local numLinesShown, location, cacheData
	for i = 1, BG_GlobalDB.tooltipNumItems do
		location = BG.list[i]
		cacheData = BG.containers[location]
		if not cacheData.item or cacheData.label == BG.IGNORE then
			-- not enough items to display
			numLinesShown = i - 1
			break
		end

		-- adds lines: itemLink, count, itemPrice, source
		local _, link, _, _, _, _, _, _, _, icon, _ = GetItemInfo(cacheData.item.id)
		local text = (BG_GlobalDB.showIcon and "|T"..icon..":0|t " or "") .. link
		local source = BG.colors[cacheData.label] .. BG.tag[cacheData.label] .. "|r"

		lineNum = tooltip:AddLine(text, cacheData.count, BG.FormatMoney(cacheData.value), BG_GlobalDB.showSource and source or nil)
		          tooltip:SetLineScript(lineNum, "OnMouseDown", BG.OnClick, location)

		if false and BG.CanDisenchant(link) then -- TODO: fixme
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
function BG:OnClick(location, button)
	local isLDBclick = type(location) == "table" and true or false
	location = isLDBclick and BG.list[1] or location

	-- don't touch invalid/outdated items
	local cacheData = BG.containers[location]
	if not cacheData.item or cacheData.label == BG.IGNORE then
		BG.Print(BG.locale.noItems)
		return
	end

	-- handle different clicks
	if button == "RightButton" then
		if not IsAddOnLoaded("Broker_Garbage-Config") then
			if InCombatLockdown() then BG.Print('Please try again after combat.'); return end -- TODO: locale
			LoadAddOn("Broker_Garbage-Config")
		end
		InterfaceOptionsFrame_OpenToCategory("Broker_Garbage")
		return

	elseif IsShiftKeyDown() then
		-- delete or sell item, depending on if we're at a vendor or not
		if BG.isAtVendor and cacheData.value > 0 then
			BG.Debug("At vendor, selling "..cacheData.item.id)
			BG_GlobalDB.moneyEarned	= BG_GlobalDB.moneyEarned + cacheData.value
			BG_LocalDB.moneyEarned 	= BG_LocalDB.moneyEarned + cacheData.value
			BG_GlobalDB.itemsSold 	= BG_GlobalDB.itemsSold + cacheData.count

			ClearCursor()
			local container = math.floor(location)
			local slot = (location - container) * 100
			UseContainerItem(container, slot)
		else
			BG.Debug("Not at vendor", "Deleting")
			-- BG.Delete(itemTable) -- TODO
		end

	elseif IsControlKeyDown() then
		BG.Add("keep", cacheData.item.id)
		BG.Print(format(BG.locale.addedTo_exclude, select(2,GetItemInfo(cacheData.item.id))))

		-- TODO rescan + update UI
		--[[ if _G["BG_ListOptions"] and _G["BG_ListOptions"]:IsVisible() then
			Broker_Garbage_Config:ListOptionsUpdate("exclude")
		end
		BG.UpdateAllCaches(itemTable.itemID)
		BG.UpdateAllDynamicItems() --]]

	elseif IsAltKeyDown() then
		-- TODO: add to force vendor price list
		--[[ BG_GlobalDB.forceVendorPrice[itemTable.itemID] = -1
		BG.Print(format(BG.locale.addedTo_forceVendorPrice, select(2,GetItemInfo(itemTable.itemID))))

		if _G["BG_ListOptions"] and _G["BG_ListOptions"]:IsVisible() then
			Broker_Garbage_Config:ListOptionsUpdate("forceprice")
		end
		BG.UpdateAllCaches(itemTable.itemID)
		BG.UpdateAllDynamicItems() --]]
	end
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
	local color, r, g, b
	if not min then
		return ""
	elseif type(min) == "table" then
		r, g, b = min.r*255, min.g*255, min.b*255
	else
		local percentage = min/(max and max ~= 0 and max or 1)
		if percentage <= 0.5 then
			r, g, b = 255, percentage*510, 0
		else
			r, g, b = 510 - percentage*510, 255, 0
		end
	end

	color = format("|cff%02x%02x%02x", r, g, b)
	return color
end

-- easier syntax for LDB display strings
function BG:FormatString(text)
	local cacheData = BG.containers[ BG.list[1] ]
	if not cacheData.item then
		return ""
	end

	local _, itemLink, _, _, _, _, _, _, _, texture = GetItemInfo(cacheData.item.id)

	-- [junkvalue]
	text = gsub(text, "%[junkvalue%]", BG.FormatMoney(BG.junkValue))

	-- [itemname][itemcount][itemvalue]
	text = gsub(text, "%[itemname%]", (itemLink or ""))
	text = gsub(text, "%[itemicon%]", "|T"..(texture or "")..":0|t")
	text = gsub(text, "%[itemcount%]", cacheData.count)
	text = gsub(text, "%[itemvalue%]", BG.FormatMoney(cacheData.value))

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

	-- return amount and GetCoinTextureString(amount) or ""
end
