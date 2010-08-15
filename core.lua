--[[ Copyright (c) 2010, ckaotik
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
Neither the name of ckaotik nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. ]]--
_, BrokerGarbage = ...

-- Libraries & setting up the LDB
-- ---------------------------------------------------------
BrokerGarbage.PT = LibStub("LibPeriodicTable-3.1", true)	-- don't scream if LPT isn't present

-- notation mix-up for Broker2FuBar to work
local LDB = LibStub("LibDataBroker-1.1"):NewDataObject("Broker_Garbage", {
    type	= "data source", 
    icon	= "Interface\\Icons\\achievement_bg_returnxflags_def_wsg",
    label	= "Garbage",
    text 	= "",
    
    OnClick = function(...) BrokerGarbage:OnClick(...) end,
    OnEnter = function(...) BrokerGarbage:Tooltip(...) end,
})

local function UpdateLDB()
    BrokerGarbage.totalBagSpace, BrokerGarbage.totalFreeSlots = BrokerGarbage:GetBagSlots()
    
    if BrokerGarbage.cheapestItems[1] then
        LDB.text = BrokerGarbage:FormatString(BG_GlobalDB.LDBformat)
    else
        BrokerGarbage.cheapestItems[1] = nil
        LDB.text = BrokerGarbage:FormatString(BG_GlobalDB.LDBNoJunk)
    end
end

-- internal variables
BrokerGarbage.optionsModules = {}	-- used for ordering/showing entries in the options panel
local locked = false				-- set to true while selling stuff
local sellValue = 0					-- represents the actual value that we sold stuff for
local cost = 0						-- the amount of money that we repaired for

-- Event Handler
-- ---------------------------------------------------------
local frame = CreateFrame("frame")
local function eventHandler(self, event, ...)
    if event == "PLAYER_ENTERING_WORLD" then
        BrokerGarbage:CheckSettings()

        -- some default values initialization
        BrokerGarbage.isAtVendor = false
        BrokerGarbage.totalBagSpace = 0
        BrokerGarbage.totalFreeSlots = 0

        -- inventory database
        BrokerGarbage.itemsCache = {}
        BrokerGarbage.clamInInventory = false
        BrokerGarbage.containerInInventory = false
        
        -- full inventory scan to start with
        BrokerGarbage:ScanInventory()
        frame:UnregisterEvent("PLAYER_ENTERING_WORLD")
        
    elseif event == "BAG_UPDATE" then
        if arg1 < 0 or arg1 > 4 then return end
        
        BrokerGarbage:ScanInventoryContainer(arg1)	-- partial inventory scan on the relevant container
        
    elseif event == "MERCHANT_SHOW" then
        BrokerGarbage.isAtVendor = true
        
        BrokerGarbage:UpdateRepairButton()
        local disable = BrokerGarbage.disableKey[BG_GlobalDB.disableKey]
        if not (disable and disable()) then
            BrokerGarbage:AutoRepair()
            BrokerGarbage:AutoSell()
        end
        
    elseif event == "MERCHANT_CLOSED" then
        BrokerGarbage.isAtVendor = false
        
        -- fallback unlock
        if locked then
            BrokerGarbage.isAtVendor = false
            locked = false
            BrokerGarbage:Debug("Fallback Unlock: Merchant window closed, scan lock released.")
        end
    
    elseif event == "AUCTION_HOUSE_CLOSED" then
        -- Update cache auction values if needed
        BrokerGarbage.itemsCache = {}
    
    elseif (locked or cost ~=0) and event == "PLAYER_MONEY" then -- regular unlock
        -- wrong player_money event (resulting from repair, not sell)
        if sellValue ~= 0 and cost ~= 0 and ((-1)*sellValue <= cost+2 and (-1)*sellValue >= cost-2) then 
            BrokerGarbage:Debug("Not yet ... Waiting for actual money change.")
            return 
        end
        
        if sellValue ~= 0 and cost ~= 0 and BG_GlobalDB.autoRepairAtVendor and BG_GlobalDB.autoSellToVendor then
            -- repair & auto-sell
            BrokerGarbage:Print(format(BrokerGarbage.locale.sellAndRepair, 
                    BrokerGarbage:FormatMoney(sellValue), 
                    BrokerGarbage:FormatMoney(cost), 
                    BrokerGarbage:FormatMoney(sellValue - cost)
            ))
            sellValue = 0
            cost = 0
            
        elseif cost ~= 0 and BG_GlobalDB.autoRepairAtVendor then
            -- repair only
            BrokerGarbage:Print(format(BrokerGarbage.locale.repair, BrokerGarbage:FormatMoney(cost)))
            cost = 0
            
        elseif sellValue ~= 0 and BG_GlobalDB.autoSellToVendor then
            -- autosell only
            BrokerGarbage:Print(format(BrokerGarbage.locale.sell, BrokerGarbage:FormatMoney(sellValue)))
            sellValue = 0
        
        end
        
        locked = false
        BrokerGarbage:Debug("Regular Unlock: Money received, scan lock released.")
    end	
