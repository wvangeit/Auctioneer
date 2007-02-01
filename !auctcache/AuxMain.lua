--[[
-- This is a debugging tool for Auctioneer and is under the same GPL licence
--]]

Aux = {}

Aux.amCaching = false
Aux.isScanning = false
Aux.curPage = 0
Aux.curCat = nil

Aux.InvTypes = {
	INVTYPE_HEAD = 1,
	INVTYPE_NECK = 2,
	INVTYPE_SHOULDER = 3,
	INVTYPE_BODY = 4,
	INVTYPE_CHEST = 5,
	INVTYPE_WAIST = 6,
	INVTYPE_LEGS = 7,
	INVTYPE_FEET = 8,
	INVTYPE_WRIST = 9,
	INVTYPE_HAND = 10,
	INVTYPE_FINGER = 11,
	INVTYPE_TRINKET = 12,
	INVTYPE_WEAPON = 13,
	INVTYPE_SHIELD = 14,
	INVTYPE_RANGEDRIGHT = 15,
	INVTYPE_CLOAK = 16,
	INVTYPE_2HWEAPON = 17,
	INVTYPE_BAG = 18,
	INVTYPE_TABARD = 19,
	INVTYPE_ROBE = 20,
	INVTYPE_WEAPONMAINHAND = 21,
	INVTYPE_WEAPONOFFHAND = 22,
	INVTYPE_HOLDABLE = 23,
	INVTYPE_AMMO = 24,
	INVTYPE_THROWN = 25,
	INVTYPE_RANGED = 26,
}


function Aux.StartScan(cat)
	Aux.curCat = cat
	Aux.isScanning = true
	Aux.ScanPage(0)
end

local LINK = 1
local ILEVEL = 2
local ITYPE = 3
local ISUB = 4
local IEQUIP = 5
local TLEFT = 6
local TIME = 7
local NAME = 8
local TEXTURE = 9
local COUNT = 10
local QUALITY = 11
local CANUSE = 12
local ULEVEL = 13
local MINBID = 14
local MININC = 15
local BUYOUT = 16
local CURBID = 17
local AMHIGH = 18
local SELLER = 19

local CLASSES = { GetAuctionItemClasses() }

function Aux.Commit()
	if not Aux.curScan then return end
	if not AuxData then AuxData = {} end
	local curAux = AuxData.snap
	AuxData.snap = {}
	if (curAux and Aux.curCat) then
		for _, data in ipairs(curAux) do
			if (CLASSES[Aux.curCat] ~= data[ITYPE]) then
				table.insert(AuxData.snap, data)
			end
		end
	end
	for _, data in ipairs(Aux.curScan) do
		table.insert(AuxData.snap, data)
	end
	Aux.curScan = nil
end

function Aux.ScanPage(nextPage)
	Aux.curPage = nextPage
	QueryAuctionItems("", "", "", nil, Aux.curCat, nil, nextPage, nil, nil)
end

function Aux.StorePage()
	local numBatchAuctions, totalAuctions = GetNumAuctionItems("list");
	local maxPages = floor(totalAuctions / NUM_AUCTION_ITEMS_PER_PAGE);
	if (not Aux.curScan) then Aux.curScan = {} end

	-- Take a snapshot of everything we've got so far.
	for i = 1, numBatchAuctions do
		local link = GetAuctionItemLink("list", i)
		if (link) then
			local _,_,_,itemLevel,_,itemType,itemSubType,_,itemEquipLoc,_ = GetItemInfo(link)
			table.insert(Aux.curScan, { GetAuctionItemLink("list", i), itemLevel, itemType,itemSubType,itemEquipLoc, GetAuctionItemTimeLeft("list", i), time(), GetAuctionItemInfo("list", i) })
		end
	end

	-- Send the next page query or finish scanning
	if (Aux.curPage < maxPages) then
		Aux.ScanPage(Aux.curPage + 1)
	else
		Aux.isScanning = false
		Aux.Commit()
	end
end

function Aux.ThrowUpdate()
	AuctionFrameBrowse_Update()
	if (Stubby) then Stubby.Events("AUCTION_ITEM_LIST_UPDATE") end
end
		
