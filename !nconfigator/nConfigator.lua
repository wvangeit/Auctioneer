--[[

	nConfigator - A library to help you create a gui config
	Revision: $Id$

	License:
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
		Foundation, Inc., 51 Franklin Street, Fifth Floor,
		Boston, MA  02110-1301  USA

	Additional:
		Regardless of any other conditions, you may freely use this code
		within the World of Warcraft game client.

--------------------------------------------------------------------------

USAGE:

	Stub   nConfigator = LibStub:GetLibrary("nConfigator")
	Call   myCfg = nConfigator:Create(setterFunc, getterFunc)
	Call   tabId = myCfg:AddTab(TabName)
	Call   myCfg:AddControl(tabId, controlType, leftPct, ...)
	Wait   for callbacks on your getters and setters

	Your setter will be called with (variableName, value) for you to set
	Your getter will be called with (variableName) for your to return the current value

	The AddControl function's ... varies depending on the controlType:
	"Header" == text
	"Subhead" == text
	"Checkbox" == level, setting, label
	"Slider" == level, setting, min, max, step, label, fmtfunc
	"Text" = level, setting, label
	"NumberBox" == level, setting, minVal, maxVal, label
	"MoneyFrame" = level, setting, label
	"MoneyFramePinned" = level, setting, minVal, maxVal, label

	Settings and configuration system.
]]

local LIBRARY_VERSION_MAJOR = "nConfigator"
local LIBRARY_VERSION_MINOR = 1

do -- LibStub
	-- LibStub is a simple versioning stub meant for use in Libraries.  http://www.wowace.com/wiki/LibStub for more info
	-- LibStub is hereby placed in the Public Domain
	-- Credits: Kaelten, Cladhaire, ckknight, Mikk, Ammo, Nevcairiel, joshborke
	local LIBSTUB_MAJOR, LIBSTUB_MINOR = "LibStub", 2  -- NEVER MAKE THIS AN SVN REVISION! IT NEEDS TO BE USABLE IN ALL REPOS!
	local LibStub = _G[LIBSTUB_MAJOR]

	-- Check to see is this version of the stub is obsolete
	if not LibStub or LibStub.minor < LIBSTUB_MINOR then
		LibStub = LibStub or {libs = {}, minors = {} }
		_G[LIBSTUB_MAJOR] = LibStub
		LibStub.minor = LIBSTUB_MINOR
		
		-- LibStub:NewLibrary(major, minor)
		-- major (string) - the major version of the library
		-- minor (string or number ) - the minor version of the library
		-- 
		-- returns nil if a newer or same version of the lib is already present
		-- returns empty library object or old library object if upgrade is needed
		function LibStub:NewLibrary(major, minor)
			assert(type(major) == "string", "Bad argument #2 to `NewLibrary' (string expected)")
			minor = assert(tonumber(strmatch(minor, "%d+")), "Minor version must either be a number or contain a number.")
			
			local oldminor = self.minors[major]
			if oldminor and oldminor >= minor then return nil end
			self.minors[major], self.libs[major] = minor, self.libs[major] or {}
			return self.libs[major], oldminor
		end
		
		-- LibStub:GetLibrary(major, [silent])
		-- major (string) - the major version of the library
		-- silent (boolean) - if true, library is optional, silently return nil if its not found
		--
		-- throws an error if the library can not be found (except silent is set)
		-- returns the library object if found
		function LibStub:GetLibrary(major, silent)
			if not self.libs[major] and not silent then
				error(("Cannot find a library instance of %q."):format(tostring(major)), 2)
			end
			return self.libs[major], self.minors[major]
		end
		
		-- LibStub:IterateLibraries()
		-- 
		-- Returns an iterator for the currently registered libraries
		function LibStub:IterateLibraries() 
			return pairs(self.libs) 
		end
		
		setmetatable(LibStub, { __call = LibStub.GetLibrary })
	end
end -- LibStub

