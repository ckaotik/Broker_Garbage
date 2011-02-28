--[[ Copyright (c) 2010-2011, ckaotik
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
Neither the name of ckaotik nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. ]]--
local addonName, BG = ...

-- Libraries & setting up the LDB
-- ---------------------------------------------------------
BG.PT = LibStub("LibPeriodicTable-3.1", true)	-- don't scream if LPT isn't present

-- internal variables
local locked = false				-- set to true while selling stuff
local sellValue = 0					-- represents the actual value that we sold stuff for
local repairCost = 0				-- the amount of money that we repaired for
local itemCount = 0                 -- number of items we sold

-- Event Handler
-- ---------------------------------------------------------
local frame = CreateFrame("frame")
local function eventHandler(self, event, arg1, ...)
    BG:Debug("EVENT", event, arg1, ...)
    if event == "ADDON_LOADED" and arg1 == addonName then
		BG:CheckSettings()

	    -- some default values initialization
	    BG.isAtVendor = false
	    BG.sellLog = {}
	    BG.totalBagSpace = 0
	    BG.totalFreeSlots = 0
	    
	    -- inventory database
	    BG.itemsCache = {}
	    BG.clamInInventory = false
	    BG.containerInInventory = false

	    -- full inventory scan to start with
	    BG:ScanInventory()
        frame:UnregisterEvent("ADDON_LOADED")
        
    elseif event == "BAG_UPDATE" then
        if not arg1 or arg1 < 0 or arg1 > 4 then return end
        
        BG:ScanInventoryContainer(arg1)	-- partial inventory scan on the relevant container
        
    elseif event == "MERCHANT_SHOW" then
        BG.isAtVendor = true
        
        BG:UpdateRepairButton()
        local disable = BG.disableKey[BG_GlobalDB.disableKey]
        if not (disable and disable()) then
            BG:AutoRepair()
            BG:AutoSell()
        end
        
    elseif event == "MERCHANT_CLOSED" then
        BG.isAtVendor = false
        
        -- fallback unlock
        if locked then
            BG.isAtVendor = false
            locked = false
            BG:Debug("Fallback Unlock: Merchant window closed, scan lock released.")
        end
    
    elseif event == "AUCTION_HOUSE_CLOSED" then
        -- Update cached auction values in case anything changed
        BG.itemsCache = {}
    
    elseif (locked or repairCost ~=0) and event == "PLAYER_MONEY" then -- regular unlock
        if sellValue ~= 0 and repairCost ~= 0 and ((-1)*sellValue <= repairCost+2 and (-1)*sellValue >= repairCost-2) then
            -- wrong player_money event (resulting from repair, not sell)
            BG:Debug("Not yet ... Waiting for relevant money change.")
            return 
        end
        
        -- print transaction information
        if BG.didSell and BG.didRepair then
            BG:Print(format(BG.locale.sellAndRepair, 
                    BG:FormatMoney(sellValue), 
                    BG:FormatMoney(repairCost), 
                    BG:FormatMoney(sellValue - repairCost)
            ))
        elseif BG.didRepair then
            BG:Print(format(BG.locale.repair, BG:FormatMoney(repairCost)))
        elseif BG.didSell then
            BG.FinishSelling()
        end
        
        BG.didSell, BG.didRepair = nil, nil
        sellValue, itemCount, repairCost = 0, 0, 0
        
        locked = false
        BG:Debug("Regular Unlock: Money received, scan lock released.")
    elseif event == "UI_ERROR_MESSAGE" and arg1 and arg1 == ERR_VENDOR_DOESNT_BUY then
        -- this merchant does not buy things! Revert any statistics changes
        --BG_LocalDB.moneyEarned  = BG_LocalDB.moneyEarned    - sellValue
        --BG_GlobalDB.moneyEarned = BG_GlobalDB.moneyEarned   - sellValue
        --BG_GlobalDB.itemsSold   = BG_GlobalDB.itemsSold     - itemCount
        
        BG.didSell = nil
        sellValue, itemCount = 0, 0
        
        BG:Print(BG.locale.reportCannotSell)
    end	
