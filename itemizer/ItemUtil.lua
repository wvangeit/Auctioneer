--[[
	Itemizer Addon for World of Warcraft(tm).
	Version: <%version%> (<%codename%>)
	Revision: $Id$

	Itemizer utility functions.
	Functions to maniuplate itemLinks, strings, tables etc

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
]]

local split
local nilTable
local nilZeros
local hashText
local chatPrint
local buildLink
local breakLink
local clearTable
local pruneTable
local nilSafeTable
local getItemLinks
local stringToTable
local nilSafeString
local nilSafeNumber
local itemCacheSize
local rotateTexture
local nilEmptyString
local binaryTableInsert
local getglobalIterator
local getItemHyperLinks

--Making a local copy of these extensively used functions will make their lookup faster.
local type = type;
local next = next;
local pairs = pairs;
local mod = math.mod;
local setn = table.setn;
local getn = table.getn;
local floor = math.floor;
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

function getItemHyperLinks(str, basicLink, noTable)
	if (not str or (not (type(str) == "string"))) then return end

	if (noTable) then
		for itemID, enchant, randomProp, uniqID in strgfind(str, "|Hitem:(%d+):(%d+):(%d+):(%d+)|h") do

			if (basicLink) then
				return "item:"..itemID..":0:0:0";

			else
				return "item:"..itemID..":"..enchant..":"..randomProp..":"..uniqID;
			end
		end
		--[[
		local _, _, itemID, enchant, randomProp, uniqID strfind(str, "Hitem:(%d+):(%d+):(%d+):(%d+)") --Bug here in the runtime.

		if (basicLink) then
			return "item:"..itemID..":0:0:0";

		else
			return "item:"..itemID..":"..enchant..":"..randomProp..":"..uniqID;
		end
		]]
	else
		local itemList = {};

		for itemID, enchant, randomProp, uniqID in strgfind(str, "|Hitem:(%d+):(%d+):(%d+):(%d+)|h") do

			if (basicLink) then
				tinsert(itemList, "item:"..itemID..":0:0:0");

			else
				tinsert(itemList, "item:"..itemID..":"..enchant..":"..randomProp..":"..uniqID);
			end
		end
		return itemList;
	end
end

--Many thanks to the guys at irc://irc.datavertex.com/cosmostesters for their help in creating this function
function getItemLinks(str)
	if (not str or (not (type(str) == "string"))) then return end
	local itemList = {};

	for color, itemHyperLink, name in strgfind(str, "|c(%x+)|Hitem:(%d+:%d+:%d+:%d+)|h%[(.-)%]|h|r") do
		tinsert(itemList, "|c"..color.."|Hitem:"..itemHyperLink.."|h["..name.."]|h|r");
	end
	return itemList;
end

function buildLink(hyperLink, quality, name)
	local _, hex

	if (type(hyperLink) == "number") then
		_, hyperLink = GetItemInfo(hyperLink);
	end

	if (not hyperLink) then
		return;
	end

	if (not quality) then
		_, _, quality = GetItemInfo(hyperLink);
		quality = quality or -1;
	end

	if (not name) then
		name = GetItemInfo(hyperLink) or "unknown";
	end

	_, _, _, hex = GetItemQualityColor(tonumber(quality));

	return hex.. "|H"..hyperLink.."|h["..name.."]|h|r";
end

-- Given a Blizzard itemLink, it breaks it into it's itemID, randomProperty, enchantProperty, uniqueness and name. Note that this function does not return the numbers in order.
function breakLink(itemLink)
	if (not (type(itemLink) == "string")) then
		return
	end

	local _, _, itemID, enchant, randomProp, uniqID, name = string.find(itemLink, "|Hitem:(%d+):(%d+):(%d+):(%d+)|h[[]([^]]+)[]]|h")
	return nilZeros(tonumber(itemID)), nilZeros(tonumber(randomProp)), nilZeros(tonumber(enchant)), nilZeros(tonumber(uniqID)), name
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
	str = tostring(str);

	if ((type(at) == "string") and (at == "")) then -- Empty string as the delimiter would result in an infinite loop.
		return;
	end

	local pos = 1;
	local splut = {};

	if (not (at and strfind(str, at))) then
		tinsert(splut, str);

	else
		while (true) do
			local first, last = strfind(str, at, pos, true); --True as the fourth argument here turns off string.find's pattern matching facilities making it faster.

			if (first) then -- found?
				tinsert(splut, strsub(str, pos, first - 1));
				pos = last + 1;

			else
				tinsert(splut, strsub(str, pos));
				break;
			end
		end
	end
	return splut;
end

