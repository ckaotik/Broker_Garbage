-- Broker_Garbage
--   Author: Ckaotik (Raisa@EU-Die Todeskrallen)
-- created to replace/update GarbageFu for 3.x and further provide LDB support
_, BrokerGarbage = ...

-- Libraries & setting up the LDB
-- ---------------------------------------------------------
local LibQTip = LibStub("LibQTip-1.0")
BrokerGarbage.PT = LibStub("LibPeriodicTable-3.1")

-- notation mix-up for Broker2FuBar to work
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
	-- lists :: key is either the itemID -or- the PeriodicTable category string
	exclude = {},
	include = {},
	autoSellList = {},
	forceVendorPrice = {},		-- only global

	-- behavior
	autoSellToVendor = true,
	autoRepairAtVendor = true,
	neverRepairGuildBank = false,
	useLootManager = false,
	restackIfNeeded = true,
	restackFullInventory = false,
	autoLoot = false,
	autoLootSkinning = true,
	autoLootFishing = true,
	autoLootPickpocket = true,
	autoDestroy = false,
	tooFewSlots = 0,
	openContainers = true,
	openClams = true,
	
	-- default values
	tooltipMaxHeight = 220,
	tooltipNumItems = 9,
	dropQuality = 0,
	showMoney = 2,
	
	-- statistic values
	moneyLostByDeleting = 0,
	moneyEarned = 0,
	itemsSold = 0,
	itemsDropped = 0,
	
	-- display options
	showAutoSellIcon = true,
	reportNothingToSell = true,
	showLost = true,
	showEarned = true,
	LDBformat = "%1$sx%2$d (%3$s)",
	-- showWarnings = true,		-- TODO
	showSource = false,
}

BrokerGarbage.defaultLocalSettings = {
	-- lists
	exclude = {},
	include = {},
	autoSellList = {},

	-- behavior
	neverRepairGuildBank = false,
	selectiveLooting = false,
	itemMinValue = 0,
	
	-- default values
	moneyLostByDeleting = 0,
	moneyEarned = 0,
}

-- internal locals
local debug = false
local locked = false
local loaded = false
local sellValue = 0		-- represents the actual value that we sold stuff for, opposed to BrokerGarbage.toSellValue which shows the maximum we could sell - imagine someone closing the merchant window. sellValue will then hold the real value we're interested in
local cost = 0
local lastReminder = time()

BrokerGarbage.tt = nil
BrokerGarbage.warnings = {}
BrokerGarbage.tagAuction	= "|cFF2bff58A"		-- green
BrokerGarbage.tagVendor		= "|cFFff9c5aV"		-- orange
BrokerGarbage.tagVendorList	= "|cFFff592dV"		-- slightly darker orange
BrokerGarbage.tagDisenchant	= "|cFFe052ffD"		-- purple
BrokerGarbage.tagInclude	= "|cFFFFFFFFI"		-- white

BrokerGarbage.clams = {15874, 5523, 5524, 7973, 24476, 36781, 45909}
BrokerGarbage.playerClass = select(2,UnitClass("player"))

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
		
	elseif locked and event == "MERCHANT_CLOSED" then
		-- fallback unlock
		cost = 0
		sellValue = 0
		BrokerGarbage.toSellValue = 0
		locked = false
		BrokerGarbage:Debug("lock released")
		
		BrokerGarbage:ScanInventory()
		
	elseif event == "PLAYER_ENTERING_WORLD" then
		BrokerGarbage:CheckSettings()
		
		if not locked and loaded then
			BrokerGarbage:ScanInventory()
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
loaded = true

-- Helper functions
-- ---------------------------------------------------------
function BrokerGarbage:Print(text)
	DEFAULT_CHAT_FRAME:AddMessage("|cffee6622Broker_Garbage|r "..text)
end

function BrokerGarbage:Warning(text)
	if BG_GlobalDB.showWarnings and time() - lastReminder >= 5 then
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
	local first = false
	if not BG_GlobalDB then BG_GlobalDB = {}; first = true end
	for key, value in pairs(BrokerGarbage.defaultGlobalSettings) do
		if BG_GlobalDB[key] == nil then
			BG_GlobalDB[key] = value
		end
	end
	
	if not BG_LocalDB then BG_LocalDB = {}; first = true end
	for key, value in pairs(BrokerGarbage.defaultLocalSettings) do
		if BG_LocalDB[key] == nil then
			BG_LocalDB[key] = value
		end
	end
	
	if first then
		BrokerGarbage:CreateDefaultLists()
	end
