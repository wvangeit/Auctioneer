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
--]]

--[[

Auctioneer Scanning Engine.

If you supply a category, that category will be scanned to completion and then the "image" will be updated.
If you do not supply a category, then the whole AH will be scanned and then replace the current "image"

--]]

local libName = "Simple"

AucAdvanced.Modules.Scan[libName] = {}
local lib = AucAdvanced.Modules.Scan[libName]
lib.Print = AucAdvanced.Print
for k, v in pairs(AucAdvanced.Const) do lib[k] = v end

lib.isScanning = false
lib.curPage = 0
lib.curCat = nil


function lib.OnLoad()
	if not AucAdvancedScanSimpleData then AucAdvancedScanSimpleData = {} end
	if not AucAdvancedScanSimpleLocal then AucAdvancedScanSimpleLocal = {} end
	local data = AucAdvancedScanSimpleData
	local ldata = AucAdvancedScanSimpleLocal
	if data.lastScan then
		local faction = AucAdvanced.GetFaction()
		if data.lastScan.faction ~= faction then
			data.lastScan = ldata.lastScan
		end
	end

	if data.lastScan and data.lastScan.time then
		if time() - data.lastScan.time > 86400 then
			data.lastScan = {}
		end
	end
	ldata.lastScan = data.lastScan
	collectgarbage()
end

function lib.StartScan(cat)
	if AuctionFrame and AuctionFrame:IsVisible() then
		lib.curCat = cat
		lib.curScan = nil
		lib.isScanning = true
		lib.ScanPage(0)
	else
		message("Steady on; You'll need to talk to the auctioneer first!")
	end
end

function lib.IsScanning()
	if (lib.isScanning) then
		if (AuctionFrame and AuctionFrame:IsVisible()) then
			return true
		else
			lib.isPaused = true
		end
	else
		lib.isPaused = false
	end
	return false
end

function lib.Unpack(item, storage)
	if not storage then storage = {} end
	storage.link = item[lib.LINK]
	storage.useLevel = item[lib.ULEVEL]
	storage.itemLevel = item[lib.ILEVEL]
	storage.itemType = item[lib.ITYPE]
	storage.subType = item[lib.ISUB]
	storage.equipPos = item[lib.IEQUIP]
	storage.price = item[lib.PRICE]
	storage.timeLeft = item[lib.TLEFT]
	storage.seenTime = item[lib.TIME]
	storage.itemName = item[lib.NAME]
	storage.texture = item[lib.TEXTURE]
	storage.stackSize = item[lib.COUNT]
	storage.quality = item[lib.QUALITY]
	storage.canUse = item[lib.CANUSE]
	storage.minBid = item[lib.MINBID]
	storage.curBid = item[lib.CURBID]
	storage.increment = item[lib.MININC]
	storage.sellerName = item[lib.SELLER]
	storage.buyoutPrice = item[lib.BUYOUT]
	storage.dataFlag = item[lib.FLAG]
	return storage
end

function lib.IsIdentical(focus, compare)
	for i = 1, lib.SELLER do
		if (i ~= lib.TIME and focus[i] ~= compare[i]) then
			return false
		end
	end
	return true
end
function lib.IsSameItem(focus, compare, onlyDirt)
	if onlyDirt then
		local flag = focus[lib.FLAG]
		if not flag or bit.band(flag, lib.FLAG_DIRTY) == 0 then
			return false
		end
	end
	if (focus[lib.LINK] ~= compare[lib.LINK]) then return false end
	if (focus[lib.COUNT] ~= compare[lib.COUNT]) then return false end
	if (focus[lib.MINBID] ~= compare[lib.MINBID]) then return false end
	if (focus[lib.BUYOUT] ~= compare[lib.BUYOUT]) then return false end
	if (focus[lib.CURBID] > compare[lib.CURBID]) then return false end
	local focusOwner = focus[lib.SELLER]
	local compareOwner = compare[lib.SELLER]
	if (focusOwner ~= "" and compareOwner ~= "" and focusOwner ~= compareOwner) then
		return false
	end
	return true
end

