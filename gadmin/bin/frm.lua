local modname = ...
local M = {}
_G[modname] = M
package.loaded[modname] = M
local iup = iup
_ENV = M

function get_main(MDIMenu,t)
	local sp = iup.split {
		VALUE = '200',
		AUTOHIDE = "YES",
		iup.vbox {
			iup.frame { t, NULL }
		},
		iup.vbox {
			iup.canvas { 
				EXPAND = 'YES', 
				MDICLIENT = 'YES',
				SHRINK="YES",	  
				--     BGCOLOR = '128 128 128' 
				--MDIMENU = MDIMenu
			}

		}
	}
	local MainForm = iup.dialog{
		menu = MDIMenu,
		TITLE = "GsoftAdmin",
		PLACEMENT = "MAXIMIZED",
		MDIFRAME = 'YES',
		SHRINK = "YES",
		ICON="SMALL.ICO",

		iup.vbox {
			iup.hbox {
				sp,
			},
			NULL, 
		},
	}

	function MainForm:show_cb(state)
	  --sp.VALUE = nil
	  --iup.Flush()
	  --iup.RefreshChildren(sp)
	  --mat_control.SHOW = "1:1"
	  --mat_control.REDRAW = "ALL"
	  --iup.Flush()
	  --iup.Map(mat_control)
	  --iup.RefreshChildren(MDI1Form)
	  --mat_control:setcell(0,0,mat_control:getcell(0,0))
	  iup.UpdateChildren(MainForm)
	end
	MainForm:map()

	return MainForm,sp
end

function get_child(mat)
	local MDI1Form = iup.dialog{
		TITLE = 'MDI1',
		MDICHILD = 'YES',
		PARENTDIALOG = MainForm,
		PLACEMENT = "FULL",
		RESIZE = "YES",
		ICON="SMALL.ICO",
		CONTROL="YES",
		SHRINK="YES",
		EXPAND="YES",
		iup.vbox{mat,EXPAND="YES",SHRINK="YES"}
	}
	MDI1Form:map()
	return MDI1Form;
end


