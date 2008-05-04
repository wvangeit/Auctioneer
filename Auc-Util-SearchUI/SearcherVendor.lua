--[[
	Auctioneer Advanced - Search UI - Searcher Vendor
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
local lib, parent, private = AucSearchUI.NewSearcher("Vendor")
if not lib then return end
local print,decode,recycle,acquire,clone,scrub = AucAdvanced.GetModuleLocals()
local get,set,default,Const = AucSearchUI.GetSearchLocals()
lib.tabname = "Vendor"
-- Set our defaults
default("vendor.profit.min", 1)
default("vendor.profit.pct", 50)
default("vendor.allow.bid", true)
default("vendor.allow.buy", true)

-- This function is automatically called when we need to create our search parameters
function lib:MakeGuiConfig(gui)
	-- Get our tab and populate it with our controls
	local id = gui:AddTab(lib.tabname, "Searches")

	gui:AddControl(id, "Header",     0,      "Vendor search criteria")

	local last = gui:GetLast(id)
	
	gui:AddControl(id, "MoneyFramePinned",  0, 1, "vendor.profit.min", 1, 99999999, "Minimum Profit")
	gui:AddControl(id, "Slider",            0, 1, "vendor.profit.pct", 1, 100, .5, "Min Discount: %0.01f%%")
	
	gui:SetLast(id, last)
	gui:AddControl(id, "Checkbox",          0.42, 1, "vendor.allow.bid", "Allow Bids")
	gui:SetLast(id, last)
	gui:AddControl(id, "Checkbox",          0.56, 1, "vendor.allow.buy", "Allow Buyouts")
end

function lib.Search(item)
	local market, seen, _, pctstring
	
	-- Valuate this item
	local pct = get("vendor.profit.pct")
	local min = get("vendor.profit.min")
	local market = GetSellValue and GetSellValue(item[Const.ITEMID]) or 0
	-- If there's no price, then we obviously can't sell it, ignore!
	if not market or market == 0 then return end
	market = market * item[Const.COUNT]
	
	
	local pct = get("vendor.profit.pct")
	local minprofit = get("vendor.profit.min")
	local value = market * (100-pct) / 100
	if value > (market - minprofit) then
		value = market - minprofit
	end
	
	if get("vendor.allow.buy") and (item[Const.BUYOUT] > 0) and (item[Const.BUYOUT] <= value) then
		if AucAdvanced.Modules.Util.PriceLevel then
			local level, _, r, g, b = AucAdvanced.Modules.Util.PriceLevel.CalcLevel(item[Const.LINK], item[Const.COUNT], item[Const.PRICE], item[Const.BUYOUT], market)
			if level then
				level = math.floor(level)
				r = r*255
				g = g*255
				b = b*255
				pctstring = string.format("|cff%06d|cff%02x%02x%02x"..level, level, r, g, b) -- first color code is to allow
			end
		end
		return "buy", market, pctstring
	elseif get("vendor.allow.bid") and (item[Const.PRICE] <= value) then
		if AucAdvanced.Modules.Util.PriceLevel then
			local level, _, r, g, b = AucAdvanced.Modules.Util.PriceLevel.CalcLevel(item[Const.LINK], item[Const.COUNT], item[Const.PRICE], item[Const.PRICE], market)
			if level then
				level = math.floor(level)
				r = r*255
				g = g*255
				b = b*255
				pctstring = string.format("|cff%06d|cff%02x%02x%02x"..level, level, r, g, b) -- first color code is to allow
			end
		end
		return "bid", market, pctstring
	end
end

AucAdvanced.RegisterRevision("$URL$", "$Rev$")