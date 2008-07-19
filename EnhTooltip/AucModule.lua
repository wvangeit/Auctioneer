--[[
	EnhTooltip - Additional function hooks to allow hooks into more tooltips
	Version: <%version%> (<%codename%>)
	Revision: $Id$
	URL: http://auctioneeraddon.com/dl/EnhTooltip

	AucModule functions

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

if not EnhTooltip then 
	EnhTooltip = {}
end
local private = {}

local libType, libName = "Util", "EnhTooltip"


function private.enhancedTooltipSuppress(action, value)
	if action == "getsetting" then
		return EnhTooltip.SetSuppressEnhancedTooltip()
	end
	if action == "set" then
		EnhTooltip.SetSuppressEnhancedTooltip(value)
	end
end

function private.enhancedTooltipForceShow(action, value)
	if action == "getsetting" then
		return EnhTooltip.SetForceTooltipKey() == "alt"
	end
	if action == "set" then
		if value then
			EnhTooltip.SetForceTooltipKey("alt")
		else
			EnhTooltip.SetForceTooltipKey("off")
		end
	end
end


function private.SetupConfigGui(gui)
	EnhTooltip.Gui = gui
	local id = gui:AddTab(libName,"Core Options")

	gui:AddControl(id, "Checkbox", 0, 1, private.enhancedTooltipSuppress, "Hide enhanced tooltip")
	gui:AddTip(id, "Disables Auctioneer enhanced tooltip")

	gui:AddControl(id, "Checkbox", 0, 2, private.enhancedTooltipForceShow, "Show enhanced tooltip if Alt is pressed")
	gui:AddTip(id, "Shows Auctioneer enhanced tooltip when the Alt button is pressed")
end

function private.Processor(callbackType, ...)
	if (callbackType == "config") then
		--Called when you should build your Configator tab.
		private.SetupConfigGui(...)
	end
end

function private.WireUpConfigurator()
	if not AucAdvanced then return end
	local lib = AucAdvanced.NewModule(libType, libName)
	if not lib then return end
	lib.Processor = private.Processor
end

EnhTooltip.WireUpConfigurator = private.WireUpConfigurator