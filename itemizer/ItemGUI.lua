--[[
	Itemizer Addon for World of Warcraft(tm).
	Version: <%version%> (<%codename%>)
	Revision: $Id$

	Itemizer GUI
	On-Demand creation of Itemizer's GUI.
	Thanks to Mikk for his Etch-A-Sketch code that generates our GUI On-Demand

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
]]

local paint
local worker
local onLoad
local upOnLoad
local sortTable
local upOnClick
local upOnUpdate
local downOnLoad
local sortOnLoad
local listOnEnter
local listOnClick
local downOnClick
local onMouseWheel
local downOnUpdate
local sortUpOnLoad
local buildItemList
local sortUpOnClick
local rotateTexture
local onValueChanged
local sortDownOnLoad
local sortButtonOnLoad
local sortButtonOnClick
local closeButtonOnLoad
local searchButtonOnLoad

local currentItem = {}
Itemizer_ItemList = {}

local sortList = {
	name = "Name",
	link = "Link",
	level = "Level",
	quality = "Quality",
}

-- Etch-A-Sketch On-Demand GUI building stub. Written by Mikk.
worker = {
	tmp = {},
	ScriptHandlers = "OnLoad OnSizeChanged OnEvent OnUpdate OnShow OnHide OnEnter OnLeave OnMouseDown OnMouseUp OnMouseWheel OnDragStart OnDragStop OnReceiveDrag OnClick OnDoubleClick OnValueChanged OnUpdateModel OnAnimFinished OnEnterPressed OnEscapePressed OnSpacePressed OnTabPressed OnTextChanged OnTextSet OnCursorChanged OnInputLanguageChanged OnEditFocusGained OnEditFocusLost OnHorizontalScroll OnVerticalScroll OnScrollRangeChanged OnChar OnKeyDown OnKeyUp OnColorSelect OnHyperlinkEnter OnHyperlinkLeave OnHyperlinkClick OnMessageScrollChanged OnMovieFinished OnMovieShowSubtitle OnMovieHideSubtitle OnTooltipSetDefaultAnchor OnTooltipCleared OnTooltipAddMoney";
	SaveArgSubsts = function(self)
		local ret = {}
		for tname,t in self.ArgSubsts do
			ret[tname] = {}
			for k,v in t do  ret[tname][k]=v;  end
		end
		return ret;
	end,
	RestoreArgSubsts = function(self, backup)
		self.ArgSubsts = backup;
	end,
	SetButtonTextureHelper = function(self,tx,a1,a2,a3,a4)
		tx = assert(self:CreateTexture());
		assert(tx:SetTexture(a1,a2,a3,a4));
		tx:SetAllPoints(self);
		return tx;
	end,
	Extenders = {
		Region = {
			SetSize = function(self, x,y)
				self:SetWidth(x);
				self:SetHeight(y);
			end
		},
		Slider = {
			SetThumbTextureEx = function(self,a1,a2,a3,a4,a5,a6)
				local tx = assert(self:CreateTexture());
				if(type(a1)=="string") then
					assert(tx:SetTexture(a1));
					tx:SetWidth(a2 or 16);
					tx:SetHeight(a3 or 16);
				else
					assert(tx:SetTexture(a1,a2,a3,a4));
					tx:SetWidth(a5 or 16);
					tx:SetWidth(a6 or 16);
				end
				self:SetThumbTexture(tx);
			end,
		},
		Button = {
			SetHighlightTextureEx = function(self,a1,a2,a3,a4) self:SetHighlightTexture(EASWorker.SetButtonTextureHelper(self,self:GetHighlightTexture(),a1,a2,a3,a4)); end,
			SetDisabledTextureEx = function(self,a1,a2,a3,a4) self:SetDisabledTexture(EASWorker.SetButtonTextureHelper(self,self:GetDisabledTexture(),a1,a2,a3,a4)); end,
			SetNormalTextureEx = function(self,a1,a2,a3,a4) self:SetNormalTexture(EASWorker.SetButtonTextureHelper(self,self:GetNormalTexture(),a1,a2,a3,a4)); end,
			SetPushedTextureEx = function(self,a1,a2,a3,a4) self:SetPushedTexture(EASWorker.SetButtonTextureHelper(self,self:GetPushedTexture(),a1,a2,a3,a4)); end,
		},
		StatusBar = {
			SetStatusBarTextureEx = function(self,a1,a2,a3,a4) self:SetStatusBarTexture(EASWorker.SetButtonTextureHelper(self,self:GetStatusBarTexture(),a1,a2,a3,a4)); end,
		},
		Texture = {
			RotateTexture = function(self, degrees)
				local angle = math.rad(degrees);
				local cos, sin = math.cos(angle), math.sin(angle);
				self:SetTexCoord((sin - cos), -(cos + sin), -cos, -sin, sin, -cos, 0, 0);
			end,
		},
	},
	ErrHandler = function(msg)
		local stk = "  "..debugstack(2, 5, 0);
		stk = string.gsub(stk, "\n%[C%]: in function `xpcall'\n", "\n");
		stk = string.gsub(stk, "\n[^\n]+\n[^\n]+: in function `Pcall'\n", "\n");
		stk = string.gsub(stk, "\n(.)", "\n  %1");
		return msg.."\nCall stack:\n" .. stk;
	end,
	Pcall = function(self,  obj, desc,  func,  ...)
		local b, ret = xpcall(function() return func(unpack(arg)) end, self.ErrHandler);
		if(not b) then
			local msg = tostring(obj.type).." "..tostring(obj.name or "(unnamed)")..", "..desc.. "( ";
			for k=1,getn(arg) do
				if(type(arg[k])=="string") then
					msg = msg .. (k>1 and ", " or "") .. '"' .. arg[k] .. '"';
				else
					msg = msg .. (k>1 and ", " or "") .. tostring(arg[k]);
				end
			end
			tinsert(self.Errors, msg.." )\n"..ret);
		end
		return b,ret;
	end,
	ClearTmp = function(self) for k,_ in pairs(self.tmp) do self.tmp[k]=nil; end end,
	FixArgs = function(self, args)
		self:ClearTmp();
		for k=1,getn(args) do
			self.tmp[k]=self:DoSubsts(args[k]);
		end
		table.setn(self.tmp, table.getn(args));
		return unpack(self.tmp);
	end,
	DoSubsts = function(self, str)
		if(type(str)~="string") then return str; end
		for from,to in pairs(self.ArgSubsts.substr) do
			str = gsub(str, from, to);
		end
		for from,to in pairs(self.ArgSubsts.whole) do
			if(str==from) then
				return to;
			end
		end
		return str;
	end,
	Worker = function(self, collection, root, parent, lastname, WidgetTree)
		local G = getfenv();
		local prevparent = self.ArgSubsts.whole["&parent"];
		for i=1,getn(collection) do
			while(type(collection[i])=="string") do i=i+1; end
			if(i>getn(collection)) then break; end
			local obj = collection[i];
			for count=1,(obj.count or 1) do
				self.ArgSubsts.whole["&parent"] = parent;
				self.ArgSubsts.substr["%$parent"] = lastname;
				self.ArgSubsts.substr["%$count"] = count;
				local widgetname = self:DoSubsts(obj.name);
				local useparent = self:DoSubsts(obj.parent);
				if(type(useparent)=="string") then
					if(useparent=="") then
						useparent=nil;
					else
						useparent = getglobal(useparent);
					end
				end
				useparent = useparent or parent;
				local b,widget;
				local bRegion = (obj.type=="FontString" or obj.type=="Texture");
					if(bRegion) then
						b,widget = self:Pcall(obj, "Create"..obj.type, parent["Create"..obj.type], parent, widgetname, obj.layer, obj.inherits);
						if(not b) then break; end
					else
						b,widget = self:Pcall(obj, "CreateFrame", CreateFrame, obj.type, widgetname, useparent, obj.inherits);
						if(not b) then break; end
						widget:SetID(count);
					end
					if(parent and parent.children and widgetname) then
						parent.children[gsub(widgetname, "^"..(lastname or "#DONT#FIND#").."_?", "")] = widget;
					end
					widget.children = {};
				widget:ClearAllPoints();
				for k,call in ipairs(obj.methods) do
					local func = (self.Extenders[obj.type] and self.Extenders[obj.type][call.f]) or
						(self.Extenders.Region and self.Extenders.Region[call.f]) or
					 	widget[call.f];
					self:Pcall(obj, call.f, func, widget, self:FixArgs(call));
				end
				if(not bRegion) then
					if(obj.children) then
						local backup = self:SaveArgSubsts();
						self:Worker(obj.children,root,widget,widgetname,
							nil
						);
						self:RestoreArgSubsts(backup);
					end
					local onload = nil;
					for scriptname in string.gfind(self.ScriptHandlers, "%w+") do
						if(obj.scripts and obj.scripts[scriptname]) then
							local script = self:DoSubsts(obj.scripts[scriptname]);
							if(type(G[script])=="function") then
								if(scriptname=="OnLoad") then onload = G[script]; end
								self:Pcall(obj, "SetScript", widget.SetScript, widget, scriptname, G[script]);
							else
								local chunkname = obj.type.." "..(widgetname or "(unnamed)").." <"..scriptname..">: " .. script;
								local chunk,msg = loadstring(script, chunkname);
								if(not chunk) then
									tinsert(self.Errors, msg);
								else
									if(scriptname=="OnLoad") then onload = chunk; end
									self:Pcall(obj, "SetScript", widget.SetScript, widget, scriptname, chunk);
								end
							end
						elseif(widgetname and type(G[widgetname.."_"..scriptname])=="function" and widget:HasScript(scriptname)) then
							if(scriptname=="OnLoad") then onload = G[widgetname.."_"..scriptname]; end
							self:Pcall(obj, "SetScript", widget.SetScript, widget, scriptname, G[widgetname.."_"..scriptname]);
						end
					end
					if(onload) then
						this = widget;
						self:Pcall(obj, "<OnLoad>", onload);
					end
				end
				self.ArgSubsts.whole["&prev"] = widget;
				self.ArgSubsts.whole["&prev("..obj.type..")"] = widget;
			end
		end
		self.ArgSubsts["&parent"] = prevparent;
	end,
	Init = function(self, Design)
		self.ArgSubsts = { whole={}, substr={} };
		self.ArgSubsts.substr["$basename"] = Design.BaseName;
		self.Errors = {}
		if(not EtchASketch_Designs) then EtchASketch_Designs = {}; end
		tinsert(EtchASketch_Designs, { Design=Design, WidgetTree=self.WidgetTree, Errors=self.Errors });
		EASWorker = self;
		self:Worker(Design, Design, nil, Design.BaseName, self.WidgetTree);
		EASWorker = nil;
		if(getn(self.Errors)>0) then
			ChatFrame1:AddMessage(Design.BaseName..":"..Design.Description.." contained "..getn(self.Errors).. " errors!", 1, 0.2, 0.2);
			ChatFrame2:AddMessage(Design.BaseName..":"..Design.Description.." contained "..getn(self.Errors).. " errors!", 1, 0.2, 0.2);
			return false, self.Errors;
		end
		return true;
	end
}


