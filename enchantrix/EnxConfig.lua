--[[
	Enchantrix Addon for World of Warcraft(tm).
	Version: <%version%> (<%codename%>)
	Revision: $Id: EnxCommand.lua 817 2006-04-11 15:50:14Z aradan $

	Configuration functions.

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

-- Global functions
local addonLoaded		-- Enchantrix.Config.AddonLoaded()
local getFilterDefaults	-- Enchantrix.Config.GetFilterDefaults()
local setFilter			-- Enchantrix.Config.SetFilter()
local getFilter			-- Enchantrix.Config.GetFilter()
local setFrame			-- Enchantrix.Config.SetFrame()
local getFrameNames		-- Enchantrix.Config.GetFrameNames()
local getFrameIndex		-- Enchantrix.Config.GetFrameIndex()
local setLocale			-- Enchantrix.Config.SetLocale()
local getLocale			-- Enchantrix.Config.GetLocale()

-- Local functions
local convertConfig
local convertFilters
local isValidLocale

-- Function references
local _ENCH -- = Enchantrix.Locale.Localize

-- Default filter configuration
local filterDefaults = {
		['all'] = true,
		['embed'] = false,
		['counts'] = false,
		['header'] = true,
		['rates'] = true,
		['valuate'] = true,
		['valuate-hsp'] = true,
		['valuate-median'] = true,
		['valuate-baseline'] = true,
		['locale'] = GetLocale(),
		['printframe'] = 1,
	}

function addonLoaded()
	_ENCH = Enchantrix.Locale.Localize

	-- Convert old localized settings
	if EnchantConfig and EnchantConfig.filters then
		convertFilters()

		-- Convert 'on', 'off' and 'default' to true, false and nil
		for key in EnchantConfig.filters do
			setFilter(key, getFilter(key))
		end
	end
end

-- Convert a single key in a table of configuration settings
function convertConfig(t, key, values, ...)
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
function convertFilters()
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

function getFilterDefaults(key)
	return filterDefaults[key]
end

function getFilter(filter)
	local val = EnchantConfig.filters[filter]
	if val == nil then
		val = getFilterDefaults(filter)
	end
	return val
end

function setFilter(key, value)
	if (value == 'default') or (value == getFilterDefaults(key)) then
		-- Don't save default values
		value = nil
	elseif value == 'on' then
		value = true
	elseif value == 'off' then
		value = false
	end
	EnchantConfig.filters[key] = value
end

-- The following three functions were added by MentalPower to implement the /enx print-in command
function getFrameNames(index)

	local frames = {}
	local frameName

	for i = 1, NUM_CHAT_WINDOWS do
		-- name, fontSize, r, g, b, a, shown, locked, docked = GetChatWindowInfo(i)
		local name = GetChatWindowInfo(i)

		if ( name == "" ) then
			if (i == 1) then
				name = _ENCH('TextGeneral')
			elseif (i == 2) then
				name = _ENCH('TextCombat')
			end
		end
		frames[name] = i

		if i == index then
			frameName = name
		end
	end

	return frames, frameName or ""
end

function getFrameIndex()
	return Enchantrix.Config.GetFilter('printframe')
end

function setFrame(frame, chatprint)

	local frameNumber
	local frameVal
	frameVal = tonumber(frame)

	-- If no arguments are passed, then set it to the default frame.
	if not (frame) then
		frameNumber = 1;

	-- If the frame argument is a number then set our chatframe to that number.
	elseif ((frameVal) ~= nil) then
		frameNumber = frameVal;

	-- If the frame argument is a string, find out if there's a chatframe with that name, and set our chatframe to that index. If not set it to the default frame.
	elseif (type(frame) == "string") then
		allFrames = Enchantrix.Config.GetFrameNames();

		if (allFrames[frame]) then
			frameNumber = allFrames[frame];

		else
			frameNumber = 1;
		end

	-- If the argument is something else, set our chatframe to it's default value.
	else
		frameNumber = 1;
	end

	local _, frameName

	if (chatprint == true) then
		_, frameName = Enchantrix.Config.GetFrameNames(frameNumber);

		if (Enchantrix.Config.GetFrameIndex() ~= frameNumber) then
			Enchantrix.Util.ChatPrint(string.format(_ENCH('FrmtPrintin'), frameName));
		end
	end

	Enchantrix.Config.SetFilter("printframe", frameNumber);

	if (chatprint == true) then
		Enchantrix.Util.ChatPrint(string.format(_ENCH('FrmtPrintin'), frameName));
		Enchantrix.Command.SetKhaosSetKeyValue("printframe", frameNumber);
	end
end

function isValidLocale(param)
	--EnhTooltip.DebugPrint("Enchantrix.isValidlocale("..param..")");

	return (EnchantrixLocalizations and EnchantrixLocalizations[param])
end

local _localeLastSet = ""
function setLocale(param, chatprint, updateKhaos)
	param = Enchantrix.Locale.DelocalizeFilterVal(param)

	if not Babylonian.IsAddOnRegistered("Enchantrix") then
		Babylonian.RegisterAddOn("Enchantrix", setLocale)
	end

	local validLocale = false

	if (param == _localeLastSet) then
		validLocale = true
	elseif (param == 'default') or (param == 'off') then
		Babylonian.SetOrder('')
		validLocale = true
	elseif (isValidLocale(param)) then
		Babylonian.SetOrder(param)
		validLocale = true
	else
		validLocale = false
	end

	if chatprint then
		if validLocale then
			Enchantrix.Util.ChatPrint(string.format(_ENCH('FrmtActSet'), _ENCH('CmdLocale'), param))
			if param ~= _localeLastSet then
				setKhaosSetKeyValue('locale', param)
			end
		else
			Enchantrix.Util.ChatPrint(string.format(_ENCH("FrmtActUnknownLocale"), param))
			local locales = "    "
			for locale, data in pairs(EnchantrixLocalizations) do
				locales = locales .. " '" .. locale .. "' "
			end
			Enchantrix.Util.ChatPrint(locales)
		end
	end

	if (Khaos and Enchantrix.State.Khaos_Registered) then
		if (param ~= _localeLastSet) or updateKhaos then
			if (updateKhaos) then
				EnhTooltip.DebugPrint("Enchantrix: Babylonian.GetOrder() = "..Babylonian.GetOrder())
				setKhaosSetKeyValue('locale', Babylonian.GetOrder())
			end
			resetKhaos()
		end
	end

	if param then
		_localeLastSet = param
	end

	Enchantrix.State.Locale_Changed = true
end

function getLocale()
	local locale = Enchantrix.Config.GetFilter('locale')
	if locale ~= 'default' then
		return locale
	end
	return GetLocale()
end

Enchantrix.Config = {
	Revision			= "$Revision$",
	AddonLoaded			= addonLoaded,

	GetFilterDefaults	= getFilterDefaults,
	GetFilter			= getFilter,
	SetFilter			= setFilter,

	GetFrameNames		= getFrameNames,
	GetFrameIndex		= getFrameIndex,
	SetFrame			= setFrame,

	SetLocale			= setLocale,
	GetLocale			= getLocale,
}
