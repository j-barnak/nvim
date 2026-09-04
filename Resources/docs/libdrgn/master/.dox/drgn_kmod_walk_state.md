{#drgn_kmod_walk_state}

# drgn_kmod_walk_state

```cpp
#include <debug_info.h>
```

```cpp
struct drgn_kmod_walk_state
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.h:339

## Public Attributes

| Return | Name | Description |
|--------|------|-------------|
| `struct drgn_kmod_walk_module_map` | [`modules`](#modules-2)  |  |
| `struct drgn_kmod_walk_stack` | [`stack`](#stack)  |  |
| struct [`string_builder`](string_builder.md#string_builder-1) | [`path`](#path-1)  |  |
| `struct drgn_kmod_walk_inode_set` | [`visited_dirs`](#visited_dirs)  |  |
| `const char *const  *` | [`next_kernel_dir`](#next_kernel_dir)  |  |
| `const char *const  *` | [`next_debug_dir`](#next_debug_dir)  |  |
| `bool` | [`duplicate_names`](#duplicate_names)  |  |

---

{#modules-2}

### modules

```cpp
struct drgn_kmod_walk_module_map modules
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.h:340

---

{#stack}

### stack

```cpp
struct drgn_kmod_walk_stack stack
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.h:341

---

{#path-1}

### path

```cpp
struct string_builder path
```

Type: struct [`string_builder`](string_builder.md#string_builder-1)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.h:342

---

{#visited_dirs}

### visited_dirs

```cpp
struct drgn_kmod_walk_inode_set visited_dirs
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.h:343

---

{#next_kernel_dir}

### next_kernel_dir

```cpp
const char *const  * next_kernel_dir
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.h:344

---

{#next_debug_dir}

### next_debug_dir

```cpp
const char *const  * next_debug_dir
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.h:345

---

{#duplicate_names}

### duplicate_names

```cpp
bool duplicate_names
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.h:346

