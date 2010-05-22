_, BrokerGarbage = ...

BrokerGarbage:CheckSettings()

-- options panel
if BrokerGarbage.PT then
	BrokerGarbage.categoryTest = CreateFrame("Frame", "BrokerGarbageCategoryTestFrame", InterfaceOptionsFramePanelContainer)
	BrokerGarbage.categoryTest.name = BrokerGarbage.locale.PTCategoryTest
	BrokerGarbage.categoryTest.parent = "Broker_Garbage"
	BrokerGarbage.categoryTest:Hide()

	-- button tooltip infos
	local function ShowTooltip(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		if self.tiptext then
			GameTooltip:SetText(self.tiptext, nil, nil, nil, nil, true)
		elseif self.itemLink then
			GameTooltip:SetHyperlink(self.itemLink)
		end
		GameTooltip:Show()
	end
	local function HideTooltip() GameTooltip:Hide() end

	local category
	local boxHeight = 200
	local boxWidth = 330
	local numCols = 8

	local backdrop = {
		bgFile = "Interface\\ChatFrame\\ChatFrameBackground", insets = {left = 4, right = 4, top = 4, bottom = 4},
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 16
	}

	function BrokerGarbage:UpdatePreviewBox(finish)
		if category == nil or category == "" then return end
		if not BrokerGarbage.listButtons.preview then BrokerGarbage.listButtons.preview = {} end
		local buttonList = BrokerGarbage.listButtons.preview
		local itemList = {}
		
		local index = 1
		for itemID, value, set in BrokerGarbage.PT:IterateSet(category) do
			if buttonList[index] then
				-- use available button
				local button = buttonList[index]
				local itemLink, texture
				_, itemLink, _, _, _, _, _, _, _, texture, _ = GetItemInfo(itemID)
				button.itemID = itemID
				button.itemLink = itemLink
				button:SetNormalTexture(texture)
				button:SetChecked(false)
				button:Show()
				
			else
				-- create another button
				local iconbutton = CreateFrame("CheckButton", "BG_PreviewIconButton"..index, _G["BG_PreviewBoxContent"])
				iconbutton:Hide()
				iconbutton:SetWidth(36)
				iconbutton:SetHeight(36)
				
				iconbutton:SetNormalTexture("Interface\\Icons\\Inv_misc_questionmark")
				iconbutton:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square")
				iconbutton:SetCheckedTexture("Interface\\Buttons\\UI-Button-Outline")
				iconbutton:SetChecked(false)
				local tex = iconbutton:GetCheckedTexture()
				tex:ClearAllPoints()
				tex:SetPoint("CENTER")
				tex:SetWidth(36/37*66) tex:SetHeight(36/37*66)
				
				iconbutton:SetScript("OnClick", function(self)
					local check = self:GetChecked()
					BrokerGarbage:Debug("OnClick", check)
					
					if IsModifiedClick("CHATLINK") and ChatFrameEditBox:IsVisible() then
						-- post item link
						ChatFrameEditBox:Insert(self.itemLink)
						self:SetChecked(not check)
					else
						self:SetChecked(not check)
					end
				end)
				iconbutton:SetScript("OnEnter", ShowTooltip)
				iconbutton:SetScript("OnLeave", HideTooltip)
				
				if index == 1 then
					-- place first icon
					iconbutton:SetPoint("TOPLEFT", "BG_PreviewBoxContent", "TOPLEFT", 6, -6)
				elseif mod(index, numCols) == 1 then
					-- new row
					iconbutton:SetPoint("TOPLEFT", buttonList[index-numCols], "BOTTOMLEFT", 0, -6)
				else
					-- new button next to the old one
					iconbutton:SetPoint("LEFT", buttonList[index-1], "RIGHT", 4, 0)
				end
				buttonList[index] = iconbutton
			end
			
			if GetItemCount(itemID) ~= 0 and not itemList[itemID] then
				itemList[itemID] = true
				index = index + 1
			end
		end
		
		-- hide unnessessary buttons
		while buttonList[index] do
			buttonList[index]:Hide()
			index = index + 1
		end
		
		if not finish then
			BrokerGarbage:UpdatePreviewBox(true)
		end
	end

	local function ShowOptions()
		local title, subtitle = LibStub("tekKonfig-Heading").new(BrokerGarbage.categoryTest, BrokerGarbage.locale.PTCategoryTestTitle, BrokerGarbage.locale.PTCategoryTestSubTitle)

		local explainText = BrokerGarbage.categoryTest:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
		explainText:SetPoint("TOPLEFT", subtitle, "BOTTOMLEFT", 0, 0)
		explainText:SetPoint("RIGHT", BrokerGarbage.categoryTest, -32, 0)
		explainText:SetHeight(40)
		explainText:SetNonSpaceWrap(true)
		explainText:SetJustifyH("LEFT")
		explainText:SetJustifyV("TOP")
		explainText:SetText(BrokerGarbage.locale.PTCategoryTestExplanation)
		
		-- dropdown menu for choosing the LPT string to view
		local categoryString, categoryText, categoryContainer = LibStub("tekKonfig-Dropdown").new(BrokerGarbage.categoryTest, BrokerGarbage.locale.PTCategoryTestDropdownTitle, "TOPLEFT", explainText, "BOTTOMLEFT", 0, -10)
		categoryText:SetText(BrokerGarbage.locale.PTCategoryTestDropdownText)
		categoryString:SetWidth(400)
		
		local function OnClick()
			UIDropDownMenu_SetSelectedValue(categoryString, this.category)
			category = this.category
			categoryText:SetText(category)
			BrokerGarbage:UpdatePreviewBox()
		end
		
		UIDropDownMenu_Initialize(categoryString, function(self,level)
			local selected = UIDropDownMenu_GetSelectedValue(categoryString)
			level = level or 1
			if level == 1 then
				for key, subarray in pairs(BrokerGarbage.PTSets) do
					-- submenus
					local info = UIDropDownMenu_CreateInfo()
					info.hasArrow = true
					info.text = key
					info.category = key
					info.checked = key == selected
					info.value = {
						[1] = key
					}
					info.func = function()
						category = key
						UIDropDownMenu_SetSelectedValue(categoryString, category)
						categoryText:SetText(category)
						BrokerGarbage:UpdatePreviewBox()
					end
					UIDropDownMenu_AddButton(info, level)
				end
			
			else
				-- getting values of first menu
				local parentValue = UIDROPDOWNMENU_MENU_VALUE
				local PTSets = BrokerGarbage.PTSets
				for i = 1, level - 1 do
					PTSets = PTSets[ parentValue[i] ]
				end
				
				for key, value in pairs(PTSets) do
					local newValue = {}
					for i = 1, level - 1 do
						newValue[i] = parentValue[i]
					end
					newValue[level] = key
					-- calculate category string
					local valueString = newValue[1]
					for i = 2, level do
						valueString = valueString.."."..newValue[i]
					end
					
					local info = UIDropDownMenu_CreateInfo();
					if type(value) == "table" then
						-- submenu
						info.hasArrow = true
						info.category = valueString
						info.value = newValue
						info.func = function()
							category = valueString
							UIDropDownMenu_SetSelectedValue(categoryString, category)
							categoryText:SetText(category)
							BrokerGarbage:UpdatePreviewBox()
						end
					else
						-- end node
						info.hasArrow = false
						info.func = function()
							category = valueString
							UIDropDownMenu_SetSelectedValue(categoryString, category)
							categoryText:SetText(category)
							BrokerGarbage:UpdatePreviewBox()
						end
					end
					info.checked = valueString == selected
					info.text = key
					
					UIDropDownMenu_AddButton(info, level);
				end
			end
		end)
		
		-- create the container
		local previewBox = CreateFrame("ScrollFrame", "BG_PreviewBox", BrokerGarbage.categoryTest, "UIPanelScrollFrameTemplate")
		previewBox:SetPoint("TOPLEFT", categoryContainer, "BOTTOMLEFT", 8, 4)
		previewBox:SetHeight(boxHeight)
		previewBox:SetWidth(boxWidth)
		previewBox:SetBackdrop(backdrop)
		previewBox:SetBackdropBorderColor(0.4, 0.4, 0.4)
		previewBox:SetBackdropColor(0.1, 0.1, 0.1)
		
		local group_preview = CreateFrame("Frame", "BG_PreviewBoxContent", previewBox)
		group_preview:SetAllPoints()
		group_preview:SetHeight(boxHeight)
		group_preview:SetWidth(boxWidth)
		previewBox:SetScrollChild(group_preview)
		
		-- now do the update & reset functions
		BrokerGarbage:UpdatePreviewBox()
		BrokerGarbage.categoryTest:SetScript("OnShow", BrokerGarbage.UpdatePreviewBox)
	end

	--BrokerGarbage.categoryTest:SetScript("OnShow", ShowOptions)
	table.insert(BrokerGarbage.optionsModules, BrokerGarbage.categoryTest)
	BrokerGarbage.optionsModules[#BrokerGarbage.optionsModules].OnShow = ShowOptions
end