function lib.FindItem(item, image, lut)
	local focus

	-- If we have a lookuptable, then we don't need to scan the whole lot
	if (lut) then
		local list = lut[item[lib.LINK]]
		if not list then return false
		elseif type(list) == "number" then
			if (lib.IsSameItem(image[list], item, true)) then return list end
		else
			local pos
			for i=1, #list do
				pos = list[i]
				if (lib.IsSameItem(image[pos], item, true)) then return pos end
			end
		end
	else
		-- We need to scan the whole thing cause there's no lookup table
		for i = 1, #image do
			if (lib.IsSameItem(image[i], item, true)) then return i end
		end
	end
end

local statItem = {}
local statItemOld = {}
local function processStats(operation, curItem, oldItem)
	lib.Unpack(curItem, statItem)
	if (oldItem) then lib.Unpack(oldItem, statItemOld) end
	for engine, engineLib in pairs(AucAdvanced.Modules.Stat) do
		if (engineLib.Processor) then
			if (oldItem) then
				engineLib.Processor("scan", operation, statItem, statItemOld)
			else
				engineLib.Processor("scan", operation, statItem)
			end
		end
	end
end

function lib.Commit()
	local now = time()
	local inscount, delcount = 0, 0
	if not lib.curScan then return end
	if not lib.image then
		local last = AucAdvancedScanSimpleData.lastScan
		if last and last.time and now-last.time<86400 and last.faction==AucAdvanced.GetFaction() then
			lib.image = last.image
		else
			lib.image = {}
		end
	end

	local list, link, flag
	local lut = {}

	-- Mark all matching auctions as DIRTY, and build a LookUpTable
	for pos, data in ipairs(lib.image) do
		if (not lib.curCat or lib.CLASSES[lib.curCat] == data[lib.ITYPE]) then
			-- Mark dirty
			flag = data[lib.FLAG] or 0
			data[lib.FLAG] = bit.bor(flag, lib.FLAG_DIRTY)

			-- Build lookup table
			link = data[lib.LINK]

			list = lut[link]
			if (not list) then
				lut[link] = pos
			else
				if (type(list) == "number") then
					lut[link] = {}
					table.insert(lut[link], list)
				end
				table.insert(lut[link], pos)
			end
		end
	end

	local itemPos
	local oldCount = #lib.image
	local scanCount = #lib.curScan
	local updateCount, sameCount, newCount, suspendCount, removeCount, resumeCount = 0,0,0,0,0,0
	for _, data in ipairs(lib.curScan) do
		itemPos = lib.FindItem(data, lib.image, lut)
		if (itemPos) then
			if not lib.IsIdentical(lib.image[itemPos], data) then
				if (bit.band(flag, lib.FLAG_UNSEEN) > 0) then
					-- If it has been recorded as suspended
					processStats("resume", data, lib.image[itemPos])
					resumeCount = resumeCount + 1
				else
					processStats("update", data, lib.image[itemPos])
					updateCount = updateCount + 1
				end
			else
				processStats("leave", data)
				sameCount = sameCount + 1
			end
			lib.image[itemPos] = data
		else
			processStats("create", data)
			table.insert(lib.image, data)
			newCount = newCount + 1
		end
	end

	local data, flag
	for pos = #lib.image, 1, -1 do
		data = lib.image[pos]
		flag = data[lib.FLAG]
		if (flag and bit.band(flag, lib.FLAG_DIRTY) > 0) then
			-- This item should have been seen, but wasn't
			if (now - data[lib.TIME] < 86400) then
				suspendCount = suspendCount + 1
				-- Don't delete it yet. It may have been either skipped, or may be awaiting relist
				if (bit.band(flag, lib.FLAG_UNSEEN) == 0) then
					-- If it hasn't been recorded as suspended yet, do so
					data[lib.FLAG] = bit.bor(flag, lib.FLAG_UNSEEN)
					processStats("suspend", data)
				end
			else
				-- Haven't seen this item in ages
				processStats("delete", data)
				table.remove(lib.image, pos)
				removeCount = removeCount + 1
			end
		end
	end
	local currentCount = #lib.image

	if (updateCount + sameCount + newCount ~= scanCount) then
		lib.Print(("Warning, discrepency in scan count: {{%d + %d + %d != %d}}"):format(updateCount, sameCount, newCount, scanCount))
	end
	
	if (oldCount - removeCount + newCount ~= currentCount) then
		lib.Print(("Warning, discrepency in current count: {{%d - %d + %d != %d}}"):format(oldCount, removeCount, newCount, currentCount))
	end

	lib.Print("Auctioneer Advanced finished scanning {{"..scanCount.."}} auctions:")
	lib.Print("  {{"..oldCount.."}} items in DB at start")
	lib.Print("  {{"..sameCount.."}} unchanged items")
	lib.Print("  {{"..newCount.."}} new items")
	lib.Print("  {{"..updateCount.."}} updated items")
	lib.Print("  {{"..resumeCount.."}} resumed items")
	lib.Print("  {{"..removeCount.."}} removed items")
	lib.Print("  {{"..currentCount.."}} items in DB at end")
	lib.Print("  ({{"..suspendCount.."}} of these are suspended)")

	AucAdvancedScanSimpleLocal.lastScan = {
		image = lib.image,
		faction = AucAdvanced.GetFaction(),
		time = time(),
	}
	AucAdvancedScanSimpleData.lastScan = AucAdvancedScanSimpleLocal.lastScan
	
	lib.curScan = nil
