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
local getItemRandomProps
local translateRandomProp
local getEnchantComponents
local getRandomPropComponents
local addRandomPropStatsToTable

--Making a local copy of these extensively used functions will make their lookup faster.
local type = type;
local pairs = pairs;
local ipairs = ipairs;
local unpack = unpack;
local tonumber = tonumber;
local tostring = tostring;
local strsub = string.sub;
local strfind = string.find;
local format = string.format;
local tinsert = table.insert;

local hashText = Itemizer.Util.HashText;
local splitString = Itemizer.Util.Split;
local nilTable = Itemizer.Util.NilTable;
local buildLink = Itemizer.Util.BuildLink;
local clearTable = Itemizer.Util.ClearTable;
local pruneTable = Itemizer.Util.PruneTable;
local stringToTable = Itemizer.Util.StringToTable;
local nilSafeNumber = Itemizer.Util.NilSafeNumber;
local nilSafeString = Itemizer.Util.NilSafeString;
local nilEmptyString = Itemizer.Util.NilEmptyString;
local gameBuildNumber = Itemizer.Core.Constants.GameBuildNumber;
local gameBuildNumberString = Itemizer.Core.Constants.GameBuildNumberString;

--Just one table to be re-used
local randomPropsTable = {}


function getItemData(itemID, randomProp, internalCall)
	itemID = tonumber(itemID);
	randomProp = tonumber(randomProp);

	if (not itemID) then
		return;
	end

	local currentItem = ItemizerLinks[itemID];

	if (internalCall) then
		return decodeItemData(currentItem, itemID, randomProp);
	end

	local haveItemID, haveRandomProp, randomPropInItem = haveItemData(itemID, randomProp)
	if (not randomPropInItem) then
		EnhTooltip.DebugPrint("Itemizer: WARNING randomProp not found in item", itemID, randomProp);
	end

	if (randomProp) then --We're looking for an "of the X" item
		if ((haveItemID) and (haveRandomProp)) then --Found!
			return decodeItemData(currentItem, itemID, randomProp);
		else --Item Not found
			return;
		end
	else --We're looking for a standard item
		if (haveItemID) then --Found!
			return decodeItemData(currentItem, itemID, randomProp);
		else --Item not found
			return;
		end
	end
end

function getItemRandomProps(itemID)
	itemID = tonumber(itemID);

	if (not itemID) then
		return;
	end

	randomPropsTable = clearTable(randomPropsTable)
	if (not (type(randomPropsTable) == "table")) then
		EnhTooltip.DebugPrint("Itemizer: getItemRandomProps() error", "itemInfo type", type(randomPropsTable), itemID);
		randomPropsTable = {};
	end

	local itemBaseInfo = splitString(ItemizerLinks[itemID][1], "§");
	for key, value in ipairs(itemBaseInfo) do
		tinsert(randomPropsTable, tonumber(value))
	end

	--Only return the table if it has something in it.
	if (next(randomPropsTable)) then
		return randomPropsTable;
	else
		return;
	end
end

