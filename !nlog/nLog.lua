--[[
	nLog - A debugging console for World of Warcraft.
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

-- /run for i = 1, 100000 do nLog.AddMessage("Auctioneer", "Scan", N_NOTICE, "Empty Auction "..i, "Found empty auction with item "..i) end

-- Call nLog.AddMessage(addon, type, level, title, detail)
-- Eg: nLog.AddMessage("Auctioneer", "Scan", N_NOTICE, "Empty Auction", "Found empty auction on page 10")

-- Message Levels
N_CRITICAL = 1
N_WARNING = 2
N_NOTICE = 3
N_INFO = 4
N_DEBUG = 5

nLog = {
	messages = {},
	levels = {
		[N_CRITICAL] = "Critical",
		[N_WARNING] = "Warning",
		[N_NOTICE] = "Notice",
		[N_INFO] = "Info",
		[N_DEBUG] = "Debug",
	}
}

nLog.Version="<%version%>"
if (nLog.Version == "<%".."version%>") then
	nLog.Version = "3.9-DEV"
end
NLOG_VERSION = nLog.Version

nLogData = {
	enabled = true,
}

function nLog.ChatMsg(msg)
	DEFAULT_CHAT_FRAME:AddMessage(msg)
end

local chat = nLog.ChatMsg
local broken = false
if not p then p = function () end end

function nLog.IsEnabled()
	return nLogData.enabled
end

function dump(...)
	local out = "";
	local n = select("#", ...)
	for i = 1, n do
		local d = select(i, ...);
		local t = type(d);
		if (t == "table") then
			out = out .. "{";
			local first = true;
			for k, v in pairs(d) do
				if (not first) then out = out .. ", "; end
				first = false;
				out = out .. dump(k);
				out = out .. " = ";
				out = out .. dump(v);
			end
			out = out .. "}";
		elseif (t == "nil") then
			out = out .. "NIL";
		elseif (t == "number") then
			out = out .. d;
		elseif (t == "string") then
			out = out .. "\"" .. d .. "\"";
		elseif (t == "boolean") then
			if (d) then
				out = out .. "true";
			else
				out = out .. "false";
			end
		else
			out = out .. string.upper(t) .. "??";
		end

		if (i < n) then out = out .. ", "; end
	end
	return out;
end

local function format(...)
	local n = select("#", ...)
	local out = ""
	for i = 1, n do
		if i > 1 and out:sub(-1) ~= "  " then out = out .. " "; end
		local d = select(i, ...)
		if (type(d) == "string") then
			if (d:sub(1,1) == " ") then
				out = out .. d:sub(2)
			else
				out = out..d;
			end
		else
			out = out..dump(d);
		end
	end
	return out
end

local pid = 0
function nLog.AddMessage(mAddon, mType, mLevel, mTitle, ...)
	if broken then return end
	if not (nLogData.enabled and mAddon and mType and mLevel and mTitle) then return end
	local ts = date("%b %d %H:%M");
	pid = pid + 1
	local msg = format(...)

	-- Once we fill up to 64k entries, treat the table like a loop buffer
	if (#nLog.messages >= 65535) then
		local ofs = nLog.Message.ofs or 0
		local message = nLog.messages[ofs+1]
		if (not message) then chat("Error logging message at offset("..ofs..")") broken = true return end
		message[1] = ts
		message[2] = pid
		message[3] = mAddon
		message[4] = mType
		message[5] = mLevel
		message[6] = mTitle
		message[7] = msg
		nLog.Message.ofs = (ofs+1 % 65535)
		return
	end
	table.insert(nLog.messages, {
		ts, pid, mAddon, mType, mLevel, mTitle, msg
	})
end

function nLog.OnEvent(frame, event, ...)
	if (event == "ADDON_LOADED") then
		local addon = select(1, ...)
		if (addon:lower() == "!nlog") then
			frame:UnregisterEvent("ADDON_LOADED")
		end
	end
end

local updateInterval = 1
local updated = 0
function nLog.OnUpdate(frame, delay)
	updated = updated + delay
	if (updated > delay) then
		updated = 0
		-- Do update stuff
		nLog.UpdateDisplay()
	end
end

function nLog.MessageShow()
	nLog.Message.pos = table.getn(nLog.messages)
	nLog.MessageDisplay()
end

function nLog.MessageDisplay(id)
	nLog.MessageUpdate()
	nLog.Message:Show()
end

function nLog.MessageDone()
	nLog.Message:Hide()
end

function nLog.MessageClicked(...)
end

function nLog.LineClicked(frame)
	local idx = frame.idx
	local ts, mId, mAddon, mType, mLevel, mTitle, msg = unpack(nLog.messages[idx])
	local mLevelName = nLog.levels[mLevel]
	local text = string.format("|cffffaa11Date:|r  %s\n|cffffaa11MsgId:|r %s\n|cffffaa11AddOn:|r %s\n|cffffaa11Type:|r  %s\n|cffffaa11Level:|r %s\n|cffffaa11Title:|r %s\n|cffffaa11Message:|r\n%s\n", ts, mId, mAddon, mType, mLevelName, mTitle, msg)
	nLog.Message.Box:SetText(text)
end

function nLog.MessageUpdate()
	nLog.Message.BoxScroll:UpdateScrollChildRect()
end

nLog.filtered = {}
function nLog.FilterUpdate()
	nLog.filterLevel = nLog.Message.LevelFilt:GetValue()
	nLog.filterAddon = nLog.Message.AddonFilt:GetText()
	nLog.filterType = nLog.Message.TypeFilt:GetText()

	if nLog.filtered.filterLevel == nLog.filterLevel
	and nLog.filtered.filterAddon == nLog.filterAddon
	and nLog.filtered.filterType == nLog.filterType
	and nLog.filtered.count == #nLog.messages
	and nLog.filtered.ofs == nLog.Message.ofs
	then
		return
	end

	-- Clean out the filter list and update
	for key in ipairs(nLog.filtered) do
		nLog.filtered[key] = nil
	end

	-- Rebuild the filter list
	local message, mAddon, mType, mLevel
	nLog.filtered.filterLevel = nLog.filterLevel
	nLog.filtered.filterAddon = nLog.filterAddon
	nLog.filtered.filterType = nLog.filterType
	nLog.filtered.count = #nLog.messages
	nLog.filtered.ofs = nLog.Message.ofs

	local fLevel = tonumber(nLog.filtered.filterLevel)
	local fAddon = (nLog.filtered.filterAddon or ""):lower()
	local fType = (nLog.filtered.filterType or ""):lower()
	local fOfs = nLog.filtered.ofs or 0
	if (fAddon == "") then fAddon = nil end
	if (fType == "") then fType = nil end
	for i = 0, #nLog.messages-1 do
		local fIdx = ((i + fOfs) % 65535)+1
		message = nLog.messages[fIdx]
		mAddon, mType, mLevel = message[3], message[4], message[5]
		if (not fLevel or fLevel >= mLevel)
		and (not fAddon or fAddon == "" or fAddon == mAddon:sub(1, #fAddon):lower())
		and (not fType or fType == "" or fType == mType:sub(1, #fType):lower())
		then
			table.insert(nLog.filtered, fIdx)
		end
	end
end

local lastLine = 0
local LOG_LINES = 16
function nLog.UpdateDisplay()
	local message, ts, mId, mAddon, mType, mLevel, mLevelName, mTitle, msg, idx, midx
	nLog.FilterUpdate()

	local rows = #nLog.filtered
	local scrollrows = rows
	if (scrollrows > 0 and scrollrows < LOG_LINES+1) then scrollrows = LOG_LINES+1 end
	FauxScrollFrame_Update(nLogMessageScroll, scrollrows, LOG_LINES, 16)

	local cpos = FauxScrollFrame_GetOffset(nLogMessageScroll)
	if (cpos ~= lastline) then
		lastline = cpos
	end

	for i = 1, LOG_LINES do
		idx = cpos + i
		midx = nLog.filtered[idx]
		if (midx) then
			message = nLog.messages[midx]
			if (message) then
				ts, mId, mAddon, mType, mLevel, mTitle, msg = unpack(message)
				mLevelName = nLog.levels[mLevel]
				nLog.Message.Lines[i]:SetText(string.format("%s: %s-%s-%s: %s", ts, mAddon, mType, mLevelName, mTitle, msg))
				nLog.Message.Lines[i]:Show()
				nLog.Message.Lines[i].idx = midx
			else
				nLog.Message.Lines[i]:Hide()
			end
		else
			nLog.Message.Lines[i]:Hide()
		end
	end
end


-- Create our message message frame
nLog.Message = CreateFrame("Frame", "", UIParent)
nLog.Message:Hide()
nLog.Message:SetPoint("CENTER", "UIParent", "CENTER")
nLog.Message:SetFrameStrata("DIALOG")
nLog.Message:SetHeight(400)
nLog.Message:SetWidth(600)
nLog.Message:SetBackdrop({
	bgFile = "Interface/Tooltips/UI-Tooltip-Background",
	edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
	tile = true, tileSize = 32, edgeSize = 16,
	insets = { left = 4, right = 4, top = 4, bottom = 4 }
})
nLog.Message:SetBackdropColor(0,0,0.5, 0.8)
nLog.Message:SetScript("OnShow", nLog.MessageShow)

nLog.Message.AddonFilt = CreateFrame("EditBox", "nLogAddFilt", nLog.Message, "InputBoxTemplate")
nLog.Message.AddonFilt:SetPoint("BOTTOMLEFT", nLog.Message, "BOTTOMLEFT", 20, 12)
nLog.Message.AddonFilt:SetAutoFocus(false)
nLog.Message.AddonFilt:SetHeight(15)
nLog.Message.AddonFilt:SetWidth(80)

nLog.Message.TypeFilt = CreateFrame("EditBox", "nLogTypeFilt", nLog.Message, "InputBoxTemplate")
nLog.Message.TypeFilt:SetPoint("BOTTOMLEFT", nLog.Message.AddonFilt, "BOTTOMRIGHT", 5, 0)
nLog.Message.TypeFilt:SetAutoFocus(false)
nLog.Message.TypeFilt:SetHeight(15)
nLog.Message.TypeFilt:SetWidth(80)

nLog.Message.LevelFilt = CreateFrame("Slider", "nLogLevelFilt", nLog.Message, "OptionsSliderTemplate")
nLog.Message.LevelFilt:SetPoint("BOTTOMLEFT", nLog.Message.TypeFilt, "BOTTOMRIGHT", 5, -3)
nLog.Message.LevelFilt:SetHeight(20)
nLog.Message.LevelFilt:SetWidth(60)
nLogLevelFiltLow:SetText("")
nLogLevelFiltHigh:SetText("")
nLog.Message.LevelFilt:SetMinMaxValues(1, 5)
nLog.Message.LevelFilt:SetValueStep(1)
nLog.Message.LevelFilt:SetValue(N_DEBUG)
nLog.Message.LevelFilt:SetHitRectInsets(0,0,0,0)

nLog.Message.Done = CreateFrame("Button", "", nLog.Message, "OptionsButtonTemplate")
nLog.Message.Done:SetText("Close")
nLog.Message.Done:SetPoint("BOTTOMRIGHT", nLog.Message, "BOTTOMRIGHT", -10, 10)
nLog.Message.Done:SetScript("OnClick", nLog.MessageDone)

nLog.Message.MsgScroll = CreateFrame("ScrollFrame", "nLogMessageScroll", nLog.Message, "FauxScrollFrameTemplate")
nLog.Message.MsgScroll:SetPoint("TOPLEFT", nLog.Message, "TOPLEFT", 20, -20)
nLog.Message.MsgScroll:SetPoint("RIGHT", nLog.Message, "RIGHT", -40, 0)
nLog.Message.MsgScroll:SetHeight(200)
nLog.Message.MsgScroll:SetScript("OnVerticalScroll", function () FauxScrollFrame_OnVerticalScroll(LOG_LINES, nLog.UpdateDisplay) end)
nLog.Message.MsgScroll:SetScript("OnShow", function() nLog.UpdateDisplay() end)

nLog.Message.BoxFrame = CreateFrame("Frame", "", nLog.Message)
nLog.Message.BoxFrame:SetBackdrop({
	bgFile = "Interface/Tooltips/UI-Tooltip-Background",
	edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
	tile = true, tileSize = 32, edgeSize = 16,
	insets = { left = 4, right = 4, top = 4, bottom = 4 }
})
nLog.Message.BoxFrame:SetBackdropColor(0,0,0.5, 0.8)
nLog.Message.BoxFrame:SetPoint("TOPLEFT", nLog.Message.MsgScroll, "BOTTOMLEFT", -5, 0)
nLog.Message.BoxFrame:SetPoint("RIGHT", nLog.Message, "RIGHT", -15, 0)
nLog.Message.BoxFrame:SetPoint("BOTTOM", nLog.Message.Done, "TOP", 0, 5)

nLog.Message.BoxScroll = CreateFrame("ScrollFrame", "nLogMessageInputScroll", nLog.Message.BoxFrame, "UIPanelScrollFrameTemplate")
nLog.Message.BoxScroll:SetPoint("TOPLEFT", nLog.Message.BoxFrame, "TOPLEFT", 10, -5)
nLog.Message.BoxScroll:SetPoint("BOTTOMRIGHT", nLog.Message.BoxFrame, "BOTTOMRIGHT", -27, 4)

nLog.Message.Box = CreateFrame("EditBox", "nLogMessageEditBox", nLog.Message.BoxScroll)
nLog.Message.Box:SetFont("Interface\\AddOns\\!nLog\\VeraMono.TTF", 11)
nLog.Message.Box:SetPoint("BOTTOM", nLog.Message.BoxFrame, "BOTTOM", 0,0)
nLog.Message.Box:SetWidth(550)
nLog.Message.Box:SetMultiLine(true)
nLog.Message.Box:SetAutoFocus(false)
nLog.Message.Box:SetFontObject(GameFontHighlight)
nLog.Message.Box:SetScript("OnEscapePressed", nLog.MessageDone)
nLog.Message.Box:SetScript("OnTextChanged", nLog.MessageUpdate)
nLog.Message.Box:SetScript("OnEditFocusGained", nLog.MessageClicked)
nLog.Message.Box:SetText("|cffffa011Select a message above to view it's contents.|r")
nLog.Message.BoxScroll:SetScrollChild(nLog.Message.Box)

nLog.Message.Lines = {}
for i=1, 16 do
	local line = CreateFrame("Button", "", nLog.Message)
	nLog.Message.Lines[i] = line
	line.id = i
	if (i == 1) then
		line:SetPoint("TOPLEFT", nLog.Message.MsgScroll, "TOPLEFT", 0, 0)
	else
		line:SetPoint("TOPLEFT", nLog.Message.Lines[i-1], "BOTTOMLEFT", 0, 0)
	end
	line:SetPoint("RIGHT", nLog.Message.MsgScroll, "RIGHT", -5, 0)
	line:SetHeight(12)
	line:SetScript("OnClick", nLog.LineClicked)
	line.text = line:CreateFontString("", "HIGH")
	line.text:SetPoint("LEFT", line, "LEFT")
	line.text:SetPoint("RIGHT", line, "RIGHT")
	line.text:SetFont("Interface\\AddOns\\!nLog\\VeraMono.TTF", 11)
	line.text:SetJustifyH("LEFT")
	line.SetText = function(obj, ...) obj.text:SetText(...) end
	line:SetText("LINE "..i)
end

nLog.UpdateDisplay()

nLog.Frame = CreateFrame("Frame")
nLog.Frame:Show()
nLog.Frame:SetScript("OnEvent", nLog.OnEvent)
nLog.Frame:SetScript("OnUpdate", nLog.OnUpdate)
nLog.Frame:RegisterEvent("ADDON_LOADED")

SLASH_NLOG1 = "/nlog"
SlashCmdList["NLOG"] = function(msg)
	if (not msg or msg == "" or msg == "help") then
		chat("nLog help:")
		chat("  /nlog enable    -  Enables nLog")
		chat("  /nlog disable   -  Disables nLog")
		chat("  /nlog show      -  Shows the nLog frame")
	elseif (msg == "show") then
		nLog.Message:Show()
	elseif (msg == "enable") then
		nLogData.enabled = true
		chat("nLog will now catch messages")
	elseif (msg == "disable") then
		nLogData.enabled = false
		chat("nLog will no longer catch messages")
	else
		chat("Unknown nLog command: "..(msg or "nil"))
	end
end