end

function lib.ScanPage(nextPage)
	if (lib.IsScanning()) then
		lib.curPage = nextPage
		lib.Hook.QueryAuctionItems("", "", "", nil, lib.curCat, nil, nextPage, nil, nil)
		AuctionFrameBrowse.page = nextPage
	end
end

function lib.StorePage()
	if not lib.IsScanning() then return end
	if lib.isPaused then
		lib.isPaused = false
		lib.ScanPage(lib.curPage)
		return
	end
	local numBatchAuctions, totalAuctions = GetNumAuctionItems("list");
	local maxPages = floor(totalAuctions / 50);
	if not lib.curScan then lib.curScan = {} end

	local curTime = time()

	-- Take a picture of everything we've got on the page so far.
	local _, itemLink, itemLevel, itemType, itemSubType, itemEquipLoc
	local timeLeft, name, texture, count, quality, canUse, level, minBid
	local minIncrement, buyoutPrice, bidAmount, highBidder, owner
	local invType, nextBid
	
	local storecount = 0
	for i = 1, numBatchAuctions do
		local itemLink = GetAuctionItemLink("list", i)
		if itemLink then
			local _,_,_,itemLevel,_,itemType,itemSubType,_,itemEquipLoc,_ = GetItemInfo(itemLink)
			timeLeft = GetAuctionItemTimeLeft("list", i)
			name, texture, count, quality, canUse, level, minBid,
			minIncrement, buyoutPrice, bidAmount, highBidder, owner =
			GetAuctionItemInfo("list", i)
			invType = lib.InvTypes[itemEquipLoc]
			buyoutPrice = buyoutPrice or 0
			nextBid = minBid
			if bidAmount then nextBid = bidAmount + minIncrement end
			if not count or count == 0 then count = 1 end
			if not highbidder then highbidder = false
			else highbidder = true end
			if not owner then owner = "" end

			local itemData = {
				itemLink, itemLevel, itemType, itemSubType, invType, nextBid,
				timeLeft, curTime, name, texture, count, quality, canUse, level,
				minBid, minIncrement, buyoutPrice, bidAmount, highBidder, owner
			}

			-- If we're going backwards
			if lib.scanDir == -1 then
				-- and this item wasn't in the last (next) page
				if noDupes(lastPage, itemData) then
					table.insert(thisPage, itemData)
					table.insert(lib.curScan, itemData)
					storecount = storecount + 1
				end
			-- Otherwise if we scan forwards, always add
			else
				table.insert(lib.curScan, itemData)
				storecount = storecount + 1
			end
		end
	end

	-- Store the last page for duplicate detection
	lastPage = thisPage

	-- Send the next page query or finish scanning
	if lib.curPage < maxPages then
		lib.ScanPage(lib.curPage + 1)
	else
		lib.isScanning = false
		lib.Commit()
	end
end

function lib.ClassConvert(cid, sid)
	if (sid) then
		return lib.SUBCLASSES[cid][sid]
	end
	return lib.CLASSES[cid]
end

local curQuery = { empty = true }
local curResults = {}

