--[[
	Itemizer Addon for World of Warcraft(tm).
	Version: <%version%> (<%codename%>)
	Revision: $Id$

	Itemizer data storage and retrieval functions.
	Functions store and retrieve item tooltip info from the SavedVariables.

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
]]

local getItemData
local haveItemData
local storeItemData
local getItemVersion
local encodeItemData
local decodeItemData
local translateEnchant
local translateRandomProp

--Making a local copy of these extensively used functions will make their calling faster.
local type = type
local pairs = pairs
local ipairs = ipairs
local unpack = unpack
local tonumber = tonumber
local tostring = tostring
local strsub = string.sub
local strfind = string.find
local format = string.format

local splitString = Itemizer.Util.Split
local stringToTable = Itemizer.Util.StringToTable
local nilSafeNumber = Itemizer.Util.NilSafeNumber
local nilSafeString = Itemizer.Util.NilSafeString
local gameBuildNumber = Itemizer.Core.Constants.GameBuildNumber
local gameBuildNumberString = tostring(Itemizer.Core.Constants.GameBuildNumber)

--Just one table to be re-used
local itemInfo = {}


function getItemData(itemID, randomProp)
	itemID = tonumber(itemID)
	randomProp = tonumber(randomProp)

	if (not itemID) then
		return
	end

	local currentItem
	local haveItemID, haveRandomProp, randomPropInItem = haveItemData(itemID, randomProp)
	if (not randomPropInItem) then
		EnhTooltip.DebugPrint("Itemizer: WARNING randomProp not found in item", itemID, randomProp)
	end

	if (randomProp) then --We're looking for an "of the X" item
		if ((haveItemID) and (haveRandomProp)) then --Found!
			currentItem = ItemizerLinks[itemID]
			return decodeItemData(currentItem, randomProp)
		else --Item Not found
			return
		end
	else --We're looking for a standard item
		if (haveItemID) then --Found!
			currentItem = ItemizerLinks[itemID]
			return decodeItemData(currentItem, randomProp)
		else --Item not found
			return
		end
	end
end

function storeItemData(itemInfo)
	--Make itemInfo a required parameter, and make sure its a table
	if (not (type(itemInfo) == "table")) then
		return
	end

	local oldBaseInfo, currentItem
	local baseInfo, tooltip, baseData, basicStats, resists, requirements, equipBonuses, metaData = encodeItemData(itemInfo)

	if (itemInfo.randomProp) then --We need to treat these separately.
		local haveItemID, haveRandomProp, randomPropInItem = haveItemData(itemInfo.itemID, itemInfo.randomProp)
		EnhTooltip.DebugPrint("Itemizer: haveItemID", haveItemID, "haveRandomProp", haveRandomProp, "randomPropInItem", randomPropInItem, "ItemID", itemInfo.itemID, "randomProp", itemInfo.randomProp)
		if (not haveRandomProp) then
			Itemizer.Util.ChatPrint("Itemizer does not have this randomProp in its cache tables:", itemInfo.randomProp, "Please update your copy of Itemizer.") --%Localize%
			return
		end

		if (haveItemID and randomPropInItem) then --Refresh data.

			currentItem = ItemizerLinks[itemInfo.itemID]

			--We don't want to reset the randomProp posibilities, so the basicData field is left alone.
			currentItem[2] = tooltip;
			currentItem[3] = baseData;
			currentItem[4] = basicStats;
			currentItem[5] = resists;
			currentItem[6] = requirements;
			currentItem[7] = equipBonuses;
			currentItem[8] = metaData;

		elseif (haveItemID) then --Add new randomProp to existing itemID table.
			--Start by adding the new randomProp to the baseInfo line
			oldBaseInfo = splitString(ItemizerLinks[itemInfo.itemID][1], "§")
			local formatString = "%s"
			oldBaseInfo[1] = itemInfo.itemBaseName
			oldBaseInfo[2] = (tonumber(oldBaseInfo[2]) or 0) + 1

			table.insert(oldBaseInfo, itemInfo.randomProp)
			for key, value in ipairs(oldBaseInfo) do
				if (key > 1) then
					formatString = formatString.."§%d"
				end
			end

			infoLine = format(formatString, unpack(oldBaseInfo))
			ItemizerLinks[itemInfo.itemID] = {}
			currentItem = ItemizerLinks[itemInfo.itemID]
			currentItem[1] = infoLine

			currentItem[2] = tooltip;
			currentItem[3] = baseData;
			currentItem[4] = basicStats;
			currentItem[5] = resists;
			currentItem[6] = requirements;
			currentItem[7] = equipBonuses;
			currentItem[8] = metaData;

		else -- Completely new item
			ItemizerLinks[itemInfo.itemID] = {}
			currentItem = ItemizerLinks[itemInfo.itemID]
			currentItem[1] = itemInfo.itemBaseName.."§1§"..itemInfo.randomProp

			currentItem[2] = tooltip;
			currentItem[3] = baseData;
			currentItem[4] = basicStats;
			currentItem[5] = resists;
			currentItem[6] = requirements;
			currentItem[7] = equipBonuses;
			currentItem[8] = metaData;
		end

	else --Item with no current randomProp
		ItemizerLinks[itemInfo.itemID] = {}
		currentItem = ItemizerLinks[itemInfo.itemID]

		currentItem[1] = baseInfo
		currentItem[2] = tooltip;
		currentItem[3] = baseData;
		currentItem[4] = basicStats;
		currentItem[5] = resists;
		currentItem[6] = requirements;
		currentItem[7] = equipBonuses;
		currentItem[8] = metaData;
	end
