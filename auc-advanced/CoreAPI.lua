--[[
	Auctioneer Advanced
	Revision: $Id$
	Version: <%version%> (<%codename%>)

	This is an addon for World of Warcraft that adds statistical history to the auction data that is collected
	when the auction is scanned, so that you can easily determine what price
	you will be able to sell an item for at auction or at a vendor whenever you
	mouse-over an item in the game

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

AucAdvanced.API = {}
local lib = AucAdvanced.API


--[[
	The following functions are defined for modules's exposed methods:

	GetName()         (ALL*)  Should return this module's full name
	OnLoad()          (ALL*)   Receives load message for all modules
	Processor()       (ALL)  Processes messages sent by Auctioneer
	CommandHandler()  (ALL)  Slash command handler for this module
	ScanProcessor {}  (ALL)   Processes items from the scan manager
	GetPrice()        (STAT*) Returns estimated price for item link
	GetPriceColumns() (STAT)  Returns the column names for GetPrice
	StartScan()       (SCAN*) Begins an AH scan session
	IsScanning()      (SCAN*) Indicates an AH scan is in session
	AbortScan()       (SCAN)  Cancels the currently running scan
	Hook { }          (ALL)   Functions that are hooked by the module


	Module type in parentheses to describe which ones provide.
	Possible Module Types are STAT, UTIL, SCAN.  ALL is a shorthand for all three.
	A * after the module type states the function is REQUIRED.
	
	Please visit http://norganna.org/wiki/Auctioneer/5.0/Modules_API for a
	more complete specification.
]]


--[[
	This function acquires the current market value of the mentioned item using
	a configurable algorithm to process the data used by the other installed
	algorithms.
	The result of this function does not take into account competition, it
	simply returns what a particular item is "Worth", and not what you could
	currently sell it for.

	AucAdvanced.API.GetMarketValue(itemLink, serverKey)
]]
function lib.GetMarketValue(itemLink, serverKey)
	-- TODO: Make a configurable algorithm.
	-- This algorithm is currently less than adequate.

	local total, count = 0, 0
	for engine, engineLib in pairs(AucAdvanced.Modules.Stat) do
		if (engineLib.GetPrice) then
			local price = engineLib.GetPrice(itemLink, serverKey)
			if (price and price > 0) then
				total = total + price
				count = count + 1
			end
		end
	end
	if (total > 0) and (count > 0) then
		return total/count
	end
end

