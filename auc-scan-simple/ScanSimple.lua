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
]]

local libName = "Simple"
local libType = "Scan"

AucAdvanced.Modules[libType][libName] = {}
local lib = AucAdvanced.Modules[libType][libName]
local private = {}

lib.Print = AucAdvanced.Print
local Const = AucAdvanced.Const

private.isScanning = false

private.curPage = 0
private.curCat = nil


function lib.OnLoad()
	if not AucAdvancedScanSimpleData then AucAdvancedScanSimpleData = {} end
	local data = AucAdvancedScanSimpleData
--	collectgarbage("collect")
end

function lib.StartScan(cat, subcat)
	if AuctionFrame and AuctionFrame:IsVisible() then
		private.curCat = cat
		private.curScan = nil
		private.curSubCat = subcat
		private.isScanning = true
		private.scanStartTime = time()
		lib.ScanPage(0)
	else
		message("Steady on; You'll need to talk to the auctioneer first!")
	end
end

function lib.IsScanning()
	if (private.isScanning) then
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

function private.Unpack(item, storage)
	if not storage then storage = {} end
	storage.id = item[Const.ID]
	storage.link = item[Const.LINK]
	storage.useLevel = item[Const.ULEVEL]
	storage.itemLevel = item[Const.ILEVEL]
	storage.itemType = item[Const.ITYPE]
	storage.subType = item[Const.ISUB]
	storage.equipPos = item[Const.IEQUIP]
	storage.price = item[Const.PRICE]
	storage.timeLeft = item[Const.TLEFT]
	storage.seenTime = item[Const.TIME]
	storage.itemName = item[Const.NAME]
	storage.texture = item[Const.TEXTURE]
	storage.stackSize = item[Const.COUNT]
	storage.quality = item[Const.QUALITY]
	storage.canUse = item[Const.CANUSE]
	storage.minBid = item[Const.MINBID]
	storage.curBid = item[Const.CURBID]
	storage.increment = item[Const.MININC]
	storage.sellerName = item[Const.SELLER]
	storage.buyoutPrice = item[Const.BUYOUT]
	storage.dataFlag = item[Const.FLAG]
	return storage
end

function private.IsIdentical(focus, compare)
	for i = 1, Const.SELLER do
		if (i ~= Const.TIME and focus[i] ~= compare[i]) then
			return false
		end
	end
	return true
end

function private.IsSameItem(focus, compare, onlyDirt)
	if onlyDirt then
		local flag = focus[Const.FLAG]
		if not flag or bit.band(flag, Const.FLAG_DIRTY) == 0 then
			return false
		end
	end
	if (focus[Const.LINK] ~= compare[Const.LINK]) then return false end
	if (focus[Const.COUNT] ~= compare[Const.COUNT]) then return false end
	if (focus[Const.MINBID] ~= compare[Const.MINBID]) then return false end
	if (focus[Const.BUYOUT] ~= compare[Const.BUYOUT]) then return false end
	if (focus[Const.CURBID] > compare[Const.CURBID]) then return false end
	local focusOwner = focus[Const.SELLER]
	local compareOwner = compare[Const.SELLER]
	if (focusOwner ~= "" and compareOwner ~= "" and focusOwner ~= compareOwner) then
		return false
	end
	return true
end

function lib.FindItem(item, image, lut)
	local focus
	-- If we have a lookuptable, then we don't need to scan the whole lot
	if (lut) then
		local list = lut[item[Const.LINK]]
		if not list then return false
		elseif type(list) == "number" then
			if (private.IsSameItem(image[list], item, true)) then return list end
		else
			local pos
			for i=1, #list do
				pos = list[i]
				if (private.IsSameItem(image[pos], item, true)) then return pos end
			end
		end
	else
		-- We need to scan the whole thing cause there's no lookup table
		for i = 1, #image do
			if (private.IsSameItem(image[i], item, true)) then return i end
		end
	end
end

local statItem = {}
local statItemOld = {}
local function processStats(operation, curItem, oldItem)
	private.Unpack(curItem, statItem)
	if (oldItem) then private.Unpack(oldItem, statItemOld) end
	if (operation == "create") then
		--[[
			Filtering out happens here so we only have to do Unpack once.
			Only filter on create because once its in the system, dropping it can give the wrong impression to other mods.
			(it could think it was sold, for instance)
			Filters are part of the Util subsystem.
		]]
		for engine, engineLib in pairs(AucAdvanced.Modules.Util) do
			if (engineLib.AuctionFilter) then
				local result=engineLib.AuctionFilter(operation, statItem)
				if (result) then return false end
			end
		end
	end
	for system, systemMods in pairs(AucAdvanced.Modules) do
		for engine, engineLib in pairs(systemMods) do
			if (engineLib.ScanProcessors and engineLib.ScanProcessors[operation]) then
				if (oldItem) then
					engineLib.ScanProcessors[operation](operation, statItem, statItemOld)
				else
					engineLib.ScanProcessors[operation](operation, statItem)
				end
			end
		end
	end
	return true
end

