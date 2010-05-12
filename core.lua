-- Broker_Garbage
--   Author: ckaotik
--   Redistribute: You may use this code - or parts of it - freely as long as you give proper credit. Please do not upload this addon on any kind of addon distribution website.
--   Disclaimer: I provide no warranty whatsoever for what this addon does or doesn't do, even though I try my best to keep it working ;)
_, BrokerGarbage = ...

-- Libraries & setting up the LDB
-- ---------------------------------------------------------
BrokerGarbage.PT = LibStub("LibPeriodicTable-3.1")

-- notation mix-up for Broker2FuBar to work
local LDB = LibStub("LibDataBroker-1.1"):NewDataObject("Broker_Garbage", {
	type	= "data source", 
	icon	= "Interface\\Icons\\achievement_bg_returnxflags_def_wsg",
	label	= "Garbage",
	text 	= "Text",		-- this is a placeholder until the first scan BrokerGarbage.locale.label
	
	OnClick = function(...) BrokerGarbage:OnClick(...) end,
	OnEnter = function(...) BrokerGarbage:Tooltip(...) end,
})

--LDB.OnClick = function(...) BrokerGarbage:OnClick(...) end
--LDB.OnEnter = function(...) BrokerGarbage:Tooltip(...) end

-- internal locals
local locked = false
local sellValue = 0		-- represents the actual value that we sold stuff for, opposed to BrokerGarbage.toSellValue which shows the maximum we could sell - imagine someone closing the merchant window. sellValue will then hold the real value we're interested in
local cost = 0

local lastReminder = time()

BrokerGarbage.isAtVendor = false
BrokerGarbage.optionsModules = {}

-- Event Handler
-- ---------------------------------------------------------
local function eventHandler(self, event, ...)
	if event == "ADDON_LOADED" then
		if arg1 == "Broker_Garbage" then
			BrokerGarbage:CheckSettings()
		end
		
	elseif event == "BAG_UPDATE" then
		if not locked then
			BrokerGarbage:ScanInventory()
		end
		
	elseif event == "MERCHANT_SHOW" then
		local disable = BrokerGarbage.disableKey[BG_GlobalDB.disableKey]
		if not (disable and disable()) then
			BrokerGarbage:AutoRepair()
			BrokerGarbage:AutoSell()
		end
		BrokerGarbage.isAtVendor = true
		
	elseif locked and event == "MERCHANT_CLOSED" then
		-- fallback unlock
		cost = 0
		sellValue = 0
		BrokerGarbage.toSellValue = 0
		BrokerGarbage.isAtVendor = false
		locked = false
		BrokerGarbage:Debug("lock released")
		
		BrokerGarbage:ScanInventory()
	
	elseif (locked or cost ~=0) and event == "PLAYER_MONEY" then
		-- regular unlock
		
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
			
		elseif cost ~= 0 and BG_GlobalDB.autoRepairAtVendor then
			-- repair only
			BrokerGarbage:Print(format(BrokerGarbage.locale.repair, BrokerGarbage:FormatMoney(cost)))
			
		elseif sellValue ~= 0 and BG_GlobalDB.autoSellToVendor then
			-- autosell only
			BrokerGarbage:Print(format(BrokerGarbage.locale.sell, BrokerGarbage:FormatMoney(sellValue)))
		
		end
		
		sellValue = 0
		BrokerGarbage.toSellValue = 0
		cost = 0
		locked = false
		BrokerGarbage:Debug("lock released")
		
		BrokerGarbage:ScanInventory()
	
	end	
end

-- register events
local frame = CreateFrame("frame")

frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("BAG_UPDATE")
frame:RegisterEvent("MERCHANT_SHOW")
frame:RegisterEvent("MERCHANT_CLOSED")
frame:RegisterEvent("PLAYER_MONEY")

frame:SetScript("OnEvent", eventHandler)

