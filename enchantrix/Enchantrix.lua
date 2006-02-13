--[[

	Enchantrix v<%version%> (<%codename%>)
	$Id$

	By Norganna
	http://enchantrix.org/

	This is an addon for World of Warcraft that add a list of what an item
	disenchants into to the items that you mouse-over in the game.

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

]]
ENCHANTRIX_VERSION = "<%version%>";
if (ENCHANTRIX_VERSION == "<".."%version%>") then
	ENCHANTRIX_VERSION = "3.3.DEV";
end

-- GUI Init Variables (Added by MentalPower)
Enchantrix_GUI_Registered = nil;
Enchantrix_Khaos_Registered = nil;

EnchantedLocal = {};
EnchantConfig = {};
EnchantedBaseItems = {}

-- These are market norm prices.
Enchantrix_StaticPrices = {
	[11082] =  7500, -- Greater Astral Essence
	[16203] = 35000, -- Greater Eternal Essence
	[10939] =  3500, -- Greater Magic Essence
	[11135] =  8500, -- Greater Mystic Essence
	[11175] = 30000, -- Greater Nether Essence
	[10998] =  3500, -- Lesser Astral Essence
	[16202] = 10000, -- Lesser Eternal Essence
	[10938] =  1000, -- Lesser Magic Essence
	[11134] =  4000, -- Lesser Mystic Essence
	[11174] = 12000, -- Lesser Nether Essence
	[14344] = 50000, -- Large Brilliant Shard
	[11084] = 10000, -- Large Glimmering Shard
	[11139] = 24500, -- Large Glowing Shard
	[11178] = 70000, -- Large Radiant Shard
	[14343] = 43500, -- Small Brilliant Shard
	[10978] =  3500, -- Small Glimmering Shard
	[11138] =  9000, -- Small Glowing Shard
	[11177] = 32500, -- Small Radiant Shard
	[11176] =  5000, -- Dream Dust
	[16204] = 12500, -- Illusion Dust
	[11083] =   800, -- Soul Dust
	[10940] =   600, -- Strange Dust
	[11137] =  1600, -- Vision Dust
	[20725] = 650000, -- Nexus Crystal
}

ENX_DUST = 1
ENX_ESSENCE_LESSER = 2
ENX_ESSENCE_GREATER = 3
ENX_SHARD_SMALL = 4
ENX_SHARD_LARGE = 5
ENX_CRYSTAL = 6
ENX_WEAPON = "Weapon"
ENX_ARMOR = "Armor"
Enchantrix_InvTypes = {
	["INVTYPE_2HWEAPON"] = ENX_WEAPON,
	["INVTYPE_WEAPON"] = ENX_WEAPON,
	["INVTYPE_WEAPONMAINHAND"] = ENX_WEAPON,
	["INVTYPE_WEAPONOFFHAND"] = ENX_WEAPON,
	["INVTYPE_RANGED"] = ENX_WEAPON,
	["INVTYPE_RANGEDRIGHT"] = ENX_WEAPON,
	["INVTYPE_BODY"] = ENX_ARMOR,
	["INVTYPE_CHEST"] = ENX_ARMOR,
	["INVTYPE_CLOAK"] = ENX_ARMOR,
	["INVTYPE_FEET"] = ENX_ARMOR,
	["INVTYPE_FINGER"] = ENX_ARMOR,
	["INVTYPE_HAND"] = ENX_ARMOR,
	["INVTYPE_HEAD"] = ENX_ARMOR,
	["INVTYPE_HOLDABLE"] = ENX_ARMOR,
	["INVTYPE_LEGS"] = ENX_ARMOR,
	["INVTYPE_NECK"] = ENX_ARMOR,
	["INVTYPE_ROBE"] = ENX_ARMOR,
	["INVTYPE_SHIELD"] = ENX_ARMOR,
	["INVTYPE_SHOULDER"] = ENX_ARMOR,
	["INVTYPE_TABARD"] = ENX_ARMOR,
	["INVTYPE_TRINKET"] = ENX_ARMOR,
	["INVTYPE_WAIST"] = ENX_ARMOR,
	["INVTYPE_WRIST"] = ENX_ARMOR,
}

Enchantrix_LevelRules = {
	[ENX_WEAPON] = {
		[5] = {
			[10940] = ENX_DUST, -- Strange Dust
			[10938] = ENX_ESSENCE_LESSER, -- Lesser Magic Essence
		},
		[10] = {
			[10940] = ENX_DUST, -- Strange Dust
			[10938] = ENX_ESSENCE_LESSER, -- Lesser Magic Essence
		},
		[15] = {
			[10940] = ENX_DUST, -- Strange Dust
			[10939] = ENX_ESSENCE_GREATER, -- Greater Magic Essence
			[10978] = ENX_SHARD_SMALL, -- Small Glimmering Shard
		},
		[20] = {
			[10940] = ENX_DUST, -- Strange Dust
			[10939] = ENX_ESSENCE_GREATER, -- Greater Magic Essence
			[10978] = ENX_SHARD_SMALL, -- Small Glimmering Shard
		},
		[25] = {
			[11083] = ENX_DUST, -- Soul Dust
			[10939] = ENX_ESSENCE_GREATER, -- Greater Magic Essence
			[11084] = ENX_SHARD_LARGE, -- Large Glimmering Shard
		},
		[30] = {
			[11083] = ENX_DUST, -- Soul Dust
			[11134] = ENX_ESSENCE_LESSER, -- Lesser Mystic Essence
			[11138] = ENX_SHARD_SMALL, -- Small Glowing Shard
		},
		[35] = {
			[11137] = ENX_DUST, -- Vision Dust
			[11135] = ENX_ESSENCE_GREATER, -- Greater Mystic Essence
			[11139] = ENX_SHARD_LARGE, -- Large Glowing Shard
		},
		[40] = {
			[11137] = ENX_DUST, -- Vision Dust
			[11174] = ENX_ESSENCE_LESSER, -- Lesser Nether Essence
			[11177] = ENX_SHARD_SMALL, -- Small Radiant Shard
		},
		[45] = {
			[11176] = ENX_DUST, -- Dream Dust
			[11175] = ENX_ESSENCE_GREATER, -- Greater Nether Essence
			[11178] = ENX_SHARD_LARGE, -- Large Radiant Shard
		},
		[50] = {
			[11176] = ENX_DUST, -- Dream Dust
			[16202] = ENX_ESSENCE_LESSER, -- Lesser Eternal Essence
			[14343] = ENX_SHARD_SMALL, -- Small Brilliant Shard
		},
		[55] = {
			[16204] = ENX_DUST, -- Illusion Dust
			[16203] = ENX_ESSENCE_GREATER, -- Greater Eternal Essence
			[14344] = ENX_SHARD_LARGE, -- Large Brilliant Shard
			[20725] = ENX_CRYSTAL, -- Nexus Crystal
		},
		[60] = {
			[16204] = ENX_DUST, -- Illusion Dust
			[16203] = ENX_ESSENCE_GREATER, -- Greater Eternal Essence
			[14344] = ENX_SHARD_LARGE, -- Large Brilliant Shard
			[20725] = ENX_CRYSTAL, -- Nexus Crystal
		},
	},
	[ENX_ARMOR] = {
		[5] = {
			[10940] = ENX_DUST, -- Strange Dust
			[10938] = ENX_ESSENCE_LESSER, -- Lesser Magic Essence
		},
		[10] = {
			[10940] = ENX_DUST, -- Strange Dust
			[10938] = ENX_ESSENCE_LESSER, -- Lesser Magic Essence
		},
		[15] = {
			[10940] = ENX_DUST, -- Strange Dust
			[10939] = ENX_ESSENCE_GREATER, -- Greater Magic Essence
			[10978] = ENX_SHARD_SMALL, -- Small Glimmering Shard
		},
		[20] = {
			[10940] = ENX_DUST, -- Strange Dust
			[10998] = ENX_ESSENCE_LESSER, -- Lesser Astral Essence
			[10978] = ENX_SHARD_SMALL, -- Small Glimmering Shard
		},
		[25] = {
			[11083] = ENX_DUST, -- Soul Dust
			[11082] = ENX_ESSENCE_GREATER, -- Greater Astral Essence
			[11084] = ENX_SHARD_LARGE, -- Large Glimmering Shard
		},
		[30] = {
			[11083] = ENX_DUST, -- Soul Dust
			[11134] = ENX_ESSENCE_LESSER, -- Lesser Mystic Essence
			[11138] = ENX_SHARD_SMALL, -- Small Glowing Shard
		},
		[35] = {
			[11137] = ENX_DUST, -- Vision Dust
			[11135] = ENX_ESSENCE_GREATER, -- Greater Mystic Essence
			[11139] = ENX_SHARD_LARGE, -- Large Glowing Shard
		},
		[40] = {
			[11137] = ENX_DUST, -- Vision Dust
			[11174] = ENX_ESSENCE_LESSER, -- Lesser Nether Essence
			[11177] = ENX_SHARD_SMALL, -- Small Radiant Shard
		},
		[45] = {
			[11176] = ENX_DUST, -- Dream Dust
			[11175] = ENX_ESSENCE_GREATER, -- Greater Nether Essence
			[11178] = ENX_SHARD_LARGE, -- Large Radiant Shard
		},
		[50] = {
			[11176] = ENX_DUST, -- Dream Dust
			[16202] = ENX_ESSENCE_LESSER, -- Lesser Eternal Essence
			[14343] = ENX_SHARD_SMALL, -- Small Brilliant Shard
		},
		[55] = {
			[16204] = ENX_DUST, -- Illusion Dust
			[16203] = ENX_ESSENCE_GREATER, -- Greater Eternal Essence
			[14344] = ENX_SHARD_LARGE, -- Large Brilliant Shard
			[20725] = ENX_CRYSTAL, -- Nexus Crystal
		},
		[60] = {
			[16204] = ENX_DUST, -- Illusion Dust
			[16203] = ENX_ESSENCE_GREATER, -- Greater Eternal Essence
			[14344] = ENX_SHARD_LARGE, -- Large Brilliant Shard
			[20725] = ENX_CRYSTAL, -- Nexus Crystal
		},
	},
}

