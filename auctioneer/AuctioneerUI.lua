--[[
	Auctioneer Addon for World of Warcraft(tm).
	Version: <%version%>
	Revision: $Id$

	Auctioneer UI manager
	
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
		along with this program(see GLP.txt); if not, write to the Free Software
		Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
--]]

-------------------------------------------------------------------------------
-- Data members
-------------------------------------------------------------------------------
CursorItem = nil;

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function AuctioneerUI_OnLoad()
	Stubby.RegisterFunctionHook("PickupContainerItem", 200, AuctioneerUI_PickupContainerItemHook)
end

-------------------------------------------------------------------------------
-- Called after Blizzard's AuctionFrameTab_OnClick() method.
-------------------------------------------------------------------------------
function AuctioneerUI_AuctionFrameTab_OnClickHook(_, _, index)
	if (not index) then 
		index = this:GetID();
	end
	
	-- Handle the Auctioneer tabs
	AuctionFrameSearch:Hide();
	AuctionFramePost:Hide();
	local tab = getglobal("AuctionFrameTab"..index);
	if (tab) then
		if (tab:GetName() == "AuctionFrameTabSearch") then
			AuctionFrameTopLeft:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Browse-TopLeft");
			AuctionFrameTop:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Browse-Top");
			AuctionFrameTopRight:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Browse-TopRight");
			AuctionFrameBotLeft:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Browse-BotLeft");
			AuctionFrameBot:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Browse-Bot");
			AuctionFrameBotRight:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Browse-BotRight");
			AuctionFrameSearch:Show();
		elseif (tab:GetName() == "AuctionFrameTabPost") then
			AuctionFrameTopLeft:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Browse-TopLeft");
			AuctionFrameTop:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Browse-Top");
			AuctionFrameTopRight:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Browse-TopRight");
			AuctionFrameBotLeft:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Browse-BotLeft");
			AuctionFrameBot:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Browse-Bot");
			AuctionFrameBotRight:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Browse-BotRight");
			AuctionFramePost:Show();
		end
	end
end

-------------------------------------------------------------------------------
-- Called after Blizzard's PickupContainerItem() method in order to capture
-- which item is on the cursor.
-------------------------------------------------------------------------------
function AuctioneerUI_PickupContainerItemHook(_, _, bag, slot)
	if (CursorHasItem()) then
		CursorItem = { bag = bag, slot = slot };
		--EnhTooltip.DebugPrint("Picked up item "..CursorItem.bag..", "..CursorItem.slot);
	else
		CursorItem = nil;
		--EnhTooltip.DebugPrint("Dropped item "..bag..", "..slot);
	end
	AuctioneerUI_GetCursorContainerItem();
end

-------------------------------------------------------------------------------
-- Gets the bag and slot number of the item on the cursor.
-------------------------------------------------------------------------------
function AuctioneerUI_GetCursorContainerItem()
	if (CursorHasItem() and CursorItem) then
		return CursorItem;
	end
	return nil;
end

