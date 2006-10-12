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

local inspect
local onEvent
local scanBank
local getItemLinks
local processLinks
local scanMerchant
local scanItemCache
local scanInventory
local registerEvents
local variablesLoaded
local addLinkToProcessStack

--Saved Variables
ItemizerSets = {};
ItemizerLinks = {};
ItemizerConfig = {};

--Global Variables
ItemizerProcessStack = {};

--Making a local copy of these extensively used functions will make their lookup faster.
local getItemVersion
local strfind = string.find

local inspectTargets = {};

local _, gameBuildNumberString = GetBuildInfo()
gameBuildNumber = tonumber(gameBuildNumberString)

local announceNewItems = true; --We want to know about newly discovered items.
local itemCacheScanCeiling = 30000; --At the time of writing, the item with the highest ItemID is "Undercity Pledge Collection" with an ItemID of 22300 (thanks to zeeg for the info [http://www.wowguru.com/db/items/id22300/]), so a ceiling of 30,000 is more than reasonable IMHO.

local eventsToRegister = {
	--General Events
	"ADDON_LOADED",
	"MERCHANT_SHOW",
	"BANKFRAME_OPENED",
	"PLAYER_TARGET_CHANGED",
	"UPDATE_MOUSEOVER_UNIT",
	"UNIT_INVENTORY_CHANGED",

	--Chat Events
	"CHAT_MSG_SAY",
	"CHAT_MSG_RAID",
	"CHAT_MSG_YELL",
	"CHAT_MSG_LOOT",
	"CHAT_MSG_GUILD",
	"CHAT_MSG_PARTY",
	"CHAT_MSG_SYSTEM",
	"CHAT_MSG_OFFICER",
	"CHAT_MSG_WHISPER",
	"CHAT_MSG_CHANNEL",
	"CHAT_MSG_TEXT_EMOTE",
	"CHAT_MSG_RAID_LEADER",
}

local bankSlots = {
	BANK_CONTAINER, 5, 6, 7, 8, 9, 10
}

function registerEvents()
	for index, event in ipairs(eventsToRegister) do
		Itemizer.Frames.MainFrame:RegisterEvent(event);
	end
end

function onEvent()
	debugprofilestart();
	if (event == "UPDATE_MOUSEOVER_UNIT") then
		if (
			(UnitIsPlayer("mouseover")) and
			(UnitFactionGroup("mouseover") == Itemizer.Core.Constants.PlayerFaction) and
			(CheckInteractDistance("mouseover", 1))
		) then
			inspect("mouseover");
		end

	elseif (event == "PLAYER_TARGET_CHANGED") then
		if (
			(UnitIsPlayer("target")) and
			(not UnitIsUnit("target", "player")) and
			(UnitFactionGroup("target") == Itemizer.Core.Constants.PlayerFaction) and
			(CheckInteractDistance("target", 1))
		) then
			inspect("target");
		end

	elseif (strfind(event, "CHAT_MSG")) then
		processLinks(arg1);

	elseif (event == "UNIT_INVENTORY_CHANGED") then
		if (arg1 == "player") then
			scanInventory(arg1);
			inspect(arg1);

		else
			inspect(arg1);
		end

	elseif (event == "BANKFRAME_OPENED") then
		scanBank();

	elseif (event == "MERCHANT_SHOW") then
		scanMerchant();

	elseif (event == "ADDON_LOADED" and string.lower(arg1) == "itemizer") then
		variablesLoaded();
	end
end

function processLinks(str, fromAPI)
	local items

	if (fromAPI) then
		items = { str };

	else
		items = Itemizer.Util.GetItemLinks(str);
		if (table.getn(items) > 0) then
			EnhTooltip.DebugPrint(
				"Itemizer: Found Item(s) in chat, number of items", table.getn(items),
				"Time taken", string.format("%.3fms", debugprofilestop())
			);
		end
	end

	if (items) then
		for index, itemLink in pairs(items) do
			--Only add items to the processing stack that have not been previously parsed on this version of the game.
			local itemID, randomProp = Itemizer.Util.BreakLink(itemLink);

			local itemBuildNumber, itemIsCurrent, randomPropInItem = getItemVersion(itemID, randomProp);
			local randomPropOK

			if (not randomProp) then
				randomPropOK = true;
			else
				randomPropOK = randomPropInItem;
			end

			if (not (itemBuildNumber and itemIsCurrent and randomPropOK)) then
				addLinkToProcessStack(itemLink);
			end
		end
	end
end

function inspect(unit)
	local name = UnitName(unit);
	local curTime = time();

	if ((not inspectTargets[name]) or (curTime - inspectTargets[name] > 30)) then
		EnhTooltip.DebugPrint("Itemizer: Inspecting Player", name);
		inspectTargets[name] = curTime;
		local currentItem;
		local numItems = 0;

		for slot = 0, 19 do
			currentItem = GetInventoryItemLink(unit, slot);

			if (currentItem) then
				numItems = numItems + 1;
				processLinks(currentItem, true);
			end
		end

	EnhTooltip.DebugPrint(
		"Itemizer: Finished inspecting player", name,
		"Number of Items", numItems,
		"Time taken", string.format("%.3f", debugprofilestop())
	);
	end
end

function variablesLoaded()
	getItemVersion = Itemizer.Storage.GetItemVersion;
	EnhTooltip.DebugPrint("Itemizer: ItemCache Size", Itemizer.Util.ItemCacheSize());
end

function scanMerchant()
	for index = 1, GetMerchantNumItems() do
		processLinks(GetMerchantItemLink(index), true);
	end

	EnhTooltip.DebugPrint(
		"Itemizer: Finished scanning merchant",
		"Number of Items", GetMerchantNumItems(),
		"Time taken", string.format("%.3fms", debugprofilestop())
	);
end

function scanItemCache()
	debugprofilestart();

	local itemLink;
	local itemsFound = 0;
	local buildLink = Itemizer.Util.BuildLink;
	Itemizer.Core.IsItemCacheScanInProgress = true;

	for index = 1, Itemizer.Core.Constants.ItemCacheScanCeiling do
		itemLink = buildLink(index);

		if (itemLink) then
			if (itemsFound > 20) then
				announceNewItems = false;
			end
			processLinks(itemLink, true);
			itemsFound = itemsFound + 1;
		end
	end

	announceNewItems = true;

	local totalTimeTaken = debugprofilestop();
	EnhTooltip.DebugPrint(
		"Itemizer: ScanItemCache() ItemCache entries scanned", Itemizer.Core.Constants.ItemCacheScanCeiling,
		"Number of Items found", itemsFound,
		"Time taken", string.format("%.3fms", totalTimeTaken),
		"Average time per found item", string.format("%.3fms", totalTimeTaken/itemsFound),
		"Average time per attempt", string.format("%.3fms", totalTimeTaken/Itemizer.Core.Constants.ItemCacheScanCeiling)
	)
end

function scanInventory()
	local currentItem
	for bag = 0, 4 do
		for slot = 1, GetContainerNumSlots(bag) do
			currentItem = GetContainerItemLink(bag, slot);
			if (currentItem) then
				processLinks(currentItem, true);
			end
		end
	end
end

function scanBank()
	local currentItem
	for index, bag in pairs(bankSlots) do
		for slot = 1, GetContainerNumSlots(bag) do
			currentItem = GetContainerItemLink(bag, slot);
			if (currentItem) then
				processLinks(currentItem, true);
			end
		end
	end
end

function addLinkToProcessStack(itemLink)
	if (not ItemizerProcessStack[itemLink]) then
		if (announceNewItems) then
			EnhTooltip.DebugPrint("Itemizer: New itemLink!", itemLink);
		end

		ItemizerProcessStack[itemLink] = { timer = GetTime(), lines = 0 };
	end
end

Itemizer.Core = {
	Constants = {},
	Inspect = inspect,
	OnEvent = onEvent,
	ScanBank = scanBank,
	ProcessLinks = processLinks,
	ScanInventory = scanInventory,
	ScanMerchant = scanMerchant,
	RegisterEvents = registerEvents,
	ScanItemCache = scanItemCache,
	VariablesLoaded = variablesLoaded,
	AddLinkToProcessStack = addLinkToProcessStack,
	IsItemCacheScanInProgress = true, --Initially set to true so that we force a full rebuild of the GUI's itemList on first show.
}

Itemizer.Core.Constants = {
	BankSlots = bankSlots,
	GameBuildNumber = gameBuildNumber,
	EventsToRegister = eventsToRegister,
	PlayerFaction = UnitFactionGroup("player"),
	ItemCacheScanCeiling = itemCacheScanCeiling,
	GameBuildNumberString = gameBuildNumberString,
}
