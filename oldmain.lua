package.cpath = "./?51.dll;./?.dll"

require "ado"
local config = require "config"

local db = ADO_Create()
hub_start(config.ip,config.port,10,60) --ip port max_accept max_accept_seconds

cs = {}
tasklist = {}

local function open_db(db,server,database,uid,pwd)
	local db_string = string.format("Provider=SQLOLEDB;Server=%s;Database=%s;uid=%s;pwd=%s",server,database,uid,pwd)
	db:connect(db_string)
end


local function insertdata(db,tb,username,startdatetime,enddatetime,totaltimes,appname)
	local str = "INSERT INTO " .. tb  .. "(username,startdatetime,enddatetime,totaltimes,appname) VALUES ('" .. username .. "','" .. startdatetime .. "','" .. enddatetime .. "','"  .. totaltimes .. "','" .. appname .. "')"
	db:exec(str)
end

local function fmt_data(datetime)
	return os.date("%Y-%m-%d %X",datetime)
end

local function log(f,exename,ip,starttime,endtime)
	exename = string.format("%-32s",exename)
	write_file(f,exename .. "\t" .. ip .. "\t" .. os.date("%Y-%m-%d %X",starttime) .. "\t" .. os.date("%Y-%m-%d %X",endtime) .. "\r\n",-1,0)
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
					f = create_file("log.txt","w")
					seek_file(f,0,0,"end")
					log_file = true
				end
				log(f,k,ip,v.start,v.cur)
			end

			if config.log_sql and db then
				if not log_sql then
					open_db(db,config.server,config.database,config.uid,config.pwd)
					log_sql = true
				end
				insertdata(db,config.tb,ip,fmt_data(v.start),fmt_data(v.cur),seconds,k)
			end

			if config.trace then
				trace_out("\n*********************************************************************\n")
				trace_out(k .. "@" .. ip .. "::"  .. os.date("%x %X",v.start) .. "-----" .. os.date("%x %X",v.cur) .. "\n")
				trace_out("*********************************************************************\n\n")
			end
			t[k] = nil
		elseif config.trace then
			trace_out(k .. "@" .. ip .. "::" .. os.date("%x %X",v.start) .. "-----" .. seconds .. " seconds\n")
		end
	end
	if log_file then
		close_file(f)
	end
	if log_sql then
		db:close_db()	
	end
end

function process_cmd(content,str)
	--local day = os.date("%Y-%m-%d")
	local ip = hub_addr(content)
	local exename = string.match(str,"^(%a+)%.exe.*")
	if exename and exename ~= "END" then
		tasklist[ip] = tasklist[ip] or {}
		tasklist[ip][exename] = tasklist[ip][exename] or {start = os.time() } 
		tasklist[ip][exename].cur = os.time()
	elseif exename and exename == "END" then
		trigger(ip,600)
	end
end

function accept(content,str)
	cs[content] = true
	process_cmd(content,str)
end

function do_accept(content,str)
	--ip,port = hub_addr(content)
	--hub_send(content,"welcome!")
	accept(content,str)
end

function do_recv(content,str)
	recv(content,str)
end

function recv(content,str)
	process_cmd(content,str)
end

function socket_quit(content)
	ip,port = hub_addr(content)
	trace_out("client exit @" .. ip .. ":" .. port .. "\n")
	trigger(ip,0)
	cs[content] = nil
end

function on_quit()
	for k,v in cs do
		remove_content(k)
	end	
	db:close()
end
