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
		--private.SetupConfigGui(...)
	elseif (callbackType == "configchanged") then
	elseif (callbackType == "inventory") then
	elseif (callbackType == "scanstats") then
	elseif (callbackType == "postresult") then
	end
end

function lib.ProcessTooltip(frame, name, hyperlink, quality, quantity, cost, additional)
end

function lib.OnLoad()
--Default sizes for the scrollframe column widths
default("util.simple.columnwidth.Seller", 89)
default("util.simple.columnwidth.Left", 32)
default("util.simple.columnwidth.Stk", 32 )
default("util.simple.columnwidth.Min/ea", 65)
default("util.simple.columnwidth.Cur/ea", 65)
default("util.simple.columnwidth.Buy/ea", 65)
default("util.simple.columnwidth.MinBid", 76)
default("util.simple.columnwidth.CurBid", 76)
default("util.simple.columnwidth.Buyout", 80)
default("util.simple.columnwidth.BLANK", 0.05)
end

AucAdvanced.RegisterRevision("$URL$", "$Rev$")
