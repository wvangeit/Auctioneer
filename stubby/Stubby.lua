--[[  Stubby

  Stubby is an addon that allows you to register boot code for
  your addon.

  This bootcode will be run whenever your addon does not demand
  load on startup so that you can setup your own conditions for
  loading.

  A quick example of this is:
  -------------------------------------------
  	Stubby.RegisterBootCode("myAddOn", "CommandHandler", [[
		local function cmdHandler(msg)
			LoadAddOn("myAddOn")
			MyAddOn_Command(msg)
		end
		SLASH_MYADDON1 = "/myaddon"
		SlashCmdList['MYADDON'] = cmdHandler
	]]);
  -------------------------------------------
  So, what did this just do? It registered some boot code
  (called "CommandHandler") with Stubby that Stubby will 
  (in the case you are not demand loaded) execute on your
  behalf.

  In the above example, your boot code sets up a command handler
  which causes your addon to load and process the command.

  Another example:
  -------------------------------------------
    Stubby.CreateAddOnLoadBootCode("myAddOn", "Blizzard_AuctionUI")
  -------------------------------------------
  Ok, what was that? Well you just setup some boot code
  for your addon that will register an addon hook when
  Stubby loads and your addon doesn't. This addon hook
  will cause your addon to load when the AuctionUI does.


  The primary functions that you will be interested in are:
    CreateAddOnLoadBootCode(ownerAddOn, triggerAddOn)
	CreateEventLoadBootCode(ownerAddOn, triggerEvent)
	CreateFunctionLoadBootCode(ownerAddOn, triggerFunction)
  And the manual, but vastly more powerful:
    RegisterBootCode(ownerAddOn, bootName, bootCode)


  Stubby can also save variables for you if you wish to retain
  stateful information in your boot code. (maybe you have
  recieved notification from your user that they wish always
  to have your addon load for the current toon?)

  These are the variable functions:
	SetConfig(ownerAddOn, variable, value, isGlobal)
    GetConfig(ownerAddOn, variable)
	ClearConfig(ownerAddOn, variable)

  The SetConfig function sets the configuration variable
  "variable" for ownerAddOn to value. The variable is
  per-toon unless isGlobal is set.

  The GetConfig function gets "variable" for ownerAddOn
  it will return per-toon values before global ones.

  The ClearConfig function clears the toon specific and
  global "variable" for ownerAddOn.


  The following functions are also available for you to use
  if you need to use some manual boot code and want to
  hook into some function, addon or event within your boot
  code:
    Stubby.RegisterFunctionHook(triggerFunction, position, hookFunction, ...)
    Stubby.RegisterAddOnHook(triggerAddOn, ownerAddOn, hookFunction, ...)
    Stubby.RegisterEventHook(triggerEvent, ownerAddOn, hookFunction, ...)

  RegisterFunctionHook allows you to hook into a function.
  * The triggerFunction is a string that names the function you
    want to hook into. eg: "GameTooltip.SetOwner
  * The position is a negative or positive number that defines
    the actual calling order of the addon. The smaller or more
    negative the number, the earlier in the call sequence your
    hookFunction will be called, the larger the number, the
    later your hook will be called. The actual original (hooked)
    function is called at position 0, so if your addon is hooked
    at a negative position, you will not have access to any
    return values.
  * You pass (by reference) your function that you wish called
    as hookFunction. This function will be called with the
	following parameters:
		hookFunction(hookParams, returnValue, hook1, hook2 .. hookN)
	- hookParams is a table containing the additional parameters
	passed to the RegisterFunctionHook function (the "..." params)
	- returnValue is an array of the returned values of the function
	or nil if none.
	- hook1..hookN are the original parameters of the hooked
	function in the original order.

  RegisterAddOnHook is very much like the register function hook
  call except that there is no positioning (you may get notified in
  any order with respect to any other addons which may be hooked)
  * The triggerAddOn specifies the name of the addon of which you
    want to be notified of it's loading.
  * The ownerAddOn is your addon's name (used for removing hooks)
  * The hookFunction is a function that gets called when the
    triggerAddOn loads or if it is already loaded straight away.
	This function will be called with the following parameters
		hookFunction(hookParams)
	- hookParams is a table containing the additional parameters
	passed to the RegisterAddOnHook function (the "..." params)

  RegisterEventHook allows you to hook an event in much the same
  way as the above functions.
  * The triggerEvent is an event which causes your hookFunction to
    be executed.
  * The ownerAddOn is your addon's name (used for removing hooks)
  * The hookFunction is a function that gets called whenever the
  triggerEvent fires (until canceled with UnregisterEventHook)
  This function will be called with the following parameters:
  	hookFunction(hookParams, event, hook1, hook2 .. hookN)
  - hookParams is a table containing the additional parameters
  passed to the RegisterEventHook function (the "..." params)
  - event is the event string that has just been fired
  - hook1..hookN are the original parameters of the event
  function in the original order.

  Other functions which may be of interest are:
  	UnregisterFunctionHook(triggerFunction, hookFunc)
	UnregisterAddOnHook(triggerAddOn, ownerAddOn)
	UnregisterEventHook(triggerEvent, ownerAddOn)
	UnregisterBootCode(ownerAddOn, bootName)

--]]
local createFunctionLoadBootCode
local createEventLoadBootCode
local createAddOnLoadBootCode
local unregisterFunctionHook
local unregisterAddOnHook
local unregisterEventHook
local unregisterBootCode
local registerFunctionHook
local registerAddOnHook
local registerEventHook
local registerBootCode
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
-- position 0.

