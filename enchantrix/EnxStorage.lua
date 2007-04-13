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

-- Global functions
local getItemDisenchants		-- Enchantrix.Storage.GetItemDisenchants()
local getItemDisenchantTotals	-- Enchantrix.Storage.GetItemDisenchantTotals()

--[[
Usages:
  Enchantrix.Storage["4:2:4:1234"] = { [5432] = { 10, 20 } }
  print(Enchantrix.Storage["4:2:4"])
]]


-- NOTE - ccox - this will get more complex than a lookup because of non-disenchantable items
function getItemDisenchants(link)

	local iType = Enchantrix.Util.GetIType(link)
	if (not iType) then
		-- NOTE - ccox - GetIType can return nil for items that are not disenchantable
		-- a nil result does not mean that we could not find the IType
		return nil
	end
	
	local data = Enchantrix.Storage[iType]
	if not data then
		Enchantrix.Util.Debug("ItemTooltip", N_DEBUG, "No data", "No data returned for iType:",  iType)
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
Enchantrix.Storage = {
	data={},
	locked=false,

	GetItemDisenchants	= getItemDisenchants,
	GetItemDisenchantTotals = getItemDisenchantTotals,
}

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

-- Make all globals local to this file
_G = getfenv(0)
local metatable = {__index = index, __newindex = newindex}
setmetatable(Enchantrix.Storage, metatable)
setfenv(1, Enchantrix.Storage)


function AddonLoaded()
end

-- Stops any other addon from modifying our stuff.
loaded = true
