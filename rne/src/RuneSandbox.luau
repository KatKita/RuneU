local State = require(script.Parent.State)

local RuneSandbox = {} -- rnesandbox

-- Protect a global name from being reassigned.
function RuneSandbox.Protect(name)
	assert(type(name) == "string", "rnesandbox: name must be a string")
	State.Sandbox.protected[name] = true
end

function RuneSandbox.Unprotect(name)
	State.Sandbox.protected[name] = nil
end

--- Protect all registered builtins and libraries.
-- Call again after registering new ones if needed.
function RuneSandbox.ProtectAll()
	for name in pairs(State.Builtins) do
		State.Sandbox.protected[name] = true
	end
	for name in pairs(State.Libraries) do
		State.Sandbox.protected[name] = true
	end
end

function RuneSandbox.IsProtected(name)
	return State.isProtected(name)
end

-- blacklist: everything is assignable except protected names.
-- whitelist: only explicitly allowed names are assignable.
function RuneSandbox.SetMode(mode)
	assert(mode == "blacklist" or mode == "whitelist", "rnesandbox: mode must be 'blacklist' or 'whitelist'")
	State.Sandbox.mode = mode
end

function RuneSandbox.GetMode()
	return State.Sandbox.mode
end

-- Allow a global name in whitelist mode.
function RuneSandbox.Allow(name)
	assert(type(name) == "string", "rnesandbox: name must be a string")
	State.Sandbox.allowed[name] = true
end

function RuneSandbox.Disallow(name)
	State.Sandbox.allowed[name] = nil
end

-- Prevent further environment changes.
function RuneSandbox.LockEnvironment()
	State.Sandbox.envLocked = true
end

function RuneSandbox.IsEnvironmentLocked()
	return State.Sandbox.envLocked
end

--[[
function RuneSandbox.SetEnv(env)
	assert(not State.Sandbox.envLocked, "rnesandbox: environment is locked")
	State.Sandbox.env = env
end
]]

return RuneSandbox
