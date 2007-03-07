--[[
	Auctioneer
	Revision: $Id$
	Version: <%version%> (<%codename%>)

	This is an addon for World of Warcraft that adds statistical history to the auction data that is collected
	when the auction is scanned, so that you can easily determine what price
	you will be able to sell an item for at auction or at a vendor whenever you
	mouse-over an item in the game

	License:
		This program is free software; you can redistribute it and/or
		modify it under the terms of the GNU General Public License
		as published by the Free Software Foundation; either version 2
		of the License, or (at your option) any later version.

		This program is distributed in the hope that it will be useful,
		but WITHOUT ANY WARRANTY; without even the implied warranty of
		MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
		GNU General Public License for more details.

		You should have received a copy of the GNU General Public License
		along with this program(see GPL.txt); if not, write to the Free Software
		Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

	Note:
		This AddOn's source code is specifically designed to work with
		World of Warcraft's interpreted AddOn system.
		You have an implicit licence to use this AddOn with these facilities
		since that is it's designated purpose as per:
		http://www.fsf.org/licensing/licenses/gpl-faq.html#InterpreterIncompat
--]]

if (not Auctioneer) then Auctioneer = {} end
if (not AuctioneerData) then AuctioneerData = {} end
if (not AuctioneerLocal) then AuctioneerLocal = {} end
if (not AuctioneerConfig) then AuctioneerConfig = {} end

-- For our modular stats system, each stats engine should add their
-- subclass to Auctioneer.Modules.<name> and store their data into their own
-- data table in AuctioneerData.Stats.<name>
if (not Auctioneer.Modules) then Auctioneer.Modules = {Stat={},Scan={},Util={}} end
if (not AuctioneerData.Stats) then AuctioneerData.Stats = {} end
if (not AuctioneerLocal.Stats) then AuctioneerLocal.Stats = {} end

function Auctioneer.Print(...)
	local output, part
	for i=1, select("#", ...) do
		part = select(i, ...)
		part = tostring(part):gsub("{{", "|cffddeeff"):gsub("}}", "|r")
		if (output) then output = output .. " " .. part
		else output = part end
	end
	DEFAULT_CHAT_FRAME:AddMessage(output, 0.3, 0.9, 0.8)
end

function Auctioneer.GetFaction() 
	local realmName = GetRealmName()
	local currentZone = GetMinimapZoneText()
	local factionGroup = UnitFactionGroup("player")
	
	if not AuctioneerConfig.factions then AuctioneerConfig.factions = {} end
	if AuctioneerConfig.factions[currentZone] then
		factionGroup = AuctioneerConfig.factions[currentZone]
	else
		SetMapToCurrentZone()
		local map = GetMapInfo()
		if ((map == "Taneris") or (map == "Winterspring") or (map == "Stranglethorn")) then
			factionGroup = "Neutral"
		end
	end

	if not factionGroup then return end

	AuctioneerConfig.factions[currentZone] = factionGroup
	if (factionGroup == "Neutral") then
		Auctioneer.cutRate = 0.15
		Auctioneer.depositRate = 0.25
	else
		Auctioneer.cutRate = 0.05
		Auctioneer.depositRate = 0.05
	end
	Auctioneer.curFaction = realmName.."-"..factionGroup
	return Auctioneer.curFaction
end


function Auctioneer.TooltipHook(vars, ret, ...)
	for system, systemMods in pairs(Auctioneer.Modules) do
		for engine, engineLib in pairs(systemMods) do
			if (engineLib.Processor) then engineLib.Processor("tooltip", ...) end
		end
	end
end

function Auctioneer.OnLoad(addon)
	if (addon == "auctioneer") then
		Stubby.RegisterFunctionHook("EnhTooltip.AddTooltip", 600, Auctioneer.TooltipHook)
	end
	local _, sys, eng = strsplit("-", addon)
	
	for system, systemMods in pairs(Auctioneer.Modules) do
		for engine, engineLib in pairs(systemMods) do
			if (sys and eng and sys == system:lower() and eng == engine:lower() and engineLib.OnLoad) then
				engineLib.OnLoad()
			end
			if (engineLib.Processor) then
				engineLib.Processor("load", addon)
			end
		end
	end
end

function Auctioneer.OnEvent(...)
	local event, arg = select(2, ...)
	if (event == "ADDON_LOADED") then
		local addon = string.lower(arg)
		if (addon == "auctioneer" or addon:sub(1,4) == "auc-") then
			Auctioneer.OnLoad(addon)
		end
	end
end

Auctioneer.Frame = CreateFrame("Frame")
Auctioneer.Frame:RegisterEvent("ADDON_LOADED")
Auctioneer.Frame:SetScript("OnEvent", Auctioneer.OnEvent)

