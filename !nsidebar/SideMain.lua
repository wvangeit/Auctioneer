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

local LIBRARY_VERSION_MAJOR = "nSideBar"
local LIBRARY_VERSION_MINOR = 1

do -- A very simple stub library
        local major, minor = "nStub", 1
        local lib = _G[major]
        if not lib or not lib.versions[major] or lib.versions[major] < minor then
                lib = lib or { libs = {}, versions = {} }
                _G[major] = lib
                lib.libs[major], lib.versions[major] = lib, minor
                function lib:New(major, minor)
						major = tostring(major)
                        minor = tonumber(strmatch(minor, "%d+")) or 0
                        local old = self.versions[major]
                        if old and old >= minor then return nil end
                        self.versions[major], self.libs[major] = minor, self.libs[major] or {}
                        return self.libs[major], old
                end
                function lib:Get(major, ignore)
						major = tostring(major)
                        if not ignore and not self.libs[major] then
                                error(("nStub cannot load: %s"):format(major))
                        end
                        return self.libs[major], self.versions[major]
                end
        end
end -- nStub

local lib = nStub:New(LIBRARY_VERSION_MAJOR, LIBRARY_VERSION_MINOR)
if not lib then return end

RegisterCVar("nSideBarPos", "fadeout:10:right:180")

if not lib.private then
	lib.private = {}
end

local private = lib.private
local frame

function lib:GetVersion()
	return LIBRARY_VERSION_MAJOR, LIBRARY_VERSION_MINOR;
end

if lib.frame then
	frame = lib.frame
else
	frame = CreateFrame("Frame", "", UIParent)
	frame:SetToplevel(true)
	frame:SetHitRectInsets(-3, -3, -3, -3)
	frame:SetBackdrop({
		bgFile = "Interface/Tooltips/UI-Tooltip-Background",
		edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
		tile = true, tileSize = 32, edgeSize = 16,
		insets = { left = 4, right = 4, top = 4, bottom = 4 }
	})
	frame:SetBackdropColor(0,0,0, 0.5)
	frame:EnableMouse(true)
	frame:SetScript("OnEnter", function(...) private.PopOut(...) end)
	frame:SetScript("OnLeave", function(...) private.PopBack(...) end)
	frame:SetScript("OnUpdate", function(...) private.Popper(...) end)
	frame.Tab = frame:CreateTexture()
	frame.Tab:SetTexture(0.98, 0.78, 0)
	frame.buttons = {}

	SLASH_NSIDEBAR1 = "/nsb"
	SLASH_NSIDEBAR2 = "/nsidebar"
	SlashCmdList["NSIDEBAR"] = function(msg)
		frame.private.CommandHandler(msg)
	end

	lib.frame = frame
end

function private:PopOut(button)
	self.PopTimer = 0.15
	self.PopDirection = 1
end

function private:PopBack(button)
	self.PopTimer = 0.75
	self.PopDirection = -1
end

function private:MouseDown(button)
	if button then
		button.icon:SetTexCoord(0, 1, 0, 1)
	end
end

function private:MouseUp(button)
	if button then
		button.icon:SetTexCoord(0.075, 0.925, 0.075, 0.925)
	end
end

function private:Popper(duration)
	if self.PopDirection then
		self.PopTimer = self.PopTimer - duration
		if self.PopTimer < 0 then
			if self.PopDirection > 0 then
				-- Pop Out
				self.PopDirection = nil
				self:ClearAllPoints()
				self.isOpen = true
			else
				-- Pop Back
				self.PopDirection = nil
				self:ClearAllPoints()
				self.isOpen = false
			end
			lib.ApplyLayout(true)
		end
	end
end

function private.CommandHandler(msg)
	local configVar = GetCVar("nSideBarPos")
	local vis, wide, side, position = strsplit(":", configVar)

	local save = false
	if (not msg or msg == "") then msg = "help" end
	local a, b, c = strsplit(" ", msg:lower())
	if (a == "help") then
		DEFAULT_CHAT_FRAME:AddMessage("/nsb [ top | left | bottom | right ] [ <n> ]")
		DEFAULT_CHAT_FRAME:AddMessage("/nsb [ fadeout | nofade ]")
		DEFAULT_CHAT_FRAME:AddMessage("/nsb size [ <n> ]")
		return
	end
	if (a == "top") 
	or (a == "left") 
	or (a == "bottom")
	or (a == "right") then
		side = a
		save = true
		if (tonumber(b)) then
			a, b, c = b, nil, nil
		end
	end
	if (tonumber(a)) then
		position = math.min(math.abs(tonumber(a)), 1200)
		save = true
	end
	if (a == "fadeout" or a == "fade") then
		vis = "fadeout"
		save = true
	elseif (a == "nofade") then
		vis = "visible"
		save = true
	end
	if (a == "size") then
		if (tonumber(b)) then
			wide = math.floor(tonumber(b))
			if (wide < 1) then wide = 1 end
			save = true
		end
	end

	if (save) then
		SetCVar("nSideBarPos", strjoin(":", vis, wide, side, position))
		lib.ApplyLayout()
	end
end

