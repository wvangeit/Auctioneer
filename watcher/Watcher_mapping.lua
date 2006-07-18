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

Watcher.zonemap = {
	["Kalimdor"] = 1,
	["Ashenvale"] = 2,
	["Aszhara"] = 3,
	["Darkshore"] = 4,
	["Darnassis"] = 5,
	["Desolace"] = 6,
	["Durotar"] = 7,
	["Dustwallow"] = 8,
	["Felwood"] = 9,
	["Feralas"] = 10,
	["Moonglade"] = 11,
	["Mulgore"] = 12,
	["Ogrimmar"] = 13,
	["Silithus"] = 14,
	["StonetalonMountains"] = 15,
	["Tanaris"] = 16,
	["Teldrassil"] = 17,
	["Barrens"] = 18,
	["ThousandNeedles"] = 19,
	["ThunderBluff"] = 20,
	["UngoroCrater"] = 21,
	["Winterspring"] = 22,
	["Azeroth"] = 33,
	["Alterac"] = 34,
	["Arathi"] = 35,
	["Badlands"] = 36,
	["BlastedLands"] = 37,
	["BurningSteppes"] = 38,
	["DeadwindPass"] = 39,
	["DunMorogh"] = 40,
	["Duskwood"] = 41,
	["EasternPlaguelands"] = 42,
	["Elwynn"] = 43,
	["Hilsbrad"] = 44,
	["Ironforge"] = 45,
	["LochModan"] = 46,
	["Redridge"] = 47,
	["SearingGorge"] = 48,
	["Silverpine"] = 49,
	["Stormwind"] = 50,
	["Stranglethorn"] = 51,
	["SwampOfSorrows"] = 52,
	["Hinterlands"] = 53,
	["Tirisfal"] = 54,
	["Undercity"] = 55,
	["WesternPlaguelands"] = 56,
	["Westfall"] = 57,
	["Wetlands"] = 58,
}

Watcher.getCurrentZone = function()
	SetMapToCurrentZone()
	local currentZone = GetMapInfo()
	if (not currentZone) then return end
	local univZone = Watcher.zonemap[currentZone]
	if (not univZone) then
		if (not Watcher_Config.addzones) then Watcher_Config.addzones = { last = 65 } end
		if (Watcher_Config.addzones[currentZone]) then
			univZone = Watcher_Config.addzones[currentZone]
		else
			univZone = Watcher_Config.addzones.last + 1
			Watcher_Config.addzones.last = univZone
			Watcher_Config.addzones[currentZone] = Watcher_Config.addzones.last
		end
	end

	return univZone
end

Watcher.getCurrentPos = function()
	local univZone = Watcher.getCurrentZone()
	if (not univZone) then return 0, 0, 0,0 end
	local px, py = GetPlayerMapPosition("player")
	px = math.floor(px * 250)
	py = math.floor(py * 250)
	return bit.lshift(univZone, 16) + bit.lshift(px, 8) + py, univZone, px,py
end

