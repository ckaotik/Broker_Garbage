local _, BG = ...

-- == LDB Display ==
BG.LDB = LibStub("LibDataBroker-1.1"):NewDataObject("Broker_Garbage", {
	type	= "data source", 
	icon	= "Interface\\Icons\\achievement_bg_returnxflags_def_wsg",
	label	= "Garbage",
	text 	= "",
	
	OnClick = function(...) BG:OnClick(...) end,
	OnEnter = function(...) BG:Tooltip(...) end,
	OnLeave = function() end,	-- needed for e.g. NinjaPanel
})

function BG:UpdateLDB()
	BG.totalBagSpace, BG.totalFreeSlots, BG.specialSlots, BG.freeSpecialSlots = BG:GetBagSlots()
	
	local cheapestItem = BG.cheapestItems[1]
	if cheapestItem and cheapestItem.source ~= BG.IGNORE then
		BG.LDB.text = BG:FormatString(BG_GlobalDB.LDBformat)
		BG.LDB.icon = select(10, GetItemInfo(cheapestItem.itemID))
	else
		BG.LDB.text = BG:FormatString(BG_GlobalDB.LDBNoJunk)
		BG.LDB.icon = "Interface\\Icons\\achievement_bg_returnxflags_def_wsg"
	end
end

function BG:Tooltip(self)
	local colNum = BG_GlobalDB.showSource and 4 or 3
	BG.tt = LibStub("LibQTip-1.0"):Acquire("BG_TT", colNum, "LEFT", "RIGHT", "RIGHT", colNum == 4 and "CENTER" or nil)
	BG.tt:Clear()
   
	-- font settings
	local tooltipHFont = CreateFont("TooltipHeaderFont")
	tooltipHFont:SetFont(GameTooltipText:GetFont(), 14)
	tooltipHFont:SetTextColor(1,1,1)
	
	local tooltipFont = CreateFont("TooltipFont")
	tooltipFont:SetFont(GameTooltipText:GetFont(), 11)
	tooltipFont:SetTextColor(255/255,176/255,25/255)
	
	local lineNum
	-- add header lines
	lineNum = BG.tt:AddLine("Broker_Garbage", "", BG.locale.headerRightClick, colNum == 4 and "" or nil)
	BG.tt:SetCell(lineNum, 1, "Broker_Garbage", tooltipHFont, 2)
	BG.tt:SetCell(lineNum, 3, BG.locale.headerRightClick, tooltipFont, colNum - 2)
   
	-- add info lines
	BG.tt:SetFont(tooltipFont)
	lineNum = BG.tt:AddLine()
	BG.tt:SetCell(lineNum, 1, BG.locale.headerShiftClick, tooltipFont, "LEFT", 2)
	BG.tt:SetCell(lineNum, 3, BG.locale.headerCtrlClick, tooltipFont, "RIGHT", colNum - 2)
	
	lineNum = BG.tt:AddSeparator(2)
	
	-- add clam information
	if IsAddOnLoaded("Broker_Garbage-LootManager") then
		if BG_GlobalDB.openContainers and BG.containerInInventory then
			lineNum = BG.tt:AddLine()
			BG.tt:SetCell(lineNum, 1, BG.locale.openPlease, tooltipFont, "CENTER", colNum)
		end
	end
	if BG.tt:GetLineCount() > lineNum then
		BG.tt:AddSeperator(2)
	end 
	
	-- shows up to n lines of deletable items
	local itemEntry, numLinesShown
	for i = 1, BG_GlobalDB.tooltipNumItems do
		itemEntry = BG.cheapestItems and BG.cheapestItems[i]
		if not itemEntry or itemEntry.source == BG.IGNORE or itemEntry.invalid then
			-- not enough items to display
			numLinesShown = i - 1
			break;
		end

		-- adds lines: itemLink, count, itemPrice, source
		local _, link, _, _, _, _, _, _, _, icon, _ = GetItemInfo(itemEntry.itemID)
		lineNum = BG.tt:AddLine(
			(BG_GlobalDB.showIcon and "|T"..icon..":0|t " or "")..link, 
			itemEntry.count,
			BG.FormatMoney(itemEntry.value))

		if colNum > 3 then
			BG.tt:SetCell(lineNum, 4, BG.tag[itemEntry.source], "RIGHT", 1, 5, 0, 50, 10)
		end
		
		BG.tt:SetLineScript(lineNum, "OnMouseDown", BG.OnClick, itemEntry)
	end
	if numLinesShown == 0 then 
		lineNum = BG.tt:AddLine(BG.locale.noItems, "", BG.locale.increaseTreshold, colNum == 4 and "" or nil)
		BG.tt:SetCell(lineNum, 1, BG.locale.noItems, tooltipFont, "CENTER", colNum)
		lineNum = BG.tt:AddLine("", "", "", colNum == 4 and "" or nil)
		BG.tt:SetCell(lineNum, 1, BG.locale.increaseTreshold, tooltipFont, "CENTER", colNum)
	end
	
	-- add statistics information
	if (BG_GlobalDB.showLost and BG_LocalDB.moneyLostByDeleting ~= 0)
		or (BG_GlobalDB.showEarned and BG_LocalDB.moneyEarned ~= 0) then
		lineNum = BG.tt:AddSeparator(2)
		
		if BG_LocalDB.moneyLostByDeleting ~= 0 then
			lineNum = BG.tt:AddLine(BG.locale.moneyLost, "", BG.FormatMoney(BG_LocalDB.moneyLostByDeleting), colNum == 4 and "" or nil)
			BG.tt:SetCell(lineNum, 1, BG.locale.moneyLost, tooltipFont, "LEFT", 2)
			BG.tt:SetCell(lineNum, 3, BG.FormatMoney(BG_LocalDB.moneyLostByDeleting), tooltipFont, "RIGHT", colNum - 2)
		end
		if BG_LocalDB.moneyEarned ~= 0 then
			lineNum = BG.tt:AddLine(BG.locale.moneyEarned, "", BG.FormatMoney(BG_LocalDB.moneyEarned), colNum == 4 and "" or nil)
			BG.tt:SetCell(lineNum, 1, BG.locale.moneyEarned, tooltipFont, "LEFT", 2)
			BG.tt:SetCell(lineNum, 3, BG.FormatMoney(BG_LocalDB.moneyEarned), tooltipFont, "RIGHT", colNum - 2)
		end
	end
	
	-- Use smart anchoring code to anchor the tooltip to our frame
	BG.tt:SmartAnchorTo(self)
	BG.tt:SetAutoHideDelay(0.25, self)

	-- Show it, et voilà !
	BG.tt:Show()
	BG.tt:UpdateScrolling(BG_GlobalDB.tooltipMaxHeight)