function storeItemData(itemInfo)
	--Make itemInfo a required parameter, and make sure its a table
	if (not (type(itemInfo) == "table")) then
		return;
	end

	local oldBaseInfo, currentItem
	local baseInfo, tooltip, baseData, basicStats, resists, requirements, equipBonuses, metaData = encodeItemData(itemInfo);

	if (itemInfo.randomProp) then --We need to treat these separately.
		local haveItemID, haveRandomProp, randomPropInItem = haveItemData(itemInfo.itemID, itemInfo.randomProp);
		if (not haveRandomProp) then
			Itemizer.Util.ChatPrint("Itemizer does not have this randomProp in its cache tables: \""..tostring(itemInfo.randomProp).."\" (From "..itemInfo.itemLink..").\n    Please update your copy of Itemizer."); --%Localize%
			return;
		end

		if (haveItemID and randomPropInItem) then --Refresh data.

			currentItem = ItemizerLinks[itemInfo.itemID];

			--We don't want to reset the randomProp posibilities, so the baseData field is left alone.
			currentItem[2] = tooltip;
			currentItem[3] = baseData;
			currentItem[4] = basicStats;
			currentItem[5] = resists;
			currentItem[6] = requirements;
			currentItem[7] = equipBonuses;
			currentItem[8] = metaData;

		elseif (haveItemID) then --Add new randomProp to existing itemID table.
			--Start by adding the new randomProp to the baseInfo line
			oldBaseInfo = splitString(ItemizerLinks[itemInfo.itemID][1], "§");
			local formatString = "%s";
			oldBaseInfo[1] = itemInfo.itemBaseName;
			oldBaseInfo[2] = (tonumber(oldBaseInfo[2]) or 0) + 1;

			table.insert(oldBaseInfo, itemInfo.randomProp);
			for key, value in ipairs(oldBaseInfo) do
				if (key > 1) then
					formatString = formatString.."§%d";
				end
			end

			local infoLine = format(formatString, unpack(oldBaseInfo));
			ItemizerLinks[itemInfo.itemID] = {};
			currentItem = ItemizerLinks[itemInfo.itemID];
			currentItem[1] = infoLine;

			currentItem[2] = tooltip;
			currentItem[3] = baseData;
			currentItem[4] = basicStats;
			currentItem[5] = resists;
			currentItem[6] = requirements;
			currentItem[7] = equipBonuses;
			currentItem[8] = metaData;

		else -- Completely new item
			ItemizerLinks[itemInfo.itemID] = {};
			currentItem = ItemizerLinks[itemInfo.itemID];
			currentItem[1] = itemInfo.itemBaseName.."§1§"..itemInfo.randomProp;

			currentItem[2] = tooltip;
			currentItem[3] = baseData;
			currentItem[4] = basicStats;
			currentItem[5] = resists;
			currentItem[6] = requirements;
			currentItem[7] = equipBonuses;
			currentItem[8] = metaData;
		end

	else --Item with no current randomProp
		ItemizerLinks[itemInfo.itemID] = {};
		currentItem = ItemizerLinks[itemInfo.itemID];

		currentItem[1] = baseInfo
		currentItem[2] = tooltip;
		currentItem[3] = baseData;
		currentItem[4] = basicStats;
		currentItem[5] = resists;
		currentItem[6] = requirements;
		currentItem[7] = equipBonuses;
		currentItem[8] = metaData;
	end
	
	Itemizer.GUI.AddItemToItemList(itemInfo.itemID, itemInfo.randomProp);
end

--Use this function to query if we have info for a certain item or not.
function haveItemData(itemID, randomProp)
	--No parameters, no returns
	if (not itemID) then
		return;
	end

	itemID = tonumber(itemID);
	randomProp = tonumber(randomProp);

	if (itemID) then
		--Two parameters, two returns
		if (randomProp) then
			if ((ItemizerLinks[itemID]) and (ItemizerRandomProps[randomProp])) then

				-- Must find out if the data for this itemID randomProp combination is already stored.
				local itemBaseInfo = splitString(ItemizerLinks[itemID][1], "§");
				for key, value in ipairs(itemBaseInfo) do
					value = tonumber(value);
					if (value and (value == randomProp)) then
						return true, true, true;
					end
				end
				return true, true, false;

			elseif (ItemizerRandomProps[randomProp]) then
				return false, true;

			else
				return false, false;
			end

		--One parameter, one return
		elseif (ItemizerLinks[itemID]) then
			return true;
		else
			return false;
		end
	else
		return false;
	end
end

function getItemVersion(itemID, randomProp)
	itemID = tonumber(itemID)
	if (not itemID) then
		return;
	end

	local haveItemID, haveRandomProp, randomPropInItem = haveItemData(itemID, randomProp);

	if (not haveItemID) then
		return;
	end

	local itemData = ItemizerLinks[itemID]
	if (not (itemData and itemData[8])) then
		return;
	end

	local itemMetaData = Itemizer.Util.Split(itemData[8], "§");
	local itemBuildNumber = tonumber(itemMetaData[1]);

	return itemBuildNumber, (itemBuildNumber == gameBuildNumber), randomPropInItem;
