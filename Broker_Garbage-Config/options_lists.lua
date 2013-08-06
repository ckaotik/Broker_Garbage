local _, BGC = ...

-- GLOBALS: Broker_Garbage, LibStub, _G, UIDROPDOWNMENU_MENU_VALUE, UIParent, StaticPopupDialogs, BG_GlobalDB, ITEM_QUALITY_COLORS, SEARCH, UNKNOWN, ARMOR
-- GLOBALS: IsShiftKeyDown, GetCursorInfo, StaticPopup_Show, ToggleDropDownMenu, UIDropDownMenu_AddButton, UIDropDownMenu_CreateInfo, GetAuctionItemSubClasses, GetEquipmentSetInfo, GetNumEquipmentSets, GetItemInfo, CreateFrame, MoneyInputFrame_GetCopper, IsModifiedClick, IsModifierKeyDown, HandleModifiedItemClick, PlaySound, InterfaceOptionsFramePanelContainer, SetItemButtonCount, SetItemButtonStock, SetItemButtonTexture, SetItemButtonNormalTextureVertexColor, EditBox_ClearFocus, InterfaceOptionsFrame_Show, FauxScrollFrame_Update, FauxScrollFrame_GetOffset, FauxScrollFrame_OnVerticalScroll
-- GLOBALS: type, wipe, ipairs, tonumber, select, pairs, unpack, table
local AceTimer = LibStub("AceTimer-3.0")

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

-- ========================================================
--  Actual UI
-- ========================================================
local entries = {}
local function SimpleSort(a, b)
	-- TODO: sort when headers are clicked
	if type(a) ~= type(b) then
		return type(a) == "string"
	else
		return a < b
	end
end
local function GetEntryTitle(text)
	if not text then return UNKNOWN end

	local specialType, identifier = text:match("^(.-)_(.+)")
	if not specialType then
		-- LibPeriodicTable category or item name
		return text:gsub("%.", " |cffffd200>|r ")
	elseif specialType == "AC" then
		-- armor class
		return ARMOR..": "..identifier
	elseif specialType == "BEQ" then
		-- Blizzard Equipment Manager item set
		identifier = GetEquipmentSetInfo( tonumber(identifier) )
		return BGC.locale.equipmentManager..": "..identifier
	elseif specialType == "NAME" then
		-- Item Name Filter
		return BGC.locale.anythingCalled..": "..identifier
	end