function private.GetID(IDlist)
	for x1, x2 in pairs(IDlist) do
		if (x1 ~= "none_after") then
			if (x1==x2) then 
				IDlist[x1] = nil
			else
				IDlist[x1] = tonumber(x2)-1
			end
			return x2
		end
	end
	local retval = IDlist.none_after
	IDlist.none_after = retval+1
	return retval
end

function private.ReleaseID(IDlist, ID)
	if (not ID) then return end

	local setbefore = nil
	local setafter = nil
	
	for x1, x2 in pairs(IDlist) do
		if (x2) then
			x2 = tonumber(x2)
			if (x1 == "none_after") then
				if (x2-1==ID) then
					setafter=x1
				end
			else
				x1 = tonumber(x1)
				if (x1+1==ID) then
					setbefore = x1
				elseif (x2-1==ID) then
					setafter = x1
				end
			end
		end
	end
	if (setafter and setafter == "none_after" and setbefore) then
		IDlist["none_after"] = setbefore
		IDlist[setbefore] = nil
	elseif (setafter and setafter == "none_after") then
		IDlist["none_after"] = ID
	elseif (setafter and setbefore) then
		IDlist[setbefore] = IDlist[setafter]
		IDlist[setafter] = nil
	elseif (setafter) then
		IDlist[ID] = IDlist[setafter]
		IDlist[setafter] = nil
	elseif (setbefore) then
		IDlist[setbefore] = ID
	else
		IDlist[ID] = ID
	end	
end

function private.Commit()
	local now = time()
	local inscount, delcount = 0, 0
	if not private.curScan then return end

	local faction = AucAdvanced.GetFaction()
	local realmName = GetRealmName()

	if (AucAdvancedScanSimpleData and not AucAdvancedScanSimpleData.Version) then AucAdvancedScanSimpleData = {} end
	
	if not AucAdvancedScanSimpleData then AucAdvancedScanSimpleData = {Version = "1.0"} end
	if not AucAdvancedScanSimpleData.scans then AucAdvancedScanSimpleData.scans = {} end
	if not AucAdvancedScanSimpleData.scans[realmName] then AucAdvancedScanSimpleData.scans[realmName] = {} end
	if not AucAdvancedScanSimpleData.scans[realmName][faction] then AucAdvancedScanSimpleData.scans[realmName][faction] = {image = {}, nextID = {none_after=1}, time=now} end
	if not AucAdvancedScanSimpleData.scans[realmName][faction].image then AucAdvancedScanSimpleData.scans[realmName][faction].image = {} end

	local scandata = AucAdvancedScanSimpleData.scans[realmName][faction]
	private.image = scandata.image
	
	local list, link, flag
	local lut = {}

	-- Mark all matching auctions as DIRTY, and build a LookUpTable
	for pos, data in ipairs(private.image) do
		if (not private.curCat or Const.CLASSES[private.curCat] == data[Const.ITYPE])
			and (not private.curSubCat or (Const.SUBCLASSES[private.curCat] and Const.SUBCLASSES[private.curCat][private.curSubCat] == data[Const.ISUB])) then
			-- Mark dirty
			flag = data[Const.FLAG] or 0
			data[Const.FLAG] = bit.bor(flag, Const.FLAG_DIRTY)

			-- Build lookup table
			link = data[Const.LINK]

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
	local oldCount = #private.image
	local scanCount = #private.curScan
	local updateCount, sameCount, newCount, suspendCount, removeCount, resumeCount = 0,0,0,0,0,0
	for _, data in ipairs(private.curScan) do
		itemPos = lib.FindItem(data, private.image, lut)
		flag = data[Const.FLAG] or 0
		data[Const.FLAG] = bit.band(flag, bit.bnot(Const.FLAG_DIRTY))
		if (itemPos) then
			data[Const.ID] = private.image[itemPos][Const.ID]
			if not private.IsIdentical(private.image[itemPos], data) then				
				if (bit.band(flag, Const.FLAG_UNSEEN) > 0) then
					-- If it has been recorded as suspended
					processStats("resume", data, private.image[itemPos])
					resumeCount = resumeCount + 1
				else
					processStats("update", data, private.image[itemPos])
					updateCount = updateCount + 1
				end
			else
				processStats("leave", data)
				sameCount = sameCount + 1
			end
			private.image[itemPos] = data
		else
			if (processStats("create", data)) then
				data[Const.ID] = private.GetID(scandata.nextID)
				table.insert(private.image, data)
				newCount = newCount + 1
			else
				scanCount = scanCount - 1
			end
		end
	end

	local data, flag
	for pos = #private.image, 1, -1 do
		data = private.image[pos]
		flag = data[Const.FLAG]
		if (flag and bit.band(flag, Const.FLAG_DIRTY) > 0) then
			-- This item should have been seen, but wasn't
			local stillpossible = false
			local auctionmaxtime = Const.AucMinTimes[data[Const.TLEFT]] or 86400

			if (now - data[Const.TIME] <= auctionmaxtime) then
				stillpossible = true
			end

			if (stillpossible) then
				-- Don't delete it yet. It may have been either skipped, or may be awaiting relist
				suspendCount = suspendCount + 1
				if (bit.band(flag, Const.FLAG_UNSEEN) == 0) then
					-- If it hasn't been recorded as suspended yet, do so
					data[Const.FLAG] = bit.bor(flag, Const.FLAG_UNSEEN)
					processStats("suspend", data)
				else
					processStats("suspended", data)
				end
			else
				-- Auction Time has expired
				processStats("delete", data)
				private.ReleaseID(scandata.nextID, data[Const.ID])
				table.remove(private.image, pos)
				removeCount = removeCount + 1
			end

		end
	end
	local currentCount = #private.image

	if (updateCount + sameCount + newCount ~= scanCount) then
		lib.Print(("Warning, discrepency in scan count: {{%d + %d + %d != %d}}"):format(updateCount, sameCount, newCount, scanCount))
	end

	if (oldCount - removeCount + newCount ~= currentCount) then
		lib.Print(("Warning, discrepency in current count: {{%d - %d + %d != %d}}"):format(oldCount, removeCount, newCount, currentCount))
	end

	local scanTimeSecs = time() - private.scanStartTime
	local scanTimeMins = floor(scanTimeSecs / 60)
	scanTimeSecs =  mod(scanTimeSecs, 60)
	local scanTimeHours = floor(scanTimeMins / 60)
	scanTimeMins = mod(scanTimeMins, 60)
	
	lib.Print("Auctioneer Advanced finished scanning {{"..scanCount.."}} auctions:")
	lib.Print("  {{"..oldCount.."}} items in DB at start")
	lib.Print("  {{"..sameCount.."}} unchanged items")
	lib.Print("  {{"..newCount.."}} new items")
	lib.Print("  {{"..updateCount.."}} updated items")
	lib.Print("  {{"..resumeCount.."}} resumed items")
	lib.Print("  {{"..removeCount.."}} removed items")
	lib.Print("  {{"..currentCount.."}} items in DB at end")
	lib.Print("  ({{"..suspendCount.."}} of these are suspended)")
	local scanTime = "  "
	if (scanTimeHours and scanTimeHours ~= 0) then
		scanTime = scanTime.."{{"..scanTimeHours.."}} Hours "
	end
	if (scanTimeMins and scanTimeMins ~= 0) then
		scanTime = scanTime.."{{"..scanTimeMins.."}} Mins "
	end
	if (scanTimeSecs and scanTimeSecs ~= 0) then
		scanTime = scanTime.."{{"..scanTimeSecs.."}} Secs "
	end
	scanTime = scanTime.."Spent Scanning Auction House"
	lib.Print(scanTime)
		
	scandata.image = private.image
	private.image = nil
	private.curScan = nil