function itemCacheSize()
	debugprofilestart();

	local itemLink
	local itemsFound = 0;

	for index = 1, Itemizer.Core.Constants.ItemCacheScanCeiling do
		itemLink = buildLink(index)
		if (itemLink) then
			itemsFound = itemsFound + 1;
		end
	end

	local totalTimeTaken = debugprofilestop();
	EnhTooltip.DebugPrint(
		"Itemizer: ItemCache entries scanned", Itemizer.Core.Constants.ItemCacheScanCeiling,
		"Number of Items found", itemsFound,
		"Time taken", format("%.3fms", totalTimeTaken),
		"Average time per found item", format("%.3fms", totalTimeTaken/itemsFound),
		"Average time per attempt", format("%.3fms", totalTimeTaken/Itemizer.Core.Constants.ItemCacheScanCeiling)
	);

	return itemsFound;
end

function nilSafeString(str)
	return str or "";
end

function nilEmptyString(str)
	if (str == "") then
		return nil;
	else
		return str;
	end
end

function nilZeros(number)
	if (number == 0) then
		return nil;
	else
		return number;
	end
end

function nilSafeNumber(number)
	return tonumber(number) or 0;
end

function nilSafeTable(tableToModify)
	for index = 1, getn(tableToModify) do
		if (tableToModify[index] == nil) then
			tableToModify[index] = 0;
		end
	end
	return tableToModify;
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
		return tableToClear;
	end

	for key, value in pairs(tableToClear) do
		if (type(value) == "table") then
			tableToClear[key] = clearTable(value);
		else
			tableToClear[key] = nil;
			key = nil;
		end
	end

	setn(tableToClear, 0);
	return tableToClear;
end

function nilTable(tableToNil)
	if (not (type(tableToNil) == "table")) then
		return tableToNil;
	end

	for key in pairs(tableToNil) do
		tableToNil[key] = nil;
		key = nil;
	end

	setn(tableToNil, 0);
	return tableToNil;
end

