--[[
	Auctioneer Advanced
	Version: <%version%> (<%codename%>)
	Revision: $Id$
	URL: http://auctioneeraddon.com/

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
]]
local lib = AucAdvanced
local private = {}

--This function sets up Protect-Window functionality.
--We had to modify the getter and setter in CoreSettings,
--so much of this code is to cope with that.
function lib.windowProtect(action, setvalue)
	if (not AucAdvanced.Settings) then
		AucAdvanced.Settings = {}
	end
	--If this was called by the getter, we'll receive an argument
	--of "getsetting"  So we get the setting and return it for
	--CoreSettings.lua
	if (action == "getsetting") then
		return AucAdvanced.Settings.GetSetting("protectwindow")
	--If this was called by the getDefault, we'll receive an argument
	--of "getdefault"
	elseif (action == "getdefault") then
		return AucAdvanced.Settings.getDefault("protectwindow")
	--If it was called by the setter, we'll receive and argument of
	--"set".  This is where we do most of our work.
	elseif (action == "set") then
		--We need the AuctionFrame to have been created and for
		--it to be associated with the UIPanelLayout tables.  If
		--it isn't, we take care of that here.
		if (not UIPanelWindows["AuctionFrame"]) then
			AuctionFrame_LoadUI()
			local info = UIPanelWindows[AuctionFrame:GetName()]
			AuctionFrame:SetAttribute("UIPanelLayout-defined", true)
			for name,value in pairs(info) do
				AuctionFrame:SetAttribute("UIPanelLayout-"..name, value)
			end
		end
		--If UIPanelLayout-defined is true, and UIPanelLayout-enabled
		--equals the value we're about to set our config to (setvalue),
		--we need to change the value of UPL-e.
		if (AuctionFrame:GetAttribute("UIPanelLayout-defined")) then
			----local bholder = not setvalue
			--We can't change window protection if the UI thinks
			--the window is open.
			if (AuctionFrame:IsShown()) then
				if (setvalue) then
					--Thanks to Esamynn for this trick.  This 
					--tricks the UI into thinking we've hidden
					--the AuctionFrame so we can protect the 
					--window.
					AuctionFrame.Hide = function() end
					HideUIPanel(AuctionFrame)
					AuctionFrame.Hide = nil
					AuctionFrame:SetAttribute("UIPanelLayout-enabled", not setvalue)
				else
					--Thanks to Esamynn for this trick, too. This
					--forces the protection off without closing the
					--window.
					AuctionFrame:SetAttribute("UIPanelLayout-enabled", not setvalue)
					AuctionFrame.IsShown = function() end
					ShowUIPanel(AuctionFrame, 1)
					AuctionFrame.IsShown = nil
				end
			else
				--Set our UIPanelLayout-enabled value
				AuctionFrame:SetAttribute("UIPanelLayout-enabled", not setvalue)
			end
		end
		--Set our config value
		return AucAdvanced.Settings.SetSetting("protectwindow", setvalue)
	end
end

--Now let's create a structure to check and set our Window Protection at
--startup.
local myFrame = CreateFrame("Frame")
myFrame:Hide()

--This script will protect the AuctionFrame on first open if we've
--got protection turned on.  It works on a delay to give the client
--time to build the AuctionFrame and attributes completely before
--we run our code. Then rehides itself so this only happens once.
myFrame:SetScript("OnUpdate", function()
	if (AucAdvanced.Settings.GetSetting("protectwindow")) and (AuctionFrame:GetAttribute("UIPanelLayout-enabled")) then
	if (AuctionFrame:IsShown()) then 
		AuctionFrame.Hide = function() end 
		HideUIPanel(AuctionFrame) 
		AuctionFrame.Hide = nil 
	end
		AuctionFrame:SetAttribute("UIPanelLayout-enabled", nil)
		this:Hide()
	end
end)

--Register our frame for the ADDON_LOADED event
myFrame:RegisterEvent("ADDON_LOADED")

