-- Broker_Garbage
--   Author: Ckaotik (Raisa@EU-Die Todeskrallen)
-- created to replace/update GarbageFu for 3.x and further provide LDB support
_, BrokerGarbage = ...

-- setting up the LDB
-- ---------------------------------------------------------
local LibQTip = LibStub('LibQTip-1.0')

local LDB = LibStub:GetLibrary("LibDataBroker-1.1"):NewDataObject("Garbage")
LDB.type 	= "data source"
LDB.icon 	= "Interface\\Icons\\achievement_bg_returnxflags_def_wsg"
LDB.label	= "Garbage"
LDB.text 	= BrokerGarbage.locale.label
LDB.OnClick = function(...) BrokerGarbage:OnClick(...) end
LDB.OnEnter = function(...) BrokerGarbage:Tooltip(...) end
LDB.OnLeave = function(...) BrokerGarbage:HideTT(...) end
LDB.OnTooltipShow = function(...) BrokerGarbage:Tooltip(...) end


-- default saved variables
if not BG_GlobalDB or BG_GlobalDB == {} then
	BG_GlobalDB = {
		dropQuality = 0,
		exclude = {},
		include = {},
		showMoney = 2,
		autoSellToVendor = true,
		autoRepairAtVendor = true,
		tooltipMaxHeight = 220,
		tooltipNumItems = 10,
		moneyLostByDeleting = 0,
		neverRepairGuildBank = false,
	}
end

-- internal locals
local debug = false
local locked = false
local loaded = false
local sellValue
local cost = 0

BrokerGarbage.tt = nil

-- event handler
local function eventHandler(self, event, ...)
	if event == "MERCHANT_SHOW" then
		if not IsShiftKeyDown() then
			BrokerGarbage:AutoRepair()
			BrokerGarbage:AutoSell()
		end
		
	elseif (locked or cost ~=0) and event == "PLAYER_MONEY" then
		-- regular unlock
		
		-- wrong player_money event
		-- testing: add a span for wich we recognize this one as repair bill
		if sellValue and cost ~= 0 and ((-1)*sellValue <= cost+2 and (-1)*sellValue >= cost-2) then 
			BrokerGarbage:Debug("Not yet ... Waiting for actual money change.")
			return 
		end
		
		if sellValue and cost ~= 0 and BG_GlobalDB.autoRepairAtVendor and BG_GlobalDB.autoSellToVendor then
			-- repair & auto-sell
			BrokerGarbage:Print(format(BrokerGarbage.locale.sellAndRepair, 
					BrokerGarbage:FormatMoney(sellValue), 
					BrokerGarbage:FormatMoney(cost), 
					BrokerGarbage:FormatMoney(sellValue - cost)
			))
			
		elseif cost ~= 0 and BG_GlobalDB.autoRepairAtVendor then
			-- repair only
			BrokerGarbage:Print(format(BrokerGarbage.locale.repair, BrokerGarbage:FormatMoney(cost)))
			
		elseif sellValue and BG_GlobalDB.autoSellToVendor then
			-- autosell only
			BrokerGarbage:Print(format(BrokerGarbage.locale.sell, BrokerGarbage:FormatMoney(sellValue)))
		end
		
		sellValue = nil
		cost = 0
		locked = false
		BrokerGarbage:Debug("lock released")
		
		BrokerGarbage:ScanInventory()
		
	elseif locked and event == "MERCHANT_CLOSED" then
		-- fallback unlock
		sellValue = nil
		cost = 0
		locked = false
		BrokerGarbage:Debug("lock released")
		
		BrokerGarbage:ScanInventory()
		
	elseif event == "PLAYER_ENTERING_WORLD" or event == "BAG_UPDATE" then
		-- don't bother calculating while selling stuff
		if not locked and loaded then
			BrokerGarbage:ScanInventory()
		end
	end	
end

-- register events
local frame = CreateFrame("frame")

frame:RegisterEvent("MERCHANT_SHOW")
frame:RegisterEvent("MERCHANT_CLOSED")
frame:RegisterEvent("PLAYER_MONEY")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("BAG_UPDATE")
frame:SetScript("OnEvent", eventHandler)

loaded = true

-- Helper functions
-- ---------------------------------------------------------
function BrokerGarbage:Print(text)
	DEFAULT_CHAT_FRAME:AddMessage("|cffee6622Broker_Garbage|r "..text)