-- Sell Icon
-- ---------------------------------------------------------
function BrokerGarbage:UpdateRepairButton(...)
	if not BG_GlobalDB.showAutoSellIcon then
		-- resets guild repair icon
		MerchantGuildBankRepairButton:ClearAllPoints()
		MerchantGuildBankRepairButton:SetPoint("LEFT", MerchantRepairAllButton, "RIGHT", 4, 0)

		if _G["BrokerGarbage_SellIcon"] then
			BrokerGarbage_SellIcon:Hide()
		end
		return
	end
	
	local iconbutton
	-- show auto-sell icon on vendor frame
	if not _G["BrokerGarbage_SellIcon"] then
		iconbutton = CreateFrame("Button", "BrokerGarbage_SellIcon", MerchantBuyBackItemItemButton)
		iconbutton:SetWidth(36); iconbutton:SetHeight(36)
		iconbutton:SetNormalTexture("Interface\\Icons\\achievement_bg_returnxflags_def_wsg")
		iconbutton:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square")
		iconbutton:SetScript("OnClick", BrokerGarbage.AutoSell)
		iconbutton:SetScript("OnEnter", function(self) 
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			local tiptext
			if BrokerGarbage.toSellValue and BrokerGarbage.toSellValue ~= 0 then
				tiptext = format(BrokerGarbage.locale.autoSellTooltip, BrokerGarbage:FormatMoney(BrokerGarbage.toSellValue))
			else
				tiptext = BrokerGarbage.locale.reportNothingToSell
			end
			GameTooltip:SetText(tiptext, nil, nil, nil, nil, true)
		end)
		iconbutton:SetScript("OnLeave", function() GameTooltip:Hide() end)
	else
		iconbutton = _G["BrokerGarbage_SellIcon"]
	end

	if CanMerchantRepair() then
		if CanGuildBankRepair() then
			MerchantGuildBankRepairButton:ClearAllPoints()
			MerchantGuildBankRepairButton:SetPoint("BOTTOMRIGHT", MerchantBuyBackItemItemButton, "BOTTOMLEFT", -22, 4)
			MerchantRepairAllButton:SetPoint("BOTTOMRIGHT", MerchantGuildBankRepairButton, "BOTTOMLEFT", -4, 0)
			iconbutton:SetPoint("BOTTOMRIGHT", MerchantRepairItemButton, "BOTTOMLEFT", -4, 1)
			iconbutton:SetWidth(30); iconbutton:SetHeight(30)
		else
			iconbutton:SetWidth(36); iconbutton:SetHeight(36)
			iconbutton:SetPoint("BOTTOMRIGHT", MerchantRepairItemButton, "BOTTOMLEFT", -2, 0)
		end
		
		iconbutton:Show()
	else
		iconbutton:SetPoint("BOTTOMRIGHT", MerchantBuyBackItemItemButton, "BOTTOMLEFT", -18, 0)
		iconbutton:Show()
	end
	MerchantRepairText:Hide()
	
	if BrokerGarbage.toSellValue and BrokerGarbage.toSellValue ~= 0 then
		_G["BrokerGarbage_SellIcon"]:GetNormalTexture():SetDesaturated(false)
	else
		_G["BrokerGarbage_SellIcon"]:GetNormalTexture():SetDesaturated(true)
	end
end
hooksecurefunc("MerchantFrame_UpdateRepairButtons", BrokerGarbage.UpdateRepairButton)

-- Tooltip
-- ---------------------------------------------------------
function BrokerGarbage:Tooltip(self)
	if BG_GlobalDB.showSource then
		BrokerGarbage.tt = LibStub("LibQTip-1.0"):Acquire("BrokerGarbage_TT", 4, "LEFT", "RIGHT", "RIGHT", "CENTER")
	else
		BrokerGarbage.tt = LibStub("LibQTip-1.0"):Acquire("BrokerGarbage_TT", 3, "LEFT", "RIGHT", "RIGHT")
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
   
	-- shows up to n lines of deletable items
	local lineNum
	local cheapList = BrokerGarbage:GetCheapest(BG_GlobalDB.tooltipNumItems)
	for i = 1, #cheapList do		
		-- adds lines: itemLink, count, itemPrice, source
		lineNum = BrokerGarbage.tt:AddLine(
			select(2,GetItemInfo(cheapList[i].itemID)), 
			cheapList[i].count,
			BrokerGarbage:FormatMoney(cheapList[i].value),
			(BG_GlobalDB.showSource and cheapList[i].source or nil))
		BrokerGarbage.tt:SetLineScript(lineNum, "OnMouseDown", BrokerGarbage.OnClick, cheapList[i])
	end
	if lineNum == nil then 
		BrokerGarbage.tt:AddLine(BrokerGarbage.locale.noItems, '', BrokerGarbage.locale.increaseTreshold)
	end
	
	-- add useful(?) information
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

