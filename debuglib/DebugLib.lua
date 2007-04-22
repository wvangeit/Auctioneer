--[[
	DebugLib
	An embedded library which works as a higher layer for nLog, by providing
	easier usage of debugging features.
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

	Manual:
		This manual is a basic introduction to this library and gives examples
		about how to use it. For a more detailed description, refere to the
		each function's documentation.

		>>>What the library is designed for<<<
		DebugLib is designed to act as a layer over the nLog addon. It makes the
		usage of nLog features easier and even works without nLog being
		installed at all. This allows the integration of a useful debug system
		in any addon without forcing the users to install a debug addon which
		they don't need.
		On the other side developers can install nLog and at once have access to
		all the debug messages without having to change anything in the code.
		If you want to know more about nLog, please refer to the nLog
		documentation.

		>>>Installation Requirements<<<
		Any addon which uses debugLib should add nLog as an optional dependancy.
		That way it is made sure that nLog is being loaded before debugLib is so
		debugLib's initialization code works as intended.

		>>>Integrating the Template Functions in an Addon<<<
		This library provides 2 template functions. These are designed to get
		local counterparts in an addon and should not be used directly.
		Instead the suggestion is to define local functions in your addon equal
		to the following reference implementation:

			local addonName = "MyAddon"

			local function debugPrint(message, category, errorCode, level)
				return DebugLib.DebugPrint(addonName, message, category, errorCode, level)
			end

			local function assert(test, message)
				return DebugLib.Assert(addonName, test, message)
			end

		Refer to the assert() and debugPrint() functions in this file to see a
		more detailed example.

		>>>Common Syntax/Usage of Main Functions<<<
		There are 3 main functions provided by this library:
		DebugLib.DebugPrint(), DebugLib.Assert() and DebugLib.Dump()
		The following examples show how these functions could be used in your own
		addon. For these examples it is expected that your addon provides the
		local counterparts for DebugLib.DebugPrint() and DebugLib.Assert() as
		described above.

			debugPrint("An error occured while processing the data.",
			           "data processor", 5)
			This is the normal usage for defined errors using debugPrint.

			debugPrint("Defaulting the parameters...",
			           "scan", DebugLib.Level.Notice)
			This generates a notice message.

			assert(v < 5, "The given value is too big.")
			Simple usage of the assert function.

			debugPrint("Corrupt tempTable: "..DebugLib.Dump(tempTable),
			           "general", 5)
			Creating an error message and dumping the content of a table.

			if type(a) == "string" then
				return debugPrint("The given parameter must not be a string.",
				                  "testPattern()", 22)
			end
			This demonstrates the usage debugPrints()'s return value. In this case
			the function returns 22, "The given parameter must not be a string."
			which the calling function can use to handle the error.

			if not assert(isValidParameter(a1), "a1 is invalid abording...") then
				return
			end
			Example usage of the assert return value.

		For a more detailed description of possible syntaxes for these functions
		refer to the description of the specific function.
]]

-------------------------------------------------------------------------------
-- Error Codes
-------------------------------------------------------------------------------
-- 1 = invalid argument (at least one of the arguments passed to the function
--                       is invalid)

-------------------------------------------------------------------------------
-- Enumerations
-------------------------------------------------------------------------------
-- Lookup list of all nLog levels. It should correspond with the list in nLog.
local levelLookupList
if not nLog then
	levelLookupList = {
		["Critical"] = 1,
		["Error"]    = 2,
		["Warning"]  = 3,
		["Notice"]   = 4,
		["Info"]     = 5,
		["Debug"]    = 6
	}
else
	-- if nLog exists, we can use its list to make 100% sure, that the content 
	-- is the same
	levelLookupList = {}
	for index, levelString in ipairs(nLog.levels) do
		levelLookupList[levelString] = index
	end
end

-- The different supported debug levels.
local levelList = {
	-- Critical = "Critical",
	-- Error    = "Error",
	-- Warning  = "Warning",
	-- Notice   = "Notice",
	-- Info     = "Info",
	-- Debug    = "Debug"
}
for stringLevel in pairs(levelLookupList) do
	levelList[stringLevel] = stringLevel
end

-------------------------------------------------------------------------------
-- Constants
-------------------------------------------------------------------------------
local addonName = "DebugLib"

-------------------------------------------------------------------------------
-- Function definitions
-------------------------------------------------------------------------------
local assert
local debugPrint
local generateTitle
local libAssert
local libDebugPrint
local libSimpleAssert
local libSimpleDebugPrint
local normalizeParameters
local dump

