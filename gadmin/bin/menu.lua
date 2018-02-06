local modname = ...
local M = {}
_G[modname] = M
package.loaded[modname] = M
local iup = iup
_ENV = M

item_set = iup.item{title="设置服务器",key="K_R"}
item_refresh = iup.item{title="刷新",key="K_R"}
item_limits = iup.item{title="设置节点数",key="K_S"}

menu_file = iup.menu{item_set,item_refresh,item_limits}
--menu_file = iup.menu{item_set,item_refresh}
submenu_file = iup.submenu{menu_file,title="管理"}

mainmenu = iup.menu{submenu_file}

