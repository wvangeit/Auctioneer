--[[
	Auctioneer Advanced
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
		since that is its designated purpose as per:
		http://www.fsf.org/licensing/licenses/gpl-faq.html#InterpreterIncompat
]]
local lib = AucAdvanced

function lib.Print(...)
	local output, part
	for i=1, select("#", ...) do
		part = select(i, ...)
		part = tostring(part):gsub("{{", "|cffddeeff"):gsub("}}", "|r")
		if (output) then output = output .. " " .. part
		else output = part end
	end
	DEFAULT_CHAT_FRAME:AddMessage(output, 0.3, 0.9, 0.8)
end

function lib.DecodeLink(link)
	local vartype = type(link)
	if (vartype == "string") then
		local linkType = EnhTooltip.LinkType(link)
		if (linkType ~= "item") then return end
		local itemId, property,_,_,_,_,_,_,_,factor = EnhTooltip.BreakLink(link)
		return linkType, itemId, property, factor
	elseif (vartype == "number") then
		return "item", link, 0, 0
	end
	return
end

function lib.GetFaction() 
	local realmName = GetRealmName()
	local currentZone = GetMinimapZoneText()
	local factionGroup = UnitFactionGroup("player")
	
	if not AucAdvancedConfig.factions then AucAdvancedConfig.factions = {} end
	if AucAdvancedConfig.factions[currentZone] then
		factionGroup = AucAdvancedConfig.factions[currentZone]
	else
		SetMapToCurrentZone()
		local map = GetMapInfo()
		if ((map == "Taneris") or (map == "Winterspring") or (map == "Stranglethorn")) then
			factionGroup = "Neutral"
		end
	end

	if not factionGroup then return end

	AucAdvancedConfig.factions[currentZone] = factionGroup
	if (factionGroup == "Neutral") then
		AucAdvanced.cutRate = 0.15
		AucAdvanced.depositRate = 0.25
	else
		AucAdvanced.cutRate = 0.05
		AucAdvanced.depositRate = 0.05
	end
	AucAdvanced.curFaction = realmName.."-"..factionGroup
	return AucAdvanced.curFaction, realmName, factionGroup
end
