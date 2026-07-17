# Rune

Rune is a small scripting language built on top of Luau, made for embedding inside Roblox games. It has its own lexer, parser and interpreter, a syntax that sits somewhere between Lua and JavaScript and GO, and a few built-in libraries so you don't have to write everything from scratch.

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

Sometimes you want to let users (or your own game systems) run scripts without giving them full access to Luau — think plugin systems, custom game logic, modding support, NPC behavior scripts, etc. Rune gives you a sandboxed language you can run inside your game, with full control over what functions and libraries are exposed to it.

## Features

- Full pipeline: lexer → parser → interpreter, all written in Luau
- Familiar syntax — `func`, `if/elseif/else`, `while`, `for`, `break`, `return`
- Tables, closures, first-class functions
- A dedicated `null` type instead of relying on `nil`
- `try(...)` for catching errors without crashing the whole script
- Separate global scopes for server/client/other environments
- Easy to extend — register your own functions and libraries from Luau
- Built-in `math`, `string`, `table` and `rbx` (Roblox API) libraries

## Installation

Drop the `rune-1.0.0` folder (with `Init`, `src`, and `libraries`) somewhere in your game, e.g. `ReplicatedStorage`, then require it:

```lua
local rune = require(path.to.rune.Init)
```

## Getting started

```lua
local rune = require(path.to.rune.Init)

rune.SetEnv("SERVER") -- or "CLIENT"

rune.Run([[
    for i = 1, 5 do
        print("i =", i)
    end
]])
```

## API

- **`rune.Run(code)`** — lexes, parses and runs a string of Rune code. Runtime errors are caught and printed with `warn`, they won't crash your game.
- **`rune.SetEnv(env)`** — sets the current environment (`"SERVER"`, `"CLIENT"`, or anything else), which controls which global scope gets used.
- **`rune.GetGlobalTable()`** — returns the global variable table for the current environment.
- **`rune.RegisterFunction(name, fn)`** — exposes a Luau function to Rune scripts under a given name.
- **`rune.RegisterLibrary(name, tbl)`** — exposes a table as a library, accessible from Rune via `getlibrary(name)`.
- **`rune.NULL`** — the value Rune uses instead of `nil`.
- **`rune.VERSION`** — current version string.

## Syntax

**Variables**

```
x = 10
name = "Rune"
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

Available inside Rune scripts through `getlibrary("name")`:

- **math** — everything from `math.*`, plus `lerp`, `map`, `dist`
- **string** — everything from `string.*`, plus `trim`, `contains`, `startsWith`, `endsWith`, `join`, `padLeft`, `padRight`
- **table** — everything from `table.*`, plus `length`, `contains`, `keys`, `values`, `reverse`
- **rbx** — wraps common Roblox services and APIs: `Instance.new`, `GetService`, `FindFirstChild`, `Vector3`, `CFrame`, `Color3`, and more

```
m = getlibrary("math")
print(m.lerp(0, 10, 0.5))
```

## Extending Rune

You can add your own functions or libraries from Luau at any point:

```lua
rune.RegisterFunction("greet", function(name)
    return "Hi, " .. tostring(name)
end)

rune.RegisterLibrary("myLib", {
    version = "1.0",
    ping = function() return "pong" end,
})
```