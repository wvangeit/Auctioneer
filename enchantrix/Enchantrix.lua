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

EnchantConfig = {};

-- Disenchant data
EnchantedLocal = {} -- Disenchants performed by user (saved variable)
EnchantedBaseItems = {} -- DisenchantList merged by item id (saved variable)
local LocalBaseItems = {} -- EnchantedLocal merged by item id
local EnchantedItemTypes = {} -- LocalBaseItems and EnchantedBaseItems merged by type

-- These are market norm prices.
-- Median prices from Allakhazam.com, Mar 16, 2006
Enchantrix_StaticPrices = {
	[20725] = 500000, -- Nexus Crystal
	[14344] =  60000, -- Large Brilliant Shard
	[11178] =  50000, -- Large Radiant Shard
	[11139] =  16500, -- Large Glowing Shard
	[11084] =  10000, -- Large Glimmering Shard
	[14343] =  30000, -- Small Brilliant Shard
	[11177] =  27500, -- Small Radiant Shard
	[11138] =   6000, -- Small Glowing Shard
	[10978] =   3000, -- Small Glimmering Shard
	[16203] =  49500, -- Greater Eternal Essence
	[11175] =  35500, -- Greater Nether Essence
	[11135] =  10000, -- Greater Mystic Essence
	[11082] =  10000, -- Greater Astral Essence
	[10939] =   3350, -- Greater Magic Essence
	[16202] =  18500, -- Lesser Eternal Essence
	[11174] =  15000, -- Lesser Nether Essence
	[11134] =   5000, -- Lesser Mystic Essence
	[10998] =   5000, -- Lesser Astral Essence
	[10938] =   1900, -- Lesser Magic Essence
	[16204] =  10000, -- Illusion Dust
	[11176] =   6000, -- Dream Dust
	[11137] =   2500, -- Vision Dust
	[11083] =   1500, -- Soul Dust
	[10940] =    800, -- Strange Dust
}