Aux.Hook = {}
Aux.Hook.CanSendAuctionQuery = CanSendAuctionQuery
function CanSendAuctionQuery(...)
	-- See if we are in caching mode.
	if Aux.amCaching then
		local interval = Aux.pageInterval or 0.5
		if not Aux.lastReq or GetTime() - Aux.lastReq > interval then
			return true
		else
			return false
		end
	end

	-- Call the original hook
	local res = { Aux.Hook.CanSendAuctionQuery(...) }
	if res[1] then
		if Aux.isScanning then
			-- Take a snapshot of the page as it is currently
			Aux.StorePage()
		end
	end
	
	return unpack(res)
end

Aux.Hook.QueryAuctionItems = QueryAuctionItems
function QueryAuctionItems(name, minLevel, maxLevel, invTypeIndex, classIndex, subclassIndex, page, isUsable, qualityIndex)
	-- See if we are in caching mode.
	if Aux.isScanning or Aux.amCaching then
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
		if (classIndex > 0) then query.class = Aux.ClassConvert(classIndex) end
		if (subclassIndex > 0) then query.subclass = Aux.ClassConvert(classIndex, subclassIndex) end
		if (qualityIndex and qualityIndex > 0) then query.quality = qualityIndex end
		Aux.curQuery = query
		Aux.lastReq = GetTime()
		if Aux.amCaching then
			return Aux.ThrowUpdate()
		end
	end
	p("Query:", name, minLevel, maxLevel, invTypeIndex, classIndex, subclassIndex, page, isUsable, qualityIndex)
	Aux.Hook.QueryAuctionItems(name, minLevel, maxLevel, invTypeIndex, classIndex, subclassIndex, page, isUsable, qualityIndex)
end

Aux.Hook.GetNumAuctionItems = GetNumAuctionItems
function GetNumAuctionItems(...)
	-- See if we are in caching mode.
	local lType = select(1, ...)
	if lType == "list" and Aux.amCaching then
		if (not Aux.curQuery) then return 0,0 end
		-- Do our funky cache thingo
		local numAucts = #AuxData.snap
		local page = Aux.curQuery.page
		local maxPages = math.ceil(numAucts/NUM_AUCTION_ITEMS_PER_PAGE)
		if (page == maxPages) then
			return numAucts % NUM_AUCTION_ITEMS_PER_PAGE, numAucts
		end
		return NUM_AUCTION_ITEMS_PER_PAGE, numAucts
	end

	-- Call the original hook
	return Aux.Hook.GetNumAuctionItems(...)
end

Aux.Hook.GetAuctionItemLink = GetAuctionItemLink
function GetAuctionItemLink(...)
	-- See if we are in caching mode.
	local lType, lPos = select(1, ...)
	if lType == "list" and Aux.amCaching then
		if (not Aux.curQuery) then return end
		-- Do our funky cache thingo
		local page = Aux.curQuery.page
		local curPos = page * NUM_AUCTION_ITEMS_PER_PAGE + lPos
		local data = AuxData.snap[curPos]
		if (data) then
			return data[LINK]
		end
		return
	end

	-- Call the original hook
	return Aux.Hook.GetAuctionItemLink(...)
end

Aux.Hook.GetAuctionItemTimeLeft = GetAuctionItemTimeLeft
function GetAuctionItemTimeLeft(...)
	-- See if we are in caching mode.
	local lType, lPos = select(1, ...)
	if lType == "list" and Aux.amCaching then
		if (not Aux.curQuery) then return end
		-- Do our funky cache thingo
		local page = Aux.curQuery.page
		local curPos = page * NUM_AUCTION_ITEMS_PER_PAGE + lPos
		local data = AuxData.snap[curPos]
		if (data) then
			return data[TLEFT]
		end
		return
	end

	-- Call the original hook
	return Aux.Hook.GetAuctionItemTimeLeft(...)
end

Aux.Hook.GetAuctionItemInfo = GetAuctionItemInfo
function GetAuctionItemInfo(...)
	-- See if we are in caching mode.
	local lType, lPos = select(1, ...)
	if lType == "list" and Aux.amCaching then
		if (not Aux.curQuery) then return end
		-- Do our funky cache thingo
		local page = Aux.curQuery.page
		local curPos = page * NUM_AUCTION_ITEMS_PER_PAGE + lPos
		local data = AuxData.snap[curPos]
		if (data) then
			return unpack(data, NAME, SELLER)
		end
		return
	end

	-- Call the original hook
	return Aux.Hook.GetAuctionItemInfo(...)
end


