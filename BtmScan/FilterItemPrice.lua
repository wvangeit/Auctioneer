--[[
	BottomScanner - An AddOn for WoW to alert you to good purchases as they appear on the AH
	Version: <%version%> (<%codename%>)
	Revision: $Id: FilterItemPrice.lua 2193 2007-10-08 18:00:0Z ironmind $
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

local libName = "IgnoreItemPrice"
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
--		BtmScan.Print(" not enabled for"..evaluationModule)
		return 
	end

--	BtmScan.Print(" got configured "..tostring(item.itemconfig.maxPrice).." bid:"..tostring(item.bid).." buy:"..tostring(item.buy))

	if item.itemconfig.maxPrice then
--		BtmScan.Print(" got configured "..item.itemconfig.maxPrice.." bid:"..tostring(item.bid).." buy:"..tostring(item.buy))
		if (item.canbid and item.bid >= item.itemconfig.maxPrice) then
--			BtmScan.Print(" got filter hit "..evaluationModule)
			filterModule=true
		elseif (item.canbuy and item.buy >= item.itemconfig.maxPrice) then
--			BtmScan.Print(" got filter hit "..evaluationModule)
			filterModule=true
		end

	end

	return filterModule
end

define(lcName..'.enable', false)


function lib:setup(gui)
	id = gui:AddTab(libName)
	gui:AddControl(id, "Subhead",          0,    libName.." Settings")
	gui:AddControl(id, "Checkbox",         0, 1, lcName..".enable", "Enable price-filtering")

	for pos, name in ipairs(BtmScan.evaluators) do
		if (name=="vendor") then
			define(lcName..".filter."..name, false)
		else
			define(lcName..".filter."..name, true)
		end
		gui:AddControl(id, "Checkbox",         0, 1, lcName..".filter."..name, "activate Filter for module:"..name)
	end
end

lib.IgnorePurchasePrice = function()
	local item = BtmScan.Prompt.item

	local price = item.purchase / item.count
	if (item.itemconfig.maxPrice==nil) or (price < item.itemconfig.maxPrice) then
		item.itemconfig.maxPrice = price
	end

	BtmScan.Print(BtmScan.Locales.Translate("BottomScanner will now %1 %2 for more than %3", BtmScan.Locales.Translate("permanently ignore"), item.link,price))
	BtmScan.scanStage = 2
	BtmScan.timer = 0
	BtmScan.pageScan = 0.001
	BtmScan.Prompt:Hide()
	BtmScan.storeItemConfig(item.itemconfig, item.sig)
end

-- hook to prompt-Window
BtmScan.Prompt.IgnorePrice = CreateFrame("Button", "", BtmScan.Prompt, "OptionsButtonTemplate")
BtmScan.Prompt.IgnorePrice:SetText(BtmScan.Locales.Translate("IgnorePrice"))
BtmScan.Prompt.IgnorePrice:SetPoint("BOTTOMLEFT", BtmScan.Prompt.lastbutton, "BOTTOMRIGHT", -5, 0)
BtmScan.Prompt.IgnorePrice:SetScript("OnClick", lib.IgnorePurchasePrice)
BtmScan.Prompt.lastbutton=BtmScan.Prompt.IgnorePrice