--When we catch the blizzard_auctionui addon loading, unhide our frame
--which will just sit there for a bit until the frame updates, when
--our code will fire.
myFrame:SetScript("OnEvent", function(name, event, addon)
	if addon:lower()=="blizzard_auctionui" then
	this:Show()
	end
end)

--The folowing function will build tables correlating Chat Frame names with their index numbers, and return different formats according to an option passed in.
function lib.getFrameNames(option)
	local frames = {}
	local frameName = ""
	local configFrames = {}
--This iterates through the first 10 ChatWindows, getting the name associated with it.
	for i=1, 10 do
		local name, fontSize, r, g, b, a, shown, locked, docked = GetChatWindowInfo(i)
		--If the name isn't blank, then we build a couple of tables, one where the Chat Frame names are the keys, and indexes the values, another which is the reverse.
		if (name ~= "") then
			frames[name] = i
			table.insert(configFrames, {i, name})
		end
	end
	--Next, if a number was passed as an option, we simply retrieve the frame name and assign it to frameName
	if (type(option) == "number") then
		local name, fontSize, r, g, b, a, shown, locked, docked = GetChatWindowInfo(option);
		frameName = name
	end
	--If no option was specified, we return the Name=>Index table
	if (not option) then
		return frames
	--If the option was a number, we return frameName
	elseif (type(option) == "number") then
		return frameName
	--If the option was the word "config" we return the Index=>Name table
	elseif (option == "config") then
		return configFrames
	end
end

--This function will retrieve the index we've got stored for the user
function lib.getFrameIndex()
	--Check to make sure AucAdvanced.Settings exists, if not initialize it
	if (not AucAdvanced.Settings) then
		AucAdvanced.Settings = {}
	end
	--Get the value of AucAdvanced.Settings["printwindow"]
	local value = AucAdvanced.Settings.GetSetting("printwindow")
	--If that value doesn't exist, we return a default of "1"
	if (not value) then
		return 1
	end
	--Otherwise, we return the value
	return value
end

--This function is used to store the user's preferred chatframe
function lib.setFrame(frame)
	local frameNumber
	local frameVal
	local allFrames = {}
	frameVal = tonumber(frame)
	--If no arguments are passed, then set the default frame of 1
	if (not frame) then
		frameNumber = 1
	--If the frame argument is a number, set that as the frameNumber
	elseif ((frameVal) ~= nil) then
			frameNumber = frameVal
	--If the argument is a string, try to convert it to a frame number, if we can't, then set it to a default of 1
	elseif (type(frame) == "string") then
		allFrames = AucAdvanced.getFrameNames()
		if (allFrames[frame]) then
				frameNumber = allFrames[frame]
		else
				frameNumber = 1
		end
	--If the argument doesn't make sense, set the default to 1
	else
			frameNumber = 1;
	end
	--Finally, set our printwindow to whatever we ended up deciding on
	AucAdvanced.Settings.SetSetting("printwindow", frameNumber)
end

--This is the printing function.  If the user has selected a preferred chatframe, we'll use it.  If not, we'll default to the first one.
function lib.Print(...)
	local output, part
	local frameIndex = AucAdvanced.getFrameIndex();
	local frameReference = _G["ChatFrame"..frameIndex]
	for i=1, select("#", ...) do
		part = select(i, ...)
		part = tostring(part):gsub("{{", "|cffddeeff"):gsub("}}", "|r")
		if (output) then output = output .. " " .. part
		else output = part end
	end
	--If we have a stored chat frame, print our output there
	if (frameReference) then
		frameReference:AddMessage(output, 0.3, 0.9, 0.8)
	--Otherwise, print it to the client's DEFAULT_CHAT_FRAME
	else
		DEFAULT_CHAT_FRAME:AddMessage(output, 0.3, 0.9, 0.8)
	end
end

