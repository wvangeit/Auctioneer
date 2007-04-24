--[[
	Enchantrix Addon for World of Warcraft(tm).
	Version: <%version%> (<%codename%>)
	Revision: $Id$

	Database functions and saved variables.

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

--[[
Usages:
  Enchantrix.Storage["4:2:4:1234"] = { [5432] = { 10, 20 } }
  print(Enchantrix.Storage["4:2:4"])
]]


-- Global functions
local getItemDisenchants		-- Enchantrix.Storage.GetItemDisenchants()
local getItemDisenchantTotals	-- Enchantrix.Storage.GetItemDisenchantTotals()
local saveDisenchant			-- Enchantrix.Storage.SaveDisenchant()
local addonLoaded				-- Enchantrix.Storage.AddonLoaded()
local saveNonDisenchantable		-- Enchantrix.Storage.SaveNonDisenchantable()

-- Local functions
local unserialize
local serialize
local normalizeDisenchant
local mergeDisenchant
local mergeDisenchantLists

-- Database

local N_DISENCHANTS = 1
local N_REAGENTS = 2


function unserialize(str)
	-- Break up a disenchant string to a table for easy manipulation
	local tbl = {}
	if type(str) == "string" then
		for de in Enchantrix.Util.Spliterator(str, ";") do
			local id, d, r = de:match("(%d+):(%d+):(%d+)")
			id, d, r = tonumber(id), tonumber(d), tonumber(r)
			if (id and d > 0 and r > 0) then
				tbl[id] = {[N_DISENCHANTS] = d, [N_REAGENTS] = r}
			end
		end
	end
	return tbl
end

function serialize(tbl)
	-- Serialize a table into a string
	if type(tbl) == "table" then
		local str
		for id, counts in pairs(tbl) do
			if (type(id) == "number" and counts[N_DISENCHANTS] > 0 and counts[N_REAGENTS] > 0) then
				if (str) then
					str = ("%s;%d:%d:%d:0"):format(str, id, counts[N_DISENCHANTS], counts[N_REAGENTS])
				else
					str = ("%d:%d:%d:0"):format(id, counts[N_DISENCHANTS], counts[N_REAGENTS])
				end
			end
		end
		return str
	end
end

function mergeDisenchant(str1, str2)
	-- Merge two disenchant strings into a single string
	local tbl1, tbl2 = unserialize(str1), unserialize(str2)
	for id, counts in pairs(tbl2) do
		if (not tbl1[id]) then
			tbl1[id] = counts
		else
			tbl1[id][N_DISENCHANTS] = tbl1[id][N_DISENCHANTS] + counts[N_DISENCHANTS]
			tbl1[id][N_REAGENTS] = tbl1[id][N_REAGENTS] + counts[N_REAGENTS]
		end
	end
	return serialize(tbl1)
end

function normalizeDisenchant(str)
	-- Divide all counts in disenchant string by gcd
	local div = 0
	local count = 0
	local tbl = unserialize(str)
	for id, counts in pairs(tbl) do
		div = Enchantrix.Util.GCD(div, counts[N_DISENCHANTS])
		div = Enchantrix.Util.GCD(div, counts[N_REAGENTS])
		count = count + 1
	end
	-- Only normalize if there's more than one kind of reagent
	if count > 1 then
		for id, counts in pairs(tbl) do
			counts[N_DISENCHANTS] = counts[N_DISENCHANTS] / div
			counts[N_REAGENTS] = counts[N_REAGENTS] / div
		end
		return serialize(tbl)
	end
	return str
end


function mergeDisenchantLists()

-- DisenchantList no longer exists
-- it used to be merged in here

--[[
	-- Merge items from EnchantedLocal into EnchantedItemTypes
	-- now only useful to developers
	
	EnchantedItemTypes = {}
	for sig, disenchant in pairs(EnchantedLocal) do
		local item = Enchantrix.Util.GetItemIdFromSig(sig)
		local itype = Enchantrix.Util.GetItemType(item)
		if itype then
			EnchantedItemTypes[itype] = mergeDisenchant(EnchantedItemTypes[itype], disenchant)
		end
	end
]]

	-- now we need to merge the user non-disenchantables with the default non-disenchantables
	if not NonDisenchantablesLocal then NonDisenchantablesLocal = {} end
	for sig, value in pairs(NonDisenchantablesLocal) do
		NonDisenchantables[sig] = value;
	end
	
	-- Take out the trash
	collectgarbage("collect")

end


-- NOTE - ccox - if we are going to keep a log of disenchantments, we need this function
-- and, if we aren't going to keep a log, we need to remove the saveDisenchant code from onEvent in EnxMain.lua
function saveDisenchant(sig, reagentID, count)
	-- Update tables after a disenchant has been detected
	assert(type(sig) == "string");
	assert(tonumber(reagentID));
	assert(tonumber(count));

	local id = Enchantrix.Util.GetItemIdFromSig(sig)
	local itype = Enchantrix.Util.GetIType(id)
	
	local disenchant = ("%d:1:%d:0"):format(reagentID, count)
	EnchantedLocal[sig] = mergeDisenchant(EnchantedLocal[sig], disenchant)
	if itype then
		EnchantedItemTypes[itype] = mergeDisenchant(EnchantedItemTypes[itype], disenchant)
	end
end


-- NOTE - ccox - this will get more complex than a lookup because of non-disenchantable items
function getItemDisenchants(link)
	local iType = Enchantrix.Util.GetIType(link)
	if (not iType) then
		-- NOTE - ccox - GetIType can return nil for items that are not disenchantable
		-- a nil result does not mean that we could not find the IType
		return nil
	end
	
	-- see if it is on our non-disenchantable list
	if type(link) == "string" then
		sig = Enchantrix.Util.GetSigFromLink(link);
	else
		local _, sLink = GetItemInfo(link);
		sig = Enchantrix.Util.GetSigFromLink(sLink);
	end
	
	if (NonDisenchantables[sig]) then
		return nil
	end
	
	local data = Enchantrix.Storage[iType]
	if not data then
		Enchantrix.Util.DebugPrint("ItemTooltip", ENX_INFO, "No data", "No data returned for iType:" .. iType)
		return nil
	end
	return data
end



-- NOTE - ccox - calculation copied from itemTooltip, I couldn't easily reuse the code
-- TODO - REVISIT - ccox - share the code with itemTooltip
function getItemDisenchantTotals(link)
	local data = getItemDisenchants(link)
	local data = Enchantrix.Storage.GetItemDisenchants(link)
	if not data then
		-- error message would have been printed inside GetItemDisenchants
		return
	end

	local lines
	local total = data.total
	local totalHSP, totalMed, totalMkt = 0,0,0
	
	if (total and total[1] > 0) then
		local totalNumber, totalQuantity = unpack(total)
		for result, resData in pairs(data) do
			if (result ~= "total") then
				if (not lines) then lines = {} end

				local resNumber, resQuantity = unpack(resData)
				local hsp, med, mkt, five = Enchantrix.Util.GetReagentPrice(result)
				local resProb, resCount = resNumber/totalNumber, resQuantity/resNumber
				local resHSP, resMed, resMkt = (hsp or 0)*resProb, (med or 0)*resProb, (mkt or 0)*resProb
				totalHSP = totalHSP + resHSP
				totalMed = totalMed + resMed
				totalMkt = totalMkt + resMkt
			end
		end
	else
		return
	end
	
	return totalHSP, totalMed, totalMkt
end


local _G
local lib = Enchantrix.Storage
lib.data = {}


local function addResults(data, ...)
	if not data then return end
	local result, number, quantity
	local n = select("#", ...)
	local v
	if (not data.total) then data.total = { 0, 0 } end
	for i = 1, n do
		v = select(i, ...)
		result, number, quantity = strsplit(":", v)
		result = tonumber(result)
		if (result) then
			number = tonumber(number) or 0
			quantity = tonumber(quantity) or 0
			if (not data[result]) then data[result] = { 0, 0 } end
			data[result][1] = data[result][1] + number
			data[result][2] = data[result][2] + quantity
			data.total[1] = data.total[1] + number
			data.total[2] = data.total[2] + quantity
		end
	end
end

local compactres = {}
local function compact(data)
	while #compactres > 0 do
		table.remove(compactres)
	end
	for item, value in pairs(data) do
		table.insert(compactres, strjoin(":", item, value[1], value[2]))
	end
	return strjoin(",", unpack(compactres))
end

local function index(self, key)
	local iLevel,iQual,iType,iItem
	if (type(key) == "string") then
		iLevel,iQual,iType,iItem = strsplit(":", key)
	end
	if (iQual) then
		local data = {}
		iLevel = tonumber(iLevel) or 0
		iQual = tonumber(iQual) or 0
		iType = tonumber(iType) or 0
		if (iLevel > 0 and iQual >= 2 and (iType == 2 or iType == 4)) then
			local key = strjoin(":", iLevel, iQual, iType)
			addResults(data, strsplit(",", Enchantrix.Data.GetDisenchantData(key)))
			if (EnchantrixData and EnchantrixData.disenchants and EnchantrixData.disenchants[key]) then
				for itemId, itemData in pairs(EnchantrixData.disenchants[key]) do
					addResults(data, strsplit(",", itemData))
				end
			end
		end
		return data
	end
	local val = rawget(self, key)
	if (val) then
		return val
	end
	return nil
end

local function newindex(self, key, value)
	local iLevel,iQual,iType,iItem
	if (type(key) == "string") then
		iLevel,iQual,iType,iItem = strsplit(":", key)
	end
	if (iQual) then
		if (type(value) ~= "table") then return end

		local data = {}
		iLevel = tonumber(iLevel) or 0
		iQual = tonumber(iQual) or 0
		iType = tonumber(iType) or 0
		iItem = tonumber(iItem) or 0

		if (iLevel > 0 and iQual >= 2 and (iType == 2 or iType == 4) and iItem > 0) then
			local key = strjoin(":", iLevel, iQual, iType)
			if (not EnchantrixData) then EnchantrixData = {} end
			if (not EnchantrixData.disenchants) then EnchantrixData.disenchants = {} end
			if (not EnchantrixData.disenchants[key]) then EnchantrixData.disenchants[key] = {}
			else
				for itemId, itemData in pairs(EnchantrixData.disenchants[key]) do
					if (itemId == iItem) then
						addResults(data, strsplit(",", itemData))
						break
					end
				end
			end
			for resultId, resultData in pairs(value) do
				if (not data[resultId]) then data[resultId] = { 0, 0 } end
				local node = data[resultId]
				node[1] = node[1] + resultData[1]
				node[2] = node[2] + resultData[2]
			end

			EnchantrixData.disenchants[key][iItem] = compact(data)
		end
		return
	end
	if (self.locked) then return end
	rawset(self, key, value)
end


function saveNonDisenchantable(itemLink)
	if not NonDisenchantablesLocal then NonDisenchantablesLocal = {} end
	local sig = Enchantrix.Util.GetSigFromLink(itemLink);
	-- put this in the local and combined list
	-- only the local list will be saved in SavedVariables
	NonDisenchantablesLocal[sig] = true;
	NonDisenchantables[sig] = true;
	Enchantrix.Util.ChatPrint(_ENCH("FrmtFoundNotDisenchant"):format(itemLink))
end


function addonLoaded()
	-- Create and setup saved variables
	if not EnchantedLocal then EnchantedLocal = {} end
	if not EnchantedBaseItems then EnchantedBaseItems = {} end
	if not EnchantedItemTypes then EnchantedItemTypes = {} end
	if not NonDisenchantables then NonDisenchantables = {} end
	if not NonDisenchantablesLocal then NonDisenchantablesLocal = {} end
	
	mergeDisenchantLists()
end


Enchantrix.Storage = {
	data={},
	locked=false,
	AddonLoaded			= addonLoaded,

	GetItemDisenchants	= getItemDisenchants,
	GetItemDisenchantTotals = getItemDisenchantTotals,
	SaveDisenchant = saveDisenchant,
	SaveNonDisenchantable = saveNonDisenchantable,
}

-- Make all globals local to this file
_G = getfenv(0)
local metatable = {__index = index, __newindex = newindex}
setmetatable(Enchantrix.Storage, metatable)
setfenv(1, Enchantrix.Storage)

-- Stops any other addon from modifying our stuff.
loaded = true
