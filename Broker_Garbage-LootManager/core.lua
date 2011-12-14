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
		local freeSlots = Broker_Garbage.totalFreeSlots
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

	local isQuestItem = ( select(6, GetItemInfo(itemTable.itemID)) ) == ( select(12, GetAuctionItemClasses()) )
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

-- [TODO] maybe consider LOOT_SLOT_CLEARED event?
-- decides how to handle loot in a LOOT_OPENED event
function BGLM.SelectiveLooting(autoloot)
	if InCombatLockdown() and not BGLM_GlobalDB.useInCombat then return end

	if BGLM.privateLoot then
		if GetTime() - BGLM.privateLoot <= BGLM_GlobalDB.privateLootTimer then
			BGLM:Debug("Item is private loot")
		else	-- reset, data is too old
			BGLM.privateLoot = nil
		end
	end
	if IsFishingLoot() then BGLM.privateLoot = true end

	local lootAll = autoloot ~= 0 or BGLM_GlobalDB.autoLoot
	local lootPickpocket = BGLM_GlobalDB.autoLootPickpocket and Broker_Garbage:GetVariable("playerClass") == "ROGUE" and IsStealthed()
	local lootFishing = BGLM_GlobalDB.autoLootFishing and IsFishingLoot()
	local lootSkinning = BGLM_GlobalDB.autoLootSkinning and UnitExists("target") and UnitIsDead("target") and UnitCreatureType("target") == BGLM.locale.CreatureTypeBeast and BGLM:CanSkin(UnitLevel("target"))

	if lootAll or lootPickpocket or lootFishing or lootSkinning then
		BGLM:Debug("SelectiveLooting initiated, autoloot:", autoloot)

		local lootSlotItem, itemLink, itemID, lootAction
		local slotQuantity, slotQuality, slotIsLocked
		local maxStack, inBags, stackOverflow
		
		local isInteresting, alwaysLoot
		local compareTo

		--[[-- trying to pre-process for optimizing loot order
		local slotItem, slotItemLink, itemQuantity, slotItemValue
		local slotItemIsItem, slotItemBagSpace, slotItemBagType
		local itemMaxStack, itemInBags, itemStackOverflow
		local itemPriorities = {}
		for lootSlot = 1, GetNumLootItems() do
			slotItemIsItem = LootSlotIsItem(lootSlot)
			if slotItemIsItem then
				slotQuantity = select(3, GetLootSlotInfo(lootSlot))
				slotItemLink = GetLootSlotLink(lootSlot)
				slotItem = Broker_Garbage.GetCached(BGLM:GetItemID(slotItemLink))

				isInteresting, alwaysLoot = BGLM:IsInteresting(slotItem)
				slotItemValue = (slotItem.value or 0) * slotQuantity

				itemMaxStack = select(8, GetItemInfo(slotItemLink))
				itemInBags = mod(GetItemCount(slotItemLink), itemMaxStack)
				itemStackOverflow = slotQuantity + mod(itemInBags, itemMaxStack) - itemMaxStack

				_, slotItemBagSpace, slotItemBagType = Broker_Garbage.FindBestContainerForItem(slotItemLink)
				slotItemBagType = slotItemBagType ~= 0 and slotItemBagSpace > 0
			else
				isInteresting, alwaysLoot = true, true
				slotItemValue = 0
			end

			table.insert(itemPriorities, {
				lootSlot = lootSlot,
				isItem = slotItemIsItem,
				
				interesting = isInteresting,
				always = alwaysLoot,
				value = slotItemValue,

				stackOverflow = itemStackOverflow,
				goesIntoSpecialBag = slotItemBagType,
			})
		end
		table.sort(itemPriorities, function(a, b)
			if a.isItem == b.isItem then
				if a.always == b.always then
					if a.interesting == b.interesting then
						return a.value > b.value
					else
						return a.interesting
					end
				else
					return a.always
				end
			else
				return not a.isItem
			end
		end) ]]--
		--[[ concept:
			if have to clear mob then
				fetch all non-item loot slots
				and
				fetch all items that stack in reverse table order:
			else
				fetch all items from priority list in order
			end

			when fetching, if not enough room then
				do some thinking, if it involves deleting then
				delay further execution and wait for LOOT_SLOT_CLEARED event
				then continue
			end
		]]--

		local close = true

		local lootConstraint, playerIsLootMaster = nil, nil
		local lootThreshold, lootMethod, lootMasterGroup, lootMasterRaid = GetLootThreshold(), GetLootMethod()

		for slot = 1, GetNumLootItems() do
			lootAction = nil

			_, _, slotQuantity, slotQuality, slotIsLocked = GetLootSlotInfo(slot)
			itemLink = GetLootSlotLink(slot)

			if lootThreshold and slotQuality >= lootThreshold then
				if lootMethod == "master" then
					lootConstraint = true
					if lootMasterRaid and GetNumRaidMembers() > 1 and UnitIsUnit("raid"..lootMasterRaid, "player") then
						playerIsLootMaster = true
					elseif lootMasterGroup and GetNumPartyMembers() > 0 and lootMasterGroup == 0 then
						playerIsLootMaster = true
					end
				elseif lootMethod ~= "freeforall" then
					lootConstraint = GetNumPartyMembers() > 0 or GetNumRaidMembers() > 1
				end
			else
				lootConstraint = nil
			end
			if BGLM.privateLoot then
				lootConstraint = nil -- private loot = god mode. you want it, you take it!
			end

			BGLM:Debug("Loot Slot", slot, "Has constraint?", lootConstraint)

			-- preparations are done, now decide on actions
			if not itemLink or not LootSlotIsItem(slot) then 		-- e.g. currency
				lootAction = "take"

			elseif lootConstraint then 	-- loot master / group loot
				lootAction = "none"

				if playerIsLootMaster then
					close = false
					BGLM:Print(format(BGLM.locale.couldNotLootLM, itemLink), BGLM_GlobalDB.warnLM)
					break -- only print message once
				else
					close = not BGLM_GlobalDB.keepGroupLootOpen
				end

			else
				itemID = itemLink and BGLM:GetItemID(itemLink)
				lootSlotItem = itemID and Broker_Garbage.GetCached(itemID)

				isInteresting, alwaysLoot = BGLM:IsInteresting(lootSlotItem)

				maxStack = select(8, GetItemInfo(itemID))
				inBags = mod(GetItemCount(itemID), maxStack)
				stackOverflow = slotQuantity + mod(inBags, maxStack) - maxStack

				compareTo = Broker_Garbage.cheapestItems and Broker_Garbage.cheapestItems[1] or nil
				local targetContainer, targetFreeSlots, targetType = Broker_Garbage.FindBestContainerForItem(itemID)

				if isInteresting or alwaysLoot then
					if lootSlotItem.value < BGLM_LocalDB.itemMinValue and not alwaysLoot then
						-- minimum loot value not reached; item is too cheap
						lootAction = "none"
						BGLM:Print(format(BGLM.locale.couldNotLootValue, itemLink), BGLM_GlobalDB.printValue)

					elseif Broker_Garbage.totalFreeSlots <= BGLM_GlobalDB.tooFewSlots then
						-- dropping low on bag space
						BGLM:Debug("Bag space below threshold")

						if inBags > 0 and stackOverflow <= 0 then
							-- item stacks, no actions nessessary
							lootAction = "take"
							BGLM:Debug("Item stacks, do nothing special", itemLink)

						elseif targetContainer and targetFreeSlots > 0 and targetType ~= 0 then
							-- item goes into specialty bag, no actions nessessary
							lootAction = "take"
							BGLM:Debug("Item goes into specialty bag", itemLink)

						elseif not alwaysLoot and stackOverflow > 0 and BGLM_LocalDB.autoDestroy and 
							(lootSkinning or (compareTo and (Broker_Garbage.GetItemValue(itemLink, stackOverflow) or 0) < compareTo.value)) then
							-- delete partial stack. throw away partial stacks to squeeze in a little more
							lootAction = "deletePartial"
							BGLM:Debug("Item can be made to fit.", itemLink)

						elseif BGLM_LocalDB.autoDestroy and compareTo and compareTo.value and 
							(alwaysLoot or lootSkinning or lootSlotItem.value > compareTo.value) then
							-- delete only if it's worth more, if it's an item we really need or if we want to skin the mob
							lootAction = "delete"
							BGLM:Debug("Deleting item", compareTo.itemLink, "to make room for", itemLink)

						elseif not alwaysLoot and compareTo and compareTo.value and lootSlotItem.value <= compareTo.value then
							lootAction = "none"
							BGLM:Debug("Making space for this item makes us loose money.", itemLink)
							BGLM:Print(format(BGLM.locale.couldNotLootCompareValue, itemLink), BGLM_GlobalDB.printCompareValue)

						else
							-- we'd like to take the item but have no bag space (and can't make any)
							lootAction = "none"
							close = false

							BGLM:Print(format(BGLM.locale.couldNotLootSpace, itemLink), BGLM_GlobalDB.printSpace)
						end
					else
						-- enough bag space available
						lootAction = "take"
					end
				else
					-- item is on junk list
					lootAction = "none"
					BGLM:Print(format(BGLM.locale.couldNotLootBlacklist, itemLink), BGLM_GlobalDB.printJunk)
				end
				
				-- last update & starting delete actions if needed
				if lootAction ~= "none" and slotIsLocked then
					-- we should probably be able to loot this, but something went wrong
					lootAction = "none"
					close = false
					BGLM:Print(format(BGLM.locale.couldNotLootLocked, itemLink), BGLM_GlobalDB.printLocked)

				elseif lootAction == "deletePartial" then
					lootAction = "take"
					BGLM:DeletePartialStack(itemID, stackOverflow)

				elseif lootAction == "delete" then
					Broker_Garbage:Delete(compareTo)
					lootAction = "take"
				end

				-- if we have private loot that the user can't take, show it to him!
				if BGLM_GlobalDB.keepPrivateLootOpen and BGLM.privateLoot and lootAction == "none" then
					close = false
				end
			end
			
			-- finally, take what we can
			if lootAction == "take" then
				BGLM:Debug("Taking", itemLink or "<not an item>", (BGLM.privateLoot or BGLM_GlobalDB.autoConfirmBoP) and "confirm" or "no confirm")
				LootSlot(slot)

				if BGLM.privateLoot or BGLM_GlobalDB.autoConfirmBoP then
					ConfirmLootSlot(slot)
				end
			end
		end
		if close and BGLM_GlobalDB.closeLootWindow and (not IsFishingLoot() or not IsAddOnLoaded("FishingBuddy")) then
			BGLM:Debug("Closing loot window")
			CloseLoot()
		end
	end
	BGLM.privateLoot = nil		-- if we used this, we need to reset; if we didn't use it then we don't need its value anyway
end