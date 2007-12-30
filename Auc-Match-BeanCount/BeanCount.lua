--[[
	Auctioneer Advanced - Price Level Utility module
	Version: <%version%> (<%codename%>)
	Revision: $Id: Undercut.lua 2537 2007-11-19 01:55:03Z speeddymon $
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
--if not BeanCounter then 
--	AucAdvanced.Print("BeanCounter not loaded")
--	return 
--end

local libType, libName = "Match", "BeanCount"
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

function lib.GetMatchArray(hyperlink, marketprice)
	local linkType,itemId,property,factor = AucAdvanced.DecodeLink(hyperlink)
	if (linkType ~= "item") then return end
	if (factor ~= 0) then property = property.."x"..factor end

	local marketdiff = 0
	local competing = 0
	if not marketprice then marketprice = 0 end
	local matchprice = marketprice
	local increase = AucAdvanced.Settings.GetSetting("match.beancount.success")
	local decrease = AucAdvanced.Settings.GetSetting("match.beancount.failed")
	increase = (increase / 100) + 1
	decrease = (decrease / 100) + 1
	itemId = tostring(itemId)

	local success = 0
	local failed = 0
	if BeanCounter and BeanCounter.Private.playerData then
		if BeanCounter.Private.playerData["completedAuctions"][itemId] then
			success = #BeanCounter.Private.playerData["completedAuctions"][itemId]
			success = math.pow(success, 0.8)
		end
		if BeanCounter.Private.playerData["failedAuctions"][itemId] then
			failed = #BeanCounter.Private.playerData["failedAuctions"][itemId]
			failed = math.pow(failed, 0.8)
		end
	end
	increase = math.pow(increase, success)
	decrease = math.pow(decrease, failed)
	matchprice = matchprice * increase
	matchprice = matchprice * decrease
	
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
	matchArray.diff = marketdiff
	matchArray.returnstring = "BeanCount: % change: "..tostring(marketdiff)
	return matchArray
end

local array = {}

function private.ProcessTooltip(frame, name, hyperlink, quality, quantity, cost, additional)

end

function lib.OnLoad()
	--This function is called when your variables have been loaded.
	--You should also set your Configator defaults here

	--print("AucAdvanced: {{"..libType..":"..libName.."}} loaded!")
	AucAdvanced.Settings.SetDefault("match.beancount.failed", -1)
	AucAdvanced.Settings.SetDefault("match.beancount.success", 1)
end

--[[ Local functions ]]--

function private.SetupConfigGui(gui)
	-- The defaults for the following settings are set in the lib.OnLoad function
	local id = gui:AddTab(libName, libType.." Modules")
	--gui:MakeScrollable(id)

	gui:AddHelp(id, "what beancount module",
		"What is this BeanCount module?",
		"The BeanCount module uses BeanCounter's data to adjust the price based on the item's past selling history.")

	gui:AddControl(id, "Header",     0,    libName.." options")
	
	gui:AddControl(id, "Subhead",    0,    "Price Adjustments")
	
	gui:AddControl(id, "WideSlider", 0, 1, "match.beancount.failed", -20, 0, 1, "Auction failure markdown: %d%%")
	gui:AddTip(id, "This controls how much you want to markdown an auction for every time it has failed to sell.\n"..
		"This is cumulative.  ie a setting of 10% with two failures will set the price at 81% of market")
	
	gui:AddControl(id, "WideSlider", 0, 1, "match.beancount.success", 0, 20, 1, "Auction success markup: %d%%")
	gui:AddTip(id, "This controls how much you want to markup an auction for every time it has sold.\n"..
		"This is cumulative.  ie a setting of 10% with two successes will set the price at 121% of market")
end

AucAdvanced.RegisterRevision("$URL: http://dev.norganna.org/auctioneer/trunk/Auc-Match-Undercut/Undercut.lua $", "$Rev: 2537 $")