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
		private.EasyCancelMain()
        private.EasyBuyout()
	elseif (callbackType == "auctionui") then
		private.AHLoaded()
		private.EasyBuyout()
		private.EasyCancelMain()
	elseif (callbackType == "config") then
		private.SetupConfigGui(...)
	elseif (callbackType == "configchanged") then
		private.EasyBuyout()
		private.EasyCancelMain()
	end
end

function lib.OnLoad()
	print("AucAdvanced: {{"..libType..":"..libName.."}} loaded!")
	
	-- EasyBuyout Default Settings
	AucAdvanced.Settings.SetDefault("util.EasyBuyout.active", false)
	AucAdvanced.Settings.SetDefault("util.EasyBuyout.modifier.active", true)
	AucAdvanced.Settings.SetDefault("util.EasyBuyout.modifier.select", 0)
	
	-- EasyCancel Default Settings
	AucAdvanced.Settings.SetDefault("util.EasyBuyout.EC.active", false)
	AucAdvanced.Settings.SetDefault("util.EasyBuyout.EC.modifier.active", true)
	AucAdvanced.Settings.SetDefault("util.EasyBuyout.EC.modifier.select", 0)
	
	-- EasyBid Default Settings
	AucAdvanced.Settings.SetDefault("util.EasyBuyout.EBid.active", false)
	--This settting will be used to turn off the module for current users until THEY choose to activate it
	--this will give us a new user friendly default state for builds past AuctioneerAdvancedSuite-5.0.PRE.3164
	--Remove this function once on or two builds have been released.
	AucAdvanced.Settings.SetDefault("util.EasyBuyout.EB.Deactivate", false)
	if not get("util.EasyBuyout.EB.Deactivate") then
		set("util.EasyBuyout.active", false)
		set("util.EasyBuyout.EC.active", false)
		set("util.EasyBuyout.EBid.active", false)
		set("util.EasyBuyout.EB.Deactivate", true)
	end
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
	
	-- EasyBuyout
	gui:AddControl(id, "Header",     0,    "EasyBuyout options")
	gui:AddControl(id, "Subhead",          0,    "Simply right-click an auction to buy it out with no confirmation box!")
    gui:AddControl(id, "Checkbox",   0, 1, "util.EasyBuyout.active", "Enable EasyBuyout")
    gui:AddTip(id, "Ticking this box will enable or disable EasyBuyout")
    gui:AddControl(id, "Checkbox",   0, 1, "util.EasyBuyout.modifier.active", "Enable key modifier")
	gui:AddTip (id, "Ticking this box will add a key modifier to EasyBuyout")
    gui:AddControl(id, "Selectbox",  0, 1, {
		{0, "Shift"},
		{1, "Alt"},
		{2, "Shift+Alt"}
	}, "util.EasyBuyout.modifier.select", "testing here")
    gui:AddTip(id, "Select your key modifier for EasyBuyout")
	
 	-- EasyCancel
	gui:AddControl(id, "Header",		0,		"EasyCancel options")
	gui:AddControl(id, "Subhead",		   0,   "Simply right-click an auction to cancel it out with no confirmation box!")
	gui:AddControl(id, "Checkbox",   0, 1, "util.EasyBuyout.EC.active", "Enable EasyCancel")
	gui:AddTip(id, "Ticking this box will enable or disable EasyCancel")
	gui:AddControl(id, "Checkbox",   0, 1, "util.EasyBuyout.EC.modifier.active", "Enable key modifier")
	gui:AddTip (id, "Ticking this box will add a key modifier to EasyCancel")
    gui:AddControl(id, "Selectbox",  0, 1, {
		{0, "Shift"},
		{1, "Alt"},
		{2, "Shift+Alt"}
	}, "util.EasyBuyout.EC.modifier.select", "testing here")
    gui:AddTip(id, "Select your key modifier for EasyCancel")
	
	-- EasyBid
	gui:AddControl(id, "Header",		0,		"EasyBid options")
	gui:AddControl(id, "Subhead",		   0,   "Simply double-click an auction to bid minimum on it!")
	gui:AddControl(id, "Checkbox",   0, 1, "util.EasyBuyout.EBid.active", "Enable EasyBid")
	gui:AddTip(id, "Ticking this box will enable or disable EasyBid")
	
	-- help sections
    gui:AddHelp(id, "What is EasyBuyout?",
        "What is EasyBuyout?",
        "EasyBuyout makes it easier to buy auctions in mass, faster! You simply right-click (or 'modifier'+right-click depending on your options) to buyout an auction with no confirmation box")
	
	gui:AddHelp(id, "What is EasyCancel?",
		"What is EasyCancel?",
		"Take what EasyBuyout does and apply it to canceling auctions! All you do is right-click (or 'modifier'+right-click) to cancel an auction you have posted up with no conformation box")

	gui:AddHelp(id, "What is EasyBid?",
		"What is EasyBid?",
		"This part of the EasyBuyout utility does what the name implies, it allows you to double click (or 'modifier'+double-click) to bid minimal on an auction! !!NOTE!! EasyBid can not use key modifiers because of the use of \"left-click\". It conflicts with other parts of auctioneer.")
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
		private.EasyBuyoutAuction();
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
    
    if (get("util.EasyBuyout.active") or get("util.EasyBuyout.EBid.active")) then
       for i=1,50 do
            local button = _G["BrowseButton"..i]
            if not button then break end
            button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
            _G["BrowseButton"..i]:RegisterForClicks("LeftButtonUp", "RightButtonUp")
			button:SetScript("ondoubleclick", private.NewOnDoubleClick)
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


