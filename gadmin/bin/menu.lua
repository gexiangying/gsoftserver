local modname = ...
local M = {}
_G[modname] = M
package.loaded[modname] = M
local iup = iup
_ENV = M

item_set = iup.item{title="���÷�����",key="K_R"}
item_refresh = iup.item{title="ˢ��",key="K_R"}
item_limits = iup.item{title="���ýڵ���",key="K_S"}

menu_file = iup.menu{item_set,item_refresh,item_limits}
--menu_file = iup.menu{item_set,item_refresh}
submenu_file = iup.submenu{menu_file,title="����"}

mainmenu = iup.menu{submenu_file}

