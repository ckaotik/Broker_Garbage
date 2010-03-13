-- This is BrokerGarbage's Loot Manager - inspired by KarniCrap
-- It allows you to manage auto looting and dropping of "too many" items
_, BrokerGarbage = ...

-- register events
local function eventHandler(self, event, ...)
	if not BG_GlobalDB.useLootManager then return end
	
	if event == "CHAT_MSG_LOOT" then
		if strfind(arg1, BrokerGarbage.locale.You) and BG_GlobalDB.autoDestroy then
			BrokerGarbage:AutoDestroy()
		end
		
	elseif event == "LOOT_OPENED" then
		local numSlots = 0
		-- restack (relevant) inventory
		if BG_GlobalDB.restackIfNeeded then
			local justStacked = {}
			if BG_GlobalDB.restackFullInventory then
				for container = 0, 4 do
					numSlots = GetContainerNumSlots(container)
					if numSlots then
						for slot = 1, numSlots do
							local itemID = GetContainerItemID(container,slot)
							if itemID and not BrokerGarbage:Find(justStacked, itemID) then
								BrokerGarbage:Restack(itemID)
								table.insert(justStacked, itemID)
							end
						end
					end
				end
			else
				for i, itemTable in pairs(BrokerGarbage.inventory) do
					if not BrokerGarbage:Find(justStacked, itemTable.itemID) then
						BrokerGarbage:Restack(itemTable.itemID)
						table.insert(justStacked, itemTable.itemID)
					end
				end
			end
		end
		-- looting
		if BG_LocalDB.selectiveLooting then
			local autoloot = arg1
			if BrokerGarbage.currentRestackItems ~= nil then
				BrokerGarbage.afterRestack = function()
					BrokerGarbage:SelectiveLooting(autoloot)
				end
			else
				BrokerGarbage:SelectiveLooting(autoloot)
			end
		end
	
	elseif event == "LOOT_CLOSED" then
		if BG_LocalDB.selectiveLooting then
			BrokerGarbage:CheckAndClearInv()
		end
		
		if BG_GlobalDB.openContainers then
			BrokerGarbage:OpenContainers()
		end
		
	elseif event == "ITEM_UNLOCKED" then
		-- keep restacking
		if BrokerGarbage:RestackStep() then
			-- wait for next update
			BrokerGarbage:Debug("Still restacking...", BrokerGarbage.currentRestackItems)
		else
			-- we're done
			frame:UnregisterEvent("ITEM_UNLOCKED")
			BrokerGarbage.currentRestackItems = nil
			BrokerGarbage:Debug("Unregistered ITEM_UNLOCKED")
			
			if BrokerGarbage.afterRestack ~= nil then
				BrokerGarbage:afterRestack()
				BrokerGarbage.afterRestack = nil
			end
		end
	end
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("CHAT_MSG_LOOT")
frame:RegisterEvent("LOOT_OPENED")
frame:RegisterEvent("LOOT_CLOSED")
frame:SetScript("OnEvent", eventHandler)

-- ---------------------------------------------------------
-- Helper functions
-- ---------------------------------------------------------
-- restacks items so when deleting you lose as few items as possible
function BrokerGarbage:Restack(itemID)
	if BrokerGarbage.currentRestackItems then
		tinsert(BrokerGarbage.currentRestackItems, itemID)
	else
		BrokerGarbage.currentRestackItems = { itemID }
		if BrokerGarbage:RestackStep() then
			-- wait for moved items
			frame:RegisterEvent("ITEM_UNLOCKED")
		else
			-- nothing to restack
			if BrokerGarbage.afterRestack ~= nil then
				BrokerGarbage:afterRestack()
				BrokerGarbage.afterRestack = nil
			end
		end
	end
end

local function NextRestackStep()
	-- go to next item if there is one
	tremove(BrokerGarbage.currentRestackItems, 1)
	if #(BrokerGarbage.currentRestackItems) <= 0 then
		BrokerGarbage.currentRestackItems = nil
		return false
	else
		return BrokerGarbage:RestackStep()
	end
end

