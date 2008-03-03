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
-- don't recalc time every query, that would be ridiculous
local currenttime = time()
local day3time = currenttime - 3*86400
local day7time = currenttime - 7*86400

function private.onEvent(frame, event, arg, ...)
	if (event == "MAIL_CLOSED") then
        -- Clear cache
		cache = {}
	end
end

function lib.GetPrice(hyperlink, faction, realm)
    if not (BeanCounter) or not (BeanCounter.API.isLoaded) then return false end
    if cache[hyperlink] then
        return cache[hyperlink][1], cache[hyperlink][2], cache[hyperlink][3], cache[hyperlink][4], cache[hyperlink][5], cache[hyperlink][6], cache[hyperlink][7], cache[hyperlink][8], cache[hyperlink][9], cache[hyperlink][10], cache[hyperlink][11], cache[hyperlink][12], cache[hyperlink][13], cache[hyperlink][14]
    end
    local settings = {["selectbox"] = {"1", "server"} , ["bid"] =true, ["auction"] = true}
	local tbl = BeanCounter.externalSearch(hyperlink, settings, true)
    local bought, sold, boughtseen, soldseen, boughtqty, soldqty, bought3, sold3, boughtqty3, soldqty3, bought7, sold7, boughtqty7, soldqty7 = 0,0,0,0,0,0,0,0,0,0,0,0,0,0
    local i,v
    if tbl then
        for i,v in pairs(tbl) do
            -- local itemLink, reason, bid, buy, net, qty, priceper, seller, deposit, fee, wealth, date = v
            local reason, qty, priceper, thistime = v[2], v[6], v[7], v[12]
            thistime = tonumber(thistime)
            if not qty then
                qty = 1
            end
            if reason == "Won on Buyout" or reason == "Won on Bid" then
                boughtqty = boughtqty + qty
                bought = bought + priceper*qty
                boughtseen = boughtseen + 1
                if thistime >= day3time then
                    boughtqty3 = boughtqty3 + qty
                    bought3 = bought3 + priceper*qty
                end
                if thistime >= day7time then
                    boughtqty7 = boughtqty7 + qty
                    bought7 = bought7 + priceper*qty
                end
            elseif reason == "Auc Successful" then
                soldqty = soldqty + qty
                sold = sold + priceper*qty
                soldseen = soldseen + 1
                if thistime >= day3time then
                    soldqty3 = soldqty3 + qty
                    sold3 = sold3 + priceper*qty
                end
                if thistime >= day7time then
                    soldqty7 = soldqty7 + qty
                    sold7 = sold7 + priceper*qty
                end
            end
        end
        bought = bought / boughtqty
        sold = sold / soldqty
        bought3 = bought3 / boughtqty3
        sold3 = sold3 / soldqty3
        bought7 = bought7 / boughtqty7
        sold7 = sold7 / soldqty7
    end
    cache[hyperlink] = {bought, sold, boughtqty, soldqty, boughtseen, soldseen, bought3, sold3, boughtqty3, soldqty3, bought7, sold7, boughtqty7, soldqty7}
    return bought, sold, boughtqty, soldqty, boughtseen, soldseen, bought3, sold3, boughtqty3, soldqty3, bought7, sold7, boughtqty7, soldqty7
end

function lib.GetPriceColumns()
   if not (BeanCounter) or not (BeanCounter.API.isLoaded) then return end
	return "Bought Price", "Sold Price", "Bought Quantity", "Sold Quantity", "Bought Times", "Sold Times", "3day Bought Price", "3day Sold Price", "3day Bought Quantity", "3day Sold Quantity", "7day Bought Price", "7day Sold Price", "7day Bought Quantity", "7day Sold Quantity"
end

local array = {}
function lib.GetPriceArray(hyperlink, faction, realm)
	if not (BeanCounter) or not (BeanCounter.API.isLoaded) then return end

	-- Get our statistics
	local bought, sold, boughtqty, soldqty, boughtseen, soldseen, bought3, sold3, boughtqty3, soldqty3, bought7, sold7, boughtqty7, soldqty7 = lib.GetPrice(hyperlink, faction, realm)
	array.boughtseen = boughtseen
    array.soldseen = soldseen
    array.bought = bought
	array.sold = sold
    array.boughtqty = boughtqty
    array.soldqty = soldqty
    array.seen = boughtseen+soldseen
    array.bought3 = bought3
	array.sold3 = sold3
    array.boughtqty3 = boughtqty3
    array.soldqty3 = soldqty3
    array.bought7 = bought7
	array.sold7 = sold7
    array.boughtqty7 = boughtqty7
    array.soldqty7 = soldqty7
    if sold3 then
        array.price = sold3
    elseif sold7 then
        array.price = sold7
    else
        array.price = sold
    end
    array.confidence = 1
    
	return array
