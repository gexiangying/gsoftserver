package.cpath = "./?51.dll;./?.dll;".. package.cpath
require "ado"
config = require "config"

--[[
local db_string = "Provider=SQLOLEDB;Server=gesql;Database=pubs;uid=sa;pwd=asd38fgh"
local db = ADO_Open(db_string)

local function insertdata(username,startdatetime,enddatetime,totaltimes,appname)
local str = "INSERT INTO [dbo].[gsoft] (username,startdatetime,enddatetime,totaltimes,appname) VALUES ('" .. username .. "','" .. startdatetime .. "','" .. enddatetime .. "','"  .. totaltimes .. "','" .. appname .. "')"
print(str .. "\n")
db:exec(str)
end
insertdata("192.168.5.244",os.date("%Y-%m-%d %X"),os.date("%Y-%m-%d %X"),100,"gosft")
--insertdata("192.168.5.244",os.date("%x %X"),os.date("%x %X"),100,"gosft")
db:close()
--]]

local function open_db(server,database,uid,pwd)
	local db_string = string.format("Provider=SQLOLEDB;Server=%s;Database=%s;uid=%s;pwd=%s",server,database,uid,pwd)
	local db = ADO_Open(db_string)
	return db
end

local function insertdata(db,tb,username,startdatetime,enddatetime,totaltimes,appname)
	local str = "INSERT INTO " .. tb  .. "(username,startdatetime,enddatetime,totaltimes,appname) VALUES ('" .. username .. "','" .. startdatetime .. "','" .. enddatetime .. "','"  .. totaltimes .. "','" .. appname .. "')"
	--print(str .. "\n")
	db:exec(str)
end

local function fmt_data(datetime)
	return os.date("%Y-%m-%d %X",datetime)
end


--local db = ADO_Create()
local	db = open_db(config.server,config.database,config.uid,config.pwd)
insertdata(db,config.tb,"192.168.5.244",fmt_data(os.time()),fmt_data(os.time()),100,"goft")
db:close()
