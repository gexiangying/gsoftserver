local cs = {}
local cmds = {}

hub_start("localhost",25,10,60) --ip port max_accept max_accept_seconds

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
	cs[content] = nil
end

function on_quit()
	for k,v in cs do
		remove_content(k)
	end	
end