end

function lib.ScanPage(nextPage)
	if (lib.IsScanning()) then
		private.curPage = nextPage
		lib.Hook.QueryAuctionItems("", "", "", nil, private.curCat, private.curSubCat, nextPage, nil, nil)
		AuctionFrameBrowse.page = nextPage
	end
end

function lib.StorePage()
	if not lib.IsScanning() then return end
	if lib.isPaused then
		lib.isPaused = false
		lib.ScanPage(private.curPage)
		return
	end
	local numBatchAuctions, totalAuctions = GetNumAuctionItems("list");
	local maxPages = floor(totalAuctions / 50);
	if not private.curScan then private.curScan = {} end

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
			local _,_,_,itemLevel,_,itemType,itemSubType,_,itemEquipLoc = GetItemInfo(itemLink)
			--[[
				Returns Integer giving range of time left for query
				1 -- short time (Less than 30 mins)
				2 -- medium time (30 mins to 2 hours)
				3 -- long time (2 hours to 8 hours)
				4 -- very long time (8 hours+)
			]]
			timeLeft = GetAuctionItemTimeLeft("list", i)
			name, texture, count, quality, canUse, level, minBid,
			minIncrement, buyoutPrice, bidAmount, highBidder, owner =
			GetAuctionItemInfo("list", i)
			invType = Const.InvTypes[itemEquipLoc]
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
				minBid, minIncrement, buyoutPrice, bidAmount, highBidder, owner, 0, -1
			}

			-- If we're going backwards
			if lib.scanDir == -1 then
				-- and this item wasn't in the last (next) page
				if noDupes(lastPage, itemData) then
					table.insert(thisPage, itemData)
					table.insert(private.curScan, itemData)
					storecount = storecount + 1
				end
			-- Otherwise if we scan forwards, always add
			else
				table.insert(private.curScan, itemData)
				storecount = storecount + 1
			end
		end
	end

	-- Store the last page for duplicate detection
	lastPage = thisPage

	-- Send the next page query or finish scanning
	if private.curPage < maxPages then
		lib.ScanPage(private.curPage + 1)
	else
		private.isScanning = false
		private.Commit()
	end
end

function lib.ClassConvert(cid, sid)
	if (sid) then
		return Const.SUBCLASSES[cid][sid]
	end
	return Const.CLASSES[cid]
end

local curQuery = { empty = true }
local curResults = {}

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

	return lib.Hook.QueryAuctionItems(name, minLevel, maxLevel, invTypeIndex, classIndex, subclassIndex, page, isUsable, qualityIndex)
end
