# `rbx` library

Wraps common Roblox services and Instance APIs so RuneU scripts can interact with the game world without needing raw Luau method calls (which RuneU's sandboxed functions can't always be passed into directly).

## Instance helpers

| Function | Roblox equivalent |
|---|---|
| `rbx.new(className)` | `Instance.new(className)` |
| `getService(self, name)` | `game:GetService(name)` |
| `findFirstChild(self, name)` | `:FindFirstChild(name)` |
| `waitForChild(self, name, timeout)` | `:WaitForChild(name, timeout)` |
| `destroy(self)` | `:Destroy()` |
| `clone(self)` | `:Clone()` |
| `isA(self, className)` | `:IsA(className)` |
| `getChildren(self)` | `:GetChildren()` |
| `getDescendants(self)` | `:GetDescendants()` |
| `findFirstAncestor(self, name)` | `:FindFirstAncestor(name)` |
| `findFirstAncestorOfClass(self, className)` | `:FindFirstAncestorOfClass(className)` |
| `findFirstAncestorWhichIsA(self, className)` | `:FindFirstAncestorWhichIsA(className)` |
| `getAttribute` / `setAttribute` | `:GetAttribute()` / `:SetAttribute()` |
| `hasTag` / `setTag` / `removeTag` / `getTags` | CollectionService tag methods |
| `clearAllChildren(self)` | `:ClearAllChildren()` |

## Signals

RuneU functions are plain tables, not real Luau functions, so they can't be passed directly to `RBXScriptSignal:Connect`. These helpers wrap that for you (they also accept native Luau functions unchanged).

| Function | Description |
|---|---|
| `rbx.connect(signal, fn)` | Connects `fn`, returns the connection |
| `rbx.once(signal, fn)` | Connects `fn`, disconnects after first fire |
| `rbx.wait(signal)` | Yields until the signal fires, returns its arguments |
| `rbx.disconnect(connection)` | Disconnects a connection |
| `rbx.isConnected(connection)` | Whether a connection is still active |

```
rbx = getlibrary("rbx")
part = rbx.workspace:findFirstChild("Part")

rbx.connect(part.Touched, func(other)
    print("touched by", other:GetFullName())
end)
```

## Constructors

`Vector2`, `Vector3`, `UDim`, `UDim2`, `CFrame`, `Color3`, `Color3RGB` (`Color3.fromRGB`), `BrickColor`, `Ray`, `Rect`, `NumberSequence`, `ColorSequence`, `NumberRange`, `PhysicalProperties`, `RaycastParams`, `NumberSequenceKeypoint`, `ColorSequenceKeypoint`, `Region3int16`, `Font`, `DateTime` (`DateTime.fromUnixTimestamp`).

## Services & globals

`Enum`, `game`, `workspace`, `Players`, `RunService`, `ReplicatedStorage`, `ServerStorage`, `Lighting`, `Debris`, `TweenService`, `UserInputService`, `StarterGui`, `StarterPack`, `StarterPlayer`, `StarterCharacterScripts`, `StarterPlayerScripts`.

## Security note

Because `rbx` gives scripts real access to the game (destroying instances, changing attributes, etc.), consider using [`rune.Sandbox.ProtectMember`](../Advanced/sandbox.md#protecting-individual-library-members) to block specific dangerous members like `rbx.destroy` on a per-project basis.
