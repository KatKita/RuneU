# RuneU

RuneU is a scripting language built on top of Luau, made for embedding inside Roblox games. It has its own lexer, parser and interpreter, a syntax that sits somewhere between Lua, JavaScript and Go, and a few built-in libraries so you don't have to write everything from scratch.

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
- Built-in `math`, `string`, `table` and `rbx` (Roblox API) libraries, including `RBXScriptSignal` support

## Documentation

New here? Read these in order:

1. **[Installation](Getting-Started/installation.md)** — install via the Roblox Studio command bar installer
2. **[Quickstart](Getting-Started/quickstart.md)** — your first script, in under 5 minutes
3. **[Language syntax](Language/syntax.md)** — variables, functions, control flow, tables, operators
4. **[Built-in functions](Language/functions.md)** — `print`, `try`, `wait`, task spawning, and more
5. **[Libraries](Libraries/overview.md)** — `math`, `string`, `table`, and `rbx` (Roblox API)
6. **[Context](Advanced/context.md)** — passing data into a running script
7. **[Processes & execution](Advanced/processes.md)** — sync vs async, stopping scripts, server/client environments
8. **[Sandbox & permissions](Advanced/sandbox.md)** — protecting globals and library members from being overwritten
9. **[Extending RuneU](Advanced/extending.md)** — registering your own functions and libraries

Looking for something specific instead? See the **[full API reference](API.md)**.

## Installation

See [Getting Started/installation.md](Getting-Started/installation.md) for the full guide. Short version: enable HTTP requests in Studio, run the installer script from the Command Bar, and it downloads the `rne` folder from GitHub straight into `ReplicatedStorage`.

## License

MIT — see [LICENSE](../LICENSE).
