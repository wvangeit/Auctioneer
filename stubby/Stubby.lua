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
----  Stubby.RegisterTrigger(triggerAddon, triggerCode)
----    Registers a trigger (for addon triggerAddon) with the
----    associated code to be run every time Stubby starts up.
----    triggerCode is a string with the lua code you want
----    Stubby to run for you. You may want to use this if your
----    addon is load on demand and you want to set up a command
----    handler or a hook into a Blizzard function which will
----    trigger the loading of your addon.
----
---------------------------------------------------------------------
----  Example code:
----    Stubby.RegisterTrigger("myAddon", "Stubby.RegisterAddonHook(\"Blizzard_AuctionUI\", \"myAddon\", LoadAddon, \"myAddon\")")
----    This code will run every time stubby starts up, and will 
----    cause your addon to be loaded whenever the Blizzard_AuctionUI
----    addon is loaded.
----    What it does is register a trigger for an addon called "myAddon"
----    which upon Stubby's execution calls another Stubby function,
----    RegisterAddonHook against the addon called "Blizzard_AuctionUI"
----    if this addon is currently loaded, it will call
----    LoadAddOn("myAddon") immediately, else it will wait until
----    Blizzard_AuctionUI is loaded and then call LoadAddOn("myAddon")
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
	calls = { functions={}, callList={} },
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
			local func = hData[requestedPos]
			table.insert(notifyFuncs[hookType], func)
		end
	end
	return notifyFuncs
end

-- This function's purpose is to execute all the attached
-- functions in order and the original call at just before
-- position 100.
local function hookCall(funcName, arguments)
	local orig = Stubby.GetOrigFunc(funcName)
	if (not orig) then return end

	local callees = {}
	if config.calls and config.calls.callList and config.calls.callList[funcName] then
		callees = config.calls.callList[funcName]
	end
	
	for _,func in pairs(callees) do
		if (orig and func.p >= 0) then
			orig(unpack(arguments))
			orig = nil
		end
		if (not func.a or func.a == {}) then
			func.f(unpack(arguments))
		else
			local params = {}
			for _,param in func.a do table.insert(params, param) end
			for _,param in arguments do table.insert(params, param) end
			func.f(unpack(params))
		end
	end
	if (orig) then orig(unpack(arguments)) end
end

-- This function automatically hooks Stubby in place of the
-- original function, dynamically.
Stubby_OldFunction = nil
Stubby_NewFunction = nil
local function hookInto(functionName)
	if (config.hooks.origFuncs[functionName]) then return end
	RunScript("Stubby_OldFunction = "..functionName)
	RunScript("Stubby_NewFunction = function(...) Stubby.HookCall('"..functionName.."', arg) end")
	RunScript(functionName.." = Stubby_NewFunction")
	config.hooks.functions[functionName] = Stubby_NewFunction;
	config.hooks.origFuncs[functionName] = Stubby_OldFunction;
	Stubby_NewFunction = nil
	Stubby_OldFunction = nil
end

local function getOrigFunc(functionName)
	if (config.hooks) and (config.hooks.origFuncs) then
		return config.hooks.origFuncs[functionName]
	end
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
	local funcObj = { f=hookFunc, a=arg, p=position }

	if (not config.calls) then config.calls = {} end
	if (not config.calls.functions) then config.calls.functions = {} end
	if (config.calls.functions[functionName]) then
		while (config.calls.functions[functionName][insertPos]) do
			if (position >= 0) then
				insertPos = insertPos + 1
			else
				insertPos = insertPos - 1
			end
		end
		config.calls.functions[functionName][insertPos] = funcObj
	else
		config.calls.functions[functionName] = {}
		config.calls.functions[functionName][insertPos] = funcObj
	end
	config.calls.callList = rebuildNotifications(config.calls.functions);
	hookInto(functionName)
end

-- This function registers a given function to be called when a given
-- addon is loaded, or immediatly if it is already loaded (this can be
-- used to setup a hooking function to execute when an addon is loaded
-- but not before)
function registerAddonHook(addonName, waiterName, hookFunction, ...)
	if (IsAddOnLoaded(addonName)) then
		hookFunction(unpack(arg))
	else
		local addon = string.lower(addonName)
		if (not config.loads[addon]) then config.loads[addon] = {} end
		config.loads[addon][waiterName] = nil
		if (hookFunction) then
			config.loads[addon][waiterName] = { f=hookFunction, a=arg }
		end
	end
end

function loadWatcher(loadedAddon)
	local addon = string.lower(loadedAddon)
	if (config.loads[addon]) then
		local waiterName, hookDetail
		for waiterName, hookDetail in config.loads[addon] do
			hookDetail.f(unpack(hookDetail.a))
		end
	end
end

-- This function registers a given function to be called when a given
-- event is fired (this can be used to activate an addon upon reciept
-- of a given event etc)
function registerEventHook(eventType, waiterName, hookFunction, ...)
	if (not config.events[eventType]) then 
		config.events[eventType] = {}
		StubbyFrame:RegisterEvent(eventType)
	end
	config.events[eventType][waiterName] = nil
	if (hookFunction) then
		config.events[eventType][waiterName] = { f=hookFunction, a=arg }
	end
