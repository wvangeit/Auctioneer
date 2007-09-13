--[[
	Auctioneer Advanced - Price Level Utility module
	Revision: $Id$
	Version: <%version%> (<%codename%>)

	This is an addon for World of Warcraft that adds a price level indicator
	to auctions when browsing the Auction House, so that you may readily see
	which items are bargains or overpriced at a glance.

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

local libName = "ScanProgress"
local libType = "Util"

AucAdvanced.Modules[libType][libName] = {}
local lib = AucAdvanced.Modules[libType][libName]
local private = {}
local print = AucAdvanced.Print
--[[
The following functions are part of the module's exposed methods:
	GetName()         (required) Should return this module's full name
	CommandHandler()  (optional) Slash command handler for this module
	Processor()       (optional) Processes messages sent by Auctioneer
	ScanProcessor()   (optional) Processes items from the scan manager
*	GetPrice()        (required) Returns estimated price for item link
*	GetPriceColumns() (optional) Returns the column names for GetPrice
	OnLoad()          (optional) Receives load message for all modules

	(*) Only implemented in stats modules; util modules do not provide
]]

function lib.GetName()
	return libName
end

function lib.Processor(callbackType, ...)
	if (callbackType == "scanprogress") then
		private.UpdateScanProgress(...)
	elseif (callbackType == "config") then
		private.SetupConfigGui(...)
	elseif (callbackType == "configchanged") then
		private.ConfigChanged(...)
	end
end

function lib.OnLoad()
	--print("AucAdvanced: {{"..libType..":"..libName.."}} loaded!")
	AucAdvanced.Settings.SetDefault("util.scanprogress.activated", true)
end

----  Functions to manage the progress indicator ----
private.scanStartTime = time()
private.scanProgressFormat = "Auctioneer Advanced: %s\nScanning page %d of %d\n\nAuctions per second: %.2f\nAuctions scanned thus far: %d\n\nEstimated time left: %s\nElapsed scan time: %s"
function private.UpdateScanProgress(state, totalAuctions, scannedAuctions)
	--Check that we're enabled before passing on the callback
	if (not AucAdvanced.Settings.GetSetting("util.scanprogress.activated")) then
		return
	end
	--Check to see if Compact UI is being used, if so gracefully allow it to continue as is
	if AucAdvanced.Settings.GetSetting("util.compactui.activated") then
		return
	end

	--Change the state if we have not scanned any auctions yet.
	--This is done so that we don't start the timer too soon and thus get skewed numbers
	if ((state == nil) and ((not scannedAuctions) or (scannedAuctions == 0))) then
		state = true
	end

	--Distribute the callback according to the value of the state variable
	if (state == nil) then
		private.UpdateScanProgressUI(totalAuctions, scannedAuctions)
	elseif (state == true) then
		private.ShowScanProgressUI(totalAuctions)
	else--if (state == false) then
		private.HideScanProgressUI()
	end
end

function private.ShowScanProgressUI(totalAuctions)
	for i=1, NUM_BROWSE_TO_DISPLAY do
		_G["BrowseButton"..i]:Hide()
	end
	BrowseNoResultsText:Show()
	private.scanStartTime = time()
	AuctionFrameBrowse:UnregisterEvent("AUCTION_ITEM_LIST_UPDATE")
	BrowseNoResultsText:SetText("Scanning "..(totalAuctions or "").." items...")
end

function private.HideScanProgressUI()
	BrowseNoResultsText:Hide()
	BrowseNoResultsText:SetText(SEARCHING_FOR_ITEMS)
	AuctionFrameBrowse:RegisterEvent("AUCTION_ITEM_LIST_UPDATE")
	for i=1, NUM_BROWSE_TO_DISPLAY do
	end
	local numBatchAuctions, totalAuctions = GetNumAuctionItems("list")
	local offset = FauxScrollFrame_GetOffset(BrowseScrollFrame)
	for i=1, NUM_BROWSE_TO_DISPLAY do
		index = offset + i + (NUM_AUCTION_ITEMS_PER_PAGE * AuctionFrameBrowse.page)
		if ( index > (numBatchAuctions + (NUM_AUCTION_ITEMS_PER_PAGE * AuctionFrameBrowse.page)) ) then
			_G["BrowseButton"..i]:Hide()
		else
			_G["BrowseButton"..i]:Show()
		end
	end
end

function private.UpdateScanProgressUI(totalAuctions, scannedAuctions)
	local numAuctionsPerPage = NUM_AUCTION_ITEMS_PER_PAGE

	local secondsElapsed = time() - private.scanStartTime
	local auctionsToScan = totalAuctions - scannedAuctions

	local currentPage = math.floor(scannedAuctions / numAuctionsPerPage)
	local totalPages = math.floor(totalAuctions / numAuctionsPerPage)

	local auctionsScannedPerSecond = scannedAuctions / secondsElapsed
	local secondsToScanCompletion = auctionsToScan / auctionsScannedPerSecond

	BrowseNoResultsText:SetText(
		private.scanProgressFormat:format(
			"Scanning auctions.",
			currentPage + 1,
			totalPages,
			auctionsScannedPerSecond,
			scannedAuctions,
			SecondsToTime(secondsToScanCompletion),
			SecondsToTime(secondsElapsed)
		)
	)
end

--Config UI functions
function private.SetupConfigGui(gui)
	-- The defaults for the following settings are set in the lib.OnLoad function
	id = gui:AddTab(libName)
	gui:AddControl(id, "Header",     0,    libName.." options")
	gui:AddControl(id, "Checkbox",   0, 1, "util.scanprogress.activated", "Show a textual progress indicator when scanning.")
end

function private.ConfigChanged()
	if (not AucAdvanced.Settings.GetSetting("util.scanprogress.activated")) then
		private.UpdateScanProgress(false)
	elseif (AucAdvanced.Scan.IsScanning()) then
		private.UpdateScanProgress(true)
	end
end
