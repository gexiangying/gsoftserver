package.cpath = "./?53.dll;./?.dll"

require('iuplua')
require( "iupluacontrols" )
require("menu")
require("tree")
require("matrix")
require("frm")
require("mgr")
require("iupluaweb")

mgr.link_menu(menu)

--mat_control = matrix.get_matrix()
myweb = iup.webbrowser{}
--function
--myweb.VALUE = "file://./LuaGL_OpenGL%20binding%20for%20Lua%205.html"
myweb.VALUE = "http://www.w3school.com.cn"
MainForm,sp = frm.get_main(menu.mainmenu,tree.get_tree())
MDI1Form = frm.get_child(MainForm,myweb)


MainForm:show()
MDI1Form:show()

if (iup.MainLoopLevel()==0) then
  iup.MainLoop()
end