end

-- register events
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("BAG_UPDATE")
frame:RegisterEvent("MERCHANT_SHOW")
frame:RegisterEvent("MERCHANT_CLOSED")
frame:RegisterEvent("AUCTION_HOUSE_CLOSED")
frame:RegisterEvent("PLAYER_MONEY")
frame:RegisterEvent("UI_ERROR_MESSAGE")

frame:SetScript("OnEvent", eventHandler)

-- LDB Display
-- ---------------------------------------------------------
-- notation mix-up for Broker2FuBar to work
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
    
    if BG.cheapestItems[1] then
        BG.LDB.text = BG:FormatString(BG_GlobalDB.LDBformat)
    else
        BG.LDB.text = BG:FormatString(BG_GlobalDB.LDBNoJunk)
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
        if BG_GlobalDB.openClams and BG.clamInInventory then
            lineNum = BG.tt:AddLine()
            BG.tt:SetCell(lineNum, 1, BG.locale.openClams, tooltipFont, "CENTER", colNum)
        end
    end
    if BG.tt:GetLineCount() > lineNum then
    	BG.tt:AddSeperator(2)
    end 
	
    -- shows up to n lines of deletable items
    local cheapList = BG.cheapestItems or {}
    for i = 1, #cheapList do
        -- adds lines: itemLink, count, itemPrice, source
        local _, link, _, _, _, _, _, _, _, icon, _ = GetItemInfo(cheapList[i].itemID)
        lineNum = BG.tt:AddLine(
            (BG_GlobalDB.showIcon and "|T"..icon..":0|t " or "")..link, 
            cheapList[i].count,
            BG:FormatMoney(cheapList[i].value))

        if colNum > 3 then
	        BG.tt:SetCell(lineNum, 4, BG.tag[cheapList[i].source], "RIGHT", 1, 5, 0, 50, 10)
	    end
        
        BG.tt:SetLineScript(lineNum, "OnMouseDown", BG.OnClick, cheapList[i])
    end
    if #cheapList == 0 then 
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
            lineNum = BG.tt:AddLine(BG.locale.moneyLost, "", BG:FormatMoney(BG_LocalDB.moneyLostByDeleting), colNum == 4 and "" or nil)
            BG.tt:SetCell(lineNum, 1, BG.locale.moneyLost, tooltipFont, "LEFT", 2)
            BG.tt:SetCell(lineNum, 3, BG:FormatMoney(BG_LocalDB.moneyLostByDeleting), tooltipFont, "RIGHT", colNum - 2)
        end
        if BG_LocalDB.moneyEarned ~= 0 then
            lineNum = BG.tt:AddLine(BG.locale.moneyEarned, "", BG:FormatMoney(BG_LocalDB.moneyEarned), colNum == 4 and "" or nil)
            BG.tt:SetCell(lineNum, 1, BG.locale.moneyEarned, tooltipFont, "LEFT", 2)
            BG.tt:SetCell(lineNum, 3, BG:FormatMoney(BG_LocalDB.moneyEarned), tooltipFont, "RIGHT", colNum - 2)
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
        BG:Debug("Click on LDB")
        itemTable = BG.cheapestItems and BG.cheapestItems[1]
        LDBclick = true
    end
    
    -- handle different clicks
    if itemTable and IsShiftKeyDown() then
        -- delete or sell item, depending on if we're at a vendor or not
        if BG.isAtVendor and itemTable.value > 0 then
            BG:Debug("At vendor, selling "..itemTable.itemID)
            BG_GlobalDB.moneyEarned	= BG_GlobalDB.moneyEarned + itemTable.value
            BG_LocalDB.moneyEarned 	= BG_LocalDB.moneyEarned + itemTable.value
            BG_GlobalDB.itemsSold 	= BG_GlobalDB.itemsSold + itemTable.count
            
            ClearCursor()
            UseContainerItem(itemTable.bag, itemTable.slot)
        else
            BG:Debug("Not at vendor", "Deleting")
            BG:Delete(itemTable)
        end
    
    elseif itemTable and IsControlKeyDown() then
        -- add to exclude list
        if not BG_LocalDB.exclude[itemTable.itemID] then
            BG_LocalDB.exclude[itemTable.itemID] = true
        end
        BG:Print(format(BG.locale.addedTo_exclude, select(2,GetItemInfo(itemTable.itemID))))
        BG.itemsCache = {}
        
        if BG.optionsLoaded then
            BG:ListOptionsUpdate("exclude")
        end
        BG:ScanInventory()
        
    elseif itemTable and IsAltKeyDown() then
        -- add to force vendor price list
        BG_GlobalDB.forceVendorPrice[itemTable.itemID] = true
        BG:Print(format(BG.locale.addedTo_forceVendorPrice, select(2,GetItemInfo(itemTable.itemID))))
        BG.itemsCache = {}
        
        if BG.optionsLoaded then
            BG:ListOptionsUpdate("forceprice")
        end
        BG:ScanInventory()
        
    elseif button == "RightButton" then
    	if not IsAddOnLoaded("Broker_Garbage-Config") then
    		LoadAddOn("Broker_Garbage-Config")
    	end
        -- open config
        InterfaceOptionsFrame_OpenToCategory("Broker_Garbage")
        
    elseif LDBclick then
        -- click on the LDB to rescan
        BG:ScanInventory()
    end
    
    BG:UpdateLDB()