local lib = LibStub:NewLibrary(LIBRARY_VERSION_MAJOR, LIBRARY_VERSION_MINOR)
if not lib then return end

local kit = {}

if not lib.frames then lib.frames = {} end
if not lib.tmpId then lib.tmpId = 0 end


function lib:CreateAnonName()
	lib.tmpId = lib.tmpId + 1
	return "nConfigatorAnon"..lib.tmpId
end


function lib:Create(setter, getter, w,h)
	local id = #(lib.frames) + 1
	local name = "nConfigatorDialog_"..id

	local gui = CreateFrame("Frame", name, UIParent)
	table.insert(lib.frames, gui)
	gui.Done = CreateFrame("Button", nil, gui, "OptionsButtonTemplate")
	gui.setter = setter
	gui.getter = getter

	local top = getter("configator.top")
	local left = getter("configator.left")
	if (top and left) then
		gui:SetPoint("TOPLEFT", "UIParent", "BOTTOMLEFT", left, top)
	else
		gui:SetPoint("CENTER", "UIParent", "CENTER")
	end
	gui:Hide()
	gui:SetFrameStrata("DIALOG")
	gui:SetToplevel(true)
	gui:SetMovable(true)
	gui:SetWidth(w or 800)
	gui:SetHeight(h or 450)
	gui:SetBackdrop({
		bgFile = "Interface/Tooltips/UI-Tooltip-Background",
		edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
		tile = true, tileSize = 32, edgeSize = 16,
		insets = { left = 5, right = 5, top = 5, bottom = 5 }
	})
	gui:SetBackdropColor(0, 0, 0, 0.9)
	table.insert(UISpecialFrames, name) -- make frames Esc Sensitive by default

	gui.Drag = CreateFrame("Button", nil, gui)
	gui.Drag:SetPoint("TOPLEFT", gui, "TOPLEFT", 10,-5)
	gui.Drag:SetPoint("TOPRIGHT", gui, "TOPRIGHT", -10,-5)
	gui.Drag:SetHeight(6)
	gui.Drag:SetHighlightTexture("Interface\\FriendsFrame\\UI-FriendsFrame-HighlightBar")

	gui.Drag:SetScript("OnMouseDown", function() gui:StartMoving() end)
	gui.Drag:SetScript("OnMouseUp", function() gui:StopMovingOrSizing() setter("configator.left", gui:GetLeft()) setter("configator.top", gui:GetTop()) end)

	gui.Done:SetPoint("BOTTOMRIGHT", gui, "BOTTOMRIGHT", -10, 10)
	gui.Done:SetScript("OnClick", function() gui:Hide() end)
	gui.Done:SetText(DONE)

	gui.tabs = {
		pos = 0,
		count = 0,
	}
	gui.elements = {}

	for k,v in pairs(kit) do
		gui[k] = v
	end

	return gui
end



function kit:ZeroFrame()
	local id = 0
	local frame
	frame = CreateFrame("Frame", nil, self)
	frame.id = id
	frame:SetPoint("TOPLEFT", self, "TOPLEFT", 10, -10)
	frame:SetPoint("BOTTOMRIGHT", self.Done, "TOPRIGHT", 0, 5)
	frame:SetBackdrop({
		bgFile = "Interface/Tooltips/UI-Tooltip-Background",
		edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
		tile = true, tileSize = 32, edgeSize = 16,
		insets = { left = 4, right = 4, top = 4, bottom = 4 }
	})
	frame:SetBackdropColor(0,0,0, 0.5)
	frame.contentWidth = 740
	self.tabs[id] = {}
	self.tabs[id][2] = frame
	return id
end

