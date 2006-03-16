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

local getItemData, storeItemData, haveItemData
local splitString = Itemizer.Util.Split

function getItemData(itemID, randomProp)
	itemID = tonumber(itemID)
	randomProp = tonumber(randomProp)

	if (not itemID) then
		return
	end

	local currentItem
	local itemInfo = {}
	local haveItemID, haveRandomProp = haveItemData(itemID, randomProp)

	if (randomProp) then --We're looking for an "of the X" item
		if ((haveItemID) and (haveRandomProp)) then --Found!
			currentItem = ItemizerLinks[itemInfo.itemID][itemInfo.randomProp]
		else --Item Not found
			
		end
	else --We're looking for a standard item
		if (haveItemID) then --Found!
			
		else --Item not found
			
		end
	end
end

function storeItemData(itemInfo)
	--Make itemInfo a required parameter, and make sure its a table
	if ((not itemInfo) or (not type(itemInfo) == "table")) then
		return
	end

	local oldBaseInfo, baseInfo, leftTooltip, rightTooltip, baseData, basicStats, resists, requirements, equipBonuses, currentItem

	if (itemInfo.randomProp) then --We need to treat these separately.
		local haveItemID, haveRandomProp = haveItemData(itemInfo.itemID, itemInfo.randomProp)

		if (haveItemID and haveRandomProp) then --Refresh data.
			baseInfo, tooltip, baseData, basicStats, resists, requirements, equipBonuses = encodeItemData(itemInfo, itemInfo.randomProp)

			ItemizerLinks[itemInfo.itemID][itemInfo.randomProp] = {}
			currentItem = ItemizerLinks[itemInfo.itemID][itemInfo.randomProp]

			currentItem[1] = baseInfo;
			currentItem[2] = tooltip;
			currentItem[3] = baseData;
			currentItem[4] = basicStats;
			currentItem[5] = resists;
			currentItem[6] = requirements;
			currentItem[7] = equipBonuses;

		elseif (haveItemID) then --Add new randomProp to existing itemID table.
			--Start by adding the new randomProp to the baseInfo line
			oldBaseInfo = splitString(ItemizerLinks[itemInfo.itemID][-1], "§")
			local formatString = "%s"
			oldBaseInfo[2] = tonumber(oldBaseInfo[2]) + 1
			table.insert(oldBaseInfo, itemInfo.randomProp)
			for key, value in ipairs(oldBaseInfo) do
				if (key > 1) then
					formatString = formatString.."§%d"
				end
			end

			--Now actually encode the information and store it.
			baseInfo, tooltip, baseData, basicStats, resists, requirements, equipBonuses = encodeItemData(itemInfo, itemInfo.randomProp)

			oldBaseInfo[1] = itemInfo.itemBaseName
			infoLine = string.format(formatString, unpack(oldBaseInfo))
			ItemizerLinks[itemInfo.itemID][-1] = infoLine

			ItemizerLinks[itemInfo.itemID][itemInfo.randomProp] = {}

			currentItem = ItemizerLinks[itemInfo.itemID][itemInfo.randomProp]

			currentItem[1] = baseInfo;
			currentItem[2] = tooltip;
			currentItem[3] = baseData;
			currentItem[4] = basicStats;
			currentItem[5] = resists;
			currentItem[6] = requirements;
			currentItem[7] = equipBonuses;

		else -- Completely new item
			ItemizerLinks[itemInfo.itemID] = {}
			ItemizerLinks[itemInfo.itemID][-1] = itemInfo.itemBaseName.."§1§"..itemInfo.randomProp

			baseInfo, tooltip, baseData, basicStats, resists, requirements, equipBonuses = encodeItemData(itemInfo, itemInfo.randomProp)

			ItemizerLinks[itemInfo.itemID][itemInfo.randomProp] = {}
			currentItem = ItemizerLinks[itemInfo.itemID][itemInfo.randomProp]

			currentItem[1] = baseInfo;
			currentItem[2] = tooltip;
			currentItem[3] = baseData;
			currentItem[4] = basicStats;
			currentItem[5] = resists;
			currentItem[6] = requirements;
			currentItem[7] = equipBonuses;
		end

	else
		ItemizerLinks[itemInfo.itemID] = {}

		baseInfo, tooltip, baseData, basicStats, resists, requirements, equipBonuses = encodeItemData(itemInfo, itemInfo.randomProp)
		currentItem = ItemizerLinks[itemInfo.itemID]

		currentItem[-1] = baseInfo;
		currentItem[-2] = tooltip;
		currentItem[-3] = baseData;
		currentItem[-4] = basicStats;
		currentItem[-5] = resists;
		currentItem[-6] = requirements;
		currentItem[-7] = equipBonuses;
	end
