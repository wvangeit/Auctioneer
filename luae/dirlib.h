#ifndef dirlib_h
#define dirlib_h

#include "lua.h"

#ifndef DIRLIB_API
#define DIRLIB_API	LUA_API
#endif

#ifndef LUA_EXTRALIBS
#define LUA_EXTRALIBS {"dirlib", luaopen_dir},
#else
#define lua_userinit(L) openstdlibs(L), luaopen_dir(L)
#endif

DIRLIB_API int luaopen_dir (lua_State *L);

#endif
