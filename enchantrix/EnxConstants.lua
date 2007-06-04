--[[
	Enchantrix Addon for World of Warcraft(tm).
	Version: <%version%> (<%codename%>)
	Revision: $Id$

	Enchantrix Constants.
	
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
]]
Enchantrix_RegisterRevision("$URL$", "$Rev$")

local const = Enchantrix.Constants

-- These are market norm prices.
-- Median prices from Allakhazam.com, April 16, 2007
-- Prices are in copper aka GGSSCC
const.StaticPrices = {
	[22450] = 759992, -- Void Crystal
	[20725] =  80000, -- Nexus Crystal
	
	[22449] = 191633, -- Large Prismatic Shard
	[14344] = 110000, -- Large Brilliant Shard
	[11178] =  88000, -- Large Radiant Shard
	[11139] =  28106, -- Large Glowing Shard
	[11084] =  11250, -- Large Glimmering Shard
	
	[22448] =  60000, -- Small Prismatic Shard
	[14343] =  24000, -- Small Brilliant Shard
	[11177] =  70200, -- Small Radiant Shard
	[11138] =   5000, -- Small Glowing Shard
	[10978] =   3200, -- Small Glimmering Shard
	
	[22446] =  64900, -- Greater Planar Essence
	[16203] = 110225, -- Greater Eternal Essence
	[11175] =  60000, -- Greater Nether Essence
	[11135] =  10000, -- Greater Mystic Essence
	[11082] =   8750, -- Greater Astral Essence
	[10939] =   6500, -- Greater Magic Essence
	
	[22447] =  21200, -- Lesser Planar Essence
	[16202] =  42538, -- Lesser Eternal Essence
	[11174] =  24285, -- Lesser Nether Essence
	[11134] =   5040, -- Lesser Mystic Essence
	[10998] =   4000, -- Lesser Astral Essence
	[10938] =   3215, -- Lesser Magic Essence
	
	[22445] =  22500, -- Arcane Dust
	[16204] =  24800, -- Illusion Dust
	[11176] =   8333, -- Dream Dust
	[11137] =   5500, -- Vision Dust
	[11083] =   3000, -- Soul Dust
	[10940] =   1250, -- Strange Dust

	[2772] =    3000, -- Iron Ore
	[3356] =     800, -- Kingsblood
	[3371] =      20, -- Empty Vial
	[3372] =     200, -- Leaded Vial
	[3819] =    4275, -- Wintersbite
	[3829] =   28500, -- Frost Oil
	[4470] =      38, -- Simple Wood
	[4625] =    3125, -- Firebloom
	[5500] =   24000, -- Iridescent Pearl
	[5637] =    7950, -- Large Fang
	[6037] =   10000, -- Truesilver Bar
	[6048] =    9000, -- Shadow Protection Potion
	[6217] =     124, -- Copper Rod
	[6370] =    4990, -- Blackmouth Oil
	[6371] =    5000, -- Fire Oil
	[7067] =    9000, -- Elemental Earth
	[7075] =   52664, -- Core of Earth
	[7077] =   50000, -- Heart of Fire
	[7078] =   98823, -- Essence of Fire
	[7079] =    7350, -- Globe of Water
	[7080] =   79900, -- Essence of Water
	[7081] =   49000, -- Breath of Wind
	[7082] =  160000, -- Essence of Air
	[7392] =    3500, -- Green Whelp Scale
	[7909] =   20000, -- Aquamarine
	[7971] =   14700, -- Black Pearl
	[7972] =    2999, -- Ichor of Undeath
	[8153] =    9950, -- Wildvine
	[8170] =    3750, -- Rugged Leather
	[8831] =    3529, -- Purple Lotus
	[8838] =    4000, -- Sungrass
	[8925] =    2500, -- Crystal Vial
	[9224] =   39500, -- Elixir of Demonslaying
	[11128] =  29500, -- Golden Rod
	[11144] =  40000, -- Truesilver Rod
	[11291] =   4500, -- Star Wood
	[11382] = 150000, -- Blood of the Mountain
	[11754] =   3135, -- Black Diamond
	[12359] =  10000, -- Thorium Bar
	[12803] =  35000, -- Living Essence
	[12808] =  67500, -- Essence of Undeath
	[12809] =  58677, -- Guardian Stone
	[12811] = 420000, -- Righteous Orb
	[13444] =  16666, -- Major Mana Potion
	[13446] =  10000, -- Major Healing Potion
	[13467] =   5875, -- Icecap
	[13468] = 180000, -- Black Lotus
	[13926] =  15500, -- Golden Pearl
	[16206] = 620000, -- Arcanite Rod
	[17034] =    200, -- Maple Seed
	[17035] =    400, -- Stranglethorn Seed
	[18256] =  30000, -- Imbued Vial
	[18512] =  20710, -- Larval Acid
	[21884] = 294500, -- Primal Fire
	[21885] = 239900, -- Primal Water
	[21886] = 140000, -- Primal Life
	[22451] = 300000, -- Primal Air
	[22452] =  55000, -- Primal Earth
	[22456] =  17525, -- Primal Shadow
	[22457] = 220000, -- Primal Mana
	[22791] =  19090, -- Netherbloom
	[22792] =  18362, -- Nightmare Vine
	[25843] = 150000, -- Fel Iron Rod
	[25844] = 185000, -- Adamantite Rod
	[25845] = 450000, -- Eternium Rod
	
	[24186] =     50, 	-- COPPERPOWDER, vendor
	[24188] =    125, 	-- TINPOWDER, vendor
	[24190] =    400, 	-- IRONPOWDER, vendor
	[24234] =    500, 	-- MITHRILPOWDER, vendor
	[24235] =    800, 	-- THORIUMPOWDER, vendor
	[24242] =   1500, 	-- FELIRONPOWDER, vendor
	[24243] =   5000, 	-- ADAMANTITEPOWDER, auction

	[818] =     2633, 	-- TIGERSEYE
	[774] =     2000, 	-- MALACHITE
	[1210] =    6076,	-- SHADOWGEM
	[1705] =   14000, 	-- LESSERMOONSTONE
	[1206] =   12100, 	-- MOSSAGATE
	[3864] =   10000, 	-- CITRINE
	[1529] =   20000, 	-- JADE
	[7909] =   22500, 	-- AQUAMARINE
	[7910] =   22500, 	-- STARRUBY
	[12800] = 105000, 	-- AZEROTHIANDIAMOND
	[12361] =  50000, 	-- BLUESAPPHIRE
	[12799] =  50000, 	-- LARGEOPAL
	[12364] = 100000, 	-- HUGEEMERALD
	[23077] =  15000, 	-- BLOODGARNET
	[21929] =  12666, 	-- FLAMESPESSARITE
	[23112] =  16332, 	-- GOLDENDRAENITE
	[23079] =  14000, 	-- DEEPPERIDOT
	[23117] =  14000, 	-- AZUREMOONSTONE
	[23107] =  15000, 	-- SHADOWDRAENITE
	[23436] = 600000,	-- LIVINGRUBY
	[23439] = 400000, 	-- NOBLETOPAZ
	[23440] = 300000, 	-- DAWNSTONE
	[23437] = 250000, 	-- TALASITE
	[23438] = 541772, 	-- STAROFELUNE
	[23441] = 480000, 	-- NIGHTSEYE

}

