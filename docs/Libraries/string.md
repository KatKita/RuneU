# `string` library

Everything from Luau's `string.*`, plus a few extras. Also accessible directly on string values (`"hi":trim()` style, via method call syntax).

## Standard

`byte`, `char`, `find`, `format`, `gmatch`, `gsub`, `len`, `lower`, `match`, `rep`, `reverse`, `sub`, `upper`, `split`.

## Extras

### `trim(s)`
Removes leading/trailing whitespace.

### `contains(s, sub)`
Plain-text substring check (not a pattern match).

```
s = getlibrary("string")
print(s.contains("hello world", "world")) -- true
```

### `startsWith(s, prefix)` / `endsWith(s, suffix)`

```
print(s.startsWith("hello", "he")) -- true
print(s.endsWith("hello", "lo"))   -- true
```

### `join(list, sep)`
Joins a list of values into a string, converting each to a string first.

```
print(s.join({1, 2, 3}, ", ")) -- "1, 2, 3"
```

### `padLeft(s, len, ch)` / `padRight(s, len, ch)`
Pads a string to at least `len` characters using `ch` (default `" "`).

```
print(s.padLeft("7", 3, "0"))  -- "007"
print(s.padRight("7", 3, "0")) -- "700"
```
