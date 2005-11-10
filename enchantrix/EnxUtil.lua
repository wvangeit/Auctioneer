--[[
	Enchantrix Addon for World of Warcraft(tm).
	Version: <%version%>
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
	return getglobal("ENCH_CMD_" .. string.upper(value))
end

function Enchantrix_DelocalizeFilterVal(value)
	if (value == ENCH_CMD_ON) then
		return 'on';
	elseif (value == ENCH_CMD_OFF) then
		return 'off';
	elseif (value == ENCH_CMD_DEFAULT) then
		return 'default';
	elseif (value == ENCH_CMD_TOGGLE) then
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