-------------------------------------------------------------------------------
-- Function declarations
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Prints the specified message to nLog.
-- This is the version used for DebugLib.DebugPrint, if nLog is installed and
-- enabled.
--
-- syntax:
--    errorCode, message = libDebugPrint(addon[, message][, category][, errorCode][, level])
--
-- parameters:
--    addon     - (string) the name of the addon
--    message   - (string) the error message
--                nil, no error message specified
--    category  - (string) the category of the debug message
--                nil, no category specified
--    errorCode - (number) the error code
--                nil, no error code specified
--    level     - (string) nLog message level
--                         Any nLog.levels string is valid.
--                nil, no level specified
--
-- returns:
--    errorCode - (number) errorCode, if one is specified
--                nil, otherwise
--    message   - (string) message, if one is specified
--                nil, otherwise
--
-- remarks:
--    >>>EXAMPLES<<<
--    Here are examples of all valid syntaxes for this function. The list is
--    ordered by how common the usage of the specific syntax is.
--       1) Common usage to quickly create debug messages in your working copy:
--          libDebugPrint("DebugLib", "Entered the function.")
--          This results in the message being written as a debug message to
--          nLog and, if enabled in nLog, to the chat channel as well. These
--          message types are normally used for local debugging, only.
--
--       2) Complete specified error entry:
--          libDebugPrint("DebugLib", "Error while processing the frame.",
--                        "UI", 6)
--          This is the preferred syntax for specifying errors.
--
--       3) Complete specified debug warning entry:
--          libDebugPrint("DebugLib", "Entering failsafe mode.", "Backend",
--                        DebugLib.Level.Warning)
--          This is the preferred syntax for any message type except errors.
--
--       4) Fully specified debug message:
--          libDebugPrint("DebugLib", "Critical error in function call.",
--                        "Scan", 6, DebugLib.Level.Critical)
--          This is the full syntax. It is the suggested syntax for specifying
--          log entries which return error codes and have a different level than
--          DebugLib.Level.Error.
--
--       5) Quick specified error entry, with only basic information:
--          libDebugPrint("DebugLib", "Failed to read data.", 5)
--          This creates a new error entry in nLog. This syntax can be used, if
--          you have to add this message quickly but don't want to specify the
--          category yet.
--
--       6) Quick specified debug entry, with only basic information:
--          libDebugPrint("DebugLib", "Executing unsafe code.",
--                        DebugLib.Level.Notice)
--          This creates a new notice entry in nLog. It's basically used, if
--          you have to quickly add some debug information but don't want to
--          specify the category yet.
--
--       7) Partly specified error entry:
--          libDebugPrint("DebugLib", "Fatal error in command handler.", 9,
--                        DebugLib.Level.Critical)
--          This syntax is possible, but quite uncommon. Instead of using this,
--          one should prefer the fully specified debug message.
--          It generates a new log entry for critical errors with no category.
--
--       8) Empty log entry:
--          libDebugPrint("DebugLib")
--          This unusual usage will generate an empty debug log entry in nLog.
--
--       9) Empty log entry with defined log level:
--          libDebugPrint("DebugLib", DebugLib.Level.Info)
--          Though valid, this syntax is also not very common. It creates an
--          empty notice in nLog.
--
--    >>>SPECIAL FUNCTION HANDLING<<<
--    Since the level parameter is a string representation, be aware of how the
--    function handles the following ambiguous calls.
--
--       Second or third parameter is a string found in DebugLib.Level:
--          libDebugPrint("DebugLib", "Error")
--          This will be interpreted as a type 9 syntax.
--          message  = nil
--          category = "unspecified"
--          level    = DebugLib.Level.Error
--
--          libDebugPrint("DebugLib", "Error occured.", "Critical")
--          This will be interpreted as a type 6 syntax.
--          message  = "Error occured."
--          category = "unspecified"
--          level    = DebugLib.Level.Critical
--
--       Second and third parameters are strings found in DebugLib.Level:
--          libDebugPrint("DebugLib", "Warning", "Notice")
--          This will be interpreted as a type 6 syntax.
--          message  = "Warning"
--          category = "unspecified"
--          level    = DebugLib.Level.Notice
--
--       Second and/or third parameter are strings found in DebugLib.Level and
--       parameter 4 is a string found in DebugLib.Level, too:
--          libDebugPrint("DebugLib", "Warning", "Debug", "Error")
--          This will be interpreted as a type 3 syntax.
--          message  = "Warning"
--          category = "Debug"
--          level    = DebugLib.Level.Error
--
--    >>>OPTIONAL PARAMETERS<<<
--    The examples above show all allowed syntaxes for this function and
--    explain the outcome. The following is a more code driven explanation of
--    what the default behaviour is, if one or more of the optional parameters
--    are missing.
--
--    category:
--    If no category is specified, the generated nLog message will print
--    "unspecified" as the category.
--
--    level:
--    If no level and no error code is specified, the level will be defaulting
--    to DebugLib.Level.Debug.
--    If no level is specified but an error code is given, the level will be
--    defaulting to DebugLib.Level.Error.
--
--    >>>TITLE<<<
--    The titel in nLog is not specified by the developer, but automatically
--    generated based on the errorCode and level.
--    If an errorCode is specified, the title says: "Errorcode: x".
--    If no errorCode is present and the level is either
--    DebugLib.Level.Critical or DebugLib.Level.Error, then the title says:
--    "Errorcode: unspecified".
--    If no errorCode is given and the level is neither DebugLib.Level.Critical
--    nor DebugLib.Level.Error, the title is the same as the level (for
--    instance: "Notice").
--
--    >>>ERROR HANDLING<<<
--    If any error occurs, the error will be written to nLog, if nLog is
--    enabled. Despite of wether or not nLog is installed, processing the debug
--    message will continue.
--    To continue processing, invalid parameters will be ignored and in cases
--    of invalid ambiguous function calls, a decision is made about which value
--    will be used. The generated error message in nLog will explain, what was
--    wrong.
--    For a list of possible errorcodes, refer to the Error Codes section.
--
--    >>>TEMPLATE FUNCTION<<<
--    This function is not designed to be called directly. Instead it is meant
--    to have a local counterpart in each file, which automatically specifies
--    the addon parameter and then calls this function.
--    Refer to the local debugPrint() function for the reference implementation.
-------------------------------------------------------------------------------
-- TODO: add better automated logging text, including function name, line number
--       etc, dump caps
function libDebugPrint(addon, message, category, errorCode, level)
	addon, message, category, errorCode, level = normalizeParameters(addon, message, category, errorCode, level)
	local title = generateTitle(level, errorCode)

	-- nLog.AddMessage() uses select() to check if any message is there.
	-- Since select() will count even passed nil values, nLog would create "NIL"
	-- as the message rather than an empty string. Therefore we need to take
	-- care of this behavior and handle it by ourself.
	local textMessage = message or ""

	nLog.AddMessage(addon, category, levelLookupList[level], title, textMessage)

	return errorCode, message
