--[[
	Auctioneer Advanced - Appraisals and Auction Posting
	Revision: $Id$
	Version: <%version%>

	This is an addon for World of Warcraft that adds an appriasals dialog for
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
		You have an implicit licence to use this AddOn with these facilities
		since that is its designated purpose as per:
		http://www.fsf.org/licensing/licenses/gpl-faq.html#InterpreterIncompat
--]]

local libName = "Appraiser"
local libType = "Util"

AucAdvanced.Modules[libType][libName] = {}
local lib = AucAdvanced.Modules[libType][libName]
local private = {}
lib.Private = private
local print = AucAdvanced.Print
lib.name = libName

local data


--[[
The following functions are part of the module's exposed methods:
	GetName()         (required) Should return this module's full name
	CommandHandler()  (optional) Slash command handler for this module
	Processor()       (optional) Processes messages sent by Auctioneer
	ScanProcessor()   (optional) Processes items from the scan manager
*	GetPrice()        (required) Returns estimated price for item link
*	GetPriceColumns() (optional) Returns the column names for GetPrice
	OnLoad()          (optional) Receives load message for all modules

	(*) Only implemented in stats modules; util modules do not provide
]]

function lib.GetName()
	return libName
end

function lib.Processor(callbackType, ...)
	if (callbackType == "tooltip") then
		lib.ProcessTooltip(...)
	elseif (callbackType == "auctionui") then
		private.CreateFrames(...)
	elseif (callbackType == "config") then
		private.SetupConfigGui(...)
	elseif (callbackType == "configchanged") then
		if not private.gui then return end
		if private.currentfilter ~= AucAdvanced.Settings.GetSetting('util.appraiser.filter') then
			lib.UpdateList()
		end
	elseif (callbackType == "inventory") then
		if private.frame and private.frame:IsVisible() then
			private.frame.GenerateList()
		end
	elseif (callbackType == "scanstats") then
		if private.frame then
			private.frame.cache = {}
			private.frame.GenerateList()
		end
	end
end

function lib.ProcessTooltip(frame, name, hyperlink, quality, quantity, cost, additional)
end

function lib.OnLoad()
	AucAdvanced.Settings.SetDefault("util.appraiser.model", "market")
end


