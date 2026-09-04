{#drgn_standard_debug_info_find_state}

# drgn_standard_debug_info_find_state

```cpp
#include <debug_info.h>
```

```cpp
struct drgn_standard_debug_info_find_state
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.h:351

## Public Attributes

| Return | Name | Description |
|--------|------|-------------|
| struct [`drgn_module`](drgn_module.md#drgn_module) *const  * | [`modules`](#modules-3)  |  |
| `size_t` | [`num_modules`](#num_modules)  |  |
| struct [`depmod_index`](depmod_index.md#depmod_index) | [`modules_dep`](#modules_dep)  |  |
| struct [`drgn_kmod_walk_state`](drgn_kmod_walk_state.md#drgn_kmod_walk_state) | [`kmod_walk`](#kmod_walk)  |  |

---

{#modules-3}

### modules

```cpp
struct drgn_module *const  * modules
```

Type: struct [`drgn_module`](drgn_module.md#drgn_module) *const  *

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.h:352

---

{#num_modules}

### num_modules

```cpp
size_t num_modules
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.h:353

---

{#modules_dep}

### modules_dep

```cpp
struct depmod_index modules_dep
```

Type: struct [`depmod_index`](depmod_index.md#depmod_index)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.h:354

---

{#kmod_walk}

### kmod_walk

```cpp
struct drgn_kmod_walk_state kmod_walk
```

Type: struct [`drgn_kmod_walk_state`](drgn_kmod_walk_state.md#drgn_kmod_walk_state)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.h:355

