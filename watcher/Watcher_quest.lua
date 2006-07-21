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

Watcher.processQuestDetail = function(gossip)
	local unitDes, pos, now = Watcher.processNpcDetail()
	if (unitDes == "anonymous") then
		if (UnitName("npc") and (not UnitLevel("npc"))) then
			-- This is a doodad
			unitDes = "d:"..UnitName("npc")
		end
	end

	local aq = { GetGossipActiveQuests() }
	local vq = { GetGossipAvailableQuests() }

	local quests = {}
	if (aq) then for i = 1, table.getn(aq)/2 do table.insert(quests, string.format("[%d] %s", aq[i*2], aq[i*2-1])) end end
	if (vq) then for i = 1, table.getn(vq)/2 do table.insert(quests, string.format("[%d] %s", vq[i*2], vq[i*2-1])) end end
	if not gossip then 
		local title = GetTitleText()
		if (title and title ~= "") then table.insert(quests, "[?] "..title) end
	end

	local numQuests = table.getn(quests)
	if (numQuests == 0) then return end

	if (not Watcher_Config.quests) then Watcher_Config.quests = {} end
	
	local questee
	if (Watcher_Config.quests[unitDes]) then
		questee = Watcher_Config.quests[unitDes]
		if (now - questee.scantime < 50 and questee.count == numQuests) then
			-- No point scanning again.
			return
		end
	else
		-- Create a new quest
		Watcher_Config.quests[unitDes] = {}
		questee = Watcher_Config.quests[unitDes]
	end

	questee.scantime = now
	questee.pos = pos
	
	local done = 0
	local questDes
	for pos, quest in quests do
		questDes = quest
		if (questDes and questDes ~= "") then
			questee[questDes] = now
			Watcher.debug("Storing quest from "..unitDes..": "..questDes.." @ "..now)
			done = done + 1
		end
	end
	questee.count = done
end

Watcher.trackQuestCompletion = function()
	local unitDes, pos, now = Watcher.processNpcDetail()
	if (unitDes == "anonymous") then return end

	local questName = GetTitleText()
	if (not questName) then return end
	if (not Watcher_Config.questends) then Watcher_Config.questends = {} end
	if (not Watcher_Config.questends[unitDes]) then Watcher_Config.questends[unitDes] = {} end
	local questee = Watcher_Config.questends[unitDes]

	local now = Watcher.timeslice()
	local questDes = "[?] "..questName
	Watcher.debug("Completing quest from "..unitDes..": "..questDes.." @ "..now)
	questee[questDes] = now
	if (not Watcher.newlyCompleted) then Watcher.newlyCompleted = {} end
	Watcher.newlyCompleted[questName] = now
end

Watcher.trackNeededQuestItems = function()
	local now = Watcher.timeslice()
	local start = time()
	Watcher.debug("Tracking quest needed items")
	if (Watcher.questsUpdated and Watcher.timer <= Watcher.questsUpdated + 1) then
		Watcher.timers[Watcher.timer + 1] = "Watcher.trackNeededQuestItems()"
		return
	end
	Watcher.questsUpdated = Watcher.timer
	local player = Watcher.getPlayerDes()
	local numItems = GetNumQuestLogEntries()
	local expanded

	if (not Watcher.dirtyQuests) then Watcher.dirtyQuests = {} end
	if (not Watcher_Config.need) then Watcher_Config.need = {} end
	if (not Watcher_Config.need[player]) then Watcher_Config.need[player] = {} end
	if (not Watcher_Config.questitems) then Watcher_Config.questitems = {} end

	local dirty = Watcher.dirtyQuests
	for questItem, times in Watcher_Config.need do
		dirty[questItem] = true
	end

	local k,l, itemDes, questItem
	local numLdr, desc, itemname, count, total, ltype, done
	local title, level, tag, header, collapsed, complete
	for i = 1, numItems do
		title, level, tag, header, collapsed, complete = GetQuestLogTitle(i)
		if (header and collapsed) then
			Watcher.debug("Expanding header "..i)
			if (not expanded) then expanded = {} end
			table.insert(expanded, i)
			ExpandQuestHeader(i)
			numItems = GetNumQuestLogEntries()
		elseif (not header) then
			Watcher.debug("Processing line "..i)
			numLdr = GetNumQuestLeaderBoards(i)
			for j = 1, numLdr do
				desc, ltype, done = GetQuestLogLeaderBoard(j, i)
				if (ltype == "item") then
					k,l, itemname, count, total = string.find(desc, "^(.+): (%d+)/(%d+)")
					if (count) then
						count = tonumber(count)
						total = tonumber(total)
						questItem = string.format("%d;%d;%s;%s", level, total, title, itemname)
						if (not Watcher_Config.questitems[questItem]) and (count > 0) then
							-- We don't know this item's ID, but we do know that it's in our bags,
							-- and we know how many we have.
							itemDes = Watcher.findInBags(itemname, count)
							Watcher_Config.questitems[questItem] = itemDes
						end
						if (Watcher_Config.need[player][questItem]) then
							if (done) then
								if (not Watcher_Config.needed) then Watcher_Config.needed = {} end
								if (not Watcher_Config.needed[player]) then Watcher_Config.needed[player] = {} end
								Watcher.debug("Finished needing "..itemname.." for quest")
								if (Watcher_Config.needed[player][questItem]) then
									if (Watcher_Config.need[player][questItem]) then
										Watcher_Config.needed[player][questItem] = Watcher_Config.needed[player][questItem] .. ";" .. Watcher_Config.need[player][questItem] .."-"..now
									else
										Watcher_Config.needed[player][questItem] = Watcher_Config.needed[player][questItem] .. "-"..now
									end
								else
									Watcher_Config.needed[player][questItem] = Watcher_Config.need[player][questItem] .."-"..now
								end
								Watcher_Config.need[player][questItem] = nil
							end
						elseif (not done) then
							Watcher.debug("Needing "..itemname.." for quest")
							Watcher_Config.need[player][questItem] = now
							dirty[questItem] = nil
						end
					end
				end
			end
		end
	end

	if (expanded) then
		for i=table.getn(expanded), 1, -1 do
			Watcher.debug("Collapsing header "..expanded[i])
			CollapseQuestHeader(expanded[i])
		end
	end

	for questItem, is in dirty do
		-- When a quest gets scanned just as the quest is completing, the scoreboard
		-- reads 0 for all the items, and they will get "reneeded", so these need to
		-- be removed (with great prejudice) the very next time this routine is run.
		Watcher.debug("Deleting dirty quest: "..questItem)
		Watcher_Config.need[player][questItem] = nil
		dirty[questItem] = nil
	end
end