function onLoad()
	local result1, errors1 = Itemizer.GUI.Worker:Init(Itemizer.Frames.MainBaseTemplate)
	--local result2, errors2 = Itemizer.GUI.Worker:Init(Itemizer.Frames.SortBaseTemplate)
	local result2, errors2 = Itemizer.Frames.CreateSortFrame()
	Stubby.RegisterFunctionHook("ItemizerBaseGUI.Show", 500, Itemizer.GUI.BuildItemList)

	if (EAS_EditDesign) then
		EAS_EditDesign("Itemizer Item Browsing Window");
	end

	if (result1 and result2) then
		EnhTooltip.DebugPrint("Itemizer: Building of GUI completed successfully")
		ItemizerBaseGUI_Title:SetText("Itemizer v."..Itemizer.Version)
	else
		EnhTooltip.DebugPrint("Itemizer: |cffffffff¡¡¡Building of GUI FAILED!!!|r")
		if (errors1) then
			for index, errorMessage in ipairs(errors1) do
				EnhTooltip.DebugPrint("|cffffffff"..errorMessage.."|r")
			end
		else
			for index, errorMessage in ipairs(errors2) do
				EnhTooltip.DebugPrint("|cffffffff"..errorMessage.."|r")
			end
		end
	end
end

function paint()
	local offset = ItemizerBaseGUI_List_Slider:GetValue()
	if (table.getn(Itemizer_ItemList)>0) then
		for line, index in Itemizer.Util.GetglobalIterator("ItemizerBaseGUI_List_%d") do
			local item = Itemizer_ItemList[offset + index]
			if (item) then
				local red, green, blue = GetItemQualityColor(item.quality)
				line:SetText("["..item.name.."]")
				line:SetTextColor(red, green, blue)
				line:SetID(offset+index)
				line.info = item
				line:Show()
			else
				line:SetTextColor(1, 1, 1)
				line:SetID(index)
				line:SetText("")
				line.info = nil
				line:Hide()
			end
		end
	end
