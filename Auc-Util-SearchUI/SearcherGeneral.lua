--[[
	Auctioneer Advanced - Search UI - Searcher General
	Version: <%version%> (<%codename%>)
	Revision: $Id$
	URL: http://auctioneeraddon.com/

	This is a plugin module for the SearchUI that assists in searching by refined paramaters

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
		since that is its designated purpose as per:
		http://www.fsf.org/licensing/licenses/gpl-faq.html#InterpreterIncompat
--]]
-- Create a new instance of our lib with our parent
local lib, parent, private = AucSearchUI.NewSearcher("General")
if not lib then return end
local print,decode,recycle,acquire,clone,scrub, _, _, _, debugPrint = AucAdvanced.GetModuleLocals()
local get,set,default,Const = AucSearchUI.GetSearchLocals()
lib.tabname = "General parameters"
local typename = {
	[1] = "Any",
	[2] = "Armor",
	[3] = "Consumable",
	[4] = "Container",
	[5] = "Gem",
	[6] = "Key",
	[7] = "Miscellaneous",
	[8] = "Reagent",
	[9] = "Recipe",
	[10] = "Projectile",
	[11] = "Quest",
	[12] = "Quiver",
	[13] = "Trade Goods",
	[14] = "Weapon",
}

-- Set our defaults
default("general.name", "")
default("general.name.exact", false)
default("general.name.regexp", false)
default("general.ilevel.min", 0)
default("general.ilevel.max", 150)
default("general.ulevel.min", 0)
default("general.ulevel.max", 80)
default("general.type", 1)

-- This function is automatically called when we need to create our search parameters
function lib:MakeGuiConfig(gui)
	-- Get our tab and populate it with our controls
	id = gui:AddTab(lib.tabname, "Searches")

	gui:MakeScrollable(id)
	gui:AddControl(id, "Header",     0,      "General search criteria")

	local last = gui:GetLast(id)
	gui:SetControlWidth(0.35)
	gui:AddControl(id, "Text",       0,   1, "general.name", "Item name")
	local cont = gui:GetLast(id)
	gui:SetLast(id, last)
	gui:AddControl(id, "Checkbox",   0.11, 0, "general.name.exact", "Exact")
	gui:SetLast(id, last)
	gui:AddControl(id, "Checkbox",   0.21, 0, "general.name.regexp", "Regexp")
	gui:SetLast(id, last)
	gui:AddControl(id, "Checkbox",   0.35, 0, "general.name.invert", "Invert")
	
	gui:SetLast(id, last)
	gui:AddControl(id, "Note",       0.48, 1, 100, 14, "Type:")
	gui:AddControl(id, "Selectbox",   0.46, 1, typename, "general.type", "ItemType")
	
	gui:SetLast(id, cont)
	
	last = cont
	gui:SetControlWidth(0.37)
	gui:AddControl(id, "NumeriSlider",     0,   1, "general.ilevel.min", 0, 200, 1, "Min item level")
	gui:SetControlWidth(0.37)
	gui:AddControl(id, "NumeriSlider",     0,   1, "general.ilevel.max", 0, 200, 1, "Max item level")
	cont = gui:GetLast(id)

	gui:SetLast(id, last)
	gui:SetControlWidth(0.17)
	gui:AddControl(id, "NumeriSlider",     0.6, 0, "general.ulevel.min", 0, 80, 1, "Min user level")
	gui:SetControlWidth(0.17)
	gui:AddControl(id, "NumeriSlider",     0.6, 0, "general.ulevel.max", 0, 80, 1, "Max user level")

	gui:SetLast(id, cont)
end

function lib.Search(item)
	private.debug = ""
	if private.NameSearch(item[Const.NAME])
			and private.LevelSearch("ilevel", item[Const.ILEVEL])
			and private.LevelSearch("ulevel", item[Const.ULEVEL]) then
		return true
	else
		return false, private.debug
	end
end

function private.LevelSearch(levelType, itemLevel)
	local min = get("general."..levelType..".min")
	local max = get("general."..levelType..".max")

	if itemLevel < min then
		private.debug = levelType.." too low"
		return false
	end
	if itemLevel > max then
		private.debug = levelType.." too high"
		return false
	end
	return true
end

function private.NameSearch(itemName)
	local name = get("general.name")

	-- If there's no name, then this matches
	if not name or name == "" then
		return true
	end

	-- Lowercase the input
	name = name:lower()
	itemName = itemName:lower()

	-- Get the matching options
	local nameExact = get("general.name.exact")
	local nameRegexp = get("general.name.regexp")
	local nameInvert = get("general.name.invert")

	-- if we need to make a non-regexp, exact match:
	if nameExact and not nameRegexp then
		-- If the name matches or we are inverted
		if name == itemName and not nameInvert then
			return true
		elseif name ~= itemName and nameInvert then
			return true
		end
		private.debug = "Name is not exact match"
		return false
	end

	local plain, text
	text = name
	if not nameRegexp then
		plain = 1
	elseif nameExact then
		text = "^"..name.."$"
	end

	local matches = itemName:find(text, 1, plain)
	if matches and not nameInvert then
		return true
	elseif not matches and nameInvert then
		return true
	end
	private.debug = "Name does not match critia"
	return false
end

AucAdvanced.RegisterRevision("$URL$", "$Rev$")