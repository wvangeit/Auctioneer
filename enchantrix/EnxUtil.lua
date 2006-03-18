--[[
	Enchantrix Addon for World of Warcraft(tm).
	Version: <%version%> (<%codename%>)
	Revision: $Id$

	General utility functions and localization helper functions
	
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
		along with this program(see GLP.txt); if not, write to the Free Software
		Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
--]]

-- Convert a single key in a table of configuration settings
local function convertConfig(t, key, values, ...)
	local v = nil;
	
	for i,localizedKey in ipairs(arg) do
		if (t[localizedKey] ~= nil) then
			v = t[localizedKey];
			t[localizedKey] = nil;
		end
	end
	if (t[key] ~= nil) then v = t[key]; end
	
	if (v ~= nil) then
		if (values[v] ~= nil) then
			t[key] = values[v];
		else
			t[key] = v;
		end
	end
end

-- Convert Enchantrix filters to standardized keys and values
function Enchantrix_ConvertFilters()
	-- Abort if there's nothing to convert
	if (not EnchantConfig or not EnchantConfig.filters) then return; end

	-- Array that maps localized versions of strings to standardized
	local convertOnOff = {	['apagado'] = 'off',	-- esES
							['prendido'] = 'on',	-- esES
							}
	
	local localeConvMap = { ['apagado'] = 'default',
							['prendido'] = 'default',
							['off'] = 'default',
							['on'] = 'default',
							}
	
	-- Format: standardizedKey,		valueMap,		esES,					deDE (old)			...
	local conversions = {
			{ 'all',				convertOnOff },
			{ 'embed',				convertOnOff,	'integrar',				'zeige-eingebunden' },
			{ 'header',				convertOnOff,	'titulo',				'zeige-kopf'},
			{ 'counts',				convertOnOff,	'conteo',				'zeige-anzahl' },
			{ 'rates',				convertOnOff,	'razones',				'zeige-kurs' },
			{ 'valuate',			convertOnOff,	'valorizar',			'zeige-wert' },
			{ 'valuate-hsp',		convertOnOff,	'valorizar-pmv',		'valuate-hvp' },
			{ 'valuate-median',		convertOnOff,	'valorizar-mediano' },
			{ 'valuate-baseline',	convertOnOff,	'valorizar-referencia', 'valuate-grundpreis' },
			{ 'locale',				localeConvMap },
		}
		
	-- Run the defined conversions
	for i,c in ipairs(conversions) do
		table.insert(c, 1, EnchantConfig.filters)
		convertConfig(unpack(c))
	end
end

function Enchantrix_SetFilterDefaults()
	if (not EnchantConfig) then EnchantConfig = {}; end
	if (not EnchantConfig.filters) then EnchantConfig.filters = {}; end
	
	for k,v in pairs(Enchantrix_FilterDefaults) do
		if (EnchantConfig.filters[k] == nil) then
			EnchantConfig.filters[k] = v;
		end
	end
end

--------------------------------------
--		Localization functions		--
--------------------------------------

Enchantrix_CommandMap = nil;
Enchantrix_CommandMapRev = nil;

function Enchantrix_GetLocale()
	local locale = Enchantrix_GetFilterVal('locale');
	if (locale ~= 'default') then
		return locale;
	end
	return GetLocale();
end

function Enchantrix_GetLocalizedCmdString(value)
	return _ENCH('Cmd'..string.upper(string.sub(value,1,1))..string.sub(value,2))
end

function Enchantrix_DelocalizeFilterVal(value)
	if (value == _ENCH('CmdOn')) then
		return 'on';
	elseif (value == _ENCH('CmdOff')) then
		return 'off';
	elseif (value == _ENCH('CmdDefault')) then
		return 'default';
	elseif (value == _ENCH('CmdToggle')) then
		return 'toggle';
	else
		return value;
	end	
end

function Enchantrix_LocalizeFilterVal(value)
	if (value == 'on' or value == 'off' or value == 'default') then
		return Enchantrix_GetLocalizedCmdString(value)
	else
		return value;
	end
end

function Enchantrix_GetLocalizedFilterVal(key)
	return Enchantrix_LocalizeFilterVal(Enchantrix_GetFilterVal(key))
end


-- Turns a localized slash command into the generic English version of the command
function Enchantrix_DelocalizeCommand(cmd)
	if (not Enchantrix_CommandMap) then Enchantrix_BuildCommandMap();end
	local result = Enchantrix_CommandMap[cmd];
	if (result) then return result; else return cmd; end
end

-- Translate a generic English slash command to the localized version, if available
function Enchantrix_LocalizeCommand(cmd)
	if (not Enchantrix_CommandMap) then	Enchantrix_BuildCommandMap(); end
	local result = Enchantrix_CommandMapRev[cmd];
	if (result) then return result; else return cmd; end
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
		EnhTooltip.DebugPrint("Profiler ["..this.n.."]")
	else
		EnhTooltip.DebugPrint("Profiler")
	end
	if this.r == nil then
		EnhTooltip.DebugPrint("  Not started")
	else
		EnhTooltip.DebugPrint(string.format("  Time: %0.3f s", this:Time()))
		EnhTooltip.DebugPrint(string.format("  Mem: %0.0f KiB", this:Mem()))
		if this.r then
			EnhTooltip.DebugPrint("  Running...")
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

-- profiler = Enchantrix_CreateProfiler("foobar")
function Enchantrix_CreateProfiler(name)
	return {
		Start = _profilerStart,
		Stop = _profilerStop,
		DebugPrint = _profilerDebugPrint,
		Time = _profilerTime,
		Mem = _profilerMem,
		n = name,
	}
end