local function breakHyperlink(match, matchlen, ...)
	local v
	local n = select("#", ...)
	for i = 2, n do
		v = select(i, ...)
		if (v:sub(1,matchlen) == match) then
			return strsplit(":", v:sub(2))
		end
	end
end
lib.breakHyperlink = breakHyperlink
lib.BreakHyperlink = breakHyperlink

function lib.GetFactor(suffix, seed)
	if (suffix < 0) then
		return bit.band(seed, 65535)
	end
	return 0
end

function lib.DecodeLink(link)
	local vartype = type(link)
	if (vartype == "string") then
		local lType,id,enchant,gem1,gem2,gem3,gemBonus,suffix,seed = breakHyperlink("Hitem:", 6, strsplit("|", link))
		if (lType ~= "item") then return end
		id = tonumber(id) or 0
		enchant = tonumber(enchant) or 0
		suffix = tonumber(suffix) or 0
		seed = tonumber(seed) or 0
		local factor = lib.GetFactor(suffix, seed)
		return lType, id, suffix, factor, enchant, seed
	elseif (vartype == "number") then
		return "item", link, 0, 0, 0, 0
	end
	return
end

function lib.GetFaction()
	local realmName = GetRealmName()
	local currentZone = GetMinimapZoneText()
	local factionGroup = lib.GetFactionGroup()
	if not factionGroup then return end

	if (factionGroup == "Neutral") then
		AucAdvanced.cutRate = 0.15
		AucAdvanced.depositRate = 0.25
	else
		AucAdvanced.cutRate = 0.05
		AucAdvanced.depositRate = 0.05
	end
	AucAdvanced.curFaction = realmName.."-"..factionGroup
	return AucAdvanced.curFaction, realmName, factionGroup
end

-- Had to create an event catching frame to allow for disabling // re-enabling use of home faction data everywhere (automagic disable on ah open/ enable on close) ~ this stops neutral ah data from getting in home faction database
local auctionHouseStatus = 0
function onEventCatcher(this, event)
	if event == 'AUCTION_HOUSE_SHOW' then
		auctionHouseStatus = 1
	end
	if event == 'AUCTION_HOUSE_CLOSED' then
		auctionHouseStatus = 0
	end
end

local frame = CreateFrame("Frame","")
	frame:SetScript("OnEvent", onEventCatcher);
	frame:RegisterEvent("AUCTION_HOUSE_SHOW");
	frame:RegisterEvent("AUCTION_HOUSE_CLOSED");

function lib.GetFactionGroup()
	local currentZone = GetMinimapZoneText()
	local factionGroup = "Faction" --Save only "Faction" or "Neutral", as non-neutral zones should always display the home faction's data

	if not private.factions then private.factions = {} end
	if private.factions[currentZone] then
		factionGroup = private.factions[currentZone]
	else
		SetMapToCurrentZone()
		local map = GetMapInfo()
		if ((map == "Tanaris") or (map == "Winterspring") or (map == "Stranglethorn")) then
			factionGroup = "Neutral"
		end
	end
	private.factions[currentZone] = factionGroup
	if auctionHouseStatus == 0 then
		if (AucAdvanced.Settings.GetSetting("alwaysHomeFaction") == true) then factionGroup = "Faction" end 
	end
	if factionGroup == "Faction" then
		factionGroup = UnitFactionGroup("player")
	end
	return factionGroup
end


function private.relevelFrame(frame)
	return private.relevelFrames(frame:GetFrameLevel() + 2, frame:GetChildren())
end

function private.relevelFrames(myLevel, ...)
	for i = 1, select("#", ...) do
		local child = select(i, ...)
		child:SetFrameLevel(myLevel)
		private.relevelFrame(child)
	end
end