end
local function ListUpdate(self)
	local data = Broker_Garbage[self.list]
	local frame = self:GetParent()

	wipe(entries)
	for item, value in pairs(data) do
		local isMatch = false
		if not frame.searchString then
			isMatch = true
		elseif type(item) == "number" then
			local itemName = GetItemInfo(item)
			isMatch = itemName:lower():find( frame.searchString )
		else
			isMatch = item:lower():find( frame.searchString )
		end
		if isMatch then
			table.insert(entries, item)
		end
	end
	table.sort(entries, SimpleSort)

	local offset = FauxScrollFrame_GetOffset(self)
	local needsScrollBar = FauxScrollFrame_Update(self, #entries, #self.buttons, self.buttons[1]:GetHeight(), nil, nil, nil, nil, nil, nil, true)

	local updateTimer
	for i = 1, #self.buttons do
		local index = i + offset
		local button = self.buttons[i]

		local item = entries[index]
		if item then
			local name, link, quality, texture
			if type(item) == "number" then
				name, link, quality, _, _, _, _, _, _, texture = GetItemInfo(item)
				button.link = link
				button.item = item
			else
				name = item
				texture = "Interface\\Icons\\Trade_engineering"
				quality = 1
				button.link = nil
				button.item = item
			end

			-- call again if we're missing data
			if not name then
				updateTimer = updateTimer or AceTimer:ScheduleTimer(ListUpdate, 0.1, self)
			end

			if self.list == "keep" then
				-- FIXME: won't display? o.0
				button.info:SetText( data[item] )
			else
				button.info:SetChecked( data[item] == 1 )
			end
			SetItemButtonTexture(button, texture or "")
			if quality and quality ~= 1 then
				button.name:SetTextColor(
					ITEM_QUALITY_COLORS[quality].r,
					ITEM_QUALITY_COLORS[quality].g,
					ITEM_QUALITY_COLORS[quality].b,
					1
				)
			else
				button.name:SetTextColor(1, 1, 1, 1)
			end
			button.name:SetText( GetEntryTitle(name) )
			button:SetChecked( Broker_Garbage.IsShared(self.list, item) )
			button:Show()
		else
			button:Hide()
		end
	end
end

local function Tooltip(self, tooltip)
	if not self.item then return end
	local item = self.item

	local specialType, identifier = item:match("^(.-)_(.+)")
	if not specialType then
		-- LibPeriodicTable category
		local text = item:gsub("%.", " |cffffd200>|r ")
		tooltip:AddLine("LibPeriodicTable")
		tooltip:AddLine(text, 1, 1, 1, true)
	elseif specialType == "AC" then
		-- armor class
		tooltip:AddLine(BGC.locale.armorClass)
		tooltip:AddLine(identifier or UNKNOWN, 1, 1, 1, true)
	elseif specialType == "BEQ" then
		-- Blizzard Equipment Manager item set
		tooltip:AddLine(BGC.locale.equipmentManager)
		identifier = GetEquipmentSetInfo( tonumber(identifier) )
		tooltip:AddLine(identifier or UNKNOWN, 1, 1, 1, true)
	elseif specialType == "NAME" then
		-- Item Name Filter
		tooltip:AddLine(BGC.locale.anythingCalled)
		tooltip:AddLine(identifier or UNKNOWN, 1, 1, 1, true)
	end
end

local function ItemButtonOnClick(self, btn)
	local list = self:GetParent().list
	if btn == "RightButton" then
		self:SetChecked( not self:GetChecked() )
		Broker_Garbage.Remove(list, self.item)
		Broker_Garbage.PrintFormat(
			BGC.locale["removedFrom_"..(list == "keep" and "exclude" or list == "toss" and "include" or "forceVendorPrice")],
			self.item)
	elseif IsModifiedClick() then
		self:SetChecked( not self:GetChecked() )
		HandleModifiedItemClick(self.link)
	else
		Broker_Garbage.ToggleShared(list, self.item)
	end
end

-- creates child options frame for setting up one's lists
local function ShowListOptions(frame)
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

	--[=[ local help = CreateFrame("SimpleHTML", nil, frame)
	help:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -60)
	help:SetSize(200, 200)
	help:SetFontObject("GameFontNormal")
	help:SetText([[<html><body>
<h1>|TInterface\MINIMAP\TRACKING\Auctioneer:0|t SimpleHTML Demo: Ambush</h1>
<img src="Interface\Icons\Ability_Ambush" width="32" height="32" align="right"/>
<p align="center">|cffee4400'You think this hurts? Just wait.'|r</p>
<p>Among every ability a rogue has at his disposal, Ambush is without a doubt the hardest hitting Rogue ability.</p>
</body></html>]]) --]=]

	local info = {
		keep = {"Treasures", "Limit"},
		toss = {"Junk", "Sell"},
	}
	local backdrop = {
		bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		tile = true,
		tileSize = 16,
		edgeSize = 16,
		insets = { left = 5, right = 5, top = 5, bottom = 5 }
	}

	for i, listName in ipairs({"keep", "toss"}) do
		local list = CreateFrame("ScrollFrame", "$parentList"..i, frame, "FauxScrollFrameTemplate")
		list:SetSize(300, 200)
		list:SetBackdrop(backdrop)
		list:SetBackdropBorderColor(0.4, 0.4, 0.4)
		list:SetBackdropColor(0.1, 0.1, 0.1, 0.3)

		if i == 1 then
			list:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -240)
		else
			list:SetPoint("TOPLEFT", "$parentList"..(i-1), "TOPRIGHT", 0, 0)
		end

		list.scrollBarHideable = false
		list.list = listName
		list.buttons = {}

		list.ScrollBar:SetPoint("TOPLEFT", "$parent", "TOPRIGHT", -20, -20)
		list.ScrollBar:SetPoint("BOTTOMLEFT", "$parent", "BOTTOMRIGHT", -20, 20)

		-- headers
		local sorter1 = CreateFrame("Button", "$parentSorterShared", list, "AuctionSortButtonTemplate")
			  sorter1:SetText("|TInterface\\FriendsFrame\\PlusManz-PlusManz:24:24:-4:-1|t")
			  sorter1:SetSize(30, 19)
			  sorter1:SetPoint("BOTTOMLEFT", list, "TOPLEFT", 6, -2)
			  sorter1:SetScript("OnClick", SimpleSort)
			  _G[sorter1:GetName().."Arrow"]:Hide()
		local sorter2 = CreateFrame("Button", "$parentSorterInfo", list, "AuctionSortButtonTemplate")
			  sorter2:SetText( info[listName][2] )
			  sorter2:SetSize(40, 19)
			  sorter2:SetPoint("BOTTOMRIGHT", list, "TOPRIGHT", -20, -2)
			  sorter2:SetScript("OnClick", SimpleSort)
			  _G[sorter2:GetName().."Arrow"]:Hide()
		local sorter3 = CreateFrame("Button", "$parentSorterName", list, "AuctionSortButtonTemplate")
			  sorter3:SetText( info[listName][1] )
			  sorter3:SetHeight(19)
			  sorter3:SetPoint("BOTTOMLEFT", sorter1, "BOTTOMRIGHT", -2, 0)
			  sorter3:SetPoint("BOTTOMRIGHT", sorter2, "BOTTOMLEFT", 2, 0)
			  sorter3:SetScript("OnClick", SimpleSort)
			  _G[sorter3:GetName().."Arrow"]:Hide()

		-- entries
		for j = 1, 7 do
			local item = CreateFrame("CheckButton", "$parentButton"..j, list, "ItemButtonTemplate", j)
				  item:SetCheckedTexture("Interface\\Buttons\\UI-Button-Outline")
				  item:SetScript("OnEnter", BGC.ShowTooltip)
				  item:SetScript("OnLeave", BGC.HideTooltip)
				  item:SetScript("OnClick", ItemButtonOnClick)
				  item.tiptext = Tooltip

				  item:SetSize(26, 26)
				  _G[item:GetName().."NormalTexture"]:SetSize(45, 45)
				  item:GetCheckedTexture():SetTexCoord(0.2, 0.8, 0.2, 0.8)
			local name = item:CreateFontString(nil, nil, "GameFontNormal")
				  name:SetPoint("LEFT", item, "RIGHT", 6, 0)
				  name:SetWidth(210)
				  name:SetJustifyH("LEFT")
				  name:SetWordWrap(true)
			item.name = name

			if i == 1 then
				local info = CreateFrame("EditBox", nil, item, "InputBoxTemplate")
					  info:SetPoint("LEFT", name, "RIGHT", 2, 0)
					  info:SetSize(26, 20)
					  info:SetAutoFocus(false)
				item.info = info
			else
				local info = CreateFrame("CheckButton", nil, item, "UICheckButtonTemplate")
					  info:SetPoint("LEFT", name, "RIGHT", 4, 0)
					  info:SetSize(20, 20)
					  -- info:SetScript("OnClick", ClickFunc)
				item.info = info
			end

			if j == 1 then
				item:SetPoint("TOPLEFT", list, "TOPLEFT", 6, -6)
			else
				item:SetPoint("TOPLEFT", list.buttons[j-1], "BOTTOMLEFT", 0, -1)
			end
			item:Hide()

			table.insert(list.buttons, item)
		end

		frame[listName.."List"] = list
		list:SetScript("OnVerticalScroll", function(self, offset)
			FauxScrollFrame_OnVerticalScroll(self, offset, self.buttons[1]:GetHeight(), ListUpdate)
		end)
		ListUpdate(list)
	end

	-- action buttons
	local plus = CreateFrame("Button", "$parentAddEntryButton", frame)
	plus:SetPoint("TOPLEFT", frame.keepList, "BOTTOMLEFT", 4, -2)
	plus:SetSize(25, 25)
	plus:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square")
	plus:SetNormalTexture("Interface\\Icons\\Spell_chargepositive")
	plus.tiptext = BGC.locale.LOPlus
	plus:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	local minus = CreateFrame("Button", "$parentRemoveEntryButton", frame)
	minus:SetPoint("LEFT", plus, "RIGHT", 4, 0)
	minus:SetSize(25, 25)
	minus:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square")
	minus:SetNormalTexture("Interface\\Icons\\Spell_chargenegative")
	minus.tiptext = BGC.locale.LOMinus

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
		BGC.ListOptionsUpdate(frame)
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
		OnAlt = function(self) savePriceSetting(-1) end,
		OnShow = function(self) --[[MoneyFrame_Update(self.moneyFrame, currentPrice)--]] end,
		EditBoxOnEscapePressed = function(self) self:GetParent():GetParent().button2:Click() end,
		EditBoxOnEnterPressed = function(self) self:GetParent():GetParent().button1:Click() end,
		timeout = 0,
		whileDead = true,
		enterClicksFirstButton = true,
		hideOnEscape = true,
		preferredIndex = 3,
	}

	local searchbox = CreateFrame("EditBox", "$parentSearchBox", frame, "SearchBoxTemplate")
	searchbox:SetPoint("TOPRIGHT", frame.keepList, "BOTTOMRIGHT", -4, 2)
	searchbox:SetSize(160, 32)
	searchbox:SetScript("OnEnterPressed", EditBox_ClearFocus)
	searchbox:SetScript("OnEscapePressed", function(self)
		PlaySound("igMainMenuOptionCheckBoxOn")
		self:SetText(SEARCH)
		EditBox_ClearFocus(self)
		self:clearFunc()
	end)
	searchbox:SetScript("OnTextChanged", function(self)
		local text = self:GetText()
		local oldText = frame.searchString
		frame.searchString = (text ~= "" and text ~= SEARCH) and text:lower() or nil
		if oldText ~= frame.searchString then
			BGC.ListOptionsUpdate(frame)
		end
	end)
	searchbox.clearFunc = function(self)
		BGC.ListOptionsUpdate(frame)
	end

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
		-- setPrice action
		elseif false then
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
		end

		Broker_Garbage:UpdateLDB()
		Broker_Garbage:UpdateMerchantButton()
		BGC:ListOptionsUpdate()
	end

	plus:SetScript("OnClick", OnClick)
	plus:SetScript("OnEnter", BGC.ShowTooltip)
	plus:SetScript("OnLeave", BGC.HideTooltip)
	plus:RegisterForDrag("LeftButton")
	plus:SetScript("OnReceiveDrag", OnClick)
	minus:SetScript("OnClick", OnClick)
	minus:SetScript("OnEnter", BGC.ShowTooltip)
	minus:SetScript("OnLeave", BGC.HideTooltip)

	local function ListOptionsUpdate(self)
		ListUpdate(self.keepList)
		ListUpdate(self.tossList)
		--[[if frame.current == "forceVendorPrice" then
				SetItemButtonCount(button, 0)
				if globalList[itemID] >= 0 then
					_G[button:GetName().."Stock"]:SetText('*')
					_G[button:GetName().."Stock"]:Show()
					button.extraTipLine = Broker_Garbage.FormatMoney(globalList[itemID])
				else
					SetItemButtonStock(button, 0)
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
		--]]
	end
	BGC.ListOptionsUpdate = ListOptionsUpdate

	ListOptionsUpdate(frame)
	listOptions:SetScript("OnShow", ListOptionsUpdate)
end

listOptions:SetScript("OnShow", ShowListOptions)
InterfaceOptions_AddCategory(listOptions)