end

-- Sell Icon
-- ---------------------------------------------------------
function BG:UpdateRepairButton(...)
    if not BG_GlobalDB.showAutoSellIcon then
        if _G["BG_SellIcon"] then
            BG_SellIcon:Hide()
        end
        -- re-position all the buttons
        MerchantRepairAllButton:ClearAllPoints()
        MerchantGuildBankRepairButton:ClearAllPoints()
        MerchantGuildBankRepairButton:SetPoint("LEFT", MerchantRepairAllButton, "RIGHT", 4, 0)
        MerchantFrame_UpdateRepairButtons()
        return
    end
    
    local sellIcon
    -- show auto-sell icon on vendor frame
    if not _G["BG_SellIcon"] then
        sellIcon = CreateFrame("Button", "BG_SellIcon", MerchantFrame, "ItemButtonTemplate")
        SetItemButtonTexture(sellIcon, "Interface\\Icons\\achievement_bg_returnxflags_def_wsg")
        sellIcon:SetFrameStrata("HIGH")
        sellIcon:SetScript("OnClick", BG.AutoSell)
        sellIcon:SetScript("OnEnter", function(self) 
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            local tiptext
            local junkValue = 0
            for i = 0, 4 do
                junkValue = junkValue + (BG.toSellValue[i] or 0)
            end
            if junkValue ~= 0 then
                tiptext = format(BG.locale.autoSellTooltip, BG:FormatMoney(junkValue))
            else
                tiptext = BG.locale.reportNothingToSell
            end
            GameTooltip:SetText(tiptext, nil, nil, nil, nil, true)
        end)
        sellIcon:SetScript("OnLeave", function() GameTooltip:Hide() end)
    else
        sellIcon = _G["BG_SellIcon"]
    end

    if MerchantBuyBackItemItemButton:IsVisible() then
        if CanMerchantRepair() then
            if CanGuildBankRepair() then    -- move all the default icons further to the right. blizz anchors are weird -.-
                MerchantGuildBankRepairButton:ClearAllPoints()
                MerchantGuildBankRepairButton:SetPoint("RIGHT", MerchantBuyBackItemItemButton, "LEFT", -22, 0)
                MerchantRepairAllButton:ClearAllPoints()
                MerchantRepairAllButton:SetPoint("RIGHT", MerchantGuildBankRepairButton, "LEFT", -4, 0)
            end
            sellIcon:SetWidth(MerchantRepairAllButton:GetWidth())
            sellIcon:SetHeight(MerchantRepairAllButton:GetHeight())
            sellIcon:SetPoint("RIGHT", MerchantRepairItemButton, "LEFT", -4, 0)
        else
            sellIcon:SetWidth(MerchantBuyBackItemItemButton:GetWidth())
            sellIcon:SetHeight(MerchantBuyBackItemItemButton:GetHeight())
            sellIcon:SetPoint("RIGHT", MerchantBuyBackItemItemButton, "LEFT", -18, 0)
        end
        MerchantRepairText:Hide()
        sellIcon:Show()
    else
        sellIcon:Hide()
    end
    
    local junkValue = 0
    for i = 0, 4 do
        junkValue = junkValue + (BG.toSellValue[i] or 0)
    end
    SetItemButtonDesaturated(_G["BG_SellIcon"], junkValue == 0)
