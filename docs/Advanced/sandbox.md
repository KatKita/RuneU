# Sandbox & Permissions (`rnesandbox`)

`rnesandbox` decides which global names RuneU scripts are allowed to create or overwrite. It protects registered globals, builtins, and library members from being clobbered by untrusted scripts.

By default, every built-in function and every default library (`math`, `string`, `table`, `rbx`) is protected right after RuneU loads. That means a script can't do `print = func() end` and permanently break `print` for that environment. Everything else stays freely assignable — this is "blacklist" mode.

## Protecting your own globals

```lua
rune.RegisterFunction("giveCoins", giveCoinsFn)
rune.Sandbox.Protect("giveCoins")

-- or re-protect everything registered so far (builtins + libraries + your own)
rune.Sandbox.ProtectAll()
```

Call `ProtectAll()` again any time after registering new functions/libraries, since new registrations aren't automatically protected.

## Deliberately unprotecting something

```lua
rune.Sandbox.Unprotect("print")
```

## Whitelist mode

By default RuneU runs in **blacklist** mode: everything is assignable except what's explicitly protected. You can flip to **whitelist** mode, where nothing is assignable except what you explicitly allow:

```lua
rune.Sandbox.SetMode("whitelist")
rune.Sandbox.Allow("score")
rune.Sandbox.Allow("playerName")
```

## Protecting individual library members

Sometimes you don't want to block a whole library — just one dangerous member of it (e.g. `rbx.destroy`):

```lua
rune.Sandbox.ProtectMember("rbx", "destroy")
rune.Sandbox.ProtectMembers("rbx", { "destroy", "setAttribute" })
```

Blocked members read as `null` and can't be called from RuneU scripts, even though the rest of the library stays usable.

## Locking the environment

```lua
rune.Sandbox.LockEnvironment()
```

Prevents any further calls to `rune.SetEnv` from changing which global scope (`SERVER`/`CLIENT`/other) is active.

## Errors

Trying to assign a protected/disallowed global from RuneU code raises:

```
rnesandbox: '<name>' is protected and cannot be assigned
```

`rune.Run` catches this like any other runtime error and reports it through `warn`.

## API summary

| Function | Description |
|---|---|
| `Sandbox.Protect(name)` | Protect a single global name |
| `Sandbox.Unprotect(name)` | Remove protection from a name |
| `Sandbox.ProtectAll()` | Protect all currently registered builtins/libraries |
| `Sandbox.IsProtected(name)` | Check if a name is protected |
| `Sandbox.SetMode("blacklist" \| "whitelist")` | Switch permission mode |
| `Sandbox.GetMode()` | Current mode |
| `Sandbox.Allow(name)` / `Disallow(name)` | Whitelist-mode allow list |
| `Sandbox.ProtectMember(lib, member)` / `ProtectMembers(lib, {...})` | Block specific library members |
| `Sandbox.UnprotectMember(lib, member)` | Unblock a specific member |
| `Sandbox.IsMemberProtected(lib, member)` | Check member protection |
| `Sandbox.LockEnvironment()` / `IsEnvironmentLocked()` | Lock/check the env switch |
