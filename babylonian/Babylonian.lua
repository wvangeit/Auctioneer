--[[
	Babylonian
	A sub-addon that manages the locales for other addons.
	<%version%> (<%codename%>)
	$Id$

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

local self = {}
self.update = {}
--Local function prototypes
local split, setOrder, getOrder, fetchString, getString, registerAddOn

--Function Imports
local tinsert = table.insert

function split(str, at)
	if (not (type(str) == "string")) then
		return
	end

	if (not str) then
		str = ""
	end

	if (not at) then
		return {str}

	else
		return {strsplit(at, str)};
	end
end

function setOrder(order)
	if (not order) then
		self.order = {}
	else
		self.order = split(order, ",")
	end

	tinsert(self.order, GetLocale())
	tinsert(self.order, "enUS")

	return SetCVar("BabylonianOrder", order)
end

function getOrder()
	return GetCVar("BabylonianOrder")
end

function fetchString(stringTable, locale, stringKey)
	if ((type(stringTable) == "table") and (type(stringTable[locale]) == "table") and (stringTable[locale][stringKey])) then
		return stringTable[locale][stringKey]
	end
end

function getString(stringTable, stringKey, default)
	local val
	for i = 1, #self.order do
		val = fetchString(stringTable, self.order[i], stringKey)
		if (val) then
			return val
		end
	end
	return default
end

if (not Babylonian) then
	Babylonian = {
		SetOrder = setOrder,
		GetOrder = getOrder,
		GetString = getString,
		FetchString = fetchString,
	}
	RegisterCVar("BabylonianOrder", "")
	setOrder(getOrder())
end
