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

runeu.Run = function(code)
	if type(code) ~= "string" then return end
	local ok, err = pcall(function()
		local tokens = Lexer.lex(code)
		local stmts = Parser.parse(tokens)
		Interpreter.execBlockStmts(stmts, State.getGlobalScope())
	end)
	if not ok then
		warn("runeu runtime error:", err)
	end
	return tostring(ok) .. (err and (" " .. tostring(err)) or "")
end

-- Uses State.setEnv so the environment can be locked
-- with runeu.Sandbox.LockEnvironment().
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
			if not ok then warn(child.Name .. " provider load error:", err) end
		end
	end
end

loadLibraries()

-- Protect builtins and default libraries.
-- Call ProtectAll() again after registering new ones if needed.
RuneSandbox.ProtectAll()

return runeu