end

BrokerGarbage.tradeSkills = {
	[2] = "Leatherworking",
	[3] = "Tailoring",
	[4] = "Engineering",
	[5] = "Blacksmithing",
	[6] = "Cooking",
	[7] = "Alchemy",
	[8] = "First Aid",
	[9] = "Enchanting",
	[10] = "Fishing",
	[11] = "Jewelcrafting",
	[12] = "Inscription",
}
-- returns original English names for non-English locales
function BrokerGarbage:UnLocalize(skillName)
	if not skillName then return nil end
	if string.find(GetLocale(), "en") then return skillName end
	
	-- crafting skills
	local searchString = ""
	for i=2,12 do
		searchString = select(i, GetAuctionItemSubClasses(9))
		if string.find(skillName, searchString) then
			return BrokerGarbage.tradeSkills[i]
		end
	end
	
	-- gathering skills
	local skill
	if skillName == GetSpellInfo(8613) then
		skill = "Skinning"
	elseif skillName == GetSpellInfo(2575) then
		skill = "Mining"
	else
		-- herbalism sucks /dump BrokerGarbage:UnLocalize("Kräuterkunde")
		searchString = select(6, GetAuctionItemSubClasses(6))
		if string.find(skillName, searchString) then
			skill = "Herbalism"
		end
	end
	
	return skill
end

-- inserts some basic list settings
function BrokerGarbage:CreateDefaultLists()
	BG_GlobalDB.include[46106] = true		-- argentum lance
	BG_GlobalDB.include[6265] = 20			-- soulshards
	BG_GlobalDB.include["Consumable.Water.Conjured"] = true
	BG_GlobalDB.forceVendorPrice["Consumable.Food.Edible"] = true
	BG_GlobalDB.forceVendorPrice["Consumable.Water.Basic"] = true
	
	-- tradeskills
	local tradeSkills = BrokerGarbage:CheckSkills()
	local numSkills = #tradeSkills or 0
	for i = 1, numSkills do
		local englishSkill = BrokerGarbage:UnLocalize(tradeSkills[i][1])
		if englishSkill then
			if tradeSkills[i][2] then
				BG_LocalDB.exclude["Tradeskill.Gather."..englishSkill] = true
			else
				BG_LocalDB.exclude["Tradeskill.Mat.ByProfession."..englishSkill] = true
			end
		end
	end
	
	-- class specific
	if BrokerGarbage.playerClass == "HUNTER" then	
		BG_LocalDB.exclude["Misc.Reagent.Ammo"] = true
	elseif BrokerGarbage.playerClass == "WARRIOR" or BrokerGarbage.playerClass == "ROGUE" or BrokerGarbage.playerClass == "DEATHKNIGHT" then
		BG_LocalDB.autoSellList["Consumable.Water"] = true
	elseif BrokerGarbage.playerClass == "SHAMAN" then
		BG_LocalDB.include[17058] = 20		-- fish oil
		BG_LocalDB.include[17057] = 20		-- scales
	end
	BG_LocalDB.exclude["Misc.Reagent.Class."..string.gsub(string.lower(BrokerGarbage.playerClass), "^.", string.upper)] = true
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

function BrokerGarbage:IsItem(itemID, itemTable)
	if type(itemTable) == "number" then
		return itemID == itemTable
		
	else
		for _, ID in pairs(itemTable) do
			if itemID == ID then
				return true
			end
		end
	end
	
	return false
end

-- joins any number of tables together, one after the other. elements within the input-tables will get mixed, though
function BrokerGarbage:JoinTables(...)
	local result = {}
	local tab
	
	for i=1,select("#", ...) do
		tab = select(i, ...)
		if tab then
			for index, value in pairs(tab) do
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

function BrokerGarbage:ResetMoney(which, global)
	if not global then
		if which == "lost" then
			BG_LocalDB.moneyLostByDeleting = 0
		elseif which == "earned" then
			BG_LocalDB.moneyEarned = 0
		end
	else
		if which == "lost" then
			BG_GlobalDB.moneyLostByDeleting = 0
		elseif which == "earned" then
			BG_GlobalDB.moneyEarned = 0
		end
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

