--[[
	Enchantrix Addon for World of Warcraft(tm).
	Version: <%version%> (<%codename%>)
	Revision: $Id: EnxUtil.lua 1735 2007-04-23 22:48:30Z ccox $

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
EnchantrixBarker_RegisterRevision("$URL: http://norganna.org/svn/auctioneer/trunk/enchantrix/EnxUtil.lua $", "$Rev: 1735 $")

-- Global functions
local getItems
local getSigFromLink
local getLinkFromName
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
		for i = 1, Barker.State.MAX_ITEM_ID + 4000 do
			local n, link = GetItemInfo(i)
			if n then
				if n == name then
					EnchantConfig.cache.names[name] = link
					break
				end
				Barker.State.MAX_ITEM_ID = math.max(Barker.State.MAX_ITEM_ID, i)
			end
		end
	end
	return EnchantConfig.cache.names[name]
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
	local frameIndex = Barker.Settings.GetSetting('printframe');

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
		Barker.Util.DebugPrintQuick("Profiler ["..this.n.."]")
	else
		Barker.Util.DebugPrintQuick("Profiler")
	end
	if this.r == nil then
		Barker.Util.DebugPrintQuick("  Not started")
	else
		Barker.Util.DebugPrintQuick(("  Time: %0.3f s"):format(this:Time()))
		Barker.Util.DebugPrintQuick(("  Mem: %0.0f KiB"):format(this:Mem()))
		if this.r then
			Barker.Util.DebugPrintQuick("  Running...")
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

-- profiler = Barker.Util.CreateProfiler("foobar")
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

Barker.Util = {
	Revision			= "$Revision: 1735 $",

	GetItems			= getItems,
	SigFromLink			= sigFromLink,
	GetSigFromLink		= getSigFromLink,
	GetLinkFromName		= getLinkFromName,
	GetItemIdFromSig	= getItemIdFromSig,
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



ENX_CRITICAL = 1
ENX_ERROR = 2
ENX_WARNING = 3
ENX_NOTICE = 4
-- info will only go to nLog
ENX_INFO = 5
-- Debug will print to the chat console as well as to nLog
ENX_DEBUG = 6

function Barker.Util.DebugPrint(mType, mLevel, mTitle, ...)
	-- function debugPrint(addon, message, category, title, errorCode, level)
	local message = DebugLib.Dump(...)
	DebugLib.DebugPrint("EnchantrixBarker", message, mType, mTitle, 1, mLevel)
end

-- when you just want to print a message and don't care about the rest
function Barker.Util.DebugPrintQuick(...)
	Barker.Util.DebugPrint("General", "Info", "QuickDebug", "QuickDebugMsg:", ... )
end
