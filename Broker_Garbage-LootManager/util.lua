local _, BGLM = ...
BGLM.name = "|cffee6622Broker_Garbage LootManager|r"

BGLM.PT = LibStub("LibPeriodicTable-3.1", true)
-- [TODO] Pandaria!
BGLM.privateLootSpells = { 51005, 13262, 31252, 73979,	-- milling, disenchanting, prospecting, archaeology
	2575, 2576, 3564, 10248, 29354, 50310, 74517, 		-- mining
	2366, 2368, 3570, 11993, 28695, 60300, 74519, 		-- herbalism
	8613, 8617, 8618, 10768, 32678, 50305, 74522, 		-- skinning
	49383, -- engineering
}

BGLM.LOOT_ACTION_NONE = 0
BGLM.LOOT_ACTION_SPLIT = 1
BGLM.LOOT_ACTION_DELETE = 2
BGLM.LOOT_ACTION_TAKE = 3

function BGLM:Print(text, trigger)
	if trigger == nil or trigger == true then
		DEFAULT_CHAT_FRAME:AddMessage(BGLM.name.." "..text)
	end
end

function BGLM:Debug(...)
  if BGLM_GlobalDB and BGLM_GlobalDB.debug then
	BGLM:Print("! "..string.join(", ", tostringall(...)))
  end
end

-- default saved variables
BGLM.defaultGlobalSettings = {
	-- behavior
	autoLoot = false,
	autoLootSkinning = true,
	autoLootFishing = true,
	autoLootPickpocket = true,

	useInCombat = true,
	closeLootWindow = true,
	autoConfirmBoP = false,
	forceClear = false,
	lootExcludeItems = true,
	lootIncludeItems = false,

	tooFewSlots = 0,
	warnLM = true,
	warnInvFull = false,
	printValue = true,
	printCompareValue = true,
	printJunk = true,
	printSpace = true,
	printLocked = true,

	privateLootTimer = 4, -- [TODO] config
	keepPrivateLootOpen = true, -- [TODO] config
}
BGLM.defaultLocalSettings = {
	-- behavior
	itemMinValue = 0,
	minItemQuality = 0, -- [TODO] config
	autoDestroy = false,
	autoDestroyInstant = false,
}

-- Helper functions
-- ---------------------------------------------------------
function BGLM:Set(setting, value, isGlobal)
	local tab = isGlobal and BGLM_GlobalDB or BGLM_LocalDB
	tab[setting] = value
end
function BGLM:Get(setting, isGlobal)
	local tab = isGlobal and BGLM_GlobalDB or BGLM_LocalDB
	return tab[setting]
end

-- create default settings if not existant
function BGLM.CheckSettings()
	-- check for settings
	if not BGLM_GlobalDB then BGLM_GlobalDB = {} end
	for key, value in pairs(BGLM.defaultGlobalSettings) do
		if BGLM_GlobalDB[key] == nil then
			BGLM_GlobalDB[key] = value
		end
	end

	if not BGLM_LocalDB then BGLM_LocalDB = {} end
	for key, value in pairs(BGLM.defaultLocalSettings) do
		if BGLM_LocalDB[key] == nil then
			BGLM_LocalDB[key] = value
		end
	end
end

function BGLM.UpdateSettings_4_1()
	if BGLM_GlobalDB.restackInventory ~= nil then
		BG_GlobalDB.restackInventory = BGLM_GlobalDB.restackInventory
		BGLM_GlobalDB.restackInventory = nil
	end
end

-- joins any number of non-basic index tables together, one after the other. elements within the input-tables _will_ get mixed
function BGLM:JoinTables(...)
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

