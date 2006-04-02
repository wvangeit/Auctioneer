--[[
	Enchantrix Addon for World of Warcraft(tm).
	Version: <%version%> (<%codename%>)
	Revision: $Id$

	Localization routines
	
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
		along with this program(see GLP.txt); if not, write to the Free Software
		Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
]]

Enchantrix_CustomLocalizations = {
	['TextGeneral'] = GetLocale(),
	['TextCombat'] = GetLocale(),
	['ArgSpellname'] = GetLocale(),
	['PatReagents'] = GetLocale(),
}

function _ENCH(stringKey, locale)
	if (locale) then
		if (type(locale) == "string") then
			return Babylonian.FetchString(EnchantrixLocalizations, locale, stringKey);
		else
			return Babylonian.FetchString(EnchantrixLocalizations, GetLocale(), stringKey);
		end
	elseif (Enchantrix_CustomLocalizations[stringKey]) then
		return Babylonian.FetchString(EnchantrixLocalizations, Enchantrix_CustomLocalizations[stringKey], stringKey)
	else
		return Babylonian.GetString(EnchantrixLocalizations, stringKey)
	end
end

