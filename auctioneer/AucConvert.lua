--[[
	Auctioneer Addon for World of Warcraft(tm).
	Version: <%version%>
	Revision: $Id$

	Auctioneer intra-version conversion.
	Functions that allow auctioneer to upgrade the data formats when necessary.
]]

-- helperfunction to backup data, which can't be converted atm
local function Auctioneer_Backup(server, sig, data)
	if AuctionBackup[server] == nil then
		AuctionBackup[server] = {}
	end

	AuctionBackup[server][sig] = data
end

local function Auctioneer_IsSortedList(list)
	for i=2, table.getn(list) do
		if list[i] < list[i-1] then
			return false
		end
	end
	return true
end

function Auctioneer_Convert()
	if (not AuctionConfig.version) then AuctionConfig.version = 30000; end
	if (AuctionConfig.version < 30200) then
		AuctionConfig.data = {};
		AuctionConfig.info = {};
		AuctionConfig.snap = {};
		AuctionConfig.sbuy = {};
		if (AHSnapshot) then
			for server, sData in pairs(AHSnapshot) do
				local colon = string.find(server, ":");
				local hyphen = string.find(server, "-");
				if (hyphen and not colon) then
					if (not AuctionConfig.snap[server]) then
						AuctionConfig.snap[server] = {};
					end
					for sig, iData in pairs(sData) do
						local catName = Auctioneer_GetCatName(tonumber(iData.category));
						if (not catName) then iData.category = Auctioneer_GetCatNumberByName(iData.category) end 
						local cat = iData.category;
						Auctioneer_SaveSnapshot(server, cat, sig, iData);
					end
				end
			end
		end
		
		if (AHSnapshotItemPrices) then
			for server, sData in pairs(AHSnapshotItemPrices) do
				local colon = string.find(server, ":");
				local hyphen = string.find(server, "-");
				if (hyphen and not colon) and (sData.buyoutPrices == nil) then
					if (not AuctionConfig.sbuy[server]) then
						AuctionConfig.sbuy[server] = {};
					end
					for itemKey, iData in pairs(sData) do
						Auctioneer_SaveSnapshotInfo(server, itemKey, iData);
					end
				end
			end
		end

		if (AuctionPrices) then
			for server, sData in pairs(AuctionPrices) do
				local colon = string.find(server, ":");
				local hyphen = string.find(server, "-");
				if (hyphen and not colon) then
					AuctionConfig.data[server] = {};
					for sig, iData in pairs(sData) do
						local catName
						local cat
						local data
						local name = nil
						local hist = ""
						local newsig = sig
						if type(iData) == "string" then
							-- 2.x -> 3.1							
							local oldData = iData
							local s1, s2, s3, s4, s5, s6, s7, sname

							-- category
							name, _, _, _, catName = GetItemInfo(sig)
							if catName == nil then
								-- !!!item not seen since serverrestart!!!
								cat = 0 -- mark as unknown
							else
								cat = Auctioneer_GetCatNumberByName(catName)
							end
							
							-- signatue
							newsig = newsig..':0:0'

							-- data/name
							_, _, s1, s2, s3, s4, s5, s6, s7, sname = string.find(iData, "(%d+):(%d+):(%d+):(%d+):(%d+):(%d+):(%d+):(.+)")
							if s1 == nil then
								_, _, s1, s2, s3, s4, s5, s6, s7 = string.find(iData, "(%d+):(%d+):(%d+):(%d+):(%d+):(%d+):(%d+)")
							end
							if s1 == nil then
								-- unsuported, likely corrupt format (for example: s7 = -727389968)

								-- set name = '' to name = nil
								name = nil

								-- backing it up so we might convert it later
								Auctioneer_Backup(server, sig, iData)
							else
								if (name == nil) or (name == '') then
									name = sname
								end
								if (name == nil) or (name == '') then
									-- ouch ! can't convert the old data atm since no valid itemname can be found

									-- set name = '' to name = nil
									name = nil

									-- backing it up so we might convert it later
									Auctioneer_Backup(server, sig, iData)
								else
									-- only set the data, if the name has successfully been identified
									data = s1..":"..s2..":"..s3..":"..s4..":"..s5..":"..s6..":"..s7
								end
							end
						elseif iData.category == nil then
							-- unknown dataformat
							-- ouch ! strange dataformat, can't convert atm since there is no way to get the itemid right now
							-- backing it up so we might convert it later
							Auctioneer_Backup(server, sig, iData)
						else
							-- 3.0 -> 3.1
							catName = Auctioneer_GetCatName(tonumber(iData.category));
							if (not catName) then iData.category = Auctioneer_GetCatNumberByName(iData.category) end 
							cat = iData.category;
							data = iData.data;
							name = iData.name;
							if (iData.buyoutPricesHistoryList) then
								if not Auctioneer_IsSortedList(iData.buyoutPricesHistoryList) then
									Auctioneer_Print("TODO: old dataformat with unsorted buyoutHistory! "..sig)
									Auctioneer_Print("Please copy/paste the corresponding entry in SavedVariables/auctioneer.lua to: http://norganna.org/bb/index.php?showtopic=226")
								end
								hist = Auctioneer_StoreMedianList (iData.buyoutPricesHistoryList);
							end
						end
						if (name) then
							local newData = string.format("%s|%s", data, hist);
							local newInfo = string.format("%s|%s", cat, name);
							AuctionConfig.data[server][newsig] = newData;
							AuctionConfig.info[newsig] = newInfo;
						end
					end
				end
			end
		end
		
		AuctionConfig.bids = {};
		if (AuctionBids) then
			for player, pData in pairs(AuctionBids) do
				AuctionConfig.bids[player] = {};
				for time, bData in pairs(pData) do
					local amount = bData.bidAmount;
					local sig = bData.signature;
					local owner = bData.itemOwner or "unknown";
					local won = bData.itemWon;
					if (won) then won = "1"; else won = "0"; end

					if (player and time and amount and sig and won) then
						local newBid = string.format("%s|%s|%s|%s", sig, amount, won, owner);
						AuctionConfig.bids[player][time] = newBid;
					end
				end
			end
		end
	end

	-- Now the conversion is complete, wipe out the old data
	AHSnapshot = nil;
	AHSnapshotItemPrices = nil;
	AuctionPrices = nil;
	AuctionBids = nil;
	AuctionConfig.version = 30200;
end