-- Default filter configuration
Enchantrix_FilterDefaults = {
		['all'] = 'on',
		['embed'] = 'off',
		['counts'] = 'off',
		['header'] = 'on',
		['rates'] = 'on',
		['valuate'] = 'on',
		['valuate-hsp'] = 'on',
		['valuate-median'] = 'on',
		['valuate-baseline'] = 'on',
		['locale'] = 'default',
		['printframe'] = 1,
	}

local ItemEssences = {};


local MAX_BUYOUT_PRICE = 800000;

local MIN_PROFIT_MARGIN = 1000;
local MIN_PERCENT_LESS_THAN_HSP = 20; -- 20% default
local MIN_PROFIT_PRICE_PERCENT = 10; -- 10% default

local EnchantedItemTypes = {}
local N_DISENCHANTS = 1
local N_REAGENTS = 2

local function gcd(a, b)
	-- Greatest Common Divisor, Euclidean algorithm
	local m, n = tonumber(a), tonumber(b)
	while (n ~= 0) do
		m, n = n, math.mod(m, n)
	end
	return m
end

local function roundup(m, n)
	-- Round up m to nearest multiple of n
	return math.floor((m + n - 1) / n) * n
end

local function Unserialize(str)
	-- Break up a disenchant string to a table for easy manipulation
	local tbl = {}
	if (str) then
		for _, de in ipairs(Enchantrix_Split(str, ";")) do
			local splt = Enchantrix_Split(de, ":")
			local id, d, r = tonumber(splt[1]), tonumber(splt[2]), tonumber(splt[3])
			if (id and d > 0 and r > 0) then
				tbl[id] = {[N_DISENCHANTS] = d, [N_REAGENTS] = r}
			end
		end
	end
	return tbl
end

local function Serialize(tbl)
	-- Serialize a table into a string
	if (tbl) then
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
	return nil
end

local function MergeDisenchant(str1, str2)
	-- Merge two disenchant strings into a single string
	local tbl1, tbl2 = Unserialize(str1), Unserialize(str2)
	for id in tbl2 do
		if (not tbl1[id]) then
			tbl1[id] = tbl2[id]
		else
			tbl1[id][N_DISENCHANTS] = tbl1[id][N_DISENCHANTS] + tbl2[id][N_DISENCHANTS]
			tbl1[id][N_REAGENTS] = tbl1[id][N_REAGENTS] + tbl2[id][N_REAGENTS]
		end
	end
	return Serialize(tbl1)
end

local function NormalizeDisenchant(str)
	-- Divide all counts in disenchant string by gcd
	local div = 0
	local tbl = Unserialize(str)
	for id in tbl do
		div = gcd(div, tbl[id][N_DISENCHANTS])
		div = gcd(div, tbl[id][N_REAGENTS])
	end
	for id in tbl do
		tbl[id][N_DISENCHANTS] = tbl[id][N_DISENCHANTS] / div
		tbl[id][N_REAGENTS] = tbl[id][N_REAGENTS] / div
	end
	return Serialize(tbl)
end

local function CleanupDisenchant(str, id)
	-- Remove reagents that don't appear in level rules table
	if (str and id) then
		local _, _, quality, level, _, _, _, equip = GetItemInfo(id)
		if (quality and Enchantrix_InvTypes[equip] and level > 0) then
			local tbl = Unserialize(str)
			local clean = {}
			local type = Enchantrix_InvTypes[equip]
			level = roundup(level, 5)
			for id in tbl do
				if (Enchantrix_LevelRules[type][level][id]) then
					if (quality == 2) then
						-- Uncommon item, remove nexus crystal
						if (Enchantrix_LevelRules[type][level][id] < ENX_CRYSTAL) then
							clean[id] = tbl[id]
						end
					else
						-- Rare or epic item, remove dusts and essences
						if (Enchantrix_LevelRules[type][level][id] > ENX_ESSENCE_GREATER) then
							clean[id] = tbl[id]
						end
					end
				end
			end
			return Serialize(clean)
		end
	end
	return str
end

local function DisenchantTotal(str)
	-- Return total number of disenchants
	local tot = 0
	local tbl = Unserialize(str)
	for id in tbl do
		tot = tot + tbl[id][N_DISENCHANTS]
	end
	return tot
end

local function ItemID(key)
	-- Return item id and item suffix as integers
	if (type(key) == "string") then
		local splt = Enchantrix_Split(key, ":")
		return tonumber(splt[1]), tonumber(splt[3])
	end
	return nil
end

local function IsDisenchantable(id)
	-- Return false if item id can't be disenchanted
	if (id) then
		local _, _, quality, _, _, _, count, equip = GetItemInfo(id)
		if (not quality) then
			-- GetItemInfo() failed, item might be disenchantable
			return true
		end
		if (not Enchantrix_InvTypes[equip]) then
			-- Neither weapon nor armor
			return false
		end
		if (quality and quality < 2) then
			-- Low quality
			return false
		end
		if (count and count > 1) then
			-- Stackable item
			return false
		end
		return true
	end
	return false
