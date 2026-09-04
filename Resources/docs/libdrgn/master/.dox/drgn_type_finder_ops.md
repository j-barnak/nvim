{#drgn_type_finder_ops}

# drgn_type_finder_ops

```cpp
#include <drgn.h>
```

```cpp
struct drgn_type_finder_ops
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:620

Type finder callback table.

## Public Attributes

| Return | Name | Description |
|--------|------|-------------|
| `void(*` | [`destroy`](#destroy-1)  | Callback to destroy the type finder. |
| struct [`drgn_error`](drgn_error.md#drgn_error) *(* | [`find`](#find-1)  | Callback for finding a type. |

---

{#destroy-1}

### destroy

```cpp
void(* destroy)(void *arg)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:629

Callback to destroy the type finder.

This may be `NULL`.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `arg` |  | Argument passed to [drgn_program_register_type_finder()](Programs.md#drgn_program_register_type_finder). |

---

{#find-1}

### find

```cpp
struct drgn_error *(* find)(uint64_t kinds, const char *name, size_t name_len, const char *filename, void *arg, struct drgn_qualified_type *ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:629

Callback for finding a type.

#### Returns
`NULL` on success, non-`NULL` on error. In particular, if the type is not found, this should return &[drgn_not_found](ErrorHandling.md#drgn_not_found); any other errors are considered fatal.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `kinds` |  | Kinds of types to find, as a bitmask of bits shifted by [drgn_type_kind](drgn_type_kind.md#drgn_type_kind). E.g., `(1 << DRGN_TYPE_STRUCT) | (1 << DRGN_TYPE_CLASS)` means to find a structure or class type. |
| `name` |  | Name of type (or tag, for structs, unions, and enums). This is *not* null-terminated. |
| `name_len` |  | Length of `name`. |
| `filename` |  | Filename containing the type definition or `NULL`. This should be matched with [drgn_filename_matches()](Programs.md#drgn_filename_matches). |
| `arg` |  | Argument passed to [drgn_program_register_type_finder()](Programs.md#drgn_program_register_type_finder). |
| `ret` |  | Returned type. |