--[[
	This function, whose original name is "table.binsert" was taken from the lua-users.org Wiki (http://lua-users.org/wiki/TableExtension) its original description follows

	table.binsert( table, value [, comp] )

	LUA 5.x ADD-On for the table library
	Inserts a given value through BinaryInsert into the table sorted by [,comp]
	If comp is given, then it must be a function that receives two table elements,
	and returns true when the first is less than the second or reverse
	e.g.  comp = function( a, b ) return a > b end , will give a sorted table, with the biggest value on position 1
	[, comp] behaves as in table.sort( table, value [, comp] )

	This method is faster than a regular table.insert( table, value ) and a table.sort( table [, comp] )

	This code was tested, and it is faster than a normal insert and a sort, but it is slower than inserting 1000 items at a time and then sort them afterwards.
]]
--[[
function binaryTableInsert(tableToModify, value, compareFunction)
	if (not (type(tableToModify) == "table")) then
		return;
	end
	EnhTooltip.DebugPrint("Itemizer: binaryTableInsert called");
	local startTime = GetTime()

	-- Initialise Compare function
	compareFunction = compareFunction or function(a,b) return a < b end;

	--  Initialise Numbers
	local startIndex, endIndex, middleIndex, insertSide =  1, getn(tableToModify), 1, 0;

	-- Get Insertposition
	while startIndex <= endIndex do

		-- calculate middle
		iMid = floor((startIndex + endIndex) / 2);

		-- compare
		if compareFunction(value, tableToModify[middleIndex]) then
			endIndex = middleIndex - 1;
			insertSide = 0;
		else
			startIndex = middleIndex + 1;
			insertSide = 1;
		end

		if ((GetTime() - startTime) > 5) then
			EnhTooltip.DebugPrint("|cffffffffItemizer: binaryTableInsert function took too ling to complete|r");
			return
		end
	end

	return tinsert(tableToModify, ( middleIndex + insertSide ), value);
end
 ]]
function binaryTableInsert( t, value, fcomp )
	EnhTooltip.DebugPrint("Itemizer: binaryTableInsert called");
	local startTime = GetTime()
	-- Initialise Compare function
	fcomp = fcomp or function( a, b ) return a < b end

	--  Initialise Numbers
	local iStart, iEnd, iMid, iState =  1, table.getn( t ), 1, 0

	-- Get Insertposition
	while iStart <= iEnd do

		-- calculate middle
		iMid = math.floor( ( iStart + iEnd )/2 )

		-- compare
		if fcomp( value , t[iMid] ) then
			iEnd = iMid - 1
			iState = 0
		else
			iStart = iMid + 1
			iState = 1
		end

		if ((GetTime() - startTime) > 5) then
			EnhTooltip.DebugPrint("|cffffffffItemizer: binaryTableInsert function took too ling to complete|r", value);
			return
		end
	end

	table.insert( t, ( iMid+iState ), value )
end

-- Iterate over numbered global objects
function getglobalIterator(fmt, first, last)
	local i = tonumber(first) or 1;
	return function()
		if ((last) and (i > last)) then
			return;
		end
		local obj = getglobal(format(fmt, i));
		i = i + 1;
		return obj, i - 1;
	end
end

function delimitText(text, delimiter, spacing)
	text = tostring(text);
	spacing = tonumber(spacing);
	delimiter = tostring(delimiter);

	if (not (text and delimiter and spacing)) then
		return text;
	end

	if (strlen(text) <= spacing) then
		return text;
	end

	local subText = "";
	local finalText = "";

	while strlen(text) > 0 do
		subText = strsub(text, -spacing);
		if (strlen(text) - spacing) < 0 then
			text = "";
		else
			text = strsub(text, 1, strlen(text) - spacing);
		end

		if (strlen(subText) < spacing) then
			finalText = subText..finalText;
		else
			finalText = delimiter..subText..finalText;
		end
	end

	return finalText;
end

function stringToTable(stringToConvert, fieldsDelimiter, keyValueDelimiter) --%TODO% This function uses tables rather extensively, prime candidate for optimization.
	local builtTable = {};

	if (not (type(stringToConvert) == "string")) then
		return builtTable;
	end

	fieldsDelimiter = tostring(fieldsDelimiter);

	if (not (strfind(stringToConvert, fieldsDelimiter))) then
		return builtTable;
	end

	for mainKey, mainValue in ipairs(split(stringToConvert, fieldsDelimiter)) do
		local splitTable = split(mainValue, keyValueDelimiter);
		if (splitTable[2]) then
			builtTable[splitTable[1]] = tonumber(splitTable[2]) or splitTable[2];
		else
			tinsert(builtTable, tonumber(splitTable[1]) or splitTable[1]);
		end
	end

	return builtTable;
end
-- /dump Itemizer.Util.StringToTable("attackPower¶26§meleeHit¶3§meleeCrit¶1", "§", "¶")
-- /dump Itemizer.Util.StringToTable("Priest¶Shaman¶Mage¶Warlock¶Druid", "¶")

function chatPrint(text, cRed, cGreen, cBlue, cAlpha, holdTime)
	--local frameIndex = Itemizer.Command.GetFrameIndex();
	local frameIndex = 1; --%Todo% Change this by implementing the above function
	local chatFrame = getglobal("ChatFrame"..frameIndex);

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

--Thanks to Mikk for creating this function. (http://www.wowwiki.com/StringHash) & (http://www.wowwiki.com/StringHash/Analysis)
function hashText(str)
	str = tostring(str);

	local counter = 1;
	local len = strlen(str);

	for i=1, len, 3 do
		counter = (
			(mod(counter * 8161, (2^32 - 17))) +	-- 2^32 - 17 (4,294,967,279): Prime! (counter*8161 is at most a 48-bit number, which easily fits in the 52-bit mantissa of a double precision float)
			(strbyte(str, i) * 16776193) +
			((strbyte(str, i + 1) or (len - i + 256)) * 8372226) +
			((strbyte(str, i + 2) or (len - i + 256)) * 3932164)
		);
	end
	return format("%08x", mod(counter, (2^32 - 5))); -- 2^32 - 5 (4,294,967,291): Prime! (and different from the prime in the loop)
end

function rotateTexture(texture, degrees)
	local angle = math.rad(degrees);
	local cos, sin = math.cos(angle), math.sin(angle);

	texture:SetTexCoord((sin - cos) , -(cos + sin), -cos, -sin, sin, -cos, 0, 0);
end

Itemizer.Util = {
	Split = split,
	NilTable = nilTable,
	NilZeros = nilZeros,
	HashText = hashText,
	ChatPrint = chatPrint,
	BuildLink = buildLink,
	BreakLink = breakLink,
	ClearTable = clearTable,
	PruneTable = pruneTable,
	DelimitText = delimitText,
	NilSafeTable = nilSafeTable,
	GetItemLinks = getItemLinks,
	StringToTable = stringToTable,
	NilSafeString = nilSafeString,
	NilSafeNumber = nilSafeNumber,
	ItemCacheSize = itemCacheSize,
	RotateTexture = rotateTexture,
	NilEmptyString = nilEmptyString,
	GetglobalIterator = getglobalIterator,
	BinaryTableInsert = binaryTableInsert,
	GetItemHyperLinks = getItemHyperLinks,
}
