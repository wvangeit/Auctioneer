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

Watcher.auctionCities = {
	[5] = "Alliance",
	[45] = "Alliance",
	[50] = "Alliance",
	[13] = "Horde",
	[20] = "Horde",
	[55] = "Horde",
	[16] = "Neutral",
	[22] = "Neutral",
	[51] = "Neutral",
}

Watcher.getAuctionFaction = function()
	local univZone = Watcher.getCurrentZone()
	local faction = Watcher.auctionCities[univZone]
	if (not faction) then faction = "Unknown:"..GetZoneText() end
	return faction
end

Watcher.scanAuction = function(page)
	local uZone = Watcher.getCurrentZone()
	if (not Watcher.aucScan) then Watcher.aucScan = {} end
	Watcher.aucScan.ah = uZone
	Watcher.aucScan.page = page
	Watcher.aucScan.pos = 1
	Watcher.aucScan.complete = false
	Watcher.aucScan.scantime = Watcher.timeslice()
end

Watcher.scanAuctionPage = function()
	if (not Watcher.aucScan or Watcher.aucScan.complete) then return end
	local size = GetNumAuctionItems("list")
	local realm = GetRealmName()
	local city = Watcher.getAuctionFaction()
	local curdate = date("%Y%m%d")
	if (curdate ~= Watcher.expiryCheck) then Watcher.doExpiryCheck() end
	if (not Watcher_Config.auctions) then Watcher_Config.auctions = {} end
	if (not Watcher_Config.auctions[curdate]) then Watcher_Config.auctions[curdate] = {} end
	if (not Watcher_Config.auctions[curdate][realm]) then Watcher_Config.auctions[curdate][realm] = {} end
	if (not Watcher_Config.auctions[curdate][realm][city]) then Watcher_Config.auctions[curdate][realm][city] = {} end
	local auctions = Watcher_Config.auctions[curdate][realm][city]
	
	local sig, scanval
	local itemDes,link,name,texture,count,quality,usable,level,min,increment,buyout,cur,high,owner,remain
	for pos = Watcher.aucScan.pos, size do
		name,texture,count,quality,usable,level,min,increment,buyout,cur,high,owner = GetAuctionItemInfo("list", pos)
		if (owner == nil) then return false end

		link = GetAuctionItemLink("list", pos)
		itemDes = Watcher.getItemDes(link, count)
		remain = GetAuctionItemTimeLeft("list", pos)
		if (not buyout) then buyout = 0 end
		sig = string.format("%d:%d:%d:%s", itemDes, min, buyout or 0, owner)
		-- Scantime is unlimited, so 49 bits = 562,949,953,421,311
		-- Remain's max is 5, so 3 bits = 7
		--
		-- <...:.......:....3..
		-- Scantime-------->R->
		-- -------49-------><3>
		--
		scanval = bit.lshift(Watcher.aucScan.scantime, 3) + remain
		if (not auctions[sig]) then
			auctions[sig] = scanval
		else
			auctions[sig] = auctions[sig]..";"..scanval
		end
		Watcher.aucScan.pos = pos
	end
	Watcher.aucScan.complete = true
	return true
end

