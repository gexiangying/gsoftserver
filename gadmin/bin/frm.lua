local modname = ...
local M = {}
_G[modname] = M
package.loaded[modname] = M
local iup = iup
_ENV = M

function get_main(MDIMenu,t)
	local sp = iup.split {
		VALUE = 200,
		AUTOHIDE = "YES",
		iup.frame {t},
		iup.canvas { 
				EXPAND = 'YES', 
				MDICLIENT = 'YES',
				SHRINK="YES",	  
			}
	}
	function sp:valuechanged_cb()
		--iup.Redraw(self,1)
		iup.UpdateChildren(self)
	end
	local MainForm = iup.dialog{
		menu = MDIMenu,
		TITLE = "GsoftAdmin",
		PLACEMENT = "MAXIMIZED",
		MDIFRAME = 'YES',
		SHRINK = "YES",
		ICON="SMALL.ICO",

		iup.vbox {
			--[[
			iup.hbox {
				sp,
			},
			--]]
			sp,
			NULL 
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

function get_child(main,content)
	local MDI1Form = iup.dialog{
		TITLE = 'MDI1',
		MDICHILD = 'YES',
		PARENTDIALOG = main,
		PLACEMENT = "FULL",
		RESIZE = "YES",
		--SIZE = '200X150',
		ICON="SMALL.ICO",
		CONTROL="YES",
		SHRINK="YES",
		EXPAND="YES",
		iup.vbox{
			content,EXPAND = 'YES',SHRINK = 'YES'
		}
	}
--	MDI1Form:map()
	return MDI1Form;
end