const.DUST = 1
const.ESSENCE_LESSER = 2
const.ESSENCE_GREATER = 3
const.SHARD_SMALL = 4
const.SHARD_LARGE = 5
const.CRYSTAL = 6

const.CONSUMABLE = 0 
const.CONTAINER  = 1 
const.WEAPON     = 2 
const.ARMOR      = 4 
const.REAGENT    = 5 
const.PROJECTILE = 6 
const.TRADE      = 7 
const.RECIPE     = 9 
const.QUIVER     = 11
const.QUEST      = 12
const.KEY        = 13
const.MISC       = 15


const.InventoryTypes = {
	["INVTYPE_2HWEAPON"] = const.WEAPON,
	["INVTYPE_WEAPON"] = const.WEAPON,
	["INVTYPE_WEAPONMAINHAND"] = const.WEAPON,
	["INVTYPE_WEAPONOFFHAND"] = const.WEAPON,
	["INVTYPE_RANGED"] = const.WEAPON,
	["INVTYPE_RANGEDRIGHT"] = const.WEAPON,
	["INVTYPE_THROWN"] = const.WEAPON,
	["INVTYPE_BODY"] = const.ARMOR,
	["INVTYPE_CHEST"] = const.ARMOR,
	["INVTYPE_CLOAK"] = const.ARMOR,
	["INVTYPE_FEET"] = const.ARMOR,
	["INVTYPE_FINGER"] = const.ARMOR,
	["INVTYPE_HAND"] = const.ARMOR,
	["INVTYPE_HEAD"] = const.ARMOR,
	["INVTYPE_HOLDABLE"] = const.ARMOR,
	["INVTYPE_LEGS"] = const.ARMOR,
	["INVTYPE_NECK"] = const.ARMOR,
	["INVTYPE_ROBE"] = const.ARMOR,
	["INVTYPE_SHIELD"] = const.ARMOR,
	["INVTYPE_SHOULDER"] = const.ARMOR,
	["INVTYPE_TABARD"] = const.ARMOR,
	["INVTYPE_TRINKET"] = const.ARMOR,
	["INVTYPE_WAIST"] = const.ARMOR,
	["INVTYPE_WRIST"] = const.ARMOR,
	["INVTYPE_RELIC"] = const.ARMOR,
}

-- Enchanting reagents
local VOID = 22450
local NEXUS = 20725
local LPRISMATIC = 22449
local LBRILLIANT = 14344
local LRADIANT = 11178
local LGLOWING = 11139
local LGLIMMERING = 11084
local SPRISMATIC = 22448
local SBRILLIANT = 14343
local SRADIANT = 11177
local SGLOWING = 11138
local SGLIMMERING = 10978
local GPLANAR = 22446
local GETERNAL = 16203
local GNETHER = 11175
local GMYSTIC = 11135
local GASTRAL = 11082
local GMAGIC = 10939
local LPLANAR = 22447
local LETERNAL = 16202
local LNETHER = 11174
local LMYSTIC = 11134
local LASTRAL = 10998
local LMAGIC = 10938
local ARCANE = 22445
local ILLUSION = 16204
local DREAM = 11176
local VISION = 11137
local SOUL = 11083
local STRANGE = 10940


-- and in a form we can iterate over, with a fixed order for the UI

const.DisenchantReagentList = {

	22450, -- Void Crystal
	20725, -- Nexus Crystal
	
	22449, -- Large Prismatic Shard
	14344, -- Large Brilliant Shard
	11178, -- Large Radiant Shard
	11139, -- Large Glowing Shard
	11084, -- Large Glimmering Shard
	
	22448, -- Small Prismatic Shard
	14343, -- Small Brilliant Shard
	11177, -- Small Radiant Shard
	11138, -- Small Glowing Shard
	10978, -- Small Glimmering Shard
	
	22446, -- Greater Planar Essence
	16203, -- Greater Eternal Essence
	11175, -- Greater Nether Essence
	11135, -- Greater Mystic Essence
	11082, -- Greater Astral Essence
	10939, -- Greater Magic Essence
	
	22447, -- Lesser Planar Essence
	16202, -- Lesser Eternal Essence
	11174, -- Lesser Nether Essence
	11134, -- Lesser Mystic Essence
	10998, -- Lesser Astral Essence
	10938, -- Lesser Magic Essence
	
	22445, -- Arcane Dust
	16204, -- Illusion Dust
	11176, -- Dream Dust
	11137, -- Vision Dust
	11083, -- Soul Dust
	10940, -- Strange Dust

}


-- item qualities
local UNCOMMON = 2
local RARE = 3
local EPIC = 4

-- disenchanting level bracket upper bounds
-- e.g. an ilevel 52 item goes into bracket 55
const.levelUpperBounds = { 15, 20, 25, 30, 35, 40, 45, 50, 55, 60, 65, 70, 79, 85, 94, 99, 120, 175 }


-- the big disenchant table, indexed by [quality][type][level bracket]
-- and yielding { { reagent type, drop probability, average drop quantity }, ... }
-- Thanks to Chardonnay, Tekkub and Wowhead

