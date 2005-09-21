--[[
	Auctioneer Addon for World of Warcraft(tm).
	Version: <%version%>
	Revision: $Id$

	Auctioneer command functions.
	Functions to allow setting of values, switching commands etc.
]]


-- GUI Init Variables (Added by MentalPower)
Auctioneer_GUI_Registered = nil;
Auctioneer_Khaos_Registered = nil;


function Auctioneer_Register()
	if (Khaos) then
		if (not Auctioneer_Khaos_Registered) then
			Auctioneer_GUI_Registered = Auctioneer_Register_Khaos();
		end
	end
	-- The following check is to accomodate other GUI libraries other than Khaos relatively easily.
	if (Auctioneer_GUI_Registered == true) then
		return true;
	else 
		return false;
	end
end

function Auctioneer_Register_Khaos()
	local optionSet = {
		id="Auctioneer";
		text="Auctioneer";
		helptext=AUCTIONEER_GUI_MAIN_HELP;
		difficulty=1;
		default={checked=true};
		options={
			{
				id="Header";
				text="Auctioneer";
				helptext=AUCTIONEER_GUI_MAIN_HELP;
				type=K_HEADER;
				difficulty=1;
			};
			{
				id="AuctioneerEnable";
				type=K_TEXT;
				text=AUCTIONEER_GUI_MAIN_ENABLE;
				helptext=AUCT_HELP_ONOFF;
				callback=function(state) if (state.checked) then Auctioneer_Command(AUCT_CMD_ON, "GUI") else Auctioneer_Command(AUCT_CMD_OFF, "GUI") end end;
				feedback=function(state) if (state.checked) then return AUCT_STAT_ON else return AUCT_STAT_OFF end end;
				check=true;
				default={checked=true};
				disabled={checked=false};
				difficulty=1;
			};
			{
				id="AuctioneerLocale";
				type=K_EDITBOX;
				setup = {
					callOn = {"enter", "tab"};
				};
				text=AUCTIONEER_GUI_LOCALE;
				helptext=AUCT_HELP_LOCALE;
				callback = function(state)
					Auctioneer_Command(AUCT_CMD_LOCALE.." "..state.value, "GUI");
				end;
				feedback = function (state)
					return string.format(AUCT_FRMT_ACT_SET, AUCT_CMD_LOCALE, state.value);
				end;
				default = {
					value = Auctioneer_GetLocale();
				};
				disabled = {
					value = Auctioneer_GetLocale();
				};
				dependencies={AuctioneerEnable={checked=true;}};
				difficulty=2;				
			};
			{
				id="ReloadUI";
				type=K_BUTTON;
				setup={
					buttonText = AUCTIONEER_GUI_RELOADUI_BUTTON;
				};
				text=AUCTIONEER_GUI_RELOADUI;
				helptext=AUCTIONEER_GUI_RELOADUI_HELP;
				callback=function() ReloadUI() end;
				feedback=AUCTIONEER_GUI_RELOADUI_FEEDBACK;
				difficulty=3;
			};
			{
				id=AUCT_SHOW_VERBOSE;
				type=K_TEXT;
				text=AUCTIONEER_GUI_VERBOSE;
				helptext=AUCT_HELP_VERBOSE;
				callback=function(state) if (state.checked) then Auctioneer_Command(string.format(AUCT_SHOW_VERBOSE.." "..AUCT_CMD_ON), "GUI") else Auctioneer_Command(string.format(AUCT_SHOW_VERBOSE.." "..AUCT_CMD_OFF), "GUI") end end;
				feedback=function(state) if (state.checked) then return (string.format(AUCT_FRMT_ACT_ENABLE, AUCT_SHOW_VERBOSE)) else return (string.format(AUCT_FRMT_ACT_DISABLE, AUCT_SHOW_VERBOSE)) end end;
				check=true;
				default={checked=true};
				disabled={checked=false};
				dependencies={AuctioneerEnable={checked=true;}};
				difficulty=1;
			};
			{
				id="AuctioneerStatsHeader";
				type=K_HEADER;
				text=AUCTIONEER_GUI_STATS_HEADER;
				helptext=AUCTIONEER_GUI_STATS_HELP;
				difficulty=2;
			};
			{
				id=AUCT_SHOW_STATS;
				type=K_TEXT;
				text=AUCTIONEER_GUI_STATS_ENABLE;
				helptext=AUCT_HELP_STATS;
				callback=function(state) if (state.checked) then Auctioneer_Command(string.format(AUCT_SHOW_STATS.." "..AUCT_CMD_ON), "GUI") else Auctioneer_Command(string.format(AUCT_SHOW_STATS.." "..AUCT_CMD_OFF), "GUI") end end;
				feedback=function(state) if (state.checked) then return (string.format(AUCT_FRMT_ACT_ENABLE, AUCT_SHOW_STATS)) else return (string.format(AUCT_FRMT_ACT_DISABLE, AUCT_SHOW_STATS)) end end;
				check=true;
				default={checked=true};
				disabled={checked=false};
				dependencies={AuctioneerEnable={checked=true;}};
				difficulty=1;
			};
			{
				id=AUCT_SHOW_AVERAGE;
				type=K_TEXT;
				text=AUCTIONEER_GUI_AVERAGES;
				helptext=AUCT_HELP_AVERAGE;
				callback=function(state) if (state.checked) then Auctioneer_Command(string.format(AUCT_SHOW_AVERAGE.." "..AUCT_CMD_ON), "GUI") else Auctioneer_Command(string.format(AUCT_SHOW_AVERAGE.." "..AUCT_CMD_OFF), "GUI") end end;
				feedback=function(state) if (state.checked) then return (string.format(AUCT_FRMT_ACT_ENABLE, AUCT_SHOW_AVERAGE)) else return (string.format(AUCT_FRMT_ACT_DISABLE, AUCT_SHOW_AVERAGE)) end end;
				check=true;
				default={checked=true};
				disabled={checked=false};
				dependencies={AuctioneerEnable={checked=true;}};
				difficulty=2;
			};
			{
				id=AUCT_SHOW_MEDIAN;
				type=K_TEXT;
				text=AUCTIONEER_GUI_MEDIAN;
				helptext=AUCT_HELP_MEDIAN;
				callback=function(state) if (state.checked) then Auctioneer_Command(string.format(AUCT_SHOW_MEDIAN.." "..AUCT_CMD_ON), "GUI") else Auctioneer_Command(string.format(AUCT_SHOW_MEDIAN.." "..AUCT_CMD_OFF), "GUI") end end;
				feedback=function(state) if (state.checked) then return (string.format(AUCT_FRMT_ACT_ENABLE, AUCT_SHOW_MEDIAN)) else return (string.format(AUCT_FRMT_ACT_DISABLE, AUCT_SHOW_MEDIAN)) end end;
				check=true;
				default={checked=true};
				disabled={checked=false};
				dependencies={AuctioneerEnable={checked=true;}};
				difficulty=2;
			};
			{
				id=AUCT_SHOW_SUGGEST;
				type=K_TEXT;
				text=AUCTIONEER_GUI_SUGGEST;
				helptext=AUCT_HELP_SUGGEST;
				callback=function(state) if (state.checked) then Auctioneer_Command(string.format(AUCT_SHOW_SUGGEST.." "..AUCT_CMD_ON), "GUI") else Auctioneer_Command(string.format(AUCT_SHOW_SUGGEST.." "..AUCT_CMD_OFF), "GUI") end end;
				feedback=function(state) if (state.checked) then return (string.format(AUCT_FRMT_ACT_ENABLE, AUCT_SHOW_SUGGEST)) else return (string.format(AUCT_FRMT_ACT_DISABLE, AUCT_SHOW_SUGGEST)) end end;
				check=true;
				default={checked=true};
				disabled={checked=false};
				dependencies={AuctioneerEnable={checked=true;}};
				difficulty=2;
			};
			{
				id="AuctioneerVendorHeader";
				type=K_HEADER;
				text=AUCTIONEER_GUI_VENDOR_HEADER;
				helptext=AUCTIONEER_GUI_VENDOR_HELP;
				difficulty=1;
			};
			{
				id=AUCT_SHOW_VENDOR;
				key="AuctioneerVendor";
				type=K_TEXT;
				text=AUCTIONEER_GUI_VENDOR;
				helptext=AUCT_HELP_VENDOR;
				callback=function(state) if (state.checked) then Auctioneer_Command(string.format(AUCT_SHOW_VENDOR.." "..AUCT_CMD_ON), "GUI") else Auctioneer_Command(string.format(AUCT_SHOW_VENDOR.." "..AUCT_CMD_OFF), "GUI") end end;
				feedback=function(state) if (state.checked) then return (string.format(AUCT_FRMT_ACT_ENABLE, AUCT_SHOW_VENDOR)) else return (string.format(AUCT_FRMT_ACT_DISABLE, AUCT_SHOW_VENDOR)) end end;
				check=true;
				default={checked=true};
				disabled={checked=false};
				dependencies={AuctioneerEnable={checked=true;}};
				difficulty=1;
			};
			{
				id=AUCT_SHOW_VENDOR_BUY;
				type=K_TEXT;
				text=AUCTIONEER_GUI_VENDOR_BUY;
				helptext=AUCT_HELP_VENDOR_BUY;
				callback=function(state) if (state.checked) then Auctioneer_Command(string.format(AUCT_SHOW_VENDOR_BUY.." "..AUCT_CMD_ON), "GUI") else Auctioneer_Command(string.format(AUCT_SHOW_VENDOR_BUY.." "..AUCT_CMD_OFF), "GUI") end end;
				feedback=function(state) if (state.checked) then return (string.format(AUCT_FRMT_ACT_ENABLE, AUCT_SHOW_VENDOR_BUY)) else return (string.format(AUCT_FRMT_ACT_DISABLE, AUCT_SHOW_VENDOR_BUY)) end end;
				check=true;
				default={checked=true};
				disabled={checked=false};
				dependencies={AuctioneerVendor={checked=true;}, AuctioneerEnable={checked=true;}};
				difficulty=2;
			};
			{
				id=AUCT_SHOW_VENDOR_SELL;
				type=K_TEXT;
				text=AUCTIONEER_GUI_VENDOR_SELL;
				helptext=AUCT_HELP_VENDOR_SELL;
				callback=function(state) if (state.checked) then Auctioneer_Command(string.format(AUCT_SHOW_VENDOR_SELL.." "..AUCT_CMD_ON), "GUI") else Auctioneer_Command(string.format(AUCT_SHOW_VENDOR_SELL.." "..AUCT_CMD_OFF), "GUI") end end;
				feedback=function(state) if (state.checked) then return (string.format(AUCT_FRMT_ACT_ENABLE, AUCT_SHOW_VENDOR_SELL)) else return (string.format(AUCT_FRMT_ACT_DISABLE, AUCT_SHOW_VENDOR_SELL)) end end;
				check=true;
				default={checked=true};
				disabled={checked=false};
				dependencies={AuctioneerVendor={checked=true;}, AuctioneerEnable={checked=true;}};
				difficulty=2;
			};
			{
				id="AuctioneerEmbedHeader";
				type=K_HEADER;
				text=AUCTIONEER_GUI_EMBED_HEADER;
				helptext=AUCT_HELP_EMBED;
				difficulty=1;
			};
			{
				id=AUCT_CMD_EMBED;
				key="AuctioneerEmbed";
				type=K_TEXT;
				text=AUCTIONEER_GUI_EMBED;
				helptext=AUCT_HELP_EMBED;
				callback=function(state) if (state.checked) then Auctioneer_Command(string.format(AUCT_CMD_EMBED.." "..AUCT_CMD_ON), "GUI") else Auctioneer_Command(string.format(AUCT_CMD_EMBED.." "..AUCT_CMD_OFF), "GUI") end end;
				feedback=function(state) if (state.checked) then return (string.format(AUCT_FRMT_ACT_ENABLE, AUCT_CMD_EMBED)) else return (string.format(AUCT_FRMT_ACT_DISABLE, AUCT_CMD_EMBED)) end end;
				check=true;
				default={checked=false};
				disabled={checked=false};
				dependencies={AuctioneerEnable={checked=true;}};
				difficulty=1;
			};
			{
				id=AUCT_SHOW_EMBED_BLANK;
				type=K_TEXT;
				text=AUCTIONEER_GUI_EMBED_BLANKLINE;
				helptext=AUCT_HELP_EMBED_BLANK;
				callback=function(state) if (state.checked) then Auctioneer_Command(string.format(AUCT_SHOW_EMBED_BLANK.." "..AUCT_CMD_ON), "GUI") else Auctioneer_Command(string.format(AUCT_SHOW_EMBED_BLANK.." "..AUCT_CMD_OFF), "GUI") end end;
				feedback=function(state) if (state.checked) then return (string.format(AUCT_FRMT_ACT_ENABLE, AUCT_SHOW_EMBED_BLANK)) else return (string.format(AUCT_FRMT_ACT_DISABLE, AUCT_SHOW_EMBED_BLANK)) end end;
				check=true;
				default={checked=false};
				disabled={checked=false};
				dependencies={AuctioneerEmbed={checked=true;}, AuctioneerEnable={checked=true;}};
				difficulty=1;
			};
			{
				id="AuctioneerClearHeader";
				type=K_HEADER;
				text=AUCTIONEER_GUI_CLEAR_HEADER;
				helptext=AUCTIONEER_GUI_CLEAR_HELP;
				difficulty=3;
			};
			{
				id="AuctioneerClearAll";
				type=K_BUTTON;
				setup={
					buttonText = AUCTIONEER_GUI_CLEARALL_BUTTON;
				};
				text=AUCTIONEER_GUI_CLEARALL;
				helptext=AUCTIONEER_GUI_CLEARALL_HELP;
				callback=function() Auctioneer_Command(string.format(AUCT_CMD_CLEAR.." "..AUCT_CMD_CLEAR_ALL), "GUI") end;
				feedback=string.format(AUCT_FRMT_ACT_CLEARALL,  AUCTIONEER_GUI_CLEARALL_NOTE);
				dependencies={AuctioneerEnable={checked=true;}};
				difficulty=3;
			};
			{
				id="AuctioneerClearSnapshot";
				type=K_BUTTON;
				setup={
					buttonText=AUCTIONEER_GUI_CLEARSNAP_BUTTON;
				};
				text=AUCTIONEER_GUI_CLEARSNAP;
				helptext=AUCTIONEER_GUI_CLEARSNAP_HELP;
				callback=function() Auctioneer_Command(string.format(AUCT_CMD_CLEAR.." "..AUCT_CMD_CLEAR_SNAPSHOT), "GUI")end;
				feedback=AUCT_FRMT_ACT_CLEARSNAP;
				dependencies={AuctioneerEnable={checked=true;}};
				difficulty=3;
			};
			{
				id="AuctioneerPercentsHeader";
				type=K_HEADER;
				text=AUCTIONEER_GUI_PERCENTS_HEADER;
				helptext=AUCTIONEER_GUI_PERCENTS_HELP;
				difficulty=4;
			};
			{
				id=AUCT_CMD_PCT_BIDMARKDOWN;
				type=K_EDITBOX;
				setup = {
					callOn = {"enter", "tab"};
				};
				text=AUCTIONEER_GUI_BIDMARKDOWN;
				helptext=AUCT_HELP_PCT_BIDMARKDOWN;
				callback = function(state)
					Auctioneer_Command(string.format(AUCT_CMD_PCT_BIDMARKDOWN.." "..state.value), "GUI");
				end;
				feedback = function (state)
					return string.format(AUCT_FRMT_ACT_SET, AUCT_CMD_PCT_BIDMARKDOWN, state.value.."%");
				end;
				default = {
					value = AUCT_OPT_PCT_BIDMARKDOWN_DEFAULT;
				};
				disabled = {
					value = AUCT_OPT_PCT_BIDMARKDOWN_DEFAULT;
				};
				dependencies={AuctioneerEnable={checked=true;}};
				difficulty=4;				
			};
			{
				id=AUCT_CMD_PCT_MARKUP;
				type=K_EDITBOX;
				setup = {
					callOn = {"enter", "tab"};
				};
				text=AUCTIONEER_GUI_MARKUP;
				helptext=AUCT_HELP_PCT_MARKUP;
				callback = function(state)
					Auctioneer_Command(string.format(AUCT_CMD_PCT_MARKUP.." "..state.value), "GUI");
				end;
				feedback = function (state)
					return string.format(AUCT_FRMT_ACT_SET, AUCT_CMD_PCT_MARKUP, state.value.."%");
				end;
				default = {
					value = AUCT_OPT_PCT_MARKUP_DEFAULT;
				};
				disabled = {
					value = AUCT_OPT_PCT_MARKUP_DEFAULT;
				};
				dependencies={AuctioneerEnable={checked=true;}};
				difficulty=4;
			};
			{
				id=AUCT_CMD_PCT_MAXLESS;
				type=K_EDITBOX;
				setup = {
					callOn = {"enter", "tab"};
				};
				text=AUCTIONEER_GUI_MAXLESS;
				helptext=AUCT_HELP_PCT_MAXLESS;
				callback = function(state)
					Auctioneer_Command(string.format(AUCT_CMD_PCT_MAXLESS.." "..state.value), "GUI");
				end;
				feedback = function (state)
					return string.format(AUCT_FRMT_ACT_SET, AUCT_CMD_PCT_MAXLESS, state.value.."%");
				end;
				default = {
					value = AUCT_OPT_PCT_MAXLESS_DEFAULT;
				};
				disabled = {
					value = AUCT_OPT_PCT_MAXLESS_DEFAULT;
				};
				dependencies={AuctioneerEnable={checked=true;}};
				difficulty=4;
			};
			{
				id=AUCT_CMD_PCT_NOCOMP;
				type=K_EDITBOX;
				setup = {
					callOn = {"enter", "tab"};
				};
				text=AUCTIONEER_GUI_NOCOMP;
				helptext=AUCT_HELP_PCT_NOCOMP;
				callback = function(state)
					Auctioneer_Command(string.format(AUCT_CMD_PCT_NOCOMP.." "..state.value), "GUI");
				end;
				feedback = function (state)
					return string.format(AUCT_FRMT_ACT_SET, AUCT_CMD_PCT_NOCOMP, state.value.."%");
				end;
				default = {
					value = AUCT_OPT_PCT_NOCOMP_DEFAULT;
				};
				disabled = {
					value = AUCT_OPT_PCT_NOCOMP_DEFAULT;
				};
				dependencies={AuctioneerEnable={checked=true;}};
				difficulty=4;
			};
			{
				id=AUCT_CMD_PCT_UNDERLOW;
				type=K_EDITBOX;
				setup = {
					callOn = {"enter", "tab"};
				};
				text=AUCTIONEER_GUI_UNDERLOW;
				helptext=AUCT_HELP_PCT_UNDERLOW;
				callback = function(state)
					Auctioneer_Command(string.format(AUCT_CMD_PCT_UNDERLOW.." "..state.value), "GUI");
				end;
				feedback = function (state)
					return string.format(AUCT_FRMT_ACT_SET, AUCT_CMD_PCT_UNDERLOW, state.value.."%");
				end;
				default = {
					value = AUCT_OPT_PCT_UNDERLOW_DEFAULT;
				};
				disabled = {
					value = AUCT_OPT_PCT_UNDERLOW_DEFAULT;
				};
				dependencies={AuctioneerEnable={checked=true;}};
				difficulty=4;
			};
			{
				id=AUCT_CMD_PCT_UNDERMKT;
				type=K_EDITBOX;
				setup = {
					callOn = {"enter", "tab"};
				};
				text=AUCTIONEER_GUI_UNDERMKT;
				helptext=AUCT_HELP_PCT_UNDERMKT;
				callback = function(state)
					Auctioneer_Command(string.format(AUCT_CMD_PCT_UNDERMKT.." "..state.value), "GUI");
				end;
				feedback = function (state)
					return string.format(AUCT_FRMT_ACT_SET, AUCT_CMD_PCT_UNDERMKT, state.value.."%");
				end;
				default = {
					value = AUCT_OPT_PCT_UNDERMKT_DEFAULT;
				};
				disabled = {
					value = AUCT_OPT_PCT_UNDERMKT_DEFAULT;
				};
				dependencies={AuctioneerEnable={checked=true;}};
				difficulty=4;
			};
			{
				id="AuctioneerOtherHeader";
				type=K_HEADER;
				text=AUCTIONEER_GUI_OTHER_HEADER;
				helptext=AUCTIONEER_GUI_OTHER_HELP;
				difficulty=1;
			};
			{
				id=AUCT_CMD_AUTOFILL;
				type=K_TEXT;
				text=AUCTIONEER_GUI_AUTOFILL;
				helptext=AUCT_HELP_AUTOFILL;
				callback=function(state) if (state.checked) then Auctioneer_Command(string.format(AUCT_CMD_AUTOFILL.." "..AUCT_CMD_ON), "GUI") else Auctioneer_Command(string.format(AUCT_CMD_AUTOFILL.." "..AUCT_CMD_OFF), "GUI") end end;
				feedback=function(state) if (state.checked) then return (string.format(AUCT_FRMT_ACT_ENABLE, AUCT_CMD_AUTOFILL)) else return (string.format(AUCT_FRMT_ACT_DISABLE, AUCT_CMD_AUTOFILL)) end end;
				check=true;
				default={checked=true};
				disabled={checked=false};
				dependencies={AuctioneerEnable={checked=true;}};
				difficulty=1;
			};
			{
				id="AuctioneerInclude";
				type=K_EDITBOX;
				setup = {
					callOn = {"enter", "tab"};
				};
				text=AUCTIONEER_GUI_ALSO;
				helptext=AUCT_HELP_ALSO;
				callback = function(state)
					Auctioneer_Command(string.format(AUCT_CMD_ALSO.." "..state.value), "GUI");
				end;
				feedback = function (state)
					if (state.value == opposite) then
						return AUCTIONEER_GUI_ALSO_OPPOSITE;
					elseif (state.value == off) then
						return AUCTIONEER_GUI_ALSO_OFF;
					elseif (not Auctioneer_IsValidAlso(param)) then
						string.format(AUCT_FRMT_UNKNOWN_RF, state.value)
					else
						return string.format(AUCTIONEER_GUI_ALSO_DISPLAY, state.value);
					end
				end;
				default = {
					value = AUCT_CMD_OFF;
				};
				disabled = {
					value = AUCT_CMD_OFF;
				};
				dependencies={AuctioneerEnable={checked=true;}};
				difficulty=2;
			};
			--Oops, not yet implemented :)
			--[[
			{
				id=AUCT_SHOW_HSP;
				type=K_TEXT;
				text="Show Highest Sellable Price (HSP)";
				helptext=AUCT_HELP_HSP;
				callback=function(state) if (state.checked) then Auctioneer_Command(string.format(AUCT_SHOW_HSP.." "..AUCT_CMD_ON), "GUI") else Auctioneer_Command(string.format(AUCT_SHOW_HSP.." "..AUCT_CMD_OFF), "GUI") end end;
				feedback=function(state) if (state.checked) then return (string.format(AUCT_FRMT_ACT_ENABLE, AUCT_SHOW_HSP)) else return (string.format(AUCT_FRMT_ACT_DISABLE, AUCT_SHOW_HSP)) end end;
				check=true;
				default={checked=false};
				disabled={checked=false};
				difficulty=3;
			};
			]]--
			{
				id=AUCT_SHOW_LINK;
				type=K_TEXT;
				text=AUCTIONEER_GUI_LINK;
				helptext=AUCT_HELP_LINK;
				callback=function(state) if (state.checked) then Auctioneer_Command(string.format(AUCT_SHOW_LINK.." "..AUCT_CMD_ON), "GUI") else Auctioneer_Command(string.format(AUCT_SHOW_LINK.." "..AUCT_CMD_OFF), "GUI") end end;
				feedback=function(state) if (state.checked) then return (string.format(AUCT_FRMT_ACT_ENABLE, AUCT_SHOW_LINK)) else return (string.format(AUCT_FRMT_ACT_DISABLE, AUCT_SHOW_LINK)) end end;
				check=true;
				default={checked=false};
				disabled={checked=false};
				dependencies={AuctioneerEnable={checked=true;}};
				difficulty=3;
			};
		};
	};

	Khaos.registerOptionSet("tooltip",optionSet);
	Auctioneer_Khaos_Registered = true;
	
	return true;
