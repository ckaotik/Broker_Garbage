_, BrokerGarbage = ...

-- options panel
if BrokerGarbage.PT then
	local function ShowTooltip(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		if self.tiptext then
			GameTooltip:SetText(self.tiptext, nil, nil, nil, nil, true)
		elseif self.link then
			GameTooltip:SetHyperlink(self.link)
		end
		GameTooltip:Show()
	end
	local function HideTooltip() GameTooltip:Hide() end

	local category
	local numCols = 8

	local backdrop = {
		bgFile = "Interface\\ChatFrame\\ChatFrameBackground", insets = {left = 4, right = 4, top = 4, bottom = 4},
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 16
	}

	local function Options_CategoryTest(pluginID)
		local panel, tab = BrokerGarbage:CreateOptionsTab(pluginID)
		
		local explainText = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
		explainText:SetPoint("TOPLEFT", 16, -16)
		explainText:SetPoint("RIGHT", panel, -16, 0)
		explainText:SetHeight(40)
		explainText:SetNonSpaceWrap(true)
		explainText:SetJustifyH("LEFT")
		explainText:SetJustifyV("TOP")
		explainText:SetText(BrokerGarbage.locale.PTCategoryTestExplanation)
		
		-- dropdown menu for choosing the LPT string to view
		local categoryString, categoryText, categoryContainer = LibStub("tekKonfig-Dropdown").new(panel, BrokerGarbage.locale.PTCategoryTestDropdownTitle, "TOPLEFT", explainText, "BOTTOMLEFT", 0, 10)
		categoryText:SetText(BrokerGarbage.locale.PTCategoryTestDropdownText)
		categoryString:SetWidth(400)
		
		-- create the container
		local scrollFrame = CreateFrame("ScrollFrame", "BG_CategoryTest_Scroll", panel, "UIPanelScrollFrameTemplate")
		scrollFrame:SetPoint("TOPLEFT", categoryContainer, "BOTTOMLEFT", 8, 4)
		scrollFrame:SetHeight(200)
		scrollFrame:SetWidth(330)
		scrollFrame:SetBackdrop(backdrop)
		scrollFrame:SetBackdropBorderColor(0.4, 0.4, 0.4)
		scrollFrame:SetBackdropColor(0.1, 0.1, 0.1)
		
		local scrollFrameContent = CreateFrame("Frame", scrollFrame:GetName().."Frame", scrollFrame)
		scrollFrameContent:SetAllPoints()
		scrollFrameContent:SetHeight(200)
		scrollFrameContent:SetWidth(330)
		scrollFrame:SetScrollChild(scrollFrameContent)
		
		local function UpdatePreviewBox()
			local category = UIDropDownMenu_GetSelectedValue(categoryString)
			if not category or category == "" then return end
			
			local index, itemList = 0, {}
			for itemID, value in BrokerGarbage.PT:IterateSet(category) do
				local show = false
				if GetItemCount(itemID) ~= 0 and not itemList[itemID] then
					itemList[itemID] = true
					index = index + 1
					show = true
				end
				
				if show then
					local button = _G["BG_PreviewIconButton"..index]
					if not button then
						-- create another button
						button = CreateFrame("Button", "BG_PreviewIconButton"..index, scrollFrameContent, "ItemButtonTemplate")
						
						button:SetScript("OnClick", function(self)
							HandleModifiedItemClick(self.link)
						end)
						button:SetScript("OnEnter", ShowTooltip)
						button:SetScript("OnLeave", HideTooltip)
						
						if index == 1 then	-- place first icon
							button:SetPoint("TOPLEFT", scrollFrameContent, "TOPLEFT", 6, -6)
						elseif mod(index, numCols) == 1 then	-- new row
							button:SetPoint("TOPLEFT", _G["BG_PreviewIconButton"..index-numCols], "BOTTOMLEFT", 0, -6)
						else	-- new button next to the old one
							button:SetPoint("LEFT", _G["BG_PreviewIconButton"..index-1], "RIGHT", 4, 0)
						end
					end
					local _, itemLink, _, _, _, _, _, _, _, texture = GetItemInfo(itemID)
					button.itemID = itemID
					button.link = itemLink
					SetItemButtonTexture(button, texture or "Interface\\Icons\\Inv_misc_questionmark")
					button:Show()
				end
			end
			
			-- hide unnessessary buttons
			index = index + 1
			while _G["BG_PreviewIconButton"..index] do
				_G["BG_PreviewIconButton"..index]:Hide()
				index = index + 1
			end
		end
		
		local function OnDropDownClick(self)
			UIDropDownMenu_SetSelectedValue(categoryString, self.value)
			categoryText:SetText(self.value)
			UpdatePreviewBox()
		end
		
		UIDropDownMenu_Initialize(categoryString, function(self, level)
			local selected = UIDropDownMenu_GetSelectedValue(categoryString)
			
			local dataTable = BrokerGarbage.PTSets or {}
			if UIDROPDOWNMENU_MENU_VALUE and string.find(UIDROPDOWNMENU_MENU_VALUE, ".") then
				local parts = { strsplit(".", UIDROPDOWNMENU_MENU_VALUE) } or {}
				for k = 1, #parts do
					dataTable = dataTable[ parts[k] ]
				end
			elseif UIDROPDOWNMENU_MENU_VALUE then
				dataTable = dataTable[ UIDROPDOWNMENU_MENU_VALUE ] or {}
			end
			
			for key, value in pairs(dataTable) do
				local info = UIDropDownMenu_CreateInfo()
				local prefix = ""
				if UIDROPDOWNMENU_MENU_VALUE then
					prefix = UIDROPDOWNMENU_MENU_VALUE .. "."
				end
				
				info.text = key
				info.value = prefix .. key
				info.hasArrow = type(value) == "table" and true or false
				info.checked = info.value == selected
				info.func = OnDropDownClick
				
				UIDropDownMenu_AddButton(info, level);
			end
		end)
	end
	local _ = BrokerGarbage:RegisterPlugin(BrokerGarbage.locale.PTCategoryTest, Options_CategoryTest)
end