end
hooksecurefunc("MerchantFrame_Update", BG.UpdateRepairButton)

-- Inventory Scanning
-- ---------------------------------------------------------
-- only used as a shortcut to cache any unknown item in the whole inventory
function BG:ScanInventory(resetCache)
	if resetCache then
		BG.itemsCache = {}
	end
    for container = 0,4 do
        BG:ScanInventoryContainer(container)
    end
    if BG.isAtVendor then
        BG:UpdateRepairButton()
    end
end

-- scans your inventory bags for possible junk items and updates LDB display
function BG:ScanInventoryContainer(container)
    -- container doesn't exist or cannot be scanned
    if not GetContainerNumSlots(container) then return end
    
    local numSlots = GetContainerNumSlots(container)
    BG.toSellValue[container] = 0
    
    for slot = 1, numSlots do
        local itemID = GetContainerItemID(container,slot)
        local item = BG:GetCached(itemID)
        if itemID and item then
            -- update toSellValue
            if item.classification == BG.SELL or 
                (item.classification == BG.UNUSABLE and BG_GlobalDB.sellNotWearable and item.quality <= BG_GlobalDB.sellNWQualityTreshold) or
                (BG_GlobalDB.autoSellIncludeItems and item.classification == BG.INCLUDE) or
                (item.classification ~= BG.EXCLUDE and item.quality == 0) then
                
                local itemCount = select(2, GetContainerItemInfo(container, slot))
                BG.toSellValue[container] = BG.toSellValue[container] + item.value * itemCount
            end
        end
    end
    
    BG:GetCheapest()
    BG:UpdateLDB()
end

-- Item Value Calculation
-- ---------------------------------------------------------
-- calculates the value of a stack/partial stack of an item
function BG:GetItemValue(item, count)
    local itemID
    if item and type(item) == "number" then
        itemID = item
    elseif item and type(item) == "string" then
        itemID = BG:GetItemID(item)
    else
        -- invalid argument
        BG:Debug("GetItemValue: Invalid argument "..(item or "<none>").."supplied.")
        return nil
    end
    
    if BG:GetCached(itemID) then
        return BG:GetCached(itemID).value * (count or 1)
    else
        local value = BG:GetSingleItemValue(item)
        return value and value * (count or 1) or nil
    end
end

