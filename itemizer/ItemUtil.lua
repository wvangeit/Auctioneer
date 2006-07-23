--[[
	Itemizer Addon for World of Warcraft(tm).
	Version: <%version%> (<%codename%>)
	Revision: $Id$

	Itemizer utility functions.
	Functions to maniuplate items links, strings, tables etc

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

local split
local buildLink
local pruneTable
local nilSafeTable
local getItemLinks
local itemCacheSize
local getItemHyperLinks

function getItemHyperLinks(str, basicLink)
	if (not str or (not type(str) == "string")) then return end
	local itemList = {};

	for itemID, enchant, randomProp, uniqID in string.gfind(str, "|Hitem:(%d+):(%d+):(%d+):(%d+)|h") do
		if (basicLink) then
			table.insert(itemList, "item:"..itemID..":0:0:0")
		else
			table.insert(itemList, "item:"..itemID..":"..enchant..":"..randomProp..":"..uniqID)
		end
	end
	return itemList;
end

--Many thanks to the guys at irc://irc.datavertex.com/cosmostesters for their help in creating this function
function getItemLinks(str)
	if (not str or (not type(str) == "string")) then return end
	local itemList = {};

	for color, itemLink, name in string.gfind(str, "|c(%x+)|Hitem:(%d+:%d+:%d+:%d+)|h%[(.-)%]|h|r") do
		table.insert(itemList, "|c"..color.."|Hitem:"..itemLink.."|h["..name.."]|h|r")
	end
	return itemList;
end

function buildLink(hyperlink, quality, name)

	if (type(hyperlink) == "number") then
		_, hyperlink = GetItemInfo(hyperlink)
	end

	if (not hyperlink) then
		return
	end

	if (not quality) then
		_, _, quality = GetItemInfo(hyperlink);
		quality = quality or 1
	end

	if (not name) then
		name = GetItemInfo(hyperlink) or "unknown";
	end

	local _, _, _, hex = GetItemQualityColor(tonumber(quality))

	return hex.. "|H"..hyperlink.."|h["..name.."]|h|r"
end

--Thanks to Esamynn for his help in modifying this function to work for "at" bigger than a single character.
function split(str, at)
	local splut = {};

	if (not type(str) == "string") then return end

	if (not at)
		then table.insert(splut, str)

	else
		str = str..at;
		at = string.gsub(at, "([%^%$%(%)%%%.%[%]%*%+%-%?])", "%%%1");
		for n in string.gfind(str, '([^'..at..']*)'..at) do
			table.insert(splut, n);
		end
	end
	return splut;
end
-- /dump Itemizer.Util.Split("Some§Random§String§to§split", "§")
-- /dump Itemizer.Util.Split("Some%Random%String%to%split", "%")

function itemCacheSize()
	debugprofilestart()

	local link
	local itemsFound = 0

	for index = 1, Itemizer.Core.Constants.ItemCacheScanCeiling do
		link = buildLink(index)
		if (link) then
			itemsFound = itemsFound + 1
		end
	end

	local totalTimeTaken = debugprofilestop()
	EnhTooltip.DebugPrint(
		"Itemizer: ItemCache entries scanned", Itemizer.Core.Constants.ItemCacheScanCeiling,
		"Number of Items found", itemsFound,
		"Time taken", totalTimeTaken,
		"Average time per found item", totalTimeTaken/itemsFound,
		"Average time per attempt", totalTimeTaken/Itemizer.Core.Constants.ItemCacheScanCeiling
	)

	return itemsFound
end

function nilSafeTable(tableToModify)
	for index = 1, table.getn(tableToModify) do
		if (tableToModify[index] == nil) then
			tableToModify[index] = 0
		end
	end
	return tableToModify
end

--Note: This function calls itself recursively until done.
function pruneTable(tableToPrune)
	if (type(tableToPrune) == "nil") then
		return nil;

	elseif (type(tableToPrune) ~= "table") then
		return tableToPrune;

	elseif (not next(tableToPrune)) then
		return nil;

	else
		for key, value in pairs(tableToPrune) do
			tableToPrune[key] = pruneTable(tableToPrune[key]);
		end
		return tableToPrune;
	end
end

Itemizer.Util = {
	Split = split,
	BuildLink = buildLink,
	PruneTable = pruneTable,
	NilSafeTable = nilSafeTable,
	GetItemLinks = getItemLinks,
	ItemCacheSize = itemCacheSize,
	GetItemHyperLinks = getItemHyperLinks,
}