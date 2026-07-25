local State = require(script.Parent.State)

local Interpreter = {}

local evalExpr, execStmt, execBlockStmts, callFunction

local function newScope(parent)
	return {
		vars = {},
		parent = parent,
		process = parent and parent.process or nil,
		global = parent and parent.global or nil
	}
end

local function checkNotStopped(scope)
	if State.isProcessStopped(scope) then
		error("runeu: process stopped", 0)
	end
end

local function scopeGet(scope, name)
	if name == "global" then
		return scope.global
	end
	local s = scope
	while s do
		local v = s.vars[name]
		if v ~= nil then
			return v
		end
		s = s.parent
	end

	local process = scope.process
	if process and process.context then
		local value = process.context[name]
		if value ~= nil then
			return value
		end
	end

	local b = State.Builtins[name]
	if b ~= nil then
		return b
	end

	local lib = State.Libraries[name]
	if lib ~= nil then
		return lib
	end

	return State.NULL
end

-- rnesandbox: assignments that would create/overwrite a name at the root
-- (global) scope are checked against State.isProtected. Locals inside
-- functions/blocks are never restricted.
local function scopeSet(scope, name, value)
	local s = scope
	while s do
		if s.vars[name] ~= nil then
			if s.parent == nil and State.isProtected(name) then
				error("rnesandbox: '" .. tostring(name) .. "' is protected and cannot be reassigned")
			end
			s.vars[name] = value
			return
		end
		s = s.parent
	end
	if scope.parent == nil and State.isProtected(name) then
		error("rnesandbox: '" .. tostring(name) .. "' is protected and cannot be assigned")
	end
	scope.vars[name] = value
end

local function binaryOp(op, a, b)
	if op == "+" then return (tonumber(a) or 0) + (tonumber(b) or 0)
	elseif op == "-" then return (tonumber(a) or 0) - (tonumber(b) or 0)
	elseif op == "*" then return (tonumber(a) or 0) * (tonumber(b) or 0)
	elseif op == "/" then return (tonumber(a) or 0) / (tonumber(b) or 1)
	elseif op == "%" then return (tonumber(a) or 0) % (tonumber(b) or 1)
	elseif op == "^" then return math.pow(tonumber(a) or 0, tonumber(b) or 0)
	elseif op == ".." then return State.toConcatString(a) .. State.toConcatString(b)
	elseif op == "==" then return a == b
	elseif op == "!=" then return a ~= b
	elseif op == "<" then return a < b
	elseif op == ">" then return a > b
	elseif op == "<=" then return a <= b
	elseif op == ">=" then return a >= b
	end
	return State.NULL
end

callFunction = function(fn, args, scope)
	if scope then
		checkNotStopped(scope)
	end
	if type(fn) == "function" then
		return State.wrapNil(fn(table.unpack(args)))
	end
	if type(fn) == "table" and fn.__isFunction then
		local fnScope = newScope(fn.closure)
		for i, pname in ipairs(fn.params) do
			fnScope.vars[pname] = args[i]
		end
		local signal, values = execBlockStmts(fn.body, fnScope)
		if signal == "return" then
			if #values == 0 then
				return State.NULL
			end
			for i = 1, #values do
				values[i] = State.wrapNil(values[i])
			end
			if #values == 1 then
				return values[1]
			end
			return {
				__multiReturn = true,
				values = values
			}
		end
		return State.NULL
	end
	error("runeu: attempt to call a non-function value")
end

execBlockStmts = function(stmts, scope)
	for _, st in ipairs(stmts) do
		local signal, value = execStmt(st, scope)
		if signal then return signal, value end
	end
	return nil, nil
end

execStmt = function(node, scope)
	checkNotStopped(scope)
	local kind = node.type
	if kind == "ExprStmt" then
		evalExpr(node.expr, scope)
		return nil, nil
	elseif kind == "Assign" then
		local values = {}
		for i, expr in ipairs(node.values) do
			local result = evalExpr(expr, scope)
			if i == #node.values and type(result) == "table" and result.__multiReturn then
				for _, v in ipairs(result.values) do
					table.insert(values, v)
				end
			else
				table.insert(values, result)
			end
		end
		for i, target in ipairs(node.targets) do
			local value = values[i]
			if value == nil then
				value = State.NULL
			end
			if target.type == "Identifier" then
				scopeSet(scope, target.name, value)

			elseif target.type == "Index" then
				local base = evalExpr(target.base, scope)
				local key = evalExpr(target.key, scope)
				base[key] = value
			end
		end
		return nil, nil
	elseif kind == "If" then
		if State.toBool(evalExpr(node.cond, scope)) then
			return execBlockStmts(node.body, newScope(scope))
		elseif node.elseBody then
			return execBlockStmts(node.elseBody, newScope(scope))
		end
		return nil, nil
	elseif kind == "While" then
		while State.toBool(evalExpr(node.cond, scope)) do
			checkNotStopped(scope)
			local signal, value = execBlockStmts(node.body, newScope(scope))
			if signal == "return" then return signal, value end
			if signal == "break" then break end
		end
		return nil, nil
	elseif kind == "Repeat" then
		repeat
			checkNotStopped(scope)
			local signal, value = execBlockStmts(node.body, newScope(scope))
			if signal == "return" then
				return signal, value
			end
			if signal == "break" then
				break
			end
		until State.toBool(evalExpr(node.cond, scope))
		return nil, nil
	elseif kind == "For" then
		local startV = tonumber(evalExpr(node.startExpr, scope)) or 0
		local stopV = tonumber(evalExpr(node.stopExpr, scope)) or 0
		local stepV = 1
		if node.stepExpr then
			stepV = tonumber(evalExpr(node.stepExpr, scope))
			if stepV == nil then stepV = 1 end
		end
		if stepV == 0 then
			error("runeu: 'for' step cannot be zero")
		end
		for i = startV, stopV, stepV do
			checkNotStopped(scope)
			local loopScope = newScope(scope)
			loopScope.vars[node.var] = i
			local signal, value = execBlockStmts(node.body, loopScope)
			if signal == "return" then return signal, value end
			if signal == "break" then break end
		end
		return nil, nil
	elseif kind == "Break" then
		return "break", nil
	elseif kind == "Continue" then
		return "continue", nil
	elseif kind == "Return" then
		local values = {}
		for i, expr in ipairs(node.values) do
			local value = evalExpr(expr, scope)
			if i == #node.values and type(value) == "table" and value.__multiReturn then
				for _, v in ipairs(value.values) do
					table.insert(values, v)
				end
			else
				table.insert(values, value)
			end
		end
		return "return", values
	end
	error("runeu: unknown statement '" .. tostring(kind) .. "'")