-- onClick function for when you ... click. works for both, the LDB plugin -and- tooltip lines
function BrokerGarbage:OnClick(itemTable, button)	
	-- handle LDB clicks seperately
	if not itemTable.itemID or type(itemTable.itemID) ~= "number" then
		BrokerGarbage:Debug("No itemTable for OnClick, using cheapest item")
		itemTable = BrokerGarbage.cheapestItem
	end
	
	-- handle different clicks
	if itemTable and IsShiftKeyDown() then
		-- delete or sell item, depending on if we're at a vendor or not
		BrokerGarbage:Debug("SHIFT-Click!")
		if BrokerGarbage.isAtVendor and itemTable.value > 0 then
			BrokerGarbage:Debug("@Vendor", "Selling")
			BG_GlobalDB.moneyEarned = BG_GlobalDB.moneyEarned + itemTable.value
			BG_LocalDB.moneyEarned = BG_LocalDB.moneyEarned + itemTable.value
			BG_GlobalDB.itemsSold = BG_GlobalDB.itemsSold + itemTable.count
			
			ClearCursor()
			UseContainerItem(itemTable.bag, itemTable.slot)
		else
			BrokerGarbage:Debug("Not @Vendor", "Deleting")
			BrokerGarbage:Delete(itemTable)
		end
	
	--[[elseif itemTable and IsAltKeyDown() and IsControlKeyDown() then
		-- disenchant
		BrokerGarbage:Debug("CTRL+ALT-Click!")
		local itemLink = select(2, GetItemInfo(itemTable.itemID))
		if BrokerGarbage:CanDisenchant(itemLink, true) then
			-- Disenchant: 13262
		end]]--		
		
	elseif itemTable and IsControlKeyDown() then
		-- add to exclude list
		BrokerGarbage:Debug("CTRL-Click!")
		if not BG_LocalDB.exclude[itemTable.itemID] then
			BG_LocalDB.exclude[itemTable.itemID] = true
		end
		BrokerGarbage:Print(format(BrokerGarbage.locale.addedToSaveList, select(2,GetItemInfo(itemTable.itemID))))
		
		if BrokerGarbage.optionsLoaded then
			BrokerGarbage:ListOptionsUpdate("exclude")
		end
		
	elseif itemTable and IsAltKeyDown() then
		-- add to force vendor price list
		BrokerGarbage:Debug("ALT-Click!")
		BG_GlobalDB.forceVendorPrice[itemTable.itemID] = true
		BrokerGarbage:Print(format(BrokerGarbage.locale.addedToPriceList, select(2,GetItemInfo(itemTable.itemID))))
		
		if BrokerGarbage.optionsLoaded then
			BrokerGarbage:ListOptionsUpdate("forceprice")
		end
		BrokerGarbage:ScanInventory()
		
	elseif button == "RightButton" then
		-- open config
		BrokerGarbage:OptionsFirstLoad()
		InterfaceOptionsFrame_OpenToCategory(BrokerGarbage.options)
		
	else
		-- do nothing
	end
	
	BrokerGarbage:ScanInventory()
end

