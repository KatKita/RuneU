local State = {}

State.VERSION = "1.0.1"
State.NULL = setmetatable({}, { __tostring = function() return "null" end })
State.ENV = "OTHER"
State.GLOBAL_1, State.GLOBAL_2, State.GLOBAL_3 = {}, {}, {}
State.Libraries = {}
State.Builtins = {}

function State.wrapNil(v)
	if v == nil then return State.NULL end
	return v
end

function State.toDisplay(v)
	if v == State.NULL then return "null" end
	return tostring(v)
end

State.toConcatString = State.toDisplay

function State.toBool(v)
	if v == nil or v == State.NULL or v == false then return false end
	return true
end

function State.getGlobalScope()
	local vars = State.ENV == "SERVER" and State.GLOBAL_1 or State.ENV == "CLIENT" and State.GLOBAL_2 or State.GLOBAL_3
	return { vars = vars, parent = nil }
end

return State
