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
		You have an implicit license to use this AddOn with these facilities
		since that is it's designated purpose as per:
		http://www.fsf.org/licensing/licenses/gpl-faq.html#InterpreterIncompat
]]
LibStub("LibRevision"):Set("$URL$","$Rev$","5.1.DEV.", 'auctioneer', 'libs')

local libName = "BeanCounter"
local libType = "Util"
local lib = BeanCounter
local private, print, get, set, _BC = lib.getLocals()
private.update = {}

local function debugPrint(...)
    if get("util.beancounter.debugUpdate") then
        private.debugPrint("BeanCounterUpdate",...)
    end
end


function private.UpgradeDatabaseVersion()
	
	--Recreate the itemID array if for some reason user lacks it.
	if not BeanCounterDB["ItemIDArray"] then BeanCounterDB["ItemIDArray"] = {} private.refreshItemIDArray() end
	--REMOVED all DB update frunctions from 1.0 to 1.11  These are quite old client versions and can get Auc 5.1 release to get DB to this point, if the DB has not been destroyed by using it in a WoW 3.0 enviroment
	if private.playerData["version"] == 1.11 then --very new DB format
		private.update._2_00A()
	elseif private.playerData["version"] < 2.01 then --
		private.update._2_01()
	elseif private.playerData["version"] < 2.02 then --runs validate to correct ;Used won, Used Failed messages and prevent postDB function errors.
		private.update._2_02()
	elseif private.playerData["version"] < 2.03 then--if not upgraded yet then upgrade
		private.update._2_03()
	elseif private.playerData["version"] < 2.04 then --runs validate to correctjust to ckeck itemstrings from teh 3.0 changes
		private.update._2_04()
	elseif private.playerData["version"] < 2.05 then
		private.update._2_05()
	end
	if private.playerData["version"] < 2.06 then
		private.update._2_06()
	end
	if private.playerData["version"] < 2.07 then -- removes all 0 entries from stored strings. Makes all database entries same length for easier parsing
		private.update._2_07()
	end
	if private.playerData["version"] < 2.08 then -- removes all 0 entries from stored strings. Makes all database entries same length for easier parsing
		private.update._2_08()
	end
	if private.playerData["version"] < 2.09 then -- removes all 0 entries from stored strings. Makes all database entries same length for easier parsing
		private.update._2_09()
	end
end

--[[INTEGRITY CHECKS
Make sure the DB format is correct removing any entries that were missed by updating.
To be run after every DB update
]]--
local integrity = {} --table containing teh DB layout
	integrity["completedBids/Buyouts"] = {"number", "number", "number", "number", "number", "number", "string", "number", "string", "string"}--10
	integrity["completedAuctions"] = {"number", "number", "number", "number", "number", "number", "string", "number", "string", "string"}--10
	integrity["failedBids"] = {"number", "number", "number", "number", "number", "number", "string", "number", "string", "string"}--10
	integrity["failedAuctions"] = {"number", "number", "number", "number", "number", "number", "string", "number", "string", "string"}--10
	integrity["postedBids"] = {"number", "number", "string", "string", "number", "number", "string" } --7
	integrity["postedAuctions"] = {"number", "number", "number", "number", "number" ,"number", "string"} --7
