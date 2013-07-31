local _, BGC = ...

-- GLOBALS: Broker_Garbage, LibStub, _G, UIDROPDOWNMENU_MENU_VALUE, UIParent, StaticPopupDialogs, BG_GlobalDB, ITEM_QUALITY_COLORS, SEARCH
-- GLOBALS: IsShiftKeyDown, GetCursorInfo, StaticPopup_Show, ToggleDropDownMenu, UIDropDownMenu_AddButton, UIDropDownMenu_CreateInfo, GetAuctionItemSubClasses, GetEquipmentSetInfo, GetNumEquipmentSets, GetItemInfo, CreateFrame, MoneyInputFrame_GetCopper, IsModifiedClick, IsModifierKeyDown, HandleModifiedItemClick, PlaySound, InterfaceOptionsFramePanelContainer, SetItemButtonCount, SetItemButtonStock, SetItemButtonTexture, SetItemButtonNormalTextureVertexColor, EditBox_ClearFocus, InterfaceOptionsFrame_Show
-- GLOBALS: type, wipe, ipairs, tonumber, select, string, pairs, unpack
local tinsert = table.insert
local sort = table.sort
local floor = math.floor
local mod = mod
local match = string.match

local listOptions = CreateFrame("Frame", "BG_ListOptions", InterfaceOptionsFramePanelContainer)
listOptions.name = BGC.locale.LOTitle
listOptions.parent = "Broker_Garbage"

-- allow detaching the config frame so it can be used on smaller screens
local detachFrame, detachTrigger, attachPoint
local function ReAttach()
	listOptions:ClearAllPoints()
	listOptions:SetParent(InterfaceOptionsFramePanelContainer)
	listOptions:SetPoint(unpack(attachPoint))

	detachFrame:SetPropagateKeyboardInput(false)
	detachFrame:Hide()

	if detachTrigger then
		detachTrigger:Enable()
	end
end
local function ToggleDetach(trigger, btn)
	if not detachFrame then
		detachTrigger = detachTrigger or trigger
		attachPoint = { listOptions:GetPoint() }

		detachFrame = CreateFrame("Frame", "BG_ListOptionsDetached", UIParent, "BasicFrameTemplate")
		detachFrame:Hide()
		detachFrame:SetFrameStrata("HIGH")
		detachFrame:EnableKeyboard(true)
		detachFrame:SetClampedToScreen(true)
		detachFrame:EnableMouse(true)
		detachFrame:SetMovable(true)
		detachFrame:SetUserPlaced(true)
		detachFrame:SetPoint("CENTER")

		detachFrame:SetScript("OnMouseDown", function()
			detachFrame:StartMoving()
		end)
		detachFrame:SetScript("OnMouseUp", function()
			detachFrame:StopMovingOrSizing()
		end)
		detachFrame:SetScript("OnHide", function()
			ReAttach()
		end)
		detachFrame:SetScript("OnShow", function()
			local source = listOptions
			local w, h = source:GetSize()
			detachFrame:SetSize(w, h + 20)

			source:SetParent(detachFrame)
			source:ClearAllPoints()
			source:SetPoint("TOPLEFT", 0, -20)
			source:SetPoint("BOTTOMRIGHT")
		end)
		detachFrame:SetScript("OnKeyDown", function(self,key)
			if key == "ESCAPE" then
				ReAttach()
			end
		end)
	end

	if detachFrame:IsVisible() then
		ReAttach()
	else
		detachFrame:SetPropagateKeyboardInput(true)
		detachFrame:Show()
		detachTrigger:Disable()
	end
	-- this is actually a toggle ...
	InterfaceOptionsFrame_Show()
end

