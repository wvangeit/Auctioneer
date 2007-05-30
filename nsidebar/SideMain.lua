--[[
	$Id$

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

if nSideBar then return end
nSideBar = {}
local lib = nSideBar
local private = {}
local frame = CreateFrame("Frame", "", UIParent)
lib.Frame = frame
lib.top = -180


function private.PopOut()
	private.PopTimer = 0.15
	private.PopDirection = 1
end

function private.PopBack()
	private.PopTimer = 0.75
	private.PopDirection = -1
end

function private.MouseDown(me)
	me.icon:SetTexCoord(0, 1, 0, 1)
end

function private.MouseUp(me)
	me.icon:SetTexCoord(0.075, 0.925, 0.075, 0.925)
end


frame:SetToplevel(true)
frame:SetPoint("TOPLEFT", UIParent, "TOPRIGHT", -9, lib.top)
frame:SetWidth(200)
frame:SetHeight(42)
frame:SetBackdrop({
	bgFile = "Interface/Tooltips/UI-Tooltip-Background",
	edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
	tile = true, tileSize = 32, edgeSize = 16,
	insets = { left = 4, right = 4, top = 4, bottom = 4 }
})
frame:SetBackdropColor(0,0,0, 0.5)
frame:EnableMouse(true)
frame:SetScript("OnEnter", function(me) private.PopOut() end)
frame:SetScript("OnLeave", function(me) private.PopBack() end)
frame:SetScript("OnUpdate", function(me, dur) private.Popper(dur) end)
frame:Hide()

frame.Tab = frame:CreateTexture()
frame.Tab:SetPoint("TOPLEFT", frame, "TOPLEFT", 5, -5)
frame.Tab:SetPoint("BOTTOM", frame, "BOTTOM", 0, 5)
frame.Tab:SetWidth(3)
frame.Tab:SetTexture(0.98, 0.78, 0)

function private.Popper(duration)
	if private.PopDirection then
		private.PopTimer = private.PopTimer - duration
		if private.PopTimer < 0 then
			if private.PopDirection > 0 then
				-- Pop Out
				frame:ClearAllPoints()
				frame:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", 5, lib.top)
				private.PopDirection = nil
			else
				-- Pop Back
				frame:ClearAllPoints()
				frame:SetPoint("TOPLEFT", UIParent, "TOPRIGHT", -9, lib.top)
				private.PopDirection = nil
			end
		end
	end
end

private.pos = 0
function lib.AddButton(texture)
	local pos = private.pos

	local row = math.floor(pos / 16)
	local col = pos % 16

	local width = 16
	if (row == 0) then width = col end

	frame:SetWidth((width+1) * 32 + 15)
	frame:SetHeight((row+1) * 32 + 10)
	frame:Show()

	button = CreateFrame("Button", "", frame)
	button:SetPoint("TOPLEFT", frame, "TOPLEFT", col*32+10, 0-(row*32+5))
	button:SetWidth(30)
	button:SetHeight(30)
	button:SetScript("OnMouseDown", private.MouseDown)
	button:SetScript("OnMouseUp", private.MouseUp)
	button:SetScript("OnEnter", private.PopOut)
	button:SetScript("OnLeave", private.PopBack)
	button.icon = button:CreateTexture("", "BACKGROUND")
	button.icon:SetTexture(texture)
	button.icon:SetTexCoord(0.075, 0.925, 0.075, 0.925)
	button.icon:SetWidth(30)
	button.icon:SetHeight(30)
	button.icon:SetPoint("TOPLEFT", button, "TOPLEFT", 0,0)

	private.pos = pos + 1
	return button
end
