-- AHScanning
-- Functions for scanning the AH
-- Thanks to Telo for the LootLink code from which this was based.

Auctioneer_isScanningRequested = false;
local lCurrentAuctionPage;
local lMajorAuctionCategories;
local lCurrentCategoryIndex;
local lIsPageScanned;
local lScanInProgress;
local lFullScan;

-- function hooks
local lOriginal_CanSendAuctionQuery;
local lOriginal_AuctionFrameBrowse_OnEvent;

-- TODO: If all categories are selected, then we should do a complete scan rather than a one-by-one scan.

-- get the next category index to based on what categories have been configured to be scanned
local function nextIndex()
	if (lCurrentCategoryIndex == nil) then lCurrentCategoryIndex = 0 end
	for i = lCurrentCategoryIndex + 1, table.getn(lMajorAuctionCategories) do
		if tostring(Auctioneer_GetFilterVal("scan-class"..i)) == "on" then
			return i;
		end
	end

	return nil;
end

function Auctioneer_StopAuctionScan()
	Auctioneer_Event_StopAuctionScan();
	
	-- Unhook the scanning functions
	if( lOriginal_CanSendAuctionQuery ) then
		CanSendAuctionQuery = lOriginal_CanSendAuctionQuery;
		lOriginal_CanSendAuctionQuery = nil;
	end
	
	if( lOriginal_AuctionFrameBrowse_OnEvent ) then
		AuctionFrameBrowse_OnEvent = lOriginal_AuctionFrameBrowse_OnEvent;
		lOriginal_AuctionFrameBrowse_OnEvent = nil;
	end
	
	Auctioneer_isScanningRequested = false;
	lScanInProgress = false;
end

local lPageStartedAt;
local function Auctioneer_AuctionNextQuery()
	lCheckPage = nil;
	if lCurrentAuctionPage then
		local numBatchAuctions, totalAuctions = GetNumAuctionItems("list");
		local maxPages = floor(totalAuctions / NUM_AUCTION_ITEMS_PER_PAGE);

		if( lCurrentAuctionPage < maxPages ) then
			lPageStartedAt = time();
			lCurrentAuctionPage = lCurrentAuctionPage + 1;
			if lFullScan then
				BrowseNoResultsText:SetText(string.format(_AUCT['AuctionPageN'], _AUCT['TextAuction'], lCurrentAuctionPage + 1, maxPages + 1));
			else
				BrowseNoResultsText:SetText(string.format(_AUCT['AuctionPageN'], lMajorAuctionCategories[lCurrentCategoryIndex],lCurrentAuctionPage + 1, maxPages + 1));
			end
		elseif nextIndex() then
			lPageStartedAt = time();
			lCurrentCategoryIndex = nextIndex();
			lCurrentAuctionPage = 0;
		else
			Auctioneer_StopAuctionScan();
			if( totalAuctions > 0 ) then
				BrowseNoResultsText:SetText(_AUCT['AuctionScanDone']);
				Auctioneer_Event_FinishedAuctionScan();
			end
			return;
		end
	end
	if not lCurrentAuctionPage or lCurrentAuctionPage == 0 then
		lPageStartedAt = time();
		if not lCurrentAuctionPage then lCurrentAuctionPage = 0 end
		if lFullScan then
			BrowseNoResultsText:SetText(string.format(_AUCT['AuctionScanStart'], _AUCT['TextAuction']));
		else
			BrowseNoResultsText:SetText(string.format(_AUCT['AuctionScanStart'], lMajorAuctionCategories[lCurrentCategoryIndex]));
		end
	end
	if (lFullScan) then
		QueryAuctionItems("", "", "", nil, nil, nil, lCurrentAuctionPage, nil, nil);
	else
		QueryAuctionItems("", "", "", nil, lCurrentCategoryIndex, nil, lCurrentAuctionPage, nil, nil);
	end

	lIsPageScanned = false;
	Auctioneer_Event_AuctionQuery(lCurrentAuctionPage);
end

local lCheckPage = nil;
local lCheckSize = nil;
local lCheckPos = nil;
function Auctioneer_CheckCompleteScan()
	if (lCheckPage ~= lCurrentAuctionPage) or (not lCheckSize) or (not lCheckPos) then
		lCheckSize = GetNumAuctionItems("list");
		lCheckPage = lCurrentAuctionPage;
		lCheckPos = 1;
	end

	if lCheckPage and lCheckSize > 0 then
		for auctionid = lCheckPos, lCheckSize do
			lCheckPos = auctionid;
			local _,_,_,_,_,_,_,_,_,_,_, owner = GetAuctionItemInfo("list", auctionid);
			if (owner == nil) then return false end
		end
	end
	return true;
