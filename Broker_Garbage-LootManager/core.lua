local addonName, BGLM = ...

local function InitializePrivateLoot()
	BGLM.privateLoot = GetTime()
end

-- register events
local frame = CreateFrame("Frame")
local function eventHandler(self, event, arg1, ...)
	if event == "ADDON_LOADED" and arg1 == addonName then
		BGLM.CheckSettings()
		BGLM.UpdateSettings_4_1()

		-- used to distinguish between raid loot and inventory loot
		hooksecurefunc("UseContainerItem", InitializePrivateLoot)

		frame:RegisterEvent("ITEM_PUSH")
		frame:RegisterEvent("UI_ERROR_MESSAGE")
		frame:RegisterEvent("LOOT_OPENED")
		frame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
		-- frame:RegisterEvent("LOOT_CLOSED")
		frame:UnregisterEvent("ADDON_LOADED")

	elseif event == "ITEM_PUSH" and BGLM_LocalDB.autoDestroy and BGLM_LocalDB.autoDestroyInstant then
		local freeSlots = Broker_Garbage:GetVariable("totalFreeSlots")
		if freeSlots < BGLM_GlobalDB.tooFewSlots then
			BGLM.TrimInventory(BGLM_GlobalDB.tooFewSlots - freeSlots)
		end

	elseif event == "UI_ERROR_MESSAGE" then
			if arg1 and (arg1 == ERR_INV_FULL or arg1 == INVENTORY_FULL) then
			BGLM:Print(BGLM.locale.errorInventoryFull, BGLM_GlobalDB.warnInvFull)
		end

	elseif event == "LOOT_OPENED" then
		local disable = Broker_Garbage:GetVariable("disableKey")
		disable = disable[Broker_Garbage:GetOption("disableKey", true)]
		if not (disable and disable()) and (not InCombatLockdown() or BGLM_GlobalDB.useInCombat) then
			securecall(BGLM.SelectiveLooting, arg1)
		end
	elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
		if arg1 == "player" and BGLM:Find(BGLM.privateLootSpells, ( select(4, ...) )) then
			InitializePrivateLoot()
		end
	end
end

frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", eventHandler)

-- ---------------------------------------------------------
-- calls restack and deletes as many items as needed
function BGLM:DeletePartialStack(itemID, num)
	local locations = Broker_Garbage:FindSlotToDelete(itemID)
	local maxStack = select(8, GetItemInfo(itemID))
	
	if GetContainerItemID(locations[1].bag, locations[1].slot) ~= itemID then
		BGLM:Print("Error! DeletePartialStack: This is not the item I expected.")
		return
	end
	
	securecall(SplitContainerItem, locations[1].bag, locations[1].slot, num)
	if CursorHasItem() then
		BGLM:Delete("cursor", num)
		BGLM:Debug("DeletePartialStack", select(2,GetItemInfo(itemID)), num, locations[1].bag, locations[1].slot)
	end
end

-- returns true if the requested mob is skinnable with our skinning skill
function BGLM:CanSkin(mobLevel)
	local skinning = Broker_Garbage:GetProfessionSkill(8613)
	if not skinning then return false end
	
	local maxLevel
	if skinning < 100 then 
		maxLevel = floor(skinning/10) + 10
	else 
		maxLevel = floor(skinning/5) 
	end
	
	return maxLevel >= mobLevel
end

-- determines if an item should be looted
function BGLM:IsInteresting(itemTable)
	local isInteresting, alwaysLoot
	if itemTable.classification == Broker_Garbage.EXCLUDE then
		isInteresting = true
		alwaysLoot = BGLM_GlobalDB.lootExcludeItems
	elseif itemTable.classification == Broker_Garbage.INCLUDE and not BGLM_GlobalDB.lootIncludeItems then
		isInteresting = false
	else
		isInteresting = true
	end

	local isQuestItem = select(6, GetItemInfo(itemTable.itemID)) == select(12, GetAuctionItemClasses())
	local isTopFitInteresting = IsAddOnLoaded("TopFit") and Broker_Garbage.IsItemEquipment(itemTable.itemID) and TopFit:IsInterestingItem( (GetItemInfo(itemTable.itemID)) )

	if isQuestItem or isTopFitInteresting or BGLM_GlobalDB.forceClear or alwaysLoot then
		return isInteresting, true
	else
		return isInteresting, false
	end
end

-- hook UpdateButton function for non-autoloot
function BGLM.UpdateLootFrame(index)
	if not index then return end
	local slot = (LOOTFRAME_NUMBUTTONS * (LootFrame.page - 1)) + index
	local item = GetLootSlotLink(slot)
		  item = item and BGLM:GetItemID(item)
		  item = Broker_Garbage.GetCached(item)
	
	if item then
		local isInteresting, alwaysLoot = BGLM:IsInteresting(item)
		if isInteresting or alwaysLoot then
			_G["LootButton"..index.."IconTexture"]:SetDesaturated(false)
			_G["LootButton"..index.."IconTexture"]:SetAlpha(1)
		else
			_G["LootButton"..index.."IconTexture"]:SetDesaturated(true)
			_G["LootButton"..index.."IconTexture"]:SetAlpha(0.5)
		end
	end
