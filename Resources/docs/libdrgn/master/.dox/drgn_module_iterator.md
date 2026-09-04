{#drgn_module_iterator}

# drgn_module_iterator

```cpp
#include <debug_info.h>
```

```cpp
struct drgn_module_iterator
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.h:165

## Public Attributes

| Return | Name | Description |
|--------|------|-------------|
| struct [`drgn_program`](drgn_program.md#drgn_program) * | [`prog`](#prog-4)  |  |
| [`drgn_module_iterator_destroy_fn`](DebugInfo.md#drgn_module_iterator_destroy_fn) * | [`destroy`](#destroy-4)  |  |
| [`drgn_module_iterator_next_fn`](DebugInfo.md#drgn_module_iterator_next_fn) * | [`next`](#next)  |  |
| `bool` | [`for_load_debug_info`](#for_load_debug_info)  |  |

---

{#prog-4}

### prog

```cpp
struct drgn_program * prog
```

Type: struct [`drgn_program`](drgn_program.md#drgn_program) *

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.h:166

---

{#destroy-4}

### destroy

```cpp
drgn_module_iterator_destroy_fn * destroy
```

Type: [`drgn_module_iterator_destroy_fn`](DebugInfo.md#drgn_module_iterator_destroy_fn) *

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.h:167

---

{#next}

### next

```cpp
drgn_module_iterator_next_fn * next
```

Type: [`drgn_module_iterator_next_fn`](DebugInfo.md#drgn_module_iterator_next_fn) *

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.h:168

---

{#for_load_debug_info}

### for_load_debug_info

```cpp
bool for_load_debug_info
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.h:169