end

function encodeItemData(itemInfo)
	--Make itemInfo a required parameter, and make sure its a table
	if (not (type(itemInfo) == "table")) then
		return;
	end

	local baseInfo, tooltip, baseData, basicStats, resists, requirements, equipBonuses, metaData

	--Slight speed optimizations
	local attribs = itemInfo.attributes;
	local resistsTable = attribs.resists;
	local basicTable = attribs.basicStats;
	local bonusesTable = attribs.equipBonuses;

	baseInfo = itemInfo.itemBaseName;

	--Build tooltips
	local first = true
	if (itemInfo.tooltip.leftText) then
		for key, value in ipairs(itemInfo.tooltip.leftText) do

			--Only store the tooltip line if it was not successfully parsed.
			if (not strfind(value, "¶")) then

				--Stop the encoding process if we reach a newline character that means that set or crafted item info is next.
				if (strfind(value, "\n")) then
					break;
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
	baseData = baseData.."§"..nilSafeString(itemInfo.itemQuality).."§"..nilSafeString(itemInfo.minLevel).."§"..nilSafeString(itemInfo.itemType).."§"..nilSafeString(itemInfo.itemSubType);

	--Store unique status
	if (itemInfo.isUnique) then
		baseData = baseData.."§1";
	else
		baseData = baseData.."§0";
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
	metaData = itemInfo.itemRevision;

	local setName = itemInfo.setName
	if (setName) then
		local setNameHash = hashText(setName);

		metaData = metaData.."§"..setNameHash;
		addItemSetName(setName, setNameHash);
	end

	return baseInfo, tooltip, baseData, basicStats, resists, requirements, equipBonuses, metaData;
end

