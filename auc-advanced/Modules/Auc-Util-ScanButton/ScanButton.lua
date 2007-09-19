--[[
	Auctioneer Advanced - Scan Button module
	Version: <%version%> (<%codename%>)
	Revision: $Id$
	URL: http://auctioneeraddon.com/

	This is an Auctioneer Advanced module that adds a textual scan progress
	indicator to the Auction House UI.

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

local libName = "ScanButton"
local libType = "Util"

AucAdvanced.Modules[libType][libName] = {}
local lib = AucAdvanced.Modules[libType][libName]
local private = {}
local print = AucAdvanced.Print
lib.Private = private

-- Required:
function lib.GetName()
	return libName
end

function lib.Processor(callbackType, ...)
	if (callbackType == "scanprogress") then
		private.UpdateScanProgress(...)
	elseif (callbackType == "auctionui") then
		private.HookAH(...)
	elseif (callbackType == "config") then
		private.SetupConfigGui(...)
	elseif (callbackType == "configchanged") then
		private.ConfigChanged(...)
	end
end

function lib.OnLoad()
	AucAdvanced.Settings.SetDefault("util.scanbutton.enabled", true)
end

function private.HookAH()
	private.buttons = CreateFrame("Frame", nil, AuctionFrameBrowse)
	private.buttons:SetPoint("TOPLEFT", AuctionFrameBrowse, "TOPLEFT", 100,-14)
	private.buttons:SetWidth(20*3 + 4)
	private.buttons:SetHeight(20)
	
	private.buttons.stop = CreateFrame("Button", nil, private.buttons, "OptionsButtonTemplate")
	private.buttons.stop:SetPoint("TOPLEFT", private.buttons, "TOPLEFT", 0,0)
	private.buttons.stop:SetWidth(20)
	private.buttons.stop:SetHeight(20)
	private.buttons.stop:SetScript("OnClick", private.stop)
	private.buttons.stop.tex = private.buttons.stop:CreateTexture(nil, "OVERLAY")
	private.buttons.stop.tex:SetPoint("TOPLEFT", private.buttons.stop, "TOPLEFT", 3,-3)
	private.buttons.stop.tex:SetPoint("BOTTOMRIGHT", private.buttons.stop, "BOTTOMRIGHT", -3,3)
	private.buttons.stop.tex:SetTexture("Interface\\AddOns\\Auc-Advanced\\Textures\\NavButtons")
	private.buttons.stop.tex:SetTexCoord(0.25, 0.5, 0, 1)
	private.buttons.stop.tex:SetVertexColor(1.0, 0.9, 0.1)
	
	private.buttons.play = CreateFrame("Button", nil, private.buttons, "OptionsButtonTemplate")
	private.buttons.play:SetPoint("TOPLEFT", private.buttons.stop, "TOPRIGHT", 2,0)
	private.buttons.play:SetWidth(20)
	private.buttons.play:SetHeight(20)
	private.buttons.play:SetScript("OnClick", private.play)
	private.buttons.play.tex = private.buttons.play:CreateTexture(nil, "OVERLAY")
	private.buttons.play.tex:SetPoint("TOPLEFT", private.buttons.play, "TOPLEFT", 3,-3)
	private.buttons.play.tex:SetPoint("BOTTOMRIGHT", private.buttons.play, "BOTTOMRIGHT", -3,3)
	private.buttons.play.tex:SetTexture("Interface\\AddOns\\Auc-Advanced\\Textures\\NavButtons")
	private.buttons.play.tex:SetTexCoord(0, 0.25, 0, 1)
	private.buttons.play.tex:SetVertexColor(1.0, 0.9, 0.1)
	
	private.buttons.pause = CreateFrame("Button", nil, private.buttons, "OptionsButtonTemplate")
	private.buttons.pause:SetPoint("TOPLEFT", private.buttons.play, "TOPRIGHT", 2,0)
	private.buttons.pause:SetWidth(20)
	private.buttons.pause:SetHeight(20)
	private.buttons.pause:SetScript("OnClick", private.pause)
	private.buttons.pause.tex = private.buttons.pause:CreateTexture(nil, "OVERLAY")
	private.buttons.pause.tex:SetPoint("TOPLEFT", private.buttons.pause, "TOPLEFT", 3,-3)
	private.buttons.pause.tex:SetPoint("BOTTOMRIGHT", private.buttons.pause, "BOTTOMRIGHT", -3,3)
	private.buttons.pause.tex:SetTexture("Interface\\AddOns\\Auc-Advanced\\Textures\\NavButtons")
	private.buttons.pause.tex:SetTexCoord(0.5, 0.75, 0, 1)
	private.buttons.pause.tex:SetVertexColor(1.0, 0.9, 0.1)

	private.UpdateScanProgress()
end

function private.UpdateScanProgress()
	local scanning, paused = AucAdvanced.Scan.IsScanning(), AucAdvanced.Scan.IsPaused()

	if scanning or paused then
		private.buttons.stop:Enable()
	else
		private.buttons.stop:Disable()
	end

	if scanning and not paused then
		private.buttons.pause:Enable()
		private.buttons.play:Disable()
	else
		private.buttons.play:Enable()
		private.buttons.pause:Disable()
	end
end

function private.SetupConfigGui(gui)
	-- The defaults for the following settings are set in the lib.OnLoad function
	id = gui:AddTab(libName)
	gui:AddControl(id, "Header",     0,    libName.." options")
	gui:AddControl(id, "Checkbox",   0, 1, "util.scanbutton.enabled", "Show scan buttons in the AuctionHouse")
end

function private.ConfigChanged()
	if AucAdvanced.Settings.GetSetting("util.scanbutton.enabled") then
		private.buttons:Show()
	else
		private.buttons:Hide()
	end
end


function private.stop()
	AucAdvanced.Scan.SetPaused(false)
	AucAdvanced.Scan.Cancel()
	private.UpdateScanProgress()
end

function private.play()
	if AucAdvanced.Scan.IsPaused() then
		AucAdvanced.Scan.SetPaused(false)
	elseif not AucAdvanced.Scan.IsScanning() then
		AucAdvanced.Scan.StartScan()
	end
	private.UpdateScanProgress()
end

function private.pause()
	if not AucAdvanced.Scan.IsPaused() then
		AucAdvanced.Scan.SetPaused(true)
	end
	private.UpdateScanProgress()
end

