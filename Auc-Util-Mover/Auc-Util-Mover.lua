--[[
	Auctioneer Advanced - AH-WindowControl
	Version: <%version%> (<%codename%>)
	Revision: $Id$
	URL: http://auctioneeraddon.com/

	This is an addon for World of Warcraft that adds the abilty to drag and reposition the Auction House Frame.

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
]]

local libType, libName = "Util", "AH-WindowControl"
local lib, parent, private = AucAdvanced.NewModule(libType, libName)

if not lib then return end

local print,decode,_,_,replicate,empty,get,set,default,debugPrint,fill = AucAdvanced.GetModuleLocals()

lib.Private = private

function lib.GetName()
	return libName
end

local debug = false
local function debugPrint(...)
	if debug  then
		print(...)
	end
end

function lib.Processor(callbackType, ...)
	if callbackType == "auctionui" then
		private.auctionHook() ---When AuctionHouse loads hook the auction function we need
		private.MoveFrame() --Set position back to previous session if options set
	elseif callbackType == "configchanged" then
		private.MoveFrame()	
	elseif callbackType == "config" then
		private.SetupConfigGui(...)
	elseif (callbackType == "scanprogress") then
		private.CheckScanProt(...)
	elseif (callbackType == "scanstats") then
		--Called when the scan has finished and stats are ready.
		private.ScanEnd(...)
	end
end

function lib.OnLoad(addon)
	default("util.mover.activated", false)
	default("util.mover.rememberlastpos", false)
	default("util.mover.anchors", {})
	default("util.protectwindow.protectwindow", 1)
	default("util.protectwindow.processprotect", 0)
	default("util.ah-windowcontrol.auctionscale", 1) --This is the scale of AuctionFrame 1 == default
	default("util.ah-windowcontrol.compactuiscale", 0) --This is the increase of compactUI scale
end

--after Auction House Loads Hook the Window Display event
function private.auctionHook()
	hooksecurefunc("AuctionFrame_Show", private.setupWindowFunctions)
end

function private.SetupConfigGui(gui)
	-- The defaults for the following settings are set in the lib.OnLoad function
	local id, last
	--Setup Tab for Mover functions
	id = gui:AddTab(libName)
	gui:MakeScrollable(id)
	gui:AddControl(id, "Header",     0,    "Window Movement Options")
	gui:AddControl(id, "Checkbox",   0, 1,  "util.mover.activated", "Allow the Auction frame to be movable?")
	gui:AddTip(id, "Ticking this box will enable the ability to reloacate the Auction frame")
	gui:AddHelp(id, "what is mover",
		"What is this Utility?",
		"This Utility allows you to drag and relocate the Auction Frame for this play session. Just click and move where you desire.")
	gui:AddControl(id, "Checkbox",   0, 1,  "util.mover.rememberlastpos", "Remember last known window position?")
	gui:AddTip(id, "If this box is checked, the Auction frame will reopen in the last location it was moved to.")
	gui:AddHelp(id, "what is remeberpos",
		"Remember last known window position?",
		"This will remember the Auction Frame's last position and re-apply it each session.")
	
	--Window Protection
	gui:AddControl(id, "Header", 0,	"Window Protection Options")
	gui:AddControl(id, "Subhead", 0, "Protect the Auction Window when?")
	--Note the function reference in the place of the setting name.  See changes in getter, setter, and getDefault to accomodate this.
	gui:AddControl(id, "Selectbox", 0, 1, {
		{1, "Never"},
		{2, "Always"},
		{3, "When Scanning"}
	}, lib.windowProtect, "Prevent other windows from closing the Auction House window.")
	gui:AddTip(id, "This will prevent other windows from closing the Auction House Window when you open them, according to your settings.")
	gui:AddControl(id, "Checkbox", 0, 1, "util.protectwindow.processprotect", "Check this to protect the window until processing is done.")
	gui:AddTip(id, "This option allows you to extend protection from the end of the scan until processing is done.")
	gui:AddHelp(id, "What is ProtectWindow",
		"What does Protecting the AH Window do?",
		"The Auction House window is normally closed when you open other windows, such as the Social window, the Quest Log, or your profession windows.  This option allows it to remain open, behind those other windows.")
	--AuctionFrame Scale
	gui:AddControl(id, "Header", 0, "") --Spacer for options
	gui:AddControl(id, "Header", 0,	"Window Size Options")
	gui:AddControl(id, "NumeriSlider", 0, 1, "util.ah-windowcontrol.auctionscale",    0.1, 3, 0.1, "Auction House Scale")
	gui:AddTip(id, "This option allows you to adjust the overall size of the Auction House Window. Default is 1")
	
	gui:AddControl(id, "NumeriSlider", 0, 1, "util.ah-windowcontrol.compactuiscale",    -5, 5, 0.2, "CompactUI Font Scale")
	gui:AddTip(id, "This option allows you to adjust the Text size of the CompactUI on the Browse tab. Default is 0")