function kit:AddTab(tabName)
	local button, frame, content, id
	button = CreateFrame("Button", nil, self, "OptionsButtonTemplate")
	frame = CreateFrame("Frame", nil, self)
	content = CreateFrame("Frame", lib.CreateAnonName(), frame)

	table.insert(self.tabs, { button, frame, content })
	id = table.getn(self.tabs)
	button.id = id
	frame.id = id
	self.tabs.count = id
	self.tabs.pos = id
	if (not self.tabs.active) then
		self.tabs.active = id
	else
		frame:Hide()
	end
	if (id == 1) then
		button:SetPoint("TOPLEFT", self, "TOPLEFT", 10, -10)
	else
		button:SetPoint("TOPLEFT", self.tabs[id-1][1], "BOTTOMLEFT", 0, 0)
	end
	button:SetWidth(120)
	button:SetScript("OnClick", kit.ActivateTab)
	frame:SetPoint("TOPLEFT", self.tabs[1][1], "TOPRIGHT", 0, 0)
	frame:SetPoint("BOTTOMRIGHT", self.Done, "TOPRIGHT", 0, 5)
	frame:SetBackdrop({
		bgFile = "Interface/Tooltips/UI-Tooltip-Background",
		edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
		tile = true, tileSize = 32, edgeSize = 16,
		insets = { left = 4, right = 4, top = 4, bottom = 4 }
	})
	frame:SetBackdropColor(0,0,0, 0.5)
	content:SetPoint("TOPLEFT", frame, "TOPLEFT", 5,-5)
	content:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -5,5)
	button:SetText(tabName)
	frame.contentWidth = 620
	return id
end

function kit:AddCat(catName)
	local button, frame, id
	button = CreateFrame("Button", nil, self)
	frame = {}
	table.insert(self.tabs, { button, frame })
	id = table.getn(self.tabs)
	self.tabs.count = id
	self.tabs.pos = id
	button.id = id
	frame.id = id
	if (id == 1) then
		button:SetPoint("TOPLEFT", self, "TOPLEFT", 10, -10)
	else
		button:SetPoint("TOPLEFT", self.tabs[id-1][1], "BOTTOMLEFT", 0, 0)
	end
	button:Disable()
	button:SetWidth(120)
	button:SetHeight(22)
	button.Text = button:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	button.Text:SetJustifyH("LEFT")
	button.Text:SetJustifyV("BOTTOM")
	button.Text:SetPoint("TOPLEFT", button, "TOPLEFT", 5,0)
	button.Text:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT")
	button.Text:SetText(catName)
	frame.contentWidth = 0
	return id
end

local function anchorPoint(frame, el, last, indent, width, height, yofs)
	local clearance = 0
	if (last and last.clearance) then clearance = last.clearance end

	el:SetPoint("LEFT", frame, "LEFT", indent or 15, 0)
	if (width == nil) then
		el:SetPoint("RIGHT", frame, "RIGHT", -5, 0)
	elseif (type(width) == "number") then
		el:SetWidth(width)
	end
	if (type(height) == "number") then
		el:SetHeight(height)
	end
	if (last) then
		el:SetPoint("TOP", last, "BOTTOM", 0, -5 + (yofs or 0) - clearance)
	else
		el:SetPoint("TOP", frame, "TOP", 0, -5 - clearance)
	end
end

function kit:Unfocus()
	self:Hide()
	self:ClearFocus()
	self:Show()
end

function kit:SetControlWidth(width)
	self.scalewidth = width
end

function kit:MakeScrollable(id)
	if (self.tabs[id][4]) then return end
	local frame = self.tabs[id][2]
	local content = self.tabs[id][3]
	local oldwidth = content:GetWidth()
	content:ClearAllPoints()
	content:SetWidth(oldwidth)
	content:SetHeight(250)
	local nPanelScroller = LibStub:GetLibrary("nPanelScroller")
	local scroll = nPanelScroller:Create(lib.CreateAnonName(), frame)
	scroll:SetPoint("TOPLEFT", frame, "TOPLEFT", 5,-5)
	scroll:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -25,5)
	scroll:SetScrollChild(content:GetName())
	scroll:UpdateScrollChildRect()
	self.tabs[id][4] = scroll
	GSC = scroll
end