end

-- register events
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("BAG_UPDATE")
frame:RegisterEvent("MERCHANT_SHOW")
frame:RegisterEvent("MERCHANT_CLOSED")
frame:RegisterEvent("AUCTION_HOUSE_CLOSED")
frame:RegisterEvent("PLAYER_MONEY")

frame:SetScript("OnEvent", eventHandler)

-- Sell Icon
-- ---------------------------------------------------------
function BrokerGarbage:UpdateRepairButton(...)
    if not BG_GlobalDB.showAutoSellIcon then
        if _G["BrokerGarbage_SellIcon"] then
            BrokerGarbage_SellIcon:Hide()
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
    if not _G["BrokerGarbage_SellIcon"] then
        sellIcon = CreateFrame("Button", "BrokerGarbage_SellIcon", MerchantFrame)
        sellIcon:SetFrameStrata("DIALOG")   -- sellIcon:Raise()
        sellIcon:SetWidth(36); sellIcon:SetHeight(36)
        sellIcon:SetNormalTexture("Interface\\Icons\\achievement_bg_returnxflags_def_wsg")
        sellIcon:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square")
        sellIcon:SetScript("OnClick", BrokerGarbage.AutoSell)
        sellIcon:SetScript("OnEnter", function(self) 
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            local tiptext
            local junkValue = 0
            for i = 0, 4 do
                junkValue = junkValue + (BrokerGarbage.toSellValue[i] or 0)
            end
            if junkValue ~= 0 then
                tiptext = format(BrokerGarbage.locale.autoSellTooltip, BrokerGarbage:FormatMoney(junkValue))
            else
                tiptext = BrokerGarbage.locale.reportNothingToSell
            end
            GameTooltip:SetText(tiptext, nil, nil, nil, nil, true)
        end)
        sellIcon:SetScript("OnLeave", function() GameTooltip:Hide() end)
    else
        sellIcon = _G["BrokerGarbage_SellIcon"]
    end

    if MerchantBuyBackItemItemButton:IsVisible() then
        if CanMerchantRepair() then
            if CanGuildBankRepair() then    -- move all the default icons further to the right. blizz anchors weird -.-
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
        junkValue = junkValue + (BrokerGarbage.toSellValue[i] or 0)
    end
    if junkValue ~= 0 then
        _G["BrokerGarbage_SellIcon"]:GetNormalTexture():SetDesaturated(false)
    else
        _G["BrokerGarbage_SellIcon"]:GetNormalTexture():SetDesaturated(true)
    end
end
hooksecurefunc("MerchantFrame_Update", BrokerGarbage.UpdateRepairButton)

