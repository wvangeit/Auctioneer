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

Watcher.processMerchantItems = function()
	local unitDes, pos, now = Watcher.processNpcDetail()
	local numItems = GetMerchantNumItems()

	if (not Watcher_Config.merchants) then Watcher_Config.merchants = {} end
	
	local merchant
	if (Watcher_Config.merchants[unitDes]) then
		merchant = Watcher_Config.merchants[unitDes]
		if (now - merchant.scantime < 50 and merchant.count == numItems) then
			-- No point scanning again.
			return
		end
	else
		-- Create a new merchant
		Watcher_Config.merchants[unitDes] = {}
		merchant = Watcher_Config.merchants[unitDes]
	end

	merchant.scantime = now
	merchant.pos = pos

	-- Now we go through all the merchant's items and scan them
	local done = 0
	local link, name, texture, price, quantity, numAvailable, isUsable, item, itemDes
	for i=1, numItems, 1 do
		link = GetMerchantItemLink(i)
		if (link) then
			name, texture, price, quantity, numAvailable, isUsable = GetMerchantItemInfo(i)
			itemDes = Watcher.getItemDes(link, quantity)
			
			if (numAvailable ~= 0) then
				if (numAvailable < 0) then numAvailable = 0 end
				local itemVal = bit.lshift(now, 7) + numAvailable
				merchant[itemDes] = itemVal
				Watcher.debug("Storing purchasable from "..unitDes..": "..itemDes..": "..itemVal)
			end
			done = done + 1
		end
	end
	merchant.count = done
end
