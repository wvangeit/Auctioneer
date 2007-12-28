--[[
	Auctioneer Advanced
	Version: <%version%> (<%codename%>)
	Revision: $Id$
	URL: http://auctioneeraddon.com/

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
local print = lib.Print
local recycle = AucAdvanced.Recycle
local acquire = AucAdvanced.Acquire
local clone = AucAdvanced.Clone

private.isScanning = false
private.curPage = 0
private.scanDir = 1
private.filteredCount = 0

local LclAucScanData = nil
function private.LoadAuctionImage()
	if (LclAucScanData) then return LclAucScanData end
	local loaded, reason = LoadAddOn("Auc-ScanData")
	if not loaded then
		message("The Auc-ScanData storage module could not be loaded: "..reason)
	elseif AucAdvanced.Modules
	and AucAdvanced.Modules.Util
	and AucAdvanced.Modules.Util.ScanData
	and AucAdvanced.Modules.Util.ScanData.Unpack then
		AucAdvanced.Modules.Util.ScanData.Unpack()
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
	private.LoadAuctionImage()
	return image
end

function lib.StartPushedScan(name, minUseLevel, maxUseLevel, invTypeIndex, classIndex, subclassIndex, isUsable, qualityIndex, GetAll)
	if not private.scanStack then private.scanStack = acquire() end
	local query = acquire() 
	name = name or ""
	minUseLevel = tonumber(minUseLevel) or 0
	maxUseLevel = tonumber(maxUseLevel) or 0
	classIndex = tonumber(classIndex) or 0
	subclassIndex = tonumber(subclassIndex) or 0
	qualityIndex = tonumber(qualityIndex)
	page = tonumber(page) or 0
	if (name and name ~= "") then query.name = name end
	if (minUseLevel > 0) then query.minUseLevel = minUseLevel end
	if (maxUseLevel > 0) then query.maxUseLevel = maxUseLevel end
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
	query.page = page
	query.isUsable = isUsable
	local now = GetTime()
	table.insert(private.scanStack, acquire(now, false, 0, query, acquire(), acquire(), now, 0, now))
end

function lib.PushScan()
	if private.isScanning then
		print(("Pausing current scan at page {{%d}}."):format(private.curPage+1))
		if not private.scanStack then private.scanStack = acquire() end
		table.insert(private.scanStack, acquire(
			private.scanStartTime,
			private.sentQuery,
			private.curPage,
			private.curQuery,
			private.curPages,
			private.curScan,
			private.scanStarted,
			private.totalPaused,
			GetTime()
		))
		private.scanStartTime = nil
		private.scanStarted = nil
		private.totalPaused = nil
		private.curQuerySig = nil
		private.curQuery = nil
		private.curScan = nil

		private.curPage = 0
		private.curPages = nil
		private.sentQuery = nil
		private.isScanning = false
		private.UpdateScanProgress(false)
	end
end

function lib.PopScan()
	if private.scanStack and #private.scanStack > 0 then
		local now, pauseTime = GetTime()
		private.scanStartTime,
		private.sentQuery,
		private.curPage,
		private.curQuery,
		private.curPages,
		private.curScan,
		private.scanStarted,
		private.totalPaused,
		pauseTime = unpack(private.scanStack[1])
		table.remove(private.scanStack, 1)

		local elapsed = now - pauseTime
		if elapsed > 300 then
			-- 5 minutes old
			print("Paused scan is older than 5 minutes, aborting")
			lib.Commit(true)
			return
		end

		private.totalPaused = private.totalPaused + elapsed
		print(("Resuming paused scan at page {{%d}}..."):format(private.curPage+1))
		private.isScanning = true
		private.sentQuery = false
		lib.ScanPage(private.curPage)
		private.UpdateScanProgress(true)
	end
end

function lib.StartScan(name, minUseLevel, maxUseLevel, invTypeIndex, classIndex, subclassIndex, isUsable, qualityIndex, GetAll)
	if AuctionFrame and AuctionFrame:IsVisible() then
		if private.isPaused then
			message("Scanning is currently paused")
			return
		end
		if private.isScanning then
			message("Scan is currently in progress")
			return
		end
		local CanQuery, CanQueryAll = CanSendAuctionQuery()
		local scandata = AucAdvanced.Scan.GetScanData(faction, realm)
		local now = time()
		if not scandata.LastFullScan then
			scandata.LastFullScan = 0
		end
		local minleft = ceil((now - scandata.LastFullScan) / 60) 
		local secleft = (now - scandata.LastFullScan) - (minleft - 1 ) * 60
		--this can be removed once 2.3 rolls out
		if (CanQueryAll == nil) and (minleft > 20) then
			CanQueryAll = true
		end
		minleft = 15 - minleft
		secleft = 60 - secleft
		if not GetAll then
			if not CanQuery then
				private.queueScan = acquire(
					name, minUseLevel, maxUseLevel, invTypeIndex, classIndex, subclassIndex, isUsable, qualityIndex, GetAll
				)
				return
			end
		else
			if not CanQueryAll then
				
				message("You must wait "..minleft..":"..secleft.." until you can do a full scan again")
				return
			end
		end

		if private.curQuery then
			lib.Commit(true)
		end

		private.isScanning = true
		local startPage = 0
		local numBatchAuctions, totalAuctions

		QueryAuctionItems(name or "", minUseLevel or "", maxUseLevel or "",
				invTypeIndex, classIndex, subclassIndex, startPage, isUsable, qualityIndex, GetAll)
		AuctionFrameBrowse.page = startPage
		private.curPage = startPage

		--Show the progress indicator
		private.UpdateScanProgress(true, totalAuctions)
	else
		message("Steady on; You'll need to talk to the auctioneer first!")
	end
end

function lib.IsScanning()
	return private.isScanning or (private.queueScan ~= nil)
end

function lib.IsPaused()
	return private.isPaused
end

function private.Unpack(item, storage)
	if not storage then storage = acquire() end
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
	storage.itemId = item[Const.ITEMID]
	storage.itemSuffix = item[Const.SUFFIX]
	storage.itemFactor = item[Const.FACTOR]
	storage.itemEnchant = item[Const.ENCHANT]
	storage.itemSeed = item[Const.SEED]

	return storage
end
-- Define a public accessor for the above upack function
lib.UnpackImageItem = private.Unpack

--The first parameter will be true if we want to show the process indicator, false if we want to hide it. and nil if we only want to update it.
--The second parameter will be a number that is the max number of items in the scan.
--The third parameter is the current progress of the scan.
function private.UpdateScanProgress(state, totalAuctions, scannedAuctions, elapsedTime)
	if (not (lib.IsScanning() or (state == false))) then
		return
	end

	for system, systemMods in pairs(AucAdvanced.Modules) do
		for engine, engineLib in pairs(systemMods) do
			if (engineLib.Processor) then
				engineLib.Processor("scanprogress", state, totalAuctions, scannedAuctions, elapsedTime)
			end
		end
	end
end

function private.IsIdentical(focus, compare)
	for i = 1, Const.SELLER do
		if (i ~= Const.TIME and i ~= Const.CANUSE and focus[i] ~= compare[i]) then
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
		]]
		for engine, engineLib in pairs(AucAdvanced.Modules.Filter) do
			if (engineLib.AuctionFilter) then
				local result=engineLib.AuctionFilter(operation, statItem)
				if (result) then 
					private.filteredCount = private.filteredCount + 1
					curItem[Const.FLAG] = bit.bor(curItem[Const.FLAG] or 0, Const.FLAG_FILTER)
					operation = "filter"
					break
				end
			end
		end
	elseif curItem and bit.band(curItem[Const.FLAG] or 0, Const.FLAG_FILTER) == Const.FLAG_FILTER then
		-- This item is a filtered item
		operation = "filter"
		private.filteredCount = private.filteredCount + 1
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
	if operation == "filter" then
		return false
	end
	return true
