# Extending RuneU

You can add your own functions or libraries from Luau at any point, letting RuneU scripts call into your game's own systems.

## Registering a function

```lua
runeu.RegisterFunction("greet", function(name)
    return "Hi, " .. tostring(name)
end)
```

Now available in any script:

```
print(greet("World")) -- "Hi, World"
```

## Registering a library

```lua
runeu.RegisterLibrary("myLib", {
    version = "1.0",
    ping = function() return "pong" end,
})
```

```
lib = getlibrary("myLib")
print(lib.ping()) -- "pong"
```

## Protecting your additions

Registrations are **not** automatically protected from being overwritten by scripts. If you don't want a script doing `myLib = null`, protect it after registering:

```lua
runeu.Sandbox.ProtectAll()
```

See [Sandbox & permissions](sandbox.md) for finer-grained control (protecting individual members, whitelist mode, etc).

## Loading libraries from folders

If you're organizing your project the way the repo does (a `libraries` folder of ModuleScripts next to `Init`), RuneU automatically requires and registers every ModuleScript under `libraries` on load — see `rne/Init.luau`'s `loadLibraries()`. Each module should return a function that takes `rune` and calls `rune.RegisterLibrary`, matching the pattern used in `rne/libraries/math.luau`, `string.luau`, `table.luau`, and `rbx.luau`.

## Loading RuneU scripts from folders (`othr/Starter.luau`)

The `othr/Starter.luau` example shows a pattern for auto-running a folder of `.rne` scripts (stored as `StringValue`s) at game start — useful for game-specific libraries like `othr/libraries/gamesw.rne`. Each `StringValue`'s `Value` is run through `runeu.Run`, and failures are caught and warned individually so one broken script doesn't stop the rest from loading.