function decodeItemData(item, itemID, randomProp) --%Todo% Finish this
	--Make itemID a required parameter, and make sure its a table
	if (not (type(item) == "table")) then
		EnhTooltip.DebugPrint("Itemizer: error in decodeItemData()", itemID, randomProp);
		return;
	end

	--Unfortunately we can't reuse tables here.
	local itemInfo = {};
	itemInfo.tooltip = {};
	itemInfo.tooltip.leftText = {};
	itemInfo.tooltip.rightText = {};
	itemInfo.attributes = {};
	itemInfo.attributes.skills = {};
	itemInfo.attributes.resists = {};
	itemInfo.attributes.basicStats = {};
	itemInfo.attributes.equipBonuses = {};

	randomProp = tonumber(randomProp);

	local metaData = item[8];
	local equipBonuses = item[7];
	local requirements = item[6];
	local resists = item[5];
	local basicStats = item[4];
	local baseData = item[3];
	local tooltip = item[2];
	local baseInfo = item[1];

	--We will decode backwards from how we encoded

	--MetaData first
	if (strfind(metaData, "§")) then
		local splitMeta = splitString(metaData, "§");
		itemInfo.setName = ItemizerSets[splitMeta[2]];
		itemInfo.itemRevision = tonumber(splitMeta[1]);
	else
		itemInfo.itemRevision = tonumber(metaData);
	end

	--Equip Bonuses are next
	if (equipBonuses) then
		itemInfo.attributes.equipBonuses = stringToTable(equipBonuses, "§", "¶");
	end

	--Required stuff (Classes, Professions, etc)
	if (requirements) then
		local splitReqs = splitString(requirements, "®");
		if (splitReqs[2]) then
			itemInfo.attributes.skills = stringToTable(splitReqs[2], "§", "¶");
		end

		itemInfo.attributes.skills = stringToTable(splitReqs[1], "¶");
	end

	--Resists are next
	if (resists) then
		local splitResists = splitString(resists, "§");

		itemInfo.attributes.resists.fire = tonumber(splitResists[1]);
		itemInfo.attributes.resists.frost = tonumber(splitResists[2]);
		itemInfo.attributes.resists.arcane = tonumber(splitResists[3]);
		itemInfo.attributes.resists.shadow = tonumber(splitResists[4]);
		itemInfo.attributes.resists.nature = tonumber(splitResists[5]);
	end

	--Now for the basic item stats (Agility, Stam, etc)
	if (basicStats) then
		local splitBasic = splitString(basicStats, "§");

		itemInfo.attributes.basicStats.agility = tonumber(splitBasic[1]);
		itemInfo.attributes.basicStats.health = tonumber(splitBasic[2]);
		itemInfo.attributes.basicStats.intellect = tonumber(splitBasic[3]);
		itemInfo.attributes.basicStats.mana = tonumber(splitBasic[4]);
		itemInfo.attributes.basicStats.spirit = tonumber(splitBasic[5]);
		itemInfo.attributes.basicStats.stamina = tonumber(splitBasic[6]);
		itemInfo.attributes.basicStats.strength = tonumber(splitBasic[7]);
		itemInfo.attributes.basicStats.defense = tonumber(splitBasic[8]);
	end

	-- Base data is next
	if (baseData) then
		local splitBase = splitString(baseData, "§");

		--Reintegrate the reduntant "INVTYPE_" to the equip location only if the item has an equipLocation.
		local equipLoc = splitBase[1];
		if (equipLoc == "") then
			itemInfo.itemEquipLocation = equipLoc;
		else
			itemInfo.itemEquipLocation = "INVTYPE_"..equipLoc;
		end

		--Retrieve info from GetItemInfo()
		itemInfo.itemQuality = splitBase[2];
		itemInfo.minLevel = splitBase[3];
		itemInfo.itemType = splitBase[4];
		itemInfo.itemSubType = splitBase[5];

		--Retrieve unique status
		itemInfo.isUnique = tonumber(splitBase[6]);

		--Retrieve binds data
		itemInfo.binds = tonumber(splitBase[7]);

		-- Retrieve type specific information
		if (equipLoc == "WEAPONMAINHAND"
		or equipLoc == "WEAPONOFFHAND"
		or equipLoc == "RANGEDRIGHT"
		or equipLoc == "2HWEAPON"
		or equipLoc == "THROWN"
		or equipLoc == "RANGED") then --Retrieve Weapon stats
			--Min and max damage
			itemInfo.attributes.itemMinDamage = nilEmptyString(splitBase[8]);
			itemInfo.attributes.itemMaxDamage = nilEmptyString(splitBase[9]);

			--Speed and DPS
			itemInfo.attributes.itemSpeed = nilEmptyString(splitBase[10]);
			itemInfo.attributes.itemDPS = nilEmptyString(splitBase[11]);

			--Armor and block values (if available)
			itemInfo.attributes.itemArmor = nilEmptyString(splitBase[12]);
			itemInfo.attributes.itemBlock = nilEmptyString(splitBase[13]);

		elseif (equipLoc == "BAG") then --Retrieve BagSize
			itemInfo.attributes.bagSize = nilEmptyString(splitBase[8]);

		else --Retrieve Armor stats

			--Armor and block values (if available)
			itemInfo.attributes.itemArmor = nilEmptyString(splitBase[8]);
			itemInfo.attributes.itemBlock = nilEmptyString(splitBase[9]);
		end
	end


	--Decode the item's base name
	itemInfo.itemBaseName = splitString(baseInfo, "§")[1]

	-- Add the stats from the randomProp to our item's info table
	if (randomProp) then
		itemInfo = addRandomPropStatsToTable(iteminfo, randomProp);
	else
		itemInfo.itemName = itemInfo.itemBaseName;
	end

	--Retrieve the original itemLink and hyperLink
	local hyperLink = "item:"..itemID..":0:"..nilSafeNumber(randomProp)..":0";
	itemInfo.itemLink = buildLink(hyperLink, itemInfo.itemQuality, itemInfo.itemName);
	itemInfo.itemHyperLink = hyperLink;

	--%Todo% Write the Tooltip line reconstruction code.

	return pruneTable(itemInfo);
