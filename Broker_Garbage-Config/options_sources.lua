local _, BGC = ...

-- declare so it's usable ...
local UpdateAuctionAddonList = function() end

local function EnableDisable(self, button)
	local name = self:GetParent().addonName:GetText()
	if self:GetParent().displayType == 'buyout' then
		Broker_Garbage.EnablePriceHandler(name, self:GetChecked() and true or false)
	else
		Broker_Garbage.EnablePriceHandler(name, nil, self:GetChecked() and true or false)
	end
end

local function ChangeOrder(self, button)
	local index = self:GetParent():GetID()
	local displayType = self:GetParent().displayType
	local name = self:GetParent().addonName:GetText()

	Broker_Garbage.ReOrderPriceHandler(name, displayType, index + (self.direction == 1 and 0 or 1))
	UpdateAuctionAddonList()
end

local frames = { buyout = {}, disenchant = {} }
local displayTypes = { 'buyout', 'disenchant' }
UpdateAuctionAddonList = function(panel)
	local auctionAddonOrder, auctionAddon, addonLine, bgTex
	for _, displayType in ipairs(displayTypes) do
		local numShown = 0
		auctionAddonOrder = Broker_Garbage.GetPriceHandlerOrder(displayType)
		for i, addonKey in ipairs(auctionAddonOrder) do
			auctionAddon = Broker_Garbage.GetPriceHandler(addonKey, true)
			if auctionAddon and auctionAddon[displayType] then
				addonLine = frames[displayType][i]
				if not addonLine then
					addonLine = CreateFrame('Frame', nil, panel)
					addonLine:SetSize(260, 16)
					addonLine:SetID(i)
					addonLine.displayType = displayType
					frames[displayType][i] = addonLine

					if i == 1 then
						addonLine:SetPoint('TOPLEFT', 16 + (displayType == 'buyout' and 0 or 260 + 40), -86)
					else
						addonLine:SetPoint('TOPLEFT', frames[displayType][i-1], 'BOTTOMLEFT', 0, 0)
					end
					if i%2 ~= 0 then
						bgTex = addonLine:CreateTexture(nil, 'BACKGROUND')
						bgTex:SetTexture(1, 1, 1, 0.1)
						bgTex:SetHorizTile(true)
						bgTex:SetVertTile(true)
						bgTex:SetAllPoints()
					end

					addonLine.enabled, addonLine.addonName = LibStub("tekKonfig-Checkbox").new(addonLine, 20, '', 'LEFT', -1, 0)
					addonLine.addonName:SetFontObject('GameFontNormalSmall')
					addonLine.enabled.tiptext = BGC.locale.AuctionAddonsEnableTT
					addonLine.enabled:SetScript('OnClick', EnableDisable)

					addonLine.moveUp = CreateFrame('Button', '$parentUpButton', addonLine)
					addonLine.moveUp.direction = 1
					addonLine.moveUp:SetScript('OnClick', ChangeOrder)
					addonLine.moveUp:SetPoint('TOPLEFT', 224, 2)
					addonLine.moveUp:SetSize(20, 20)
					addonLine.moveUp:SetNormalTexture('Interface\\ChatFrame\\UI-ChatIcon-ScrollUp-Up')
					addonLine.moveUp:SetPushedTexture('Interface\\ChatFrame\\UI-ChatIcon-ScrollUp-Down')
					addonLine.moveUp:SetDisabledTexture('Interface\\ChatFrame\\UI-ChatIcon-ScrollUp-Disabled')
					addonLine.moveUp:SetHighlightTexture('Interface\\PaperDollInfoFrame\\UI-Character-Tab-Highlight', 'ADD')

					addonLine.moveDown = CreateFrame('Button', '$parentDownButton', addonLine)
					addonLine.moveDown.direction = -1
					addonLine.moveDown:SetScript('OnClick', ChangeOrder)
					addonLine.moveDown:SetPoint('TOPLEFT', 224+18, 2)
					addonLine.moveDown:SetSize(20, 20)
					addonLine.moveDown:SetNormalTexture('Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Up')
					addonLine.moveDown:SetPushedTexture('Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Down')
					addonLine.moveDown:SetDisabledTexture('Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Disabled')
					addonLine.moveDown:SetHighlightTexture('Interface\\PaperDollInfoFrame\\UI-Character-Tab-Highlight', 'ADD')
				end
				addonLine.enabled:SetChecked(auctionAddon[displayType .. 'Enabled'])
				addonLine.addonName:SetText(addonKey)
				addonLine.moveDown:Show()
				if i == 1 then addonLine.moveUp:Hide()
				else addonLine.moveUp:Show() end


				numShown = numShown + 1
				addonLine:Show()
			end
		end
		if numShown > 0 then frames[displayType][numShown].moveDown:Hide() end
		for i = numShown + 1, #frames[displayType] do
			frames[i]:Hide()
		end
	end
end

local function AuctionAddons(pluginID)
	local panel, tab = BGC:CreateOptionsTab(pluginID)

	local explainText = panel:CreateFontString(nil, 'ARTWORK', 'GameFontHighlightSmall')
	explainText:SetPoint('TOPLEFT', 16, -16)
	explainText:SetPoint('RIGHT', panel, -16, 0)
	explainText:SetHeight(40)
	explainText:SetNonSpaceWrap(true)
	explainText:SetJustifyH('LEFT')
	explainText:SetJustifyV('TOP')
	explainText:SetText(BGC.locale.AuctionAddonsExplanation)

	local buyoutHeading = panel:CreateFontString(nil, 'ARTWORK', 'GameFontNormalSmall')
	buyoutHeading:SetPoint('TOP', explainText, 'BOTTOMLEFT', 0.5*260, -10)
	buyoutHeading:SetText(BGC.locale.AuctionAddonsBuyout)

	local disenchantHeading = panel:CreateFontString(nil, 'ARTWORK', 'GameFontNormalSmall')
	disenchantHeading:SetPoint('TOP', explainText, 'BOTTOMLEFT', (1.5*260)+40, -10)
	disenchantHeading:SetText(BGC.locale.AuctionAddonsDisenchant)

	function panel:Update()
		UpdateAuctionAddonList(panel)
	end
end
local _ = Broker_Garbage:RegisterPlugin(BGC.locale.AuctionAddonsHeading, AuctionAddons)
