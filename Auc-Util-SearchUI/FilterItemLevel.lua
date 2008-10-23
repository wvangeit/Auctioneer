--[[
	Auctioneer Advanced - Search UI - Filter IgnoreItemQuality
	Version: <%version%> (<%codename%>)
	Revision: $Id$
	URL: http://auctioneeraddon.com/

	This is a plugin module for the SearchUI that assists in searching by refined parameters

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
		You have an implicit license to use this AddOn with these facilities
		since that is its designated purpose as per:
		http://www.fsf.org/licensing/licenses/gpl-faq.html#InterpreterIncompat
--]]
-- Create a new instance of our lib with our parent
local lib, parent, private = AucSearchUI.NewFilter("ItemLevel")
if not lib then return end
local print,decode,_,_,replicate,empty,_,_,_,debugPrint,fill = AucAdvanced.GetModuleLocals()
local get,set,default,Const = AucSearchUI.GetSearchLocals()
lib.tabname = "ItemLevel"
-- Set our defaults
default("ignoreitemlevel.enable", false)

local typename

-- This function is automatically called when we need to create our search parameters
function lib:MakeGuiConfig(gui)
	if not typename then
		typename = {GetAuctionItemClasses()}
	end
	-- Get our tab and populate it with our controls
	local id = gui:AddTab(lib.tabname, "Filters")
	gui:MakeScrollable(id)

	-- Add the help
	gui:AddSearcher("Item Level", "Filter out items based on their level and type", 600)
	gui:AddHelp(id, "itemlevel filter",
		"What does this filter do?",
		"This filter provides the ability to filter out specific item types which are below a preset level threshold. It can selectively apply it's filters only for certain types of searches.")

	gui:AddControl(id, "Header",     0,      "ItemLevel Filter Criteria")

	gui:AddControl(id, "Checkbox",    0, 1,  "ignoreitemlevel.enable", "Enable ItemLevel filtering")
	gui:AddControl(id, "Subhead",     0, "Filter for:")
	for name, searcher in pairs(AucSearchUI.Searchers) do
		if searcher and searcher.Search then
			gui:AddControl(id, "Checkbox", 0, 1, "ignoreitemlevel.filter."..name, name)
			gui:AddTip(id, "Filter Time-left when searching with "..name)
			default("ignoreitemlevel.filter."..name, false)
		end
	end

-- Assume valid minimum item level is 0 and valid max item level is 300.
-- Configure slider controls to reflect this range of values.
-- See norganna.org JIRA ASER-106 and ASER-132 for additional info about this value range.
	gui:AddControl(id, "Subhead",     0,  "Minimum itemLevels by Type")
	for i = 1, #typename do
		default("ignoreitemlevel.minlevel."..typename[i], 61)
		gui:AddControl(id, "WideSlider",   0, 1, "ignoreitemlevel.minlevel."..typename[i], 0, 300, 1, "Min iLevel for "..typename[i]..": %s")
	end
end

--lib.Filter(item, searcher)
--This function will return true if the item is to be filtered
--Item is the itemtable, and searcher is the name of the searcher being called. If searcher is not given, it will assume you want it active.
function lib.Filter(item, searcher)
	if not typename then
		typename = {GetAuctionItemClasses()}
	end

	if (not get("ignoreitemlevel.enable"))
			or (searcher and (not get("ignoreitemlevel.filter."..searcher))) then
		return
	end

	local itype = item[Const.ITYPE]
	local ilevel = item[Const.ILEVEL]

	if ilevel < get("ignoreitemlevel.minlevel."..itype) then
		return true, "ItemLevel too low"
	end
end

AucAdvanced.RegisterRevision("$URL$", "$Rev$")