end

function addItemSetName(setName, setNameHash)
	setName = tostring(setName);
	setNameHash = tostring(setNameHash);

	ItemizerSets[setNameHash] = setName;
end

function getRandomPropComponents(randomProp)
	randomProp = tonumber(randomProp);
	if (not randomProp) then
		return;
	end

	local properties = ItemizerRandomProps[randomProp];
	if (not properties) then
		return;
	end

	local nameNumber, enchant1, enchant2, enchant3 = unpack(Itemizer.Util.Split(properties, ":"));

	return tonumber(nameNumber), tonumber(enchant1), tonumber(enchant2), tonumber(enchant3);
end

function translateRandomProp(randomProp)
	local nameNumber, enchant1, enchant2, enchant3 = getRandomPropComponents(randomProp);

	return ItemizerSuffixes[nameNumber], translateEnchant(getEnchantComponents(ItemizerEnchants[enchant1])), translateEnchant(getEnchantComponents(ItemizerEnchants[enchant2])), translateEnchant(getEnchantComponents(ItemizerEnchants[enchant3]));
end

function getEnchantComponents(enchantTable)
	if (not (type(enchantTable) == "table")) then
		return;
	end

	local _, _, enchantType, enchantModifier = strfind(enchantTable[2], "(.+)-(.+)");
	local quantity = enchantTable[1];

	return enchantType, enchantModifier, quantity;
end

function translateEnchant(enchantType, enchantModifier, quantity)
	if (not (enchantType and enchantModifier and quantity)) then
		return;
	end

	local modifierType
	local formatString
	local tooltipLine
	local inverted

	--First translate the class of modifier (Spell Damage, Stats, etc)
	if (enchantType == "Ba") then
		formatString = "+%d %s"; --%Localize%
	elseif  (enchantType == "OH") then
		formatString = "%s Skill +%d"; --%Localize%
		inverted= true;
	elseif  (enchantType == "TH") then
		formatString = "Two-Handed %s Skill +%d"; --%Localize%
		inverted= true;
	elseif  (enchantType == "Sl") then
		formatString = "+%d %s Slaying"; --%Localize%
	elseif  (enchantType == "Re") then
		formatString = "+%d %s Resistance"; --%Localize%
	elseif  (enchantType == "Atk") then
		formatString = "+%d %sAttack Power"; --%Localize%
	elseif  (enchantType == "Sp") then -- These are a bit complicated
		if (enchantModifier == "Hea" or enchantModifier == "D&H") then
			formatString = "+%d %s Spells"; --%Localize%
		else
			formatString = "+%d %s Spell Damage"; --%Localize%
		end
	elseif  (enchantType == "P5") then
		formatString = "+%d %s every 5 sec."; --%Localize%
	end

	--Then translate the type of modifier (Fire, Spirit, etc.)

	--Stats
	if (enchantModifier == "Dam") then
		modifierType = "Damage"; --%Localize%
	elseif  (enchantModifier == "Str") then
		modifierType = "Strength"; --%Localize%
	elseif  (enchantModifier == "Sta") then
		modifierType = "Stamina"; --%Localize%
	elseif  (enchantModifier == "Agi") then
		modifierType = "Agility"; --%Localize%
	elseif  (enchantModifier == "Int") then
		modifierType = "Intellect"; --%Localize%
	elseif  (enchantModifier == "Arm") then
		modifierType = "Armor"; --%Localize%
	elseif  (enchantModifier == "Spi") then
		modifierType = "Spirit"; --%Localize%
	elseif  (enchantModifier == "Def") then
		modifierType = "Defense"; --%Localize%

	--Weapons
	elseif  (enchantModifier == "Swo") then
		modifierType = "Sword"; --%Localize%
	elseif  (enchantModifier == "Mac") then
		modifierType = "Mace"; --%Localize%
	elseif  (enchantModifier == "Axe") then
		modifierType = "Axe"; --%Localize%
	elseif  (enchantModifier == "Dag") then
		modifierType = "Dagger"; --%Localize%
	elseif  (enchantModifier == "Gun") then
		modifierType = "Gun"; --%Localize%
	elseif  (enchantModifier == "Bow") then
		modifierType = "Bow"; --%Localize%

	--Mob types
	elseif  (enchantModifier == "Bea") then
		modifierType = "Beast"; --%Localize%

	--Magic Types
	elseif  (enchantModifier == "Arc") then
		modifierType = "Arcane"; --%Localize%
	elseif  (enchantModifier == "Fro") then
		modifierType = "Frost"; --%Localize%
	elseif  (enchantModifier == "Fir") then
		modifierType = "Fire"; --%Localize%
	elseif  (enchantModifier == "Nat") then
		modifierType = "Nature"; --%Localize%
	elseif  (enchantModifier == "Sha") then
		modifierType = "Shadow"; --%Localize%
	elseif  (enchantModifier == "Hol") then
		modifierType = "Holy"; --%Localize%
	elseif  (enchantModifier == "Hea") then
		modifierType = "Healing"; --%Localize%
	elseif  (enchantModifier == "D&H") then
		modifierType = "Damage and Healing"; --%Localize%

	--Attack Types
	elseif  (enchantModifier == "Mel") then
		modifierType = ""; --%Localize%
	elseif  (enchantModifier == "Ran") then
		modifierType = "Ranged "; --%Localize%

	--Health and Mana
	elseif  (enchantModifier == "Het") then
		modifierType = "health"; --%Localize%
	elseif  (enchantModifier == "Man") then
		modifierType = "mana"; --%Localize%
	end

	--Now build the string
	if (inverted) then
		tooltipLine = format(formatString, modifierType, quantity);
	else
		tooltipLine = format(formatString, quantity, modifierType);
	end

	--We're Done!
	return tooltipLine;
