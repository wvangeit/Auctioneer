--[[
	Auctioneer Advanced - Price Level Utility module
	Version: <%version%> (<%codename%>)
	Revision: $Id$
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

local libType, libName = "Stat", "WOWEcon"
local lib,parent,private = AucAdvanced.NewModule(libType, libName)
if not lib then return end
local print,decode,recycle,acquire,clone,scrub,get,set,default = AucAdvanced.GetModuleLocals()

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
	
	if AucAdvanced.Settings.GetSetting("stat.wowecon.useglobal") then
		array.price = array.g_price
		array.seen = array.g_seen
		array.specific = false
	end
	
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

function lib.Processor(callbackType, ...)
	if (callbackType == "config") then
		--Called when you should build your Configator tab.
		private.SetupConfigGui(...)
	elseif (callbackType == "load") then
		lib.OnLoad(...)
	end
end

function private.SetupConfigGui(gui)
	local id = gui:AddTab(lib.libName, lib.libType.." Modules")

	gui:AddHelp(id, "what global price",
		"What are global prices?",
		"Wowecon provides two different types of prices: a global price, averaged across "..
		"all servers, and a server specific price, for just your server and faction.")

	gui:AddHelp(id, "why use global",
		"Why should I use global prices?",
		"Server specific prices can be useful if your server has prices which are far "..
		"removed from the average, but often these prices are based on many "..
		"fewer data points, causing your server specific price to "..
		"possibly get out of whack for some items.  This option lets you force the "..
		"Wowecon stat to always use global prices, if you'd prefer.")
	
	gui:AddHelp(id, "prices dont match",
		"The Wowecon price used by Appraiser doesn't match the Wowecon tooltip.  What gives?",
		"Wowecon gives you the option to hide server specific prices if seen "..
		"fewer than a given number of times.  Even though these prices are "..
		"hidden from the tooltip, they are still reported to Appraiser.  "..
		"If you are not using the global price option here, you should "..
		"check to make sure there isn't a hidden server specific price for your server, "..
		"with just a small number of seen times.")
	
	gui:AddControl(id, "Header",     0,    libName.." options")
	gui:AddControl(id, "Note",       0, 1, nil, nil, " ")
	gui:AddControl(id, "Checkbox",   0, 1, "stat.wowecon.useglobal", "Always use global price, not server price")
	gui:AddTip(id, "Toggle use of server specific Wowecon price stats, if they exist")
end

function lib.OnLoad(addon)
	AucAdvanced.Settings.SetDefault("stat.wowecon.useglobal", true)
end

AucAdvanced.RegisterRevision("$URL$", "$Rev$")