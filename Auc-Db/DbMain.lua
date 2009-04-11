--[[
	AuctioneerDB
	Revision: $Id: DbCore.lua 3583 2008-10-11 16:50:02Z Norganna $
	Version: <%version%>

	This is an addon for World of Warcraft that integrates with the online
	auction database site at http://auctioneerdb.com.
	This addon provides detailed price data for auctionable items based off
	an online database that is contributed to by users just like you.
	If you want to contribute your data and keep your price up-to-date, you
	can easily update your pricelist by using the sychronization utility
	which is provided with this addon.
	To syncronize you data, run the SyncDb executable for your platform.

	License:
		AuctioneerDB AddOn for World of Warcraft.
		Copyright (C) 2007, Norganna's AddOns Pty Ltd.

		This program is free software: you can redistribute it and/or modify
		it under the terms of the GNU General Public License as published by
		the Free Software Foundation, either version 3 of the License, or
		(at your option) any later version.

		This program is distributed in the hope that it will be useful,
		but WITHOUT ANY WARRANTY; without even the implied warranty of
		MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
		GNU General Public License for more details.

		You should have received a copy of the GNU General Public License
		along with this program.  If not, see <http://www.gnu.org/licenses/>.

	Note:
		This AddOn's source code is specifically designed to work with
		World of Warcraft's interpreted AddOn system.
		You have an implicit license to use this AddOn with these facilities
		since that is its designated purpose as per:
		http://www.fsf.org/licensing/licenses/gpl-faq.html#InterpreterIncompat
--]]
LibStub("LibRevision"):Set("$URL: http://dev.norganna.org/auctioneer/trunk/Auc-Db/DbCore.lua $","$Rev: 3583 $","5.1.DEV.", 'auctioneer', 'libs')

if not AucDb or not AucDb.Enabled then return end
local lib = AucDb
local private = lib.Private

local print,decode,_,_,replicate,empty,get,set,default,debugPrint,fill = AucAdvanced.GetModuleLocals()

local function getTime()
	return time()
end

local rope = LibStub("StringRope"):New()
local faction, designation, scanid

local function RealmDesignation(faction, portal)
	local realm

	if not portal then portal = GetCVar("portal") or "??" end
	portal = portal:upper()

	if faction then
		local a,b = strsplit("-", faction)
		if a and b then
			realm, faction = a, b
		elseif a then
			realm, faction = GetRealmName(), a
		end
	end

	if (not realm or not faction) and AucAdvanced and AucAdvanced.GetFaction then
		local _, a, b = AucAdvanced.GetFaction()
		if not realm then realm = a end
		if not faction then faction = b end
	end

	if not realm then realm = GetRealmName() end

	if not realm then realm = "Unknown" end
	if not faction then faction = "Unknown" end
	return portal.."/"..realm.."-"..faction
end


function private.getLink(itemName)
	local _, itemLink = GetItemInfo(itemName)
	local itemId, itemSuffix
	if itemLink then
		_, itemId, itemSuffix = AucAdvanced.DecodeLink(itemLink)
	else
		for sig, name in pairs(AucDbData.names) do
			if name == itemName then
				itemId, itemSuffix = strsplit(":", sig)
				_, itemLink = GetItemInfo("item:"..itemId..":0:0:0:0:0:"..itemSuffix)
			end
		end
	end
	return itemLink, tonumber(itemId), tonumber(itemSuffix) or 0
end
AucDb.RealmDesignation = RealmDesignation

function private.getPrice(itemId)
	itemId = tonumber(itemId)
	if itemId then
		local price = AucDbData.price[itemId]
		if not price then
			price = GetSellValue(itemId)
		end
		return tonumber(price)
	end
end

function private.findDeposit(deposit, rate, price, buyout, ...)
	local n = select("#", ...)
	for i=1, n do
		local detail = select(i, ...)
		local detailBuyout, count, runTime = strsplit(":", detail)
		if buyout == detailBuyout then
			local run = runtime/720
			if deposit == 0 then return count, run end
			local total = math.floor(price * rate * count) * run
			if total == deposit then return count, run end
		end
	end
end

function private.guessCount(itemId, itemSuffix, faction, deposit, buyout)
	local price = private.getPrice(itemId)
	if price == nil then return end

	local rate = 0.15
	if faction:lower() == "neutral" then rate = 0.75 end

	local sig = designation..":"..itemId..":"..itemSuffix
	if AucDbData.count[sig] then
		local match
		for dayidx, details in pairs(AucDbData.count[sig]) do
			local count, run = private.findDeposit(deposit, rate, price, buyout, strsplit(";", details))
			if match then return count, run, true end
		end
	end
end


function private.begin()
	rope:Clear()
	scanid = getTime()
	faction = AucAdvanced.GetFaction()
	designation = RealmDesignation(faction)
	if not AucDbData then AucDbData = {} end
	if not AucDbData.scans then AucDbData.scans = {} end
	if not AucDbData.scans[designation] then AucDbData.scans[designation] = {} end