end
hooksecurefunc("LootFrame_UpdateButton", BGLM.UpdateLootFrame)

-- ---------------------------------------------------------
-- lootmanager functionality from here on
-- ---------------------------------------------------------
-- for use in CHAT_MSG_LOOT event - destroys watched items as needed; UNUSED
function BGLM.AutoDestroy()
	local location = {}
	local itemLink
	
	for itemID, maxCount in pairs(BGLM:JoinTables(Broker_Garbage:GetOption("include"))) do
		count = 0
		if type(itemID) == "number" and type(maxCount) == "number" then
			BGLM:Debug(itemID, maxCount)
			-- delete excess items
			location = Broker_Garbage:FindSlotToDelete(itemID)
			for i = #location, 1, -1 do
				if count >= maxCount then
					itemLink = select(2, GetItemInfo(itemID))
					Broker_Garbage:Delete(itemLink, {location[i].bag, location[i].slot})
				else
					count = count + location[i].count
				end
			end
		end
	end
end

function BGLM.TrimInventory(emptySlotNum)
	if not emptySlotNum then return end
	for i = 1, emptySlotNum do
		local deleteThis = select(i, Broker_Garbage:GetVariable("cheapestItems"))
		if not deleteThis then
			BGLM:Print("Error! I tried to make space but there is nothing left for me to delete!")
			return
		end
		Broker_Garbage:Delete(deleteThis)
	end
end