local r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11,r12,r13,r14,r15,r16,r17,r18,r19,r20
local function hookCall(funcName, a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13,a14,a15,a16,a17,a18,a19,a20)
	local orig = Stubby.GetOrigFunc(funcName)
	if (not orig) then return end

	local retVal = nil
	local returns = false

	local callees
	if config.calls and config.calls.callList and config.calls.callList[funcName] then
		callees = config.calls.callList[funcName]
	end
	
	if (callees) then
		for _,func in pairs(callees) do
			if (orig and func.p >= 0) then
				r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11,r12,r13,r14,r15,r16,r17,r18,r19,r20
					= orig(a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13,a14,a15,a16,a17,a18,a19,a20)
				if r1 or r2 or r3 or r4 or r5 or r6 or r7 or r8 or r9 or r10 or r11 or r12 or r13 or r14 or r15 or r16 or r17 or r18 or r19 or r29 then
					retVal = { r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11,r12,r13,r14,r15,r16,r17,r18,r19,r20 }
					returns = true
				end
				orig = nil
			end
			func.f(func.a, retVal, a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13,a14,a15,a16,a17,a18,a19,a20);
		end
	end
	if (orig) then
		r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11,r12,r13,r14,r15,r16,r17,r18,r19,r20
			= orig(a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13,a14,a15,a16,a17,a18,a19,a20)
		if r1 or r2 or r3 or r4 or r5 or r6 or r7 or r8 or r9 or r10 or r11 or r12 or r13 or r14 or r15 or r16 or r17 or r18 or r19 or r29 then
			returns = true
		end
	end
	if (returns) then
		return r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11,r12,r13,r14,r15,r16,r17,r18,r19,r20
	end
end

-- This function automatically hooks Stubby in place of the
-- original function, dynamically.
Stubby_OldFunction = nil
Stubby_NewFunction = nil
local function hookInto(triggerFunction)
	if (config.hooks.origFuncs[triggerFunction]) then return end
	RunScript("Stubby_OldFunction = "..triggerFunction)
	RunScript("Stubby_NewFunction = function(a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13,a14,a15,a16,a17,a18,a19,a20) return Stubby.HookCall('"..triggerFunction.."', a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13,a14,a15,a16,a17,a18,a19,a20) end")
	RunScript(triggerFunction.." = Stubby_NewFunction")
	config.hooks.functions[triggerFunction] = Stubby_NewFunction;
	config.hooks.origFuncs[triggerFunction] = Stubby_OldFunction;
	Stubby_NewFunction = nil
	Stubby_OldFunction = nil