end

--Cleaner Command Handling Functions (added by MentalPower)
function Auctioneer_Command(command, source)
	
	--To print or not to print, that is the question...
	local chatprint = nil;
	if (source == "GUI") then 
		chatprint = false;
	else 
		chatprint = true;
	end;
	
	--Divide the large command into smaller logical sections (Shameless copy from the original function)
	local i,j, cmd, param = string.find(command, "^([^ ]+) (.+)$");

	if (not cmd) then
		cmd = command;
	end

	if (not cmd) then
		cmd = "";
	end

	if (not param) then
		param = "";
	end

	--Now for the real Command handling
	if ((cmd == "") or (cmd == "help")) then
		Auctioneer_ChatPrint_Help();
		return;

	elseif (((cmd == AUCT_CMD_ON) or (cmd == "on")) or ((cmd == AUCT_CMD_OFF) or (cmd == "off")) or ((cmd == AUCT_CMD_TOGGLE) or (cmd == "toggle"))) then
		Auctioneer_OnOff(cmd, chatprint);

	elseif ((cmd == AUCT_CMD_CLEAR) or (cmd == "clear")) then
		Auctioneer_Clear(param, chatprint);

	elseif ((cmd == AUCT_CMD_ALSO) or (cmd == "also")) then
		Auctioneer_AlsoInclude(param, chatprint);
	
	elseif ((cmd == AUCT_CMD_LOCALE) or (cmd == "locale")) then
		Auctioneer_SetLocale(param, chatprint);

	elseif ((cmd == AUCT_CMD_DEFAULT) or (cmd == "default")) then
		Auctioneer_Default(param, chatprint);

	--The following are copied verbatim from the original function. These functions are not supported in the current Khaos-based GUI implementation and as such have been left intact.
	elseif ((cmd == AUCT_CMD_BROKER) or (cmd == "broker")) then
		Auctioneer_DoBroker(param);

	elseif ((cmd == AUCT_CMD_BIDBROKER) or (cmd == AUCT_CMD_BIDBROKER_SHORT)
		or (cmd == "bidbroker") or (cmd == "bb")) then
		Auctioneer_DoBidBroker(param);

	elseif ((cmd == AUCT_CMD_PERCENTLESS) or (cmd == AUCT_CMD_PERCENTLESS_SHORT)
		or (cmd == "percentless") or (cmd == "pl")) then
		Auctioneer_DoPercentLess(param);

	elseif ((cmd == AUCT_CMD_COMPETE) or (cmd == "compete")) then
		Auctioneer_DoCompeting(param);

	elseif ((cmd == AUCT_CMD_SCAN) or (cmd == "scan")) then
		Auctioneer_RequestAuctionScan();

	elseif (cmd == "low") then
		Auctioneer_DoLow(param);

	elseif (cmd == "med") then
		Auctioneer_DoMedian(param);

	elseif (cmd == "hsp") then
		Auctioneer_DoHSP(param);

	elseif (
		((cmd == AUCT_CMD_EMBED) or (cmd == "embed")) or
		((cmd == AUCT_CMD_AUTOFILL) or (cmd == "autofill")) or
		((cmd == AUCT_SHOW_VERBOSE) or (cmd == "show-verbose")) or
		((cmd == AUCT_SHOW_AVERAGE) or (cmd == "show-average")) or
		((cmd == AUCT_SHOW_LINK) or (cmd == "show-link")) or
		((cmd == AUCT_SHOW_MEDIAN) or (cmd == "show median")) or
		((cmd == AUCT_SHOW_STACK) or (cmd == "show-stack")) or
		((cmd == AUCT_SHOW_STATS) or (cmd == "show-stats")) or
		((cmd == AUCT_SHOW_SUGGEST) or (cmd == "show-suggest")) or
		((cmd == AUCT_SHOW_USAGE) or (cmd == "show-usage")) or
		((cmd == AUCT_SHOW_VENDOR) or (cmd == "show-vendor")) or
		((cmd == AUCT_SHOW_VENDOR_BUY) or (cmd == "show-vendor-buy")) or
		((cmd == AUCT_SHOW_VENDOR_SELL) or (cmd == "show-vendor-sell")) or		
		((cmd == AUCT_SHOW_EMBED_BLANK) or (cmd == "show-embed-blankline")) or
		((cmd == AUCT_SHOW_HSP) or (cmd == "show-hsp")) --This command has not yet been implemented.
	) then
		Auctioneer_GenVarSet(cmd, param, chatprint);

	elseif (
		((cmd == AUCT_CMD_PCT_BIDMARKDOWN) or(cmd == "pct-bidmarkdown")) or
		((cmd == AUCT_CMD_PCT_MARKUP) or(cmd == "pct-markup")) or
		((cmd == AUCT_CMD_PCT_MAXLESS) or(cmd == "pct-maxless")) or
		((cmd == AUCT_CMD_PCT_NOCOMP) or(cmd == "pct-nocomp")) or
		((cmd == AUCT_CMD_PCT_UNDERLOW) or(cmd == "pct-underlow")) or
		((cmd == AUCT_CMD_PCT_UNDERMKT) or (cmd == "pct-undermkt"))
	) then
		Auctioneer_PercentVarSet(cmd, param, chatprint);

	else
		if (chatprint == true) then
			Auctioneer_ChatPrint(string.format(AUCT_FRMT_ACT_UNKNOWN, cmd));
		end
	end
