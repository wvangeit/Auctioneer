--[[

	Babylonian.lua

]]

local self = {}

local function split(str, at)
	local splut = {}
	if (type(str) ~= "string") then return nil end
	if (not str) then str = "" end
	if (not at) then table.insert(splut, str)
	else for n, c in string.gfind(str, '([^%'..at..']*)(%'..at..'?)') do
		table.insert(splut, n); if (c == '') then break end
	end end
	return splut
end

local function setOrder(order)
	if (not order) then self.order = {}
	else self.order = split(order, ",") end
	table.insert(self.order, GetLocale())
	table.insert(self.order, "enUS")
	SetCVar("BabylonianOrder", order)
end

local function getOrder(order)
	return GetCVar("BabylonianOrder")
end

local function fetchString(stringTable, locale, stringKey)
	if (type(stringTable)=="table" and
		type(stringTable[locale])=="table" and
		stringTable[locale][stringKey]) then
			return stringTable[locale][stringKey]
	end
end

local function getString(stringTable, stringKey, default)
	local val
	for i=1, table.getn(self.order) do
		val = fetchString(stringTable, self.order[i], stringKey)
		if (val) then return val end
	end
	return default
end

if (not Babylonian) then
	Babylonian = {
		['SetOrder'] = setOrder,
		['GetOrder'] = getOrder,
		['GetString'] = getString,
		['FetchString'] = fetchString,
	}
	RegisterCVar("BabylonianOrder", "")
	setOrder(getOrder())
end