end

		
--[[ Local functions ]]--

--Hooks AH show function. This is fired after all Auction Frame methods have been set by Blizzard
--We can now override with our settings
function private.setupWindowFunctions()
	private.recallLastPos()
	private.AdjustProtection()
end

--Enable or Disable the move scripts
function private.MoveFrame()
	if not AuctionFrame then return end
	
	if get("util.mover.activated") then
		AuctionFrame:SetMovable(true)
		AuctionFrame:SetClampedToScreen(true)
		AuctionFrame:SetScript("OnMouseDown", function()  AuctionFrame:StartMoving() end)
		AuctionFrame:SetScript("OnMouseUp", function() AuctionFrame:StopMovingOrSizing() 
						set("util.mover.anchors", {AuctionFrame:GetPoint()}) --store the current anchor points
					end)
	else
		AuctionFrame:SetMovable(false)
		AuctionFrame:SetScript("OnMouseDown", function() end)
		AuctionFrame:SetScript("OnMouseUp", function() end)
	end
	if get("util.ah-windowcontrol.auctionscale") then
		AuctionFrame:SetScale(get("util.ah-windowcontrol.auctionscale"))
	end
	if get("util.compactui.activated") then
		for i = 1,14 do
			local button = _G["BrowseButton"..i]
			local increase = get('util.ah-windowcontrol.compactuiscale') or 0
			if not button.Count then return end -- we get called before compactUI has built teh frame
			button.Count:SetFont(STANDARD_TEXT_FONT, 11 + increase)
			button.Name:SetFont(STANDARD_TEXT_FONT, 10 + increase)
			button.rLevel:SetFont(STANDARD_TEXT_FONT, 11 + increase)
			button.iLevel:SetFont(STANDARD_TEXT_FONT, 11 + increase)
			button.tLeft:SetFont(STANDARD_TEXT_FONT, 11 + increase)
			button.Owner:SetFont(STANDARD_TEXT_FONT, 10 + increase)
			button.Value:SetFont(STANDARD_TEXT_FONT, 11 + increase)
		end
	end
	
end

--Restore previous sessions Window position
function private.recallLastPos()
	if get("util.mover.rememberlastpos") then
		local anchors = get("util.mover.anchors")
		AuctionFrame:ClearAllPoints()
		AuctionFrame:SetPoint(anchors[1], anchors[2], anchors[3], anchors[4], anchors[5])
	end
end

--This script will turn the protection of the AuctionFrame on or off,
--as appropriate.  It works on a delay to give the client time to 
--build the AuctionFrame and attributes completely before we run our
--code if it's being run when the AH first loads, then rehides itself
--so this only happens once.
function private.AdjustProtection ()
	if not UIPanelWindows["AuctionFrame"] then
		
			debugPrint("frame hidden because AuctionFrame doesn't exist yet.")
		
		return
	elseif (get("util.protectwindow.protectwindow") == 1) and not AuctionFrame:GetAttribute("UIPanelLayout-enabled") then
		
		debugPrint("Enabling Standard Frame Handler for AuctionFrame because protectwindow ="..get("util.protectwindow.protectwindow"))

		AuctionFrame:SetAttribute("UIPanelLayout-enabled", true) 
		if AuctionFrame:IsVisible() then 
			AuctionFrame.IsShown = function() end 
			ShowUIPanel(AuctionFrame, 1) 
			AuctionFrame.IsShown = nil 
		end
	elseif (get("util.protectwindow.protectwindow") == 3) and not AuctionFrame:GetAttribute("UIPanelLayout-enabled") then
		
		debugPrint("Enabling Standard Frame Handler for AuctionFrame because protectwindow ="..get("util.protectwindow.protectwindow"))
		
		AuctionFrame:SetAttribute("UIPanelLayout-enabled", true) 
		if AuctionFrame:IsVisible() then 
			AuctionFrame.IsShown = function() end 
			ShowUIPanel(AuctionFrame, 1) 
			AuctionFrame.IsShown = nil 
		end
	elseif get("util.protectwindow.protectwindow") == 2 and AuctionFrame:GetAttribute("UIPanelLayout-enabled") then
		
		debugPrint("Disabling Standard Frame Handler for AuctionFrame because protectwindow ="..get("util.protectwindow.protectwindow"))
	
		if AuctionFrame:IsVisible() then
			AuctionFrame.Hide = function() end 
			HideUIPanel(AuctionFrame) 
			AuctionFrame.Hide = nil 
		end 
		AuctionFrame:SetAttribute("UIPanelLayout-enabled", nil)
	end
