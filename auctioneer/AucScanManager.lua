--[[
	Auctioneer Addon for World of Warcraft(tm).
	Version: <%version%> (<%codename%>)
	Revision: $Id$

	ScanManager - manages AH scanning

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

-- Debug switch - set to true, to enable debug output for this module
local debug = false

Auctioneer_RegisterRevision("$URL$", "$Rev$")

-------------------------------------------------------------------------------
-- Function Prototypes
-------------------------------------------------------------------------------
local load;
local killHook;
local onEventHook;
local isScanning;
local scan;
local scanAll;
local scanCategories;
local scanQuery;
local cancelScan;
local addRequestToQueue;
local removeRequestFromQueue;
local sendQuery;
local queryCompleteCallback;
local emptyHookFunction
local scanStarted;
local scanEnded;
local updateScanProgressUI;
local onAuctionAdded;
local onAuctionUpdated;
local onAuctionRemoved;
local debugPrint;
local isQueryStyle;

-------------------------------------------------------------------------------
-- Enumerations
-------------------------------------------------------------------------------
-- The states, which a scan request can enter.
local ScanRequestState = {
	WaitingToQuery        = "WaitingToQuery";        -- request is waiting in queue to be sent to the query manager
	WaitingForQueryResult = "WaitingForQueryResult"; -- request is waiting in queue to be processed by the callback function
	Done                  = "Done";                  -- request is done
	Canceled              = "Canceled";              -- request is meant to be canceled
	Failed                = "Failed";                -- request failed
}

-------------------------------------------------------------------------------
-- Private Data
-------------------------------------------------------------------------------

-- Queue of scan requests.
local ScanRequestQueue = {};

-- Counters that keep track of the number of auctions added, updated or removed
-- during the course of a scan.
local AuctionsScanned
local AuctionsAdded
local AuctionsUpdated
local AuctionsRemoved
local AuctionsScannedCacheSize
local LastRequestResult = ScanRequestState.Done;
local QueryStyleScan = nil;

-- Flag that indicates, if scanning has begun.
local Scanning = false;

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function load()
	Stubby.RegisterEventHook("AUCTION_HOUSE_CLOSED", "Auctioneer_ScanManager", onEventHook);
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function AucScanManager_OnUpdate()
	local request = ScanRequestQueue[1];
	if (request) then
		if (request.state == ScanRequestState.WaitingToQuery and Auctioneer.QueryManager.CanSendAuctionQuery()) then
			if (not Scanning) then
				scanStarted();
			end
			sendQuery(request);
		end
	elseif (Scanning) then
		scanEnded();
	end
end

-------------------------------------------------------------------------------
-- OnEvent handler.
-------------------------------------------------------------------------------
function onEventHook(_, event)
	if (event == "AUCTION_HOUSE_CLOSED") then
		cancelScan();
	end
end

-------------------------------------------------------------------------------
-- Checks if a scan is in progress.
-------------------------------------------------------------------------------
function isScanning()
	return Scanning;
end

-------------------------------------------------------------------------------
-- Starts an AH scan of the categories selected in the UI.
-------------------------------------------------------------------------------
function scan()
	-- Get the list of categories checked (by index).
	categories = {};
	local allCategories = {GetAuctionItemClasses()};
	for category, name in pairs(allCategories) do
		if (tostring(Auctioneer.Command.GetFilterVal("scan-class"..category)) == "on") then
			table.insert(categories, category);
		end
	end

	-- Scan everything or only selected categories?
	if (#allCategories == #categories) then
		debugPrint("Scanning all categories");
		return scanAll();
	else
		debugPrint("Scanning", #categories, "categories");
		return scanCategories(categories);
	end
end

-------------------------------------------------------------------------------
-- Starts an AH scan of all auctions.
-------------------------------------------------------------------------------
function scanAll()
	if (#ScanRequestQueue == 0) then
		-- Construct a scan all request.
		local request = {};
		request.description = _AUCT('AuctionScanAll');
		addRequestToQueue(request);
		return true;
	else
		debugPrint("Cannot start scan because a scan is already in progress!");
		return false;
	end
end

-------------------------------------------------------------------------------
-- Starts an AH scan of the specified categories.
-------------------------------------------------------------------------------
function scanCategories(categories)
	if (#ScanRequestQueue == 0) then
		-- Construct a scan request for each category requested.
		for index, category in pairs(categories) do
			local request = {};
			request.description = string.format(_AUCT('AuctionScanCat'), Auctioneer.ItemDB.GetCategoryName(category));
			request.classIndex = category;
			addRequestToQueue(request);
		end
		return true;
	else
		debugPrint("Cannot start scan because a scan is already in progress!");
		return false;
	end
end

-------------------------------------------------------------------------------
-- Starts an AH scan base on a query.
-------------------------------------------------------------------------------
function scanQuery(name, minLevel, maxLevel, invTypeIndex, classIndex, subclassIndex, page, isUsable, qualityIndex)
	if (#ScanRequestQueue == 0) then
		-- Construct the scan request.
		local request = {
			description = _AUCT('AuctionScanAuctions');
			name = name;
			minLevel = minLevel;
			maxLevel = maxLevel;
			invTypeIndex = invTypeIndex;
			classIndex = classIndex;
			subclassIndex = subclassIndex;
			page = page;
			isUsable = isUsable;
			qualityIndex = qualityIndex;
		};
		addRequestToQueue(request);
		debugPrint("Query Style Scan");
		QueryStyleScan = 1;
		return true;
	else
		debugPrint("Cannot start scan because a scan is already in progress!");
		return false;
	end
end

-------------------------------------------------------------------------------
-- Cancels any in progress scan.
-------------------------------------------------------------------------------
function cancelScan()
	-- %todo: We should probaby wait for the result of any query that is in
	-- progress.
	while (#ScanRequestQueue > 0) do
		ScanRequestQueue[1].state = ScanRequestState.Canceled;
		removeRequestFromQueue();
	end
end

-------------------------------------------------------------------------------
-- Adds a request to the back of the queue.
-------------------------------------------------------------------------------
function addRequestToQueue(request)
	request.pages           = 0;
	request.totalAuctions   = 0;
	request.nextPage        = 0;
	request.auctionsScanned = 0;
	request.state           = ScanRequestState.WaitingToQuery;
	table.insert(ScanRequestQueue, request);
	debugPrint("Added request to back of queue");
end

-------------------------------------------------------------------------------
-- Removes the request at the head of the queue.
-------------------------------------------------------------------------------
function removeRequestFromQueue()
	if (#ScanRequestQueue > 0) then
		-- Remove the request from the queue.
		local request = ScanRequestQueue[1];
		table.remove(ScanRequestQueue, 1);
		debugPrint("Removed request from queue with result:", request.state);

		-- If the request succeeded, add the auctions scanned to the total.
		LastRequestResult = request.state;
		if (LastRequestResult == ScanRequestState.Done) then
			AuctionsScanned = request.auctionsScanned;
			AuctionsScannedCacheSize = AuctionsScannedCacheSize + AuctionsScanned;
			debugPrint("AuctionsScanned: "..AuctionsScannedCacheSize.."("..AuctionsScanned..")");
		end
	end
end

-------------------------------------------------------------------------------
-- Sends the next query
-------------------------------------------------------------------------------
function sendQuery(request)
	-- If this is the first query of the request, update the UI to say so.
	if (request.totalAuctions == 0) then
		BrowseNoResultsText:SetText(_AUCT('AuctionScanStart'):format(request.description));
	end

	-- Send the query!
	debugPrint("Requesting page"..request.nextPage);
	Auctioneer.QueryManager.QueryAuctionItems(
		request.name,
		request.minLevel,
		request.maxLevel,
		request.invTypeIndex,
		request.classIndex,
		request.subclassIndex,
		request.nextPage,
		request.isUsable,
		request.qualityIndex,
		10,
		3,
		queryCompleteCallback
	);
	request.state = ScanRequestState.WaitingForQueryResult;
end

-------------------------------------------------------------------------------
-- Called when our query request completes.
-------------------------------------------------------------------------------
function queryCompleteCallback(query, result)
	local request = ScanRequestQueue[1];
	if (not request) or (request.state ~= ScanRequestState.WaitingForQueryResult) then
		debugPrint("WARNING: Received query complete callback in unexpected state")
		return
	end

	-- Check, if query failed
	if (result ~= QueryAuctionItemsResultCodes.Complete) and (result ~= QueryAuctionItemsResultCodes.PartialComplete) then
		debugPrint("Aborting request due to failed query!");
		-- set, so that the debug output in removeRequestFromQueue() will print the correct state
		request.state = ScanRequestState.Failed
		removeRequestFromQueue();
		return
	end

	-- Query succeeded so update the request.
	debugPrint("Scanned page"..request.nextPage);
	local lastIndexOnPage, totalAuctions = GetNumAuctionItems("list");

	-- Is this the first query?
	if (request.totalAuctions == 0) then
		-- This was the first query to get the total number of auctions.
		request.totalAuctions = totalAuctions;
		request.pages = math.floor((totalAuctions - 1) / NUM_AUCTION_ITEMS_PER_PAGE) + 1;
		if (request.pages == 1) then
			-- There's one and only one page. Tally the auctions
			-- scanned and we are done!
			request.nextPage = -1;
			request.auctionsScanned = lastIndexOnPage;
		else
			-- More then one page so we'll scan in reverse so as to
			-- not miss any auctions.
			-- Start counting the time, after scanning the first page is done
			request.startTime = GetTime();
			request.nextPage = request.pages - 1;
			Auctioneer.QueryManager.ClearPageCache();
		end
		debugPrint("Found", request.totalAuctions, "auctions (", request.pages, "pages)");
	else
		-- Tweak the start time if it happened in less than 5 seconds.
		local currentTime = GetTime();
		local timeElapsed = currentTime - request.startTime;
		-- This is off by one page, since we did not record the processing time
		-- for the first page.
		local pagesScanned = request.pages - request.nextPage;
		-- Scanning one page should take at least approximitaly 4-5 seconds due to
		-- blizzards restrictions on how fast a new page might be querried.
		-- Therefore scanning one page should never be faster then 4 seconds.
		local minTimeElapsed = 4.0 * pagesScanned;
		debugPrint(pagesScanned, "pages scanned thus far in", timeElapsed);
		if (timeElapsed < minTimeElapsed) then
			-- TODO: Before the release of 4.0 either remove this debug message, or
			--       if no user reported this issue, remove the complete
			--       timeElapsed code since it does no longer seem to be of any use.
			Auctioneer.Util.ChatPrint("Scanning the AH up to now was unexpectingly fast. Please report this issue and explain what exactly you did before this message occured on: http://www.auctioneeraddon.com/scm/ticket/1436.")
			Auctioneer.Util.ChatPrint("Please also add these details to your report: Number of total pages: "..request.pages.." - calculated time: "..timeElapsed.." - pages scanned: "..pagesScanned)
			debugPrint("Adjusted request.startTime to keep the time remaining accurate.");
			request.startTime = currentTime - minTimeElapsed;
		end

		-- This was a subsequent query.
		request.nextPage = request.nextPage - 1;
		request.auctionsScanned = request.auctionsScanned + lastIndexOnPage;
		if request.nextPage >= 0 then
			-- update the scan progress only, if there is at least one page left to be processed
			updateScanProgressUI(request.description, pagesScanned+1, request.pages, request.startTime, request.auctionsScanned)
		end
	end

	-- Check if the scan is complete.
	if (request.nextPage < 0) then
		-- Request is complete!
		debugPrint("Reached the first page");
		request.state = ScanRequestState.Done;
		removeRequestFromQueue();
	else
		-- More pages to go...
		request.state = ScanRequestState.WaitingToQuery;
	end
end

-------------------------------------------------------------------------------
-- Called when a scan starts.
-------------------------------------------------------------------------------
function killHook()
	return "killorig"
end

function scanStarted()
	-- Protect window if needed
	if (Auctioneer.Command.GetFilterVal('protect-window') == 1) then
		-- We're set to protect only while scanning, so protect the window now
		Auctioneer.Util.ProtectAuctionFrame(true);
	end

	-- Don't allow AuctionFrameBrowse updates during a scan.
	Stubby.RegisterFunctionHook("AuctionFrameBrowse_OnEvent", -200, killHook)
	Stubby.RegisterFunctionHook("AuctionFrameBrowse_Update", -200, killHook)
	Stubby.RegisterFunctionHook("AuctionFrameBrowse_Search", -200, killHook)

	-- Hide the results UI
	BrowseNoResultsText:SetText("");
	BrowseNoResultsText:Show();
	-- "result buttons" (the entries, shown in the saerch result list)
	for iButton = 1, NUM_BROWSE_TO_DISPLAY do
		button = getglobal("BrowseButton"..iButton);
		button:Hide();
	end
	BrowsePrevPageButton:Hide();
	BrowseNextPageButton:Hide();
	BrowseSearchCountText:Hide();
	BrowseBidButton:Disable();
	BrowseBuyoutButton:Disable();

	-- Initialize the counters for this scan.
	AuctionsScanned = 0;
	AuctionsAdded   = 0;
	AuctionsUpdated = 0;
	AuctionsRemoved = 0;
	AuctionsScannedCacheSize = 0;

	-- Register for snapshot update events so we can track how many auctions
	-- are added, updated and removed.
	Auctioneer.EventManager.RegisterEvent("AUCTIONEER_AUCTION_ADDED", onAuctionAdded);
	Auctioneer.EventManager.RegisterEvent("AUCTIONEER_AUCTION_UPDATED", onAuctionUpdated);
	Auctioneer.EventManager.RegisterEvent("AUCTIONEER_AUCTION_REMOVED", onAuctionRemoved);

	-- Scanning has begun!
	Scanning = true;
	Auctioneer.Scanning.IsScanningRequested = true;
	Auctioneer.QueryManager.ClearPageCache();
	debugPrint("Scan started");
end

-------------------------------------------------------------------------------
-- Called when a scan ends.
-------------------------------------------------------------------------------
function scanEnded()
	-- Scanning has ended!
	Scanning = false;
	Auctioneer.Scanning.IsScanningRequested = false;
	debugPrint("Scan ended with result:", LastRequestResult);

	-- Unregister snapshot events.
	Auctioneer.EventManager.UnregisterEvent("AUCTIONEER_AUCTION_ADDED", onAuctionAdded)
	Auctioneer.EventManager.UnregisterEvent("AUCTIONEER_AUCTION_UPDATED", onAuctionUpdated)
	Auctioneer.EventManager.UnregisterEvent("AUCTIONEER_AUCTION_REMOVED", onAuctionRemoved)
	-- reenable the original Auction Browse Frame functions
	Stubby.UnregisterFunctionHook("AuctionFrameBrowse_OnEvent", killHook)
	Stubby.UnregisterFunctionHook("AuctionFrameBrowse_Update", killHook)
	Stubby.UnregisterFunctionHook("AuctionFrameBrowse_Search", killHook)

	-- Compile the results.
	local chatResultText;
	local uiResultText;
	if (LastRequestResult == ScanRequestState.Done) then
		chatResultText = _AUCT('ScanComplete')
		uiResultText   = _AUCT('UIScanComplete')
	elseif (LastRequestResult == ScanRequestState.Canceled) then
		chatResultText = _AUCT('ScanCanceled')
		uiResultText   = _AUCT('UIScanCanceled')
	else
		chatResultText = _AUCT('ScanFailed')
		uiResultText   = _AUCT('UIScanFailed')
	end
	local auctionsScannedMessage = _AUCT('AuctionTotalAucts'):format(AuctionsScannedCacheSize);
	local auctionsAddedMessage   = _AUCT('AuctionNewAucts'):format(AuctionsAdded);
	local auctionsRemovedMessage = _AUCT('AuctionDefunctAucts'):format(AuctionsRemoved);
	local auctionsUpdatedMessage = _AUCT('AuctionUpdatedAucts'):format(AuctionsUpdated);

	-- Report the result to the chat window.
	Auctioneer.Util.ChatPrint(chatResultText..":");
	Auctioneer.Util.ChatPrint(auctionsScannedMessage);
	Auctioneer.Util.ChatPrint(auctionsAddedMessage);
	Auctioneer.Util.ChatPrint(auctionsRemovedMessage);
	Auctioneer.Util.ChatPrint(auctionsUpdatedMessage);
	-- Report the result to the UI.
	BrowseNoResultsText:SetText(strjoin("\n", uiResultText, auctionsScannedMessage, auctionsAddedMessage, auctionsRemovedMessage, auctionsUpdatedMessage));

	-- The followng was added by MentalPower to implement the "/auc finish-sound" command
	if (Auctioneer.Command.GetFilter("finish-sound")) then
		PlaySoundFile("Interface\\AddOns\\Auctioneer\\Sounds\\ScanComplete.mp3")
	end

	-- The followng was added by MentalPower to implement the "/auc finish" command
	local finish = Auctioneer.Command.GetFilterVal('finish');
	if (finish == 1) then
		Logout();
	elseif (finish == 2) then
		Quit();
	end

	-- Reset Scan Type Flag
	QueryStyleScan = nil;
	debugPrint("Scan Style Reset");

	-- Un-Protect window if needed
	if (Auctioneer.Command.GetFilterVal('protect-window') == 1) then
		-- We're set to protect only while scanning, so it's time to unprotect the window
		Auctioneer.Util.ProtectAuctionFrame(false);
	end

	-- Cleaning up after oneself is always a good idea.
	collectgarbage("collect");
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function updateScanProgressUI(description, pagesScanned, pages, startTime, auctionsScanned)
	local pagesToScan       = pages - pagesScanned
	local auctionsToScan    = pagesToScan * NUM_AUCTION_ITEMS_PER_PAGE
	local secondsElapsed    = GetTime() - startTime

	-- This explains the following calculation, since it's a bit tricky:
	-- pagesScanned - 1:
	--    The parameter startTime passed to this function contains the timestamp
	--    AFTER the first page was already processed. Therefore secondsElapsed
	--    only contains the number of seconds we needed to process page 2 to
	--    the current one.
	--    That's why we have to reduce pagesScanned by one to calculate the
	--    value for auctionsPerSecond
	--    So we get the [NUMBER_OF_SCANNED_PAGES].
	-- [NUMBER_OF_SCANNED_PAGES] * NUM_AUCTION_ITEMS_PER_PAGE:
	--    We assume that we scanned the maximum number of auctions on each page;
	--    even if we would have included the last page in our calculations,
	--    what we don't, we would have assumed that the last page also contains
	--    the maximum amount of auctions on the list. That's because we scanning
	--    one auction takes only few miliseconds, while the most time the scan
	--    waits for the next page being sent.
	--    Blizzard limits the interval of requesting AH pages to something like
	--    4-5 seconds (the latency is included in these 4-5 seconds) to reduce
	--    the serverload. Therefore most of the time Auctioneer is waiting.
	--    That's why there is almost no difference in the needed time to scan 1
	--    or 50 auctions, and to get a more precise estimated time, we simply
	--    assume that each page contains these 50 items (which is defined by bliz
	--    in NUM_AUCTION_ITEMS_PER_PAGE.
	--    We finally get the [NUMBER_OF_SCANNED_AUCTIONS].
	-- [NUMBER_OF_SCANNED_AUCTION] / secondsElapsed:
	--    Deviding this number by the seconds which already elapsed, results in
	--    the 100% accurate [AUCTIONS_PER_SECOND]. Note that this value is a
	--    float and therfore the positions after the decimal contain the
	--    milliseconds.
	-- [AUCTIONS_PER_SECOND] * 100:
	--    This simply returns the [AUCTIONS_PER_HUNDRED_MILLISECONDS] with the
	--    rest of the milliseconds still being positioned after the decimal
	--    point.
	-- math.floor([AUCTIONS_PER_HUNDRED_MILLISECONDS]):
	--    This way we get rid of the milliseconds after the decimal point and
	--    get [AUCTIONS_PER_HUNDRED_MILLISECONDS_INT].
	-- [AUCTIONS_PER_HUNDRED_MILLISECONDS] / 100:
	--    The final operation moves the milliseconds which are still there up to
	--    two positions back after the decimal point.
	local auctionsPerSecond = math.floor((pagesScanned-1) * NUM_AUCTION_ITEMS_PER_PAGE / secondsElapsed * 100) / 100
	local secondsLeft       = auctionsToScan / auctionsPerSecond

	-- convert seconds left to a useful string (SecondsToTime would return an empty string, if secondsLeft is 0)
	local strSecondsLeft
	if secondsLeft == 0 then
		strSecondsLeft = _AUCT('AuctionScanFinished')
	else
		strSecondsLeft = SecondsToTime(secondsLeft)
	end

	-- Update the progress of this request in the UI to
	-- Auctioneer: [request.description]
	-- Scanned page [request.pages - request.nextPage] of [request.pages]
	-- Auctions per second: [auctionsScannedPerSecond]
	-- Estimated time left: [secondsLeft]
	-- Auctions scanned thus far: [AuctionsScannedCacheSize]
	BrowseNoResultsText:SetText(
		_AUCT('AuctionPageN'):format(
			description,
			pagesScanned,
			pages,
			-- tostring is used instead of %f, so that the number won't be
			-- displayed with tailing zeroes
			tostring(auctionsPerSecond),
			strSecondsLeft,
			auctionsScanned + AuctionsScannedCacheSize
		)
	)
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function onAuctionAdded()
	AuctionsAdded = AuctionsAdded + 1
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function onAuctionUpdated()
	AuctionsUpdated = AuctionsUpdated + 1
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function onAuctionRemoved()
	AuctionsRemoved = AuctionsRemoved + 1
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function debugPrint(...)
	if debug then EnhTooltip.DebugPrint("[Auc.ScanManager]", ...) end
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function isQueryStyle()
	return QueryStyleScan
end

-------------------------------------------------------------------------------
-- Public API
-------------------------------------------------------------------------------
Auctioneer.ScanManager = {
	Load              = load;
	Scan              = scan;
	ScanAll           = scanAll;
	ScanCategories    = scanCategories;
	ScanQuery         = scanQuery;
	IsScanning        = isScanning;
	EmptyHookFunction = emptyHookFunction;
	IsQueryStyle      = isQueryStyle;
}

-- This is the variable Auctioneer used to use to indicate scanning. Keep it for
-- compatbility with addons such as AuctionFilterPlus.
Auctioneer.Scanning = {
	IsScanningRequested = false;
}