end

--Help ME!! (The Handler) (Another shameless copy from the original function)
function Auctioneer_ChatPrint_Help()

	local onOffToggle = " ("..AUCT_CMD_ON.."|"..AUCT_CMD_OFF.."|"..AUCT_CMD_TOGGLE..")";
	local lineFormat = "  |cffffffff/auctioneer %s "..onOffToggle.."|r |cff2040ff[%s]|r - %s";

	Auctioneer_ChatPrint(AUCT_TEXT_USAGE);
	Auctioneer_ChatPrint("  |cffffffff/auctioneer "..onOffToggle.."|r |cff2040ff["..Auctioneer_GetFilterVal("all").."]|r - " .. AUCT_HELP_ONOFF);
	
	Auctioneer_ChatPrint(string.format(lineFormat, AUCT_SHOW_VERBOSE, Auctioneer_GetFilterVal(AUCT_SHOW_VERBOSE), AUCT_HELP_VERBOSE));
	Auctioneer_ChatPrint(string.format(lineFormat, AUCT_SHOW_AVERAGE, Auctioneer_GetFilterVal(AUCT_SHOW_AVERAGE), AUCT_HELP_AVERAGE));
	Auctioneer_ChatPrint(string.format(lineFormat, AUCT_SHOW_MEDIAN, Auctioneer_GetFilterVal(AUCT_SHOW_MEDIAN), AUCT_HELP_MEDIAN));
	Auctioneer_ChatPrint(string.format(lineFormat, AUCT_SHOW_SUGGEST, Auctioneer_GetFilterVal(AUCT_SHOW_SUGGEST), AUCT_HELP_SUGGEST));
	Auctioneer_ChatPrint(string.format(lineFormat, AUCT_SHOW_STATS, Auctioneer_GetFilterVal(AUCT_SHOW_STATS), AUCT_HELP_STATS));
	Auctioneer_ChatPrint(string.format(lineFormat, AUCT_SHOW_VENDOR, Auctioneer_GetFilterVal(AUCT_SHOW_VENDOR), AUCT_HELP_VENDOR));
	Auctioneer_ChatPrint(string.format(lineFormat, AUCT_SHOW_VENDOR_SELL, Auctioneer_GetFilterVal(AUCT_SHOW_VENDOR_SELL), AUCT_HELP_VENDOR_SELL));
	Auctioneer_ChatPrint(string.format(lineFormat, AUCT_SHOW_VENDOR_BUY, Auctioneer_GetFilterVal(AUCT_SHOW_VENDOR_BUY), AUCT_HELP_VENDOR_BUY));
	Auctioneer_ChatPrint(string.format(lineFormat, AUCT_SHOW_USAGE, Auctioneer_GetFilterVal(AUCT_SHOW_USAGE), AUCT_HELP_USAGE));
	Auctioneer_ChatPrint(string.format(lineFormat, AUCT_SHOW_STACK, Auctioneer_GetFilterVal(AUCT_SHOW_STACK), AUCT_HELP_STACK));
	Auctioneer_ChatPrint(string.format(lineFormat, AUCT_SHOW_LINK, Auctioneer_GetFilterVal(AUCT_SHOW_LINK), AUCT_HELP_LINK));
	Auctioneer_ChatPrint(string.format(lineFormat, AUCT_CMD_AUTOFILL, Auctioneer_GetFilterVal(AUCT_CMD_AUTOFILL), AUCT_HELP_AUTOFILL));
	Auctioneer_ChatPrint(string.format(lineFormat, AUCT_CMD_EMBED, Auctioneer_GetFilterVal(AUCT_CMD_EMBED), AUCT_HELP_EMBED));
	Auctioneer_ChatPrint(string.format(lineFormat, AUCT_SHOW_EMBED_BLANK, Auctioneer_GetFilterVal(AUCT_SHOW_EMBED_BLANK), AUCT_HELP_EMBED_BLANK));

	lineFormat = "  |cffffffff/auctioneer %s %s|r |cff2040ff[%s]|r - %s";
	Auctioneer_ChatPrint(string.format(lineFormat, AUCT_CMD_LOCALE, AUCT_OPT_LOCALE, Auctioneer_GetFilterVal('locale'), AUCT_HELP_LOCALE));

	Auctioneer_ChatPrint(string.format(lineFormat, AUCT_CMD_PCT_MARKUP, AUCT_OPT_PCT_MARKUP, Auctioneer_GetFilterVal(AUCT_CMD_PCT_MARKUP, AUCT_OPT_PCT_MARKUP_DEFAULT), AUCT_HELP_PCT_MARKUP));
	Auctioneer_ChatPrint(string.format(lineFormat, AUCT_CMD_PCT_BIDMARKDOWN, AUCT_OPT_PCT_BIDMARKDOWN, Auctioneer_GetFilterVal(AUCT_CMD_PCT_BIDMARKDOWN, AUCT_OPT_PCT_BIDMARKDOWN_DEFAULT), AUCT_HELP_PCT_BIDMARKDOWN));
	Auctioneer_ChatPrint(string.format(lineFormat, AUCT_CMD_PCT_NOCOMP, AUCT_OPT_PCT_NOCOMP, Auctioneer_GetFilterVal(AUCT_CMD_PCT_NOCOMP, AUCT_OPT_PCT_NOCOMP_DEFAULT), AUCT_HELP_PCT_NOCOMP));
	Auctioneer_ChatPrint(string.format(lineFormat, AUCT_CMD_PCT_UNDERLOW, AUCT_OPT_PCT_UNDERLOW, Auctioneer_GetFilterVal(AUCT_CMD_PCT_UNDERLOW, AUCT_OPT_PCT_UNDERLOW_DEFAULT), AUCT_HELP_PCT_UNDERLOW));
	Auctioneer_ChatPrint(string.format(lineFormat, AUCT_CMD_PCT_UNDERMKT, AUCT_OPT_PCT_UNDERMKT, Auctioneer_GetFilterVal(AUCT_CMD_PCT_UNDERMKT, AUCT_OPT_PCT_UNDERMKT_DEFAULT), AUCT_HELP_PCT_UNDERMKT));
	Auctioneer_ChatPrint(string.format(lineFormat, AUCT_CMD_PCT_MAXLESS, AUCT_OPT_PCT_MAXLESS, Auctioneer_GetFilterVal(AUCT_CMD_PCT_MAXLESS, AUCT_OPT_PCT_MAXLESS_DEFAULT), AUCT_HELP_PCT_MAXLESS));

	lineFormat = "  |cffffffff/auctioneer %s %s|r - %s";
	Auctioneer_ChatPrint(string.format(lineFormat, AUCT_CMD_CLEAR, AUCT_OPT_CLEAR, AUCT_HELP_CLEAR));
	Auctioneer_ChatPrint(string.format(lineFormat, AUCT_CMD_ALSO, AUCT_OPT_ALSO, AUCT_HELP_ALSO));
	Auctioneer_ChatPrint(string.format(lineFormat, AUCT_CMD_BROKER, AUCT_OPT_BROKER, AUCT_HELP_BROKER));
	Auctioneer_ChatPrint(string.format(lineFormat, AUCT_CMD_BIDBROKER, AUCT_OPT_BIDBROKER, AUCT_HELP_BIDBROKER));
	Auctioneer_ChatPrint(string.format(lineFormat, AUCT_CMD_PERCENTLESS, AUCT_OPT_PERCENTLESS, AUCT_HELP_PERCENTLESS));
	Auctioneer_ChatPrint(string.format(lineFormat, AUCT_CMD_COMPETE, AUCT_OPT_COMPETE, AUCT_HELP_COMPETE));
	Auctioneer_ChatPrint(string.format(lineFormat, AUCT_CMD_SCAN, AUCT_OPT_SCAN, AUCT_HELP_SCAN));