-- move 1 item for restacking
function BrokerGarbage:RestackStep()
	if not BrokerGarbage.currentRestackItems then return false end
	local itemID = BrokerGarbage.currentRestackItems[1]
	if not itemID then return NextRestackStep() end

	local count = GetItemCount(itemID)
	if not count or count <= 1 then return NextRestackStep() end
	
	local locations = BrokerGarbage:FindSlotToDelete(itemID, true)
	local maxLoc = #locations
	if maxLoc <= 1 then
		return NextRestackStep()
	end -- we're done, nothing to restack
	
	if GetContainerItemInfo(locations[1].bag, locations[1].slot) then
		ClearCursor()
		PickupContainerItem(locations[1].bag, locations[1].slot)
		PickupContainerItem(locations[maxLoc].bag, locations[maxLoc].slot)
		
		BrokerGarbage:Debug("Restack from/to", locations[1].count, locations[maxLoc].count)
	end
	return true
end

-- calls restack and deletes as many items as needed
function BrokerGarbage:DeletePartialStack(itemID, num)
	local locations = BrokerGarbage:FindSlotToDelete(itemID)
	local maxStack = select(8, GetItemInfo(itemID))
	
	SplitContainerItem(locations[1].bag, locations[1].slot, num)
	if CursorHasItem() then
		BrokerGarbage:Debug("DeletePartialStack", select(2,GetItemInfo(itemID)), num, locations[1].bag, locations[1].slot)
		DeleteCursorItem()
	end
end

-- checks the inventory for items that can and should be dropped/restacked
function BrokerGarbage:CheckAndClearInv()
	local numSlots
	-- restack
	local justStacked = {}
	if BG_GlobalDB.restackIfNeeded and BG_GlobalDB.restackFullInventory then
		for container = 0, 4 do
			numSlots = GetContainerNumSlots(container)
			if numSlots then
				for slot = 1, numSlots do
					local itemID = GetContainerItemID(container,slot)
					if itemID and not BrokerGarbage:Find(justStacked, itemID) then
						BrokerGarbage:Restack(itemID)
						table.insert(justStacked, itemID)
					end
				end
			end
		end
	elseif BG_GlobalDB.restackIfNeeded then
		for i, itemTable in pairs(BrokerGarbage.inventory) do
			if not BrokerGarbage:Find(justStacked, itemTable.itemID) then
				BrokerGarbage:Restack(itemTable.itemID)
				table.insert(justStacked, itemTable.itemID)
			end
		end
	end

	-- drop until conditions are met
	--while BrokerGarbage.totalFreeSlots <= BG_GlobalDB.tooFewSlots do
	--	BrokerGarbage:Delete(BrokerGarbage:GetCheapest())	-- automatically takes included items
	--	BrokerGarbage:ScanInventory()
	--end
end

-- drops Include List (Blacklist) items
function BrokerGarbage:AntiCrap()
	local numSlots, itemID
	for bag = 0, 4 do
		numSlots = GetContainerNumSlots(container)
		if numSlots then
			for slot = 1, numSlots do
				itemID = GetContainerItemID(container,slot)
				if not IsInteresting(select(2,GetItemInfo(itemID))) then
					BrokerGarbage:Delete(select(2,GetItemInfo(itemID)), bag, slot)
				end
			end
		end
	end
end

-- warns of container - clams and/or containers
function BrokerGarbage:OpenContainers()
	--[[if BrokerGarbage.totalFreeSlots < 2 then
		BrokerGarbage:Print("Too few slots to securely loot containers! Please make some room.")
		return
	end]]--
	
	-- only containers
	if BG_GlobalDB.openContainers then
		local itemLink
		
		for i, itemTable in pairs(BrokerGarbage.unopened) do
			if not itemTable.clam then
				itemLink = select(2,GetItemInfo(itemTable.itemID))
				BrokerGarbage:Print(format(BrokerGarbage.locale.openPlease, itemLink))
				-- UseContainerItem(itemTable.container, itemTable.slot)
				tremove(BrokerGarbage.unopened, i)
			end
		end
	end
		
	-- only clams
	if BG_GlobalDB.openClams then
		-- opening clams
		local auctionType = select(6,GetAuctionItemClasses())
		local auctionSubType = GetAuctionItemSubClasses(6)
		local itemLink
		
		for i, itemTable in pairs(BrokerGarbage.unopened) do
			if itemTable.clam then
				-- UseContainerItem(itemTable.bag, itemTable.slot)
				itemLink = select(2,GetItemInfo(itemTable.itemID))
				BrokerGarbage:Print(format(BrokerGarbage.locale.openClams, itemLink))
				tremove(BrokerGarbage.unopened, i)
			end
		end
	end
end