end

function buildItemList()
	Itemizer_ItemList = Itemizer.Util.ClearTable(Itemizer_ItemList)
	if (not (type(itemList) == "table")) then
		Itemizer_ItemList = {}
	end

	for key, value in pairs(ItemizerLinks) do
		for key, item in ipairs(decodeInfo(value, key, currentItem)) do
			table.insert(Itemizer_ItemList, item)
		end
	end

	table.sort(Itemizer_ItemList, sortTable)

	if (table.getn(Itemizer_ItemList) >= 25) then
		ItemizerBaseGUI_List_Slider:SetMinMaxValues(0, table.getn(Itemizer_ItemList) - 25)
	else
		ItemizerBaseGUI_List_Slider:SetMinMaxValues(0, 0)
	end

	ItemizerBaseGUI_List_Slider:SetValue(0)
	ItemizerBaseGUI_NumItems:SetText(Itemizer.Util.DelimitText(table.getn(Itemizer_ItemList), ",", 3).." Items") --%Localize%

	paint()
end

function sortTable(a, b)
	if (a and b) then
		if (a.quality == b.quality) then
			return a.name < b.name
		else
			return a.quality > b.quality
		end
	end
end

function decodeInfo(item, itemID, itemData)
	--itemData = Itemizer.Util.ClearTable(itemData)
	itemData = {}
	--if (not (type(itemData) == "table")) then
	--end
	local itemNameData = Itemizer.Util.Split(item[1] or "", "§")
	local itemBaseData = Itemizer.Util.Split(item[3] or "", "§")
	if (table.getn(itemNameData) > 1) then
		for key, value in ipairs(itemNameData) do
			if (key > 1) then
				table.insert(itemData, { name = (itemNameData[1] or "").." "..(Itemizer.Storage.TranslateRandomProp(value) or ""), quality = (tonumber(itemBaseData[2]) or -1), level = (tonumber(itemBaseData[3]) or 0), link = "item:"..(itemID or 0)..":"..(value or 0)..":0:0" })
			end
		end
	else
		table.insert(itemData, { name = (itemNameData[1] or ""), quality = (tonumber(itemBaseData[2]) or -1), level = (tonumber(itemBaseData[3]) or 0), link = "item:"..(itemID or 0)..":0:0:0" })
	end
	EnhTooltip.DebugPrint(itemData)
	EnhTooltip.DebugPrint("\n\n")
	return itemData
