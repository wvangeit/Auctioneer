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

Watcher.processNpcDetail = function()
	local unitDes = Watcher.getUnitDes("npc")
	local pos = Watcher.getCurrentPos()
	local now = Watcher.timeslice()

	if (not Watcher_Config.npcs) then Watcher_Config.npcs = {} end
	Watcher_Config.npcs[unitDes] = pos..":"..now
	return unitDes, pos, now
end