function kit:AddControl(id, cType, column, ...)
	local frame = self.tabs[id][2]
	if (frame.contentWidth == 0) then
		error("Attempting to add a control to a non-existent frame")
	end
	if (not frame.ctrls) then
		frame.ctrls = { pos = 0 }
	end
	local cpos = frame.ctrls.pos + 1
	frame.ctrls.pos = cpos
	local ctrl = { kids = {} }
	frame.ctrls[cpos] = ctrl

	local last = frame.ctrls.last
	local control

	local kids = ctrl.kids
	local kpos = 0

	local framewidth = frame:GetWidth() - 20
	column = (column or 0) * framewidth
	local colwidth = nil
	if (self.scalewidth) then
		colwidth = math.min(framewidth-column, (self.scalewidth or 1) * framewidth)
	end

	local content = self.tabs[id][3]

	local el
	if (cType == "Header") then
		el = content:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
		kpos = kpos+1 kids[kpos] = el
		anchorPoint(content, el, last)
		local text = ...
		el:SetText(text)
		last = el
	elseif (cType == "Subhead") then
		el = content:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
		el:SetJustifyH("LEFT")
		kpos = kpos+1 kids[kpos] = el
		anchorPoint(content, el, last, column+15, colwidth, nil, -10)
		local text = ...
		el:SetText(text)
		last = el
	elseif (cType == "Note") then
		local level, width, height, text = ...
		local indent = 10 * (level or 1)
		el = content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
		el:SetJustifyH("LEFT")
		el:SetJustifyV("TOP")
		kpos = kpos+1 kids[kpos] = el
		anchorPoint(content, el, last, column+indent+15, width, height, nil)
		el:SetText(text)
		control = el
		last = el
	elseif (cType == "Label") then
		local level, setting, text = ...
		local indent = 10 * (level or 1)
		el = content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
		el:SetJustifyH("LEFT")
		kpos = kpos+1 kids[kpos] = el
		anchorPoint(content, el, last, column+indent+15, colwidth)
		el:SetText(text)
		if (setting) then
			el.hit = CreateFrame("Button", nil, content)
			el.hit.parent = el
			el.hit:SetAlpha(0.3)
			el.hit:SetPoint("TOPLEFT", el, "TOPLEFT", -2, 2)
			el.hit:SetPoint("BOTTOMRIGHT", el, "BOTTOMRIGHT", 2, -2)
			--el.hit:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")
			el.hit:SetHighlightTexture("Interface\\FriendsFrame\\UI-FriendsFrame-HighlightBar")
			el.hit.setting = setting
			el.hit.stype = "Button";
			el.hit:SetScript("OnClick", function() self:ChangeSetting(this) end)
			el.hit:Show()
		end
		control = el
		last = el
	elseif (cType == "Custom") then
		local level, el = ...
		local indent = 10 * (level or 1)
		kpos = kpos+1 kids[kpos] = el
		anchorPoint(content, el, last, column + indent + 15, colwidth)
		control = el
		last = el
	elseif (cType == "Text") then
		local level, setting, label = ...
		local indent = 10 * (level or 1)
		-- FontString
		el = content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
		el:SetJustifyH("LEFT")
		kpos = kpos+1 kids[kpos] = el
		anchorPoint(content, el, last, 10 + column + indent)
		el:SetText(label)
		last = el
		-- Editbox
		el = CreateFrame("EditBox", nil, content, "InputBoxTemplate")
		kpos = kpos+1 kids[kpos] = el
		anchorPoint(content, el, last, 20 + column + indent, colwidth or 160, 32, 4)
		el.setting = setting
		el.stype = "EditBox"
		el:SetAutoFocus(false)
		self:GetSetting(el)
		el:SetScript("OnEditFocusLost", function() self:ChangeSetting(this) end)
		el:SetScript("OnEscapePressed", kit.Unfocus)
		el:SetScript("OnEnterPressed", kit.Unfocus)
		self.elements[setting] = el
		el.textEl = last

		control = el
		last = el
	elseif (cType == "Selectbox") then
		local level, list, setting, text = ...
		local indent = 10 * (level or 1)
		-- Selectbox
		local tmpName = lib.CreateAnonName()

		if (type(list) ~= "function") then
			local listVar = list
			if (type(list) == "table") then
				list = function() return listVar end
			else
				list = function() return self.getter(listVar) end
			end
		end

		local nSelectBox = LibStub:GetLibrary("nSelectBox")
		el = nSelectBox:Create(tmpName, content, 140, function(...) self:ChangeSetting(...) end, list, "Default")
		kpos = kpos+1 kids[kpos] = el
		anchorPoint(content, el, last, column+indent - 5, colwidth or 140, 22, 4)
		el.list = list
		el.setting = setting
		el.stype = "SelectBox";
		el.clearance = 10
		self.elements[setting] = el
		self:GetSetting(el)
		control = el
		last = el

	elseif (cType == "Button") then
		local level, setting, text = ...
		local indent = 10 * (level or 1)
		-- Button
		el = CreateFrame("Button", nil, content, "OptionsButtonTemplate")
		kpos = kpos+1 kids[kpos] = el
		anchorPoint(content, el, last, 10 + column + indent, colwidth or 80, 22, 4)
		el.setting = setting
		el.stype = "Button";
		el:SetScript("OnClick", function() self:ChangeSetting(this) end)
		el:SetText(text)
		control = el
		last = el
	elseif (cType == "Checkbox") then
		local level, setting, text, singleLine, maxLabelLength = ...
		if ( maxLabelLength and maxLabelLength <= 1 ) then
			maxLabelLength = maxLabelLength * framewidth - 25
		end
		local indent = 10 * (level or 1)
		-- CheckButton
		el = CreateFrame("CheckButton", nil, content, "OptionsCheckButtonTemplate")
		kpos = kpos+1 kids[kpos] = el
		anchorPoint(content, el, last, 10 + column + indent, 22, 22, 4)
		el.setting = setting
		el.stype = "CheckButton"
		self:GetSetting(el)
		el:SetScript("OnClick", function() self:ChangeSetting(this) end)
		self.elements[setting] = el
		control = el
		-- FontString
		el = content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
		el:SetJustifyH("LEFT")
		kpos = kpos+1 kids[kpos] = el
		if (colwidth) then colwidth = colwidth - 15 end
		anchorPoint(content, el, last, 35+column+indent, (colwidth or maxLabelLength), (singleLine and 14))
		el:SetText(text)
		control.textEl = el
		last = el
	elseif (cType == "Slider" or cType == "WideSlider") then
		local swidth = 140
		if (cType == "WideSlider") then swidth = 260 end
		local level, setting, min, max, step, text, fmtfunc = ...
		local indent = 10 * (level or 1)
		-- FontString
		el = content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
		el:SetJustifyH("LEFT")
		kpos = kpos+1 kids[kpos] = el
		anchorPoint(content, el, last, swidth + 20 + column+indent)
		el:SetText(text)
		local textElement = el
		-- Slider
		local tmpName = lib.CreateAnonName()
		el = CreateFrame("Slider", tmpName, content, "OptionsSliderTemplate")
		kpos = kpos+1 kids[kpos] = el
		anchorPoint(content, el, last, 13 + column + indent, swidth, 20, 4)
		getglobal(tmpName.."Low"):SetText("")
		getglobal(tmpName.."High"):SetText("")
		el.setting = setting
		el.textFmt = text
		el.fmtFunc = fmtfunc
		el.textEl = textElement
		el.stype = "Slider";
		el:SetMinMaxValues(min, max)
		el:SetValueStep(step)
		self:GetSetting(el)
		el:SetHitRectInsets(0,0,0,0)
		el:SetScript("OnValueChanged", function() self:ChangeSetting(this) end)
		self.elements[setting] = el
		control = el
		last = textElement
	elseif (cType == "NumberBox") then
		local level, setting, minVal, maxVal, label = ...
		local indent = 10 * (level or 1)
		-- FontString
		el = content:CreateFontString("", "OVERLAY", "GameFontHighlight")
		el:SetJustifyH("LEFT")
		kpos = kpos+1 kids[kpos] = el
		anchorPoint(content, el, last, 10+column+indent)
		el:SetText(label)
		last = el
		-- Editbox
		el = CreateFrame("EditBox", "", content, "InputBoxTemplate")
		kpos = kpos+1 kids[kpos] = el
		anchorPoint(content, el, last, 20+column+indent, colwidth or 160, 32, 4)
		el.setting = setting
		el.stype = "EditBox"
		el:SetAutoFocus(false)
		el:SetNumeric(true);
		el.minValue = minVal;
		el.maxValue = maxVal;
		el.Numeric = true;
		self:GetSetting(el)
		el:SetScript("OnEditFocusLost", function() self:ChangeSetting(this) end)
		el:SetScript("OnEscapePressed", kit.Unfocus)
		el:SetScript("OnEnterPressed", kit.Unfocus)
		self.elements[setting] = el
		el.textEl = last
		control = el
		last = el
	elseif (cType == "MoneyFrame" or cType == "MoneyFramePinned") then
		local level, setting, minVal, maxVal, label  = ...
		if (cType == "MoneyFrame") then
			label, minVal, maxVal = minVal, nil, nil
		end
		local indent = 10 * (level or 1)
		-- FontString
		if label then
			el = content:CreateFontString("", "OVERLAY", "GameFontHighlight")
			el:SetJustifyH("LEFT")
			kpos = kpos+1 kids[kpos] = el
			anchorPoint(content, el, last, 10+column+indent)
			el:SetText(label)
			last = el
		end
		-- MoneyFrame
		frameName = lib.CreateAnonName();
		el = CreateFrame("Frame", frameName, content, "MoneyInputFrameTemplate")
		local cur = el
		MoneyInputFrame_SetOnvalueChangedFunc(el, function() self:ChangeSetting(cur) end);
		kpos = kpos+1 kids[kpos] = el
		anchorPoint(content, el, last, 20+column+indent, colwidth or 160, 32, 4)
		el.frameName = frameName;
		el.setting = setting;
		el.stype = cType
		el.clearance = -10
		el.minValue = minVal;
		el.maxValue = maxVal;
		self:GetSetting(el)
		self.elements[setting] = el
		el.textEl = last
		control = el
		last = el
	end

	self:SetLast(id, last)
	return control
