#include <stdio.h>
#include <string.h>
#include <windows.h>
#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"
HINSTANCE g_hinst = NULL;
static int get_computer_name(lua_State* L)
{
	TCHAR name[256];
  DWORD len = 255;
	BOOL bOK = GetComputerName(&name[0],&len);
	lua_pushstring(L,name);
	return 1;
}
int WINAPI WinMain(HINSTANCE hinstance, HINSTANCE hPrevInstance, // 
		   LPSTR lpCmdLine, int nCmdShow) // 
{				// 
	g_hinst = hinstance;
	lua_State* L = luaL_newstate();	
	luaL_openlibs(L);
	if(luaL_dofile(L,"main.lua") != 0){
		const char* error_str = lua_tostring(L,-1);
		MessageBox(NULL,error_str,"Error",MB_OK);
		lua_pop(L,1);
		lua_close(L);
		return 1;
	}
	return 0; 
}
