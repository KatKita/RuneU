local State = require(script.Parent.State)
local Interpreter = require(script.Parent.Interpreter)

local RuneFuncs = {}

local function builtinPrint(...)
	local parts = {}
	for _, v in ipairs({ ... }) do
		table.insert(parts, State.toDisplay(v))
	end
	print(table.concat(parts, "\t"))
	return State.NULL
end

local function builtinWarn(...)
	local parts = {}
	for _, v in ipairs({ ... }) do
		table.insert(parts, State.toDisplay(v))
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
	return lib
end

local function builtinGetLibrary(name)
	return State.Libraries[name] or State.NULL
end

RuneFuncs.print = builtinPrint
RuneFuncs.warn = builtinWarn
RuneFuncs.createlibrary = builtinCreateLibrary
RuneFuncs.getlibrary = builtinGetLibrary

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
RuneFuncs.raweq = rawequal
RuneFuncs.rawread = rawget
RuneFuncs.rawwrite = rawset
RuneFuncs.getmeta = getmetatable
RuneFuncs.setmeta = setmetatable

RuneFuncs.tick = function()
	return os.clock()
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
	return task.spawn(fn, ...)
end

RuneFuncs.rundefer = function(fn, ...)
	return task.defer(fn, ...)
end

RuneFuncs.rundelay = function(seconds, fn, ...)
	return task.delay(seconds, fn, ...)
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
RuneFuncs.runeversion = State.VERSION
RuneFuncs._G = _G

return RuneFuncs