end

-- OnClick function - works for both, the LDB plugin -and- tooltip lines
function BG:OnClick(itemTable, button)
	-- handle LDB clicks seperately
	local LDBclick = false
	if not itemTable or not itemTable.itemID or type(itemTable.itemID) ~= "number" then
		BG.Debug("Click on LDB")
		if (BG.cheapestItems and BG.cheapestItems[1] and not BG.cheapestItems[1].invalid) then
			itemTable = BG.cheapestItems[1]
		end
		LDBclick = true
	end
	
	-- handle different clicks
	if itemTable and IsShiftKeyDown() then
		-- delete or sell item, depending on if we're at a vendor or not
		if BG.isAtVendor and itemTable.value > 0 then
			BG.Debug("At vendor, selling "..itemTable.itemID)
			BG_GlobalDB.moneyEarned	= BG_GlobalDB.moneyEarned + itemTable.value
			BG_LocalDB.moneyEarned 	= BG_LocalDB.moneyEarned + itemTable.value
			BG_GlobalDB.itemsSold 	= BG_GlobalDB.itemsSold + itemTable.count
			
			ClearCursor()
			UseContainerItem(itemTable.bag, itemTable.slot)
		else
			BG.Debug("Not at vendor", "Deleting")
			BG:Delete(itemTable)
		end
	
	elseif itemTable and IsControlKeyDown() then
		-- add to exclude list
		if not BG_LocalDB.exclude[itemTable.itemID] then
			BG_LocalDB.exclude[itemTable.itemID] = 0
		end
		BG.Print(format(BG.locale.addedTo_exclude, select(2,GetItemInfo(itemTable.itemID))))
		
		if BG.optionsLoaded then
			Broker_Garbage_Config:ListOptionsUpdate("exclude")
		end
		BG.UpdateAllCaches(itemTable.itemID)
		
	elseif itemTable and IsAltKeyDown() then
		-- add to force vendor price list
		BG_GlobalDB.forceVendorPrice[itemTable.itemID] = 0
		BG.Print(format(BG.locale.addedTo_forceVendorPrice, select(2,GetItemInfo(itemTable.itemID))))
		
		if BG.optionsLoaded then
			Broker_Garbage_Config:ListOptionsUpdate("forceprice")
		end
		BG.UpdateAllCaches(itemTable.itemID)
		
	-- [TODO] interface options opened -> also load config, if not yet done
	elseif button == "RightButton" then
		if not IsAddOnLoaded("Broker_Garbage-Config") then
			LoadAddOn("Broker_Garbage-Config")
		end
		-- open config
		InterfaceOptionsFrame_OpenToCategory("Broker_Garbage")
		
	elseif LDBclick then
		-- click on the LDB to rescan
	else
		-- no scanning in any other case
		return
	end
	
	BG.ScanInventory()
	BG:UpdateLDB()