end

function BrokerGarbage:Debug(...)
  if debug then
	BrokerGarbage:Print("! "..string.join(", ", tostringall(...)))
  end
end

function BrokerGarbage:FormatMoney(amount)
	if not amount then return "" end
	
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
	
	if BG_GlobalDB.showMoney == 0 then
		return format(signum.."%i.%i.%i", gold, silver,copper)

	elseif BG_GlobalDB.showMoney == 1 then
		return format(signum.."|cffffd700%i|r.|cffc7c7cf%.2i|r.|cffeda55f%.2i|r", gold, silver, copper)

	-- copied from Ara Broker Money
	elseif BG_GlobalDB.showMoney == 2 then
		if amount>9999 then
			return format(signum.."|cffeeeeee%i|r|cffffd700g|r |cffeeeeee%.2i|r|cffc7c7cfs|r |cffeeeeee%.2i|r|cffeda55fc|r", floor(amount*.0001), floor(amount*.01)%100, amount%100 )
		
		elseif amount > 99 then
			return format(signum.."|cffeeeeee%i|r|cffc7c7cfs|r |cffeeeeee%.2i|r|cffeda55fc|r", floor(amount*.01), amount%100 )
		
		else
			return format(signum.."|cffeeeeee%i|r|cffeda55fc|r", amount)
		end
	
	-- copied from Haggler
	elseif BG_GlobalDB.showMoney == 3 then
		gold         = gold   > 0 and gold  .."|TInterface\\MoneyFrame\\UI-GoldIcon:12:12:4:0|t" or ""
		silver       = silver > 0 and silver.."|TInterface\\MoneyFrame\\UI-SilverIcon:12:12:4:0|t" or ""
		copper       = copper > 0 and copper.."|TInterface\\MoneyFrame\\UI-CopperIcon:12:12:4:0|t" or ""
		-- add spaces if needed
		copper       = (silver ~= "" and copper ~= "") and " "..copper or copper
		silver       = (gold   ~= "" and silver ~= "") and " "..silver or silver
	
		return signum..gold..silver..copper
		
	elseif BG_GlobalDB.showMoney == 4 then		
		gold         = gold   > 0 and "|cffeeeeee"..gold  .."|r|cffffd700g|r" or ""
		silver       = silver > 0 and "|cffeeeeee"..silver.."|r|cffc7c7cfs|r" or ""
		copper       = copper > 0 and "|cffeeeeee"..copper.."|r|cffeda55fc|r" or ""
		-- add spaces if needed
		copper       = (silver ~= "" and copper ~= "") and " "..copper or copper
		silver       = (gold   ~= "" and silver ~= "") and " "..silver or silver
	
		return signum..gold..silver..copper
	end
end

-- check if a given value can be found in a table
function BrokerGarbage:Find(table, value)
	for k, v in pairs(table) do
		if (v == value) then return true end
	end
	return false
end

function BrokerGarbage:ResetMoneyLost()
	BG_GlobalDB.moneyLostByDeleting = 0
end

-- basic functionality from here
-- ---------------------------------------------------------
function BrokerGarbage:Tooltip(wut)
	-- Acquire a tooltip with 3 columns, respectively aligned to left, center and right	
	BrokerGarbage.tt = LibQTip:Acquire("BrokerGarbage_TT", 3, "LEFT", "RIGHT", "RIGHT")
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
		-- adds lines: itemLink, count, itemPrice
		lineNum = BrokerGarbage.tt:AddLine(
			select(2,GetItemInfo(cheapList[i].itemID)), 
			cheapList[i].count, 
			BrokerGarbage:FormatMoney(cheapList[i].value))
		BrokerGarbage.tt:SetLineScript(lineNum, "OnMouseDown", BrokerGarbage.OnClick, cheapList[i])
	end
	
	-- add useful(?) information
	BrokerGarbage.tt:AddSeparator(2)
	BrokerGarbage.tt:AddLine(BrokerGarbage.locale.moneyLost, '', BrokerGarbage:FormatMoney(BG_GlobalDB.moneyLostByDeleting))
	
	
	-- Use smart anchoring code to anchor the tooltip to our frame
	BrokerGarbage.tt:SmartAnchorTo(wut)

	-- Show it, et voilà !
	BrokerGarbage.tt:Show()
	BrokerGarbage.tt:UpdateScrolling(BG_GlobalDB.tooltipMaxHeight)