end

function kit:GetLast(id)
	if (self.tabs[id] and self.tabs[id][2].ctrls) then
		return self.tabs[id][2].ctrls.last
	end
end

function kit:SetLast(id, last)
	if (self.tabs[id] and self.tabs[id][2].ctrls) then
		self.tabs[id][2].ctrls.last = last
	end
end

function kit:ActivateTab(id)
	id = tonumber(id)
	if not id then id = self.id end

	if not self.tabs then self = self:GetParent() end
	if not self.tabs then
		return error("Must call ActivateTab from a valid nConfigator object")
	end

	if (self.tabs.active) then
		self.tabs[self.tabs.active][2]:Hide()
	end
	self.tabs.active = id
	self.tabs[id][2]:Show()
end

function kit:Refresh()
	for name, el in pairs(self.elements) do
		self:GetSetting(el)
	end
end

function kit:Resave()
	for name, el in pairs(self.elements) do
		self:ChangeSetting(el)
	end
end

function kit:GetSetting(element)
	assert(element, "You must pass a valid element")
	local setting = element.setting
	local value = self.getter(setting)
	if (element.stype == "CheckButton") then
		element:SetChecked(value or false)
	elseif (element.stype == "EditBox") then
		if (element.Numeric) then
			oldvalue = value or 0;
			value = oldvalue;
			if (element.minValue) then
				value = math.max( value, element.minValue );
			end
			if (element.maxValue) then
				value = math.min( value, element.maxValue );
			end
			element:SetNumber(value);
			-- notify that we have pinned the value
			if (value ~= oldvalue) then
				self.setter(setting, value);
			end
		else
			element:SetText(value or "")
		end
	elseif (element.stype == "SelectBox") then
		element.value = value
		element:UpdateValue()
	elseif (element.stype == "Button") then
	elseif (element.stype == "Slider") then
		value = value or 0
		element:SetValue(value)
		if (element.fmtFunc) then
			element.textEl:SetText(string.format(element.textFmt, element.fmtFunc(value)))
		else
			element.textEl:SetText(string.format(element.textFmt, value))
		end
	elseif (element.stype == "MoneyFrame") then
		MoneyInputFrame_ResetMoney(element)
		MoneyInputFrame_SetCopper(element, tonumber(value) or 0);
	elseif (element.stype == "MoneyFramePinned") then
		oldvalue = tonumber(value) or 0;
		value = oldvalue;
		if (element.minValue) then
			value = math.max( value, element.minValue );
		end
		if (element.maxValue) then
			value = math.min( value, element.maxValue );
		end
		MoneyInputFrame_ResetMoney(element)
		MoneyInputFrame_SetCopper( element, value );
		-- update with pinned value
		if (oldvalue ~= value) then
			self.setter(setting, value);
		end
	else
		value = element:GetValue()
	end