function BGLM.ShowTooltip(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	if self.tiptext then
		GameTooltip:SetText(self.tiptext, nil, nil, nil, nil, true)
	elseif self.itemLink then
		GameTooltip:SetHyperlink(self.itemLink)
	end
	GameTooltip:Show()
end
function BGLM.HideTooltip() GameTooltip:Hide() end

function BGLM.CreateHorizontalRule(parent)
	local line = parent:CreateTexture(nil, "ARTWORK")
	line:SetHeight(8)
	line:SetTexture("Interface\\Tooltips\\UI-Tooltip-Border")
	line:SetTexCoord(0.81, 0.94, 0.5, 1)

	return line
end

-- returns true if the requested mob is skinnable with our skinning skill
function BGLM:CanSkin(mobLevel)
	local skinning = Broker_Garbage.GetProfessionSkill(8613)
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
function BGLM:IsInteresting(cachedItemTable)
	local isInteresting, alwaysLoot
	if cachedItemTable.classification == Broker_Garbage.EXCLUDE then
		isInteresting = true
		alwaysLoot = BGLM_GlobalDB.lootExcludeItems
	elseif cachedItemTable.classification == Broker_Garbage.INCLUDE and not BGLM_GlobalDB.lootIncludeItems then
		isInteresting = false
	elseif cachedItemTable.quality < BGLM_LocalDB.minItemQuality then
		isInteresting = false
	else
		isInteresting = true
	end

	-- local isQuestItem = ( select(6, GetItemInfo(cachedItemTable.itemID)) ) == ( select(10, GetAuctionItemClasses()) )
	local isTopFitInteresting = IsAddOnLoaded("TopFit") and Broker_Garbage.IsItemEquipment(select(9, GetItemInfo(cachedItemTable.itemID))) and TopFit:IsInterestingItem(cachedItemTable.itemID)

	if isTopFitInteresting or BGLM_GlobalDB.forceClear or alwaysLoot then
		return isInteresting, true
	else
		return isInteresting, false
	end
end

-- returns <shouldAL:true|false>, <clearAll:true|false>
function BGLM:ShouldAutoLoot(blizzAutoLoot)
	local lootAny = blizzAutoLoot ~= 0 or BGLM_GlobalDB.autoLoot
	local lootPickpocket = BGLM_GlobalDB.autoLootPickpocket and Broker_Garbage:GetVariable("playerClass") == "ROGUE" and IsStealthed()
	local lootFishing = BGLM_GlobalDB.autoLootFishing and IsFishingLoot()
	local lootSkinning = BGLM_GlobalDB.autoLootSkinning and UnitExists("target") and UnitIsDead("target") and UnitCreatureType("target") == BGLM.locale.CreatureTypeBeast and BGLM:CanSkin(UnitLevel("target"))

	return (lootAny or lootPickpocket or lootFishing or lootSkinning), (BGLM_GlobalDB.forceClear or lootSkinning)
end

function BGLM:IsPrivateLoot()
	local private = nil
	if IsFishingLoot() then
		private = true
	elseif BGLM.privateLoot then
		if GetTime() - BGLM.privateLoot <= BGLM_GlobalDB.privateLootTimer then
			private = true
		else	-- reset, data is too old
			BGLM.privateLoot = nil
		end
	end
	return private
end

-- returns -threshold if player is LootMaster, nil if unrestricted or else threshold
function BGLM:GetLootConstraint()
	if BGLM:IsPrivateLoot() or not (IsInGroup() or IsInRaid()) then
		return nil
	else
		local lootMethod, lootMasterGroup, lootMasterRaid = GetLootMethod()
		local lootThreshold = GetLootThreshold()

		if lootMethod == "freeforall" then
			return nil
		elseif lootMethod == "master" then
			local playerIsLootMaster

			if IsInRaid() then
				playerIsLootMaster = lootMasterRaid and UnitIsUnit("raid"..lootMasterRaid, "player")
			else
				playerIsLootMaster = lootMasterGroup and lootMasterGroup == 0
			end

			return (playerIsLootMaster and -1 or 1) * lootThreshold
		else
			return lootThreshold
		end
	end
end

function BGLM:DeleteCheapestItem()
	local item = Broker_Garbage.cheapestItems and Broker_Garbage.cheapestItems
	if item then
		Broker_Garbage.Delete(item)
	end
end
