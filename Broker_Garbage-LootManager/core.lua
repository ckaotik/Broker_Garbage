local addonName, BGLM = ...
local _

-- GLOBALS: BGLM_GlobalDB, BGLM_LocalDB, Broker_Garbage, ERR_INV_FULL, INVENTORY_FULL, coroutine, LOOTFRAME_NUMBUTTONS, NUM_BAG_SLOTS, LOOT_SLOT_ITEM
-- GLOBALS: StaticPopup1, LootFrame
-- GLOBALS: IsAddOnLoaded, GetTime, InCombatLockdown, IsFishingLoot, GetNumLootItems, GetLootSlotType, LootSlot, CloseLoot, CursorHasItem, GetItemInfo, GetContainerNumFreeSlots, GetContainerItemID, SplitContainerItem, GetLootSlotLink, GetLootSlotInfo, ConfirmLootSlot, GetItemCount
local _G = _G
local pairs = pairs
local ipairs = ipairs
local select = select
local wipe = table.wipe
local sort = table.sort
local format = string.format
local hooksecurefunc = hooksecurefunc
local infinite = math.huge
local abs = math.abs
local mod = mod

local function InitializePrivateLoot()
	BGLM.privateLoot = GetTime()
end
local function MarkSlotAsLooted(lootSlotID)
	BGLM.looted[lootSlotID] = true
end

-- register events
local lootRoutine = nil
local frame = CreateFrame("Frame")
function frame.RESTACK_COMPLETE()
	Broker_Garbage.UnregisterCallback("Broker_Garbage-LootManager", "RESTACK_COMPLETE")
	BGLM:HandleLootCallback()
end
local function eventHandler(self, event, arg1, ...)
	if event == "ADDON_LOADED" and arg1 == addonName then
		BGLM.CheckSettings()
		BGLM.UpdateSettings_4_1()

		-- used to distinguish between raid loot and inventory loot
		hooksecurefunc("UseContainerItem", InitializePrivateLoot)

		BGLM.looted = {}
		hooksecurefunc("LootSlot", MarkSlotAsLooted)

		BGLM.confirm = {}

		BGLM.BoPConfirmation = 0 -- number of pending item confirmations

		local events = {
			"ITEM_PUSH", "LOOT_OPENED", "LOOT_BIND_CONFIRM", "LOOT_CLOSED",
			"UI_ERROR_MESSAGE", "UNIT_SPELLCAST_SUCCEEDED"
		}
		for _, event in ipairs(events) do
			frame:RegisterEvent(event)
		end
		frame:UnregisterEvent("ADDON_LOADED")

	elseif event == "ITEM_PUSH" and BGLM_LocalDB.autoDestroy and BGLM_LocalDB.autoDestroyInstant then
		local numOverflowSlots = BGLM_GlobalDB.tooFewSlots - Broker_Garbage.totalFreeSlots
		if numOverflowSlots > 0 then
			BGLM.TrimInventory(numOverflowSlots)
		end

	elseif event == "UI_ERROR_MESSAGE" then
			if arg1 and (arg1 == ERR_INV_FULL or arg1 == INVENTORY_FULL) then
			BGLM:Print(BGLM.locale.errorInventoryFull, BGLM_GlobalDB.warnInvFull)
		end

	elseif lootRoutine and (event == "BAG_UPDATE" or event == "UNIT_INVENTORY_CHANGED" or event == "GET_ITEM_INFO_RECEIVED") then
		frame:UnregisterEvent(event)
		BGLM:HandleLootCallback()

	elseif event == "LOOT_BIND_CONFIRM" and BGLM_GlobalDB.autoConfirmBoP then
		BGLM.confirm[arg1] = true

	elseif event == "LOOT_OPENED" then
		if not Broker_Garbage:IsDisabled() and (not InCombatLockdown() or BGLM_GlobalDB.useInCombat) then
			for lootSlotID, confirm in pairs(BGLM.confirm) do
				if confirm then
					StaticPopup1:Hide()
				end
			end

			if not lootRoutine then
				lootRoutine = coroutine.create(BGLM.SelectiveLooting)
			end
			BGLM:HandleLootCallback(arg1)
		end

	elseif event == "LOOT_CLOSED" then
		StaticPopup1:Hide()
		for lootSlotID, looted in pairs(BGLM.looted) do
			BGLM.looted[lootSlotID] = nil
		end
		for lootSlotID, confirm in pairs(BGLM.confirm) do
			BGLM.confirm[lootSlotID] = nil
		end

	elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
		if arg1 == "player" and Broker_Garbage.Find(BGLM.privateLootSpells, ( select(4, ...) )) then
			InitializePrivateLoot()
		end
	end
