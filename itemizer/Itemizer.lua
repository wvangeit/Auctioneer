--[[
	Itemizer
	Revision: $Id$
	Version: <%version%> (<%codename%>)
	Original version written by MentalPower.

	This is an addon for World of Warcraft that stores items and their tooltip information
	for later re-linking and review.

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
		since that is it's designated purpose as per:
		http://www.fsf.org/licensing/licenses/gpl-faq.html#InterpreterIncompat
]]

Itemizer.Version="<%version%>";
-- If you want to see debug messages, create a window called "ETTDebug" within the client.
if (Itemizer.Version == "<".."%version%>") then
	Itemizer.Version = "3.9.DEV";
end

local function onLoad()

	Itemizer.Frames.CreateFrames();
	Itemizer.Core.RegisterEvents();

	-- Setup the default for stubby to always load (people can override this on a per toon basis)
	Stubby.SetConfig("Itemizer", "LoadType", "always", true);

	-- Register our temporary command hook with stubby
	Stubby.RegisterBootCode("Itemizer", "CommandHandler", [[
		local function cmdHandler(msg)
			local i,j, cmd, param = string.find(string.lower(msg), "^([^ ]+) (.+)$")
			if (not cmd) then cmd = string.lower(msg) end
			if (not cmd) then cmd = "" end
			if (not param) then param = "" end
			if (cmd == "load") then
				if (param == "") then
					Stubby.Print("Manually loading Itemizer...")
					LoadAddOn("Itemizer")
				elseif (param == "always") then
					Stubby.Print("Setting Itemizer to always load for this character")
					Stubby.SetConfig("Itemizer", "LoadType", param)
					LoadAddOn("Itemizer")
				elseif (param == "never") then
					Stubby.Print("Setting Itemizer to never load automatically for this character (you may still load manually)")
					Stubby.SetConfig("Itemizer", "LoadType", param)
				else
					Stubby.Print("Your command was not understood")
				end
			elseif (cmd == "clear") then
				--Saved Variables
				ItemizerSets = {}
				ItemizerLinks = {}
				ItemizerConfig = {}

				--Global Variables
				ItemizerProcessStack = {}
				Stubby.Print("Itemizer Variables cleared")
				EnhTooltip.DebugPrint("Itemizer Variables cleared")
			elseif (cmd == "show") then
				if (Itemizer and Itemizer.GUI) then
					if (not ItemizerBaseGUI) then
						Itemizer.GUI.OnLoad()
					end
					if (ItemizerBaseGUI:IsVisible()) then
						ItemizerBaseGUI:Hide()
					else
						Itemizer.GUI.BuildItemList()
						ItemizerBaseGUI:Show()
					end
				end
			else
				Stubby.Print("Itemizer is currently not loaded.")
				Stubby.Print("  You may load it now by typing |cffffffff/itemizer load|r")
				Stubby.Print("  You may also set your loading preferences for this character by using the following commands:")
				Stubby.Print("  |cffffffff/itemizer load always|r - Itemizer will always load for this character")
				Stubby.Print("  |cffffffff/itemizer load never|r - Itemizer will never load automatically for this character (you may still load it manually)")
			end
		end
		SLASH_ITEMIZER1 = "/itemizer"
		SLASH_ITEMIZER2 = "/item"
		SLASH_ITEMIZER3 = "/it"
		SlashCmdList["ITEMIZER"] = cmdHandler
	]]);
	Stubby.RegisterBootCode("Itemizer", "Triggers", [[
		local loadType = Stubby.GetConfig("Itemizer", "LoadType")
		if (loadType == "always") then
			LoadAddOn("Itemizer")
		else
			Stubby.Print("]].._ITEM('MesgNotLoaded')..[[");
		end
	]]);
end

Itemizer.OnLoad = onLoad;

Itemizer.OnLoad();