local modname = ...
local M = {}
_G[modname] = M
package.loaded[modname] = M
local iup = iup
local socket = require("socket") 
local string = string
local tonumber = tonumber
local load = load
local tree = tree
local loadfile = loadfile
local comma = require("comma")
_ENV = M

local ip 
local port 
local limit

local function send_str(ct,str)
	local prefix = string.len(str) .. "\r\n" .. str
	ct:send(prefix)
end

local function recv_str(ct)
	local num = tonumber(ct:receive())
	local str = ct:receive(num)
	return str
end

function farse_recv(ct,t)
	local num = tonumber(ct:receive())
	local str = ct:receive(num)
	--iup.Message("INFO",str)
	local func = load(str,"rcv","bt",t)
	if func then func() end
end

local function load_config()
	local t = {}
	t.db = {}
	local func = loadfile("config.db","bt",t)
	if func then func() end
	t.db.ip = t.db.ip or "127.0.0.1"
	t.db.port = t.db.port or 25
	return t.db
end
local function save_config(db)
	comma.save_io("config.db",db,"db")
end
function set()
 local db = load_config()
 local status,iptemp,porttemp = iup.GetParam("set",nil,"ip %s\nport %i\n",db.ip,db.port) 
 if status then
	 ip = iptemp
	 port = porttemp
	 db.ip = ip
	 db.port = port
	 save_config(db)
 end
end

function refresh()
	if not ip and not port then return end
	local ct = socket.connect(ip,port)
	local str = "getwhite\r\n"
	send_str(ct,str)
	local M = {}
	M.db = {}
	farse_recv(ct,M)
	local white = M.db
	limit = white.limits
	ct:close()
	tree.update(white)
end

function deluser(uname)
	local ct = socket.connect(ip,port)
	local str = "deluser\r\n" .. uname .. "\r\n"
	send_str(ct,str)
	ct:close()	
end
function limits()
 if not limit then return end
 local status
 local temp = limit
 status,temp = iup.GetParam("set",nil,"limits %i\n",temp) 
 if status then
	 limit = temp
	 local ct = socket.connect(ip,port)
	 local str = "setlimits\r\n" .. limit .. "\r\n"
	 send_str(ct,str)
 end
end

function link_menu(menu)
	menu.item_refresh.action = refresh
	--menu.item_limits.action = limits
	menu.item_set.action = set
end

