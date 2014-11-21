local addonName, addon, _ = ...

-- GLOBALS: _G, Wowecon, Auctional, AuctionLite, Enchantrix, AucAdvanced, GetAuctionBuyout, GetDisenchantValue
-- GLOBALS: IsAddOnLoaded, Atr_GetAuctionBuyout, Atr_GetDisenchantValue, AucMasGetCurrentAuctionInfo
-- GLOBALS: error, type, assert, table, floor pairs, unpack, select, tContains

-- auction addons
addon.auctionAddons = {}

-- TODO: checkbox to use highest price

function addon.AddPriceHandler(name, buyoutPriceHandler, disenchantPriceHandler, overwrite)
	if name ~= 'Default' then
		if not (buyoutPriceHandler or disenchantPriceHandler) then
			error('Name and at least one handler are required for registration')
		elseif type(buyoutPriceHandler) ~= 'function' and type(disenchantPriceHandler) ~= 'function' then
			error('Supplied handlers are no functions')
		end
	end
	assert(overwrite or not addon.auctionAddons[name], 'Auction handler with this name already exists')

	addon.auctionAddons[name] = {
		buyout = buyoutPriceHandler,
		disenchant = disenchantPriceHandler,

		buyoutEnabled = not addon.db.global.dataSources.buyoutDisabled[name],
		disenchantEnabled = not addon.db.global.dataSources.disenchantDisabled[name],
	}

	-- add us to the end of the list if not already present
	if not tContains(addon.db.global.dataSources.buyout, name) then
		table.insert(addon.db.global.dataSources.buyout, name)
	end
	if not tContains(addon.db.global.dataSources.disenchant, name) then
		table.insert(addon.db.global.dataSources.disenchant, name)
	end
end
function addon.EnablePriceHandler(name, buyout, disenchant)
	assert(name and addon.auctionAddons[name], 'No price handler with this name was found')
	if buyout ~= nil then
		addon.auctionAddons[name].buyoutEnabled = buyout
		addon.db.global.dataSources.buyoutDisabled[name] = not buyout and true or nil
	end
	if disenchant ~= nil then
		addon.auctionAddons[name].disenchantEnabled = disenchant
		addon.db.global.dataSources.disenchantDisabled[name] = not disenchant and true or nil
	end
end
function addon.ReOrderPriceHandler(name, displayType, index)
	-- implements moving things up (to move down, simply have the next index move up)
	local table = addon.db.global.dataSources[displayType]
	if index > 1 and index <= #table then
        local temp = table[index]
        table[index] = table[index-1]
        table[index-1] = temp
    end
end
function addon.GetPriceHandlerOrder(displayType)
	return addon.db.global.dataSources[displayType]
end
function addon.GetPriceHandler(name, noFallback)
	if name and addon.auctionAddons[name] then
		return addon.auctionAddons[name]
	end
	if noFallback then return end
	for name, data in pairs(addon.auctionAddons) do
		return data
	end
end

-- ----------------------------------------------------
-- List of all supported auction price handlers
-- add your own by calling Broker_Garbage.AddPriceHandler(addonIdentifier, buyoutHandler, disenchantHandler)
-- ----------------------------------------------------
function addon.InitPriceHandlers()
	local disenchantHandler

	addon.AddPriceHandler('Default', GetAuctionBuyout, GetDisenchantValue)

	if IsAddOnLoaded('Auctionator') then
		addon.AddPriceHandler('Auctionator', Atr_GetAuctionBuyout, Atr_GetDisenchantValue)
	end

	if IsAddOnLoaded('Auc-Advanced') then
		if IsAddOnLoaded('Enchantrix') then
			disenchantHandler = function(itemLink)
				local disenchantPrice = select(3, Enchantrix.Storage.GetItemDisenchantTotals(itemLink))
				return disenchantPrice
			end
		end
		addon.AddPriceHandler('Auc-Advanced', AucAdvanced.API.GetMarketValue, disenchantHandler)
	end

	if IsAddOnLoaded('AuctionLite') then
		addon.AddPriceHandler('AuctionLite', function(itemLink)
			return AuctionLite:GetAuctionValue(itemLink)
		end, function(itemLink)
			return AuctionLite:GetDisenchantValue(itemLink)
		end)
	end

	if IsAddOnLoaded('AuctionMaster') then
		-- some addon authors haven't heard of compatible namespacing :(
		local AuctionMaster = _G.vendor
		disenchantHandler = function(itemLink)
			return AuctionMaster.Disenchant:GetDisenchantValue(itemLink)
		end
		addon.AddPriceHandler('AuctionMaster', AucMasGetCurrentAuctionInfo, disenchantHandler)
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
		addon.AddPriceHandler('WOWEcon_PriceMod', Wowecon.API.GetAuctionPrice_ByLink, disenchantHandler)
	end

	if IsAddOnLoaded('Auctional') then
		addon.AddPriceHandler('Auctional', function(itemLink)
			return Auctional:GetAuctionBuyout(itemLink)
		end, function(itemLink)
			return Auctional:GetDisenchantValue(itemLink)
		end)
	end

	-- remove stray entries so we can reorder without troubles
	local addons, addonKey = addon.db.global.dataSources.buyout
	for i = #(addons), 1, -1 do
		addonKey = addons[i]
		if not addon.auctionAddons[addonKey] then
			table.remove(addons, i)
		end
	end
	addons, addonKey = addon.db.global.dataSources.disenchant
	for i = #(addons), 1, -1 do
		addonKey = addons[i]
		if not addon.auctionAddons[addonKey] then
			table.remove(addons, i)
		end
	end
end
