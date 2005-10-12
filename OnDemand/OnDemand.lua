--[[
--	OnDemand
--		This AddOn is merely for the purpose of testing
--		Stubby functions.
--
--	Yes, I know it's ugly :P
--]]

local ONDEMAND_COMMAND = "/ondemand";
local OnDemand_HookOriginals= {}

local function DebugMsg(...)
	if ( DEFAULT_CHAT_FRAME ) then 
		local msg = "OnDemand:"
		for i=1, table.getn(arg) do
			msg = msg.." "..arg[i]
		end
		DEFAULT_CHAT_FRAME:AddMessage(msg, 1.0, 0.45, 0.25)
	end
end

-- Code to be executed when this addon loads
-- Note that Stubby will sometimes load the addon just to learn
-- about it and allow it to set up it's triggers.
function OnDemand_OnLoad()
	DebugMsg("OnDemand loaded!");
	
	OnDemand_RegisterWithStubby();
	
	-- Register slash command
	SLASH_ONDEMAND1 = ONDEMAND_COMMAND;
	SlashCmdList["ONDEMAND"] = function(msg)
		OnDemand_Commands(msg);
	end	
end

-- Hooks into the AuctionFrame_Show function
function OnDemand_OnLoadAH()
	if (AuctionFrame_Show) then
		OnDemand_HookOriginals.AuctionFrame_Show = AuctionFrame_Show;
		AuctionFrame_Show = OnDemand_AuctionFrame_Show
	else
		DebugMsg("Unable to hook functions. Expected AddOn not loaded?");
	end
end

-- Register an AddOn hook to watch for loading of the Blizzard_AuctionUI addon,
-- as well as a stub for this addon's slash command.
function OnDemand_RegisterWithStubby()
	Stubby.RegisterTrigger("OnDemand", [[
		function OnDemand_LoadingAH()
			Stubby.Print("Loading OnDemand addon...")
			LoadAddOn("OnDemand")
			OnDemand_OnLoadAH();
		end
		Stubby.RegisterAddonHook("Blizzard_AuctionUI", "OnDemand", OnDemand_LoadingAH)
		
		SLASH_ONDEMAND1 = "]] .. ONDEMAND_COMMAND .. [[";
		SlashCmdList["ONDEMAND"] = function(msg)
			if (msg == "") then
				DEFAULT_CHAT_FRAME:AddMessage("OnDemand is currently not loaded.");
				DEFAULT_CHAT_FRAME:AddMessage("Usage:");
				DEFAULT_CHAT_FRAME:AddMessage(" /ondemand load - load the addon");
				DEFAULT_CHAT_FRAME:AddMessage(" /ondemand clearstub - clear Stubby data for this addon");
			else
				LoadAddOn("OnDemand")
				OnDemand_Commands(msg)
			end
		end
	]])
end

-- Do something silly whenever the AuctionFrame is shown
function OnDemand_AuctionFrame_Show()
	OnDemand_HookOriginals.AuctionFrame_Show()
	DebugMsg("AuctionFrame being displayed!");
end

-- Handle slash commands
function OnDemand_Commands(msg)
	if (string.lower(msg) == "load") then
		DEFAULT_CHAT_FRAME:AddMessage("OnDemand loaded successfully.");	
	elseif (string.lower(msg) == "clearstub") then
		-- Ugly hack for testing
		if (StubbyConfig and StubbyConfig.addinfo and type(StubbyConfig.addinfo) == "table") then
			StubbyConfig.addinfo.OnDemand = nil
			DEFAULT_CHAT_FRAME:AddMessage("Made Stubby forget version information for this addon.");	
		end
	else
		DEFAULT_CHAT_FRAME:AddMessage("OnDemand is loaded.");
		DEFAULT_CHAT_FRAME:AddMessage("Usage:");
		DEFAULT_CHAT_FRAME:AddMessage(" /ondemand load - load the addon");
		DEFAULT_CHAT_FRAME:AddMessage(" /ondemand clearstub - clear Stubby data for this addon");
	end
end