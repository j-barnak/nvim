{#preprocessor}

# Preprocessor

> [`Internals`](Internals.md#internals)

Preprocessor metaprogramming

This provides several macros that can be used for preprocessor metaprogramming. It is inspired by the [Boost Preprocessing library](https://www.boost.org/doc/libs/release/libs/preprocessor/doc/index.html).

## Macros

| Name | Description |
|------|-------------|
| [`PP_NARGS`](#pp_nargs)  | Get the number of variadic arguments. |
| [`PP_OVERLOAD`](#pp_overload)  | Overload a macro based on the number of arguments. |
| [`PP_CAT`](#pp_cat)  | Expand and concatenate arguments. |
| [`PP_CAT3`](#pp_cat3)  |  |
| [`PP_CAT4`](#pp_cat4)  |  |
| [`PP_CAT5`](#pp_cat5)  |  |
| [`PP_CAT6`](#pp_cat6)  |  |
| [`PP_CAT7`](#pp_cat7)  |  |
| [`PP_CAT8`](#pp_cat8)  |  |
| [`PP_MAP`](#pp_map)  | Call a macro on each variable argument. |
| [`PP_UNIQUE`](#pp_unique)  | Create a unique name. |

---

{#pp_nargs}

### PP_NARGS

```cpp
#define PP_NARGS(...)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/pp.h:50

Get the number of variadic arguments.

```cpp
PP_NARGS(a, b, c) // Expands to 3
#define ARGS x, y
PP_NARGS(ARGS) // Expands to 2
```

An empty argument list is considered to have 0 arguments.

```cpp
PP_NARGS() // Expands to 0.
```

:::note
This depends on the `, ##__VA_ARGS__` GNU C extension. `__VA_OPT__` could be used instead, but it is only supported since GCC 8 (released in 2018) and Clang 12 (released in 2021). 

:::

---

{#pp_overload}

### PP_OVERLOAD

```cpp
#define PP_OVERLOAD(prefix, ...)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/pp.h:75

Overload a macro based on the number of arguments.

This expands to `prefix` concatenated with the number of arguments (as determined by [PP_NARGS()](#pp_nargs)). Use it like so:

```cpp
#define DEFINE_ARRAY(...) PP_OVERLOAD(DEFINE_ARRAY_I, __VA_ARGS__)(__VA_ARGS__)
#define DEFINE_ARRAY_I2(name, type) DEFINE_ARRAY_I3(a, b, DEFAULT_ARRAY_SIZE)
#define DEFINE_ARRAY_I3(name, type, size) type name[size]
#define DEFAULT_ARRAY_SIZE 5

DEFINE_ARRAY(int, several); // Expands to int several[5];
DEFINE_ARRAY(int, couple, 2); // Expands to int couple[2];
```

---

{#pp_cat}

### PP_CAT

```cpp
#define PP_CAT(_0, _1)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/pp.h:107

Expand and concatenate arguments.

This expands each argument and then joins them with the `##` operator. `PP_CAT` takes two arguments, `PP_CAT3` takes three, `PP_CAT4` takes four, etc.

```cpp
#define a foo
#define b bar
PP_CAT(a, b) // Expands to foobar
```

Intermediate results are not expanded: 
```cpp
#define HELLO oops
PP_CAT3(HELL, O, WORLD) // Expands to HELLOWORLD, _not_ oopsWORLD
```

All possible intermediate results must be valid preprocessing tokens: 
```cpp
PP_CAT3(1e, +, 3) // Undefined because +3 is not a valid preprocessing token
```

---

{#pp_cat3}

### PP_CAT3

```cpp
#define PP_CAT3(_0, _1, _2) PP_CAT_I3(_0, _1, _2)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/pp.h:108

---

{#pp_cat4}

### PP_CAT4

```cpp
#define PP_CAT4(_0, _1, _2, _3) PP_CAT_I4(_0, _1, _2, _3)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/pp.h:109

---

{#pp_cat5}

### PP_CAT5

```cpp
#define PP_CAT5(_0, _1, _2, _3, _4) PP_CAT_I5(_0, _1, _2, _3, _4)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/pp.h:110

---

{#pp_cat6}

### PP_CAT6

```cpp
#define PP_CAT6(_0, _1, _2, _3, _4, _5) PP_CAT_I6(_0, _1, _2, _3, _4, _5)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/pp.h:111

---

{#pp_cat7}

### PP_CAT7

```cpp
#define PP_CAT7(_0, _1, _2, _3, _4, _5, _6) PP_CAT_I7(_0, _1, _2, _3, _4, _5, _6)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/pp.h:112

---

{#pp_cat8}

### PP_CAT8

```cpp
#define PP_CAT8(_0, _1, _2, _3, _4, _5, _6, _7) PP_CAT_I8(_0, _1, _2, _3, _4, _5, _6, _7)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/pp.h:113

---

{#pp_map}

### PP_MAP

```cpp
#define PP_MAP(func, arg, ...)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/pp.h:137

Call a macro on each variable argument.

```cpp
#define add_string(arg, x) x arg
PP_MAP(add_string, "\n", "abc", "def") // Expands to "abc" "\n" "def" "\n"
```

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `func` |  | Macro taking `arg` and the next variable argument. |
| `arg` |  | First argument to pass to `func`. |

---

{#pp_unique}

### PP_UNIQUE

```cpp
#define PP_UNIQUE(prefix)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/pp.h:222

Create a unique name.

This can be used to avoid name collisions and shadowing in macros that define local variables.

```cpp
#define SWAP(a, b) SWAP_I(a, b, PP_UNIQUE(tmp))
#define SWAP_I(a, b, tmp) do { typeof(a) tmp = (a); (a) = (b); (b) = tmp; } while (0)
```

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `prefix` |  | Prefix for unique name. This makes the created name more recognizable in compiler diagnostics and debuggers. This is not expanded. |