end

function private.process(operation, itemData, oldData)
	if (designation and scanid) then
		if not rope:IsEmpty() then rope:Add(";") end
		rope:AddDelimited(":", itemData.itemId, itemData.itemSuffix, itemData.itemEnchant, itemData.itemFactor, itemData.itemSeed, itemData.stackSize, itemData.sellerName, itemData.minBid, itemData.buyoutPrice, itemData.curBid, itemData.timeLeft)

		AucDbData.names[("%d:%d:%d"):format(itemData.itemId,itemData.itemSuffix,0)] = itemData.itemName;
	end
end
function private.complete()
	AucDbData.scans[designation][scanid] = rope:Get()
	rope:Clear()
end

function private.bid(operation, itemData, bidType, index, bid)
	local prevLine = ""
	local timeidx = getTime()
	local line = strjoin(":", itemData.itemId,itemData.itemSuffix,itemData.itemEnchant, itemData.itemFactor, itemData.itemSeed, itemData.stackSize, itemData.sellerName, itemData.minBid, itemData.buyoutPrice, itemData.curBid, itemData.timeLeft, bidType, bid)
	print("Accepted bid for", itemData.itemName)

	if not AucDbData then AucDbData = {} end
	if not AucDbData.bids then AucDbData.bids = {} end
	if not AucDbData.names then AucDbData.names = {} end
	if not AucDbData.bids[designation] then AucDbData.bids[designation] = {} end
	if AucDbData.bids[designation][timeidx] then prevLine = AucDbData.bids[designation][timeidx] .. ";" end

	AucDbData.names[("%d:%d:%d"):format(itemData.itemId,itemData.itemSuffix,0)] = itemData.itemName;
	AucDbData.bids[designation][timeidx] = prevLine .. line
end

function private.start(operation, itemData, minBid, buyoutPrice, runTime, price)
	local prevLine = ""
	local timeidx = getTime()
	local dayidx = math.floor(timeidx / 86400)
	local line = strjoin(":", itemData.itemId,itemData.itemSuffix,itemData.itemEnchant, itemData.itemFactor, itemData.itemSeed, itemData.stackSize, itemData.sellerName, itemData.minBid, itemData.buyoutPrice, itemData.curBid, itemData.timeLeft)
	print("Started auction for", itemData.itemName)

	if not AucDbData then AucDbData = {} end
	if not AucDbData.start then AucDbData.start = {} end
	if not AucDbData.names then AucDbData.names = {} end
	if not AucDbData.price then AucDbData.price = {} end
	if not AucDbData.count then AucDbData.count = {} end
	if not AucDbData.start[designation] then AucDbData.start[designation] = {} end
	if AucDbData.start[designation][timeidx] then prevLine = AucDbData.start[designation][timeidx] .. ";" end

	local sig = ("%d:%d:%d"):format(itemData.itemId,itemData.itemSuffix,0)
	AucDbData.names[sig] = itemData.itemName;
	AucDbData.price[itemData.itemId] = price;
	AucDbData.start[designation][timeidx] = prevLine .. line

	sig = ("%d:%d"):format(itemData.itemId,itemData.itemSuffix)
	if not AucDbData.count[designation] then AucDbData.count[designation] = {} end
	if not AucDbData.count[designation][sig] then AucDbData.count[designation][sig] = {} end
	if AucDbData.count[designation][sig][dayidx] then prevLine = AucDbData.count[designation][sig][dayidx] .. ";" end
	AucDbData.count[designation][sig][dayidx] = prevLine .. strjoin(":", itemData.buyoutPrice, itemData.stackSize, runTime)
end

function private.sale(operation, faction, itemName, playerName, bid, buyout, deposit, consignment)
	local prevLine = ""
	local timeidx = getTime()
	local designation = RealmDesignation(faction)
	local itemLink, itemId, itemSuffix = private.getLink(itemName)
	if not itemLink then return end
	local count = private.guessCount(itemId, itemSuffix, faction, deposit, buyout)
	if not count then return end

	local line = strjoin(":", itemId,itemSuffix,0,0,0,count,UnitName("player"),0,buyout,bid,0)
	print("Processed sale for", itemName)

	if not AucDbData then AucDbData = {} end
	if not AucDbData.start then AucDbData.start = {} end
	if not AucDbData.sales[designation] then AucDbData.sales[designation] = {} end
	if AucDbData.sales[designation][timeidx] then prevLine = AucDbData.sales[designation][timeidx] .. ";" end

	AucDbData.sales[designation][timeidx] = prevLine .. line
end

lib.ScanProcessors = {
	begin = private.begin,
	create = private.process,
	update = private.process,
	complete = private.complete,
	placebid = private.bid,
	aucsold = private.sale,
	newauc = private.start,
}


