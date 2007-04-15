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


--[[
			[10940] = const.DUST, -- Strange Dust
			[11083] = const.DUST, -- Soul Dust
			[11137] = const.DUST, -- Vision Dust
			[11176] = const.DUST, -- Dream Dust
			[16204] = const.DUST, -- Illusion Dust
			[22445] = const.DUST, -- Arcane Dust
			[10938] = const.ESSENCE_LESSER, -- Lesser Magic Essence
			[10939] = const.ESSENCE_GREATER, -- Greater Magic Essence
			[10998] = const.ESSENCE_LESSER, -- Lesser Astral Essence -- Armor Only
			[11082] = const.ESSENCE_GREATER, -- Greater Astral Essence -- Armor Only
			[11134] = const.ESSENCE_LESSER, -- Lesser Mystic Essence
			[11135] = const.ESSENCE_GREATER, -- Greater Mystic Essence
			[11174] = const.ESSENCE_LESSER, -- Lesser Nether Essence
			[11175] = const.ESSENCE_GREATER, -- Greater Nether Essence
			[16202] = const.ESSENCE_LESSER, -- Lesser Eternal Essence
			[16203] = const.ESSENCE_GREATER, -- Greater Eternal Essence
			[22447] = const.ESSENCE_LESSER, -- Lesser Planar Essence
			[22446] = const.ESSENCE_GREATER, -- Greater Planar Essence
			[10978] = const.SHARD_SMALL, -- Small Glimmering Shard
			[11084] = const.SHARD_LARGE, -- Large Glimmering Shard
			[11138] = const.SHARD_SMALL, -- Small Glowing Shard
			[11139] = const.SHARD_LARGE, -- Large Glowing Shard
			[11177] = const.SHARD_SMALL, -- Small Radiant Shard
			[11178] = const.SHARD_LARGE, -- Large Radiant Shard
			[14343] = const.SHARD_SMALL, -- Small Brilliant Shard
			[14344] = const.SHARD_LARGE, -- Large Brilliant Shard
			[22448] = const.SHARD_SMALL, -- Small Prismatic Shard
			[22449] = const.SHARD_LARGE, -- Large Prismatic Shard
			[20725] = const.CRYSTAL, -- Nexus Crystal
			[22450] = const.CRYSTAL, -- Void Crystal
]]

