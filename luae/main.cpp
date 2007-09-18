/**
 **  Luae, A windowed lua execution environment built for Auctioneer's
 **  module building system.
 **
*******************************************************************************
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
*******************************************************************************
 **
 */


#define lua_c

#include <signal.h>
#include <windows.h>
#include <lua.hpp>
#include <lauxlib.h>
#include <lualib.h>
#include <stdlib.h>

#include "dirlib.h"

#define IDC_MAIN_EDIT	101
#define ID_ICON         100

HWND mainWnd;

#define sleep(t) _sleep((long unsigned int)((t) * 1000))

bool exitApp = false;
bool runLoop();

static lua_State *globalL = NULL;

void appendText(const char *output)
{
	HWND dlgWnd = GetDlgItem(mainWnd, IDC_MAIN_EDIT);
	int n = GetWindowTextLength(dlgWnd);
	SendMessage(dlgWnd, EM_SETSEL, n, n);
	SendMessage(dlgWnd, EM_REPLACESEL, 0, (LPARAM)output);
	n = GetWindowTextLength(dlgWnd);
	SendMessage(dlgWnd, EM_SETSEL, n, n);
	SendMessage(dlgWnd, EM_REPLACESEL, 0, (LPARAM)"\r\n");
	SendMessage(dlgWnd, WM_VSCROLL, SB_BOTTOM, (LPARAM)NULL);
}

static void lstop (lua_State *L, lua_Debug *ar) {
	(void)ar;  /* unused arg. */
	lua_sethook(L, NULL, 0, 0);
	luaL_error(L, "interrupted!");
	appendText("Error, interrupted...");
}


static void laction (int i) {
	signal(i, SIG_DFL); /* if another SIGINT happens before lstop,
						   terminate process (default action) */
	lua_sethook(globalL, lstop, LUA_MASKCALL | LUA_MASKRET | LUA_MASKCOUNT, 1);
}

static int traceback (lua_State *L) {
	lua_getfield(L, LUA_GLOBALSINDEX, "debug");
	if (!lua_istable(L, -1)) {
		lua_pop(L, 1);
		return 1;
	}
	lua_getfield(L, -1, "traceback");
	if (!lua_isfunction(L, -1)) {
		lua_pop(L, 2);
		return 1;
	}
	lua_pushvalue(L, 1);  /* pass error message */
	lua_pushinteger(L, 2);  /* skip this function and traceback */
	lua_call(L, 2, 1);  /* call debug.traceback */
	return 1;
}

static int docall (lua_State *L, int narg, int clear) {
	int status;
	int base = lua_gettop(L) - narg;  /* function index */
	lua_pushcfunction(L, traceback);  /* push traceback function */
	lua_insert(L, base);  /* put it under chunk and args */
	signal(SIGINT, laction);
	status = lua_pcall(L, narg, (clear ? 0 : LUA_MULTRET), base);
	signal(SIGINT, SIG_DFL);
	lua_remove(L, base);  /* remove traceback function */
	/* force a complete garbage collection in case of errors */
	if (status != 0) {
		if (!lua_isnil(L, -1)) {
			const char *msg = lua_tostring(L, -1);
            appendText("Error occurred during execution:");
			appendText(msg);
		}
		lua_gc(L, LUA_GCCOLLECT, 0);
	}
	return status;
}

static int print (lua_State *L) {
	char buffer[50];
	int n=lua_gettop(L);
	const char *output;
	if (n > 1)
		output = "";
	else if (lua_isstring(L,1))
		output = lua_tostring(L,1);
	else if (lua_isnil(L,1)==2)
		output = "nil";
	else if (lua_isboolean(L,1))
		output = lua_toboolean(L,1) ? "true" : "false";
	else {
		snprintf(buffer, 50, "%s:%p", luaL_typename(L,1),lua_topointer(L,1));
		output = buffer;
	}
	appendText(output);

	return 0;
}

static int alert (lua_State *L) {
	char buffer[50];
	int n=lua_gettop(L);
	const char *output;
	if (n > 1)
		output = "";
	else if (lua_isstring(L,1))
		output = lua_tostring(L,1);
	else if (lua_isnil(L,1)==2)
		output = "nil";
	else if (lua_isboolean(L,1))
		output = lua_toboolean(L,1) ? "true" : "false";
	else {
		snprintf(buffer, 50, "%s:%p", luaL_typename(L,1),lua_topointer(L,1));
		output = buffer;
	}

	char buf[strlen(output)*2 + 10];
	wsprintf (buf, "Alert: %s", output);
	::MessageBox (0, buf, "Alert", MB_ICONEXCLAMATION | MB_OK);

	return 0;
}

static int exit (lua_State *L) {
	exitApp = true;
	PostQuitMessage(0);
	return 0;
}

static int wait(lua_State *L) {
	runLoop();
	int n=lua_gettop(L);
	double sleepTime = 2;
	if ((n == 1) && (lua_isnumber(L,1)))
		sleepTime = lua_tonumber(L, 1);
	while (sleepTime > 0) {
		sleep(0.1);
		sleepTime -= 0.1;
		runLoop();
	}
	return 0;
}


