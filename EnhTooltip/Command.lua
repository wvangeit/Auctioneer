--[[
	EnhTooltip - Additional function hooks to allow hooks into more tooltips
	Version: <%version%> (<%codename%>)
	Revision: $Id$
	URL: http://auctioneeraddon.com/dl/EnhTooltip

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

EnhTooltip.Config = {}
local lib = EnhTooltip.Config
local private = {}

private.Print = function(...)
	local output, part
	for i=1, select("#", ...) do
		part = select(i, ...)
		part = tostring(part):gsub("{{", "|cffddeeff"):gsub("}}", "|r")
		if (output) then output = output .. " " .. part
		else output = part end
	end
	DEFAULT_CHAT_FRAME:AddMessage(output, 0.3, 0.9, 0.8)
end

function private.CommandHandler(command, subcommand, ...)
	command = command:lower()
	if (command == "help") then
		private.Print("Auctioneer Advanced Help")
		private.Print("  {{/ett help}} - Show this help")
		private.Print("  {{/ett on||off}} - Show or hide enhanced tooltip")
		private.Print("  {{/auc force alt||shift||ctrl||off}} - Force showing enhanced tooltip, when a key pressed")
	elseif command == "on" then
		EnhTooltip.SetSuppressEnhancedTooltip(false)
		private.Print("Enhanced tooltips are now on")
	elseif command == "off" then
		EnhTooltip.SetSuppressEnhancedTooltip(true)
		private.Print("Enhanced tooltips are now off")
	elseif command == "force" then
		EnhTooltip.SetForceTooltipKey(subcommand)
		if (subcommand == "shift") or (subcommand == "alt") or (subcommand == "ctrl") then
			private.Print("Enhanced tooltips are forced with ".. subcommand.." key")
		else
			private.Print("Enhanced tooltips are not forced")
		end
	else
		-- No match found
		private.Print("Unable to find command: "..command)
		private.Print("Type {{/ett help}} for help")
	end
	if EnhTooltip.Gui then
		EnhTooltip.Gui:Refresh()
	end
end


SLASH_ENHTOOLTIP1 = "/ett"
SLASH_ENHTOOLTIP2 = "/enhtooltip"
SlashCmdList["ENHTOOLTIP"] = function(msg) private.CommandHandler(strsplit(" ", msg)) end