end

local function getOrigFunc(triggerFunction)
	if (config.hooks) and (config.hooks.origFuncs) then
		return config.hooks.origFuncs[triggerFunction]
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
function registerFunctionHook(triggerFunction, position, hookFunc, ...)
	local insertPos = tonumber(position) or 200
	local funcObj = { f=hookFunc, a=arg, p=position }
	if (table.getn(arg) == 0) then funcObj.a = nil; end

	if (not config.calls) then config.calls = {} end
	if (not config.calls.functions) then config.calls.functions = {} end
	if (config.calls.functions[triggerFunction]) then
		while (config.calls.functions[triggerFunction][insertPos]) do
			if (position >= 0) then
				insertPos = insertPos + 1
			else
				insertPos = insertPos - 1
			end
		end
		config.calls.functions[triggerFunction][insertPos] = funcObj
	else
		config.calls.functions[triggerFunction] = {}
		config.calls.functions[triggerFunction][insertPos] = funcObj
	end
	config.calls.callList = rebuildNotifications(config.calls.functions);
	hookInto(triggerFunction)
end
function unregisterFunctionHook(triggerFunction, hookFunc)
	if not (config.calls and config.calls.functions and config.calls.functions[triggerFunction]) then return end
	for pos, funcObj in config.calls.functions[triggerFunction] do
		if (funcObj and funcObj.f == hookFunc) then
			config.calls.functions[triggerFunction][pos] = nil
		end
	end
end

-- This function registers a given function to be called when a given
-- addon is loaded, or immediatly if it is already loaded (this can be
-- used to setup a hooking function to execute when an addon is loaded
-- but not before)
function registerAddOnHook(triggerAddOn, ownerAddOn, hookFunction, ...)
	if (IsAddOnLoaded(triggerAddOn)) then
		hookFunction(unpack(arg))
	else
		local addon = string.lower(triggerAddOn)
		if (not config.loads[addon]) then config.loads[addon] = {} end
		config.loads[addon][ownerAddOn] = nil
		if (hookFunction) then
			config.loads[addon][ownerAddOn] = { f=hookFunction, a=arg }
		end
	end
end
function unregisterAddOnHook(triggerAddOn, ownerAddOn)
	local addon = string.lower(triggerAddOn)
	if (config.loads and config.loads[addon] and config.loads[addon][ownerAddOn]) then
		config.loads[addon][ownerAddOn] = nil
	end
end

function loadWatcher(loadedAddOn)
	local addon = string.lower(loadedAddOn)
	if (config.loads[addon]) then
		local ownerAddOn, hookDetail
		for ownerAddOn, hookDetail in config.loads[addon] do
			hookDetail.f(hookDetail.a)
		end
	end
end

-- This function registers a given function to be called when a given
-- event is fired (this can be used to activate an addon upon receipt
-- of a given event etc)
function registerEventHook(triggerEvent, ownerAddOn, hookFunction, ...)
	if (not config.events[triggerEvent]) then 
		config.events[triggerEvent] = {}
		StubbyFrame:RegisterEvent(triggerEvent)
	end
	config.events[triggerEvent][ownerAddOn] = nil
	if (hookFunction) then
		config.events[triggerEvent][ownerAddOn] = { f=hookFunction, a=arg }
	end
end
function unregisterEventHook(triggerEvent, ownerAddOn)
	if (config.events and config.events[triggerEvent] and config.events[triggerEvent][ownerAddOn]) then
		config.events[triggerEvent][ownerAddOn] = nil
	end
end

function eventWatcher(event)
	if (config.events[event]) then
		local ownerAddOn, hookDetail
		for ownerAddOn, hookDetail in config.events[event] do
			hookDetail.f(hookDetail.a, event, arg1,arg2,arg3,arg4,arg5,arg6,arg7,arg8,arg9,arg10,arg11,arg12,arg13,arg14,arg15,arg16,arg17,arg18,arg19,arg20);
		end
	end
end