-- Item Value Calculation
-- ---------------------------------------------------------
-- calculates the value of a stack/partial stack of an item
function BrokerGarbage:GetItemValue(itemLink, count)
	if not itemLink then return nil, nil end
	local itemID = BrokerGarbage:GetItemID(itemLink)
	local DE = BrokerGarbage:CanDisenchant(itemLink)
	local itemQuality = select(3,GetItemInfo(itemLink))
	local vendorPrice = select(11,GetItemInfo(itemLink))
	local auctionPrice, disenchantPrice, source
	
	if vendorPrice == 0 then vendorPrice = nil end
	if not count then
		count = GetItemCount(itemLink, false, false)
		if count == 0 then count = 1 end
	end
	
	-- gray items on the AH?
	if itemQuality == 0 then
		return vendorPrice and vendorPrice*count or nil, BrokerGarbage.tagVendor
	end
	
	-- calculate auction value
	if IsAddOnLoaded("Auctionator") then
		BrokerGarbage.auctionAddon = "Auctionator"
		auctionPrice = Atr_GetAuctionBuyout(itemLink)
		disenchantPrice = DE and Atr_GetDisenchantValue(itemLink)
	
	elseif IsAddOnLoaded("AuctionLite") then
		BrokerGarbage.auctionAddon = "AuctionLite"
		auctionPrice = AuctionLite:GetAuctionValue(itemLink)
		disenchantPrice = DE and AuctionLite:GetDisenchantValue(itemLink)
		
	elseif IsAddOnLoaded("WOWEcon_PriceMod") then
		BrokerGarbage.auctionAddon = "WoWecon"
		auctionPrice = Wowecon.API.GetAuctionPrice_ByLink(itemLink)
		
		if DE then
			disenchantPrice = 0
			local DEData = Wowecon.API.GetDisenchant_ByLink(itemLink)
			for i,data in pairs(DEData) do
				-- data[1] = itemLink, data[2] = quantity, data[3] = chance
				disenchantPrice = disenchantPrice + (Wowecon.API.GetAuctionPrice_ByLink(data[1]) * data[2] * data[3])
			end
			disenchantPrice = DE and math.floor(disenchantPrice)
		end

	elseif IsAddOnLoaded("Auc-Advanced") then
		BrokerGarbage.auctionAddon = "Auc-Advanced"
		auctionPrice = AucAdvanced.API.GetMarketValue(itemLink)
		
		if DE and IsAddOnLoaded("Enchantrix") then
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
				
				local item, chance, amount, itemVal
				for i = 1, #DEMats do
					item = DEMats[i][1]
					chance = DEMats[i][2]
					amount = DEMats[i][3]
					
					itemVal = select(2, GetItemInfo(item))
					itemVal = AucAdvanced.API.GetMarketValue(itemVal) or 0
					
					disenchantPrice = disenchantPrice + (itemVal * chance * amount)
				end
				disenchantPrice = math.floor(disenchantPrice)
			else
				disenchantPrice = nil
			end
		end
		
	else
		BrokerGarbage.auctionAddon = "Unknown/None"
		auctionPrice = GetAuctionBuyout and GetAuctionBuyout(itemLink) or nil
		disenchantPrice = DE and GetDisenchantValue and GetDisenchantValue(itemLink) or nil

	end

	local maximum = math.max((disenchantPrice or 0), (auctionPrice or 0), (vendorPrice or 0))
	if vendorPrice and maximum == vendorPrice then
		return vendorPrice*count, BrokerGarbage.tagVendor
		
	elseif auctionPrice and maximum == auctionPrice then
		return auctionPrice*count, BrokerGarbage.tagAuction
		
	elseif disenchantPrice and maximum == disenchantPrice then
		return disenchantPrice, BrokerGarbage.tagDisenchant
		
	else
		return nil, nil
	end
end

-- finds all occurences of the given item and returns the best location to delete from
function BrokerGarbage:FindSlotToDelete(itemID, ignoreFullStack)
	local locations = {}
	local maxStack = select(8, GetItemInfo(itemID))
	
	local numSlots, freeSlots, ratio, bagType
	for container = 0,4 do
		numSlots = GetContainerNumSlots(container)
		freeSlots, bagType = GetContainerFreeSlots(container)
		if not numSlots or not freeSlots then break end
		ratio = #freeSlots/numSlots
		
		for slot = 1, numSlots do
			local _,count,locked,_,_,canOpen,itemLink = GetContainerItemInfo(container, slot)
			
			if itemLink and BrokerGarbage:GetItemID(itemLink) == itemID then
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