-- Tooltip
-- ---------------------------------------------------------
function BrokerGarbage:Tooltip(self)
    local colNum, lineNum
    if BG_GlobalDB.showSource then
        BrokerGarbage.tt = LibStub("LibQTip-1.0"):Acquire("BrokerGarbage_TT", 4, "LEFT", "RIGHT", "RIGHT", "CENTER")
        colNum = 4
    else
        BrokerGarbage.tt = LibStub("LibQTip-1.0"):Acquire("BrokerGarbage_TT", 3, "LEFT", "RIGHT", "RIGHT")
        colNum = 3
    end
    BrokerGarbage.tt:Clear()
   
    -- font settings
    local tooltipHFont = CreateFont("TooltipHeaderFont")
    tooltipHFont:SetFont(GameTooltipText:GetFont(), 14)
    tooltipHFont:SetTextColor(1,1,1)
    
    local tooltipFont = CreateFont("TooltipFont")
    tooltipFont:SetFont(GameTooltipText:GetFont(), 11)
    tooltipFont:SetTextColor(255/255,176/255,25/255)
    
    -- add header lines
    BrokerGarbage.tt:SetHeaderFont(tooltipHFont)
    BrokerGarbage.tt:AddHeader('Broker_Garbage', '', BrokerGarbage.locale.headerRightClick)
   
    -- add info lines
    BrokerGarbage.tt:SetFont(tooltipFont)
    BrokerGarbage.tt:AddLine(BrokerGarbage.locale.headerShiftClick, '', BrokerGarbage.locale.headerCtrlClick)
    BrokerGarbage.tt:AddSeparator(2)
    
    -- add clam information
    if IsAddOnLoaded("Broker_Garbage-LootManager") and (
        (BGLM_GlobalDB.openContainers and BrokerGarbage.containerInInventory) or 
        (BGLM_GlobalDB.openClams and BrokerGarbage.clamInInventory)) then
        
        if BGLM_GlobalDB.openContainers and BrokerGarbage.containerInInventory then
            lineNum = BrokerGarbage.tt:AddLine()
            BrokerGarbage.tt:SetCell(lineNum, 1, BrokerGarbage_LootManager.locale.openPlease, tooltipFont, "CENTER", colNum)
        end
        if BGLM_GlobalDB.openClams and BrokerGarbage.clamInInventory then
            lineNum = BrokerGarbage.tt:AddLine()
            BrokerGarbage.tt:SetCell(lineNum, 1, BrokerGarbage_LootManager.locale.openClams, tooltipFont, "CENTER", colNum)
        end
        BrokerGarbage.tt:AddSeparator(2)
    end
    
    -- shows up to n lines of deletable items
    local cheapList = BrokerGarbage.cheapestItems or {}
    for i = 1, #cheapList do
        -- adds lines: itemLink, count, itemPrice, source
        lineNum = BrokerGarbage.tt:AddLine(
            select(2,GetItemInfo(cheapList[i].itemID)), 
            cheapList[i].count,
            BrokerGarbage:FormatMoney(cheapList[i].value),
            (BG_GlobalDB.showSource and BrokerGarbage.tag[cheapList[i].source] or nil))
        BrokerGarbage.tt:SetLineScript(lineNum, "OnMouseDown", BrokerGarbage.OnClick, cheapList[i])
    end
    if lineNum == nil then 
        BrokerGarbage.tt:AddLine(BrokerGarbage.locale.noItems, '', BrokerGarbage.locale.increaseTreshold)
    end
    
    -- add statistics information
    if (BG_GlobalDB.showLost and BG_LocalDB.moneyLostByDeleting ~= 0)
        or (BG_GlobalDB.showEarned and BG_LocalDB.moneyEarned ~= 0) then
        BrokerGarbage.tt:AddSeparator(2)
        
        if BG_LocalDB.moneyLostByDeleting ~= 0 then
            BrokerGarbage.tt:AddLine(BrokerGarbage.locale.moneyLost, '', BrokerGarbage:FormatMoney(BG_LocalDB.moneyLostByDeleting))
        end
        if BG_LocalDB.moneyEarned ~= 0 then
            BrokerGarbage.tt:AddLine(BrokerGarbage.locale.moneyEarned, '', BrokerGarbage:FormatMoney(BG_LocalDB.moneyEarned))
        end
    end
    
    -- Use smart anchoring code to anchor the tooltip to our frame
    BrokerGarbage.tt:SmartAnchorTo(self)
    BrokerGarbage.tt:SetAutoHideDelay(0.25, self)

    -- Show it, et voilà !
    BrokerGarbage.tt:Show()
    BrokerGarbage.tt:UpdateScrolling(BG_GlobalDB.tooltipMaxHeight)
