-- chinese localization file by a9012456 on Curse.com
local _, BGLM = ...

if GetLocale() == "zhTW" then
	BGLM.locale.CreatureTypeBeast = "野獸"
	BGLM.locale.GlobalSetting = "\n|cffffff9a這設定是全局。"
	
	-- Chat Messages
	BGLM.locale.couldNotLootValue = "沒有捨取%s，因為太便宜。"
	BGLM.locale.couldNotLootCompareValue = "沒有捨取%s。它比我們已經有的還要便宜。背包滿了!"
	BGLM.locale.couldNotLootBlacklist = "沒有捨取%s，因為它在你的垃圾列表。"
	BGLM.locale.couldNotLootLocked = "無法捨取%s，因為它被鎖定。請手動捨取。"
	BGLM.locale.couldNotLootSpace = "無法捨取%s，因為你沒有任何空間。"
	BGLM.locale.couldNotLootLM = "你是捨取管理員，請手動分配%s。"
	
	BGLM.locale.errorInventoryFull = "有東西沒有被捨取，因為你的背包滿了。請手動捨取!"
	
	-- Loot Manager
	BGLM.locale.LMTitle = "捨取管理員"
	BGLM.locale.LMSubTitle = "捨取管理員控制你的捨取和背包空間。"
	
	BGLM.locale.GroupLooting = "捨取"
	BGLM.locale.GroupInventory = "背包"
	BGLM.locale.GroupNotices = "注意"
	BGLM.locale.GroupTreshold = "門檻"
	
	BGLM.locale.LMEnableInCombatTitle = "戰鬥中啟用"
	BGLM.locale.LMEnableInCombatTooltip = "如果勾選，Broker_Garbage會嘗試捨取即使你在戰鬥中。\n|cffff0000警告|r: 這可能會造成'插件被阻擋'事件。"
	
	BGLM.locale.LMAutoLootTitle = "自動捨取"
	BGLM.locale.LMAutoLootTooltip = "使用這設定或是組合以下設定讓Broker_Garbage來決定如何/如果處理捨取。"
	
	BGLM.locale.LMAutoLootSkinningTitle = "剝皮"
	BGLM.locale.LMAutoLootSkinningTooltip = "勾選來捨取如果你可以剝皮生物。"
	
	BGLM.locale.LMAutoLootPickpocketTitle = "偷竊"
	BGLM.locale.LMAutoLootPickpocketTooltip = "勾選來捨取如果你是盜賊並且潛行。"
	
	BGLM.locale.LMAutoLootFishingTitle = "釣魚"
	BGLM.locale.LMAutoLootFishingTooltip = "勾選來捨取如果是釣魚捨取。"
	
	BGLM.locale.LMAutoAcceptLootTitle = "自動確認捨取綁定"
	BGLM.locale.LMAutoAcceptLootTooltip = "勾選自動確認捨取綁定。"
	
	BGLM.locale.LMCloseLootTitle = "關閉視窗"
	BGLM.locale.LMCloseLootTooltip = "勾選自動關閉捨取視窗同時沒有興趣的物品會被遺留在裡面。\n|cffff0000警告|r: 這可能會干擾其它插件。"
	
	BGLM.locale.LMForceClearTitle = "強制清除Mobs"
	BGLM.locale.LMForceClearTooltip = "勾選清除Mobs(即使你不是skinner)。用這設定你可能失去金錢!"
	
	BGLM.locale.lootJunkTitle = "捨取 '垃圾'"
	BGLM.locale.lootJunkTooltip = "勾選捨取在你'垃圾'清單的物品像是正常物品。"

	BGLM.locale.lootKeepTitle = "捨取 '保留'"
	BGLM.locale.lootKeepTooltip = "勾選總是捨取在你'保留'清單的物品。"

	BGLM.locale.LMAutoDestroyTitle = "自動摧毀"
	BGLM.locale.LMAutoDestroyTooltip = "勾選時，Broker_Garbage將會採取行動當你背包空間(幾乎)滿。"
	
	BGLM.locale.LMAutoDestroyInstantTitle = "強制"
	BGLM.locale.LMAutoDestroyInstantTooltip = "勾選時，Broker_Garbage可能在捨取那時刻刪除物品。換句話說，刪除僅發生在你有更好的捨取或是需要空間。"
	
	BGLM.locale.debugTitle = "列出除錯輸出"
	BGLM.locale.debugTooltip = "勾選顯示LootManager的除錯資訊。往往對你而言是垃圾，你必須注意。"

	BGLM.locale.LMFreeSlotsTitle = "最小空間槽"
	BGLM.locale.LMFreeSlotsTooltip = "設定最小空間槽數量來讓自動摧毀行動。"
	
	BGLM.locale.LMWarnLMTitle = "捨取管理員"
	BGLM.locale.LMWarnLMTooltip = "勾選時，Broker_Garbage將會列出通知提醒你分配捨取。"
	
	BGLM.locale.LMWarnInventoryFullTitle = "背包已滿"
	BGLM.locale.LMWarnInventoryFullTooltip = "勾選讓Broker_Garbage顯示聊天訊息當'背包滿了。'錯誤觸發。"
	
	BGLM.locale.printValueTitle = "低於門檻"
	BGLM.locale.printValueText = "勾選獲得聊天訊息當Broker_Garbage不捨取物品，因為物品價值少於最小捨取價值(看下面)。"
	
	BGLM.locale.printCompareValueTitle = "太便宜"
	BGLM.locale.printCompareValueText = "勾選收到聊天訊息當Broker_Garbage不捨取物品，因為它比你所有已獲得的價值還少。"
	
	BGLM.locale.printJunkTitle = "在垃圾列表"
	BGLM.locale.printJunkText = "勾選收到聊天訊息當Broker_Garbage不捨取物品，因為在你的垃圾列表。"
	
	BGLM.locale.printSpaceTitle = "缺少空間"
	BGLM.locale.printSpaceText = "勾選收到聊天訊息當Broker_Garbage不捨取物品，因為你的背包已經滿了且自動摧毀已禁用。"
	
	BGLM.locale.printLockedTitle = "已鎖定"
	BGLM.locale.printLockedText = "勾選收到聊天訊息當Broker_Garbage不捨取物品，因為已經鎖定(舉例：已經有人捨取)。"
		
	BGLM.locale.LMItemMinValue = "最小物品價值捨取"
end