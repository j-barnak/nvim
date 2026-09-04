{#drgn_memory_segment}

# drgn_memory_segment

```cpp
struct drgn_memory_segment
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/memory_reader.c:108

Memory segment in a [drgn_memory_reader](drgn_memory_reader.md#drgn_memory_reader).

## Public Attributes

| Return | Name | Description |
|--------|------|-------------|
| struct [`binary_tree_node`](binary_tree_node.md#binary_tree_node) | [`node`](#node-1)  |  |
| `uint64_t` | [`min_address`](#min_address-1)  | Address range of the segment in memory (inclusive). |
| `uint64_t` | [`max_address`](#max_address-1)  |  |
| `uint64_t` | [`orig_min_address`](#orig_min_address)  | The address of the segment when it was added, before any truncations. |
| [`drgn_memory_read_fn`](Programs.md#drgn_memory_read_fn) | [`read_fn`](#read_fn)  | Read callback. |
| `void *` | [`arg`](#arg-6)  | Argument to pass to [drgn_memory_segment::read_fn](#read_fn). |

---

{#node-1}

### node

```cpp
struct binary_tree_node node
```

Type: struct [`binary_tree_node`](binary_tree_node.md#binary_tree_node)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/memory_reader.c:109

---

{#min_address-1}

### min_address

```cpp
uint64_t min_address
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/memory_reader.c:111

Address range of the segment in memory (inclusive).

---

{#max_address-1}

### max_address

```cpp
uint64_t max_address
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/memory_reader.c:111

---

{#orig_min_address}

### orig_min_address

```cpp
uint64_t orig_min_address
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/memory_reader.c:118

The address of the segment when it was added, before any truncations.

This is always less than or equal to [drgn_memory_segment::min_address](#min_address-1).

---

{#read_fn}

### read_fn

```cpp
drgn_memory_read_fn read_fn
```

Type: [`drgn_memory_read_fn`](Programs.md#drgn_memory_read_fn)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/memory_reader.c:120

Read callback.

---

{#arg-6}

### arg

```cpp
void * arg
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/memory_reader.c:122

Argument to pass to [drgn_memory_segment::read_fn](#read_fn).

