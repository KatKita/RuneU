# Run Context

`context` lets you pass custom values directly into a script's global scope, without permanently registering a function or library.

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

## How it resolves

When a script reads a name that isn't a local variable, RuneU looks it up in this order:

1. Local/enclosing scopes (normal variable lookup)
2. The current process's `context` table
3. Registered builtins (`rune.RegisterFunction`)
4. Registered libraries (`rune.RegisterLibrary`)
5. Otherwise, `null`

This means `context` values are per-run and don't need sandbox protection the way global registrations do — each `rune.Run` call gets its own `context`, scoped to that process.

## When to use context vs. RegisterFunction

- **Use `context`** for values specific to a single run — the player who triggered the script, a specific instance, a one-off config table.
- **Use `RegisterFunction` / `RegisterLibrary`** for capabilities that should be available to *every* script, every time, and that you'll want to [protect](sandbox.md) from being overwritten.