function lib.AddTab(tabButton, tabFrame)
	-- Count the number of auction house tabs (including the tab we are going
	-- to insert).
	local tabCount = 1;
	while (getglobal("AuctionFrameTab"..(tabCount))) do
		tabCount = tabCount + 1;
	end

	-- Find the correct location to insert our Search Auctions and Post Auctions
	-- tabs. We want to insert them at the end or before BeanCounter's
	-- Transactions tab.
	local tabIndex = 1;
	while (getglobal("AuctionFrameTab"..(tabIndex)) and
		   getglobal("AuctionFrameTab"..(tabIndex)):GetName() ~= "AuctionFrameTabTransactions") do
		tabIndex = tabIndex + 1;
	end

	-- Make room for the tab, if needed.
	for index = tabCount, tabIndex + 1, -1  do
		setglobal("AuctionFrameTab"..(index), getglobal("AuctionFrameTab"..(index - 1)));
		getglobal("AuctionFrameTab"..(index)):SetID(index);
	end

	-- Configure the frame.
	tabFrame:SetParent("AuctionFrame");
	tabFrame:SetPoint("TOPLEFT", "AuctionFrame", "TOPLEFT", 0, 0);
	private.relevelFrame(tabFrame);

	-- Configure the tab button.
	setglobal("AuctionFrameTab"..tabIndex, tabButton);
	tabButton:SetParent("AuctionFrame");
	tabButton:SetPoint("TOPLEFT", getglobal("AuctionFrameTab"..(tabIndex - 1)):GetName(), "TOPRIGHT", -8, 0);
	tabButton:SetID(tabIndex);
	tabButton:Show();

	-- If we inserted a tab in the middle, adjust the layout of the next tab button.
	if (tabIndex < tabCount) then
		nextTabButton = getglobal("AuctionFrameTab"..(tabIndex + 1));
		nextTabButton:SetPoint("TOPLEFT", tabButton:GetName(), "TOPRIGHT", -8, 0);
	end

	-- Update the tab count.
	PanelTemplates_SetNumTabs(AuctionFrame, tabCount)
end

local LibRecycle = LibStub("LibRecycle")

lib.Recycle = LibRecycle.Recycle
lib.Acquire = LibRecycle.Acquire
lib.Clone = LibRecycle.Clone
lib.Scrub = LibRecycle.Scrub


--[[
Functions for establishing a new copy of the library.
Recommended method:

  local libType, libName = "myType", "myName"
  local lib,parent,private = AucAdvanced.NewModule(libType, libName)
  if not lib then return end
  local print,decode,recycle,acquire,clone,scrub,get,set,default = AucAdvanced.GetModuleLocals()

--]]

--[[

Usage:
  local lib,parent,private = AucAdvanced.NewModule(libType, libName)

--]]
local moduleKit = {}
function lib.NewModule(libType, libName)
	assert(lib.Modules[libType], "Invalid AucAdvanced libType specified: "..tostring(libType))

	if not lib.Modules[libType][libName] then
		local module = {}
		local private = {}
		module.libType = libType
		module.libName = libName
		module.Private = private
		module.GetName = function() return libName end
		for k,v in pairs(moduleKit) do
			module[k] = v
		end

		lib.Modules[libType][libName] = module
		return module, lib, private
	end
end

--[[

Usage:
  local libCopy = AucAdvanced.GetModule(libType, libName)

--]]
function lib.GetModule(libType, libName)
	assert(lib.Modules[libType], "Invalid AucAdvanced libType specified: "..tostring(libType))
	
	if lib.Modules[libType][libName] then
		return lib.Modules[libType][libName], lib, private
	end
end

--[[

Usage:
  local print,decode,recycle,acquire,clone,scrub,get,set,default = AucAdvanced.GetModuleLocals()

-- ]]
function lib.GetModuleLocals()
	return lib.Print, lib.DecodeLink,
	lib.Recycle, lib.Acquire, lib.Clone, lib.Scrub,
	lib.Settings.GetSetting, lib.Settings.SetSetting, lib.Settings.SetDefault
end

AucAdvanced.RegisterRevision("$URL$", "$Rev$")
