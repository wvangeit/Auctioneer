--[[
	DebugLib
	An embedded library for Auctioneer which provides easier debugging and
	logging.
	<%version%> (<%codename%>)
	$Id$

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

-------------------------------------------------------------------------------
-- Function definitions
-------------------------------------------------------------------------------
local assert
local debugPrint
local dump

-------------------------------------------------------------------------------
-- Enumerations
-------------------------------------------------------------------------------
-- The different supported debug levels.
local level = {
		Critical = "Critical",
		Error    = "Error",
		Warning  = "Warning",
		Notice   = "Notice",
		Info     = "Info",
		Debug    = "Debug"
}

-------------------------------------------------------------------------------
-- Function declarations
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Prints the specified message to nLog.
--
-- parameters:
--    strAddon   - (string) the name of the addon/file used to specify where
--                          the error occured
--    strMessage - (string) the error message
--    level      - (string) level of debug message (optional - defaulting to
--                          "Debug")
--    iCode      - (number) the error code (optional)
--    priority   - nLog message level (optional - see remarks on which default
--                 value is used)
--
-- returns:
--    first value:
--       "none", if no iCode is specified
--       iCode, otherwise
--    second value:
--       strMessage
--
-- remarks:
--    If priority is not specified, a default value will be assigned. This
--    default value depends on the specified type parameter. If type is set to a
--    valid nLog level, the appropriate priority will be used (i.e. 1 for
--    "Critical", 2 for "Error", etc.). See nLog.levels for a complete list.
--    If there is no counterpart to the specified type, priority defaults to
--    N_DEBUG.
--
--    This function is not designed to be called directly. Instead it is meant
--    to have a local counterpart in each file, which automatically specifies
--    the strAddon parameter and then calls this function.
-------------------------------------------------------------------------------
-- TODO: add better automated logging text, including function name, line number
--       etc, dump caps
function debugPrint(strAddon, strMessage, level, iCode, priority)
	if not iCode then
		iCode = "none"
	end

	if nLog then
		if not level then
			level = nLog.levels[N_DEBUG]
		end
		if not priority then
			-- search the list of error levels to find the correct priority
			for iLevel, strLevel in pairs(nLog.levels) do
				if strLevel == level then
					priority = iLevel
					break
				end
			end
			priority = priority or N_DEBUG
		end
		nLog.AddMessage(strAddon, level, priority, "Errorcode: "..iCode, strMessage)
	end

	return iCode, strMessage
end

-------------------------------------------------------------------------------
-- Used to make sure that conditions are met within functions.
-- If bTest is false, the error message will be written to nLog and the user's
-- default chat channel.
--
-- parameters:
--    strAddon   - (string) the name of the addon/file used to identify the
--                          specific assertion
--    bTest      - (boolean) true, if the assertion was met
--                           false, otherwise
--    strMessage - (string) the message which will be output to the user
--
-- remark:
--    If nLog is present, the message will not only be written to the user's
--    channel, but also to nLog with the priority set to N_CRITICAL, since it
--    is assumed that assert() is only used in critical parts of functions and
--    that bTest is expected to never fail. This is especially useful to track
--    down bugs which might randomly occure. Therefore this log message is given
--    the highest priority.
--
--    This function is not designed to be called directly. Instead it is meant
--    to have a local counterpart in each file, which automatically specifies
--    the strAddon parameter and then calls this function.
-------------------------------------------------------------------------------
function assert(strAddon, bTest, strMessage)
	if bTest then
		return -- test passed, nothing to worry about
	end

	getglobal("ChatFrame1"):AddMessage(strMessage, 1.0, 0.3, 0.3)

	if nLog then
		nLog.AddMessage(strAddon, "Assertion", N_CRITICAL, "assertion failed", strMessage)
	end
end

-------------------------------------------------------------------------------
-- Creates a string by transforming all parameters into string representations
-- and concatenating these.
--
-- parameters:
--    ... - parameter which should be added to the string
--
-- returns:
--    (string) - The concatenated string.
--
-- remark:
--    Be aware that there is no safety measurement in place to handle recursions
--    inside of tables. If a recursion occures, this function causes a stack
--    overflow
-------------------------------------------------------------------------------
-- TODO: Add safety measurement to prohibit recursions inside tables causing
--       a stack overflow.
function dump(...)
	local out = ""
	local numVarArgs = select("#", ...)
	for i = 1, numVarArgs do
		local d = select(i, ...)
		local t = type(d)
		if (t == "table") then
			out = out .. "{"
			local first = true
			if (d) then
				for k, v in pairs(d) do
					if (not first) then out = out .. ", " end
					first = false
					out = out .. dump(k)
					out = out .. " = "
					out = out .. dump(v)
				end
			end
			out = out .. "}"
		elseif (t == "nil") then
			out = out .. "NIL"
		elseif (t == "number") then
			out = out .. d
		elseif (t == "string") then
			out = out .. "\"" .. d .. "\""
		elseif (t == "boolean") then
			if (d) then
				out = out .. "true"
			else
				out = out .. "false"
			end
		else
			out = out .. t:upper() .. "??"
		end

		if (i < numVarArgs) then out = out .. ", " end
	end
	return out
end

-------------------------------------------------------------------------------
-- Initialization code
-------------------------------------------------------------------------------
if not DebugLib then
	DebugLib = {
		Assert     = assert,
		DebugPrint = debugPrint,
		Dump       = dump,
		Level      = level
	}
end