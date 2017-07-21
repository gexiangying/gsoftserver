package.cpath = "./?53.dll;./?.dll"

require('iuplua')
require( "iupluacontrols" )
require("menu")
require("tree")
require("matrix")
require("frm")
require("mgr")

mgr.link_menu(menu)

mat_control = matrix.get_matrix()
MainForm,sp = frm.get_main(menu.mainmenu,tree.get_tree())
MDI1Form = frm.get_child(mat_control)


MainForm:show()
MDI1Form:show()
iup.Refresh(MainForm)


if (iup.MainLoopLevel()==0) then
  iup.MainLoop()
end