--[[ returns number of free inventory slots // currently unused
function BrokerGarbage:GetNumSlots()
	local total = 0
	local free = 0
	local numSlots = 0
	local freeSlots = 0
	
	for container = 0, 4 do
		freeSlots = select(1,GetContainerFreeSlots(container)) or {}
		free = free + #freeSlots
		numSlots = GetContainerNumSlots(container)
		if numSlots then
			total = total + numSlots
		end
	end
	return total, free
end ]]--

-- returns true if the requested mob is skinnable with our skill
function BrokerGarbage:CanSkin(mobLevel)
	local isSkinner = IsUsableSpell(select(1,GetSpellInfo(8613))) and BrokerGarbage:GetTradeSkill(select(1,GetSpellInfo(8613)))
	if not isSkinner then return false end
	local maxLevel
	if isSkinner < 100 then 
		maxLevel = floor(isSkinner/10) + 10
	else 
		maxLevel = floor(isSkinner/5) 
	end
	
	return maxLevel >= mobLevel
end

-- determines if an item should be lootet
function BrokerGarbage:IsInteresting(itemLink)
	local itemID = BrokerGarbage:GetItemID(itemLink)
	
	local negativeList = BrokerGarbage:JoinTables(BG_GlobalDB.include, BG_LocalDB.include)
	if negativeList[itemID] then
		return false
	else
		-- check if the item belongs to a category
		local inCategory
		for setName,_ in pairs(negativeList) do
			if type(setName) == "string" then
				_, inCategory = BrokerGarbage.PT:ItemInSet(itemID, setName)
			end
			if inCategory then return false end
		end
	end
	
	return true
	
	--local positiveList = BrokerGarbage:JoinTables(BG_GlobalDB.exclude, BG_LocalDB.exclude)
	--local sellList = BrokerGarbage:JoinTables(BG_GlobalDB.forceVendorPrice, BG_GlobalDB.autoSellList, BG_LocalDB.autoSellList)
end

-- hook UpdateButton function for non-autoloot
local LootFrame_UpdateButton_orig = LootFrame_UpdateButton
function LootFrame_UpdateButton(index)
	LootFrame_UpdateButton_orig(index)
	
	local slot = (LOOTFRAME_NUMBUTTONS * (LootFrame.page - 1)) + index
	_, itemName, quantity,  quality, locked = GetLootSlotInfo(slot)
	itemLink = GetLootSlotLink(slot)
	if not itemLink then return end
	if BrokerGarbage:IsInteresting(itemLink) then
		_G["LootButton"..index.."IconTexture"]:SetDesaturated(false)
		_G["LootButton"..index.."IconTexture"]:SetAlpha(1)
	else
		_G["LootButton"..index.."IconTexture"]:SetDesaturated(true)
		_G["LootButton"..index.."IconTexture"]:SetAlpha(0.5)
	end
end

-- ---------------------------------------------------------
-- lootmanager functionality from here
-- ---------------------------------------------------------
-- for use in CHAT_MSG_LOOT event - destroys watched items as needed
function BrokerGarbage:AutoDestroy()
	local count
	local location = {}
	
	for itemID,maxCount in pairs(BrokerGarbage:JoinTables(BG_LocalDB.include, BG_GlobalDB.include)) do
		if type(itemID) == "number" and type(maxCount) == number then
			count = GetItemCount(itemID)
			
			-- delete excess items
			local i = 1
			location = BrokerGarbage:FindSlotToDelete(itemID)
			while count > maxCount do
				-- save the last stack, even if it itself is over our treshold (for stackable items)
				if i == #location then break end
				BrokerGarbage:Delete(GetItemInfo(itemID), location[i].bag, location[i].slot)
				
				count = GetItemCount(itemID)
				i = i + 1
			end
		end
	end
end