-- creates child options frame for setting up one's lists
function BGC:ShowListOptions(frame)
	local detach = LibStub("tekKonfig-Button").new(frame, "TOPRIGHT", frame, "TOPRIGHT", -16, -12)
	detach:SetText(BGC.locale.detachConfigText)
	detach.tiptext = BGC.locale.detachConfigTooltip
	detach:SetWidth(100)
	detach:RegisterForClicks("RightButtonUp", "LeftButtonUp")
	detach:SetScript("OnClick", ToggleDetach)

	local title = LibStub("tekKonfig-Heading").new(frame, "Broker_Garbage - " .. BGC.locale.LOTitle)

	local explanation = frame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	explanation:SetHeight(80)
	explanation:SetPoint("TOPLEFT", title, "TOPLEFT", 0, -20)
	explanation:SetPoint("RIGHT", frame, -4, 0)
	explanation:SetNonSpaceWrap(true)
	explanation:SetJustifyH("LEFT")
	explanation:SetJustifyV("TOP")
	explanation:SetText(BGC.locale.LOSubTitle)

	local autoSellIncludeItems = LibStub("tekKonfig-Checkbox").new(frame, nil, BGC.locale.LOIncludeAutoSellText, "TOPLEFT", explanation, "BOTTOMLEFT", 10, -8)
	autoSellIncludeItems.tiptext = BGC.locale.LOIncludeAutoSellTooltip .. BGC.locale.GlobalSetting
	autoSellIncludeItems:SetChecked( Broker_Garbage:GetOption("autoSellIncludeItems", true) )
	local checksound = autoSellIncludeItems:GetScript("OnClick")
	autoSellIncludeItems:SetScript("OnClick", function(autoSellIncludeItems)
		checksound(autoSellIncludeItems)
		Broker_Garbage:ToggleOption("autoSellIncludeItems", true)
		-- Broker_Garbage.ScanInventory(true)
		Broker_Garbage.UpdateAllDynamicItems()
	end)

	local includeMode = LibStub("tekKonfig-Checkbox").new(frame, nil, BGC.locale.LOUseRealValues, "TOPLEFT", autoSellIncludeItems, "BOTTOMLEFT", 0, 8)
	includeMode.tiptext = BGC.locale.LOUseRealValuesTooltip .. BGC.locale.GlobalSetting
	includeMode:SetChecked( Broker_Garbage:GetOption("useRealValues", true) )
	local checksound = includeMode:GetScript("OnClick")
	includeMode:SetScript("OnClick", function(includeMode)
		checksound(includeMode)
		Broker_Garbage:ToggleOption("useRealValues", true)
		Broker_Garbage.UpdateAllCaches()
		Broker_Garbage:UpdateLDB()
	end)

	local panel = LibStub("tekKonfig-Group").new(frame, nil, "TOPLEFT", includeMode, "BOTTOMLEFT", -10, -20)
	panel:SetPoint("LEFT", 10, 0)
	panel:SetPoint("BOTTOMRIGHT", -16, 34)

	local topTab = LibStub("tekKonfig-TopTab")
	local exclude = topTab.new(frame, BGC.locale.LOTabTitleExclude, "BOTTOMLEFT", panel, "TOPLEFT", 0, -4)
	frame.current = "exclude"
	local include = topTab.new(frame, BGC.locale.LOTabTitleInclude, "LEFT", exclude, "RIGHT", -15, 0)
	include:Deactivate()
	local autoSell = topTab.new(frame, BGC.locale.LOTabTitleAutoSell, "LEFT", include, "RIGHT", -15, 0)
	autoSell:Deactivate()
	local vendorPrice = topTab.new(frame, BGC.locale.LOTabTitleVendorPrice, "LEFT", autoSell, "RIGHT", -15, 0)
	vendorPrice:Deactivate()
	local help = topTab.new(frame, "?", "LEFT", vendorPrice, "RIGHT", -15, 0)
	help:Deactivate()

	local scrollFrame = CreateFrame("ScrollFrame", frame:GetName().."_Scroll", panel, "UIPanelScrollFrameTemplate")
	scrollFrame:SetSize(600, 300)
	scrollFrame:SetPoint("TOPLEFT", panel, "TOPLEFT", 0, -4)
	scrollFrame:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -26, 3)
	local scrollContent = CreateFrame("Frame", scrollFrame:GetName().."Frame", scrollFrame)
	scrollFrame:SetScrollChild(scrollContent)
	scrollContent:SetSize(600, 300)
	scrollContent:SetAllPoints()

	local default = LibStub("tekKonfig-Button").new(frame, "BOTTOMRIGHT", panel, "TOPRIGHT", 0, 30)
	default:SetText(BGC.locale.defaultListsText)
	default.tiptext = BGC.locale.defaultListsTooltip
	default:SetWidth(150)
	default:RegisterForClicks("RightButtonUp", "LeftButtonUp")
	default:SetScript("OnClick", function(self, button)
		Broker_Garbage:CreateDefaultLists(IsShiftKeyDown())
	end)

	local rescan = LibStub("tekKonfig-Button").new(frame, "BOTTOMRIGHT", panel, "TOPRIGHT", 0, 4)
	rescan:SetText(BGC.locale.rescanInventoryText)
	rescan.tiptext = BGC.locale.rescanInventoryTooltip
	rescan:SetWidth(150)
	rescan:RegisterForClicks("LeftButtonUp")
	rescan:SetScript("OnClick", function(self, button)
		-- Broker_Garbage.ScanInventory()
		Broker_Garbage.UpdateAllDynamicItems()
	end)

	-- action buttons
	local plus = CreateFrame("Button", "$parentAddEntryButton", frame)
	plus:SetPoint("TOPLEFT", panel, "BOTTOMLEFT", 4, -2)
	plus:SetWidth(25); plus:SetHeight(25)
	plus:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square")
	plus:SetNormalTexture("Interface\\Icons\\Spell_chargepositive")
	plus.tiptext = BGC.locale.LOPlus
	plus:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	local minus = CreateFrame("Button", "$parentRemoveEntryButton", frame)
	minus:SetPoint("LEFT", plus, "RIGHT", 4, 0)
	minus:SetWidth(25);	minus:SetHeight(25)
	minus:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square")
	minus:SetNormalTexture("Interface\\Icons\\Spell_chargenegative")
	minus.tiptext = BGC.locale.LOMinus
	local demote = CreateFrame("Button", "$parentDemoteButton", frame)
	demote:SetPoint("LEFT", minus, "RIGHT", 14, 0)
	demote:SetWidth(25) demote:SetHeight(25)
	demote:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square")
	demote:SetNormalTexture("Interface\\Icons\\INV_Misc_GroupLooking")
	demote.tiptext = BGC.locale.LODemote
	local promote = CreateFrame("Button", "$parentPromoteButton", frame)
	promote:SetPoint("LEFT", demote, "RIGHT", 4, 0)
	promote:SetWidth(25) promote:SetHeight(25)
	promote:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square")
	promote:SetNormalTexture("Interface\\Icons\\INV_Misc_GroupNeedMore")
	promote.tiptext = BGC.locale.LOPromote

	local savePriceSetting = function(value)
		if not value then return end
		local index, button, item, resetRequired = 1, nil, nil, nil
		while _G["BG_ListOptions_ScrollFrameItem"..index] do
			button = _G["BG_ListOptions_ScrollFrameItem"..index]
			if button:IsVisible() and button:GetChecked() then
				item = button.itemID or button.tiptext
				BG_GlobalDB.forceVendorPrice[item] = value
				if button.itemID and type(button.itemID) == "number" then
					Broker_Garbage.UpdateAllCaches(item)
				else
					resetRequired = true
				end
			end
			index = index + 1
		end

		if resetRequired then
			Broker_Garbage.UpdateAllDynamicItems()
		end
		Broker_Garbage:UpdateLDB()
		Broker_Garbage:UpdateMerchantButton()
		BGC:ListOptionsUpdate()
	end
	StaticPopupDialogs["BROKERGARBAGE_SETITEMPRICE"] = {
		text = BGC.locale.setPriceInfo,
		button1 = _G["OKAY"],
		button2 = _G["CANCEL"],
		button3 = _G["SELL_PRICE"],
		hasMoneyInputFrame = true,
		OnAccept = function(self)
			local value = MoneyInputFrame_GetCopper(self.moneyInputFrame)
			savePriceSetting(value)
		end,
		OnAlt = function(self)
			savePriceSetting(-1)
		end,
		OnShow = function(self)
			-- MoneyFrame_Update(self.moneyFrame, currentPrice)
		end,
		EditBoxOnEscapePressed = function(self)
			self:GetParent():GetParent().button2:Click()
		end,
		EditBoxOnEnterPressed = function(self)
			self:GetParent():GetParent().button1:Click()
		end,
		timeout = 0,
		whileDead = true,
		enterClicksFirstButton = true,
		hideOnEscape = true,
		preferredIndex = 3,
	}
	local setPrice = CreateFrame("Button", "$parentSetPriceButton", frame)
	setPrice:SetPoint("LEFT", promote, "RIGHT", 14, 0)
	setPrice:SetWidth(25); setPrice:SetHeight(25)
	setPrice:SetNormalTexture("Interface\\Icons\\INV_Misc_Coin_02") -- Coin_06
	setPrice.tiptext = BGC.locale.LOSetPrice
	setPrice:Disable(); setPrice:GetNormalTexture():SetDesaturated(true)

	local emptyList = CreateFrame("Button", "$parentClearListButton", frame)
	emptyList:SetPoint("LEFT", setPrice, "RIGHT", 14, 0)
	emptyList:SetWidth(25); emptyList:SetHeight(25)
	emptyList:SetNormalTexture("Interface\\Buttons\\UI-GroupLoot-Pass-UP")
	emptyList.tiptext = BGC.locale.LOEmptyList

	local searchbox = CreateFrame("EditBox", "$parentSearchBox", frame, "SearchBoxTemplate")
	searchbox:SetPoint("TOPRIGHT", panel, "BOTTOMRIGHT", -4, 2)
	searchbox:SetSize(160, 32)
	searchbox:SetText(SEARCH) -- TODO why won't it show :()
	searchbox:SetScript("OnEnterPressed", EditBox_ClearFocus)
	searchbox:SetScript("OnEscapePressed", function(self)
		self:SetText(SEARCH)
		PlaySound("igMainMenuOptionCheckBoxOn")
		EditBox_ClearFocus(self)
	end)
	searchbox:SetScript("OnTextChanged", function(self)
		local text = self:GetText()
		local oldText = self.searchString
		self.searchString = (text ~= "" and text ~= SEARCH) and string.lower(text) or nil
		if oldText ~= self.searchString then
			BGC:UpdateSearch(self.searchString)
		end
	end)
	searchbox.clearFunc = function(self)
		BGC:UpdateSearch(self.searchString)
	end

	-- tab changing actions
	local tabs = { include, exclude, vendorPrice, autoSell, help }
	local function ToggleTab(activated)
		for _, tab in ipairs(tabs) do
			if tab == activated then
				tab:Activate()
			else
				tab:Deactivate()
			end
		end
	end
	local function ToggleButton(button, enabled)
		if enabled then
			button:Enable()
			button:GetNormalTexture():SetDesaturated(false)
		else
			button:Disable()
			button:GetNormalTexture():SetDesaturated(true)
		end
	end
	include:SetScript("OnClick", function(self)
		ToggleTab(self)
		ToggleButton(promote, true)
		ToggleButton(demote, true)
		ToggleButton(setPrice, false)

		frame.current = "include"
		scrollFrame:SetVerticalScroll(0)
		BGC:ListOptionsUpdate()
	end)
	exclude:SetScript("OnClick", function(self)
		ToggleTab(self)
		ToggleButton(promote, true)
		ToggleButton(demote, true)
		ToggleButton(setPrice, false)

		frame.current = "exclude"
		scrollFrame:SetVerticalScroll(0)
		BGC:ListOptionsUpdate()
	end)
	vendorPrice:SetScript("OnClick", function(self)
		ToggleTab(self)
		ToggleButton(promote, false)
		ToggleButton(demote, false)
		ToggleButton(setPrice, true)

		frame.current = "forceVendorPrice"
		scrollFrame:SetVerticalScroll(0)
		BGC:ListOptionsUpdate()
	end)
	autoSell:SetScript("OnClick", function(self)
		ToggleTab(self)
		ToggleButton(promote, true)
		ToggleButton(demote, true)
		ToggleButton(setPrice, false)

		frame.current = "autoSellList"
		scrollFrame:SetVerticalScroll(0)
		BGC:ListOptionsUpdate()
	end)
	help:SetScript("OnClick", function(self)
		ToggleTab(self)
		ToggleButton(promote, true)
		ToggleButton(demote, true)
		ToggleButton(setPrice, false)

		frame.current = nil
		scrollFrame:SetVerticalScroll(0)
		BGC:ListOptionsUpdate()
	end)

	-- function to set the drop treshold (limit) via the mousewheel
	local function OnMouseWheel(self, dir)
		local list = Broker_Garbage:GetOption(frame.current, self.isGlobal)
		local key = self.itemID or self.tiptext

		local countText = _G[self:GetName()..'Count']
		local change = IsShiftKeyDown() and 10 or 1
			  change = (dir == 1) and change or change * -1
		local value = tonumber(list[key]) or 0
			  value = value + change
			  value = value > 0 and value or 0

		list[key] = value
		SetItemButtonCount(self, value)
		if value == 1 then
			countText:SetText(value)
			countText:Show()
		end

		if self.itemID then
			Broker_Garbage.UpdateCache(self.itemID)
		else
			-- commented because of huuuuge memory/CPU requirements
			-- Broker_Garbage.ScanInventory() -or- Broker_Garbage.UpdateAllDynamicItems()
		end
	end

	-- function that updates & shows items from various lists
	local data = {}
	function BGC:ListOptionsUpdate(listName)
		if listName and frame.current and listName ~= frame.current then
			return
		end

		if frame.current == nil then
			local index = 1
			while _G["BG_ListOptions_ScrollFrameItem"..index] do
				_G["BG_ListOptions_ScrollFrameItem"..index]:Hide()
				index = index + 1
			end
			BGC:ShowHelp()
			return
		elseif _G["BG_HelpFrame"] then
			_G["BG_HelpFrame"]:Hide()
		end

		local localList, globalList = Broker_Garbage:GetOption(frame.current)
		local dataList = BGC:JoinTables(globalList or {}, localList or {})

		-- make this table sortable
		wipe(data)
		for key, value in pairs(dataList) do
			tinsert(data, key)
		end
		sort(data, function(a,b)
			if type(a) == "string" and type(b) == "string" then
				return a < b
			elseif type(a) == "number" and type(b) == "number" then
				return (GetItemInfo(a) or "z") < (GetItemInfo(b) or "z")
			else
				return type(a) == "string"
			end
		end)

		local currentWidth = scrollFrame:GetWidth()
		scrollContent:SetWidth(currentWidth)					-- update scrollframe content to full width
		local numCols = floor((currentWidth - 20 - 2)/(36 + 2))	-- or is it panel's width we want?
		for index, itemID in ipairs(data) do
			local button = _G[scrollContent:GetName().."Item"..index]
			if not button then	-- create another button
				button = CreateFrame("CheckButton", "$parentItem"..index, scrollContent, 'ItemButtonTemplate')
				button:SetWidth(36)
				button:SetHeight(36)
				button:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square")
				button:SetCheckedTexture("Interface\\Buttons\\UI-Button-Outline")
				button:SetChecked(false)
				local tex = button:GetCheckedTexture()
				tex:ClearAllPoints()
				tex:SetPoint("CENTER")
				tex:SetWidth(36/37*66) tex:SetHeight(36/37*66)

				button:SetScript("OnClick", function(self)
					local check = self:GetChecked()
					if IsModifiedClick() then	-- this handles chat linking as well as dress-up
						local linkText = type(self.itemID) == "string" and self.itemID or BGC.locale.AuctionAddonUnknown
						HandleModifiedItemClick(self.itemLink or linkText)
						self:SetChecked(not check)
					elseif not IsModifierKeyDown() then
						self:SetChecked(check)
					else
						self:SetChecked(not check)
					end
				end)
				button:SetScript("OnEnter", BGC.ShowTooltip)
				button:SetScript("OnLeave", BGC.HideTooltip)
			end

			-- update button positions
			if index == 1 then		-- place first icon
				button:SetPoint("TOPLEFT", scrollContent, "TOPLEFT", 6, -6)
			elseif mod(index, numCols) == 1 then	-- new row
				button:SetPoint("TOPLEFT", "$parentItem" .. (index - numCols), "BOTTOMLEFT", 0, -6)
			else					-- new button next to the old one
				button:SetPoint("LEFT", "$parentItem" .. (index - 1), "RIGHT", 4, 0)
			end

			-- update this button with data
			local itemLink, texture, quality
			button.extraTipLine = nil
			if type(itemID) == "string" then
				local specialType, identifier = match(itemID, "^(.-)_(.+)")
				if specialType == "AC" then
					-- this is an armor class
					identifier = tonumber(identifier)
					identifier = select(identifier, GetAuctionItemSubClasses(2))
					texture = "Interface\\Icons\\INV_Misc_Toy_07"

					button.itemLink = nil
					button.itemID = itemID
					button.tiptext = identifier or "Invalid Armor Type"
				elseif specialType == "BEQ" then
					-- blizzard gear set
					identifier = tonumber(identifier)
					if identifier then
						itemLink, texture = GetEquipmentSetInfo(identifier)
					end

					button.itemLink = nil
					button.itemID = itemID
					button.tiptext = itemLink
				elseif specialType == "NAME" then
					-- item name filter
					texture = "Interface\\Icons\\Ability_Hunter_Pathfinding"

					button.itemLink = nil
					button.itemID = itemID
					button.tiptext = identifier
				else
					-- this is an item category
					texture = "Interface\\Icons\\Trade_engineering"

					button.itemLink = nil
					button.itemID = nil
					button.tiptext = itemID			-- category description string
				end
			else
				-- this is an explicit item
				_, itemLink, quality, _, _, _, _, _, _, texture, _ = GetItemInfo(itemID)
				button.itemLink = itemLink
				button.itemID = itemID
				button.tiptext = nil
			end

			if globalList[itemID] then
				_G[button:GetName().."Stock"]:SetText('G')
				_G[button:GetName().."Stock"]:Show()
				button.isGlobal = true
			else
				SetItemButtonStock(button, 0)
				button.isGlobal = false
			end

			if frame.current == "forceVendorPrice" then
				SetItemButtonCount(button, 0)
				if globalList[itemID] >= 0 then
					_G[button:GetName().."Stock"]:SetText('*')
					_G[button:GetName().."Stock"]:Show()
					button.extraTipLine = Broker_Garbage.FormatMoney(globalList[itemID])
				else
					SetItemButtonStock(button, 0)
				end
			else
				local listValue = (button.isGlobal and type(globalList[itemID]) == "number") and globalList[itemID]
					or  (not button.isGlobal and type( localList[itemID]) == "number") and localList[itemID]
					or 0

				SetItemButtonCount(button, listValue)
				if listValue == 1 then
					_G[button:GetName()..'Count']:Show()
				end
			end

			if not itemLink and not button.itemID and not BGC.PT then
				button:SetAlpha(0.2)
				button.tiptext = button.tiptext .. "\n|cffff0000"..BGC.locale.LPTNotLoaded
			else
				button:SetAlpha(1)
			end
			SetItemButtonTexture(button, texture or "Interface\\Icons\\INV_MISC_Questionmark")
			if quality and ITEM_QUALITY_COLORS[quality] then
				SetItemButtonNormalTextureVertexColor(button,
					ITEM_QUALITY_COLORS[quality].r, ITEM_QUALITY_COLORS[quality].g, ITEM_QUALITY_COLORS[quality].b)
			else
				SetItemButtonNormalTextureVertexColor(button, 1, 1, 1)
			end


			if listOptions.current ~= "forceVendorPrice" then
				button:EnableMouseWheel(true)
				button:SetScript("OnMouseWheel", OnMouseWheel)
			else
				button:EnableMouseWheel(false)
			end
			button:SetChecked(false)
			button:Show()
		end
		-- hide unnessessary buttons
		local index = #data + 1
		while _G[scrollContent:GetName().."Item"..index] do
			_G[scrollContent:GetName().."Item"..index]:Hide()
			index = index + 1
		end
	end

	-- shows some help strings for setting up the lists
	function BGC:ShowHelp()
		if not _G["BG_HelpFrame"] then
			local helpFrame = CreateFrame("Frame", "BG_HelpFrame", scrollContent)
			helpFrame:SetAllPoints()

			local helpTexts = helpFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
			helpTexts:SetPoint("TOPLEFT", helpFrame, "TOPLEFT", 8, -4)
			helpTexts:SetWidth(helpFrame:GetWidth() - 8)	-- substract the offset we added to the left
			helpTexts:SetWordWrap(true)
			helpTexts:SetJustifyH("LEFT")
			helpTexts:SetJustifyV("TOP")
			helpTexts:SetText(BGC.locale.listsBestUse .. "\n\n" ..
				BGC.locale.listsSpecialOptions .. "\n\n" ..
				BGC.locale.iconButtonsUse .. "\n\n" ..
				BGC.locale.actionButtonsUse .. "\n")
		else
			_G["BG_HelpFrame"]:Show()
		end
	end

	-- when a search string is passed, suitable items will be shown while the rest is grayed out
	function BGC:UpdateSearch(searchString)
		local index = 1
		local button = _G[scrollContent:GetName().."Item"..index]
		while button and button:IsVisible() do
			local name = button.itemID and GetItemInfo(button.itemID) or button.tiptext
			name = (button.itemID or "") .. " " .. (name or "")
			name = name:lower()

			if not searchString or match(name, searchString) then
				button:SetAlpha(1)
			else
				button:SetAlpha(0.3)
			end
			index = index + 1
			button = _G[scrollContent:GetName().."Item"..index]
		end
	end

	if not _G["BG_LPTMenuFrame"] then
		local RightClickMenuOnClick = function(self)
			local value = self
			if type(self) == "table" then
				value = self.value
			end

			local reset = BGC.RemoteAddItemToList(value, frame.current)
			if reset then
				Broker_Garbage.UpdateAllDynamicItems()
			end
			Broker_Garbage:UpdateLDB()
			Broker_Garbage.UpdateMerchantButton()
			BGC:ListOptionsUpdate()
		end

		StaticPopupDialogs["BROKERGARBAGE_ADDITEMNAME"] = {
			text = BGC.locale.namedItemsInfo,
			button1 = _G["OKAY"],
			button2 = _G["CANCEL"],
			hasEditBox = true,
			OnAccept = function(self)
				local name = self.editBox:GetText()
				name = GetItemInfo(name) or name

				if name and name ~= "" then
					name = "NAME_"..name
					local localList, globalList = Broker_Garbage:GetOption(frame.current)
					if localList and localList[name] == nil then localList[name] = 0
					elseif globalList and globalList[name] == nil then globalList[name] = 0
					end
					BGC:ListOptionsUpdate()
				end
			end,
			EditBoxOnEscapePressed = function(self)
				self:GetParent().button2:Click()
			end,
			EditBoxOnEnterPressed = function(self)
				self:GetParent().button1:Click()
			end,
			timeout = 0,
			whileDead = true,
			enterClicksFirstButton = true,
			hideOnEscape = true,
			preferredIndex = 3,
		}

		--initialize dropdown menu for adding setstrings
		BGC.menuFrame = CreateFrame("Frame", "BG_LPTMenuFrame", UIParent, "UIDropDownMenuTemplate")
		BGC.menuFrame.displayMode = "MENU"
		BGC.menuFrame.initialize = function(self, level)
			-- LPT sets as dropdown entries
			BGC:LPTDropDown(self, level, RightClickMenuOnClick, true)

			-- add equipment sets
			if level == 1 then
				-- placeholder
				local info = UIDropDownMenu_CreateInfo()
				info.notCheckable = true
				UIDropDownMenu_AddButton(info, level)

				info.notClickable = true
				info.isTitle = true
				info.text = BGC.locale.tooltipHeadingOther
				UIDropDownMenu_AddButton(info, level)

				-- reset unwanted attributes
				info.notClickable = nil
				info.isTitle = nil
				info.disabled = nil

				info.text = BGC.locale.namedItems
				info.value = "NAME"
				info.func = function()
					StaticPopup_Show("BROKERGARBAGE_ADDITEMNAME")
					ToggleDropDownMenu(nil, nil, BGC.menuFrame)
				end
				UIDropDownMenu_AddButton(info, level)

				info.hasArrow = true
				info.text = BGC.locale.equipmentManager
				info.value = "BEQ"
				UIDropDownMenu_AddButton(info, level)

				info.text = BGC.locale.armorClass
				info.value = "AC"
				UIDropDownMenu_AddButton(info, level)
			elseif level == 2 and UIDROPDOWNMENU_MENU_VALUE then
				if UIDROPDOWNMENU_MENU_VALUE == "BEQ" then
					for k = 1, GetNumEquipmentSets() do
						local info = UIDropDownMenu_CreateInfo()
						info.text = GetEquipmentSetInfo(k)
						info.value = "BEQ_" .. k

						info.notCheckable = true
						info.hasArrow = false
						info.func = RightClickMenuOnClick

						UIDropDownMenu_AddButton(info, level);
					end
				elseif UIDROPDOWNMENU_MENU_VALUE == "AC" then
					local armorTypes = { GetAuctionItemSubClasses(2) }

					for k = 2, 5 do
						local info = UIDropDownMenu_CreateInfo()
						info.text = armorTypes[k]
						info.value = "AC_"..k

						info.notCheckable = true
						info.hasArrow = false
						info.func = RightClickMenuOnClick

						UIDropDownMenu_AddButton(info, level);
					end
				end
			end
		end
	end

	local function OnClick(self, button)
		if frame.current == nil then return end
		if button == "RightButton" then
			-- toggle LibPeriodicTable menu
			BGC.menuFrame.clickTarget = self
			ToggleDropDownMenu(nil, nil, BGC.menuFrame, self, -20, 0)
			return
		end

		local reset = nil	-- used to clean the items cache once we're done here
		local localList, globalList = Broker_Garbage:GetOption(frame.current)
		-- add action
		if self == plus then
			local cursorType, item, _ = GetCursorInfo()
			if not (cursorType == "item" and item) then return end
			reset = BGC.RemoteAddItemToList(item, frame.current)
		-- remove action
		elseif self == minus then
			local index, newReset = 1, nil
			while _G["BG_ListOptions_ScrollFrameItem"..index] do
				local button = _G["BG_ListOptions_ScrollFrameItem"..index]
				if button:IsVisible() and button:GetChecked() then
					local item = button.itemID or button.tiptext
					newReset = BGC.RemoteRemoveItemFromList(item, frame.current)
					reset = reset or newReset
				end
				index = index + 1
			end
		-- demote action
		elseif self == demote then
			local index = 1
			while _G["BG_ListOptions_ScrollFrameItem"..index] do
				local button = _G["BG_ListOptions_ScrollFrameItem"..index]
				if button:IsVisible() and button:GetChecked() then
					local item = button.itemID or button.tiptext
					BGC.RemoteDemoteItemInList(item, frame.current)
				end
				index = index + 1
			end
		-- promote action
		elseif self == promote then
			local index = 1
			while _G["BG_ListOptions_ScrollFrameItem"..index] do
				local button = _G["BG_ListOptions_ScrollFrameItem"..index]
				if button:IsVisible() and button:GetChecked() then
					local item = button.itemID or button.tiptext
					BGC.RemotePromoteItemInList(item, frame.current)
				end
				index = index + 1
			end
		-- setPrice action
		elseif self == setPrice then
			local index = 1
			while _G["BG_ListOptions_ScrollFrameItem"..index] do
				local button = _G["BG_ListOptions_ScrollFrameItem"..index]
				if button:IsVisible() and button:GetChecked() then
					StaticPopup_Show("BROKERGARBAGE_SETITEMPRICE")
					break
				end
				index = index + 1
			end
			return -- continued in savePriceSetting() called from popup
		-- empty action
		elseif self == emptyList then
			Broker_Garbage.ClearCache()
			if IsShiftKeyDown() then
				globalList = {}
			elseif localList then
				localList = {}
			end
			reset = true
		end

		-- post changed data
		Broker_Garbage:SetOption(frame.current, false, localList)
		Broker_Garbage:SetOption(frame.current, true, globalList)

		if reset then
			Broker_Garbage.UpdateAllDynamicItems()
		end
		Broker_Garbage:UpdateLDB()
		Broker_Garbage:UpdateMerchantButton()
		BGC:ListOptionsUpdate()
	end

	plus:SetScript("OnClick", OnClick)
	plus:SetScript("OnEnter", BGC.ShowTooltip)
	plus:SetScript("OnLeave", BGC.HideTooltip)
	minus:SetScript("OnClick", OnClick)
	minus:SetScript("OnEnter", BGC.ShowTooltip)
	minus:SetScript("OnLeave", BGC.HideTooltip)
	demote:SetScript("OnClick", OnClick)
	demote:SetScript("OnEnter", BGC.ShowTooltip)
	demote:SetScript("OnLeave", BGC.HideTooltip)
	promote:SetScript("OnClick", OnClick)
	promote:SetScript("OnEnter", BGC.ShowTooltip)
	promote:SetScript("OnLeave", BGC.HideTooltip)
	setPrice:SetScript("OnClick", OnClick)
	setPrice:SetScript("OnEnter", BGC.ShowTooltip)
	setPrice:SetScript("OnLeave", BGC.HideTooltip)
	emptyList:SetScript("OnClick", OnClick)
	emptyList:SetScript("OnEnter", BGC.ShowTooltip)
	emptyList:SetScript("OnLeave", BGC.HideTooltip)

	-- support for add-mechanism
	plus:RegisterForDrag("LeftButton")
	plus:SetScript("OnReceiveDrag", OnClick)
	-- plus:SetScript("OnMouseDown", OnClick)

	BGC:ListOptionsUpdate()
	listOptions:SetScript("OnShow", BGC.ListOptionsUpdate)
end

InterfaceOptions_AddCategory(listOptions)
