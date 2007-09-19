--[[
	Auctioneer Advanced - Price Level Utility module
	Version: <%version%> (<%codename%>)
	Revision: $Id: Example.lua 2193 2007-09-18 06:10:48Z mentalpower $
	URL: http://auctioneeraddon.com/

	This is an Auctioneer Advanced module that does something nifty.

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

local libName = "WOWEcon"
local libType = "Stat"

AucAdvanced.Modules[libType][libName] = {}
local lib = AucAdvanced.Modules[libType][libName]
local private = {}
local print = AucAdvanced.Print

function lib.GetName()
	return libName
end

function lib.GetPrice(hyperlink, faction, realm)
	if not (Wowecon and Wowecon.API) then return end
	local price,seen,specific = Wowecon.API.GetAuctionPrice_ByLink(hyperlink)
	return price, false, seen, specific
end

function lib.GetPriceColumns()
	if not (Wowecon and Wowecon.API) then return end
	return "WOWEcon Price", false, "WOWEcon Seen"
end

local array = {}
function lib.GetPriceArray(hyperlink, faction, realm)
	if not (Wowecon and Wowecon.API) then return end

	-- Get our statistics
	local price, _, seen, specific = lib.GetPrice(hyperlink, faction, realm)
	array.price = price
	array.seen = seen
	array.specific = specific

	if (specific) then
		price,seen = Wowecon.API.GetAuctionPrice_ByLink(hyperlink, Wowecon.API.GLOBAL_PRICE)
	end
	array.g_price = price
	array.g_seen = seen
	return array
end

function lib.IsValidAlgorithm()
	if not (Wowecon and Wowecon.API) then return false end
	return true
end

function lib.CanSupplyMarket()
	if not (Wowecon and Wowecon.API) then return false end
	return true
end

