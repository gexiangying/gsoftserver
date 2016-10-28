package.cpath = "./?53.dll;./?.dll"
require "ado" 
local config = require("config")
local cs = {}
local cmds = {}
tasklist = {}
local user = {}

hub_start("localhost",config.port,10,60) --ip port max_accept max_accept_seconds
local db
local function open_db(server,database,uid,pwd)
	local db_string = string.format("Provider=SQLOLEDB;Server=%s;Database=%s;uid=%s;pwd=%s",server,database,uid,pwd)
	--local db_string = "Provider=Microsoft.ACE.OLEDB.12.0;Data Source=test.mdb"
	--db:connect(db_string)
	db = ADO_Open(db_string)
end


local function insertdata(tb,username,ip,startdatetime,enddatetime,totaltimes,appname,apptitle)
	local str = "INSERT INTO " .. tb  .. "(username,ip,startdatetime,enddatetime,totaltimes,appname,apptitle) VALUES ('" .. username .. "','" .. ip .. "','" .. startdatetime .. "','" .. enddatetime .. "','"  .. totaltimes .. "','" .. appname .. "','" .. apptitle .. "')"
	local f = io.open("sql.txt","a")
	f:write(str .. "\n")
	f:close()
--	db:exec(str)
end

local function fmt_data(datetime)
	return os.date("%Y-%m-%d %X",datetime)
end

local function log(f,exename,ip,starttime,endtime,title)
	exename = string.format("%-32s",exename)
	f:write(exename .. "\t" .. title .. "\t" .. ip .. "\t" .. os.date("%Y-%m-%d %X",starttime) .. "\t" .. os.date("%Y-%m-%d %X",endtime) .. "\r\n")
end

local function trigger(ip,delay)
	local f 
	local t = tasklist[ip]

  local log_sql = false
	local log_file = false

	for k,v in pairs(t) do
		local seconds = v.cur - v.start
		local period = os.time() - v.cur
		if period > delay then
			if config.log_file then
				if not log_file then
					f = io.open("log.txt","a")
					log_file = true
				end
				log(f,v.exe,ip,v.start,v.cur,v.title)
			end

			if config.log_sql then
				if not log_sql then
					open_db(config.server,config.database,config.uid,config.pwd)
					log_sql = true
				end
				insertdata(config.tb,user[ip] or ip,ip,fmt_data(v.start),fmt_data(v.cur),seconds,v.exe,v.title)
			end

			if config.trace then
				trace_out("\n*********************************************************************\n")
				trace_out(v.exe .. "@" .. (user[ip] or ip ).. "::"  .. os.date("%x %X",v.start) .. "-----" .. os.date("%x %X",v.cur) .. "\n")
				trace_out("*********************************************************************\n\n")
			end
			t[k] = nil
		elseif config.trace then
			trace_out(v.exe .. "(" .. v.title .. ")" .. "@" .. (user[ip] or ip) .. "::" .. os.date("%x %X",v.start) .. "-----" .. seconds .. " seconds\n")
		end
	end
	if log_file then
		f:close()
	end
	if log_sql then
		db:close()	
	end
end


function cmds.whoami(content,line)
  local domain_name,name = string.match(line,"(.*)\\(%w+)")
	local ip = hub_addr(content)
	user[ip] = name
	if config.trace then
		trace_out("domain_name:" .. domain_name .. " user: " .. name .. "\n")
	end
end

function cmds.systeminfo(content,line)
	trace_out(line)
end

function cmds.tasklist(content,line)
	trace_out("cmd :tasklist \n")
	local ip = hub_addr(content)
	tasklist[ip] = tasklist[ip] or {}
	for l in string.gmatch(line,"(.-\n)") do
		--trace_out(l)
		local t = {}
		local index = 1
		for data in string.gmatch(l,"%b\"\"") do
			t[index] = string.gsub(data,"\"","")
			--trace_out(t[index] .. "\t")
			index = index + 1
		end
		if index > 9 then
			local name = t[1] .. t[9]
			tasklist[ip][name] = tasklist[ip][name] or {start = os.time() } 
			tasklist[ip][name].cur = os.time()
			tasklist[ip][name].title = t[9]
			tasklist[ip][name].exe = t[1]
		end
	end
	trigger(ip,config.delay)
	--[[
	for exename in string.gmatch(line,"(%w+).exe") do
		tasklist[ip][exename] = tasklist[ip][exename] or {start = os.time() } 
		tasklist[ip][exename].cur = os.time()
	end
	trigger(ip,config.delay)
	--]]
end

function process_cmd_imp(content,line)
	local fun,l = string.match(line,"([^\r\n]-)\r\n(.*)")
	if fun and l  and cmds[fun] then
		cmds[fun](content,l)
	elseif fun then
		local ip,port = hub_addr(content)
		trace_out("unkown command :" .. fun .. "@" .. ip .. ":" .. port .. "\n")
		trace_out(l)
	end
end

function process_data(content,line)
	local len,l = string.match(line,"^(%d+)\r\n(.*)")

	local num = 0

	if len then num = tonumber(len) end

	if len and l and num < string.len(l) then
		local str = string.sub(l,1,num)
		local left = string.sub(l,num +1)
		cs[content] = left
		process_cmd_imp(content,str)
		return false,left
	elseif len and l and num == string.len(l) then
		process_cmd_imp(content,l)
		cs[content] = true
		return true
	elseif len and l and num > string.len(l) then
		cs[content] = line
		return true
	elseif string.len(line) > 10 then
		local sock = get_socket(content)
		close_socket(sock)
		return true
	end
	return true
end

function process_cmd(content,line)
	local str 
	if type(cs[content]) == "boolean" then
		str = line
	elseif type(cs[content]) == "string" then
		str = cs[content] ..line
	end

	local result = false
	local s = str
	local s1
	repeat 
		result,s1 = process_data(content,s)	
		s = s1
	until result == true
end

function do_accept(content,str)
	cs[content] = true
	process_cmd(content,str)
end

function do_recv(content,str)
	process_cmd(content,str)
end

function socket_quit(content)
	ip,port = hub_addr(content)
	local exittime = os.date("%x %X")
	trace_out("client exit @" .. ip .. ":" .. port .. "---" .. exittime .. "\n")
	trigger(ip,0)
	cs[content] = nil
end

function on_quit()
	for k,v in cs do
		remove_content(k)
	end	
end