end

function lib.IsValidAlgorithm()
	if not (BeanCounter) or not (BeanCounter.API.isLoaded) then return false end
	return true
end

function lib.CanSupplyMarket()
    if not (BeanCounter) or not (BeanCounter.API.isLoaded) then return false end
	return true
end

function lib.OnLoad(addon)
	AucAdvanced.Settings.SetDefault("stat.sales.tooltip", true)
    AucAdvanced.Settings.SetDefault("stat.sales.avg", true)
    AucAdvanced.Settings.SetDefault("stat.sales.avg3", true)
    AucAdvanced.Settings.SetDefault("stat.sales.avg7", true)
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
	
	if not AucAdvanced.Settings.GetSetting("stat.sales.tooltip") or not (BeanCounter.API.isLoaded) then return end --If beancounter disabled itself, boughtseen etc are nil and throw errors
	
	local bought, sold, boughtqty, soldqty, boughtseen, soldseen, bought3, sold3, boughtqty3, soldqty3, bought7, sold7, boughtqty7, soldqty7 = lib.GetPrice(hyperlink)
	
    if (boughtseen+soldseen>0) then
		EnhTooltip.AddLine(libName.." prices:")
		EnhTooltip.LineColor(0.3, 0.9, 0.8)
    
        if AucAdvanced.Settings.GetSetting("stat.sales.avg3") then
            if (boughtqty3 > 0) then
                EnhTooltip.AddLine("  3 Days Bought |cffddeeff"..(boughtqty3).."|r at avg each", bought3)
                EnhTooltip.LineColor(0.3, 0.9, 0.8)
            end
            if (soldqty3 > 0) then
                EnhTooltip.AddLine("  3 Days Sold |cffddeeff"..(soldqty3).."|r at avg each", sold3)
                EnhTooltip.LineColor(0.3, 0.9, 0.8)
            end
        end
        if AucAdvanced.Settings.GetSetting("stat.sales.avg7") then
            if (boughtqty7 > 0) then
                EnhTooltip.AddLine("  7 Days Bought |cffddeeff"..(boughtqty7).."|r at avg each", bought7)
                EnhTooltip.LineColor(0.3, 0.9, 0.8)
            end
            if (soldqty7 > 0) then
                EnhTooltip.AddLine("  7 Days Sold |cffddeeff"..(soldqty7).."|r at avg each", sold7)
                EnhTooltip.LineColor(0.3, 0.9, 0.8)
            end
        end
        if AucAdvanced.Settings.GetSetting("stat.sales.avg") then
            if (boughtseen > 0) then
                EnhTooltip.AddLine("  Total Bought |cffddeeff"..(boughtqty).."|r at avg each", bought)
                EnhTooltip.LineColor(0.3, 0.9, 0.8)
            end
            if (soldseen > 0) then
                EnhTooltip.AddLine("  Total Sold |cffddeeff"..(soldqty).."|r at avg each", sold)
                EnhTooltip.LineColor(0.3, 0.9, 0.8)
            end
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
	gui:AddControl(id, "Checkbox",   0, 2, "stat.sales.avg3", "Display Moving 3 Day Average")
   	gui:AddTip(id, "Toggle display of 3-Day Average from the Sales module on or off")
	gui:AddControl(id, "Checkbox",   0, 2, "stat.sales.avg7", "Display Moving 7 Day Average")
	gui:AddTip(id, "Toggle display of 7-Day Average from the Sales module on or off")
	gui:AddControl(id, "Checkbox",   0, 2, "stat.sales.avg", "Display Permanent Average")
	gui:AddTip(id, "Toggle display of Permanent Average from the Sales module on or off")
	end
    
--[[Bootstrap Code]]
private.scriptframe = CreateFrame("Frame")
private.scriptframe:SetScript("OnEvent", private.onEvent)


AucAdvanced.RegisterRevision("$URL$", "$Rev$")