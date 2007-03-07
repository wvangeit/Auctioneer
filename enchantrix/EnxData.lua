--[[

	Enchantrix v<%version%> (<%codename%>)
	$Id$

	By Norganna
	http://enchantrix.org/

	This is an addon for World of Warcraft that add a list of what an item
	disenchants into to the items that you mouse-over in the game.

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
Enchantrix_RegisterRevision("$URL$", "$Rev$")

if Enchantrix.Data then return end

Enchantrix.Data = {}
local data = Enchantrix.Data
local dataStore = {}

local function deepCopy(source, dest)
	for k, v in pairs(source) do
		if (type(v) == "table") then
			if not (type(dest[k]) == "table") then
				dest[k] = {}
			end
			deepCopy(v, dest[k])
		else
			dest[k] = v
		end
	end
end

function data.SetDisenchantData(list)
	if (dataStore.disenchant) then return end
	dataStore.disenchant = list
end
function data.GetDisenchantData(key)
	local source = dataStore.disenchant[key]
	return source or ""
end