-- returns which of the items values is the highest (value, type)
function BG:GetSingleItemValue(item)
	if not item then return nil end
	local hasData, itemLink, itemQuality, itemLevel, _, _, _, _, itemType, _, vendorPrice = GetItemInfo(item)
	
	BG:Debug("GetSingleItemValue("..(item or "?").."), "..(hasData or "no data"))
	hasData, itemLink, itemQuality, itemLevel, _, _, _, _, itemType, _, vendorPrice = GetItemInfo(item)
	if not hasData then		-- invalid argument
       	BG:Debug("Error! GetSingleItemValue: Failed on "..(itemLink or item or "<unknown>").."."..(hasData or "no data"))
       	return nil
	end

	-- ignore AH prices for gray items and soulbound items
    if not itemQuality or itemQuality == 0 or BG:IsItemSoulbound(itemLink) then
        return vendorPrice, vendorPrice and BG.VENDOR
    end
	
	BG.auctionAddon = nil	-- reset this!
    local disenchantPrice, auctionPrice, source = 0, 0, nil
	local canDE = BG:CanDisenchant(itemLink)

    -- calculate auction value: choose the highest auction/disenchant value
    if IsAddOnLoaded("Auctionator") then
        BG.auctionAddon = "Auctionator"
        auctionPrice = Atr_GetAuctionBuyout(itemLink) or 0
        disenchantPrice = canDE and Atr_GetDisenchantValue(itemLink)
	end
	
	if IsAddOnLoaded("Auc-Advanced") then	-- uses Market Value in any case
        BG.auctionAddon = (BG.auctionAddon and BG.auctionAddon..", " or "") .. "Auc-Advanced"
        auctionPrice = math.max(auctionPrice, AucAdvanced.API.GetMarketValue(itemLink))
        
        if IsAddOnLoaded("Enchantrix") then
            disenchantPrice = canDE and math.max(disenchantPrice or 0, select(3, Enchantrix.Storage.GetItemDisenchantTotals(itemLink)) or 0)
        end
    end
    
    if IsAddOnLoaded("AuctionLite") then
        BG.auctionAddon = (BG.auctionAddon and BG.auctionAddon..", " or "") .. "AuctionLite"
        auctionPrice = math.max(auctionPrice, AuctionLite:GetAuctionValue(itemLink) or 0)
        disenchantPrice = canDE and math.max(disenchantPrice or 0, AuctionLite:GetDisenchantValue(itemLink) or 0)
	end
        
    if IsAddOnLoaded("WOWEcon_PriceMod") then
        BG.auctionAddon = (BG.auctionAddon and BG.auctionAddon..", " or "") .. "WoWecon"
        auctionPrice = math.max(auctionPrice, Wowecon.API.GetAuctionPrice_ByLink(itemLink) or 0)
        
        if canDE and not disenchantPrice then
            local tmpPrice = 0
            local DEData = Wowecon.API.GetDisenchant_ByLink(itemLink)
            for i, data in pairs(DEData) do	-- [1] = item link, [2] = quantity, [3] = chance
                tmpPrice = tmpPrice + ((Wowecon.API.GetAuctionPrice_ByLink(data[1] or 0)) * data[2] * data[3])
            end
            disenchantPrice = math.max(disenchantPrice or 0, math.floor(tmpPrice or 0))
        end
	end

	-- last chance to get auction values
	if GetAuctionBuyout then
		BG.auctionAddon = BG.auctionAddon or BG.locale.unknown
		auctionPrice = math.max(auctionPrice, GetAuctionBuyout(itemLink) or 0)
	else
		BG.auctionAddon = BG.auctionAddon or BG.locale.na
	end
	if GetDisenchantValue then
		disenchantPrice = canDE and math.max(disenchantPrice or 0, GetDisenchantValue(itemLink) or 0)
	end

    -- simply return the highest value price
    local maximum = math.max((disenchantPrice or 0), (auctionPrice or 0), (vendorPrice or 0))
    if vendorPrice and maximum == vendorPrice then
        return vendorPrice, BG.VENDOR
    elseif auctionPrice and maximum == auctionPrice then
        return auctionPrice, BG.AUCTION
    elseif disenchantPrice and maximum == disenchantPrice then
        return disenchantPrice, BG.DISENCHANT
    else
        return nil, nil
    end
end

-- finds all occurences of the given item and returns the least important location
function BG:FindSlotToDelete(itemID, ignoreFullStack)
    local locations = {}
    local _, _, _, _, _, _, _, maxStack = GetItemInfo(itemID)
    
    local numSlots, freeSlots, ratio, bagType
    for container = 0,4 do
        numSlots = GetContainerNumSlots(container)
        freeSlots, bagType = GetContainerFreeSlots(container)
        freeSlots = freeSlots and #freeSlots or 0
        
        if numSlots then
            ratio = freeSlots/numSlots
            
            for slot = 1, numSlots do
                local _,count,_,_,_,_,link = GetContainerItemInfo(container, slot)
                
                if link and BG:GetItemID(link) == itemID then
                    if not ignoreFullStack or (ignoreFullStack and count < maxStack) then
                        -- found one
                        table.insert(locations, {
                            slot = slot, 
                            bag = container, 
                            count = count, 
                            ratio = ratio, 
                            bagType = (bagType or 0)
                        })
                    end
                end
            end
        end
    end
    
    -- recommend the location with the largest count or ratio that is NOT a specialty bag
    table.sort(locations, function(a,b)
        if a.bagType ~= b.bagType then
            return a.bagType == 0
        else
            if a.count == b.count then
                return a.ratio > b.ratio
            else
                return a.count < b.count
            end
        end
    end)
    return locations
