local _, BG = ...

-- auction addons
BG.auctionAddons = {}

-- TODO: checkbox to use highest price

function BG.AddPriceHandler(name, buyoutPriceHandler, disenchantPriceHandler, overwrite)
	if name ~= 'Default' then
		if not (buyoutPriceHandler or disenchantPriceHandler) then
			error('Name and at least one handler are required for registration')
		elseif type(buyoutPriceHandler) ~= 'function' and type(disenchantPriceHandler) ~= 'function' then
			error('Supplied handlers are no functions')
		end
	end
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
	assert(name and BG.auctionAddons[name], 'No price handler with this name was found')
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
function BG.GetPriceHandler(name, noFallback)
	if name and BG.auctionAddons[name] then
		return BG.auctionAddons[name]
	end
	if noFallback then return end
	for name, data in pairs(BG.auctionAddons) do
		return data
	end
end

-- ----------------------------------------------------
-- List of all supported auction price handlers
-- add your own by calling Broker_Garbage.AddPriceHandler(addonIdentifier, buyoutHandler, disenchantHandler)
-- ----------------------------------------------------
function BG.InitPriceHandlers()
	local disenchantHandler

	BG.AddPriceHandler('Default', GetAuctionBuyout, GetDisenchantValue)

	if IsAddOnLoaded('Auctionator') then
		BG.AddPriceHandler('Auctionator', Atr_GetAuctionBuyout, Atr_GetDisenchantValue)
	end

	if IsAddOnLoaded('Auc-Advanced') then
		if IsAddOnLoaded('Enchantrix') then
			disenchantHandler = function(itemLink)
				local disenchantPrice = select(3, Enchantrix.Storage.GetItemDisenchantTotals(itemLink))
				return disenchantPrice
			end
		end
		BG.AddPriceHandler('Auc-Advanced', AucAdvanced.API.GetMarketValue, disenchantHandler)
	end

	if IsAddOnLoaded('AuctionLite') then
		BG.AddPriceHandler('AuctionLite', function(itemLink)
			return AuctionLite:GetAuctionValue(itemLink)
		end, function(itemLink)
			return AuctionLite:GetDisenchantValue(itemLink)
		end)
	end

	if IsAddOnLoaded('AuctionMaster') then
		-- some addon authors haven't heard of compatible namespacing :(
		local AuctionMaster = vendor
		disenchantHandler = function(itemLink)
			return AuctionMaster.Disenchant:GetDisenchantValue(itemLink)
		end
		BG.AddPriceHandler('AuctionMaster', AucMasGetCurrentAuctionInfo, disenchantHandler)
	end

	if IsAddOnLoaded('WOWEcon_PriceMod') then
		disenchantHandler = function(itemLink)
			local tmpPrice = 0
			local DEData = Wowecon.API.GetDisenchant_ByLink(itemLink)
			local link, quantity, chance
			for i, data in pairs(DEData) do
				link, quantity, chance = unpack(data)
				tmpPrice = tmpPrice + ((Wowecon.API.GetAuctionPrice_ByLink(link or '')) * quantity * chance)
			end
			return floor(tmpPrice or 0)
		end
		BG.AddPriceHandler('WOWEcon_PriceMod', Wowecon.API.GetAuctionPrice_ByLink, disenchantHandler)
	end

	if IsAddOnLoaded('Auctional') then
		BG.AddPriceHandler('Auctional', function(itemLink)
			return Auctional:GetAuctionBuyout(itemLink)
		end, function(itemLink)
			return Auctional:GetDisenchantValue(itemLink)
		end)
	end

	-- remove stray entries so we can reorder without troubles
	local addons, addonKey = BG_GlobalDB.auctionAddonOrder.buyout
	for i = #(addons), 1, -1 do
		addonKey = addons[i]
		if not BG.auctionAddons[addonKey] then
			table.remove(addons, i)
		end
	end
	addons, addonKey = BG_GlobalDB.auctionAddonOrder.disenchant
	for i = #(addons), 1, -1 do
		addonKey = addons[i]
		if not BG.auctionAddons[addonKey] then
			table.remove(addons, i)
		end
	end
end