end

-- onClick function - works for both, the LDB plugin -and- tooltip lines
function BrokerGarbage:OnClick(itemTable, button)	
    -- handle LDB clicks seperately
    local LDBclick = false
    if not itemTable.itemID or type(itemTable.itemID) ~= "number" then
        BrokerGarbage:Debug("Click on LDB")
        itemTable = BrokerGarbage.cheapestItems[1]
        LDBclick = true
    end
    
    -- handle different clicks
    if itemTable and IsShiftKeyDown() then
        -- delete or sell item, depending on if we're at a vendor or not
        if BrokerGarbage.isAtVendor and itemTable.value > 0 then
            BrokerGarbage:Debug("At vendor, selling "..itemTable.itemID)
            BG_GlobalDB.moneyEarned	= BG_GlobalDB.moneyEarned + itemTable.value
            BG_LocalDB.moneyEarned 	= BG_LocalDB.moneyEarned + itemTable.value
            BG_GlobalDB.itemsSold 	= BG_GlobalDB.itemsSold + itemTable.count
            
            ClearCursor()
            UseContainerItem(itemTable.bag, itemTable.slot)
        else
            BrokerGarbage:Debug("Not at vendor", "Deleting")
            BrokerGarbage:Delete(itemTable)
        end
    
    --[[elseif itemTable and IsAltKeyDown() and IsControlKeyDown() then
        -- disenchant
        local itemLink = select(2, GetItemInfo(itemTable.itemID))
        if BrokerGarbage:CanDisenchant(itemLink, true) then
            -- Disenchant: 13262
        end]]--		
        
    elseif itemTable and IsControlKeyDown() then
        -- add to exclude list
        if not BG_LocalDB.exclude[itemTable.itemID] then
            BG_LocalDB.exclude[itemTable.itemID] = true
        end
        BrokerGarbage:Print(format(BrokerGarbage.locale.addedTo_exclude, select(2,GetItemInfo(itemTable.itemID))))
        BrokerGarbage.itemsCache = {}
        
        if BrokerGarbage.optionsLoaded then
            BrokerGarbage:ListOptionsUpdate("exclude")
        end
        BrokerGarbage:ScanInventory()
        
    elseif itemTable and IsAltKeyDown() then
        -- add to force vendor price list
        BG_GlobalDB.forceVendorPrice[itemTable.itemID] = true
        BrokerGarbage:Print(format(BrokerGarbage.locale.addedTo_forceVendorPrice, select(2,GetItemInfo(itemTable.itemID))))
        BrokerGarbage.itemsCache = {}
        
        if BrokerGarbage.optionsLoaded then
            BrokerGarbage:ListOptionsUpdate("forceprice")
        end
        BrokerGarbage:ScanInventory()
        
    elseif button == "RightButton" then
        -- open config
        BrokerGarbage:OptionsFirstLoad()
        InterfaceOptionsFrame_OpenToCategory(BrokerGarbage.options)
        
    elseif LDBclick then
        -- click on the LDB to rescan
        BrokerGarbage:ScanInventory()
    end
    
    UpdateLDB()
end

-- Item Value Calculation
-- ---------------------------------------------------------
-- calculates the value of a stack/partial stack of an item
function BrokerGarbage:GetItemValue(item, count)
    local itemID
    if item and type(item) == "number" then
        itemID = item
    
    elseif item and type(item) == "string" then
        itemID = BrokerGarbage:GetItemID(item)
    
    else
        -- invalid argument
        BrokerGarbage:Debug("GetItemValue: Invalid argument "..(item or "<none>").."supplied.")
        return nil
    end
    
    if BrokerGarbage:GetCached(itemID) then
        return BrokerGarbage:GetCached(itemID).value * (count or 1)
    else
        local value = BrokerGarbage:GetSingleItemValue(item)
        return value and value * (count or 1) or nil
    end
