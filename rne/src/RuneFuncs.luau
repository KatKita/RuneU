local State = require(script.Parent.State)
local Interpreter = require(script.Parent.Interpreter)

-- Ignore this dev test module
-- Interpreter = require(src.InterpreterV2)

local RuneFuncs = {}

local function tableToString(value, visited)
	visited = visited or {}
	if type(value) ~= "table" then
		return tostring(value)
	end
	if visited[value] then
		return "<recursive>"
	end
	visited[value] = true
	local parts = {}
	for k, v in pairs(value) do
		table.insert(parts, "[" .. tableToString(k, visited) .. "] = " .. tableToString(v, visited))
	end
	visited[value] = nil
	return "{ " .. table.concat(parts, ", ") .. " }"
end

local function builtinPrint(...)
	local parts = {}
	for _, v in ipairs({ ... }) do
		if type(v) == "table" then
			table.insert(parts, tableToString(v))
		else
			table.insert(parts, State.toDisplay(v))
		end
	end
	print(table.concat(parts, "\t"))
	return State.NULL
end

local function builtinWarn(...)
	local parts = {}
	for _, v in ipairs({ ... }) do
		if type(v) == "table" then
			table.insert(parts, tableToString(v))
		else
			table.insert(parts, State.toDisplay(v))
		end
	end
	warn(table.concat(parts, "\t"))
	return State.NULL
end

local function builtinCreateLibrary(name)
	if State.Libraries[name] then
		warn("runeu: library '" .. tostring(name) .. "' already exists")
		return State.Libraries[name]
	end
	local lib = {}
	State.Libraries[name] = lib
	State.Builtins[name] = lib
	return lib
end

local function builtinGetLibrary(name)
	return State.Libraries[name] or State.NULL
end

RuneFuncs.print = builtinPrint
RuneFuncs.warn = builtinWarn
RuneFuncs.createlibrary = builtinCreateLibrary
RuneFuncs.getlibrary = builtinGetLibrary

RuneFuncs.newlib = builtinCreateLibrary
RuneFuncs.getlib = builtinGetLibrary

RuneFuncs.type = function(v)
	if v == State.NULL then return "null" end
	return type(v)
end

RuneFuncs.typeof = function(v)
	if v == State.NULL then return "null" end
	return typeof(v)
end

RuneFuncs.str = tostring
RuneFuncs.num = tonumber
RuneFuncs.pick = select
RuneFuncs.next = next
RuneFuncs.pairs = pairs
RuneFuncs.each = ipairs
RuneFuncs.spread = table.unpack
RuneFuncs.assert = assert
RuneFuncs.err = error
RuneFuncs.error = error
RuneFuncs.raweq = rawequal
RuneFuncs.rawread = rawget
RuneFuncs.rawwrite = rawset
RuneFuncs.getmeta = getmetatable
RuneFuncs.setmeta = setmetatable

RuneFuncs.tick = function()
	return tick()
end

RuneFuncs.wait = function(seconds)
	task.wait(tonumber(seconds) or 0)
	return State.NULL
end

RuneFuncs.try = function(fn, ...)
	local args = { ... }
	local ok, result = pcall(function()
		return Interpreter.callFunction(fn, args)
	end)
	if ok then
		return true, State.wrapNil(result)
	end
	return false, tostring(result)
end

RuneFuncs.utf8 = utf8

RuneFuncs.runne = function(fn, ...)
	local args = { ... }
	return task.spawn(Interpreter.callFunction, fn, args)
end

RuneFuncs.rundefer = function(fn, ...)
	local args = { ... }
	return task.defer(function() Interpreter.callFunction(fn, args) end)
end

RuneFuncs.rundelay = function(seconds, fn, ...)
	local args = { ... }
	return task.delay(seconds, function() Interpreter.callFunction(fn, args) end)
end

RuneFuncs.runcancel = function(thread)
	task.cancel(thread)
	return State.NULL
end

RuneFuncs.os = {
	clock = os.clock,
	date = os.date,
	difftime = os.difftime,
	time = os.time,
}

RuneFuncs.co = coroutine
RuneFuncs.bit32 = bit32
RuneFuncs.luaversion = _VERSION 
RuneFuncs.runeversion = State.VERSION -- old name for RuneU/runeu (idk there are any scripts that use this anymore, but I'll include it anyway just in case)
RuneFuncs.runeuversion = State.VERSION
RuneFuncs.isdevbuild = State.DEV_BUILD -- debug feature (so yeah ignore this)
-- RuneFuncs._G = _G 
-- removed _G for security reasons

return RuneFuncs
