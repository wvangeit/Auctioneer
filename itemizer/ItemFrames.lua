--[[
	Itemizer Addon for World of Warcraft(tm).
	Version: <%version%> (<%codename%>)
	Revision: $Id$

	Itemizer frames and frame creation functions.
	Frame creation and managing functions.

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

local createFrames
local mainBaseTemplate
local sortBaseTemplate

--Global Frame Names
ItemizerTooltip = nil;
ItemizerHidden = nil;

function createFrames()
	if (Itemizer.Frames.MainFrame) then
		return
	end

	Itemizer.Frames.MainFrame = CreateFrame("Frame");
	Itemizer.Frames.MainFrame:SetScript("OnEvent", Itemizer.Core.OnEvent);
	Itemizer.Frames.MainFrame:SetScript("OnUpdate", function() return Itemizer.Scanner.OnUpdate(arg1) end);
	Itemizer.Frames.MainFrame:Show();

	ItemizerTooltip = CreateFrame("GameTooltip", "ItemizerTooltip", UIParent, "GameTooltipTemplate");
	ItemizerHidden = CreateFrame("GameTooltip", "ItemizerHidden", UIParent, "GameTooltipTemplate");
	ItemizerHidden:Show();
	ItemizerHidden:SetOwner(this, "ANCHOR_NONE");
	ItemizerHidden:Show();
end

mainBaseTemplate = {
	BaseName = "ItemizerBaseGUI",
	Description = "Itemizer Item Browsing Window",

	"Main Itemizer Frame",
	{
		type="Frame",
		name="$parent",
		parent="UIParent",
		methods = {
			{ f="Hide" },
			{ f="SetToplevel", true },
			{ f="SetSize", 384, 512 },
			{ f="SetFrameStrata", "MEDIUM" },
			{ f="SetPoint", "TOPLEFT", 100, -104 },
		},
		children = {
			{
				type="Texture", --Main Texture (Dark Blue)
				methods = {
					{ f="SetTexture", 0, 0, 0.5, 0.75 },
					{ f="SetDrawLayer", "BACKGROUND" },
					{ f="SetPoint", "TOPLEFT", "&parent", "TOPLEFT", 0, -67 },
					{ f="SetPoint", "BOTTOMRIGHT", "&parent", "BOTTOMRIGHT", -20, 0 },
				}
			},
			{
				type="Texture", --TopLeft corner texture (70% Gray Round Corner)
				methods = {
					{ f="SetWidth", 32 },
					{ f="SetHeight", 32 },
					{ f="SetDrawLayer", "BACKGROUND" },
					{ f="SetVertexColor", 0.7, 0.7, 0.7, 0.8 },
					{ f="SetPoint", "TOPLEFT", "&parent", "TOPLEFT", 0, 0 },
					{ f="SetTexture", "Interface\\AddOns\\Itemizer\\Art\\RoundCorner" },
				}
			},
			{
				type="Texture", --Header Texture (70% Gray)
				methods = {
					{ f="SetHeight", 35 },
					{ f="SetTexture", 0.7, 0.7, 0.7, 0.8 },
					{ f="SetDrawLayer", "BACKGROUND" },
					{ f="SetPoint", "TOPLEFT", "&parent", "TOPLEFT", 32, 0 },
					{ f="SetPoint", "TOPRIGHT", "&parent", "TOPRIGHT", 0, 0 },
				}
			},
			{
				type="Texture", --Secondary Header Texture (70% Gray)
				methods = {
					{ f="SetHeight", 32 },
					{ f="SetTexture", 0.7, 0.7, 0.7, 0.8 },
					{ f="SetDrawLayer", "BACKGROUND" },
					{ f="SetPoint", "TOPLEFT", "&parent", "TOPLEFT", 0, -35 },
					{ f="SetPoint", "TOPRIGHT", "&parent", "TOPRIGHT", -20, -35 },
				}
			},
			{
				type="Texture", --Separator (Black)
				methods = {
					{ f="SetHeight", 3 },
					{ f="SetTexture", 0, 0, 0, 0.8 },
					{ f="SetDrawLayer", "ARTWORK" },
					{ f="SetPoint", "TOPLEFT", "&parent", "TOPLEFT", 0, -32 },
					{ f="SetPoint", "TOPRIGHT", "&parent", "TOPRIGHT", 0, -32 },
				}
			},
			{
				type="FontString",
				name="$parent_Title",
				inherits="GameFontNormalHuge",
				methods = {
					{ f="SetHeight", 30 },
					{ f="SetJustifyV", "CENTER" },
					{ f="SetJustifyH", "CENTER" },
					{ f="SetText", "Itemizer Items" },
					{ f="SetPoint", "TOPLEFT", "&parent", "TOPLEFT", 0, 0 },
					{ f="SetPoint", "TOPRIGHT", "&parent", "TOPRIGHT", 0, 0 },
				}
			},
			{
				type="FontString",
				name="$parent_NumItems",
				inherits="GameFontNormalLarge",
				methods = {
					{ f="SetHeight", 30 },
					{ f="SetJustifyV", "CENTER" },
					{ f="SetJustifyH", "CENTER" },
					{ f="SetText", "# of Items" },
					{ f="SetPoint", "TOPLEFT", "&parent", "TOPLEFT", 0, -32 },
					{ f="SetPoint", "TOPRIGHT", "&parent", "TOPRIGHT", 0, -32 },
				}
			},
			{
				type="Button",
				name="$parent_SortButton",
				scripts = {
					OnLoad = "return Itemizer.GUI.SortButtonOnLoad()",
					OnClick = "return Itemizer.GUI.SortButtonOnClick()",
				},
				methods = {
					{ f="SetText", "Sort" },
					{ f="SetSize", 64, 32 },
					{ f="SetTextFontObject", "GameFontNormalLarge" },
					{ f="SetPoint", "TOPLEFT", "&parent", "TOPLEFT", 0, -35 },
					{ f="SetNormalTexture", "Interface\\AddOns\\Itemizer\\Art\\RoundedButton" },
					{ f="SetPushedTexture", "Interface\\AddOns\\Itemizer\\Art\\RoundedButton" },
					{ f="SetHighlightTextureEx", "Interface\\AddOns\\Itemizer\\Art\\RoundedButton" },
				},
			},
			{
				type="Button",
				name="$parent_SearchButton",
				scripts = {
					OnLoad = "return Itemizer.GUI.SearchButtonOnLoad()",
					OnClick = "return Itemizer.GUI.SearchButtonOnClick()",
				},
				methods = {
					{ f="SetSize", 80, 32 },
					{ f="SetText", "Search" },
					{ f="SetTextFontObject", "GameFontNormalLarge" },
					{ f="SetPoint", "TOPRIGHT", "&parent", "TOPRIGHT", -20, -35 },
					{ f="SetNormalTexture", "Interface\\AddOns\\Itemizer\\Art\\RoundedButton" },
					{ f="SetPushedTexture", "Interface\\AddOns\\Itemizer\\Art\\RoundedButton" },
					{ f="SetHighlightTextureEx", "Interface\\AddOns\\Itemizer\\Art\\RoundedButton" },
				},
			},
			{
				type="Button",
				name="$parent_CloseButton",
				scripts = {
					OnClick = "return this:GetParent():Hide()",
					OnLoad = "return Itemizer.GUI.CloseButtonOnLoad()",
				},
				methods = {
					{ f="SetSize", 20, 20 },
					{ f="SetHighlightTextureEx", 0.4,0.4,0.5,0.5 },
					{ f="SetPoint", "TOPRIGHT", "&parent", "TOPRIGHT", -5, -5 },
					{ f="SetNormalTexture", "Interface\\AddOns\\Itemizer\\Art\\CloseButton" },
					{ f="SetPushedTexture", "Interface\\AddOns\\Itemizer\\Art\\CloseButton" },
				},
			},
			{
				type="Frame",
				name="$parent_List",
				scripts = {
					OnMouseWheel = "return Itemizer.GUI.OnMouseWheel()",
				},
				methods = {
					{ f="EnableMouseWheel", true },
					{ f="SetPoint", "LEFT", "&parent", "LEFT", 0, 0 },
					{ f="SetPoint", "TOP", "&parent", "TOP", 0, -35 },
					{ f="SetPoint", "RIGHT", "&parent", "RIGHT", 0, 0 },
					{ f="SetPoint", "BOTTOM", "&parent", "BOTTOM", 0, 0 },
				},
				children = {
					{
						type="Texture",
						methods = {
							{ f="SetWidth", 20 },
							{ f="SetTexture", 0.7, 0.7, 0.7, 0.8 },
							{ f="SetPoint", "TOPRIGHT", "&parent", "TOPRIGHT", 0, -32 },
							{ f="SetPoint", "BOTTOMRIGHT", "&parent", "BOTTOMRIGHT", 0, 32 },
						},
					},
					{
						type="Texture",
						name="$parent_SliderTex",
						methods = {
							{ f="SetAllPoints", "&prev" },
							{ f="SetTexture", 0.15, 0.15, 0.5, 0.75 },
						},
					},
					{
						type="Texture",
						methods = {
							{ f="SetSize", 20, 32 },
							{ f="SetDrawLayer", "BACKGROUND" },
							{ f="SetVertexColor", 0.7, 0.7, 0.7, 0.8 },
							{ f="SetPoint", "TOPRIGHT", "&parent", "TOPRIGHT", 0, 0 },
							{ f="SetTexture", "Interface\\AddOns\\Itemizer\\Art\\TallRoundCorner" },
						},
					},
					{
						type="Texture",
						name="$parent_UpCorner",
						methods = {
							{ f="SetAllPoints", "&prev" },
							{ f="SetDrawLayer", "ARTWORK" },
							{ f="SetVertexColor", 0, 0, 0.5, 0.75 },
							{ f="SetTexture", "Interface\\AddOns\\Itemizer\\Art\\TallRoundCorner" },
						},
					},
					{
						type="Button",
						name="$parent_Up",
						scripts = {
							OnClick = "return Itemizer.GUI.UpOnClick()",
							OnLoad = "return Itemizer.GUI.UpOnLoad()",
							OnUpdate = "return Itemizer.GUI.UpOnUpdate()",
						},
						methods = {
							{ f="SetSize", 20, 20 },
							{ f="SetPoint", "TOPRIGHT", "&parent", "TOPRIGHT", 0, -7 },
							{ f="SetNormalTexture", "Interface\\AddOns\\Itemizer\\Art\\UpDownButton" },
							{ f="SetPushedTexture", "Interface\\AddOns\\Itemizer\\Art\\UpDownButton" },
							{ f="SetHighlightTextureEx", "Interface\\AddOns\\Itemizer\\Art\\TallRoundCorner" },
						}
					},
					{
						type="Texture",
						methods = {
							{ f="SetSize", 20, 32 },
							{ f="SetDrawLayer", "BACKGROUND" },
							{ f="SetVertexColor", 0.7, 0.7, 0.7, 0.8 },
							{ f="SetTexCoord", 0, 1, 0, 0, 1, 1, 1, 0 },
							{ f="SetPoint", "BOTTOMRIGHT", "&parent", "BOTTOMRIGHT", 0, 0 },
							{ f="SetTexture", "Interface\\AddOns\\Itemizer\\Art\\TallRoundCorner" },
						},
					},
					{
						type="Texture",
						name="$parent_DownCorner",
						methods = {
							{ f="SetAllPoints", "&prev" },
							{ f="SetDrawLayer", "ARTWORK" },
							{ f="SetVertexColor", 0, 0, 0.5, 0.75 },
							{ f="SetTexCoord", 0, 1, 0, 0, 1, 1, 1, 0 },
							{ f="SetTexture", "Interface\\AddOns\\Itemizer\\Art\\TallRoundCorner" },
						},
					},
					{
						type="Button",
						name="$parent_Down",
						scripts = {
							OnLoad = "return Itemizer.GUI.DownOnLoad()",
							OnClick = "return Itemizer.GUI.DownOnClick()",
							OnUpdate = "return Itemizer.GUI.DownOnUpdate()",
						},
						methods = {
							{ f="SetSize", 20, 20 },
							{ f="SetPoint", "BOTTOMRIGHT", "&parent", "BOTTOMRIGHT", 0, 7 },
							{ f="SetNormalTexture", "Interface\\AddOns\\Itemizer\\Art\\UpDownButton" },
							{ f="SetPushedTexture", "Interface\\AddOns\\Itemizer\\Art\\UpDownButton" },
							{ f="SetHighlightTextureEx", "Interface\\AddOns\\Itemizer\\Art\\TallRoundCorner" },
						}
					},
					{
						type="Slider",
						name="$parent_Slider",
						scripts = {
							OnValueChanged = "return Itemizer.GUI.OnValueChanged()",
						},
						methods= {
							{ f="SetThumbTextureEx", "Interface\\AddOns\\Itemizer\\Art\\Slider", 20, 20 },
							{ f="SetAllPoints", "$parent_SliderTex" },
							{ f="SetOrientation", "VERTICAL" },
 							{ f="SetMinMaxValues", 0, 0 },
							{ f="SetValueStep", 1 },
							{ f="SetValue", 0 },
						},
					},
					{
						type="Frame",
						name="$parent_Anchor",
						methods = {
							{ f="SetHeight", 37 },
							{ f="SetPoint", "TOPLEFT", "&parent", "TOPLEFT", 2, -2 },
							{ f="SetPoint", "TOPRIGHT", "$parent_Up", "TOPLEFT", -2, -2 },
						}
					},
					{
						type="Button",
						name="$parent_$count",
						count=25,
						scripts = {
							OnLeave = "return GameTooltip:Hide()",
							OnClick = "return Itemizer.GUI.ListOnClick()",
							OnEnter = "return Itemizer.GUI.ListOnEnter()",
						},
						methods = {
							{ f="SetHeight", 17 },
							{ f="SetID", "$count" },
							{ f="SetHighlightTextureEx", 0.4,0.4,0.5,0.5 },
							{ f="SetTextFontObject", "GameTooltipHeaderText" },
							{ f="SetPoint", "TOPLEFT", "&prev", "BOTTOMLEFT", 0, 0 },
							{ f="RegisterForClicks", "LeftButtonUp", "RightButtonUp" },
							{ f="SetPoint", "RIGHT", "$parent_Anchor", "RIGHT", 0, 0 },
						},
					},
				},
			},
		},
	},

	"Itemizer Sort Frame",
	{
		type="Frame",
		name="$parent_Sort",
		parent="ItemizerBaseGUI",
		methods = {
			{ f="SetToplevel", true },
			{ f="SetSize", 192, 256 },
			{ f="EnableMouse", true },
			{ f="SetFrameStrata", "HIGH" },
			{ f="SetPoint", "TOPLEFT", "ItemizerBaseGUI_SortButton", "BOTTOMRIGHT", -5, 5 },
			--[[
			{ f="SetBackdrop",
				{
					tile = true,
					tileSize = 64,
					edgeSize = 64,
					edgeFile = "Interface\\AddOns\\Itemizer\\Art\\ItemizerTooltipBorder",
					bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
					insets = {
						top = 8,
						left = 8,
						right = 8,
						bottom = 8,
					},
				},
			},
			{ f="SetBackdropColor", 0.1, 0.1, 0.5, 0.75 },
			]]
			{ f="Hide" },
		},
		children = {
			{
				type="Texture",
				methods = {
					{ f="SetAllPoints", "&parent" },
					{ f="SetTexture", 0.1, 0.1, 0.5, 0.75 },
				},
			},
			{
				type="Frame",
				name="$parent_Anchor",
				methods = {
					{ f="SetHeight", 3 },
					{ f="SetPoint", "TOPLEFT", "&parent", "TOPLEFT", 10, -12 },
					{ f="SetPoint", "TOPRIGHT", "$parent", "TOPRIGHT", -10, -12 },
				},
			},
			{
				type="FontString",
				name="$parent_FontString_$count",
				count=12,
				methods = {
					{ f="SetHeight", 19 },
					{ f="SetFontObject", "GameTooltipHeaderText" },
					{ f="SetPoint", "TOPLEFT", "&prev", "BOTTOMLEFT", 0, 0 },
					{ f="SetPoint", "RIGHT", "$parent_Anchor", "RIGHT", 0, 0 },
					{ f="SetText", "FontString #$count" },
				},
			},
			{
				type="Button",
				name="$parent_UpButton_$count",
				count=12,
				scripts = {
					OnLoad = "return Itemizer.GUI.SortUpOnLoad()",
					OnClick = "return Itemizer.GUI.SortUpOnClick()",
				},
				methods = {
					{ f="SetSize", 16, 16 },
					{ f="SetID", "$count" },
					{ f="SetPoint", "RIGHT", "$parent_FontString_$count", "RIGHT", -16, 0 },
					{ f="SetNormalTexture", "Interface\\AddOns\\Itemizer\\Art\\UpDownButton" },
					{ f="SetPushedTexture", "Interface\\AddOns\\Itemizer\\Art\\UpDownButton" },
					{ f="SetHighlightTextureEx", 0.4,0.4,0.5,0.5 },
				},
			},
			{
				type="Button",
				name="$parent_DownButton_$count",
				count=12,
				scripts = {
					OnLoad = "return Itemizer.GUI.SortDownOnLoad()",
					OnClick = "return Itemizer.GUI.SortDownOnClick()",
				},
				methods = {
					{ f="SetSize", 16, 16 },
					{ f="SetID", "$count" },
					{ f="SetPoint", "RIGHT", "$parent_FontString_$count", "RIGHT", 0, 0 },
					{ f="SetNormalTexture", "Interface\\AddOns\\Itemizer\\Art\\UpDownButton" },
					{ f="SetPushedTexture", "Interface\\AddOns\\Itemizer\\Art\\UpDownButton" },
					{ f="SetHighlightTextureEx", 0.4,0.4,0.5,0.5 },
				},
			},
		},
	},

--[[
	"Itemizer Test Art Frame",
	{
		type="Frame",
		name="ItemizerArt",
		methods = {
			{ f="SetSize", 512, 512 },
			{ f="SetPoint", "CENTER", UIParent, "CENTER" },
			{ f="Hide" },
		},
		children = {
			{
				type="Texture",
				name="$parentTex",
				methods = {
					{ f="SetAllPoints", "$parent" },
					--{ f="SetTexCoord", 0, 1, 0, 0, 1, 1, 1, 0 },
					{ f="SetTexture", "Interface\\Glues\\LoadingScreens\\LoadScreenUldaman" },
				},
			},
		},
	},
]]
}

mainSeachTemplate = {
	BaseName = "ItemizerSearchGUI",
	Description = "Itemizer Item Browsing Window",

	"Itemizer Search Frame",
	{
		type="Frame",
		name="$parent",
		parent="UIParent",
		methods = {
			{ f="Hide" },
			{ f="SetToplevel", true },
			{ f="SetSize", 384, 512 },
			{ f="SetFrameStrata", "MEDIUM" },
			{ f="SetPoint", "TOPLEFT", "ItemizerBaseGUI", "TOPLEFT", 400, 0 },
		},
		children = {
			{
				type="Texture", --Main Texture (Dark Blue)
				methods = {
					{ f="SetDrawLayer", "BACKGROUND" },
					{ f="SetTexture", 0, 0, 0.5, 0.75 },
					{ f="SetPoint", "TOPLEFT", "&parent", "TOPLEFT", 0, -67 },
					{ f="SetPoint", "BOTTOMRIGHT", "&parent", "BOTTOMRIGHT", -32, 0 },
				}
			},
			{
				type="Texture", --TopLeft corner texture (70% Gray Round Corner)
				methods = {
					{ f="SetWidth", 32 },
					{ f="SetHeight", 32 },
					{ f="SetDrawLayer", "BACKGROUND" },
					{ f="SetVertexColor", 0.7, 0.7, 0.7, 0.8 },
					{ f="SetPoint", "TOPLEFT", "&parent", "TOPLEFT", 0, 0 },
					{ f="SetTexture", "Interface\\AddOns\\Itemizer\\Art\\RoundCorner" },
				}
			},
			{
				type="Texture", --Header Texture (70% Gray)
				methods = {
					{ f="SetHeight", 35 },
					{ f="SetTexture", 0.7, 0.7, 0.7, 0.8 },
					{ f="SetDrawLayer", "BACKGROUND" },
					{ f="SetPoint", "TOPLEFT", "&parent", "TOPLEFT", 32, 0 },
					{ f="SetPoint", "TOPRIGHT", "&parent", "TOPRIGHT", 0, 0 },
				}
			},
			{
				type="Texture", --Secondary Header Texture (70% Gray)
				methods = {
					{ f="SetHeight", 32 },
					{ f="SetTexture", 0.7, 0.7, 0.7, 0.8 },
					{ f="SetDrawLayer", "BACKGROUND" },
					{ f="SetPoint", "TOPLEFT", "&parent", "TOPLEFT", 0, -35 },
					{ f="SetPoint", "TOPRIGHT", "&parent", "TOPRIGHT", 0, -35 },
				}
			},
			{
				type="Texture", --Separator (Black)
				methods = {
					{ f="SetHeight", 3 },
					{ f="SetTexture", 0, 0, 0, 0.8 },
					{ f="SetDrawLayer", "ARTWORK" },
					{ f="SetPoint", "TOPLEFT", "&parent", "TOPLEFT", 0, -32 },
					{ f="SetPoint", "TOPRIGHT", "&parent", "TOPRIGHT", 0, -32 },
				}
			},
			{
				type="Texture", --Right Texture (Dark Blue)
				methods = {
					{ f="SetWidth", 32 },
					{ f="SetDrawLayer", "BACKGROUND" },
					{ f="SetTexture", 0, 0, 0.5, 0.75 },
					{ f="SetPoint", "TOPRIGHT", "&parent", "TOPRIGHT", 0, -64 },
					{ f="SetPoint", "BOTTOMRIGHT", "&parent", "BOTTOMRIGHT", 0, 32 },
				}
			},
			{
				type="Texture", --BottomRight corner texture (Dark Blue)
				methods = {
					{ f="SetWidth", 32 },
					{ f="SetHeight", 32 },
					{ f="RotateTexture", 180 },
					{ f="SetDrawLayer", "BACKGROUND" },
					{ f="SetVertexColor", 0, 0, 0.5, 0.75 },
					{ f="SetPoint", "BOTTOMRIGHT", "&parent", "BOTTOMRIGHT", 0, 0 },
					{ f="SetTexture", "Interface\\AddOns\\Itemizer\\Art\\RoundCorner" },
				}
			},
			{
				type="FontString",
				name="$parent_Title",
				inherits="GameFontNormalHuge",
				methods = {
					{ f="SetHeight", 30 },
					{ f="SetJustifyV", "CENTER" },
					{ f="SetJustifyH", "CENTER" },
					{ f="SetText", "Itemizer Search" },
					{ f="SetPoint", "TOPLEFT", "&parent", "TOPLEFT", 0, 0 },
					{ f="SetPoint", "TOPRIGHT", "&parent", "TOPRIGHT", 0, 0 },
				}
			},
			{
				type="FontString",
				name="$parent_NumItems",
				inherits="GameFontNormalLarge",
				methods = {
					{ f="SetHeight", 30 },
					{ f="SetJustifyV", "CENTER" },
					{ f="SetJustifyH", "CENTER" },
					{ f="SetText", "# of Items" },
					{ f="SetPoint", "TOPLEFT", "&parent", "TOPLEFT", 0, -32 },
					{ f="SetPoint", "TOPRIGHT", "&parent", "TOPRIGHT", 0, -32 },
				}
			},
			{
				type="Button",
				name="$parent_ClearButton",
				scripts = {
					OnLoad = "return Itemizer.GUI.ClearButtonOnLoad()",
					OnClick = "return Itemizer.GUI.ClearButtonOnClick()",
				},
				methods = {
					{ f="SetText", "Clear" },
					{ f="SetSize", 64, 32 },
					{ f="SetTextFontObject", "GameFontNormalLarge" },
					{ f="SetPoint", "TOPLEFT", "&parent", "TOPLEFT", 64, -35 },
					{ f="SetNormalTexture", "Interface\\AddOns\\Itemizer\\Art\\RoundedButton" },
					{ f="SetPushedTexture", "Interface\\AddOns\\Itemizer\\Art\\RoundedButton" },
					{ f="SetHighlightTextureEx", "Interface\\AddOns\\Itemizer\\Art\\RoundedButton" },
				},
			},
			{
				type="Button",
				name="$parent_ClearButton2",
				scripts = {
					--OnLoad = "return Itemizer.GUI.ClearButtonOnLoad()",
					OnClick = "return Itemizer.GUI.ClearButtonOnClick()",
				},
				methods = {
					{ f="SetText", "Clear" },
					{ f="SetSize", 64, 32 },
					{ f="SetTextFontObject", "GameFontNormalLarge" },
					{ f="SetPoint", "RIGHT", "&prev", "LEFT", 0, 0 },
					{ f="SetNormalTextureEx", 0, 0, 0.5, 0.75 },
					{ f="SetPushedTextureEx", 0, 0, 0.5, 0.75 },
					{ f="SetHighlightTextureEx", 0.6, 0.6, 0.6, 0.1 },
				},
			},
			{
				type="Button",
				name="$parent_SearchButton",
				scripts = {
					OnLoad = "return Itemizer.GUI.SearchItemsButtonOnLoad()",
				},
				methods = {
					{ f="SetSize", 80, 32 },
					{ f="SetText", "Search" },
					{ f="SetTextFontObject", "GameFontNormalLarge" },
					{ f="SetPoint", "TOPRIGHT", "&parent", "TOPRIGHT", 0, -35 },
					{ f="SetNormalTexture", "Interface\\AddOns\\Itemizer\\Art\\RoundedButton" },
					{ f="SetPushedTexture", "Interface\\AddOns\\Itemizer\\Art\\RoundedButton" },
					{ f="SetHighlightTextureEx", "Interface\\AddOns\\Itemizer\\Art\\RoundedButton" },
				},
			},
			{
				type="Button",
				name="$parent_CloseButton",
				scripts = {
					OnClick = "return this:GetParent():Hide()",
					OnLoad = "return Itemizer.GUI.CloseButtonOnLoad()",
				},
				methods = {
					{ f="SetSize", 20, 20 },
					{ f="SetHighlightTextureEx", 0.4,0.4,0.5,0.5 },
					{ f="SetPoint", "TOPRIGHT", "&parent", "TOPRIGHT", -5, -5 },
					{ f="SetNormalTexture", "Interface\\AddOns\\Itemizer\\Art\\CloseButton" },
					{ f="SetPushedTexture", "Interface\\AddOns\\Itemizer\\Art\\CloseButton" },
				},
			},
		},
	},
}

Itemizer.Frames = {
	CreateFrames = createFrames,
	MainBaseTemplate = mainBaseTemplate,
	MainSeachTemplate = mainSeachTemplate,
}