end

function listOnEnter()
	GameTooltip:SetOwner(this, 'ANCHOR_BOTTOMRIGHT', ItemizerBaseGUI_List_Slider:GetWidth() + 2, this:GetHeight())
	if (((this) and (this.info) and (this.info.link)) and (GetItemInfo(this.info.link))) then
		GameTooltip:SetHyperlink(this.info.link)
		EnhTooltip.TooltipCall(GameTooltip, this.info.name, this.info.link, this.info.quality, 1)
	elseif (this and this.info and this.info.link) then
		GameTooltip:SetText("Test Tooltip #"..this:GetID().."\n\nGetItemInfo() returned nil\n\""..this.info.link.."\"\ndoes not exist in the ItemCache")
	else
		GameTooltip:SetText("Test Tooltip #"..this:GetID())
	end
end

function listOnClick()
	EnhTooltip.DebugPrint("Itemizer OnClick called", this:GetName(), this:GetID(), arg1, this:GetText())
	if (IsShiftKeyDown()) then
		if (ChatFrameEditBox:IsVisible()) then
			ChatFrameEditBox:Insert(Itemizer.Util.BuildLink(this.info.link))
		end

	elseif (IsControlKeyDown()) then
		DressUpItemLink(this.info.link)

	elseif (IsAltKeyDown()) then
		if (ChatFrameEditBox:IsVisible()) then
			ChatFrameEditBox:Insert("\""..this.info.link.."\"")
		end
	end
