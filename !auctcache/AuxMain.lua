--[[
-- This is a debugging tool for Auctioneer and is under the same GPL licence
--]]

Aux = {}

Aux.amCaching = false
Aux.isScanning = false
Aux.noBlankOwner = true
Aux.numPerPage = 50000
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


function Aux.Caching(enabled)
	if (enabled) then
		Aux.amCaching = true
		NUM_AUCTION_ITEMS_PER_PAGE = Aux.numPerPage
	else
		Aux.amCaching = false
		NUM_AUCTION_ITEMS_PER_PAGE = 50
	end
end
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
local SUBCLASSES = { }
for i = 1, #CLASSES do
	SUBCLASSES[i] = { GetAuctionItemSubClasses(i) }
end

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
	local maxPages = floor(totalAuctions / Aux.numPerPage);
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

function Aux.ClassConvert(cid, sid)
	if (sid) then
		return SUBCLASSES[cid][sid]
	end
	return CLASSES[cid]
end

local lastThrow, scheduleThrow
function Aux.ThrowUpdate()
	scheduleThrow = false
	lastThrow = GetTime()

	-- Simulate AuctionFrameBrowse_OnEvent
	AuctionFrameBrowse_Update()
	AuctionFrameBrowse.isSearching = nil;
	BrowseNoResultsText:SetText(BROWSE_NO_RESULTS);
	-- Run any Stubby hooks for auction list updates
	if (Stubby) then Stubby.Events("AUCTION_ITEM_LIST_UPDATE") end
end
function Aux.NeedUpdate()
	lastThrow = GetTime()
	scheduleThrow = true
end

local curMode
function Aux.AucItemEnter(obj)
	local parent = obj:GetParent()
	local pos = parent:GetID() + FauxScrollFrame_GetOffset(BrowseScrollFrame)

	if (curMode) then
		local link = GetAuctionItemLink("list", pos)
		GameTooltip:SetOwner(parent, "ANCHOR_RIGHT")
		GameTooltip:SetHyperlink(link)
		GameTooltip:ClearAllPoints()
		GameTooltip:SetPoint("TOPLEFT", obj, "BOTTOMRIGHT", 10, 5)
		if (EnhTooltip) then
			local name,_,count,quality,_,_,_,_,buyout = GetAuctionItemInfo("list", pos)
			EnhTooltip.TooltipCall(GameTooltip, name, link, quality, count, buyout)
		end
		if IsControlKeyDown() then ShowInspectCursor()
		else ResetCursor() end
	else
		AuctionFrameItem_OnEnter("list", pos)
	end
end

function Aux.ButtonMode(display)
	for i=1, NUM_BROWSE_TO_DISPLAY do
		local o = getglobal("BrowseButton"..i)
		if o then
			local t = o.cachedTex
			if not t then
				t = o:CreateTexture("", "BACKGROUND")
				t:SetPoint("TOPLEFT", o, "TOPLEFT")
				t:SetPoint("BOTTOMRIGHT", o, "BOTTOMRIGHT")
				t:SetTexture(0.3,0.1,0, 0.35)
				o.cachedTex = t
				local b = getglobal("BrowseButton"..i.."Item")
				b:SetScript("OnEnter", Aux.AucItemEnter)
			end
			if display then
				t:Show()
			else
				t:Hide()
			end
			curMode = display
		end
	end
end

local curQuery = { empty = true }
local curResults = {}