end

--The Auctioneer_OnOff(state, chatprint) function handles the state of the Auctioneer AddOn (whether it is currently on or off)
--If "on" or "off" is specified in the " state" variable then Auctioneer's state is changed to that value,
--If "toggle" is specified then it will toggle Auctioneer's state (if currently on then it will be turned off and vice-versa)
--If no keyword is specified then the functione will simply return the current state
--
--If chatprint is "true" then the state will also be printed to the user.

function Auctioneer_OnOff(state, chatprint)

	if ((state == nil) or (state == "")) then
		state = Auctioneer_GetFilterVal("all");


	elseif ((state == AUCT_CMD_ON) or (state == "on")) then
		Auctioneer_SetFilter("all", "on");


	elseif ((state == AUCT_CMD_OFF) or (state == "off")) then
		Auctioneer_SetFilter("all", "off");


	elseif ((state == AUCT_CMD_TOGGLE) or (state == "toggle")) then
		state = Auctioneer_GetFilterVal("all");

		if (state == "off") then
			Auctioneer_SetFilter("all", "on");
		else
			Auctioneer_SetFilter("all", "off");
		end
	end

	--Print the change and alert the GUI if the command came from slash commands. Do nothing if they came from the GUI.
	if (chatprint == true) then
		if ((state == AUCT_CMD_ON) or (state == "on")) then
			Auctioneer_ChatPrint(AUCT_STAT_ON);

			if (Auctioneer_Khaos_Registered) then
				Khaos.setSetKeyParameter("Auctioneer", "AuctioneerEnable", "checked", true);
			end
		else
			Auctioneer_ChatPrint(AUCT_STAT_OFF);

			if (Auctioneer_Khaos_Registered) then
				Khaos.setSetKeyParameter("Auctioneer", "AuctioneerEnable", "checked", false);
			end
		end
	end

	return state;	