end

function onValueChanged()
	Itemizer.GUI.Paint()
end

function upOnLoad()
	local pushedTexture = this:GetPushedTexture()
	local highlightTexture = this:GetHighlightTexture()

	pushedTexture:ClearAllPoints()
	pushedTexture:SetPoint("TOPLEFT", this, "TOPLEFT", 1, -1)
	pushedTexture:SetPoint("BOTTOMRIGHT", this, "BOTTOMRIGHT", 1, -1)

	highlightTexture:ClearAllPoints()
	highlightTexture:SetVertexColor(1, 1, 1, 0.1)
	highlightTexture:SetAllPoints(ItemizerBaseGUI_List_UpCorner)
end

function upOnClick()
	ItemizerBaseGUI_List_Slider:SetValue(ItemizerBaseGUI_List_Slider:GetValue()-1)
end

function upOnUpdate()
	if (this:GetButtonState() == "PUSHED") then
		Itemizer.GUI.UpOnClick()
	end
end

function downOnLoad()
	local normalTexture = this:GetNormalTexture()
	local pushedTexture = this:GetPushedTexture()
	local highlightTexture = this:GetHighlightTexture()

	rotateTexture(normalTexture, 180)
	rotateTexture(pushedTexture, 180)
	highlightTexture:SetTexCoord(0, 1, 0, 0, 1, 1, 1, 0)

	pushedTexture:ClearAllPoints()
	pushedTexture:SetPoint("TOPLEFT", this, "TOPLEFT", 1, -1)
	pushedTexture:SetPoint("BOTTOMRIGHT", this, "BOTTOMRIGHT", 1, -1)

	highlightTexture:ClearAllPoints()
	highlightTexture:SetVertexColor(1, 1, 1, 0.1)
	highlightTexture:SetAllPoints(ItemizerBaseGUI_List_DownCorner)
end

function downOnClick()
	ItemizerBaseGUI_List_Slider:SetValue(ItemizerBaseGUI_List_Slider:GetValue()+1)
end

function downOnUpdate()
	if (this:GetButtonState() == "PUSHED") then
		Itemizer.GUI.DownOnClick()
	end
end

function onMouseWheel()
	ItemizerBaseGUI_List_Slider:SetValue(ItemizerBaseGUI_List_Slider:GetValue() - 5 * arg1)
end

function closeButtonOnLoad()
	local normalTexture = this:GetNormalTexture()
	local pushedTexture = this:GetPushedTexture()
	local highlightTexture = this:GetHighlightTexture()

	normalTexture:SetVertexColor(1,0,0)
	pushedTexture:SetVertexColor(1,0,0)

	pushedTexture:ClearAllPoints()
	pushedTexture:SetPoint("TOPLEFT", this, "TOPLEFT", 2, -2)
	pushedTexture:SetPoint("BOTTOMRIGHT", this, "BOTTOMRIGHT", 2, -2)

	highlightTexture:ClearAllPoints()
	highlightTexture:SetPoint("TOPRIGHT", this:GetParent(), "TOPRIGHT")
	highlightTexture:SetPoint("BOTTOMLEFT", this:GetParent(), "TOPRIGHT", -32, -32)
end

function sortButtonOnLoad()
	local fontString = this:GetFontString()
	local normalTexture = this:GetNormalTexture()
	local pushedTexture = this:GetPushedTexture()
	local highlightTexture = this:GetHighlightTexture()

	fontString:ClearAllPoints()
	fontString:SetPoint("LEFT", this, "LEFT", 10, 0)

	rotateTexture(normalTexture, 180)
	rotateTexture(pushedTexture, 180)
	rotateTexture(highlightTexture, 180)

	normalTexture:SetVertexColor(0, 0, 0.5, 0.75)
	pushedTexture:SetVertexColor(0, 0, 0.5, 0.75)
	highlightTexture:SetVertexColor(0.6, 0.6, 0.6, 0.1)

	this:SetPushedTextOffset(2, -2)
