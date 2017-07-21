local modname = ...
local M = {}
_G[modname] = M
package.loaded[modname] = M
local iup = iup
_ENV = M

local mat = iup.matrix{widthdef=50,SCROLLBAR="YES"}
mat.resizematrix = "YES"
mode_flag = "round"

function get_matrix()
	return mat
end