/*  Declare Windows procedure  */
LRESULT CALLBACK WindowProcedure (HWND, UINT, WPARAM, LPARAM);

/*  Make the class name into a global variable  */
char szClassName[ ] = "WindowsApp";
MSG messages;            /* Here messages to the application are saved */

bool runLoop() {
	if (exitApp) return false;
	while (PeekMessage(&messages, NULL, 0, 0, 1)) {
		/* Translate virtual-key messages into character messages */
		TranslateMessage(&messages);
		/* Send message to WindowProcedure */
		DispatchMessage(&messages);
	}
	if (messages.message == WM_QUIT) {
		exitApp = true;
		return false;
	}
	return true;
}

int WINAPI WinMain (HINSTANCE hThisInstance,
		HINSTANCE hPrevInstance,
		LPSTR lpszArgument,
		int nFunsterStil)

{
	HWND hwnd;               /* This is the handle for our window */
	WNDCLASSEX wincl;        /* Data structure for the windowclass */

	/* The Window structure */
	wincl.hInstance = hThisInstance;
	wincl.lpszClassName = szClassName;
	wincl.lpfnWndProc = WindowProcedure;      /* This function is called by windows */
	wincl.style = CS_DBLCLKS;                 /* Catch double-clicks */
	wincl.cbSize = sizeof (WNDCLASSEX);

	/* Use default icon and mouse-pointer */
	wincl.hIcon = LoadIcon (hThisInstance, MAKEINTRESOURCE(ID_ICON));
	wincl.hIconSm = LoadIcon (hThisInstance, MAKEINTRESOURCE(ID_ICON));
	wincl.hCursor = LoadCursor (NULL, IDC_ARROW);
	wincl.lpszMenuName = NULL;                 /* No menu */
	wincl.cbClsExtra = 0;                      /* No extra bytes after the window class */
	wincl.cbWndExtra = 0;                      /* structure or the window instance */
	/* Use Windows's default color as the background of the window */
	wincl.hbrBackground = (HBRUSH) COLOR_BACKGROUND;

	/* Register the window class, and if it fails quit the program */
	if (!RegisterClassEx (&wincl))
		return 0;

	/* The class is registered, let's create the program*/
	hwnd = CreateWindowEx (
			0,                   /* Extended possibilites for variation */
			szClassName,         /* Classname */
			"Lua Executor",       /* Title Text */
			WS_OVERLAPPEDWINDOW, /* default window */
			CW_USEDEFAULT,       /* Windows decides the position */
			CW_USEDEFAULT,       /* where the window ends up on the screen */
			544,                 /* The programs width */
			375,                 /* and height in pixels */
			HWND_DESKTOP,        /* The window is a child-window to desktop */
			NULL,                /* No menu */
			hThisInstance,       /* Program Instance handler */
			NULL                 /* No Window Creation data */
			);

	mainWnd = hwnd;

	/* Make the window visible on the screen */
	ShowWindow (hwnd, nFunsterStil);

	lua_State *L = lua_open();  /* create state */
	globalL = L;
	luaL_openlibs(L);
	luaopen_dir(L);
	lua_register(L,"print",print);
	lua_register(L,"alert",alert);
	lua_register(L,"sleep",wait);
	lua_register(L,"exit",exit);

	int status = luaL_loadfile(L, "autorun.lua") || docall(L, 0, 1);

	while (runLoop()) {}

	/* The program return-value is 0 - The value that PostQuitMessage() gave */
	return messages.wParam;
}


/*  This function is called by the Windows function DispatchMessage()  */

LRESULT CALLBACK WindowProcedure (HWND hwnd, UINT message, WPARAM wParam, LPARAM lParam)
{

	switch (message)                  /* handle the messages */
	{
		case WM_CREATE:
			{
				HFONT hfDefault;
				HWND hEdit;

				hEdit = CreateWindowEx(WS_EX_CLIENTEDGE, "EDIT", "",
						WS_CHILD | WS_VISIBLE | WS_VSCROLL | WS_HSCROLL | ES_MULTILINE | ES_AUTOVSCROLL | ES_AUTOHSCROLL,
						0, 0, 100, 100, hwnd, (HMENU)IDC_MAIN_EDIT, GetModuleHandle(NULL), NULL);
				if(hEdit == NULL)
					MessageBox(hwnd, "Could not create edit box.", "Error", MB_OK | MB_ICONERROR);

				hfDefault = (HFONT)GetStockObject(DEFAULT_GUI_FONT);
				SendMessage(hEdit, WM_SETFONT, (WPARAM)hfDefault, MAKELPARAM(FALSE, 0));
			}
		case WM_SIZE:
			{
				HWND hEdit;
				RECT rcClient;

				GetClientRect(hwnd, &rcClient);

				hEdit = GetDlgItem(hwnd, IDC_MAIN_EDIT);
				SetWindowPos(hEdit, NULL, 0, 0, rcClient.right, rcClient.bottom, SWP_NOZORDER);
			}
			break;
		case WM_DESTROY:
			PostQuitMessage (0);       /* send a WM_QUIT to the message queue */
			break;
		default:                      /* for messages that we don't deal with */
			return DefWindowProc (hwnd, message, wParam, lParam);
	}

	return 0;
}
