--[[
	Auctioneer Addon for World of Warcraft(tm).
	Version: <%version%>
	Revision: $Id: AucConvert.lua 299 2005-09-26 12:33:35Z luke1410 $

	Auctioneer storage functions.
	Functions that allow auctioneer writing/reading data to/from its savedvariables file.
]]

function Auctioneer_HistMed(auctKey, itemKey, median, count)
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