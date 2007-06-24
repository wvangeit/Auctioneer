--[[	Auctioneer Advanced
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


--[[
	See CoreAPI.lua for a description of the modules API
]]

if (not AucAdvanced) then AucAdvanced = {} end
if (not AucAdvancedData) then AucAdvancedData = {} end
if (not AucAdvancedLocal) then AucAdvancedLocal = {} end
if (not AucAdvancedConfig) then AucAdvancedConfig = {} end

AucAdvanced.Version="<%version%>";
if (AucAdvanced.Version == "<".."%version%>") then
	AucAdvanced.Version = "5.0.DEV";
end

local private = {}

-- For our modular stats system, each stats engine should add their
-- subclass to AucAdvanced.Modules.<type>.<name> and store their data into their own
-- data table in AucAdvancedData.Stats.<type><name>
if (not AucAdvanced.Modules) then AucAdvanced.Modules = {Stat={},Scan={},Util={}} end
if (not AucAdvancedData.Stats) then AucAdvancedData.Stats = {} end
if (not AucAdvancedLocal.Stats) then AucAdvancedLocal.Stats = {} end

function private.TooltipHook(vars, ret, frame, name, hyperlink, quality, quantity, cost, additional)
	if EnhTooltip.LinkType(hyperlink) ~= "item" then
		return -- Auctioneer hooks into item tooltips only
	end

	for system, systemMods in pairs(AucAdvanced.Modules) do
		for engine, engineLib in pairs(systemMods) do
			if (engineLib.Processor) then engineLib.Processor("tooltip", frame, name, hyperlink, quality, quantity, cost, additional) end
		end
	end
end

function private.HookAH()
	hooksecurefunc("AuctionFrameBrowse_Update", AucAdvanced.API.ListUpdate)
	for system, systemMods in pairs(AucAdvanced.Modules) do
		for engine, engineLib in pairs(systemMods) do
			if (engineLib.Processor) then
				engineLib.Processor("auctionui")
			end
		end
	end
end

function private.OnLoad(addon)
	if (addon:lower() == "auc-advanced") then
		Stubby.RegisterAddOnHook("Blizzard_AuctionUi", "Auc-Advanced", private.HookAH)
		Stubby.RegisterFunctionHook("EnhTooltip.AddTooltip", 600, private.TooltipHook)
		for pos, module in ipairs(AucAdvanced.EmbeddedModules) do
			-- These embedded modules have also just been loaded
			private.OnLoad(module)
		end
	end
	local auc, sys, eng = strsplit("-", addon:lower())
	if (auc ~= "auc" or not sys or not eng) then return end
	
	for system, systemMods in pairs(AucAdvanced.Modules) do
		if (sys == system:lower()) then
			for engine, engineLib in pairs(systemMods) do
				if (eng == engine:lower() and engineLib.OnLoad) then
					engineLib.OnLoad()
				end
				if (engineLib.Processor) then
					engineLib.Processor("load", addon)
				end
			end
		end
	end
end

function private.OnEvent(...)
	local event, arg = select(2, ...)
	if (event == "ADDON_LOADED") then
		local addon = string.lower(arg)
		if (addon:sub(1,4) == "auc-") then
			private.OnLoad(addon)
		end
	elseif (event == "AUCTION_HOUSE_SHOW") then
		-- Do Nothing for now
	elseif (event == "AUCTION_HOUSE_CLOSED") then
		AucAdvanced.Scan.Cancel()
	end
end

private.Frame = CreateFrame("Frame")
private.Frame:RegisterEvent("ADDON_LOADED")
private.Frame:RegisterEvent("AUCTION_HOUSE_SHOW")
private.Frame:RegisterEvent("AUCTION_HOUSE_CLOSED")
private.Frame:SetScript("OnEvent", private.OnEvent)

-- Auctioneer's debug functions
AucAdvanced.Debug = {}
local addonName = "Auctioneer" -- the addon's name as it will be displayed in
                               -- the debug messages
-------------------------------------------------------------------------------
-- Prints the specified message to nLog.
--
-- syntax:
--    errorCode, message = debugPrint([message][, category][, title][, errorCode][, level])
--
-- parameters:
--    message   - (string) the error message
--                nil, no error message specified
--    category  - (string) the category of the debug message
--                nil, no category specified
--    title     - (string) the title for the debug message
--                nil, no title specified
--    errorCode - (number) the error code
--                nil, no error code specified
--    level     - (string) nLog message level
--                         Any nLog.levels string is valid.
--                nil, no level specified
--
-- returns:
--    errorCode - (number) errorCode, if one is specified
--                nil, otherwise
--    message   - (string) message, if one is specified
--                nil, otherwise
-------------------------------------------------------------------------------
function AucAdvanced.Debug.DebugPrint(message, category, title, errorCode, level)
	return DebugLib.DebugPrint(addonName, message, category, title, errorCode, level)
end

-------------------------------------------------------------------------------
-- Used to make sure that conditions are met within functions.
-- If test is false, the error message will be written to nLog and the user's
-- default chat channel.
--
-- syntax:
--    assertion = assert(test, message)
--
-- parameters:
--    test    - (any)     false/nil, if the assertion failed
--                        anything else, otherwise
--    message - (string)  the message which will be output to the user
--
-- returns:
--    assertion - (boolean) true, if the test passed
--                          false, otherwise
-------------------------------------------------------------------------------
function AucAdvanced.Debug.Assert(test, message)
	return DebugLib.Assert(addonName, test, message)
end