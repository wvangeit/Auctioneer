--[[
	Auctioneer Advanced - Basic Auction Posting
	Version: <%version%> (<%codename%>)
	Revision: $Id$
	URL: http://auctioneeraddon.com/

	This is an addon for World of Warcraft that adds a simple dialog for
	easy posting of your auctionables when you are at the auction-house.

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
if not AucAdvanced then return end

local libType, libName = "Util", "SimpleAuction"
local lib,parent,private = AucAdvanced.NewModule(libType, libName)
if not lib then return end
local print,decode,_,_,replicate,empty,get,set,default,debugPrint,fill = AucAdvanced.GetModuleLocals()

local data, _
local ownResults = {}
local ownCounts = {}

function lib.Processor(callbackType, ...)
	if (callbackType == "tooltip") then
		lib.ProcessTooltip(...)
	elseif (callbackType == "auctionui") then
        private.CreateFrames(...)
	elseif (callbackType == "config") then
		private.SetupConfigGui(...)
	elseif (callbackType == "configchanged") then
		private.UpdateConfig(...)
	elseif (callbackType == "inventory") then
	elseif (callbackType == "scanstats") then
	elseif (callbackType == "postresult") then
	end
end

local function whitespace(length)
	local spaces = ""
	for index = length, 0, -1 do
		spaces = spaces.." "
	end
	return spaces
end

function lib.ProcessTooltip(frame, name, link, quality, quantity, cost, additional)
	if not get("util.simpleauc.tooltip") then return end
	local realm = AucAdvanced.GetFaction()
	local id = private.SigFromLink(link)
	local settingstr = get("util.simpleauc."..realm.."."..id)
	local market, seen, fixbuy, fixbid, stack
	local imgseen, image, matchBid, matchBuy, lowBid, lowBuy, aveBuy, aSeen = private.GetItems(link)
	local reason = "Market"

	market, seen = AucAdvanced.API.GetMarketValue(link)
	if (not market) or (market <= 0) or (not (seen > 5 or aSeen < 3)) then
		market = aveBuy
		reason = "Current"
	end
	if (not market) and GetSellValue then
		local vendor = GetSellValue(link)
		if vendor and vendor > 0 then
			market = vendor * 3
			reason = "Vendor markup"
		end
	end
	if not market or market <= 0 then
		market = 0
		reason = "No data"
	end
	
	local coinsBid, coinsBuy, coinsBidEa, coinsBuyEa = "no","no","no","no"
	if market > 0 then
		coinsBid = private.coins(market*0.8*quantity)
		coinsBidEa = private.coins(market*0.8)
		coinsBuy = private.coins(market*quantity)
		coinsBuyEa = private.coins(market)
	end
	if quantity == 1 then
		local text = string.format("%s: %s bid/%s buyout", libName, coinsBid, coinsBuy)
		EnhTooltip.AddLine(text)
		EnhTooltip.LineColor(0.4, 1.0, 0.9)
	else
		local text = string.format("%s x%d: %s bid/%s buyout", libName, quantity, coinsBid, coinsBuy)
		local textea =  string.format("%s(Or individually: %s/%s)", whitespace(5), coinsBidEa, coinsBuyEa)
		EnhTooltip.AddLine(text)
		EnhTooltip.LineColor(0.4, 1.0, 0.9)
		EnhTooltip.AddLine(textea)
		EnhTooltip.LineColor(0.3, .8, 0.7)
	end
	if settingstr then
		fixbid, fixbuy, _, _, stack = strsplit(":", settingstr)
		fixbid, fixbuy, stack = tonumber(fixbid), tonumber(fixbuy), tonumber(stack)
		fixbid = ceil(fixbid/stack)
		fixbuy = ceil(fixbuy/stack)
	end
	
	if fixbid then
		coinsBuy = "no"
		coinsBid = private.coins(fixbid*quantity)
		if fixbuy then
			coinsBuy = private.coins(fixbuy*quantity)
		end
		if quantity == 1 then
			local text = string.format("%sFixed: %s bid/%s buyout", whitespace(12), coinsBid, coinsBuy)
			EnhTooltip.AddLine(text)
			EnhTooltip.LineColor(0.4, 1.0, 0.9)
		else
			local text = string.format("%sFixed x%d: %s bid/%s buyout", whitespace(12), quantity, coinsBid, coinsBuy)
			EnhTooltip.AddLine(text)
			EnhTooltip.LineColor(0.4, 1.0, 0.9)
		end
	end
	if lowBid and lowBid > 0 then
		coinsBuy = "no"
		coinsBid = private.coins(lowBid*quantity)
		if lowBuy and lowBuy > 0 then
			coinsBuy = private.coins(lowBuy*quantity)
		end
		if quantity == 1 then
			local text = string.format("%sUndercut: %s bid/%s buyout", whitespace(8), coinsBid, coinsBuy)
			EnhTooltip.AddLine(text)
			EnhTooltip.LineColor(0.4, 1.0, 0.9)
		else
			local text = string.format("%sUndercut x%d: %s bid/%s buyout", whitespace(8), quantity, coinsBid, coinsBuy)
			EnhTooltip.AddLine(text)
			EnhTooltip.LineColor(0.4, 1.0, 0.9)
		end
	else
		EnhTooltip.AddLine("  No Competition")
		EnhTooltip.LineColor(0.4, 1.0, 0.9)
	end
	
end

function lib.OnLoad()
	--Default sizes for the scrollframe column widths
	default("util.simpleauc.columnwidth.Seller", 89)
	default("util.simpleauc.columnwidth.Left", 32)
	default("util.simpleauc.columnwidth.Stk", 32 )
	default("util.simpleauc.columnwidth.Min/ea", 65)
	default("util.simpleauc.columnwidth.Cur/ea", 65)
	default("util.simpleauc.columnwidth.Buy/ea", 65)
	default("util.simpleauc.columnwidth.MinBid", 76)
	default("util.simpleauc.columnwidth.CurBid", 76)
	default("util.simpleauc.columnwidth.Buyout", 80)
	default("util.simpleauc.columnwidth.BLANK", 0.05)
	--Default options
	default("util.simpleauc.clickhook", true)
	default("util.simpleauc.scanbutton", true)
	default("util.simpleauc.tooltip", true)
end

function private.UpdateConfig()
	if private.frame then
		local frame = private.frame
		if get("util.simpleauc.scanbutton") then
			frame.scanbutton:Show()
		else
			frame.scanbutton:Hide()
		end
	end
end

function private.SetupConfigGui(gui)
	local id = gui:AddTab(lib.libName, lib.libType.." Modules")
	gui:MakeScrollable(id)
	private.gui = gui
	private.guiId = id

	gui:AddHelp(id, "what simpleauc",
		"What is SimpleAuction?",
		"Simple Auction is a simplified, more automated way of posting items. It focuses it's emphasis on easy pricing and maximum sale speed with a minimum of configuration options and learning curve.\n"..
		"It won't get you maximium profit, or ultimate configurability, but the values it provides are reasonable in most circumstances and it is primarily very easy to use.\n")

	gui:AddControl(id, "Header",       0,    lib.libName.." options")
	gui:AddControl(id, "Checkbox",     0, 1, "util.simpleauc.tooltip", "Show prices in tooltip")
	gui:AddTip(id, "Shows market price and potential undercut price for the current item in the tooltip")
	gui:AddControl(id, "Checkbox",     0, 1, "util.simpleauc.clickhook", "Allow alt-click item in bag instead of drag")
	gui:AddTip(id, "Enables an alt-click mouse-hook so you can alt-click your inventory items into the SimpleAuction post frame")
	gui:AddControl(id, "Checkbox",     0, 1, "util.simpleauc.scanbutton", "Show big red scan button at bottom of seach window")
	gui:AddTip(id, "Displays the old-style \"Scan\" button at the bottom of the browse window.")
end

AucAdvanced.RegisterRevision("$URL$", "$Rev$")
