--[[  This addon's sole purpose is to hook and execute functions.
----  The publically accessible functions of this library are:
----
----  Stubby.RegisterFunctionHook(functionName, position, hookFunc, ...)
----    Hook into the function with the same name as the string 
----    "functionName" at the given position ( -int .. +int )
----    A negative position causes your hook to be called before
----    the original function, and a positive after it. Please
----    leave ample space for other addons to position themselves
----    around you if they wish.
----    Your function hookFunc(...) is called in the correct
----    sequence when the original function is invoked.
----
----  Stubby.RegisterAddonHook(addonName, waiterName, hookFunction, ...)
----    Waits for addon "addonName" to load then calls your
----    hookFunction(...) when it is loaded (or immediatly if the
----    addon is already loaded (so you don't have to check)
----    "waiterName" is your addon name, and is used to index your
----    hookFunction into the lookup table.
----
----  Stubby.RegisterTrigger(triggerName, triggerCode)
----    Registers a trigger (named triggerName) with the
----    associated code to be run every time Stubby starts up.
----    triggerCode is a string with the lua code you want
----    Stubby to run for you. You may want to use this if your
----    addon is load on demand and you want to set up a command
----    handler or a hook into a Blizzard function which will
----    trigger the loading of your addon.
----
---------------------------------------------------------------------
----  Example code:
----    Stubby.RegisterTrigger("myAddonLoader", "Stubby.RegisterAddonHook(\"Blizzard_AuctionUI\", \"myAddon\", LoadAddon, \"myAddon\")");
----    This code will run every time stubby starts up, and will 
----    cause your addon to be loaded whenever the Blizzard_AuctionUI
----    addon is loaded.
----    What it does is register a trigger called "myAddonLoader"
----    which upon Stubby's execution calls another Stubby function,
----    RegisterAddonHook against the addon called "Blizzard_AuctionUI"
----    if this addon is currently loaded, it will call
----    LoadAddon("myAddon") immediatly, else it will wait until
----    Blizzard_AuctionUI is loaded and then call LoadAddon("myAddon")
----    
----    Many more complex triggers can be created, even to the extent
----    of creating functions and programming logic, slash command
----    handlers, etc.
----    
--]]
local registerFunctionHook
local registerAddonHook
local registerEventHook
local registerTrigger
local eventWatcher
local loadWatcher

local config = {
	hooks = { functions={}, origFuncs={} },
	calls = { functions={} },
	loads = {},
	events = {},
}

StubbyConfig = {}

-- This function takes all the items and their requested orders
-- and assigns an actual ordering to them.
local function rebuildNotifications(notifyItems)
	local notifyFuncs = {}
	for hookType, hData in notifyItems do
		notifyFuncs[hookType] = {}

		-- Sort all hooks for this type in ascending numerical order.
		local sortedPositions = {}
		for requestedPos,_ in hData do
			table.insert(sortedPositions, requestedPos)
		end
		table.sort(sortedPositions)

		-- Process the sorted request list and insert in correct
		-- order into the call list.
		for _,requestedPos in sortedPositions do
			local func = hData[requestedPos];
			func.pos = requestedPos;
			table.insert(notifyFuncs[hookType], hData[requestedPos])
		end
	end
	return notifyFuncs
end

-- This function's purpose is to execute all the attached
-- functions in order and the original call at just before
-- position 100.
local function hookCall(funcName, arguments)
	local orig = Stubby.GetOrigFunc(funcName);
	for _,func in pairs(config.calls.functions[funcName]) do
		if (orig and func.p >= 0) then
			orig(unpack(arguments))
			orig = nil
		end
		func.f(unpack(func.a));
	end
end

-- This function automatically hooks Stubby in place of the
-- original function, dynamically.
Stubby_NewFunction = nil;
local function hookInto(functionName)
	if (config.hooks.functions[functionName]) then return end
	config.hooks.origFuncs[functionName] = getglobal(functionName);
	
	RunScript("Stubby_NewFunction = function(...) Stubby.HookCall(\""..functionName.."\", arg) end");
	setglobal(functionName, Stubby_NewFunction);
	Stubby_NewFunction = nil
end

-- This function causes a given function to be hooked by stubby and
-- configures the hook function to be called at the given position.
-- The original function gets executed a position 0. Use a negative
-- number to get called before the original function, and positive
-- number to get called after the original function. Default position
-- is 200. If someone else is already using your number, you will get
-- automatically moved up for after or down for before. Please also
-- leave space for other people who may need to position their hooks
-- in between your hook and the original.
function registerFunctionHook(functionName, position, hookFunc, ...)
	local insertPos = tonumber(position) or 200
	local funcObj = { f=hookFunc, a=arg, p=position };

	if (config.calls.functions[hookType]) then
		while (config.calls.functions[hookType][insertPos]) do
			if (position >= 0) then
				insertPos = insertPos + 1
			else
				insertPos = insertPos - 1
			end
		end
		config.calls.functions[functionName][insertPos] = funcObj
	end		
	hookInto(functionName)
end

-- This function registers a given function to be called when a given
-- addon is loaded, or immediatly if it is already loaded (this can be
-- used to setup a hooking function to execute when an addon is loaded
-- but not before)
function registerAddonHook(addonName, waiterName, hookFunction, ...)
	if (IsAddOnLoaded(addonName)) then
		hookFunction(unpack(arg));
	else
		local addon = string.lower(addonName)
		if (not config.loads[addon]) then config.loads[addon] = {} end
		table.insert(config.loads[addon][waiterName], { f=hookFunction, a=arg })
	end
end
function loadWatcher(loadedAddon)
	if (config.loads[loadedAddon]) then
		local waiterName, hookDetail
		for waiterName, hookDetail in config.loads[loadedAddon] do
			hookDetail.f(unpack(hookDetail.a));
		end
	end
end

-- This function registers a given function to be called when a given
-- event is fired (this can be used to activate an addon upon reciept
-- of a given event etc)
function registerEventHook(eventType, waiterName, hookFunction, ...)
	if (not config.events[eventType]) then 
		config.events[eventType] = {}
		RegisterEvent(eventType);
	end
	table.insert(config.events[eventType][waiterName], { f=hookFunction, a=arg })
end
function eventWatcher(eventType)
	if (config.events[eventType]) then
		local waiterName, hookDetail
		for waiterName, hookDetail in config.events[eventType] do
			hookDetail.f(unpack(hookDetail.a));
		end
	end
end

-- This function registers a trigger. This is a piece of code
-- specified as a string, which Stubby will execute on your behalf
-- when we are first loaded. This code can do anything a normal
-- lua script can, such as create global functions, register a
-- command handler, hook into functions, load your addon etc.
-- Leaving triggerCode nil will remove your trigger.
function registerTrigger(triggerName, triggerCode)
	local triggerIndex = string.lower(triggerName);
	if (not StubbyConfig.triggers) then StubbyConfig.triggers = {} end
	StubbyConfig.triggers[triggerIndex] = nil
	if (triggerCode) then
		StubbyConfig.triggers[triggerIndex] = triggerCode;
	end
end


-- Functions to check through all addons for dependants.
-- If any exist that we don't know about, and have a dependancy of us, then we will load them
-- once to give them a chance to register themselves with us.
local function shouldInspectAddon(addonName)
	if not StubbyConfig.inspected then StubbyConfig.inpected = {} end
	if not StubbyConfig.inspected[addonName] then return true end
	return false;
end
local function inspectAddon(addonName)
	LoadAddon(addonName);
	StubbyConfig.inspected[addonName] = true;
end
local function searchForNewAddons()
	local addonCount = GetNumAddOns();
	local name, title, notes, enabled, loadable, reason, security, requiresLoad
	for i=1, addonCount do
		requiresLoad = false;
		name, title, notes, enabled, loadable, reason, security = GetAddOnInfo(i)
		if (IsAddonLoadOnDemand(i) and shouldInspectAddon(name) and loadable) then
			local addonDeps = { GetAddOnDependancies(i) }
			for _, dependancy in pairs(addonDeps) do
				if (string.lower(dependancy) == "stubby") then
					requiresLoad = true;
				end
			end
		end

		if (requiresLoad) then inspectAddon(name) end
	end
end

-- This function runs through the trigger scripts we have, and if the
-- related addon is not loaded yet, runs the trigger script.
local function runTriggers()
	if (not StubbyConfig.triggers) then return end
	for addon, trigger in StubbyConfig.triggers do
		if (IsAddOnLoaded(addon) and IsAddonLoadOnDemand(addon)) then
			RunScript(trigger)
		end
	end
end


local function onLoaded()
	-- Run all of our triggers to setup the respective addons functions.
	runTriggers()
	-- The search for new life and new civilizations... or just addons maybe.
	searchForNewAddons()
end

function events(event, param)
	if (event == "ADDON_LOADED") then
		if (param == "Stubby") then onLoaded() end
		Stubby.LoadWatcher(param);
	end
	Stubby.EventWatcher();
end


-- Setup our Stubby global object. All interaction is done
-- via the methods exposed here.
Stubby = {
	Events = events,
	LoadWatcher = loadWatcher,
	RegisterTrigger = registerTrigger,
	RegisterAddonHook = registerAddonHook,
	RegisterFunctionHook = registerFunctionHook,
};


