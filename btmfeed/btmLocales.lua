--[[
	BottomFeeder
	Revision: $Id$
	Version: <%version%> (<%codename%>)

	This is an addon for World of Warcraft that allows searching and analysis
	of the auction contents for specific good buys. When it identifies something
	that is a "good buy" according to the rules you set, it can either place a
	bid or buyout the item.

	Please note that this addon is not intended for unattended usage. Any such
	usage of this addon is against the tennants set forth in the World of Warcraft
	Terms of Use and End User Licence Agreement, and will get your account banned.

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

-- Stub for future localization function
BtmFeed.Locales.GetLocalization = function (l) return l end
BtmFeed.Locales.Translate = function ( localization, ... )
	localization = BtmFeed.Locales.GetLocalization(localization)
	local newloc = ""

	local n = arg.n;
	for i = 1, n do
		local s, b, e
		s = 1 b = 1
		while (b > 0) do
			b,e = string.find(localization, "%"..i, s, true)
			if (b and b > 0) then
				local argv = arg[i] or ""
				if (type(argv) == "table") then argv = "TABLE" end
				newloc = newloc .. string.sub(localization, s, b-1) .. argv;
				s = e + 1
			else
				b = 0
			end
		end
		newloc = newloc .. string.sub(localization, s)
		localization = newloc newloc = ""
	end
	return localization
end