end

frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", eventHandler)

function BGLM:HandleLootCallback(blizzAutoLoot)
	if lootRoutine and coroutine.status(lootRoutine) ~= "dead" then
		local success, waitFor, isCBH = coroutine.resume(lootRoutine, blizzAutoLoot)
		if waitFor then
			if isCBH and waitFor == "RESTACK_COMPLETE" then
				Broker_Garbage.RegisterCallback("Broker_Garbage-LootManager", waitFor, frame[waitFor])
				Broker_Garbage.DoFullRestack()
			else
				frame:RegisterEvent(waitFor)
			end
		else
			lootRoutine = nil
		end
	else
		lootRoutine = nil
	end
end


-- ---------------------------------------------------------
-- deletes as many items as needed
function BGLM:DeletePartialStack(itemID, num)
	local locations = Broker_Garbage.GetItemLocations(itemID)
	local maxStack = select(8, GetItemInfo(itemID))

	if GetContainerItemID(locations[1].bag, locations[1].slot) ~= itemID then
		BGLM:Print("Error! DeletePartialStack: This is not the item I expected.")
		return
	end

	SplitContainerItem(locations[1].bag, locations[1].slot, num)
	if CursorHasItem() then
		BGLM:Delete("cursor", num)
		BGLM:Debug("DeletePartialStack", itemID, num, locations[1].bag, locations[1].slot)
	end
end

-- hook UpdateButton function for non-autoloot
function BGLM.UpdateLootFrame(index)
	if not index then return end
	local slot = (LOOTFRAME_NUMBUTTONS * (LootFrame.page - 1)) + index
	local item = GetLootSlotLink(slot)
		  item = item and Broker_Garbage.GetItemID(item)
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
function BGLM.TrimInventory(emptySlotNum)
	if not emptySlotNum then return end
	for i = 1, emptySlotNum do
		local deleteThis = select(i, Broker_Garbage:GetVariable("cheapestItems"))
		if not deleteThis then
			BGLM:Print(BGLM.locale.LMAutoDestroy_ErrorNoItems)
			return
		end
		Broker_Garbage.Delete(deleteThis)
	end
end

function BGLM.Loot(lootSlotID)
	if not lootSlotID or BGLM.looted[lootSlotID] or not (GetLootSlotInfo(lootSlotID)) then
		BGLM:Debug("Trying to loot, but there is nothing left in slot", lootSlotID)
	else
		LootSlot(lootSlotID)
		if BGLM.confirm[lootSlotID] then
			ConfirmLootSlot(lootSlotID)
		end
	end
end

