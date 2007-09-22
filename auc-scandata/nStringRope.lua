--[[
	nStringRope Lib for World of Warcraft (tm)
	Version: <%version%> (<%codename%>)
	Revision: $Id$
	URL: http://norganna.org

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
		This source code is specifically designed to work with
		World of Warcraft's interpreted AddOn system.
		You have an implicit licence to use this AddOn with these facilities
		since that is its designated purpose as per:
		http://www.fsf.org/licensing/licenses/gpl-faq.html#InterpreterIncompat
]]

local LIBRARY_VERSION_MAJOR = "nStringRope"
local LIBRARY_VERSION_MINOR = 2

do -- LibStub
	-- LibStub is a simple versioning stub meant for use in Libraries.  http://www.wowace.com/wiki/LibStub for more info
	-- LibStub is hereby placed in the Public Domain
	-- Credits: Kaelten, Cladhaire, ckknight, Mikk, Ammo, Nevcairiel, joshborke
	local LIBSTUB_MAJOR, LIBSTUB_MINOR = "LibStub", 2  -- NEVER MAKE THIS AN SVN REVISION! IT NEEDS TO BE USABLE IN ALL REPOS!
	local LibStub = _G[LIBSTUB_MAJOR]

	-- Check to see is this version of the stub is obsolete
	if not LibStub or LibStub.minor < LIBSTUB_MINOR then
		LibStub = LibStub or {libs = {}, minors = {} }
		_G[LIBSTUB_MAJOR] = LibStub
		LibStub.minor = LIBSTUB_MINOR

		-- LibStub:NewLibrary(major, minor)
		-- major (string) - the major version of the library
		-- minor (string or number ) - the minor version of the library
		--
		-- returns nil if a newer or same version of the lib is already present
		-- returns empty library object or old library object if upgrade is needed
		function LibStub:NewLibrary(major, minor)
			assert(type(major) == "string", "Bad argument #2 to `NewLibrary' (string expected)")
			minor = assert(tonumber(strmatch(minor, "%d+")), "Minor version must either be a number or contain a number.")

			local oldminor = self.minors[major]
			if oldminor and oldminor >= minor then return nil end
			self.minors[major], self.libs[major] = minor, self.libs[major] or {}
			return self.libs[major], oldminor
		end

		-- LibStub:GetLibrary(major, [silent])
		-- major (string) - the major version of the library
		-- silent (boolean) - if true, library is optional, silently return nil if its not found
		--
		-- throws an error if the library can not be found (except silent is set)
		-- returns the library object if found
		function LibStub:GetLibrary(major, silent)
			if not self.libs[major] and not silent then
				error(("Cannot find a library instance of %q."):format(tostring(major)), 2)
			end
			return self.libs[major], self.minors[major]
		end

		-- LibStub:IterateLibraries()
		--
		-- Returns an iterator for the currently registered libraries
		function LibStub:IterateLibraries()
			return pairs(self.libs)
		end

		setmetatable(LibStub, { __call = LibStub.GetLibrary })
	end
end -- LibStub

local lib = LibStub:NewLibrary(LIBRARY_VERSION_MAJOR, LIBRARY_VERSION_MINOR)
if not lib then return end

--Local references of used functions
local pairs = pairs
local tconcat = table.concat
local tinsert = table.insert

-- Create a new nStringRope instance
function lib:New()
	local new = { strings = {} }
	for k,v in pairs(self.kit) do
		new[k] = v
	end
	return new
end

-- Holds the functions to be copied to new nStringRope instances
lib.kit = {}

-- Clears the nStringRope instance
function lib.kit:Clear()
	local size = #self.strings
	for i = size, 1, -1 do self.strings[i] = nil end
end
-- Gets the current nStringRope instance
function lib.kit:Get()
	return tconcat(self.strings)
end
-- Adds a substring to the nStringRope instance
function lib.kit:Add(text)
	if #self.strings > 245 then
		local text = self:Get()
		self:Clear()
		self:Add(text)
	end
	return tinsert(self.strings, text)
end

