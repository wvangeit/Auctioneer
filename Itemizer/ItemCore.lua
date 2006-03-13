--[[
	Itemizer Addon for World of Warcraft(tm).
	Version: <%version%> (<%codename%>)
	Revision: $Id$

	Itemizer core functions and variables.
	Functions central to the major operation of Itemizer.

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
]]

local registerEvents, onEvent, inspect, scanInventory, scanBank, variablesLoaded, processLinks, getItemLinks, inspectTargets, addLinkToProcessStack

if (not inspectTargets) then
	inspectTargets = {};
end

local eventsToRegister = {
	--General Events
	"ADDON_LOADED",
	"UPDATE_MOUSEOVER_UNIT",
	"PLAYER_TARGET_CHANGED",
	"BANKFRAME_OPENED",
	"UNIT_INVENTORY_CHANGED",
	"MERCHANT_SHOW",
	"PLAYER_LEAVING_WORLD",
	"PLAYER_ENTERING_WORLD",

	--Chat Events
	"CHAT_MSG_SYSTEM",
	"CHAT_MSG_SAY",
	"CHAT_MSG_TEXT_EMOTE",
	"CHAT_MSG_YELL",
	"CHAT_MSG_WHISPER",
	"CHAT_MSG_PARTY",
	"CHAT_MSG_GUILD",
	"CHAT_MSG_OFFICER",
	"CHAT_MSG_CHANNEL",
	"CHAT_MSG_RAID",
	"CHAT_MSG_LOOT",
}
local processEvents = true

local bankSlots = {
	BANK_CONTAINER, 5, 6, 7, 8, 9, 10
}

function registerEvents()
	for index, event in pairs(eventsToRegister) do
		ItemizerFrame:RegisterEvent(event)
	end
end

function onEvent(event)
	EnhTooltip.DebugPrint("Itemizer: OnEvent called", event);

	--Do not process events when zoning
	if ((not processEvents) or (not event == "PLAYER_ENTERING_WORLD")) then
		return
	end

	if (event == "UPDATE_MOUSEOVER_UNIT") then
		if (UnitIsPlayer("mouseover") and (UnitFactionGroup("mouseover") == Itemizer.Core.Constants.PlayerFaction)) then
			debugprofilestart()
			inspect("mouseover");
		end

	elseif (event == "PLAYER_TARGET_CHANGED") then
		if (UnitIsPlayer("target") and (not UnitIsUnit("target", "player"))) then
			inspect("target");
		end

	elseif (event == "UNIT_INVENTORY_CHANGED" and arg1 == "player") then
		debugprofilestart()
		scanInventory(arg1);
		inspect("player");

	elseif (event == "BANKFRAME_OPENED") then
		scanBank();

	elseif (event == "ADDON_LOADED") then
		variablesLoaded();

	elseif (event == "MERCHANT_SHOW") then

	elseif (event == "PLAYER_LEAVING_WORLD") then
		processEvents = false;

	elseif (event == "PLAYER_ENTERING_WORLD") then
		processEvents = true;

	else
		debugprofilestart()
		processLinks(arg1);
	end
end

function processLinks(str, fromAPI)
	local items

	if (fromAPI) then
		items = {str};

	else
		items = Itemizer.Util.GetItemLinks(str);
		if (table.getn(items) > 0) then
			EnhTooltip.DebugPrint("Itemizer: Found Item(s) in chat, number of items", table.getn(items), "Time taken", debugprofilestop());
		end
	end

	if (items) then
		for index, link in pairs(items) do

			--This debug call increases inspect time 20 fold, if the debugging frame is visible.
			--EnhTooltip.DebugPrint("Itemizer: Found Item", link);
			addLinkToProcessStack(link)
		end
	end
end

function inspect(unit)
	local name = UnitName(unit)
	local curTime = time()
	if ((not inspectTargets[name]) or (curTime - inspectTargets[name] > 120)) then
		EnhTooltip.DebugPrint("Itemizer: Inspecting Player", name);
		inspectTargets[name] = curTime
		local currentItem
		local numItems = 0

		for slot = 0, 19 do
			currentItem = GetInventoryItemLink(unit, slot)
			if (currentItem) then
				numItems = numItems + 1
				processLinks(currentItem, true)
			end
		end
	EnhTooltip.DebugPrint("Itemizer: Finished inspecting player", name, "Number of Items", numItems, "Time taken", debugprofilestop());
	end
end

function variablesLoaded()

end

function scanInventory()
	local currentItem
	for bag = 0, 4 do
		for slot = 1, GetContainerNumSlots(bag) do
			currentItem = GetContainerItemLink(bag, slot)
			if (currentItem) then
				processLinks(currentItem, true)
			end
		end
	end
end

function scanBank()
	local currentItem
	for index, bag in pairs(bankSlots) do
		for slot = 1, GetContainerNumSlots(bag) do
			currentItem = GetContainerItemLink(bag, slot)
			if (currentItem) then
				processLinks(currentItem, true)
			end
		end
	end
end

function addLinkToProcessStack(link)
	table.insert(ItemizerProcessStack, link)
end

Itemizer.Core = {
	Constants = {},
	RegisterEvents = registerEvents,
	OnEvent = onEvent,
	ProcessLinks = processLinks,
}
Itemizer.Core.Constants = {
	PlayerFaction = UnitFactionGroup("player"),
	EventsToRegister = eventsToRegister,
	BankSlots = bankSlots,
}