--[[
	Auctioneer Advanced - Search UI - Searcher Prospect
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
		You have an implicit license to use this AddOn with these facilities
		since that is its designated purpose as per:
		http://www.fsf.org/licensing/licenses/gpl-faq.html#InterpreterIncompat
--]]
-- Create a new instance of our lib with our parent
local lib, parent, private = AucSearchUI.NewSearcher("Prospect")
if not lib then return end
local print,decode,_,_,replicate,empty,_,_,_,debugPrint,fill = AucAdvanced.GetModuleLocals()
local get,set,default,Const = AucSearchUI.GetSearchLocals()
lib.tabname = "Prospect"
-- Set our defaults
default("prospect.profit.min", 1)
default("prospect.profit.pct", 50)
default("prospect.level.custom", false)
default("prospect.level.min", 0)
default("prospect.level.max", 450)
default("prospect.adjust.brokerage", true)
default("prospect.allow.bid", true)
default("prospect.allow.buy", true)
default("prospect.maxprice", 10000000)
default("prospect.maxprice.enable", false)

-- This function is automatically called when we need to create our search parameters
function lib:MakeGuiConfig(gui)
	-- Get our tab and populate it with our controls
	local id = gui:AddTab(lib.tabname, "Searchers")

	-- Add the help
	gui:AddSearcher("Prospect", "Search for items which can be prospected for profit", 100)
	gui:AddHelp(id, "prospect searcher",
		"What does this searcher do?",
		"This searcher provides the ability to search for ores which will prospect into gems that on average will have a greater value than the purchase price of the original ore.")

	if not (Enchantrix and Enchantrix.Storage and Enchantrix.Storage.GetItemProspectTotals) then
		gui:AddControl(id, "Header",     0,   "Enchantrix not detected")
		gui:AddControl(id, "Note",    0.3, 1, 290, 30,    "Enchantrix must be enabled to search with Prospect")
		return
	end

	gui:AddControl(id, "Header",     0,      "Prospect search criteria")

	local last = gui:GetLast(id)

	gui:AddControl(id, "MoneyFramePinned",  0, 1, "prospect.profit.min", 1, 99999999, "Minimum Profit")
	gui:AddControl(id, "Slider",            0, 1, "prospect.profit.pct", 1, 100, .5, "Min Discount: %0.01f%%")
	gui:AddControl(id, "Checkbox",          0, 1, "prospect.level.custom", "Use custom levels")
	gui:AddControl(id, "Slider",            0, 2, "prospect.level.min", 0, 450, 25, "Minimum skill: %s")
	gui:AddControl(id, "Slider",            0, 2, "prospect.level.max", 25, 450, 25, "Maximum skill: %s")
	gui:AddControl(id, "Subhead",           0, "Note:")
	gui:AddControl(id, "Note",              0, 1, 290, 30, "The \"Pct\" Column is \% of Prospect Value")

	gui:SetLast(id, last)
	gui:AddControl(id, "Checkbox",          0.42, 1, "prospect.allow.bid", "Allow Bids")
	gui:SetLast(id, last)
	gui:AddControl(id, "Checkbox",          0.56, 1, "prospect.allow.buy", "Allow Buyouts")
	gui:AddControl(id, "Checkbox",          0.42, 1, "prospect.maxprice.enable", "Enable individual maximum price:")
	gui:AddTip(id, "Limit the maximum amount you want to spend with the Prospect searcher")
	gui:AddControl(id, "MoneyFramePinned",  0.42, 2, "prospect.maxprice", 1, 99999999, "Maximum Price for Prospect")

	gui:AddControl(id, "Subhead",           0.42,    "Fees Adjustment")
	gui:AddControl(id, "Checkbox",          0.42, 1, "prospect.adjust.brokerage", "Subtract auction fees")
end

function lib.Search(item)
	if not (Enchantrix and Enchantrix.Storage and Enchantrix.Storage.GetItemProspectTotals) then
		return false, "Enchantrix not detected"
	end
	if item[Const.QUALITY] ~= 1 then -- All prospectable ores are "Common" quality
		return false, "Item not prospectable"
	end

	local bidprice, buyprice = item[Const.PRICE], item[Const.BUYOUT]
	local maxprice = get("prospect.maxprice.enable") and get("prospect.maxprice")
	if buyprice <= 0 or not get("prospect.allow.buy") or (maxprice and buyprice > maxprice) then
		buyprice = nil
	end
	if not get("prospect.allow.bid") or (maxprice and bidprice > maxprice) then
		bidprice = nil
	end
	if not (bidprice or buyprice) then
		return false, "Does not meet bid/buy requirements"
	end

	-- Give up if it doesn't prospect to anything
	local prospects = Enchantrix.Storage.GetItemProspects(item[Const.LINK])
	if not prospects then
		return false, "Item not prospectable"
	end

	local minskill = 0
	local maxskill = 450
	if get("prospect.level.custom") then
		minskill = get("prospect.level.min")
		maxskill = get("prospect.level.max")
	else
		maxskill = Enchantrix.Util.GetUserJewelCraftingSkill()
	end
	local skillneeded = Enchantrix.Util.JewelCraftSkillRequiredForItem(item[Const.LINK])
	if (skillneeded < minskill) or (skillneeded > maxskill) then
		return false, "Skill not high enough to prospect"
	end

	local _, _, _, market = Enchantrix.Storage.GetItemProspectTotals(item[Const.LINK])
	if (not market) or (market == 0) then
		return false, "Item not prospectable"
	end

	--adjust for stack size
	market = market * item[Const.COUNT]

	--adjust for brokerage costs
	local brokerage = get("prospect.adjust.brokerage")

	if brokerage then
		market = market * 0.95
	end
	local pct = get("prospect.profit.pct")
	local minprofit = get("prospect.profit.min")
	local value = market * (100-pct) / 100
	if value > (market - minprofit) then
		value = market - minprofit
	end
	if buyprice and buyprice <= value then
		return "buy", market
	elseif bidprice and bidprice <= value then
		return "bid", market
	end
	return false, "Not enough profit"
end

AucAdvanced.RegisterRevision("$URL$", "$Rev$")
