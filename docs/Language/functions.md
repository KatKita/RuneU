# Built-in Functions

These are available globally inside any RuneU script, without needing `getlibrary`.

## Output

| Function | Description |
|---|---|
| `print(...)` | Prints values, tab-separated |
| `warn(...)` | Same as `print`, but as a warning |

## Types

| Function | Description |
|---|---|
| `type(v)` | Lua-style type name (`"null"` for RuneU's null) |
| `typeof(v)` | Roblox-style type name |
| `str(v)` | Converts to string |
| `num(v)` | Converts to number |

## Iteration

| Function | Description |
|---|---|
| `pairs(t)` | Iterate all key/value pairs |
| `each(t)` | Iterate array-like tables (alias for `ipairs`) |
| `next(t)` | Raw next-key iterator |

## Libraries

| Function | Description |
|---|---|
| `createlibrary(name)` / `newlib(name)` | Creates and registers a new library table |
| `getlibrary(name)` / `getlib(name)` | Fetches a registered library |

## Safety

| Function | Description |
|---|---|
| `try(fn, ...)` | Calls `fn` and catches errors, returns `ok, result` |
| `assert(cond, msg)` | Raises an error if `cond` is falsy |
| `err(msg)` / `error(msg)` | Raises an error |

## Timing & tasks

| Function | Description |
|---|---|
| `tick()` | Current time (`os.clock()`) |
| `wait(seconds)` | Yields the current script |
| `runne(fn, ...)` | Spawns `fn` as a new task (`task.spawn`) |
| `rundefer(fn, ...)` | Defers `fn` to run later this frame (`task.defer`) |
| `rundelay(seconds, fn, ...)` | Runs `fn` after a delay (`task.delay`) |
| `runcancel(thread)` | Cancels a spawned thread |

## Direct Luau access

`assert`, `err`/`error`, `co` (coroutine), `bit32`, `os` (`clock`, `date`, `difftime`, `time`), `utf8`, `raweq`, `rawread`, `rawwrite`, `getmeta`, `setmeta`, `pick` (`select`), `spread` (`table.unpack`).

> Note: `_G` is intentionally **not** exposed, for sandboxing/security reasons.

## Next

- [Libraries overview](../Libraries/overview.md)
- [Sandbox & permissions](../Advanced/sandbox.md)