end

--Use this function to query if we have info for a certain item or not.
function haveItemData(itemID, randomProp)
	--No parameters, no returns
	if (not itemID) then
		return
	end

	itemID = tonumber(itemID);
	randomProp = tonumber(randomProp);

	if (itemID) then
		--Two parameters, two returns
		if (randomProp) then
			if ((ItemizerLinks[itemID]) and (ItemizerRandomProps[randomProp])) then

				-- Must find out if the data for this itemID randomProp combination is already stored.
				local itemBaseInfo = splitString(ItemizerLinks[itemID][1], "§")
				for key, value in ipairs(itemBaseInfo) do
					value = tonumber(value)
					if (value and (value == randomProp)) then
						return true, true, true
					end
				end
				return true, true, false

			elseif (ItemizerRandomProps[randomProp]) then
				return false, true

			else
				return false, false
			end

		--One parameter, one return
		elseif (ItemizerLinks[itemID]) then
			return true
		else
			return false
		end
	else
		return false
	end
end

function getItemVersion(itemID, randomProp)
	itemID = tonumber(itemID)
	if (not itemID) then
		return
	end

	local haveItemID, haveRandomProp, randomPropInItem = haveItemData(itemID, randomProp)

	if (not haveItemID) then
		return
	end

	local itemData = ItemizerLinks[itemID]
	if (not (itemData and itemData[8])) then
		return
	end

	local itemMetaData = Itemizer.Util.Split(itemData[8], "§")


	return tonumber(itemMetaData[1]), (tonumber(itemMetaData[1]) == gameBuildNumber), randomPropInItem
end

