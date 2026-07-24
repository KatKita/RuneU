# Quickstart

This page gets you from "installed" to "first script running" in a couple of minutes.

## 1. Require RuneU

```lua
local runeu = require(path.to.rne.Init)
```

## 2. Run some code

```lua
runeu.Run([[
    print("Hello from RuneU!")
]])
```

## 3. Pass data in with `context`

`context` lets you expose values to a script without registering global functions or libraries.

```lua
runeu.Run({
    code = [[
        print("Hello, " .. name)
    ]],
    context = {
        name = "World"
    }
})
```

## 4. Register your own functions

```lua
runeu.RegisterFunction("double", function(x)
    return x * 2
end)

runeu.Run([[
    print(double(21))
]])
```

## 5. Stop a running script

`runeu.Run` returns a process id you can use to stop it later:

```lua
local id = runeu.Run([[
    while true do
        wait(1)
    end
]])

runeu.Stop(id)
```

## Next steps

- [Language basics](../Language/syntax.md) — variables, functions, control flow
- [Built-in libraries](../Libraries/overview.md) — `math`, `string`, `table`, `rbx`
- [Sandbox & permissions](../Advanced/sandbox.md) — locking down what scripts can touch
- [Processes & execution](../Advanced/processes.md) — sync vs async, stopping scripts