end

local function ItemType(id)
	-- Return item level (rounded up to nearest 5 levels) and type as string, e.g. "20 Armor"
	-- High quality items have predictable disenchants so we're only interested in green
	-- items (quality == 2)
	if (id) then
		local _, _, quality, level, _, _, _, equip = GetItemInfo(id)
		if (quality and quality == 2 and level > 0 and Enchantrix_InvTypes[equip]) then
			return string.format("%d %s", roundup(level, 5), Enchantrix_InvTypes[equip])
		end
	end
	return nil
end

local function DisenchantListHash()
	-- Generate a hash for DisenchantList
	local hash = 1
	for key in DisenchantList do
		local item, suffix = ItemID(key)
		hash = math.mod(3 * hash + 2 * item + suffix, 16777216)
	end
	return hash
end

local function MergeDisenchantLists()
	-- Merge DisenchantList by base item, i.e. all "Foobar of <x>" are merged into "Foobar"
	-- This can be rather time consuming so we store this in a saved variable and use a hash
	-- signature to determine if we need to update the table
	local hash = DisenchantListHash()
	if (not EnchantedBaseItems.hash) then
		EnchantedBaseItems.hash = -hash
	end
	if (EnchantedBaseItems.hash ~= hash) then
		-- Hash has changed, update EnchantedBaseItems
		EnchantedBaseItems = {}
		for key in DisenchantList do
			local item, suffix = ItemID(key)
			if (IsDisenchantable(item)) then
				EnchantedBaseItems[item] = MergeDisenchant(EnchantedBaseItems[item],
					NormalizeDisenchant(DisenchantList[key]))
			end
		end
		EnchantedBaseItems.hash = hash
	end

	-- Merge items from EnchantedLocal
	for key in EnchantedLocal do
		local item, suffix = ItemID(key)
		if (IsDisenchantable(item)) then
			EnchantedBaseItems[item] = MergeDisenchant(EnchantedBaseItems[item], EnchantedLocal[key])
		end
	end

	-- Merge by item type
	for id in EnchantedBaseItems do
		local type = ItemType(id)
		if (type) then
			EnchantedItemTypes[type] = MergeDisenchant(EnchantedItemTypes[type], EnchantedBaseItems[id])
		end
	end
end

function Enchantrix_CheckTooltipInfo(frame)
	-- If we've already added our information, no need to do it again
	if ( not frame or frame.eDone ) then
		return nil;
	end

	lEnchantrixTooltip = frame;

	if( frame:IsVisible() ) then
		local field = getglobal(frame:GetName().."TextLeft1");
		if( field and field:IsVisible() ) then
			local name = field:GetText();
			if( name ) then
				Enchantrix_AddTooltipInfo(frame, name);
				return nil;
			end
		end
	end

	return 1;
end

function Enchantrix_HookTooltip(funcVars, retVal, frame, name, link, quality, count)
	-- nothing to do, if enchantrix is disabled
	if (not Enchantrix_GetFilter('all')) then
		return;
	end;

	local embed = Enchantrix_GetFilter('embed');

	local sig, sigNR = Enchantrix_SigFromLink(link);

	local _,_,data = Enchantrix_FindSigInBags(sig);
	if (not data) then _,_,data = Enchantrix_FindSigInBags(sigNR); end


	-- Check for correct item quality
	if (data) then
		if (data.quality > -1) and (data.quality < 2) then
			-- The item data says the quality is not right, zero it out.
			EnchantedLocal[sig] = { z = true; };
			EnchantedLocal[sigNR] = { z = true; };
		end
	else
		-- We can't get definative proof that this item is not disenchant quality,
		-- but the tooltip says it's not good enough quality though so don't display it.
		if (quality) and (quality > -1) and (quality < 2) then return; end
	end

	local disenchantsTo = Enchantrix_GetItemDisenchants(sig, sigNR, name, true);

	local itemID = Enchantrix_BreakLink(link);
	if (Enchantrix_StaticPrices[itemID]) then return end

	-- Process the results
	local totals = disenchantsTo.totals;
	disenchantsTo.totals = nil;
	if (totals and totals.total > 0) then

		-- If it looks quirky, and we haven't disenchanted it, then ignore it...
		if (totals.bCount < 10) and (totals.iCount + totals.biCount < 1) then return; end

		local total = totals.total;
		local note = "";
		if (not totals.exact) then note = "*"; end

		EnhTooltip.AddLine(_ENCH('FrmtDisinto')..note, nil, embed);
		EnhTooltip.LineColor(0.8,0.8,0.2);
		for dSig, counts in disenchantsTo do
			if (counts.rate > 1) then
				EnhTooltip.AddLine(string.format("  %s: %0.1f%% x%0.1f", counts.name, counts.pct, counts.rate), nil, embed);
			else
				EnhTooltip.AddLine(string.format("  %s: %0.1f%%", counts.name, counts.pct), nil, embed);
			end
			EnhTooltip.LineColor(0.6,0.6,0.1);

			if (Enchantrix_GetFilter('counts')) then
				EnhTooltip.AddLine(string.format(_ENCH('FrmtCounts'), counts.bCount, counts.oCount, counts.dCount), nil, embed);
				EnhTooltip.LineColor(0.5,0.5,0.0);
			end
		end

		if (Enchantrix_GetFilter('valuate')) then
			local confidence = totals.conf;

			if (Enchantrix_GetFilter('valuate-hsp') and totals.hspValue > 0) then
				EnhTooltip.AddLine(_ENCH('FrmtValueAuctHsp'), totals.hspValue * confidence, embed);
				EnhTooltip.LineColor(0.1,0.6,0.6);
			end
			if (Enchantrix_GetFilter('valuate-median') and totals.medValue > 0) then
				EnhTooltip.AddLine(_ENCH('FrmtValueAuctMed'), totals.medValue * confidence, embed);
				EnhTooltip.LineColor(0.1,0.6,0.6);
			end
			if (Enchantrix_GetFilter('valuate-baseline') and totals.mktValue > 0) then
				EnhTooltip.AddLine(_ENCH('FrmtValueMarket'), totals.mktValue * confidence, embed);
				EnhTooltip.LineColor(0.1,0.6,0.6);
			end
		end
	end
end

function Enchantrix_NameFromLink(link)
	local name;
	if( not link ) then
		return nil;
	end
	for name in string.gfind(link, "|c%x+|Hitem:%d+:%d+:%d+:%d+|h%[(.-)%]|h|r") do
		return name;
	end
	return nil;
end

function Enchantrix_SigFromLink(link)
	local name;
	if( not link ) then
		return nil;
	end
	for id,enchant,rand in string.gfind(link, "|c%x+|Hitem:(%d+):(%d+):(%d+):%d+|h%[.-%]|h|r") do
		local sig = string.format("%s:%s:%s", id, 0, rand);
		local sigNR = string.format("%s:%s:%s", id, 0, 0);
		return sig, sigNR;
	end
	return nil;
end

