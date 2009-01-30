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
local faction, scanid

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

	local sig = GetRealmName().."-"..faction..":"..itemId..":"..itemSuffix
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
	if not AucDbData then AucDbData = {} end
	if not AucDbData.scans then AucDbData.scans = {} end
	if not AucDbData.scans[faction] then AucDbData.scans[faction] = {} end
end

function private.process(operation, itemData, oldData)
	if (faction and scanid) then
		if not rope:IsEmpty() then rope:Add(";") end
		rope:AddDelimited(":", itemData.itemId, itemData.itemSuffix, itemData.itemEnchant, itemData.itemFactor, itemData.itemSeed, itemData.stackSize, itemData.sellerName, itemData.minBid, itemData.buyoutPrice, itemData.curBid, itemData.timeLeft)

		AucDbData.names[("%d:%d:%d"):format(itemData.itemId,itemData.itemSuffix,0)] = itemData.itemName;
	end
end
function private.complete()
	AucDbData.scans[faction][scanid] = rope:Get()
	rope:Clear()
end

function private.bid(operation, itemData, bidType, index, bid)
	local prevLine = ""
	local timeidx = getTime()
	local faction = AucAdvanced.GetFaction()
	local line = strjoin(":", itemData.itemId,itemData.itemSuffix,itemData.itemEnchant, itemData.itemFactor, itemData.itemSeed, itemData.stackSize, itemData.sellerName, itemData.minBid, itemData.buyoutPrice, itemData.curBid, itemData.timeLeft, bidType, bid)
	print("Accepted bid for", itemData.itemName)

	if not AucDbData then AucDbData = {} end
	if not AucDbData.bids then AucDbData.bids = {} end
	if not AucDbData.names then AucDbData.names = {} end
	if not AucDbData.bids[faction] then AucDbData.bids[faction] = {} end
	if AucDbData.bids[faction][timeidx] then prevLine = AucDbData.bids[faction][timeidx] .. ";" end

	AucDbData.names[("%d:%d:%d"):format(itemData.itemId,itemData.itemSuffix,0)] = itemData.itemName;
	AucDbData.bids[faction][timeidx] = prevLine .. line
end

function private.start(operation, itemData, minBid, buyoutPrice, runTime, price)
	local prevLine = ""
	local timeidx = getTime()
	local dayidx = math.floor(timeidx / 86400)
	local faction = AucAdvanced.GetFaction()
	local line = strjoin(":", itemData.itemId,itemData.itemSuffix,itemData.itemEnchant, itemData.itemFactor, itemData.itemSeed, itemData.stackSize, itemData.sellerName, itemData.minBid, itemData.buyoutPrice, itemData.curBid, itemData.timeLeft)
	print("Started auction for", itemData.itemName)

	if not AucDbData then AucDbData = {} end
	if not AucDbData.start then AucDbData.start = {} end
	if not AucDbData.names then AucDbData.names = {} end
	if not AucDbData.price then AucDbData.price = {} end
	if not AucDbData.count then AucDbData.count = {} end
	if not AucDbData.start[faction] then AucDbData.start[faction] = {} end
	if AucDbData.start[faction][timeidx] then prevLine = AucDbData.start[faction][timeidx] .. ";" end

	local sig = ("%d:%d:%d"):format(itemData.itemId,itemData.itemSuffix,0)
	AucDbData.names[sig] = itemData.itemName;
	AucDbData.price[itemData.itemId] = price;
	AucDbData.start[faction][timeidx] = prevLine .. line

	sig = ("%d:%d"):format(itemData.itemId,itemData.itemSuffix)
	if not AucDbData.count[faction] then AucDbData.count[faction] = {} end
	if not AucDbData.count[faction][sig] then AucDbData.count[faction][sig] = {} end
	if AucDbData.count[faction][sig][dayidx] then prevLine = AucDbData.count[faction][sig][dayidx] .. ";" end
	AucDbData.count[faction][sig][dayidx] = prevLine .. strjoin(":", itemData.buyoutPrice, itemData.stackSize, runTime)
end

function private.sale(operation, faction, itemName, playerName, bid, buyout, deposit, consignment)
	local realmName = GetRealmName()
	faction = realmName .. "-" .. faction
	local prevLine = ""
	local timeidx = getTime()
	local realmfaction = GetRealmName() .. "-" .. faction
	local itemLink, itemId, itemSuffix = private.getLink(itemName)
	if not itemLink then return end
	local count = private.guessCount(itemId, itemSuffix, faction, deposit, buyout)
	if not count then return end

	local line = strjoin(":", itemId,itemSuffix,0,0,0,count,UnitName("player"),0,buyout,bid,0)
	print("Processed sale for", itemName)

	if not AucDbData then AucDbData = {} end
	if not AucDbData.start then AucDbData.start = {} end
	if not AucDbData.sales[faction] then AucDbData.sales[faction] = {} end
	if AucDbData.sales[faction][timeidx] then prevLine = AucDbData.sales[faction][timeidx] .. ";" end

	AucDbData.sales[faction][timeidx] = prevLine .. line
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


