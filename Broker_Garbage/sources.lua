local _, BG = ...

-- auction addons
BG.auctionAddons = {}

-- TODO: checkbox to use highest price

function BG.AddPriceHandler(name, buyoutPriceHandler, disenchantPriceHandler, overwrite)
	assert(name and (buyoutPriceHandler or disenchantPriceHandler), 'AddPriceHandler requires a name and at least one price handler')
	assert(type(buyoutPriceHandler) == 'function' or type(disenchantPriceHandler) == 'function', 'Supplied handlers are no functions')
	assert(overwrite or not BG.auctionAddons[name], 'Auction handler with this name already exists')

	BG.auctionAddons[name] = {
		buyout = buyoutPriceHandler,
		disenchant = disenchantPriceHandler,

		buyoutEnabled = not BG_GlobalDB.buyoutDisabledSources[name],
		disenchantEnabled = not BG_GlobalDB.disenchantDisabledSources[name],
	}

	-- add us to the end of the list if not already present
	if not BG.Find(BG_GlobalDB.auctionAddonOrder.buyout, name) then
		table.insert(BG_GlobalDB.auctionAddonOrder.buyout, name)
	end
	if not BG.Find(BG_GlobalDB.auctionAddonOrder.disenchant, name) then
		table.insert(BG_GlobalDB.auctionAddonOrder.disenchant, name)
	end
end
function BG.EnablePriceHandler(name, buyout, disenchant)
	assert(name and BG.auctionAddons[name], 'Price handler with this name not found')
	if buyout ~= nil then
		BG.auctionAddons[name].buyoutEnabled = buyout
		BG_GlobalDB.buyoutDisabledSources[name] = not buyout and true or nil
	end
	if disenchant ~= nil then
		BG.auctionAddons[name].disenchantEnabled = disenchant
		BG_GlobalDB.disenchantDisabledSources[name] = not disenchant and true or nil
	end
end
function BG.ReOrderPriceHandler(name, displayType, index)
	-- implements moving things up (to move down, simply have the next index move up)
	local table = BG_GlobalDB.auctionAddonOrder[displayType]
	if index > 1 and index <= #table then
        local temp = table[index]
        table[index] = table[index-1]
        table[index-1] = temp
    end
end
function BG.GetPriceHandlerOrder(displayType)
	return BG_GlobalDB.auctionAddonOrder[displayType]
end
function BG.GetPriceHandler(name)
	if name and BG.auctionAddons[name] then
		return BG.auctionAddons[name]
	end
	for name, data in pairs(BG.auctionAddons) do
		return data
	end
end

-- ----------------------------------------------------
-- List of all supported auction price handlers
-- add your own by calling Broker_Garbage.AddPriceHandler(addonIdentifier, buyoutHandler, disenchantHandler)
-- ----------------------------------------------------
function BG.InitPriceHandlers()
	BG.AddPriceHandler('Auctionator', function(itemLink)
		if IsAddOnLoaded('Auctionator') then
			return Atr_GetAuctionBuyout(itemLink)
		end
	end, function(itemLink)
		if IsAddOnLoaded('Auctionator') then
			return Atr_GetDisenchantValue(itemLink)
		end
	end)

	BG.AddPriceHandler('Auc-Advanced', function(itemLink)
		if IsAddOnLoaded('Auc-Advanced') then
			return AucAdvanced.API.GetMarketValue
		end
	end, function(itemLink)
		if IsAddOnLoaded('Enchantrix') then
			local disenchantPrice = select(3, Enchantrix.Storage.GetItemDisenchantTotals(itemLink))
			return disenchantPrice
		end
	end)

	BG.AddPriceHandler('AuctionLite', function(itemLink)
		if IsAddOnLoaded('AuctionLite') then
			return AuctionLite:GetAuctionValue(itemLink)
		end
	end, function(itemLink)
		if IsAddOnLoaded('AuctionLite') then
			return AuctionLite:GetDisenchantValue(itemLink)
		end
	end)

	BG.AddPriceHandler('AuctionMaster', function(itemLink)
		if IsAddOnLoaded('AuctionMaster') then
			return AucMasGetCurrentAuctionInfo(itemLink)
		end
	end, function(itemLink)
		if IsAddOnLoaded('AuctionMaster') then
			return AuctionMaster.Disenchant:GetDisenchantValue(itemLink)
		end
	end)

	BG.AddPriceHandler('WOWEcon_PriceMod', function(itemLink)
		if IsAddOnLoaded('WOWEcon_PriceMod') then
			return Wowecon.API.GetAuctionPrice_ByLink
		end
	end, function(itemLink)
		if IsAddOnLoaded('WOWEcon_PriceMod') then
			local tmpPrice = 0
			local DEData = Wowecon.API.GetDisenchant_ByLink(itemLink)
			local link, quantity, chance
			for i, data in pairs(DEData) do
				link, quantity, chance = unpack(data)
				tmpPrice = tmpPrice + ((Wowecon.API.GetAuctionPrice_ByLink(link or '')) * quantity * chance)
			end
			return floor(tmpPrice or 0)
		end
	end)

	BG.AddPriceHandler('Auctional', function(itemLink)
		if IsAddOnLoaded('Auctional') then
			return Auctional:GetAuctionValue(itemLink)
		end
	end, function(itemLink)
		if IsAddOnLoaded('Auctional') then
			return Auctional:GetDisenchantValue(itemLink)
		end
	end)

	BG.AddPriceHandler('Default', GetAuctionBuyout, GetDisenchantValue)
end
