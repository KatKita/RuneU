-- rnesandbox
-- Controls which global names RuneU scripts are allowed to create/overwrite,
-- and locks down the SERVER/CLIENT/OTHER environment split so a running
-- script can't be redirected into another environment's globals.

local State = require(script.Parent.State)

local RuneSandbox = {}

-- Mark a single name as protected (blacklist mode). Protected names cannot
-- be assigned to from RuneU code at the global scope.
function RuneSandbox.Protect(name)
	assert(type(name) == "string", "rnesandbox: name must be a string")
	State.Sandbox.protected[name] = true
end

function RuneSandbox.Unprotect(name)
	State.Sandbox.protected[name] = nil
end

-- Protects every builtin function and every registered library name at the
-- time this is called. Call again after registering your own functions if
-- you want those protected too.
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

-- "blacklist" (default): everything assignable except `protected` names.
-- "whitelist": nothing assignable except `allowed` names.
function RuneSandbox.SetMode(mode)
	assert(mode == "blacklist" or mode == "whitelist", "rnesandbox: mode must be 'blacklist' or 'whitelist'")
	State.Sandbox.mode = mode
end

function RuneSandbox.GetMode()
	return State.Sandbox.mode
end

-- Only relevant in "whitelist" mode: explicitly allow a name to be assigned.
function RuneSandbox.Allow(name)
	assert(type(name) == "string", "rnesandbox: name must be a string")
	State.Sandbox.allowed[name] = true
end

function RuneSandbox.Disallow(name)
	State.Sandbox.allowed[name] = nil
end

-- Prevents any further calls to rune.SetEnv from succeeding. Call this right
-- after you set the environment for a given realm (server script / client
-- script) so a script can never be re-pointed at another realm's globals.
function RuneSandbox.LockEnvironment()
	State.Sandbox.envLocked = true
end

function RuneSandbox.IsEnvironmentLocked()
	return State.Sandbox.envLocked
end

return RuneSandbox
