local src = script.Parent.src

local State = require(src.State)
local Lexer = require(src.Lexer)
local Parser = require(src.Parser)
local Interpreter = require(src.Interpreter)
local RuneFuncs = require(src.RuneFuncs)
local RuneSandbox = require(src.RuneSandbox)

-- Ignore this dev test module
-- Interpreter = require(src.InterpreterV2)

for name, fn in pairs(RuneFuncs) do
	State.Builtins[name] = fn
end

local runeu = {}

runeu.NULL = State.NULL
runeu.VERSION = State.VERSION
runeu.Sandbox = RuneSandbox

-- Supported Run() signatures:
--
-- runeu.Run("code")
--
-- runeu.Run({
--     code = "print(Player.Name) Character = Health == 0 and null or (Character or Player.Character)",
--     context = {
--         Player = player,
--         Character = character,
--         Health = 100,
--     },
--     sync = false,
-- })
--
-- By default Run() starts the script as a separate process and
-- immediately returns its process ID.
--
-- When sync = true, execution is blocking and behaves like the
-- legacy API. In this mode no process is created, Stop() cannot
-- interrupt execution, and the return value is:
--
--     "true"
--     "false <error>"
runeu.Run = function(argsOrCode)
	local args
	if type(argsOrCode) == "table" then
		args = argsOrCode
	elseif type(argsOrCode) == "string" then
		args = { code = argsOrCode }
	else
		return nil
	end

	local code = args.code
	if type(code) ~= "string" then return nil end

	local context = type(args.context) == "table" and args.context or {}

	if args.sync then
		local ok, err = pcall(function()
			local scope = State.getGlobalScope()
			-- Synchronous execution does not create a process,
			-- so it cannot be stopped with Stop().
			scope.process = {
				context = context,
				stopped = false,
			}
			local tokens = Lexer.lex(code)
			local stmts = Parser.parse(tokens)
			Interpreter.execBlockStmts(stmts, scope)
		end)
		if not ok then
			warn("runeu runtime error:", err)
		end
		return tostring(ok) .. (err and (" " .. tostring(err)) or "")
	end

	local id = State.newProcessId()
	local process = {
		id = id,
		context = context,
		stopped = false,
		thread = nil,
		finished = false,
		ok = nil,
		err = nil,
	}
	State.registerProcess(process)

	local scope = State.getGlobalScope()
	scope.process = process

	process.thread = task.spawn(function()
		local ok, err = pcall(function()
			local tokens = Lexer.lex(code)
			local stmts = Parser.parse(tokens)
			Interpreter.execBlockStmts(stmts, scope)
		end)
		process.finished = true
		process.ok = ok
		process.err = err
		if not ok then
			warn("runeu runtime error (process " .. tostring(id) .. "):", err)
		end
		State.removeProcess(id)
	end)

	return id
end

-- Stops a running process.
-- Sets the cooperative stop flag and attempts to cancel the task
-- if it is currently yielding (wait(), etc.).
-- Returns true if the process existed, otherwise false.
runeu.Stop = function(id)
	local process = State.getProcess(id)
	if not process then
		return false
	end
	process.stopped = true
	if process.thread then
		pcall(task.cancel, process.thread)
	end
	State.removeProcess(id)
	return true
end

runeu.IsRunning = function(id)
	return State.getProcess(id) ~= nil
end

runeu.GetProcess = function(id)
	local process = State.getProcess(id)
	if not process then return State.NULL end
	return {
		id = process.id,
		context = process.context,
		stopped = process.stopped,
	}
end

runeu.GetRunningProcesses = function()
	local out = {}
	for id in pairs(State.Processes) do
		table.insert(out, id)
	end
	return out
end

-- Updates the global environment.
-- Uses State.setEnv() so the environment can be locked through
-- runeu.Sandbox.LockEnvironment().
runeu.SetEnv = function(env)
	State.setEnv(env)
end

runeu.GetGlobalTable = function()
	return State.ENV == "SERVER" and State.GLOBAL_1 or State.ENV == "CLIENT" and State.GLOBAL_2 or State.GLOBAL_3
end

runeu.RegisterFunction = function(name, fn)
	if type(name) ~= "string" or type(fn) ~= "function" then return end
	State.Builtins[name] = fn
end

runeu.RegisterLibrary = function(name, tbl)
	if type(name) ~= "string" or type(tbl) ~= "table" then return end
	State.Libraries[name] = tbl
end

local function loadLibraries()
	if script == nil then warn("runeu: loadLibraries called outside of a script") return end
	local libraries = script.Parent and script.Parent:FindFirstChild("libraries")
	if not libraries then return end
	for _, child in ipairs(libraries:GetChildren()) do
		if child:IsA("ModuleScript") then
			local ok, err = pcall(function() require(child)(runeu) end)
			if not ok then warn(child.Name .. " library load error:", err) end
		end
	end
end

loadLibraries()

-- Protect builtins and default libraries.
-- Call ProtectAll() again after registering new ones if needed.
RuneSandbox.ProtectAll()

return runeu
