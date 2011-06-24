local _, BGLM = ...


BGLM.PT = LibStub("LibPeriodicTable-3.1", true)

function BGLM:Print(text, trigger)
	if trigger == nil or trigger == true then
		DEFAULT_CHAT_FRAME:AddMessage("|cffee6622Broker_Garbage LootManager|r "..text)
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
	restackInventory = true,
	autoLoot = false,
	autoLootSkinning = true,
	autoLootFishing = true,
	autoLootPickpocket = true,
	closeLootWindow = true,
	forceClear = false,
	autoConfirmBoP = false,
	useInCombat = false,
	tooFewSlots = 0,
	
	warnLM = true,
	warnInvFull = false,
	printValue = true,
	printCompareValue = true,
	printJunk = true,
	printSpace = true,
	printLocked = true,
	
	-- semi-internals
	privateLootTimer = 4,
}
BGLM.defaultLocalSettings = {
	-- behavior
	itemMinValue = 0,
	autoDestroy = false,
	autoDestroyInstant = false,
}

BGLM.PT = LibStub("LibPeriodicTable-3.1", true)

-- Helper functions
-- ---------------------------------------------------------
function BGLM.SetMinValue(value)
	BGLM_LocalDB.itemMinValue = value
end

function BGLM.SetMinSlots(value)
	BGLM_GlobalDB.tooFewSlots = value
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

function BGLM:GetItemID(itemLink)
	if not itemLink then return end
	local itemID = string.gsub(itemLink, ".-Hitem:([0-9]*):.*", "%1")
	return tonumber(itemID)
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

function BGLM:Find(table, value)
	for k, v in pairs(table) do
		if (v == value) then return true end
	end
	return false
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