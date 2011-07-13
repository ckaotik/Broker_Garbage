-- chinese localisation file
local _, BG = ...

if GetLocale() == "zhTW" then
	BG.locale.label = "垃圾，去吧！"
	
	-- Chat Messages
	BG.locale.addedTo_exclude = "%s已經被新增到儲存名單。"
	BG.locale.addedTo_forceVendorPrice = "%s只會有它自己的商店價錢考慮。"

	BG.locale.reportNothingToSell = "沒有東西可以賣！"
	-- BG.locale.reportCannotSell = ""
	-- BG.locale.sellItem = ""
	BG.locale.sell = "賣出垃圾：%s。"
	BG.locale.sellAndRepair = "賣出垃圾：%1$s，修理：%2$s。改變：%3$s。"
	BG.locale.repair = "修理：%s。"
	-- BG.locale.couldNotRepair = ""
	BG.locale.itemDeleted = "%1$sx%2$d 已經被刪除。"
	-- BG.locale.listsUpdatedPleaseCheck = ""
	-- BG.locale.disenchantOutdated = ""
	
	-- Tooltip
	BG.locale.headerRightClick = "右鍵點擊設定"
	BG.locale.headerShiftClick = "SHIFT-點擊：摧毀"
	BG.locale.headerCtrlClick = "CTRL-點擊：保留"
	BG.locale.moneyLost = "金錢失去："
	BG.locale.moneyEarned = "金錢賺得："
	BG.locale.noItems = "沒有物品刪除。"
	BG.locale.increaseTreshold = "提升品質門檻"
	BG.locale.openPlease = "請打開你的%s。它在你的背包，偷竊你的空間！"
	
	-- Sell button tooltip
	BG.locale.autoSellTooltip = "賣出物品：%s"
end