-- TODO - ccox - can I use a bounds list per quality to make the tables smaller?
const.baseDisenchantTable = {
 [UNCOMMON] = {
  [const.WEAPON] = {
   [15]  = { { STRANGE , 0.20, 1.5 }, { LMAGIC  , 0.80, 1.5 }, },
   [20]  = { { STRANGE , 0.20, 2.5 }, { GMAGIC  , 0.75, 1.5 }, { SGLIMMERING, 0.05, 1.0 }, },
   [25]  = { { STRANGE , 0.15, 5.0 }, { LASTRAL , 0.75, 1.5 }, { SGLIMMERING, 0.10, 1.0 }, },
   [30]  = { { SOUL    , 0.20, 1.5 }, { GASTRAL , 0.75, 1.5 }, { LGLIMMERING, 0.05, 1.0 }, },
   [35]  = { { SOUL    , 0.20, 3.5 }, { LMYSTIC , 0.75, 1.5 }, { SGLOWING   , 0.05, 1.0 }, },
   [40]  = { { VISION  , 0.20, 1.5 }, { GMYSTIC , 0.75, 1.5 }, { LGLOWING   , 0.05, 1.0 }, },
   [45]  = { { VISION  , 0.15, 3.5 }, { LNETHER , 0.80, 1.5 }, { SRADIANT   , 0.05, 1.0 }, },
   [50]  = { { DREAM   , 0.20, 1.5 }, { GNETHER , 0.75, 1.5 }, { LRADIANT   , 0.05, 1.0 }, },
   [55]  = { { DREAM   , 0.20, 3.5 }, { LETERNAL, 0.75, 1.5 }, { SBRILLIANT , 0.05, 1.0 }, },
   [60]  = { { ILLUSION, 0.20, 1.5 }, { GETERNAL, 0.75, 1.5 }, { LBRILLIANT , 0.05, 1.0 }, },
   [65]  = { { ILLUSION, 0.20, 3.5 }, { GETERNAL, 0.75, 2.5 }, { LBRILLIANT , 0.05, 1.0 }, },
   [70]  = { { ARCANE  , 0.20, 1.5 }, { LPLANAR , 0.75, 1.5 }, { SPRISMATIC , 0.05, 1.0 }, },
   [79]  = { { ARCANE  , 0.20, 1.5 }, { LPLANAR , 0.75, 1.5 }, { SPRISMATIC , 0.05, 1.0 }, },
   [85]  = { { ARCANE  , 0.20, 2.5 }, { LPLANAR , 0.75, 2.5 }, { SPRISMATIC , 0.05, 1.0 }, },
   [94]  = { { ARCANE  , 0.20, 2.5 }, { LPLANAR , 0.75, 2.5 }, { SPRISMATIC , 0.05, 1.0 }, },
   [99]  = { { ARCANE  , 0.20, 2.5 }, { LPLANAR , 0.75, 2.5 }, { SPRISMATIC , 0.05, 1.0 }, },
   [120] = { { ARCANE  , 0.20, 3.5 }, { GPLANAR , 0.75, 1.5 }, { LPRISMATIC , 0.05, 1.0 }, },
   [175] = { { ARCANE  , 0.20, 3.5 }, { GPLANAR , 0.75, 1.5 }, { LPRISMATIC , 0.05, 1.0 }, },
  },
  [const.ARMOR] = {
   [15]  = { { STRANGE , 0.80, 1.5 }, { LMAGIC  , 0.20, 1.5 }, },
   [20]  = { { STRANGE , 0.75, 2.5 }, { GMAGIC  , 0.20, 1.5 }, { SGLIMMERING, 0.05, 1.0 }, },
   [25]  = { { STRANGE , 0.75, 5.0 }, { LASTRAL , 0.15, 1.5 }, { SGLIMMERING, 0.10, 1.0 }, },
   [30]  = { { SOUL    , 0.75, 1.5 }, { GASTRAL , 0.20, 1.5 }, { LGLIMMERING, 0.05, 1.0 }, },
   [35]  = { { SOUL    , 0.75, 3.5 }, { LMYSTIC , 0.20, 1.5 }, { SGLOWING   , 0.05, 1.0 }, },
   [40]  = { { VISION  , 0.75, 1.5 }, { GMYSTIC , 0.20, 1.5 }, { LGLOWING   , 0.05, 1.0 }, },
   [45]  = { { VISION  , 0.80, 3.5 }, { LNETHER , 0.15, 1.5 }, { SRADIANT   , 0.05, 1.0 }, },
   [50]  = { { DREAM   , 0.75, 1.5 }, { GNETHER , 0.20, 1.5 }, { LRADIANT   , 0.05, 1.0 }, },
   [55]  = { { DREAM   , 0.75, 3.5 }, { LETERNAL, 0.20, 1.5 }, { SBRILLIANT , 0.05, 1.0 }, },
   [60]  = { { ILLUSION, 0.75, 1.5 }, { GETERNAL, 0.20, 1.5 }, { LBRILLIANT , 0.05, 1.0 }, },
   [65]  = { { ILLUSION, 0.75, 3.5 }, { GETERNAL, 0.20, 2.5 }, { LBRILLIANT , 0.05, 1.0 }, },
   [70]  = { { ARCANE  , 0.80, 1.5 }, { LPLANAR , 0.15, 1.5 }, { SPRISMATIC , 0.05, 1.0 }, },
   [79]  = { { ARCANE  , 0.80, 1.5 }, { LPLANAR , 0.15, 1.5 }, { SPRISMATIC , 0.05, 1.0 }, },
   [85]  = { { ARCANE  , 0.75, 2.5 }, { LPLANAR , 0.20, 2.5 }, { SPRISMATIC , 0.05, 1.0 }, },
   [94]  = { { ARCANE  , 0.75, 2.5 }, { LPLANAR , 0.20, 2.5 }, { SPRISMATIC , 0.05, 1.0 }, },
   [99]  = { { ARCANE  , 0.75, 2.5 }, { LPLANAR , 0.20, 2.5 }, { SPRISMATIC , 0.05, 1.0 }, },
   [120] = { { ARCANE  , 0.75, 3.5 }, { GPLANAR , 0.20, 1.5 }, { LPRISMATIC , 0.05, 1.0 }, },
   [175] = { { ARCANE  , 0.75, 3.5 }, { GPLANAR , 0.20, 1.5 }, { LPRISMATIC , 0.05, 1.0 }, },
  },
 },
 [RARE] = {
  [const.WEAPON] = {
   [20]  = { { SGLIMMERING, 1.00, 1.0 }, },
   [25]  = { { SGLIMMERING, 1.00, 1.0 }, },
   [30]  = { { LGLIMMERING, 1.00, 1.0 }, },
   [35]  = { { SGLOWING   , 1.00, 1.0 }, },
   [40]  = { { LGLOWING   , 1.00, 1.0 }, },
   [45]  = { { SRADIANT   , 1.00, 1.0 }, },
   [50]  = { { LRADIANT   , 1.00, 1.0 }, },
   [55]  = { { SBRILLIANT , 1.00, 1.0 }, },
   [60]  = { { LBRILLIANT , 0.99, 1.0 }, { NEXUS, 0.01, 1.0 }, },
   [65]  = { { LBRILLIANT , 0.99, 1.0 }, { NEXUS, 0.01, 1.0 }, },
   [70]  = { { LBRILLIANT , 0.99, 1.0 }, { NEXUS, 0.01, 1.0 }, },
   [79]  = { { SPRISMATIC , 0.99, 1.0 }, { NEXUS, 0.01, 1.0 }, },
   [85]  = { { SPRISMATIC , 0.99, 1.0 }, { NEXUS, 0.01, 1.0 }, },
   [94]  = { { SPRISMATIC , 0.99, 1.0 }, { VOID , 0.01, 1.0 }, },
   [99]  = { { SPRISMATIC , 0.99, 1.0 }, { VOID , 0.01, 1.0 }, },
   [120] = { { LPRISMATIC , 0.99, 1.0 }, { VOID , 0.01, 1.0 }, },
   [175] = { { LPRISMATIC , 0.99, 1.0 }, { VOID , 0.01, 1.0 }, },
  },
  [const.ARMOR] = {
   [20]  = { { SGLIMMERING, 1.00, 1.0 }, },
   [25]  = { { SGLIMMERING, 1.00, 1.0 }, },
   [30]  = { { LGLIMMERING, 1.00, 1.0 }, },
   [35]  = { { SGLOWING   , 1.00, 1.0 }, },
   [40]  = { { LGLOWING   , 1.00, 1.0 }, },
   [45]  = { { SRADIANT   , 1.00, 1.0 }, },
   [50]  = { { LRADIANT   , 1.00, 1.0 }, },
   [55]  = { { SBRILLIANT , 1.00, 1.0 }, },
   [60]  = { { LBRILLIANT , 0.99, 1.0 }, { NEXUS, 0.01, 1.0 }, },
   [65]  = { { LBRILLIANT , 0.99, 1.0 }, { NEXUS, 0.01, 1.0 }, },
   [70]  = { { LBRILLIANT , 0.99, 1.0 }, { NEXUS, 0.01, 1.0 }, },	-- this is for pre-BC items, there is some overlap 66-70
   [79]  = { { SPRISMATIC , 0.99, 1.0 }, { NEXUS, 0.01, 1.0 }, },
   [85]  = { { SPRISMATIC , 0.99, 1.0 }, { NEXUS, 0.01, 1.0 }, },
   [94]  = { { SPRISMATIC , 0.99, 1.0 }, { VOID , 0.01, 1.0 }, },
   [99]  = { { SPRISMATIC , 0.99, 1.0 }, { VOID , 0.01, 1.0 }, },
   [120] = { { LPRISMATIC , 0.99, 1.0 }, { VOID , 0.01, 1.0 }, },
   [175] = { { LPRISMATIC , 0.99, 1.0 }, { VOID , 0.01, 1.0 }, },
  },
 },
 [EPIC] = {
  [const.WEAPON] = {
   [40]  = { { SRADIANT  , 1.00, 3.0 }, },
   [45]  = { { SRADIANT  , 1.00, 3.5 }, },
   [50]  = { { LRADIANT  , 1.00, 3.5 }, },
   [55]  = { { SBRILLIANT, 1.00, 3.5 }, },
   [60]  = { { NEXUS     , 1.00, 1.0 }, },
   [65]  = { { NEXUS     , 1.00, 1.5 }, },
   [70]  = { { NEXUS     , 1.00, 1.5 }, },
   [79]  = { { NEXUS     , 1.00, 1.5 }, },
   [85]  = { { NEXUS     , 1.00, 1.5 }, },
   [94]  = { { NEXUS     , 1.00, 1.5 }, },	-- BC gear appears to start at 95
   [99]  = { { VOID      , 1.00, 1.0 }, },
   [120] = { { VOID      , 1.00, 1.5 }, },
   [175] = { { VOID      , 1.00, 1.5 }, },	-- Highest known ilvl is 151 but Illidan loot should be around this
  },
  [const.ARMOR] = {
   [40]  = { { SRADIANT  , 1.00, 3.0 }, },
   [45]  = { { SRADIANT  , 1.00, 3.5 }, },
   [50]  = { { LRADIANT  , 1.00, 3.5 }, },
   [55]  = { { SBRILLIANT, 1.00, 3.5 }, },
   [60]  = { { NEXUS     , 1.00, 1.0 }, },
   [65]  = { { NEXUS     , 1.00, 1.5 }, },
   [70]  = { { NEXUS     , 1.00, 1.5 }, },
   [79]  = { { NEXUS     , 1.00, 1.5 }, },
   [85]  = { { NEXUS     , 1.00, 1.5 }, },
   [94]  = { { NEXUS     , 1.00, 1.5 }, },	-- BC gear appears to start at 95
   [99]  = { { VOID      , 1.00, 1.0 }, },
   [120] = { { VOID      , 1.00, 1.5 }, },
   [175] = { { VOID      , 1.00, 1.5 }, },	-- Highest known ilvl is 151 but Illidan loot should be around this
  },
 },
}