end

-- returns which of the items values is the highest (value, type)
function BrokerGarbage:GetSingleItemValue(item)
    local itemID, itemLink
    if item and type(item) == "number" then
        itemID = item
        itemLink = select(2, GetItemInfo(itemID))
    
    elseif item and type(item) == "string" then
        itemID = BrokerGarbage:GetItemID(item)
        itemLink = item
    end
    
    if not itemID or not itemLink then
        -- invalid argument
        BrokerGarbage:Print("Error! GetSingleItemValue: Invalid argument "..(item or "<none>").." supplied.")
        return nil
    end
    
    local canDE = BrokerGarbage:CanDisenchant(itemLink)
    local _, _, itemQuality, _, _, _, _, _, _, _, vendorPrice = GetItemInfo(itemID)
    local auctionPrice, disenchantPrice, source
    
    -- gray items on the AH?
    if itemQuality == 0 then
        return vendorPrice, BrokerGarbage.VENDOR
    end
    
    -- calculate auction value
    if IsAddOnLoaded("Auctionator") then
        BrokerGarbage.auctionAddon = "Auctionator"
        auctionPrice = Atr_GetAuctionBuyout(itemLink)
        disenchantPrice = canDE and Atr_GetDisenchantValue(itemLink)
    
    elseif IsAddOnLoaded("AuctionLite") then
        BrokerGarbage.auctionAddon = "AuctionLite"
        auctionPrice = AuctionLite:GetAuctionValue(itemLink)
        disenchantPrice = canDE and AuctionLite:GetDisenchantValue(itemLink)
        
    elseif IsAddOnLoaded("WOWEcon_PriceMod") then
        BrokerGarbage.auctionAddon = "WoWecon"
        auctionPrice = Wowecon.API.GetAuctionPrice_ByLink(itemLink)
        
        if canDE then
            disenchantPrice = 0
            local DEData = Wowecon.API.GetDisenchant_ByLink(itemLink)
            for i,data in pairs(DEData) do
                -- data[1] = itemLink, data[2] = quantity, data[3] = chance
                disenchantPrice = disenchantPrice + (Wowecon.API.GetAuctionPrice_ByLink(data[1]) * data[2] * data[3])
            end
            disenchantPrice = canDE and math.floor(disenchantPrice)
        end

    elseif IsAddOnLoaded("Auc-Advanced") then
        BrokerGarbage.auctionAddon = "Auc-Advanced"
        auctionPrice = AucAdvanced.API.GetMarketValue(itemLink)
        
        if canDE and IsAddOnLoaded("Enchantrix") then
            disenchantPrice = 0
            local itemType
            local weaponString, armorString = GetAuctionItemClasses()
            if select(6, GetItemInfo(itemID)) == weaponString then
                itemType = 2
            else
                itemType = 4
            end
            
            local itemLevel = select(4, GetItemInfo(itemID))
            local enchItemQuality = Enchantrix.Constants.baseDisenchantTable[itemQuality]
            if enchItemQuality then
                while not enchItemQuality[itemType][itemLevel] and itemLevel < 500 do
                    itemLevel = itemLevel + 1
                end
                DEMats = Enchantrix.Constants.baseDisenchantTable[itemQuality][itemType][itemLevel]
                
                if DEMats then
                    local item, chance, amount, itemVal
                    for i = 1, #DEMats do
                        item = DEMats[i][1]
                        chance = DEMats[i][2]
                        amount = DEMats[i][3]
                        
                        itemVal = select(2, GetItemInfo(item))
                        itemVal = AucAdvanced.API.GetMarketValue(itemLink) or 0
                        
                        disenchantPrice = disenchantPrice + (itemVal * chance * amount)
                    end
                    disenchantPrice = math.floor(disenchantPrice)
                else
                    BrokerGarbage:Debug("Tried to get Enchantrix value of " .. itemLink .. " but failed.")
                    disenchantPrice = nil
                end
            else
                BrokerGarbage:Debug("Invalid item quality for Enchantrix values of " .. itemLink .. ".")
                disenchantPrice = nil
            end
        end
        
    else
        if GetAuctionBuyout then
            BrokerGarbage.auctionAddon = BrokerGarbage.locale.unknown
            auctionPrice = GetAuctionBuyout(itemLink)
        else
            BrokerGarbage.auctionAddon = BrokerGarbage.locale.na
        end
        disenchantPrice = canDE and GetDisenchantValue and GetDisenchantValue(itemLink) or nil
    end

    -- simply return the highest value price
    local maximum = math.max((disenchantPrice or 0), (auctionPrice or 0), (vendorPrice or 0))
    if vendorPrice and maximum == vendorPrice then
        return vendorPrice, BrokerGarbage.VENDOR
    elseif auctionPrice and maximum == auctionPrice then
        return auctionPrice, BrokerGarbage.AUCTION
    elseif disenchantPrice and maximum == disenchantPrice then
        return disenchantPrice, BrokerGarbage.DISENCHANT
    else
        return nil, nil
    end