end

-- deletes the item in a given location of your bags
function BG:Delete(item, position)
    local itemID, itemCount, cursorType
    
    if type(item) == "string" and item == "cursor" then
        -- item on the cursor
        cursorType, itemID = GetCursorInfo()
        if cursorType ~= "item" then
            BG:Print("Error! Trying to delete an item from the cursor, but there is none.")
            return
        end
        itemCount = position	-- second argument is the item count

    elseif type(item) == "table" then
        -- item given as an itemTable
        itemID = item.itemID
        position = {item.bag, item.slot}
    
    elseif type(item) == "number" then
        -- item given via its itemID
        itemID = item
    
    elseif item then
        -- item given via its itemLink
        itemID = BG:GetItemID(item)
    else
        BG:Print("Error! BG:Delete() no argument supplied.")
        return
    end

    -- security check
    local bag = position[1] or item.bag
    local slot = position[2] or item.slot
    if not cursorType and (not (bag and slot) or GetContainerItemID(bag, slot) ~= itemID) then
        BG:Print("Error! Item to be deleted is not the expected item.")
        BG:Debug("I got these parameters:", item, bag, slot)
        return
    end
    
    -- make sure there is nothing unwanted on the cursor
    if not cursorType then
        ClearCursor()
    end
    
    _, itemCount = GetContainerItemInfo(bag, slot)
    
    -- actual deleting happening after this
    securecall(PickupContainerItem, bag, slot)
    securecall(DeleteCursorItem)					-- comment this line to prevent item deletion
    
    local itemValue = (BG:GetCached(itemID).value or 0) * itemCount	-- if an item is unknown to the cache, statistics will not change
    -- statistics
    BG_GlobalDB.itemsDropped 		= BG_GlobalDB.itemsDropped + itemCount
    BG_GlobalDB.moneyLostByDeleting	= BG_GlobalDB.moneyLostByDeleting + itemValue
    BG_LocalDB.moneyLostByDeleting 	= BG_LocalDB.moneyLostByDeleting + itemValue
    
    local _, itemLink = GetItemInfo(itemID)
    BG:Print(format(BG.locale.itemDeleted, itemLink, itemCount))
end

-- Find Cheap Items
-- ---------------------------------------------------------
local function TableSort(a, b)
    -- put included items even prior to forced vendor price items
    if (a.source == b.source) or (a.source ~= BG.INCLUDE and b.source ~= BG.INCLUDE) or BG_GlobalDB.useRealValues then
        if a.value == b.value then
            if a.itemID == b.itemID then
                return a.count < b.count
            else
                return a.itemID < b.itemID
            end
        else
            return a.value < b.value
        end
    else 
        return a.source == BG.INCLUDE
    end
end

