-- Broker_Garbage
--   Author: Ckaotik (Raisa@EU-Die Todeskrallen)
-- created to replace/update GarbageFu for 3.x and further provide LDB support
_, BrokerGarbage = ...

-- Libraries & setting up the LDB
-- ---------------------------------------------------------
local LibQTip = LibStub("LibQTip-1.0")
BrokerGarbage.PT = LibStub("LibPeriodicTable-3.1")

-- notation mix-up for B2FB to work
local LDB = LibStub:GetLibrary("LibDataBroker-1.1"):NewDataObject("Garbage", {
	type	= "data source", 
	icon	= "Interface\\Icons\\achievement_bg_returnxflags_def_wsg",
	label	= "Garbage",
	text 	= BrokerGarbage.locale.label
})

LDB.OnClick = function(...) BrokerGarbage:OnClick(...) end
LDB.OnEnter = function(...) BrokerGarbage:Tooltip(...) end
LDB.OnMouseWheel = function(...) BrokerGarbage:OnScroll(...) end

-- default saved variables
BrokerGarbage.defaultGlobalSettings = {
	-- lists
	-- key is either the itemID -or- the PeriodicTable category string
	exclude = {},
	include = {},
	autoSellList = {},
	forceVendorPrice = {},		-- only global

	-- behavior
	autoSellToVendor = true,
	autoRepairAtVendor = true,
	neverRepairGuildBank = false,
	
	-- default values
	moneyLostByDeleting = 0,	-- total value
	moneyEarned = 0,			-- total value
	tooltipMaxHeight = 220,
	tooltipNumItems = 9,
	dropQuality = 0,
	showMoney = 2,
	
	-- display options
	showAutoSellIcon = true,
	showLost = true,
	showEarned = true,
	-- showWarnings = true,		-- TODO options
	showSource = false,
}

BrokerGarbage.defaultLocalSettings = {
	-- lists
	exclude = {},
	include = {},
	autoSellList = {},

	-- behavior
	neverRepairGuildBank = false,
	
	-- default values
	moneyLostByDeleting = 0,
	moneyEarned = 0,
}

-- internal locals
local debug = false
local locked = false
local loaded = false
local sellValue = 0
local cost = 0
local lastReminder = time()

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
		
		-- wrong player_money event (resulting from repair, not sell)
		-- testing: add a span for wich we recognize this one as repair bill
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
		cost = 0
		locked = false
		BrokerGarbage:Debug("lock released")
		
		BrokerGarbage:ScanInventory()
		
	elseif locked and event == "MERCHANT_CLOSED" then
		-- fallback unlock
		sellValue = 0
		cost = 0
		locked = false
		BrokerGarbage:Debug("lock released")
		
		BrokerGarbage:ScanInventory()
		
	elseif event == "PLAYER_ENTERING_WORLD" then
		BrokerGarbage:CheckSettings()
		
		if not locked and loaded then
			warnings = BrokerGarbage:ScanInventory()
		end
	
	elseif event == "BAG_UPDATE" then
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