function Enchantrix_TakeInventory()
	local bagid, slotid, size;
	local inventory = {};

	for bagid = 0, 10, 1 do -- Changed from 4 to 10 by FtKxDE to include bank bags as well
		inventory[bagid] = {};

		size = GetContainerNumSlots(bagid);
		if( size ) then
			for slotid = size, 1, -1 do
				inventory[bagid][slotid] = {};

				local link = GetContainerItemLink(bagid, slotid);
				if( link ) then
					local name = Enchantrix_NameFromLink(link);
					local sig = Enchantrix_SigFromLink(link);
					local texture, itemCount, locked, quality, readable = GetContainerItemInfo(bagid, slotid);
					if ((not itemCount) or (itemCount < 1)) then
						itemCount = 1;
					end
					if (name) then
						inventory[bagid][slotid].name = name;
						inventory[bagid][slotid].tx = texture;
						inventory[bagid][slotid].sig = sig;
						inventory[bagid][slotid].link = link;
						inventory[bagid][slotid].count = itemCount;
					end
				end
			end
		end
	end

	-- Added by FtKxDE to include bank slots
	inventory["bank"] = {};

	size = GetContainerNumSlots(BANK_CONTAINER);
	if( size ) then
		for slotid = size, 1, -1 do
			inventory["bank"][slotid] = {};

			local link = GetContainerItemLink(BANK_CONTAINER, slotid);
			if( link ) then
				local name = Enchantrix_NameFromLink(link);
				local sig = Enchantrix_SigFromLink(link);
				local texture, itemCount, locked, quality, readable = GetContainerItemInfo(BANK_CONTAINER, slotid);
				if ((not itemCount) or (itemCount < 1)) then
					itemCount = 1;
				end
				if (name) then
					inventory["bank"][slotid].name = name;
					inventory["bank"][slotid].tx = texture;
					inventory["bank"][slotid].sig = sig;
					inventory["bank"][slotid].link = link;
					inventory["bank"][slotid].count = itemCount;
				end
			end
		end
	end

	-- Added by FtKxDE to include player's inventory
	inventory["inv"] = {};

	for slotid = 0, 19, 1 do
		inventory["inv"][slotid] = {};

		local link = GetInventoryItemLink("player", slotid);
		if( link ) then
			local name = Enchantrix_NameFromLink(link);
			local sig = Enchantrix_SigFromLink(link);
			local texture = GetInventoryItemTexture("player", slotid);
			local itemCount = GetInventoryItemCount("player", slotid);
			if ((not itemCount) or (itemCount < 1)) then
				itemCount = 1;
			end
			if (name) then
				inventory["inv"][slotid].name = name;
				inventory["inv"][slotid].tx = texture;
				inventory["inv"][slotid].sig = sig;
				inventory["inv"][slotid].link = link;
				inventory["inv"][slotid].count = itemCount;
			end
		end
	end
	return inventory;
end

function Enchantrix_FullDiff(invA, invB)
	local bagid, slotid, size;
	local diffData = {};
	local aStuff = {};
	local bStuff = {};

	for bag, bagStuff in invA do
		for slot, slotStuff in bagStuff do
			if (slotStuff.sig) then
				if (not aStuff[slotStuff.sig]) then
					aStuff[slotStuff.sig] = { c=slotStuff.count, n=slotStuff.name, t=slotStuff.tx, l=slotStuff.link };
				else
					aStuff[slotStuff.sig].c = aStuff[slotStuff.sig].c + slotStuff.count;
				end
			end
		end
	end
	for bag, bagStuff in invB do
		for slot, slotStuff in bagStuff do
			if (slotStuff.sig) then
				if (not bStuff[slotStuff.sig]) then
					bStuff[slotStuff.sig] = { c=slotStuff.count, n=slotStuff.name, t=slotStuff.tx, l=slotStuff.link };
				else
					bStuff[slotStuff.sig].c = bStuff[slotStuff.sig].c + slotStuff.count;
				end
			end
		end
	end

	for sig, slotStuff in aStuff do
		local count = slotStuff.c;
		local bCount;
		if (bStuff[sig]) then bCount = bStuff[sig].c; end
		if (bCount == nil) then bCount = 0; end
		if (bCount < count) then
			local diffCount = bCount - count;
			diffData[sig] = { s=sig, d=diffCount, n=slotStuff.n, t=slotStuff.t, l=slotStuff.l };
		end
	end
	for sig, slotStuff in bStuff do
		local count = slotStuff.c;
		local aCount;
		if (aStuff[sig]) then aCount = aStuff[sig].c; end
		if (aCount == nil) then aCount = 0; end
		if (aCount < count) then
			local diffCount = count - aCount;
			diffData[sig] = { s=sig, d=diffCount, n=slotStuff.n, t=slotStuff.t, l=slotStuff.l };
		end
	end
	return diffData;
end

ItemEssences = {};
EssenceItemIDs = {};
local essences = {
	11082, 16203, 10939, 11135, 11175, 10998, 16202, 10938,
	11134, 11174, 14344, 11084, 11139, 11178, 14343, 10978,
	11138, 11177, 11176, 16204, 11083, 10940, 11137, 20725
}
local hackEssencePos = 0;
local elapsedTime = 0;

function Enchantrix_OnUpdate(elapsed)
	elapsedTime = elapsedTime + elapsed;
	if (elapsedTime > 0.01) then elapsedTime = elapsedTime - 0.01;
	else return; end

    if (hackEssencePos < 0) then return; end

	-- Check to see if we already have the localized data saved away.
	if (EnchantConfig and EnchantConfig.essences and EnchantConfig.essences[GetLocale()]) then
		ItemEssences = EnchantConfig.essences[GetLocale()];

		-- Go through the essences
		for pos, essence in essences do
			-- Check the local cache for a fresher entry
			local iName = GetItemInfo(essence);
			-- If there isn't one, use the SV cached copy
			if (not iName) then iName = EnchantConfig.essences[GetLocale()][essence] end
			-- If there was one missing, clear the SV cache and redo the lot
			if (not iName) then
				EnchantConfig.essences[GetLocale()] = nil;
				return
			end
			-- Store the item value
			ItemEssences[essence] = iName;
		end

		-- Cause the next loop to succeed
		hackEssencePos = 1000;
	end

	-- Get the previously mined data and save it away.
	if (hackEssencePos > 0) then
		local essence = essences[hackEssencePos];

		-- If we are done, store the data and turn this loop off.
		if (not essence) then
			-- Save this data into the SV Cache
			if (not EnchantConfig) then EnchantConfig = {} end
			if (not EnchantConfig.essences) then EnchantConfig.essences = {} end
			EnchantConfig.essences[GetLocale()] = ItemEssences

			-- Stop the update events from firing
			EnchantrixScheduler:Hide();
			hackEssencePos = -1;

			-- Build a lookup array for the essence item names
			for id, name in ItemEssences do
				EssenceItemIDs[name] = id
			end
			return;
		end

		-- Get the item info for the mined data from the prior loop.
		local iName = GetItemInfo(essence);
		if (not iName) then
			-- Still hasn't downloaded
			return
		end
		ItemEssences[essence] = iName;
	end

	-- It's time to mine the data... It's possible the below code could cause disconnects
	-- directly after server restarts/on really new servers... That's why we cache it.
	hackEssencePos = hackEssencePos + 1;
	essence = essences[hackEssencePos];
	if (essence) then
		GameTooltip:SetHyperlink("item:"..essence..":0:0:0");
		GameTooltip:Hide();
	end
end

