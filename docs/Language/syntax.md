# Syntax

RuneU's syntax sits somewhere between Lua, JavaScript and Go. If you know Lua, most of this will feel familiar.

## Variables

```
x = 10
name = "RuneU"
isReady = true
nothing = null
```

There is no `local` keyword — every assignment at the top of a scope creates a variable in that scope. RuneU uses a dedicated `null` type instead of relying on Luau's `nil`.

## Functions

```
func add(a, b)
    return a + b
end

double = func(x)
    return x * 2
end
```

Functions are first-class values and close over their surrounding scope, so you can pass them around, store them in tables, and return them from other functions.

## Conditionals

```
if x > 10 then
    print("big")
elseif x > 0 then
    print("small")
else
    print("non-positive")
end
```

## Loops

```
for i = 1, 10 do
    if i == 5 then break end
    print(i)
end

while x > 0 do
    x = x - 1
end

repeat
    x = x - 1
until x <= 0
```

## Tables

```
t = { 1, 2, 3, key = "value", [10] = "ten" }
print(t.key)
print(t[10])
```

## Operators

| Category   | Operators                     |
|------------|--------------------------------|
| Math       | `+ - * / % ^`                  |
| Comparison | `== != < > <= >=`             |
| Logic      | `and or not`                   |
| Concat     | `..`                            |
| Length     | `#t`                            |

## Errors and `try`

`try(fn, ...)` calls a function safely without crashing the whole script:

```
ok, result = try(func()
    return riskyThing()
end)

if ok then
    print(result)
else
    print("failed:", result)
end
```

## Next

- [Built-in functions](functions.md)
- [Libraries overview](../Libraries/overview.md)