end

local ScanProtected = nil
local ProcessProtect = nil
function private.CheckScanProt(state, totalAuctions, scannedAuctions, elapsedTime)
	if debug == "debug_on" then
		print "CheckScanProt was called"
	end
	if get("util.protectwindow.protectwindow") == 3 then 
		
			debugPrint("State:", state)
			debugPrint("totalAuctions:", totalAuctions)
			debugPrint("scannedAuctions:", scannedAuctions)
			debugPrint("elapsedTime", elapsedTime)
			debugPrint("IsScanning reports:", AucAdvanced.Scan.IsScanning())
	
		
		if state == true and not ScanProtected then
			debugPrint("Protecting AuctionFrame while scanning")
			
			AuctionFrame.Hide = function() end
			HideUIPanel(AuctionFrame)
			AuctionFrame.Hide = nil
			ScanProtected = true
		elseif state == nil and ScanProtected then
			debugPrint("AuctionFrame already protected while scanning")
		
		elseif state == false and ScanProtected and not get("util.protectwindow.processprotect") then
			debugPrint("Unprotecting AuctionFrame because we're not scanning")
			
			if AuctionFrame:IsVisible() then
				AuctionFrame.IsShown = function () end
				ShowUIPanel(AuctionFrame, 1)
				AuctionFrame.IsShown = nil
			end
			ScanProtected = nil
		end
	end
end

function private.ScanEnd()
	if get("util.protectwindow.processprotect") == true then

		debugPrint("Scan Data received, we're done scanning.")
		debugPrint("IsScanning() reports", AucAdvanced.Scan.IsScanning())

		if get("util.protectwindow.protectwindow") == 3 then
			debugPrint("Unprotecting AuctionFrame after processing")
			if AuctionFrame:IsVisible() then
				AuctionFrame.IsShown = function () end
				ShowUIPanel(AuctionFrame, 1)
				AuctionFrame.IsShown = nil
			end
			ScanProtected = nil
		end
	else
		return
	end
end

function lib.ToggleDebug()
	if debug  then
		debug = false
		print("Turned debugging text off.")
	else
		debug = true
		print("Turned debugging text on.")
	end
end

--This function sets up Protect-Window functionality.
--We had to modify the getter and setter in CoreSettings,
--so much of this code is to cope with that.
function lib.windowProtect(action, setvalue)
	--If this was called by the getter, we'll receive an argument
	--of "getsetting"  So we get the setting and return it for
	--CoreSettings.lua
	if (action == "getsetting") then
		
		debugPrint("windowProtect called by getter")

		return get("util.protectwindow.protectwindow")
	--If this was called by the getDefault, we'll receive an argument
	--of "getdefault"
	elseif (action == "getdefault") then
		
		debugPrint("windowProtect called by getDefault")

		return AucAdvanced.Settings.getDefault("util.protectwindow.protectwindow")
	--If it was called by the setter, we'll receive and argument of
	--"set".  This is where we do most of our work.
	elseif (action == "set") then
		
		debugPrint("windowProtect called by setter")
		
		--Set our config value
		local retvalue = set("util.protectwindow.protectwindow", setvalue)
		--Unhide the frame that will run the script to protect
		--the window
		if UIPanelWindows["AuctionFrame"] then
			
			debugPrint(print "Unhiding frame")
	
		end
		return retvalue
	end
end

AucAdvanced.RegisterRevision("$URL$", "$Rev$")