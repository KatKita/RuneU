# Processes & Execution

Every call to `rune.Run` executes RuneU code. By default this happens as a separate "process" you can manage and stop; you can also opt into blocking, synchronous execution.

## Async (default)

```lua
local id = runeu.Run({
    code = [[ while true do wait(1) end ]]
})

-- later
runeu.Stop(id)
```

- `rune.Run(...)` immediately returns a numeric process id.
- `rune.Stop(id)` stops it:
  - Cooperatively, via a `stopped` flag checked at every loop iteration and function call — so even scripts without yields get interrupted at the next checkpoint.
  - Forcefully, via `task.cancel`, for scripts currently yielded (`wait()`, `rbx.wait()`, etc).
- `rune.IsRunning(id)` — whether a process is still active.
- `rune.GetProcess(id)` — returns `{ id, context, stopped }`, or `rune.NULL` if not found.
- `rune.GetRunningProcesses()` — array of all active process ids.

## Sync mode

```lua
local result = runeu.Run({
    code = [[ print("hi") ]],
    sync = true
})
```

In sync mode:
- Execution blocks the calling thread.
- No process is created — `rune.Stop` can't interrupt it.
- The return value is a string: `"true"` on success, or `"false <error message>"` on failure.

Use sync mode for short, trusted snippets where you need the result immediately and don't need cancellation. Use async (default) for anything long-running, anything that yields, or anything you might need to stop early.

## Errors

Runtime errors in either mode are caught with `pcall` and reported via `warn` — they never crash your game.

## Environments

```lua
runeu.SetEnv("SERVER") -- or "CLIENT", or anything else
runeu.GetGlobalTable()
```

RuneU keeps **separate global scopes** for `"SERVER"`, `"CLIENT"`, and everything else (`"OTHER"`). This lets you run RuneU on both the server and client without variables leaking between them. `rune.SetEnv` controls which scope subsequent `rune.Run` calls use; it can be locked with [`rune.Sandbox.LockEnvironment()`](sandbox.md#locking-the-environment).

## See also

- [Context](context.md) — passing data into a script
- [Extending RuneU](extending.md) — registering functions/libraries
- [Sandbox & permissions](sandbox.md)
