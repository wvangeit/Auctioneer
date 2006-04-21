--[[
	Enchantrix Addon for World of Warcraft(tm).
	Version: <%version%> (<%codename%>)
	Revision: $Id: EnxCommand.lua 817 2006-04-11 15:50:14Z aradan $

	Database functions and saved variables.

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
		along with this program(see GLP.txt); if not, write to the Free Software
		Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
--]]

-- Global functions
local addonLoaded			-- Enchantrix.Storage.AddonLoaded()
local saveDisenchant		-- Enchantrix.Storage.SaveDisenchant()
local getItemDisenchants	-- Enchantrix.Storage.GetItemDisenchants()

-- Local functions
local unserialize
local serialize
local mergeDisenchant
local normalizeDisenchant
local cleanupDisenchant
local disenchantTotal
local disenchantListHash
local mergeDisenchantLists
local saveLocal
local getLocal

-- Database
local LocalBaseItems = {} -- EnchantedLocal merged by item id
local EnchantedItemTypes = {} -- LocalBaseItems and EnchantedBaseItems merged by type

local N_DISENCHANTS = 1
local N_REAGENTS = 2

Enchantrix.State.MAX_ITEM_ID = 26000

local const = Enchantrix.Constants

function addonLoaded()
	-- Create and setup saved variables
	if not EnchantConfig then
		EnchantConfig = {}
	end
	if not EnchantConfig.filters then
		EnchantConfig.filters = {}
	end
	if not EnchantConfig.cache then
		EnchantConfig.cache = {}
	end
	if not EnchantConfig.cache.reagentinfo then
		EnchantConfig.cache.reagentinfo = {}
	end
	if not EnchantedLocal then
		EnchantedLocal = {}
	end
	if not EnchantedBaseItems then
		EnchantedBaseItems = {}
	end

	if not EnchantConfig.zomgBlizzardAreMeanies then
		-- Push disenchant reagents into cache if needed
		for id in Enchantrix.Constants.StaticPrices do
			if not (Enchantrix.Util.GetReagentInfo(id)) then
				EnchantConfig.zomgBlizzardAreMeanies = true
				GameTooltip:SetHyperlink("item:"..id..":0:0:0")
				GameTooltip:Hide()
				EnchantConfig.zomgBlizzardAreMeanies = nil
			end
		end
	else
		-- We were kicked from the server last time, better not try that again for a while
		EnchantConfig.zomgBlizzardAreMeanies = nil
	end

	mergeDisenchantLists()
end

function unserialize(str)
	-- Break up a disenchant string to a table for easy manipulation
	local tbl = {}
	if type(str) == "string" then
		for de in Enchantrix.Util.Spliterator(str, ";") do
			local splt = Enchantrix.Util.Split(de, ":")
			local id, d, r = tonumber(splt[1]), tonumber(splt[2]), tonumber(splt[3])
			if (id and d > 0 and r > 0) then
				tbl[id] = {[N_DISENCHANTS] = d, [N_REAGENTS] = r}
			end
		end
	end
	return tbl
end

function serialize(tbl)
	-- Serialize a table into a string
	if type(tbl) == "table" then
		local str
		for id in tbl do
			if (type(id) == "number" and tbl[id][N_DISENCHANTS] > 0 and tbl[id][N_REAGENTS] > 0) then
				if (str) then
					str = str..";"..string.format("%d:%d:%d:0", id, tbl[id][N_DISENCHANTS], tbl[id][N_REAGENTS])
				else
					str = string.format("%d:%d:%d:0", id, tbl[id][N_DISENCHANTS], tbl[id][N_REAGENTS])
				end
			end
		end
		return str
	end
end

function mergeDisenchant(str1, str2)
	-- Merge two disenchant strings into a single string
	local tbl1, tbl2 = unserialize(str1), unserialize(str2)
	for id in tbl2 do
		if (not tbl1[id]) then
			tbl1[id] = tbl2[id]
		else
			tbl1[id][N_DISENCHANTS] = tbl1[id][N_DISENCHANTS] + tbl2[id][N_DISENCHANTS]
			tbl1[id][N_REAGENTS] = tbl1[id][N_REAGENTS] + tbl2[id][N_REAGENTS]
		end
	end
	return serialize(tbl1)