end

function kit:ChangeSetting(element, ...)
	assert(element and element.stype, "You must pass a valid element")
	local setting = element.setting
	local value
	if (element.stype == "CheckButton") then
		value = element:GetChecked()
		if (value) then value = true else value = false end
	elseif (element.stype == "EditBox") then
		if (element.Numeric) then
			oldvalue = element:GetNumber() or 0;
			value = oldvalue;
			if (element.minValue) then
				value = math.max( value, element.minValue );
			end
			if (element.maxValue) then
				value = math.min( value, element.maxValue );
			end
			-- update the text field with pinned value
			if (oldvalue ~= value) then
				element:SetNumber(value);
			end
		else
			value = element:GetText() or ""
		end
	elseif (element.stype == "SelectBox") then
		value = select(2, ...)
	elseif (element.stype == "Button") then
		value = true
	elseif (element.stype == "Slider") then
		value = element:GetValue() or 0
		if (element.fmtFunc) then
			element.textEl:SetText(string.format(element.textFmt, element.fmtFunc(value)))
		else
			element.textEl:SetText(string.format(element.textFmt, value))
		end
	elseif (element.stype == "MoneyFrame") then
		value = MoneyInputFrame_GetCopper( element );
	elseif (element.stype == "MoneyFramePinned") then
		oldvalue = MoneyInputFrame_GetCopper( element );
		value = oldvalue;
		if (element.minValue) then
			value = math.max( value, element.minValue );
		end
		if (element.maxValue) then
			value = math.min( value, element.maxValue );
		end
		-- update with pinned value
		if (oldvalue ~= value) then
			MoneyInputFrame_SetCopper( element, value );
		end
	elseif element.GetValue then
		value = element:GetValue()
	else
		return
	end
	self.setter(setting, value)
end

function kit:ColumnCheckboxes(id, cols, options)
	local last, cont, el, setting, text
	last = self:GetLast(id)
	local optc = table.getn(options)
	local rows = math.ceil(optc / cols)
	local row, col = 0, 0
	cont = nil
	for pos, option in ipairs(options) do
		setting, text = unpack(option)
		col = math.floor(row / rows)
		el = self:AddControl(id, "Checkbox", col/cols, 1, setting, text, true, 1/cols)
		row = row + 1
		if (row % rows == 0) then
			if (col == 0) then
				cont = el
			end
			self:SetLast(id, last)
		end
	end
	self:SetLast(id, cont)
end

function kit:SetEscSensitive(setting)
	local name = self:GetName()
	for i = #UISpecialFrames, 1, -1 do
		if (name == UISpecialFrames[i]) then
			table.remove(UISpecialFrames, i)
		end
	end
	if (setting) then
		table.insert(UISpecialFrames[i], name)
	end
end


