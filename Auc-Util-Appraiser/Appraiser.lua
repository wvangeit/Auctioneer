--[[
	Auctioneer Advanced - Appraisals and Auction Posting
	Version: <%version%> (<%codename%>)
	Revision: $Id$
	URL: http://auctioneeraddon.com/

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

local libType, libName = "Util", "Appraiser"
local lib,parent,private = AucAdvanced.NewModule(libType, libName)
if not lib then return end
local print,decode,recycle,acquire,clone,scrub,get,set,default = AucAdvanced.GetModuleLocals()

local data, _
local ownResults = {}
local ownCounts = {}

function lib.Processor(callbackType, ...)
	if (callbackType == "tooltip") then
		lib.ProcessTooltip(...)
	elseif (callbackType == "auctionui") then
        private.CreateFrames(...)
	elseif (callbackType == "config") then
		private.SetupConfigGui(...)
	elseif (callbackType == "configchanged") then
		if private.frame then
			private.frame.salebox.config = true
			private.frame.SetPriceFromModel()
			private.frame.UpdateControls()
			private.frame.salebox.config = nil
		end
	elseif (callbackType == "inventory") then
		if private.frame and private.frame:IsVisible() then
			private.frame.GenerateList()
		end
	elseif (callbackType == "scanstats") then
		if private.frame then
			private.frame.cache = {}
			private.frame.GenerateList()
			private.frame.UpdateImage()
		end
	elseif (callbackType == "postresult") then
		private.frame.Reselect(select(3, ...))
	end
end

function lib.GetSigFromLink(link)
	local sig
	local itype, id, suffix, factor, enchant, seed = AucAdvanced.DecodeLink(link)
	if itype == "item" then
		if enchant ~= 0 then
			sig = ("%d:%d:%d:%d"):format(id, suffix, factor, enchant)
		elseif factor ~= 0 then
			sig = ("%d:%d:%d"):format(id, suffix, factor)
		elseif suffix ~= 0 then
			sig = ("%d:%d"):format(id, suffix)
		else
			sig = tostring(id)
		end
	else
		print("Link is not item")
	end
	return sig
end

function lib.GetLinkFromSig(sig)
	local link
	local id, suffix, factor, enchant = strsplit(":", sig)
	if not suffix then suffix = "0" end
	if not factor then factor = "0" end
	if not enchant then enchant = "0" end
	
	link = ("item:%d:%d:0:0:0:0:%d:%d"):format(id, enchant, suffix, factor)
	_, link = GetItemInfo(link)
	return link
end

function lib.ProcessTooltip(frame, name, hyperlink, quality, quantity, cost, additional)
	if not AucAdvanced.Settings.GetSetting("util.appraiser.enable") then return end
	if not AucAdvanced.Settings.GetSetting("util.appraiser.model") then return end

	local sig = lib.GetSigFromLink(hyperlink)
	if sig then
		local curModel = AucAdvanced.Settings.GetSetting('util.appraiser.item.'..sig..".model") or "default"
		if curModel == "default" then
			curModel = AucAdvanced.Settings.GetSetting("util.appraiser.model") or "market"
		end

		local value
		if curModel == "fixed" then
			value = AucAdvanced.Settings.GetSetting("util.appraiser.item."..sig..".fixed.buy")
			if not value then
				value = AucAdvanced.Settings.GetSetting("util.appraiser.item."..sig..".fixed.bid")
			end
		elseif curModel == "market" then
			value = AucAdvanced.API.GetMarketValue(hyperlink)
		else
			value = AucAdvanced.API.GetAlgorithmValue(curModel, hyperlink)
		end

		if value then
			EnhTooltip.AddLine("Appraiser |cffddeeff("..curModel..")|r x|cffddeeff"..quantity.."|r", value * quantity)
			EnhTooltip.LineColor(0.3, 0.9, 0.8)
		end
	end
    if AucAdvanced.Settings.GetSetting("util.appraiser.ownauctions") then
        -- Just to make sure it has the data seeing it likes to not load when you first load the auction house currently
        local numBatchAuctions, totalAuctions = GetNumAuctionItems("owner");
        if numBatchAuctions > 0 and totalAuctions > 0 and #ownCounts == 0 then
            lib.GetOwnAuctionDetails()
        end
    
        local itemName = name
        
        local colored = (AucAdvanced.Settings.GetSetting('util.appraiser.manifest.color') and AucAdvanced.Modules.Util.PriceLevel)
		
		local results = lib.ownResults[itemName]
		local counts = lib.ownCounts[itemName]
		
		if counts and #counts>0 then
            local sumBid, sumBO = 0, 0
            local countBid, countBO = 0, 0
			for _,count in ipairs(counts) do
				local res = results[count]
				sumBid = sumBid + res.sumBid --*res.stackCount
                sumBO = sumBO + res.sumBO --*res.stackCount
                countBid = countBid + res.countBid --*res.stackCount
                countBO = countBO + res.countBO --*res.stackCount
			end
            local avgBid =  countBid>0 and (sumBid / countBid) or nil
            local avgBO =  countBO>0 and (sumBO / countBO) or nil
            local r,g,b,_
			if colored then
				_, _, r,g,b = AucAdvanced.Modules.Util.PriceLevel.CalcLevel(hyperlink, 1, avgBid, avgBO)
			end
			r,g,b = r or 1,g or 1, b or 1
			
            EnhTooltip.AddLine(format("  Posted %2d at avg/ea", countBO or countBid)..
				(avgBO and "" or " (bid)"), avgBO or avgBid)
            EnhTooltip.LineColor(r,g,b)    
		end
    end
end

function lib.OnLoad()
	AucAdvanced.Settings.SetDefault("util.appraiser.model", "market")
end

function lib.CanSupplyMarket()
	return false
end

function lib.GetPrice(link, _, match)
	local sig = lib.GetSigFromLink(link)
	local curModel, curModelText
	
	if not sig then
       	return 0, 0, false, 0, "Unknown", "", 0, 0, 0
	end
	
	curModel = AucAdvanced.Settings.GetSetting("util.appraiser.item."..sig..".model") or "default"
	curModelText = curModel
	
	if match then
		match = AucAdvanced.Settings.GetSetting("util.appraiser.item."..sig..".match")
		if match == nil then
			match = AucAdvanced.Settings.GetSetting("util.appraiser.match")
		end
	end
	
	local newBuy, newBid, seen, _, DiffFromModel, MatchString
	if curModel == "default" then
		curModel = AucAdvanced.Settings.GetSetting("util.appraiser.model") or "market"
		curModelText = curModelText.."("..curModel..")"
		if curModel == "market" then
			newBuy, seen = AucAdvanced.API.GetMarketValue(link)
		else
			newBuy, seen = AucAdvanced.API.GetAlgorithmValue(curModel, link)
		end
		if (not newBuy) or (newBuy == 0) then
			curModel = AucAdvanced.Settings.GetSetting("util.appraiser.altModel")
			if curModel == "market" then
				newBuy, seen = AucAdvanced.API.GetMarketValue(link)
			else
				newBuy, seen = AucAdvanced.API.GetAlgorithmValue(curModel, link)
			end
		end
	elseif curModel == "fixed" then
		newBuy = AucAdvanced.Settings.GetSetting("util.appraiser.item."..sig..".fixed.buy")
		newBid = AucAdvanced.Settings.GetSetting("util.appraiser.item."..sig..".fixed.bid")
		seen = 99
	elseif curModel == "market" then
		newBuy, seen = AucAdvanced.API.GetMarketValue(link)
	else
		newBuy, seen = AucAdvanced.API.GetAlgorithmValue(curModel, link)
	end
	if match then
		local biddown
		if curModel == "fixed" then
			if newBuy and newBuy > 0 then
				biddown = newBid/newBuy
				newBuy, _, _, DiffFromModel, MatchString = AucAdvanced.API.GetBestMatch(link, newBuy)
				newBid = newBuy * biddown
			end
		else
			newBuy, _, _, DiffFromModel, MatchString = AucAdvanced.API.GetBestMatch(link, newBuy)
		end
	end
	if curModel ~= "fixed" then
		if newBuy and not newBid then
			local markdown = math.floor(AucAdvanced.Settings.GetSetting("util.appraiser.bid.markdown") or 0)/100
			local subtract = AucAdvanced.Settings.GetSetting("util.appraiser.bid.subtract") or 0
			local deposit = AucAdvanced.Settings.GetSetting("util.appraiser.bid.deposit") or false
			if deposit then
				local rate
				deposit, rate = AucAdvanced.Post.GetDepositAmount(sig)
				if not rate then rate = AucAdvanced.depositRate or 0.05 end
			end
			if (not deposit) then deposit = 0 end
			
			deposit = deposit * 2
			
			markdown = newBuy * markdown
			
			newBid = math.max(newBuy - markdown - subtract - deposit, 1)
		end
		
		if newBid and (not newBuy or newBid > newBuy) then
			newBuy = newBid
		end
	end

	local stack = AucAdvanced.Settings.GetSetting("util.appraiser.item."..sig..".stack") or AucAdvanced.Settings.GetSetting("util.appraiser.stack")
	local number = AucAdvanced.Settings.GetSetting("util.appraiser.item."..sig..".number") or AucAdvanced.Settings.GetSetting("util.appraiser.number")
	local duration = AucAdvanced.Settings.GetSetting("util.appraiser.item."..sig..".duration") or AucAdvanced.Settings.GetSetting("util.appraiser.duration")
		
	if stack == "max" then
		_, _, _, _, _, _, _, stack = GetItemInfo(link)
	end
	if number == "maxplus" then
		number = -1
	elseif number == "maxfull" then
		number = -2
	end
	number = tonumber(number)
--	if (type(stack) ~= "number") or (type(number) ~= "number") then
--		print("Stack: "..stack.."  Number: "..number)
--		print("Stack: "..type(stack).."  Number: "..type(number))
--	end
	if not newBuy then
		newBuy = 0
	end
	return newBuy, newBid, false, seen, curModelText, MatchString, stack, number, duration
end

function lib.GetPriceColumns()
	return "Buyout", "Bid", false, "seen", "curModelText", "MatchString", "Stack", "Number", "Duration"
end

local array = {}
--returns pricing and posting settings
function lib.GetPriceArray(link, _, match)
	while (#array > 0) do table.remove(array) end
	
	local newBuy, newBid, _, seen, curModelText, MatchString, stack, number, duration = lib.GetPrice(link, _, match)
	
	array.price = newBuy
	array.seen = seen
	
	array.stack = stack
	array.number = number
	array.duration = duration
	
	return array
end

function lib.GetOwnAuctionDetails()
    local results = {}
    local counts = {}		
    local numBatchAuctions, totalAuctions = GetNumAuctionItems("owner");
	for i=1, totalAuctions do
		local name, _, count, _, _, _, minBid, minIncrement, buyoutPrice, bidAmount, highBidder, owner  = GetAuctionItemInfo("owner", i)
        if not results[name] then
            results[name] = {}
            counts[name] = {}
		end
		local r = results[name][count] 
		if not r then
			r = { stackCount=0, countBid=0, sumBid=0, countBO=0, sumBO=0 }
			results[name][count] = r
			tinsert(counts[name], count)
		end
		if (minBid or 0)>0 then
			r.countBid = r.countBid + count
            r.sumBid = r.sumBid + bidAmount
        end
        if (buyoutPrice or 0)>0 then
            r.countBO = r.countBO + count
            r.sumBO = r.sumBO + buyoutPrice
        end
        r.stackCount = r.stackCount + 1
    end
    lib.ownResults = results
    lib.ownCounts = counts
end



AucAdvanced.RegisterRevision("$URL$", "$Rev$")