end

--Use this function to query if we have info for a certain item or not.
function haveItemData(itemID, randomProp)
	--No parameters, no returns
	if (not itemID) then
		return
	end

	itemID = tonumber(itemID);

	if (randomProp) then
		randomProp = tonumber(randomProp);
	end

	if (itemID) then
		--Two parameters, two returns
		if (randomProp) then
			if ((ItemizerLinks[itemID]) and (ItemizerLinks[itemID][randomProp])) then
				return true, true

			elseif (ItemizerLinks[itemID]) then
				return true, false

			else
				return false, false
			end

		--One parameter, one return
		elseif (ItemizerLinks[itemID]) then
			return true
		else
			return false
		end
	end
end

function encodeItemData(itemInfo, randomProp)
	--Make itemInfo a required parameter, and make sure its a table
	if ((not itemInfo) or (not type(itemInfo) == "table")) then
		return
	end

	local baseInfo, tooltip, baseData, basicStats, resists, requirements, equipBonuses

	--Slight speed optimizations
	local attribs = itemInfo.attributes;
	local basicTable = itemInfo.attributes.basicStats;
	local resistsTable = itemInfo.attributes.resists;
	local bonusesTable = itemInfo.attributes.equipBonuses;

	if (randomProp) then
		baseInfo = string.sub(itemInfo.itemName, string.len(itemInfo.itemBaseName) + 1);
	else
		baseInfo = itemInfo.itemBaseName
	end


	--Build tooltips
	local first = true
	if (itemInfo.tooltip.leftText) then
		for key, value in pairs(itemInfo.tooltip.leftText) do

			--Only store the tooltip line if it was not successfully parsed.
			if (not string.find(value, "¶")) then

				--Stop the encoding process if we reach a newline character that means that set item info is next.
				if (string.find(value, "\n")) then
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
		for key, value in pairs(itemInfo.tooltip.rightText) do

			--Only store the tooltip line if it was not successfully parsed.
			if (not string.find(value, "¶")) then

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
	baseData = string.sub(itemInfo.itemEquipLocation, 9); --Trim the reduntant "INVTYPE_" from the equip location.
	baseData = baseData.."§"..nilSafeString(itemInfo.itemQuality).."§"..nilSafeString(itemInfo.itemLevel).."§"..nilSafeString(itemInfo.itemType).."§"..nilSafeString(itemInfo.itemSubType)

	--Store binds data
	if (itemInfo.isUnique) then
		baseData = baseData.."§1";
	else
		baseData = baseData.."§";
	end

	--Store unique status
	baseData = baseData.."§"..nilSafeString(itemInfo.binds);

	if (baseData == "WEAPONMAINHAND" or baseData == "WEAPONOFFHAND" or baseData == "2HWEAPON") then --Store Weapon stats
		--Min and max damage
		baseData = baseData.."§"..attribs.itemMinDamage.."§"..attribs.itemMaxDamage;
		--Speed and DPS
		baseData = baseData.."§"..attribs.itemSpeed.."§"..attribs.itemDPS;

		--Armor and block values (if available)
		if (attribs.itemArmor) then
			baseData = baseData.."§"..attribs.itemArmor;

			if (attribs.itemBlock) then
				baseData = baseData.."§"..attribs.itemBlock;
			end
		end

	elseif (baseData == "BAG") then --Store BagSize
		baseData = baseData.."§"..attribs.bagSize;

	else --Store Armor stats

		--Armor and block values (if available)
		if (attribs.itemArmor) then
			baseData = baseData.."§"..attribs.itemArmor;

			if (attribs.itemBlock) then
				baseData = baseData.."§"..attribs.itemBlock;
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

	--Equip Bonuses are the final item
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

	return baseInfo, tooltip, baseData, basicStats, resists, requirements, equipBonuses
end

function decodeItemData(itemID, randomProp) --%Todo% Finish this
	--Make itemID a required parameter, and make sure its a table
	if ((not itemID) or (not type(itemID) == "table")) then
		return
	end
end

function nilSafeString(str)
	if (not str) then
		return ""
	else
		return str
	end
end

Itemizer.Storage = {
	GetItemData = getItemData,
	StoreItemData = storeItemData,
	HaveItemData = haveItemData,
	EncodeItemData = encodeItemData,
}