function lib.AddButton(id, texture, priority)
	if not priority then priority = 200 end
	p("Adding button", id, texture, priority)

	local button
	if not frame.buttons[id] then
		p("Creating button")
		button = CreateFrame("Button", "", frame)
		button.frame = frame
		button:SetPoint("TOPLEFT", frame, "TOPLEFT", 0,0)
		button:SetWidth(30)
		button:SetHeight(30)
		button:SetScript("OnMouseDown", function (...) private.MouseDown(this.frame, this, ...) end)
		button:SetScript("OnMouseUp", function (...) private.MouseUp(this.frame, this, ...) end)
		button:SetScript("OnEnter", function (...) private.PopOut(this.frame, this, ...) end)
		button:SetScript("OnLeave", function (...) private.PopBack(this.frame, this, ...) end)
		button.icon = button:CreateTexture("", "BACKGROUND")
		button.icon:SetTexCoord(0.075, 0.925, 0.075, 0.925)
		button.icon:SetPoint("TOPLEFT", button, "TOPLEFT", 0,0)
		button.icon:SetWidth(30)
		button.icon:SetHeight(30)
		button.id = id
		frame.buttons[id] = button
	else
		p("Using existing button")
		button = frame.buttons[id]
	end
	p("Seting icon texture")
	button.icon:SetTexture(texture)
	button.priority = priority

	lib.ApplyLayout()
	return button
end


-- TODO - do we need a show/hide function, possibly keyed off of a per-button "shown" value?
-- or is add/remove good enough?  It's not something likely to be changed often.

function lib.RemoveButton(id)
	p("Removing button", id)
	local button = frame.buttons[id]
	if button then button:Hide() end
	frame.buttons[id] = nil
	lib.ApplyLayout()
end


function lib.ApplyLayout(useLayout)
	p("Applying Layout")
	local configVar = GetCVar("nSideBarPos")
	if not (lib.lastConfig and configVar == lib.lastConfig) then
		useLayout = false
	end

	local vis, wide, side, position = strsplit(":", configVar)
	position = math.abs(tonumber(position) or 180)
	wide = tonumber(wide)
	side = side:lower()

	if not lib.private.layout then
		lib.private.layout = {}
		useLayout = false
	end
	local layout = lib.private.layout
	
	if not useLayout then
		for i = 1, #layout do table.remove(layout) end
		for id, button in pairs(frame.buttons) do
			table.insert(layout, button)
		end
	
		if (#layout == 0) then
			frame:Hide()
			return
		end
		
		table.sort(layout, function (a, b)
			if (a.priority < b.priority) then
				return true
			elseif (a.id < b.id) then
				return true
			end
			return false
		end)
	end

	if (#layout == 0) then
		frame:Hide()
		return
	end
		
	local width = wide
	if (#layout < wide) then width = #layout end
	local height = math.floor((#layout - 1) / wide) + 1

	local distance = 9
	if (frame.isOpen) then
		distance = width * 32 + 10
		if (frame:GetAlpha() < 1) then
			UIFrameFadeIn(frame, 0.25, frame:GetAlpha(), 1)
		end
	elseif (vis ~= "visible") then
		if (frame:GetAlpha() > 0.2) then
			UIFrameFadeOut(frame, 1.5, frame:GetAlpha(), 0.2)
		end
	end

	frame:ClearAllPoints()
	if (side == "top") then
		frame:SetPoint("BOTTOMLEFT", UIParent, "TOPLEFT", position, -1*distance)
	elseif (side == "bottom") then
		frame:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", position, distance)
	elseif (side == "left") then
		frame:SetPoint("TOPRIGHT", UIParent, "TOPLEFT", distance, -1*position)
	elseif (side == "right") then
		frame:SetPoint("TOPLEFT", UIParent, "TOPRIGHT", -1*distance, -1*position)
	end

	if (useLayout) then return end

	frame.Tab:ClearAllPoints()
	if (side == "top" or side == "bottom") then
		frame:SetWidth(height * 32 + 10)
		frame:SetHeight(width * 32 + 18)
		if (side == "top") then
			frame.Tab:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 5, 5)
			frame.Tab:SetPoint("RIGHT", frame, "RIGHT", -5, 0)
		else
			frame.Tab:SetPoint("TOPLEFT", frame, "TOPLEFT", 5, -5)
			frame.Tab:SetPoint("RIGHT", frame, "RIGHT", -5, 0)
		end
		frame.Tab:SetHeight(3)
	else
		frame:SetWidth(width * 32 + 18)
		frame:SetHeight(height * 32 + 10)
		if (side == "right") then
			frame.Tab:SetPoint("TOPLEFT", frame, "TOPLEFT", 5, -5)
			frame.Tab:SetPoint("BOTTOM", frame, "BOTTOM", 0, 5)
		else
			frame.Tab:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -5, -5)
			frame.Tab:SetPoint("BOTTOM", frame, "BOTTOM", 0, 5)
		end
		frame.Tab:SetWidth(3)
	end
	frame:Show()
	
	local button
	for pos = 1, #layout do
		button = layout[pos]
		pos = pos - 1
		local row = math.floor(pos / wide)
		local col = pos % wide

		if (row == 0) then width = col end

		button:ClearAllPoints()
		if (side == "right") then
			button:SetPoint("TOPLEFT", frame, "TOPLEFT", col*32+10, 0-(row*32+5))
		elseif (side == "left") then
			button:SetPoint("TOPLEFT", frame, "TOPLEFT", col*32+5, 0-(row*32+5))
		elseif (side == "bottom") then
			button:SetPoint("TOPLEFT", frame, "TOPLEFT", row*32+5, 0-(col*32+10))
		elseif (side == "top") then
			button:SetPoint("TOPLEFT", frame, "TOPLEFT", row*32+5, 0-(col*32+5))
		end
	end
end