function Enchantrix_OnEvent(funcVars, event, argument)

	if ((event == "SPELLCAST_START") and (argument == _ENCH('ArgSpellname'))) then
		Enchantrix_Disenchanting = true;
		Enchantrix_WaitingPush = false;
		Enchantrix_StartInv = Enchantrix_TakeInventory();
		Enchantrix_Disenchants = {};

		return;
	end
	if ((event == "SPELLCAST_FAILED") or (event == "SPELLCAST_INTERRUPTED")) then
		Enchantrix_Disenchanting = false;
		Enchantrix_WaitingPush = false;
		return;
	end
	if ((event == "SPELLCAST_STOP") and (Enchantrix_Disenchanting)) then
		Enchantrix_Disenchanting = false;
		Enchantrix_WaitingPush = true;
		return;
	end
	if ((event == "ITEM_PUSH") and (Enchantrix_WaitingPush)) then
		local textureType = strsub(arg2, 1, 28);
		local receivedItem = strsub(arg2, 29);
		if (not receivedItem) then return; end
		if (textureType == "Interface\\Icons\\INV_Enchant_") then
			Enchantrix_Disenchants[arg2] = receivedItem;
			Enchantrix_Disenchants.exists = true;
		end
		return;
	end
	if ((event == "BAG_UPDATE") and (Enchantrix_Disenchants and Enchantrix_Disenchants.exists)) then

		-- /script inv = Enchantrix_TakeInventory()
		-- /script p(Enchantrix_FullDiff(inv, Enchantrix_TakeInventory()))
		-- /script p(Enchantrix_FullDiff(Enchantrix_StartInv, Enchantrix_TakeInventory()))
		local nowInv = Enchantrix_TakeInventory();
		local invDiff = Enchantrix_FullDiff(Enchantrix_StartInv, nowInv);

		local foundItem = "";
		for sig, data in invDiff do
			if (data.d == -1) then
				if (foundItem ~= "") then
					-- Unable to determine which item was disenchanted, ignore DE to avoid incorrect data
					Enchantrix_Disenchants = {};
					Enchantrix_Disenchanting = false;
					Enchantrix_WaitingPush = false;
					return;
				end
				foundItem = data;
			end
		end
		if (foundItem == "") then
			-- Unable to determine which item was disenchanted, ignore DE to avoid incorrect data
			Enchantrix_Disenchants = {};
			Enchantrix_Disenchanting = false;
			Enchantrix_WaitingPush = false;
			return;
		end

		local gainedItem = {};
		for sig, data in invDiff do
			if (data.d > 0) and (Enchantrix_Disenchants[data.t]) then
				gainedItem[sig] = data;
			end
		end
		if (next(gainedItem) == nil) then return; end

		if (EnchantedLocal[foundItem.n]) then
			EnchantedLocal[foundItem.s] = { o = ""..EnchantedLocal[foundItem.n] };
		end

		local itemData = Enchantrix_GetLocal(foundItem.s);

		Enchantrix_ChatPrint(string.format(_ENCH('FrmtFound'), foundItem.l), 0.8, 0.8, 0.2);
		for sig, data in gainedItem do
			local i,j, strItemID = string.find(sig, "^(%d+):");
			local itemID = 0;
			if (strItemID) then itemID = tonumber(strItemID); end
			if (itemID > 0) and (ItemEssences[itemID]) then
				-- We are interested cause this is an essence that was gained since last snaphot
				local iCount = 0; local dCount = 0;
				local curData = itemData[itemID];
				if (curData == nil) then curData = {}; end
				if (curData.i) then iCount = tonumber(curData.i); end
				if (curData.d) then dCount = tonumber(curData.d); end
				curData.i = ""..(iCount + 1);
				curData.d = ""..(dCount + data.d);
				itemData[itemID] = curData;
				Enchantrix_ChatPrint("  " .. data.n .. " x" .. data.d, 0.6, 0.6, 0.1);
			end
		end

		Enchantrix_SaveLocal(foundItem.s, itemData);

		Enchantrix_Disenchants = {};
		Enchantrix_Disenchanting = false;
		Enchantrix_WaitingPush = false;

		return
	end
end

function Enchantrix_ChatPrint(text, cRed, cGreen, cBlue, cAlpha, holdTime)
	local frameIndex = Enchantrix_GetFrameIndex();

	if (cRed and cGreen and cBlue) then
		if getglobal("ChatFrame"..frameIndex) then
			getglobal("ChatFrame"..frameIndex):AddMessage(text, cRed, cGreen, cBlue, cAlpha, holdTime);

		elseif (DEFAULT_CHAT_FRAME) then
			DEFAULT_CHAT_FRAME:AddMessage(text, cRed, cGreen, cBlue, cAlpha, holdTime);
		end

	else
		if getglobal("ChatFrame"..frameIndex) then
			getglobal("ChatFrame"..frameIndex):AddMessage(text, 1.0, 0.5, 0.25);
		elseif (DEFAULT_CHAT_FRAME) then
			DEFAULT_CHAT_FRAME:AddMessage(text, 1.0, 0.5, 0.25);
		end
	end
end

function Enchantrix_OnLoad()
	-- Hook in new tooltip code
	Stubby.RegisterFunctionHook("EnhTooltip.AddTooltip", 400, Enchantrix_HookTooltip)

	Stubby.RegisterAddOnHook("Auctioneer", "Enchantrix", Enchantrix_AuctioneerLoaded);

	Stubby.RegisterEventHook("SPELLCAST_FAILED", "Enchantrix", Enchantrix_OnEvent);
	Stubby.RegisterEventHook("SPELLCAST_INTERRUPTED", "Enchantrix", Enchantrix_OnEvent);
	Stubby.RegisterEventHook("SPELLCAST_START", "Enchantrix", Enchantrix_OnEvent);
	Stubby.RegisterEventHook("SPELLCAST_STOP", "Enchantrix", Enchantrix_OnEvent);
	Stubby.RegisterEventHook("ITEM_PUSH", "Enchantrix", Enchantrix_OnEvent);
	Stubby.RegisterEventHook("BAG_UPDATE", "Enchantrix", Enchantrix_OnEvent);

	-- Register our temporary command hook with stubby
	Stubby.RegisterBootCode("Enchantrix", "CommandHandler", [[
		local function cmdHandler(msg)
			local i,j, cmd, param = string.find(string.lower(msg), "^([^ ]+) (.+)$")
			if (not cmd) then cmd = string.lower(msg) end
			if (not cmd) then cmd = "" end
			if (not param) then param = "" end
			if (cmd == "load") then
				if (param == "") then
					Stubby.Print("Manually loading Enchantrix...")
					LoadAddOn("Enchantrix")
				elseif (param == "always") then
					Stubby.Print("Setting Enchantrix to always load for this character")
					Stubby.SetConfig("Enchantrix", "LoadType", param)
					LoadAddOn("Enchantrix")
				elseif (param == "never") then
					Stubby.Print("Setting Enchantrix to never load automatically for this character (you may still load manually)")
					Stubby.SetConfig("Enchantrix", "LoadType", param)
				else
					Stubby.Print("Your command was not understood")
				end
			else
				Stubby.Print("Enchantrix is currently not loaded.")
				Stubby.Print("  You may load it now by typing |cffffffff/enchantrix load|r")
				Stubby.Print("  You may also set your loading preferences for this character by using the following commands:")
				Stubby.Print("  |cffffffff/enchantrix load always|r - Enchantrix will always load for this character")
				Stubby.Print("  |cffffffff/enchantrix load never|r - Enchantrix will never load automatically for this character (you may still load it manually)")
			end
		end
		SLASH_ENCHANTRIX1 = "/enchantrix"
		SLASH_ENCHANTRIX2 = "/enchant"
		SLASH_ENCHANTRIX3 = "/enx"
		SlashCmdList["ENCHANTRIX"] = cmdHandler
	]]);
	Stubby.RegisterBootCode("Enchantrix", "Triggers", [[
		local loadType = Stubby.GetConfig("Enchantrix", "LoadType")
		if (loadType == "always") then
			LoadAddOn("Enchantrix")
		else
			Stubby.Print("]].._ENCH('MesgNotloaded')..[[")
		end
	]]);

	Enchantrix_DisenchantCount = 0;
	Enchantrix_DisenchantResult = {};
	Enchantrix_Disenchanting = false;
	Enchantrix_WaitingPush = false;

	SLASH_ENCHANTRIX1 = "/enchantrix";
	SLASH_ENCHANTRIX2 = "/enchant";
	SLASH_ENCHANTRIX3 = "/enx";
	SlashCmdList["ENCHANTRIX"] = function(msg)
		Enchantrix_Command(msg);
	end
