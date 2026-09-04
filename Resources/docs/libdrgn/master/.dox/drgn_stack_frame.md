{#drgn_stack_frame}

# drgn_stack_frame

```cpp
#include <stack_trace.h>
```

```cpp
struct drgn_stack_frame
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/stack_trace.h:30

## Public Attributes

| Return | Name | Description |
|--------|------|-------------|
| struct [`drgn_register_state`](drgn_register_state.md#drgn_register_state) * | [`regs`](#regs)  |  |
| `Dwarf_Die *` | [`scopes`](#scopes)  |  |
| `size_t` | [`num_scopes`](#num_scopes)  |  |
| `size_t` | [`function_scope`](#function_scope)  |  |

---

{#regs}

### regs

```cpp
struct drgn_register_state * regs
```

Type: struct [`drgn_register_state`](drgn_register_state.md#drgn_register_state) *

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/stack_trace.h:31

---

{#scopes}

### scopes

```cpp
Dwarf_Die * scopes
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/stack_trace.h:32

---

{#num_scopes}

### num_scopes

```cpp
size_t num_scopes
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/stack_trace.h:33

---

{#function_scope}

### function_scope

```cpp
size_t function_scope
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/stack_trace.h:34

