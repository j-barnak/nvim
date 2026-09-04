{#linux_kernel_loaded_module_iterator}

# linux_kernel_loaded_module_iterator

```cpp
struct linux_kernel_loaded_module_iterator
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/linux_kernel.c:1636

## Public Attributes

| Return | Name | Description |
|--------|------|-------------|
| struct [`drgn_module_iterator`](drgn_module_iterator.md#drgn_module_iterator) | [`it`](#it-5)  |  |
| `bool` | [`yielded_vmlinux`](#yielded_vmlinux)  |  |
| `int` | [`module_list_iterations_remaining`](#module_list_iterations_remaining)  |  |
| struct [`drgn_qualified_type`](drgn_qualified_type.md#drgn_qualified_type) | [`module_type`](#module_type)  |  |
| struct [`drgn_object`](drgn_object.md#drgn_object-1) | [`node`](#node-2)  |  |
| `uint64_t` | [`modules_head`](#modules_head)  |  |

---

{#it-5}

### it

```cpp
struct drgn_module_iterator it
```

Type: struct [`drgn_module_iterator`](drgn_module_iterator.md#drgn_module_iterator)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/linux_kernel.c:1637

---

{#yielded_vmlinux}

### yielded_vmlinux

```cpp
bool yielded_vmlinux
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/linux_kernel.c:1638

---

{#module_list_iterations_remaining}

### module_list_iterations_remaining

```cpp
int module_list_iterations_remaining
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/linux_kernel.c:1639

---

{#module_type}

### module_type

```cpp
struct drgn_qualified_type module_type
```

Type: struct [`drgn_qualified_type`](drgn_qualified_type.md#drgn_qualified_type)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/linux_kernel.c:1641

---

{#node-2}

### node

```cpp
struct drgn_object node
```

Type: struct [`drgn_object`](drgn_object.md#drgn_object-1)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/linux_kernel.c:1643

---

{#modules_head}

### modules_head

```cpp
uint64_t modules_head
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/linux_kernel.c:1645