end

-- This function differs from Enchantrix_OnLoad in that it is executed
-- after variables have been loaded.
function Enchantrix_AddonLoaded()
	this:UnregisterEvent("ADDON_LOADED")

	Enchantrix_ConvertFilters();		-- Convert old localized settings
	Enchantrix_SetFilterDefaults();		-- Apply defaults

	--GUI Registration code added by MentalPower
	Enchantrix_Register();

	if (IsAddOnLoaded("Auctioneer")) then
		Enchantrix_AuctioneerLoaded()
	end

	if not Babylonian.IsAddOnRegistered("Enchantrix") then
		Babylonian.RegisterAddOn("Enchantrix", Enchantrix_SetLocale);
	end

	Enchantrix_ChatPrint(string.format(_ENCH('FrmtWelcome'), ENCHANTRIX_VERSION), 0.8, 0.8, 0.2);
	Enchantrix_ChatPrint(_ENCH('FrmtCredit'), 0.6, 0.6, 0.1);

	MergeDisenchantLists()
end


function Enchantrix_SetFilter(key, value)
	if (not EnchantConfig.filters) then EnchantConfig.filters = {}; end
	if (type(value) == "boolean") then
		if (value) then
			EnchantConfig.filters[key] = 'on';
		else
			EnchantConfig.filters[key] = 'off';
		end
	else
		EnchantConfig.filters[key] = value;
	end
end

function Enchantrix_GetFilterVal(key)
	if (not EnchantConfig.filters) then
		EnchantConfig.filters = {};
		Enchantrix_SetFilterDefaults();
	end
	return EnchantConfig.filters[key]
end

function Enchantrix_GetFilter(filter)
	value = Enchantrix_GetFilterVal(filter);
	if (value == 'on') then
		return true;
	elseif (value == 'off') then
		return false;
	else
		return value;
	end
end

function Enchantrix_GetSigs(str)
	local itemList = {};
	local listSize = 0;
	for sig, item in string.gfind(str, "|Hitem:(%d+:%d+:%d+):%d+|h[[]([^]]+)[]]|h") do
		listSize = listSize+1;
		itemList[listSize] = { s=sig, n=item };
	end
	return itemList;
end


function Enchantrix_PercentLessFilter(percentLess, signature)
    local filterAuction = true;
    local id,rprop,enchant, name, count,min,buyout,uniq = Auctioneer.Core.GetItemSignature(signature);
	local disenchantsTo = Enchantrix_GetAuctionItemDisenchants(signature, true);
	if not disenchantsTo.totals then return filterAuction; end

	local hspValue = disenchantsTo.totals.hspValue or 0;
	local medValue = disenchantsTo.totals.medValue or 0;
	local mktValue = disenchantsTo.totals.mktValue or 0;
	local confidence = disenchantsTo.totals.conf or 0;

	local myValue = confidence * (hspValue + medValue + mktValue) / 3;
	local margin = Auctioneer.Statistic.PercentLessThan(myValue, buyout/count);
	local profit = (myValue * count) - buyout;

	local results = {
		buyout = buyout,
		count = count,
		value = myValue,
		margin = margin,
		profit = profit,
		conf = confidence
	};
	if (buyout > 0) and (margin >= tonumber(percentLess)) and (profit >= MIN_PROFIT_MARGIN) then
		filterAuction = false;
		Enchantrix_ProfitMargins[signature] = results;
	end

	return filterAuction;
end

function Enchantrix_BidBrokerFilter(minProfit, signature)
    local filterAuction = true;
    local id,rprop,enchant, name, count,min,buyout,uniq = Auctioneer.Core.GetItemSignature(signature);
    local currentBid = Auctioneer.Statistic.GetCurrentBid(signature);
	local disenchantsTo = Enchantrix_GetAuctionItemDisenchants(signature, true);
	if not disenchantsTo.totals then return filterAuction; end

	local hspValue = disenchantsTo.totals.hspValue or 0;
	local medValue = disenchantsTo.totals.medValue or 0;
	local mktValue = disenchantsTo.totals.mktValue or 0;
	local confidence = disenchantsTo.totals.conf or 0;

	local myValue = confidence * (hspValue + medValue + mktValue) / 3;
	local margin = Auctioneer.Statistic.PercentLessThan(myValue, currentBid/count);
	local profit = (myValue * count) - currentBid;
    local profitPricePercent = math.floor((profit / currentBid) * 100);

	local results = {
		buyout = buyout,
		count = count,
		value = myValue,
		margin = margin,
		profit = profit,
		conf = confidence
	};
	if (currentBid <= MAX_BUYOUT_PRICE) and (profit >= tonumber(minProfit)) and (profit >= MIN_PROFIT_MARGIN) and (profitPricePercent >= MIN_PROFIT_PRICE_PERCENT) then
		filterAuction = false;
		Enchantrix_ProfitMargins[signature] = results;
	end
	return filterAuction;
end

function Enchantrix_ProfitComparisonSort(a, b)
	if (not a) or (not b) then return false; end
	local aSig = a.signature;
	local bSig = b.signature;
	if (not aSig) or (not bSig) then return false; end
	local aEpm = Enchantrix_ProfitMargins[aSig];
	local bEpm = Enchantrix_ProfitMargins[bSig];
	if (not aEpm) and (not bEpm) then return false; end
	local aProfit = aEpm.profit or 0;
	local bProfit = bEpm.profit or 0;
	local aMargin = aEpm.margin or 0;
	local bMargin = bEpm.margin or 0;
	local aValue  = aEpm.value or 0;
	local bValue  = bEpm.value or 0;
	if (aProfit > bProfit) then return true; end
	if (aProfit < bProfit) then return false; end
	if (aMargin > bMargin) then return true; end
	if (aMargin < bMargin) then return false; end
	if (aValue > bValue) then return true; end
	if (aValue < bValue) then return false; end
	return false;
end

function Enchantrix_BidBrokerSort(a, b)
	if (not a) or (not b) then return false; end
	local aTime = a.timeLeft or 0;
	local bTime = b.timeLeft or 0;
	if (aTime > bTime) then return true; end
	if (aTime < bTime) then return false; end
	return Enchantrix_ProfitComparisonSort(a, b);
end

