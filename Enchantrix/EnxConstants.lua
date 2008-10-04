--[[
	Enchantrix Addon for World of Warcraft(tm).
	Version: <%version%> (<%codename%>)
	Revision: $Id$
	URL: http://enchantrix.org/

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
-- Median prices from Allakhazam.com, December 4, 2007 - Updated by testleK
-- Prices are in copper aka GGSSCC
const.StaticPrices = {
	[22450] = 246666, -- Void Crystal
	[20725] =  95000, -- Nexus Crystal

	[22449] = 249999, -- Large Prismatic Shard
	[14344] =  95000, -- Large Brilliant Shard
	[11178] =  80000, -- Large Radiant Shard
	[11139] =  17500, -- Large Glowing Shard
	[11084] =   9000, -- Large Glimmering Shard

	[22448] =  84900, -- Small Prismatic Shard
	[14343] =  39600, -- Small Brilliant Shard
	[11177] =  75000, -- Small Radiant Shard
	[11138] =   5000, -- Small Glowing Shard
	[10978] =   3846, -- Small Glimmering Shard

	[22446] =  75850, -- Greater Planar Essence
	[16203] = 119999, -- Greater Eternal Essence
	[11175] =  65000, -- Greater Nether Essence
	[11135] =   8990, -- Greater Mystic Essence
	[11082] =   7887, -- Greater Astral Essence
	[10939] =   6550, -- Greater Magic Essence

	[22447] =  21366, -- Lesser Planar Essence
	[16202] =  45411, -- Lesser Eternal Essence
	[11174] =  23750, -- Lesser Nether Essence
	[11134] =   4183, -- Lesser Mystic Essence
	[10998] =   3500, -- Lesser Astral Essence
	[10938] =   3020, -- Lesser Magic Essence

	[22445] =  19000, -- Arcane Dust
	[16204] =  27500, -- Illusion Dust
	[11176] =   7500, -- Dream Dust
	[11137] =   6000, -- Vision Dust
	[11083] =   3370, -- Soul Dust
	[10940] =   1600, -- Strange Dust

	[2772] =    3500, -- Iron Ore
	[3356] =     250, -- Kingsblood
	[3371] =     110, -- Empty Vial
	[3372] =     187, -- Leaded Vial
	[3819] =    5000, -- Wintersbite
	[3829] =   32500, -- Frost Oil
	[4470] =     436, -- Simple Wood
	[4625] =    3000, -- Firebloom
	[5500] =   42000, -- Iridescent Pearl
	[5637] =    7610, -- Large Fang
	[6037] =   10000, -- Truesilver Bar
	[6048] =    5999, -- Shadow Protection Potion
	[6217] =   11100, -- Copper Rod
	[6370] =    4940, -- Blackmouth Oil
	[6371] =    5000, -- Fire Oil
	[7067] =   12344, -- Elemental Earth
	[7075] =   79600, -- Core of Earth
	[7077] =   55555, -- Heart of Fire
	[7078] =   10000, -- Essence of Fire
	[7079] =   14406, -- Globe of Water
	[7080] =   25000, -- Essence of Water
	[7081] =   90000, -- Breath of Wind
	[7082] =   11000, -- Essence of Air
	[7392] =    2880, -- Green Whelp Scale
	[7909] =   28000, -- Aquamarine
	[7971] =   26666, -- Black Pearl
	[7972] =    3000, -- Ichor of Undeath
	[8153] =   14190, -- Wildvine
	[8170] =    4625, -- Rugged Leather
	[8831] =    5000, -- Purple Lotus
	[8838] =    5325, -- Sungrass
	[8925] =     500, -- Crystal Vial
	[9224] =   35900, -- Elixir of Demonslaying
	[11128] =  32944, -- Golden Rod
	[11144] =  44500, -- Truesilver Rod
	[11291] =   4500, -- Star Wood
	[11382] = 186900, -- Blood of the Mountain
	[11754] =   3600, -- Black Diamond
	[12359] =  12000, -- Thorium Bar
	[12803] =  20000, -- Living Essence
	[12808] =  60000, -- Essence of Undeath
	[12809] =  50000, -- Guardian Stone
	[12811] = 430000, -- Righteous Orb
	[13444] =  11199, -- Major Mana Potion
	[13446] =  12400, -- Major Healing Potion
	[13467] =   7000, -- Icecap
	[13468] =  95000, -- Black Lotus
	[13926] =  17500, -- Golden Pearl
	[16206] = 550000, -- Arcanite Rod
	[17034] =    650, -- Maple Seed
	[17035] =    676, -- Stranglethorn Seed
	[18256] =   5821, -- Imbued Vial
	[18512] =  17332, -- Larval Acid
	[21884] = 250000, -- Primal Fire
	[21885] = 200000, -- Primal Water
	[21886] = 133333, -- Primal Life
	[22451] = 250000, -- Primal Air
	[22452] =  40000, -- Primal Earth
	[22456] = 180450, -- Primal Shadow
	[22457] = 196000, -- Primal Mana
	[22791] =  15891, -- Netherbloom
	[22792] =  18995, -- Nightmare Vine
	[25843] = 188500, -- Fel Iron Rod
	[25844] = 250000, -- Adamantite Rod
	[25845] = 369397, -- Eternium Rod

	[24186] =     50, 	-- COPPERPOWDER, vendor
	[24188] =    125, 	-- TINPOWDER, vendor
	[24190] =    400, 	-- IRONPOWDER, vendor
	[24234] =    500, 	-- MITHRILPOWDER, vendor
	[24235] =    800, 	-- THORIUMPOWDER, vendor
	[24242] =   1500, 	-- FELIRONPOWDER, vendor
	[24243] =   4750, 	-- ADAMANTITEPOWDER, auction

	[818] =     3500, 	-- TIGERSEYE
	[774] =     2500, 	-- MALACHITE
	[1210] =    6153,	-- SHADOWGEM
	[1705] =   12500, 	-- LESSERMOONSTONE
	[1206] =   16377, 	-- MOSSAGATE
	[3864] =   10000, 	-- CITRINE
	[1529] =   20000, 	-- JADE
	[7909] =   28000, 	-- AQUAMARINE
	[7910] =   24545, 	-- STARRUBY
	[12800] =  94500, 	-- AZEROTHIANDIAMOND
	[12361] =  46549, 	-- BLUESAPPHIRE
	[12799] =  48220, 	-- LARGEOPAL
	[12364] =  87500, 	-- HUGEEMERALD
	[23077] =   9850, 	-- BLOODGARNET
	[21929] =   6250, 	-- FLAMESPESSARITE
	[23112] =   9500, 	-- GOLDENDRAENITE
	[23079] =   7500, 	-- DEEPPERIDOT
	[23117] =   7500, 	-- AZUREMOONSTONE
	[23107] =   8000, 	-- SHADOWDRAENITE
	[23436] = 500000,	-- LIVINGRUBY
	[23439] = 439900, 	-- NOBLETOPAZ
	[23440] = 349999, 	-- DAWNSTONE
	[23437] = 157900, 	-- TALASITE
	[23438] = 450000, 	-- STAROFELUNE
	[23441] = 420000, 	-- NIGHTSEYE

-- ccox - WOTLK items - fake prices for now
	[39151] =   100,	-- ALABASTER_PIGMENT
	[39334] =   200,	-- DUSKY_PIGMENT
	[39338] =   400,	-- GOLDEN_PIGMENT
	[39339] =   800,	-- EMERALD_PIGMENT
	[39340] =  1000,	-- VIOLET_PIGMENT
	[39341] =  2000, 	-- SILVERY_PIGMENT
	[43103] =  4000,	-- VERDANT_PIGMENT
	[43104] =  8000,	-- BURNT_PIGMENT
	[43105] = 10000,	-- INDIGO_PIGMENT
	[43106] = 20000,	-- RUBY_PIGMENT
	[43107] = 20000, 	-- SAPPHIRE_PIGMENT
	[39342] = 10000, 	-- NETHER_PIGMENT
	[43108] = 20000, 	-- EBON_PIGMENT
	[39343] = 20000, 	-- AZURE_PIGMENT
	[43109] = 40000, 	-- ICY_PIGMENT
	
	[43557] = 80000, 	-- POISONOUSIVYBERRIES
	[43558] = 80000,	-- NIGHTBLOOMLILAC
	[43559] = 80000,	-- LOCUSTWING
	[43560] = 80000,	-- FIREFLYDUST
	[43561] = 80000,	-- IRIDESCENTPOLLEN
	[43562] = 80000,	-- NIGHTMAREBERRIES
	[43563] = 80000,	-- FROZENBEETLEHUSK
	
	[34052] = 250000, 	-- Dream Shard
	[34053] =  90000, 	-- Small Dream Shard
	[34054] =  20000, 	-- Infinite Dust
	[34055] =  80000, 	-- Greater Cosmic Essence
	[34056] =  25000, 	-- Lesser Cosmic Essence
	[34057] = 900000, 	-- Abyss Crystal
	
	[41741] = 800000, 	-- Cobalt Rod
	[41745] = 800000, 	-- Titanium Rod
	
	[35622] = 200000, 	-- Eternal Water
	[35623] = 200000, 	-- Eternal Air
	[35624] = 200000, 	-- Eternal Earth
	[35625] = 200000, 	-- Eternal Life
	[35627] = 200000, 	-- Eternal Shadow
	[36860] = 200000, 	-- Eternal Fire
	
	[36923] = 200000, 	-- Chalcedony
	[36929] = 200000, 	-- Huge Citrine
	[36917] = 200000, 	-- Bloodstone
	[36926] = 200000, 	-- Shadow Crystal
	[36920] = 200000, 	-- Sun Crystal
	[36932] = 200000, 	-- Dark Jade
	
	[36933] = 800000, 	-- Forest Emerald
	[36918] = 800000, 	-- Scarlet Ruby
	[36927] = 800000, 	-- Twilight Opal
	[36930] = 800000, 	-- Monarch Topaz
	[36924] = 800000, 	-- Sky Sapphire
	[36921] = 800000, 	-- Autumn's Glow
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

local DREAM = 34052
local SDREAM = 34053
local INFINITE = 34054
local GCOSMIC = 34055
local LCOSMIC = 34056
local ABYSS = 34057


-- and in a form we can iterate over, with a fixed order for the UI

const.DisenchantReagentList = {

	34057, -- Abyss Crystal
	22450, -- Void Crystal
	20725, -- Nexus Crystal

	34052, -- Dream Shard
	22449, -- Large Prismatic Shard
	14344, -- Large Brilliant Shard
	11178, -- Large Radiant Shard
	11139, -- Large Glowing Shard
	11084, -- Large Glimmering Shard

	34053, -- Small Dream Shard
	22448, -- Small Prismatic Shard
	14343, -- Small Brilliant Shard
	11177, -- Small Radiant Shard
	11138, -- Small Glowing Shard
	10978, -- Small Glimmering Shard

	34055, -- Greater Cosmic Essence
	22446, -- Greater Planar Essence
	16203, -- Greater Eternal Essence
	11175, -- Greater Nether Essence
	11135, -- Greater Mystic Essence
	11082, -- Greater Astral Essence
	10939, -- Greater Magic Essence

	34056, -- Lesser Cosmic Essence
	22447, -- Lesser Planar Essence
	16202, -- Lesser Eternal Essence
	11174, -- Lesser Nether Essence
	11134, -- Lesser Mystic Essence
	10998, -- Lesser Astral Essence
	10938, -- Lesser Magic Essence

	34054, -- Infinite Dust
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
const.levelUpperBounds = { 15, 20, 25, 30, 35, 40, 45, 50, 55, 60, 65, 70, 79, 85, 94, 99, 115, 120, 151, 164, 200, 220 }


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
   [115] = { { ARCANE  , 0.20, 3.5 }, { GPLANAR , 0.75, 1.5 }, { LPRISMATIC , 0.05, 1.0 }, },
   [120] = { { ARCANE  , 0.20, 3.5 }, { GPLANAR , 0.75, 1.5 }, { LPRISMATIC , 0.05, 1.0 }, },	-- highest level BC green
   [151] = { { INFINITE, 0.20, 1.5 }, { LCOSMIC , 0.75, 1.5 }, { SDREAM     , 0.05, 1.0 }, },
   [164] = { { INFINITE, 0.20, 3.5 }, { GCOSMIC , 0.75, 1.5 }, { DREAM      , 0.05, 1.0 }, },
   [200] = { { INFINITE, 0.20, 3.5 }, { GCOSMIC , 0.75, 1.5 }, { DREAM      , 0.05, 1.0 }, },	-- highest level LK green is 182, so far
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
   [115] = { { ARCANE  , 0.75, 3.5 }, { GPLANAR , 0.20, 1.5 }, { LPRISMATIC , 0.05, 1.0 }, },
   [120] = { { ARCANE  , 0.75, 3.5 }, { GPLANAR , 0.20, 1.5 }, { LPRISMATIC , 0.05, 1.0 }, },	-- highest level BC green
   [151] = { { INFINITE, 0.75, 1.5 }, { LCOSMIC , 0.20, 1.5 }, { SDREAM     , 0.05, 1.0 }, },
   [164] = { { INFINITE, 0.75, 3.5 }, { GCOSMIC , 0.20, 1.5 }, { DREAM      , 0.05, 1.0 }, },
   [200] = { { INFINITE, 0.75, 3.5 }, { GCOSMIC , 0.20, 1.5 }, { DREAM      , 0.05, 1.0 }, },	-- highest level LK green is 182, so far
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
   [70]  = { { SPRISMATIC , 0.99, 1.0 }, { NEXUS, 0.01, 1.0 }, },
   [79]  = { { SPRISMATIC , 0.99, 1.0 }, { NEXUS, 0.01, 1.0 }, },
   [85]  = { { SPRISMATIC , 0.99, 1.0 }, { NEXUS, 0.01, 1.0 }, },
   [94]  = { { SPRISMATIC , 0.99, 1.0 }, { VOID , 0.01, 1.0 }, },
   [99]  = { { SPRISMATIC , 0.99, 1.0 }, { VOID , 0.01, 1.0 }, },
   [115] = { { LPRISMATIC , 0.99, 1.0 }, { VOID , 0.01, 1.0 }, },	-- highest level BC blue is 115
   [120] = { { LPRISMATIC , 0.05, 1.0 }, { VOID , 0.01, 1.0 }, },
   [151] = { { SDREAM     , 0.99, 1.0 }, { ABYSS, 0.01, 1.0 }, },
   [164] = { { SDREAM     , 0.99, 1.0 }, { ABYSS, 0.01, 1.0 }, },
   [200] = { { DREAM      , 0.99, 1.0 }, { ABYSS, 0.01, 1.0 }, },	-- highest level LK blue is 200, so far
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
   [70]  = { { SPRISMATIC , 0.99, 1.0 }, { NEXUS, 0.01, 1.0 }, },	-- this is for pre-BC items, there is some overlap 66-70
   [79]  = { { SPRISMATIC , 0.99, 1.0 }, { NEXUS, 0.01, 1.0 }, },
   [85]  = { { SPRISMATIC , 0.99, 1.0 }, { NEXUS, 0.01, 1.0 }, },
   [94]  = { { SPRISMATIC , 0.99, 1.0 }, { VOID , 0.01, 1.0 }, },
   [99]  = { { SPRISMATIC , 0.99, 1.0 }, { VOID , 0.01, 1.0 }, },
   [115] = { { LPRISMATIC , 0.99, 1.0 }, { VOID , 0.01, 1.0 }, },	-- highest level BC blue
   [120] = { { LPRISMATIC , 0.99, 1.0 }, { VOID , 0.01, 1.0 }, },
   [151] = { { SDREAM     , 0.99, 1.0 }, { ABYSS, 0.01, 1.0 }, },
   [164] = { { SDREAM     , 0.99, 1.0 }, { ABYSS, 0.01, 1.0 }, },
   [200] = { { DREAM      , 0.99, 1.0 }, { ABYSS, 0.01, 1.0 }, },	-- highest level LK blue is 200, so far
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
   [115] = { { VOID      , 1.00, 1.5 }, },
   [120] = { { VOID      , 1.00, 1.5 }, },
   [151] = { { VOID      , 1.00, 1.5 }, },
   [164] = { { VOID      , 1.00, 1.5 }, },	-- highest level BC epic
   [200] = { { ABYSS     , 1.00, 1.0 }, },
   [220] = { { ABYSS     , 1.00, 1.5 }, },	-- highest level LK epic is 213, so far
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
   [115] = { { VOID      , 1.00, 1.5 }, },
   [120] = { { VOID      , 1.00, 1.5 }, },
   [151] = { { VOID      , 1.00, 1.5 }, },
   [164] = { { VOID      , 1.00, 1.5 }, },	-- highest level BC epic
   [200] = { { ABYSS     , 1.00, 1.0 }, },
   [220] = { { ABYSS     , 1.00, 1.5 }, },	-- highest level LK epic is 213, so far
  },
 },
}



local COPPER_ORE = 2770
local TIN_ORE = 2771
local IRON_ORE = 2772
local MITHRIL_ORE = 3858
local THORIUM_ORE = 10620
local FEL_IRON_ORE = 23424
local ADAMANTITE_ORE = 23425
local COBALT_ORE = 36909
local SARONITE_ORE = 36912

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

-- ccox - new for WOTLK
local CHALCEDONY = 36923
local SHADOWCRYSTAL = 36926
local TWILIGHTOPAL = 36927
local HUGECITRINE = 36929
local BLOODSTONE = 36917
local SUNCRYSTAL = 36920
local DARKJADE = 36932
local FORESTEMERALD = 36933
local SCARLETRUBY = 36918
local MONARCHTOPAZ = 36930
local SKYSAPPHIRE = 36924
local AUTMNSGLOW = 36921


--[[
	Prospectable ores
	percentages from Wowhead
	last updated Aug 24, 2008
]]

const.ProspectMinLevels = {
	[COPPER_ORE] = 20,
	[TIN_ORE] = 50,
	[IRON_ORE] = 125,
	[MITHRIL_ORE] = 175,
	[THORIUM_ORE] = 250,
	[FEL_IRON_ORE] = 275,
	[ADAMANTITE_ORE] = 325,
	[COBALT_ORE] = 350,
	[SARONITE_ORE] = 400,
}


-- data is a combination of wowhead, wowwiki, and personal results
const.ProspectableItems = {

	[COPPER_ORE] = {
			[TIGERSEYE] = 0.5,
			[MALACHITE] = 0.5,
			[SHADOWGEM] = 0.1,
			},

	[TIN_ORE] = {
			[SHADOWGEM] = 0.375,
			[LESSERMOONSTONE] = 0.375,
			[MOSSAGATE] = 0.375,
			
			[CITRINE] = 0.04,
			[JADE] = 0.04,
			[AQUAMARINE] = 0.04,
			},

	[IRON_ORE] = {
			[CITRINE] = 0.375,
			[LESSERMOONSTONE] = 0.375,
			[JADE] = 0.375,
			
			[AQUAMARINE] = 0.05,
			[STARRUBY] = 0.05,
			},

	[MITHRIL_ORE] = {
			[CITRINE] = 0.375,
			[STARRUBY] = 0.375,
			[AQUAMARINE] = 0.375,
			
			[AZEROTHIANDIAMOND] = 0.03,
			[BLUESAPPHIRE] = 0.03,
			[LARGEOPAL] = 0.03,
			[HUGEEMERALD] = 0.03,
			},

	[THORIUM_ORE] = {
			[STARRUBY] = 0.25,
			[LARGEOPAL] = 0.20,
			[BLUESAPPHIRE] = 0.20,
			[AZEROTHIANDIAMOND] = 0.20,
			[HUGEEMERALD] = 0.20,
			
			[BLOODGARNET] = 0.01,
			[FLAMESPESSARITE] = 0.01,
			[GOLDENDRAENITE] = 0.01,
			[DEEPPERIDOT] = 0.01,
			[AZUREMOONSTONE] = 0.01,
			[SHADOWDRAENITE] = 0.01,
			},

	[FEL_IRON_ORE] = {
			[BLOODGARNET] = 0.17,
			[FLAMESPESSARITE] = 0.17,
			[GOLDENDRAENITE] = 0.17,
			[DEEPPERIDOT] = 0.17,
			[AZUREMOONSTONE] = 0.17,
			[SHADOWDRAENITE] = 0.17,
			
			[LIVINGRUBY] = 0.011,
			[NOBLETOPAZ] = 0.011,
			[DAWNSTONE] = 0.011,
			[TALASITE] = 0.011,
			[STAROFELUNE] = 0.011,
			[NIGHTSEYE] = 0.011,
			},

	[ADAMANTITE_ORE] = {
			[ADAMANTITEPOWDER] = 1.0,		-- other powders were taken out in 3.0, is this still there?
			[BLOODGARNET] = 0.19,
			[FLAMESPESSARITE] = 0.19,
			[GOLDENDRAENITE] = 0.19,
			[DEEPPERIDOT] = 0.19,
			[AZUREMOONSTONE] = 0.19,
			[SHADOWDRAENITE] = 0.19,
			
			[LIVINGRUBY] = 0.03,
			[NOBLETOPAZ] = 0.03,
			[DAWNSTONE] = 0.03,
			[TALASITE] = 0.03,
			[STAROFELUNE] = 0.03,
			[NIGHTSEYE] = 0.03,
			},

	-- ccox - WOTLK - new ores!
	-- data is far from complete
	
	[COBALT_ORE] = {
			[CHALCEDONY] = 0.2,
			[HUGECITRINE] = 0.2,
			[BLOODSTONE] = 0.2,
			[SHADOWCRYSTAL] = 0.2,
			[SUNCRYSTAL] = 0.2,
			[DARKJADE] = 0.2,
			
			[TWILIGHTOPAL] = 0.03,
			[FORESTEMERALD] = 0.03,
			[SCARLETRUBY] = 0.03,
			[MONARCHTOPAZ] = 0.03,
			[SKYSAPPHIRE] = 0.03,
			[AUTMNSGLOW] = 0.03,
			},

	[SARONITE_ORE] = {
			[CHALCEDONY] = 0.2,
			[SHADOWCRYSTAL] = 0.2,
			[DARKJADE] = 0.2,
			[HUGECITRINE] = 0.2,
			[BLOODSTONE] = 0.2,
			[SUNCRYSTAL] = 0.2,
			
			[FORESTEMERALD] = 0.03,
			[SCARLETRUBY] = 0.03,
			[MONARCHTOPAZ] = 0.03,
			[SKYSAPPHIRE] = 0.03,
			[TWILIGHTOPAL] = 0.03,
			[AUTMNSGLOW] = 0.03,
			},
	
}



local ALABASTER_PIGMENT = 39151
local DUSKY_PIGMENT = 39334
local GOLDEN_PIGMENT = 39338
local EMERALD_PIGMENT = 39339
local VIOLET_PIGMENT = 39340
local SILVERY_PIGMENT = 39341
local NETHER_PIGMENT = 39342
local AZURE_PIGMENT = 39343

local VERDANT_PIGMENT = 43103
local BURNT_PIGMENT = 43104
local INDIGO_PIGMENT = 43105
local RUBY_PIGMENT = 43106
local SAPPHIRE_PIGMENT = 43107
local EBON_PIGMENT = 43108
local ICY_PIGMENT = 43109

local POISONOUSIVYBERRIES = 43557
local NIGHTBLOOMLILAC = 43558
local LOCUSTWING = 43559
local FIREFLYDUST = 43560
local IRIDESCENTPOLLEN = 43561
local NIGHTMAREBERRIES = 43562
local FROZENBEETLEHUSK = 43563

local HERB_PEACEBLOOM = 2447
local HERB_SILVERLEAF = 765
local HERB_EARTHROOT = 2449
local HERB_MAGEROYAL = 785
local HERB_BLOODTHISTLE = 22710

local HERB_BRIARTHORN = 2450
local HERB_SWIFTTHISTLE = 2452
local HERB_BRUISEWEED = 2453
local HERB_STRANGLEKELP = 3820

local HERB_WILDSTEELBLOOM = 3355
local HERB_GRAVEMOSS = 3369
local HERB_KINGSBLOOD = 3356
local HERB_LIFEROOT = 3357

local HERB_FADELEAF = 3818
local HERB_GOLDTHORN = 3821
local HERB_WINTERSBITE = 3819
local HERB_KHADGARSWHISKER = 3358

local HERB_FIREBLOOM = 4625
local HERB_GHOSTMUSHROOM = 8845
local HERB_ARTHASTEARS = 8836
local HERB_GROMSBLOOD = 8846
local HERB_BLINDWEED = 8839
local HERB_SUNGRASS = 8838
local HERB_PURPLELOTUS = 8831

local HERB_ICECAP = 13467
local HERB_GOLDENSANSAM = 13464
local HERB_PLAGUEBLOOM = 13466
local HERB_DREAMFOIL = 13463
local HERB_MOUNTAINSILVERSAGE = 13465

-- all BC herbs
local HERB_TEROCONE = 22789
local HERB_DREAMINGGLORY = 22786
local HERB_FELWEED = 22785
local HERB_RAGVEIL = 22787
local HERB_NIGHTMAREVINE = 22792
local HERB_MANATHISTLE = 22793
local HERB_NETHERBLOOM = 22791
local HERB_ANCIENTLICHEN = 22790

-- all northrend herbs?
local HERB_GOLDCLOVER = 36901
local HERB_CONSTRICTORGRASS = 36902
local HERB_ADDERSTONGUE = 36903
local HERB_TIGERLILY = 36904
local HERB_LICHBLOOM = 36905
local HERB_ICETHORN = 36906
local HERB_TALANDRASROSE = 36907
local HERB_DEADNETTLE = 37921


-- skill required, by bracket/result
const.MillingSkillRequired = {

	[ALABASTER_PIGMENT] = 1,
	[DUSKY_PIGMENT] =  25,
	[GOLDEN_PIGMENT] = 75,
	[EMERALD_PIGMENT] = 125,
	[VIOLET_PIGMENT] = 175,
	[SILVERY_PIGMENT] = 225,
	[NETHER_PIGMENT] = 275,
	[AZURE_PIGMENT] = 325,

}

const.MillableItems = {

	[HERB_PEACEBLOOM] = ALABASTER_PIGMENT,
	[HERB_SILVERLEAF] = ALABASTER_PIGMENT,
	[HERB_EARTHROOT] = ALABASTER_PIGMENT,
--	[HERB_BLOODTHISTLE] = ALABASTER_PIGMENT,		-- removed during beta
	
	[HERB_MAGEROYAL] = DUSKY_PIGMENT,				-- moved with build 8982 - double check others!
	[HERB_BRIARTHORN] = DUSKY_PIGMENT,
	[HERB_SWIFTTHISTLE] = DUSKY_PIGMENT,
	[HERB_BRUISEWEED] = DUSKY_PIGMENT,
	[HERB_STRANGLEKELP] = DUSKY_PIGMENT,

	[HERB_WILDSTEELBLOOM] = GOLDEN_PIGMENT,
	[HERB_GRAVEMOSS] = GOLDEN_PIGMENT,
	[HERB_KINGSBLOOD] = GOLDEN_PIGMENT,
	[HERB_LIFEROOT] = GOLDEN_PIGMENT,
	
	[HERB_FADELEAF] = EMERALD_PIGMENT,
	[HERB_GOLDTHORN] = EMERALD_PIGMENT,
	[HERB_WINTERSBITE] = EMERALD_PIGMENT,
	[HERB_KHADGARSWHISKER] = EMERALD_PIGMENT,
	
	[HERB_FIREBLOOM] = VIOLET_PIGMENT,
	[HERB_GHOSTMUSHROOM] = VIOLET_PIGMENT,
	[HERB_ARTHASTEARS] = VIOLET_PIGMENT,
	[HERB_GROMSBLOOD] = VIOLET_PIGMENT,
	[HERB_BLINDWEED] = VIOLET_PIGMENT,
	[HERB_SUNGRASS] = VIOLET_PIGMENT,
	[HERB_PURPLELOTUS] = VIOLET_PIGMENT,

	[HERB_ICECAP] = SILVERY_PIGMENT,
	[HERB_GOLDENSANSAM] = SILVERY_PIGMENT,
	[HERB_PLAGUEBLOOM] = SILVERY_PIGMENT,
	[HERB_DREAMFOIL] = SILVERY_PIGMENT,
	[HERB_MOUNTAINSILVERSAGE] = SILVERY_PIGMENT,

	[HERB_TEROCONE] = NETHER_PIGMENT,
	[HERB_DREAMINGGLORY] = NETHER_PIGMENT,
	[HERB_FELWEED] = NETHER_PIGMENT,
	[HERB_RAGVEIL] = NETHER_PIGMENT,
	[HERB_NIGHTMAREVINE] = NETHER_PIGMENT,
	[HERB_MANATHISTLE] = NETHER_PIGMENT,
	[HERB_NETHERBLOOM] = NETHER_PIGMENT,
	[HERB_ANCIENTLICHEN] = NETHER_PIGMENT,

	[HERB_GOLDCLOVER] = AZURE_PIGMENT,
	[HERB_CONSTRICTORGRASS] = AZURE_PIGMENT,
	[HERB_ADDERSTONGUE] = AZURE_PIGMENT,
	[HERB_TIGERLILY] = AZURE_PIGMENT,
	[HERB_LICHBLOOM] = AZURE_PIGMENT,
	[HERB_ICETHORN] = AZURE_PIGMENT,
	[HERB_TALANDRASROSE] = AZURE_PIGMENT,
	[HERB_DEADNETTLE] = AZURE_PIGMENT,
}


const.MillGroupYields = {

	[ALABASTER_PIGMENT] = {
		[ALABASTER_PIGMENT] = 2.77,
		},

	[DUSKY_PIGMENT] = {
		[DUSKY_PIGMENT] = 2.77,				-- yields 2-4
		[VERDANT_PIGMENT] = 0.45,			-- yields 1-2
		-- [POISONOUSIVYBERRIES] = 0.05,	-- may have been removed
		},

	[GOLDEN_PIGMENT] = {
		[GOLDEN_PIGMENT] = 2.77,
		[BURNT_PIGMENT] = 0.45,
		-- [NIGHTBLOOMLILAC] = 0.05,	-- may have been removed
		},

	[EMERALD_PIGMENT] = {
		[EMERALD_PIGMENT] = 2.77,
		[INDIGO_PIGMENT] = 0.45,
		-- [LOCUSTWING] = 0.05,			-- may have been removed
		},

	[VIOLET_PIGMENT] = {
		[VIOLET_PIGMENT] = 2.77,
		[RUBY_PIGMENT] = 0.45,
		-- [FIREFLYDUST] = 0.05,		-- may have been removed
		},

	[SILVERY_PIGMENT] = {
		[SILVERY_PIGMENT] = 2.77,
		[SAPPHIRE_PIGMENT] = 0.45,
		-- [IRIDESCENTPOLLEN] = 0.05,	-- may have been removed
		},

	[NETHER_PIGMENT] = {
		[NETHER_PIGMENT] = 2.77,
		[EBON_PIGMENT] = 0.45,
		-- [NIGHTMAREBERRIES] = 0.05,	-- may have been removed
		},

	[AZURE_PIGMENT] = {
		[AZURE_PIGMENT] = 2.77,
		[ICY_PIGMENT] = 0.45,
		-- [FROZENBEETLEHUSK] = 0.05,	-- may have been removed
		},

}



-- items that have no use, sell to vendor, and thus get vendor prices
const.VendorTrash =  {
	[COPPERPOWDER] = true,
	[TINPOWDER] = true,
	[IRONPOWDER] = true,
	[MITHRILPOWDER] = true,
	[THORIUMPOWDER] = true,
	[FELIRONPOWDER] = true,
}


-- needed because GetItemInfo fails when items are not in the user's cache
const.BackupReagentItemInfo = {
	[774] = "Malachite#|cff1eff00|Hitem:774:0:0:0:0:0:0:0:20|h[Malachite]|h|r#2#7#0#Gem#Simple#20##Interface\\Icons\\INV_Misc_Gem_Emerald_03",
	[785] = "Mageroyal#|cffffffff|Hitem:785:0:0:0:0:0:0:0:70|h[Mageroyal]|h|r#1#10#0#Trade Goods#Herb#20##Interface\\Icons\\INV_Jewelry_Talisman_03",
	[818] = "Tigerseye#|cff1eff00|Hitem:818:0:0:0:0:0:0:0:20|h[Tigerseye]|h|r#2#15#0#Gem#Simple#20##Interface\\Icons\\INV_Misc_Gem_Opal_03",
	[1206] = "Moss Agate#|cff1eff00|Hitem:1206:0:0:0:0:0:0:0:20|h[Moss Agate]|h|r#2#25#0#Gem#Simple#20##Interface\\Icons\\INV_Misc_Gem_Emerald_02",
	[1210] = "Shadowgem#|cff1eff00|Hitem:1210:0:0:0:0:0:0:0:20|h[Shadowgem]|h|r#2#20#0#Gem#Simple#20##Interface\\Icons\\INV_Misc_Gem_Amethyst_01",
	[1529] = "Jade#|cff1eff00|Hitem:1529:0:0:0:0:0:0:0:20|h[Jade]|h|r#2#35#0#Gem#Simple#20##Interface\\Icons\\INV_Misc_Gem_Stone_01",
	[1705] = "Lesser Moonstone#|cff1eff00|Hitem:1705:0:0:0:0:0:0:0:20|h[Lesser Moonstone]|h|r#2#30#0#Gem#Simple#20##Interface\\Icons\\INV_Misc_Gem_Crystal_01",
	[3356] = "Kingsblood#|cffffffff|Hitem:3356:0:0:0:0:0:0:0:70|h[Kingsblood]|h|r#1#24#0#Trade Goods#Herb#20##Interface\\Icons\\INV_Misc_Herb_03",
	[3819] = "Wintersbite#|cffffffff|Hitem:3819:0:0:0:0:0:0:0:70|h[Wintersbite]|h|r#1#39#0#Trade Goods#Herb#20##Interface\\Icons\\INV_Misc_Flower_03",
	[3864] = "Citrine#|cff1eff00|Hitem:3864:0:0:0:0:0:0:0:20|h[Citrine]|h|r#2#40#0#Gem#Simple#20##Interface\\Icons\\INV_Misc_Gem_Opal_02",
	[6037] = "Truesilver Bar#|cff1eff00|Hitem:6037:0:0:0:0:0:0:0:20|h[Truesilver Bar]|h|r#2#50#0#Trade Goods#Metal & Stone#20##Interface\\Icons\\INV_Ingot_08",
	[6048] = "Shadow Protection Potion#|cffffffff|Hitem:6048:0:0:0:0:0:0:0:70|h[Shadow Protection Potion]|h|r#1#27#17#Consumable#Potion#5##Interface\\Icons\\INV_Potion_44",
	[6370] = "Blackmouth Oil#|cffffffff|Hitem:6370:0:0:0:0:0:0:0:70|h[Blackmouth Oil]|h|r#1#15#0#Trade Goods#Other#20##Interface\\Icons\\INV_Drink_12",
	[6371] = "Fire Oil#|cffffffff|Hitem:6371:0:0:0:0:0:0:0:57|h[Fire Oil]|h|r#1#25#0#Trade Goods#Other#20##Interface\\Icons\\INV_Potion_38",
	[7067] = "Elemental Earth#|cffffffff|Hitem:7067:0:0:0:0:0:0:0:70|h[Elemental Earth]|h|r#1#25#0#Trade Goods#Elemental#10##Interface\\Icons\\INV_Ore_Iron_01",
	[7068] = "Elemental Fire#|cffffffff|Hitem:7068:0:0:0:0:0:0:0:70|h[Elemental Fire]|h|r#1#25#0#Trade Goods#Elemental#10##Interface\\Icons\\Spell_Fire_Fire",
	[7075] = "Core of Earth#|cffffffff|Hitem:7075:0:0:0:0:0:0:0:70|h[Core of Earth]|h|r#1#45#0#Trade Goods#Elemental#10##Interface\\Icons\\INV_Stone_05",
	[7077] = "Heart of Fire#|cffffffff|Hitem:7077:0:0:0:0:0:0:0:70|h[Heart of Fire]|h|r#1#45#0#Trade Goods#Elemental#10##Interface\\Icons\\Spell_Fire_LavaSpawn",
	[7078] = "Essence of Fire#|cff1eff00|Hitem:7078:0:0:0:0:0:0:0:70|h[Essence of Fire]|h|r#2#55#0#Trade Goods#Elemental#10##Interface\\Icons\\Spell_Fire_Volcano",
	[7079] = "Globe of Water#|cffffffff|Hitem:7079:0:0:0:0:0:0:0:70|h[Globe of Water]|h|r#1#45#0#Trade Goods#Elemental#10##Interface\\Icons\\INV_Misc_Orb_01",
	[7080] = "Essence of Water#|cff1eff00|Hitem:7080:0:0:0:0:0:0:0:70|h[Essence of Water]|h|r#2#55#0#Trade Goods#Elemental#10##Interface\\Icons\\Spell_Nature_Acid_01",
	[7081] = "Breath of Wind#|cffffffff|Hitem:7081:0:0:0:0:0:0:0:70|h[Breath of Wind]|h|r#1#45#0#Trade Goods#Elemental#10##Interface\\Icons\\Spell_Nature_Cyclone",
	[7082] = "Essence of Air#|cff1eff00|Hitem:7082:0:0:0:0:0:0:0:70|h[Essence of Air]|h|r#2#55#0#Trade Goods#Elemental#10##Interface\\Icons\\Spell_Nature_EarthBind",
	[7909] = "Aquamarine#|cff1eff00|Hitem:7909:0:0:0:0:0:0:0:20|h[Aquamarine]|h|r#2#45#0#Gem#Simple#20##Interface\\Icons\\INV_Misc_Gem_Crystal_02",
	[7910] = "Star Ruby#|cff1eff00|Hitem:7910:0:0:0:0:0:0:0:20|h[Star Ruby]|h|r#2#50#0#Gem#Simple#20##Interface\\Icons\\INV_Misc_Gem_Ruby_02",
	[7972] = "Ichor of Undeath#|cffffffff|Hitem:7972:0:0:0:0:0:0:0:70|h[Ichor of Undeath]|h|r#1#45#0#Trade Goods#Elemental#10##Interface\\Icons\\INV_Misc_Slime_01",
	[8838] = "Sungrass#|cffffffff|Hitem:8838:0:0:0:0:0:0:0:20|h[Sungrass]|h|r#1#46#0#Trade Goods#Herb#20##Interface\\Icons\\INV_Misc_Herb_18",
	[9224] = "Elixir of Demonslaying#|cffffffff|Hitem:9224:0:0:0:0:0:0:0:70|h[Elixir of Demonslaying]|h|r#1#50#40#Consumable#Elixir#20##Interface\\Icons\\INV_Potion_27",
	[10648] = "Common Parchment#|cffffffff|Hitem:10648:0:0:0:0:0:0:0:70|h[Common Parchment]|h|r#1#40#0#Trade Goods#Other#20##Interface\\Icons\\INV_Inscription_Parchment",
	[10938] = "Lesser Magic Essence#|cff1eff00|Hitem:10938:0:0:0:0:0:0:0:58|h[Lesser Magic Essence]|h|r#2#10#0#Trade Goods#Enchanting#10##Interface\\Icons\\INV_Enchant_EssenceMagicSmall",
	[10939] = "Greater Magic Essence#|cff1eff00|Hitem:10939:0:0:0:0:0:0:0:70|h[Greater Magic Essence]|h|r#2#15#0#Trade Goods#Enchanting#10##Interface\\Icons\\INV_Enchant_EssenceMagicLarge",
	[10940] = "Strange Dust#|cffffffff|Hitem:10940:0:0:0:0:0:0:0:70|h[Strange Dust]|h|r#1#10#0#Trade Goods#Enchanting#20##Interface\\Icons\\INV_Enchant_DustStrange",
	[10978] = "Small Glimmering Shard#|cff0070dd|Hitem:10978:0:0:0:0:0:0:0:70|h[Small Glimmering Shard]|h|r#3#20#0#Trade Goods#Enchanting#20##Interface\\Icons\\INV_Enchant_ShardGlimmeringSmall",
	[10998] = "Lesser Astral Essence#|cff1eff00|Hitem:10998:0:0:0:0:0:0:0:58|h[Lesser Astral Essence]|h|r#2#20#0#Trade Goods#Enchanting#10##Interface\\Icons\\INV_Enchant_EssenceAstralSmall",
	[11082] = "Greater Astral Essence#|cff1eff00|Hitem:11082:0:0:0:0:0:0:0:58|h[Greater Astral Essence]|h|r#2#25#0#Trade Goods#Enchanting#10##Interface\\Icons\\INV_Enchant_EssenceAstralLarge",
	[11083] = "Soul Dust#|cffffffff|Hitem:11083:0:0:0:0:0:0:0:58|h[Soul Dust]|h|r#1#25#0#Trade Goods#Enchanting#20##Interface\\Icons\\INV_Enchant_DustSoul",
	[11084] = "Large Glimmering Shard#|cff0070dd|Hitem:11084:0:0:0:0:0:0:0:58|h[Large Glimmering Shard]|h|r#3#25#0#Trade Goods#Enchanting#20##Interface\\Icons\\INV_Enchant_ShardGlimmeringLarge",
	[11134] = "Lesser Mystic Essence#|cff1eff00|Hitem:11134:0:0:0:0:0:0:0:58|h[Lesser Mystic Essence]|h|r#2#30#0#Trade Goods#Enchanting#10##Interface\\Icons\\INV_Enchant_EssenceMysticalSmall",
	[11135] = "Greater Mystic Essence#|cff1eff00|Hitem:11135:0:0:0:0:0:0:0:58|h[Greater Mystic Essence]|h|r#2#35#0#Trade Goods#Enchanting#10##Interface\\Icons\\INV_Enchant_EssenceMysticalLarge",
	[11137] = "Vision Dust#|cffffffff|Hitem:11137:0:0:0:0:0:0:0:70|h[Vision Dust]|h|r#1#35#0#Trade Goods#Enchanting#20##Interface\\Icons\\INV_Enchant_DustVision",
	[11138] = "Small Glowing Shard#|cff0070dd|Hitem:11138:0:0:0:0:0:0:0:70|h[Small Glowing Shard]|h|r#3#30#0#Trade Goods#Enchanting#20##Interface\\Icons\\INV_Enchant_ShardGlowingSmall",
	[11139] = "Large Glowing Shard#|cff0070dd|Hitem:11139:0:0:0:0:0:0:0:58|h[Large Glowing Shard]|h|r#3#35#0#Trade Goods#Enchanting#20##Interface\\Icons\\INV_Enchant_ShardGlowingLarge",
	[11174] = "Lesser Nether Essence#|cff1eff00|Hitem:11174:0:0:0:0:0:0:0:70|h[Lesser Nether Essence]|h|r#2#40#0#Trade Goods#Enchanting#10##Interface\\Icons\\INV_Enchant_EssenceNetherSmall",
	[11175] = "Greater Nether Essence#|cff1eff00|Hitem:11175:0:0:0:0:0:0:0:70|h[Greater Nether Essence]|h|r#2#45#0#Trade Goods#Enchanting#10##Interface\\Icons\\INV_Enchant_EssenceNetherLarge",
	[11176] = "Dream Dust#|cffffffff|Hitem:11176:0:0:0:0:0:0:0:58|h[Dream Dust]|h|r#1#45#0#Trade Goods#Enchanting#20##Interface\\Icons\\INV_Enchant_DustDream",
	[11177] = "Small Radiant Shard#|cff0070dd|Hitem:11177:0:0:0:0:0:0:0:70|h[Small Radiant Shard]|h|r#3#40#0#Trade Goods#Enchanting#20##Interface\\Icons\\INV_Enchant_ShardRadientSmall",
	[11178] = "Large Radiant Shard#|cff0070dd|Hitem:11178:0:0:0:0:0:0:0:70|h[Large Radiant Shard]|h|r#3#45#0#Trade Goods#Enchanting#20##Interface\\Icons\\INV_Enchant_ShardRadientLarge",
	[12361] = "Blue Sapphire#|cff1eff00|Hitem:12361:0:0:0:0:0:0:0:20|h[Blue Sapphire]|h|r#2#55#0#Gem#Simple#20##Interface\\Icons\\INV_Misc_Gem_Sapphire_02",
	[12364] = "Huge Emerald#|cff1eff00|Hitem:12364:0:0:0:0:0:0:0:20|h[Huge Emerald]|h|r#2#60#0#Gem#Simple#20##Interface\\Icons\\INV_Misc_Gem_Emerald_01",
	[12799] = "Large Opal#|cff1eff00|Hitem:12799:0:0:0:0:0:0:0:20|h[Large Opal]|h|r#2#55#0#Gem#Simple#20##Interface\\Icons\\INV_Misc_Gem_Opal_01",
	[12800] = "Azerothian Diamond#|cff1eff00|Hitem:12800:0:0:0:0:0:0:0:20|h[Azerothian Diamond]|h|r#2#60#0#Gem#Simple#20##Interface\\Icons\\INV_Misc_Gem_Diamond_01",
	[12803] = "Living Essence#|cff1eff00|Hitem:12803:0:0:0:0:0:0:0:70|h[Living Essence]|h|r#2#55#0#Trade Goods#Elemental#10##Interface\\Icons\\Spell_Nature_AbolishMagic",
	[12808] = "Essence of Undeath#|cff1eff00|Hitem:12808:0:0:0:0:0:0:0:70|h[Essence of Undeath]|h|r#2#55#0#Trade Goods#Elemental#10##Interface\\Icons\\Spell_Shadow_ShadeTrueSight",
	[13446] = "Major Healing Potion#|cffffffff|Hitem:13446:0:0:0:0:0:0:0:70|h[Major Healing Potion]|h|r#1#55#45#Consumable#Potion#5##Interface\\Icons\\INV_Potion_54",
	[13467] = "Icecap#|cffffffff|Hitem:13467:0:0:0:0:0:0:0:70|h[Icecap]|h|r#1#58#0#Trade Goods#Herb#20##Interface\\Icons\\INV_Misc_Herb_IceCap",
	[14343] = "Small Brilliant Shard#|cff0070dd|Hitem:14343:0:0:0:0:0:0:0:70|h[Small Brilliant Shard]|h|r#3#50#0#Trade Goods#Enchanting#20##Interface\\Icons\\INV_Enchant_ShardBrilliantSmall",
	[14344] = "Large Brilliant Shard#|cff0070dd|Hitem:14344:0:0:0:0:0:0:0:70|h[Large Brilliant Shard]|h|r#3#55#0#Trade Goods#Enchanting#20##Interface\\Icons\\INV_Enchant_ShardBrilliantLarge",
	[16202] = "Lesser Eternal Essence#|cff1eff00|Hitem:16202:0:0:0:0:0:0:0:58|h[Lesser Eternal Essence]|h|r#2#50#0#Trade Goods#Enchanting#10##Interface\\Icons\\INV_Enchant_EssenceEternalSmall",
	[16203] = "Greater Eternal Essence#|cff1eff00|Hitem:16203:0:0:0:0:0:0:0:58|h[Greater Eternal Essence]|h|r#2#55#0#Trade Goods#Enchanting#10##Interface\\Icons\\INV_Enchant_EssenceEternalLarge",
	[16204] = "Illusion Dust#|cffffffff|Hitem:16204:0:0:0:0:0:0:0:58|h[Illusion Dust]|h|r#1#55#0#Trade Goods#Enchanting#20##Interface\\Icons\\INV_Enchant_DustIllusion",
	[20725] = "Nexus Crystal#|cffa335ee|Hitem:20725:0:0:0:0:0:0:0:60|h[Nexus Crystal]|h|r#4#60#0#Trade Goods#Enchanting#20##Interface\\Icons\\INV_Enchant_ShardNexusLarge",
	[21884] = "Primal Fire#|cff1eff00|Hitem:21884:0:0:0:0:0:0:0:70|h[Primal Fire]|h|r#2#65#0#Trade Goods#Elemental#20##Interface\\Icons\\INV_Elemental_Primal_Fire",
	[21885] = "Primal Water#|cff1eff00|Hitem:21885:0:0:0:0:0:0:0:70|h[Primal Water]|h|r#2#65#0#Trade Goods#Elemental#20##Interface\\Icons\\INV_Elemental_Primal_Water",
	[21929] = "Flame Spessarite#|cff1eff00|Hitem:21929:0:0:0:0:0:0:0:70|h[Flame Spessarite]|h|r#2#65#0#Gem#Orange#20##Interface\\Icons\\INV_Misc_Gem_FlameSpessarite_03",
	[22445] = "Arcane Dust#|cffffffff|Hitem:22445:0:0:0:0:0:0:0:70|h[Arcane Dust]|h|r#1#60#0#Trade Goods#Enchanting#20##Interface\\Icons\\INV_Enchant_DustArcane",
	[22446] = "Greater Planar Essence#|cff1eff00|Hitem:22446:0:0:0:0:0:0:0:70|h[Greater Planar Essence]|h|r#2#65#0#Trade Goods#Enchanting#10##Interface\\Icons\\INV_Enchant_EssenceArcaneLarge",
	[22447] = "Lesser Planar Essence#|cff1eff00|Hitem:22447:0:0:0:0:0:0:0:60|h[Lesser Planar Essence]|h|r#2#60#0#Trade Goods#Enchanting#10##Interface\\Icons\\INV_Enchant_EssenceArcaneSmall",
	[22448] = "Small Prismatic Shard#|cff0070dd|Hitem:22448:0:0:0:0:0:0:0:60|h[Small Prismatic Shard]|h|r#3#65#0#Trade Goods#Enchanting#20##Interface\\Icons\\INV_Enchant_ShardPrismaticSmall",
	[22449] = "Large Prismatic Shard#|cff0070dd|Hitem:22449:0:0:0:0:0:0:0:70|h[Large Prismatic Shard]|h|r#3#70#0#Trade Goods#Enchanting#20##Interface\\Icons\\INV_Enchant_ShardPrismaticLarge",
	[22450] = "Void Crystal#|cffa335ee|Hitem:22450:0:0:0:0:0:0:0:70|h[Void Crystal]|h|r#4#70#0#Trade Goods#Enchanting#20##Interface\\Icons\\INV_Enchant_VoidCrystal",
	[22451] = "Primal Air#|cff1eff00|Hitem:22451:0:0:0:0:0:0:0:70|h[Primal Air]|h|r#2#65#0#Trade Goods#Elemental#20##Interface\\Icons\\INV_Elemental_Primal_Air",
	[22452] = "Primal Earth#|cff1eff00|Hitem:22452:0:0:0:0:0:0:0:70|h[Primal Earth]|h|r#2#65#0#Trade Goods#Elemental#20##Interface\\Icons\\INV_Elemental_Primal_Earth",
	[22457] = "Primal Mana#|cff1eff00|Hitem:22457:0:0:0:0:0:0:0:70|h[Primal Mana]|h|r#2#65#0#Trade Goods#Elemental#20##Interface\\Icons\\INV_Elemental_Primal_Mana",
	[22577] = "Mote of Shadow#|cffffffff|Hitem:22577:0:0:0:0:0:0:0:70|h[Mote of Shadow]|h|r#1#65#0#Trade Goods#Elemental#10##Interface\\Icons\\INV_Elemental_Mote_Shadow01",
	[22832] = "Super Mana Potion#|cffffffff|Hitem:22832:0:0:0:0:0:0:0:70|h[Super Mana Potion]|h|r#1#68#55#Consumable#Potion#5##Interface\\Icons\\INV_Potion_137",
	[23077] = "Blood Garnet#|cff1eff00|Hitem:23077:0:0:0:0:0:0:0:70|h[Blood Garnet]|h|r#2#65#0#Gem#Red#20##Interface\\Icons\\INV_Misc_Gem_BloodGem_03",
	[23079] = "Deep Peridot#|cff1eff00|Hitem:23079:0:0:0:0:0:0:0:70|h[Deep Peridot]|h|r#2#65#0#Gem#Green#20##Interface\\Icons\\INV_Misc_Gem_DeepPeridot_03",
	[23107] = "Shadow Draenite#|cff1eff00|Hitem:23107:0:0:0:0:0:0:0:70|h[Shadow Draenite]|h|r#2#65#0#Gem#Purple#20##Interface\\Icons\\INV_Misc_Gem_EbonDraenite_03",
	[23112] = "Golden Draenite#|cff1eff00|Hitem:23112:0:0:0:0:0:0:0:70|h[Golden Draenite]|h|r#2#65#0#Gem#Yellow#20##Interface\\Icons\\INV_Misc_Gem_GoldenDraenite_03",
	[23117] = "Azure Moonstone#|cff1eff00|Hitem:23117:0:0:0:0:0:0:0:70|h[Azure Moonstone]|h|r#2#65#0#Gem#Blue#20##Interface\\Icons\\INV_Misc_Gem_AzureDraenite_03",
	[23427] = "Eternium Ore#|cff1eff00|Hitem:23427:0:0:0:0:0:0:0:70|h[Eternium Ore]|h|r#2#70#0#Trade Goods#Metal & Stone#20##Interface\\Icons\\INV_Ore_Eternium",
	[23436] = "Living Ruby#|cff0070dd|Hitem:23436:0:0:0:0:0:0:0:70|h[Living Ruby]|h|r#3#70#0#Gem#Red#20##Interface\\Icons\\INV_Jewelcrafting_LivingRuby_02",
	[23437] = "Talasite#|cff0070dd|Hitem:23437:0:0:0:0:0:0:0:70|h[Talasite]|h|r#3#70#0#Gem#Green#20##Interface\\Icons\\INV_Jewelcrafting_Talasite_02",
	[23438] = "Star of Elune#|cff0070dd|Hitem:23438:0:0:0:0:0:0:0:70|h[Star of Elune]|h|r#3#70#0#Gem#Blue#20##Interface\\Icons\\INV_Jewelcrafting_StarOfElune_02",
	[23439] = "Noble Topaz#|cff0070dd|Hitem:23439:0:0:0:0:0:0:0:70|h[Noble Topaz]|h|r#3#70#0#Gem#Orange#20##Interface\\Icons\\INV_Jewelcrafting_NobleTopaz_02",
	[23440] = "Dawnstone#|cff0070dd|Hitem:23440:0:0:0:0:0:0:0:70|h[Dawnstone]|h|r#3#70#0#Gem#Yellow#20##Interface\\Icons\\INV_Jewelcrafting_Dawnstone_02",
	[23441] = "Nightseye#|cff0070dd|Hitem:23441:0:0:0:0:0:0:0:20|h[Nightseye]|h|r#3#70#0#Gem#Purple#20##Interface\\Icons\\INV_Jewelcrafting_Nightseye_02",
	[24186] = "Copper Powder#|cff9d9d9d|Hitem:24186:0:0:0:0:0:0:0:20|h[Copper Powder]|h|r#0#10#0#Miscellaneous#Junk#20##Interface\\Icons\\INV_Misc_Powder_Copper",
	[24188] = "Tin Powder#|cff9d9d9d|Hitem:24188:0:0:0:0:0:0:0:20|h[Tin Powder]|h|r#0#10#0#Miscellaneous#Junk#20##Interface\\Icons\\INV_Misc_Powder_Tin",
	[24190] = "Iron Powder#|cff9d9d9d|Hitem:24190:0:0:0:0:0:0:0:20|h[Iron Powder]|h|r#0#30#0#Miscellaneous#Junk#20##Interface\\Icons\\INV_Misc_Powder_Iron",
	[24234] = "Mithril Powder#|cff9d9d9d|Hitem:24234:0:0:0:0:0:0:0:20|h[Mithril Powder]|h|r#0#30#0#Miscellaneous#Junk#20##Interface\\Icons\\INV_Misc_Powder_Mithril",
	[24235] = "Thorium Powder#|cff9d9d9d|Hitem:24235:0:0:0:0:0:0:0:20|h[Thorium Powder]|h|r#0#50#0#Miscellaneous#Junk#20##Interface\\Icons\\INV_Misc_Powder_Thorium",
	[24242] = "Fel Iron Powder#|cff9d9d9d|Hitem:24242:0:0:0:0:0:0:0:20|h[Fel Iron Powder]|h|r#0#60#0#Miscellaneous#Junk#20##Interface\\Icons\\INV_Misc_Powder_Feliron",
	[24243] = "Adamantite Powder#|cffffffff|Hitem:24243:0:0:0:0:0:0:0:20|h[Adamantite Powder]|h|r#1#70#0#Trade Goods#Jewelcrafting#20##Interface\\Icons\\INV_Misc_Powder_Adamantite",
	[34052] = "Dream Shard#|cff0070dd|Hitem:34052:0:0:0:0:0:0:0:70|h[Dream Shard]|h|r#3#80#0#Trade Goods#Enchanting#20##Interface\\Icons\\INV_Enchant_DreamShard_02",
	[34053] = "Small Dream Shard#|cff0070dd|Hitem:34053:0:0:0:0:0:0:0:70|h[Small Dream Shard]|h|r#3#80#0#Trade Goods#Enchanting#20##Interface\\Icons\\INV_Enchant_DreamShard_01",
	[34054] = "Infinite Dust#|cffffffff|Hitem:34054:0:0:0:0:0:0:0:70|h[Infinite Dust]|h|r#1#70#0#Trade Goods#Enchanting#20##Interface\\Icons\\INV_Misc_Dust_Infinite",
	[34055] = "Greater Cosmic Essence#|cff1eff00|Hitem:34055:0:0:0:0:0:0:0:70|h[Greater Cosmic Essence]|h|r#2#75#0#Trade Goods#Elemental#10##Interface\\Icons\\INV_Enchant_EssenceCosmicGreater",
	[34056] = "Lesser Cosmic Essence#|cff1eff00|Hitem:34056:0:0:0:0:0:0:0:70|h[Lesser Cosmic Essence]|h|r#2#70#0#Trade Goods#Enchanting#10##Interface\\Icons\\INV_Enchant_EssenceCosmicLesser",
	[36904] = "Tiger Lily#|cffffffff|Hitem:36904:0:0:0:0:0:0:0:70|h[Tiger Lily]|h|r#1#72#0#Trade Goods#Herb#20##Interface\\Icons\\INV_Misc_Herb_Tigerlily",
	[36917] = "Bloodstone#|cff1eff00|Hitem:36917:0:0:0:0:0:0:0:70|h[Bloodstone]|h|r#2#75#0#Gem#Red#20##Interface\\Icons\\INV_Misc_Gem_BloodGem_03",
	[36926] = "Shadow Crystal#|cff1eff00|Hitem:36926:0:0:0:0:0:0:0:70|h[Shadow Crystal]|h|r#2#75#0#Gem#Purple#20##Interface\\Icons\\INV_Misc_Gem_EbonDraenite_03",
	[36929] = "Huge Citrine#|cff1eff00|Hitem:36929:0:0:0:0:0:0:0:70|h[Huge Citrine]|h|r#2#75#0#Gem#Orange#20##Interface\\Icons\\INV_Misc_Gem_FlameSpessarite_03",
	[37701] = "Crystallized Earth#|cffffffff|Hitem:37701:0:0:0:0:0:0:0:70|h[Crystallized Earth]|h|r#1#75#0#Trade Goods#Elemental#10##Interface\\Icons\\INV_Crystallized_Earth",
	[39151] = "Alabaster Pigment#|cffffffff|Hitem:39151:0:0:0:0:0:0:0:70|h[Alabaster Pigment]|h|r#1#1#0#Trade Goods#Other#20##Interface\\Icons\\INV_Inscription_Pigment_White",
	[39334] = "Dusky Pigment#|cffffffff|Hitem:39334:0:0:0:0:0:0:0:70|h[Dusky Pigment]|h|r#1#10#0#Trade Goods#Other#20##Interface\\Icons\\INV_Inscription_Pigment_Grey",
	[39338] = "Golden Pigment#|cffffffff|Hitem:39338:0:0:0:0:0:0:0:70|h[Golden Pigment]|h|r#1#20#0#Trade Goods#Other#20##Interface\\Icons\\INV_Inscription_Pigment_Golden",
	[39339] = "Emerald Pigment#|cffffffff|Hitem:39339:0:0:0:0:0:0:0:70|h[Emerald Pigment]|h|r#1#30#0#Trade Goods#Other#20##Interface\\Icons\\INV_Inscription_Pigment_Emerald",
	[39340] = "Violet Pigment#|cffffffff|Hitem:39340:0:0:0:0:0:0:0:20|h[Violet Pigment]|h|r#1#40#0#Trade Goods#Other#20##Interface\\Icons\\INV_Inscription_Pigment_Violet",
	[39341] = "Silvery Pigment#|cffffffff|Hitem:39341:0:0:0:0:0:0:0:70|h[Silvery Pigment]|h|r#1#50#0#Trade Goods#Other#20##Interface\\Icons\\INV_Inscription_Pigment_Silvery",
	[39342] = "Nether Pigment#|cffffffff|Hitem:39342:0:0:0:0:0:0:0:70|h[Nether Pigment]|h|r#1#60#0#Trade Goods#Other#20##Interface\\Icons\\INV_Inscription_Pigment_Nether",
	[39343] = "Azure Pigment#|cffffffff|Hitem:39343:0:0:0:0:0:0:0:70|h[Azure Pigment]|h|r#1#70#0#Trade Goods#Other#20##Interface\\Icons\\INV_Inscription_Pigment_Azure",
	[39354] = "Light Parchment#|cffffffff|Hitem:39354:0:0:0:0:0:0:0:70|h[Light Parchment]|h|r#1#1#0#Trade Goods#Other#20##Interface\\Icons\\INV_Inscription_Papyrus",
	[39469] = "Moonglow Ink#|cffffffff|Hitem:39469:0:0:0:0:0:0:0:70|h[Moonglow Ink]|h|r#1#1#0#Trade Goods#Parts#20##Interface\\Icons\\INV_Inscription_InkWhite02",
	[39501] = "Heavy Parchment#|cffffffff|Hitem:39501:0:0:0:0:0:0:0:70|h[Heavy Parchment]|h|r#1#60#0#Trade Goods#Other#20##Interface\\Icons\\INV_Misc_Note_02",
	[39502] = "Resilient Parchment#|cffffffff|Hitem:39502:0:0:0:0:0:0:0:70|h[Resilient Parchment]|h|r#1#80#0#Trade Goods#Other#20##Interface\\Icons\\INV_Misc_Note_02",
	[39774] = "Midnight Ink#|cffffffff|Hitem:39774:0:0:0:0:0:0:0:70|h[Midnight Ink]|h|r#1#10#0#Trade Goods#Parts#20##Interface\\Icons\\INV_Inscription_InkBlack01",
	[43103] = "Verdant Pigment#|cff1eff00|Hitem:43103:0:0:0:0:0:0:0:70|h[Verdant Pigment]|h|r#2#20#0#Trade Goods#Other#20##Interface\\Icons\\INV_Inscription_Pigment_Verdant",
	[43104] = "Burnt Pigment#|cff1eff00|Hitem:43104:0:0:0:0:0:0:0:70|h[Burnt Pigment]|h|r#2#30#0#Trade Goods#Other#20##Interface\\Icons\\INV_Inscription_Pigment_Burnt",
	[43105] = "Indigo Pigment#|cff1eff00|Hitem:43105:0:0:0:0:0:0:0:70|h[Indigo Pigment]|h|r#2#40#0#Trade Goods#Other#20##Interface\\Icons\\INV_Inscription_Pigment_Indigo",
	[43106] = "Ruby Pigment#|cff1eff00|Hitem:43106:0:0:0:0:0:0:0:20|h[Ruby Pigment]|h|r#2#50#0#Trade Goods#Other#20##Interface\\Icons\\INV_Inscription_Pigment_Ruby",
	[43107] = "Sapphire Pigment#|cff1eff00|Hitem:43107:0:0:0:0:0:0:0:70|h[Sapphire Pigment]|h|r#2#60#0#Trade Goods#Other#20##Interface\\Icons\\INV_Inscription_Pigment_Sapphire",
	[43108] = "Ebon Pigment#|cff1eff00|Hitem:43108:0:0:0:0:0:0:0:70|h[Ebon Pigment]|h|r#2#70#0#Trade Goods#Other#20##Interface\\Icons\\INV_Inscription_Pigment_Ebon",
	[43109] = "Icy Pigment#|cff1eff00|Hitem:43109:0:0:0:0:0:0:0:70|h[Icy Pigment]|h|r#2#80#0#Trade Goods#Other#20##Interface\\Icons\\INV_Inscription_Pigment_Icy",
	[43116] = "Lion's Ink#|cffffffff|Hitem:43116:0:0:0:0:0:0:0:70|h[Lion's Ink]|h|r#1#20#0#Trade Goods#Parts#20##Interface\\Icons\\INV_Inscription_InkYellow02",
	[43557] = "Poisonous Ivy Berries#|cff1eff00|Hitem:43557:0:0:0:0:0:0:0:70|h[Poisonous Ivy Berries]|h|r#2#20#0#Trade Goods#Other#20##Interface\\Icons\\INV_Misc_Food_104_TundraBerries",
	[43558] = "Nightbloom Lilac#|cff1eff00|Hitem:43558:0:0:0:0:0:0:0:70|h[Nightbloom Lilac]|h|r#2#30#0#Trade Goods#Other#20##Interface\\Icons\\INV_Misc_Flower_04",
}

