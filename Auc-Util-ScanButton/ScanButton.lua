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

local libType, libName = "Util", "ScanButton"
local lib,parent,private = AucAdvanced.NewModule(libType, libName)
if not lib then return end
local print,decode,recycle,acquire,clone,scrub,get,set,default = AucAdvanced.GetModuleLocals()

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

-- /run local t = AucAdvanced.Modules.Util.ScanButton.Private.buttons.stop.tex t:SetPoint("TOPLEFT", t:GetParent() "TOPLEFT", 3,-3) t:SetPoint("BOTTOMRIGHT", t:GetParent(), "BOTTOMRIGHT", -3,3)
-- /run local t = AucAdvanced.Modules.Util.ScanButton.Private.buttons.stop.tex t:SetTexture("Interface\\AddOns\\Auc-Advanced\\Textures\\NavButtons") t:SetTexCoord(0.25, 0.5, 0, 1) t:SetVertexColor(1.0, 0.9, 0.1)

function private.HookAH()
	private.buttons = CreateFrame("Frame", nil, AuctionFrameBrowse)
	private.buttons:SetPoint("TOPLEFT", AuctionFrameBrowse, "TOPLEFT", 200,-15)
	private.buttons:SetWidth(22*3 + 4)
	private.buttons:SetHeight(18)
	private.buttons:SetScript("OnUpdate", private.OnUpdate)
	
	private.buttons.stop = CreateFrame("Button", nil, private.buttons, "OptionsButtonTemplate")
	private.buttons.stop:SetPoint("TOPLEFT", private.buttons, "TOPLEFT", 0,0)
	private.buttons.stop:SetWidth(22)
	private.buttons.stop:SetHeight(18)
	private.buttons.stop:SetScript("OnClick", private.stop)
	private.buttons.stop.tex = private.buttons.stop:CreateTexture(nil, "OVERLAY")
	private.buttons.stop.tex:SetPoint("TOPLEFT", private.buttons.stop, "TOPLEFT", 4,-2)
	private.buttons.stop.tex:SetPoint("BOTTOMRIGHT", private.buttons.stop, "BOTTOMRIGHT", -4,2)
	private.buttons.stop.tex:SetTexture("Interface\\AddOns\\Auc-Advanced\\Textures\\NavButtons")
	private.buttons.stop.tex:SetTexCoord(0.25, 0.5, 0, 1)
	private.buttons.stop.tex:SetVertexColor(1.0, 0.9, 0.1)
	
	private.buttons.play = CreateFrame("Button", nil, private.buttons, "OptionsButtonTemplate")
	private.buttons.play:SetPoint("TOPLEFT", private.buttons.stop, "TOPRIGHT", 2,0)
	private.buttons.play:SetWidth(22)
	private.buttons.play:SetHeight(18)
	private.buttons.play:SetScript("OnClick", private.play)
	private.buttons.play.tex = private.buttons.play:CreateTexture(nil, "OVERLAY")
	private.buttons.play.tex:SetPoint("TOPLEFT", private.buttons.play, "TOPLEFT", 4,-2)
	private.buttons.play.tex:SetPoint("BOTTOMRIGHT", private.buttons.play, "BOTTOMRIGHT", -4,2)
	private.buttons.play.tex:SetTexture("Interface\\AddOns\\Auc-Advanced\\Textures\\NavButtons")
	private.buttons.play.tex:SetTexCoord(0, 0.25, 0, 1)
	private.buttons.play.tex:SetVertexColor(1.0, 0.9, 0.1)
	
	private.buttons.pause = CreateFrame("Button", nil, private.buttons, "OptionsButtonTemplate")
	private.buttons.pause:SetPoint("TOPLEFT", private.buttons.play, "TOPRIGHT", 2,0)
	private.buttons.pause:SetWidth(22)
	private.buttons.pause:SetHeight(18)
	private.buttons.pause:SetScript("OnClick", private.pause)
	private.buttons.pause.tex = private.buttons.pause:CreateTexture(nil, "OVERLAY")
	private.buttons.pause.tex:SetPoint("TOPLEFT", private.buttons.pause, "TOPLEFT", 4,-2)
	private.buttons.pause.tex:SetPoint("BOTTOMRIGHT", private.buttons.pause, "BOTTOMRIGHT", -4,2)
	private.buttons.pause.tex:SetTexture("Interface\\AddOns\\Auc-Advanced\\Textures\\NavButtons")
	private.buttons.pause.tex:SetTexCoord(0.5, 0.75, 0, 1)
	private.buttons.pause.tex:SetVertexColor(1.0, 0.9, 0.1)

	private.UpdateScanProgress()
end

function private.UpdateScanProgress()
	local scanning, paused = AucAdvanced.Scan.IsScanning(), AucAdvanced.Scan.IsPaused()
	private.ConfigChanged()

	if scanning or paused then
		private.buttons.stop:Enable()
		private.buttons.stop.tex:SetVertexColor(1.0, 0.9, 0.1)
	else
		private.buttons.stop:Disable()
		private.buttons.stop.tex:SetVertexColor(0.3,0.3,0.3)
	end

	private.blink = nil
	if scanning and not paused then
		private.buttons.pause:Enable()
		private.buttons.pause.tex:SetVertexColor(1.0, 0.9, 0.1)
		private.buttons.play:Disable()
		private.buttons.play.tex:SetVertexColor(0.3,0.3,0.3)
	else
		private.buttons.play:Enable()
		private.buttons.play.tex:SetVertexColor(1.0, 0.9, 0.1)
		private.buttons.pause:Disable()
		private.buttons.pause.tex:SetVertexColor(0.3,0.3,0.3)
		if paused then
			private.blink = 1
		end
	end
end

function private:OnUpdate(delay)
	if private.blink then
		private.timer = (private.timer or 0) - delay
		if private.timer < 0 then
			if not AucAdvanced.Scan.IsPaused() then
				private.UpdateScanProgress()
				return
			end
			if private.blink == 1 then
				private.buttons.pause.tex:SetVertexColor(0.1, 0.3, 1.0)
				private.blink = 2
			else
				private.buttons.pause.tex:SetVertexColor(0.3, 0.3, 0.3)
				private.blink = 1
			end
			private.timer = 0.75
		end
	end
end

function private.SetupConfigGui(gui)
	-- The defaults for the following settings are set in the lib.OnLoad function
	id = gui:AddTab(libName, libType.." Modules")
	gui:AddControl(id, "Header",     0,    libName.." options")
	gui:AddControl(id, "Checkbox",   0, 1, "util.scanbutton.enabled", "Show scan buttons in the AuctionHouse")
end

function private.ConfigChanged()
	if not private.buttons then return end
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
		AucAdvanced.Scan.StartScan("", "", "", nil, nil, nil, nil, nil, true)
	end
	private.UpdateScanProgress()
end

function private.pause()
	if not AucAdvanced.Scan.IsPaused() then
		AucAdvanced.Scan.SetPaused(true)
	end
	private.UpdateScanProgress()
end