end

-- == LDB formating ==
-- returns total bag slots and free bag slots of your whole inventory
function BG:GetBagSlots()
	local numSlots, freeSlots = 0, 0
	local specialSlots, specialFree = 0, 0
	local bagSlots, emptySlots, bagType
	
	for i = 0, 4 do
		bagSlots = GetContainerNumSlots(i) or 0
		emptySlots, bagType = GetContainerNumFreeSlots(i)
		
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
	
	color = string.format("|cff%02x%02x%02x", color[1], color[2], color[3])
	return color
end

-- easier syntax for LDB display strings
function BG:FormatString(text)
	local item
	if not BG.cheapestItems or not BG.cheapestItems[1] then
		item = { itemID = 0, count = 0, value = 0 }
	else
		item = BG.cheapestItems[1]
	end
	
	-- [junkvalue]
	text = string.gsub(text, "%[junkvalue%]", BG.FormatMoney(BG.junkValue))
	
	-- [itemname][itemcount][itemvalue]
	text = string.gsub(text, "%[itemname%]", (select(2,GetItemInfo(item.itemID)) or ""))
	text = string.gsub(text, "%[itemicon%]", "|T"..(select(10,GetItemInfo(item.itemID)) or "")..":0|t")
	text = string.gsub(text, "%[itemcount%]", item.count)
	text = string.gsub(text, "%[itemvalue%]", BG.FormatMoney(item.value))
	
	-- [freeslots][totalslots]
	text = string.gsub(text, "%[freeslots%]", BG.totalFreeSlots + BG.freeSpecialSlots)
	text = string.gsub(text, "%[totalslots%]", BG.totalBagSpace + BG.specialSlots)

	-- [specialfree][specialslots][specialslots][basicslots]
	text = string.gsub(text, "%[specialfree%]", BG.freeSpecialSlots)
	text = string.gsub(text, "%[specialslots%]", BG.specialSlots)
	text = string.gsub(text, "%[basicfree%]", BG.totalFreeSlots)
	text = string.gsub(text, "%[basicslots%]", BG.totalBagSpace)
	
	-- [bagspacecolor][basicbagcolor][specialbagcolor][endcolor]
	text = string.gsub(text, "%[bagspacecolor%]", 
		BG:Colorize(BG.totalFreeSlots + BG.freeSpecialSlots, BG.totalBagSpace + BG.specialSlots))
	text = string.gsub(text, "%[basicbagcolor%]", 
			BG:Colorize(BG.totalFreeSlots, BG.totalBagSpace))
	text = string.gsub(text, "%[specialbagcolor%]", 
			BG:Colorize(BG.freeSpecialSlots, BG.specialSlots))
	text = string.gsub(text, "%[endcolor%]", "|r")
	
	return text
end

