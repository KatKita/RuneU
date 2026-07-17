return function(rune)
	rune.RegisterLibrary("string", {
		byte = string.byte,
		char = string.char,
		find = string.find,
		format = string.format,
		gmatch = string.gmatch,
		gsub = string.gsub,
		len = string.len,
		lower = string.lower,
		match = string.match,
		rep = string.rep,
		reverse = string.reverse,
		sub = string.sub,
		upper = string.upper,
		split = string.split,

		trim = function(s)
			return (s:gsub("^%s+", ""):gsub("%s+$", ""))
		end,

		contains = function(s, sub)
			return string.find(s, sub, 1, true) ~= nil
		end,

		startsWith = function(s, prefix)
			return string.sub(s, 1, #prefix) == prefix
		end,

		endsWith = function(s, suffix)
			if #suffix == 0 then
				return true
			end
			return string.sub(s, -#suffix) == suffix
		end,

		join = function(list, sep)
			sep = sep or ""
			local out = {}

			for i, v in ipairs(list) do
				out[i] = tostring(v)
			end

			return table.concat(out, sep)
		end,

		padLeft = function(s, len, ch)
			ch = ch or " "
			while #s < len do
				s = ch .. s
			end
			return s
		end,

		padRight = function(s, len, ch)
			ch = ch or " "
			while #s < len do
				s = s .. ch
			end
			return s
		end,
	})
end
