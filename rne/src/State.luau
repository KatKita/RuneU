local State = {}

State.VERSION = "1.1.0"
State.NULL = setmetatable({}, { __tostring = function() return "null" end })
State.ENV = "OTHER"
State.GLOBAL_1, State.GLOBAL_2, State.GLOBAL_3 = {}, {}, {}
State.Libraries = {}
State.Builtins = {}

-- rnesandbox: permission state
-- mode = "blacklist" -> everything is assignable except names in `protected`
-- mode = "whitelist" -> nothing is assignable except names in `allowed`
State.Sandbox = {
	mode = "blacklist",
	protected = {},
	allowed = {},
	envLocked = false,
}

function State.isProtected(name)
	local sb = State.Sandbox
	if sb.mode == "whitelist" then
		return not sb.allowed[name]
	end
	return sb.protected[name] == true
end

function State.setEnv(env)
	if State.Sandbox.envLocked then
		error("rnesandbox: environment is locked and cannot be changed")
	end
	State.ENV = env
end

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
