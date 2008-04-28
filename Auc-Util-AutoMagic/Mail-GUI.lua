--[[
	Auctioneer Advanced - AutoMagic Utility module
	Version: <%version%> (<%codename%>)
	Revision: $Id: Auc-Util-AutoMagic.lua 3005 2008-04-05 15:13:13Z RockSlice $
	URL: http://auctioneeraddon.com/
	AutoMagic is an Auctioneer Advanced module.
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

local lib = AucAdvanced.Modules.Util.AutoMagic
local print,decode,recycle,acquire,clone,scrub,get,set,default = AucAdvanced.GetModuleLocals()

---------------------------------------------------------
-- Mail Interface
---------------------------------------------------------
lib.ammailgui = CreateFrame("Frame", "", UIParent); lib.ammailgui:Hide()
function lib.makeMailGUI()
	-- Set frame visuals
	-- [name of frame]:SetPoint("[relative to point on my frame]","[frame we want to be relative to]","[point on relative frame]",-left/+right, -down/+up)	
	lib.ammailgui:ClearAllPoints()	
	lib.ammailgui:SetPoint("CENTER", UIParent, "BOTTOMLEFT", get("util.automagic.ammailguix"), get("util.automagic.ammailguiy"))
	lib.ammailgui:SetFrameStrata("DIALOG")
	lib.ammailgui:SetHeight(90)
	lib.ammailgui:SetWidth(220)
	lib.ammailgui:SetBackdrop({
		bgFile = "Interface/Tooltips/UI-Tooltip-Background",
		edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
		tile = true, tileSize = 32, edgeSize = 32,
		insets = { left = 9, right = 9, top = 9, bottom = 9 }
	})
	lib.ammailgui:SetBackdropColor(0,0,0, 0.8)
	lib.ammailgui:EnableMouse(true)
	lib.ammailgui:SetMovable(true)
	lib.ammailgui:SetClampedToScreen(true)
	
	-- Make highlightable drag bar
	lib.ammailgui.Drag = CreateFrame("Button", "", lib.ammailgui)
	lib.ammailgui.Drag:SetPoint("TOPLEFT", lib.ammailgui, "TOPLEFT", 10,-5)
	lib.ammailgui.Drag:SetPoint("TOPRIGHT", lib.ammailgui, "TOPRIGHT", -10,-5)
	lib.ammailgui.Drag:SetHeight(6)
	lib.ammailgui.Drag:SetHighlightTexture("Interface\\FriendsFrame\\UI-FriendsFrame-HighlightBar")
	lib.ammailgui.Drag:SetScript("OnMouseDown", function() lib.ammailgui:StartMoving() end)
	lib.ammailgui.Drag:SetScript("OnMouseUp", function() lib.ammailgui:StopMovingOrSizing() end)
	
	-- Text Header
	lib.mguiheader = lib.ammailgui:CreateFontString(one, "OVERLAY", "NumberFontNormalYellow")
	lib.mguiheader:SetText("AutoMagic: Mail Loader")
	lib.mguiheader:SetJustifyH("CENTER")
	lib.mguiheader:SetWidth(200)
	lib.mguiheader:SetHeight(10)
	lib.mguiheader:SetPoint("TOPLEFT",  lib.ammailgui, "TOPLEFT", 0, 0)
	lib.mguiheader:SetPoint("TOPRIGHT", lib.ammailgui, "TOPRIGHT", 0, 0)
	lib.ammailgui.mguiheader = lib.mguiheader
	
	-- [name of frame]:SetPoint("[relative to point on my frame]","[frame we want to be relative to]","[point on relative frame]",-left/+right, -down/+up)
	-- LEFT COLUMN
	lib.ammailgui.loadprospect = CreateFrame("Button", "", lib.ammailgui, "OptionsButtonTemplate")
	lib.ammailgui.loadprospect:SetText(("Prospect"))
	lib.ammailgui.loadprospect:SetPoint("BOTTOMLEFT", lib.ammailgui, "BOTTOMLEFT", 12, 35)
	lib.ammailgui.loadprospect:SetScript("OnClick", lib.doMailProspect)	
		
	lib.mguibtmrules = lib.ammailgui:CreateFontString(two, "OVERLAY", "NumberFontNormalYellow")
	lib.mguibtmrules:SetText("BTM Rule:")
	lib.mguibtmrules:SetJustifyH("LEFT")
	lib.mguibtmrules:SetWidth(250)
	lib.mguibtmrules:SetHeight(10)
	lib.mguibtmrules:SetPoint("BOTTOMLEFT",  lib.ammailgui.loadprospect, "TOPLEFT", 0, 0)
	lib.mguibtmrules:SetPoint("BOTTOMRIGHT", lib.ammailgui.loadprospect, "TOPRIGHT", 0, 0)
	lib.ammailgui.mguibtmrules = lib.mguibtmrules
	
	lib.ammailgui.loadde = CreateFrame("Button", "", lib.ammailgui, "OptionsButtonTemplate")
	lib.ammailgui.loadde:SetText(("Disenchant"))
	lib.ammailgui.loadde:SetPoint("BOTTOMLEFT", lib.ammailgui, "BOTTOMLEFT", 12, 12)
	lib.ammailgui.loadde:SetScript("OnClick", lib.doMailDE)
	
	--RIGHT COLUMN
	lib.ammailgui.loadgems = CreateFrame("Button", "", lib.ammailgui, "OptionsButtonTemplate")
	lib.ammailgui.loadgems:SetText(("Gems"))
	lib.ammailgui.loadgems:SetPoint("BOTTOMRIGHT", lib.ammailgui, "BOTTOMRIGHT", -12, 35)
	lib.ammailgui.loadgems:SetScript("OnClick", lib.doMailGems)
	
	lib.mguimailfor = lib.ammailgui:CreateFontString(three, "OVERLAY", "NumberFontNormalYellow")
	lib.mguimailfor:SetText("Other:")
	lib.mguimailfor:SetJustifyH("RIGHT")
	lib.mguimailfor:SetWidth(220)
	lib.mguimailfor:SetHeight(10)
	lib.mguimailfor:SetPoint("BOTTOMLEFT",  lib.ammailgui.loadgems, "TOPLEFT", 0, 0)
	lib.mguimailfor:SetPoint("BOTTOMRIGHT", lib.ammailgui.loadgems, "TOPRIGHT", 0, 0)
	lib.ammailgui.mguimailfor = lib.mguimailfor
	
	lib.ammailgui.loaddemats = CreateFrame("Button", "", lib.ammailgui, "OptionsButtonTemplate")
	lib.ammailgui.loaddemats:SetText(("Chant Mats"))
	lib.ammailgui.loaddemats:SetPoint("BOTTOMRIGHT", lib.ammailgui, "BOTTOMRIGHT", -12, 12)
	lib.ammailgui.loaddemats:SetScript("OnClick", lib.doMailDEMats)
end 