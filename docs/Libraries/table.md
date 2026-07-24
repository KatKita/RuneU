# `table` library

Everything from Luau's `table.*`, plus a few extras.

## Standard

`clear`, `clone`, `concat`, `create`, `find`, `freeze`, `insert`, `isfrozen`, `move`, `pack`, `remove`, `sort`, `unpack`.

## Extras

### `length(t)`
Same as `#t`, exposed as a function.

### `contains(t, value)`
Whether `value` exists anywhere in the array part of `t`.

```
t = getlibrary("table")
print(t.contains({1, 2, 3}, 2)) -- true
```

### `keys(t)` / `values(t)`
Returns an array of all keys, or all values, in `t` (uses `pairs`, so works on non-array tables too).

### `reverse(t)`
Returns a new array with elements in reverse order.

```
print(t.reverse({1, 2, 3})) -- {3, 2, 1}
```