-- This function registers boot code. This is a piece of code
-- specified as a string, which Stubby will execute on your behalf
-- when we are first loaded. This code can do anything a normal
-- lua script can, such as create global functions, register a
-- command handler, hook into functions, load your addon etc.
-- Leaving bootCode nil will remove your boot.
function registerBootCode(ownerAddOn, bootName, bootCode)
	local ownerIndex = string.lower(ownerAddOn)
	local bootIndex = string.lower(bootName)
	if (not StubbyConfig.boots) then StubbyConfig.boots = {} end
	if (not StubbyConfig.boots[ownerIndex]) then StubbyConfig.boots[ownerIndex] = {} end
	StubbyConfig.boots[ownerIndex][bootIndex] = nil
	if (bootCode) then
		StubbyConfig.boots[ownerIndex][bootIndex] = bootCode
	end
end
function unregisterBootCode(ownerAddOn, bootName)
	local ownerIndex = string.lower(ownerAddOn)
	local bootIndex = string.lower(bootName)
	if not (StubbyConfig.boots) then return end
	if not (ownerIndex and StubbyConfig.boots[ownerIndex]) then return end
	if (bootIndex == nil) then
		StubbyConfig.boots[ownerIndex] = nil
	else
		StubbyConfig.boots[ownerIndex][bootIndex] = nil
	end
end

function createAddOnLoadBootCode(ownerAddOn, triggerAddOn)
	registerBootCode(ownerAddOn, triggerAddOn.."AddOnLoader",
		'local function hookFunction() '..
			'LoadAddOn("'..ownerAddOn..'") '..
			'Stubby.UnregisterAddOnHook("'..triggerAddOn..'", "'..ownerAddOn..'") '..
		'end '..
		'Stubby.RegisterAddOnHook("'..triggerAddOn..'", "'..ownerAddOn..'", hookFunction)'
	);
end
function createFunctionLoadBootCode(ownerAddOn, triggerFunction)
	registerBootCode(ownerAddOn, triggerFunction.."FunctionLoader",
		'local function hookFunction() '..
			'LoadAddOn("'..ownerAddOn..'") '..
			'Stubby.UnregisterFunctionHook("'..triggerFunction..'", hookFunction) '..
		'end '..
		'Stubby.RegisterFunctionHook("'..triggerFunction..'", 200, "'..ownerAddOn..'", hookFunction)'
	);
end
function createEventLoadBootCode(ownerAddOn, triggerEvent)
	registerBootCode(ownerAddOn, triggerEvent.."FunctionLoader",
		'local function hookFunction() '..
			'LoadAddOn("'..ownerAddOn..'") '..
			'Stubby.UnregisterEventHook("'..triggerEvent..'", "'..ownerAddOn..'") '..
		'end '..
		'Stubby.RegisterEventHook("'..triggerEvent..'", "'..ownerAddOn..'", hookFunction)'
	);
end

-- Functions to check through all addons for dependants.
-- If any exist that we don't know about, and have a dependancy of us, then we will load them
-- once to give them a chance to register themselves with us.
local function checkAddOns()
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
local function shouldInspectAddOn(addonName)
	if not StubbyConfig.inspected[addonName] then return true end
	return false
end
local function inspectAddOn(addonName, title, info)
	LoadAddOn(addonName)
	StubbyConfig.inspected[addonName] = true
	StubbyConfig.addinfo[addonName] = title.."|"..info
end
local function searchForNewAddOns()
	local addonCount = GetNumAddOns()
	local name, title, notes, enabled, loadable, reason, security, requiresLoad
	for i=1, addonCount do
		requiresLoad = false
		name, title, notes, enabled, loadable, reason, security = GetAddOnInfo(i)
		if (IsAddOnLoadOnDemand(i) and shouldInspectAddOn(name) and loadable) then
			local addonDeps = { GetAddOnDependencies(i) }
			for _, dependancy in pairs(addonDeps) do
				if (string.lower(dependancy) == "stubby") then
					requiresLoad = true
				end
			end
		end

		if (requiresLoad) then inspectAddOn(name, title, notes) end
	end
end

