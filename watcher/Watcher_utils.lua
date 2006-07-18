--[[
WatchDatabase WoW AddOn
-----------------------
This addon is (c)2006 norganna.org
You are granted the right to copy and use this addon for personal uses and only in it's unaltered state.
You may not host nor distribute this addon in any fashion. All rights are reserved by Norganna's AddOns.
http://norganna.org/watcher/
-----------------------
$Id$
]]

Watcher.timeslice = function()
	-- Returns the number of 1/10th of a minute intervals elapsed since 2006-01-01
	return math.floor((time() - 1136073600)/6)
	-- 1136073600 is the number of seconds from epoch till 2006-01-01 00:00:00 GMT
	-- there are ten 6 second blocks in a minute (10*6 = 60 seconds)
end

Watcher.debug = function(msg, force)
	if (Watcher_Config.debug or force) then
		DEFAULT_CHAT_FRAME:AddMessage("Watcher: "..msg, 0.3,0.5,0.9)
	end
end

Watcher.doExpiryCheck = function()
	local expire = date("%Y%m%d", time()-7*86400)
	if (Watcher_Config.auctions) then
		for scandate, scan in Watcher_Config.auctions do
			if scandate < expire then
				Watcher_Config.auctions[scandate] = nil
			end
		end
	end
	Watcher.expiryCheck = date("%Y%m%d")
end

Watcher.findInBags = function(findName, findCount)
	local bagSearch
	local c, size, link, texture, count, itemDes, itemName, _
	for bag=0, 4, 1 do
		size = GetContainerNumSlots(bag)
		if (size) then
			for slot=size, 1, -1 do
				link = GetContainerItemLink(bag, slot)
				if (link) then
					itemDes, _,_,_,_, itemName = Watcher.getItemDes(link)
					local texture, count = GetContainerItemInfo(frameID, buttonID)
					if (itemName == findName) then
						c = Watcher.bagSearch[itemID] or 0
						if (c >= findCount) then return itemDes end
						if (not bagSearch) then bagSearch = {} end
						bagSearch[itemID] = c + count
					end
				end
			end
		end
	end

	if (bagSearch) then
		for itemDes, count in pairs(bagSearch) do
			if (count >= findCount) then
				return itemDes
			end
		end
	end
end

Watcher.initCheck = function()
	if (not Watcher_Config.aid) then
		local player = UnitName("player")
		local realm = GetRealmName()
		Watcher_Config.aid = string.sub(string.upper(player), 1,3)..string.sub(string.upper(realm),1,3)..Watcher.fvnHash(time()..player..realm..math.random(10000))
	end
end

Watcher.getUnitDes = function(unit)
	local unitName = UnitName(unit)
	if (not unitName) then return "anonymous" end
	local level = UnitLevel(unit)
	local react = UnitReaction(unit, "player")
	if (not react) then react = 0 end
	
	local faction = UnitFactionGroup("player")
	local key = "units"..faction
	
	if (not Watcher_Config[key]) then Watcher_Config[key] = {} end
	local unitData = Watcher_Config[key]
	local min = level
	local max = level
	local store
	if (unitData[unitName]) then
		local data = unitData[unitName]
		max = bit.band(data, 127)
		min = bit.band(bit.rshift(data, 7), 127)
		if (level < min) then
			min = level
			store = true
		elseif (level > max) then
			max = level
			store = true
		end
	else
		store = true
	end

	if (store and react >= 0 and min > 0 and max > 0) then
		-- Reaction's max is 5, so 4 bits = 15
		-- Minimum level's max is about 70, so 7 bits = 128
		-- Maximum level's max is about 70, 20 7 bits = 128
		--
		--  1 : 1     :
		--  8.:.4.....:7......
		--  Rea>Minim->Maxim->
		--  <4-><--7--><--7-->
		--
		unitData[unitName] = bit.lshift(react, 14)+bit.lshift(min, 7)+max
	end

	if (not CheckInteractDistance(unit, 1)) then return "anonymous" end
	return unitName
end

Watcher.getItemDes = function(link, quantity)
	if (type(link) ~= 'string') then return 0,0,0,0,0,"" end
	if (not quantity) then quantity = 1 end
	local _,_, sitem, senchant, srandom, suniq, name = string.find(link, "|Hitem:(%d+):(%d+):(%d+):(%d+)|h[[]([^]]+)[]]|h")
	local item = tonumber(sitem) or 0
	local enchant = tonumber(senchant) or 0
	local random = tonumber(srandom) or 0
	local uniq = tonumber(suniq) or 0

	-- Ok, so here we get the fun job of cramming an full item id (minus the uniq id,
	-- plus an item count) into a single 53 bit portion of the mantissa of a double.
	--
	-- Here are the ranges that we are assuming: (note there is ample room for growth)
	-- item enchantment's max is 4000, so 13 bits = 8,191
	-- random property's max is 8000, so 14 bits = 16,383
	-- item id's max is under 20k, so 17 bits = 131,071
	-- count quantity's max is 200, so 8 bits = 255
	-- 13 + 14 + 17 + 8 = 52 bits (mantissa is 53 bits)
	-- Bit offsets:
	--
	--   5   :       :3      :      2:       :       :
	--   2...:.......:9......:......5:.......:.......8.......
	--   Enchant----->RandomProp--->ItemID---------->Count-->
	--   <---13bits--><---14bits---><-----17bits----><-8bits>
	--
	if (enchant > 8191) then Watcher.debug("ERROR: Enchantment of item "..link.." is > 8191 ("..enchant..")", true) enchant = 0 end
	if (random > 16383) then Watcher.debug("ERROR: Random property of item "..link.." is > 16383 ("..random..")", true) random = 0 end
	if (item > 131071) then Watcher.debug("ERROR: Item ID of item "..link.." is > 131071 ("..item..")", true) item = 0 end
	if (quantity > 255) then Watcher.debug("ERROR: Quantity of item "..link.." is > 255 ("..item..")", true) quantity = 0 end
	
	local itemDes = bit.lshift(enchant, 39) + bit.lshift(random, 25) + bit.lshift(item, 8) + quantity
	return itemDes, sitem, senchant, srandom, suniq, name
end

Watcher.getPlayerDes = function()
	return GetRealmName().."/"..UnitFactionGroup("player").."/"..UnitName("player")
end