end

function Auctioneer_ScanAuction()
	local numBatchAuctions, totalAuctions = GetNumAuctionItems("list");
	local auctionid;

	if( numBatchAuctions > 0 ) then
		for auctionid = 1, numBatchAuctions do
			Auctioneer_Event_ScanAuction(lCurrentAuctionPage, auctionid, lCurrentCategoryIndex);
		end
	end

	lIsPageScanned = true;
end

local function Auctioneer_CanSendAuctionQuery()
	local value = lOriginal_CanSendAuctionQuery();
	if (value and lIsPageScanned) then
		Auctioneer_AuctionNextQuery();
		return nil;
	end
	local pageElapsed = time() - lPageStartedAt;
	if (pageElapsed > 60) then
		if (Auctioneer_GetFilter(_AUCT['ShowRedo'])) then
			Auctioneer_ChatPrint(string.format(_AUCT['AuctionScanRedo'], 60));
		end
		Auctioneer_AuctionNextQuery();
		return nil;
	end
	return false;
end

function Auctioneer_AuctionFrameBrowse_OnEvent()
	-- Intentionally empty; don't allow the auction UI to update while we're scanning
end

function Auctioneer_StartAuctionScan()
	lMajorAuctionCategories = {GetAuctionItemClasses()};

	lFullScan = true;
	for i = 1, table.getn(lMajorAuctionCategories) do
		if tostring(Auctioneer_GetFilterVal("scan-class"..i)) ~= "on" then
			lFullScan = false;
		end
	end

	if (lFullScan) then
		lCurrentCategoryIndex = table.getn(lMajorAuctionCategories);
	else
		-- first make sure that we have at least one category to scan
		lCurrentCategoryIndex = nextIndex();
		if not lCurrentCategoryIndex then
			lCurrentCategoryIndex = 0;
			Auctioneer_ChatPrint(_AUCT['AuctionScanNocat']);
			return;
		end
	end

	-- Start with the first page
	lCurrentAuctionPage = nil;
	lScanInProgress = true;

	-- Hook the functions that we need for the scan
	if( not lOriginal_CanSendAuctionQuery ) then
		lOriginal_CanSendAuctionQuery = CanSendAuctionQuery;
		CanSendAuctionQuery = Auctioneer_CanSendAuctionQuery;
	end
	
	if( not lOriginal_AuctionFrameBrowse_OnEvent ) then
		lOriginal_AuctionFrameBrowse_OnEvent = AuctionFrameBrowse_OnEvent;
		AuctionFrameBrowse_OnEvent = Auctioneer_AuctionFrameBrowse_OnEvent;
	end
	
	Auctioneer_Event_StartAuctionScan();
	
	Auctioneer_AuctionNextQuery();
end

function Auctioneer_CanScan()
	if (lScanInProgress) then
		return false;
	end
	if (not CanSendAuctionQuery()) then
		return false;
	end
	return true;
end

function Auctioneer_RequestAuctionScan()
	Auctioneer_isScanningRequested = true;
	if( AuctionFrame:IsVisible() ) then
		local iButton;
		local button;
	
		-- Hide the UI from any current results, show the no results text so we can use it
		BrowseNoResultsText:Show();
		for iButton = 1, NUM_BROWSE_TO_DISPLAY do
			button = getglobal("BrowseButton"..iButton);
			button:Hide();
		end
		BrowsePrevPageButton:Hide();
		BrowseNextPageButton:Hide();
		BrowseSearchCountText:Hide();
	
		Auctioneer_StartAuctionScan();
	else
		Auctioneer_ChatPrint(_AUCT['AuctionScanNexttime']);
	end
end


-- Hook this function to be called whenever an auction entry is successfully inspected
function Auctioneer_Event_ScanAuction(auctionpage, auctionid)
	-- auctionpage: the page number this item was found on
	-- auctionid: the id of the inspected item
end

-- Hook this function to be called whenever Auctioneer starts an auction scan
function Auctioneer_Event_StartAuctionScan()
end

-- Hook this function to be called whenever Auctioneer stops an auction scan
function Auctioneer_Event_StopAuctionScan()
end

-- Hook this function to be called whenever Auctioneer completes a full auction scan
function Auctioneer_Event_FinishedAuctionScan()
end

-- Hook this function to be called whenever Auctioneer sends a new auction query
function Auctioneer_Event_AuctionQuery(auctionpage)
	-- auctionpage: the page number for the query that was just sent
end
