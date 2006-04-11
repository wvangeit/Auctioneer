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

local getItemHyperLinks, getItemLinks, buildLink, split, pruneTable

function getItemHyperLinks(str, basicLink)
	if (not str or (not type(str) == "string")) then return end
	local itemList = {};

	for itemID, enchant, randomProp, uniqID in string.gfind(str, "|Hitem:(%d+):(%d+):(%d+):(%d+)|h") do
		if (basicLink) then
			table.insert(itemList, "item:"..itemID..":0:"..randomProp..":0")
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
	-- make this function nilSafe, as it's a global one and might be used by external addons
	if (not hyperlink) then
		return
	end

	if (type(hyperlink) == "number") then
		_, hyperlink = GetItemInfo(hyperlink)
	end

	if (not quality) then 
		_,_, quality = GetItemInfo(hyperlink);
		quality = quality or 1
	end

	if (not name) then 
		name = GetItemInfo(hyperlink) or "unknown";
	end

	local _, _, _, hex = GetItemQualityColor(tonumber(quality))

	return hex.. "|H"..hyperlink.."|h["..name.."]|h|r"
end

function split(str, at)
	local splut = {};

	if (type(str) ~= "string") then return nil end
	if (not str) then str = "" end

	if (not at)
		then table.insert(splut, str)

	else
		for n, c in string.gfind(str, '([^%'..at..']*)(%'..at..'?)') do
			table.insert(splut, n);

			if (c == '') then break end
		end
	end
	return splut;
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
	GetItemHyperLinks = getItemHyperLinks,
	GetItemLinks = getItemLinks,
	BuildLink = buildLink,
	Split = split,
	PruneTable = pruneTable,
}