# `math` library

Everything from Luau's `math.*`, plus a few extras.

## Standard

`abs`, `acos`, `asin`, `atan`, `atan2`, `ceil`, `clamp`, `cos`, `cosh`, `deg`, `exp`, `floor`, `fmod`, `frexp`, `huge`, `ldexp`, `log`, `log10`, `max`, `min`, `modf`, `pi`, `pow`, `rad`, `random`, `randomseed`, `round`, `sign`, `sin`, `sinh`, `sqrt`, `tan`, `tanh`.

## Extras

### `lerp(a, b, t)`
Linear interpolation between `a` and `b`.

```
m = getlibrary("math")
print(m.lerp(0, 10, 0.5)) -- 5
```

### `map(x, inMin, inMax, outMin, outMax)`
Remaps `x` from one range to another.

```
print(m.map(5, 0, 10, 0, 100)) -- 50
```

### `dist(x1, y1, x2, y2)`
2D distance between two points.

```
print(m.dist(0, 0, 3, 4)) -- 5
```
