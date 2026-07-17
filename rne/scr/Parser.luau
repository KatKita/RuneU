local Parser = {}

local function newParser(tokens)
	return { tokens = tokens, pos = 1 }
end

local function peek(p) return p.tokens[p.pos] end
local function peekAt(p, offset) return p.tokens[p.pos + offset] or { type = "EOF" } end
local function advance(p) local t = p.tokens[p.pos]; p.pos = p.pos + 1; return t end

local function check(p, type_, value)
	local t = peek(p)
	if t.type ~= type_ then return false end
	if value ~= nil and t.value ~= value then return false end
	return true
end

local function expect(p, type_, value)
	if check(p, type_, value) then return advance(p) end
	local t = peek(p)
	error("rune parse error: expected " .. type_ .. " " .. tostring(value) .. " got " .. tostring(t.type) .. " " .. tostring(t.value))
end

local parseExpr, parsePrimary, parsePostfix, parseUnary, parseMul, parseAdd, parseConcat, parseCompare, parseAnd, parseOr, parseBlock, parseStatement, parseIfChain

parsePrimary = function(p)
	local t = peek(p)
	if t.type == "NUMBER" then advance(p); return { type = "Number", value = t.value } end
	if t.type == "STRING" then advance(p); return { type = "String", value = t.value } end
	if t.type == "KEYWORD" and t.value == "true" then advance(p); return { type = "Bool", value = true } end
	if t.type == "KEYWORD" and t.value == "false" then advance(p); return { type = "Bool", value = false } end
	if t.type == "KEYWORD" and t.value == "null" then advance(p); return { type = "Null" } end
	if t.type == "OP" and t.value == "(" then
		advance(p)
		local e = parseExpr(p)
		expect(p, "OP", ")")
		return e
	end
	if t.type == "OP" and t.value == "{" then
		advance(p)
		local fields = {}
		while not check(p, "OP", "}") do
			if check(p, "OP", "[") then
				advance(p)
				local key = parseExpr(p)
				expect(p, "OP", "]")
				expect(p, "OP", "=")
				table.insert(fields, { key = key, value = parseExpr(p) })
			elseif check(p, "IDENT") and peekAt(p, 1).type == "OP" and peekAt(p, 1).value == "=" then
				local name = advance(p).value
				advance(p)
				table.insert(fields, { key = { type = "String", value = name }, value = parseExpr(p) })
			else
				table.insert(fields, { key = nil, value = parseExpr(p) })
			end
			if check(p, "OP", ",") then advance(p) end
		end
		expect(p, "OP", "}")
		return { type = "Table", fields = fields }
	end
	if t.type == "KEYWORD" and t.value == "func" then
		advance(p)
		expect(p, "OP", "(")
		local params = {}
		while not check(p, "OP", ")") do
			table.insert(params, expect(p, "IDENT").value)
			if check(p, "OP", ",") then advance(p) end
		end
		expect(p, "OP", ")")
		local body = parseBlock(p, { ["end"] = true })
		expect(p, "KEYWORD", "end")
		return { type = "Function", params = params, body = body }
	end
	if t.type == "IDENT" then
		advance(p)
		return { type = "Identifier", name = t.value }
	end
	error("rune parse error: unexpected token " .. tostring(t.type) .. " " .. tostring(t.value))
end

parsePostfix = function(p)
	local expr = parsePrimary(p)
	while true do
		if check(p, "OP", ".") then
			advance(p)
			local name = expect(p, "IDENT").value
			expr = { type = "Index", base = expr, key = { type = "String", value = name } }
		elseif check(p, "OP", ":") then
			advance(p)
			local name = expect(p, "IDENT").value
			expect(p, "OP", "(")
			local args = { expr }
			while not check(p, "OP", ")") do
				table.insert(args, parseExpr(p))
				if check(p, "OP", ",") then advance(p) end
			end
			expect(p, "OP", ")")
			expr = { type = "Call", callee = { type = "Index", base = expr, key = { type = "String", value = name } }, args = args }
		elseif check(p, "OP", "[") then
			advance(p)
			local key = parseExpr(p)
			expect(p, "OP", "]")
			expr = { type = "Index", base = expr, key = key }
		elseif check(p, "OP", "(") then
			advance(p)
			local args = {}
			while not check(p, "OP", ")") do
				table.insert(args, parseExpr(p))
				if check(p, "OP", ",") then advance(p) end
			end
			expect(p, "OP", ")")
			expr = { type = "Call", callee = expr, args = args }
		else
			break
		end
	end
	return expr
end

parseUnary = function(p)
	if check(p, "OP", "-") then
		advance(p)
		return { type = "Unary", op = "-", expr = parseUnary(p) }
	end
	if check(p, "OP", "#") then
		advance(p)
		return { type = "Unary", op = "#", expr = parseUnary(p) }
	end
	if check(p, "KEYWORD", "not") then
		advance(p)
		return { type = "Unary", op = "not", expr = parseUnary(p) }
	end
	return parsePostfix(p)
end

parseMul = function(p)
	local left = parseUnary(p)
	while check(p, "OP", "*") or check(p, "OP", "/") or check(p, "OP", "%") do
		local op = advance(p).value
		left = { type = "Binary", op = op, left = left, right = parseUnary(p) }
	end
	return left