end

function normalizeDisenchant(str)
	-- Divide all counts in disenchant string by gcd
	local div = 0
	local count = 0
	local tbl = unserialize(str)
	for id in tbl do
		div = Enchantrix.Util.GCD(div, tbl[id][N_DISENCHANTS])
		div = Enchantrix.Util.GCD(div, tbl[id][N_REAGENTS])
		count = count + 1
	end
	-- Only normalize if there's more than one kind of reagent
	if count > 1 then
		for id in tbl do
			tbl[id][N_DISENCHANTS] = tbl[id][N_DISENCHANTS] / div
			tbl[id][N_REAGENTS] = tbl[id][N_REAGENTS] / div
		end
		return serialize(tbl)
	end
	return str
end

function cleanupDisenchant(str, id)
	-- Remove reagents that don't appear in level rules table
	if (type(str) == "string") and (id ~= nil) then
		local _, _, quality, level, _, _, _, equip = GetItemInfo(id)
		local itype = const.InventoryTypes[equip]
		if quality and itype then
			local tbl = unserialize(str)
			local clean = {}
			level = Enchantrix.Util.RoundUp(level, 5)
			for id in tbl do
				if const.LevelRules[itype][level][id] then
					if quality == 2 then
						-- Uncommon item, remove nexus crystal
						if (const.LevelRules[itype][level][id] < const.CRYSTAL) then
							clean[id] = tbl[id]
						end
					else
						-- Rare or epic item, remove dusts and essences
						if (const.LevelRules[itype][level][id] > const.ESSENCE_GREATER) then
							clean[id] = tbl[id]
						end
					end
				end
			end
			return serialize(clean)
		end
	end
	return str
end

function disenchantTotal(str)
	-- Return total number of disenchants
	local tot = 0
	local tbl = unserialize(str)
	for id in tbl do
		tot = tot + tbl[id][N_DISENCHANTS]
	end
	return tot
end

function disenchantListHash()
	-- Generate a hash for DisenchantList
	local hash = 1
	local id
	for sig, val in pairs(DisenchantList) do
		id = Enchantrix.Util.GetItemIdFromSig(sig)
		Enchantrix.State.MAX_ITEM_ID = math.max(Enchantrix.State.MAX_ITEM_ID, id or 0)
		hash = math.mod(3 * hash + 2 * (id or 0) + string.len(val), 16777216)
	end
	return hash
end

function mergeDisenchantLists()
	-- Merge DisenchantList by base item, i.e. all "Foobar of <x>" are merged into "Foobar"
	-- This can be rather time consuming so we store this in a saved variable and use a hash
	-- signature to determine if we need to update the table
	local hash = disenchantListHash()
	if (not EnchantedBaseItems.hash) then
		EnchantedBaseItems.hash = -hash
	end
	if (EnchantedBaseItems.hash ~= hash) then
		-- Hash has changed, update EnchantedBaseItems
		EnchantedBaseItems = {}
		for sig, disenchant in pairs(DisenchantList) do
			local item = Enchantrix.Util.GetItemIdFromSig(sig)
			if (Enchantrix.Util.IsDisenchantable(item)) then
				EnchantedBaseItems[item] = mergeDisenchant(EnchantedBaseItems[item],
					normalizeDisenchant(disenchant))
			end
		end
		EnchantedBaseItems.hash = hash
	end
	-- We don't need DisenchantList anymore
	DisenchantList = nil

	-- Merge items from EnchantedLocal
	for sig, disenchant in pairs(EnchantedLocal) do
		local item = Enchantrix.Util.GetItemIdFromSig(sig)
		if type(disenchant) == "table" then
			saveLocal(sig, disenchant)
			disenchant = EnchantedLocal[sig]
		end
		if Enchantrix.Util.IsDisenchantable(item) and (type(disenchant) == "string") then
			LocalBaseItems[item] = mergeDisenchant(LocalBaseItems[item], disenchant)
		end
	end

	-- Merge by item type
	for id, disenchant in pairs(EnchantedBaseItems) do
		local itype = Enchantrix.Util.GetItemType(id)
		if itype then
			EnchantedItemTypes[itype] = mergeDisenchant(EnchantedItemTypes[itype], disenchant)
		end
	end
	for id, disenchant in pairs(LocalBaseItems) do
		local itype = Enchantrix.Util.GetItemType(id)
		if itype then
			EnchantedItemTypes[itype] = mergeDisenchant(EnchantedItemTypes[itype], disenchant)
		end
	end
