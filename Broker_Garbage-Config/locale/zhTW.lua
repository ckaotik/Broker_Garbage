-- chinese localization file by a9012456 @Curse.com and google ;)
local _, BGC = ...

if GetLocale() == "zhTW" then
	-- BGC.locale.GlobalSetting = "\n|cffffff9aThis setting is global."

	-- Chat Messages
	BGC.locale.addedTo_exclude = "%s已經被新增到儲存名單。"
	BGC.locale.addedTo_forceVendorPrice = "%s只會有它自己的商店價錢考慮。"
	BGC.locale.addedTo_include = "%s已經被新增到包含名單。"
	BGC.locale.addedTo_autoSellList = "%s自動賣出當在商人。"
	
	-- BGC.locale.itemAlreadyOnList = "%s is already on this list!"
	BGC.locale.limitSet = "%s已經被分配一個限制%d。"
	BGC.locale.minValueSet = "物品價值小於%s將不會再被捨取。"
	-- BGC.locale.minSlotsSet = "The Loot Manager will try to keep at least %s slots free."

	BGC.locale.slashCommandHelp = [=[以下命令可以啟動: |cffc0c0c0/garbage|r
|cffc0c0c0config|r 開啟設定面板。
|cffc0c0c0format |cffc0c0ffformatstring|r 讓你自訂LDB顯示文字， |cffc0c0c0 format reset|r 重置。
|cffc0c0c0stats|r 回傳統計。
|cffc0c0c0limit |cffc0c0ffitemLink/ID count|r 在目前的角色上設定給予物品限制。
|cffc0c0c0globallimit |cffc0c0ffitemLink/ID count|r 設定所有角色限制。
|cffc0c0c0value |cffc0c0ffvalueInCopper|r 設定捨取物品的最小數值(Loot Manager 需要)。]=]
	-- BGC.locale.invalidArgument = "You supplied an invalid argument. Please check your input and try again."
	
	-- Tooltip
	-- BGC.locale.categoriesHeading = "Categories"
	-- BGC.locale.LPTNotLoaded = "LibPeriodicTable not loaded"
	
	-- Special types
	-- BGC.locale.tooltipHeadingOther = "Other"
	-- BGC.locale.equipmentManager = "Equipment Manager"
	-- BGC.locale.armorClass = "Armor Class"
	-- BGC.locale.anythingCalled = "Items named"
	
	-- Statistics Frame
	BGC.locale.StatisticsHeading = "统计" -- this is probably not correct
	BGC.locale.ResetStatistic = "|cffffffff点击|r重置这个统计。\n|cFFff0000警告：这不能撤消。"
	
	BGC.locale.MemoryUsageTitle = "記憶體使用(KB)"
	BGC.locale.CollectMemoryUsageTooltip = "點擊開始垃圾收集(內建功能)"
	
	BGC.locale.GlobalStatisticsHeading = "整體金錢統計："
	BGC.locale.AverageSellValueTitle = "平均賣出價值"
	-- BGC.locale.AverageSellValueTooltip = "The average value an item earned you. Calculated as Money Earned/Items Sold."
	BGC.locale.AverageDropValueTitle = "平均丟棄價值"
	-- BGC.locale.AverageDropValueTooltip = "The average value of dropped/deleted items. Calculated as Money Lost/Items Dropped."
	BGC.locale.GlobalMoneyEarnedTitle = "全部已賺的總額"
	BGC.locale.GlobalMoneyLostTitle = "全部失去的總額"
	BGC.locale.GlobalItemsSoldTitle = "物品賣出"
	BGC.locale.ItemsDroppedTitle = "物品丟棄"
	
	BGC.locale.LocalStatisticsHeading = "%s的統計:"
	BGC.locale.StatisticsLocalAmountEarned = "總共賺得"
	BGC.locale.StatisticsLocalAmountLost = "總共失去"
	
	BGC.locale.ResetAllText = "重置整體統計"
	-- BGC.locale.ResetAllTooltip = "|cffffffffClick|r here to reset all character specific statistics. |cffffffffSHIFT-Click|r to clear all global statistics." -- 典籍這裡重置所有本地統計。
	
	BGC.locale.AuctionAddon = "拍卖插件"
	-- BGC.locale.AuctionAddonTooltip = "Broker_Garbage will take auction values from this addon. If none is listed, you may still have auction values available by an addon that Broker_Garbage doesn't know."
	BGC.locale.unknown = "未知"	-- refers to auction addon
	BGC.locale.na = "不可用"
	
	-- Basic Options Frame
	BGC.locale.BasicOptionsTitle = "基本設定"
	BGC.locale.BasicOptionsText = "你不想要自動賣出/修理?和商人說話時按住Shift(根據你的設定)!"
	
	BGC.locale.GroupBehavior = "行为"
	BGC.locale.GroupTresholds = "阈"
	BGC.locale.GroupDisplay = "的广告"
	BGC.locale.GroupTooltip = "工具提示"
	
	BGC.locale.autoSellTitle = "自動賣出"
	BGC.locale.autoSellText = "切換自動賣出你的裝備物品"
	
	BGC.locale.showAutoSellIconTitle = "顯示圖示"
	BGC.locale.showAutoSellIconText = "切換顯示圖示來手動賣出。"
	
	BGC.locale.showNothingToSellTitle = "'沒有東西可以賣'"
	BGC.locale.showNothingToSellText = "切換顯示提示當在一個商店且沒有東西可以賣。"
	
	BGC.locale.autoRepairTitle = "自動修復"
	BGC.locale.autoRepairText = "切換自動修復你的裝備"
	
	BGC.locale.autoRepairGuildTitle = "允许维修协会" 
	BGC.locale.autoRepairGuildText = "检查允许Broker_Garbage使用公会资金进行修复。"
	
	BGC.locale.showSourceTitle = "顯示來源"
	BGC.locale.showSourceText = "切換在提示顯示最後列，顯示物品數值來源。"
	
	-- BGC.locale.showIconTitle = "Icon"
	-- BGC.locale.showIconText = "Check to show the item's icon in front of the item link on the tooltip."
		
	BGC.locale.showEarnedTitle = "顯示金錢獲得"
	BGC.locale.showEarnedText = "切換顯示提示'金錢賺得'行。"
	
	BGC.locale.showLostTitle = "顯示金錢失去"
	BGC.locale.showLostText = "切換顯示'金錢失去'行提示。"
	
	BGC.locale.warnContainersTitle = "警告：箱子"
	BGC.locale.warnContainersText = "當勾選，Broker_Garbage會警告你當你有未開啟的箱子在你的背包。"
	
	BGC.locale.warnClamsTitle = "警告：蚌"
	BGC.locale.warnClamsText = "當勾選，Broker_Garbage將會警告你當你有蚌在你的背包。當這些東西現在做堆疊，藉由取消選中你不用浪費任何槽。"
	
	BGC.locale.dropQualityTitle = "丟棄品質"
	BGC.locale.dropQualityText = "最多選擇treshold物品可能被列表當作可刪除。預設：Poor (0)"
	
	BGC.locale.moneyFormatTitle = "金錢格式"
	BGC.locale.moneyFormatText = "改變金錢顯示方式(即金/銀/銅)。"
	
	BGC.locale.maxItemsTitle = "最大。物品"
	BGC.locale.maxItemsText = "設定多少行你要顯示在提示。預設：9"
	
	BGC.locale.maxHeightTitle = "最大。高度"
	BGC.locale.maxHeightText = "設定提示高度。預設：220"
	
	BGC.locale.sellNotUsableTitle = "賣出裝備"
	BGC.locale.sellNotUsableText = "勾選這來讓Broker_Garbage賣出所有你不能穿的靈魂綁定裝備。"
	
	-- BGC.locale.TopFitOldItem = "Outdated Armor"
	-- BGC.locale.TopFitOldItemText = "If the addon TopFit is loaded, BG can ask for outdated gear and directly sell it."
	
	BGC.locale.SNUMaxQualityTitle = "最大。品質"
	BGC.locale.SNUMaxQualityText = "當'賣出裝備'被勾選，選擇最大品質來賣。"
	
	BGC.locale.enchanterTitle = "附魔"
	BGC.locale.enchanterTooltip = "勾選這個如果你有/知道附魔。當勾選，Broker_Garbage將使用分解物品，通常高於商店價錢。"

	BGC.locale.restackTitle = "滿的背包"
	BGC.locale.restackTooltip = "勾選將會捨取在你全部的背包為了可堆疊物品，不只是已看過物品。"
	
	--[[ BGC.locale.inDev = "Under Development",

	BGC.locale.sellLogTitle = "Print Sell Log",
	BGC.locale.sellLogTooltip = "Check to print any item that gets sold by Broker_Garbage into your chat.",

	BGC.locale.overrideLPTTitle = "Override LPT junk",
	BGC.locale.overrideLPTTooltip = "Check to ignore any LibPeriodicTable category data for grey items.\nSome items are no longer needed (grey) but still listed as e.g. reagents in LPT.",

	BGC.locale.hideZeroTitle = "Hide items worth 0c",
	BGC.locale.hideZeroTooltip = "Check to hide items that are not worth anything. Enabled by default.",

	BGC.locale.debugTitle = "Print debug output",
	BGC.locale.debugTooltip = "Check to display Broker_Garbage's debug information. Tends to spam your chat frame, you have been warned.",

	BGC.locale.reportDEGearTitle = "Report outdated gear for disenchanting",
	BGC.locale.reportDEGearTooltip = "Check to print a message when an item becomes outdated (by means of TopFit) so you may disenchant it.",

	BGC.locale.keepForLaterDETitle = "DE skill difference",
	BGC.locale.keepForLaterDETooltip = "Keep items that require at most <x> more skill points to be disenchanted by your character." ]]--
	
	BGC.locale.DKTitle = "暫存。停用按鍵"
	BGC.locale.DKTooltip = "設定一個按鍵來暫時性的停用BrokerGarbage。"
	BGC.locale.disableKeys = {
		["None"] = "無"
		["SHIFT"] = "SHIFT"
		["ALT"] = "ALT"
		["CTRL"] = "CTRL"
	},
	
	BGC.locale.LDBDisplayTextTitle = "LDB顯示文字"
	BGC.locale.LDBDisplayTextTooltip = "使用這項來改變你在LDB顯示裡所看到的文字。"
	BGC.locale.LDBNoJunkTextTooltip = "使用這改變你所看到的文字當沒有垃圾被顯示。"
	BGC.locale.ResetToDefault = "重置为默认值。"
	BGC.locale.LDBDisplayTextHelpTooltip = [=[|cffffffffBasic tags:|r
[itemname] - 物品連結
[itemicon] - item icon
[itemcount] - 物品計數
[itemvalue] - 物品數值
[junkvalue] - total autosell value

|cffffffffInventory space tags:|r
[freeslots] - 任意包包槽
[totalslots] - 所有包包槽
[junkvalue] - 所有自動售出數值
[basicfree],[specialfree] - free
[basicslots],[specialslots] - total

|cffffffffColor tags:|r
[bagspacecolor]... - all bags
[basicbagcolor]... - basic only
[specialbagcolor]... - special only
...[endcolor] ends a color section]=] -- changed
	
	-- List Options Panel
	BGC.locale.LOTitle = "Lists"
	BGC.locale.LOSubTitle = [[類似使用到確定名單。為了設定物品限制，當經過物品圖示使用你的滾輪。点击“？”标签帮助

|cffffd200Junk|r: Items on this list can be thrown away if inventory space is needed.
|cffffd200Keep|r: Items on this list will never be deleted or sold.
|cffffd200Vendor Price|r: Items on this list only use vendor values. (This list is always global)
|cffffd200Sell|r: Items on this list will be sold when at a merchant. They also only use vendor prices.

!! Always use the 'Rescan Inventory' button after you make changes !!]],
	
	-- BGC.locale.defaultListsText = "Default Lists"
	-- BGC.locale.defaultListsTooltip = "|cffffffffClick|r to manually create default local list entries.\n |cffffffffShift-Click|r to also create default global lists." -- changed
	
	BGC.locale.rescanInventoryText = "重新掃描背包"
	BGC.locale.rescanInventoryTooltip = "點擊手動重新掃描你的背包。通常應該不需要。 Do this whenever you change list entries!" -- changed

	BGC.locale.LOTabTitleInclude = "废料"
	BGC.locale.LOTabTitleExclude = "继续"
	BGC.locale.LOTabTitleVendorPrice = "经销商奖"
	BGC.locale.LOTabTitleAutoSell = "卖出"
	
	BGC.locale.LOIncludeAutoSellText = "卖废品的项目清单"
	-- BGC.locale.LOIncludeAutoSellTooltip = "Check this to automatically sell items on your include list when at a merchant. Items without a value will be ignored."
	
	BGC.locale.LOUseRealValues = "实际值用于废料"
	-- BGC.locale.LOUseRealValuesTooltip = "Check this to have junk items considered with their actual value, rather than 0c."
	
	BGC.locale.listsBestUse = [[|cffffd200List Examples|r
Don't forget to use the default lists! They provide a great example.
First, put any items you don't want to lose on your |cffffd200Keep List|r. Make good use of categories (see below)! If the LootManager is active it will alwas try to loot these items.
|cffAAAAAAe.g. class reagents, flasks|r
Items which may be thrown away any time belong on the |cffffd200Junk List|r.
|cffAAAAAAe.g. summoned food & drink, argent lance|r
In case you encounter highly overrated items, put them on your |cffffd200Vendor Price List|r. They will only have their vendor value used instead of auction or disenchant values.
|cffAAAAAAe.g. fish oil|r
Put items on your |cffffd200Sell List|r that should be sold when visiting a merchant.
|cffAAAAAAe.g. water as a warrior, cheese|r]],

	BGC.locale.listsSpecialOptions = [[|cffffd200Junk List special options|r
|cffffd200Sell Junk List items|r: This setting is useful for those who do not want to distinguish between the Sell List and the Junk List. If you check this, any items on your Junk -or- Sell List will be sold when you visit a vendor.
|cffffd200Use actual values|r: This setting changes the behavior of the Junk List. By default (disabled) Junk List items will get their value set to 0c (statistics will still work just fine!) and they will be shown first in the tooltip. If you enable this setting, these items will retain their regular value and will only show up in the tooltip once their value is reached.]],
	
	BGC.locale.iconButtonsUse = [[|cffffd200Item Buttons|r
For any item you'll either see its icon, a gear if it's a category or a question mark in case the server doesn't know this item.
In the top left of each button you'll see a "G" (or not). If it's there, the item is on your |cffffd200global list|r meaning this rule is effective for every character.
Items on your Junk List may also have a |cffffd200limit|r. This will be shown as a small number in the lower right corner. By using the |cffffd200mousewheel|r on this button you can change this number. Limited items will only be dropped/destroyed if you have more than their limit indicates.]],
	
	BGC.locale.actionButtonsUse = [[|cffffd200Action Buttons|r
Below this window you'll see five buttons and a search bar.
|TInterface\Icons\Spell_ChargePositive:18|t |cffffd200Plus|r: Use this to add items to the currently shown list. Simply drag/drop them onto the plus. To add a |cffffd200category|r, right-click the plus and then choose a category.
|cffAAAAAAe.g. "Tradeskill > Recipe" "Misc > Key"|r
|TInterface\Icons\Spell_ChargeNegative:18|t |cffffd200Minus|r: Mark items on the list (by clicking them). When you click the minus, they will be removed from this list.
|TInterface\Icons\INV_Misc_GroupLooking:18|t |cffffd200Local|r: Marked items will be put on your local list, meaning the rule is only active for the current character.
|TInterface\Icons\INV_Misc_GroupNeedMore:18|t |cffffd200Global|r: Same as local, only this time items will be put on your global list. Those rules are active for all your characters.
|TInterface\Buttons\UI-GroupLoot-Pass-UP:18|t |cffffd200Empty|r: Click this button to remove any character specific (local) items from it. Shift-click empties any account wide (global) rules. |cffff0000Use with caution!|r]],

	BGC.locale.LOPlus = "藉由拖曳來新增物品。右鍵點擊新增種類！"
	BGC.locale.LOMinus = "選擇你想要移除的物品，然後點擊這裡。"
	-- BGC.locale.LODemote = "|cffffffffClick|r to have any marked items used as character specific rules."
	-- BGC.locale.LOPromote = "|cffffffffClick|r to use any marked item as account wide rule."
	BGC.locale.LOEmptyList = "|cffff0000Caution!|r\n|cffffffffClick|r to empty any local entries on this list.\n"..
		"|cffff0000警告!|r SHIFT-點擊 清空你的商店價錢名單。"
	
	BGC.locale.namedItems = "|TInterface\\Icons\\Spell_chargepositive:15:15|t 主题与名称 ..."
	BGC.locale.search = "搜索..."
	
	-- LibPeriodicTable category testing
	-- BGC.locale.PTCategoryTest = "Category Test"
	-- BGC.locale.PTCategoryTestExplanation = "Simply select a category below and it will display all items in your inventory that match this category.\nCategory information is provided by LibPeriodicTable."
	-- BGC.locale.PTCategoryTestDropdownTitle = "Category to check"
	-- BGC.locale.PTCategoryTestDropdownText = "Choose a category string"
end