-- for use in LOOT_OPENED event
-- [TODO] check item/bagtypes to use those specialty bags wisely!
function BGLM.SelectiveLooting(autoloot)	-- jwehgH"G$(&/&§$/!!" stupid . vs. : notation
	if InCombatLockdown() and not BGLM_GlobalDB.useInCombat then return end
	
	if BGLM.privateLoot then
		if GetTime() - BGLM.privateLoot <= BGLM_GlobalDB.privateLootTimer then
			BGLM:Debug("Item is private loot")
		else
			BGLM.privateLoot = nil	-- reset, data is too old
		end
	end
	if IsFishingLoot() then BGLM.privateLoot = true end
	
	local lootAll = autoloot ~= 0 or BGLM_GlobalDB.autoLoot
	local lootPickpocket = BGLM_GlobalDB.autoLootPickpocket and Broker_Garbage:GetVariable("playerClass") == "ROGUE" and IsStealthed()
	local lootFishing = BGLM_GlobalDB.autoLootFishing and IsFishingLoot()
	local lootSkinning = BGLM_GlobalDB.autoLootSkinning and UnitExists("target") and UnitIsDead("target") and UnitCreatureType("target") == BGLM.locale.CreatureTypeBeast and BGLM:CanSkin(UnitLevel("target"))
	
	if lootAll or lootPickpocket or lootFishing or lootSkinning then
		BGLM:Debug("SelectiveLooting: Check passed, figure out what to do. Autoloot:", autoloot)
		
		local close = true
		BGLM:Debug("close initialized: true")

		local lootSlotItem, itemLink, itemID, lootAction
		local compareTo
		
		local lootMethod, groupLM, raidLM = GetLootMethod()

		local slotQuantity, slotQuality, isLocked
		local isInteresting, alwaysLoot
		local maxStack, inBags, stackOverflow

		for slot = 1, GetNumLootItems() do
			lootAction = nil

			_, _, quantity, quality, locked = GetLootSlotInfo(slot)
			itemLink = GetLootSlotLink(slot)

			if itemLink then	-- some slots have money, i.e. not an item
				itemID = itemLink and BGLM:GetItemID(itemLink)
				lootSlotItem = itemID and Broker_Garbage.GetCached(itemID)
				
				isInteresting, alwaysLoot = BGLM:IsInteresting(lootSlotItem)
				maxStack = select(8, GetItemInfo(itemID))
				inBags = mod(GetItemCount(itemID), maxStack)
				stackOverflow = quantity + mod(inBags, maxStack) - maxStack

				compareTo = Broker_Garbage:GetVariable("cheapestItems")
				compareTo = compareTo and compareTo[1] or nil
				
				if isInteresting or alwaysLoot then
					if not alwaysLoot and lootSlotItem.value < BGLM_LocalDB.itemMinValue then
						BGLM:Print(format(BGLM.locale.couldNotLootValue, itemLink), BGLM_GlobalDB.printValue)
						lootAction = "none"
					
					elseif Broker_Garbage:GetVariable("totalFreeSlots") <= BGLM_GlobalDB.tooFewSlots then
						-- dropping low on bag space
						BGLM:Debug("Free bag space below minimum treshold! Thinking ...", itemLink)
						-- new item: 13c.
						if inBags > 0 and stackOverflow <= 0 then
							-- delete nothing. this item fits without us doing anything
							BGLM:Debug("Item stacks, do nothing special", itemLink)
							lootAction = "take"
						
						elseif not alwaysLoot and BGLM_LocalDB.autoDestroy and stackOverflow > 0 and 
							(lootSkinning or (compareTo and (Broker_Garbage.GetItemValue(itemLink, stackOverflow) or 0) < compareTo.value)) then
							-- delete partial stack. throw away partial stacks to squeeze in a little more
							BGLM:Debug("Item can be made to fit.", itemLink)
							lootAction = "deletePartial"
						
						elseif BGLM_LocalDB.autoDestroy and compareTo and compareTo.value and 
							(alwaysLoot or lootSkinning or lootSlotItem.value > compareTo.value) then
							-- delete only if it's worth more, if it's an item we really need or if we want to skin the mob
							BGLM:Debug("Deleting item", compareTo.itemLink, "to make room for", itemLink)
							lootAction = "delete"
						
						elseif not alwaysLoot and compareTo and compareTo.value and lootSlotItem.value <= compareTo.value then
							BGLM:Debug("Taking this item by throwing away stuff would make us loose money.", itemLink)
							BGLM:Print(format(BGLM.locale.couldNotLootCompareValue, itemLink), BGLM_GlobalDB.printCompareValue)
							lootAction = "none"
						else
							-- we'd like to take the item but have no bag space (and can't make any)
							close = false
							if BGLM.privateLoot or lootMethod == "freeforall" or quality < GetLootThreshold() 
								or (GetNumPartyMembers() == 0 and GetNumRaidMembers() == 0) then
								-- we should be able to loot. if we can't it's because the inventory is full
								BGLM:Print(format(BGLM.locale.couldNotLootSpace, itemLink), BGLM_GlobalDB.printSpace)
							end
							lootAction = "none"
						end
					else
						lootAction = "take"
					end
				else
					-- item is on junk list
					BGLM:Print(format(BGLM.locale.couldNotLootBlacklist, itemLink), BGLM_GlobalDB.printJunk)
                    lootAction = "none"
				end
				
				-- last update & starting delete actions if needed
				if lootAction ~= "none" and locked and quality < GetLootThreshold() then
					-- we should probably be able to loot this, but something went wrong
					BGLM:Print(format(BGLM.locale.couldNotLootLocked, itemLink), BGLM_GlobalDB.printLocked)
                    lootAction = "none"
					close = false
					
				elseif lootMethod == "master" and quality >= GetLootThreshold() and
                    ((GetNumRaidMembers() > 1 and UnitIsUnit("raid"..raidLM, "player")) or 
                    (GetNumPartyMembers() > 0 and groupLM == 0)) then
                    -- we have loot master messages enabled and are loot master
					BGLM:Print(format(BGLM.locale.couldNotLootLM, itemLink), BGLM_GlobalDB.warnLM)
                    lootAction = "none"
					close = false
					break	-- prevent multiple messages when you're the LM
					
                elseif not BGLM.privateLoot and lootAction ~= "none" and 
					lootMethod ~= "freeforall" and quality >= GetLootThreshold() and 
					(GetNumPartyMembers() > 0 or GetNumRaidMembers() > 1) then
                    -- item is above the group's loot treshold and we're in a group
                    BGLM:Debug("Item is above loot treshold. Leave it for the user to decide.")
                    lootAction = "none"
					close = false

                elseif lootAction == "deletePartial" then
                    BGLM:DeletePartialStack(itemID, stackOverflow)
                    lootAction = "take"
                elseif lootAction == "delete" then
                    Broker_Garbage:Delete(compareTo)
                    lootAction = "take"
				end
			end
			
			if lootAction == "take" or not LootSlotIsItem(slot) then	-- finally, take it!
				BGLM:Debug("Taking item", itemLink or "???")
				LootSlot(slot)
				if BGLM.privateLoot or BGLM_GlobalDB.autoConfirmBoP then
					BGLM:Debug("Confirming loot")
					ConfirmLootSlot(slot)
				end
			end
		end
		if close and BGLM_GlobalDB.closeLootWindow and (not IsFishingLoot() or not IsAddOnLoaded("FishingBuddy")) then
			CloseLoot()
		end
	end	-- TODO: maybe consider LOOT_SLOT_CLEARED event ... or not.
	BGLM.privateLoot = nil		-- if we used this, reset; if we didn't we don't need its value anyway
end