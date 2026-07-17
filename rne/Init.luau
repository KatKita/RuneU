local src = script.Parent.src

local State = require(src.State)
local Lexer = require(src.Lexer)
local Parser = require(src.Parser)
local Interpreter = require(src.Interpreter)
local RuneFuncs = require(src.RuneFuncs)

for name, fn in pairs(RuneFuncs) do
	State.Builtins[name] = fn
end

local rune = {}

rune.NULL = State.NULL
rune.VERSION = State.VERSION

rune.Run = function(code)
	if type(code) ~= "string" then return end
	local ok, err = pcall(function()
		local tokens = Lexer.lex(code)
		local stmts = Parser.parse(tokens)
		Interpreter.execBlockStmts(stmts, State.getGlobalScope())
	end)
	if not ok then
		warn("rune runtime error:", err)
	end
end

rune.SetEnv = function(env)
	State.ENV = env
end

rune.GetGlobalTable = function()
	return State.ENV == "SERVER" and State.GLOBAL_1 or State.ENV == "CLIENT" and State.GLOBAL_2 or State.GLOBAL_3
end

rune.RegisterFunction = function(name, fn)
	if type(name) ~= "string" or type(fn) ~= "function" then return end
	State.Builtins[name] = fn
end

rune.RegisterLibrary = function(name, tbl)
	if type(name) ~= "string" or type(tbl) ~= "table" then return end
	State.Libraries[name] = tbl
end

local function loadLibraries()
	if script == nil then return end
	local libraries = script.Parent and script.Parent:FindFirstChild("libraries")
	if not libraries then return end
	for _, child in ipairs(libraries:GetChildren()) do
		if child:IsA("ModuleScript") then
			local ok, err = pcall(function() require(child)(rune) end)
			if not ok then warn(child.Name .. " provider load error:", err) end
		end
	end
end

loadLibraries()

return rune
