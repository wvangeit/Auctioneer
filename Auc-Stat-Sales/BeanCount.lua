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

local libType, libName = "Stat", "Sales"
local lib,parent,private = AucAdvanced.NewModule(libType, libName)
if not lib then return end
local print,decode,recycle,acquire,clone,scrub,get,set,default = AucAdvanced.GetModuleLocals()

local cache = {}

function lib.GetPrice(hyperlink, faction, realm)
    if not (BeanCounter) or not (BeanCounter.API.isLoaded) then return false end
    if cache[hyperlink] then
        return cache[hyperlink][1], cache[hyperlink][2], cache[hyperlink][3], cache[hyperlink][4], cache[hyperlink][5], cache[hyperlink][6]
    end
    local settings = {["selectbox"] = {"1", "server"} , ["bid"] =true, ["auction"] = true}
	local tbl = BeanCounter.externalSearch(hyperlink, settings, true)
    local bought, sold, boughtseen, soldseen, boughtqty, soldqty = 0,0,0,0,0,0
    local i,v
    if tbl then
        for i,v in pairs(tbl) do
            -- local itemLink, reason, bid, buy, net, qty, priceper, seller, deposit, fee, wealth, date = v
            local reason, qty, priceper = v[2], v[6], v[7]
            if reason == "Won on Buyout" or reason == "Won on Bid" then
                boughtqty = boughtqty + qty
                bought = bought + priceper*qty
                boughtseen = boughtseen + 1
            elseif reason == "Auc Successful" then
                soldqty = soldqty + qty
                sold = sold + priceper*qty
                soldseen = soldseen + 1
            end
        end
        bought = bought / boughtqty
        sold = sold / soldqty
    end
    cache[hyperlink] = {bought, sold, boughtqty, soldqty, boughtseen, soldseen}
    return bought, sold, boughtqty, soldqty, boughtseen, soldseen
end

function lib.GetPriceColumns()
    if not (BeanCounter) then return end
	return "Bought Price", "Sold Price", "Bought Quantity", "Sold Quantity", "Bought Times", "Sold Times"
end

local array = {}
function lib.GetPriceArray(hyperlink, faction, realm)
	if not (BeanCounter) then return end

	-- Get our statistics
	local bought, sold, boughtqty, soldqty, boughtseen, soldseen = lib.GetPrice(hyperlink, faction, realm)
	array.bought = bought
	array.boughtseen = boughtseen
    array.soldseen = soldseen
    array.boughtqty = boughtqty
    array.soldqty = soldqty
    array.seen = boughtseen+soldseen
	array.sold = sold
    array.price = sold
    array.confidence = 1
    
	return array
end

function lib.IsValidAlgorithm()
	if not (BeanCounter) then return false end
	return true
end

function lib.CanSupplyMarket()
    if not (BeanCounter) then return false end
	return true
end

function lib.OnLoad(addon)
	AucAdvanced.Settings.SetDefault("stat.sales.tooltip", true)
end

function lib.Processor(callbackType, ...)
	if (callbackType == "tooltip") then
		private.ProcessTooltip(...)
	elseif (callbackType == "config") then
		--Called when you should build your Configator tab.
		private.SetupConfigGui(...)
	elseif (callbackType == "load") then
		lib.OnLoad(...)
	end
end

function private.ProcessTooltip(frame, name, hyperlink, quality, quantity, cost)
	-- In this function, you are afforded the opportunity to add data to the tooltip should you so
	-- desire. You are passed a hyperlink, and it's up to you to determine whether or what you should
	-- display in the tooltip.
	
	if not AucAdvanced.Settings.GetSetting("stat.sales.tooltip") then return end
	
	local bought, sold, boughtqty, soldqty, boughtseen, soldseen = lib.GetPrice(hyperlink)
	
    if (boughtseen+soldseen>0) then
		EnhTooltip.AddLine(libName.." prices:")
		EnhTooltip.LineColor(0.3, 0.9, 0.8)

		if (boughtseen > 0) then
			EnhTooltip.AddLine("  Bought |cffddeeff"..(boughtqty).."|r at avg each", bought)
			EnhTooltip.LineColor(0.3, 0.9, 0.8)
		end
        if (soldseen > 0) then
			EnhTooltip.AddLine("  Sold |cffddeeff"..(soldqty).."|r at avg each", sold)
			EnhTooltip.LineColor(0.3, 0.9, 0.8)
		end
	end
end

function private.SetupConfigGui(gui)
	local id = gui:AddTab(lib.libName, lib.libType.." Modules")

	gui:AddHelp(id, "what sales stats",
		"What are sales stats?",
		"Sales stats are the numbers that are generated by the sales module from the "..
		"BeanCounter database. It averages all of the prices for items that you have sold")
	
	gui:AddControl(id, "Header",     0,    libName.." options")
	gui:AddControl(id, "Note",       0, 1, nil, nil, " ")
	gui:AddControl(id, "Checkbox",   0, 1, "stat.sales.tooltip", "Show sales stats in the tooltips?")
	gui:AddTip(id, "Toggle display of stats from the Sales module on or off")
end

AucAdvanced.RegisterRevision("$URL$", "$Rev$")