-- deletes the item in a given location of your bags. takes either link/{bag,slot} or an itemTable as created by GetCheapest() or "cursor"/count
function BrokerGarbage:Delete(itemLink, position)
	local cursorType, itemID, itemCount
	
	if itemLink == "cursor" then
		-- item on the cursor
		cursorType, itemID, itemLink = GetCursorInfo()
		if cursorType ~= "item" then return end

	elseif type(itemLink) == "table" then
		-- item given as an itemTable
		position = {itemLink.bag, itemLink.slot}
		itemID = itemLink.itemID
		itemLink = select(2,GetItemInfo(itemID))
		ClearCursor()
	end

	-- security check
	if not select(2,GetItemInfo(itemID)) == itemLink then return end
	
	if type(position) == "table" then
		itemCount = select(2, GetContainerItemInfo(position[1], position[2]))
		PickupContainerItem(position[1], position[2])
	else
		itemCount = position
	end
	local itemValue = BrokerGarbage:GetItemValue(itemLink, itemCount) or 0
	
	-- statistics
	BG_GlobalDB.itemsDropped = BG_GlobalDB.itemsDropped + itemCount
	BG_GlobalDB.moneyLostByDeleting = BG_GlobalDB.moneyLostByDeleting + itemValue
	BG_LocalDB.moneyLostByDeleting = BG_LocalDB.moneyLostByDeleting + itemValue
	
	DeleteCursorItem()					-- comment this line to prevent item deletion
	BrokerGarbage:Print(format(BrokerGarbage.locale.itemDeleted, itemLink, itemCount))
end