local ENX_DUST = 1
local ENX_ESSENCE_LESSER = 2
local ENX_ESSENCE_GREATER = 3
local ENX_SHARD_SMALL = 4
local ENX_SHARD_LARGE = 5
local ENX_CRYSTAL = 6
local ENX_WEAPON = "Weapon"
local ENX_ARMOR = "Armor"
local InventoryTypes = {
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

local LevelRules = {
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

local tooltipFormat = {
	currentFormat = "fancy",
	format = {
		["fancy"] = {
			-- counts = off
			['off'] = "  $conf% |q$name|r $rate",
			-- counts = on
			['on'] = "  $conf% |q$name|r $rate |e(B=$bcount L=$lcount)|r",
		},
		["default"] = {
			['off'] = "  $name: $prob% $rate",
			['on'] = "  $name: $prob% $rate |e(B=$bcount L=$lcount)|r",
		},
	},
	patterns = {
		-- Strings
		["$prob"]	= "",			-- Probability: "75"
		["$conf"]	= "",			-- Confidence interval: "<1", "72-78", ">99"
		["$count"]	= "",			-- Local + base counts: "51"
		["$lcount"] = "",			-- Local count: "13"
		["$bcount"] = "",			-- Base count: "38"
		["$name"]	= "",			-- Name: "Lesser Magic Essence"
		["$rate"]	= "",			-- Avg drop amount: "x1.5"
		-- Colors
		["|q"]		= "",			-- Quality color
		["|E"]		= "|cffcccc33",	-- Yellow ("Enchantrix" color)
		["|e"]		= "|cff7f7f00",	-- Dark yellow
		["|r"]		= "|r",			-- Reset color
	},
	SelectFormat = function(this, fmt)
		if this.format[fmt] then
			this.currentFormat = fmt
		else
			this.currentFormat = "default"
		end
	end,
	SetFormat = function(this, fmt, val, counts)
		if counts == nil then
			counts = Enchantrix_GetFilter('counts')
		end
		if counts then
			this.format[fmt]['on'] = val
		else
			this.format[fmt]['off'] = val
		end
	end,
	GetFormat = function(this, fmt, counts)
		if not this.format[fmt] then return end
		if counts == nil then
			counts = Enchantrix_GetFilter('counts')
		end
		if counts then
			return this.format[fmt]['on']
		else
			return this.format[fmt]['off']
		end
	end,
	GetString = function(this, counts)
		local line
		if counts == nil then
			counts = Enchantrix_GetFilter('counts')
		end
		if counts then
			line = this.format[this.currentFormat]['on']
		else
			line = this.format[this.currentFormat]['off']
		end
		-- Replace patterns
		for pat, repl in pairs(this.patterns) do
			line = string.gsub(line, pat, repl or "")
		end
		return line
	end,
	SetPattern = function(this, pat, repl)
		this.patterns[pat] = repl
	end,
}

local DisenchantEvent = {}

local MAX_BUYOUT_PRICE = 800000;

local MAX_ITEM_ID = 20000

local MIN_PROFIT_MARGIN = 1000;
local MIN_PERCENT_LESS_THAN_HSP = 20; -- 20% default
local MIN_PROFIT_PRICE_PERCENT = 10; -- 10% default

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
	return math.ceil(m / n) * n
end

local function digits(m, n)
	-- Round m to n digits
	if m == 0 then
		return 0
	elseif m < 0 then
		return -digits(-m, n)
	end
	local d = 10^(n - math.floor(math.log10(m)) - 1)
	return math.floor(m * d + 0.5) / d
end

local function confidenceInterval(p, n, z)
	-- Returns confidence interval for binomial distribution given observed
	-- probability p, sample size n, and z-value
	if not z then
		--[[
		z		conf
		1.282	80%
		1.645	90%
		1.960	95%
		2.326	98%
		2.576	99%
		3.090	99.8%
		3.291	99.9%
		]]
		z = 1.645
	end
	assert(p >= 0 and p <= 1)
	assert(n > 0)

	local a = p + z^2 / (2 * n)
	local b = z * math.sqrt(p * (1 - p) / n + z^2 / (4 * n^2))
	local c = 1 + z^2 / n

	return (a - b) / c, (a + b) / c
end

local function Unserialize(str)
	-- Break up a disenchant string to a table for easy manipulation
	local tbl = {}
	if type(str) == "string" then
		for de in Enchantrix_Spliterator(str, ";") do
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
	local count = 0
	local tbl = Unserialize(str)
	for id in tbl do
		div = gcd(div, tbl[id][N_DISENCHANTS])
		div = gcd(div, tbl[id][N_REAGENTS])
		count = count + 1
	end
	-- Only normalize if there's more than one kind of reagent
	if count > 1 then
		for id in tbl do
			tbl[id][N_DISENCHANTS] = tbl[id][N_DISENCHANTS] / div
			tbl[id][N_REAGENTS] = tbl[id][N_REAGENTS] / div
		end
		return Serialize(tbl)
	end
	return str
end

local function CleanupDisenchant(str, id)
	-- Remove reagents that don't appear in level rules table
	if (type(str) == "string") and (id ~= nil) then
		local _, _, quality, level, _, _, _, equip = GetItemInfo(id)
		local type = InventoryTypes[equip]
		if (quality and type and level > 0) then
			local tbl = Unserialize(str)
			local clean = {}
			level = roundup(level, 5)
			for id in tbl do
				if (LevelRules[type][level][id]) then
					if (quality == 2) then
						-- Uncommon item, remove nexus crystal
						if (LevelRules[type][level][id] < ENX_CRYSTAL) then
							clean[id] = tbl[id]
						end
					else
						-- Rare or epic item, remove dusts and essences
						if (LevelRules[type][level][id] > ENX_ESSENCE_GREATER) then
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

local function ItemID(sig)
	-- Return item id and item suffix as integers
	if (type(sig) == "string") then
		local splt = Enchantrix_Split(sig, ":")
		return tonumber(splt[1]), tonumber(splt[3])
	elseif (type(sig) == "number") then
		return sig, 0
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
		if (not InventoryTypes[equip]) then
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
	-- Return item level (rounded up to nearest 5 levels), quality and type as string,
	-- e.g. "20:2:Armor" for uncommon level 20 armor
	if (id) then
		local _, _, quality, level, _, _, _, equip = GetItemInfo(id)
		if (quality and quality >= 2 and level > 0 and InventoryTypes[equip]) then
			return string.format("%d:%d:%s", roundup(level, 5), quality, InventoryTypes[equip])
		end
	end
	return nil
end

local function DisenchantListHash()
	-- Generate a hash for DisenchantList
	local hash = 1
	for sig in DisenchantList do
		local item, suffix = ItemID(sig)
		MAX_ITEM_ID = math.max(MAX_ITEM_ID, item)
		hash = math.mod(3 * hash + 2 * (item or 0) +(suffix or 0), 16777216)
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
		for sig, disenchant in pairs(DisenchantList) do
			local item = ItemID(sig)
			if (IsDisenchantable(item)) then
				EnchantedBaseItems[item] = MergeDisenchant(EnchantedBaseItems[item],
					NormalizeDisenchant(disenchant))
			end
		end
		EnchantedBaseItems.hash = hash
	end
	-- We don't need DisenchantList anymore
	DisenchantList = nil

	-- Merge items from EnchantedLocal
	for sig, disenchant in pairs(EnchantedLocal) do
		local item = ItemID(sig)
		MAX_ITEM_ID = math.max(MAX_ITEM_ID, item)
		if type(disenchant) == "table" then
			Enchantrix_SaveLocal(sig, disenchant)
			disenchant = EnchantedLocal[sig]
		end
		if IsDisenchantable(item) and (type(disenchant) == "string") then
			LocalBaseItems[item] = MergeDisenchant(LocalBaseItems[item], disenchant)
		end
	end

	-- Merge by item type
	for id, disenchant in pairs(EnchantedBaseItems) do
		local type = ItemType(id)
		if (type) then
			EnchantedItemTypes[type] = MergeDisenchant(EnchantedItemTypes[type], disenchant)
		end
	end
	for id, disenchant in pairs(LocalBaseItems) do
		local type = ItemType(id)
		if (type) then
			EnchantedItemTypes[type] = MergeDisenchant(EnchantedItemTypes[type], disenchant)
		end
	end
end

local function SaveDisenchant(sig, reagentID, count)
	-- Update tables after a disenchant has been detected
	assert(type(sig) == "string"); assert(tonumber(reagentID)); assert(tonumber(count))

	local id = ItemID(sig)
	local type = ItemType(id)
	local disenchant = string.format("%d:1:%d:0", reagentID, count)
	EnchantedLocal[sig] = MergeDisenchant(EnchantedLocal[sig], disenchant)
	LocalBaseItems[id] = MergeDisenchant(LocalBaseItems[id], disenchant)
	if type then
		EnchantedItemTypes[type] = MergeDisenchant(EnchantedItemTypes[type], disenchant)
	end
end

function Enchantrix_GetLinkFromName(name)
	if type(name) ~= "string" then return nil end

	if not EnchantConfig.cache then
		EnchantConfig.cache = {}
	end
	if not EnchantConfig.cache.names then
		EnchantConfig.cache.names = {}
	end

	local link = EnchantConfig.cache.names[name]
	if link then
		local n = GetItemInfo(link)
		if n ~= name then
			EnchantConfig.cache.names[name] = nil
		end
	end
	if not EnchantConfig.cache.names[name] then
		for i = 1, MAX_ITEM_ID + 4000 do
			local n, link = GetItemInfo(i)
			if n == name then
				EnchantConfig.cache.names[name] = link
				break
			end
		end
	end
	return EnchantConfig.cache.names[name]
end

function Enchantrix_GetReagentPrice(reagentID)
	-- reagentID ::= number | hyperlink
	if type(reagentID) == "string" then
		local _, _, i = string.find(reagentID, "item:(%d+):")
		reagentID = i
	end
	reagentID = tonumber(reagentID)
	if not reagentID then return nil end

	local hsp, median, market

	market = Enchantrix_StaticPrices[reagentID]

	if Auctioneer then
		local itemKey = string.format("%d:0:0", reagentID);
		local realm
		if Auctioneer.Util then
			realm = Auctioneer.Util.GetAuctionKey()
		end
		if realm then
			hsp = Auctioneer.Statistic.GetHSP(itemKey, realm)
			median = Auctioneer.Statistic.GetUsableMedian(itemKey, realm)
		end
	end

	if not EnchantConfig.cache then EnchantConfig.cache = {} end
	if not EnchantConfig.cache.prices then EnchantConfig.cache.prices = {} end
	if not EnchantConfig.cache.prices[reagentID] then EnchantConfig.cache.prices[reagentID] = {} end
	local cache = EnchantConfig.cache.prices[reagentID]
	if cache.timestamp and time() - cache.timestamp > 172800 then
		cache = {}
	end

	cache.hsp = hsp or cache.hsp
	cache.median = median or cache.median
	cache.market = market or cache.market
	cache.timestamp = time()

	return cache.hsp, cache.median, cache.market
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

local function PickupInventoryItemHook(funcArgs, retVal, slot)
	-- Remember last activated item
	if slot then
		DisenchantEvent.spellTarget = GetInventoryItemLink("player", slot)
		EnhTooltip.DebugPrint("PickupInventoryItemHook: "..(DisenchantEvent.spellTarget or "nil"))
	end
end

local function PickupContainerItemHook(funcArgs, retVal, bag, slot)
	-- Remember last activated item
	if bag and slot then
		DisenchantEvent.spellTarget = GetContainerItemLink(bag, slot)
		EnhTooltip.DebugPrint("PickupContainerItemHook: "..(DisenchantEvent.spellTarget or "nil"))
	end
end

function Enchantrix_HookTooltip(funcVars, retVal, frame, name, link, quality, count)
	-- nothing to do, if enchantrix is disabled
	if (not Enchantrix_GetFilter('all')) then
		return;
	end;

	local type = EnhTooltip.LinkType(link)
	if type == "item" then
		Enchantrix_ItemTooltip(funcVars, retVal, frame, name, link, quality, count)
	elseif type == "enchant" then
		Enchantrix_EnchantTooltip(funcVars, retVal, frame, name, link)
	end
end

function Enchantrix_ItemTooltip(funcVars, retVal, frame, name, link, quality, count)
	local embed = Enchantrix_GetFilter('embed');

	-- Check for disenchantable target
	local itemID = Enchantrix_BreakLink(link)
	if (not itemID or itemID == 0 or not IsDisenchantable(itemID)) then
		return
	end

	local disenchantsTo = Enchantrix_GetItemDisenchants(Enchantrix_SigFromLink(link), name, true);

	-- Process the results
	local totals = disenchantsTo.totals;
	disenchantsTo.totals = nil;
	if (totals and totals.total > 0) then

		-- If it looks quirky, and we haven't disenchanted it, then ignore it...
		if (totals.iCount + totals.biCount < 1) then return; end

		-- Header
		local total = ""
		if (Enchantrix_GetFilter('counts')) then
			total = string.format(" |cff7f7f00(%d)|r", totals.total)
		end
		EnhTooltip.AddLine(_ENCH('FrmtDisinto')..total, nil, embed);
		EnhTooltip.LineColor(0.8,0.8,0.2);

		local lines = {}
		for dSig, counts in pairs(disenchantsTo) do
			local p = (counts.biCount + counts.iCount) / totals.total
			local pmin, pmax = confidenceInterval(p, totals.total)

			-- Probabilities
			p, pmin, pmax = math.floor(p * 100 + 0.5), math.floor(pmin * 100 + 0.5), math.floor(pmax * 100 + 0.5)
			tooltipFormat:SetPattern("$prob", tostring(p))
			if pmin == 0 then
				tooltipFormat:SetPattern("$conf", "<"..max(pmax, 1))
			elseif pmax == 100 then
				tooltipFormat:SetPattern("$conf", ">"..min(pmin, 99))
			else
				if pmin ~= pmax then
					tooltipFormat:SetPattern("$conf", pmin.."-"..pmax)
				else
					tooltipFormat:SetPattern("$conf", tostring(p))
				end
			end

			-- Counts
			tooltipFormat:SetPattern("$count", tostring(counts.biCount + counts.iCount))
			tooltipFormat:SetPattern("$lcount", tostring(counts.iCount))
			tooltipFormat:SetPattern("$bcount", tostring(counts.biCount))

			-- Name and quality
			local name, _, quality = GetItemInfo(dSig)
			local _, _, _, color = GetItemQualityColor(quality or 0)
			tooltipFormat:SetPattern("|q", color or "|cffcccc33")
			tooltipFormat:SetPattern("$name", name or counts.name)

			-- Rate
			if counts.rate ~= 1 then
				tooltipFormat:SetPattern("$rate", string.format("x%0.1f", counts.rate))
			else
				tooltipFormat:SetPattern("$rate", "")
			end

			-- Store this line and sort key
			local line = tooltipFormat:GetString(Enchantrix_GetFilter('counts'))
			table.insert(lines,  {str = line, sort = pmin})
		end

		-- Sort in order of decreasing probability before adding to tooltip
		table.sort(lines, function(a, b) return a.sort > b.sort end)
		for n, line in ipairs(lines) do
			EnhTooltip.AddLine(line.str, nil, embed)
			EnhTooltip.LineColor(0.8, 0.8, 0.2);
			if n >= 5 then break end -- Don't add more than 5 lines
		end

		if (Enchantrix_GetFilter('valuate')) then
			local confidence = totals.conf;

			if (Enchantrix_GetFilter('valuate-hsp') and totals.hspValue > 0) then
				EnhTooltip.AddLine(_ENCH('FrmtValueAuctHsp'), digits(totals.hspValue * confidence, 3), embed);
				EnhTooltip.LineColor(0.1,0.6,0.6);
			end
			if (Enchantrix_GetFilter('valuate-median') and totals.medValue > 0) then
				EnhTooltip.AddLine(_ENCH('FrmtValueAuctMed'), digits(totals.medValue * confidence, 3), embed);
				EnhTooltip.LineColor(0.1,0.6,0.6);
			end
			if (Enchantrix_GetFilter('valuate-baseline') and totals.mktValue > 0) then
				EnhTooltip.AddLine(_ENCH('FrmtValueMarket'), digits(totals.mktValue * confidence, 3), embed);
				EnhTooltip.LineColor(0.1,0.6,0.6);
			end
		end
	end
end

function Enchantrix_EnchantTooltip(funcVars, retVal, frame, name, link)
	local embed = Enchantrix_GetFilter('embed');

	local auctioneerLoaded = false
	if Auctioneer and Auctioneer.Statistic then
		auctioneerLoaded = true
	end

	local frameName = frame:GetName()
	local nLines = frame:NumLines()
	local reagents
	for i = 1, nLines do
		local obj = getglobal(frameName.."TextLeft"..i)
		local text = ""
		if obj and obj.GetText then
			text = obj:GetText()
		end
		-- TODO: Localization
		local _, _, r = string.find(text, "Reagents: (.+)")
		if r then
			reagents = r
			break
		end
	end
	local price = 0
	local unknownPrices = false
	local reagentInfo = {}
	for reagent in Enchantrix_Spliterator(reagents, ",") do
		-- Chomp whitespace
		reagent = string.gsub(reagent, "^%s*", "")
		reagent = string.gsub(reagent, "%s*$", "")
		-- ...and color codes
		reagent = string.gsub(reagent, "^%|c%x%x%x%x%x%x%x%x", "")
		reagent = string.gsub(reagent, "%|r$", "")

		local _, _, count = string.find(reagent, "%((%d+)%)$")
		if count then
			reagent = string.gsub(reagent, "%s*%(%d+%)$", "")
			count = tonumber(count)
		else
			count = 1
		end

		local link = Enchantrix_GetLinkFromName(reagent)
		if link then
			local name, quality, color
			name, _, quality = GetItemInfo(link)
			if quality then
				_, _, _, color = GetItemQualityColor(quality)
			end
			local hsp, median, market = Enchantrix_GetReagentPrice(link)
			table.insert(reagentInfo, {
				["name"] = reagent,
				["count"] = count,
				["price"] = hsp,
				["quality"] = quality,
				["color"] = color,
			})
			if hsp then
				price = price + count * hsp
			else
				unknownPrices = true
			end
		else
			table.insert(reagentInfo, {
				["name"] = reagent,
				["count"] = count,
			})
			unknownPrices = true
		end
	end
	table.sort(reagentInfo, function(a,b)
		return ((b.quality or -1) < (a.quality or -1)) or ((b.price or 0) < (a.price or 0))
	end)

	-- No reagents
	if table.getn(reagentInfo) < 1 then
		return
	end

	if not embed then
		EnhTooltip.SetIcon("Interface\\Icons\\Spell_Holy_GreaterHeal")
		EnhTooltip.AddLine(name)
		EnhTooltip.AddLine(EnhTooltip.HyperlinkFromLink(link))
	end
	-- TODO: Localization
	EnhTooltip.AddLine("Suggested price:", nil, embed)
	EnhTooltip.LineColor(0.8,0.8,0.2)

	for _, reagent in pairs(reagentInfo) do
		local line = "  "
		
		if reagent.color then
			line = line..reagent.color
		end
		line = line..reagent.name
		if reagent.color then
			line = line.."|r"
		end
		line = line.." x"..reagent.count
		if reagent.count > 1 and reagent.price then
			line = line..string.format(" (%s ea)", EnhTooltip.GetTextGSC(digits(reagent.price, 3)))
			EnhTooltip.AddLine(line, digits(reagent.price * reagent.count, 3), embed)
		elseif reagent.price then
			EnhTooltip.AddLine(line, digits(reagent.price, 3), embed)
		else
			EnhTooltip.AddLine(line, nil, embed)
		end
		EnhTooltip.LineColor(0.7,0.7,0.1)
	end

	if price > 0 then
		-- TODO: Localization
		EnhTooltip.AddLine("Total", digits(price, 3), embed)
		EnhTooltip.LineColor(0.8,0.8,0.2)
		if not auctioneerLoaded then
			-- TODO: Localization
			EnhTooltip.AddLine("[Auctioneer not loaded, using cached prices]")
			EnhTooltip.LineColor(0.6,0.6,0.1)
		end
		if unknownPrices then
			-- TODO: Localization
			EnhTooltip.AddLine("[Some prices unavailable]")
			EnhTooltip.LineColor(0.6,0.6,0.1)
		end
	else
		-- TODO: Localization
		EnhTooltip.AddLine("[No prices available]")
		EnhTooltip.LineColor(0.6,0.6,0.1)
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

local ItemEssences = {};
local EssenceItemIDs = {};
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

function Enchantrix_OnEvent(funcVars, event, arg1, arg2)

	if ((event == "SPELLCAST_START") and (arg1 == _ENCH('ArgSpellname'))) then
		DisenchantEvent.started = DisenchantEvent.spellTarget
		DisenchantEvent.startTime = GetTime()
		DisenchantEvent.spellDuration = arg2 / 1000  -- Convert ms to s
		DisenchantEvent.finished = nil
		return
	end
	if ((event == "SPELLCAST_FAILED") or (event == "SPELLCAST_INTERRUPTED")) then
		DisenchantEvent.started = nil
		DisenchantEvent.finished = nil
		return
	end
	if ((event == "SPELLCAST_STOP") and DisenchantEvent.started) then
		DisenchantEvent.finished = DisenchantEvent.started
		DisenchantEvent.started = nil
		return
	end
	if (event == "LOOT_OPENED") then
		if DisenchantEvent.finished then
			-- Make sure loot windows opens within a few seconds from expected spell completion time
			-- Normal range of lootLatency appears to be around -0.1 - 0.7s
			local lootLatency = GetTime() - (DisenchantEvent.startTime + DisenchantEvent.spellDuration)
			if (lootLatency > -1) and (lootLatency < 2) then
				Enchantrix_ChatPrint(string.format(_ENCH("FrmtFound"), DisenchantEvent.finished))
				local sig = Enchantrix_SigFromLink(DisenchantEvent.finished)
				for i = 1, GetNumLootItems(), 1 do
					if LootSlotIsItem(i) then
						local icon, name, quantity, rarity = GetLootSlotInfo(i)
						local link = GetLootSlotLink(i)
						Enchantrix_ChatPrint(string.format("  %s x%d", link, quantity))
						-- Save result
						local reagentID = Enchantrix_BreakLink(link)
						if reagentID then
							SaveDisenchant(sig, reagentID, quantity)
						end
					end
				end
			end
		end
		DisenchantEvent.started = nil
		DisenchantEvent.finished = nil
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
	Stubby.RegisterFunctionHook("PickupContainerItem", 200, PickupContainerItemHook)
	Stubby.RegisterFunctionHook("PickupInventoryItem", 200, PickupInventoryItemHook)

	Stubby.RegisterAddOnHook("Auctioneer", "Enchantrix", Enchantrix_AuctioneerLoaded);

	Stubby.RegisterEventHook("SPELLCAST_FAILED", "Enchantrix", Enchantrix_OnEvent);
	Stubby.RegisterEventHook("SPELLCAST_INTERRUPTED", "Enchantrix", Enchantrix_OnEvent);
	Stubby.RegisterEventHook("SPELLCAST_START", "Enchantrix", Enchantrix_OnEvent);
	Stubby.RegisterEventHook("SPELLCAST_STOP", "Enchantrix", Enchantrix_OnEvent);
	Stubby.RegisterEventHook("LOOT_OPENED", "Enchantrix", Enchantrix_OnEvent);

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
	return Enchantrix_GetItemDisenchants(sig, name, useCache);
end

function Enchantrix_Split(str, at)
	local splut = {};

	if (type(str) ~= "string") then return nil end
	if (not str) then str = "" end

	if (not at)
		then table.insert(splut, str)

	else
		for n, c in string.gfind(str, '([^%'..at..']*)(%'..at..'?)') do
			table.insert(splut, n);

			if (c == '') then break end
		end
	end
	return splut;
end

function Enchantrix_Spliterator(str, at)
	local start
	local found = 0
	local done = (type(str) ~= "string")
	return function()
		if done then return nil end
		start = found + 1
		found = string.find(str, at, start, true)
		if not found then
			found = 0
			done = true
		end
		return string.sub(str, start, found - 1)
	end
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
		for enchantResult in Enchantrix_Spliterator(EnchantedLocal[sig]) do
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

function Enchantrix_GetItemDisenchants(sig, name, useCache)
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

	local itemID = ItemID(sig)
	if (not (itemID and IsDisenchantable(itemID))) then
		-- Item is not disenchantable
		return {}
	end

	-- If there is data, then work out the disenchant data
	if (EnchantedBaseItems[itemID] or LocalBaseItems[itemID]) then
		local biTotal = 0;
		local bdTotal = 0;
		local iTotal = 0;
		local dTotal = 0;

		local baseDisenchant = EnchantedBaseItems[itemID]

		local type = ItemType(itemID)
		if (type and EnchantedItemTypes[type]) then
			if (DisenchantTotal(EnchantedItemTypes[type]) > DisenchantTotal(baseDisenchant)) then
				baseDisenchant = EnchantedItemTypes[type]
			end
		end

		baseDisenchant = CleanupDisenchant(baseDisenchant, itemID)

		if (baseDisenchant) then
			-- Base Disenchantments are now serialized
			local baseResults = Unserialize(baseDisenchant)
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

		if (LocalBaseItems[itemID]) then
			local enchantedLocal = Unserialize(LocalBaseItems[itemID])
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
				local itemID = 0;
				if (dSig) then itemID = tonumber(dSig); end
				local dName = ItemEssences[itemID];
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
				local mkt = Enchantrix_StaticPrices[itemID] or 0

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

				local itemKey = string.format("%d:0:0", itemID);
				if (useCache and not Enchantrix_PriceCache[itemKey]) then
					Enchantrix_PriceCache[itemKey] = {};
				end

				local hsp, median;
				if (useCache and Enchantrix_PriceCache[itemKey].hsp) then
					hsp = Enchantrix_PriceCache[itemKey].hsp;
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
				if (useCache) then Enchantrix_PriceCache[itemKey].hsp = hsp; end

				if (useCache and Enchantrix_PriceCache[itemKey].median) then
					median = Enchantrix_PriceCache[itemKey].median;
				end

				if ((not median or median < 1) and (major == 3 and (minor > 0 and minor <= 3) and (rev > 11 and rev < 675))) then
					-- 3.1.11 < ver < 3.3.675
					median = Auctioneer_GetUsableMedian(itemKey);
				elseif ((not median or median < 1) and (major >= 3 and minor >= 3 and (rev >= 675 or rev == 0))) then
					-- 3.3.675 <= ver
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

function Enchantrix_BreakLink(link)
	if type(link) ~= "string" then
		return nil
	end
	local i,j, itemID, enchant, randomProp, uniqID, name = string.find(link, "|Hitem:(%d+):(%d+):(%d+):(%d+)|h[[]([^]]+)[]]|h");
	return tonumber(itemID or 0), tonumber(randomProp or 0), tonumber(enchant or 0), tonumber(uniqID or 0), name;
end