end

function private.IsInQuery(curQuery, data)
	if 	(not curQuery.class or curQuery.class == data[Const.ITYPE])
			and (not curQuery.subclass or (curQuery.subclass == data[Const.ISUB]))
			and (not curQuery.minUseLevel or (data[Const.ULEVEL] >= curQuery.minUseLevel))
			and (not curQuery.maxUseLevel or (data[Const.ULEVEL] <= curQuery.maxUseLevel))
			and (not curQuery.name or (data[Const.NAME] and strfind(data[Const.NAME]:lower(), curQuery.name:lower(), 1, true)))
			and (not curQuery.isUsable or (private.CanUse(data[Const.LINK])))
			and (not curQuery.invType or (data[Const.IEQUIP] == Const.InvTypes[curQuery.invType]))
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
	first = (first or 0) + 1 --Normalize it, since it will be nil if theres nothing in the tables.
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

private.CommitQueue = {}

private.CommitQueueScan = {}
private.CommitQueueQuery = {}
private.CommitQueuewasIncomplete = {}
private.CommitQueuewasGetAll = {}

local Commitprogressbar = CreateFrame("STATUSBAR", "$parentHealthBar",UIParent, "TextStatusBar")
Commitprogressbar:SetWidth(200)
Commitprogressbar:SetHeight(20)
Commitprogressbar:SetPoint("BOTTOM", "UIParent", "BOTTOM", 0, 150)
Commitprogressbar:SetBackdrop({
  bgFile="Interface\\Tooltips\\UI-Tooltip-Background", 
  edgeFile="Interface\\Tooltips\\UI-Tooltip-Border", 
  tile=1, tileSize=10, edgeSize=10, 
  insets={left=3, right=3, top=3, bottom=3}
})

Commitprogressbar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
Commitprogressbar:SetStatusBarColor(0.6,0,0,0.4)
Commitprogressbar:SetMinMaxValues(0,100)
Commitprogressbar:SetValue(50)
Commitprogressbar:Hide()