end

-- finds all occurences of the given item and returns the least important location
function BrokerGarbage:FindSlotToDelete(itemID, ignoreFullStack)
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
                
                if link and BrokerGarbage:GetItemID(link) == itemID then
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
function BrokerGarbage:Delete(item, position)
    local itemID, itemCount, cursorType
    
    if type(item) == "string" and item == "cursor" then
        -- item on the cursor
        cursorType, itemID = GetCursorInfo()
        if cursorType ~= "item" then
            BrokerGarbage:Print("Error! Trying to delete an item from the cursor, but there is none.")
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
        itemID = BrokerGarbage:GetItemID(item)
    else
        BrokerGarbage:Print("Error! BrokerGarbage:Delete() no argument supplied.")
        return
    end

    -- security check
    if not cursorType and GetContainerItemID(position[1] or item.bag, position[2] or item.slot) ~= itemID then
        BrokerGarbage:Print("Error! Item to be deleted is not the expected item.")
        return
    end
    
    -- make sure there is nothing unwanted on the cursor
    if not cursorType then
        ClearCursor()
    end
    
    if not cursorType and (not position or type(position) ~= "table") then
        BrokerGarbage:Print("Error! No position given to delete from.")
        return
    
    else
        _, itemCount = GetContainerItemInfo(position[1], position[2])
    end
    
    -- actual deleting happening after this
    securecall(PickupContainerItem, position[1], position[2])
    securecall(DeleteCursorItem)					-- comment this line to prevent item deletion
    
    local itemValue = (BrokerGarbage:GetCached(itemID).value or 0) * itemCount	-- if an item is unknown to the cache, statistics will not change
    -- statistics
    BG_GlobalDB.itemsDropped 		= BG_GlobalDB.itemsDropped + itemCount
    BG_GlobalDB.moneyLostByDeleting	= BG_GlobalDB.moneyLostByDeleting + itemValue
    BG_LocalDB.moneyLostByDeleting 	= BG_LocalDB.moneyLostByDeleting + itemValue
    
    local _, itemLink = GetItemInfo(itemID)
    BrokerGarbage:Print(format(BrokerGarbage.locale.itemDeleted, itemLink, itemCount))
end

-- Inventory Scanning
-- ---------------------------------------------------------
-- only used as a shortcut to cache any unknown item in the whole inventory
function BrokerGarbage:ScanInventory()
    for container = 0,4 do
        BrokerGarbage:ScanInventoryContainer(container)
    end
end

