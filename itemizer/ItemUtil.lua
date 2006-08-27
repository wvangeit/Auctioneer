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
local hashText
local chatPrint
local buildLink
local clearTable
local pruneTable
local nilSafeTable
local getItemLinks
local stringToTable
local nilSafeString
local nilSafeNumber
local itemCacheSize
local getglobalIterator
local getItemHyperLinks

--Making a local copy of these extensively used functions will make their calling faster.
local type = type;
local next = next;
local pairs = pairs;
local mod = math.mod;
local getn = table.getn;
local tonumber = tonumber;
local tostring = tostring;
local strlen = string.len;
local strsub = string.sub;
local strgsub = string.gsub;
local strbyte = string.byte;
local strfind = string.find;
local format = string.format;
local tinsert = table.insert;
local strgfind = string.gfind;

function getItemHyperLinks(str, basicLink)
	if (not str or (not (type(str) == "string"))) then return end
	local itemList = {};

	for itemID, enchant, randomProp, uniqID in strgfind(str, "|Hitem:(%d+):(%d+):(%d+):(%d+)|h") do
		if (basicLink) then
			tinsert(itemList, "item:"..itemID..":0:0:0")
		else
			tinsert(itemList, "item:"..itemID..":"..enchant..":"..randomProp..":"..uniqID)
		end
	end
	return itemList;
end

--Many thanks to the guys at irc://irc.datavertex.com/cosmostesters for their help in creating this function
function getItemLinks(str)
	if (not str or (not (type(str) == "string"))) then return end
	local itemList = {};

	for color, itemLink, name in strgfind(str, "|c(%x+)|Hitem:(%d+:%d+:%d+:%d+)|h%[(.-)%]|h|r") do
		tinsert(itemList, "|c"..color.."|Hitem:"..itemLink.."|h["..name.."]|h|r")
	end
	return itemList;
end

function buildLink(hyperlink, quality, name)
	local _, hex

	if (type(hyperlink) == "number") then
		_, hyperlink = GetItemInfo(hyperlink)
	end

	if (not hyperlink) then
		return
	end

	if (not quality) then
		_, _, quality = GetItemInfo(hyperlink);
		quality = quality or -1
	end

	if (not name) then
		name = GetItemInfo(hyperlink) or "unknown";
	end

	_, _, _, hex = GetItemQualityColor(tonumber(quality))

	return hex.. "|H"..hyperlink.."|h["..name.."]|h|r"
end
--[[
-- Thanks to Esamynn for his help in modifying this function to work for "at" bigger than a single character.
-- This function fails with the following text case, so it was replaced with the one below.
-- /dump Itemizer.Util.Split("attackPower¶26§meleeHit¶1§meleeCrit¶1", "§")
function split(str, at)
	if (not (type(str) == "string")) then return end
	local splut = {};

	if (not (at or strfind(str, at))) then
		tinsert(splut, str)

	else
		str = str..at;
		at = strgsub(at, "([%^%$%(%)%%%.%[%]%*%+%-%?])", "%%%1");
		for n in strgfind(str, '([^'..at..']*)'..at) do
			tinsert(splut, n);
		end
	end
	return splut;
end
]]

--Thanks to PeterPrade from http://lua-users.org/ for this function.
function split(str, at)
	str = tostring(str)

	if ((type(at) == "string") and (at == "")) then -- Empty string as the delimiter would result in an infinite loop.
		return
	end

	local pos = 1
	local splut = {}

	if (not (at and strfind(str, at))) then
		tinsert(splut, str)

	else
		while (true) do
			local first, last = strfind(str, at, pos)

			if (first) then -- found?
				tinsert(splut, strsub(str, pos, first - 1))
				pos = last + 1

			else
				tinsert(splut, strsub(str, pos))
				break
			end
		end
	end
	return splut
end

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

function nilSafeString(str)
	return str or ""
end

function nilSafeNumber(number)
	return tonumber(number) or 0
end

function nilSafeTable(tableToModify)
	for index = 1, getn(tableToModify) do
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

--Note: This function calls itself recursively until done.
function clearTable(tableToClear)
	if (not (type(tableToClear) == "table")) then
		return tableToClear
	end

	for key, value in pairs(tableToClear) do
		if (type(value) == "table") then
			tableToClear[key] = clearTable(value)
		else
			tableToClear[key] = nil
		end
	end

	table.setn(tableToClear, 0)
	return tableToClear