-- this is for the few items that overlap Pre and Post Burning Crusade item level 66 to 70
-- because pre and post disenchant to different things
-- generated from  http://www.wowhead.com/?items=4&filter=qu=3;minle=66;maxle=70;cr=82:93;crs=1:2;crv=0:0
-- all the weapons in this range are pre-BC
const.RareArmorExceptionList = {
	[32695] = true,
	[32481] = true,
	[23835] = true,
	[23836] = true,
	[25653] = true,
	[32863] = true,
	[70]  = { { SPRISMATIC , 0.99, 1.0 }, { NEXUS, 0.01, 1.0 }, },	-- result for post-BC items
}



local COPPER_ORE = 2770
local TIN_ORE = 2771
local IRON_ORE = 2772
local MITHRIL_ORE = 3858
local THORIUM_ORE = 10620
local FEL_IRON_ORE = 23424
local ADAMANTITE_ORE = 23425

local COPPERPOWDER = 24186
local TINPOWDER = 24188
local IRONPOWDER = 24190
local MITHRILPOWDER = 24234
local THORIUMPOWDER = 24235
local FELIRONPOWDER = 24242
local ADAMANTITEPOWDER = 24243

local TIGERSEYE = 818
local MALACHITE = 774
local SHADOWGEM = 1210
local LESSERMOONSTONE = 1705
local MOSSAGATE = 1206
local CITRINE = 3864
local JADE = 1529
local AQUAMARINE = 7909
local STARRUBY = 7910
local AZEROTHIANDIAMOND = 12800
local BLUESAPPHIRE = 12361
local LARGEOPAL = 12799
local HUGEEMERALD = 12364
local BLOODGARNET = 23077
local FLAMESPESSARITE = 21929
local GOLDENDRAENITE = 23112
local DEEPPERIDOT = 23079
local AZUREMOONSTONE = 23117
local SHADOWDRAENITE = 23107
local LIVINGRUBY = 23436
local NOBLETOPAZ = 23439
local DAWNSTONE = 23440
local TALASITE = 23437
local STAROFELUNE = 23438
local NIGHTSEYE = 23441


--[[
	Prospectable ores
	Current percentages from http://www.wowwiki.com/Prospecting
]]

const.ProspectMinLevels = {
	[COPPER_ORE] = 20,
	[TIN_ORE] = 50,
	[IRON_ORE] = 125,
	[MITHRIL_ORE] = 175,
	[THORIUM_ORE] = 250,
	[FEL_IRON_ORE] = 275,
	[ADAMANTITE_ORE] = 325,
}

const.ProspectableItems = {

	[COPPER_ORE] = {
			[COPPERPOWDER] = 1.0,
			[TIGERSEYE] = 0.5,
			[MALACHITE] = 0.5,
			[SHADOWGEM] = 0.1,
			},
	
	[TIN_ORE] = {
			[TINPOWDER] = 1.0,
			[SHADOWGEM] = 0.375,
			[LESSERMOONSTONE] = 0.375,
			[MOSSAGATE] = 0.375,
			[CITRINE] = 0.033,
			[JADE] = 0.033,
			[AQUAMARINE] = 0.033,
			},
	
	[IRON_ORE] = {
			[IRONPOWDER] = 1.0,
			[CITRINE] = 0.30,
			[LESSERMOONSTONE] = 0.30,
			[JADE] = 0.30,
			[AQUAMARINE] = 0.05,
			[STARRUBY] = 0.05,
			},
	
	[MITHRIL_ORE] = {
			[MITHRILPOWDER] = 1.0,
			[CITRINE] = 0.30,
			[STARRUBY] = 0.30,
			[AQUAMARINE] = 0.30,
			[AZEROTHIANDIAMOND] = 0.025,
			[BLUESAPPHIRE] = 0.025,
			[LARGEOPAL] = 0.025,
			[HUGEEMERALD] = 0.025,
			},
	
	[THORIUM_ORE] = {
			[THORIUMPOWDER] = 1.0,
			[STARRUBY] = 0.30,
			[LARGEOPAL] = 0.16,
			[BLUESAPPHIRE] = 0.16,
			[AZEROTHIANDIAMOND] = 0.16,
			[HUGEEMERALD] = 0.16,
			[BLOODGARNET] = 0.0167,
			[FLAMESPESSARITE] = 0.0167,
			[GOLDENDRAENITE] = 0.0167,
			[DEEPPERIDOT] = 0.0167,
			[AZUREMOONSTONE] = 0.0167,
			[SHADOWDRAENITE] = 0.0167,
			},
	
	[FEL_IRON_ORE] = {
			[FELIRONPOWDER] = 1.0,
			[BLOODGARNET] = 0.16,
			[FLAMESPESSARITE] = 0.16,
			[GOLDENDRAENITE] = 0.16,
			[DEEPPERIDOT] = 0.16,
			[AZUREMOONSTONE] = 0.16,
			[SHADOWDRAENITE] = 0.16,
			[LIVINGRUBY] = 0.083,
			[NOBLETOPAZ] = 0.083,
			[DAWNSTONE] = 0.083,
			[TALASITE] = 0.083,
			[STAROFELUNE] = 0.083,
			[NIGHTSEYE] = 0.083,
			},
	
	[ADAMANTITE_ORE] = {
			[ADAMANTITEPOWDER] = 1.0,
			[BLOODGARNET] = 0.19,
			[FLAMESPESSARITE] = 0.19,
			[GOLDENDRAENITE] = 0.19,
			[DEEPPERIDOT] = 0.19,
			[AZUREMOONSTONE] = 0.19,
			[SHADOWDRAENITE] = 0.19,
			[LIVINGRUBY] = 0.025,
			[NOBLETOPAZ] = 0.025,
			[DAWNSTONE] = 0.025,
			[TALASITE] = 0.025,
			[STAROFELUNE] = 0.025,
			[NIGHTSEYE] = 0.025,
			},
}