-- scans your inventory bags for possible junk items and updates LDB display
function BrokerGarbage:ScanInventoryContainer(container)
    -- container doesn't exist or cannot be scanned
    if not GetContainerNumSlots(container) then return end
    
    local numSlots = GetContainerNumSlots(container)
    BrokerGarbage.toSellValue[container] = 0
    
    for slot = 1, numSlots do
        local itemID = GetContainerItemID(container,slot)
        local item = BrokerGarbage:GetCached(itemID)
        
        if itemID and item then
            -- update toSellValue
            if item.classification == BrokerGarbage.VENDORLIST or 
                (item.classification == BrokerGarbage.UNUSABLE and BG_GlobalDB.sellNotWearable and item.quality <= BG_GlobalDB.sellNWQualityTreshold) or
                (BG_GlobalDB.autoSellIncludeItems and item.classification == BrokerGarbage.INCLUDE) or
                (item.classification ~= BrokerGarbage.EXCLUDE and item.quality == 0) then
                
                local itemCount = select(2, GetContainerItemInfo(container, slot))
                BrokerGarbage.toSellValue[container] = BrokerGarbage.toSellValue[container] + item.value * itemCount
            end
        end
    end
    
    BrokerGarbage:GetCheapest()
    UpdateLDB()
end

-- Find Cheap Items
-- ---------------------------------------------------------
local function TableSort(a, b)
    -- put included items even prior to forced vendor price items
    if (a.source == b.source) or (a.source ~= BrokerGarbage.INCLUDE and b.source ~= BrokerGarbage.INCLUDE) then
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
        return a.source == BrokerGarbage.INCLUDE
    end
end

-- returns the n cheapest items in your bags  in a table
function BrokerGarbage:GetCheapest(number)
    if not number then number = BG_GlobalDB.tooltipNumItems end
    local cheapestItems = {}
    local numSlots, count, quality, canOpen, itemLink, itemID, stackSize
    local item, maxValue, insert
    
    BrokerGarbage.clamInInventory = false
    BrokerGarbage.containerInInventory = false
    
    for container = 0, 4 do
        numSlots = GetContainerNumSlots(container)
        if numSlots then
            for slot = 1, numSlots do
                -- "Gather Information"
                _, count, _, _, _, canOpen, itemLink = GetContainerItemInfo(container, slot)
                itemID = BrokerGarbage:GetItemID(itemLink)
                
                if itemLink and BrokerGarbage:GetCached(itemID) then
                    item = BrokerGarbage:GetCached(itemID)
                    
                    insert = true
                    local value = count * item.value
                    local vendorValue = select(11, GetItemInfo(itemID)) * count
                    local classification = item.classification
                    
                    -- remember lootable items
                    if canOpen or (item and item.isClam) then
                        if item.isClam then
                            BrokerGarbage.clamInInventory = true
                        else
                            BrokerGarbage.containerInInventory = true
                        end
                    end
                    
                    -- handle different types of items
                    if not item or item.classification == BrokerGarbage.EXCLUDE then
                        insert = false
                    
                    elseif item.classification == BrokerGarbage.LIMITED then
                        local saveStacks = ceil(item.limit/(item.stackSize or 1))
                        local locations = BrokerGarbage:FindSlotToDelete(itemID)
                        
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
                            value = 0
                        end
                    
                    elseif item.classification == BrokerGarbage.DISENCHANT or item.classification == BrokerGarbage.AUCTION then
                        -- check if item is really soulbound
                        if BrokerGarbage:IsItemSoulbound(itemID, container, slot) then
                            -- use vendor price instead
                            value = vendorValue
                            classification = BrokerGarbage.VENDOR
                        end
                    
                    elseif item.classification == BrokerGarbage.UNUSABLE then
                        if not BG_GlobalDB.sellNotWearable or item.quality > BG_GlobalDB.sellNWQualityTreshold then
                            insert = false
                        end
                    
                    elseif item.classification == BrokerGarbage.INCLUDE then
                        value = 0
                        
                    elseif item.classification == BrokerGarbage.VENDORLIST or item.classification == BrokerGarbage.VENDOR then
                        value = vendorValue
                    end
                    
                    if item.quality > BG_GlobalDB.dropQuality and 
                        not (classification == BrokerGarbage.INCLUDE or classification == BrokerGarbage.VENDORLIST) then
                        -- include and vendor list items should always be displayed
                        insert = false
                    
                    elseif value == 0 and BG_GlobalDB.hideZeroValue and classification == BrokerGarbage.VENDOR then
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
    
    BrokerGarbage.cheapestItems = cheapestItems
    return cheapestItems
