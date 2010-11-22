--[[
	Enchantrix Addon for World of Warcraft(tm).
	Version: <%version%> (<%codename%>)
	Revision: $Id: EnxConstants.lua 4632 2010-01-24 02:33:54Z ccox $
	URL: http://enchantrix.org/

	Enchantrix Constants for Jewelcrafting / Prospecting

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
Enchantrix_RegisterRevision("$URL: http://dev.norganna.org/auctioneer/trunk/Enchantrix/EnxConstantsJewelcrafting.lua $", "$Rev: 4632 $")

local const = Enchantrix.Constants

local COPPER_ORE = 2770
local TIN_ORE = 2771
local IRON_ORE = 2772
local MITHRIL_ORE = 3858
local THORIUM_ORE = 10620
local FEL_IRON_ORE = 23424
local ADAMANTITE_ORE = 23425
local COBALT_ORE = 36909
local SARONITE_ORE = 36912
local TITANIUM_ORE = 36910
local OBSIDIUM_ORE = 53038
local ELEMENTIUM_ORE = 52185
local PYRITE_ORE = 52183

local COPPERPOWDER = 24186
local TINPOWDER = 24188
local IRONPOWDER = 24190
local MITHRILPOWDER = 24234
local THORIUMPOWDER = 24235
local FELIRONPOWDER = 24242
local ADAMANTITEPOWDER = 24243
local TITANIUMPOWDER = 46849

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

local MAJESTICZIRCON = 36925
local AMETRINE = 36931
local KINGSAMBER = 36922
local DREADSTONE = 36928
local CARDINALRUBY = 36919
local EYEOFZUL = 36934

-- ccox - new for Cataclysm
local CARNELIAN = 52177
local ZEPHYRITE = 52178
local ALICITE = 52179
local NIGHTSTONE = 52180
local HESSONITE = 52181
local JASPER = 52182

local INFERNORUBY = 52190
local OCEANSAPPHIRE = 52191
local DREAMEMERALD = 52192
local EMBERTOPAZ = 52193
local DEMONSEYE = 52194
local AMBERJEWEL = 52195


--[[
	Prospectable ores and skill to prospect them
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
	[TITANIUM_ORE] = 450,
	[OBSIDIUM_ORE] = 425,
	[ELEMENTIUM_ORE] = 475,			 -- ccox - this is guesswork!
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
			[ADAMANTITEPOWDER] = 1.0,		-- other powders were taken out in 3.0
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

	[COBALT_ORE] = {
			[CHALCEDONY] = 0.25,
			[HUGECITRINE] = 0.25,
			[BLOODSTONE] = 0.25,
			[SHADOWCRYSTAL] = 0.25,
			[SUNCRYSTAL] = 0.25,
			[DARKJADE] = 0.25,

			[TWILIGHTOPAL] = 0.013,
			[FORESTEMERALD] = 0.013,
			[SCARLETRUBY] = 0.013,
			[MONARCHTOPAZ] = 0.013,
			[SKYSAPPHIRE] = 0.013,
			[AUTMNSGLOW] = 0.013,
			},

	[SARONITE_ORE] = {
			[CHALCEDONY] = 0.2,
			[SHADOWCRYSTAL] = 0.2,
			[DARKJADE] = 0.2,
			[HUGECITRINE] = 0.2,
			[BLOODSTONE] = 0.2,
			[SUNCRYSTAL] = 0.2,

			[FORESTEMERALD] = 0.04,
			[SCARLETRUBY] = 0.04,
			[MONARCHTOPAZ] = 0.04,
			[SKYSAPPHIRE] = 0.04,
			[TWILIGHTOPAL] = 0.04,
			[AUTMNSGLOW] = 0.04,
			},

	[TITANIUM_ORE] = {
			[TITANIUMPOWDER] = 0.65,
			
			[CHALCEDONY] = 0.25,
			[SHADOWCRYSTAL] = 0.25,
			[DARKJADE] = 0.25,
			[HUGECITRINE] = 0.25,
			[BLOODSTONE] = 0.25,
			[SUNCRYSTAL] = 0.25,
			
			[FORESTEMERALD] = 0.04,
			[SCARLETRUBY] = 0.04,
			[MONARCHTOPAZ] = 0.04,
			[SKYSAPPHIRE] = 0.04,
			[TWILIGHTOPAL] = 0.04,
			[AUTMNSGLOW] = 0.04,
			
			[MAJESTICZIRCON] = 0.04,
			[AMETRINE] = 0.04,
			[KINGSAMBER] = 0.04,
			[DREADSTONE] = 0.04,
			[CARDINALRUBY] = 0.04,
			[EYEOFZUL] = 0.04,
			
			},

	[OBSIDIUM_ORE] = {						 -- ccox - this is guesswork!
			[CARNELIAN] = 0.25,
			[ZEPHYRITE] = 0.25,
			[ALICITE] = 0.25,
			[NIGHTSTONE] = 0.25,
			[HESSONITE] = 0.25,
			[JASPER] = 0.25,

			[INFERNORUBY] = 0.013,
			[OCEANSAPPHIRE] = 0.013,
			[DREAMEMERALD] = 0.013,
			[EMBERTOPAZ] = 0.013,
			[DEMONSEYE] = 0.013,
			[AMBERJEWEL] = 0.013,
			},

	[ELEMENTIUM_ORE] = {						 -- ccox - this is guesswork!
			[CARNELIAN] = 0.25,
			[ZEPHYRITE] = 0.25,
			[ALICITE] = 0.25,
			[NIGHTSTONE] = 0.25,
			[HESSONITE] = 0.25,
			[JASPER] = 0.25,

			[INFERNORUBY] = 0.013,
			[OCEANSAPPHIRE] = 0.013,
			[DREAMEMERALD] = 0.013,
			[EMBERTOPAZ] = 0.013,
			[DEMONSEYE] = 0.013,
			[AMBERJEWEL] = 0.013,
			},

}


-- list of ores from which each item could be prospected
-- copied from ProspectableItems

const.ReverseProspectingSources = {
	
	[TIGERSEYE] = { COPPER_ORE },
	[MALACHITE] = { COPPER_ORE },
	[SHADOWGEM] = { TIN_ORE, COPPER_ORE },
	
	[LESSERMOONSTONE] = { IRON_ORE, TIN_ORE },
	[MOSSAGATE] = { TIN_ORE },
	[CITRINE] = { MITHRIL_ORE, IRON_ORE, TIN_ORE },
	[JADE] = { IRON_ORE, TIN_ORE },
	[AQUAMARINE] = { MITHRIL_ORE, IRON_ORE, TIN_ORE },
	[STARRUBY] = { THORIUM_ORE, MITHRIL_ORE, IRON_ORE },
	
	[AZEROTHIANDIAMOND] = { THORIUM_ORE, MITHRIL_ORE },
	[BLUESAPPHIRE] = { THORIUM_ORE, MITHRIL_ORE },
	[LARGEOPAL] = { THORIUM_ORE, MITHRIL_ORE },
	[HUGEEMERALD] = { THORIUM_ORE, MITHRIL_ORE },
	
	[BLOODGARNET] = { ADAMANTITE_ORE, FEL_IRON_ORE, THORIUM_ORE },
	[FLAMESPESSARITE] = { ADAMANTITE_ORE, FEL_IRON_ORE, THORIUM_ORE },
	[GOLDENDRAENITE] = { ADAMANTITE_ORE, FEL_IRON_ORE, THORIUM_ORE },
	[DEEPPERIDOT] = { ADAMANTITE_ORE, FEL_IRON_ORE, THORIUM_ORE },
	[AZUREMOONSTONE] = { ADAMANTITE_ORE, FEL_IRON_ORE, THORIUM_ORE },
	[SHADOWDRAENITE] = { ADAMANTITE_ORE, FEL_IRON_ORE, THORIUM_ORE },
	
	[LIVINGRUBY] = { ADAMANTITE_ORE, FEL_IRON_ORE },
	[NOBLETOPAZ] = { ADAMANTITE_ORE, FEL_IRON_ORE },
	[DAWNSTONE] = { ADAMANTITE_ORE, FEL_IRON_ORE },
	[TALASITE] = { ADAMANTITE_ORE, FEL_IRON_ORE },
	[STAROFELUNE] = { ADAMANTITE_ORE, FEL_IRON_ORE },
	[NIGHTSEYE] = { ADAMANTITE_ORE, FEL_IRON_ORE },
	[ADAMANTITEPOWDER] = { ADAMANTITE_ORE },
	
	[CHALCEDONY] = { TITANIUM_ORE, SARONITE_ORE, COBALT_ORE },
	[HUGECITRINE] = { TITANIUM_ORE, SARONITE_ORE, COBALT_ORE },
	[BLOODSTONE] = { TITANIUM_ORE, SARONITE_ORE, COBALT_ORE },
	[SHADOWCRYSTAL] = { TITANIUM_ORE, SARONITE_ORE, COBALT_ORE },
	[SUNCRYSTAL] = { TITANIUM_ORE, SARONITE_ORE, COBALT_ORE },
	[DARKJADE] = { TITANIUM_ORE, SARONITE_ORE, COBALT_ORE },
	
	[TWILIGHTOPAL] = { TITANIUM_ORE, SARONITE_ORE, COBALT_ORE },
	[FORESTEMERALD] = { TITANIUM_ORE, SARONITE_ORE, COBALT_ORE },
	[SCARLETRUBY] = { TITANIUM_ORE, SARONITE_ORE, COBALT_ORE },
	[MONARCHTOPAZ] = { TITANIUM_ORE, SARONITE_ORE, COBALT_ORE },
	[SKYSAPPHIRE] = { TITANIUM_ORE, SARONITE_ORE, COBALT_ORE },
	[AUTMNSGLOW] = { TITANIUM_ORE, SARONITE_ORE, COBALT_ORE },
	
	[MAJESTICZIRCON] = { TITANIUM_ORE },
	[AMETRINE] = { TITANIUM_ORE },
	[KINGSAMBER] = { TITANIUM_ORE },
	[DREADSTONE] = { TITANIUM_ORE },
	[CARDINALRUBY] = { TITANIUM_ORE },
	[EYEOFZUL] = { TITANIUM_ORE },
	[TITANIUMPOWDER] = { TITANIUM_ORE },

	[CARNELIAN] = { OBSIDIUM_ORE, ELEMENTIUM_ORE },
	[ZEPHYRITE] = { OBSIDIUM_ORE, ELEMENTIUM_ORE },
	[ALICITE] = { OBSIDIUM_ORE, ELEMENTIUM_ORE },
	[NIGHTSTONE] = { OBSIDIUM_ORE, ELEMENTIUM_ORE },
	[HESSONITE] = { OBSIDIUM_ORE, ELEMENTIUM_ORE },
	[JASPER] = { OBSIDIUM_ORE, ELEMENTIUM_ORE },
	
	[INFERNORUBY] = { OBSIDIUM_ORE, ELEMENTIUM_ORE },
	[OCEANSAPPHIRE] = { OBSIDIUM_ORE, ELEMENTIUM_ORE },
	[DREAMEMERALD] = { OBSIDIUM_ORE, ELEMENTIUM_ORE },
	[EMBERTOPAZ] = { OBSIDIUM_ORE, ELEMENTIUM_ORE },
	[DEMONSEYE] = { OBSIDIUM_ORE, ELEMENTIUM_ORE },
	[AMBERJEWEL] = { OBSIDIUM_ORE, ELEMENTIUM_ORE },

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

