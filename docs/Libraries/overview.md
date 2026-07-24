# Built-in Libraries

RuneU ships four built-in libraries, accessible from scripts via `getlibrary("name")`.

```
m = getlibrary("math")
print(m.lerp(0, 10, 0.5))
```

| Library | Description |
|---|---|
| [`math`](math.md) | All of `math.*` plus `lerp`, `map`, `dist` |
| [`string`](string.md) | All of `string.*` plus `trim`, `contains`, `startsWith`, `endsWith`, `join`, `padLeft`, `padRight` |
| [`table`](table.md) | All of `table.*` plus `length`, `contains`, `keys`, `values`, `reverse` |
| [`rbx`](rbx.md) | Roblox services, instance helpers, and `RBXScriptSignal` support |

## Writing your own library

You can register your own libraries from Luau at any point:

```lua
runeu.RegisterLibrary("myLib", {
    version = "1.0",
    ping = function() return "pong" end,
})

-- protect your additions too, if you don't want scripts overwriting them
runeu.Sandbox.ProtectAll()
```

See [Extending RuneU](../Advanced/extending.md) for more on registering functions and libraries, and [Sandbox & permissions](../Advanced/sandbox.md) for protecting them.