end

function saveDisenchant(sig, reagentID, count)
	-- Update tables after a disenchant has been detected
	assert(type(sig) == "string"); assert(tonumber(reagentID)); assert(tonumber(count))

	local id = Enchantrix.Util.GetItemIdFromSig(sig)
	local itype = Enchantrix.Util.GetItemType(id)
	local disenchant = string.format("%d:1:%d:0", reagentID, count)
	EnchantedLocal[sig] = mergeDisenchant(EnchantedLocal[sig], disenchant)
	LocalBaseItems[id] = mergeDisenchant(LocalBaseItems[id], disenchant)
	if itype then
		EnchantedItemTypes[itype] = mergeDisenchant(EnchantedItemTypes[itype], disenchant)
	end
end

function saveLocal(sig, lData)
	local str = "";
	for eResult, eData in lData do
		if (eData and type(eData) == "table") then
			local iCount = tonumber(eData.i) or 0;
			local dCount = tonumber(eData.d) or 0;
			local oCount = tonumber(eData.o) or 0;
			local serial = string.format("%d:%d:%d:%d", eResult, iCount, dCount, oCount);
			if (str == "") then str = serial else str = str..";"..serial end
		else
			eData = nil;
		end
	end
	EnchantedLocal[sig] = str;
end

function getLocal(sig)
	local enchantItem = {};
	if (EnchantedLocal and EnchantedLocal[sig]) then
		if (type(EnchantedLocal[sig]) == "table") then
			-- Time to convert it into the new serialized format
			saveLocal(sig, EnchantedLocal[sig]);
		end

		-- Get the string and break it apart
		for enchantResult in Enchantrix.Util.Spliterator(EnchantedLocal[sig], ";") do
			local enchantBreak = Enchantrix.Util.Split(enchantResult, ":");
			local rSig = tonumber(enchantBreak[1]) or 0;
			local iCount = tonumber(enchantBreak[2]) or 0;
			local dCount = tonumber(enchantBreak[3]) or 0;
			local oCount = tonumber(enchantBreak[4]) or 0;

			enchantItem[rSig] = { i=iCount, d=dCount, o=oCount };
		end
	end
	return enchantItem;
end

