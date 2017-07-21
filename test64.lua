require "ado"

local db_string = "Provider=Microsoft.ACE.OLEDB.12.0;Data Source=test.mdb"
--pcall(ADO.new,db_string)
local db = ADO_Open(db_string)
--db:exec("create table test (username char(30),appname char(30),totaltimes INTEGER,startdatetime DATETIME,enddatetime DATETIME)")
db:exec("select * from test")
t = db:row()
while t~= nil do
	print(tostring(t.username) .. "\t" .. tostring(t.appname))
	t = db:row()
end
--db:exec("drop table test")
db:close()

--[[
db:exec("select * from [ReceivedData]")
local t = db:row()
while t ~= nil do
print(tostring(t[1]).."\t"..tostring(t["Contract"]))
t = db:row()
end
db:close()
--]]