-- decides how to handle loot in a LOOT_OPENED event
local lootData, capacities = {}, {}
function BGLM.SelectiveLooting(blizzAutoLoot)
	-- if InCombatLockdown() and not BGLM_GlobalDB.useInCombat then return end

	local shouldAutoLoot, clearAll = BGLM:ShouldAutoLoot(blizzAutoLoot)
	BGLM:Debug("Selective looting ...", shouldAutoLoot and "yes" or "no")
	if not shouldAutoLoot then return end

	local isPrivateLoot = BGLM:IsPrivateLoot()
	if isPrivateLoot then BGLM:Debug("Currently dealing with private loot") end
	local constraint = BGLM:GetLootConstraint() or infinite

	local closeLootWindow = BGLM_GlobalDB.closeLootWindow

	local slotQuantity, slotQuality, isLocked, isQuest, slotItemLink, slotItemID, slotItem
	local masterWarning = nil

	for container = 1, NUM_BAG_SLOTS do
		capacities[container] = (GetContainerNumFreeSlots(container))
	end
	for i=1, #lootData do
		wipe(lootData[i])
	end

	-- loot preprocessing
	local goesIntoSpecialBag, dataIndex
	local numRequiredSlots, numSpecialSlots, numItems = 0, 0, 0
	local isInteresting, alwaysLoot
	for lootSlotID = 1, GetNumLootItems() do
		local addItem, needsConfirmation = nil, nil
		if GetLootSlotType(lootSlotID) == LOOT_SLOT_ITEM then
			_, _, slotQuantity, slotQuality, isLocked, isQuest = GetLootSlotInfo(lootSlotID)
			slotItemLink = GetLootSlotLink(lootSlotID)
			slotItemID = Broker_Garbage.GetItemID(slotItemLink)
			slotItem = Broker_Garbage.GetCached(slotItemID)

			if not slotItem then
				BGLM:Debug("PAUSE: GET_ITEM_INFO_RECEIVED")
				coroutine.yield("GET_ITEM_INFO_RECEIVED")
				slotItem = Broker_Garbage.GetCached(slotItemID)
				BGLM:Debug("GET_ITEM_INFO_RECEIVED: "..(slotItem and slotItem.itemLink or "nil"))
			end

			BGLM:Debug("Checking item", slotItemLink)

			isInteresting, alwaysLoot = BGLM:IsInteresting(slotItem)
			-- interesting items that we may take need to be considered
			if clearAll then
				BGLM:Debug("Have to clear all items ...", slotItemLink)
				addItem = true

			elseif isInteresting or alwaysLoot or isQuest then
				if isLocked then
					BGLM:Print(format(BGLM.locale.couldNotLootLocked, slotItemLink, slotQuantity), BGLM_GlobalDB.printLocked)

				elseif slotItem.value < BGLM_LocalDB.itemMinValue then
					-- minimum loot value not reached; item is too cheap
					BGLM:Print(format(BGLM.locale.couldNotLootValue, slotItemLink, slotQuantity), BGLM_GlobalDB.printValue)

				elseif abs(constraint) > slotQuality then
					BGLM:Debug("Unconstrained item:", slotItemLink)
					addItem = true
				else
					BGLM:Debug("Item obove threshold:", slotItemLink)
					if isQuest or isPrivateLoot then
						needsConfirmation = true
						addItem = true
					end
					closeLootWindow = nil
				end
			else
				BGLM:Debug("Left uninteresting item behind:", slotItemLink)
			end

			if constraint < 0 and -1*constraint <= slotQuality and not masterWarning then
				-- You are loot master! Do something!
				BGLM:Print(format(BGLM.locale.couldNotLootLM, slotItemLink), BGLM_GlobalDB.warnLM)
				masterWarning = true
				closeLootWindow = nil
			end
		else
			-- this can be looted right away! hooray!
			BGLM:Debug("Not an item:", slotItemLink)
			BGLM.Loot(lootSlotID)
		end

		local itemMaxStack, itemInBags, itemStackOverflow, targetContainer, slotItemBagType
		if addItem then
			itemMaxStack = select(8, GetItemInfo(slotItemLink))
			itemInBags = mod(GetItemCount(slotItemLink), itemMaxStack)
			itemInBags = itemInBags ~= 0 and itemInBags or itemMaxStack
			itemStackOverflow = slotQuantity + itemInBags - itemMaxStack

			if itemStackOverflow > 0 then
				targetContainer, _, slotItemBagType = Broker_Garbage.FindBestContainerForItem(slotItemLink)
				goesIntoSpecialBag = targetContainer and slotItemBagType ~= 0 and capacities[targetContainer] > 0
				if goesIntoSpecialBag then
					numSpecialSlots = numSpecialSlots + 1
					capacities[targetContainer] = capacities[targetContainer] - 1
				else
					numRequiredSlots = numRequiredSlots + 1
				end
			end

			numItems = numItems + 1
			if not lootData[numItems] then lootData[numItems] = {} end
			lootData[numItems].slotID = lootSlotID
			lootData[numItems].itemLink = slotItemLink
			lootData[numItems].count = slotQuantity
			lootData[numItems].value = isInteresting and ((slotItem.value or 0) * slotQuantity) or -1
			lootData[numItems].stackOverflow = itemStackOverflow
			lootData[numItems].isSpecial = goesIntoSpecialBag
			lootData[numItems].confirm = needsConfirmation
			lootData[numItems].clear = alwaysLoot or isQuest or clearAll
			lootData[numItems].quest = isQuest
		end
	end

	sort(lootData, function(a, b)
		-- data available for both entries
		if a.slotID and b.slotID then
			if a.clear == b.clear then
				if a.quest == b.quest then
					if a.value and b.value then
						return a.value > b.value
					else
						return a.value
					end
				else
					return a.quest
				end
			else
				return a.clear
			end
		else
			return a.slotID
		end
	end)

	local outOfBagSpace = (numRequiredSlots - Broker_Garbage.totalFreeSlots) > 0
		or ((numRequiredSlots+numSpecialSlots) - (Broker_Garbage.freeSpecialSlots+Broker_Garbage.totalFreeSlots)) > 0
	BGLM:Debug("Out of bag space?", outOfBagSpace and "true" or "false", numRequiredSlots, numSpecialSlots, Broker_Garbage.totalFreeSlots, Broker_Garbage.freeSpecialSlots)

	if outOfBagSpace and Broker_Garbage:GetOption("restackInventory", true) then
		BGLM:Debug("Out of bag space, trying restack ...")
		coroutine.yield("RESTACK_COMPLETE", true)

		-- update, in case restack helped
		outOfBagSpace = (numRequiredSlots - Broker_Garbage.totalFreeSlots) > 0
					or (numSpecialSlots - Broker_Garbage.freeSpecialSlots) > 0
	end

	local start, finish, step = 1, numItems, 1
	if clearAll then
		start = numItems
		finish = 1
		step = -1
	end

	local slot, takeItem, compareTo
	local numBasic, numSpecial = Broker_Garbage.totalFreeSlots, Broker_Garbage.freeSpecialSlots
	for i = start, finish, step do
		slot = lootData[i]
		takeItem = nil

		if slot.stackOverflow <= 0 then
			-- item stacks somehow, no actions nessessary
			BGLM:Debug("Item Stacks", slot.itemLink)
			takeItem = true

		elseif outOfBagSpace then
			compareTo = Broker_Garbage.cheapestItems and Broker_Garbage.cheapestItems[1]
			compareTo = compareTo and compareTo.value or -1

			-- these items *just* fit
			if numSpecial > 0 and slot.isSpecial then
				takeItem = true
				numSpecial = numSpecial - 1
			elseif numBasic > 0 then
				takeItem = true
				numBasic = numBasic - 1

			-- these items don't fit anymore
			elseif not slot.clear and slot.value <= compareTo then
					BGLM:Print(format(BGLM.locale.couldNotLootCompareValue, slot.itemLink, slot.count), BGLM_GlobalDB.printCompareValue)

			elseif BGLM_LocalDB.autoDestroy then
				if slot.stackOverflow > 0 then
					-- delete partial stack. throw away partial stacks to squeeze in a little more
					BGLM:Debug("Deleting partial stack of", slot.itemLink)
					local itemID = Broker_Garbage.GetItemID(slot.itemLink)
					BGLM:DeletePartialStack(itemID, slot.stackOverflow)
					BGLM:Debug("PAUSE: BAG_UPDATE")
					coroutine.yield("BAG_UPDATE")
					takeItem = true
				else
					-- delete only if it's worth more, if it's an item we really need or if we want to skin the mob
					BGLM:Debug("Deleting item to make room for", slot.itemLink)
					BGLM:DeleteCheapestItem()
					BGLM:Debug("PAUSE: UNIT_INVENTORY_CHANGED")
					coroutine.yield("UNIT_INVENTORY_CHANGED")
					takeItem = true
				end
			else
				BGLM:Print(format(BGLM.locale.couldNotLootSpace, slot.itemLink, slot.count), BGLM_GlobalDB.printSpace)
				if slot.clear or slot.quest then
					closeLootWindow = false
				end
			end
		else
			BGLM:Debug("Item is fine.", slot.itemLink)
			takeItem = true
		end

		-- A little less conversation, a little more action please!
		if takeItem then
			BGLM:Debug("Taking", slot.itemLink or "<not an item>", (slot.confirm and BGLM_GlobalDB.autoConfirmBoP) and "confirm" or "no confirm")
			BGLM.Loot(slot.slotID)

			if slot.confirm and BGLM_GlobalDB.autoConfirmBoP then
				BGLM.BoPConfirmation = BGLM.BoPConfirmation + 1
			end
			if isPrivateLoot and BGLM_GlobalDB.keepPrivateLootOpen then
				closeLootWindow = false
			end
		end
	end

	if closeLootWindow and (not IsFishingLoot() or not IsAddOnLoaded("FishingBuddy")) then
		BGLM:Debug("Closing loot window")
		CloseLoot()
	end
end