end

function addRandomPropStatsToTable(itemInfo, randomProp)
	if (not (type(itemInfo) == "table")) then
		return itemInfo;
	end
	local nameNumber, enchant1, enchant2, enchant3 = getRandomPropComponents(tonumber(randomProp));

	if (not nameNumber) then
		return itemInfo;
	end

	itemInfo.itemName = itemInfo.itemBaseName.." "..ItemizerSuffixes[nameNumber]
	itemInfo = addEnchantStatsToTable(itemInfo, getEnchantComponents(ItemizerEnchants[enchant1]));
	itemInfo = addEnchantStatsToTable(itemInfo, getEnchantComponents(ItemizerEnchants[enchant2]));
	itemInfo = addEnchantStatsToTable(itemInfo, getEnchantComponents(ItemizerEnchants[enchant3]));

	return itemInfo;
end

-- Note: This function will only add info about certain enchants to the itemInfo table, some enchants are excluded (such as the weapon proficiency ones)
function addEnchantStatsToTable(itemInfo, enchantType, enchantModifier, enchantQuantity)
	if (not ((type(itemInfo) == "table") and (enchantType and enchantModifier and enchantQuantity))) then
		return itemInfo;
	end

	local tableEntry = convertEnchantModifierToTableKey(enchantModifier)

	if (enchantType == "Ba") then --Base Stats
		if (enchantModifier == "Arm") then --Armor value is in a higler order table
			itemInfo.attributes.itemArmor = nilSafeNumber(itemInfo.attributes.itemArmor) + enchantQuantity;
		else
			itemInfo.attributes.basicStats[tableEntry] = nilSafeNumber(itemInfo.attributes.basicStats[tableEntry]) + enchantQuantity;
		end

	elseif  (enchantType == "Re") then --Resists
		itemInfo.attributes.resists[tableEntry] = nilSafeNumber(itemInfo.attributes.resists[tableEntry]) + enchantQuantity;

	elseif  (enchantType == "Atk") then --Attack Power
		itemInfo.attributes.equipBonuses[tableEntry] = nilSafeNumber(itemInfo.attributes.equipBonuses[tableEntry]) + enchantQuantity;

	elseif  (enchantType == "Sp") then --Spell Power
		itemInfo.attributes.equipBonuses[tableEntry] = nilSafeNumber(itemInfo.attributes.equipBonuses[tableEntry]) + enchantQuantity;

	elseif  (enchantType == "P5") then --Foo per 5
		itemInfo.attributes.equipBonuses[tableEntry] = nilSafeNumber(itemInfo.attributes.equipBonuses[tableEntry]) + enchantQuantity;
	end

	return itemInfo