end

--The following functions are almost verbatim copies of the original functions but modified in order to make them compatible with direct GUI access.
function Auctioneer_Clear(param, chatprint)

	local aKey = Auctioneer_GetAuctionKey();
	local clearok = nil;

	if ((param == AUCT_CMD_CLEAR_ALL) or (param == "all")) then

		AuctionConfig.data = {};
		AuctionConfig.info = {};
		AuctionConfig.snap = {};
		AuctionConfig.sbuy = {};

	elseif ((param == AUCT_CMD_CLEAR_SNAPSHOT) or (param == "snapshot")) then

		AuctionConfig.snap = {};
		AuctionConfig.sbuy = {};
		lSnapshotItemPrices = {}; 

	else

		local items = Auctioneer_GetItems(param);
		if (items) then
			for pos,itemKey in pairs(items) do
				if (AuctionConfig.data[aKey][itemKey] ~= nil) then
					AuctionConfig.data[aKey][itemKey] = nil;
					clearok = true;
				else
					clearok = false;
				end
			end
		end
	end

	if (chatprint == true) then

		if ((param == AUCT_CMD_CLEAR_ALL) or (param == "all")) then
			Auctioneer_ChatPrint(string.format(AUCT_FRMT_ACT_CLEARALL, aKey));

		elseif ((param == AUCT_CMD_CLEAR_SNAPSHOT) or (param == "snapshot")) then
			Auctioneer_ChatPrint(AUCT_FRMT_ACT_CLEARSNAP);

		else
			if (clearok == true) then
				Auctioneer_ChatPrint(string.format(AUCT_FRMT_ACT_CLEAR_OK, itemKey));

			else
				Auctioneer_ChatPrint(string.format(AUCT_FRMT_ACT_CLEAR_FAIL, itemKey));
			end
		end
	end