-- returns the n cheapest items in your bags in a table
function BG:GetCheapest(number)
    if not number then number = BG_GlobalDB.tooltipNumItems end
    local cheapestItems = {}
    local numSlots, count, quality, canOpen, itemLink, itemID, stackSize
    local item, maxValue, insert
    
    BG.clamInInventory = false
    BG.containerInInventory = false
    
    for container = 0, 4 do
        numSlots = GetContainerNumSlots(container)
        if numSlots then
            for slot = 1, numSlots do
                -- "Gather Information"
                _, count, _, _, _, canOpen, itemLink = GetContainerItemInfo(container, slot)
                itemID = itemLink and BG:GetItemID(itemLink)
				item = itemID and BG:GetCached(itemID)
                
                if item then
                    insert = true
                    local value = count * item.value
                    local vendorValue = select(11, GetItemInfo(itemID)) * count
                    local classification = item.classification
                    
                    -- remember lootable items
                    if canOpen or (item and item.isClam) then
                        if item.isClam then
                            BG.clamInInventory = true
                        else
                            BG.containerInInventory = true
                        end
                    end
                    
                    -- handle different types of items
                    if not item or item.classification == BG.EXCLUDE then
                        insert = false
                    
                    elseif item.classification == BG.LIMITED then
                        local saveStacks = ceil(item.limit/(item.stackSize or 1))
                        local locations = BG:FindSlotToDelete(itemID)
                        
                        if #locations > saveStacks then
                            local itemCount = 0
                            
                            for i = #locations, 1, -1 do
                                if itemCount < item.limit then
                                    -- keep this amount
                                    itemCount = itemCount + locations[i].count
                                    if locations[i].bag == container and locations[i].slot == slot then
                                        insert = false
                                    end
                                else
                                    break;
                                end
                            end
                        else
                            insert = false
                        end
                        if insert then
                            -- treat like a regular include item
                            value = BG_GlobalDB.useRealValues and value or 0
                        end
                    
                    elseif item.classification == BG.DISENCHANT or item.classification == BG.AUCTION then
                        -- check if item is really soulbound
                        if BG:IsItemSoulbound(itemID, container, slot) then
                            -- use vendor price instead
                            value = vendorValue
                            classification = BG.VENDOR
                        end
                    
                    elseif item.classification == BG.UNUSABLE then
                        if not BG_GlobalDB.sellNotWearable or item.quality > BG_GlobalDB.sellNWQualityTreshold then
                            insert = false
                        end
                    
                    elseif item.classification == BG.INCLUDE then
                        value = BG_GlobalDB.useRealValues and value or 0
                        
                    elseif item.classification == BG.SELL or item.classification == BG.VENDOR then
                        value = vendorValue
                    end
                    
                    if item.quality > BG_GlobalDB.dropQuality and 
                        not (classification == BG.INCLUDE or classification == BG.SELL) then
                        -- include and vendor list items should always be displayed
                        insert = false
                    
                    elseif value == 0 and BG_GlobalDB.hideZeroValue and classification == BG.VENDOR then
                        insert = false
                    end	
                    
                    -- insert data
                    if insert then
                        maxValue = cheapestItems[number] and cheapestItems[number].value or nil
                        if not maxValue then
                            tinsert(cheapestItems, {
                                itemID = itemID,
                                bag = container,
                                slot = slot,
                                count = count,
                                value = value,
                                source = classification,
                            })
                        elseif value < maxValue then
                            -- update last item
                            cheapestItems[number].itemID = itemID
                            cheapestItems[number].bag = container
                            cheapestItems[number].slot = slot
                            cheapestItems[number].count = count
                            cheapestItems[number].value = value
                            cheapestItems[number].source = classification
                        end
                        table.sort(cheapestItems, TableSort)
                    end
                end
            end
        end
    end
    
    BG.cheapestItems = cheapestItems
    return cheapestItems
end


-- special functionality
-- ---------------------------------------------------------
-- when at a merchant this will clear your bags of junk (gray quality) and items on your autoSellList
function BG:AutoSell()
    if not BG.isAtVendor then
        return
    end
    
    if self == _G["BG_SellIcon"] then
        BG:Debug("AutoSell was triggered by a click on Sell Icon.")
    
    elseif not BG_GlobalDB.autoSellToVendor then
        -- we're not supposed to sell. jump out
        return
    end
    
    BG.PrepareAutoSell()
    BG.GatherSellStatistics()
    BG.FinishSelling(self == _G["BG_SellIcon"])
end

