--[[
	Auctioneer Advanced - Search UI - Searcher Arbitrage
	Version: <%version%> (<%codename%>)
	Revision: $Id: SearcherResale.lua 3277 2008-07-28 12:04:47Z Norganna $
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
local lib, parent, private = AucSearchUI.NewSearcher("Arbitrage")
if not lib then return end
local print,decode,_,_,replicate,empty,_,_,_,debugPrint,fill = AucAdvanced.GetModuleLocals()
local get,set,default,Const = AucSearchUI.GetSearchLocals()
lib.tabname = "Arbitrage"

function private.getStyles()
	return {
			{0, "Neutral"},
			{1, "Cross-Faction"},
			{2, "Cross-Realm"},
		}
end

function private.getFactions()
	return {
			{0, "Neutral"},
			{1, "Alliance"},
			{2, "Horde"},
		}
end

function private.getRealmList()
	local found = false
	local allrealms = get("arbitrage.search.allrealms")
	local _,current,_ = AucAdvanced.GetFaction()
	for num,realm in pairs(allrealms) do
		if realm == current then found = true end
	end
	if not found then
		table.insert(allrealms, current)
		set("arbitrage.search.allrealms", allrealms)
	end
end

-- Set our defaults
default("arbitrage.profit.min", 1)
default("arbitrage.profit.pct", 50)
default("arbitrage.seen.check", false)
default("arbitrage.seen.min", 10)
default("arbitrage.adjust.brokerage", true)
default("arbitrage.adjust.deposit", true)
default("arbitrage.adjust.listings", 3)
default("arbitrage.allow.bid", true)
default("arbitrage.allow.buy", true)
default("arbitrage.allow.buy", true)
default("arbitrage.search.crossrealmrealm", false) --I'm not sure what this should be for default
default("arbitrage.search.crossrealmfaction", false) --I'm not sure what this should be for default
default("arbitrage.search.allrealms", {})
default("arbitrage.search.style", "Neutral")

-- This function is automatically called when we need to create our search parameters
function lib:MakeGuiConfig(gui)
	-- Get our tab and populate it with our controls
	local id = gui:AddTab(lib.tabname, "Searches")
	gui:MakeScrollable(id)
	private.getRealmList()

	gui:AddControl(id, "Header",     0,      "Arbitrage search criteria")

	local last = gui:GetLast(id)
	
	gui:AddControl(id, "MoneyFramePinned",  0, 1, "arbitrage.profit.min", 1, 99999999, "Minimum Profit")
	gui:AddControl(id, "Slider",            0, 1, "arbitrage.profit.pct", 1, 100, .5, "Min Discount: %0.01f%%")
	gui:AddControl(id, "Checkbox",          0, 1, "arbitrage.seen.check", "Check Seen count")
	gui:AddControl(id, "Slider",            0, 2, "arbitrage.seen.min", 1, 100, 1, "Min seen count: %s")
	
	gui:AddControl(id, "Subhead",           0,      "Search against")
	gui:AddControl(id, "Selectbox",         0.01, 1, private.getStyles(), "arbitrage.search.style", "Search against")
	gui:AddControl(id, "Subhead",           0.01,      "Cross-Realm:")
	gui:AddControl(id, "Selectbox",         0.02, 1, "arbitrage.search.allrealms", "arbitrage.search.crossrealmrealm", "Realm")
	gui:AddControl(id, "Selectbox",         0.02, 1, private.getFactions(), "arbitrage.search.crossrealmfaction", "Faction")
	
	gui:SetLast(id, last)
	gui:AddControl(id, "Checkbox",          0.42, 1, "arbitrage.allow.bid", "Allow Bids")
	gui:SetLast(id, last)
	gui:AddControl(id, "Checkbox",          0.56, 1, "arbitrage.allow.buy", "Allow Buyouts")

	gui:AddControl(id, "Subhead",           0.42,    "Fees Adjustment")
	gui:AddControl(id, "Checkbox",          0.42, 1, "arbitrage.adjust.brokerage", "Subtract auction fees")
	gui:AddControl(id, "Checkbox",          0.42, 1, "arbitrage.adjust.deposit", "Subtract deposit")
	gui:AddControl(id, "Slider",            0.42, 1, "arbitrage.adjust.listings", 1, 10, .1, "Ave relistings: %0.1fx")
end

function lib.Search(item)
	local market, seen, _, curModel, pctstring
	private.getRealmList()

	-- Get correct faction to compare against
	local comparefaction,_,factionGroup = AucAdvanced.GetFaction()
	if get("arbitrage.search.style") == "Neutral" then
		if (factionGroup == UnitFactionGroup("player")) then
			comparefaction = GetRealmName().."-Neutral" --If you're at home, compare to neutral
		else
			comparefaction = GetRealmName().."-"..UnitFactionGroup("player") --if you're at neutral, compare to home
		end
	elseif get("arbitrage.search.style") == "Cross-Faction" then
		if (factionGroup == UnitFactionGroup("player")) then
			if UnitFactionGroup("player") == "Horde" then faction = "-Alliance" end
			if UnitFactionGroup("player") == "Alliance" then faction = "-Horde" end
			comparefaction = GetRealmName()..faction --If you're at home, compare to cross-faction
			faction = nil
		else
			comparefaction = GetRealmName().."-"..UnitFactionGroup("player") --if you're at neutral, compare to home
		end
	elseif get("arbitrage.search.style") == "Cross-Realm" then
		comparefaction = get("arbitrage.search.crossrealmrealm").."-"..get("arbitrage.search.crossrealmfaction")
	else
		comparefaction = AucAdvanced.GetFaction()
	end
	
	market, _, _, seen, curModel = AucAdvanced.Modules.Util.Appraiser.GetPrice(item[Const.LINK], comparefaction)
	
	if not market then
		return false, "No appraiser price"
	end
	market = market * item[Const.COUNT]
	
	if (get("arbitrage.seen.check")) and curModel ~= "fixed" then
		if ((not seen) or (seen < get("arbitrage.seen.min"))) then
			return false, "Seen count too low"
		end
	end
	
	--adjust for brokerage/deposit costs
	local deposit = get("arbitrage.adjust.deposit")
	local brokerage = get("arbitrage.adjust.brokerage")
	local sig = AucAdvanced.Modules.Util.Appraiser.GetSigFromLink(item[Const.LINK])
	local duration = AucAdvanced.Settings.GetSetting("util.appraiser.item."..sig..".duration") or AucAdvanced.Settings.GetSetting("util.appraiser.duration")
	
	if brokerage then
		market = market * .095
	end
	if deposit then
		local relistings = get("arbitrage.adjust.listings")
		--set up correct brokerage/deposit costs for our target AH
		local newfaction
		if strsub(comparefaction, (strlen(comparefaction)-6)) == "Neutral" then
			newfaction = "neutral"
		end
		local amount = GetDepositCost(item[Const.LINK], (AucAdvanced.Settings.GetSetting("util.appraiser.duration")/60), newfaction, item[Const.COUNT])
		if not amount then
			amount = 0
		else
			amount = amount * relistings
		end
		market = market - amount
	end
	
	local pct = get("arbitrage.profit.pct")
	local minprofit = get("arbitrage.profit.min")
	local value = market * (100-pct) / 100
	if value > (market - minprofit) then
		value = market - minprofit
	end
	if get("arbitrage.allow.buy") and (item[Const.BUYOUT] > 0) and (item[Const.BUYOUT] <= value) then
		return "buy", market
	elseif get("arbitrage.allow.bid") and (item[Const.PRICE] <= value) then
		return "bid", market
	end
	return false, "Not enough profit"
end

private.getRealmList()
AucAdvanced.RegisterRevision("$URL: http://svn.norganna.org/auctioneer/trunk/Auc-Util-SearchUI/SearcherArbitrage.lua $", "$Rev: 3229 $")