end


function Auctioneer_AlsoInclude(param, chatprint)

	if ((param == AUCT_CMD_ALSO_OPPOSITE) or (param == "opposite")) then
		param = "opposite";
	end

	if (not Auctioneer_IsValidAlso(param)) then

		if (chatprint == true) then 
			Auctioneer_ChatPrint(string.format(AUCT_FRMT_UNKNOWN_RF, param));
		end
		return
	end
	
	Auctioneer_SetFilter("also", param);
	
	if (chatprint == true) then 
		
		if (Auctioneer_Khaos_Registered) then 
			Khaos.setSetKeyParameter("Auctioneer", "AuctioneerInclude", "value", param);
		end

		if ((param == AUCT_CMD_OFF) or (param == "off")) then
			Auctioneer_ChatPrint(string.format(AUCT_FRMT_ACT_DISABLE, AUCT_CMD_ALSO));	

		else
			Auctioneer_ChatPrint(string.format(AUCT_FRMT_ACT_SET, AUCT_CMD_ALSO, param));
		end	
	end
end


function Auctioneer_SetLocale(param, chatprint)

local validLocale=nil;

	if (param == Auctioneer_GetLocale()) then
		--Do Nothing
		validLocale=true;
	elseif (AUCT_VALID_LOCALES[param]) then
		Auctioneer_SetFilter('locale', param);
		Auctioneer_SetLocaleStrings(Auctioneer_GetLocale());
		Auctioneer_BuildBaseData();
		validLocale=true;

	elseif (param == '') or (param == 'default') or (param == 'off') then
		Auctioneer_SetFilter('locale', 'default');
		Auctioneer_SetLocaleStrings(Auctioneer_GetLocale());
		validLocale=true;
	end
	
	
	if (chatprint == true) then

		if ((validLocale == true) and (AUCT_VALID_LOCALES[param])) then
			Auctioneer_ChatPrint(string.format(AUCT_FRMT_ACT_SET, AUCT_CMD_LOCALE, param));
			
			if (Auctioneer_Khaos_Registered) then
				Khaos.setSetKeyParameter("Auctioneer", "AuctioneerLocale", "value", param);
			end

		elseif (validLocale == nil) then
			Auctioneer_ChatPrint(string.format(AUCT_FRMT_UNKNOWN_LOCALE, param));

			if (AUCT_VALID_LOCALES) then
				for locale, x in pairs(AUCT_VALID_LOCALES) do
					Auctioneer_ChatPrint("  "..locale);
				end
			end

		else
			Auctioneer_ChatPrint(string.format(AUCT_FRMT_ACT_SET, AUCT_CMD_LOCALE, 'default'));

			if (Auctioneer_Khaos_Registered) then
				Khaos.setSetKeyParameter("Auctioneer", "AuctioneerLocale", "value", "default");
			end
		end
	end
