--[[
	BottomScanner - An AddOn for WoW to alert you to good purchases as they appear on the AH
	Version: <%version%> (<%codename%>)
	Revision: $Id$
	URL: http://auctioneeraddon.com/dl/BottomScanner/
	Copyright (c) 2006, Norganna

	This is a module for BtmScan to evaluate an item for purchase.

	If you wish to make your own module, do the following:
	 -  Make a copy of the supplied "EvalTemplate.lua" file.
	 -  Rename your copy to a name of your choosing.
	 -  Edit your copy to do your own valuations of the item.
	      (search for the "TODO" sections in the file)
	 -  Insert your new file's name into the "BtmScan.toc" file.
	 -  Optionally, put it up on the wiki at:
	      http://norganna.org/wiki/BottomScanner/Evaluators

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

-- If auctioneer is not loaded, then we cannot run.
if not (AucAdvanced or (Auctioneer and Auctioneer.Statistic)) then return end

local libName = "Snatch"
local lcName = libName:lower()
local lib = { name = lcName, propername = libName }
table.insert(BtmScan.evaluators, lcName)
local define = BtmScan.Settings.SetDefault
local get = BtmScan.Settings.GetSetting
local set = BtmScan.Settings.SetSetting
local translate = BtmScan.Locales.Translate

BtmScan.evaluators[lcName] = lib

function lib:valuate(item, tooltip)
	local price = 0

	-- If we're not enabled, scadaddle!
	if (not get(lcName..".enable")) then return end

	if ((not item.itemconfig.buyBelow) or item.itemconfig.buyBelow==0) then return end

	local value = item.itemconfig.buyBelow * item.count

	-- If the current purchase price is more than our valuation,
	-- another module "wins" this purchase.
	if (value < item.purchase) then return end

	-- Check to see what the most we can pay for this item is.
	if (item.canbuy and get(lcName..".allow.buy") and item.buy < value) then
		price = item.buy
	elseif (item.canbid and get(lcName..".allow.bid") and item.bid < value) then
		price = item.bid
	end

	item.purchase = price
	item.reason = self.name
	item.what = self.name
	item.profit = value-price
	item.valuation = value
end

function lib.PrintHelp()
	BtmScan.Print("/btm snatch maxPrice item ")
end

function lib.CommandHandler(msg)
	BtmScan.Print("called snatch-handler"..msg)
	local i,j, ocmd, oparam = string.find(msg, "^([^ ]+) (.*)$")
	local i,j, cmd, param = string.find(string.lower(msg), "^([^ ]+) (.*)$")
	if (not i) then cmd = msg param = nil oparam = nil end
	if (oparam == "") then param = nil oparam = nil end


	if (oparam) then
		local des, count, price, itemid,itemrand,itemlink, remain = BtmScan.ItemDes(oparam)
		if (not des) then
			BtmScan.Print(translate("Unable to understand command. Please see /btm help"))
			return
		end

		local itemid, itemsuffix, itemenchant, itemseed = BtmScan.BreakLink(itemlink)
		local itemsig = (":"):join(itemid, itemsuffix, itemenchant)
		local itemconfig = BtmScan.getItemConfig(itemsig)


		if (price <= 0) then
			price = BtmScan.ParseGSC(remain) or 0
		end

		if (price <= 0) then
			BtmScan.Print(translate("BottomScanner will now %1 %2", translate("not snatch"), itemlink))
			return
		end

		local _,_,_,_,_,_,_,stack = GetItemInfo(itemid)
		if (not stack) then
			stack = 1
		end

		local stackText = ""
		if (stack > 1) then
			stackText = " ("..translate("%1 per %2 stack", BtmScan.GSC(price*stack, 1), stack)..")"
		end
		local countText =""
		if (count > 0) then
			countText = translate("up to %1", count).." "
		else
			countText = translate("unlimited").." "
		end

		BtmScan.Print(translate("BottomScanner will now %1 %2", translate("snatch"), countText..translate("%1 at %2", itemlink, translate("%1 per unit", BtmScan.GSC(price, 1)))..stackText))
		itemconfig.buyBelow=price
		BtmScan.storeItemConfig(itemconfig, itemsig)
	end

end


define(lcName..'.enable', true)
define(lcName..'.allow.bid', true)
define(lcName..'.allow.buy', true)
function lib:setup(gui)
	id = gui:AddTab(libName)
	gui:AddControl(id, "Subhead",          0,    libName.." Settings")
	gui:AddControl(id, "Checkbox",         0, 1, lcName..".enable", "Enable purchasing for "..lcName)
	gui:AddControl(id, "Checkbox",         0, 2, lcName..".allow.buy", "Allow buyout on items")
	gui:AddControl(id, "Checkbox",         0, 2, lcName..".allow.bid", "Allow bid on items")
end

