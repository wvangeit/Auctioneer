#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <dirent.h>

#include <lua.hpp>
#include <lauxlib.h>
#include <lualib.h>
#include "dirlib.h"

static void setfield (lua_State *L, const char *key, int value) {
  lua_pushstring(L, key);
  lua_pushnumber(L, value);
  lua_rawset(L, -3);
}

static void setboolfield (lua_State *L, const char *key, int value) {
  lua_pushstring(L, key);
  lua_pushboolean(L, value);
  lua_rawset(L, -3);
}

static int os_stat (lua_State *L)
{
  const char *filename = luaL_checkstring(L, 1);
  struct stat st[1];
  if (stat(filename, st) == 0) {
    lua_newtable(L);
    setboolfield(L, "dir", S_ISDIR(st->st_mode));
    setboolfield(L, "reg", S_ISREG(st->st_mode));
    setfield(L, "size", st->st_size);
    setfield(L, "atime", st->st_atime);
    setfield(L, "ctime", st->st_ctime);
    setfield(L, "mtime", st->st_mtime);
    return 1;
  } else {
    lua_pushnil(L);
    lua_pushfstring(L, "failed to stat file %s", filename);
    return 2;
  }
}

static int os_chdir (lua_State *L)
{
  const char *dirname = luaL_checkstring(L, 1);

  if (chdir(dirname) == 0) {
    lua_pushboolean(L, 1);
    return 1;
  } else {
    lua_pushnil(L);
    lua_pushfstring(L, "failed to change to directory %s", dirname);
    return 2;
  }
}


#define DIRHANDLE "DIR*"

static DIR *toDir (lua_State *L, int dindex)
{
  DIR **pd = (DIR **)luaL_checkudata(L, dindex, DIRHANDLE);
  if (pd == 0) luaL_typerror(L, dindex, DIRHANDLE);
  return *pd;
}

static DIR *checkDir(lua_State *L, int dindex)
{
  DIR *d;
  luaL_checktype(L, dindex, LUA_TUSERDATA);
  d = toDir(L, dindex);
  if (!d)
    luaL_error(L, "attempt to use a closed directory");
  return d;
}

static DIR **pushDir (lua_State *L, DIR *d)
{
  DIR **pd = (DIR **)lua_newuserdata(L, sizeof(DIR *));
  *pd = d;
  luaL_getmetatable(L, DIRHANDLE);
  lua_setmetatable(L, -2);
  return pd;
}


static int Dir_read (lua_State *L)
{
  DIR *d = checkDir(L, 1);
  struct dirent *de = readdir(d);
  if (de) {
    lua_pushstring(L, de->d_name);
  } else
    lua_pushnil(L);
  return 1;
}

static int Dir_close (lua_State *L)
{
  DIR *d = checkDir(L, 1);
  int rc = closedir(d);
  if (!rc) {
    *(DIR **)lua_touserdata(L, 1) = 0;  /* mark directory as closed */
    lua_pushboolean(L, 1);
    return 1;
  } else {
    lua_pushnil(L);
    lua_pushfstring(L, "closedir error %d", rc);
    return 2;
  }
}

static int Dir_gc (lua_State *L)
{
  DIR *d = toDir(L, 1);
  if (d) closedir(d);
  return 0;
}

static int Dir_tostring (lua_State *L)
{
  char buff[32];
  DIR *d = toDir(L, 1);
  if (d) sprintf(buff, "%p", lua_touserdata(L, 1));
  else   strcpy(buff, "closed");
  lua_pushfstring(L, "dir (%s)", buff);
  return 1;
}

static const luaL_reg Dir_meta[] = {
  {"read",       Dir_read},
  {"close",      Dir_close},
  {"__gc",       Dir_gc},
  {"__tostring", Dir_tostring},
  {0, 0}
};

static int os_opendir (lua_State *L)
{
  const char *dirname = luaL_checkstring(L, 1);
  DIR **pd = pushDir(L, 0);
  *pd = opendir(dirname);
  if (*pd)
    return 1;
  else {
    lua_pushnil(L);
    lua_pushfstring(L, "failed to open directory %s", dirname);
    return 2;
  }
}

static const luaL_reg Dir_methods[] = {
  {"stat",     os_stat},
  {"chdir",    os_chdir},
  {"opendir",  os_opendir},
  {0, 0}
};

DIRLIB_API int luaopen_dir (lua_State *L)
{
  luaL_register(L, LUA_OSLIBNAME, Dir_methods);  /* add methods to os table */
  luaL_newmetatable(L, DIRHANDLE);  /* create metatable for directory handle,
                                       add it to the Lua registry */
  luaL_register(L, 0, Dir_meta);  /* fill metatable */
  lua_pushliteral(L, "__index");
  lua_pushvalue(L, -2);             /* dup metatable */
  lua_rawset(L, -3);                /* metatable.__index = metatable */
  lua_pushliteral(L, "__metatable");
  lua_pushvalue(L, -2);             /* dup metatable */
  lua_rawset(L, -3);                /* hide metatable:
                                       metatable.__metatable = methods */
  lua_pop(L, 1);                    /* drop metatable */
  return 1;                         /* return os table on the stack */
}