function encodeItemData(itemInfo)
	--Make itemInfo a required parameter, and make sure its a table
	if (not (type(itemInfo) == "table")) then
		return
	end

	local baseInfo, tooltip, baseData, basicStats, resists, requirements, equipBonuses, metaData

	--Slight speed optimizations
	local attribs = itemInfo.attributes;
	local resistsTable = attribs.resists;
	local basicTable = attribs.basicStats;
	local bonusesTable = attribs.equipBonuses;

	baseInfo = itemInfo.itemBaseName

	--Build tooltips
	local first = true
	local itemIsSetitem = false
	local possibleSetItem = false
	if (itemInfo.tooltip.leftText) then
		for key, value in ipairs(itemInfo.tooltip.leftText) do

			--Only store the tooltip line if it was not successfully parsed.
			if (not strfind(value, "¶")) then

				--Stop the encoding process if we reach a newline character that means that set or crafted item info is next.
				if (strfind(value, "\n")) then
					break
				end

				if (first) then
					tooltip = key.."¶"..value;
					first = false;

				else
					tooltip = tooltip.."§"..key.."¶"..value;
				end
			end
		end
	end

	first = true
	if (itemInfo.tooltip.rightText) then
		for key, value in ipairs(itemInfo.tooltip.rightText) do

			--Only store the tooltip line if it was not successfully parsed.
			if (not strfind(value, "¶")) then

				if (first) then
					tooltip = nilSafeString(tooltip).."®"..key.."¶"..value;
					first = false;

				else
					tooltip = tooltip.."§"..key.."¶"..value;
				end
			end
		end
	end

	--Store info from GetItemInfo()
	baseData = strsub(itemInfo.itemEquipLocation, 9); --Trim the reduntant "INVTYPE_" from the equip location.
	baseData = baseData.."§"..nilSafeString(itemInfo.itemQuality).."§"..nilSafeString(itemInfo.itemLevel).."§"..nilSafeString(itemInfo.itemType).."§"..nilSafeString(itemInfo.itemSubType)

	--Store unique status
	if (itemInfo.isUnique) then
		baseData = baseData.."§1";
	else
		baseData = baseData.."§";
	end

	--Store binds data
	baseData = baseData.."§"..nilSafeString(itemInfo.binds);

	-- Store type specific information
	local equipLoc = strsub(itemInfo.itemEquipLocation, 9); --Trim the reduntant "INVTYPE_" from the equip location.
	if (equipLoc == "WEAPONMAINHAND"
	or equipLoc == "WEAPONOFFHAND"
	or equipLoc == "RANGEDRIGHT"
	or equipLoc == "2HWEAPON"
	or equipLoc == "THROWN"
	or equipLoc == "RANGED") then --Store Weapon stats
		--Min and max damage
		baseData = baseData.."§"..nilSafeNumber(attribs.itemMinDamage).."§"..nilSafeNumber(attribs.itemMaxDamage);
		--Speed and DPS
		baseData = baseData.."§"..nilSafeNumber(attribs.itemSpeed).."§"..nilSafeNumber(attribs.itemDPS);

		--Armor and block values (if available)
		if (attribs.itemArmor) then
			baseData = baseData.."§"..nilSafeNumber(attribs.itemArmor);

			if (attribs.itemBlock) then
				baseData = baseData.."§"..nilSafeNumber(attribs.itemBlock);
			end
		end

	elseif (equipLoc == "BAG") then --Store BagSize
		baseData = baseData.."§"..nilSafeNumber(attribs.bagSize);

	else --Store Armor stats

		--Armor and block values (if available)
		if (attribs.itemArmor) then
			baseData = baseData.."§"..nilSafeNumber(attribs.itemArmor);

			if (attribs.itemBlock) then
				baseData = baseData.."§"..nilSafeNumber(attribs.itemBlock);
			end
		end
	end


	--Now for the basic item stats (Agility, Stam, etc)
	if (basicTable) then
		basicStats = "";
		--Agility and Health
		basicStats = basicStats..nilSafeString(basicTable.agility).."§"..nilSafeString(basicTable.health);
		--Intellect and Mana
		basicStats = basicStats.."§"..nilSafeString(basicTable.intellect).."§"..nilSafeString(basicTable.mana);
		--Spirit and Stamina
		basicStats = basicStats.."§"..nilSafeString(basicTable.spirit).."§"..nilSafeString(basicTable.stamina);
		--Strength and Defense
		basicStats = basicStats.."§"..nilSafeString(basicTable.strength).."§"..nilSafeString(basicTable.defense);
	end

	--Resists are next
	if (resistsTable) then
		resists = "";
		--Fire and Frost
		resists = resists..nilSafeString(resistsTable.fire).."§"..nilSafeString(resistsTable.frost);
		--Arcane and Shadow
		resists = resists.."§"..nilSafeString(resistsTable.arcane).."§"..nilSafeString(resistsTable.shadow);
		--Nature
		resists = resists.."§"..nilSafeString(resistsTable.nature);
	end

	--Required stuff (Classes, Professions, etc)
	first = true
	if (attribs.classes) then
		for key, value in pairs(attribs.classes) do

			if (first) then
				requirements = value;
				first = false;

			else
				requirements = requirements.."¶"..value;
			end
		end
	end

	first = true
	if (attribs.skills) then
		for key, value in pairs(attribs.skills) do

			if (first) then
				requirements = nilSafeString(requirements).."®"..key.."¶"..value;
				first = false;

			else
				requirements = requirements.."§"..key.."¶"..value;
			end
		end
	end

	--Equip Bonuses are next
	first = true
	if (bonusesTable) then
		for key, value in pairs(bonusesTable) do

			if (first) then
				equipBonuses = key.."¶"..value;
				first = false;

			else
				equipBonuses = equipBonuses.."§"..key.."¶"..value;
			end
		end
	end

	--And finally encode the item's metadata
	metaData = gameBuildNumberString

	local setName = itemInfo.setName
	if (setName) then
		local setNameHash = Itemizer.Util.HashText(setName)

		metaData = metaData.."§"..setNameHash
		ItemizerSets[setNameHash] = setName
	end

	return baseInfo, tooltip, baseData, basicStats, resists, requirements, equipBonuses, metaData