function Enchantrix_DoPercentLess(percentLess)
	if (not Auctioneer) then
		Enchantrix_ChatPrint("You do not have Auctioneer installed. Auctioneer must be installed to do an enchanting percentless scan");
		return;
	elseif (not Auctioneer.Filter.QuerySnapshot) then
		Enchantrix_ChatPrint("You do not have the correct version of Auctioneer installed, this feature requires Auctioneer v3.3.0.0675 or later");
		return;
	end

	if not percentLess or percentLess == "" then percentLess = MIN_PERCENT_LESS_THAN_HSP end
	local output = string.format(_ENCH('FrmtPctlessHeader'), percentLess);
	Enchantrix_ChatPrint(output);

	Enchantrix_PriceCache = {t=time()};
	Enchantrix_ProfitMargins = {};
	local targetAuctions = Auctioneer.Filter.QuerySnapshot(Enchantrix_PercentLessFilter, percentLess);

	-- sort by profit based on median
	table.sort(targetAuctions, Enchantrix_ProfitComparisonSort);

	-- output the list of auctions
	for _,a in targetAuctions do
		if (a.signature and Enchantrix_ProfitMargins[a.signature]) then
			local quality = EnhTooltip.QualityFromLink(a.itemLink);
			if (quality and quality >= 2) then
				local id,rprop,enchant, name, count,_,buyout,_ = Auctioneer.Core.GetItemSignature(a.signature);
				local value = Enchantrix_ProfitMargins[a.signature].value;
				local margin = Enchantrix_ProfitMargins[a.signature].margin;
				local profit = Enchantrix_ProfitMargins[a.signature].profit;
				local output = string.format(_ENCH('FrmtPctlessLine'), Auctioneer.Util.ColorTextWhite(count.."x")..a.itemLink, EnhTooltip.GetTextGSC(value * count), EnhTooltip.GetTextGSC(buyout), EnhTooltip.GetTextGSC(profit * count), Auctioneer.Util.ColorTextWhite(margin.."%"));
				Enchantrix_ChatPrint(output);
			end
		end
	end

	Enchantrix_ChatPrint(_ENCH('FrmtPctlessDone'));
end

function Enchantrix_DoBidBroker(minProfit)
	if (not Auctioneer) then
		Enchantrix_ChatPrint("You do not have Auctioneer installed. Auctioneer must be installed to do an enchanting percentless scan");
		return;
	elseif (not Auctioneer.Filter.QuerySnapshot) then
		Enchantrix_ChatPrint("You do not have the correct version of Auctioneer installed, this feature requires Auctioneer v3.3.0.0675 or later");
		return;
	end

	if not minProfit or minProfit == "" then minProfit = MIN_PROFIT_MARGIN; else minProfit = tonumber(minProfit) * 100; end
	local output = string.format(_ENCH('FrmtBidbrokerHeader'), EnhTooltip.GetTextGSC(minProfit));
	Enchantrix_ChatPrint(output);

	Enchantrix_PriceCache = {t=time()};
	Enchantrix_ProfitMargins = {};
	local targetAuctions = Auctioneer.Filter.QuerySnapshot(Enchantrix_BidBrokerFilter, minProfit);

	-- sort by profit based on median
	table.sort(targetAuctions, Enchantrix_BidBrokerSort);

	-- output the list of auctions
	for _,a in targetAuctions do
		if (a.signature and Enchantrix_ProfitMargins[a.signature]) then
			local quality = EnhTooltip.QualityFromLink(a.itemLink);
			if (quality and quality >= 2) then
				local id,rprop,enchant, name, count, min, buyout,_ = Auctioneer.Core.GetItemSignature(a.signature);
				local currentBid = Auctioneer.Statistic.GetCurrentBid(a.signature);
				local value = Enchantrix_ProfitMargins[a.signature].value;
				local margin = Enchantrix_ProfitMargins[a.signature].margin;
				local profit = Enchantrix_ProfitMargins[a.signature].profit;
				local bidText = _ENCH('FrmtBidbrokerCurbid');
				if (currentBid == min) then
					bidText = _ENCH('FrmtBidbrokerMinbid');
				end
				local output = string.format(_ENCH('FrmtBidbrokerLine'), Auctioneer.Util.ColorTextWhite(count.."x")..a.itemLink, EnhTooltip.GetTextGSC(value * count), bidText, EnhTooltip.GetTextGSC(currentBid), EnhTooltip.GetTextGSC(profit * count), Auctioneer.Util.ColorTextWhite(margin.."%"), Auctioneer.Util.ColorTextWhite(Auctioneer.Util.GetTimeLeftString(a.timeLeft)));
				Enchantrix_ChatPrint(output);
			end
		end
	end

	Enchantrix_ChatPrint(_ENCH('FrmtBidbrokerDone'));
end

function Enchantrix_GetAuctionItemDisenchants(auctionSignature, useCache)
	local id,rprop,enchant, name, count,min,buyout,uniq = Auctioneer.Core.GetItemSignature(auctionSignature);
	local sig = string.format("%d:%d:%d", id, enchant, rprop);
	local sigNR = string.format("%d:%d:%d", id, 0, 0);
	return Enchantrix_GetItemDisenchants(sig, sigNR, name, useCache);
end

function Enchantrix_Split(str, at)
	local splut = {};
	local pos = 1;

	local match, mend = string.find(str, at, pos, true);
	while match do
		table.insert(splut, string.sub(str, pos, match-1));
		pos = mend+1;
		match, mend = string.find(str, at, pos, true);
	end
	table.insert(splut, string.sub(str, pos));
	return splut;
end

function Enchantrix_SaveLocal(sig, lData)
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

function Enchantrix_GetLocal(sig)
	local enchantItem = {};
	if (EnchantedLocal and EnchantedLocal[sig]) then
		if (type(EnchantedLocal[sig]) == "table") then
			-- Time to convert it into the new serialized format
			Enchantrix_SaveLocal(sig, EnchantedLocal[sig]);
		end

		-- Get the string and break it apart
		local enchantSerial = EnchantedLocal[sig];
		local enchantResults = Enchantrix_Split(enchantSerial, ";");
		for pos, enchantResult in enchantResults do
			local enchantBreak = Enchantrix_Split(enchantResult, ":");
			local rSig = tonumber(enchantBreak[1]) or 0;
			local iCount = tonumber(enchantBreak[2]) or 0;
			local dCount = tonumber(enchantBreak[3]) or 0;
			local oCount = tonumber(enchantBreak[4]) or 0;

			enchantItem[rSig] = { i=iCount, d=dCount, o=oCount };
		end
	end
	return enchantItem;
end