end

evalExpr = function(node, scope)
	local kind = node.type
	if kind == "Number" then return node.value
	elseif kind == "String" then return node.value
	elseif kind == "Bool" then return node.value
	elseif kind == "Null" then return State.NULL
	elseif kind == "Identifier" then return scopeGet(scope, node.name)
	elseif kind == "Unary" then
		local v = evalExpr(node.expr, scope)
		if node.op == "-" then return -(tonumber(v) or 0) end
		if node.op == "not" then return not State.toBool(v) end
		if node.op == "#" then
			if type(v) == "string" or type(v) == "table" then return #v end
			return 0
		end
		return State.NULL
	elseif kind == "Binary" then
		return binaryOp(node.op, evalExpr(node.left, scope), evalExpr(node.right, scope))
	elseif kind == "Logical" then
		local a = evalExpr(node.left, scope)
		if node.op == "and" then
			if not State.toBool(a) then return a end
			return evalExpr(node.right, scope)
		else
			if State.toBool(a) then return a end
			return evalExpr(node.right, scope)
		end
	elseif kind == "Table" then
		local t = {}
		local arrIndex = 1
		for _, f in ipairs(node.fields) do
			if f.key then
				t[evalExpr(f.key, scope)] = evalExpr(f.value, scope)
			else
				t[arrIndex] = evalExpr(f.value, scope)
				arrIndex = arrIndex + 1
			end
		end
		return t
	elseif kind == "Function" then
		return { __isFunction = true, params = node.params, body = node.body, closure = scope }
	elseif kind == "Index" then
		local base = evalExpr(node.base, scope)
		local key = evalExpr(node.key, scope)
		if type(base) == "string" then
			local stringLib = State.Libraries.string
			if stringLib then
				local v = stringLib[key]
				if v ~= nil then
					return v
				end
			end
		end
		if type(base) ~= "table" and type(base) ~= "userdata" then
			error("runeu: attempt to index a " .. type(base) .. " value")
		end
		-- rnesandbox: block reads of specific protected library members,
		-- e.g. rune.Sandbox.ProtectMember("rbx", "destroy")
		if node.base.type == "Identifier" and type(key) == "string" then
			local lib = State.Libraries[node.base.name]
			if lib == base and State.isMemberProtected(node.base.name, key) then
				error("rnesandbox: '" .. node.base.name .. "." .. key .. "' is protected and cannot be accessed")
			end
		end
		local ok, value = pcall(function()
			return base[key]
		end)
		if ok then
			if value == nil then
				return State.NULL
			end
			return value
		end
		error("runeu: " .. tostring(value))
	elseif kind == "Call" then
		local args = {}

		for i, expr in ipairs(node.args) do
			if i == #node.args then
				local value = evalExpr(expr, scope)

				if type(value) == "table" and value.__multiReturn then
					for _, v in ipairs(value.values) do
						table.insert(args, v)
					end
				else
					table.insert(args, value)
				end
			else
				table.insert(args, evalExpr(expr, scope))
			end
		end

		local callee = node.callee.type == "Identifier" and scopeGet(scope, node.callee.name) or evalExpr(node.callee, scope)

		if callee == State.NULL then
			error("runeu: attempt to call nil value")
		end

		return callFunction(callee, args, scope)
	end
	error("runeu: unknown expression '" .. tostring(kind) .. "'")
end

Interpreter.newScope = newScope
Interpreter.scopeGet = scopeGet
Interpreter.scopeSet = scopeSet
Interpreter.evalExpr = evalExpr
Interpreter.execStmt = execStmt
Interpreter.execBlockStmts = execBlockStmts
Interpreter.callFunction = callFunction

return Interpreter
