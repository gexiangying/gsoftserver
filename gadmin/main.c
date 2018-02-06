#include <stdio.h>
#include <string.h>
#include <windows.h>
#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"
#define ENABLE_TRACE
#include "trace.h"
HINSTANCE g_hinst = NULL;

static int _trace(const char* str,size_t len)
{
	HANDLE hStdOut=GetStdHandle(STD_OUTPUT_HANDLE);
	if(hStdOut == INVALID_HANDLE_VALUE ){
		return 0;
	}
	unsigned long count = 0;
	WriteFile(hStdOut,str,len,&count,NULL);
	return 0;
}
static int trace(lua_State* L)
{
	size_t len = 0;
	const char* str = lua_tolstring(L,1,&len);
	_trace(str,len);
	return 0;
}
static BOOL b_enable_trace = FALSE;
static int enable_trace(lua_State* L)
{
	b_enable_trace = TRUE;
	TRACE_INIT;
	lua_pushcfunction(L,&trace);
	lua_setglobal(L,"trace_out");
	return 0;
}
static int _dummy(lua_State* L)
{
	return 0;
}
int WINAPI WinMain(HINSTANCE hinstance, HINSTANCE hPrevInstance, // 
		   LPSTR lpCmdLine, int nCmdShow) // 
{				// 
	g_hinst = hinstance;
	lua_State* L = luaL_newstate();	
	lua_pushcfunction(L,&_dummy);
	lua_setglobal(L,"trace_out");
	lua_pushcfunction(L,&enable_trace);
	lua_setglobal(L,"enable_trace");
	luaL_openlibs(L);
	if(luaL_dofile(L,"main.lua") != 0){
		const char* error_str = lua_tostring(L,-1);
		MessageBox(NULL,error_str,"Error",MB_OK);
		lua_pop(L,1);
		lua_close(L);
		return 1;
	}
	lua_close(L);
	if(b_enable_trace)
		TRACE_CLOSE;
	return 0; 
}
