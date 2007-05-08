--[[
	Enchantrix Addon for World of Warcraft(tm).
	Version: <%version%> (<%codename%>)
	Revision: $Id$

	General utility functions

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
local getItems
local getItemType
local getReagentInfo
local getSigFromLink
local getReagentPrice
local getLinkFromName
local isDisenchantable
local getItemIdFromSig
local getItemHyperlinks
local getItemIdFromLink

local split
local chatPrint
local getRevision
local spliterator

local gcd
local round
local roundUp
local confidenceInterval

local createProfiler

------------------------
--   Item functions   --
------------------------

-- Return false if item id can't be disenchanted
function isDisenchantable(id)
	if (id) then
		local _, _, quality, _, _, _, _, count, equip = GetItemInfo(id)
		if (not quality) then
			-- GetItemInfo() failed, item might be disenchantable
			return true
		end
		if (not Enchantrix.Constants.InventoryTypes[equip]) then
			-- Neither weapon nor armor
			return false
		end
		if (quality and quality < 2) then
			-- Low quality
			return false
		end
		if (count and count > 1) then
			-- Stackable item
			return false
		end
		return true
	end
	return false
end

-- Frontend to GetItemInfo()
-- Information for disenchant reagents are kept in a saved variable cache
function getReagentInfo(id)
	if (not EnchantConfig) then EnchantConfig = {} end
	if (not EnchantConfig.cache) then EnchantConfig.cache = {} end
	if (not EnchantConfig.cache.names) then EnchantConfig.cache.names = {} end
	if (not EnchantConfig.cache.reagentinfo) then EnchantConfig.cache.reagentinfo = {} end
	local cache = EnchantConfig.cache.reagentinfo

	if type(id) == "string" then
		local _, _, i = id:find("item:(%d+):")
		id = i
	end
	id = tonumber(id)

	local sName, sLink, iQuality, _, iLevel, sType, sSubtype, iStack, sEquip, sTexture = GetItemInfo(id)
	if id and Enchantrix.Constants.StaticPrices[id] then
		if sName then
			cache[id] = sName.."|"..iQuality.."|"..sTexture
			cache["t"] = sType
		elseif type(cache[id]) == "string" then
			local cdata = split(cache[id], "|")

			sName = cdata[1]
			iQuality = tonumber(cdata[2])
			iLevel = 0
			sType = cache["t"]
			sSubtype = cache["t"]
			iStack = 10
			sEquip = ""
			sTexture = cdata[3]
			sLink = "item:"..id..":0:0:0"
		end
	end

	if sName and id then
		-- Might as well save this name while we have the data
		EnchantConfig.cache.names[sName] = "item:"..id..":0:0:0"
	end

	return sName, sLink, iQuality, iLevel, sType, sSubtype, iStack, sEquip, sTexture
end

function getLinkFromName(name)
	assert(type(name) == "string")

	if not EnchantConfig.cache then
		EnchantConfig.cache = {}
	end
	if not EnchantConfig.cache.names then
		EnchantConfig.cache.names = {}
	end

	local link = EnchantConfig.cache.names[name]
	if link then
		local n = GetItemInfo(link)
		if n ~= name then
			EnchantConfig.cache.names[name] = nil
		end
	end
	if not EnchantConfig.cache.names[name] then
		for i = 1, Enchantrix.State.MAX_ITEM_ID + 4000 do
			local n, link = GetItemInfo(i)
			if n then
				if n == name then
					EnchantConfig.cache.names[name] = link
					break
				end
				Enchantrix.State.MAX_ITEM_ID = math.max(Enchantrix.State.MAX_ITEM_ID, i)
			end
		end
	end
	return EnchantConfig.cache.names[name]
end


-- Returns HSP, median and static price for reagent
-- Auctioneer values are kept in cache for 48h in case Auctioneer isn't loaded
function getReagentPrice(reagentID)
	-- reagentID ::= number | hyperlink
	if type(reagentID) == "string" then
		local _, _, i = reagentID:find("item:(%d+):")
		reagentID = i
	end
	reagentID = tonumber(reagentID)
	if not reagentID then return nil end

	local hsp, median, market, price5

	market = Enchantrix.Constants.StaticPrices[reagentID]

	if AucAdvanced then
		price5 = AucAdvanced.API.GetMarketValue(reagentID)
	elseif Enchantrix.State.Auctioneer_Loaded then
		local itemKey = ("%d:0:0"):format(reagentID);
		local realm = Auctioneer.Util.GetAuctionKey()
		hsp = Auctioneer.Statistic.GetHSP(itemKey, realm)
		median = Auctioneer.Statistic.GetUsableMedian(itemKey, realm)
	end

	if not EnchantConfig.cache then EnchantConfig.cache = {} end
	if not EnchantConfig.cache.prices then EnchantConfig.cache.prices = {} end
	if not EnchantConfig.cache.prices[reagentID] then EnchantConfig.cache.prices[reagentID] = {} end
	local cache = EnchantConfig.cache.prices[reagentID]
	if cache.timestamp and time() - cache.timestamp > 172800 then
		cache = {}
	end

	cache.hsp = hsp or cache.hsp
	cache.median = median or cache.median
	cache.market = market or cache.market
	cache.price5 = price5 or cache.price5
	cache.timestamp = time()

	return cache.hsp, cache.median, cache.market, cache.price5
end


-- Return item level (rounded up to nearest 5 levels), quality and type as string,
-- e.g. "20:2:Armor" for uncommon level 20 armor
function getItemType(id)
	if (id) then
		local _, _, quality, ilevel, _, _, _, _, equip = GetItemInfo(id)
		if (quality and quality >= 2 and Enchantrix.Constants.InventoryTypes[equip]) then
			return ("%d:%d:%s"):format(Enchantrix.Util.RoundUp(ilevel, 5), quality, Enchantrix.Constants.InventoryTypes[equip])
		end
	end
end

-- Return item id as integer
function getItemIdFromSig(sig)
	if type(sig) == "string" then
		_, _, sig = sig:find("(%d+)")
	end
	return tonumber(sig)
end

function getItemIdFromLink(link)
	return (EnhTooltip.BreakLink(link))
end

function getIType(link)
	assert(type(link) == "string")
	local _, _, iId = link:find("item:(%d+):")

	local iName,iLink,iQual,iLevel,iMin,iType,iSub,iStack,iEquip,iTex=GetItemInfo(link)
	if (iQual < 2) then
		Enchantrix.DebugPrint("GetIType", ENX_INFO, "Quality too low", "The quality for " .. link .. " is too low (" .. iQual .. "< 2)")
		return
	end
	if not iEquip then
		Enchantrix.DebugPrint("GetIType", ENX_INFO, "Item not equippable", "The item " .. link .. " is not equippable")
		return
	end
	local invType = Enchantrix.Constants.InventoryTypes[iEquip]
	if not invType then
		Enchantrix.DebugPrint("GetIType", ENX_INFO, "Unrecognized equip slot", "The item " .. link .. " has an equip slot (" .. iEquip .. ") that is not recognized")
		return
	end
	
	return ("%d:%d:%d:%d"):format(iLevel, iQual, invType, iId)
end

function getSigFromLink(link)
	assert(type(link) == "string")

	local _, _, id, rand = link:find("item:(%d+):%d+:(%d+):%d+")
	if id and rand then
		return id..":0:"..rand
	end
end

function getItems(str)
	if (not str) then return end
	local itemList = {};
	local itemKey;

	for itemID, randomProp, enchant, uniqID in str:gmatch("|Hitem:(%d+):(%d+):(%d+):(%d+)|h") do
		itemKey = itemID..":"..randomProp..":"..enchant;
		table.insert(itemList, itemKey)
	end
	return itemList;
end

--Many thanks to the guys at irc://irc.datavertex.com/cosmostesters for their help in creating this function
function getItemHyperlinks(str)
	if (not str) then return nil end
	local itemList = {};

	for color, item, name in str:gmatch("|c(%x+)|Hitem:(%d+:%d+:%d+:%d+)|h%[(.-)%]|h|r") do
		table.insert(itemList, "|c"..color.."|Hitem:"..item.."|h["..name.."]|h|r")
	end
	return itemList;
end
-----------------------------------
--   General Utility Functions   --
-----------------------------------

-- Extract the revision number from SVN keyword string
function getRevision(str)
	if not str then return 0 end
	local _, _, rev = str:find("Revision: (%d+)")
	return tonumber(rev) or 0
end

function split(str, at)
	local splut = {};

	if (type(str) ~= "string") then return nil end
	if (not str) then str = "" end

	if (not at)
		then table.insert(splut, str)

	else
		for n, c in str:gmatch('([^%'..at..']*)(%'..at..'?)') do
			table.insert(splut, n);

			if (c == '') then break end
		end
	end
	return splut;
end

-- Iterator version of split()
--   for i in spliterator(a, b) do
-- is equivalent to
--   for _, i in ipairs(split(a, b)) do
-- but puts less strain on the garbage collector
function spliterator(str, at)
	local start
	local found = 0
	local done = (type(str) ~= "string")
	return function()
		if done then return nil end
		start = found + 1
		found = str:find(at, start, true)
		if not found then
			found = 0
			done = true
		end
		return str:sub(start, found - 1)
	end
end

function chatPrint(text, cRed, cGreen, cBlue, cAlpha, holdTime)
	local frameIndex = Enchantrix.Config.GetFrameIndex();

	if (cRed and cGreen and cBlue) then
		if getglobal("ChatFrame"..frameIndex) then
			getglobal("ChatFrame"..frameIndex):AddMessage(text, cRed, cGreen, cBlue, cAlpha, holdTime);

		elseif (DEFAULT_CHAT_FRAME) then
			DEFAULT_CHAT_FRAME:AddMessage(text, cRed, cGreen, cBlue, cAlpha, holdTime);
		end

	else
		if getglobal("ChatFrame"..frameIndex) then
			getglobal("ChatFrame"..frameIndex):AddMessage(text, 1.0, 0.5, 0.25);
		elseif (DEFAULT_CHAT_FRAME) then
			DEFAULT_CHAT_FRAME:AddMessage(text, 1.0, 0.5, 0.25);
		end
	end
end


------------------------
--   Math Functions   --
------------------------

function gcd(a, b)
	-- Greatest Common Divisor, Euclidean algorithm
	local m, n = tonumber(a), tonumber(b) or 0
	while (n ~= 0) do
		m, n = n, math.fmod(m, n)
	end
	return m
end

-- Round up m to nearest multiple of n
function roundUp(m, n)
	return math.ceil(m / n) * n
end

-- Round m to n digits in given base
function round(m, n, base, offset)
	base = base or 10 -- Default to base 10
	offset = offset or 0.5

	if (n or 0) == 0 then
		return math.floor(m + offset)
	end

	if m == 0 then
		return 0
	elseif m < 0 then
		return -round(-m, n, base, offset)
	end

	-- Get integer and fractional part of n
	local f = math.floor(n)
	n, f = f, n - f

	-- Pre-rounding multiplier is 1 / f
	local mul = 1
	if f > 0.1 then
		mul = math.floor(1 / f + 0.5)
	end

	local d
	if n > 0 then
		d = base^(n - math.floor(math.log(m) / math.log(base)) - 1)
	else
		d = 1
	end
	if offset >= 1 then
		return math.ceil(m * d * mul) / (d * mul)
	else
		return math.floor(m * d * mul + offset) / (d * mul)
	end
end

-- Returns confidence interval for binomial distribution given observed
-- probability p, sample size n, and z-value
function confidenceInterval(p, n, z)
	if not z then
		--[[
		z		conf
		1.282	80%
		1.645	90%
		1.960	95%
		2.326	98%
		2.576	99%
		3.090	99.8%
		3.291	99.9%
		]]
		z = 1.645
	end
	assert(p >= 0 and p <= 1)
	assert(n > 0)

	local a = p + z^2 / (2 * n)
	local b = z * math.sqrt(p * (1 - p) / n + z^2 / (4 * n^2))
	local c = 1 + z^2 / n

	return (a - b) / c, (a + b) / c
end

---------------------
-- Debug functions --
---------------------

-- profiler:Start()
-- Record start time and memory, set state to running
local function _profilerStart(this)
	this.t = GetTime()
	this.m = gcinfo()
	this.r = true
end

-- profiler:Stop()
-- Record time and memory change, set state to stopped
local function _profilerStop(this)
	this.m = (gcinfo()) - this.m
	this.t = GetTime() - this.t
	this.r = false
end

-- profiler:DebugPrint()
local function _profilerDebugPrint(this)
	if this.n then
		Enchantrix.Util.DebugPrintQuick("Profiler ["..this.n.."]")
	else
		Enchantrix.Util.DebugPrintQuick("Profiler")
	end
	if this.r == nil then
		Enchantrix.Util.DebugPrintQuick("  Not started")
	else
		Enchantrix.Util.DebugPrintQuick(("  Time: %0.3f s"):format(this:Time()))
		Enchantrix.Util.DebugPrintQuick(("  Mem: %0.0f KiB"):format(this:Mem()))
		if this.r then
			Enchantrix.Util.DebugPrintQuick("  Running...")
		end
	end
end

-- time = profiler:Time()
-- Return time (in seconds) from Start() [until Stop(), if stopped]
local function _profilerTime(this)
	if this.r == false then
		return this.t
	elseif this.r == true then
		return GetTime() - this.t
	end
end

-- mem = profiler:Mem()
-- Return memory change (in kilobytes) from Start() [until Stop(), if stopped]
local function _profilerMem(this)
	if this.r == false then
		return this.m
	elseif this.r == true then
		return (gcinfo()) - this.m
	end
end

-- profiler = Enchantrix.Util.CreateProfiler("foobar")
function createProfiler(name)
	return {
		Start = _profilerStart,
		Stop = _profilerStop,
		DebugPrint = _profilerDebugPrint,
		Time = _profilerTime,
		Mem = _profilerMem,
		n = name,
	}
end

Enchantrix.Util = {
	Revision			= "$Revision$",

	GetItems			= getItems,
	GetItemType			= getItemType,
	SigFromLink			= sigFromLink,
	GetReagentInfo		= getReagentInfo,
	GetSigFromLink		= getSigFromLink,
	GetLinkFromName		= getLinkFromName,
	GetReagentPrice		= getReagentPrice,
	GetItemIdFromSig	= getItemIdFromSig,
	IsDisenchantable	= isDisenchantable,
	GetItemIdFromLink	= getItemIdFromLink,
	GetItemHyperlinks	= getItemHyperlinks,

	Split				= split,
	ChatPrint			= chatPrint,
	Spliterator			= spliterator,
	GetRevision			= getRevision,

	GCD					= gcd,
	Round				= round,
	RoundUp				= roundUp,
	ConfidenceInterval	= confidenceInterval,

	CreateProfiler		= createProfiler,
}


function Enchantrix.Util.GetIType(link)
	local const = Enchantrix.Constants
	local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, invTexture = GetItemInfo(link)

	if not (itemName and itemEquipLoc and itemRarity and itemLevel) then
		Enchantrix.Util.DebugPrint("GetIType", ENX_INFO, "GetItemInfo failed, bad link", "could not get item info for: " .. link)
		return
	end
	
	local class = const.InventoryTypes[itemEquipLoc] or 0
	
	if itemRarity < 2 or not (class and (class == const.WEAPON or class == const.ARMOR)) then
		return
	end
	
	return ("%d:%d:%d"):format(itemLevel,itemRarity,class)
end

function Enchantrix.Util.MaxDisenchantItemLevel(skill)
	local maxLevel = 20 + (5 * math.floor(skill / 25));
	return maxLevel;
end

-- NOTE: this is sort of an expensive function, so don't call it often
-- I've tried to make it friendlier by caching the value and only checking every 5 seconds

function Enchantrix.Util.GetUserEnchantingSkill()
	local MyExpandedHeaders = {}
	local i, j
	
	-- the user can't have increased their skill too much in 5 seconds
	if (Enchantrix.EnchantingSkill
		and Enchantrix.EnchantingSkillTimeStamp
		and GetTime() - Enchantrix.EnchantingSkillTimeStamp < 5) then
		return Enchantrix.EnchantingSkill
	end
	
	-- just in case the user doesn't have enchanting
	Enchantrix.EnchantingSkill = 0;
	
	-- search the skill tree for Mying skills
	for i=0, GetNumSkillLines(), 1 do
		local skillName, header, isExpanded, skillRank = GetSkillLineInfo(i)
	
		-- expand the header if necessary
		if ( header and not isExpanded ) then
			MyExpandedHeaders[i] = skillName
		end
	end
	
	ExpandSkillHeader(0)
	for i=1, GetNumSkillLines(), 1 do
		local skillName, header, _, skillRank = GetSkillLineInfo(i)
		-- check for the skill name
		if (skillName and not header) then
			if (skillName == _ENCH("Enchanting")) then
				-- save this in a global for caching, and the auction filters
				Enchantrix.EnchantingSkill = skillRank
				Enchantrix.EnchantingSkillTimeStamp = GetTime()
				-- no need to look at the rest of the skills
				break
			end
		end
	end
	
	-- close headers expanded during search process
	for i=0, GetNumSkillLines() do
		local skillName, header, isExpanded = GetSkillLineInfo(i)
		for j in pairs(MyExpandedHeaders) do
			if ( header and skillName == MyExpandedHeaders[j] ) then
				CollapseSkillHeader(i)
				MyExpandedHeaders[j] = nil
			end
		end
	end

	return Enchantrix.EnchantingSkill
end


ENX_CRITICAL = 1
ENX_ERROR = 2
ENX_WARNING = 3
ENX_NOTICE = 4
-- info will only go to nLog
ENX_INFO = 5
-- Debug will print to the chat console as well as to nLog
ENX_DEBUG = 6

function Enchantrix.Util.DebugPrint(mType, mLevel, mTitle, ...)
	-- function libDebugPrint(addon, message, category, title, errorCode, level)
	local message = DebugLib.Dump(...)
	DebugLib.DebugPrint("Enchantrix", message, mType, mTitle, nil, mLevel)
end

-- when you just want to print a message and don't care about the rest
function Enchantrix.Util.DebugPrintQuick(...)
	Enchantrix.Util.DebugPrint("General", ENX_INFO, "QuickDebug", "QuickDebug:", ... )
end
