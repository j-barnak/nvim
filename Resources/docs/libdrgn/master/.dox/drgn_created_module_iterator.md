{#drgn_created_module_iterator}

# drgn_created_module_iterator

```cpp
struct drgn_created_module_iterator
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.c:3322

## Public Attributes

| Return | Name | Description |
|--------|------|-------------|
| struct [`drgn_module_iterator`](drgn_module_iterator.md#drgn_module_iterator) | [`it`](#it-3)  |  |
| `struct drgn_module_table_iterator` | [`table_it`](#table_it)  |  |
| struct [`drgn_module`](drgn_module.md#drgn_module) * | [`next_module`](#next_module)  |  |
| `uint64_t` | [`generation`](#generation)  |  |
| `bool` | [`yielded_main`](#yielded_main)  |  |

---

{#it-3}

### it

```cpp
struct drgn_module_iterator it
```

Type: struct [`drgn_module_iterator`](drgn_module_iterator.md#drgn_module_iterator)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.c:3323

---

{#table_it}

### table_it

```cpp
struct drgn_module_table_iterator table_it
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.c:3324

---

{#next_module}

### next_module

```cpp
struct drgn_module * next_module
```

Type: struct [`drgn_module`](drgn_module.md#drgn_module) *

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.c:3325

---

{#generation}

### generation

```cpp
uint64_t generation
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.c:3326

---

{#yielded_main}

### yielded_main

```cpp
bool yielded_main
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.c:3327