end

-------------------------------------------------------------------------------
-- The function does not do anything but processing the parameters and returning
-- the errorCode and message.
-- This is the version used for DebugLib.DebugPrint, if nLog is not installed or
-- disabled.
--
-- syntax:
--    errorCode, message = libDebugPrint(addon[, message][, category][, errorCode][, level])
--
-- parameters:
--    addon     - (string) the name of the addon
--    message   - (string) the error message
--                nil, no error message specified
--    category  - (string) the category of the debug message
--                nil, no category specified
--    errorCode - (number) the error code
--                nil, no error code specified
--    level     - (string) nLog message level
--                         Any nLog.levels string is valid.
--                nil, no level specified
--
-- returns:
--    errorCode - (number) errorCode, if one is specified
--                nil, otherwise
--    message   - (string) message, if one is specified
--                nil, otherwise
--
-- remarks:
--    Refer to the description of libDebugPrint() to see a more detailed
--    explanation about this function.
-------------------------------------------------------------------------------
function libSimpleDebugPrint(addon, message, category, errorCode, level)
	_, message, _, errorCode = normalizeParameters(addon, message, category, errorCode, level)

	return errorCode, message
end

-------------------------------------------------------------------------------
-- Prints the specified message to nLog.
--
-- syntax:
--    errorCode, message = debugPrint([message][, category][, errorCode][, level])
--
-- parameters:
--    message   - (string) the error message
--                nil, no error message specified
--    category  - (string) the category of the debug message
--                nil, no category specified
--    errorCode - (number) the error code
--                nil, no error code specified
--    level     - (string) nLog message level
--                         Any nLog.levels string is valid.
--                nil, no level specified
--
-- returns:
--    errorCode - (number) errorCode, if one is specified
--                nil, otherwise
--    message   - (string) message, if one is specified
--                nil, otherwise
--
-- remarks:
--    This is the reference implementation for a local version of debugPrint().
--    Refer to the documentation about libDebugPrint for a more detailed
--    description about this function.
-------------------------------------------------------------------------------
function debugPrint(message, category, errorCode, level)
	return DebugLib.DebugPrint(addonName, message, category, errorCode, level)
