-- chinese localization file by a9012456 on Curse.com
local _, BGC = ...

if GetLocale() == "zhTW" then
	BGC.locale.GlobalSetting = "\n|cffffff9a這設定是全局。"

	-- Chat Messages
	BGC.locale.addedTo_exclude = "%s已新增到保留列表。"
	BGC.locale.addedTo_forceVendorPrice = "%s只會有它認定的商店價格。"
	BGC.locale.addedTo_include = "%s已新增到垃圾列表。"
	BGC.locale.addedTo_autoSellList = "在商人時%s自動賣出。"
	
	BGC.locale.itemAlreadyOnList = "%s已經在列表!"
	BGC.locale.limitSet = "%s已經被分配一個限制%d。"
	BGC.locale.minValueSet = "物品價值小於%s將不會再被捨取。"
	BGC.locale.minSlotsSet = "捨取管理員嘗試保留至少%s空間。"

	BGC.locale.slashCommandHelp = [[以下命令是可行的:
/garbage |cffc0c0c0config|r 開啟設定面板。
/garbage |cffc0c0c0format |cffc0c0ffformatstring|r 讓你自訂LDB顯示文字，|cffc0c0c0 format reset|r 重置。
/garbage |cffc0c0c0limit |cffc0c0ffitemLink/ID count|r 在目前的角色上設定給予物品限制。
/garbage |cffc0c0c0globallimit |cffc0c0ffitemLink/ID count|r 設定所有角色限制。
/garbage |cffc0c0c0value |cffc0c0ffvalueInCopper|r 設定捨取物品的最小價值(捨取管理員需要)。
/garbage |cffc0c0c0freeslots |cffc0c0ffnumber|r 設定保留背包槽為空的數量。]]
	BGC.locale.invalidArgument = "你輸入無效的參數。請檢查你的輸入並再一次嘗試。"
	
	-- Tooltip
	BGC.locale.categoriesHeading = "分類"
	BGC.locale.LPTNotLoaded = "LibPeriodicTable未載入"
	
	-- Special types
	BGC.locale.tooltipHeadingOther = "其它"
	BGC.locale.equipmentManager = "裝備管理"
	BGC.locale.armorClass = "護甲類型"
	BGC.locale.anythingCalled = "物品名稱"
	
	-- Statistics Frame
	BGC.locale.StatisticsHeading = "統計"
	BGC.locale.ResetStatistic = "|cffffffff點擊|r 重置統計。\n|cFFff0000警告：這無法完成。"
	
	BGC.locale.MemoryUsageTitle = "記憶體使用(KB)"
	BGC.locale.CollectMemoryUsageTooltip = "|cffffffff點擊|r 開始內建的垃圾收集。"
	
	BGC.locale.GlobalStatisticsHeading = "帳號廣泛統計："
	BGC.locale.AverageSellValueTitle = "平均賣出價值"
	BGC.locale.AverageSellValueTooltip = "你所獲得的物品平均價值。計算如金錢獲得/物品賣出。"
	BGC.locale.AverageDropValueTitle = "平均丟棄價值"
	BGC.locale.AverageDropValueTooltip = "你所丟棄/刪除的物品平均價值。計算如金錢失去/物品丟棄。"
	BGC.locale.GlobalMoneyEarnedTitle = "總共賺取金額"
	BGC.locale.GlobalMoneyLostTitle = "總共失去金額"
	BGC.locale.GlobalItemsSoldTitle = "物品賣出"
	BGC.locale.ItemsDroppedTitle = "物品丟棄"
	
	BGC.locale.LocalStatisticsHeading = "角色(%s)的統計:"
	BGC.locale.StatisticsLocalAmountEarned = "總共賺得"
	BGC.locale.StatisticsLocalAmountLost = "總共失去"
	
	BGC.locale.ResetAllText = "重置全部"
	BGC.locale.ResetAllTooltip = "|cffffffff點擊|r 重置所有角色個別統計。|cffffffffSHIFT-點擊|r 清除所有全局統計。"
	
	BGC.locale.AuctionAddon = "拍賣插件"
	BGC.locale.AuctionAddonTooltip = "Broker_Garbage會從這插件獲得拍賣價值。如果沒有在列表，你可能扔然有Broker_Garbage所不知道的插件的拍賣價值。"
	BGC.locale.unknown = "未知"	-- refers to auction addon
	BGC.locale.na = "不可用"
	
	-- Basic Options Frame
	BGC.locale.BasicOptionsTitle = "基本設定"
	BGC.locale.BasicOptionsText = "你不想要自動賣出/修理?和商人說話時按住Shift(根據你的設定)!"
	
	BGC.locale.GroupBehavior = "行為"
	BGC.locale.GroupTresholds = "門檻"
	BGC.locale.GroupDisplay = "顯示"
	BGC.locale.GroupTooltip = "提示"
	
	BGC.locale.autoSellTitle = "自動賣出"
	BGC.locale.autoSellText = "勾選讓Broker_Garbage自動賣出你的灰色和垃圾物品。"
	
	BGC.locale.showAutoSellIconTitle = "顯示商人圖示"
	BGC.locale.showAutoSellIconText = "勾選顯示圖示來手動地自動賣出當在商人時。"
	
	BGC.locale.showNothingToSellTitle = "'沒有東西可以賣'"
	BGC.locale.showNothingToSellText = "勾選顯示聊天訊息當在商人時，但是卻沒有東西可以賣。"
	
	BGC.locale.autoRepairTitle = "自動修理"
	BGC.locale.autoRepairText = "勾選來自動修理當在商人時。"
	
	BGC.locale.autoRepairGuildTitle = "使用公會資金" 
	BGC.locale.autoRepairGuildText = "勾選允許Broker_Garbage使用公會金錢來修理。"
	
	BGC.locale.showSourceTitle = "來源"
	BGC.locale.showSourceText = "勾選顯示在提示的最後一行，顯示物品數值來源。"
	
	BGC.locale.showIconTitle = "圖示"
	BGC.locale.showIconText = "勾選在提示裡的物品連結前面顯示物品圖示。"
		
	BGC.locale.showEarnedTitle = "賺得"
	BGC.locale.showEarnedText = "勾選顯示角色賺得的金錢(根據賣出垃圾)"
	
	BGC.locale.showLostTitle = "失去"
	BGC.locale.showLostText = "勾選在提示上顯示角色失去的金錢。"
	
	BGC.locale.warnContainersTitle = "箱子"
	BGC.locale.warnContainersText = "勾選時，Broker_Garbage會警告你有未開啟的箱子。"
	
	BGC.locale.warnClamsTitle = "蚌"
	BGC.locale.warnClamsText = "勾選時，Broker_Garbage會警告你有蚌在你的背包。\n當蚌堆疊，你不會浪費任何槽因為沒有勾選這。"
	
	BGC.locale.dropQualityTitle = "丟棄品質"
	BGC.locale.dropQualityText = "選到物品門檻可能被列舉為可刪除。預設：貧乏"
	
	BGC.locale.moneyFormatTitle = "金錢格式"
	BGC.locale.moneyFormatText = "改變金錢顯示方式。"
	
	BGC.locale.maxItemsTitle = "最多物品"
	BGC.locale.maxItemsText = "設定多少行你要顯示在提示裡。預設：9"
	
	BGC.locale.maxHeightTitle = "最大高度"
	BGC.locale.maxHeightText = "設定提示的高度。預設：220"
	
	BGC.locale.sellNotUsableTitle = "賣出無法使用裝備"
	BGC.locale.sellNotUsableText = "勾選讓Broker_Garbage賣出所有你不能穿的靈魂綁定裝備。\n(只在不是附魔師使用)"
	
	BGC.locale.TopFitOldItem = "淘汰的護甲"
	BGC.locale.TopFitOldItemText = "如果插件TopFit已載入，Broker_Garbage可以請求淘汰的裝備並且直接賣掉。"
	
	BGC.locale.SNUMaxQualityTitle = "賣出品質"
	BGC.locale.SNUMaxQualityText = "選擇最大物品品質來賣出當'賣出無法使用裝備'或是'淘汰的護甲'被勾選。"
	
	BGC.locale.enchanterTitle = "附魔"
	BGC.locale.enchanterTooltip = "勾選這如果你有/知道附魔師。\n當勾選分解價值被考慮，那些高於商店價格。"

	BGC.locale.restackTitle = "自動重新堆疊"
	BGC.locale.restackTooltip = "勾選自動壓縮你的背包物品在你捨取之後。"
	
	BGC.locale.inDev = "根據發展"

	BGC.locale.sellLogTitle = "列出賣出紀錄"
	BGC.locale.sellLogTooltip = "勾選列出任何由Broker_Garbage賣出的物品到聊天視窗。"

	BGC.locale.overrideLPTTitle = "覆蓋LPT垃圾"
	BGC.locale.overrideLPTTooltip = "勾選忽略任何LibPeriodicTable分類資料庫的灰色物品。\n某些物品不再需要(灰色)但是扔然在列表中 例如：藥劑在LPT中。"

	BGC.locale.hideZeroTitle = "隱藏價值0銅的物品"
	BGC.locale.hideZeroTooltip = "勾選來隱藏不值任何的物品。預設啟用。"

	BGC.locale.debugTitle = "列出除錯輸出"
	BGC.locale.debugTooltip = "勾選顯示Broker_Garbage的除錯資訊。往往對你而言是垃圾，你必須注意。"

	BGC.locale.reportDEGearTitle = "報告分解淘汰的裝備"
	BGC.locale.reportDEGearTooltip = "勾選當物品變淘汰時列出訊息(根據TopFit所指)所以你可能不會分解。"

	BGC.locale.keepForLaterDETitle = "分解技能差距"
	BGC.locale.keepForLaterDETooltip = "保留需要至多<x>更多技能點數來由你的角色分解。"
	
	BGC.locale.DKTitle = "暫時停用快捷鍵"
	BGC.locale.DKTooltip = "設定快捷鍵來暫時性的停用BrokerGarbage。"
	BGC.locale.disableKeys = {
		["None"] = "無",
		["SHIFT"] = "SHIFT",
		["ALT"] = "ALT",
		["CTRL"] = "CTRL",
	}
	
	BGC.locale.LDBDisplayTextTitle = "LDB顯示文字"
	BGC.locale.LDBDisplayTextTooltip = "設定在LDB插件顯示的文字。"
	BGC.locale.LDBNoJunkTextTooltip = "設定當沒有垃圾時顯示的文字。"
	BGC.locale.ResetToDefault = "重置到預設值。"
	BGC.locale.LDBDisplayTextHelpTooltip = [[|cffffffff基本標籤:|r
[itemname] - 物品連結
[itemicon] - 物品圖示
[itemcount] - 物品統計
[itemvalue] - 物品價值
[junkvalue] - 總共自動賣出價值

|cffffffff背包空間標籤:|r
[freeslots] - 空間包包槽
[totalslots] - 所有包包槽
[basicfree],[specialfree] - 空間
[basicslots],[specialslots] - 總共

|cffffffff顏色標籤:|r
[bagspacecolor]... - 所有包包
[basicbagcolor]... - 只有基本
[specialbagcolor]... - 只有特別
...[endcolor] 結束部分顏色]]
	
	-- List Options Panel
	BGC.locale.LOTitle = "列表"
	BGC.locale.LOSubTitle = [[如果你需要幫助點擊"?"標籤

|cffffd200垃圾|r: 在列表的物品可能會被丟出如果背包需要空間。
|cffffd200保留|r: 在列表的物品不會被刪除或賣出。
|cffffd200商店價格|r: 在列表裡的物品只使用商店價值。(這列表是全局的)
|cffffd200賣出|r: 在列表的物品當在商人時會被賣掉。這也只使用商店價值。

!! Always use the 'Rescan Inventory' button after you make changes !!]]
	
	BGC.locale.defaultListsText = "預設列表"
	BGC.locale.defaultListsTooltip = "|cffffffff點擊|r 手動建立預設局部列表項目。\n |cffffffffShift-點擊|r 建立預設全局列表。"
	
	BGC.locale.rescanInventoryText = "更新背包"
	BGC.locale.rescanInventoryTooltip = "|cffffffff點擊|r 讓Broker_Garbage重新掃描你的背包。當你改變列表項目都要這樣做!"

	BGC.locale.LOTabTitleInclude = "垃圾"
	BGC.locale.LOTabTitleExclude = "保留"
	BGC.locale.LOTabTitleVendorPrice = "商店價格"
	BGC.locale.LOTabTitleAutoSell = "賣出"
	
	BGC.locale.LOIncludeAutoSellText = "賣出垃圾列表物品"
	BGC.locale.LOIncludeAutoSellTooltip = "勾選來自動賣出在你包含列表裡的物品當在商人時。沒有價值的物品會被忽略。"
	
	BGC.locale.LOUseRealValues = "使用實際的垃圾物品價值"
	BGC.locale.LOUseRealValuesTooltip = "勾選來讓垃圾物品被考慮到實際的價值，而不是0銅。"
	
	BGC.locale.listsBestUse = [[|cffffd200列表舉例|r
不要忘記使用預設列表!他們提供最好的例子。
首先，放置任何你不想失去的物品在你的|cffffd200保留列表|r。用好分類使用(看以下)! 如果捨取管理員啟動，將會嘗試捨取物品。
|cffAAAAAA例如 class reagents, flasks|r
物品在你|cffffd200垃圾列表|r將被任何時候被丟棄。
|cffAAAAAA例如 summoned food & drink, argent lance|r
假如你遇到高度高估的物品，放置他們到你的|cffffd200商店價格列表|r。他們就只會有商店價格而不是拍賣或是分解價格。
|cffAAAAAA例如 fish oil|r
放置物品到你的|cffffd200賣出列表|r當你訪問商人會被賣出。
|cffAAAAAA例如 water as a warrior, cheese|r]]

	BGC.locale.listsSpecialOptions = [[|cffffd200垃圾列表特別設定|r
|cffffd200賣出垃圾列表物品|r: 對那些不想要區分賣出列表跟垃圾列的人這設定是有用的。如果你勾選，當你訪問商店任何在你垃圾或賣出列表的物品會被賣出。
|cffffd200使用真實的價值|r: 這設定改變垃圾列表的行為。根據預設(禁用)垃圾列表會讓他們的價值設定為0銅(統計扔然會工作得很好!)並且第一時間被顯示在提示中。如果你啟用這設定，這些物品會保留他們合理的價值並且只會在提示裡顯示一次他們的價值。]]
	
	BGC.locale.iconButtonsUse = [[|cffffd200物品按鈕|r
對任何物品你可以看到圖示，如果分類或是或是伺服器無法辨識的問題。
在左上的任何按鈕你可以看見"G"(或是沒有)。如果有，物品在你的|cffffd200全局列表|r，指的是對你所有角色都有影響。
在你垃圾列表的物品也有個|cffffd200限制|r。會在右下角顯示小數字，在按鈕上使用|cffffd200滑鼠滾輪|r你可以改變數字。限制的物品只會被拖曳如果你對他們有更多的指示。]]
	
	BGC.locale.actionButtonsUse = [[|cffffd200拍賣按鈕|r
下面這視窗你可以看到5個按鈕和搜尋條。
|TInterface\Icons\Spell_ChargePositive:18|t |cffffd200附加|r: 新增物品到目前顯示的列表。只需要拖曳到附加。新增|cffffd200分類|r，右鍵-點擊 附加並且選擇分類。
|cffAAAAAA例如 "Tradeskill > Recipe" "Misc > Key"|r
|TInterface\Icons\Spell_ChargeNegative:18|t |cffffd200減少|r: 點選在列表裡標記的物品。當你點擊減少，就會從列表中移除。
|TInterface\Icons\INV_Misc_GroupLooking:18|t |cffffd200局部|r: 被標記的物品會放到你的局部列表，這想規則只作用在你目前啟動的角色。
|TInterface\Icons\INV_Misc_GroupNeedMore:18|t |cffffd200全局|r: 某些是局部，只有這項物品會被放到你的全局列表。這些規則對你所有角色都有效。
|TInterface\Buttons\UI-GroupLoot-Pass-UP:18|t |cffffd200清空|r: 點擊這按鈕來移除任何角色個別(局部)物品。Shift-點擊 清空任何帳號的廣泛(局部)規則。|cffff0000使用警告!|r]]

	BGC.locale.LOPlus = "|cffffffff拖曳|r物品到按鈕來新增物品到列表。\n|cffffffff右鍵-點擊|r 新增種類!"
	BGC.locale.LOMinus = "從列表中選擇物品移除，然後|cffffffff點擊|r這裡。"
	BGC.locale.LODemote = "|cffffffff點擊|r讓任何被標記的物品被使用作為角色的個別規則。"
	BGC.locale.LOPromote = "|cffffffff點擊|r來使用任何被標記的物品作為帳號的廣泛規則。"
	BGC.locale.LOEmptyList = "|cffff0000注意!|r\n|cffffffff點擊|r清空任何局部列表項目。\n"..
		"|cffff0000Shift-點擊!|r 清空任何全局項目。"
	
	BGC.locale.namedItems = "|TInterface\\Icons\\Spell_chargepositive:15:15|t 物品名稱..."
	BGC.locale.search = "搜尋..."
	
	-- LibPeriodicTable category testing
	BGC.locale.PTCategoryTest = "分類測試"
	BGC.locale.PTCategoryTestExplanation = "只需選擇以下的分類就會顯示在你背包相符的所有物品。\n分類資訊由LibPeriodicTable提供。"
	BGC.locale.PTCategoryTestDropdownTitle = "分類檢查"
	BGC.locale.PTCategoryTestDropdownText = "選擇分類字串"

	BGC.locale.categoryTestItemSlot = "拖物品到這個槽來搜尋任何有包含它的分類。"
	BGC.locale.categoryTestItemTitle = "%s已經在這些分類...\n"
	BGC.locale.categoryTestItemEntry = "%s不在任何已使用的分類。"
end