end


function Auctioneer_Default(param, chatprint)

	if ((param == AUCT_CMD_CLEAR_ALL) or (param == "all") or (param == "") or (param == nil)) then
		AuctionConfig = {};

	else
		Auctioneer_SetFilter(param, nil);
	end

	if (chatprint == true) then
		if ((param == AUCT_CMD_CLEAR_ALL) or (param == "all")) then
			Auctioneer_ChatPrint(AUCT_FRMT_ACT_DEFAULTALL);

		else
			Auctioneer_ChatPrint(string.format(AUCT_FRMT_ACT_DEFAULT, param));
		end
	end
end


function Auctioneer_GenVarSet(variable, param, chatprint)

	if ((param == AUCT_CMD_ON) or (param == "on")) then
		Auctioneer_SetFilter(variable, "on");

	elseif ((param == AUCT_CMD_OFF) or (param == "off")) then
		Auctioneer_SetFilter(variable, "off");

	elseif ((param == AUCT_CMD_TOGGLE) or (param == "toggle") or (param == nil) or (param == "")) then
		param = Auctioneer_GetFilterVal(variable);

		if (param == "on") then
			param = "off";

		else
			param = "on";
		end

		Auctioneer_SetFilter(variable, param);
	end

	if (chatprint == true) then	

		if ((param == AUCT_CMD_ON) or (param == "on")) then
			Auctioneer_ChatPrint(string.format(AUCT_FRMT_ACT_ENABLE, variable));

			--Account for different key name in the embed variable
			if ((variable == AUCT_CMD_EMBED) or (variable == "embed")) then

				if (Auctioneer_Khaos_Registered) then
					Khaos.setSetKeyParameter("Auctioneer", "AuctioneerEmbed", "checked", true);
				end
			else

				if (Auctioneer_Khaos_Registered) then
					Khaos.setSetKeyParameter("Auctioneer", variable, "checked", true);
				end
			end

		elseif ((param == AUCT_CMD_OFF) or (param == "off")) then
			Auctioneer_ChatPrint(string.format(AUCT_FRMT_ACT_DISABLE, variable));

			--Account for different key name in the embed variable
			if ((variable == AUCT_CMD_EMBED) or (variable == "embed")) then

				if (Auctioneer_Khaos_Registered) then
					Khaos.setSetKeyParameter("Auctioneer", "AuctioneerEmbed", "checked", false);
				end
			else

				if (Auctioneer_Khaos_Registered) then
					Khaos.setSetKeyParameter("Auctioneer", variable, "checked", false);
				end
			end
		end
	end