end

-------------------------------------------------------------------------------
-- Analyses and rearanges the given parameters, if necessary. Any invalidity
-- will cause a debug message, but the function will continue by automatically
-- handling these cases.
--
-- syntax:
--    addon, message, category, errorCode, level = normalizeParameter(addon[, message][, category][, errorCode][, level])
--
-- parameters:
--    addon     - (string) the name of the addon
--    message   - (string) the error message
--                nil, no error message specified
--    category  - (string) the category of the debug message
--                nil, no category specified
--    errorCode - (number) the error code
--                nil, no error code specified
--    level     - (string) nLog message level
--                         Any nLog.levels string is valid.
--                nil, no level specified
--
-- returns:
--    addon     - (string) the name of the addon
--                "unspecified", if there was no addon name
--    message   - (string) message, if one is specified
--                nil, otherwise
--    category  - (string) category
--                "unspecified", if no valid category was specified
--    errorCode - (number) error code
--                nil, if no valid error code was specified
--    level     - (string) debug level
--                   One of the levelList values.
--
-- remarks:
--    This is a helper function for libDebugPrint and manages its complex
--    syntaxes by correctly ordering and handling the specified parameters.
--    Refer to the documentation about libDebugPrint() to read in detail how
--    the parameter list is handled.
-------------------------------------------------------------------------------
function normalizeParameters(addon, message, category, errorCode, level)
	-- return values
	local retAddon, retMessage, retCategory, retErrorCode, retLevel

	-- process the addon parameter
	if addon == nil then
		-- addon is not defined
		debugPrint("No addon specified! Defaulting to \"unspecified\" and continue with processing the debug message.",
		           "debugPrint",
		           1)
	elseif type(addon) ~= "string" then
		-- addon is of an invalid type
		debugPrint("Invalid addon parameter! The type "..type(addon).." is not supported. Defaulting to \"unspecified\" and continue with processing the debug message.",
		           "debugPrint",
		           1)
	else
		-- addon content is valid
		retAddon = addon
	end

	-- process the level parameter
	if level ~= nil then
		-- The level parameter is present. It should contain the level content.
		if type(level) ~= "string" then
			-- It's not a string, therefore it's invalid.
			debugPrint("Invalid level parameter. The type "..type(level).." is not supported.  Removing the value and continue with processing the debug message.",
			           "debugPrint",
			           1)
		else
			-- It's a string and should be one of the valid levels.
			if not isDebugLevel(level) then
				-- It's not one of the valid levels, therefore the content is
				-- invalid.
				debugPrint("Invalid level parameter. The given string is no valid debug level. Removing the value and continue with processing the debug message.",
				           "debugPrint",
				           1)
			else
				-- level content is valid
				retLevel = level
			end
		end
	end

	-- process the errorCode parameter
	if errorCode ~= nil then
		-- The errorCode parameter is present. It should contain either the
		-- errorCode or level content.
		if (type(errorCode) == "string") and (level == nil) then
			-- errorCode could contain the level parameter
			if not isDebugLevel(errorCode) then
				-- It does not contain a valid level, therefore the parameter is
				-- invalid.
				debugPrint("Invalid errorCode parameter. The given string is no valid debug level. Removing the value and continue with processing the debug message.",
				           "debugPrint",
				           1)
			elseif retLevel ~= nil then
				-- ErrorCode contains a valid level parameter, but level parameter
				-- is set, too.
				debugPrint("Multiple level parameters specified. Ignoring the one in errorCode and continue processing the debug message.",
				           "debugPrint",
				           1)
			else
				-- ErrorCode contains the valid level parameter and it's the only
				-- one.
				retLevel = errorCode
			end
		elseif type(errorCode) ~= "number" then
			-- errorCode contains an invalid parameter
			debugPrint("Invalid errorCode type. The type "..type(errorCode).." is not supported. Removing the value and continue with processing the debug message.",
			           "debugPrint",
			           1)
		else
			-- errorCode content is valid
			retErrorCode = errorCode
		end
	end

	-- process the category parameter
	if category ~= nil then
		-- The category parameter is present. It should contain either the
		-- category, errorCode or level content.
		if (type(category) == "number") and (level == nil) then
			-- It's the error code. Make sure that it's the only one.
			if retErrorCode then
				-- errorCode is already present, ignore the one in category
				debugPrint("Multiple error codes specified! Ignoring the one in category and continue processing the debug message.",
				           "debugPrint",
				           1)
			else
				-- we got the error code, so safe it in the right place
				retErrorCode = category
			end
		elseif type(category) ~= "string" then
			-- category contains invalid content
			debugPrint("Invalid category type. The type "..type(category).." is not supported. Removing the value and continue with processing the debug message.",
			           "debugPrint",
			           1)
		else
			-- It's either the category or the level content.
			if (errorCode == nil) and (level == nil) and not retLevel and isDebugLevel(category) then
				-- it's the level content
				retLevel = category
			else
				-- it's the category
				retCategory = category
			end
		end
	end

	-- process the message parameter
	if message ~= nil then
		-- The message parameter is present. It should contain either the
		-- message, errorCode or level content.
		if (type(message) == "number") and (errorCode == nil) and (level == nil) then
			-- It's the error code. Make sure that it's the only one.
			if retErrorCode then
				-- errorCode is already present, ignore the one in message
				debugPrint("Multiple error codes specified! Ignoring the one in message and continue processing the debug message.",
				           "debugPrint",
				           1)
			else
				-- we got the error code, so safe it in the right place
				retErrorCode = message
			end
		elseif type(message) ~= "string" then
			-- message contains invalid content
			debugPrint("Invalid message type. The type "..type(message).." is not supported. Removing the value and continue with processing the debug message.",
			           "debugPrint",
			           1)
		else
			-- It's either the message or the level content.
			if (category == nil) and (errorCode == nil) and (level == nil) and not retLevel and isDebugLevel(message) then
				-- it's the level content
				retLevel = message
			else
				retMessage = message
			end
		end
	end

	-- defaulting return values, for unspecified ones
	retAddon    = retAddon    or "unspecified"
	retCategory = retCategory or "unspecified"
	if not retLevel then
		if retErrorCode then
			retLevel = levelList.Error
		else
			retLevel = levelList.Debug
		end
	end

	return retAddon, retMessage, retCategory, retErrorCode, retLevel