--[[ EasyCancel Function - Easy Auction Cancel is a lot simpler to incorporate everything in it's own section
	 rather than incorporating it into everything else coded before this comment. EasyCancel does not need to be
	 hooked like EasyBuyout does with compactUI
--]]

local function OrigAuctionOnClick(...)
	if ( IsModifiedClick() ) then
		HandleModifiedItemClick(GetAuctionItemLink("owner", this:GetParent():GetID() + FauxScrollFrame_GetOffset(AuctionsScrollFrame)));
	else
		AuctionsButton_OnClick(self);
	end
end
-- handler for modifiers
local function NewOnClick(self, button)
	local active = get("util.EasyBuyout.EC.active")
	local modified = get("util.EasyBuyout.EC.modifier.active")
	local modselect = get("util.EasyBuyout.EC.modifier.select")

	if active and button=="RightButton" and
			(
			(not modified)
			or (modified and modselect == 0 and IsShiftKeyDown())
			or (modified and modselect == 1 and IsAltKeyDown())
			or (modified and modselect == 2 and IsAltKeyDown() and IsShiftKeyDown())
			)	then
		private.EasyCancel(self, button)
	else
		OrigAuctionOnClick(self, button)
	end

end

function private.EasyCancelMain()

	for i=1,199 do
		local button = _G["AuctionsButton"..i]
		if not button then break end
		button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
		_G["AuctionsButton"..i.."Item"]:RegisterForClicks("LeftButtonUp", "RightButtonUp")
		button:SetScript("onclick", NewOnClick)
	end
end

function private.EasyCancel(self, button)
	
	local link = GetAuctionItemLink("owner", self:GetID() + FauxScrollFrame_GetOffset(AuctionsScrollFrame))
	if link then
		local _,_,count = GetAuctionItemInfo("owner", self:GetID() + FauxScrollFrame_GetOffset(AuctionsScrollFrame))
		ChatFrame1:AddMessage("Rightclick - cancelling auction of " .. (count or "?") .. "x" .. link)
	else
		return ChatFrame1:AddMessage("Rightclick - not finding anything to cancel. If you are mass clicking - try going from the bottom up!")
	end

	SetSelectedAuctionItem("owner", self:GetID() + FauxScrollFrame_GetOffset(AuctionsScrollFrame));
	CancelAuction(GetSelectedAuctionItem("owner"))
	CloseAuctionStaticPopups();
	AuctionFrameBid_Update();
end

-- EasyBid Function - This section listed below is for EasyBid: the utility that allows users to easily bid on an item simply by double clicking on it.


function private.NewOnDoubleClick(self, button)

	-- check for EBid enabled
    if not get("util.EasyBuyout.EBid.active") then
        return
    end

	local id
	if CompactUImode then
		id = self.id
	else
		id = self:GetID() + FauxScrollFrame_GetOffset(BrowseScrollFrame)
	end
	local link = GetAuctionItemLink("list", id)
	if button == 'LeftButton' then
		if (select(11, GetAuctionItemInfo("list", id))) then
			ChatFrame1:AddMessage("You are already the highest bidder on this item!")
			return
		end
		if link then
			local _,_,count = GetAuctionItemInfo("list", id)
			ChatFrame1:AddMessage("Doubleclick - bidding on auction of " .. (count or "?") .. "x" .. link)
		else
			ChatFrame1:AddMessage("Doubleclick - not finding anything to bid on. If you are mass clicking - try going from the bottom up!")
			return
		end
	SetSelectedAuctionItem("list", self:GetID() + FauxScrollFrame_GetOffset(BrowseScrollFrame));
	private.EasyBidAuction(id);
	CloseAuctionStaticPopups();
	end
end

function private.EasyBidAuction(getID)
    local EasyBuyoutPrice = select(10, GetAuctionItemInfo("list", getID)) + select(8, GetAuctionItemInfo("list", getID))
	if EasyBuyoutPrice == 0 then
		EasyBuyoutPrice = EasyBuyoutPrice + select(7, GetAuctionItemInfo("list", getID))
	end
	PlaceAuctionBid("list", getID, EasyBuyoutPrice)
    CloseAuctionStaticPopups();
end

AucAdvanced.RegisterRevision("$URL: http://dev.norganna.org/auctioneer/trunk/Auc-Advanced/Modules/Auc-Util-EasyBuyout/EasyBuyout.lua $", "$Rev: 3054 $")