local _, BGC = ...

-- GLOBALS: LibStub, Broker_Garbage, Broker_Garbage_Config, UIDROPDOWNMENU_MENU_VALUE, GameTooltip, _G, DEFAULT_CHAT_FRAME
-- GLOBALS: UIDropDownMenu_CreateInfo, UIDropDownMenu_AddButton, GetItemInfo, GetEquipmentSetInfo, GetAuctionItemSubClasses, ClearCursor, CreateFrame

BGC.quality = {
	[0] = "|c"..select(4,GetItemQualityColor(0))..ITEM_QUALITY0_DESC.."|r",	-- gray (junk)
	[1] = "|c"..select(4,GetItemQualityColor(1))..ITEM_QUALITY1_DESC.."|r",	-- white
	[2] = "|c"..select(4,GetItemQualityColor(2))..ITEM_QUALITY2_DESC.."|r",	-- green
	[3] = "|c"..select(4,GetItemQualityColor(3))..ITEM_QUALITY3_DESC.."|r",	-- blue
	[4] = "|c"..select(4,GetItemQualityColor(4))..ITEM_QUALITY4_DESC.."|r",	-- purple
	[5] = "|c"..select(4,GetItemQualityColor(5))..ITEM_QUALITY5_DESC.."|r",	-- legendary
	[6] = "|c"..select(4,GetItemQualityColor(6))..ITEM_QUALITY6_DESC.."|r",	-- heirloom
	[7] = "|c"..select(4,GetItemQualityColor(7))..ITEM_QUALITY7_DESC.."|r",	-- artifact
}

-- Basic Functions
-- ---------------------------------------------------------
function BGC:Print(text)
	DEFAULT_CHAT_FRAME:AddMessage("|cffee6622Broker_Garbage|r "..(text or ""))
end

function BGC.Find(where, value)
	if not where then return end
	for k, v in pairs(where) do
		if v == value then
			return k
		end
	end
end

function BGC.GetListEntryInfo(item)
	local link, resetRequired = nil, nil
	-- create "link" for output
	if item and type(item) == "number" then -- item on cursor
		link = select(2, GetItemInfo(item))

	elseif item and type(item) == "string" then
		resetRequired = true
		local specialType, identifier = match(item, "^(.-)_(.+)")
		if specialType == "BEQ" then
			-- equipment set
			identifier = tonumber(identifier)
			link = identifier and GetEquipmentSetInfo(identifier) or "Invalid Set"
		elseif specialType == "AC" then
			-- armor class
			identifier = tonumber(identifier)
			local armorType = select(identifier, GetAuctionItemSubClasses(2))
			link = BGC.locale.armorClass .. ": " .. (armorType or "Invalid Armor Class")
		elseif specialType == "NAME" then
			link = BGC.locale.anythingCalled .. " \"" .. identifier .. "\""
		else
			-- LPT category
			link = item
		end
	end
	return link, resetRequired
end

-- Config Helpers
-- -------------------------------------------------------------------------------------
function BGC.ShowTooltip(self)
	if not self.tiptext and not self.link then return end
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	GameTooltip:ClearLines()

	if self.link then
		GameTooltip:SetHyperlink(self.link)
	elseif type(self.tiptext) == "string" and self.tiptext ~= "" then
		GameTooltip:SetText(self.tiptext, nil, nil, nil, nil, true)
	elseif type(self.tiptext) == "function" then
		self.tiptext(self, GameTooltip)
	end
	GameTooltip:Show()
end
function BGC:HideTooltip() GameTooltip:Hide() end

function BGC.CreateHorizontalRule(parent)
	local line = parent:CreateTexture(nil, "ARTWORK")
	line:SetHeight(8)
	line:SetTexture("Interface\\Tooltips\\UI-Tooltip-Border")
	line:SetTexCoord(0.81, 0.94, 0.5, 1)

	return line
end

function BGC.CreateCheckBox(parent, size, text, ...)
	local check, label = LibStub("tekKonfig-Checkbox").new(parent, size, text, ...)
	label:SetPoint("TOPLEFT", check, "TOPRIGHT", 0, -6)
	label:SetPoint("RIGHT", parent)
	label:SetWordWrap(true)
	label:SetJustifyH("LEFT")
	label:SetJustifyV("TOP")
	check:SetHitRectInsets(0, -1 * label:GetStringWidth(), 0, 0)

	return check, label
end