end

function decodeItemData(item, randomProp) --%Todo% Finish this
	--Make itemID a required parameter, and make sure its a table
	if (not (type(item) == "table")) then
		EnhTooltip.DebugPrint("Itemizer: error in decodeItemData()", itemID, randomProp)
		return
	end
	
	itemInfo = clearTable(itemInfo)
	if (not (type(itemInfo) == "table")) then
		EnhTooltip.DebugPrint("Itemizer: decodeItemData() error", "itemInfo type", type(itemInfo), link)
		itemInfo = {}
	end

	if (not itemInfo.tooltip) then
		itemInfo.tooltip = {}
	end
	if (not itemInfo.tooltip.leftText) then
		itemInfo.tooltip.leftText = {}
	end
	if (not itemInfo.tooltip.rightText) then
		itemInfo.tooltip.rightText = {}
	end
	if (not itemInfo.attributes) then
		itemInfo.attributes = {}
	end
	if (not itemInfo.attributes.skills) then
		itemInfo.attributes.skills = {}
	end
	if (not itemInfo.attributes.resists) then
		itemInfo.attributes.resists = {}
	end
	if (not itemInfo.attributes.basicStats) then
		itemInfo.attributes.basicStats = {}
	end
	if (not itemInfo.attributes.equipBonuses) then
		itemInfo.attributes.equipBonuses = {}
	end

	randomProp = tonumber(randomProp)

	local metaData = item[8]
	local equipBonuses = item[7]
	local requirements = item[6]
	local resists = item[5]
	local basicStats = item[4]
	local baseData = item[3]
	local tooltip = item[2]
	local baseInfo = item[1]

	--We will decode backwards from how we encoded
	
	--metaData first
	if (strfind(metaData, "§")) then
		local splitMeta = splitString(metaData, "§")
		itemInfo.setName = ItemizerSets[splitMeta[2]]
	end

	--Equip Bonuses are next
	if (equipBonuses) then
		itemInfo.attributes.equipBonuses = stringToTable(equipBonuses, "§", "¶")
	end

	--Required stuff (Classes, Professions, etc)
	if (requirements) then
		local splitReqs = splitString(requirements, "®")
		if (splitReqs[2]) then
			itemInfo.attributes.skills = stringToTable(splitReqs[2], "§", "¶")
		end

		itemInfo.attributes.skills = stringToTable(splitReqs[1], "¶")
	end
	
	--Resists are next
	if (resists) then
		local splitResists = splitString(resists, "§")

		itemInfo.attributes.resists.fire = splitResists[1]
		itemInfo.attributes.resists.frost = splitResists[2]
		itemInfo.attributes.resists.arcane = splitResists[3]
		itemInfo.attributes.resists.shadow = splitResists[4]
		itemInfo.attributes.resists.nature = splitResists[5]
	end
	
	--Now for the basic item stats (Agility, Stam, etc)
	if (basicStats) then
		local splitBasic = splitString(basicStats, "§")

		itemInfo.attributes.basicStats.agility = splitBasic[1]
		itemInfo.attributes.basicStats.health = splitBasic[1]
		itemInfo.attributes.basicStats.intellect = splitBasic[1]
		itemInfo.attributes.basicStats.mana = splitBasic[1]
		itemInfo.attributes.basicStats.spirit = splitBasic[1]
		itemInfo.attributes.basicStats.stamina = splitBasic[1]
		itemInfo.attributes.basicStats.strength = splitBasic[1]
		itemInfo.attributes.basicStats.defense = splitBasic[1]
	end

	return itemInfo
