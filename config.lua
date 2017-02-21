--module(...)
local modename = (...)
local M = {
	port = 25 ,--gosft server port
	server = "gesql" ,-- sql server
	database = "pubs", -- sql server database
	uid = "sa" ,--sql server user name
	pwd = "asd38fgh" ,-- sql server user possword
	tb = "[dbo].[gsoft]", -- sql server table name (username=ip,starttime,enddatetime,totaltimes,appname)
	--tb = "test",
	log_file = true,
	log_sql = true, 
	nosql = true,
	trace = true, 
	delay = 20,
	ignore = {"lsass.exe","tasklist.exe","taskhost.exe","dwm.exe","gsoft.exe","dllhost.exe","smss.exe"},
	titles = {"TeamViewer","SSDD","微信"},
}
package.loaded[modename] = M