local orig_MerchantFrame_UpdateRepairButtons = MerchantFrame_UpdateRepairButtons
function MerchantFrame_UpdateRepairButtons(...)
	orig_MerchantFrame_UpdateRepairButtons(...)
	
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
		iconbutton:SetNormalTexture("Interface\\Icons\\achievement_bg_returnxflags_def_wsg")	-- INV_Crate_05
		iconbutton:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square")
		iconbutton:SetScript("OnClick", BrokerGarbage.AutoSell)
		iconbutton:SetScript("OnEnter", function(self) 
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			GameTooltip:SetText(BrokerGarbage.locale.autoSellTooltip, nil, nil, nil, nil, true)
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
			iconbutton:SetPoint("BOTTOMRIGHT", MerchantRepairItemButton, "BOTTOMLEFT", -4, 0)
		end
		
		iconbutton:Show()
	else
		iconbutton:SetPoint("BOTTOMRIGHT", MerchantBuyBackItemItemButton, "BOTTOMLEFT", -18, 0)
		iconbutton:Show()
	end
	MerchantRepairText:Hide()
end

loaded = true

-- Helper functions
-- ---------------------------------------------------------
function BrokerGarbage:Print(text)
	DEFAULT_CHAT_FRAME:AddMessage("|cffee6622Broker_Garbage|r "..text)
end

function BrokerGarbage:Warning(text)
	if showWarnings and time() - lastReminder >= 5 then
		BrokerGarbage:Print("|cfff0000Warning:|r ", text)
		lastReminder = time()
	end
end

function BrokerGarbage:Debug(...)
  if debug then
	BrokerGarbage:Print("! "..string.join(", ", tostringall(...)))
  end
end

function BrokerGarbage:CheckSettings()
	-- check for settings
	if not BG_GlobalDB then BG_GlobalDB = {} end
	for key, value in pairs(BrokerGarbage.defaultGlobalSettings) do
		if BG_GlobalDB[key] == nil then
			BG_GlobalDB[key] = value
		end
	end
	
	if not BG_LocalDB then BG_LocalDB = {} end
	for key, value in pairs(BrokerGarbage.defaultLocalSettings) do
		if BG_LocalDB[key] == nil then
			BG_LocalDB[key] = value
		end
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

-- joins any number of tables together, one after the other. elements within the input-tables will get mixed, though
function BrokerGarbage:JoinTables(...)
	local result = {}
	local table
	
	for i=1,select("#", ...) do
		table = select(i, ...)
		if table then
			for index, value in pairs(table) do
				result[index] = value
			end
		end
	end
	return result
end

function BrokerGarbage:Count(table)
  local i = 0
  for _, _ in pairs(table) do i = i + 1 end
  return i
end

function BrokerGarbage:ResetMoney(which)
	if which == 0 then
		BG_LocalDB.moneyLostByDeleting = 0
	elseif which == 1 then
		BG_LocalDB.moneyEarned = 0
	end
end

function BrokerGarbage:ResetList(which)
	if which == "exclude" then
		BG_GlobalDB.exclude = {}
	elseif which == "include" then
		BG_GlobalDB.include = {}
	elseif which == "autosell" then
		-- TODO: add to options
		BG_GlobalDB.autoSellList = {}
	end
end

function BrokerGarbage:GetItemID(itemLink)
	local itemID = string.gsub(itemLink, ".*|Hitem:([0-9]*):.*", "%1")
	return tonumber(itemID)
end

function BrokerGarbage:CanDisenchant(itemLink)
	if (itemLink) then
		local _, _, quality, level, _, _, _, count, slot = GetItemInfo(itemLink)

		-- stackables are not DE-able
		if quality and quality >= 2 and 
			string.find(slot, "INVTYPE") and not string.find(slot, "BAG") 
			and (not count or count == 1) then
			
			-- can we DE ourself?
			local enchanting = GetSpellInfo(7411)
			if IsUsableSpell(enchanting) then
				local skill
				for i=1, GetNumSkillLines() do
					local name, _, _, skillRank, _, _, _, _, _, _, _, _, _ = GetSkillLineInfo(i)
					if name == enchanting then 
						skill = skillRank
						BrokerGarbage:Debug("DE Skill", skill)
						break
					end
				end
				
				local requiredSkill = 0
				if level <= 20 then
					requiredSkill = 1
				elseif level <= 60 then
					requiredSkill = 5*5*math.ceil(level/5)-100
				elseif level < 100 then		-- BC starts here
					requiredSkill = 225
				elseif level <= 115 then
					requiredSkill = 275
				elseif level <= 130 then
					requiredSkill = 300
				elseif level <= 200 and quality <= 3 then	-- WotLK starts here
					requiredSkill = 325
				else
					requiredSkill = 375
				end
				BrokerGarbage:Debug("Required DE Skill", requiredSkill)

				if skill >= requiredSkill then
					BrokerGarbage:Debug("Can Diss.")
					return true
				end
				-- if skill is too low, still check if we can send it
			end
			
			-- so we can't DE, but can we send it to someone who may? i.e. is the item soulbound?
			
		end
	end
	return false
end

-- basic functionality from here
-- ---------------------------------------------------------
function BrokerGarbage:Tooltip(wut)
	if BG_GlobalDB.showSource then
		BrokerGarbage.tt = LibQTip:Acquire("BrokerGarbage_TT", 4, "LEFT", "RIGHT", "RIGHT", "CENTER")
	else
		BrokerGarbage.tt = LibQTip:Acquire("BrokerGarbage_TT", 3, "LEFT", "RIGHT", "RIGHT")
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
	BrokerGarbage.tt:SmartAnchorTo(wut)
	BrokerGarbage.tt:SetAutoHideDelay(0.25, wut)

	-- Show it, et voilà !
	BrokerGarbage.tt:Show()
	BrokerGarbage.tt:UpdateScrolling(BG_GlobalDB.tooltipMaxHeight)
end

function BrokerGarbage:HideTT()
	if BrokerGarbage.tt and BrokerGarbage.tt:IsMouseOver() then 
		return 
	end
	BrokerGarbage.tt:Hide()
	
	-- Release the tooltip
	LibQTip:Release(BrokerGarbage.tt)
	BrokerGarbage.tt = nil
end

function BrokerGarbage:OnScroll(self, direction)
	BrokerGarbage:Debug("Scroll!", direction)
	--BG_GlobalDB.dropQuality
end

-- onClick function for when you ... click. works for both, the LDB plugin -and- tooltip lines
function BrokerGarbage:OnClick(itemTable, button)	
	-- handle LDB clicks seperately
	if not itemTable.itemID or type(itemTable.itemID) ~= "number" then
		itemTable = BrokerGarbage.cheapestItem
	end
	
	-- handle different clicks
	if itemTable and IsShiftKeyDown() then
		-- delete item
		BrokerGarbage:Debug("SHIFT-Click!")
		BrokerGarbage:Delete(select(2,GetItemInfo(itemTable.itemID)), itemTable.bag, itemTable.slot)
		BG_GlobalDB.moneyLostByDeleting = BG_GlobalDB.moneyLostByDeleting + itemTable.value
		BG_LocalDB.moneyLostByDeleting = BG_GlobalDB.moneyLostByDeleting + itemTable.value
		
	elseif itemTable and IsControlKeyDown() then
		-- add to exclude list
		BrokerGarbage:Debug("CTRL-Click!")
		BG_LocalDB.exclude[itemTable.itemID] = true
		BrokerGarbage:Print(format(BrokerGarbage.locale.addedToSaveList, select(2,GetItemInfo(itemTable.itemID))))
		
		if BrokerGarbage.optionsLoaded then
			BrokerGarbage:ListOptionsUpdate("exclude")
		end
		
	elseif button == "RightButton" then
		-- open config
		InterfaceOptionsFrame_OpenToCategory(BrokerGarbage.options)
		
	elseif IsAltKeyDown() then
		-- add to force vendor price list
		BrokerGarbage:Debug("ALT-Click!")
		BG_GlobalDB.forceVendorPrice[itemTable.itemID] = true
		BrokerGarbage:Print(format(BrokerGarbage.locale.addedToPriceList, select(2,GetItemInfo(itemTable.itemID))))
		
		if BrokerGarbage.optionsLoaded then
			BrokerGarbage:ListOptionsUpdate("forceprice")
		end
		BrokerGarbage:ScanInventory()
		
	else
		-- do nothing
	end
	
	BrokerGarbage:ScanInventory()
end

-- calculates the value of a stack/partial stack of an item
function BrokerGarbage:GetItemValue(itemLink, count)
	local vendorPrice = select(11,GetItemInfo(itemLink))
	local itemID = BrokerGarbage:GetItemID(itemLink)
	local auctionPrice, disenchantPrice, temp, source
	local DE = false
	
	if vendorPrice == 0 then vendorPrice = nil end
	if not count then count = GetItemCount(itemLink, false, false) end
	
	-- gray items on the AH / auto sell items have only vendor value (to not screw up moneyEarned/moneyLost)
	local inCategory, useVendorPrice
	for setName,_ in pairs(BrokerGarbage:JoinTables(BG_GlobalDB.autoSellList, BG_LocalDB.autoSellList, BG_GlobalDB.forceVendorPrice)) do
		if type(setName) == "string" then
			_, inCategory = BrokerGarbage.PT:ItemInSet(itemID, setName)
			if inCategory and inCategory ~= "" then
				useVendorPrice = true
				break
			end
		elseif type(setName) == "number" then
			if setName == itemID then
				useVendorPrice = true
				break
			end
		end
	end
	if select(3,GetItemInfo(itemLink)) == 0 or useVendorPrice then		
		return vendorPrice and vendorPrice*count or nil, "|cFFF5DEB3V" -- orange
	end
	
	-- calculate auction value
	if IsAddOnLoaded("Auctionator") then
		auctionPrice = Atr_GetAuctionBuyout(itemLink)
		disenchantPrice = Atr_GetDisenchantValue(itemLink)
	
	elseif IsAddOnLoaded("AuctionLite") then
		auctionPrice = AuctionLite:GetAuctionValue(itemLink)
		disenchantPrice = AuctionLite:GetDisenchantValue(itemLink)
		
	elseif IsAddOnLoaded("WOWEcon_PriceMod")  then
		auctionPrice = Wowecon.API.GetAuctionPrice_ByLink(itemLink, Wowecon.API.SERVER_PRICE)
		
		disenchantPrice = 0
		local DeData = Wowecon.API.GetDisenchant_ByLink(itemLink)
		for i,data in pairs(DeData) do
			disenchantPrice = disenchantPrice + (Wowecon.API.GetAuctionPrice_ByLink(data[1], Wowecon.API.SERVER_PRICE) * data[3])
		end

	elseif IsAddOnLoaded("Auc-Advanced") then
		auctionPrice = AucAdvanced.API.GetMarketValue(itemLink)
		-- TODO: get enchantrix values
		
	else
		auctionPrice = GetAuctionBuyout and GetAuctionBuyout(itemLink) or nil
		disenchantPrice = GetDisenchantValue and GetDisenchantValue(itemLink) or nil
		
		-- no auctionPrice => no auction addon loaded
	end

	-- DE items might be worth more than auction selling
	if BrokerGarbage:CanDisenchant(itemLink) then
		DE = true
		--auctionPrice = (disenchantPrice > auctionPrice) and disenchantPrice or auctionPrice
	end
	
	if vendorPrice then
		if auctionPrice and disenchantPrice and DE then
			if auctionPrice > disenchantPrice then
				temp = auctionPrice
				source = "|cFF9F9F5FA"	-- greenish
			else
				temp = disenchantPrice
				source = "|cFF7171C6DE"	-- purple
			end
		elseif auctionPrice then
			temp = auctionPrice
			source = "|cFF9F9F5FA" -- greenish
		else
			temp = 0
		end
		
		-- return highest price found
		if vendorPrice > temp then
			return vendorPrice * count, "|cFFF5DEB3V" -- orange
		else
			return temp * count or 0, source
		end	
	else
		return nil
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
	local warnings = {}
	
	for container = 0,4 do
		for slot = 1, GetContainerNumSlots(container) do
			local itemID = GetContainerItemID(container,slot)
			if itemID then
				-- GetContainerItemInfo sucks big time ... just don't use it for quality IDs!!!!!!!
				local _,count,locked,_,_,canOpen,itemLink = GetContainerItemInfo(container, slot)
				local quality = select(3,GetItemInfo(itemID))
				
				if canOpen and showWarnings then
					tinsert(warnings, format(BrokerGarbage.locale.openPlease, 
						select(2,GetItemInfo(itemID))))
				end
				
				-- check if this item belongs to an excluded category
				local inCategory, skip
				for setName,_ in pairs(BrokerGarbage:JoinTables(BG_GlobalDB.exclude, BG_LocalDB.exclude)) do
					if type(setName) == "string" then
						_, inCategory = BrokerGarbage.PT:ItemInSet(itemID, setName)
					end
					-- item is on save list, skip
					if inCategory then
						skip = true
						break
					end
				end
				inCategory = nil
				if not skip then
					for setName,_ in pairs(BrokerGarbage:JoinTables(BG_GlobalDB.autoSellList, BG_LocalDB.autoSellList, BG_LocalDB.include, BG_GlobalDB.include)) do
						if type(setName) == "string" then
							_, inCategory = BrokerGarbage.PT:ItemInSet(itemID, setName)
						end
						if inCategory then inCategory = setName; break end
					end
				end
				
				if quality and 
					(quality <= BG_GlobalDB.dropQuality or inCategory
					or BG_GlobalDB.include[itemID] or BG_LocalDB.include[itemID]
					or BG_GlobalDB.autoSellList[itemID] or BG_LocalDB.autoSellList[itemID]) 
					and not BG_GlobalDB.exclude[itemID] and not BG_LocalDB.exclude[itemID] and not skip then	-- save excluded items!!!
					
					local force = false
					local value, source = BrokerGarbage:GetItemValue(itemLink,count)
					-- make included items appear in tooltip list as "forced"
					if BG_GlobalDB.include[itemID] or BG_LocalDB.include[itemID]
						or BG_GlobalDB.include[inCategory] or BG_LocalDB.include[inCategory] then
						if not value then value = 0 end
						force = true
						source = "|cFF8C1717I"	-- overwrites former value, I as in "include"
					end
					if value then
						local currentItem = {
							bag = container,
							slot = slot,
							itemID = itemID,
							quality = quality,
							count = count,
							value = value,
							source = source,
							force = force,
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
		LDB.text = format("%sx%d (%s)", 
			select(2,GetItemInfo(cheapestItem.itemID)),
			cheapestItem.count,
			BrokerGarbage:FormatMoney(cheapestItem.value))
		BrokerGarbage.cheapestItem = cheapestItem
	else
		LDB.text = BrokerGarbage.locale.label
		BrokerGarbage.cheapestItem = nil
	end
	
	return warnings
end

-- returns the n cheapest items in your bags
function BrokerGarbage:GetCheapest(number)
	if not number then number = 1 end
	local cheapestItems = {}
	
	for i = 1, number do
		for _, itemTable in pairs(BrokerGarbage.inventory) do
			local skip = false
			
			for _, usedTable in pairs(cheapestItems) do
				if usedTable == itemTable then skip = true end
			end
				
			if not skip and itemTable.force then
				tinsert(cheapestItems, itemTable)
			end
		end
	end
	
	if #cheapestItems < number then
		local minPrice, minTable
		
		for i = #cheapestItems +1, number do
			for _, itemTable in pairs(BrokerGarbage.inventory) do
				local skip = false
				
				for _, usedTable in pairs(cheapestItems) do
					if usedTable.itemID == itemTable.itemID then 
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
		local i = 1
		sellValue = 0
		for _, itemTable in pairs(BrokerGarbage.inventory) do
			local inCategory
			for setName,_ in pairs(BrokerGarbage:JoinTables(BG_GlobalDB.exclude, BG_LocalDB.exclude)) do
				if type(setName) == "string" then
					_, inCategory = BrokerGarbage.PT:ItemInSet(itemTable.itemID, setName)
				end
				-- item is on save list, skip
				if inCategory then
					BrokerGarbage:Debug(itemTable.itemID,"in set", inCategory, "on exclude list")
					skip = true
					break
				end
			end
			if not skip then
				for setName,_ in pairs(BrokerGarbage:JoinTables(BG_LocalDB.autoSellList, BG_GlobalDB.autoSellList)) do
					if type(setName) == "string" then
						_, inCategory = BrokerGarbage.PT:ItemInSet(itemTable.itemID, setName)
					end
					if inCategory then BrokerGarbage:Debug(itemTable.itemID,"in set", inCategory, "on autosell");break end
				end
			end
			
			if not (BG_GlobalDB.exclude[itemTable.itemID] or BG_LocalDB.exclude[itemTable.itemID] or skip) 
				and itemTable.value ~= 0 and (itemTable.quality == 0 or inCategory 
				or BG_GlobalDB.autoSellList[itemTable.itemID] or BG_LocalDB.autoSellList[itemTable.itemID]) then
			
				if i == 1 then					
					BrokerGarbage:Debug("locked")
					locked = true
				end
				
				sellValue = sellValue + itemTable.value
				BG_GlobalDB.moneyEarned = BG_GlobalDB.moneyEarned + itemTable.value
				BG_LocalDB.moneyEarned = BG_LocalDB.moneyEarned + itemTable.value
				
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
-- show lootable containers in your bag! make "open items" not as spammy
-- increase/decrease loot treshold with mousewheel on LDB
-- restack if necessary
-- ask before deleting / treshold
-- search list frames (similar to gnomishvendorshrinker)
-- fubar_garbagefu: Soulbound, Quest, Bind on Pickup, Bind on Equip/Use.
-- ignore special bags
-- drop-beyond-treshold: only keep 5 soulshards
-- feature: selective looting (only crafting materials, greens+ , ...)