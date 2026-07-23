# RuneU

RuneU is a small scripting language built on top of Luau, made for embedding inside Roblox games. It has its own lexer, parser and interpreter, a syntax that sits somewhere between Lua and JavaScript and GO, and a few built-in libraries so you don't have to write everything from scratch.

```lua
runeu.RegisterFunction("double", function(x) return x * 2 end)

runeu.Run({
    code = [[
        func greet(name)
            print("Hello, " .. name)
        end

        greet(contextName)
        print(double(21))
    ]],
    context = {
        contextName = "World"
    }
})
```

## Why

Sometimes you want to let users (or your own game systems) run scripts without giving them full access to Luau — think plugin systems, custom game logic, modding support, NPC behavior scripts, etc. RuneU gives you a sandboxed language you can run inside your game, with full control over what functions and libraries are exposed to it.

## Features

- Full pipeline: lexer → parser → interpreter, all written in Luau
- Familiar syntax — `func`, `if/elseif/else`, `while`, `for`, `break`, `return`
- Tables, closures, first-class functions
- A dedicated `null` type instead of relying on `nil`
- `try(...)` for catching errors without crashing the whole script
- **`rnesandbox`** — a permission layer that protects global names, builtins and library members from being overwritten
- Execution context support — pass custom values directly into scripts with `context`
- Separate global scopes for server/client/other environments
- Easy to extend — register your own functions and libraries from Luau
- Built-in `math`, `string`, `table` and `rbx` (Roblox API) libraries, including `RBXScriptSignal` support (`rbx.connect`, `rbx.once`, `rbx.wait`, `rbx.disconnect`)

## Installation

Drop the `rne` folder (with `Init`, `src`, and `libraries`) somewhere in your game, e.g. `ReplicatedStorage`, then require it. Make sure the folder that holds `State`/`Lexer`/`Parser`/`Interpreter`/`RuneFuncs`/`RuneSandbox` is named `src` — that's the name `Init.luau` requires.

```lua
local runeu = require(path.to.rne.Init)
```

## Getting started

```lua
local runeu = require(path.to.rne.Init)

local id = runeu.Run({
	code = [[
		for i = 1, count do
			print("i =", i)
		end
	]],
	context = {
		count = 5
	}
})

-- need to stop the running script?
if id then
	runeu.Stop(id)
end
```

## API

- **`rune.Run(code)`** — runs RuneU code from a string.
- **`rune.Run({code = "...", context = {...}})`** — runs RuneU code with custom values exposed to the script through the global scope. Runtime errors are caught and printed with `warn`
- **`rune.SetEnv(env)`** — sets the current environment (`"SERVER"`, `"CLIENT"`, or anything else), which controls which global scope gets used.
- **`rune.GetGlobalTable()`** — returns the global variable table for the current environment.
- **`rune.RegisterFunction(name, fn)`** — exposes a Luau function to RuneU scripts under a given name.
- **`rune.RegisterLibrary(name, tbl)`** — exposes a table as a library, accessible from RuneU via `getlibrary(name)`.
- **`rune.NULL`** — the value RuneU uses instead of `nil`.
- **`rune.VERSION`** — current version string.
- **`rune.Sandbox`** — the `rnesandbox` permission API, see below.

## rnesandbox

`rnesandbox` decides which global names RuneU scripts are allowed to create or overwrite, and provides protection against overwriting registered globals, builtins and library members.

By default, every built-in function and every default library (`math`, `string`, `table`, `rbx`) is protected right after RuneU loads, so a script can't do `print = func() end` and permanently break `print` for that environment. Everything else stays freely assignable ("blacklist" mode).

```lua
-- protect one of your own registered functions/globals
rune.RegisterFunction("giveCoins", giveCoinsFn)
rune.Sandbox.Protect("giveCoins")

-- or re-protect everything registered so far (builtins + libraries + your own)
rune.Sandbox.ProtectAll()

-- deliberately allow a script to override something protected
rune.Sandbox.Unprotect("print")

-- switch to whitelist mode: nothing is assignable except what you explicitly allow
rune.Sandbox.SetMode("whitelist")
rune.Sandbox.Allow("score")
rune.Sandbox.Allow("playerName")
```

Trying to assign a protected/disallowed global from RuneU code raises a `rnesandbox: '<name>' is protected and cannot be assigned` error, which `rune.Run` catches and reports through `warn` like any other runtime error.

## Syntax

**Variables**

```
x = 10
name = "RuneU"
isReady = true
nothing = null
```

**Functions**

```
func add(a, b)
    return a + b
end

double = func(x)
    return x * 2
end
```

**Conditionals**

```
if x > 10 then
    print("big")
elseif x > 0 then
    print("small")
else
    print("non-positive")
end
```

**Loops**

```
for i = 1, 10 do
    if i == 5 then break end
    print(i)
end

while x > 0 do
    x = x - 1
end
```

**Tables**

```
t = { 1, 2, 3, key = "value", [10] = "ten" }
print(t.key)
print(t[10])
```

**Operators** — `+ - * / %` for math, `== != < > <= >=` for comparison, `and or not` for logic, `..` for string concat, `#t` for length.

## Built-in functions

`print`, `warn`, `type`, `typeof`, `str`, `num`, `pairs`, `each`, `try(fn, ...)` for safe calls, `createlibrary`/`getlibrary`, `tick`, `wait`, `runne`/`rundefer`/`rundelay`/`runcancel` for spawning and delaying tasks, plus direct access to `assert`, `err`, `co` (coroutine), `bit32`, `os`, `utf8` and `_G`.

## Built-in libraries

Available inside RuneU scripts through `getlibrary("name")`:

- **math** — everything from `math.*`, plus `lerp`, `map`, `dist`
- **string** — everything from `string.*`, plus `trim`, `contains`, `startsWith`, `endsWith`, `join`, `padLeft`, `padRight`
- **table** — everything from `table.*`, plus `length`, `contains`, `keys`, `values`, `reverse`
- **rbx** — wraps common Roblox services and APIs: `Instance.new`, `GetService`, `FindFirstChild`, `Vector3`, `CFrame`, `Color3`, and more, plus `RBXScriptSignal` helpers:
  - `rbx.connect(signal, fn)` — connects a RuneU function (or native Luau function) to any signal, returns the `RBXScriptConnection`
  - `rbx.once(signal, fn)` — same, but disconnects after firing once
  - `rbx.wait(signal)` — yields until the signal fires, returns its arguments
  - `rbx.disconnect(connection)` — disconnects a connection
  - `rbx.isConnected(connection)` — whether a connection is still active

```
m = getlibrary("math")
print(m.lerp(0, 10, 0.5))

rbx = getlibrary("rbx")
part = rbx.workspace:findFirstChild("Part")
rbx.connect(part.Touched, func(other)
    print("touched by", other:GetFullName())
end)
```

### Run context

`context` allows passing custom values into a RuneU script without registering global functions or libraries.

```lua
runeu.Run({
    code = [[
        print(Player.Name)
        print(Character)
    ]],
    context = {
        Player = player,
        Character = player.Character
    }
})
```

## Extending RuneU

You can add your own functions or libraries from Luau at any point:

```lua
runeu.RegisterFunction("greet", function(name)
    return "Hi, " .. tostring(name)
end)

runeu.RegisterLibrary("myLib", {
    version = "1.0",
    ping = function() return "pong" end,
})

-- protect your additions too, if you don't want scripts overwriting them
runeu.Sandbox.ProtectAll()
```
