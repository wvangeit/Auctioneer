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

Auctioneer.Revisions = {
}

function Auctioneer.RegisterRevision(path, revision)
	local file = revision:find("%$URL: .*/([^/]+)%$")
	local rev = revision:find("%$Rev: (%d)%$")
	if not file then return end
	if not rev then rev = 0 end

	Auctioneer.Revisions[file] = rev
	if (nLog) then
		nLog.AddMessage("Auctioneer", "AucRevision", N_INFO, "Loaded revisioned file", "Loaded", file, "revision", rev)
	end
end

Auctioneer.RegisterRevision("$URL$", "$Rev$")