function Aux.GetResults()
	if not AuxData or not AuxData.snap then return end
	Aux.ButtonMode(true)

	local invalid = false
	for k,v in pairs(Aux.curQuery) do
		if k ~= "page" and v ~= curQuery[k] then invalid = true end
	end
	for k,v in pairs(curQuery) do
		if k ~= "page" and v ~= Aux.curQuery[k] then invalid = true end
	end
	if not invalid then return end

	local numResults = #curResults
	for i=1, numResults do curResults[i] = nil end
	for k,v in pairs(curQuery) do curQuery[k] = nil end
	for k,v in pairs(Aux.curQuery) do curQuery[k] = v end

	local ptr, max = 1, #AuxData.snap
	while ptr <= max do
		repeat
			local data = AuxData.snap[ptr] ptr = ptr + 1
			if (not data) then break end
			if curQuery.minUseLevel and data[ULEVEL] < curQuery.minUseLevel then break end
			if curQuery.maxUseLevel and data[ULEVEL] > curQuery.maxUseLevel then break end
			if curQuery.minItemLevel and data[ILEVEL] < curQuery.minItemLevel then break end
			if curQuery.maxItemLevel and data[ILEVEL] > curQuery.maxItemLevel then break end
			if curQuery.class and data[ITYPE] ~= curQuery.class then break end
			if curQuery.subclass and data[ISUB] ~= curQuery.subclass then break end
			if curQuery.quality and data[QUALITY] ~= curQuery.quality then break end
			if curQuery.invType and data[IEQUIP] then
				local equipType = Aux.InvTypes[data[IEQUIP]]
				if equipType ~= curQuery.invType then break end
			end
			if curQuery.seller and data[SELLER] ~= curQuery.seller then break end
			if curQuery.name then
				local name = data[NAME]:lower()
				if not name:find(curQuery.name:lower(), 1, true) then break end
			end

			local stack = data[COUNT]
			local buyout = data[BUYOUT] or 0
			local nextBid = data[MINBID]
			if not stack or stack < 1 then stack = 1 end
			if data[CURBID] then nextBid = data[CURBID]+data[MININC] end
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
end

Aux.Hook = {}
Aux.Hook.CanSendAuctionQuery = CanSendAuctionQuery
function CanSendAuctionQuery(...)
	-- See if we are in caching mode.
	if Aux.amCaching then
		local interval = Aux.pageInterval or 0.5
		if scheduleThrow and GetTime() - lastThrow > 0.5 then
			Aux.ThrowUpdate()
		end
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
		if (invTypeIndex and invTypeIndex ~= "") then query.invType = invTypeIndex end
		Aux.curQuery = query
		Aux.lastReq = GetTime()
		if Aux.amCaching then
			Aux.GetResults()
			Aux.NeedUpdate()
			return
		end
	end
	Aux.ButtonMode(false)
	Aux.Hook.QueryAuctionItems(name, minLevel, maxLevel, invTypeIndex, classIndex, subclassIndex, page, isUsable, qualityIndex)
end

Aux.Hook.GetNumAuctionItems = GetNumAuctionItems
function GetNumAuctionItems(...)
	-- See if we are in caching mode.
	local lType = select(1, ...)
	if lType == "list" and Aux.amCaching then
		if not (curResults and curQuery and curQuery.page) then
			return 0,0
		end
		-- Do our funky cache thingo
		local numAucts = #curResults
		if (numAucts == 0) then return 0,0 end
		local page = curQuery.page
		local maxPages = math.ceil(numAucts/Aux.numPerPage) - 1
		local pageCount = Aux.numPerPage
		if (page == maxPages) then
			pageCount = ((numAucts-1) % Aux.numPerPage) + 1
		end
		return pageCount, numAucts
	end

	-- Call the original hook
	return Aux.Hook.GetNumAuctionItems(...)
end

Aux.Hook.GetAuctionItemLink = GetAuctionItemLink
function GetAuctionItemLink(...)
	-- See if we are in caching mode.
	local lType, lPos = select(1, ...)
	if lType == "list" and Aux.amCaching then
		if not (curResults and curQuery and curQuery.page) then return end
		-- Do our funky cache thingo
		local page = curQuery.page
		local curPos = page * Aux.numPerPage + lPos
		local data = curResults[curPos]
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
		if not (curResults and curQuery and curQuery.page) then return end
		-- Do our funky cache thingo
		local page = curQuery.page
		local curPos = page * Aux.numPerPage + lPos
		local data = curResults[curPos]
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
		if not (curResults and curQuery and curQuery.page) then
			return nil,nil,1,-1,nil,0,0,0,0,0,nil,nil
		end
		-- Do our funky cache thingo
		local page = curQuery.page
		local curPos = page * Aux.numPerPage + lPos
		local data = curResults[curPos]
		if (data) then
			local name,texture,count,quality,canUse,level,minBid,minIncrement,buyoutPrice,bidAmount,highBidder,owner = unpack(data, NAME, SELLER)
			if (Aux.noBlankOwner) then
				owner = owner or "Anon"
			end
			return name,texture,count,quality,canUse,level,minBid,minIncrement,buyoutPrice,bidAmount,highBidder,owner
		end
		return nil,nil,1,-1,nil,0,0,0,0,0,nil,nil
	end

	-- Call the original hook
	return Aux.Hook.GetAuctionItemInfo(...)
end