end

-------------------------------------------------------------------------------
-- Checks the given level to see if it's a valid debug level.
--
-- syntax:
--    validLevel = isDebugLevel(level)
--
-- parameters:
--    level - (string) the level parameter to be checked
--
-- returns:
--    validLevel - (boolean) true, if the level string represents a valid
--                                 debug level
--                           false, otherwise
-------------------------------------------------------------------------------
function isDebugLevel(level)
	if type(level) ~= "string" then
		return false -- it's not a string, so it can't be a valid level
	end

	for _, levelString in pairs(levelList) do
		if levelString == level then
			return true -- it's a valid level
		end
	end

	return false -- level is not in the level list, therefore it's invalid
end

-------------------------------------------------------------------------------
-- Takes the debug level and error code and returns a title for the log entry
-- according to these parameters.
--
-- syntax:
--    title = generateTitle(level[, errorCode])
--
-- parameters:
--    level     - (string) the debug level
--    errorCode - (number) the error code
--                nil, if no error code is specified
--
-- returns:
--    title - (string) the generated title
--
-- remarks:
--    Refer to the documentation about libDebugPrint() to see which titles are
--    generated.
-------------------------------------------------------------------------------
function generateTitle(level, errorCode)
	if errorCode then
		return "Errorcode: "..errorCode
	elseif (level == DebugLib.Level.Error) or (level == DebugLib.Level.Critical) then
		return "Errorcode: unspecified"
	else
		return level
	end
end

