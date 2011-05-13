local _, BGC = ...

BGC.modules = Broker_Garbage:GetVariable("modules")

BGC.quality = {
	[0] = select(4,GetItemQualityColor(0))..ITEM_QUALITY0_DESC.."|r",	-- gray (junk)
	[1] = select(4,GetItemQualityColor(1))..ITEM_QUALITY1_DESC.."|r",	-- white
	[2] = select(4,GetItemQualityColor(2))..ITEM_QUALITY2_DESC.."|r",	-- green
	[3] = select(4,GetItemQualityColor(3))..ITEM_QUALITY3_DESC.."|r",	-- blue
	[4] = select(4,GetItemQualityColor(4))..ITEM_QUALITY4_DESC.."|r",	-- purple
	[5] = select(4,GetItemQualityColor(5))..ITEM_QUALITY5_DESC.."|r",	-- legendary
	[6] = select(4,GetItemQualityColor(6))..ITEM_QUALITY6_DESC.."|r",	-- heirloom
	[7] = select(4,GetItemQualityColor(7))..ITEM_QUALITY7_DESC.."|r",	-- artifact
}

-- Basic Functions
-- ---------------------------------------------------------
function BGC:Print(text)
	DEFAULT_CHAT_FRAME:AddMessage("|cffee6622Broker_Garbage|r "..text)
end

-- joins any number of non-basic index tables together, one after the other. elements within the input-tables _will_ get mixed
function BGC:JoinTables(...)
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