end

-- Note: This function will only convert certain enchants, some enchants are excluded (such as the weapon proficiency ones)
function convertEnchantModifierToTableKey(enchantModifier)
	if (not (type(itemInfo) == "string")) then
		return
	end

	local tableKey

	--Stats
	if (enchantModifier == "Dam") then
		tableKey = "damage";
	elseif  (enchantModifier == "Str") then
		tableKey = "strength";
	elseif  (enchantModifier == "Sta") then
		tableKey = "stamina";
	elseif  (enchantModifier == "Agi") then
		tableKey = "agility";
	elseif  (enchantModifier == "Int") then
		tableKey = "intellect";
	elseif  (enchantModifier == "Arm") then
		tableKey = "armor";
	elseif  (enchantModifier == "Spi") then
		tableKey = "spirit";
	elseif  (enchantModifier == "Def") then
		tableKey = "defense";

	--[[
	--Weapons
	elseif  (enchantModifier == "Swo") then
		tableKey = "sword"
	elseif  (enchantModifier == "Mac") then
		tableKey = "mace"
	elseif  (enchantModifier == "Axe") then
		tableKey = "axe"
	elseif  (enchantModifier == "Dag") then
		tableKey = "dagger"
	elseif  (enchantModifier == "Gun") then
		tableKey = "gun"
	elseif  (enchantModifier == "Bow") then
		tableKey = "bow"

	--Mob types
	elseif  (enchantModifier == "Bea") then
		tableKey = "beast"
	]]

	--Magic Types
	elseif  (enchantModifier == "Arc") then
		tableKey = "arcane";
	elseif  (enchantModifier == "Fro") then
		tableKey = "frost";
	elseif  (enchantModifier == "Fir") then
		tableKey = "fire";
	elseif  (enchantModifier == "Nat") then
		tableKey = "nature";
	elseif  (enchantModifier == "Sha") then
		tableKey = "shadow";
	elseif  (enchantModifier == "Hol") then
		tableKey = "holy";
	elseif  (enchantModifier == "Hea") then
		tableKey = "healing";
	elseif  (enchantModifier == "D&H") then
		tableKey = "damageAndHealing";

	--Attack Types
	elseif  (enchantModifier == "Mel") then
		tableKey = "attackPower";
	elseif  (enchantModifier == "Ran") then
		tableKey = "rangedAttackPower";

	--Health and Mana
	elseif  (enchantModifier == "Het") then
		tableKey = "healthPerFive";
	elseif  (enchantModifier == "Man") then
		tableKey = "manaPerFive";
	end

	return tableKey;
end

Itemizer.Storage = {
	GetItemData = getItemData,
	HaveItemData = haveItemData,
	StoreItemData = storeItemData,
	GetItemVersion = getItemVersion,
	EncodeItemData = encodeItemData,
	DecodeItemData = decodeItemData,
	TranslateEnchant = translateEnchant,
	GetItemRandomProps = getItemRandomProps,
	TranslateRandomProp = translateRandomProp,
	GetEnchantComponents = getEnchantComponents,
	GetRandomPropComponents = getRandomPropComponents,
	AddRandomPropStatsToTable = addRandomPropStatsToTable,
}