end


-- special functionality
-- ---------------------------------------------------------
-- when at a merchant this will clear your bags of junk (gray quality) and items on your autoSellList
function BrokerGarbage:AutoSell()
    if not BrokerGarbage.isAtVendor then return end
    
    if self == _G["BrokerGarbage_SellIcon"] then
        BrokerGarbage:Debug("AutoSell was triggered by a click on Sell Icon.")
    
    elseif not BG_GlobalDB.autoSellToVendor then
        -- we're not supposed to sell. jump out
        return
    end
    local sell, classification
    local item, itemID, value, count, numSlots
    sellValue = 0
    
    for container = 0, 4 do
        numSlots = GetContainerNumSlots(container)
        if numSlots then
            for slot = 1, numSlots do
                _, count, _, _, _, _, itemLink = GetContainerItemInfo(container, slot)
                itemID 	= BrokerGarbage:GetItemID(itemLink)
                
                if itemLink and BrokerGarbage:GetCached(itemID) then
                    item 	= BrokerGarbage:GetCached(itemID)
                    value 	= item.value
                    
                    sell = false
                    -- various cases that have us sell this item
                    if item.classification == BrokerGarbage.UNUSABLE then
                        if BG_GlobalDB.sellNotWearable and item.quality <= BG_GlobalDB.sellNWQualityTreshold then 
                            sell = true
                        end
                    
                    elseif item.classification == BrokerGarbage.INCLUDE and BG_GlobalDB.autoSellIncludeItems then
                        sell = true
                    
                    elseif item.classification == BrokerGarbage.VENDORLIST then
                        sell = true
                    
                    elseif item.classification ~= BrokerGarbage.EXCLUDE and item.quality == 0 then
                        sell = true
                    end
                    
                    -- Actual Selling
                    if value ~= 0 and sell then
                        if not locked then					
                            BrokerGarbage:Debug("Inventory scans locked")
                            locked = true
                        end
                        
                        BrokerGarbage:Debug("Selling", itemID)
                        ClearCursor()
                        UseContainerItem(container, slot)
                        
                        sellValue = sellValue + (count * value)
                        -- update statistics
                        BG_GlobalDB.moneyEarned = BG_GlobalDB.moneyEarned + (count * value)
                        BG_LocalDB.moneyEarned = BG_LocalDB.moneyEarned + (count * value)
                        BG_GlobalDB.itemsSold = BG_GlobalDB.itemsSold + count
                    end
                end
            end
        end
    end
    
    -- create output if needed
    if self == _G["BrokerGarbage_SellIcon"] then
        if sellValue == 0 and BG_GlobalDB.reportNothingToSell then
            BrokerGarbage:Print(BrokerGarbage.locale.reportNothingToSell)
        elseif sellValue ~= 0 and not BG_GlobalDB.autoSellToVendor then
            BrokerGarbage:Print(format(BrokerGarbage.locale.sell, BrokerGarbage:FormatMoney(sellValue)))
        end
        _G["BrokerGarbage_SellIcon"]:GetNormalTexture():SetDesaturated(true)
    end
end

-- automatically repair at a vendor
function BrokerGarbage:AutoRepair()
    if BG_GlobalDB.autoRepairAtVendor and CanMerchantRepair() then
        cost = GetRepairAllCost()
        local money = GetMoney()
        
        if cost > 0 and CanGuildBankRepair() and GetGuildBankWithdrawMoney() >= cost and not BG_LocalDB.neverRepairGuildBank then
            -- guild repair if we're allowed to and the user wants it
            RepairAllItems(1)
        elseif cost > 0 and money >= cost then
            -- not enough allowance to guild bank repair, pay ourselves
            RepairAllItems(0)
        elseif cost > 0 then
            -- oops. give us your moneys!
            BrokerGarbage:Print(format(BrokerGarbage.locale.couldNotRepair, BrokerGarbage:FormatMoney(cost)))
        end
    else
        cost = 0
    end
end