end

parseAdd = function(p)
	local left = parseMul(p)
	while check(p, "OP", "+") or check(p, "OP", "-") do
		local op = advance(p).value
		left = { type = "Binary", op = op, left = left, right = parseMul(p) }
	end
	return left
end

parseConcat = function(p)
	local left = parseAdd(p)
	if check(p, "OP", "..") then
		advance(p)
		local right = parseConcat(p)
		return { type = "Binary", op = "..", left = left, right = right }
	end
	return left
end

parseCompare = function(p)
	local left = parseConcat(p)
	while check(p, "OP", "==") or check(p, "OP", "!=") or check(p, "OP", "<") or check(p, "OP", ">") or check(p, "OP", "<=") or check(p, "OP", ">=") do
		local op = advance(p).value
		left = { type = "Binary", op = op, left = left, right = parseConcat(p) }
	end
	return left
end

parseAnd = function(p)
	local left = parseCompare(p)
	while check(p, "KEYWORD", "and") do
		advance(p)
		left = { type = "Logical", op = "and", left = left, right = parseCompare(p) }
	end
	return left
end

parseOr = function(p)
	local left = parseAnd(p)
	while check(p, "KEYWORD", "or") do
		advance(p)
		left = { type = "Logical", op = "or", left = left, right = parseAnd(p) }
	end
	return left
end

parseExpr = parseOr

parseBlock = function(p, stopSet)
	local stmts = {}
	while true do
		local t = peek(p)
		if t.type == "EOF" then break end
		if t.type == "KEYWORD" and stopSet[t.value] then break end
		table.insert(stmts, parseStatement(p))
	end
	return stmts
end

parseIfChain = function(p)
	local cond = parseExpr(p)
	if check(p, "KEYWORD", "then") then advance(p) end
	local body = parseBlock(p, { ["elseif"] = true, ["else"] = true, ["end"] = true })
	if check(p, "KEYWORD", "elseif") then
		advance(p)
		local elseBody = { parseIfChain(p) }
		return { type = "If", cond = cond, body = body, elseBody = elseBody }
	end
	if check(p, "KEYWORD", "else") then
		advance(p)
		local elseBody = parseBlock(p, { ["end"] = true })
		expect(p, "KEYWORD", "end")
		return { type = "If", cond = cond, body = body, elseBody = elseBody }
	end
	expect(p, "KEYWORD", "end")
	return { type = "If", cond = cond, body = body, elseBody = nil }
end

parseStatement = function(p)
	local t = peek(p)
	if t.type == "KEYWORD" and t.value == "func" and peekAt(p, 1).type == "IDENT" then
		advance(p)
		local name = advance(p).value
		expect(p, "OP", "(")
		local params = {}
		while not check(p, "OP", ")") do
			table.insert(params, expect(p, "IDENT").value)
			if check(p, "OP", ",") then advance(p) end
		end
		expect(p, "OP", ")")
		local body = parseBlock(p, { ["end"] = true })
		expect(p, "KEYWORD", "end")
		return { type = "Assign", target = { type = "Identifier", name = name }, value = { type = "Function", params = params, body = body } }
	end
	if t.type == "KEYWORD" and t.value == "if" then
		advance(p)
		return parseIfChain(p)
	end
	if t.type == "KEYWORD" and t.value == "while" then
		advance(p)
		local cond = parseExpr(p)
		if check(p, "KEYWORD", "do") then advance(p) end
		local body = parseBlock(p, { ["end"] = true })
		expect(p, "KEYWORD", "end")
		return { type = "While", cond = cond, body = body }
	end
	if t.type == "KEYWORD" and t.value == "for" then
		advance(p)
		local var = expect(p, "IDENT").value
		expect(p, "OP", "=")
		local startExpr = parseExpr(p)
		expect(p, "OP", ",")
		local stopExpr = parseExpr(p)
		local stepExpr = nil
		if check(p, "OP", ",") then
			advance(p)
			stepExpr = parseExpr(p)
		end
		if check(p, "KEYWORD", "do") then advance(p) end
		local body = parseBlock(p, { ["end"] = true })
		expect(p, "KEYWORD", "end")
		return { type = "For", var = var, startExpr = startExpr, stopExpr = stopExpr, stepExpr = stepExpr, body = body }
	end
	if t.type == "KEYWORD" and t.value == "break" then
		advance(p)
		return { type = "Break" }
	end
	if t.type == "KEYWORD" and t.value == "return" then
		advance(p)
		local nt = peek(p)
		local hasValue = not (nt.type == "EOF" or (nt.type == "KEYWORD" and (nt.value == "end" or nt.value == "else" or nt.value == "elseif")))
		return { type = "Return", value = hasValue and parseExpr(p) or nil }
	end
	local expr = parsePostfix(p)
	if check(p, "OP", "=") then
		advance(p)
		return { type = "Assign", target = expr, value = parseExpr(p) }
	end
	if expr.type ~= "Call" then
		error("rune parse error: unexpected expression used as statement")
	end
	return { type = "ExprStmt", expr = expr }
end

function Parser.parse(tokens)
	local p = newParser(tokens)
	return parseBlock(p, {})
end

return Parser