-- Inventory Scanning
-- ---------------------------------------------------------
-- scans your inventory for possible junk items and updates LDB display
function BrokerGarbage:ScanInventory()
	BrokerGarbage.inventory = {}
	BrokerGarbage.sellItems = {}
	BrokerGarbage.unopened = {}
	local limitedItemsChecked = {}
	
	BrokerGarbage.toSellValue = 0
	BrokerGarbage.totalBagSpace = 0
	BrokerGarbage.totalFreeSlots = 0
	
	for container = 0,4 do
		local numSlots = GetContainerNumSlots(container)
		if numSlots then
			freeSlots = GetContainerFreeSlots(container)
			BrokerGarbage.totalFreeSlots = BrokerGarbage.totalFreeSlots + (freeSlots and #freeSlots or 0)
			BrokerGarbage.totalBagSpace = BrokerGarbage.totalBagSpace + numSlots
			
			for slot = 1, numSlots do
				local itemID = GetContainerItemID(container,slot)
				if itemID then
					-- GetContainerItemInfo sucks big time ... just don't use it for quality IDs!!!!!!!
					local _,count,locked,_,_, canOpen,itemLink = GetContainerItemInfo(container, slot)
					local quality = select(3,GetItemInfo(itemID))
					local isClam = BrokerGarbage:Find(BrokerGarbage.clams, itemID)
					
					if canOpen or isClam then
						local _,_,_,_,_,type,subType,_,_,tex = GetItemInfo(itemID)
						tinsert(BrokerGarbage.unopened, {
							bag = container,
							slot = slot,
							itemID = itemID,
							clam = isClam,
						})
					end
					
					-- check if this item belongs to an excluded category
					local isExclude
					for setName,_ in pairs(BrokerGarbage:JoinTables(BG_GlobalDB.exclude, BG_LocalDB.exclude)) do
						if type(setName) == "string" then
							_, isExclude = BrokerGarbage.PT:ItemInSet(itemID, setName)
						end
						if isExclude then
							break
						end
					end

					local isSell, isInclude, isVendor
					-- this saves excluded items
					if not BG_GlobalDB.exclude[itemID] and not BG_LocalDB.exclude[itemID] then
						local force = false

						-- check if item is in a category of Include List
						for setName,_ in pairs(BrokerGarbage:JoinTables(BG_LocalDB.include, BG_GlobalDB.include)) do
							if type(setName) == "string" then
								_, isInclude = BrokerGarbage.PT:ItemInSet(itemID, setName)
							end
							if isInclude then isInclude = setName; break end
						end
						
						-- check if item is in a category of Sell List
						for setName,_ in pairs(BrokerGarbage:JoinTables(BG_GlobalDB.autoSellList, BG_LocalDB.autoSellList)) do
							if type(setName) == "string" then
								_, isSell = BrokerGarbage.PT:ItemInSet(itemID, setName)
							end
							if isSell then isSell = setName; break end
						end
						
						-- check if item is in a category of Force Vendor Price List
						for setName,_ in pairs(BG_GlobalDB.forceVendorPrice) do
							if type(setName) == "string" then
								_, isVendor = BrokerGarbage.PT:ItemInSet(itemID, setName)
							end
							if isVendor then isVendor = setName; break end
						end
						
						-- ----------------------------------------------------------------------
						-- get price and tag
						BrokerGarbage.checkItem = {
							bag = container,
							slot = slot,
							itemID = itemID,
						}
						local value, source = BrokerGarbage:GetItemValue(itemLink, count)
						BrokerGarbage.checkItem = nil
						
						local _,_,_,_,_,_,subClass,stackSize,invType,_,vendorPrice = GetItemInfo(itemLink)
						
						if (isInclude and not isExclude) 
							or BG_GlobalDB.include[itemID] or BG_LocalDB.include[itemID] then
							-- Include List item
							isInclude = true
							force = true
							
							local limited = BrokerGarbage:Find(limitedItemsChecked, itemID)
							if not limited then
								if (BG_GlobalDB.include[itemID] and type(BG_GlobalDB.include[itemID]) == "number")
									or (BG_LocalDB.include[itemID] and type(BG_LocalDB.include[itemID]) == "number") then
									
									-- this is a limited item - only check it once
									tinsert(limitedItemsChecked, itemID)
									limited = true
									
									local limit = tonumber(BG_GlobalDB.include[itemID]) or tonumber(BG_LocalDB.include[itemID])
									local saveStacks = ceil(limit/(stackSize or 1))
									local locations = BrokerGarbage:FindSlotToDelete(itemID)
									
									if #locations > saveStacks then
										local itemCount = 0
										for i = #locations, 1, -1 do
											if itemCount < limit then
												itemCount = itemCount + locations[i].count
											else
												tinsert(BrokerGarbage.inventory, {
													bag = locations[i].bag,
													slot = locations[i].slot,
													itemID = itemID,
													quality = quality,
													count = locations[i].count,
													value = 0,
													source = BrokerGarbage.tagInclude,
													force = force,
												})
											end
										end
									end
								else
									limited = false
								end
							end
							
							if not limited then
								value = value or 0
								source = BrokerGarbage.tagInclude
							else
								-- this makes limited items not be inserted twice
								value = nil
							end
						
						elseif (isSell and not isExclude)
							or BG_GlobalDB.autoSellList[itemID] or BG_LocalDB.autoSellList[itemID] then
							-- AutoSell
							isSell = true
							force = false
							
							value = vendorPrice
							if value then value = value * count end
							source = BrokerGarbage.tagVendorList
							
						elseif quality and quality <= BG_GlobalDB.dropQuality and
							((isVendor and not isExclude) or BG_GlobalDB.forceVendorPrice[itemID]) then
							-- Force Vendor Price List item
							isVendor = true
							force = false
							
							value = vendorPrice
							if value then value = value * count end
							source = BrokerGarbage.tagVendorList
							
						elseif not IsUsableSpell(BrokerGarbage.enchanting)	and BrokerGarbage:IsItemSoulbound(itemLink)
							and BG_GlobalDB.sellNotWearable and quality <= BG_GlobalDB.sellNWQualityTreshold 
							and string.find(invType, "INVTYPE") and not string.find(invType, "BAG") 
							and not BrokerGarbage.usableByClass[BrokerGarbage.playerClass][subClass]
							and not BrokerGarbage.usableByAll[invType] then
							-- Sell unusable Gear
							isSell = true
							force = false
							
							value = vendorPrice
							source = BrokerGarbage.tagUnusableGear
						
						elseif isExclude or (quality and quality > BG_GlobalDB.dropQuality) or not quality then
							-- setting the value to nil will prevent the item being inserted to our inventory table
							value = nil
							
						-- all 'regular' items would be in the else part but already have their values and attributes set
						end
						
						if value then
							-- save if we have something sellable
							if quality == 0 or isSell
								or BG_GlobalDB.autoSellList[itemID] or BG_LocalDB.autoSellList[itemID] then
								BrokerGarbage.toSellValue = BrokerGarbage.toSellValue + value
							end
							
							-- insert into BrokerGarbage.inventory
							if (quality and quality <= BG_GlobalDB.dropQuality) 
								or (isSell and not source == BrokerGarbage.tagUnusableGear) or isInclude or isVendor then
								
								tinsert(BrokerGarbage.inventory, {
									bag = container,
									slot = slot,
									itemID = itemID,
									quality = quality,
									count = count,
									value = value,
									source = source,
									force = force,
								})
							
							elseif quality > BG_GlobalDB.dropQuality and 
								(source == BrokerGarbage.tagUnusableGear or source == BrokerGarbage.tagVendorList) then
								tinsert(BrokerGarbage.sellItems, {
									bag = container,
									slot = slot,
									itemID = itemID,
									quality = quality,
									count = count,
									value = value,
									source = source,
									force = force,
								})
							end
						end
					end
				end
			end
		end
	end
	
	local cheapestItem = BrokerGarbage:GetCheapest()
	
	if cheapestItem[1] then
		BrokerGarbage.cheapestItem = cheapestItem[1]
		LDB.text = BrokerGarbage:FormatString(BG_GlobalDB.LDBformat)
	else
		BrokerGarbage.cheapestItem = nil
		LDB.text = BrokerGarbage:FormatString(BG_GlobalDB.LDBNoJunk)
	end
end

-- Find Cheap Items
-- ---------------------------------------------------------
-- returns the n cheapest items in your bags  in a table
function BrokerGarbage:GetCheapest(number)
	if not number then number = 1 end
	local cheapestItems, temp = {}, {}
	
	-- get forced items
	for _, itemTable in pairs(BrokerGarbage.inventory) do
		local skip = false
		
		for _, usedTable in pairs(cheapestItems) do
			if usedTable == itemTable then 
				skip = true
				break
			end
		end
			
		if not skip and itemTable.force then
			tinsert(temp, itemTable)
		end
	end
	table.sort(temp, function(a, b)
		-- put included items even prior to forced vendor price items
		if (a.source == b.source) or (a.source ~= BrokerGarbage.tagInclude and b.source ~= BrokerGarbage.tagInclude) then
			return a.value < b.value
		else 
			return a.source == BrokerGarbage.tagInclude
		end
	end)
	
	if #temp <= number then
		cheapestItems = temp
	else
		for i = 1, number do
			tinsert(cheapestItems, temp[i])
		end
	end
	
	-- fill with non-forced
	if #cheapestItems < number then
		local minPrice, minTable
		
		for i = #cheapestItems +1, number do
			for _, itemTable in pairs(BrokerGarbage.inventory) do
				local skip = false
				
				for _, usedTable in pairs(cheapestItems) do
					if usedTable == itemTable then 
						skip = true
					end
				end
				
				if not skip and (not minPrice or itemTable.value < minPrice) then
					minPrice = itemTable.value
					minTable = itemTable
				end
			end
			
			if minTable then tinsert(cheapestItems, minTable) end
			minPrice = nil
			minTable = nil
		end
	end
	
	return cheapestItems
end


-- special functionality
-- ---------------------------------------------------------
-- when at a merchant this will clear your bags of junk (gray quality) and items on your autoSellList
function BrokerGarbage:AutoSell()
	if BG_GlobalDB.autoSellToVendor or self == _G["BrokerGarbage_SellIcon"] then
		if self == _G["BrokerGarbage_SellIcon"] then
			BrokerGarbage:Debug("AutoSell was triggered by a click on Sell Icon.", BrokerGarbage:FormatMoney(sellValue), BrokerGarbage:FormatMoney(BrokerGarbage.toSellValue))
		end
		local i = 1
		local skip
		sellValue = 0
		for _, itemTable in pairs(BrokerGarbage:JoinSimpleTables(BrokerGarbage.inventory, BrokerGarbage.sellItems)) do
			local sellByString, excludeByString = false, false
			local temp, checkTable
			
			-- check if item should be saved: exclude/whitelist
			for setName,_ in pairs(BrokerGarbage:JoinTables(BG_GlobalDB.exclude, BG_LocalDB.exclude)) do
				if type(setName) == "string" then
					_, temp = BrokerGarbage.PT:ItemInSet(itemTable.itemID, setName)
				end
				if temp then
					BrokerGarbage:Debug(itemTable.itemID, "is in set", temp, "on exclude list")
					excludeByString = true
					break
				end
			end
			
			temp = nil
			-- check if item should be sold: auto sell list
			if BG_GlobalDB.autoSellIncludeItems then
				checkTable = BrokerGarbage:JoinTables(BG_LocalDB.include, BG_GlobalDB.include)
			else
				checkTable = BrokerGarbage:JoinTables(BG_LocalDB.autoSellList, BG_GlobalDB.autoSellList)
			end
			for setName,_ in pairs(checkTable) do
				if type(setName) == "string" then
					_, temp = BrokerGarbage.PT:ItemInSet(itemTable.itemID, setName)
				end
				if temp then
					-- this only prints the first match
					BrokerGarbage:Debug(itemTable.itemID, "is in set", temp, "on auto sell list")
					sellByString = true
					break
				end
			end
			
			
			-- ==== Sell Gear ==== --
			-- check if this item is equippable for us
			local _, itemLink, quality, _, _, _, subClass, _, invType = GetItemInfo(itemTable.itemID)
			local sellGear = quality 
				and not IsUsableSpell(BrokerGarbage.enchanting)	and BrokerGarbage:IsItemSoulbound(itemLink)
				and BG_GlobalDB.sellNotWearable and quality <= BG_GlobalDB.sellNWQualityTreshold 
				and string.find(invType, "INVTYPE") and not string.find(invType, "BAG") 
				and not BrokerGarbage.usableByClass[BrokerGarbage.playerClass][subClass]
				and not BrokerGarbage.usableByAll[invType]
			
			if sellGear then 
				BrokerGarbage:Debug("Item should be sold (as we cannot wear it):" .. itemLink)
			end
			
			-- shorten our literals
			local excludeByID = BG_GlobalDB.exclude[itemTable.itemID] or BG_LocalDB.exclude[itemTable.itemID]
			if excludeByID then
				BrokerGarbage:Debug(itemTable.itemID, "is excluded via its itemID")
			end
			local autoSellByID = BG_GlobalDB.autoSellList[itemTable.itemID] or BG_LocalDB.autoSellList[itemTable.itemID]
			if autoSellByID then
				BrokerGarbage:Debug(itemTable.itemID, "is to be sold via its itemID")
			end
			
			-- === Actuall Selling === ---
			-- do the priorities right!
			if itemTable.value ~= 0 and not excludeByID and (autoSellByID 
				or (not excludeByString and (sellByString or itemTable.quality == 0 or sellGear))) then
			
				if i == 1 then					
					BrokerGarbage:Debug("Inventory scans locked")
					locked = true
				end
				
				BrokerGarbage:Debug("Selling", itemTable.itemID)
				sellValue = sellValue + itemTable.value
				BG_GlobalDB.moneyEarned = BG_GlobalDB.moneyEarned + itemTable.value
				BG_LocalDB.moneyEarned = BG_LocalDB.moneyEarned + itemTable.value
				
				ClearCursor()
				UseContainerItem(itemTable.bag, itemTable.slot)
				BG_GlobalDB.itemsSold = BG_GlobalDB.itemsSold + itemTable.count
				i = i+1
			end
		end
		
		if self == _G["BrokerGarbage_SellIcon"] then
			if sellValue == 0 and BG_GlobalDB.reportNothingToSell then
				BrokerGarbage:Print(BrokerGarbage.locale.reportNothingToSell)
			elseif sellValue ~= 0 and not BG_GlobalDB.autoSellToVendor then
				BrokerGarbage:Print(format(BrokerGarbage.locale.sell, BrokerGarbage:FormatMoney(sellValue)))
			end
			_G["BrokerGarbage_SellIcon"]:GetNormalTexture():SetDesaturated(true)
		end
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