end


function Auctioneer_PercentVarSet(variable, param, chatprint)

	local paramVal = tonumber(param);
	if paramVal == nil then
		-- failed to convert the param to a number
		if chatprint then
			Auctioneer_ChatPrint(string.format(AUCT_FRMT_UNKNOWN_ARG, param, variable));
		end
		return -- invalid argument, don't do anything
	end
	-- param is a valid number, save it
	Auctioneer_SetFilter(variable, paramVal);

	if (chatprint == true) then
		Auctioneer_ChatPrint(string.format(AUCT_FRMT_ACT_SET, variable, paramVal.."%"));

		if (Auctioneer_Khaos_Registered) then
			Khaos.setSetKeyParameter("Auctioneer", variable, "value", paramVal);
		end
	end
end

--This marks the end of the New Command processing code.
function Auctioneer_SetFilter(type, value)
	if (not AuctionConfig.filters) then AuctionConfig.filters = {}; end
	AuctionConfig.filters[type] = value;
end

function Auctioneer_GetFilterVal(type, default)
	if (default == nil) then default = "on"; end
	if (not AuctionConfig.filters) then AuctionConfig.filters = {}; end
	value = AuctionConfig.filters[type];
	if (not value) then
		if (type == AUCT_SHOW_LINK) then return "off"; end
		if (type == AUCT_CMD_EMBED) then return "off"; end
		return default;
	end
	return value;
end

function Auctioneer_GetFilter(filter)
	value = Auctioneer_GetFilterVal(filter);
	if (value == "on") then return true;
	elseif (value == "off") then return false; end
	return true;
end



function Auctioneer_FindFilterClass(text)
	local totalFilters = getn(CLASS_FILTERS);
	for currentFilter=1, totalFilters do
		if (text == CLASS_FILTERS[currentFilter]) then
			return currentFilter, totalFilters;
		end
	end
	return 0, totalFilters;
end

function AuctFilter_SetFilter(checkbox, filter)
	checkbox.filterVal = filter;
	checkbox:SetChecked(Auctioneer_GetFilter(filter));
	checkbox:SetScale(0.5);
	checkbox:Show();
end

function Auctioneer_GetLocale()
	local locale = Auctioneer_GetFilterVal('locale');
	if (locale ~= 'on') and (locale ~= 'off') and (locale ~= 'default') then
		return locale;
	end
	return GetLocale();
end

function Auctioneer_FilterButton_SetType(button, type, text, isLast)
	Auctioneer_Old_FilterButton_SetType(button, type, text, isLast);

	local buttonName = button:GetName();
	local i,j, buttonID = string.find(buttonName, "(%d+)$");
	buttonID = tonumber(buttonID);

	local checkbox = getglobal(button:GetName().."Checkbox");
	if (type == "class") then
		local classid, maxid = Auctioneer_FindFilterClass(text);
		if (classid > 0) then
			AuctFilter_SetFilter(checkbox, "scan-class"..classid);
			if (classid == maxid) and (buttonID < 15) then
				for i=buttonID+1, 15 do
					getglobal("AuctionFilterButton"..i):Hide();
				end
			end
		else
			checkbox:Hide();
		end
	else
		checkbox:Hide();
	end
end


-- execute the '/auctioneer low <itemName>' that returns the auction for an item with the lowest buyout
function Auctioneer_DoLow(link)
	local itemID, randomProp, enchant, uniqID, itemName = TT_BreakLink(link);
	local itemKey = itemID..":"..randomProp..":"..enchant;

	local auctionSignature = Auctioneer_FindLowestAuctions(itemKey);
	if (not auctionSignature) then
		Auctioneer_ChatPrint(string.format(AUCT_FRMT_NOAUCT, Auctioneer_ColorTextWhite(itemName)));
	else
		local auctKey = Auctioneer_GetAuctionKey();
		local itemCat = Auctioneer_GetCatForKey(itemKey);
		local auction = Auctioneer_GetSnapshot(auctKey, itemCat, auctionSignature);
		local x,x,x, x, count, x, buyout, x = Auctioneer_GetItemSignature(auctionSignature);
		Auctioneer_ChatPrint(string.format(AUCT_FRMT_LOW_LINE, Auctioneer_ColorTextWhite(count.."x")..auction.itemLink, TT_GetTextGSC(buyout), Auctioneer_ColorTextWhite(auction.owner), TT_GetTextGSC(buyout / count), Auctioneer_ColorTextWhite(Auctioneer_PercentLessThan(Auctioneer_GetUsableMedian(itemKey), buyout / count).."%")));
	end
end

function Auctioneer_DoHSP(link)
	local itemID, randomProp, enchant, uniqID, itemName = TT_BreakLink(link);
	local itemKey = itemID..":"..randomProp..":"..enchant;
	local highestSellablePrice = Auctioneer_GetHSP(itemKey, Auctioneer_GetAuctionKey());
	Auctioneer_ChatPrint(string.format(AUCT_FRMT_HSP_LINE, Auctioneer_ColorTextWhite(itemName), TT_GetTextGSC(nilSafeString(highestSellablePrice))));
end