-- Config Helpers
-- -------------------------------------------------------------------------------------
-- button tooltip infos
function BGC.ShowTooltip(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	
	if self.itemLink then
		GameTooltip:SetHyperlink(self.itemLink)

	elseif self.itemID and type(self.itemID) == "number" then
		-- most likely an actual item
		local itemLink = select(2,GetItemInfo(self.itemID))
		if itemLink then
			GameTooltip:SetHyperlink(itemLink)
			if self:GetParent() == _G["BG_ListOptions_ScrollFrame"] and not self.itemLink then
				-- we just got new data for this tooltip!
				BGC:ListOptionsUpdate()
			end
		elseif self.tiptext then
			-- fallback, in case GetItemInfo() wasn't available
			GameTooltip:SetText(self.tiptext or BGC.locale.unknown, nil, nil, nil, nil, true)
		end

	elseif self.itemID and type(self.itemID) == "string" then
		if string.find(self.itemID, "^AC_") then
			-- armor class
			GameTooltip:ClearLines()
			GameTooltip:AddLine(BGC.locale.armorClass)
			GameTooltip:AddLine(self.tiptext or BGC.locale.unknown, 1, 1, 1, true)
		elseif string.find(self.itemID, "^BEQ_") then
			-- Blizzard Equipment Manager item set
			GameTooltip:ClearLines()
			GameTooltip:AddLine(BGC.locale.equipmentManager)
			GameTooltip:AddLine(self.tiptext or BGC.locale.unknown, 1, 1, 1, true)
		end
		
	elseif self.tiptext and self:GetParent() == _G["BG_ListOptions_ScrollFrame"] then
		-- LibPeriodicTable category
		local text = string.gsub(self.tiptext, "%.", " |cffffd200>|r ")
		
		GameTooltip:ClearLines() 
		GameTooltip:AddLine("LibPeriodicTable")
		GameTooltip:AddLine(text, 1, 1, 1, true)

	else
		GameTooltip:SetText(self.tiptext, nil, nil, nil, nil, true)
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

function BGC.CreateFrameBorders(frame)
	local left = frame:CreateTexture(nil, "BACKGROUND")
	left:SetWidth(8) left:SetHeight(20)
	left:SetPoint("LEFT", -5, 0)
	left:SetTexture("Interface\\Common\\Common-Input-Border")
	left:SetTexCoord(0, 0.0625, 0, 0.625)
	local right = frame:CreateTexture(nil, "BACKGROUND")
	right:SetWidth(8) right:SetHeight(20)
	right:SetPoint("RIGHT", 0, 0)
	right:SetTexture("Interface\\Common\\Common-Input-Border")
	right:SetTexCoord(0.9375, 1, 0, 0.625)
	local center = frame:CreateTexture(nil, "BACKGROUND")
	center:SetHeight(20)
	center:SetPoint("RIGHT", right, "LEFT", 0, 0)
	center:SetPoint("LEFT", left, "RIGHT", 0, 0)
	center:SetTexture("Interface\\Common\\Common-Input-Border")
	center:SetTexCoord(0.0625, 0.9375, 0, 0.625)
	
	return left, center, right
end

function BGC.CreateCheckBox(parent, size, text, ...)
	local check, label = LibStub("tekKonfig-Checkbox").new(parent, size, text, ...)
	check:SetHitRectInsets(0, -1 * label:GetStringWidth(), 0, 0)
	
	return check, label
end

local topTab = LibStub("tekKonfig-TopTab")
function BGC:CreateOptionsTab(id)
	if not id then BGC:Print("Error creating options tab: No id supplied."); return end
	local plugin = BGC.modules[id]

	local tab
	if id == 1 then
		tab = topTab.new(BGC.options, plugin.name, "BOTTOMLEFT", BGC.options.group, "TOPLEFT", 0, -4)
	else
		tab = topTab.new(BGC.options, plugin.name, "BOTTOMLEFT", BGC.modules[ id - 1 ].tab, "BOTTOMRIGHT", -15, 0)
	end
	
	panel = CreateFrame("Frame", nil, BGC.options.group)
	panel:SetAllPoints()
	panel.tab = tab
	
	tab.panel = panel
	tab:SetID(id)
	tab:SetScript("OnClick", function(self)
		BGC.ChangeView(self:GetID())
	end)
	tab:Deactivate()
	
	plugin.panel = panel
	plugin.tab = tab
	
	return panel, tab
end

-- ---------------------------------------------------------------------------------------

BGC.PT = LibStub("LibPeriodicTable-3.1", true)	-- don't scream if LPT isn't present
-- constructs a DropDown ready table
local function CreateLPTTable()
	BGC.PTSets = {}
	for set, _ in pairs( BGC.PT and BGC.PT.sets or {} ) do
		local partials = { strsplit(".", set) }
		local maxParts = #partials
		local pre = BGC.PTSets
			
		for i = 1, maxParts do
			if i == maxParts then
				-- actual clickable entries
				pre[ partials[i] ] = set
			else
				-- all parts before that
				if not pre[ partials[i] ] or type(pre[ partials[i] ]) == "string" then
					pre[ partials[i] ] = {}
				end
				pre = pre[ partials[i] ]
			end
		end
	end
end

function BGC:LPTDropDown(self, level, functionHandler, notChecked)
	if not BGC.PTSets then
		CreateLPTTable()
	end
	local dataTable = BGC.PTSets or {}
	if UIDROPDOWNMENU_MENU_VALUE and string.find(UIDROPDOWNMENU_MENU_VALUE, ".") then
		local parts = { strsplit(".", UIDROPDOWNMENU_MENU_VALUE) } or {}
		for k = 1, #parts do
			dataTable = dataTable[ parts[k] ] or {}
		end
	elseif UIDROPDOWNMENU_MENU_VALUE then
		dataTable = dataTable[ UIDROPDOWNMENU_MENU_VALUE ] or {}
	end

	-- display a heading
	if (level == 1) then		
		local info = UIDropDownMenu_CreateInfo()
		info.isTitle = true
		info.notCheckable = true
		info.text = BGC.locale.categoriesHeading
		UIDropDownMenu_AddButton(info, level)

		-- and some warning text, in case LPT is not available
		if not BGC.PT then
			local info = UIDropDownMenu_CreateInfo()
			info.isTitle = true
			info.notCheckable = true
			info.text = BGC.locale.LPTNotLoaded
			UIDropDownMenu_AddButton(info, level)
		end
	end
	
	for key, value in pairs(dataTable or {}) do
		local info = UIDropDownMenu_CreateInfo()
		local prefix = ""
		if UIDROPDOWNMENU_MENU_VALUE then
			prefix = UIDROPDOWNMENU_MENU_VALUE .. "."
		end
		
		info.text = key
		info.value = prefix .. key
		info.notCheckable = notChecked
		info.hasArrow = type(value) == "table" and true or false
		info.func = functionHandler
		
		UIDropDownMenu_AddButton(info, level);
	end
end

Broker_Garbage_Config = {
	CreateOptionsTab = BGC.CreateOptionsTab,
	CreateFrameBorders = BGC.CreateFrameBorders,
	CreateHorizontalRule = BGC.CreateHorizontalRule,
}