end

function BrokerGarbage:HideTT()
	if BrokerGarbage.tt and MouseIsOver(BrokerGarbage.tt) then return end
	BrokerGarbage.tt:Hide()
	
	-- Release the tooltip
	LibQTip:Release(BrokerGarbage.tt)
	BrokerGarbage.tt = nil
end

-- onClick function for when you ... click
function BrokerGarbage:OnClick(itemTable)
	-- just in case our drop list is empty
	if not itemTable then itemTable = {} end

	if type(itemTable) ~= "table" then
		cheapList = BrokerGarbage:GetCheapest()
		BrokerGarbage:OnClick(cheapList[1])
		return
	end
	
	-- handle different clicks
	if itemTable ~= {} and IsShiftKeyDown() then
		-- delete item
		BrokerGarbage:Debug("SHIFT-Click!")
		BrokerGarbage:Delete(select(2,GetItemInfo(itemTable.itemID)), itemTable.bag, itemTable.slot)
		BG_GlobalDB.moneyLostByDeleting = BG_GlobalDB.moneyLostByDeleting + itemTable.value
		BrokerGarbage:ScanInventory()
		
	elseif itemTable ~= {} and IsControlKeyDown() then
		-- add to exclude list
		BrokerGarbage:Debug("CTRL-Click!")
		tinsert(BG_GlobalDB.exclude, itemTable.itemID)
		BrokerGarbage:Print(format(BrokerGarbage.locale.addedToSaveList, select(2,GetItemInfo(itemTable.itemID))))
		BrokerGarbage:ScanInventory()
		
	elseif GetMouseButtonClicked() == "RightButton" then
		-- open config
		InterfaceOptionsFrame_OpenToCategory(BrokerGarbage.options)
		BrokerGarbage:ScanInventory()
		
	else
		-- do nothing
	end
end

-- calculates the value of a stack/partial stack of an item
function BrokerGarbage:GetItemValue(itemLink, count)
	local vendorPrice = select(11,GetItemInfo(itemLink))
	local auctionPrice, disenchantPrice, temp
	
	if not count then count = GetItemCount(itemLink, false, false) end
	
	-- gray items on the AH? yeah, right ... shortcut here
	if select(3,GetItemInfo(itemLink)) == 0 then return vendorPrice*count end
	
	-- TODO: set "always use vendor price"
	
	-- calculate auction value
	-- TODO: update/support more
	if IsAddOnLoaded("Auctionator") then
		auctionPrice = Atr_GetAuctionBuyout(itemLink)
		disenchantPrice = Atr_GetDisenchantValue(itemLink)

	elseif IsAddOnLoaded("Auc-Advanced") then
		auctionPrice = AucAdvanced.API.GetMarketValue(itemLink)
	
	else
		auctionPrice = GetAuctionBuyout and GetAuctionBuyout(itemLink) or nil
		if not auctionPrice then
			-- BrokerGarbage:Print("No auction values available!")
		end
	end

	-- TODO: also use DE price when an item is NOT soulbound
	-- can enchant & disenchantPrice & item is at least green & equippable
	local enchanting = GetSpellInfo(7411)
	if IsUsableSpell(enchanting) and disenchantPrice and
			select(3,GetItemInfo(itemLink)) >= 2 and string.find(select(9,GetItemInfo(itemLink)), "INVTYPE") then
		auctionPrice = (disenchantPrice > auctionPrice) and disenchantPrice or auctionPrice
	end
	
	if vendorPrice then
		if auctionPrice and disenchantPrice then
			if auctionPrice > disenchantPrice then
				temp = auctionPrice
			else
				temp = disenchantPrice
			end
		elseif auctionPrice then
			temp = auctionPrice
		else
			temp = 0
		end
		
		if vendorPrice > temp then
			return vendorPrice * count
		else
			return temp * count or 0
		end
	end		
end

-- deletes the item in a given location of your bags. no questions asked
function BrokerGarbage:Delete(itemLink, bag, slot)
	if type(itemLink) == "table" then
		bag = itemLink[2]
		slot = itemLink[3]
		itemLink = itemLink[1]
	end

	PickupContainerItem(bag, slot)
	DeleteCursorItem()					-- comment this line to prevent item deletion
	
	BrokerGarbage:Print(format(BrokerGarbage.locale.itemDeleted, itemLink))
	BrokerGarbage:Debug(itemLink.." deleted. (bag "..bag..", slot "..slot..")")