-------------------------------------------------------------------------------
-- Used to make sure that conditions are met within functions.
-- If test is false, the error message will be written to nLog and the user's
-- default chat channel.
-- This is the version used for DebugLib.Assert, if nLog is installed and
-- enabled.
--
-- syntax:
--    assertion = libAssert(addon, test, message)
--
-- parameters:
--    addon   - (string)  the name of the addon/file used to identify the
--                        specific assertion
--    test    - (any)     false/nil, if the assertion failed
--                        anything else, otherwise
--    message - (string)  the message which will be output to the user
--
-- return:
--    assertion - (boolean) true, if the test passed
--                          false, otherwise
--
-- remark:
--    >>>NLOG ENTRY<<<
--    If nLog is present, the message will not only be written to the user's
--    channel, but also to nLog with the priority set to N_CRITICAL, since it
--    is assumed that Assert() is only used in critical parts of functions and
--    that test is expected to never fail. This is especially useful to track
--    down bugs which might randomly occure. Therefore this log message is given
--    the highest priority.
--
--    >>>ERROR HANDLING<<<
--    If any error occurs, the error will be written to nLog, if nLog is
--    enabled. Despite of wether or not nLog is installed, processing the debug
--    message will continue.
--    To continue processing, missing parameters will get default values. The
--    generated error message in nLog will explain, what was wrong.
--    For a list of possible errorcodes, refer to the Error Codes section.
--
--    >>>TEMPLATE FUNCTION<<<
--    This function is not designed to be called directly. Instead it is meant
--    to have a local counterpart in each file, which automatically specifies
--    the addon parameter and then calls this function.
--    Refer to the local assert() function for the reference implementation.
-------------------------------------------------------------------------------
function libAssert(addon, test, message)
	-- validate the parameters
	if type(addon) ~= "string" then
		debugPrint("Invalid addon parameter. Addon must be a string.",
		           "assert",
		           1)
		addon = "unspecified"
	end
	if type(message) ~= "string" then
		debugPrint("Invalid message parameter. Message must be a string.",
		           "assert",
		           1)
		message = ""
	end

	if test then
		return true -- test passed
	end

	getglobal("ChatFrame1"):AddMessage(message, 1.0, 0.3, 0.3)

	if nLog then
		nLog.AddMessage(addon, "Assertion", N_CRITICAL, "assertion failed", message)
	end

	return false -- test failed
end

-------------------------------------------------------------------------------
-- Used to make sure that conditions are met within functions.
-- If test is false, the error message will be written to nLog and the user's
-- default chat channel.
--
-- syntax:
--    assertion = assert(test, message)
--
-- parameters:
--    test    - (any)     false/nil, if the assertion failed
--                        anything else, otherwise
--    message - (string)  the message which will be output to the user
--
-- returns:
--    assertion - (boolean) true, if the test passed
--                          false, otherwise
--
-- remarks:
--    This is the reference implementation for a local version of assert().
--    Refer to the documentation about libAssert for a more detailed
--    description about this function.
-------------------------------------------------------------------------------
function assert(test, message)
	return DebugLib.Assert(addonName, test, message)
end

-------------------------------------------------------------------------------
-- Used to make sure that conditions are met within functions.
-- If test is false, the error message will be written to the user's default
-- chat channel.
-- This is the version used for DebugLib.Assert, if nLog is not installed or
-- disabled.
--
-- syntax:
--    assertion = libSimpleAssert(addon, test, message)
--
-- parameters:
--    addon   - (string)  the name of the addon/file used to identify the
--                        specific assertion
--    test    - (any)     false/nil, if the assertion failed
--                        anything else, otherwise
--    message - (string)  the message which will be output to the user
--
-- return:
--    assertion - (boolean) true, if the test passed
--                          false, otherwise
--
-- remarks:
--    Refer to the description of libAssert() to see a more detailed explanation
--    about this function.
-------------------------------------------------------------------------------
function libSimpleAssert(addon, test, message)
	-- validate the parameters
	if type(addon) ~= "string" then
		debugPrint("Invalid addon parameter. Addon must be a string.",
		           "assert",
		           1)
		addon = "unspecified"
	end
	if type(message) ~= "string" then
		debugPrint("Invalid message parameter. Message must be a string.",
		           "assert",
		           1)
		message = ""
	end

	if test then
		return true -- test passed
	end

	getglobal("ChatFrame1"):AddMessage(message, 1.0, 0.3, 0.3)

	return false -- test failed
end

-------------------------------------------------------------------------------
-- Creates a string by transforming all parameters into string representations
-- and concatenating these.
--
-- syntax:
--    concatString = dump(...)
--
-- parameters:
--    ... - (any) parameters which should be added to the string
--
-- returns:
--    concatStrin - (string) The concatenated string.
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
		Dump       = dump,
		Level      = levelList,
		Version    = {
		   Major = 1,
		   Minor = 0
		}
	}

	if nLog then
		DebugLib["Assert"]     = libAssert
		DebugLib["DebugPrint"] = libDebugPrint
	else
		DebugLib["Assert"]     = libSimpleAssert
		DebugLib["DebugPrint"] = libSimpleDebugPrint
	end
end