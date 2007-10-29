--[[
	Auctioneer Addon for World of Warcraft(tm).
	Version: <%version%> (<%codename%>)
	Revision: $Id$
	URL: http://auctioneeraddon.com/
	
	BeanCounterUpdate - Upgrades the Beancounter Database to latest version 

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
		since that is it's designated purpose as per:
		http://www.fsf.org/licensing/licenses/gpl-faq.html#InterpreterIncompat
]]

local libName = "BeanCounter"
local libType = "Util"
local lib = AucAdvanced.Modules[libType][libName]
local private = lib.Private

local print = AucAdvanced.Print

local function debugPrint(...) 
private.debugPrint("BeanCounterFrames",...)
end


function private.UpgradeDatabaseVersion()
	print("START")
	if BeanCounterDB["version"] then --Remove the old global version and create new per toon version
		BeanCounterDB["version"] = nil
	end
	if not BeanCounterDB[private.realmName][private.playerName]["version"] then  --added in 1.01 update
		BeanCounterDB[private.realmName][private.playerName]["version"] = private.version
		BeanCounterDB[private.realmName][private.playerName]["vendorbuy"] = {}
		BeanCounterDB[private.realmName][private.playerName]["vendorsell"] = {}
	end

	if private.playerData["version"] < 1.015 then
		private.updateTo1_02A()
	elseif private.playerData["version"] < 1.02 then
		private.updateTo1_02B()
	end
		
end
--[[This changes the database to use ; and to replace itemNames with and itemlink]]--
function private.updateTo1_02A() 
	print("START A")
	--: to ; and itemName to itemlink
	for player, v in pairs(private.serverData) do
		for DB, data in pairs(v) do
			if type(data) == "table" then
				for itemID, value in pairs(data) do
				    for index, text in ipairs(value) do
					private.serverData[player][DB][itemID][index] = private.packString(strsplit(":", text)) --repackage all strings using ;
				    end
				end
			end
		end
	end
	for player, v in pairs(private.serverData) do
	    for DB, data in pairs(v) do
		print(DB)
		if DB == "version" then
		    private.serverData[player]["version"] = 1.015 --update each players version #
		end
	    end
	end
	private.updateTo1_02B()
end
function private.updateTo1_02B() 
print("START B")
	for player, v in pairs(private.serverData) do
		for DB, data in pairs(v) do
			if type(data) == "table" then
				for itemID, value in pairs(data) do
				    for index, text in ipairs(value) do
					local _, link = private.getItemInfo(itemID, "itemid")
					    if link then 
						text = text:gsub("(.-);", link..";", 1) --Change item Name to item links
						private.serverData[player][DB][itemID][index] = private.packString(strsplit(";", text)) --repackage string with new itemlink   
					    else
						name = text:match("(.-);")
						link = private.updateCreatelink(itemID, name)
						text = text:gsub("(.-);", link..";", 1) --Change item Name to item links
						private.serverData[player][DB][itemID][index] = private.packString(strsplit(";", text)) --repackage string with new itemlink   
					    end
				    end
				end
			end
		end
	end
	for player, v in pairs(private.serverData) do
	    for DB, data in pairs(v) do
		if DB == "version" then
		    private.serverData[player]["version"] = 1.02 --update each players version #
		end
	    end
	end
end 
function private.updateCreatelink(itemID, name) --If the server query dails make a fake link so we can still view item
    return "|cffffff33|Hitem:"..itemID..":0:0:0:0:0:0:1529248154|h["..name.."]|h|r" --Our fake links are always yellow
end
