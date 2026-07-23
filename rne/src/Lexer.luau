local Lexer = {}

local KEYWORDS = {
	["func"] = true, ["end"] = true, ["if"] = true, ["then"] = true, ["else"] = true, ["elseif"] = true,
	["for"] = true, ["while"] = true, ["repeat"] = true, ["until"] = true, ["do"] = true, ["break"] = true, ["return"] = true, 
	["true"] = true, ["false"] = true, ["null"] = true, ["and"] = true, ["or"] = true, ["not"] = true,
}

Lexer.KEYWORDS = KEYWORDS

function Lexer.lex(src)
	local tokens = {}
	local i, n = 1, #src -- Ignore this RobloxStudio warning here
	local function push(t, v) table.insert(tokens, { type = t, value = v }) end
	while i <= n do
		local c = src:sub(i, i)
		if c:match("%s") then
			i = i + 1
		elseif c == "-" and src:sub(i + 1, i + 1) == "-" then
			local nl = src:find("\n", i) or (n + 1)
			i = nl + 1
		elseif c:match("%d") then
			local s, e = src:find("^%d+%.?%d*", i)
			push("NUMBER", tonumber(src:sub(s, e)))
			i = e + 1
		elseif c:match("[%a_]") then
			local s, e = src:find("^[%w_]+", i)
			local word = src:sub(s, e)
			push(KEYWORDS[word] and "KEYWORD" or "IDENT", word)
			i = e + 1
		elseif c == '"' or c == "'" then
			local j = i + 1
			local buf = {}
			while j <= n and src:sub(j, j) ~= c do
				table.insert(buf, src:sub(j, j))
				j = j + 1
			end
			if j > n then
				error("runeu lex error: unterminated string starting at position " .. i)
			end
			push("STRING", table.concat(buf))
			i = j + 1
		elseif c == "=" and src:sub(i + 1, i + 1) == "=" then push("OP", "=="); i = i + 2
		elseif c == "!" and src:sub(i + 1, i + 1) == "=" then push("OP", "!="); i = i + 2
		elseif c == "<" and src:sub(i + 1, i + 1) == "=" then push("OP", "<="); i = i + 2
		elseif c == ">" and src:sub(i + 1, i + 1) == "=" then push("OP", ">="); i = i + 2
		elseif c == "." and src:sub(i + 1, i + 1) == "." then push("OP", ".."); i = i + 2
		elseif c:match("[%+%-%*/%%<>=%^%(%)%{%}%[%],%.#:]") then
			push("OP", c)
			i = i + 1
		else
			error("runeu lex error: unexpected character '" .. c .. "' at position " .. i)
		end
	end
	push("EOF", nil)
	return tokens
end

return Lexer