-- reagents that have no use, sell to vendor, and thus get vendor prices
const.VendorTrash =  {
	[COPPERPOWDER] = true,
	[TINPOWDER] = true,
	[IRONPOWDER] = true,
	[MITHRILPOWDER] = true,
	[THORIUMPOWDER] = true,
	[FELIRONPOWDER] = true,
}


-- needed because GetItemInfo fails when items are not in the cache
-- TODO - ccox - find a more compact representation for this table
-- 		serialization?  lots of separators we can't use here... how about "#@$!"?
const.BackupReagentItemInfo = {
	[10939] = {
		"Greater Magic Essence", -- [1]
		"|cff1eff00|Hitem:10939:0:0:0:0:0:0:0|h[Greater Magic Essence]|h|r", -- [2]
		2, -- [3]
		15, -- [4]
		0, -- [5]
		"Trade Goods", -- [6]
		"Trade Goods", -- [7]
		10, -- [8]
		"", -- [9]
		"Interface\\Icons\\INV_Enchant_EssenceMagicLarge", -- [10]
	},
	[10978] = {
		"Small Glimmering Shard", -- [1]
		"|cff0070dd|Hitem:10978:0:0:0:0:0:0:0|h[Small Glimmering Shard]|h|r", -- [2]
		3, -- [3]
		20, -- [4]
		0, -- [5]
		"Trade Goods", -- [6]
		"Trade Goods", -- [7]
		20, -- [8]
		"", -- [9]
		"Interface\\Icons\\INV_Enchant_ShardGlimmeringSmall", -- [10]
	},
	[16202] = {
		"Lesser Eternal Essence", -- [1]
		"|cff1eff00|Hitem:16202:0:0:0:0:0:0:0|h[Lesser Eternal Essence]|h|r", -- [2]
		2, -- [3]
		50, -- [4]
		0, -- [5]
		"Trade Goods", -- [6]
		"Trade Goods", -- [7]
		10, -- [8]
		"", -- [9]
		"Interface\\Icons\\INV_Enchant_EssenceEternalSmall", -- [10]
	},
	[10940] = {
		"Strange Dust", -- [1]
		"|cffffffff|Hitem:10940:0:0:0:0:0:0:0|h[Strange Dust]|h|r", -- [2]
		1, -- [3]
		10, -- [4]
		0, -- [5]
		"Trade Goods", -- [6]
		"Trade Goods", -- [7]
		20, -- [8]
		"", -- [9]
		"Interface\\Icons\\INV_Enchant_DustStrange", -- [10]
	},
	[11134] = {
		"Lesser Mystic Essence", -- [1]
		"|cff1eff00|Hitem:11134:0:0:0:0:0:0:0|h[Lesser Mystic Essence]|h|r", -- [2]
		2, -- [3]
		30, -- [4]
		0, -- [5]
		"Trade Goods", -- [6]
		"Trade Goods", -- [7]
		10, -- [8]
		"", -- [9]
		"Interface\\Icons\\INV_Enchant_EssenceMysticalSmall", -- [10]
	},
	[14343] = {
		"Small Brilliant Shard", -- [1]
		"|cff0070dd|Hitem:14343:0:0:0:0:0:0:0|h[Small Brilliant Shard]|h|r", -- [2]
		3, -- [3]
		50, -- [4]
		0, -- [5]
		"Trade Goods", -- [6]
		"Trade Goods", -- [7]
		20, -- [8]
		"", -- [9]
		"Interface\\Icons\\INV_Enchant_ShardBrilliantSmall", -- [10]
	},
	[16203] = {
		"Greater Eternal Essence", -- [1]
		"|cff1eff00|Hitem:16203:0:0:0:0:0:0:0|h[Greater Eternal Essence]|h|r", -- [2]
		2, -- [3]
		55, -- [4]
		0, -- [5]
		"Trade Goods", -- [6]
		"Trade Goods", -- [7]
		10, -- [8]
		"", -- [9]
		"Interface\\Icons\\INV_Enchant_EssenceEternalLarge", -- [10]
	},
	[11135] = {
		"Greater Mystic Essence", -- [1]
		"|cff1eff00|Hitem:11135:0:0:0:0:0:0:0|h[Greater Mystic Essence]|h|r", -- [2]
		2, -- [3]
		35, -- [4]
		0, -- [5]
		"Trade Goods", -- [6]
		"Trade Goods", -- [7]
		10, -- [8]
		"", -- [9]
		"Interface\\Icons\\INV_Enchant_EssenceMysticalLarge", -- [10]
	},
	[11174] = {
		"Lesser Nether Essence", -- [1]
		"|cff1eff00|Hitem:11174:0:0:0:0:0:0:0|h[Lesser Nether Essence]|h|r", -- [2]
		2, -- [3]
		40, -- [4]
		0, -- [5]
		"Trade Goods", -- [6]
		"Trade Goods", -- [7]
		10, -- [8]
		"", -- [9]
		"Interface\\Icons\\INV_Enchant_EssenceNetherSmall", -- [10]
	},
	[14344] = {
		"Large Brilliant Shard", -- [1]
		"|cff0070dd|Hitem:14344:0:0:0:0:0:0:0|h[Large Brilliant Shard]|h|r", -- [2]
		3, -- [3]
		55, -- [4]
		0, -- [5]
		"Trade Goods", -- [6]
		"Trade Goods", -- [7]
		20, -- [8]
		"", -- [9]
		"Interface\\Icons\\INV_Enchant_ShardBrilliantLarge", -- [10]
	},
	[11082] = {
		"Greater Astral Essence", -- [1]
		"|cff1eff00|Hitem:11082:0:0:0:0:0:0:0|h[Greater Astral Essence]|h|r", -- [2]
		2, -- [3]
		25, -- [4]
		0, -- [5]
		"Trade Goods", -- [6]
		"Trade Goods", -- [7]
		10, -- [8]
		"", -- [9]
		"Interface\\Icons\\INV_Enchant_EssenceAstralLarge", -- [10]
	},
	[10998] = {
		"Lesser Astral Essence", -- [1]
		"|cff1eff00|Hitem:10998:0:0:0:0:0:0:0|h[Lesser Astral Essence]|h|r", -- [2]
		2, -- [3]
		20, -- [4]
		0, -- [5]
		"Trade Goods", -- [6]
		"Trade Goods", -- [7]
		10, -- [8]
		"", -- [9]
		"Interface\\Icons\\INV_Enchant_EssenceAstralSmall", -- [10]
	},
	[11175] = {
		"Greater Nether Essence", -- [1]
		"|cff1eff00|Hitem:11175:0:0:0:0:0:0:0|h[Greater Nether Essence]|h|r", -- [2]
		2, -- [3]
		45, -- [4]
		0, -- [5]
		"Trade Goods", -- [6]
		"Trade Goods", -- [7]
		10, -- [8]
		"", -- [9]
		"Interface\\Icons\\INV_Enchant_EssenceNetherLarge", -- [10]
	},
	[11084] = {
		"Large Glimmering Shard", -- [1]
		"|cff0070dd|Hitem:11084:0:0:0:0:0:0:0|h[Large Glimmering Shard]|h|r", -- [2]
		3, -- [3]
		25, -- [4]
		0, -- [5]
		"Trade Goods", -- [6]
		"Trade Goods", -- [7]
		20, -- [8]
		"", -- [9]
		"Interface\\Icons\\INV_Enchant_ShardGlimmeringLarge", -- [10]
	},
	[22450] = {
		"Void Crystal", -- [1]
		"|cffa335ee|Hitem:22450:0:0:0:0:0:0:0|h[Void Crystal]|h|r", -- [2]
		4, -- [3]
		70, -- [4]
		0, -- [5]
		"Trade Goods", -- [6]
		"Trade Goods", -- [7]
		20, -- [8]
		"", -- [9]
		"Interface\\Icons\\INV_Enchant_VoidCrystal", -- [10]
	},
	[22445] = {
		"Arcane Dust", -- [1]
		"|cffffffff|Hitem:22445:0:0:0:0:0:0:0|h[Arcane Dust]|h|r", -- [2]
		1, -- [3]
		60, -- [4]
		0, -- [5]
		"Trade Goods", -- [6]
		"Trade Goods", -- [7]
		20, -- [8]
		"", -- [9]
		"Interface\\Icons\\INV_Enchant_DustArcane", -- [10]
	},
	[11176] = {
		"Dream Dust", -- [1]
		"|cffffffff|Hitem:11176:0:0:0:0:0:0:0|h[Dream Dust]|h|r", -- [2]
		1, -- [3]
		45, -- [4]
		0, -- [5]
		"Trade Goods", -- [6]
		"Trade Goods", -- [7]
		20, -- [8]
		"", -- [9]
		"Interface\\Icons\\INV_Enchant_DustDream", -- [10]
	},
	[22446] = {
		"Greater Planar Essence", -- [1]
		"|cff1eff00|Hitem:22446:0:0:0:0:0:0:0|h[Greater Planar Essence]|h|r", -- [2]
		2, -- [3]
		65, -- [4]
		0, -- [5]
		"Trade Goods", -- [6]
		"Trade Goods", -- [7]
		10, -- [8]
		"", -- [9]
		"Interface\\Icons\\INV_Enchant_EssenceArcaneLarge", -- [10]
	},
	[11138] = {
		"Small Glowing Shard", -- [1]
		"|cff0070dd|Hitem:11138:0:0:0:0:0:0:0|h[Small Glowing Shard]|h|r", -- [2]
		3, -- [3]
		30, -- [4]
		0, -- [5]
		"Trade Goods", -- [6]
		"Trade Goods", -- [7]
		20, -- [8]
		"", -- [9]
		"Interface\\Icons\\INV_Enchant_ShardGlowingSmall", -- [10]
	},
	[22447] = {
		"Lesser Planar Essence", -- [1]
		"|cff1eff00|Hitem:22447:0:0:0:0:0:0:0|h[Lesser Planar Essence]|h|r", -- [2]
		2, -- [3]
		60, -- [4]
		0, -- [5]
		"Trade Goods", -- [6]
		"Trade Goods", -- [7]
		10, -- [8]
		"", -- [9]
		"Interface\\Icons\\INV_Enchant_EssenceArcaneSmall", -- [10]
	},
	[11177] = {
		"Small Radiant Shard", -- [1]
		"|cff0070dd|Hitem:11177:0:0:0:0:0:0:0|h[Small Radiant Shard]|h|r", -- [2]
		3, -- [3]
		40, -- [4]
		0, -- [5]
		"Trade Goods", -- [6]
		"Trade Goods", -- [7]
		20, -- [8]
		"", -- [9]
		"Interface\\Icons\\INV_Enchant_ShardRadientSmall", -- [10]
	},
	[22448] = {
		"Small Prismatic Shard", -- [1]
		"|cff0070dd|Hitem:22448:0:0:0:0:0:0:0|h[Small Prismatic Shard]|h|r", -- [2]
		3, -- [3]
		65, -- [4]
		0, -- [5]
		"Trade Goods", -- [6]
		"Trade Goods", -- [7]
		20, -- [8]
		"", -- [9]
		"Interface\\Icons\\INV_Enchant_ShardPrismaticSmall", -- [10]
	},
	[11139] = {
		"Large Glowing Shard", -- [1]
		"|cff0070dd|Hitem:11139:0:0:0:0:0:0:0|h[Large Glowing Shard]|h|r", -- [2]
		3, -- [3]
		35, -- [4]
		0, -- [5]
		"Trade Goods", -- [6]
		"Trade Goods", -- [7]
		20, -- [8]
		"", -- [9]
		"Interface\\Icons\\INV_Enchant_ShardGlowingLarge", -- [10]
	},
	[22449] = {
		"Large Prismatic Shard", -- [1]
		"|cff0070dd|Hitem:22449:0:0:0:0:0:0:0|h[Large Prismatic Shard]|h|r", -- [2]
		3, -- [3]
		70, -- [4]
		0, -- [5]
		"Trade Goods", -- [6]
		"Trade Goods", -- [7]
		20, -- [8]
		"", -- [9]
		"Interface\\Icons\\INV_Enchant_ShardPrismaticLarge", -- [10]
	},
	[11178] = {
		"Large Radiant Shard", -- [1]
		"|cff0070dd|Hitem:11178:0:0:0:0:0:0:0|h[Large Radiant Shard]|h|r", -- [2]
		3, -- [3]
		45, -- [4]
		0, -- [5]
		"Trade Goods", -- [6]
		"Trade Goods", -- [7]
		20, -- [8]
		"", -- [9]
		"Interface\\Icons\\INV_Enchant_ShardRadientLarge", -- [10]
	},
	[10938] = {
		"Lesser Magic Essence", -- [1]
		"|cff1eff00|Hitem:10938:0:0:0:0:0:0:0|h[Lesser Magic Essence]|h|r", -- [2]
		2, -- [3]
		10, -- [4]
		0, -- [5]
		"Trade Goods", -- [6]
		"Trade Goods", -- [7]
		10, -- [8]
		"", -- [9]
		"Interface\\Icons\\INV_Enchant_EssenceMagicSmall", -- [10]
	},
	[11083] = {
		"Soul Dust", -- [1]
		"|cffffffff|Hitem:11083:0:0:0:0:0:0:0|h[Soul Dust]|h|r", -- [2]
		1, -- [3]
		25, -- [4]
		0, -- [5]
		"Trade Goods", -- [6]
		"Trade Goods", -- [7]
		20, -- [8]
		"", -- [9]
		"Interface\\Icons\\INV_Enchant_DustSoul", -- [10]
	},
	[11137] = {
		"Vision Dust", -- [1]
		"|cffffffff|Hitem:11137:0:0:0:0:0:0:0|h[Vision Dust]|h|r", -- [2]
		1, -- [3]
		35, -- [4]
		0, -- [5]
		"Trade Goods", -- [6]
		"Trade Goods", -- [7]
		20, -- [8]
		"", -- [9]
		"Interface\\Icons\\INV_Enchant_DustVision", -- [10]
	},
	[20725] = {
		"Nexus Crystal", -- [1]
		"|cffa335ee|Hitem:20725:0:0:0:0:0:0:0|h[Nexus Crystal]|h|r", -- [2]
		4, -- [3]
		60, -- [4]
		0, -- [5]
		"Trade Goods", -- [6]
		"Trade Goods", -- [7]
		20, -- [8]
		"", -- [9]
		"Interface\\Icons\\INV_Enchant_ShardNexusLarge", -- [10]
	},
	[16204] = {
		"Illusion Dust", -- [1]
		"|cffffffff|Hitem:16204:0:0:0:0:0:0:0|h[Illusion Dust]|h|r", -- [2]
		1, -- [3]
		55, -- [4]
		0, -- [5]
		"Trade Goods", -- [6]
		"Trade Goods", -- [7]
		20, -- [8]
		"", -- [9]
		"Interface\\Icons\\INV_Enchant_DustIllusion", -- [10]
	},
	[12799] = {
		"Large Opal", -- [1]
		"|cff1eff00|Hitem:12799:0:0:0:0:0:0:0|h[Large Opal]|h|r", -- [2]
		2, -- [3]
		55, -- [4]
		0, -- [5]
		"Gem", -- [6]
		"Simple", -- [7]
		20, -- [8]
		"", -- [9]
		"Interface\\Icons\\INV_Misc_Gem_Opal_01", -- [10]
	},
	[1210] = {
		"Shadowgem", -- [1]
		"|cff1eff00|Hitem:1210:0:0:0:0:0:0:0|h[Shadowgem]|h|r", -- [2]
		2, -- [3]
		20, -- [4]
		0, -- [5]
		"Gem", -- [6]
		"Simple", -- [7]
		20, -- [8]
		"", -- [9]
		"Interface\\Icons\\INV_Misc_Gem_Amethyst_01", -- [10]
	},
	[3864] = {
		"Citrine", -- [1]
		"|cff1eff00|Hitem:3864:0:0:0:0:0:0:0|h[Citrine]|h|r", -- [2]
		2, -- [3]
		40, -- [4]
		0, -- [5]
		"Gem", -- [6]
		"Simple", -- [7]
		20, -- [8]
		"", -- [9]
		"Interface\\Icons\\INV_Misc_Gem_Opal_02", -- [10]
	},
	[1206] = {
		"Moss Agate", -- [1]
		"|cff1eff00|Hitem:1206:0:0:0:0:0:0:0|h[Moss Agate]|h|r", -- [2]
		2, -- [3]
		25, -- [4]
		0, -- [5]
		"Trade Goods", -- [6]
		"Trade Goods", -- [7]
		20, -- [8]
		"", -- [9]
		"Interface\\Icons\\INV_Misc_Gem_Emerald_02", -- [10]
	},
	[818] = {
		"Tigerseye", -- [1]
		"|cff1eff00|Hitem:818:0:0:0:0:0:0:0|h[Tigerseye]|h|r", -- [2]
		2, -- [3]
		15, -- [4]
		0, -- [5]
		"Gem", -- [6]
		"Simple", -- [7]
		20, -- [8]
		"", -- [9]
		"Interface\\Icons\\INV_Misc_Gem_Opal_03", -- [10]
	},
	[24243] = {
		"Adamantite Powder", -- [1]
		"|cffffffff|Hitem:24243:0:0:0:0:0:0:0|h[Adamantite Powder]|h|r", -- [2]
		1, -- [3]
		70, -- [4]
		0, -- [5]
		"Trade Goods", -- [6]
		"Trade Goods", -- [7]
		20, -- [8]
		"", -- [9]
		"Interface\\Icons\\INV_Misc_Powder_Adamantite", -- [10]
	},
	[7909] = {
		"Aquamarine", -- [1]
		"|cff1eff00|Hitem:7909:0:0:0:0:0:0:0|h[Aquamarine]|h|r", -- [2]
		2, -- [3]
		45, -- [4]
		0, -- [5]
		"Gem", -- [6]
		"Simple", -- [7]
		20, -- [8]
		"", -- [9]
		"Interface\\Icons\\INV_Misc_Gem_Crystal_02", -- [10]
	},
	[1529] = {
		"Jade", -- [1]
		"|cff1eff00|Hitem:1529:0:0:0:0:0:0:0|h[Jade]|h|r", -- [2]
		2, -- [3]
		35, -- [4]
		0, -- [5]
		"Gem", -- [6]
		"Simple", -- [7]
		20, -- [8]
		"", -- [9]
		"Interface\\Icons\\INV_Misc_Gem_Stone_01", -- [10]
	},
	[23112] = {
		"Golden Draenite", -- [1]
		"|cff1eff00|Hitem:23112:0:0:0:0:0:0:0|h[Golden Draenite]|h|r", -- [2]
		2, -- [3]
		65, -- [4]
		0, -- [5]
		"Gem", -- [6]
		"Yellow", -- [7]
		20, -- [8]
		"", -- [9]
		"Interface\\Icons\\INV_Misc_Gem_GoldenDraenite_03", -- [10]
	},
	[23079] = {
		"Deep Peridot", -- [1]
		"|cff1eff00|Hitem:23079:0:0:0:0:0:0:0|h[Deep Peridot]|h|r", -- [2]
		2, -- [3]
		65, -- [4]
		0, -- [5]
		"Gem", -- [6]
		"Green", -- [7]
		20, -- [8]
		"", -- [9]
		"Interface\\Icons\\INV_Misc_Gem_DeepPeridot_03", -- [10]
	},
	[23441] = {
		"Nightseye", -- [1]
		"|cff0070dd|Hitem:23441:0:0:0:0:0:0:0|h[Nightseye]|h|r", -- [2]
		3, -- [3]
		70, -- [4]
		0, -- [5]
		"Gem", -- [6]
		"Purple", -- [7]
		20, -- [8]
		"", -- [9]
		"Interface\\Icons\\INV_Jewelcrafting_Nightseye_02", -- [10]
	},
	[24186] = {
		"Copper Powder", -- [1]
		"|cff9d9d9d|Hitem:24186:0:0:0:0:0:0:0|h[Copper Powder]|h|r", -- [2]
		0, -- [3]
		10, -- [4]
		0, -- [5]
		"Trade Goods", -- [6]
		"Trade Goods", -- [7]
		20, -- [8]
		"", -- [9]
		"Interface\\Icons\\INV_Misc_Powder_Copper", -- [10]
	},
	[23117] = {
		"Azure Moonstone", -- [1]
		"|cff1eff00|Hitem:23117:0:0:0:0:0:0:0|h[Azure Moonstone]|h|r", -- [2]
		2, -- [3]
		65, -- [4]
		0, -- [5]
		"Gem", -- [6]
		"Blue", -- [7]
		20, -- [8]
		"", -- [9]
		"Interface\\Icons\\INV_Misc_Gem_AzureDraenite_03", -- [10]
	},
	[24188] = {
		"Tin Powder", -- [1]
		"|cff9d9d9d|Hitem:24188:0:0:0:0:0:0:0|h[Tin Powder]|h|r", -- [2]
		0, -- [3]
		10, -- [4]
		0, -- [5]
		"Trade Goods", -- [6]
		"Trade Goods", -- [7]
		20, -- [8]
		"", -- [9]
		"Interface\\Icons\\INV_Misc_Powder_Tin", -- [10]
	},
	[1705] = {
		"Lesser Moonstone", -- [1]
		"|cff1eff00|Hitem:1705:0:0:0:0:0:0:0|h[Lesser Moonstone]|h|r", -- [2]
		2, -- [3]
		30, -- [4]
		0, -- [5]
		"Gem", -- [6]
		"Simple", -- [7]
		20, -- [8]
		"", -- [9]
		"Interface\\Icons\\INV_Misc_Gem_Crystal_01", -- [10]
	},
	[23077] = {
		"Blood Garnet", -- [1]
		"|cff1eff00|Hitem:23077:0:0:0:0:0:0:0|h[Blood Garnet]|h|r", -- [2]
		2, -- [3]
		65, -- [4]
		0, -- [5]
		"Gem", -- [6]
		"Red", -- [7]
		20, -- [8]
		"", -- [9]
		"Interface\\Icons\\INV_Misc_Gem_BloodGem_03", -- [10]
	},
	[23436] = {
		"Living Ruby", -- [1]
		"|cff0070dd|Hitem:23436:0:0:0:0:0:0:0|h[Living Ruby]|h|r", -- [2]
		3, -- [3]
		70, -- [4]
		0, -- [5]
		"Gem", -- [6]
		"Red", -- [7]
		20, -- [8]
		"", -- [9]
		"Interface\\Icons\\INV_Jewelcrafting_LivingRuby_02", -- [10]
	},
	[23437] = {
		"Talasite", -- [1]
		"|cff0070dd|Hitem:23437:0:0:0:0:0:0:0|h[Talasite]|h|r", -- [2]
		3, -- [3]
		70, -- [4]
		0, -- [5]
		"Gem", -- [6]
		"Green", -- [7]
		20, -- [8]
		"", -- [9]
		"Interface\\Icons\\INV_Jewelcrafting_Talasite_02", -- [10]
	},
	[23438] = {
		"Star of Elune", -- [1]
		"|cff0070dd|Hitem:23438:0:0:0:0:0:0:0|h[Star of Elune]|h|r", -- [2]
		3, -- [3]
		70, -- [4]
		0, -- [5]
		"Gem", -- [6]
		"Blue", -- [7]
		20, -- [8]
		"", -- [9]
		"Interface\\Icons\\INV_Jewelcrafting_StarOfElune_02", -- [10]
	},
	[23439] = {
		"Noble Topaz", -- [1]
		"|cff0070dd|Hitem:23439:0:0:0:0:0:0:0|h[Noble Topaz]|h|r", -- [2]
		3, -- [3]
		70, -- [4]
		0, -- [5]
		"Gem", -- [6]
		"Orange", -- [7]
		20, -- [8]
		"", -- [9]
		"Interface\\Icons\\INV_Jewelcrafting_NobleTopaz_02", -- [10]
	},
	[23440] = {
		"Dawnstone", -- [1]
		"|cff0070dd|Hitem:23440:0:0:0:0:0:0:0|h[Dawnstone]|h|r", -- [2]
		3, -- [3]
		70, -- [4]
		0, -- [5]
		"Gem", -- [6]
		"Yellow", -- [7]
		20, -- [8]
		"", -- [9]
		"Interface\\Icons\\INV_Jewelcrafting_Dawnstone_02", -- [10]
	},
	[21929] = {
		"Flame Spessarite", -- [1]
		"|cff1eff00|Hitem:21929:0:0:0:0:0:0:0|h[Flame Spessarite]|h|r", -- [2]
		2, -- [3]
		65, -- [4]
		0, -- [5]
		"Gem", -- [6]
		"Orange", -- [7]
		20, -- [8]
		"", -- [9]
		"Interface\\Icons\\INV_Misc_Gem_FlameSpessarite_03", -- [10]
	},
	[23107] = {
		"Shadow Draenite", -- [1]
		"|cff1eff00|Hitem:23107:0:0:0:0:0:0:0|h[Shadow Draenite]|h|r", -- [2]
		2, -- [3]
		65, -- [4]
		0, -- [5]
		"Gem", -- [6]
		"Purple", -- [7]
		20, -- [8]
		"", -- [9]
		"Interface\\Icons\\INV_Misc_Gem_EbonDraenite_03", -- [10]
	},
	[774] = {
		"Malachite", -- [1]
		"|cff1eff00|Hitem:774:0:0:0:0:0:0:0|h[Malachite]|h|r", -- [2]
		2, -- [3]
		7, -- [4]
		0, -- [5]
		"Gem", -- [6]
		"Simple", -- [7]
		20, -- [8]
		"", -- [9]
		"Interface\\Icons\\INV_Misc_Gem_Emerald_03", -- [10]
	},
	[7910] = {
		"Star Ruby", -- [1]
		"|cff1eff00|Hitem:7910:0:0:0:0:0:0:0|h[Star Ruby]|h|r", -- [2]
		2, -- [3]
		50, -- [4]
		0, -- [5]
		"Gem", -- [6]
		"Simple", -- [7]
		20, -- [8]
		"", -- [9]
		"Interface\\Icons\\INV_Misc_Gem_Ruby_02", -- [10]
	},
	[12361] = {
		"Blue Sapphire", -- [1]
		"|cff1eff00|Hitem:12361:0:0:0:0:0:0:0|h[Blue Sapphire]|h|r", -- [2]
		2, -- [3]
		55, -- [4]
		0, -- [5]
		"Gem", -- [6]
		"Simple", -- [7]
		20, -- [8]
		"", -- [9]
		"Interface\\Icons\\INV_Misc_Gem_Sapphire_02", -- [10]
	},
	[12364] = {
		"Huge Emerald", -- [1]
		"|cff1eff00|Hitem:12364:0:0:0:0:0:0:0|h[Huge Emerald]|h|r", -- [2]
		2, -- [3]
		60, -- [4]
		0, -- [5]
		"Gem", -- [6]
		"Simple", -- [7]
		20, -- [8]
		"", -- [9]
		"Interface\\Icons\\INV_Misc_Gem_Emerald_01", -- [10]
	},
	[12800] = {
		"Azerothian Diamond", -- [1]
		"|cff1eff00|Hitem:12800:0:0:0:0:0:0:0|h[Azerothian Diamond]|h|r", -- [2]
		2, -- [3]
		60, -- [4]
		0, -- [5]
		"Gem", -- [6]
		"Simple", -- [7]
		20, -- [8]
		"", -- [9]
		"Interface\\Icons\\INV_Misc_Gem_Diamond_01", -- [10]
	},
}
