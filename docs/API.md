# API Reference

Quick reference for everything on the `runeu` table returned by `require(path.to.rne.Init)`. For deeper explanations follow the links.

| Member | Description |
|---|---|
| `runeu.Run(code)` / `runeu.Run({code, context, sync})` | Runs RuneU code. See [Processes & execution](Advanced/processes.md) and [Context](Advanced/context.md) |
| `runeu.Stop(id)` | Stops a running process |
| `runeu.IsRunning(id)` | Whether a process id is still active |
| `runeu.GetProcess(id)` | Returns `{ id, context, stopped }` or `runeu.NULL` |
| `runeu.GetRunningProcesses()` | Array of active process ids |
| `runeu.SetEnv(env)` | Sets the active global scope (`"SERVER"`, `"CLIENT"`, or other) |
| `runeu.GetGlobalTable()` | Returns the global variable table for the current environment |
| `runeu.RegisterFunction(name, fn)` | Exposes a Luau function to scripts. See [Extending RuneU](Advanced/extending.md) |
| `runeu.RegisterLibrary(name, tbl)` | Exposes a table as a library |
| `runeu.NULL` | The value RuneU uses instead of `nil` |
| `runeu.VERSION` | Current version string |
| `runeu.Sandbox` | The `rnesandbox` permission API. See [Sandbox & permissions](Advanced/sandbox.md) |

## See also

- [Getting Started](Getting-Started/quickstart.md)
- [Language syntax](Language/syntax.md)
- [Built-in functions](Language/functions.md)
- [Libraries](Libraries/overview.md)
