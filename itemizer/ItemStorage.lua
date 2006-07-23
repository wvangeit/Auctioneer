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
local storeItemData
local haveItemData
local encodeItemData
local splitString = Itemizer.Util.Split
local nilSafeTable = Itemizer.Util.NilSafeTable

function getItemData(itemID, randomProp) --This function is not finished
--[[
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
]]
end

function storeItemData(itemInfo)
	--Make itemInfo a required parameter, and make sure its a table
	if (not type(itemInfo) == "table") then
		return
	end

	local oldBaseInfo, baseInfo, leftTooltip, rightTooltip, baseData, basicStats, resists, requirements, equipBonuses, currentItem

	if (itemInfo.randomProp) then --We need to treat these separately.
		local haveItemID, haveRandomProp, randomPropInItem = haveItemData(itemInfo.itemID, itemInfo.randomProp)
		EnhTooltip.DebugPrint(haveItemID, haveRandomProp, randomPropInItem, itemInfo.itemID, itemInfo.randomProp)
		if (not haveRandomProp) then
			EnhTooltip.DebugPrint("Itemizer does not have this randomProp in its cache tables:", itemInfo.randomProp, "Please update your copy of Itemizer.")
			return
		end

		if (haveItemID and randomPropInItem) then --Refresh data.
			baseInfo, tooltip, baseData, basicStats, resists, requirements, equipBonuses = encodeItemData(itemInfo, itemInfo.randomProp)

			currentItem = ItemizerLinks[itemInfo.itemID]

			--We don't want to reset the randomProp posibilities, so the basicData field is left alone.
			currentItem[2] = tooltip;
			currentItem[3] = baseData;
			currentItem[4] = basicStats;
			currentItem[5] = resists;
			currentItem[6] = requirements;
			currentItem[7] = equipBonuses;

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

			--Now actually encode the information and store it.
			baseInfo, tooltip, baseData, basicStats, resists, requirements, equipBonuses = encodeItemData(itemInfo, itemInfo.randomProp)

			infoLine = string.format(formatString, unpack(oldBaseInfo))
			ItemizerLinks[itemInfo.itemID] = {}
			currentItem = ItemizerLinks[itemInfo.itemID]
			currentItem[1] = infoLine

			currentItem[2] = tooltip;
			currentItem[3] = baseData;
			currentItem[4] = basicStats;
			currentItem[5] = resists;
			currentItem[6] = requirements;
			currentItem[7] = equipBonuses;

		else -- Completely new item
			ItemizerLinks[itemInfo.itemID] = {}
			currentItem = ItemizerLinks[itemInfo.itemID]
			currentItem[1] = itemInfo.itemBaseName.."§1§"..itemInfo.randomProp

			baseInfo, tooltip, baseData, basicStats, resists, requirements, equipBonuses = encodeItemData(itemInfo, itemInfo.randomProp)

			currentItem[2] = tooltip;
			currentItem[3] = baseData;
			currentItem[4] = basicStats;
			currentItem[5] = resists;
			currentItem[6] = requirements;
			currentItem[7] = equipBonuses;
		end

	else --Item with no current randomProp
		ItemizerLinks[itemInfo.itemID] = {}
		currentItem = ItemizerLinks[itemInfo.itemID]

		baseInfo, tooltip, baseData, basicStats, resists, requirements, equipBonuses = encodeItemData(itemInfo, itemInfo.randomProp)

		currentItem[1] = baseInfo
		currentItem[2] = tooltip;
		currentItem[3] = baseData;
		currentItem[4] = basicStats;
		currentItem[5] = resists;
		currentItem[6] = requirements;
		currentItem[7] = equipBonuses;
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

function encodeItemData(itemInfo, randomProp)
	--Make itemInfo a required parameter, and make sure its a table
	if (not type(itemInfo) == "table") then
		return
	end

	local baseInfo, tooltip, baseData, basicStats, resists, requirements, equipBonuses

	--Slight speed optimizations
	local attribs = itemInfo.attributes;
	local basicTable = itemInfo.attributes.basicStats;
	local resistsTable = itemInfo.attributes.resists;
	local bonusesTable = itemInfo.attributes.equipBonuses;

	baseInfo = itemInfo.itemBaseName

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

	--Store unique status
	if (itemInfo.isUnique) then
		baseData = baseData.."§1";
	else
		baseData = baseData.."§";
	end

	--Store binds data
	baseData = baseData.."§"..nilSafeString(itemInfo.binds);

	-- Store type specific information
	local equipLoc = string.sub(itemInfo.itemEquipLocation, 9); --Trim the reduntant "INVTYPE_" from the equip location.
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
	return str or ""
end

function nilSafeNumber(number)
	return number or 0
end

Itemizer.Storage = {
	GetItemData = getItemData,
	HaveItemData = haveItemData,
	StoreItemData = storeItemData,
	EncodeItemData = encodeItemData,
}