end

function sortButtonOnClick()
	if (not ItemizerBaseGUI_Sort:IsVisible()) then
		ItemizerBaseGUI_Sort:Show()
	else
		ItemizerBaseGUI_Sort:Hide()
	end
end

function searchButtonOnLoad()
	local fontString = this:GetFontString()
	local normalTexture = this:GetNormalTexture()
	local pushedTexture = this:GetPushedTexture()
	local highlightTexture = this:GetHighlightTexture()

	fontString:ClearAllPoints()
	fontString:SetPoint("RIGHT", this, "RIGHT", -6, 0)

	normalTexture:SetVertexColor(0, 0, 0.5, 0.75)
	pushedTexture:SetVertexColor(0, 0, 0.5, 0.75)
	highlightTexture:SetVertexColor(0.6, 0.6, 0.6, 0.1)

	this:SetPushedTextOffset(2, -2)
end

function sortOnLoad()
	this.List = {}
	for key, value in pairs(sortList) do
		table.insert(this.List, { Key = key, Value = value })
	end

	for line, index in Itemizer.Util.GetglobalIterator(this:GetName().."_FontString_%d") do
		if (this.List[index]) then
			line:SetText(this.List[index]["Value"])
		else
			line:SetTextColor(1, 1, 1, 1)
			line:SetText(nil)
			line:Hide()
		end
	end
	this:Hide()
end

function sortDownOnLoad()
	if (this:GetID() == 13) then
		this:Hide()
	end

	local normalTexture = this:GetNormalTexture()
	local pushedTexture = this:GetPushedTexture()

	pushedTexture:ClearAllPoints()
	pushedTexture:SetPoint("TOPLEFT", this, "TOPLEFT", 1, -1)
	pushedTexture:SetPoint("BOTTOMRIGHT", this, "BOTTOMRIGHT", 1, -1)

	rotateTexture(normalTexture, 180)
	rotateTexture(pushedTexture, 180)
end

function sortDownOnClick()

end

function sortUpOnLoad()
	if (this:GetID() == 1) then
		this:Hide()
	end

	local pushedTexture = this:GetPushedTexture()

	pushedTexture:ClearAllPoints()
	pushedTexture:SetPoint("TOPLEFT", this, "TOPLEFT", 1, -1)
	pushedTexture:SetPoint("BOTTOMRIGHT", this, "BOTTOMRIGHT", 1, -1)

end

function sortUpOnClick()

end

function rotateTexture(texture, degrees)
	local angle = math.rad(degrees);
	local cos, sin = math.cos(angle), math.sin(angle);

	texture:SetTexCoord((sin - cos) , -(cos + sin), -cos, -sin, sin, -cos, 0, 0);
end

Itemizer.GUI = {
	Paint = paint,
	Worker = worker,
	OnLoad = onLoad,
	UpOnLoad = upOnLoad,
	UpOnClick = upOnClick,
	UpOnUpdate = upOnUpdate,
	DownOnLoad = downOnLoad,
	SortOnLoad = sortOnLoad,
	ListOnEnter = listOnEnter,
	ListOnClick = listOnClick,
	DownOnClick = downOnClick,
	SortUpOnLoad = sortUpOnLoad,
	OnMouseWheel = onMouseWheel,
	DownOnUpdate = downOnUpdate,
	SortUpOnClick = sortUpOnClick,
	BuildItemList = buildItemList,
	OnValueChanged = onValueChanged,
	SortDownOnLoad = sortDownOnLoad,
	SortDownOnClick = sortDownOnClick,
	SortButtonOnLoad = sortButtonOnLoad,
	SortButtonOnClick = sortButtonOnClick,
	CloseButtonOnLoad = closeButtonOnLoad,
	SearchButtonOnLoad = searchButtonOnLoad,
}