end

-- scans your inventory for possible junk items and updates LDB display
function BrokerGarbage:ScanInventory()
	BrokerGarbage.inventory = {}
	local cheapestItem
	
	for container = 0,4 do
		for slot = 1, GetContainerNumSlots(container) do
			local itemID = GetContainerItemID(container,slot)
			if itemID then
				-- GetContainerItemInfo sucks big time ... just don't use it for quality IDs!!!!!!!
				local _,count,locked,_,_,canOpen,itemLink = GetContainerItemInfo(container, slot)
				local quality = select(3,GetItemInfo(itemID))
				
				if canOpen and showSpam then
					BrokerGarbage:Print(format(BrokerGarbage.locale.openPlease, select(2,GetItemInfo(itemID))))
				end
				
				if quality and (quality <= BG_GlobalDB.dropQuality or BrokerGarbage:Find(BG_GlobalDB.include, itemID)) 
				  and not BrokerGarbage:Find(BG_GlobalDB.exclude, itemID) then
					local value = BrokerGarbage:GetItemValue(itemLink,count)
					if value ~= 0 then
						local currentItem = {
							bag = container,
							slot = slot,
							itemID = itemID,
							quality = quality,
							count = count,
							value = value,
						}
						
						if not cheapestItem or cheapestItem.value >= value then
							cheapestItem = currentItem
						end
						tinsert(BrokerGarbage.inventory, currentItem)
					end
				end
			end
		end
	end

	if cheapestItem then
		LDB.text = select(2,GetItemInfo(cheapestItem.itemID)).."x".. cheapestItem.count .." (".. BrokerGarbage:FormatMoney(cheapestItem.value) ..")"
	else
		LDB.text = BrokerGarbage.locale.label
	end
end

-- returns the n cheapest items in your bags
function BrokerGarbage:GetCheapest(number)
	if not number then number = 1 end
	local cheapestItems = {}
	for i = 1, number do
		local minPrice, minTable
		for _, itemTable in pairs(BrokerGarbage.inventory) do
			local skip = false
			
			for _, usedTable in pairs(cheapestItems) do
				if usedTable == itemTable then skip = true end
			end
			if not skip and (not minPrice or itemTable.value < minPrice) then
				minPrice = itemTable.value
				minTable = itemTable
			end
		end
		
		if minTable then tinsert(cheapestItems, minTable) end
	end
	
	return cheapestItems
end


-- special functionality
-- ---------------------------------------------------------
-- when at a merchant this will clear your bags of junk (gray quality)
function BrokerGarbage:AutoSell()
	if BG_GlobalDB.autoSellToVendor then		
		local i = 1
		sellValue = 0
		for _, itemTable in pairs(BrokerGarbage.inventory) do
			if (itemTable.quality == 0 and not BrokerGarbage:Find(BG_GlobalDB.exclude, itemTable.itemID)) 
			  or BrokerGarbage:Find(BG_GlobalDB.include, itemTable.itemID) then
				if i == 1 then					
					BrokerGarbage:Debug("locked")
					locked = true
				end
				sellValue = sellValue + itemTable.value
				UseContainerItem(itemTable.bag, itemTable.slot)
				i = i+1
			end
		end
	end
end

-- automatically repair at a vendor
function BrokerGarbage:AutoRepair()
	if BG_GlobalDB.autoRepairAtVendor and CanMerchantRepair() then
		cost = GetRepairAllCost()

		if cost > 0 and GetGuildBankWithdrawMoney() >= cost and not BG_GlobalDB.neverRepairGuildBank then
			RepairAllItems(CanGuildBankRepair())
		elseif cost > 0 then
			RepairAllItems(0)
		end
	else
		cost = 0
	end
end


-- Wishlist
-- ---------------------------------------------------------
-- Notice: When trying to stop BG from auto selling/repairing, hold Shift when adressing a merchant
-- show lootable containers in your bag! make "open items" not as spammy
-- increase/decrease loot treshold with mousewheel
-- restack if necessary
-- make "autosell" list - e.g. mages selling dropped water/food [quickfix: use include list]

-- local selectiveLooting = false
-- local askWhenDeleting = true, askWhenDeletingTreshold