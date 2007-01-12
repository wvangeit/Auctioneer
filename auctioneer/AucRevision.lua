--[[
	Auctioneer Addon for World of Warcraft(tm).
	Version: <%version%> (<%codename%>)
	Revision: $Id$

	Auctioneer Revisions
	Keep track of the revision numbers for various auctioneer files

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

if (Auctioneer_RegisterRevision) then return end

local revs = { }
local dist = {
--[[<%revisions%>]]
}

function Auctioneer_RegisterRevision(path, revision)
	local _,_, file = path:find("%$URL: .*/auctioneer/([^%$]+) %$")
	local _,_, rev = revision:find("%$Rev: (%d+) %$")
	if not file then return end
	if not rev then rev = 0 else rev = tonumber(rev) or 0 end

	revs[file] = rev
	if (nLog) then
		nLog.AddMessage("Auctioneer", "AucRevision", N_INFO, "Loaded revisioned file", "Loaded", file, "revision", rev)
	end
end
Auctioneer_RegisterRevision("$URL$", "$Rev$")


local messageFrame
local function message(msg)
	if not messageFrame then
		messageFrame = CreateFrame("Frame", "", UIParent)
		messageFrame:SetPoint("TOP", UIParent, "TOP", 0, 150)
		messageFrame:SetWidth(300);
		messageFrame:SetWidth(200);
		messageFrame:SetFrameStrata("DIALOG")
		messageFrame:SetBackdrop({
			bgFile = "Interface/Tooltips/UI-Tooltip-Background",
			edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
			tile = true, tileSize = 32, edgeSize = 16,
			insets = { left = 4, right = 4, top = 4, bottom = 4 }
		})
		messageFrame:SetBackdropColor(0.5,0,0, 0.8)

		messageFrame.done = CreateFrame("Button", "", messageFrame, "OptionsButtonTemplate")
		messageFrame.done:SetText(OKAY)
		messageFrame.done:SetPoint("BOTTOMRIGHT", messageFrame, "BOTTOMRIGHT", -10, 10)
		messageFrame.done:SetScript("OnClick", function() messageFrame:Hide() end)

		messageFrame.text = messageFrame:CreateFontString("", "HIGH")
		messageFrame.text:SetPoint("TOPLEFT", messageFrame, "TOPLEFT")
		messageFrame.text:SetPoint("BOTTOMRIGHT", messageFrame.done, "TOPRIGHT")
		messageFrame.text:SetFont("Fonts\\FRIZQT__.TTF",12)
		messageFrame.text:SetJustifyH("LEFT")
	end
	messageFrame.text:SetText(msg)
	messageFrame:Show()
end

function Auctioneer_Validate()
	local matches = true
	for file, revision in pairs(dist) do
		local current = revs[file]
		if (not current or current ~= revision) then
			matches = false
			if (nLog) then
				nLog.AddMessage("Auctioneer", "Validate", N_WARNING, "File revision mismatch", "File", file, "should be revision", revision, "but is actually", current)
			end
		end
	end
	if (not matches) then
		message("Warning: Your Auctioneer installation appears to have mismatching file versions.\nPlease make sure you delete the old AddOns/Auctioneer directory, reinstall a fresh copy and restart WoW completely before reporting any bugs.\nThankyou.")
	end
	return true
end

