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

Watcher.getTooltip = function(ttype, linenum, p1,p2,p3,p4,p5,p6,p7,p8)
	local scanlines = {}
	WatcherTooltip:SetOwner(WorldFrame,"ANCHOR_NONE");	
	WatcherTooltip[ttype](WatcherTooltip, p1,p2,p3,p4,p5,p6,p7,p8)
	local line
	for i=1, 20 do
		if (not linenum or linenum == i) then
			line = getglobal("WatcherTooltipTextLeft"..i)
			if line then
				if linenum then 
					local text = line:GetText()
					WatcherTooltip:Hide()
					return text
				end
				table.insert(scanLines, line:GetText())
			end
		end
	end
	WatcherTooltip:Hide()
	return scanlines
end