-- resets statistics. global = true -> global, otherwise local
function BrokerGarbage:ResetAll(global)
	if global then
		BG_GlobalDB.moneyEarned = 0
		BG_GlobalDB.moneyLostByDeleting = 0
		BG_GlobalDB.itemsDropped = 0
		BG_GlobalDB.itemsSold = 0
	else
		BG_LocalDB.moneyEarned = 0
		BG_LocalDB.moneyLostByDeleting = 0
	end
end

-- returns an item's itemID
function BrokerGarbage:GetItemID(itemLink)
	if not itemLink then return end
	local itemID = string.gsub(itemLink, ".*|Hitem:([0-9]*):.*", "%1")
	return tonumber(itemID)
end

-- returns the skill rank of a given tradeskill, or nil
function BrokerGarbage:GetTradeSkill(skillName)
	for i=1, GetNumSkillLines() do
		local name, _, _, skillRank, _, _, _, _, _, _, _, _, _ = GetSkillLineInfo(i)
		if name == skillName then 
			return skillRank
		end
	end
	return nil
end

-- returns all tradeskills found
function BrokerGarbage:CheckSkills()
	local result = {}
	for i=1, GetNumSkillLines() do
		local name, _, _, skillRank, _, _, _, tradeSkill = GetSkillLineInfo(i)
		if tradeSkill then
			local isGather = true
			if name == GetSpellInfo(2259) or name == GetSpellInfo(2018) or name == GetSpellInfo(7411) or name == GetSpellInfo(4036) or name == GetSpellInfo(45357) or name == GetSpellInfo(25229) or name == GetSpellInfo(2108) or name == GetSpellInfo(3908) then 
				-- crafting skill
				isGather = false
			end
			tinsert(result, {name, isGather, skillRank})
		end
	end
	if result == {} then return nil else return result end
end

local scanTooltip = CreateFrame('GameTooltip', 'BGItemScanTooltip', UIParent, 'GameTooltipTemplate')
function BrokerGarbage:CanDisenchant(itemLink)
	if (itemLink) then
		local _, _, quality, level, _, _, _, count, bagSlot = GetItemInfo(itemLink)

		-- stackables are not DE-able
		if quality and quality >= 2 and 
			string.find(bagSlot, "INVTYPE") and not string.find(bagSlot, "BAG") 
			and (not count or count == 1) then
			
			-- can we DE ourself?
			local enchanting = select(1,GetSpellInfo(7411))
			if IsUsableSpell(enchanting) then
				local skill = BrokerGarbage:GetTradeSkill(enchanting) or 0
				
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

				if skill >= requiredSkill then
					return true
				end
				-- if skill is too low, still check if we can send it
			end
			
			-- so we can't DE, but can we send it to someone who may? i.e. is the item not soulbound?
			if BrokerGarbage.checkItem then
				return not BrokerGarbage:IsItemSoulbound(itemLink, BrokerGarbage.checkItem.bag, BrokerGarbage.checkItem.slot)
			else 
				return not BrokerGarbage:IsItemSoulbound(itemLink)
			end
		end
	end
	return false
end