end

-- Iterate over numbered global objects
function getglobalIterator(fmt, first, last)
	local i = tonumber(first) or 1
	return function()
		if last and (i > last) then
			return
		end
		local obj = getglobal(format(fmt, i))
		i = i + 1
		return obj, i - 1
	end
end

function delimitText(text, delimiter, spacing)
	text = tostring(text)
	spacing = tonumber(spacing)
	delimiter = tostring(delimiter)

	if ((not text) or (not delimiter) or (not spacing)) then
		return text
	end

	if (strlen(text) <= spacing) then
		return text
	end

	local subText = ""
	local finalText = ""

	while strlen(text) > 0 do
		subText = strsub(text, -spacing)
		if (strlen(text) - spacing) < 0 then
			text = ""
		else
			text = strsub(text, 1, strlen(text) - spacing)
		end

		if (strlen(subText) < spacing) then
			finalText = subText..finalText
		else
			finalText = delimiter..subText..finalText
		end
	end

	return finalText
end

function stringToTable(stringToConvert, fieldsDelimiter, keyValueDelimiter) --%TODO% This function uses tables rather extensively, prime candidate for optimization.
	if (not (type(stringToConvert) == "string")) then
		return
	end

	fieldsDelimiter = tostring(fieldsDelimiter)

	if (not (strfind(stringToConvert, fieldsDelimiter))) then
		return
	end

	local builtTable = {}

	for mainKey, mainValue in ipairs(split(stringToConvert, fieldsDelimiter)) do
		local splitTable = split(mainValue, keyValueDelimiter)
		if (splitTable[2]) then
			builtTable[splitTable[1]] = tonumber(splitTable[2]) or splitTable[2]
		else
			tinsert(builtTable, tonumber(splitTable[1]) or splitTable[1])
		end
	end

	return builtTable
end
-- /dump Itemizer.Util.StringToTable("attackPower¶26§meleeHit¶3§meleeCrit¶1", "§", "¶")
-- /dump Itemizer.Util.StringToTable("Priest¶Shaman¶Mage¶Warlock¶Druid", "¶")

function chatPrint(text, cRed, cGreen, cBlue, cAlpha, holdTime)
	--local frameIndex = Itemizer.Command.GetFrameIndex();
	local frameIndex = 1 --%Todo% Change this by implementing the above function
	local chatFrame = getglobal("ChatFrame"..frameIndex)

	if (cRed and cGreen and cBlue) then
		if (chatFrame) then
			chatFrame:AddMessage(text, cRed, cGreen, cBlue, cAlpha, holdTime);

		elseif (DEFAULT_CHAT_FRAME) then
			DEFAULT_CHAT_FRAME:AddMessage(text, cRed, cGreen, cBlue, cAlpha, holdTime);
		end

	else
		if (chatFrame) then
			chatFrame:AddMessage(text, 0.1, 0.1, 1.0);

		elseif (DEFAULT_CHAT_FRAME) then
			DEFAULT_CHAT_FRAME:AddMessage(text, 0.1, 0.1, 1.0);
		end
	end
end

--Thanks to Mikk and the AceComm guys for creating this function.
function hashText(str)
	str = tostring(str)

	local counter = 1
	for i=1, strlen(str), 3 do
		counter = (
			(mod(counter * 8257, 4294967279)) +
			(strbyte(str,i) * 81) +
			((strbyte(str,i+1) or 1) * 4368) +
			((strbyte(str,i+2) or 2) * 34828)
		)
	end
	return format("%08x", mod(counter, 4294967291))
end

Itemizer.Util = {
	Split = split,
	HashText = hashText,
	chatPrint = chatPrint,
	BuildLink = buildLink,
	ClearTable = clearTable,
	PruneTable = pruneTable,
	DelimitText = delimitText,
	NilSafeTable = nilSafeTable,
	GetItemLinks = getItemLinks,
	StringToTable = stringToTable,
	NilSafeString = nilSafeString,
	NilSafeNumber = nilSafeNumber,
	ItemCacheSize = itemCacheSize,
	GetglobalIterator = getglobalIterator,
	GetItemHyperLinks = getItemHyperLinks,
}