# RuneU

RuneU is a small scripting language built on top of Luau, made for embedding inside Roblox games. It has its own lexer, parser and interpreter, a syntax that sits somewhere between Lua and JavaScript and GO, and a few built-in libraries so you don't have to write everything from scratch.

```lua
rune.RegisterFunction("double", function(x) return x * 2 end)

rune.Run([[
    func greet(name)
        print("Hello, " .. name)
    end

    greet("World")
    print(double(21))
]])
```

## Why

Sometimes you want to let users (or your own game systems) run scripts without giving them full access to Luau — think plugin systems, custom game logic, modding support, NPC behavior scripts, etc. RuneU gives you a sandboxed language you can run inside your game, with full control over what functions and libraries are exposed to it.

## Features

- Full pipeline: lexer → parser → interpreter, all written in Luau
- Familiar syntax — `func`, `if/elseif/else`, `while`, `for`, `break`, `return`
- Tables, closures, first-class functions
- A dedicated `null` type instead of relying on `nil`
- `try(...)` for catching errors without crashing the whole script
- **`rnesandbox`** — a permission layer that decides which global names scripts can create or overwrite, plus a lock so a script's environment (server/client/other) can never be switched after the fact
- Separate global scopes for server/client/other environments
- Easy to extend — register your own functions and libraries from Luau
- Built-in `math`, `string`, `table` and `rbx` (Roblox API) libraries, including `RBXScriptSignal` support (`rbx.connect`, `rbx.once`, `rbx.wait`, `rbx.disconnect`)

## Installation

Drop the `rne` folder (with `Init`, `src`, and `libraries`) somewhere in your game, e.g. `ReplicatedStorage`, then require it. Make sure the folder that holds `State`/`Lexer`/`Parser`/`Interpreter`/`RuneFuncs`/`RuneSandbox` is named `src` — that's the name `Init.luau` requires.

```lua
local rune = require(path.to.rne.Init)
```

## Getting started

```lua
local rune = require(path.to.rne.Init)

rune.SetEnv("SERVER") -- or "CLIENT"
rune.Sandbox.LockEnvironment() -- prevent this realm's script from ever being switched to another one

rune.Run([[
    for i = 1, 5 do
        print("i =", i)
    end
]])
```

## API

- **`rune.Run(code)`** — lexes, parses and runs a string of RuneU code. Runtime errors are caught and printed with `warn`, they won't crash your game.
- **`rune.SetEnv(env)`** — sets the current environment (`"SERVER"`, `"CLIENT"`, or anything else), which controls which global scope gets used. Fails once `rune.Sandbox.LockEnvironment()` has been called.
- **`rune.GetGlobalTable()`** — returns the global variable table for the current environment.
- **`rune.RegisterFunction(name, fn)`** — exposes a Luau function to RuneU scripts under a given name.
- **`rune.RegisterLibrary(name, tbl)`** — exposes a table as a library, accessible from RuneU via `getlibrary(name)`.
- **`rune.NULL`** — the value RuneU uses instead of `nil`.
- **`rune.VERSION`** — current version string.
- **`rune.Sandbox`** — the `rnesandbox` permission API, see below.

## rnesandbox

`rnesandbox` decides which global names RuneU scripts are allowed to create or overwrite, and lets you lock an environment in place so a script can never be re-pointed at another realm's globals (e.g. a client script reading server-only state).

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

-- lock the SERVER/CLIENT/OTHER split so this realm can never be switched again
rune.Sandbox.LockEnvironment()
```

Trying to assign a protected/disallowed global from RuneU code raises a `rnesandbox: '<name>' is protected and cannot be assigned` error, which `rune.Run` catches and reports through `warn` like any other runtime error.

Note: server and client scripts are already separate Luau VMs in Roblox, so a client script has no way to reach a server script's memory (and vice versa) regardless of RuneU. `LockEnvironment()` closes the one remaining risk inside a single realm: a script or a bug calling `rune.SetEnv` again to swap which global table it's reading and writing.

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

## Extending RuneU

You can add your own functions or libraries from Luau at any point:

```lua
rune.RegisterFunction("greet", function(name)
    return "Hi, " .. tostring(name)
end)

rune.RegisterLibrary("myLib", {
    version = "1.0",
    ping = function() return "pong" end,
})

-- protect your additions too, if you don't want scripts overwriting them
rune.Sandbox.ProtectAll()
```
