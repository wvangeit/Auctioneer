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

Watcher.fvnHash = function(value)
	local chr

	local top = 4294967296 
	local tff = 16777619 
	local hash = 2166136261

	local len = string.len(value)
	for i=1, len do
		chr = string.byte(value,i)
		hash = hash * tff
		pre = hash
		hash = bit.mod(hash, top)
		hash = bit.bxor(hash, chr)
	end
	--hash = bit.mod(hash, 4294967296);
	return hash
end

Watcher.getGroupHash = function()
	if (not Watcher.groupMembers) then Watcher.groupMembers = {} end
	local group = Watcher.groupMembers
	while (table.getn(group)>0) do table.remove(group) end
	
	local raid = GetNumRaidMembers()
	local party = GetNumPartyMembers()
	local count = 1
	local name = UnitName("player")
	if (raid > 0) then
		count = raid
		for i=1, raid do
			name = UnitName("raid"..i)
			table.insert(group, name)
		end
	elseif (party > 0) then
		count = party
		table.insert(group, name)
		for i=1, party do
			name = UnitName("party"..i)
			table.insert(group, name)
		end
	else
		return count
	end

	table.sort(group)
	local groupstr = table.concat(group, ":")
	local grouphash = Watcher.fvnHash(groupstr)
	return bit.lshift(grouphash, 7) + count
end

