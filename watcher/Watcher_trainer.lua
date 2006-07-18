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

Watcher.processTrainerAbility = function()
	local unitDes, pos, now = Watcher.processNpcDetail()
	local numAbilities = GetNumTrainerServices()
	local expanded

	local name, rank, category, isexpanded = GetTrainerServiceInfo(1)
	if (not name) then return end

	local trainer
	if (not Watcher_Config.trainers) then Watcher_Config.trainers = {} end
	if (Watcher_Config.trainers[unitDes]) then
		trainer = Watcher_Config.trainers[unitDes]
		if (now - trainer.scantime < 50 and trainer.count == numAbilities) then
			-- No point scanning again.
			return
		end
	else
		-- Create a new trainer
		Watcher_Config.trainers[unitDes] = {}
		trainer = Watcher_Config.trainers[unitDes]
	end

	trainer.scantime = now
	trainer.count = numAbilities
	trainer.pos = pos
	
	for i = 1, numAbilities do
		name, rank, category, isexpanded = GetTrainerServiceInfo(i)
		if category == "header" and not isexpanded then
			if (not expanded) then expanded = {} end
			table.insert(expanded, i)
			ExpandTrainerSkillLine(i)
			numAbilities  = GetNumTrainerServices()
		elseif category ~= "header" then
			if (rank and rank ~= "") then name = name.." ("..rank..")" end
			trainer[name] = now
			Watcher.debug("Storing ability from "..unitDes..": "..name.." @ "..now)
		end
	end
	if (expanded) then
		for i=table.getn(expanded), 1, -1 do
			CollapseTrainerSkillLine(expanded[i])
		end
	end
end

