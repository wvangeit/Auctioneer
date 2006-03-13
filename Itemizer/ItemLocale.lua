--[[
	Auctioneer Addon for World of Warcraft(tm).
	Version: <%version%> (<%codename%>)
	Revision: $Id$

	AucLocale
	Functions for localizing Informant

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

local Itemizer_CustomLocalizations = {
}

function _ITEM(stringKey, locale)
	if (locale) then
		if (type(locale) == "string") then
			return Babylonian.FetchString(ItemizerLocalizations, locale, stringKey);
		else
			return Babylonian.FetchString(ItemizerLocalizations, GetLocale(), stringKey);
		end
	elseif (Itemizer_CustomLocalizations[stringKey]) then
		return Babylonian.FetchString(ItemizerLocalizations, Itemizer_CustomLocalizations[stringKey], stringKey)
	else
		local str = Babylonian.GetString(ItemizerLocalizations, stringKey)
		if (not str) then return stringKey end
		return str
	end
end