-- returns true if the given item is soulbound
function BrokerGarbage:IsItemSoulbound(itemLink, bag, slot)
	scanTooltip:SetOwner(UIParent, 'ANCHOR_NONE')
	local searchString
	
	if not (bag and slot) then
		-- check if item is BOP
		scanTooltip:SetHyperlink(itemLink)
		searchString = ITEM_BIND_ON_PICKUP
	else
		-- check if item is soulbound
		scanTooltip:SetBagItem(bag, slot)
		searchString = ITEM_SOULBOUND
	end

	local numLines = scanTooltip:NumLines()
	for i = 1, numLines do
		local leftLine = getglobal("BGItemScanTooltip".."TextLeft"..i)
		local leftLineText = leftLine:GetText()
		
		if string.find(leftLineText, searchString) then
			return true
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
		BG_GlobalDB.moneyLostByDeleting 	= BG_GlobalDB.moneyLostByDeleting + itemTable.value
		BG_LocalDB.moneyLostByDeleting 		= BG_LocalDB.moneyLostByDeleting + itemTable.value
		
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
	local itemID = BrokerGarbage:GetItemID(itemLink)
	local DE = BrokerGarbage:CanDisenchant(itemLink)
	local vendorPrice = select(11,GetItemInfo(itemLink))
	local auctionPrice, disenchantPrice, source
	
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
		return vendorPrice and vendorPrice*count or nil, BrokerGarbage.tagVendor
	end
	
	-- calculate auction value
	if IsAddOnLoaded("Auctionator") then
		auctionPrice = Atr_GetAuctionBuyout(itemLink)
		disenchantPrice = DE and Atr_GetDisenchantValue(itemLink)
	
	elseif IsAddOnLoaded("AuctionLite") then
		auctionPrice = AuctionLite:GetAuctionValue(itemLink)
		disenchantPrice = DE and AuctionLite:GetDisenchantValue(itemLink)
		
	elseif IsAddOnLoaded("WOWEcon_PriceMod")  then
		auctionPrice = Wowecon.API.GetAuctionPrice_ByLink(itemLink, Wowecon.API.SERVER_PRICE)
		
		disenchantPrice = 0
		local DeData = Wowecon.API.GetDisenchant_ByLink(itemLink)
		for i,data in pairs(DeData) do
			disenchantPrice = disenchantPrice + (Wowecon.API.GetAuctionPrice_ByLink(data[1], Wowecon.API.SERVER_PRICE) * data[3])
		end
		disenchantPrice = DE and disenchantPrice

	elseif IsAddOnLoaded("Auc-Advanced") then
		auctionPrice = AucAdvanced.API.GetMarketValue(itemLink)
		-- TODO: get enchantrix values
		
	else
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
	
	-- recommend the location with the largest ratio that is NOT a specialty bag
	table.sort(locations, function(a,b)
		if a.bagType == 0 and b.bagType ~= 0 then
			return true
		else
			-- return a.ratio > b.ratio
			return a.count < b.count
		end
	end)
	return locations
end

-- deletes the item in a given location of your bags. takes either link/bag/slot or an itemTable as created by GetCheapest()
function BrokerGarbage:Delete(itemLink, bag, slot)
	if type(itemLink) == "table" then
		bag = itemLink[1].bag
		slot = itemLink[1].slot
		itemLink = select(2,GetItemInfo(itemLink[1].itemID))
	end

	-- security check
	local itemID = GetContainerItemID(bag, slot)
	if not select(2,GetItemInfo(itemID)) == itemLink then return end
	
	PickupContainerItem(bag, slot)
	DeleteCursorItem()					-- comment this line to prevent item deletion
	BG_GlobalDB.itemsDropped = BG_GlobalDB.itemsDropped + 1
	
	BrokerGarbage:Print(format(BrokerGarbage.locale.itemDeleted, itemLink))
	BrokerGarbage:Debug(itemLink.." deleted. (bag "..bag..", slot "..slot..")")
end