-- for use in LOOT_OPENED event
function BrokerGarbage:SelectiveLooting(autoloot)
	if IsShiftKeyDown() then return end
	local numItems = GetNumLootItems()
	local texture, quantity, quality, locked, itemLink
	local manage, loot, close = false, false, true
	
	local mobLevel = UnitExists("target") and UnitIsDead("target") and UnitLevel("target")
	local mobType = UnitCreatureType("target") == BrokerGarbage.locale.CreatureTypeBeast
	local autoLoot = autoloot ~= 0 or BG_GlobalDB.autoLoot
	
	if autoLoot
		or (BG_GlobalDB.autoLootPickpocket and BrokerGarbage.playerClass == "ROGUE" and IsStealthed()) 
		or (BG_GlobalDB.autoLootFishing and IsFishingLoot())
		or (BG_GlobalDB.autoLootSkinning and mobType and CanSkin(mobLevel)) then
		
		BrokerGarbage:Debug("Clearing mob")
		manage = true
		
		for slot = 1,numItems do
			if LootSlotIsCoin(slot) then
				-- take money
				loot = true
			else
				-- check items
				_, _, quantity,  quality, locked = GetLootSlotInfo(slot)
				itemLink = GetLootSlotLink(slot)
				local value = BrokerGarbage:GetItemValue(itemLink, quantity)
				
				if BrokerGarbage:IsInteresting(itemLink) 
					and (not value or value >= BG_LocalDB.itemMinValue) then
					
					if BrokerGarbage.totalFreeSlots <= BG_GlobalDB.tooFewSlots then
						-- try to compress and make room
						BrokerGarbage:Debug("We're out of space!")
						
						local itemID = BrokerGarbage:GetItemID(itemLink)
						local maxStack = select(8, GetItemInfo(itemID))
						local inBags = mod(GetItemCount(itemID), maxStack)
						local compareTo = BrokerGarbage:GetCheapest()
						
						if inBags > 0 and maxStack >= (inBags + quantity) then
							-- this item fits without us doing anything
							BrokerGarbage:Debug("Item stacks.", itemLink)
							loot = true
						
						elseif BG_GlobalDB.autoDestroy and inBags > 0 and inBags + quantity > maxStack then
							-- we can fit x more in ... *squeeze*
							BrokerGarbage:Debug("Item can be made to fit.", itemLink)
							
							local amount = quantity + inBags - maxStack
							if compareTo[1] and 
								(BrokerGarbage:GetItemValue(itemLink, (quantity-amount)) or 0) < compareTo[1].value then
								
								BrokerGarbage:DeletePartialStack(itemID, amount)
								loot = true
							end
						
						elseif BG_GlobalDB.autoDestroy and compareTo[1] then
							-- delete cheaper item
							BrokerGarbage:Debug("Check for items to throw away for", itemLink)
							
							if (BrokerGarbage:GetItemValue(itemLink, quantity) or 0) > compareTo[1].value 
								or select(6,GetItemInfo(itemLink)) == select(12, GetAuctionItemClasses()) then
								
								-- this item is worth more or it is a quest item
								BrokerGarbage:Debug("Delete item to make room.", itemLink)
								
								BrokerGarbage:Delete(select(2,GetItemInfo(compareTo[1].itemID)), 
									compareTo[1].bag, compareTo[1].slot)
								loot = true
							
							elseif BG_GlobalDB.autoLootSkinning and mobType and BrokerGarbage:CanSkin(mobLevel) and compareTo[1] then
								-- we are skinning
								BrokerGarbage:Debug("Looting for skinning", itemLink)
								
								BrokerGarbage:Delete(select(2,GetItemInfo(compareTo[1].itemID)), 
									compareTo[1].bag, compareTo[1].slot)
								loot = true
							end
						end
					else
						-- enough bag space
						loot = true
					end
				end
			end
			
			-- take loot if we can
			if locked and quality < GetLootThreshold() then
				BrokerGarbage:Print(format(BrokerGarbage.locale.couldNotLootLocked, itemLink))
			elseif not loot and not BG_GlobalDB.autoDestroy then
				BrokerGarbage:Print(format(BrokerGarbage.locale.couldNotLootSpace, itemLink))
			elseif not loot then
				BrokerGarbage:Print(format(BrokerGarbage.locale.couldNotLootValue, itemLink))
			else
				-- check if we are allowed to loot this
				if (GetNumPartyMembers() > 0 or GetNumRaidMembers() > 1) 
					and GetLootMethod() ~= "freeforall" and quality >= GetLootThreshold() then
					
					-- ignore item as it is still being rolled for / loot master's job
					if GetNumRaidMembers() > 1 and select(3,GetLootMethod()) 
						and UnitIsUnit("raid"..select(3,GetLootMethod()), "player") then
						
						BrokerGarbage:Print(format(BrokerGarbage.locale.couldNotLootLM, itemLink))
						close = false
					end
				else
					-- loot normally
					LootSlot(slot)
				end
			end
		end
	end
	
	if manage and (close or GetNumLootItems() == 0) then
		CloseLoot()
	end
end
BrokerGarbage.lootManager = true