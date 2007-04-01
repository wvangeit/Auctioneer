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

if (not AucAdvanced) then AucAdvanced = {} end
if (not AucAdvancedData) then AucAdvancedData = {} end
if (not AucAdvancedLocal) then AucAdvancedLocal = {} end
if (not AucAdvancedConfig) then AucAdvancedConfig = {} end

AucAdvanced.Version="<%version%>";
if (AucAdvanced.Version == "<".."%version%>") then
	AucAdvanced.Version = "5.0.DEV";
end

-- For our modular stats system, each stats engine should add their
-- subclass to AucAdvanced.Modules.<type>.<name> and store their data into their own
-- data table in AucAdvancedData.Stats.<type><name>
if (not AucAdvanced.Modules) then AucAdvanced.Modules = {Stat={},Scan={},Util={}} end
if (not AucAdvancedData.Stats) then AucAdvancedData.Stats = {} end
if (not AucAdvancedLocal.Stats) then AucAdvancedLocal.Stats = {} end

function AucAdvanced.Print(...)
	local output, part
	for i=1, select("#", ...) do
		part = select(i, ...)
		part = tostring(part):gsub("{{", "|cffddeeff"):gsub("}}", "|r")
		if (output) then output = output .. " " .. part
		else output = part end
	end
	DEFAULT_CHAT_FRAME:AddMessage(output, 0.3, 0.9, 0.8)
end

function AucAdvanced.DecodeLink(link)
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

function AucAdvanced.GetFaction()
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
	return AucAdvanced.curFaction
end


function AucAdvanced.TooltipHook(vars, ret, ...)
	for system, systemMods in pairs(AucAdvanced.Modules) do
		for engine, engineLib in pairs(systemMods) do
			if (engineLib.Processor) then engineLib.Processor("tooltip", ...) end
		end
	end
end

function AucAdvanced.OnLoad(addon)
	if (addon == "auc-advanced") then
		AucAdvanced.LoadEmbedded()
		Stubby.RegisterFunctionHook("EnhTooltip.AddTooltip", 600, AucAdvanced.TooltipHook)
	end
	local _, sys, eng = strsplit("-", addon)

	for system, systemMods in pairs(AucAdvanced.Modules) do
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

function AucAdvanced.LoadEmbedded()
	for index, addon in ipairs(AucAdvanced.EmbeddedModules) do
		AucAdvanced.OnLoad(addon:lower())
	end
end

function AucAdvanced.OnEvent(...)
	local event, arg = select(2, ...)
	if (event == "ADDON_LOADED") then
		local addon = string.lower(arg)
		if (addon:sub(1,4) == "auc-") then
			AucAdvanced.OnLoad(addon)
		end
	end
end

AucAdvanced.Frame = CreateFrame("Frame")
AucAdvanced.Frame:RegisterEvent("ADDON_LOADED")
AucAdvanced.Frame:SetScript("OnEvent", AucAdvanced.OnEvent)