function getItemDisenchants(sig, name, useCache)
	local disenchantsTo = {};

	if (not Enchantrix.Storage.Price_Cache) or (time()-Enchantrix.Storage.Price_Cache.t > 300) then
		Enchantrix.Storage.Price_Cache = {t=time()};
	end

	-- Automatically convert any named EnchantedLocal items to new items
	if (name and EnchantedLocal[name]) then
		local iData = getLocal(name)
		for dName, count in iData do
			local link = Enchantrix.Util.GetLinkFromName(dName);
			local dSig = Enchantrix.Util.GetItemIdFromLink(link)
			if (dSig ~= nil) then
				if (not iData[dSig]) then iData[dSig] = {}; end
				local oCount = tonumber(iData[dSig].o);
				if (oCount == nil) then oCount = 0; end
				iData[dSig].o = ""..count;
			end
		end
		EnchantedLocal[name] = nil;
		saveLocal(sig, iData);
	end

	local item = Enchantrix.Util.GetItemIdFromSig(sig)
	if (not (item and Enchantrix.Util.IsDisenchantable(item))) then
		-- Item is not disenchantable
		return {}
	end

	-- If there is data, then work out the disenchant data
	if (EnchantedBaseItems[item] or LocalBaseItems[item]) then
		local biTotal = 0;
		local bdTotal = 0;
		local iTotal = 0;
		local dTotal = 0;

		local baseDisenchant = EnchantedBaseItems[item]

		local itype = Enchantrix.Util.GetItemType(item)
		if (itype and EnchantedItemTypes[itype]) then
			if (disenchantTotal(EnchantedItemTypes[itype]) > disenchantTotal(baseDisenchant)) then
				baseDisenchant = EnchantedItemTypes[itype]
			end
		end

		baseDisenchant = cleanupDisenchant(baseDisenchant, item)

		if (baseDisenchant) then
			-- Base Disenchantments are now serialized
			local baseResults = unserialize(baseDisenchant)
			for dSig, counts in pairs(baseResults) do
				if (dSig > 0) then
					disenchantsTo[dSig] = {
						biCount = counts[N_DISENCHANTS],
						bdCount = counts[N_REAGENTS],
						iCount = 0,
						dCount = 0,
					}
					biTotal = biTotal + counts[N_DISENCHANTS]
					bdTotal = bdTotal + counts[N_REAGENTS]
				end
			end
		end

		if (LocalBaseItems[item]) then
			local enchantedLocal = unserialize(LocalBaseItems[item])
			for dSig, counts in pairs(enchantedLocal) do
				if (dSig and dSig > 0) then
					if (not disenchantsTo[dSig]) then
						disenchantsTo[dSig] = {biCount = 0, bdCount = 0, iCount = 0, dCount = 0}
					end
					disenchantsTo[dSig].dCount = counts[N_REAGENTS]
					disenchantsTo[dSig].iCount = counts[N_DISENCHANTS]

					dTotal = dTotal + counts[N_REAGENTS]
					iTotal = iTotal + counts[N_DISENCHANTS]
				end
			end
		end

		local total = biTotal + iTotal;

		local hspGuess = 0;
		local medianGuess = 0;
		local marketGuess = 0;
		if (total > 0) then
			for dSig, counts in disenchantsTo do
				local item = 0;
				if (dSig) then item = tonumber(dSig); end
				local dName = Enchantrix.Util.GetReagentInfo(item);
				if (not dName) then dName = "Item "..dSig; end
				local count = (counts.biCount or 0) + (counts.iCount or 0);
				local countI = (counts.biCount or 0) + (counts.iCount or 0);
				local countD = (counts.bdCount or 0) + (counts.dCount or 0);
				local pct = tonumber(string.format("%0.1f", count / total * 100));
				local rate = 0;
				if (countI > 0) then
					rate = tonumber(string.format("%0.1f", countD / countI));
					if (not rate) then rate = 0; end
				end

				local count = 1;
				if (rate and rate > 0) then count = rate; end
				disenchantsTo[dSig].name = dName;
				disenchantsTo[dSig].pct = pct;
				disenchantsTo[dSig].rate = count;
				local mkt = const.StaticPrices[item] or 0

				-- Work out what version if any of Auctioneer is installed
				local auctVerStr;
				if (not Auctioneer) then
					auctVerStr = AUCTIONEER_VERSION or "0.0.0";
				else
					auctVerStr = AUCTIONEER_VERSION or Auctioneer.Version or "0.0.0";
				end
				local auctVer = Enchantrix.Util.Split(auctVerStr, ".");
				local major = tonumber(auctVer[1]) or 0;
				local minor = tonumber(auctVer[2]) or 0;
				local rev = tonumber(auctVer[3]) or 0;
				if (auctVer[3] == "DEV") then rev = 0; minor = minor + 1; end

				local itemKey = string.format("%d:0:0", item);
				if (useCache and not Enchantrix.Storage.Price_Cache[itemKey]) then
					Enchantrix.Storage.Price_Cache[itemKey] = {};
				end

				local hsp, median;
				if (useCache and Enchantrix.Storage.Price_Cache[itemKey].hsp) then
					hsp = Enchantrix.Storage.Price_Cache[itemKey].hsp;
				end

				if ((not hsp or hsp < 1) and (major >= 3)) then
					if (major == 3 and minor == 0 and rev <= 11) then
						-- 3.0.0 <= ver <= 3.0.11
						if (rev == 11) then
							hsp = Auctioneer_GetHighestSellablePriceForOne(itemKey, false, Auctioneer_GetAuctionKey());
						else
							if (Auctioneer_GetHighestSellablePriceForOne) then
								hsp = Auctioneer_GetHighestSellablePriceForOne(itemKey, false);
							elseif (getHighestSellablePriceForOne) then
								hsp = getHighestSellablePriceForOne(itemKey, false);
							end
						end
					elseif (major == 3 and (minor > 0 and minor <= 3) and (rev > 11 and rev < 675)) then
						-- 3.1.11 < ver < 3.3.675
						hsp = Auctioneer_GetHSP(itemKey, Auctioneer_GetAuctionKey());
					elseif (major >= 3 and minor >= 3 and (rev >= 675 or rev == 0)) then
						-- 3.3.675 <= ver
						hsp = Auctioneer.Statistic.GetHSP(itemKey, Auctioneer.Util.GetAuctionKey());
					end
				end
				if hsp == nil then hsp = mkt * 0.98; end
				if (useCache) then Enchantrix.Storage.Price_Cache[itemKey].hsp = hsp; end

				if (useCache and Enchantrix.Storage.Price_Cache[itemKey].median) then
					median = Enchantrix.Storage.Price_Cache[itemKey].median;
				end

				if ((not median or median < 1) and (major == 3 and (minor > 0 and minor <= 3) and (rev > 11 and rev < 675))) then
					-- 3.1.11 < ver < 3.3.675
					median = Auctioneer_GetUsableMedian(itemKey);
				elseif ((not median or median < 1) and (major >= 3 and minor >= 3 and (rev >= 675 or rev == 0))) then
					-- 3.3.675 <= ver
					median = Auctioneer.Statistic.GetUsableMedian(itemKey, Auctioneer.Util.GetAuctionKey());
				end
				if median == nil then median = mkt * 0.95; end
				if (useCache) then Enchantrix.Storage.Price_Cache[itemKey].median = median; end

				local hspValue = (hsp * pct * count / 100);
				local medianValue = (median * pct * count / 100);
				disenchantsTo[dSig].hspValue = hspValue;
				disenchantsTo[dSig].medValue = medValue;
				hspGuess = hspGuess + hspValue;
				medianGuess = medianGuess + medianValue;

				local mktValue = (mkt * pct * count / 100);
				disenchantsTo[dSig].mktValue = mktValue;
				marketGuess = marketGuess + mktValue;
			end
		end

		local confidence = math.log(math.min(total, 19)+1)/3;

		disenchantsTo.totals = {};
		disenchantsTo.totals.hspValue = hspGuess or 0;
		disenchantsTo.totals.medValue = medianGuess or 0;
		disenchantsTo.totals.mktValue = marketGuess or 0;
		disenchantsTo.totals.biCount = biTotal or 0;
		disenchantsTo.totals.bdCount = bdTotal or 0;
		disenchantsTo.totals.dCount = dTotal or 0;
		disenchantsTo.totals.iCount = iTotal or 0;
		disenchantsTo.totals.total = total or 0;
		disenchantsTo.totals.conf = confidence or 0;
	end

	return disenchantsTo;
end

Enchantrix.Storage = {
	Revision			= "$Revision$",
	AddonLoaded			= addonLoaded,

	GetItemDisenchants	= getItemDisenchants,
	SaveDisenchant		= saveDisenchant,
}
