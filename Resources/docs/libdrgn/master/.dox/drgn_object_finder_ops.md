{#drgn_object_finder_ops}

# drgn_object_finder_ops

```cpp
#include <drgn.h>
```

```cpp
struct drgn_object_finder_ops
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:718

Object finder callback table.

## Public Attributes

| Return | Name | Description |
|--------|------|-------------|
| `void(*` | [`destroy`](#destroy-2)  | Callback to destroy the object finder. |
| struct [`drgn_error`](drgn_error.md#drgn_error) *(* | [`find`](#find-2)  | Callback for finding an object. |

---

{#destroy-2}

### destroy

```cpp
void(* destroy)(void *arg)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:727

Callback to destroy the object finder.

This may be `NULL`.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `arg` |  | Argument passed to [drgn_program_register_object_finder()](Programs.md#drgn_program_register_object_finder). |

---

{#find-2}

### find

```cpp
struct drgn_error *(* find)(const char *name, size_t name_len, const char *filename, enum drgn_find_object_flags flags, void *arg, struct drgn_object *ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:727

Callback for finding an object.

#### Returns
`NULL` on success, non-`NULL` on error. In particular, if the object is not found, this should return &[drgn_not_found](ErrorHandling.md#drgn_not_found); any other errors are considered fatal.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `name` |  | Name of object. This is *not* null-terminated. |
| `name_len` |  | Length of `name`. |
| `filename` |  | Filename containing the object definition or `NULL`. This should be matched with [drgn_filename_matches()](Programs.md#drgn_filename_matches). |
| `flags` |  | Flags indicating what kind of object to look for. |
| `arg` |  | Argument passed to [drgn_program_register_object_finder()](Programs.md#drgn_program_register_object_finder). |
| `ret` |  | Returned object. This must only be modified on success. |