const.LevelRules = {
	[const.WEAPON] = {
		[5]  = {
			[10940] = const.DUST, -- Strange Dust
		},
		[10] = {
			[10940] = const.DUST, -- Strange Dust
			[10938] = const.ESSENCE_LESSER, -- Lesser Magic Essence
		},
		[15] = {
			[10940] = const.DUST, -- Strange Dust
			[10938] = const.ESSENCE_LESSER, -- Lesser Magic Essence
		},
		[20] = {
			[10940] = const.DUST, -- Strange Dust
			[10939] = const.ESSENCE_GREATER, -- Greater Magic Essence
			[10978] = const.SHARD_SMALL, -- Small Glimmering Shard
		},
		[25] = {
			[10940] = const.DUST, -- Strange Dust
			[10939] = const.ESSENCE_GREATER, -- Greater Magic Essence
			[10978] = const.SHARD_SMALL, -- Small Glimmering Shard
		},
		[30] = {
			[11083] = const.DUST, -- Soul Dust
			[10939] = const.ESSENCE_GREATER, -- Greater Magic Essence
			[11084] = const.SHARD_LARGE, -- Large Glimmering Shard
		},
		[35] = {
			[11083] = const.DUST, -- Soul Dust
			[11134] = const.ESSENCE_LESSER, -- Lesser Mystic Essence
			[11138] = const.SHARD_SMALL, -- Small Glowing Shard
		},
		[40] = {
			[11137] = const.DUST, -- Vision Dust
			[11135] = const.ESSENCE_GREATER, -- Greater Mystic Essence
			[11139] = const.SHARD_LARGE, -- Large Glowing Shard
		},
		[45] = {
			[11137] = const.DUST, -- Vision Dust
			[11174] = const.ESSENCE_LESSER, -- Lesser Nether Essence
			[11177] = const.SHARD_SMALL, -- Small Radiant Shard
		},
		[50] = {
			[11176] = const.DUST, -- Dream Dust
			[11175] = const.ESSENCE_GREATER, -- Greater Nether Essence
			[11178] = const.SHARD_LARGE, -- Large Radiant Shard
		},
		[55] = {
			[11176] = const.DUST, -- Dream Dust
			[16202] = const.ESSENCE_LESSER, -- Lesser Eternal Essence
			[14343] = const.SHARD_SMALL, -- Small Brilliant Shard
		},
		[60] = {
			[16204] = const.DUST, -- Illusion Dust
			[16203] = const.ESSENCE_GREATER, -- Greater Eternal Essence
			[14344] = const.SHARD_LARGE, -- Large Brilliant Shard
			[20725] = const.CRYSTAL, -- Nexus Crystal
		},
		[65] = {
			[16204] = const.DUST, -- Illusion Dust
			[16203] = const.ESSENCE_GREATER, -- Greater Eternal Essence
			[14344] = const.SHARD_LARGE, -- Large Brilliant Shard
			[20725] = const.CRYSTAL, -- Nexus Crystal
		},
		[70] = {
			[22445] = const.DUST, -- Arcane Dust
			[22447] = const.ESSENCE_LESSER, -- Lesser Planar Essence
			[22448] = const.SHARD_SMALL, -- Small Prismatic Shard
			[20725] = const.CRYSTAL, -- Nexus Crystal
		},
		[75] = {
			[22445] = const.DUST, -- Arcane Dust
			[22447] = const.ESSENCE_LESSER, -- Lesser Planar Essence
			[22448] = const.SHARD_SMALL, -- Small Prismatic Shard
			[20725] = const.CRYSTAL, -- Nexus Crystal
		},
		[80] = {
			[22445] = const.DUST, -- Arcane Dust
			[22447] = const.ESSENCE_LESSER, -- Lesser Planar Essence
			[22448] = const.SHARD_SMALL, -- Small Prismatic Shard
			[20725] = const.CRYSTAL, -- Nexus Crystal
		},
		[85] = {
			[22445] = const.DUST, -- Arcane Dust
			[22447] = const.ESSENCE_LESSER, -- Lesser Planar Essence
			[22448] = const.SHARD_SMALL, -- Small Prismatic Shard
			[20725] = const.CRYSTAL, -- Nexus Crystal
		},
		[90] = {
			[22445] = const.DUST, -- Arcane Dust
			[22447] = const.ESSENCE_LESSER, -- Lesser Planar Essence
			[22448] = const.SHARD_SMALL, -- Small Prismatic Shard
			[22450] = const.CRYSTAL, -- Void Crystal
		},
		[95] = {
			[22445] = const.DUST, -- Arcane Dust
			[22447] = const.ESSENCE_LESSER, -- Lesser Planar Essence
			[22448] = const.SHARD_SMALL, -- Small Prismatic Shard
			[22450] = const.CRYSTAL, -- Void Crystal
		},
		[100] = {
			[22445] = const.DUST, -- Arcane Dust
			[22447] = const.ESSENCE_LESSER, -- Lesser Planar Essence
			[22449] = const.SHARD_LARGE, -- Large Prismatic Shard
			[22450] = const.CRYSTAL, -- Void Crystal
		},
		[105] = {
			[22445] = const.DUST, -- Arcane Dust
			[22446] = const.ESSENCE_GREATER, -- Greater Planar Essence
			[22449] = const.SHARD_LARGE, -- Large Prismatic Shard
			[22450] = const.CRYSTAL, -- Void Crystal
		},
		[110] = {
			[22445] = const.DUST, -- Arcane Dust
			[22446] = const.ESSENCE_GREATER, -- Greater Planar Essence
			[22449] = const.SHARD_LARGE, -- Large Prismatic Shard
			[22450] = const.CRYSTAL, -- Void Crystal
		},
		[115] = {
			[22445] = const.DUST, -- Arcane Dust
			[22446] = const.ESSENCE_GREATER, -- Greater Planar Essence
			[22449] = const.SHARD_LARGE, -- Large Prismatic Shard
			[22450] = const.CRYSTAL, -- Void Crystal
		},
		[120] = {
			[22445] = const.DUST, -- Arcane Dust
			[22446] = const.ESSENCE_GREATER, -- Greater Planar Essence
			[22449] = const.SHARD_LARGE, -- Large Prismatic Shard
			[22450] = const.CRYSTAL, -- Void Crystal
		},
		[125] = {
			[22445] = const.DUST, -- Arcane Dust
			[22446] = const.ESSENCE_GREATER, -- Greater Planar Essence
			[22449] = const.SHARD_LARGE, -- Large Prismatic Shard
			[22450] = const.CRYSTAL, -- Void Crystal
		},
		[130] = {
			[22445] = const.DUST, -- Arcane Dust
			[22446] = const.ESSENCE_GREATER, -- Greater Planar Essence
			[22449] = const.SHARD_LARGE, -- Large Prismatic Shard
			[22450] = const.CRYSTAL, -- Void Crystal
		},
		[135] = {
			[22445] = const.DUST, -- Arcane Dust
			[22446] = const.ESSENCE_GREATER, -- Greater Planar Essence
			[22449] = const.SHARD_LARGE, -- Large Prismatic Shard
			[22450] = const.CRYSTAL, -- Void Crystal
		},
		[140] = {
			[22445] = const.DUST, -- Arcane Dust
			[22446] = const.ESSENCE_GREATER, -- Greater Planar Essence
			[22449] = const.SHARD_LARGE, -- Large Prismatic Shard
			[22450] = const.CRYSTAL, -- Void Crystal
		},
	},
	[const.ARMOR] = {
		[5]  = {
			[10940] = const.DUST, -- Strange Dust
		},
		[10] = {
			[10940] = const.DUST, -- Strange Dust
			[10938] = const.ESSENCE_LESSER, -- Lesser Magic Essence
		},
		[15] = {
			[10940] = const.DUST, -- Strange Dust
			[10938] = const.ESSENCE_LESSER, -- Lesser Magic Essence
		},
		[20] = {
			[10940] = const.DUST, -- Strange Dust
			[10939] = const.ESSENCE_GREATER, -- Greater Magic Essence
			[10978] = const.SHARD_SMALL, -- Small Glimmering Shard
		},
		[25] = {
			[10940] = const.DUST, -- Strange Dust
			[10998] = const.ESSENCE_LESSER, -- Lesser Astral Essence -- Armor Only
			[10978] = const.SHARD_SMALL, -- Small Glimmering Shard
		},
		[30] = {
			[11083] = const.DUST, -- Soul Dust
			[11082] = const.ESSENCE_GREATER, -- Greater Astral Essence -- Armor Only
			[11084] = const.SHARD_LARGE, -- Large Glimmering Shard
		},
		[35] = {
			[11083] = const.DUST, -- Soul Dust
			[11134] = const.ESSENCE_LESSER, -- Lesser Mystic Essence
			[11138] = const.SHARD_SMALL, -- Small Glowing Shard
		},
		[40] = {
			[11137] = const.DUST, -- Vision Dust
			[11135] = const.ESSENCE_GREATER, -- Greater Mystic Essence
			[11139] = const.SHARD_LARGE, -- Large Glowing Shard
		},
		[45] = {
			[11137] = const.DUST, -- Vision Dust
			[11174] = const.ESSENCE_LESSER, -- Lesser Nether Essence
			[11177] = const.SHARD_SMALL, -- Small Radiant Shard
		},
		[50] = {
			[11176] = const.DUST, -- Dream Dust
			[11175] = const.ESSENCE_GREATER, -- Greater Nether Essence
			[11178] = const.SHARD_LARGE, -- Large Radiant Shard
		},
		[55] = {
			[11176] = const.DUST, -- Dream Dust
			[16202] = const.ESSENCE_LESSER, -- Lesser Eternal Essence
			[14343] = const.SHARD_SMALL, -- Small Brilliant Shard
		},
		[60] = {
			[16204] = const.DUST, -- Illusion Dust
			[16203] = const.ESSENCE_GREATER, -- Greater Eternal Essence
			[14344] = const.SHARD_LARGE, -- Large Brilliant Shard
			[20725] = const.CRYSTAL, -- Nexus Crystal
		},
		[65] = {
			[16204] = const.DUST, -- Illusion Dust
			[16203] = const.ESSENCE_GREATER, -- Greater Eternal Essence
			[14344] = const.SHARD_LARGE, -- Large Brilliant Shard
			[20725] = const.CRYSTAL, -- Nexus Crystal
		},
		[70] = {
			[22445] = const.DUST, -- Arcane Dust
			[22447] = const.ESSENCE_LESSER, -- Lesser Planar Essence
			[22448] = const.SHARD_SMALL, -- Small Prismatic Shard
			[20725] = const.CRYSTAL, -- Nexus Crystal
		},
		[75] = {
			[22445] = const.DUST, -- Arcane Dust
			[22447] = const.ESSENCE_LESSER, -- Lesser Planar Essence
			[22448] = const.SHARD_SMALL, -- Small Prismatic Shard
			[20725] = const.CRYSTAL, -- Nexus Crystal
		},
		[80] = {
			[22445] = const.DUST, -- Arcane Dust
			[22447] = const.ESSENCE_LESSER, -- Lesser Planar Essence
			[22448] = const.SHARD_SMALL, -- Small Prismatic Shard
			[20725] = const.CRYSTAL, -- Nexus Crystal
		},
		[85] = {
			[22445] = const.DUST, -- Arcane Dust
			[22447] = const.ESSENCE_LESSER, -- Lesser Planar Essence
			[22448] = const.SHARD_SMALL, -- Small Prismatic Shard
			[20725] = const.CRYSTAL, -- Nexus Crystal
		},
		[90] = {
			[22445] = const.DUST, -- Arcane Dust
			[22447] = const.ESSENCE_LESSER, -- Lesser Planar Essence
			[22448] = const.SHARD_SMALL, -- Small Prismatic Shard
			[22450] = const.CRYSTAL, -- Void Crystal
		},
		[95] = {
			[22445] = const.DUST, -- Arcane Dust
			[22447] = const.ESSENCE_LESSER, -- Lesser Planar Essence
			[22448] = const.SHARD_SMALL, -- Small Prismatic Shard
			[22450] = const.CRYSTAL, -- Void Crystal
		},
		[100] = {
			[22445] = const.DUST, -- Arcane Dust
			[22447] = const.ESSENCE_LESSER, -- Lesser Planar Essence
			[22449] = const.SHARD_LARGE, -- Large Prismatic Shard
			[22450] = const.CRYSTAL, -- Void Crystal
		},
		[105] = {
			[22445] = const.DUST, -- Arcane Dust
			[22446] = const.ESSENCE_GREATER, -- Greater Planar Essence
			[22449] = const.SHARD_LARGE, -- Large Prismatic Shard
			[22450] = const.CRYSTAL, -- Void Crystal
		},
		[110] = {
			[22445] = const.DUST, -- Arcane Dust
			[22446] = const.ESSENCE_GREATER, -- Greater Planar Essence
			[22449] = const.SHARD_LARGE, -- Large Prismatic Shard
			[22450] = const.CRYSTAL, -- Void Crystal
		},
		[115] = {
			[22445] = const.DUST, -- Arcane Dust
			[22446] = const.ESSENCE_GREATER, -- Greater Planar Essence
			[22449] = const.SHARD_LARGE, -- Large Prismatic Shard
			[22450] = const.CRYSTAL, -- Void Crystal
		},
		[120] = {
			[22445] = const.DUST, -- Arcane Dust
			[22446] = const.ESSENCE_GREATER, -- Greater Planar Essence
			[22449] = const.SHARD_LARGE, -- Large Prismatic Shard
			[22450] = const.CRYSTAL, -- Void Crystal
		},
		[125] = {
			[22445] = const.DUST, -- Arcane Dust
			[22446] = const.ESSENCE_GREATER, -- Greater Planar Essence
			[22449] = const.SHARD_LARGE, -- Large Prismatic Shard
			[22450] = const.CRYSTAL, -- Void Crystal
		},
		[130] = {
			[22445] = const.DUST, -- Arcane Dust
			[22446] = const.ESSENCE_GREATER, -- Greater Planar Essence
			[22449] = const.SHARD_LARGE, -- Large Prismatic Shard
			[22450] = const.CRYSTAL, -- Void Crystal
		},
		[135] = {
			[22445] = const.DUST, -- Arcane Dust
			[22446] = const.ESSENCE_GREATER, -- Greater Planar Essence
			[22449] = const.SHARD_LARGE, -- Large Prismatic Shard
			[22450] = const.CRYSTAL, -- Void Crystal
		},
		[140] = {
			[22445] = const.DUST, -- Arcane Dust
			[22446] = const.ESSENCE_GREATER, -- Greater Planar Essence
			[22449] = const.SHARD_LARGE, -- Large Prismatic Shard
			[22450] = const.CRYSTAL, -- Void Crystal
		},
	},
}
