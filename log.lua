package.cpath = "./?53.dll;./?.dll"
require "ado" 
local luaext = require("luaext")
local config = require("config")

local hassql = not config.nosql 
local db

local function open_db(server,database,uid,pwd)
	local db_string = string.format("Provider=SQLOLEDB;Server=%s;Database=%s;uid=%s;pwd=%s",server,database,uid,pwd)
	db = ADO_Open(db_string)
end


local function insertdata(str)
	--str = luaext.a2u8(str)
	if hassql then
		db:exec(str)
	end
end

if not arg[1] then 
	print("lua log.lua xxxx-xx-xx")
else
	if hassql then
		open_db(config.server,config.database,config.uid,config.pwd)
	end
	io.input("log/" .. arg[1] .. "-sql.txt")
	for line in io.lines() do
		open_db(config.server,config.database,config.uid,config.pwd)
		print(line)
		insertdata(line)
	end
	io.input():close()
	if hassql then
		db:close()
	end
end
