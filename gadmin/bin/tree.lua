local modname = ...
local M = {}
_G[modname] = M
package.loaded[modname] = M
local iup = iup
local pairs = pairs
local mgr = require("mgr") 
_ENV = M

local t = iup.tree{ RASTERSIZE = '200x',ADDROOT="YES"}
local t1 = iup.tree{ RASTERSIZE = '200x',ADDROOT="YES"}
local vboxA = iup.vbox{t}
local vboxB = iup.vbox{t1}
vboxA.tabtitle = "白名单"
vboxB.tabtitle = "黑名单"
local tabs = iup.tabs{vboxA, vboxB;TABTYPE="BOTTOM"}

local function update_t(white)
	if not white.users then return end
 t.DELNODE0 = "CHILDREN"
 t.name = "white"
 for k,v in pairs(white.users) do
	 if v then
		 t.addleaf0 = k
	 end
 end
end

local function update_t1(white)
	if not white.users then return end
 t1.DELNODE0 = "CHILDREN"
 t1.name = "black"
 for k,v in pairs(white.users) do
	 if not v then
		 t1.addleaf0 = k
	 end
 end

end

function update(white)
	update_t(white)
	update_t1(white)
end

function t:executeleaf_cb(id)
		--iup.Message("HELP",t.name)
		t1.addleaf0 = t.name
		mgr.deluser(t.name)
		t["DELNODE" .. id] = "SELECTED"
end

function t1:executeleaf_cb(id)
		mgr.deluser(t1.name)
		t1["DELNODE" .. id] = "SELECTED"
    --local temp = iup.TreeGetUserId(t1,id)
    --assert(temp,"no userdata")
end

function get_tree()
  return tabs
end