-- formats money int values, depending on settings
function BG.FormatMoney(amount, displayMode)
	if not amount then return "" end
	displayMode = displayMode or BG_GlobalDB.showMoney
	
	local signum
	if amount < 0 then 
		signum = "-"
		amount = -amount
	else 
		signum = "" 
	end
	
	local gold   = floor(amount / (100 * 100))
	local silver = math.fmod(floor(amount / 100), 100)
	local copper = math.fmod(floor(amount), 100)
	
	if displayMode == 0 then
		return format(signum.."%i.%i.%i", gold, silver,copper)

	elseif displayMode == 1 then
		return format(signum.."|cffffd700%i|r.|cffc7c7cf%.2i|r.|cffeda55f%.2i|r", gold, silver, copper)

	-- copied from Ara Broker Money
	elseif displayMode == 2 then
		if amount>9999 then
			return format(signum.."|cffeeeeee%i|r|cffffd700g|r |cffeeeeee%.2i|r|cffc7c7cfs|r |cffeeeeee%.2i|r|cffeda55fc|r", floor(amount*.0001), floor(amount*.01)%100, amount%100 )
		
		elseif amount > 99 then
			return format(signum.."|cffeeeeee%i|r|cffc7c7cfs|r |cffeeeeee%.2i|r|cffeda55fc|r", floor(amount*.01), amount%100 )
		
		else
			return format(signum.."|cffeeeeee%i|r|cffeda55fc|r", amount)
		end
	
	-- copied from Haggler
	elseif displayMode == 3 then
		gold         = gold   > 0 and gold  .."|TInterface\\MoneyFrame\\UI-GoldIcon:0|t" or ""
		silver       = silver > 0 and silver.."|TInterface\\MoneyFrame\\UI-SilverIcon:0|t" or ""
		copper       = copper > 0 and copper.."|TInterface\\MoneyFrame\\UI-CopperIcon:0|t" or ""
		-- add spaces if needed
		copper       = (silver ~= "" and copper ~= "") and " "..copper or copper
		silver       = (gold   ~= "" and silver ~= "") and " "..silver or silver
	
		return signum..gold..silver..copper
		
	elseif displayMode == 4 then		
		gold         = gold   > 0 and "|cffeeeeee"..gold  .."|r|cffffd700g|r" or ""
		silver       = silver > 0 and "|cffeeeeee"..silver.."|r|cffc7c7cfs|r" or ""
		copper       = copper > 0 and "|cffeeeeee"..copper.."|r|cffeda55fc|r" or ""
		-- add spaces if needed
		copper       = (silver ~= "" and copper ~= "") and " "..copper or copper
		silver       = (gold   ~= "" and silver ~= "") and " "..silver or silver
	
		return signum..gold..silver..copper
	end
end

-- == Merchant Sell Icon ==
function BG.UpdateRepairButton(forceUpdate)
	local sellIcon = _G["BG_SellIcon"]

	if MerchantFrame.selectedTab ~= 1 or not BG_GlobalDB.showAutoSellIcon then
		if sellIcon then
			sellIcon:Hide()
		end

		if not BG_GlobalDB.showAutoSellIcon then
			if forceUpdate then
				MerchantFrame_UpdateRepairButtons()
			end
		end
	else
		if not sellIcon then
			sellIcon = CreateFrame("Button", "BG_SellIcon", MerchantFrame, "ItemButtonTemplate")
			SetItemButtonTexture(sellIcon, "Interface\\Icons\\achievement_bg_returnxflags_def_wsg")
			
			sellIcon:SetFrameStrata("HIGH")
			sellIcon:SetScript("OnClick", BG.ManualAutoSell)
			sellIcon:SetScript("OnEnter", function(self) 
				GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
				GameTooltip:SetText(BG.junkValue ~= 0 and format(BG.locale.autoSellTooltip, BG.FormatMoney(BG.junkValue)) 
						or BG.locale.reportNothingToSell, nil, nil, nil, nil, true)
			end)
			sellIcon:SetScript("OnLeave", function() GameTooltip:Hide() end)
		end
		
		-- update tooltip value
		SetItemButtonDesaturated(sellIcon, BG.junkValue == 0)

		local iconSize = MerchantRepairAllButton:GetHeight()
		sellIcon:SetHeight(iconSize)
		sellIcon:SetWidth(iconSize)
		_G[sellIcon:GetName().."NormalTexture"]:SetHeight(64/37 * iconSize)
		_G[sellIcon:GetName().."NormalTexture"]:SetWidth(64/37 * iconSize)
		
		if CanGuildBankRepair() then
			MerchantRepairAllButton:SetPoint("BOTTOMRIGHT", MerchantFrame, "BOTTOMLEFT", 115 + 18, 89 + 4);
		else
			MerchantRepairAllButton:SetPoint("BOTTOMRIGHT", MerchantFrame, "BOTTOMLEFT", 172 - 18, 91);
		end
		sellIcon:SetPoint("RIGHT", MerchantRepairAllButton, "LEFT", -4 - 36, 0)
		MerchantRepairText:Hide()
		sellIcon:Show()
	end
end
hooksecurefunc("MerchantFrame_Update", BG.UpdateRepairButton)