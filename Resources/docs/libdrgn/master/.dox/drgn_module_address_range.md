{#drgn_module_address_range-1}

# drgn_module_address_range

```cpp
#include <debug_info.h>
```

```cpp
struct drgn_module_address_range
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.h:192

## Public Attributes

| Return | Name | Description |
|--------|------|-------------|
| struct [`binary_tree_node`](binary_tree_node.md#binary_tree_node) | [`node`](#node)  | Node in [drgn_debug_info::modules_by_address](drgn_debug_info.md#modules_by_address). |
| `uint64_t` | [`start`](#start)  | Address range. |
| `uint64_t` | [`end`](#end-1)  |  |
| struct [`drgn_module`](drgn_module.md#drgn_module) * | [`module`](#module)  | [Module](Module.md#module-3) owning this range. |

---

{#node}

### node

```cpp
struct binary_tree_node node
```

Type: struct [`binary_tree_node`](binary_tree_node.md#binary_tree_node)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.h:194

Node in [drgn_debug_info::modules_by_address](drgn_debug_info.md#modules_by_address).

---

{#start}

### start

```cpp
uint64_t start
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.h:196

Address range.

---

{#end-1}

### end

```cpp
uint64_t end
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.h:196

---

{#module}

### module

```cpp
struct drgn_module * module
```

Type: struct [`drgn_module`](drgn_module.md#drgn_module) *

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.h:198

[Module](Module.md#module-3) owning this range.