function BG.PrepareAutoSell()
    local sell, classification
    local item, itemID, value, count, numSlots
    
    wipe(BG.sellLog)    -- reset data for refilling
    
    sellValue = 0
    for container = 0, 4 do
        numSlots = GetContainerNumSlots(container)
        if numSlots then
            for slot = 1, numSlots do
                _, count, _, _, _, _, itemLink = GetContainerItemInfo(container, slot)
                itemID 	= BG:GetItemID(itemLink)
                
                if itemLink and BG:GetCached(itemID) then
                    item 	= BG:GetCached(itemID)
                    value 	= item.value        -- single item value
                    
                    sell = false
                    -- various cases that have us sell this item
                    if item.classification == BG.UNUSABLE
                        and BG_GlobalDB.sellNotWearable and item.quality <= BG_GlobalDB.sellNWQualityTreshold then 
                        sell = true
                    elseif item.classification == BG.OUTDATED and BG_GlobalDB.sellOldGear and item.quality <= BG_GlobalDB.sellNWQualityTreshold then
                        sell = true
                    elseif item.classification == BG.INCLUDE and BG_GlobalDB.autoSellIncludeItems then
                        sell = true
                    elseif item.classification == BG.SELL then
                        sell = true
                    elseif item.classification ~= BG.EXCLUDE and item.quality == 0 then
                        sell = true
                    end
                    
                    -- mark item for selling
                    if value ~= 0 and sell then
                        if not locked then					
                            BG:Debug("Inventory scans locked")
                            locked = true
                        end
                        
                        BG:Debug("Selling", item, container, slot)

                        ClearCursor()
                        UseContainerItem(container, slot)
                        table.insert(BG.sellLog, {container = container, slot = slot, item = itemLink, count = count, value = value})
                    end
                end
            end
        end
    end
    if locked then BG.didSell = true end    -- otherwise we didn't sell anything
end

function BG.GatherSellStatistics()
    if not BG.didSell then return end       -- in case something went wrong, e.g. merchant doesn't buy
    sellValue, itemCount = 0, 0
    for _, data in ipairs(BG.sellLog) do
        if BG_GlobalDB.showSellLog then
        	BG:Print(BG.locale.sellItem, data.item, data.count, BG:FormatMoney(data.count * data.value))
        end
        
        sellValue = sellValue + (data.count * data.value)
        itemCount = itemCount + data.count
    end

    -- update statistics
    BG_LocalDB.moneyEarned  = BG_LocalDB.moneyEarned    + sellValue
    BG_GlobalDB.moneyEarned = BG_GlobalDB.moneyEarned   + sellValue
    BG_GlobalDB.itemsSold   = BG_GlobalDB.itemsSold     + itemCount
end

function BG.FinishSelling(isUserStarted)
    -- create output if needed
    if isUserStarted then
        if sellValue == 0 and BG_GlobalDB.reportNothingToSell then
            BG:Print(BG.locale.reportNothingToSell)
        elseif sellValue ~= 0 and not BG_GlobalDB.autoSellToVendor then
            BG:Print(format(BG.locale.sell, BG:FormatMoney(sellValue)))
        end
        _G["BG_SellIcon"]:GetNormalTexture():SetDesaturated(true)
    end
    
    BG:UpdateRepairButton()
end

-- automatically repair at a vendor
function BG:AutoRepair()
    if BG_GlobalDB.autoRepairAtVendor and CanMerchantRepair() then
        repairCost = GetRepairAllCost()
        
        if repairCost > 0 and not BG_LocalDB.neverRepairGuildBank and CanGuildBankRepair()
        	and (GetGuildBankWithdrawMoney() == -1 or GetGuildBankWithdrawMoney() >= repairCost) then
            -- guild repair if we're allowed to and the user wants it
            RepairAllItems(1)
            BG.didRepair = true
        elseif repairCost > 0 and GetMoney() >= repairCost then
            -- not enough allowance to guild bank repair, pay ourselves
            RepairAllItems(0)
            BG.didRepair = true
        elseif repairCost > 0 then
            -- oops. give us your moneys!
            BG:Print(format(BG.locale.couldNotRepair, BG:FormatMoney(repairCost)))
        end
    else
        repairCost = 0
    end
end