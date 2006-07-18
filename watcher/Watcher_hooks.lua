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

Watcher.funchooks = {}
Watcher.hook = function(hookFunction)
	local vars = "a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13,a14,a15,a16,a17,a18,a19,a20"
	RunScript(
		"Watcher.funchooks['"..hookFunction.."'] = "..hookFunction.." "..
		hookFunction.." = function("..vars..") "..
			"Watcher.onHook('"..hookFunction.."', "..vars..") "..
			"return Watcher.funchooks['"..hookFunction.."']("..vars..") "..
		"end"
	)
end

Watcher.timer = 0
Watcher.timers = {}
Watcher.cron = function(elapsed)
	local time = Watcher.timer + elapsed
	Watcher.timer = time
	for scheduled, event in pairs(Watcher.timers) do
		if (time >= scheduled) then RunScript(event) end
		Watcher.timers[scheduled] = nil
	end
end
