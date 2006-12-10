--[[

Swatter - An AddOn debugging aid for World of Warcraft.
$Id$
Copyright (C) 2006 Norganna

This library is free software; you can redistribute it and/or
modify it under the terms of the GNU Lesser General Public
License as published by the Free Software Foundation; either
version 2.1 of the License, or (at your option) any later version.

This library is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public
License along with this library; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA

]]
Swatter = {
	origHandler = geterrorhandler(),
	nilFrame = {},
}
SwatterData = {
	enabled = true,
	autoshow = true,
}

function Swatter.nilFrame.GetName() return "Global" end

function Swatter.ChatMsg(msg)
	DEFAULT_CHAT_FRAME:AddMessage(msg)
end
local chat = Swatter.ChatMsg

function Swatter.IsEnabled()
	return SwatterData.enabled
end

function Swatter.OnError(msg, frame)
	if (not SwatterData.enabled) then return Swatter.origHandler(msg, frame) end
	if (not frame) then frame = Swatter.nilFrame end

	if (not frame.Swatter) then frame.Swatter = {} end

	local count = frame.Swatter[msg] or 0
	frame.Swatter[msg] = count + 1

	Swatter.lastFrame = frame
	Swatter.lastMsg = msg
	Swatter.lastBt = debugstack(2, 3, 6)

	if (count == 0) then
		if (SwatterData.autoshow) then
			Swatter.Error:Show()
		else
			chat("Swatter caught error in "..frame:GetName()..". Type /swat show")
		end
	end
end

function Swatter.ErrorShow()
	local frame, msg, bt = Swatter.lastFrame, Swatter.lastMsg, Swatter.lastBt
	if (not frame) then
		Swatter.Error.Box:SetText("No errors have been recorded yet")
	end

	local count = frame.Swatter[msg]
	
	Swatter.Error.Box:SetText("Error occured in: "..frame:GetName().."\nCount: "..count.."\nMessage: "..msg.."\n".."Debug:\n"..bt.."\n")
end
function Swatter.ErrorDone()
	Swatter.Error:Hide()
end
function Swatter.ErrorUpdate()
	Swatter.Error.Scroll:UpdateScrollChildRect()
end

-- Create our error message frame
Swatter.Error = CreateFrame("Frame", "", UIParent)
Swatter.Error:Hide()
Swatter.Error:SetPoint("CENTER", "UIParent", "CENTER")
Swatter.Error:SetFrameStrata("DIALOG")
Swatter.Error:SetHeight(280)
Swatter.Error:SetWidth(500)
Swatter.Error:SetBackdrop({
	bgFile = "Interface/Tooltips/UI-Tooltip-Background",
	edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
	tile = true, tileSize = 32, edgeSize = 32,
	insets = { left = 9, right = 9, top = 9, bottom = 9 }
})
Swatter.Error:SetBackdropColor(0,0,0, 0.8)
Swatter.Error:SetScript("OnShow", Swatter.ErrorShow)

Swatter.Error.Done = CreateFrame("Button", "", Swatter.Error, "OptionsButtonTemplate")
Swatter.Error.Done:SetText("Close")
Swatter.Error.Done:SetPoint("BOTTOMRIGHT", Swatter.Error, "BOTTOMRIGHT", -10, 10)
Swatter.Error.Done:SetScript("OnClick", Swatter.ErrorDone)

Swatter.Error.Scroll = CreateFrame("ScrollFrame", "SwatterErrorInputScroll", Swatter.Error, "UIPanelScrollFrameTemplate")
Swatter.Error.Scroll:SetPoint("TOPLEFT", Swatter.Error, "TOPLEFT", 20, -20)
Swatter.Error.Scroll:SetPoint("RIGHT", Swatter.Error, "RIGHT", -30, 0)
Swatter.Error.Scroll:SetPoint("BOTTOM", Swatter.Error.Done, "TOP", 0, 10)

Swatter.Error.Box = CreateFrame("EditBox", "SwatterErrorEditBox", Swatter.Error.Scroll)
Swatter.Error.Box:SetWidth(460)
Swatter.Error.Box:SetHeight(85)
Swatter.Error.Box:SetMultiLine(true)
Swatter.Error.Box:SetAutoFocus(true)
Swatter.Error.Box:SetFontObject(GameFontHighlight)
Swatter.Error.Box:SetScript("OnEscapePressed", Swatter.ErrorDone)
Swatter.Error.Box:SetScript("OnTextChanged", Swatter.ErrorUpdate)

Swatter.Error.Scroll:SetScrollChild(Swatter.Error.Box)

seterrorhandler(Swatter.OnError)

SLASH_SWATTER1 = "/swatter"
SLASH_SWATTER2 = "/swat"
SlashCmdList["SWATTER"] = function(msg)
	if (not msg or msg == "" or msg == "help") then
		chat("Swatter help:")
		chat("  /swat enable    -  Enables swatter")
		chat("  /swat disable   -  Disables swatter")
		chat("  /swat show      -  Shows the last error box again")
		chat("  /swat autoshow  -  Enables swatter autopopup upon error")
		chat("  /swat noauto    -  Swatter will only show an error in chat")
	elseif (msg == "show") then
		Swatter.Error:Show()
	elseif (msg == "enable") then
		SwatterData.enabled = true
		chat("Swatter will now catch errors")
	elseif (msg == "disable") then
		SwatterData.enabled = false
		chat("Swatter will no longer catch errors")
	elseif (msg == "autoshow") then
		SwatterData.autoshow = true
		chat("Swatter will popup the first time it sees an error")
	elseif (msg == "noautoshow") then
		SwatterData.autoshow = false
		chat("Swatter will print into chat instead of popping up")
	end
end

