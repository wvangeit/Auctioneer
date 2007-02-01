--[[
-- This is a debugging tool for Auctioneer and is under the same GPL licence
--]]


Aux = {}

Aux.amCaching = false
Aux.isScanning = false
Aux.curPage = 0


Aux.InvConstants = {
	[INVTYPE_HEAD] = 1,
	[INVTYPE_NECK] = 2,
	[INVTYPE_SHOULDER] = 3,
	[INVTYPE_BODY] = 4,
	[INVTYPE_CHEST] = 5,
	[INVTYPE_WAIST] = 6,
	[INVTYPE_LEGS] = 7,
	[INVTYPE_FEET] = 8,
	[INVTYPE_WRIST] = 9,
	[INVTYPE_HAND] = 10,
	[INVTYPE_FINGER] = 11,
	[INVTYPE_TRINKET] = 12,
	[INVTYPE_WEAPON] = 13,
	[INVTYPE_SHIELD] = 14,
	[INVTYPE_RANGEDRIGHT] = 15,
	[INVTYPE_CLOAK] = 16,
	[INVTYPE_2HWEAPON] = 17,
	[INVTYPE_BAG] = 18,
	[INVTYPE_TABARD] = 19,
	[INVTYPE_ROBE] = 20,
	[INVTYPE_WEAPONMAINHAND] = 21,
	[INVTYPE_WEAPONOFFHAND] = 22,
	[INVTYPE_HOLDABLE] = 23,
	[INVTYPE_AMMO] = 24,
	[INVTYPE_THROWN] = 25,
	[INVTYPE_RANGED] = 26,
}



function Aux.StartScan()
	Aux.curPage = 0
	Aux.isScanning = true
end

function Aux.






Aux.Hook = {}
Aux.Hook.CanSendAuctionQuery = CanSendAuctionQuery
function CanSendAuctionQuery(...)
	-- See if we are in caching mode.
	if Aux.amCaching then
		if GetTime() - Aux.lastReq > Aux.pageInterval then
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
	
	return unpack(res, 0, #res)
end

Aux.Hook.QueryAuctionItems = QueryAuctionItems
function QueryAuctionItems(name, minLevel, maxLevel, invTypeIndex, classIndex, subclassIndex, page, isUsable, qualityIndex)
	-- See if we are in caching mode.
	if Aux.amCaching then
		query = {}
		minLevel = tonumber(minLevel) or 0
		maxLevel = tonumber(maxLevel) or 0
		if (name and name ~= "") then query.name = name end
		if (minLevel > 0) then query.minUseLevel = minLevel end
		if (maxLevel > 0) then query.maxUseLevel = maxLevel end
		if ( ~= "") then query.name = name end
		if (name and name ~= "") then query.name = name end
		if (name and name ~= "") then query.name = name end
		Aux.ExecQuery(
end

