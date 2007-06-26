--[[
	Auctioneer Advanced
	Revision: $Id: ScanSimple.lua 1761 2007-04-27 20:50:28Z prowell $
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

if (not AucAdvanced) then AucAdvanced = {} end
if (not AucAdvanced.Scan) then AucAdvanced.Scan = {} end

local lib = AucAdvanced.Scan
local private = {}
lib.Private = private

lib.Print = AucAdvanced.Print
local Const = AucAdvanced.Const

private.isScanning = false
private.curPage = 0
private.scanDir = 1

local LclAucScanData = nil
function private.LoadAuctionImage()
	if (LclAucScanData) then return LclAucScanData end
	local loaded, reason = LoadAddOn("Auc-ScanData")
	if not loaded then
		message("The Auc-ScanData storage module could not be loaded: "..reason)
	end

	if (AucAdvancedData.ScanData) then
		lib.Print("Warning, Overwriting AucScanData with AucAdvancedData.ScanData")
		AucScanData = AucAdvancedData.ScanData
		if (loaded) then AucAdvancedData.ScanData = nil end
	end

	if (not AucScanData) then
		LoadAddOn("Auc-Scan-Simple")
		lib.Print("Warning, Overwriting AucScanData with AucAdvancedScanSimpleData")
		AucScanData = AucAdvancedScanSimpleData
		AucAdvancedScanSimpleData = nil
	end

	if (AucScanData and not AucScanData.Version) then 
		AucScanData = nil 
		lib.Print("Warning, Scan Data in wrong format, clearing data")
	end
	
	if not AucScanData then AucScanData = {Version = "1.0"} end
	if not AucScanData.scans then AucScanData.scans = {} end
	if not loaded then AucAdvancedData.Scandata = AucScanData end
	LclAucScanData = AucScanData

	return LclAucScanData
end

function lib.GetImage()
	LoadAuctionImage()
	return image
end

function lib.StartScan(name, minUseLevel, maxUseLevel, invTypeIndex, classIndex, subclassIndex, isUsable, qualityIndex)
	if AuctionFrame and AuctionFrame:IsVisible() then
		private.Commit(true)
		private.isScanning = true
		local startPage = 0
		if (private.scanDir == 1) then
			startPage = 0
		else
			private.curPage = -1
			private.sentQuery = true
			-- Get "list" from appropriately filtered list
			private.Hook.QueryAuctionItems(name or "", minUseLevel or "", maxUseLevel or "",
				invTypeIndex, classIndex, subclassIndex, 0, isUsable, quality) 
			local numBatchAuctions, totalAuctions = GetNumAuctionItems("list");
			local maxPages = floor(totalAuctions / 50);
			startPage = maxPages
		end

		QueryAuctionItems(name or "", minUseLevel or "", maxUseLevel or "",
				invTypeIndex, classIndex, subclassIndex, startPage, isUsable, qualityIndex) 
		AuctionFrameBrowse.page = startPage
		private.curPage = startPage
	else
		message("Steady on; You'll need to talk to the auctioneer first!")
	end
end

function lib.IsScanning()
	return private.isScanning
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
	storage.amBidder = item[Const.AMHIGH]
	storage.dataFlag = item[Const.FLAG]
	
	return storage
end
-- Define a public accessor for the above upack function
lib.UnpackImageItem = private.Unpack

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
	if (curItem) then private.Unpack(curItem, statItem) end
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

function private.IsInQuery(curQuery, data)
	if 	(not curQuery.class or curQuery.class == data[Const.ITYPE])
			and (not curQuery.subClass or (curQuery.subClass == data[Const.ISUB])) 
			and (not curQuery.minUseLevel or (data[Const.ULEVEL] >= curQuery.minUseLevel))
			and (not curQuery.maxUseLevel or (data[Const.ULEVEL] <= curQuery.maxUseLevel))
			and (not curQuery.name or (strfind(data[Const.NAME], curQuery.name, 1, true)))
			and (not curQuery.isUsable or (data[Const.CANUSE]))
			and (not curQuery.invType or (data[Const.INVTYPE] == curQuery.invType))
			and (not curQuery.quality or (data[Const.QUALITY] >= curQuery.quality))
			then
		return true
	end
	return false
end

local idLists = {}
function private.BuildIDList(scandata, faction, realmName)
	local sig = realmName.."-"..faction
	if (idLists[sig]) then return idLists[sig] end
	idLists[sig] = {}
	local idList = idLists[sig]

	local id
	for i = 1, #scandata.image do
		id = scandata.image[i][Const.ID]
		table.insert(idList, id)
	end
	table.sort(idList)
	return idList
end
function private.GetNextID(idList)
	local first = idList[1]
	local second = idList[2]
	while first and second and second == first + 1 do
		first = second
		table.remove(idList, 1)
		second = idList[2]
	end
	first = first + 1
	idList[1] = first
	return first
end
function lib.GetScanData(faction, realmName)
	if not faction then faction = AucAdvanced.GetFactionGroup() end
	if not realmName then realmName = GetRealmName() end
	local AucScanData = private.LoadAuctionImage()
	if not AucScanData.scans[realmName] then AucScanData.scans[realmName] = {} end
	if not AucScanData.scans[realmName][faction] then AucScanData.scans[realmName][faction] = {image = {}, time=time()} end
	if not AucScanData.scans[realmName][faction].image then AucScanData.scans[realmName][faction].image = {} end
	if AucScanData.scans[realmName][faction].nextID then AucScanData.scans[realmName][faction].nextID = nil end
	local idList = private.BuildIDList(AucScanData.scans[realmName][faction], faction, realmName)
	return AucScanData.scans[realmName][faction], idList
end


function private.Commit(wasIncomplete)
	local inscount, delcount = 0, 0
	if not private.curScan then return end
	if not private.curQuery then return end
	local scandata, idList = lib.GetScanData()
	local now = time()
	
	local list, link, flag
	local lut = {}

	-- Mark all matching auctions as DIRTY, and build a LookUpTable
	for pos, data in ipairs(scandata.image) do
		if private.IsInQuery(private.curQuery, data) then
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
	local oldCount = #scandata.image
	local scanCount = #private.curScan
	local updateCount, sameCount, newCount, missedCount, earlyDeleteCount, expiredDeleteCount = 0,0,0,0,0,0

	processStats("begin")
	for _, data in ipairs(private.curScan) do
		itemPos = lib.FindItem(data, scandata.image, lut)
		data[Const.FLAG] = bit.band(data[Const.FLAG] or 0, bit.bnot(Const.FLAG_DIRTY))
		data[Const.FLAG] = bit.band(data[Const.FLAG], bit.bnot(Const.FLAG_UNSEEN))
		if (itemPos) then
			data[Const.ID] = scandata.image[itemPos][Const.ID]
			if not private.IsIdentical(scandata.image[itemPos], data) then				
				processStats("update", data, scandata.image[itemPos])
				updateCount = updateCount + 1
			else
				processStats("leave", data)
				sameCount = sameCount + 1
			end
			scandata.image[itemPos] = data
		else
			if (processStats("create", data)) then
				data[Const.ID] = private.GetNextID(idList)
				table.insert(scandata.image, data)
				newCount = newCount + 1
			else
				scanCount = scanCount - 1
			end
		end
	end

	local data, flag
	for pos = #scandata.image, 1, -1 do
		data = scandata.image[pos]
		if (bit.band(data[Const.FLAG] or 0, Const.FLAG_DIRTY) == Const.FLAG_DIRTY) then
			local stillpossible = false
			local auctionmaxtime = Const.AucMaxTimes[data[Const.TLEFT]] or 86400
			local dodelete = false
			if (now - data[Const.TIME] <= auctionmaxtime) then
				stillpossible = true
			end

			if (stillpossible) then
				if (not wasIncomplete) then
					if bit.band(data[Const.FLAG] or 0, Const.FLAG_UNSEEN) == Const.FLAG_UNSEEN then
						dodelete = true
						earlyDeleteCount = earlyDeleteCount + 1
					else
						data[Const.FLAG] = bit.bor(data[Const.FLAG] or 0, Const.FLAG_UNSEEN)
						missedCount = missedCount + 1
					end
				else
					missedCount = missedCount + 1
				end
			else
				dodelete = true
				expiredDeleteCount = expiredDeleteCount + 1
			end
			if dodelete then
				-- Auction Time has expired
				processStats("delete", data)
				table.remove(scandata.image, pos)
			end

		end
	end
	processStats("complete")

	local currentCount = #scandata.image	
	if (updateCount + sameCount + newCount ~= scanCount) then
		lib.Print(("Warning, discrepency in scan count: {{%d + %d + %d != %d}}"):format(updateCount, sameCount, newCount, scanCount))
	end

	if (oldCount - earlyDeleteCount - expiredDeleteCount + newCount ~= currentCount) then
		lib.Print(("Warning, discrepency in current count: {{%d - %d - %d + %d != %d}}"):format(oldCount, earlyDeleteCount, expiredDeleteCount,
			newCount, currentCount))
	end

	local scanTimeSecs = time() - private.scanStartTime
	local scanTimeMins = floor(scanTimeSecs / 60)
	scanTimeSecs =  mod(scanTimeSecs, 60)
	local scanTimeHours = floor(scanTimeMins / 60)
	scanTimeMins = mod(scanTimeMins, 60)
	
	if (wasIncomplete) then
		lib.Print("Auctioneer Advanced scanned {{"..scanCount.."}} auctions before interruption:")
	else
		lib.Print("Auctioneer Advanced finished scanning {{"..scanCount.."}} auctions:")
	end
	lib.Print("  {{"..oldCount.."}} items in DB at start")
	lib.Print("  {{"..sameCount.."}} unchanged items")
	lib.Print("  {{"..newCount.."}} new items")
	lib.Print("  {{"..updateCount.."}} updated items")
	lib.Print("  {{"..(earlyDeleteCount+expiredDeleteCount).."}} removed items")
	lib.Print("  {{"..currentCount.."}} items in DB at end")
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
	
	if (not scandata.scanstats) then scandata.scanstats = {} end
	if (scandata.scanstats[1]) then 
		scandata.scanstats[2] = scandata.scanstats[1] 
		scandata.scanstats[1] = nil 
	end
	if (scandata.scanstats[0]) then scandata.scanstats[1] = scandata.scanstats[0] end
	scandata.scanstats[0] = {oldCount = oldCount, sameCount = sameCount, newCount = newCount, updateCount = updateCount,
		earlyDeleteCount = earlyDeleteCount, expiredDeleteCount = expiredDeleteCount, currentCount = currentCount, missedCount = missedCount}
	scandata.scanstats[0].wasIncomplete = wasIncomplete or false
	scandata.time = time()
	private.curQuery = nil
	private.scanStartTime = nil
	private.curScan = nil
end

function lib.ScanPage(nextPage)
	if (private.isScanning) then
		private.sentQuery = true
		private.Hook.QueryAuctionItems(private.curQuery.name or "", 
			private.curQuery.minUseLevel or "", private.curQuery.maxUseLevel or "",
			private.curQuery.invType, private.curQuery.classIndex, private.curQuery.subclassIndex, nextPage, 
			private.curQuery.isUsable, private.curQuery.quality) 
		AuctionFrameBrowse.page = nextPage
	end
	private.curPage = nextPage
end

function lib.StorePage()
	if (private.curPage == -1) then
		local numBatchAuctions, totalAuctions = GetNumAuctionItems("list");
		private.curPage = floor(totalAuctions / 50);
	end
	
	if not (private.curPage == AuctionFrameBrowse.page) then return end
	if not private.curQuery then return end
	private.sentQuery = false

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
			if bidAmount > 0 then nextBid = bidAmount + minIncrement end
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
			if private.scanDir == -1 then
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
	
	if (private.scanDir == 1 and private.curPage < maxPages) 
			or (private.scanDir == -1 and private.curPage > 0) then
		lib.ScanPage(private.curPage + private.scanDir)
	else
		private.isScanning = false
		private.Commit()
	end
end

function private.ClassConvert(cid, sid)
	if (sid) then
		return Const.SUBCLASSES[cid][sid]
	end
	return Const.CLASSES[cid]
end

local curQuery = { empty = true }
local curResults = {}

private.Hook = {}
private.Hook.PlaceAuctionBid = PlaceAuctionBid
function PlaceAuctionBid(type, index, bid)
	return private.Hook.PlaceAuctionBid(type, index, bid)
end

private.Hook.QueryAuctionItems = QueryAuctionItems
function QueryAuctionItems(name, minLevel, maxLevel, invTypeIndex, classIndex, subclassIndex, page, isUsable, qualityIndex)
	local is_same = true
	query = {}
	name = name or ""
	minLevel = tonumber(minLevel) or 0
	maxLevel = tonumber(maxLevel) or 0
	classIndex = tonumber(classIndex) or 0
	subclassIndex = tonumber(subclassIndex) or 0
	qualityIndex = tonumber(qualityIndex)
	query.page = tonumber(page) or 0
	if (name and name ~= "") then query.name = name end
	if (minLevel > 0) then query.minUseLevel = minLevel end
	if (maxLevel > 0) then query.maxUseLevel = maxLevel end
	if (classIndex > 0) then 
		query.class = private.ClassConvert(classIndex) 
		query.classIndex = classIndex
	end
	if (subclassIndex > 0) then 
		query.subclass = private.ClassConvert(classIndex, subclassIndex)
		query.subclassIndex = subclassIndex
	end
	if (qualityIndex and qualityIndex > 0) then query.quality = qualityIndex end
	if (invTypeIndex and invTypeIndex ~= "") then query.invType = invTypeIndex end
	
	if (private.curQuery) then
		for x, y in pairs(query) do
			if (x~="page" and (not (query[x] and private.curQuery[x] and query[x]==private.curQuery[x]))) then is_same = false break end		
		end
		for x, y in pairs(private.curQuery) do
			if (x~="page" and (not (query[x] and private.curQuery[x] and query[x]==private.curQuery[x]))) then is_same = false break end		
		end
	end
	
	if (not is_same or not private.curQuery) then
		private.Commit(true)
		private.scanStartTime = time()
		local startPage = 0
		if (private.scanDir == 1) then
			private.curPage = 0
		else
			private.curPage = -1
		end
		private.curPage = startPage
	end	
	private.curQuery = query
	private.curQuerySig = ("%s-%s-%s-%s-%s-%s-%s"):format(
		query.name or "",
		query.minUseLevel or "",
		query.maxUseLevel or "",
		query.class or "",
		query.subclass or "",
		query.quality or "",
		query.invType or ""
	)
	private.sentQuery = true
	lib.lastReq = GetTime()	

	return private.Hook.QueryAuctionItems(name, minLevel, maxLevel, invTypeIndex, classIndex, subclassIndex, page, isUsable, qualityIndex)
end

function private.OnUpdate(me, dur)
	if private.sentQuery and CanSendAuctionQuery() then
		lib.StorePage()
	end
end
private.updater = CreateFrame("Frame", "", UIParent)
private.updater:SetScript("OnUpdate", private.OnUpdate)

function lib.Cancel()
	if (private.curQuery) then
		private.Commit(true)
	end
end

function lib.Abort()
	if (private.curQuery) then
		private.curQuery = nil
		private.curScan = nil
	end
end
