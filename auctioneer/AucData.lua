--[[
	Auctioneer Addon for World of Warcraft(tm).
	Version: <%version%>
	Revision: $Id$

	Auctioneer data access and management.
	Functions central to setting/getting any data from Auctioneer.
]]

function Auctioneer_GetVendorBuyPrice(itemId)
	local ret = Auctioneer_GetItemDataByID(itemId)
	return ret.buy
end

function Auctioneer_GetVendorSellPrice(itemId)
	local ret = Auctioneer_GetItemDataByID(itemId)
	return ret.sell
end