Commitprogressbar.text = Commitprogressbar:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
Commitprogressbar.text:SetPoint("CENTER", Commitprogressbar, "CENTER")
Commitprogressbar.text:SetJustifyH("CENTER")
Commitprogressbar.text:SetJustifyV("CENTER")
Commitprogressbar.text:SetText("AucAdv: Processing")
Commitprogressbar.text:SetTextColor(1,1,1)

local CommitRunning = false
Commitfunction = function()
	local ProcessSpeed = AucAdvanced.Settings.GetSetting("scancommit.speed")
	local inscount, delcount = 0, 0
	if #private.CommitQueue == 0 then CommitRunning = false return end
	--	if not private.curQuery then CommitRunning = false return end
	CommitRunning = true
	local scandata, idList = lib.GetScanData()
	
	--grab the first item in the commit queue, and bump everything else down 
	local wasIncomplete = private.CommitQueue[1]["wasIncomplete"]
	local wasGetAll = private.CommitQueue[1]["wasGetAll"]
	local scanStarted = private.CommitQueue[1]["scanStarted"]
	local scanStartTime = private.CommitQueue[1]["scanStartTime"]
	local totalPaused = private.CommitQueue[1]["totalPaused"]
	local TempcurScan = {}
	TempcurScan, private.CommitQueue[1]["Scan"] = private.CommitQueue[1]["Scan"], TempcurScan
	local TempcurQuery = {}
	TempcurQuery, private.CommitQueue[1]["Query"] = private.CommitQueue[1]["Query"], TempcurQuery
	
	for i = 1, #private.CommitQueue do
		if private.CommitQueue[i+1] then
			private.CommitQueue[i], private.CommitQueue[i+1] = private.CommitQueue[i+1], private.CommitQueue[i]
		else
			recycle(private.CommitQueue, i)
			--private.CommitQueue[i] = nil
		end
	end
	local now = time()
	if AucAdvanced.Settings.GetSetting("scancommit.progressbar") then
		Commitprogressbar:Show()
		Commitprogressbar:SetValue(0)
	end
	local totali = 2*(#scandata.image) + #TempcurScan
	
	local list, link, flag
	local lut = acquire()

	-- Mark all matching auctions as DIRTY, and build a LookUpTable
	local dirtyCount = 0
	local i = 0
	for pos, data in ipairs(scandata.image) do
		link = data[Const.LINK]
		i = i + 1
		if i % (ProcessSpeed*100) == 0 then
			Commitprogressbar:SetValue(100*i/totali)
			coroutine.yield()
		end
		if link then
			if private.IsInQuery(TempcurQuery, data) then
				-- Mark dirty
				flag = data[Const.FLAG] or 0
				data[Const.FLAG] = bit.bor(flag, Const.FLAG_DIRTY)
				dirtyCount = dirtyCount+1

				-- Build lookup table
				list = lut[link]
				if (not list) then
					lut[link] = pos
				else
					if (type(list) == "number") then
						lut[link] = acquire() 
						table.insert(lut[link], list)
					end
					table.insert(lut[link], pos)
				end
			else
				-- Mark NOT dirty
				data[Const.FLAG] = bit.band(data[Const.FLAG] or 0, bit.bnot(Const.FLAG_DIRTY))
			end
		end
	end

	local itemPos
	local oldCount = #scandata.image
	local scanCount = #TempcurScan
	local updateCount, sameCount, newCount, updateRecoveredCount, sameRecoveredCount, missedCount, earlyDeleteCount, expiredDeleteCount = 0,0,0,0,0,0,0,0
	
	processStats("begin")
	for index, data in ipairs(TempcurScan) do
		i = i + 1
		if i % (ProcessSpeed*10) == 0 then
			Commitprogressbar:SetValue(100*i/totali)
			coroutine.yield()
		end
		itemPos = lib.FindItem(data, scandata.image, lut)
		data[Const.FLAG] = bit.band(data[Const.FLAG] or 0, bit.bnot(Const.FLAG_DIRTY))
		data[Const.FLAG] = bit.band(data[Const.FLAG], bit.bnot(Const.FLAG_UNSEEN))
		if (itemPos) then
			local oldItem = scandata.image[itemPos]
			data[Const.ID] = oldItem[Const.ID]
			data[Const.FLAG] = bit.band(oldItem[Const.FLAG] or 0, bit.bnot(Const.FLAG_DIRTY+Const.FLAG_UNSEEN))
			if not private.IsIdentical(oldItem, data) then
				if processStats("update", data, oldItem) then
					updateCount = updateCount + 1
				end
				if bit.band(oldItem[Const.FLAG] or 0, Const.FLAG_UNSEEN) == Const.FLAG_UNSEEN then
					updateRecoveredCount = updateRecoveredCount + 1
				end
			else
				if processStats("leave", data) then
					sameCount = sameCount + 1
				end
				if bit.band(oldItem[Const.FLAG] or 0, Const.FLAG_UNSEEN) == Const.FLAG_UNSEEN then
					sameRecoveredCount = sameRecoveredCount + 1
				end
			end
			scandata.image[itemPos] = clone(data)
		else
			if (processStats("create", data)) then
				data[Const.ID] = private.GetNextID(idList)
				table.insert(scandata.image, clone(data))
				newCount = newCount + 1
			end
		end

-- end of debugging code
	
	end
	recycle(lut)

	local data, flag
	for pos = #scandata.image, 1, -1 do
		data = scandata.image[pos]
		i = i + 1
		if i % (ProcessSpeed*100) == 0 then
			Commitprogressbar:SetValue(100*i/totali)
			coroutine.yield()
		end
		if (bit.band(data[Const.FLAG] or 0, Const.FLAG_DIRTY) == Const.FLAG_DIRTY) then
			local stillpossible = false
			local auctionmaxtime = Const.AucMaxTimes[data[Const.TLEFT]] or 172800
			local dodelete = false
			if (not data[Const.TIME]) or (now - data[Const.TIME] <= auctionmaxtime) then
				stillpossible = true
			end
			if wasGetAll then
				stillpossible = false
			elseif #TempcurScan <= 50 and not wasIncomplete then
				stillpossible = false
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
	Commitprogressbar:SetValue(100)
	processStats("complete")

	local filterCount = private.filteredCount

	local currentCount = #scandata.image
	if (updateCount + sameCount + newCount + filterCount ~= scanCount) then
		lib.Print(("Warning, discrepency in scan count: {{%d updated + %d same + %d new + %d filtered != %d scanned}}"):format(updateCount, sameCount, newCount, filterCount, scanCount))
	end

	if (oldCount - earlyDeleteCount - expiredDeleteCount + newCount ~= currentCount) then
		lib.Print(("Warning, discrepency in current count: {{%d - %d - %d + %d != %d}}"):format(oldCount, earlyDeleteCount, expiredDeleteCount,
			newCount, currentCount))
	end

	local now = time()
	local scanTimeSecs = math.floor(GetTime() - scanStarted - totalPaused)
	local scanTimeMins = floor(scanTimeSecs / 60)
	scanTimeSecs =  mod(scanTimeSecs, 60)
	local scanTimeHours = floor(scanTimeMins / 60)
	scanTimeMins = mod(scanTimeMins, 60)
	--Hides the end of scan summary if user is not interested
	if private.getOption("scandata.summary") then
		if (wasIncomplete) then
			lib.Print("Auctioneer Advanced scanned {{"..scanCount.."}} auctions before interruption:")
		else

			lib.Print("Auctioneer Advanced finished scanning {{"..scanCount.."}} auctions:")
		end
		lib.Print("  {{"..oldCount.."}} items in DB at start ({{"..dirtyCount.."}} matched query)")
		if (sameRecoveredCount > 0) then
			lib.Print("  {{"..sameCount.."}} unchanged items (of which, "..sameRecoveredCount.." were missed last scan)")
		else
			lib.Print("  {{"..sameCount.."}} unchanged items")
		end
		lib.Print("  {{"..newCount.."}} new items")
		if (updateRecoveredCount > 0) then
			lib.Print("  {{"..updateCount.."}} updated items (of which, "..updateRecoveredCount.." were missed last scan)")
		else
			lib.Print("  {{"..updateCount.."}} updated items")
		end
		lib.Print("  {{"..earlyDeleteCount+expiredDeleteCount.."}} items removed")
		lib.Print("  {{"..filterCount.."}} filtered items")
		lib.Print("  {{"..missedCount.."}} missed items")
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
	end

	if (not scandata.scanstats) then scandata.scanstats = acquire() end
	if (scandata.scanstats[1]) then
		scandata.scanstats[2] = scandata.scanstats[1]
		scandata.scanstats[1] = nil
	end
	if (scandata.scanstats[0]) then scandata.scanstats[1] = scandata.scanstats[0] end
	scandata.scanstats[0] = acquire()
	scandata.scanstats[0].oldCount = oldCount
	scandata.scanstats[0].sameCount = sameCount
	scandata.scanstats[0].newCount = newCount
	scandata.scanstats[0].updateCount = updateCount
	scandata.scanstats[0].earlyDeleteCount = earlyDeleteCount
	scandata.scanstats[0].expiredDeleteCount = expiredDeleteCount
	scandata.scanstats[0].currentCount = currentCount
	scandata.scanstats[0].missedCount = missedCount
	scandata.scanstats[0].filteredCount = filterCount
	scandata.scanstats[0].wasIncomplete = wasIncomplete or false
	scandata.scanstats[0].startTime = scanStartTime
	scandata.scanstats[0].endTime = now
	scandata.scanstats[0].started = scanStarted
	scandata.scanstats[0].paused = totalPaused
	scandata.scanstats[0].ended = GetTime()
	scandata.scanstats[0].elapsed = GetTime() - scanStarted - totalPaused
	scandata.scanstats[0].query = clone(TempcurQuery)
	scandata.time = now
	if wasGetAll then scandata.LastFullScan = now end

	private.filteredCount = 0
	recycle(TempcurScan)
	recycle(TempcurQuery)

	-- Tell everyone that our stats are updated
	for system, systemMods in pairs(AucAdvanced.Modules) do
		for engine, engineLib in pairs(systemMods) do
			if engineLib.Processor then
				engineLib.Processor("scanstats", scandata.scanstats[0])
			end
		end
	end

	--Hide the progress indicator
	Commitprogressbar:Hide()
	private.UpdateScanProgress(false)
	lib.PopScan()
	CommitRunning = false 
	if not private.curScan then
		private.ResetAll()
	end
end

local CoCommit = coroutine.create(Commitfunction)

local function CoroutineResume(...)
	local status, result = coroutine.resume(...)
	if not status and result then
		print("error in coroutine: " .. result)
	end
	return status, result
end

function lib.Commit(wasIncomplete, wasGetAll)
	if not private.curScan then return end
	local Queuelength = #private.CommitQueue
	private.CommitQueue[Queuelength + 1] = {}
	private.CommitQueue[Queuelength + 1]["Query"], private.curQuery = private.curQuery, private.CommitQueue[Queuelength + 1]["Query"]
	private.CommitQueue[Queuelength + 1]["Scan"], private.curScan = private.curScan, private.CommitQueue[Queuelength + 1]["Scan"]
	private.CommitQueue[Queuelength + 1]["wasIncomplete"] = wasIncomplete
	private.CommitQueue[Queuelength + 1]["wasGetAll"] = wasGetAll
	private.CommitQueue[Queuelength + 1]["scanStarted"] = private.scanStarted
	private.CommitQueue[Queuelength + 1]["scanStartTime"] = private.scanStartTime
	private.CommitQueue[Queuelength + 1]["totalPaused"] = private.totalPaused
	recycle(private, "curQuery")
	recycle(private, "curScan")
	
	if coroutine.status(CoCommit) ~= "dead" then
		CoroutineResume(CoCommit)
	else
		CoCommit = coroutine.create(Commitfunction)
		CoroutineResume(CoCommit)
	end
end

function lib.LogoutCommit()
	while coroutine.status(CoCommit) == "suspended" do
		CoroutineResume(CoCommit)
	end
end

function private.QuerySent(query, isSearch, isNavigate, ...)
	-- Tell everyone that our stats are updated
	for system, systemMods in pairs(AucAdvanced.Modules) do
		for engine, engineLib in pairs(systemMods) do
			if engineLib.Processor then
				engineLib.Processor("querysent", query, isSearch, ...)
			end
		end
	end
	return ...
end

function private.FinishedPage(nextPage)
	-- Tell everyone that our stats are updated
	for system, systemMods in pairs(AucAdvanced.Modules) do
		for engine, engineLib in pairs(systemMods) do
			if engineLib.FinishedPage then
				local finished = engineLib.FinishedPage(nextPage)
				if finished and finished == false then
					return false
				end
			end
		end
	end
	return true
end

function lib.ScanPage(nextPage, really)
	if (private.isScanning) then
		local CanQuery, CanQueryAll = CanSendAuctionQuery()
		if not (CanQuery and private.FinishedPage(nextPage) and really) then
			private.scanNext = GetTime() + 0.1
			private.scanNextPage = nextPage
			return
		end
		private.sentQuery = true
		private.Hook.QueryAuctionItems(private.curQuery.name or "",
			private.curQuery.minUseLevel or "", private.curQuery.maxUseLevel or "",
			private.curQuery.invType, private.curQuery.classIndex, private.curQuery.subclassIndex, nextPage,
			private.curQuery.isUsable, private.curQuery.quality)
		AuctionFrameBrowse.page = nextPage

		-- The maximum time we'll wait for the pagedata to be returned to us:
		local now = GetTime()
		private.scanDelay = now + 8 -- Only wait for up to ?? seconds
		private.nextCheck = now + 1 -- Check complete in ?? seconds
		private.verifyStart = nil
	end
	private.curPage = nextPage
end

function private.HasAllData()
	local check = private.nextCheck
	local start = private.verifyStart or 1
	if not check then return true end
	local now = GetTime()
	if now > check then -- Wait at least 1 second before checking
		-- Check to see if we have all the page data
		local numBatchAuctions, totalAuctions = GetNumAuctionItems("list")
		if start > numBatchAuctions then
			-- Already verified 100%
			return true
		end
		local _, owner = 0, {}
		for i = start, numBatchAuctions do
			_,_,_,_,_,_,_,_,_,_,_,owner[i] = GetAuctionItemInfo("list", i)
		end
		for i = start, numBatchAuctions do
			if not owner[i] then
				-- We'll start from here again next cycle since we're waiting
				private.verifyStart = i
				private.nextCheck = now + 0.25
				return false
			end
		end
		private.verifyStart = numBatchAuctions + 1
		return true
	end
	return false
end

function private.NoDupes(pageData, compare)
	if not pageData then return true end
	for pos, pageItem in ipairs(pageData) do
		if (compare[Const.LINK] == pageItem[Const.LINK]) then
			if (private.IsSameItem(pageItem, compare)) then
				return false
			end
		end
	end
	return true
end

function lib.StorePage()
	if (private.curPage == -1) then
		local numBatchAuctions, totalAuctions = GetNumAuctionItems("list");
		private.curPage = floor(totalAuctions / 50);
	end

	if not private.curQuery then
		return
	end
	private.sentQuery = false

	local numBatchAuctions, totalAuctions = GetNumAuctionItems("list");
	local maxPages = ceil(totalAuctions / 50);
	if (numBatchAuctions > 50) then
		maxPages = 1
	end
	if not private.curScan then 
		private.curScan = acquire()
	end


	--Update the progress indicator
	local now = GetTime()
	local elapsed = now - private.scanStarted - private.totalPaused
	private.UpdateScanProgress(nil, totalAuctions, #private.curScan, elapsed)
	local pageNumber
	if private.curQuery.page then
		pageNumber = private.curQuery.page+1
	else
		pageNumber = private.curPage
	end


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
		 	local _, itemId, itemSuffix, itemFactor, itemEnchant, itemSeed = AucAdvanced.DecodeLink(itemLink)
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

			local itemData = acquire(
				itemLink, itemLevel, itemType, itemSubType, invType, nextBid,
				timeLeft, curTime, name, texture, count, quality, canUse, level,
				minBid, minIncrement, buyoutPrice, bidAmount, highBidder, owner,
				0, -1, itemId, itemSuffix, itemFactor, itemEnchant, itemSeed
			)

			local legacyScanning = private.legacyScanning
			if legacyScanning == nil then
				if Auctioneer and Auctioneer.ScanManager and Auctioneer.ScanManager.IsScanning then
					legacyScanning = Auctioneer.ScanManager.IsScanning
				else
					legacyScanning = function () return false end
				end
				private.legacyScanning = legacyScanning
			end

			-- We only store one of the same item/owner/price/quantity in the scan
			-- unless we are doing a forward scan (in which case we can be sure they
			-- are not duplicate entries.
			if private.isScanning
			or totalAuctions <= 50
			or numBatchAuctions > 50 --if GetAll, we can be sure they aren't duplicates
			or legacyScanning() -- Is AucClassic scanning?
			or private.NoDupes(private.curScan, itemData) then
				table.insert(private.curScan, itemData)
				storecount = storecount + 1
			end
		end
	end

	-- Send the next page query or finish scanning

	if private.isScanning then
		if numBatchAuctions > 50 then
			private.isScanning = false
			lib.Commit(false, true)
		--Check against private.curPage + 1 because the first page in the AH is actually page 0, so if you don't then you end up one page over the max at the end of scan
		elseif (private.scanDir == 1 and private.curPage + 1 < maxPages) or
		(private.scanDir == -1 and private.curPage > 0) then
			lib.ScanPage(private.curPage + private.scanDir)
		else
			local incomplete = false
			if (#(private.curScan) < 0.90 * totalAuctions) then
				incomplete = true
			end
			private.isScanning = false
			lib.Commit(incomplete)
		end
	elseif (totalAuctions <= 50) then
		lib.Commit(false)
	elseif maxPages and maxPages > 0 then
		if not private.curPages then
			private.curPages = acquire()
		end
		private.curPages[pageNumber] = true
		local incomplete = 0
		for i = 1, maxPages do
			if not private.curPages[i] then
				incomplete = incomplete + 1
			end
		end

		local pctIncomplete = incomplete/maxPages
		if (pageNumber == maxPages and incomplete < 2 and pctIncomplete < 0.05) or incomplete == 0 then
			lib.Commit(true)
		end
	end
end

function private.ClassConvert(cid, sid)
	if (sid) then
		return Const.SUBCLASSES[cid][sid]
	end
	return Const.CLASSES[cid]
end

private.Hook = {}
private.Hook.PlaceAuctionBid = PlaceAuctionBid
function PlaceAuctionBid(type, index, bid)
	return private.Hook.PlaceAuctionBid(type, index, bid)
end

private.Hook.QueryAuctionItems = QueryAuctionItems

local isSecure, taint = issecurevariable("CanSendAuctionQuery")
if (isSecure) then
	private.CanSend = CanSendAuctionQuery
else
	private.warnTaint = taint
end

function QueryAuctionItems(name, minLevel, maxLevel, invTypeIndex, classIndex, subclassIndex, page, isUsable, qualityIndex, GetAll, ...)
	if private.warnTaint then
		lib.Print("\nAuctioneer Advanced:\n  WARNING, The CanSendAuctionQuery() function was tainted by the addon: {{"..private.warnTaint.."}}.\n  This may cause minor inconsistencies with scanning.\n  If possible, adjust the load order to get me to load first.\n ")
		private.warnTaint = nil
	end
	if private.CanSend and not private.CanSend() then
		print("Can't send query just at the moment")
		return
	end

	local isSearch = (BrowseSearchButton:GetButtonState() == "PUSHED")

	-- If we're getting called after we've sent a query, but before it's been stored, take this chance to save it.
	if private.sentQuery then
		lib.StorePage()
	end
	
	local isSame = true
	local query = acquire() 
	name = name or ""
	minLevel = tonumber(minLevel) or 0
	maxLevel = tonumber(maxLevel) or 0
	classIndex = tonumber(classIndex) or 0
	subclassIndex = tonumber(subclassIndex) or 0
	qualityIndex = tonumber(qualityIndex)
	page = tonumber(page) or 0
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
	query.page = page
	query.isUsable = isUsable

	if (private.curQuery) then
		for x, y in pairs(query) do
			if (x~="page" and (not (query[x] and private.curQuery[x] and query[x]==private.curQuery[x]))) then isSame = false break end
		end
		for x, y in pairs(private.curQuery) do
			if (x~="page" and (not (query[x] and private.curQuery[x] and query[x]==private.curQuery[x]))) then isSame = false break end
		end
	end

	if (not isSame or not private.curQuery) then
		lib.Commit(true)
		private.scanStartTime = time()
		private.scanStarted = GetTime()
		private.totalPaused = 0
		local startPage = 0
		if (private.scanDir == 1) then
			private.curPage = 0
		else
			private.curPage = -1
		end
		private.curPage = startPage

		recycle(private.curQuery)
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
	else
		recycle(query)
		query = private.curQuery
		query.page = page
	end

	private.sentQuery = true
	lib.lastReq = GetTime()

	return private.QuerySent(query, isSearch,
		private.Hook.QueryAuctionItems(
			name, minLevel, maxLevel, invTypeIndex, classIndex, subclassIndex,
			page, isUsable, qualityIndex, GetAll, ...))
end

function lib.SetPaused(pause)
	if pause then
		if private.isPaused then return end
		lib.PushScan()
		private.isPaused = true
	elseif private.isPaused then
		lib.PopScan()
		private.isPaused = false
	end
end
private.unexpectedClose = false
local flip, flop = false, false
function private.OnUpdate(me, dur)
	if coroutine.status(CoCommit) == "suspended" then
		flip = not flip
		if flip then
			flop = not flop
			if flop then
				CoroutineResume(CoCommit)
			end
		end
	else
		if #private.CommitQueue > 0 then
			CoCommit = coroutine.create(Commitfunction)
			CoroutineResume(CoCommit)
		end
	end
	if not AuctionFrame then return end
	if private.isPaused then return end

	if private.queueScan then
		if CanSendAuctionQuery() and (not private.CanSend or private.CanSend()) then
			local queued = private.queueScan
			private.queueScan = nil
			lib.StartScan(unpack(queued))
		end
		return
	end
	local now = GetTime()
	if private.scanDelay then
		-- If we are within the delay interval
		if now < private.scanDelay then
			-- Check to see if all the auctions have fully populated
			if not private.HasAllData() then
				-- If not, we still have time to wait
				return
			end
		end
		private.scanDelay = nil
	end
	if private.scanNext then
		if now > private.scanNext and CanSendAuctionQuery() then
			local nextPage = private.scanNextPage
			private.scanNext = nil
			lib.ScanPage(nextPage, true)
		end
		return
	end

	if AuctionFrame:IsVisible() then
		if private.unexpectedClose then
			private.unexpectedClose = false
			lib.PopScan()
			return
		end

		if private.sentQuery and CanSendAuctionQuery() then
			lib.StorePage()
		end
	elseif private.curQuery then
		lib.Interrupt()
	end
end
private.updater = CreateFrame("Frame", nil, UIParent)
private.updater:SetScript("OnUpdate", private.OnUpdate)

function lib.Cancel()
	if (private.curQuery) then
		print("Cancelling current scan")
		lib.Commit(true)
	end
	private.ResetAll()
end

function lib.Interrupt()
	if private.curQuery and not AuctionFrame:IsVisible() then
		if private.isScanning then
			private.unexpectedClose = true
			lib.PushScan()
		else
			lib.Commit(true)
			private.sentQuery = false
		end
	end
end

function lib.Abort()
	if (private.curQuery) then
		print("Aborting current scan")
	end
	private.ResetAll()
end

function private.ResetAll()
	if CommitRunning then
		recycle(private, "curQuery")
		recycle(private, "curScan")
	
		private.curPage = 0
		private.isPaused = nil
		private.sentQuery = nil
		private.isScanning = false
		private.unexpectedClose = false
		private.UpdateScanProgress(false)
		return
	end
	private.scanStartTime = nil
	private.scanStarted = nil
	private.totalPaused = nil
	private.curQuerySig = nil

	recycle(private, "curQuery")
	recycle(private, "curScan")
	recycle(private, "curPages")
	recycle(private, "scanStack")

	private.curPage = 0
	private.isPaused = nil
	private.Pausing = nil
	private.sentQuery = nil
	private.isScanning = false
	private.unexpectedClose = false
	--Hide the progress indicator
	private.UpdateScanProgress(false)
end
--Did not have a way of easily retrieving options for corescan  Kandoko
function private.getOption(option)
	return AucAdvanced.Settings.GetSetting(option)
end

-- In the absence of a proper API function to do it, it's necessary to inspect an item's tooltip to
-- figure out if it's usable by the player
local ItemUsableTooltip = {
	tooltipFrame = nil,
	fontString = {},
	maxLines = 100,

	CanUse = function(this, link)
		-- quick level check first
		local minLevel = select(5, GetItemInfo(link)) or 0
		if UnitLevel("player") < minLevel then
			return false
		end
	
		-- set up if not done already
		if not this.tooltipFrame then
			this.tooltipFrame = CreateFrame("GameTooltip")
			this.tooltipFrame:SetOwner(UIParent, "ANCHOR_NONE")
			for i = 1, this.maxLines do
				this.fontString[i] = {}
				for j = 1, 2 do
					this.fontString[i][j] = this.tooltipFrame:CreateFontString()
					this.fontString[i][j]:SetFontObject(GameFontNormal)
				end
				this.tooltipFrame:AddFontStrings(this.fontString[i][1], this.fontString[i][2])
			end
			this.minLevelPattern = string.gsub(ITEM_MIN_LEVEL, "(%%d)", "(.+)")
		end

		-- clear tooltip
		local numLines
		numLines = math.min(this.maxLines, this.tooltipFrame:NumLines())
		for i = 1, numLines do
			for j = 1, 2 do
				this.fontString[i][j]:SetText()
				this.fontString[i][j]:SetTextColor(0, 0, 0)
			end
		end

		-- populate tooltip
		this.tooltipFrame:SetHyperlink(link)

		-- search tooltip for red text
		numLines = math.min(this.maxLines, this.tooltipFrame:NumLines())
		for i = 1, numLines do
			for j = 1, 2 do
				local r, g, b = this.fontString[i][j]:GetTextColor()
				if r > 0.8 and g < 0.2 and b < 0.2 then
					-- item is not usable, with one exception: if it doesn't have a level
					-- requirement, red "requires level xxx" text refers to some other item,
					-- e.g. that created by a recipe
					local text = string.lower(this.fontString[i][j]:GetText())
					if not (minLevel == 0 and string.find(text, this.minLevelPattern)) then
						return false
					end
				end
			end
		end

		return true
	end,
}

-- Caching wrapper for ItemUsableTooltip. Invalidates cache when certain events occur
-- (player levels up, learns a new recipe, etc.)
local ItemUsableCached = {
	eventFrame = nil,
	patterns = {},
	cache = {},
	tooltip = ItemUsableTooltip,

	OnEvent = function(this, event, arg1, ...)
		local dirty = false
		-- print("got event " .. event .. ", arg1 " .. arg1)
		if event == "CHAT_MSG_SYSTEM" or event == "CHAT_MSG_SKILL" then
			for _, pattern in pairs(this.patterns) do
				if string.find(arg1, pattern) then
					dirty = true
					break
				end
			end
		elseif event == "PLAYER_LEVEL_UP" then
			dirty = true
		end

		if dirty then
			-- print("invalidating")
			this.cache = {}
		end
	end,

	RegisterChatString = function(this, chatString)
		local pattern = chatString
		pattern = string.gsub(pattern, "(%%s)", "(.+)")
		pattern = string.gsub(pattern, "(%%d)", "(.+)")
		table.insert(this.patterns, pattern)
	end,

	CanUse = function(this, link)
		-- set up if not done already
		if not this.eventFrame then
			this.eventFrame = CreateFrame("Frame")

			-- forward events from frame to self
			this.eventFrame.forwardEventsTo = this
			this.eventFrame:SetScript(
				"OnEvent",
				function(eventFrame, ...)
					eventFrame.forwardEventsTo:OnEvent(...)
				end)

			-- register events and chat patterns
			this.eventFrame:RegisterEvent("CHAT_MSG_SYSTEM")
			this.eventFrame:RegisterEvent("CHAT_MSG_SKILL")
			this.eventFrame:RegisterEvent("PLAYER_LEVEL_UP")

			this:RegisterChatString(ERR_LEARN_ABILITY_S)
			this:RegisterChatString(ERR_LEARN_RECIPE_S)
			this:RegisterChatString(ERR_LEARN_SPELL_S)
			this:RegisterChatString(ERR_SPELL_UNLEARNED_S)
			this:RegisterChatString(ERR_SKILL_GAINED_S)
			this:RegisterChatString(ERR_SKILL_UP_SI)
		end

		local id = EnhTooltip.BreakLink(link)

		-- check cache first. failing that, do a tooltip scan
		if this.cache[id] == nil then
			-- print("miss " .. link) 
			this.cache[id] = this.tooltip:CanUse(link)
		else
			-- print("hit  " .. link) 
		end
		
		return this.cache[id]
	end,
}

private.itemUsable = ItemUsableCached
function private.CanUse(link)
	return private.itemUsable:CanUse(link)
end

AucAdvanced.RegisterRevision("$URL$", "$Rev$")
