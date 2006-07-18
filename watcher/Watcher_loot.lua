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

Watcher.processLootItems = function()
	local unitDes = Watcher.getUnitDes("target")
	local pos = Watcher.getCurrentPos()
	local now = Watcher.timeslice()

	local player = Watcher.getPlayerDes()

	if (unitDes == "anonymous") then
		unitDes = Watcher.checkSpells()
	elseif (Watcher.checkSkinning()) then
		unitDes = "skin:"..unitDes
	else
		unitDes = "mob:"..unitDes
	end

	local groupDes = Watcher.getGroupHash()

	if (not Watcher_Config.loot) then Watcher_Config.loot = {} end
	if (not Watcher_Config.loot[player]) then Watcher_Config.loot[player] = {} end
	if (not Watcher_Config.loot[player][groupDes]) then Watcher_Config.loot[player][groupDes] = {} end
	if (not Watcher_Config.loot[player][groupDes][unitDes]) then Watcher_Config.loot[player][groupDes][unitDes] = {} end
	local unitLoot = Watcher_Config.loot[player][groupDes][unitDes]

	local done = 0
	local numItems = GetNumLootItems()
	local _, link, texture, name, quantity, quality, itemDes
	for i = 1, numItems do
		link = GetLootSlotLink(i)
		texture, name, quantity, quality = GetLootSlotInfo(i)
		if (link) then
			quantity = tonumber(quantity or 1)
			itemDes = Watcher.getItemDes(link, quantity)
		elseif (LootSlotIsCoin(i)) then
			local i,j,val
			local coin = 0
			i,j, val = string.find(name, "(%d+) "..COPPER)
			if (i) then coin = coin + val end
			i,j, val = string.find(name, "(%d+) "..SILVER)
			if (i) then coin = coin + (val*100) end
			i,j, val = string.find(name, "(%d+) "..GOLD)
			if (i) then coin = coin + (val*10000) end
			-- This is the same formula as the utils:getItemDes function
			-- When decoded, this will appear as an item with itemID 0 and
			-- a quantity of 0. Bits 25 and up will contain the coin value
			itemDes = bit.lshift(coin, 25)
		end

		if (itemDes) then
			Watcher.debug("Storing drop from "..unitDes..": "..itemDes.." @ "..now)
			
			if (unitLoot[itemDes]) then
				unitLoot[itemDes] = unitLoot[itemDes] .. ";" .. now .. ":" .. pos
			else
				unitLoot[itemDes] = now .. ":" .. pos
			end
			done = done + 1
		end
	end
	if (done == 0) then
		itemDes = "none"
		if (unitLoot[itemDes]) then
			unitLoot[itemDes] = unitLoot[itemDes] .. ";" .. pos
		else
			unitLoot[itemDes] = pos
		end
	end
end
