local modname = ...
local M = {}
_G[modname] = M
package.loaded[modname] = M
local string = string
local io = io
local write_file = write_file
local lock_file = lock_file
local unlock_file = unlock_file
local close_file = close_file
local create_file = create_file
local pairs = pairs
local type = type
local tostring = tostring
local concat = table.concat
_ENV = M

local function basicSerialize(o,saved)
	if type(o) == "number" then
		return tostring(o)
	elseif type(o) == "table" then
		return saved[o]
	elseif type(o) == "boolean" then
		return tostring(o)
	else
		return string.format("%q",o)
	end
end

local function save(name,value,out,saved)
	if not name then return end
	saved = saved or {}
	--write_file(f,name .. " = ",-1,0)
	out(name .. " = ")
	if type(value) == "number" or type(value) == "string" or type(value) =="boolean" then
		--write_file(f,basicSerialize(value) .. "\n",-1,0)
		out(basicSerialize(value) .. "\n")
	elseif type(value) == "table" then
		if saved[value] then
			--write_file(f,saved[value] .. "\n")
			out(saved[value] .. "\n")
		else
			saved[value] = name
			--write_file(f,"{}\n",-1,0)
			out("{}\n")
			for k,v in pairs(value) do
				k = basicSerialize(k,saved)
				if k then 
					local fname =  string.format("%s[%s]",name,k)
					save(fname,v,out,saved)
				end
			end
		end
	elseif type(value) == "function" then
		out("function()   end \n")
	elseif type(value) == "nil" then
		out("nil\n")
	else
		out("nil\n")
		--error("cannot save a "..type(value))
	end
end

local function fileout(file)
	return function(str)
		write_file(file,str,-1,0)
	end
end

local function strout(rs)
	return function(str)
		rs[#rs+1] = str
	end
end

local function io_out(file)
	return function(str)
		file:write(str)
	end
end

function save_io(file,content,key)
	local f = io.open(file,"w")
	local t = {}
	if key then
		save(key,content,io_out(f),t)
	else
		for k,v in pairs(content) do
			save(k,v,io_out(f),t)
		end
	end
	f:close()
end

function save_file(file,content,key)
	local f = create_file(file,"w+")
	local t = {}
	lock_file(f,1024,0,0,0)

	local out = fileout(f)
	if key then
		save(key,content,out)
	else
		for k,v in pairs(content) do
			save(k,v,out,t)
		end
	end
	unlock_file(f,1024,0,0,0)
	close_file(f)
end

function save_str(content,key)
	local rs = {}
	local t = {}
	local out = strout(rs)
	if key then
		save(key,content,out)
	else
		for k,v in pairs(content) do
			save(k,v,out,t)
		end
	end
	return concat(rs) 
end