function lib.GetResults()
	if not lib.image then return end
	lib.ButtonMode(true)

	local invalid = false
	for k,v in pairs(lib.curQuery) do
		if k ~= "page" and v ~= curQuery[k] then invalid = true end
	end
	for k,v in pairs(curQuery) do
		if k ~= "page" and v ~= lib.curQuery[k] then invalid = true end
	end
	if not invalid then return curResults end

	local numResults = #curResults
	for i=1, numResults do curResults[i] = nil end
	for k,v in pairs(curQuery) do curQuery[k] = nil end
	for k,v in pairs(lib.curQuery) do curQuery[k] = v end

	local ptr, max = 1, #lib.image
	while ptr <= max do
		repeat
			local data = lib.image[ptr] ptr = ptr + 1
			if (not data) then break end
			if curQuery.minUseLevel and data[lib.ULEVEL] < curQuery.minUseLevel then break end
			if curQuery.maxUseLevel and data[lib.ULEVEL] > curQuery.maxUseLevel then break end
			if curQuery.minItemLevel and data[lib.ILEVEL] < curQuery.minItemLevel then break end
			if curQuery.maxItemLevel and data[lib.ILEVEL] > curQuery.maxItemLevel then break end
			if curQuery.class and data[lib.ITYPE] ~= curQuery.class then break end
			if curQuery.subclass and data[lib.ISUB] ~= curQuery.subclass then break end
			if curQuery.quality and data[lib.QUALITY] ~= curQuery.quality then break end
			if curQuery.invType and data[lib.IEQUIP] ~= curQuery.invType then break end
			if curQuery.seller and data[lib.SELLER] ~= curQuery.seller then break end
			if curQuery.name then
				local name = data[lib.NAME]
				if not (name and name:lower():find(curQuery.name:lower(), 1, true)) then break end
			end

			local stack = data[lib.COUNT]
			local nextBid = data[lib.PRICE]
			local buyout = data[lib.BUYOUT]
			if curQuery.perItem and stack > 1 then
				nextBid = math.ceil(nextBid / stack)
				buyout = math.ceil(buyout / stack)
			end
			if curQuery.minStack and stack < curQuery.minStack then break end
			if curQuery.maxStack and stack > curQuery.maxStack then break end
			if curQuery.minBid and nextBid < curQuery.minBid then break end
			if curQuery.maxBid and nextBid > curQuery.maxBid then break end
			if curQuery.minBuyout and buyout < curQuery.minBuyout then break end
			if curQuery.maxBuyout and buyout > curQuery.maxBuyout then break end
		
			-- If we're still here, then we've got a winner
			table.insert(curResults, data)
		until true
	end	
	return curResults
end

lib.Hook = {}
lib.Hook.CanSendAuctionQuery = CanSendAuctionQuery
function CanSendAuctionQuery(...)
	-- Call the original hook
	local res = { lib.Hook.CanSendAuctionQuery(...) }
	if res[1] then
		if lib.IsScanning() then
			-- Take a snapshot of the page as it is currently
			lib.StorePage()
		end
	end
	
	return unpack(res)
end

lib.Hook.QueryAuctionItems = QueryAuctionItems
function QueryAuctionItems(name, minLevel, maxLevel, invTypeIndex, classIndex, subclassIndex, page, isUsable, qualityIndex)
	-- See if we are in caching mode.
	if lib.IsScanning() then
		query = {}
		minLevel = tonumber(minLevel) or 0
		maxLevel = tonumber(maxLevel) or 0
		classIndex = tonumber(classIndex) or 0
		subclassIndex = tonumber(subclassIndex) or 0
		qualityIndex = tonumber(qualityIndex)
		query.page = tonumber(page) or 0
		if (name and name ~= "") then query.name = name end
		if (minLevel > 0) then query.minUseLevel = minLevel end
		if (maxLevel > 0) then query.maxUseLevel = maxLevel end
		if (classIndex > 0) then query.class = lib.ClassConvert(classIndex) end
		if (subclassIndex > 0) then query.subclass = lib.ClassConvert(classIndex, subclassIndex) end
		if (qualityIndex and qualityIndex > 0) then query.quality = qualityIndex end
		if (invTypeIndex and invTypeIndex ~= "") then query.invType = invTypeIndex end
		lib.curQuery = query
		lib.curQuerySig = ("%s-%s-%s-%s-%s-%s-%s"):format(
			query.name or "", 
			query.minUseLevel or "",
			query.maxUseLevel or "",
			query.class or "",
			query.subclass or "",
			query.quality or "",
			query.invType or ""
		)
		lib.lastReq = GetTime()
	end
	lib.Hook.QueryAuctionItems(name, minLevel, maxLevel, invTypeIndex, classIndex, subclassIndex, page, isUsable, qualityIndex)
end