-- This function runs through the boot scripts we have, and if the
-- related addon is not loaded yet, runs the boot script.
local function runBootCodes()
	if (not StubbyConfig.boots) then return end
	for addon, boots in StubbyConfig.boots do
		if (not IsAddOnLoaded(addon) and IsAddOnLoadOnDemand(addon)) then
			local _, _, _, _, loadable = GetAddOnInfo(addon)
			if (loadable) then
				for _, boot in pairs(boots) do
					RunScript(boot)
				end
			end
		end
	end
end


local function onWorldStart()
	checkAddOns()
	-- Run all of our boots to setup the respective addons functions.
	runBootCodes()
	-- The search for new life and new civilizations... or just addons maybe.
	searchForNewAddOns()
end

local function onLoaded()
	if not StubbyConfig.inspected then StubbyConfig.inspected = {} end
	if not StubbyConfig.addinfo then StubbyConfig.addinfo = {} end
	Stubby.RegisterEventHook("PLAYER_LOGIN", "Stubby", onWorldStart)
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

-- This function allows boot code to store a configuration variable
-- by default the variable is per character unless isGlobal is set.
local function setConfig(ownerAddOn, variable, value, isGlobal)
	local ownerIndex = string.lower(ownerAddOn)
	local varIndex = string.lower(variable)
	if (isGlobal) then
		varIndex = string.lower(UnitName("player")) .. ":" .. varIndex
	end

	if (not StubbyConfig.configs) then StubbyConfig.configs = {} end
	if (not StubbyConfig.configs[ownerIndex]) then StubbyConfig.configs[ownerIndex] = {} end
	StubbyConfig.configs[ownerIndex][varIndex] = value
end

-- This function gets a config variable stored by the above function
-- it will prefer a player specific variable over a global with the
-- same name
local function getConfig(ownerAddOn, variable)
	local ownerIndex = string.lower(ownerAddOn)
	local globalIndex = string.lower(variable)
	local playerIndex = string.lower(UnitName("player")) .. ":" .. globalIndex

	if (not StubbyConfig.configs) then return end
	if (not StubbyConfig.configs[ownerIndex]) then return end
	local curValue = StubbyConfig.configs[ownerIndex][playerIndex]
	if (curValue == nil) then
		curValue = StubbyConfig.configs[ownerIndex][globalIndex]
	end
end

-- This function clears the config variable specified (both the
-- global and player specific) or all config variables for the
-- ownerAddOn if no variable is specified
local function clearConfig(ownerAddOn, variable)
	local ownerIndex = string.lower(ownerAddOn)
	if (not StubbyConfig.configs) then return end
	if (not StubbyConfig.configs[ownerIndex]) then return end
	if (variable) then
		local globalIndex = string.lower(variable)
		local playerIndex = string.lower(UnitName("player")) .. ":" .. globalIndex
		StubbyConfig.configs[ownerIndex][globalIndex] = nil
		StubbyConfig.configs[ownerIndex][playerIndex] = nil
	else
		StubbyConfig.configs[ownerIndex] = nil
	end
end


-- Setup our Stubby global object. All interaction is done
-- via the methods exposed here.
Stubby = {
	Print = chatPrint,
	Events = events,
	HookCall = hookCall,
	SetConfig = setConfig,
	GetConfig = getConfig,
	ClearConfig = clearConfig,
	GetOrigFunc = getOrigFunc,
	LoadWatcher = loadWatcher,
	EventWatcher = eventWatcher,
	RegisterBootCode = registerBootCode,
	RegisterEventHook = registerEventHook,
	RegisterAddOnHook = registerAddOnHook,
	RegisterFunctionHook = registerFunctionHook,
	UnregisterBootCode = unregisterBootCode,
	UnregisterEventHook = unregisterEventHook,
	UnregisterAddOnHook = unregisterAddOnHook,
	UnregisterFunctionHook = unregisterFunctionHook,
	CreateAddOnLoadBootCode = createAddOnLoadBootCode,
	CreateEventLoadBootCode = createEventLoadBootCode,
	CreateFunctionLoadBootCode = createFunctionLoadBootCode,
}


