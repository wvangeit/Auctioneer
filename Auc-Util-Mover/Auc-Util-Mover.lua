--[[
	Auctioneer Advanced - Mover
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

local libType, libName = "Util", "Mover"
local lib, parent, private = AucAdvanced.NewModule(libType, libName)

if not lib then return end

local print, decode, recycle, acquire, clone, scrub, get, set, default = AucAdvanced.GetModuleLocals()

lib.Private = private

function lib.GetName()
	return libName
end

function lib.Processor(callbackType, ...)
	if callbackType == "auctionui" then
		private.auctionHook() ---When AuctionHouse loads hook the auction function we need
		private.MoveFrame()
	elseif callbackType == "configchanged" then
		private.MoveFrame()	
	elseif callbackType == "config" then
		private.SetupConfigGui(...)
	end
end

function lib.OnLoad(addon)
	default("util.mover.activated", false)
	default("util.mover.rememberlastpos", false)
	default("util.mover.anchors", {})
end

--after Auction House Loads Hook the Window Display event
function private.auctionHook()
	hooksecurefunc("AuctionFrame_Show", private.recallLastPos)
end

function private.SetupConfigGui(gui)
	-- The defaults for the following settings are set in the lib.OnLoad function
	local id, last
	-- The defaults for the following settings are set in the lib.OnLoad function
	local id = gui:AddTab(libName)
	gui:MakeScrollable(id)
	gui:AddControl(id, "Header",     0,    libName.." options")
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
end
		
--[[ Local functions ]]--

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
end

--Restore previous sessions Window position
function private.recallLastPos()
	if get("util.mover.rememberlastpos") then
		local anchors = get("util.mover.anchors")
		AuctionFrame:ClearAllPoints()
		AuctionFrame:SetPoint(anchors[1], anchors[2], anchors[3], anchors[4], anchors[5])
	end
end

AucAdvanced.RegisterRevision("$URL$", "$Rev$")
