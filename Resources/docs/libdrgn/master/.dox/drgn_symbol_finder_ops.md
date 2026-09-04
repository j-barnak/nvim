{#drgn_symbol_finder_ops}

# drgn_symbol_finder_ops

```cpp
#include <drgn.h>
```

```cpp
struct drgn_symbol_finder_ops
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:1342

[Symbol](Symbol.md#symbol) finder callback table.

## Public Attributes

| Return | Name | Description |
|--------|------|-------------|
| `void(*` | [`destroy`](#destroy-3)  | Callback to destroy the symbol finder. |
| struct [`drgn_error`](drgn_error.md#drgn_error) *(* | [`find`](#find-3)  | Callback for finding one or more symbols. |

---

{#destroy-3}

### destroy

```cpp
void(* destroy)(void *arg)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:1351

Callback to destroy the symbol finder.

This may be `NULL`.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `arg` |  | Argument passed to [drgn_program_register_symbol_finder()](Programs.md#drgn_program_register_symbol_finder). |

---

{#find-3}

### find

```cpp
struct drgn_error *(* find)(const char *name, uint64_t addr, enum drgn_find_symbol_flags flags, void *arg, struct drgn_symbol_result_builder *builder)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:1351

Callback for finding one or more symbols.

The callback should perform a symbol lookup based on the flags given in `flags`. When multiple flags are provided, the effect should be treated as a logical AND. [Symbol](Symbol.md#symbol) results should be added to the result builder `builder`, via [drgn_symbol_result_builder_add()](Programs.md#drgn_symbol_result_builder_add). When [DRGN_FIND_SYMBOL_ONE](Programs.md#group__Programs_1gga68a2d31672c92f6653ea1836a5de860dab362c2f2c3f86cb859eea1e70c78bc3c) is set, then the finding function should only return the single best symbol result, and short-circuit return.

When no symbol is found, simply do not add any result to the builder. No error should be returned in this case.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `name` |  | Name of the symbol to match |
| `addr` |  | Address of the symbol to match |
| `flags` |  | Flags indicating the desired behavior of the search |
| `arg` |  | Argument passed to [drgn_program_register_symbol_finder()](Programs.md#drgn_program_register_symbol_finder). |
| `builder` |  | Used to build the resulting symbol output |