end

function translateRandomProp(randomProp)
	randomProp = tonumber(randomProp)
	if (not randomProp) then
		return
	end

	local properties = ItemizerRandomProps[randomProp]
	if (not properties) then
		return
	end

	local propsTable = Itemizer.Util.Split(properties, ":")
	local name, enchant1, enchant2, enchant3 = unpack(propsTable)
	name = ItemizerSuffixes[tonumber(name)]
	enchant1 = tonumber(enchant1)
	enchant2 = tonumber(enchant2)
	enchant3 = tonumber(enchant3)

	local enchant1Table = ItemizerEnchants[enchant1]
	local enchant2Table = ItemizerEnchants[enchant2]
	local enchant3Table = ItemizerEnchants[enchant3]


	return name, (translateEnchant(enchant1Table)), (translateEnchant(enchant2Table)), (translateEnchant(enchant3Table))
end

function translateEnchant(enchantTable)
	if (not (type(enchantTable) == "table")) then
		return
	end

	local enchantIdentifiers = Itemizer.Util.Split(enchantTable[2], "-")
	local quantity = enchantTable[1]
	local modifierType
	local formatString
	local tooltipLine
	local inverted

	--First translate the class of modifier (Spell Damage, Stats, etc)
	if (enchantIdentifiers[1] == "Ba") then
		formatString = "+%d %s" --%Localize%
	elseif  (enchantIdentifiers[1] == "OH") then
		formatString = "%s Skill +%d" --%Localize%
		inverted= true
	elseif  (enchantIdentifiers[1] == "TH") then
		formatString = "Two-Handed %s Skill +%d" --%Localize%
		inverted= true
	elseif  (enchantIdentifiers[1] == "Sl") then
		formatString = "+%d %s Slaying" --%Localize%
	elseif  (enchantIdentifiers[1] == "Re") then
		formatString = "+%d %s Resistance" --%Localize%
	elseif  (enchantIdentifiers[1] == "Atk") then
		formatString = "+%d %sAttack Power" --%Localize%
	elseif  (enchantIdentifiers[1] == "Sp") then -- These are a bit complicated
		if (enchantIdentifiers[2] == "Hea" or enchantIdentifiers[2] == "D&H") then
			formatString = "+%d %s Spells" --%Localize%
		else
			formatString = "+%d %s Spell Damage" --%Localize%
		end
	elseif  (enchantIdentifiers[1] == "P5") then
		formatString = "+%d %s every 5 sec." --%Localize%
	end

	--Then translate the type of modifier (Fire, Spirit, etc.)

	--Stats
	if (enchantIdentifiers[2] == "Dam") then
		modifierType = "Damage" --%Localize%
	elseif  (enchantIdentifiers[2] == "Str") then
		modifierType = "Strength" --%Localize%
	elseif  (enchantIdentifiers[2] == "Sta") then
		modifierType = "Stamina" --%Localize%
	elseif  (enchantIdentifiers[2] == "Agi") then
		modifierType = "Agility" --%Localize%
	elseif  (enchantIdentifiers[2] == "Int") then
		modifierType = "Intellect" --%Localize%
	elseif  (enchantIdentifiers[2] == "Arm") then
		modifierType = "Armor" --%Localize%
	elseif  (enchantIdentifiers[2] == "Spi") then
		modifierType = "Spirit" --%Localize%
	elseif  (enchantIdentifiers[2] == "Def") then
		modifierType = "Defense" --%Localize%

	--Weapons
	elseif  (enchantIdentifiers[2] == "Swo") then
		modifierType = "Sword" --%Localize%
	elseif  (enchantIdentifiers[2] == "Mac") then
		modifierType = "Mace" --%Localize%
	elseif  (enchantIdentifiers[2] == "Axe") then
		modifierType = "Axe" --%Localize%
	elseif  (enchantIdentifiers[2] == "Dag") then
		modifierType = "Dagger" --%Localize%
	elseif  (enchantIdentifiers[2] == "Gun") then
		modifierType = "Gun" --%Localize%
	elseif  (enchantIdentifiers[2] == "Bow") then
		modifierType = "Bow" --%Localize%

	--Mob types
	elseif  (enchantIdentifiers[2] == "Bea") then
		modifierType = "Beast" --%Localize%

	--Magic Types
	elseif  (enchantIdentifiers[2] == "Arc") then
		modifierType = "Arcane" --%Localize%
	elseif  (enchantIdentifiers[2] == "Fro") then
		modifierType = "Frost" --%Localize%
	elseif  (enchantIdentifiers[2] == "Fir") then
		modifierType = "Fire" --%Localize%
	elseif  (enchantIdentifiers[2] == "Nat") then
		modifierType = "Nature" --%Localize%
	elseif  (enchantIdentifiers[2] == "Sha") then
		modifierType = "Shadow" --%Localize%
	elseif  (enchantIdentifiers[2] == "Hol") then
		modifierType = "Holy" --%Localize%
	elseif  (enchantIdentifiers[2] == "Hea") then
		modifierType = "Healing" --%Localize%
	elseif  (enchantIdentifiers[2] == "D&H") then
		modifierType = "Damage and Healing" --%Localize%

	--Attack Types
	elseif  (enchantIdentifiers[2] == "Mel") then
		modifierType = "" --%Localize%
	elseif  (enchantIdentifiers[2] == "Ran") then
		modifierType = "Ranged " --%Localize%

	--Health and Mana
	elseif  (enchantIdentifiers[2] == "Het") then
		modifierType = "health" --%Localize%
	elseif  (enchantIdentifiers[2] == "Man") then
		modifierType = "mana" --%Localize%
	end

	--Now build the string
	if (inverted) then
		tooltipLine = format(formatString, modifierType, quantity)
	else
		tooltipLine = format(formatString, quantity, modifierType)
	end

	--We're Done!
	return tooltipLine, quantity
end

Itemizer.Storage = {
	GetItemData = getItemData,
	HaveItemData = haveItemData,
	StoreItemData = storeItemData,
	GetItemVersion = getItemVersion,
	EncodeItemData = encodeItemData,
	DecodeItemData = decodeItemData,
	TranslateEnchant = translateEnchant,
	TranslateRandomProp = translateRandomProp,
}
