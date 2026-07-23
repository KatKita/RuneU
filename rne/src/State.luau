local State = {}

State.VERSION = "1.2.0"
State.NULL = setmetatable({}, { __tostring = function() return "null" end })
State.ENV = "OTHER"
State.DEV_BUILD = false
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
	-- protected members inside libraries, keyed as "libName.memberName" = true
	-- e.g. protectedMembers["rbx.destroy"] = true blocks rbx.destroy specifically
	protectedMembers = {},
}

function State.isProtected(name)
	local sb = State.Sandbox
	if sb.mode == "whitelist" then
		return not sb.allowed[name]
	end
	return sb.protected[name] == true
end

-- Is `libName.memberName` (e.g. "rbx.destroy") blocked from being read/called?
function State.isMemberProtected(libName, memberName)
	return State.Sandbox.protectedMembers[libName .. "." .. tostring(memberName)] == true
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
	return { vars = vars, parent = nil, process = nil }
end

----------------------------------------------------------------------
-- runeu processes
--
-- Every rune.Run() call spawns a "process" with a unique numeric id.
-- rune.Stop(id) can then terminate it:
--   - cooperatively, via a `stopped` flag checked at every loop iteration
--     and every function call (so scripts without yields can still be
--     interrupted at the next checkpoint)
--   - forcefully, via task.cancel on the underlying thread, for scripts
--     that are currently yielded (rbx.wait, wait(), etc.)
----------------------------------------------------------------------
State.Processes = {}
local nextProcessId = 0

function State.newProcessId()
	nextProcessId = nextProcessId + 1
	return nextProcessId
end

function State.registerProcess(process)
	State.Processes[process.id] = process
	return process
end

function State.getProcess(id)
	return State.Processes[id]
end

function State.removeProcess(id)
	State.Processes[id] = nil
end

-- Walks up to the root scope and returns its attached process (if any).
function State.findProcess(scope)
	local s = scope
	while s do
		if s.process then
			return s.process
		end
		if s.parent == nil then
			break
		end
		s = s.parent
	end
	return nil
end

function State.isProcessStopped(scope)
	local process = State.findProcess(scope)
	return process ~= nil and process.stopped == true
end

return State