-- scans your inventory for possible junk items and updates LDB display
function BrokerGarbage:ScanInventory()
	BrokerGarbage.inventory = {}
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
					local _,count,locked,_,_,_,itemLink = GetContainerItemInfo(container, slot)
					local quality = select(3,GetItemInfo(itemID))
					local isClam = BrokerGarbage:IsItem(itemID, BrokerGarbage.clams)
					
					if canOpen or isClam then
						local _,_,_,_,_,type,subType,_,_,tex = GetItemInfo(itemID)
						tinsert(BrokerGarbage.unopened, {
							bag = container,
							slot = slot,
							itemID = itemID,
							clam = isClam,
						})
						if BG_GlobalDB.showWarnings then
							local notice = format(BrokerGarbage.locale.openPlease, select(2,GetItemInfo(itemID)))
							if not BrokerGarbage:Find(BrokerGarbage.warnings, notice) then
								tinsert(BrokerGarbage.warnings, notice)
							end
						end
					end
					
					-- check if this item belongs to an excluded category
					local isExclude, skip
					for setName,_ in pairs(BrokerGarbage:JoinTables(BG_GlobalDB.exclude, BG_LocalDB.exclude)) do
						if type(setName) == "string" then
							_, isExclude = BrokerGarbage.PT:ItemInSet(itemID, setName)
						end
						if isExclude then
							skip = true; break
						end
					end

					local isSell, isInclude
					-- this saves excluded items
					if not skip and not BG_GlobalDB.exclude[itemID] and not BG_LocalDB.exclude[itemID] then
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
						
						-- ----------------------------------------------------------------------
						
						-- get price and tag
						BrokerGarbage.checkItem = {
							bag = container,
							slot = slot,
							itemID = itemID,
						}
						local value, source = BrokerGarbage:GetItemValue(itemLink, count)
						BrokerGarbage.checkItem = nil
						if isInclude or BG_GlobalDB.include[itemID] or BG_LocalDB.include[itemID] then
							-- Include List item
							force = true
							
							local limited = BrokerGarbage:Find(limitedItemsChecked, itemID)
							if not limited then
								if BG_GlobalDB.include[itemID] and type(BG_GlobalDB.include[itemID]) == "number"
									or BG_LocalDB.include[itemID] and type(BG_LocalDB.include[itemID]) == "number" then
									
									-- this is a limited item - only check it once
									tinsert(limitedItemsChecked, itemID)
									limited = true
									
									local stackSize = select(8, GetItemInfo(itemID))
									local limit = tonumber(BG_GlobalDB.include[itemID]) or tonumber(BG_LocalDB.include[itemID])
									local saveStacks = ceil(limit/stackSize)
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
								end
							end
							
							if not limited then
								value = value or 0
								source = BrokerGarbage.tagInclude
							else 
								value = nil
							end
						
						elseif isSell or BG_GlobalDB.autoSellList[itemID] or BG_LocalDB.autoSellList[itemID] then
							-- AutoSell List item
							value = select(11,GetItemInfo(itemID))
							source = BrokerGarbage.tagVendorList
						
						--elseif quality and quality <= BG_GlobalDB.dropQuality then
							-- regular gray/junk treshold item
							--force = false
						end
							
						if value then
							-- save if we have something sellable
							if quality == 0 or isSell
								or BG_GlobalDB.autoSellList[itemID] or BG_LocalDB.autoSellList[itemID] then
								BrokerGarbage.toSellValue = BrokerGarbage.toSellValue + value
							end
						
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
							
							tinsert(BrokerGarbage.inventory, currentItem)
						end
					end
				end
			end
		end
	end
	
	local cheapestItem = BrokerGarbage:GetCheapest()
	
	if cheapestItem[1] then
		LDB.text = format(BG_GlobalDB.LDBformat, 
			select(2,GetItemInfo(cheapestItem[1].itemID)),
			cheapestItem[1].count,
			BrokerGarbage:FormatMoney(cheapestItem[1].value),
			BrokerGarbage.totalFreeSlots,
			BrokerGarbage.totalBagSpace)
		BrokerGarbage.cheapestItem = cheapestItem[1]
	else
		LDB.text = BrokerGarbage.locale.label
		BrokerGarbage.cheapestItem = nil
	end
	
	return warnings
end

-- returns the n cheapest items in your bags  in a table
function BrokerGarbage:GetCheapest(number)
	if not number then number = 1 end
	local cheapestItems, temp = {}, {}
	
	-- get forced items
	for _, itemTable in pairs(BrokerGarbage.inventory) do
		local skip = false
		
		for _, usedTable in pairs(cheapestItems) do
			if usedTable == itemTable then skip = true end
		end
			
		if not skip and itemTable.force then
			tinsert(temp, itemTable)
		end
	end
	table.sort(temp, function(a, b)
		return a.value < b.value
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
				BG_GlobalDB.itemsSold = BG_GlobalDB.itemsSold + 1
				i = i+1
			end
		end
		
		if self == _G["BrokerGarbage_SellIcon"] then
			BrokerGarbage:Debug("AutoSell on Sell Icon.", BrokerGarbage:FormatMoney(sellValue), BrokerGarbage:FormatMoney(BrokerGarbage.toSellValue))
			
			if BrokerGarbage.toSellValue == 0 and BG_GlobalDB.reportNothingToSell then
				BrokerGarbage:Print(BrokerGarbage.locale.reportNothingToSell)
			elseif BrokerGarbage.toSellValue ~= 0 and not BG_GlobalDB.autoSellToVendor then
				BrokerGarbage:Print(format(BrokerGarbage.locale.sell, BrokerGarbage:FormatMoney(BrokerGarbage.toSellValue)))
			end
			_G["BrokerGarbage_SellIcon"]:GetNormalTexture():SetDesaturated(true)
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
-- tooltip: if item has a count treshold set, don't show if we're below that treshold
-- show lootable containers in your bag! make "open items" not as spammy
-- increase/decrease loot treshold with mousewheel on LDB
-- restack if necessary	-> PickupContainerItem // SplitContainerItem
-- fubar_garbagefu: Soulbound, Quest, Bind on Pickup, Bind on Equip/Use.
-- ignore special bags