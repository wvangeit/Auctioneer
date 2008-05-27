--[[
	Auctioneer Advanced - EasyBuyout Utility Module
	Version: <%version%> (<%codename%>)
	Revision: $Id: EasyBuyout.lua 3054 2008-04-27 23:07:17Z MentalPower $
	URL: http://auctioneeraddon.com/

	This is an Auctioneer Advanced module that does something nifty.

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
--]]

local libType, libName = "Util", "EasyBuyout"
local lib,parent,private = AucAdvanced.NewModule(libType, libName)
if not lib then return end
local print,decode,recycle,acquire,clone,scrub,get,set,default = AucAdvanced.GetModuleLocals()
local addShift;
local CompactUImode = false
local orig_AB_OC;
local ebModifier = false

function lib.GetName()
	return libName
end

function lib.Processor(callbackType, ...)
    if (callbackType == "listupdate") then
        private.EasyBuyout()
	elseif (callbackType == "auctionui") then
		private.AHLoaded()
		private.EasyBuyout()
	elseif (callbackType == "config") then
		private.SetupConfigGui(...)
	elseif (callbackType == "configchanged") then
		private.EasyBuyout()
	end
end

function lib.OnLoad()
	print("AucAdvanced: {{"..libType..":"..libName.."}} loaded!")
	AucAdvanced.Settings.SetDefault("util.EasyBuyout.active", true)
    AucAdvanced.Settings.SetDefault("util.EasyBuyout.modifier.active", true)
    AucAdvanced.Settings.SetDefault("util.EasyBuyout.modifier.select", 0)
end

--[[ Local functions ]]--

function private.AHLoaded()
	if AucAdvanced.Modules.Util.CompactUI and AucAdvanced.Modules.Util.CompactUI.Private.ButtonClick and get("util.compactui.activated") then
		orig_AB_OC = AucAdvanced.Modules.Util.CompactUI.Private.ButtonClick
		AucAdvanced.Modules.Util.CompactUI.Private.ButtonClick = private.BrowseButton_OnClick
		CompactUImode = true
	else
		assert(BrowseButton_OnClick, "BrowseButton_OnClick doesn't exist yet")
		orig_AB_OC = BrowseButton_OnClick
		BrowseButton_OnClick = private.BrowseButton_OnClick
		CompactUImode = false
	end
end

function private.SetupConfigGui(gui)
	-- The defaults for the following settings are set in the lib.OnLoad function
	local id = gui:AddTab(libName)
	gui:MakeScrollable(id)
	gui:AddControl(id, "Header",     0,    libName.." options")
    gui:AddControl(id, "Subhead",          0,    "EasyBuyout allows you to make auction buyout a lot easier!")
	gui:AddControl(id, "Subhead",          0,    "Simply right-click an auction to buy it out with no confirmation box!")
    gui:AddControl(id, "Checkbox",   0, 1, "util.EasyBuyout.active", "Enable EasyBuyout")
    gui:AddTip(id, "Ticking this box will enable or disable the addon")
    gui:AddControl(id, "Checkbox",   0, 1, "util.EasyBuyout.modifier.active", "Enable key modifier")
    gui:AddControl(id, "Subhead",          0,   "Select your modifier below. (ex. shift+rightclick)")
    gui:AddControl(id, "Selectbox",  0, 1, {
		{0, "Shift"},
		{1, "Alt"},
		{2, "Shift+Alt"}
	}, "util.EasyBuyout.modifier.select", "testing here")
    gui:AddTip(id, "Select your key modifier")
    gui:AddHelp(id, "What is EasyBuyout?",
        "What is EasyBuyout?",
        "EasyBuyout makes it easier to buy auctions in mass, faster! You simply right-click (or 'modifier'+right-click depending on your options) to buyout an auction with no confirmation box")
end

function private.BrowseButton_OnClick(...)
    -- check for EB enabled
    if not get("util.EasyBuyout.active") then
        return orig_AB_OC(...)
    end

    -- check and assign modifier
    if get("util.EasyBuyout.modifier.active") then
        if (get("util.EasyBuyout.modifier.select") == 0) and IsShiftKeyDown() then
            ebModifier = true;
        elseif (get("util.EasyBuyout.modifier.select") == 1) and IsAltKeyDown() then
            ebModifier = true;
        elseif (get("util.EasyBuyout.modifier.select") == 2) and IsShiftKeyDown() and IsAltKeyDown() then
            ebModifier = true;
        else
            return orig_AB_OC(...)
        end
    end

    if (arg1 == "RightButton") then
        local button = select(1, ...) or this
	
		local id
		if CompactUImode then
			id = button.id
		else
			id = button:GetID() + FauxScrollFrame_GetOffset(BrowseScrollFrame)
		end
		local link = GetAuctionItemLink("list", id)
		if link then
            local _,_,count = GetAuctionItemInfo("list", id)
            ChatFrame1:AddMessage("Rightclick - buying auction of " .. (count or "?") .. "x" .. link)
        else
            ChatFrame1:AddMessage("Rightclick - not finding anything to buy. If you are mass clicking - try going from the bottom up!")
            return
        end
        SetSelectedAuctionItem("list", id);
        if get("util.EasyBuyout.shift.active") then
            if (IsShiftKeyDown()) then
                private.EasyBuyoutAuction();
            end
        else
            private.EasyBuyoutAuction();
        end
    else
        return orig_AB_OC(...)
    end
end

function private.EasyBuyout()
    if not AuctionFrame then return end
    
    if get("util.EasyBuyout.shift.active") then
        addShift = true;
    else
        addShift = false;
    end
    
    if get("util.EasyBuyout.active") then
       for i=1,50 do
            local button = _G["BrowseButton"..i]
            if not button then break end
            button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
            _G["BrowseButton"..i]:RegisterForClicks("LeftButtonUp", "RightButtonUp")
        end
    else
    
        return;
    end
end


function private.EasyBuyoutAuction()
    local EasyBuyoutIndex = GetSelectedAuctionItem("list");
    local EasyBuyoutPrice = select(9, GetAuctionItemInfo("list", EasyBuyoutIndex))
    PlaceAuctionBid("list", EasyBuyoutIndex, EasyBuyoutPrice)
    CloseAuctionStaticPopups();
end

AucAdvanced.RegisterRevision("$URL: http://dev.norganna.org/auctioneer/trunk/Auc-Advanced/Modules/Auc-Util-EasyBuyout/EasyBuyout.lua $", "$Rev: 3054 $")