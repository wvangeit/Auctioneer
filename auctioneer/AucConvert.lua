--[[
	Auctioneer Addon for World of Warcraft(tm).
	Version: <%version%>
	Revision: $Id$

	Auctioneer intra-version conversion.
	Functions that allow auctioneer to upgrade the data formats when necessary.
]]

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
				if (hyphen and not colon) then
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
						local name
						local sname
						local hist = ""
						-- addded by Luke1410 to convert old 2.x data to the new 3.2 format
						if type(iData) == "string" then
							local oldData = iData

							-- category
							local _, _, _, _, catName = GetItemInfo(sig)
							if catName == nil then
								-- !!!item not seen since serverrestart!!!
								cat = 0 -- mark as unknown
							else
								cat = Auctioneer_GetCatNumberByName(catName)
							end

							-- data/name
							local i, j, s1, s2, s3, s4, s5, s6, s7, sname = string.find(iData, "(%d+):(%d+):(%d+):(%d+):(%d+):(%d+):(%d+):(.+)")
							if s7 == nil then
								p("TODO!!!!! Very old format? iData = "..iData)
								p("Please report to: http://norganna.org/bb/index.php?showtopic=226")
							end
							data = s1..":"..s2..":"..s3..":"..s4..":"..s5..":"..s6..":"..s7
							name = sname
						else
							catName = Auctioneer_GetCatName(tonumber(iData.category));
							if (not catName) then iData.category = Auctioneer_GetCatNumberByName(iData.category) end 
							cat = iData.category;
							data = iData.data;
							name = iData.name;
							if (iData.buyoutPricesHistoryList) then
								for pos, hPrice in pairs(iData.buyoutPricesHistoryList) do
									if (hist == "") then hist = string.format("%d", hPrice);
									else hist = string.format("%s:%d", hist, hPrice); end
								end
							end
						end
						if (name) then
							local newData = string.format("%s|%s", data, hist);
							local newInfo = string.format("%s|%s", cat, name);
							AuctionConfig.data[server][sig] = newData;
							AuctionConfig.info[sig] = newInfo;
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
					local owner = bData.itemOwner;
					local won = bData.itemWon;
					if (won) then won = "1"; else won = "0"; end

					local newBid = string.format("%s|%s|%s|%s", sig, amount, won, owner);
					AuctionConfig.bids[player][time] = newBid;
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