local integrityClean, integrityCount = true, 0
 function private.integrityCheck(complete)
	local tbl
	debugPrint(integrityCount)
	for player, v in pairs(private.serverData)do
		for DB, data in pairs(v) do
			if  DB == "failedBids" or DB == "failedAuctions" or DB == "completedAuctions" or DB == "completedBids/Buyouts" or DB == "postedBids" or DB == "postedAuctions" then
				for itemID, value in pairs(data) do
					for itemString, data in pairs(value) do
						local _, itemStringLength = itemString:gsub(":", ":")
						--check that the data is a string and table
						if type(itemString) ~= "string"  or  type(data) ~= "table" then
							private.serverData[player][DB][itemID][itemString] = nil
							debugPrint("Failed: Invalid format", DB, data, "", itemString)
							integrityClean = false
						elseif itemStringLength > 10 then --Bad itemstring purge
							debugPrint("Failed: Invalid itemString", DB, data, "", itemString)
							local _, link = GetItemInfo(itemString) --ask server for a good itemlink
							local itemStringNew = lib.API.getItemString(link) --get NEW itemString from itemlink
							if itemStringNew then
								debugPrint(itemStringNew, "New link recived replacing")
								private.serverData[player][DB][itemID][itemStringNew] = data
								private.serverData[player][DB][itemID][itemString] = nil
							else
								debugPrint(itemString, "New link falied purging item")
								private.serverData[player][DB][itemID][itemString] = nil
							end
							integrityClean = false
						elseif itemStringLength < 9 then
							local itemStringNew = itemString..":80"
							private.serverData[player][DB][itemID][itemStringNew] = data
							private.serverData[player][DB][itemID][itemString] = nil
							integrityClean = false
						else
							for index, text in pairs(data) do
								tbl = {strsplit(";", text)}
									--check entries for missing data points
								if #integrity[DB] ~= #tbl then
									debugPrint("Failed: Number of entries invalid", player, DB, #tbl)
									table.remove(data, index)
									integrityClean = false
								elseif complete and private.IC(tbl, DB) then
									--do a full check type() = check
									debugPrint("Failed type() check", player, DB)
									table.remove(data, index)
									integrityClean = false
								end
							end
						end
					end

				end
			end
		end
	end
	--rerun integrity 10 times or until it goes cleanly
	if not integrityClean and  integrityCount < 10 then
		integrityCount = integrityCount + 1
		integrityClean = true
		private.integrityCheck(complete)
	else
		print("BeanCounter Integrity Check Completed after:",integrityCount, "passes")
		integrityClean, integrityCount = true, 0
		set("util.beancounter.integrityCheckComplete", true)
		set("util.beancounter.integrityCheck", true)
	end

end
--look at each value and compare to the number, string, number pattern for that specific DB
function private.IC(tbl, DB, text)
	for i,v in pairs(tbl) do
		if v ~= "" then --<nil> is a placeholder for string and number values, ignore
			v = tonumber(v) or v
			if type(v) ~= integrity[DB][i] then
				return true
			end
		end
	end
	return false
end

--[[2.0 DATABASE UPDATES]]--

--Creates new format itemID to itemLink/name Array
--Recreate/refresh ItemIName to ItemID array
function private.update._2_00A()
	private.fixMissingItemlinks() --use these util functions before we upgrade.
	private.fixMissingStack()
	--start the DB migration to new format. Do Array first
	BeanCounterDB["ItemIDArray"] = {}
	for player, v in pairs(private.serverData)do
		for DB,data in pairs(private.serverData[player]) do
			if type(data) == "table" then
				for itemID, value in pairs(data) do
					for index, text in ipairs(value) do
						local link , key, suffix = text:match("^(|c%x+|Hitem:(%d+).+:(%d+):%d+|h%[.+%].-);.*")
						if key and suffix and link then
							BeanCounterDB["ItemIDArray"][key..":"..suffix] = link
						end
					end
				end
			end
		end
	end
	private.update._2_00B()
end
function private.update._2_00B()
	for player, v in pairs(private.serverData)do
		private.serverData[player]["postedBuyouts"] = nil --no longer needed in new DB
		for DB,data in pairs(private.serverData[player]) do
			if DB == "postedBids" or DB == "postedAuctions" or DB == "completedAuctions"  or DB == "failedAuctions" or DB == "completedBids/Buyouts" or DB == "failedBids" or DB == "vendorsell" or DB == "vendorbuy" then
				for itemID, values in pairs(data) do
					for index, text in ipairs(values) do --use ipairs so we do not see new array additions
						local itemKey = text:match("^|c%x+|H(.+)|h%[.+%].-;.*") --extract the itemstring
						text = private.update._2_00D(text) --remove reason text(s)
						if player and DB and itemID and itemKey and text then
							private.update._2_00C(player, DB, itemID, itemKey, text) --send data back to DB to be "re-added" in new format
							private.serverData[player][DB][itemID][index] = nil --remove old entry after conversion
						end
					end
				end
			end
		end
		private.serverData[player]["version"] = 2.0
	end
	private.update._2_01()
end
--2.0 updgrade utility functions
function private.update._2_00D(text)
	text = text:gsub("^(|c%x+|H.+|h%[.+%].-;)","",1) --remove itemLink
	text = text:gsub("^Auction won;","",1)
	text = text:gsub("^Auction successful;","",1)
	text = text:gsub("^Auction failed;","",1)
	text = text:gsub("^Auction expired;","",1)
	text = text:gsub("^Outbid;","",1)
	return text
end
function private.update._2_00C(player, key, itemID, itemLink, value)
	if private.serverData[player][key][itemID] then --if ltemID exsists
		if private.serverData[player][key][itemID][itemLink] then
			table.insert(private.serverData[player][key][itemID][itemLink], value)
		else
			private.serverData[player][key][itemID][itemLink] = {value}
		end
	else
		private.serverData[player][key][itemID]={[itemLink] = {value}}
	end
end
--removes old "Wealth entry to make room for reason codes
function private.update._2_01()
	for player, v in pairs(private.serverData)do
		for DB, data in pairs(private.serverData[player]) do
			if  DB == "failedBids" or DB == "failedAuctions" or DB == "completedAuctions" or DB == "completedBids/Buyouts" then
				for itemID, value in pairs(data) do
					for itemString, index in pairs(value) do
						for i, item in pairs(index) do
							local reason = item:match(".+;(.-)$")
							if tonumber(reason) or reason == "<nil>" then
								item = item:gsub("(.+);.-$", "%1;", 1)
								private.serverData[player][DB][itemID][itemString][i] = item
							end
						end
					end
				end
			end
		end
		private.serverData[player]["version"] = 2.01
	end
	private.update._2_02()
end
--runs validate to correct ;Used won, Used Failed messages and prevent postDB function errors.
function private.update._2_02()
	private.playerData["version"] = 2.02
	private.update._2_03()
end

--Updates all keys and itemLinks due to extension in WotLK expansion
--NOT IMPLEMENTED UNTIL CLIENT VERSION IS 30000
function private.update._2_03()
	for player, v in pairs(private.serverData)do
		if private.serverData[player]["version"] < 2.03 then
			for DB, data in pairs(private.serverData[player]) do
				if  DB == "failedBids" or DB == "failedAuctions" or DB == "completedAuctions" or DB == "completedBids/Buyouts" or DB == "postedAuctions" or DB == "postedBids" then
					for itemID, value in pairs(data) do
						local temp = {}
						for itemString, index in pairs(value) do
							itemString = itemString..":80"
							temp[itemString] = index
						end
						private.serverData[player][DB][itemID] = temp
					end
				end
			end
		end
		private.serverData[player]["version"] = 2.03
	end

	--Upgrade the itemID array's itemLinks only needs to run once
	if not get("util.beancounter.ItemLinkArray.upgradedtoWotLK") then
		print("WOW version 30000 ItemLink Array upgrade started")
		local temp = {}
		for i,v in pairs(BeanCounterDB["ItemIDArray"]) do
			v = v:gsub("(.*item:.-)|(.*)", "%1:80|%2" )
			temp[i] = v
		end
		BeanCounterDB["ItemIDArray"] = temp
		set("util.beancounter.ItemLinkArray.upgradedtoWotLK", true)
		print("WOW version 30000 ItemLink Array upgrade finished")
	end

	print("WOW version 30000 Update finished")
	
	private.update._2_04()
end
--this is just to bring us to post WoW 3.0 so some of the hacks can be removed
function private.update._2_04()
	for player, v in pairs(private.serverData)do
		private.serverData[player]["version"] = 2.04
	end
	private.update._2_05()
end
--Bah run one last integrity check.
function private.update._2_05()
	private.integrityCheck(true)
	for player, v in pairs(private.serverData)do
		private.serverData[player]["version"] = 2.05
	end
end
--corrects itemArray errors from rev 3601 failed upgrade
function private.update._2_06()
	private.integrityCheck(true)

	local temp = {}
	for i,v in pairs(BeanCounterDB["ItemIDArray"]) do
		if v:match("^|.-|Hitem:.-|h%[.-%]:.-|h|r") then
			v = v:gsub( "(.*)(|h%[.-%]):80(|h|r)", "%1:80%2%3")
		elseif v:match("^|.-|Hitem:.-:.-:.-:.-:.-:.-:.-:.-:%d-|h%[.-%]|h|r") then
		 --do nothing normal link
		else--purge it, will be recreated when server sees it once again
			v = nil
		end
		temp[i] = v
	end
	BeanCounterDB["ItemIDArray"] = temp
		
	for player, v in pairs(private.serverData)do
		private.serverData[player]["version"] = 2.06
	end
end

function private.update._2_07()
	local function convert(DB , text)
		if  DB == "failedBids" then
			local money, Time = strsplit(";", text)
			text =  private.packString("", money,"", "", "", "", "", Time, "","")
		elseif DB == "failedAuctions" then
			local stack, buyout, bid, deposit, Time, reason = strsplit(";", text)
			text = private.packString(stack, "", deposit, "", buyout, bid,  "", Time, reason, "")
		elseif DB == "completedAuctions" then
			local stack,  money, deposit, fee, buyout, bid, buyer, Time, reason = strsplit(";", text)
			text = private.packString(stack,  money, deposit , fee, buyout , bid, buyer, Time, reason, "")
		elseif DB == "completedBids/Buyouts" then
			local stack,  money, fee, buyout, bid, buyer, Time, reason = strsplit(";", text)
			text = private.packString(stack,  money, "" , fee, buyout , bid, buyer, Time, reason, "")
		end
		return text
	end
			
	for player, v in pairs(private.serverData)do
		for DB, data in pairs(v) do
			if  DB == "failedBids" or DB == "failedAuctions" or DB == "completedAuctions" or DB == "completedBids/Buyouts"  then
				for itemID, value in pairs(data) do
					for itemString, data in pairs(value) do
						for index, text in pairs(data) do
							text = convert(DB , text)
							private.serverData[player][DB][itemID][itemString][index] = text
						end
					end
				end
			end
		end
		private.serverData[player]["version"] = 2.07
	end
end
--[[moves itemNameArray  to not store full itemlinks but generate when needed
from "10155:1046"] = "|cff1eff00|Hitem:10155:0:0:0:0:0:1046:898585428:15|h[Mercurial Greaves of the Whale]|h|r",
to "10155:1046"] = "cff1eff00:Mercurial Greaves of the Whale",
reduces saved variable size and slighty increases text string matching speed even with the overhead needed to change it back to an itemlink
]]
function private.update._2_08()
--just let 2.09 do it.  Yes we will nuke teh array in each server that has not been upgraded. But we do not know how far behind each server is.
end
--Storing the data using a colon caused issues with schematics so store using a ;  instead.
--Easiest to just regenerate the ItemID array
function private.update._2_09()
	BeanCounterDB["ItemIDArray"] = {}
	for player, v in pairs(private.serverData)do
		private.serverData[player]["version"] = 2.09
	end
end