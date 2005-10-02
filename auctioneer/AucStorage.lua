--[[
	Auctioneer Addon for World of Warcraft(tm).
	Version: <%version%>
	Revision: $Id: AucConvert.lua 299 2005-09-26 12:33:35Z luke1410 $

	Auctioneer storage functions.
	Functions that allow auctioneer writing/reading data to/from its savedvariables file.
]]

function Auctioneer_SetHistMed(auctKey, itemKey, median, count)
	if (not AuctionConfig.stats)                    then AuctionConfig.stats = {}                    end
	if (not AuctionConfig.stats.histmed)            then AuctionConfig.stats.histmed = {}            end
	if (not AuctionConfig.stats.histmed[auctKey])   then AuctionConfig.stats.histmed[auctKey] = {}   end
	if (not AuctionConfig.stats.histcount)          then AuctionConfig.stats.histcount = {}          end
	if (not AuctionConfig.stats.histcount[auctKey]) then AuctionConfig.stats.histcount[auctKey] = {} end
	if (count >= MIN_BUYOUT_SEEN_COUNT) then
		AuctionConfig.stats.histmed[auctKey][itemKey]   = median
		AuctionConfig.stats.histcount[auctKey][itemKey] = count
	else
		AuctionConfig.stats.histmed[auctKey][itemKey]   = 0
		AuctionConfig.stats.histcount[auctKey][itemKey] = 0
	end
end

function Auctioneer_SetSnapMed(auctKey, itemKey, median, count)
	if (not AuctionConfig.stats)                    then AuctionConfig.stats = {}                    end
	if (not AuctionConfig.stats.snapmed)            then AuctionConfig.stats.snapmed = {}            end
	if (not AuctionConfig.stats.snapmed[auctKey])   then AuctionConfig.stats.snapmed[auctKey] = {}   end
	if (not AuctionConfig.stats.snapcount)          then AuctionConfig.stats.snapcount = {}          end
	if (not AuctionConfig.stats.snapcount[auctKey]) then AuctionConfig.stats.snapcount[auctKey] = {} end
	if (count >= MIN_BUYOUT_SEEN_COUNT) then
		AuctionConfig.stats.snapmed[auctKey][itemKey]   = median
		AuctionConfig.stats.snapcount[auctKey][itemKey] = count
	else
		AuctionConfig.stats.snapmed[auctKey][itemKey]   = 0
		AuctionConfig.stats.snapcount[auctKey][itemKey] = 0
	end
end
