package.cpath = "./?53.dll;./?.dll"
require "ado" 
local luaext = require("luaext")
local config = require("config")
local cs = {}
local cmds = {}
tasklist = {}
local user = {}
local domain = {}
local hassql = not config.nosql 

os.execute("mkdir " .. "log")
hub_start("localhost",config.port,10,60) --ip port max_accept max_accept_seconds
local db
local function open_db(server,database,uid,pwd)
	local db_string = string.format("Provider=SQLOLEDB;Server=%s;Database=%s;uid=%s;pwd=%s",server,database,uid,pwd)
	--local db_string = "Provider=Microsoft.ACE.OLEDB.12.0;Data Source=test.mdb"
	--db:connect(db_string)
	db = ADO_Open(db_string)
end


local function insertdata(tb,username,ip,startdatetime,enddatetime,totaltimes,appname,apptitle)
	local str = "INSERT INTO " .. tb  .. "(username,ip,startdatetime,enddatetime,totaltimes,appname,apptitle,domainname,computername) VALUES ('" .. username .. "','" .. ip .. "','" .. startdatetime .. "','" .. enddatetime .. "','"  .. totaltimes .. "','" .. appname .. "',N'" .. apptitle .. "','" .. domain[username].domainname .. "','" .. user[ip].hostname .. "')"
	local sql_log_name = os.date("log/%Y-%m-%d-sql.txt")
	local f = io.open(sql_log_name,"a")
	f:write(str .. "\n")
	f:close()
	str = luaext.a2u8(str)
	if hassql then
		db:exec(str)
	end
end

local function fmt_data(datetime)
	return os.date("%Y-%m-%d %X",datetime)
end

local function log(f,exename,ip,starttime,endtime,title)
	exename = string.format("%-32s",exename)
	f:write(exename .. "\t" .. title .. "\t" .. ip .. "\t" .. os.date("%Y-%m-%d %X",starttime) .. "\t" .. os.date("%Y-%m-%d %X",endtime) .. "\r\n")
end

local function trigger_imp(ip,uname,t,delay)
	local f 

  local log_sql = false
	local log_file = false
  local log_file_name = os.date("log/%Y-%m-%d-log.txt")
	for k,v in pairs(t) do
		local seconds = v.cur - v.start
		local period = os.time() - v.cur
		if period > delay then
			if config.log_file then
				if not log_file or not f then
					f = io.open(log_file_name,"a")
					log_file = true
				end
				log(f,v.exe,ip,v.start,v.cur,v.title)
			end

			if config.log_sql then
				if not log_sql and hassql then
					open_db(config.server,config.database,config.uid,config.pwd)
					log_sql = true
				end
				insertdata(config.tb,uname,ip,fmt_data(v.start),fmt_data(v.cur),seconds,v.exe,v.title)
			end

			if config.trace then
				trace_out("\n*********************************************************************\n")
				trace_out(v.exe .. "@" .. uname .. "::"  .. os.date("%x %X",v.start) .. "-----" .. os.date("%x %X",v.cur) .. "\n")
				trace_out("*********************************************************************\n\n")
			end
			t[k] = nil
		elseif config.trace then
			trace_out(v.exe .. "(" .. v.title .. ")" .. "@" .. uname .. "::" .. os.date("%x %X",v.start) .. "-----" .. seconds .. " seconds\n")
		end
	end
	if log_file then
		f:close()
	end
	if log_sql and hassql then
		db:close()	
	end
end
local function trigger(ip,delay)
 for k,v in pairs(tasklist[ip]) do
	 trigger_imp(ip,k,v,delay)
	 --trace_out("trigger\tip:" .. ip .. "\tk:" .. k .. "\n")
 end
end
function cmds.hostname(content,line)
	local hostname = string.match(line,"([%w%p]+)")
	local ip = hub_addr(content)
	user[ip] = user[ip] or {}
	user[ip].hostname = hostname
	if config.trace then
		trace_out("hostname:" .. hostname .. "\n")
	end
end

function cmds.whoami(content,line)
	--[[
  local domain_name,name = string.match(line,"(.*)\\(%w+)")
	local ip = hub_addr(content)
	user[ip] = user[ip] or {}
	user[ip].name = name
	user[ip].domainname = domain_name
	if config.trace then
		trace_out("domain_name:" .. domain_name .. " user: " .. name .. "\n")
	end
	--]]
end

function cmds.systeminfo(content,line)
	trace_out(line)
end

function fix(t1,t9)
	for i,v in ipairs(config.ignore) do
		if t1 == v then
			return nil,nil
		end
	end
	for i,v in ipairs(config.titles) do
		if string.find(t9,v) then
			t9 = v
			break
		end
	end
  return t1,t9
end

function process_user(username)
	local domainname,name = string.match(username,"(.*)\\(.*)")
	if domainname and name then
		 domain[name] = domain[name] or {}
		 domain[name].domainname = domainname
		 --trace_out("process_user:" .. "\t" .. domainname .. "\t" .. name .. "\n")
		 return name 
  end
	return nil
end

function cmds.tasklist(content,line)
	trace_out("cmd :tasklist \n")
	local ip = hub_addr(content)
	if not user[ip] then return end
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
			t[1],t[9] = fix(t[1],t[9])
			if t[1] and t[9] then
				local name = t[1] .. t[9]
				local uname = process_user(t[7])
				if uname then
					--trace_out("uanme:" .. uname .. "\tname:" .. name .. "\n")
					tasklist[ip][uname] = tasklist[ip][uname] or {}
					tasklist[ip][uname][name] = tasklist[ip][uname][name] or {start=os.time()} 
					tasklist[ip][uname][name].cur = os.time()
					tasklist[ip][uname][name].title = t[9]
					tasklist[ip][uname][name].exe = t[1]
				end
			end
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
	if not user[ip] then return end
	trigger(ip,0)
	cs[content] = nil
	user[ip] = nil
	tasklist[ip] = nil
end

function on_quit()
	for k,v in cs do
		remove_content(k)
	end	
end
