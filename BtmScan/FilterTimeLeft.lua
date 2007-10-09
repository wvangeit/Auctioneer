--[[
	BottomScanner - An AddOn for WoW to alert you to good purchases as they appear on the AH
	Version: <%version%> (<%codename%>)
	Revision: $Id$
	URL: http://auctioneeraddon.com/dl/BottomScanner/
	Copyright (c) 2006, Norganna

	This is a module for BtmScan to filter an item for purchase.

	If you wish to make your own module, do the following:
	 -  Make a copy of the supplied "EvalFilterTemplate.lua" file.
	 -  Rename your copy to a name of your choosing.
	 -  Edit your copy to do your own valuations of the item.
	      (search for the "TODO" sections in the file)
	 -  Insert your new file's name into the "BtmScan.toc" file.
	 -  Optionally, put it up on the wiki at:
	      http://norganna.org/wiki/BottomScanner/Filters

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
]]

local libName = "IgnoreTimeLeft"
local lcName = libName:lower()
local lib = { name = lcName, propername = libName }
table.insert(BtmScan.filters, lcName)
local define = BtmScan.Settings.SetDefault
local get = BtmScan.Settings.GetSetting
local set = BtmScan.Settings.SetSetting
local translate = BtmScan.Locales.Translate

BtmScan.filters[lcName] = lib

function lib:filterItem(item, evaluationModule)
	local price = 0
	local filterModule=false

	-- If we're not enabled, scadaddle!
	if (not get(lcName..".enable")) then return end

	if (get(lcName..".filter."..evaluationModule)==false) then
		-- check not enabled for this eval-module
		return
	end

	local maxTimeLeft=get(lcName..".filter.timeleft")

	-- no config -> no check
	if (not maxTimeLeft) then return end

	-- no remain -> no check (called tooltip outside ah ...)
	if (not item.remain) then return end

	-- timeleft is higher than configured limit
	if (tonumber(item.remain)<tonumber(maxTimeLeft)) then return end

--	BtmScan.Print(" filtered timeleft "..item.remain..":"..maxTimeLeft..":"..item.sig)
	return true
end

lib.durations = {
	{ 1, "less than 30min" },
	{ 2, "2 hours" },
	{ 3, "8 hours" },
}

define(lcName..'.enable', false)
define(lcName..'.filter.timeleft', 1)

function lib:setup(gui)
	id = gui:AddTab(libName)
	gui:AddControl(id, "Subhead",          0,    libName.." Settings")
	gui:AddControl(id, "Checkbox",         0, 1, lcName..".enable", "Enable time-left-filtering")
	gui:AddControl(id, "Subhead",          0,    "filter if more than")
	gui:AddControl(id, "Selectbox",        0, 2, lib.durations, lcName..".filter.timeleft", "Max time left")

	for pos, name in ipairs(BtmScan.evaluators) do
		if (name=="vendor") then
			define(lcName..".filter."..name, false)
		else
			define(lcName..".filter."..name, true)
		end
		gui:AddControl(id, "Checkbox",         0, 1, lcName..".filter."..name, "activate Filter for module:"..name)
	end
end




