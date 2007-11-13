--[[
	Auctioneer Advanced - Price Level Utility module
	Version: <%version%> (<%codename%>)
	Revision: $Id: Example.lua 2193 2007-09-18 06:10:48Z mentalpower $
	URL: http://auctioneeraddon.com/

	This is an Auctioneer Advanced Matcher module that returns an undercut price 
	based on the current market snapshot

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


local libType, libName = "Match", "Undercut"
local lib,parent,private = AucAdvanced.NewModule(libType, libName)
if not lib then return end
local print,decode,recycle,acquire,clone,scrub,get,set,default = AucAdvanced.GetModuleLocals()

function lib.Processor(callbackType, ...)
	if (callbackType == "tooltip") then
		--Called when the tooltip is being drawn.
		private.ProcessTooltip(...)
	elseif (callbackType == "config") then
		--Called when you should build your Configator tab.
		private.SetupConfigGui(...)
	elseif (callbackType == "listupdate") then
		--Called when the AH Browse screen receives an update.
	elseif (callbackType == "configchanged") then
		--Called when your config options (if Configator) have been changed.
	end
end

function lib.GetMatchArray(hyperlink, algorithm, faction, realm)
	local linkType,itemId,property,factor = AucAdvanced.DecodeLink(hyperlink)
	if (linkType ~= "item") then return end
	if (factor ~= 0) then property = property.."x"..factor end

	if not faction then faction = AucAdvanced.GetFaction() end
	
	local overmarket = AucAdvanced.Settings.GetSetting("match.undermarket.overmarket")
	local undermarket = AucAdvanced.Settings.GetSetting("match.undermarket.undermarket")
	local undercut = AucAdvanced.Settings.GetSetting("match.undermarket.undercut")
	local playerName = UnitName("player")
	local marketprice = 0
	if algorithm.price then
		marketprice = algorithm.price
	else
		if algorithm == "market" then
			marketprice = AucAdvanced.API.GetMarketValue(hyperlink)
		else
			marketprice = AucAdvanced.API.GetAlgorithmValue(algorithm, hyperlink)
		end
	end
	local marketdiff = 0
	local competing = 0
	local matchprice = 0
	local minprice = 0
	if not marketprice then marketprice = 0 end
	if marketprice > 0 then
		matchprice = floor(marketprice*(1+(overmarket/100)))
		minprice = ceil(marketprice*(1+(undermarket/100)))
	end
	
	itemId = tonumber(itemId)
	property = tonumber(property) or 0
	factor = tonumber(factor) or 0

	
	local data = AucAdvanced.API.QueryImage({
		itemId = itemId,
		suffix = property,
		factor = factor,
	})
	competing = #data
	for i = 1, #data do
		local compet = AucAdvanced.API.UnpackImageItem(data[i])
		local competname = compet.itemName or " "
		local competseller = compet.sellerName or " "
		local competcost = compet.buyoutPrice or 0
		local competstack = compet.stackSize or 0
		compet.buyoutPrice = (compet.buyoutPrice/compet.stackSize)
		compet.buyoutPrice = floor(compet.buyoutPrice*((100-undercut)/100))
		if (compet.buyoutPrice < matchprice) then
			if (compet.buyoutPrice > minprice) then
				if (not (compet.sellerName == playerName)) then
					matchprice = compet.buyoutPrice
				end
			end
		end
	end
	if (marketprice > 0) then
		marketdiff = (((matchprice - marketprice)/marketprice)*100)
		if (marketdiff-floor(marketdiff))<0.5 then
			marketdiff = floor(marketdiff)
		else
			marketdiff = ceil(marketdiff)
		end
	else
		marketdiff = 0
	end
	local matchArray = {}
	matchArray.value = matchprice
	matchArray.competing = competing
	matchArray.diff = marketdiff
	return matchArray
end

local array = {}

function private.ProcessTooltip(frame, name, hyperlink, quality, quantity, cost, additional)

end

function lib.OnLoad()
	--This function is called when your variables have been loaded.
	--You should also set your Configator defaults here

	--print("AucAdvanced: {{"..libType..":"..libName.."}} loaded!")
	AucAdvanced.Settings.SetDefault("match.undermarket.undermarket", -10)
	AucAdvanced.Settings.SetDefault("match.undermarket.overmarket", 10)
	AucAdvanced.Settings.SetDefault("match.undermarket.undercut", 5)
end

--[[ Local functions ]]--

function private.SetupConfigGui(gui)
	-- The defaults for the following settings are set in the lib.OnLoad function
	id = gui:AddTab(libName, libType.." Modules")
	gui:MakeScrollable(id)
	gui:AddControl(id, "Header",     0,    libName.." options")
	
	gui:AddControl(id, "Subhead",    0,    "Competition Matching")
	gui:AddControl(id, "WideSlider", 0, 1, "match.undermarket.undermarket", -100, 0, 1, "Max under market price (markdown): %d%%")
	gui:AddControl(id, "WideSlider", 0, 1, "match.undermarket.overmarket", 0, 100, 1, "Max over market price (markup): %d%%")
	gui:AddControl(id, "Slider",     0, 1, "match.undermarket.undercut", 0, 20, 1, "Undercut: %d%%")
	
	
end

