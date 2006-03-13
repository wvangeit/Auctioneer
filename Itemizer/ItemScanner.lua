--[[
	Itemizer Addon for World of Warcraft(tm).
	Version: <%version%> (<%codename%>)
	Revision: $Id$

	Itemizer itemLink and itemCache scanning and parsing functions.

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

local onUpdate, elapsedTime, entriesToProcess, frequencyOfUpdates, scanItemCache, stringFind, toNumber, storeItemData, tableRemove, tablePairs

elapsedTime = 0; --Running time to compare with frequencyOfUpdates
entriesToProcess = 50; --Items per OnUpdate call
frequencyOfUpdates = 0.2; --Seconds to wait between OnUpdate calls.
itemCacheScanCeiling = 30000; --At the time of writing, the item with the highest ItemID is "Undercity Pledge Collection" with an ItemID of 22300 (thanks to zeeg for the info [http://www.wowguru.com/db/items/id22300/]), so a ceiling of 30,000 is more than reasonable IMHO.

--Making a local copy of these extensively used functions will make their calling faster.
toNumber = tonumber;
tablePairs = ipairs;
stringFind = string.find;
tableRemove = table.remove;
storeItemData = Itemizer.Storage.StoreItemData;
pruneTable = Itemizer.Util.PruneTable


function onUpdate(timePassed)
	if (elapsedTime < frequencyOfUpdates) then
		elapsedTime = elapsedTime + timePassed;
		return;
	end

	local numItems = 0;

	for index, link in tablePairs(ItemizerProcessStack) do
		numItems = numItems + 1;
		storeItemData(buildItemData(link))

		local removedLink = table.remove(ItemizerProcessStack, index)

		if (not removedLink == link) then
			EnhTooltip.DebugPrint("Itemizer: WARNING: table.remove removed the wrong link! Expected", link, "Removed", removedLink);
		end

		if (numItems >= entriesToProcess) then
			elapsedTime = 0;
			return;
		end
	end
	elapsedTime = 0;
end

--Be VERY careful with what you send to this function, it will DC the user if the item is invalid.
function buildItemData(link)
	if (not link or (not type(link) == "string")) then return end
	local baseHyperLink = Itemizer.Util.GetItemHyperLinks(link, true)
	local hyperLink = Itemizer.Util.GetItemHyperLinks(link, false)
	local curLine, textLeft, textRight, switch, keepGoing, matched, matchedRight

	itemInfo = {}
	itemInfo.tooltip = {}
	itemInfo.tooltip.leftText = {}
	itemInfo.tooltip.rightText = {}
	itemInfo.attributes = {}
	itemInfo.attributes.skills = {}
	itemInfo.attributes.resists = {}
	itemInfo.attributes.basicStats = {}
	itemInfo.attributes.equipBonuses = {}

	itemInfo.itemID, itemInfo.randomProp = EnhTooltip.BreakLink(link)
	itemInfo.itemBaseName, _, itemInfo.itemQuality, itemInfo.itemLevel, itemInfo.itemType, itemInfo.itemSubType, _, itemInfo.itemEquipLocation = GetItemInfo(baseHyperLink[1])

	if (itemInfo.randomProp == 0) then
		itemInfo.randomProp = nil;
	end

	ItemizerHidden:SetHyperlink(hyperLink[1]);

	for index = 1, 30 do

		curLine = getglobal("ItemizerHiddenTextLeft"..index);
		if (curLine and curLine:IsShown()) then
			textLeft = curLine:GetText();
		else
			textLeft = nil
		end

		curLine = getglobal("ItemizerHiddenTextRight"..index);
		if (curLine and curLine:IsShown()) then
			textRight = curLine:GetText();
		else
			textRight = nil
		end

		itemInfo.tooltip.leftText[index] = textLeft;
		itemInfo.tooltip.rightText[index] = textRight;

		matched = false;
		matchedRight = false;
		keepGoing = true;
		while (keepGoing and (textLeft or textRight)) do
			--If either of these are nil, they can cause problems later in the loop.
			if (not textLeft) then
				textLeft = "";
			end

			if (not textRight) then
				textRight = "";
			end

			--Re-Verify the item name according to the tooltip.
			if (not switch) then
				switch = 2;
				itemInfo.itemName = textLeft;
				keepGoing = false;
				matched = true;

			--Scan for binding status
			elseif (switch == 2) then
				local _, _, binds = stringFind(textLeft, "Binds when (.+)"); --%Localize%
				if (binds) then
					if (binds == "equipped") then --%Localize%
						itemInfo.binds = 1

					elseif (binds == "picked up") then --%Localize%
						itemInfo.binds = 2

					elseif (binds == "used") then --%Localize%
						itemInfo.binds = 3
					end
					keepGoing = false;
					matched = true;

				else
					itemInfo.binds = false
				end
				switch = 3;

			--Scan for unique status
			elseif (switch == 3) then
				if (stringFind(textLeft, "Unique")) then --%Localize%
					itemInfo.isUnique = true
					keepGoing = false;
					matched = true;

				else
					itemInfo.isUnique = false
				end
				switch = 4;

			--Redirect the loop according to item type.
			elseif (switch == 4) then
				if (itemInfo.itemEquipLocation == "INVTYPE_WEAPONMAINHAND" or itemInfo.itemEquipLocation == "INVTYPE_WEAPONOFFHAND" or itemInfo.itemEquipLocation == "INVTYPE_2HWEAPON") then
					switch = 5;
					keepGoing = false;
					matchedRight = true;
					matched = true;

				elseif (itemInfo.itemEquipLocation == "INVTYPE_BAG") then
					switch = 9;

				else
					switch = 7;
					keepGoing = false;
					matchedRight = true;
					matched = true;
				end

			--Scan for weapon damage and speed.
			elseif (switch == 5) then
				local _, _, minDamage, maxDamage = stringFind(textLeft, "(%d+) %- (%d+) Damage"); --%Localize%
				if (minDamage and maxDamage) then
					itemInfo.attributes.itemMinDamage = toNumber(minDamage);
					itemInfo.attributes.itemMaxDamage = toNumber(maxDamage);
					matched = true;
				end

				local_, _, itemSpeed = stringFind(textRight, "Speed (.+)");
				if (itemSpeed) then
					itemInfo.attributes.itemSpeed = toNumber(itemSpeed);
					matchedRight = true;
				end
				keepGoing = false;
				switch = 6;

			--Scan for weapon DPS
			elseif (switch == 6) then
				local _, _, itemDPS = stringFind(textLeft, "%((.+) damage per second%)"); --%Localize%
				if (itemDPS) then
					itemInfo.attributes.itemDPS = toNumber(itemDPS);
					keepGoing = false;
					matched = true;
				end
				switch = 7;

			--Scan for item armor values.
			elseif (switch == 7) then
				local _, _, itemArmor = stringFind(textLeft, "(%d+) Armor"); --%Localize%
				if (itemArmor) then
					itemInfo.attributes.itemArmor = toNumber(itemArmor);
					keepGoing = false;
					matched = true;
				end
				if (itemInfo.itemEquipLocation == "INVTYPE_SHIELD") then
					switch = 8;
				else
					switch = 10;
				end

			--Scan for shield base block values.
			elseif (switch == 8) then
				local _, _, itemBlock = stringFind(textLeft, "(%d+) Block"); --%Localize%
				if (itemBlock) then
					itemInfo.attributes.itemBlock = toNumber(itemBlock);
					keepGoing = false;
					matched = true;
				end
				switch = 10;

			--Scan for bag size.
			elseif (switch == 9) then
				local _, _, bagSize = stringFind(textLeft, "(%d+) Slot Bag"); --%Localize%
				if (bagSize) then
					itemInfo.attributes.bagSize = toNumber(bagSize);
					keepGoing = false;
					matched = true;
				end
				switch = 10;

			--Scan for the base attributes that appear in white in the tooltip.
			elseif (switch == 10) then
				local found, plusOrMinus, quantity

				_, _, plusOrMinus, quantity = stringFind(textLeft, "(%p)(%d+) Agility"); --%Localize%
				if (quantity) then
					found = true;
					itemInfo.attributes.basicStats.agility = toNumber(plusOrMinus..quantity);
				end

				_, _, plusOrMinus, quantity = stringFind(textLeft, "(%p)(%d+) Health"); --%Localize%
				if (quantity) then
					found = true;
					itemInfo.attributes.basicStats.health = toNumber(plusOrMinus..quantity);
				end

				_, _, plusOrMinus, quantity = stringFind(textLeft, "(%p)(%d+) Intellect"); --%Localize%
				if (quantity) then
					found = true;
					itemInfo.attributes.basicStats.intellect = toNumber(plusOrMinus..quantity);
				end

				_, _, plusOrMinus, quantity = stringFind(textLeft, "(%p)(%d+) Mana"); --%Localize%
				if (quantity) then
					found = true;
					itemInfo.attributes.basicStats.mana = toNumber(plusOrMinus..quantity);
				end

				_, _, plusOrMinus, quantity = stringFind(textLeft, "(%p)(%d+) Spirit"); --%Localize%
				if (quantity) then
					found = true;
					itemInfo.attributes.basicStats.spirit = toNumber(plusOrMinus..quantity);
				end

				_, _, plusOrMinus, quantity = stringFind(textLeft, "(%p)(%d+) Stamina"); --%Localize%
				if (quantity) then
					found = true;
					itemInfo.attributes.basicStats.stamina = toNumber(plusOrMinus..quantity);
				end

				_, _, plusOrMinus, quantity = stringFind(textLeft, "(%p)(%d+) Strength"); --%Localize%
				if (quantity) then
					found = true;
					itemInfo.attributes.basicStats.strength = toNumber(plusOrMinus..quantity);
				end

				_, _, plusOrMinus, quantity = stringFind(textLeft, "(%p)(%d+) Defense"); --%Localize%
				if (quantity) then
					found = true;
					itemInfo.attributes.basicStats.defense = toNumber(plusOrMinus..quantity);
				end

				if (not found) then
					switch = 11;
				else
					keepGoing = false;
					matched = true;
				end

			--Scan for resists, which appear below base stats in the tooltip.
			elseif (switch == 11) then
				local found, plusOrMinus, quantity

				_, _, plusOrMinus, quantity = stringFind(textLeft, "(%p)(%d+) Fire Resistance"); --%Localize%
				if (quantity) then
					found = true;
					itemInfo.attributes.resists.fire = toNumber(plusOrMinus..quantity);
				end

				_, _, plusOrMinus, quantity = stringFind(textLeft, "(%p)(%d+) Frost Resistance"); --%Localize%
				if (quantity) then
					found = true;
					itemInfo.attributes.resists.frost = toNumber(plusOrMinus..quantity);
				end

				_, _, plusOrMinus, quantity = stringFind(textLeft, "(%p)(%d+) Arcane Resistance"); --%Localize%
				if (quantity) then
					found = true;
					itemInfo.attributes.resists.arcane = toNumber(plusOrMinus..quantity);
				end

				_, _, plusOrMinus, quantity = stringFind(textLeft, "(%p)(%d+) Shadow Resistance"); --%Localize%
				if (quantity) then
					found = true;
					itemInfo.attributes.resists.shadow = toNumber(plusOrMinus..quantity);
				end

				_, _, plusOrMinus, quantity = stringFind(textLeft, "(%p)(%d+) Nature Resistance"); --%Localize%
				if (quantity) then
					found = true;
					itemInfo.attributes.resists.nature = toNumber(plusOrMinus..quantity);
				end

				if (not found) then
					switch = 12;
				else
					keepGoing = false;
					matched = true;
				end

			--Scan for class requirements
			elseif (switch == 12) then
				local _, _, itemClasses = stringFind(textLeft, "Classes: (.+)"); --%Localize%
				if (itemClasses) then

					if (stringFind(itemClasses, ", ")) then
						itemInfo.attributes.classes = Itemizer.Util.Split(itemClasses, ", ");

					else
						itemInfo.attributes.classes = {itemClasses};
					end

					keepGoing = false;
					matched = true;
				else
					switch = 13;
				end

			--Scan for profession or skill requirements.
			elseif (switch == 13) then
				local _, _, requires = stringFind(textLeft, "Requires (.+)"); --%Localize%
				if (requires) then
					local _, _, skill, skillLevel = stringFind(textLeft, "(.+) %((%d+)%)");

					if (skillLevel) then
						itemInfo.attributes.skills[skill] = toNumber(skillLevel);
					end
					keepGoing = false;
					matched = true;

				else
					switch = 14;
				end

			--Scan for equip bonuses.
			elseif (switch == 14) then
				local found, damageOrHealing, schoolType, quantity, increaseType

				if (not stringFind(textLeft, "Equip: ")) then --%Localize%
					keepGoing = false;
					break;
				end

				_, _, schoolType, quantity = stringFind(textLeft, "Equip: Increases damage done by fire spells and effects by up to (%d+)"); --%Localize%
				if (quantity) then
					found = true;
					itemInfo.attributes.equipBonuses.fire = toNumber(quantity);
				end

				_, _, schoolType, quantity = stringFind(textLeft, "Equip: Increases damage done by frost spells and effects by up to (%d+)"); --%Localize%
				if (quantity) then
					found = true;
					itemInfo.attributes.equipBonuses.frost = toNumber(quantity);
				end

				_, _, schoolType, quantity = stringFind(textLeft, "Equip: Increases damage done by holy spells and effects by up to (%d+)"); --%Localize%
				if (quantity) then
					found = true;
					itemInfo.attributes.equipBonuses.holy = toNumber(quantity);
				end

				_, _, schoolType, quantity = stringFind(textLeft, "Equip: Increases damage done by shadow spells and effects by up to (%d+)"); --%Localize%
				if (quantity) then
					found = true;
					itemInfo.attributes.equipBonuses.shadow = toNumber(quantity);
				end

				_, _, schoolType, quantity = stringFind(textLeft, "Equip: Increases damage done by arcane spells and effects by up to (%d+)"); --%Localize%
				if (quantity) then
					found = true;
					itemInfo.attributes.equipBonuses.arcane = toNumber(quantity);
				end

				_, _, schoolType, quantity = stringFind(textLeft, "Equip: Increases damage done by nature spells and effects by up to (%d+)"); --%Localize%
				if (quantity) then
					found = true;
					itemInfo.attributes.equipBonuses.nature = toNumber(quantity);
				end

				_, _, quantity = stringFind(textLeft, "Equip: Increases healing done by spells and effects by up to (%d+)"); --%Localize%
				if (quantity) then
					found = true;
					itemInfo.attributes.equipBonuses.healing = toNumber(quantity);
				end
				_, _, quantity = stringFind(textLeft, "Equip: Increases damage and healing done by magical spells and effects by up to (%d+)"); --%Localize%
				if (quantity) then
					found = true;
					itemInfo.attributes.equipBonuses.damageAndHealing = toNumber(quantity);
				end

				_, _, quantity = stringFind(textLeft, "Equip: Restores (%d+) health per 5 sec"); --%Localize%
				if (quantity) then
					found = true;
					itemInfo.attributes.equipBonuses.healthPerFive = toNumber(quantity);
				end

				_, _, quantity = stringFind(textLeft, "Equip: Restores (%d+) mana per 5 sec"); --%Localize%
				if (quantity) then
					found = true;
					itemInfo.attributes.equipBonuses.manaPerFive = toNumber(quantity);
				end

				_, _, quantity = stringFind(textLeft, "Equip: Improves your chance to get a critical strike with spells by (%d+)"); --%Localize%
				if (quantity) then
					found = true;
					itemInfo.attributes.equipBonuses.spellCrit = toNumber(quantity);
				end

				_, _, quantity = stringFind(textLeft, "Equip: Improves your chance to get a critical strike by (%d+)"); --%Localize%
				if (quantity) then
					found = true;
					itemInfo.attributes.equipBonuses.meleeCrit = toNumber(quantity);
				end

				_, _, quantity = stringFind(textLeft, "Equip: Improves your chance to hit with spells by (%d+)"); --%Localize%
				if (quantity) then
					found = true;
					itemInfo.attributes.equipBonuses.spellHit = toNumber(quantity);
				end

				_, _, quantity = stringFind(textLeft, "Equip: Improves your chance to hit by (%d+)"); --%Localize%
				if (quantity) then
					found = true;
					itemInfo.attributes.equipBonuses.meleeHit = toNumber(quantity);
				end

				_, _, plusOrMinus, quantity = stringFind(textLeft, "Equip: (%p)(%d+) Attack Power"); --%Localize%
				if (quantity) then
					found = true;
					itemInfo.attributes.equipBonuses.attackPower = toNumber(plusOrMinus..quantity);
				end

				_, _, increaseType, plusOrMinus, quantity = stringFind(textLeft, "Equip: Increased (.+) (%p)(%d+)"); --%Localize%
				if (quantity) then
					found = true;
					itemInfo.attributes.equipBonuses[string.lower(increaseType)] = toNumber(plusOrMinus..quantity);
				end

				_, _, quantity = stringFind(textLeft, "Equip: Increases the block value of your shield by (%d+)"); --%Localize%
				if (quantity) then
					found = true;
					itemInfo.attributes.equipBonuses.blockValue = toNumber(quantity);
				end

				_, _, increaseType, quantity = stringFind(textLeft, "Equip: Increases your chance to dodge an attack by (%d+)"); --%Localize%
				if (quantity) then
					found = true;
					itemInfo.attributes.equipBonuses.dodgeAttack = toNumber(quantity);
				end

				_, _, increaseType, quantity = stringFind(textLeft, "Equip: Increases your chance to parry an attack by (%d+)"); --%Localize%
				if (quantity) then
					found = true;
					itemInfo.attributes.equipBonuses.parryAttack = toNumber(quantity);
				end

				_, _, quantity = stringFind(textLeft, "Equip: Increases your chance to block attacks with a shield by (%d+)"); --%Localize%
				if (quantity) then
					found = true;
					itemInfo.attributes.equipBonuses.blockAttack = toNumber(quantity);
				end
				keepGoing = false;
				if (found) then
					matched = true;
				end
			end
		end
		if (matched) then
			itemInfo.tooltip.leftText[index] = "¶"..itemInfo.tooltip.leftText[index];
		end
		if (matchedRight) then
			if (itemInfo.tooltip.rightText[index]) then
				itemInfo.tooltip.rightText[index] = "¶"..itemInfo.tooltip.rightText[index];
			end
		end
	end
	return pruneTable(itemInfo);
end

function scanItemCache()
	debugprofilestart()
	local itemName, hyperLink, itemQuality, totalTimeTaken
	local itemsFound = 0;
	for itemID = 1, itemCacheScanCeiling do
		itemName, hyperLink, itemQuality = GetItemInfo(itemID)
		if (itemName) then
			Itemizer.Core.ProcessLinks(Itemizer.Util.BuildLink(hyperLink, itemQuality, itemName), true)
			itemsFound = itemsFound + 1;
		end
	end
	totalTimeTaken = debugprofilestop();
	EnhTooltip.DebugPrint("Itemizer: ItemCache entries scanned", itemCacheScanCeiling, "Number of Items found", itemsFound, "Time taken", totalTimeTaken, "Average time per found item", totalTimeTaken/itemsFound, "Average time per attempt", totalTimeTaken/itemCacheScanCeiling);
end
-- /script Itemizer.Scanner.ScanItemCache()
-- /eval ItemizerProcessStack
-- /script a,b,c,d,e,f,g,h,i = GetItemInfo(16921) ChatFrame2:AddMessage(a.."§ "..b.."§ "..c.."§ "..d.."§"..e.."§"..f.."§"..g.."§"..h.."§"..i)
-- /script start, stop, plusOrMinus, quantity, resistType = stringFind("-30 Nature Resistance", "(%p)(%d+) (.+) Resistance"); EnhTooltip.DebugPrint(start, stop, plusOrMinus, quantity, resistType)

-- /script GameTooltip_SetDefaultAnchor(ItemizerHiddenTooltip, UIParent); ItemizerHiddenTooltip:SetHyperlink("item:16921:0:0:0")
-- /script GameTooltip_SetDefaultAnchor(ItemizerHiddenTooltip, UIParent); ItemizerHiddenTooltip:SetText("item:4500:0:0:0")
-- /script GameTooltip_SetDefaultAnchor(GameTooltip, UIParent); GameTooltip:SetHyperlink("item:4500:0:0:0")
-- /script GameTooltip_SetDefaultAnchor(GameTooltip, UIParent); GameTooltip:SetText("item:4500:0:0:0")
-- /script GameTooltip_SetDefaultAnchor(Gobblidy, UIParent); Gobblidy:SetHyperlink("item:4500:0:0:0")
-- /script GameTooltip_SetDefaultAnchor(Gobblidy, UIParent); Gobblidy:SetText("item:4500:0:0:0")

-- /script DATA = Itemizer.Scanner.BuildItemData(Itemizer.Util.BuildLink(16696)) Fire_Debugger_LoadString("DATA")
-- /script DATA = {Itemizer.Storage.EncodeItemData(Itemizer.Scanner.BuildItemData(Itemizer.Util.BuildLink(16921)))} Fire_Debugger_LoadString("DATA")
-- /dump Itemizer.Storage.EncodeItemData(Itemizer.Scanner.BuildItemData(Itemizer.Util.BuildLink(16921)))
-- /dump Itemizer.Storage.EncodeItemData(Itemizer.Scanner.BuildItemData(Itemizer.Util.BuildLink(16921)))
-- /dump Itemizer.Scanner.BuildItemData(Itemizer.Util.BuildLink(16921))
-- /dump Itemizer.Scanner.BuildItemData(Itemizer.Util.BuildLink("item:6587:0:851", 3, "Scouting Trousers of the Eagle"))

-- /script Blah = "hello" Blah2 = "world" Blah3 = Blah.."§"..Blah2 ChatFrame2:AddMessage(Blah3)
Itemizer.Scanner = {
	OnUpdate = onUpdate,
	BuildItemData = buildItemData,
	ScanItemCache = scanItemCache,
}