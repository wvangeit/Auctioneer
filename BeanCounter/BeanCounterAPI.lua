--[[
	Auctioneer Addon for World of Warcraft(tm).
	Version: <%version%> (<%codename%>)
	Revision: $Id$

	BeanCounterAPI - Functions for other addons to get BeanCounter Data
	URL: http://auctioneeraddon.com/
	
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
		since that is it's designated purpose as per:
		http://www.fsf.org/licensing/licenses/gpl-faq.html#InterpreterIncompat
]]

local lib = BeanCounter
lib.API = {}

local private = lib.Private
local print =  BeanCounter.Print
local _BC = private.localizations

--[[ Returns the Sum of all AH sold vs AH buys along with the date range
If no player name is supplied then the entire server profit will be totaled
if no item name is provided then all items will be returned
if no date range is supplied then a sufficently large range to cover the entire BeanCounter History will be used. 
]]
function lib.API.getAHProfit(player, item, lowDate, highDate)
	if not player or player == "" then player = "server" end
	if not item then item = "" end

	local sum, high, low, number =  0, 0198796618, 2198796618 --high and low are date ranges that will always fall out of the BeanCounters range of Dates 
	local settings = {["selectbox"] = {"1", player} , ["bid"] =true, ["auction"] = true}
	local tbl = private.startSearch(item, settings, "none")
	
	for i,v in pairs(tbl.completedAuctions) do
		local Time = tonumber(v[5])
		number = tonumber(v[3]:match(".-;.-;.-;.-;.-;(.-);.*")) or 0
		--Allow the user to filter a time range to look at 
		if lowDate and highDate then
			if Time >= lowDate and Time <= highDate then  
				sum = sum + number
			end
		else --if no date ranges are supplied we find the min and max dates in the Database and return them as the range
			if Time > high then high = Time elseif Time < low then low = Time end 
			sum = sum + number
		end
	end
	for i,v in pairs(tbl["completedBids/Buyouts"]) do
		local Time = tonumber(v[5])
		number = tonumber(v[3]:match(".-;.-;.-;.-;.-;.-;(.-);.*")) or 0
		if lowDate and highDate then
			if Time >= lowDate and Time <= highDate then  
				sum = sum - number
			end
		else
			if Time > high then high = Time elseif Time < low then low = Time end
			sum = sum - number
		end
	end
	return sum, lowDate or low, highDate or high
end
