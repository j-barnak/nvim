{#drgn_debug_info_finder_ops}

# drgn_debug_info_finder_ops

```cpp
#include <drgn.h>
```

```cpp
struct drgn_debug_info_finder_ops
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:1878

Debugging information finder callback table.

## Public Attributes

| Return | Name | Description |
|--------|------|-------------|
| `void(*` | [`destroy`](#destroy)  | Callback to destroy the debug info finder. |
| struct [`drgn_error`](drgn_error.md#drgn_error) *(* | [`find`](#find)  | Callback for finding debug info. |

---

{#destroy}

### destroy

```cpp
void(* destroy)(void *arg)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:1887

Callback to destroy the debug info finder.

This may be `NULL`.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `arg` |  | Argument passed to [drgn_program_register_debug_info_finder()](Modules.md#drgn_program_register_debug_info_finder). |

---

{#find}

### find

```cpp
struct drgn_error *(* find)(struct drgn_module *const *modules, size_t num_modules, void *arg)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:1887

Callback for finding debug info.

#### Returns
`NULL` on success, non-`NULL` on error. It is not an error for some debugging information to not be found.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `modules` |  | Array of modules that want debugging information. |
| `num_modules` |  | Number of modules in `modules`. |
| `arg` |  | Argument passed to [drgn_program_register_debug_info_finder()](Modules.md#drgn_program_register_debug_info_finder). |

