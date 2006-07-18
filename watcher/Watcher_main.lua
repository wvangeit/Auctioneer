--[[
WatchDatabase WoW AddOn
-----------------------
This addon is (c)2006 norganna.org
You are granted the right to copy and use this addon for personal uses and only in it's unaltered state.
You may not host nor distribute this addon in any fashion. All rights are reserved by Norganna's AddOns.
http://norganna.org/watcher/
-----------------------
$Id$
]]

Watcher = {
	dataVersion = 0100,
}
Watcher_Config = {
	debug = false,
	dataVersion = Watcher.dataVersion,
}

Watcher.onHook = function(hooked, a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13,a14,a15,a16,a17,a18,a19,a20)
	--Watcher.debug("Processing hook "..hooked);
	if (hooked == "GameTooltip.SetMerchantItem") then
		Watcher.processMerchantItems()
	elseif (hooked == "QueryAuctionItems") then
		Watcher.scanAuction(a7) -- a7 is the page number
	elseif (hooked == "ContainerFrameItemButton_OnClick") then
		Watcher.processInventoryTarget(a1,a2)
	end
end

Watcher.onEvent = function(event, a1,a2,a3,a4,a5,a6,a7,a8,a9)
	Watcher.debug("Processing event "..event);
	if (event == "MERCHANT_SHOW") then
		Watcher.processMerchantItems()
	elseif (event == "GOSSIP_SHOW") then
		Watcher.processQuestDetail(true)
	elseif ((event == "QUEST_GREETING") or
			(event == "QUEST_PROGRESS") or
			(event == "QUEST_DETAIL")) then
		Watcher.processQuestDetail()
	elseif (event == "QUEST_LOG_UPDATE") then
		Watcher.trackNeededQuestItems()
	elseif (event == "QUEST_COMPLETE") then
		Watcher.trackQuestCompletion()
	elseif (event == "TRAINER_SHOW") then
		Watcher.processTrainerAbility()
	elseif (event == "LOOT_OPENED") then
		Watcher.processLootItems()
	elseif ((event == "PET_STABLE_SHOW") or
			(event == "AUCTION_HOUSE_SHOW") or
			(event == "BANKFRAME_OPENED") or
			(event == "TAXIMAP_OPENED")) then
		Watcher.processNpcDetail()
	elseif ((event == "SPELLCAST_START") or
			(event == "SPELLCAST_FAILED") or
			(event == "SPELLCAST_INTERRUPTED") or
			(event == "SPELLCAST_STOP")) then
		Watcher.processSpellEvent(event, a1,a2)
	elseif (event == "AUCTION_ITEM_LIST_UPDATE") then
		Watcher.scanAuctionPage()
	elseif (event == "ADDON_LOADED") then
		if (string.lower(a1) == "watcher") then
			if (Watcher_Config.dataVersion ~= Watcher.dataVersion) then
				Watcher_Config = {
					aid = Watcher_Config.aid,
					debug = Watcher_Config.debug,
					dataVersion = Watcher.dataVersion,
				}
			end
			Watcher.initCheck()
		end
	end
end

Watcher.onLoad = function()
	this:RegisterEvent("ADDON_LOADED")
	this:RegisterEvent("MERCHANT_SHOW")
	this:RegisterEvent("GOSSIP_SHOW")
	this:RegisterEvent("TRAINER_SHOW")
	this:RegisterEvent("PET_STABLE_SHOW")
	this:RegisterEvent("AUCTION_HOUSE_SHOW")
	this:RegisterEvent("BANKFRAME_OPENED")
	this:RegisterEvent("TAXIMAP_OPENED")
	this:RegisterEvent("QUEST_DETAIL")
	this:RegisterEvent("QUEST_GREETING")
	this:RegisterEvent("QUEST_PROGRESS")
	this:RegisterEvent("QUEST_COMPLETE")
	this:RegisterEvent("QUEST_LOG_UPDATE")
	this:RegisterEvent("LOOT_OPENED")
	this:RegisterEvent("SPELLCAST_START")
	this:RegisterEvent("SPELLCAST_FAILED")
	this:RegisterEvent("SPELLCAST_INTERRUPTED")
	this:RegisterEvent("SPELLCAST_STOP")
	this:RegisterEvent("AUCTION_ITEM_LIST_UPDATE")
	Watcher.hook("GameTooltip.SetMerchantItem")
	Watcher.hook("QueryAuctionItems")
	Watcher.hook("ContainerFrameItemButton_OnClick")
end

