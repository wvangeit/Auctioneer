--[[
	Auctioneer
	Version: <%version%> (<%codename%>)
	Revision: $Id$
	URL: http://auctioneeraddon.com/

	This is an addon for World of Warcraft that adds statistical history to the auction data that is collected
	when the auction is scanned, so that you can easily determine what price
	you will be able to sell an item for at auction or at a vendor whenever you
	mouse-over an item in the game

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
		You have an implicit license to use this AddOn with these facilities
		since that is its designated purpose as per:
		http://www.fsf.org/licensing/licenses/gpl-faq.html#InterpreterIncompat
]]
if not AucAdvanced then return end

local lib = {
	PlayerName = UnitName("player"),
	PlayerRealm = GetRealmName(),

	AucMinTimes = {
		0,
		1800, -- 30 mins
		7200, -- 2 hours
		43200, -- 12 hours
	},
	AucMaxTimes = {
		1800,  -- 30 mins
		7200,  -- 2 hours
		43200, -- 12 hours
		172800 -- 48 hours
	},
	AucTimes = {
		0,
		1800, -- 30 mins
		7200, -- 2 hours
		43200, -- 12 hours
		172800 -- 48 hours
	},

	EquipEncode = { -- Converts "INVTYPE_*" strings to an internal number code; stored in scandata and used by Stat-iLevel
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
	},
	-- EquipDecode = <add a reverse lookup table here if we need it>

	EquipLocToInvIndex = {}, -- converts "INVTYPE_*" strings to invTypeIndex for scan queries - only valid for Armour types
	EquipCodeToInvIndex = {}, -- as above, but converts the EquipEncode'd number to invTypeIndex
	-- InvIndexToEquipLoc = <add a reverse lookup table here if we need it>

	LINK = 1,
	ILEVEL = 2,
	ITYPE = 3,
	ISUB = 4,
	IEQUIP = 5,
	PRICE = 6,
	TLEFT = 7,
	TIME = 8,
	NAME = 9,
	DEP2 = 10,
	COUNT = 11,
	QUALITY = 12,
	CANUSE = 13,
	ULEVEL = 14,
	MINBID = 15,
	MININC = 16,
	BUYOUT = 17,
	CURBID = 18,
	AMHIGH = 19,
	SELLER = 20,
	FLAG = 21,
	BONUSES = 22,
	ITEMID = 23,
	SUFFIX = 24,
	FACTOR = 25,
	ENCHANT = 26,
	SEED = 27,
	LASTENTRY = 27, -- Used to determine how many entries the table has when copying (some entries can be nil so # won't work)

	ScanPosLabels = {"LINK", "ILEVEL", "ITYPE", "ISUB", "IEQUIP", "PRICE", "TLEFT", "TIME", "NAME", "DEP2", "COUNT", "QUALITY", "CANUSE", "ULEVEL", "MINBID", "MININC",
		"BUYOUT", "CURBID", "AMHIGH", "SELLER", "FLAG", "BONUSES", "ITEMID", "SUFFIX", "FACTOR", "ENCHANT", "SEED" },

	-- Permanent flags (stored in save file)
	FLAG_UNSEEN = 2,
	FLAG_FILTER = 4,
	-- Temporary flags (only used during processing - higher values to leave lower ones free for permanent flags)
	FLAG_DIRTY = 64,
	FLAG_EXPIRED = 128,
	FLAG_CORRUPT = 256,

	ALEVEL_OFF = 0,
	ALEVEL_MIN = 1,
	ALEVEL_LOW = 2,
	ALEVEL_MED = 3,
	ALEVEL_HI = 4,
	ALEVEL_MAX = 5,

	-- CLASSES = { GetAuctionItemClasses() }, -- removed in 7.0.x
	CLASSES = {
		AUCTION_CATEGORY_WEAPONS,
		AUCTION_CATEGORY_ARMOR,
		AUCTION_CATEGORY_CONTAINERS,
		AUCTION_CATEGORY_GEMS,
		AUCTION_CATEGORY_ITEM_ENHANCEMENT,
		AUCTION_CATEGORY_CONSUMABLES,
		AUCTION_CATEGORY_GLYPHS,
		AUCTION_CATEGORY_TRADE_GOODS,
		AUCTION_CATEGORY_RECIPES,
		AUCTION_CATEGORY_BATTLE_PETS,
		AUCTION_CATEGORY_QUEST_ITEMS,
		AUCTION_CATEGORY_MISCELLANEOUS,
	},

	SUBCLASSES = { },
	CLASSESREV = { }, -- Table mapping names to index in CLASSES table
	SUBCLASSESREV = { }, -- Table mapping from CLASS and SUBCLASSES names to index number in SUBCLASSES

	MAXSKILLLEVEL = 700, -- 7.x Note: Legion increases to 800
	MAXUSERLEVEL = 100, -- 7.x Note: Legion increases to 110

	MAXITEMLEVEL = 750, -- 7.x Note: Reports that Legion goes up as high as 950
	MAXBIDPRICE = 9999999999, -- copy from Blizzard_AuctionUI.lua, so it is available before AH loads
}

lib.CompactRealm = lib.PlayerRealm:gsub(" ", "") -- CompactRealm is realm name with spaces removed

for i = 1, #lib.CLASSES do
	lib.CLASSESREV[lib.CLASSES[i]] = i
	lib.SUBCLASSESREV[lib.CLASSES[i]] = {}
	lib.SUBCLASSES[i] = { GetAuctionItemSubClasses(i) }
	for j = 1, #lib.SUBCLASSES[i] do
		lib.SUBCLASSESREV[lib.CLASSES[i]][lib.SUBCLASSES[i][j]] = j
	end
end

--[[
local function CompileInvTypes(...)
	for i=1, select("#", ...), 2 do
		-- each type has 2 args: token name(i), display in list(i+1)
		local equipLoc = select(i, ...)
		local invTypeIndex = (i+1)/2
		local equipCode = lib.EquipEncode[equipLoc]

		lib.EquipLocToInvIndex[equipLoc] = invTypeIndex
		if equipCode then
			lib.EquipCodeToInvIndex[equipCode] = invTypeIndex
		else
			-- All possible entries should exist in the table - warn if a missing entry is detected
			print("AucAdvanced CoreConst error: missing EquipCode for Equip Location "..equipLoc)
		end
	end
end

CompileInvTypes(GetAuctionInvTypes(2, 1))
--]]
-- 7.x removed GetAuctionInvTypes() and now uses hardcoded globals
local function CompileInvTypes()
	local invtype_strformat = "INVTYPE_%s"
	local le_invtype_strformat = "LE_INVENTORY_TYPE_%s_TYPE"
	local invtype_strings = {
		"HEAD",
		"NECK",
		"SHOULDER",
		"BODY",
		"CHEST",
		"WAIST",
		"LEGS",
		"FEET",
		"WRIST",
		"HAND",
		"FINGER",
		"TRINKET",
		"WEAPON",
		"SHIELD",
		"RANGEDRIGHT",
		"CLOAK",
		"2HWEAPON",
		"BAG",
		"TABARD",
		"ROBE",
		"WEAPONMAINHAND",
		"WEAPONOFFHAND",
		"HOLDABLE",
		"AMMO",
		"THROWN",
		"RANGED"
	}
	local invstr
	for _,invstr in ipairs(invtype_strings) do
		-- each type has 2 args: token name(i), display in list(i+1)
		-- However 7.x has removed GetAuctionInvTypes() so we need to be creative
		local equipLoc = string.format(invtype_strformat, invstr)
		local invTypeIndex = _G[string.format(le_invtype_strformat, invstr)]
		local equipCode = lib.EquipEncode[equipLoc]

		if not invTypeIndex == nil then
			lib.EquipLocToInvIndex[equipLoc] = invTypeIndex
			if equipCode then
				lib.EquipCodeToInvIndex[equipCode] = invTypeIndex
			else
				-- All possible entries should exist in the table - warn if a missing entry is detected
				print("AucAdvanced CoreConst error: missing EquipCode for Equip Location "..equipLoc)
			end
		else
			print("AucAdvanced CoreConst error: missing invTypeIndex for Inventory Type "..invstr)
		end
	end
end
CompileInvTypes()

AucAdvanced.Const = lib

AucAdvanced.RegisterRevision("$URL$", "$Rev$")
