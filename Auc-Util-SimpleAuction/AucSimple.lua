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

function lib.ProcessTooltip(frame, name, hyperlink, quality, quantity, cost, additional)
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
	gui:AddControl(id, "Checkbox",     0, 1, "util.simpleauc.clickhook", "Allow alt-click item in bag instead of drag")
	gui:AddTip(id, "Enables an alt-click mouse-hook so you can alt-click your inventory items into the SimpleAuction post frame")
	gui:AddControl(id, "Checkbox",     0, 1, "util.simpleauc.scanbutton", "Show big red scan button at bottom of seach window")
	gui:AddTip(id, "Displays the old-style \"Scan\" button at the bottom of the browse window.")
end

AucAdvanced.RegisterRevision("$URL$", "$Rev$")