end

function eventWatcher(eventType)
	if (config.events[eventType]) then
		local waiterName, hookDetail
		for waiterName, hookDetail in config.events[eventType] do
			local params = {}
			for _,param in hookDetail.a do table.insert(params, param) end
			table.insert(params, event);
			local maxParam = 0;
			for i = 1, 25 do if getglobal("arg"..pos) then maxParam = i end end
			if (maxParam > 0) then
				for i = 1, maxParam do
					table.insert(params, getglobal("arg"..i))
				end
			end
			hookDetail.f(unpack(params))
		end
	end
end

-- This function registers a trigger. This is a piece of code
-- specified as a string, which Stubby will execute on your behalf
-- when we are first loaded. This code can do anything a normal
-- lua script can, such as create global functions, register a
-- command handler, hook into functions, load your addon etc.
-- Leaving triggerCode nil will remove your trigger.
function registerTrigger(triggerAddon, triggerCode)
	local triggerIndex = string.lower(triggerAddon)
	if (not StubbyConfig.triggers) then StubbyConfig.triggers = {} end
	StubbyConfig.triggers[triggerIndex] = nil
	if (triggerCode) then
		StubbyConfig.triggers[triggerIndex] = triggerCode
	end
end


-- Functions to check through all addons for dependants.
-- If any exist that we don't know about, and have a dependancy of us, then we will load them
-- once to give them a chance to register themselves with us.
local function checkAddons()
	if not StubbyConfig.inspected then return end
	local goodList = {}
	local addonCount = GetNumAddOns()
	local name, title, notes
	for i=1, addonCount do
		name, title, notes = GetAddOnInfo(i)
		if (StubbyConfig.inspected and StubbyConfig.inspected[name]) then
			local infoCompare = title.."|"..notes
			if (infoCompare == StubbyConfig.addinfo[name]) then
				goodList[name] = true
			end
		end
	end
	for name,_ in StubbyConfig.inspected do
		if (not goodList[name]) then
			StubbyConfig.inspected[name] = nil
			StubbyConfig.addinfo[name] = nil
		end
	end
end
local function shouldInspectAddon(addonName)
	if not StubbyConfig.inspected[addonName] then return true end
	return false
end
local function inspectAddon(addonName, title, info)
	LoadAddOn(addonName)
	StubbyConfig.inspected[addonName] = true
	StubbyConfig.addinfo[addonName] = title.."|"..info
end
local function searchForNewAddons()
	local addonCount = GetNumAddOns()
	local name, title, notes, enabled, loadable, reason, security, requiresLoad
	for i=1, addonCount do
		requiresLoad = false
		name, title, notes, enabled, loadable, reason, security = GetAddOnInfo(i)
		if (IsAddOnLoadOnDemand(i) and shouldInspectAddon(name) and loadable) then
			local addonDeps = { GetAddOnDependencies(i) }
			for _, dependancy in pairs(addonDeps) do
				if (string.lower(dependancy) == "stubby") then
					requiresLoad = true
				end
			end
		end

		if (requiresLoad) then inspectAddon(name, title, notes) end
	end
end

-- This function runs through the trigger scripts we have, and if the
-- related addon is not loaded yet, runs the trigger script.
local function runTriggers()
	if (not StubbyConfig.triggers) then return end
	for addon, trigger in StubbyConfig.triggers do
		if (not IsAddOnLoaded(addon) and IsAddOnLoadOnDemand(addon)) then
			RunScript(trigger)
		end
	end
end


local function onLoaded()
	if not StubbyConfig.inspected then StubbyConfig.inspected = {} end
	if not StubbyConfig.addinfo then StubbyConfig.addinfo = {} end

	checkAddons()
	-- Run all of our triggers to setup the respective addons functions.
	runTriggers()
	-- The search for new life and new civilizations... or just addons maybe.
	searchForNewAddons()
end

function events(event, param)
	if (event == "ADDON_LOADED") then
		if (param == "Stubby") then onLoaded() end
		Stubby.LoadWatcher(param)
	end
	Stubby.EventWatcher(event)
end

local function chatPrint(...)
	if ( DEFAULT_CHAT_FRAME ) then 
		local msg = ""
		for i=1, table.getn(arg) do
			if i==1 then msg = arg[i]
			else msg = msg.." "..arg[i]
			end
		end
		DEFAULT_CHAT_FRAME:AddMessage(msg, 1.0, 0.35, 0.15)
	end
end

-- Setup our Stubby global object. All interaction is done
-- via the methods exposed here.
Stubby = {
	Print = chatPrint,
	Events = events,
	HookCall = hookCall,
	GetOrigFunc = getOrigFunc,
	LoadWatcher = loadWatcher,
	EventWatcher = eventWatcher,
	RegisterTrigger = registerTrigger,
	RegisterEventHook = registerEventHook,
	RegisterAddonHook = registerAddonHook,
	RegisterFunctionHook = registerFunctionHook,
}


