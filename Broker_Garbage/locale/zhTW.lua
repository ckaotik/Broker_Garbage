-- chinese localization file by a9012456 on Curse.com
local _, BG = ...

if GetLocale() == "zhTW" then
	BG.locale.label = "垃圾，沒有了！"

	-- Chat Messages
	BG.locale.addedTo_exclude = "%s已經新增到保留列表。"
	BG.locale.addedTo_forceVendorPrice = "%s只會考慮它自己的商店價錢。"

	BG.locale.reportNothingToSell = "沒有東西來賣！"
	BG.locale.reportCannotSell = "這商人不買物品"
	BG.locale.sellItem = "%3$s 賣出 %1$sx%2$d。"
	BG.locale.sell = "賣出垃圾：%s。"
	BG.locale.sellAndRepair = "賣出垃圾：%1$s，修理：%2$s%3$s。改變：%4$s。"
	BG.locale.repair = "修理：%1$s%2$s。"
	-- BG.locale.guildRepair = " (guild)"
	BG.locale.couldNotRepair = "無法修理，因為你沒有足夠的錢。你需要%s。"
	BG.locale.itemDeleted = "%1$sx%2$d 已經被刪除。"
	BG.locale.listsUpdatedPleaseCheck = "你的列表已更新。請看看你的設定並且檢查是否符合你的需要。"
	BG.locale.disenchantOutdated = "%1$s 已經淘汰並且應該分解。"
	-- BG.locale.couldNotMoveItem = "Error! Item to move does not match requested item."

	-- Tooltip
	-- headerAltClick = "Alt-Click: Use Vendor Price"
	BG.locale.headerRightClick = "右鍵-點擊：設定" -- unused
	BG.locale.headerShiftClick = "SHIFT-點擊：摧毀"
	BG.locale.headerCtrlClick = "CTRL-點擊：保留"
	BG.locale.moneyLost = "金錢失去："
	BG.locale.moneyEarned = "金錢賺得："
	BG.locale.noItems = "沒有物品刪除。"
	BG.locale.increaseTreshold = "提升品質門檻"
	BG.locale.openPlease = "未開啟的箱子在你的背包"

	-- Sell button tooltip
	BG.locale.autoSellTooltip = "賣出物品：%s"

	-- List names
	-- BG.locale.listExclude= "Keep"
	-- BG.locale.listInclude = "Include"
	-- BG.locale.listVendor = "Vendor"
	-- BG.locale.listSell = "Auto sell"
	-- BG.locale.listCustom = "Custom price"
	-- BG.locale.listAuction = "Auction"
	-- BG.locale.listDisenchant = "Disenchant"
	-- BG.locale.listUnusable = "Unusable Gear"
	-- BG.locale.listOutdated = "Outdated"
end
