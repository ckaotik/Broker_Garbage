local _, BGC = ...
if not BGC.PT then return end

-- options panel
local category
local numCols = 8

local backdrop = {
	bgFile = "Interface\\ChatFrame\\ChatFrameBackground", insets = {left = 4, right = 4, top = 4, bottom = 4},
	edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 16
}

local function Options_CategoryTest(pluginID)
	local panel, tab = BGC:CreateOptionsTab(pluginID)

	local explainText = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	explainText:SetPoint("TOPLEFT", 16, -16)
	explainText:SetPoint("RIGHT", panel, -16, 0)
	explainText:SetHeight(40)
	explainText:SetNonSpaceWrap(true)
	explainText:SetJustifyH("LEFT")
	explainText:SetJustifyV("TOP")
	explainText:SetText(BGC.locale.PTCategoryTestExplanation)

	local function UpdatePreviewBox(data, dataType, parent)
		if not (data and dataType) then return end

		if dataType == "item" then
			local itemLink = select(2, GetItemInfo(data))
			local output = string.format(BGC.locale.categoryTestItemTitle, itemLink)
			local itemCategories = Broker_Garbage.GetItemListCategories( Broker_Garbage.GetCached(data) )
			if #itemCategories == 0 then
				output = string.format(BGC.locale.categoryTestItemEntry, itemLink)
			else
				for _, listName in ipairs(itemCategories) do
					output = output .. "\n    " .. listName
				end
			end

			if not parent.outputText then
				local outputText = parent:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
				outputText:SetPoint("TOPLEFT", parent, "TOPLEFT", 8, -8)
				outputText:SetWidth(parent:GetWidth() - 8)	-- substract the offset we added to the left
				outputText:SetWordWrap(true)
				outputText:SetJustifyH("LEFT")
				outputText:SetJustifyV("TOP")

				parent.outputText = outputText
			end
			parent.outputText:Show()
			parent.outputText:SetText(output)

			-- hide item buttons
			index = 1
			while _G["BG_PreviewIconButton"..index] do
				_G["BG_PreviewIconButton"..index]:Hide()
				index = index + 1
			end

		elseif dataType == "category" then
			if parent.outputText then
				parent.outputText:Hide()
			end

			local index, itemList = 0, {}
			for itemID, value in BGC.PT:IterateSet(data) do
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
						button = CreateFrame("Button", "BG_PreviewIconButton"..index, parent, "ItemButtonTemplate")

						button:SetScript("OnClick", function(self)
							HandleModifiedItemClick(self.link)
						end)
						button:SetScript("OnEnter", BGC.ShowTooltip)
						button:SetScript("OnLeave", BGC.HideTooltip)

						if index == 1 then	-- place first icon
							button:SetPoint("TOPLEFT", parent, "TOPLEFT", 6, -6)
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
	end

	-- create the container
	local scrollFrame = CreateFrame("ScrollFrame", "BG_CategoryTest_Scroll", panel, "UIPanelScrollFrameTemplate")
	scrollFrame:SetPoint("TOPLEFT", explainText, "BOTTOMLEFT", 0, -30)
	scrollFrame:SetHeight(200)
	scrollFrame:SetWidth(342)
	scrollFrame:SetBackdrop(backdrop)
	scrollFrame:SetBackdropBorderColor(0.4, 0.4, 0.4)
	scrollFrame:SetBackdropColor(0.1, 0.1, 0.1)

	local scrollFrameContent = CreateFrame("Frame", scrollFrame:GetName().."Frame", scrollFrame)
	scrollFrameContent:SetAllPoints()
	scrollFrameContent:SetWidth( scrollFrame:GetWidth() - 22)
	scrollFrameContent:SetHeight( scrollFrame:GetHeight() )
	scrollFrame:SetScrollChild(scrollFrameContent)

	-- dropdown menu for choosing the LPT string to view
	local LPTDropDown = CreateFrame("Frame", "BG_CategoryTestDropDown", panel, "UIDropDownMenuTemplate")
	LPTDropDown:SetPoint("BOTTOMLEFT", scrollFrame, "TOPLEFT", -16, -2)
	-- _G[LPTDropDown:GetName() .. "Button"].tiptext = BGC.locale.PTCategoryTestDropdownText
	-- _G[LPTDropDown:GetName() .. "Button"]:SetScript("OnEnter", BGC.ShowTooltip)
	-- _G[LPTDropDown:GetName() .. "Button"]:SetScript("OnLeave", BGC.HideTooltip)
	_G[LPTDropDown:GetName() .. "Button"]:SetPoint("LEFT", _G[LPTDropDown:GetName().."Middle"])
	UIDropDownMenu_SetText(LPTDropDown, BGC.locale.PTCategoryTestDropdownText)
	UIDropDownMenu_SetWidth(LPTDropDown, 300)

	itemSlot = CreateFrame("Button", "BG_CategoryTestItemSlot", panel, "ItemButtonTemplate")
	itemSlot:SetPoint("BOTTOMLEFT", LPTDropDown, "BOTTOMRIGHT", -8, 8)
	itemSlot:SetScript("OnClick", function(self)
		local type, item = GetCursorInfo()
		if type == "item" and item then
			self.itemID = item
			SetItemButtonTexture(self, (select(10, GetItemInfo(item))) )
			UpdatePreviewBox(item, "item", scrollFrameContent)
			ClearCursor()
		end
	end)
	SetItemButtonTexture(itemSlot, [[Interface\PaperDoll\UI-PaperDoll-Slot-Bag]])
	itemSlot:SetScript("OnEnter", BGC.ShowTooltip)
	itemSlot:SetScript("OnLeave", BGC.HideTooltip)
	itemSlot.tiptext = BGC.locale.categoryTestItemSlot

	LPTDropDown.initialize = function(self, level)
		BGC:LPTDropDown(self, level, function(self)
			UIDropDownMenu_SetSelectedValue(LPTDropDown, self.value)
			UIDropDownMenu_SetText(LPTDropDown, self.value)
			UpdatePreviewBox(self.value, "category", scrollFrameContent)
		end)
	end
end
local _ = Broker_Garbage:RegisterPlugin(BGC.locale.PTCategoryTest, Options_CategoryTest)
