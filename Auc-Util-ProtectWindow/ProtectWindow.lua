--[[
	Auctioneer Advanced - Price Level Utility module
	Version: <%version%> (<%codename%>)
	Revision: $Id$
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

local libType, libName = "Util", "ProtectWindow"
local lib,parent,private = AucAdvanced.NewModule(libType, libName)
if not lib then return end
local print,decode,recycle,acquire,clone,scrub,get,set,default = AucAdvanced.GetModuleLocals()
local debug = "debug_off"

--[[
The following functions are part of the module's exposed methods:
	GetName()         (required) Should return this module's full name
	CommandHandler()  (optional) Slash command handler for this module
	Processor()       (optional) Processes messages sent by Auctioneer
	ScanProcessor()   (optional) Processes items from the scan manager
*	GetPrice()        (required) Returns estimated price for item link
*	GetPriceColumns() (optional) Returns the column names for GetPrice
	OnLoad()          (optional) Receives load message for all modules

	(*) Only implemented in stats modules; util modules do not provide
]]

function lib.GetName()
	return libName
end

function lib.Processor(callbackType, ...)
	if (callbackType == "config") then
		--Called when you should build your Configator tab.
		private.SetupConfigGui(...)
	elseif (callbackType == "configchanged") then
		--Called when your config options (if Configator) have been changed.
	elseif (callbackType == "scanprogress") then
		--Called from scan start to scan end.
		private.CheckScanProt(...)
	elseif (callbackType == "scanstats") then
		--Called when the scan has finished and stats are ready.
		private.ScanEnd(...)
	end
end

function lib.OnLoad()
	--This function is called when your variables have been loaded.
	--You should also set your Configator defaults here

--	print("AucAdvanced: {{"..libType..":"..libName.."}} loaded!")
	AucAdvanced.Settings.SetDefault("util.protectwindow.protectwindow", 1)
	AucAdvanced.Settings.SetDefault("util.protectwindow.processprotect", 0)
end

--[[ Local functions ]]--
local ScanProtected = nil
local ProcessProtect = nil
function private.CheckScanProt(state, totalAuctions, scannedAuctions, elapsedTime)
	if get("util.protectwindow.protectwindow") == 3 then 
		if debug == "debug_on" then 
			print("State:", state)
			print("totalAuctions:", totalAuctions)
			print("scannedAuctions:", scannedAuctions)
			print("elapsedTime", elapsedTime)
			print("IsScanning reports:", AucAdvanced.Scan.IsScanning())
		end
		if get("util.protectwindow.protectwindow") == 3 then
			if state == true and not ScanProtected then
				if debug == "debug_on" then print("Protecting AuctionFrame while scanning") end
				AuctionFrame.Hide = function() end
				HideUIPanel(AuctionFrame)
				AuctionFrame.Hide = nil
				ScanProtected = true
			elseif state == nil and ScanProtected then
				if debug == "debug_on" then print("AuctionFrame already protected while scanning") end
			elseif state == false and ScanProtected and not get("util.protectwindow.processprotect") then
				if debug == "debug_on" then print("Unprotecting AuctionFrame after scanning") end
				AuctionFrame.IsShown = function () end
				ShowUIPanel(AuctionFrame, 1)
				AuctionFrame.IsShown = nil
				ScanProtected = nil
			end
		end
	end
end

function private.ScanEnd()
	if get("util.protectwindow.processprotect") == true then
		if debug=="debug_on" then
			print("Scan Data received, we're done scanning.")
			print("IsScanning() reports", AucAdvanced.Scan.IsScanning())
		end
		if get("util.protectwindow.protectwindow") == 3 then
			if debug=="debug_on" then print("Unprotecting AuctionFrame after processing") end
			AuctionFrame.IsShown = function () end
			ShowUIPanel(AuctionFrame, 1)
			AuctionFrame.IsShown = nil
			ScanProtected = nil
		end
	else
		return
	end
end
function lib.ToggleDebug()
	if debug == "debug_on" then
		debug = "debug_off"
		print("Turned debugging text off.")
	else
		debug = "debug_on"
		print("Turned degubbing text on.")
	end
end
function private.SetupConfigGui(gui)
	-- The defaults for the following settings are set in the lib.OnLoad function
	local id = gui:AddTab(libName)
	gui:AddControl(id, "Header", 0,	libName.." options")
	gui:AddControl(id, "Subhead", 0, "Protect the Auction Window when?")
	--Note the function reference in the place of the setting name.  See changes in getter, setter, and getDefault to accomodate this.
	gui:AddControl(id, "Selectbox", 0, 1, {
		{1, "Never"},
		{2, "Always"},
		{3, "When Scanning"}
	}, lib.windowProtect, "Prevent other windows from closing the Auction House window.")
	gui:AddTip(id, "This will allow prevent other windows from closing the Auction House Window when you open them.")
	gui:AddControl(id, "Checkbox", 0, 1, "util.protectwindow.processprotect", "Check this to protect the window until processing is done.")
	gui:AddTip(id, "This option allows you to extend protection from the end of the scan until processing is done.")
	gui:AddHelp(id, "What is ProtectWindow",
		"What does Protecting the AH Window do?",
		"The Auction House window is normally closed when you open other windows, such as the Social window, the Quest Log, or your profession windows.  This option allows it to remain open, behind those other windows.")
end

--Now let's create a structure to check and set our Window Protection at
--startup. We want this frame to be the major point of execution for the
--code.
local myFrame = CreateFrame("Frame")
lib.protFrame = myFrame
myFrame:Hide()

--This function sets up Protect-Window functionality.
--We had to modify the getter and setter in CoreSettings,
--so much of this code is to cope with that.
function lib.windowProtect(action, setvalue)
	--If this was called by the getter, we'll receive an argument
	--of "getsetting"  So we get the setting and return it for
	--CoreSettings.lua
	if (action == "getsetting") then
		return get("util.protectwindow.protectwindow")
	--If this was called by the getDefault, we'll receive an argument
	--of "getdefault"
	elseif (action == "getdefault") then
		return AucAdvanced.Settings.getDefault("util.protectwindow.protectwindow")
	--If it was called by the setter, we'll receive and argument of
	--"set".  This is where we do most of our work.
	elseif (action == "set") then
		--Set our config value
		local retvalue = set("util.protectwindow.protectwindow", setvalue)
		--Unhide the frame that will run the script to protect
		--the window
		if UIPanelWindows["AuctionFrame"] then
			myFrame:Show()
		end
		return retvalue
	end
end

--This script will turn the protection of the AuctionFrame on or off,
--as appropriate.  It works on a delay to give the client time to 
--build the AuctionFrame and attributes completely before we run our
--code if it's being run when the AH first loads, then rehides itself
--so this only happens once.
function lib.AdjustProtection ()
	if not UIPanelWindows["AuctionFrame"] and myFrame:IsShown() then
		myFrame:Hide()
		if debug == "debug_on" then 
			print ("myFrame hidden because AuctionFrame doesn't exist yet.") 
		end
		return
	elseif (get("util.protectwindow.protectwindow") == 1) and not AuctionFrame:GetAttribute("UIPanelLayout-enabled") then
		if debug == "debug_on" then
			print ("Enabling Standard Frame Handler for AuctionFrame because protectwindow ="..get("util.protectwindow.protectwindow"))
		end
		AuctionFrame:SetAttribute("UIPanelLayout-enabled", true) 
		if AuctionFrame:IsShown() then 
			AuctionFrame.IsShown = function() end 
			ShowUIPanel(AuctionFrame, 1) 
			AuctionFrame.IsShown = nil 
		end
	elseif (get("util.protectwindow.protectwindow") == 3) and not AuctionFrame:GetAttribute("UIPanelLayout-enabled") then
		if debug == "debug_on" then
			print ("Enabling Standard Frame Handler for AuctionFrame because protectwindow ="..get("util.protectwindow.protectwindow"))
		end
		AuctionFrame:SetAttribute("UIPanelLayout-enabled", true) 
		if AuctionFrame:IsShown() then 
			AuctionFrame.IsShown = function() end 
			ShowUIPanel(AuctionFrame, 1) 
			AuctionFrame.IsShown = nil 
		end
	elseif get("util.protectwindow.protectwindow") == 2 and AuctionFrame:GetAttribute("UIPanelLayout-enabled") then
		if debug == "debug_on" then
			print ("Disabling Standard Frame Handler for AuctionFrame because protectwindow ="..get("util.protectwindow.protectwindow"))
		end
		if AuctionFrame:IsShown() then
			AuctionFrame.Hide = function() end 
			HideUIPanel(AuctionFrame) 
			AuctionFrame.Hide = nil 
		end 
		AuctionFrame:SetAttribute("UIPanelLayout-enabled", nil)
	end
	if myFrame:IsShown() then
		myFrame:Hide()
	end
	if debug == "debug_on" then
		print ("Closing myFrame after adjusting protection")
	end
end
			
--We cause a slight delay before any code execution by waiting for our 
--frame to Update and using the OnUpdate event to trigger our code.
myFrame:SetScript("OnUpdate", lib.AdjustProtection)

--Register our frame for the ADDON_LOADED event
myFrame:RegisterEvent("ADDON_LOADED")
myFrame:RegisterEvent("AUCTION_HOUSE_SHOW")

--When we catch the blizzard_auctionui addon loading, unhide our frame
--which will just sit there for a bit until the frame updates, when
--our code will fire.
myFrame:SetScript("OnEvent", function(name, event, addon)
	if addon=="Blizzard_AuctionUI" and event=="ADDON_LOADED" then
		myFrame:Show()
--		AuctionFrame:HookScript("OnShow", function () return myFrame:Show() end)
	elseif event=="AUCTION_HOUSE_SHOW" then
		myFrame:Show()
	end
end)

AucAdvanced.RegisterRevision("$URL$", "$Rev$")
