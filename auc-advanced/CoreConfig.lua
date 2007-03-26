--[[
	Auctioneer Advanced
	Revision: $Id$
	Version: <%version%> (<%codename%>)

	This is an addon for World of Warcraft that adds statistical history to the auction data that is collected
	when the auction is scanned, so that you can easily determine what price
	you will be able to sell an item for at auction or at a vendor whenever you
	mouse-over an item in the game

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

AucAdvanced.Config = {}
local lib = AucAdvanced.Config
lib.Print = AucAdvanced.Print

function lib.CommandHandler(command, ...)
	command = command:lower()
	if (command == "help") then
		lib.Print("Auctioneer Advanced Help")
		lib.Print("  {{/auc help}} - Show this help")
		lib.Print("  {{/auc begin [catid]}} - Scan the auction house (optional catid)")
		for system, systemMods in pairs(AucAdvanced.Modules) do
			for engine, engineLib in pairs(systemMods) do
				if (engineLib.CommandHandler) then
					lib.Print("  {{/auc "..system:lower().." "..engine:lower().." help}} - Show "..engineLib.GetName().." "..system.." help")
				end
			end
		end
	elseif command == "begin" then
		lib.ScanCommand(...)
	else
		local sys, eng = strsplit(" ", command)
		if sys and eng then
			for system, systemMods in pairs(AucAdvanced.Modules) do
				if sys == system:lower() then
					for engine, engineLib in pairs(systemMods) do
						if command == engine:lower() then
							if engineLib.CommandHandler then
								if not engineLib.Print then
									engineLib.Print = lib.Print
								end
								engineLib.CommandHandler(...)
								return
							end
						end
					end
				end
			end
		end

		-- No match found
		lib.Print("Unable to find command: "..command)
		lib.Print("Type {{/auc help}} for help")
	end
end

function lib.ScanCommand(cat)
	if cat then cat = tonumber(cat) end
	if cat then
		local catName = AucAdvanced.Const.CLASSES[cat]
		if catName then
			lib.Print("Beginning scanning: {{Category "..cat.." ("..catName..")}}")
		else
			cat = nil
		end
	end
	if not cat then
		lib.Print("Beginning scanning: {{All categories}}")
	end

	local scanner = AucAdvanced.scanner
	if not scanner then scanner = "Simple" end

	if not AucAdvanced.Modules.Scan[scanner] then
		local loaded, reason = LoadAddOn("Auc-Scan-"..scanner)
		if not loaded then
			message("The "..tostring(scanner).." scan engine could not be loaded: "..reason)
			return
		end
	end
	AucAdvanced.Modules.Scan[scanner].StartScan(cat)
end

SLASH_AUCADVANCED1 = "/auc"
SlashCmdList["AUCADVANCED"] = function(msg) lib.CommandHandler(strsplit(" ", msg)) end