function Enchantrix_GetItemDisenchants(sig, sigNR, name, useCache)
	local disenchantsTo = {};

	if (not Enchantrix_PriceCache) or (time()-Enchantrix_PriceCache.t > 300) then
		Enchantrix_PriceCache = {t=time()};
	end

	-- Automatically convert any named EnchantedLocal items to new items
	if (name and EnchantedLocal[name]) then
		local iData = Enchantrix_GetLocal(name)
		for dName, count in iData do
			local dSig = EssenceItemIDs[dName];
			if (dSig ~= nil) then
				if (not iData[dSig]) then iData[dSig] = {}; end
				local oCount = tonumber(iData[dSig].o);
				if (oCount == nil) then oCount = 0; end
				iData[dSig].o = ""..count;
			end
		end
		EnchantedLocal[name] = nil;
		Enchantrix_SaveLocal(sig, iData);
	end

	local item = ItemID(sig)
	if (not IsDisenchantable(item)) then
		-- Item is not disenchantable
		return disenchantsTo
	end

	-- If there is data, then work out the disenchant data
	if ((item and EnchantedBaseItems[item]) or (DisenchantList[sig]) or (sigNR and DisenchantList[sigNR]) or (EnchantedLocal[sig])) then
		local bTotal = 0;
		local biTotal = 0;
		local bdTotal = 0;
		local oTotal = 0;
		local iTotal = 0;
		local dTotal = 0;

		local exactMatch = true;

		local baseDisenchant = DisenchantList[sig];

		if (not baseDisenchant) and (sigNR) then
			baseDisenchant = DisenchantList[sigNR];
			if (baseDisenchant) then
				exactMatch = false;
			end
		end

		if (item and EnchantedBaseItems[item]) then
			baseDisenchant = EnchantedBaseItems[item]
		end

		local type = ItemType(item)
		if (type and EnchantedItemTypes[type]) then
			if (DisenchantTotal(EnchantedItemTypes[type]) > DisenchantTotal(baseDisenchant)) then
				baseDisenchant = EnchantedItemTypes[type]
			end
		end

		if (item) then
			baseDisenchant = CleanupDisenchant(baseDisenchant, item)
		end

		if (baseDisenchant) then
			-- Base Disenchantments are now serialized
			local baseResults = Enchantrix_Split(baseDisenchant, ";");
			for pos, baseResult in baseResults do
				local baseBreak = Enchantrix_Split(baseResult, ":");
				local dSig = tonumber(baseBreak[1]) or 0;
				local biCount = tonumber(baseBreak[2]) or 0;
				local bdCount = tonumber(baseBreak[3]) or 0;
				local bCount = tonumber(baseBreak[4]) or 0;

				if (dSig > 0) and (bCount+biCount > 0) then
					disenchantsTo[dSig] = {};
					disenchantsTo[dSig].bCount = bCount;
					disenchantsTo[dSig].biCount = biCount;
					disenchantsTo[dSig].bdCount = bdCount;
					disenchantsTo[dSig].oCount = 0;
					disenchantsTo[dSig].iCount = 0;
					disenchantsTo[dSig].dCount = 0;
					bTotal = bTotal + bCount;
					biTotal = biTotal + biCount;
					bdTotal = bdTotal + bdCount;
				end
			end
		end

		local enchantedLocal = Enchantrix_GetLocal(sig);
		if (enchantedLocal) then
			for dSigStr, data in enchantedLocal do
				local dSig = tonumber(dSigStr);
				if (dSig and dSig > 0) then
					local oCount = 0;
					local dCount = 0;
					local iCount = 0;
					if (data.o) then oCount = tonumber(data.o); end
					if (data.d) then dCount = tonumber(data.d); end
					if (data.i) then iCount = tonumber(data.i); end

					if (not disenchantsTo[dSig]) then
						disenchantsTo[dSig] = {};
						disenchantsTo[dSig].bCount = 0;
					end
					if (data.z) then
						local bCount = disenchantsTo[dSig].bCount;
						disenchantsTo[dSig].bCount = 0;
						bTotal = bTotal - bCount;
					end
					disenchantsTo[dSig].oCount = oCount;
					disenchantsTo[dSig].dCount = dCount;
					disenchantsTo[dSig].iCount = iCount;
					oTotal = oTotal + oCount;
					dTotal = dTotal + dCount;
					iTotal = iTotal + iCount;
				end
			end
		end

		local total = bTotal + biTotal + oTotal + iTotal;

		local hspGuess = 0;
		local medianGuess = 0;
		local marketGuess = 0;
		if (total > 0) then
			for dSig, counts in disenchantsTo do
				local itemID = 0;
				if (dSig) then itemID = tonumber(dSig); end
				local dName = ItemEssences[itemID];
				if (not dName) then dName = "Item "..dSig; end
				local oldCount, itemCount, disenchantCount;
				local count = (counts.bCount or 0) + (counts.biCount or 0) + (counts.oCount or 0) + (counts.iCount or 0);
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
				local mkt = Enchantrix_StaticPrices[itemID];

				-- Work out what version if any of Auctioneer is installed
				local auctVerStr;
				if (not Auctioneer) then
					auctVerStr = AUCTIONEER_VERSION or "0.0.0";
				else
					auctVerStr = AUCTIONEER_VERSION or Auctioneer.Version or "0.0.0";
				end
				local auctVer = Enchantrix_Split(auctVerStr, ".");
				local major = tonumber(auctVer[1]) or 0;
				local minor = tonumber(auctVer[2]) or 0;
				local rev = tonumber(auctVer[3]) or 0;
				if (auctVer[3] == "DEV") then rev = 0; minor = minor + 1; end

				local itemKey = string.format("%s:0:0", itemID);
				if (useCache and not Enchantrix_PriceCache[itemKey]) then
					Enchantrix_PriceCache[itemKey] = {};
				end

				local hsp, median;
				if (useCache and Enchantrix_PriceCache[itemKey].hsp) then
					hsp = Enchantrix_PriceCache[itemKey].hsp;
				end

				if ((not hsp or hsp < 1) and (major >= 3)) then
					if (major == 3 and minor == 0 and rev <= 11) then
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
						hsp = Auctioneer_GetHSP(itemKey, Auctioneer_GetAuctionKey());
					elseif (major > 3 and minor >= 3 and (rev >= 675 or rev == 0)) then
						hsp = Auctioneer.Statistic.GetHSP(itemKey, Auctioneer.Util.GetAuctionKey());
					end
				end
				if hsp == nil then hsp = mkt * 0.98; end
				if (useCache) then Enchantrix_PriceCache[itemKey].hsp = hsp; end

				if (useCache and Enchantrix_PriceCache[itemKey].median) then
					median = Enchantrix_PriceCache[itemKey].median;
				end

				if ((not median or median < 1) and (major == 3 and (minor > 0 and minor <= 3) and (rev > 11 and rev < 675))) then
					median = Auctioneer_GetUsableMedian(itemKey);
				elseif ((not median or median < 1) and (major > 3 and minor >= 3 and (rev >= 675 or rev == 0))) then
					median = Auctioneer.Statistic.GetUsableMedian(itemKey, Auctioneer.Util.GetAuctionKey());
				end
				if median == nil then median = mkt * 0.95; end
				if (useCache) then Enchantrix_PriceCache[itemKey].median = median; end

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
		disenchantsTo.totals.exact = exactMatch;
		disenchantsTo.totals.hspValue = hspGuess or 0;
		disenchantsTo.totals.medValue = medianGuess or 0;
		disenchantsTo.totals.mktValue = marketGuess or 0;
		disenchantsTo.totals.bCount = bTotal or 0;
		disenchantsTo.totals.biCount = biTotal or 0;
		disenchantsTo.totals.bdCount = bdTotal or 0;
		disenchantsTo.totals.oCount = oTotal or 0;
		disenchantsTo.totals.dCount = dTotal or 0;
		disenchantsTo.totals.iCount = iTotal or 0;
		disenchantsTo.totals.total = total or 0;
		disenchantsTo.totals.conf = confidence or 0;
	end

	return disenchantsTo;
end

function Enchantrix_BreakLink(link)
	local i,j, itemID, enchant, randomProp, uniqID, name = string.find(link, "|Hitem:(%d+):(%d+):(%d+):(%d+)|h[[]([^]]+)[]]|h");
	return tonumber(itemID or 0), tonumber(randomProp or 0), tonumber(enchant or 0), tonumber(uniqID or 0), name;
end


function Enchantrix_FindSigInBags(sig)
	for bag = 0, 4, 1 do
		size = GetContainerNumSlots(bag);
		if (size) then
			for slot = size, 1, -1 do
				local link = GetContainerItemLink(bag, slot);
				if (link) then
					local itemID, randomProp, enchant, uniqID, itemName = Enchantrix_BreakLink(link);
					if (itemName == findName) then
						local texture, itemCount, locked, quality, readable = GetContainerItemInfo(frameID, buttonID);
						local data = {
							name = itemName, link = link,
							sig = string.format("%d:%d:%d", itemID, enchant, randomProp),
							id = itemID, rand = randomProp, ench = enchant, uniq = uniqID,
							quality = quality
						}

						return bag, slot, data;
					end
				end
			end
		end
	end
end
