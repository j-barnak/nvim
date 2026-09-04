{#drgn_dwarf_index_iterator}

# drgn_dwarf_index_iterator

```cpp
struct drgn_dwarf_index_iterator
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:2582

Iterator over DWARF debugging information.

An iterator is initialized with drgn_dwarf_index_iterator_init(). It is advanced with drgn_dwarf_index_iterator_next().

## Public Attributes

| Return | Name | Description |
|--------|------|-------------|
| struct [`drgn_namespace_dwarf_index`](drgn_namespace_dwarf_index.md#drgn_namespace_dwarf_index) * | [`ns`](#ns)  |  |
| `const char *` | [`name`](#name-14)  |  |
| `size_t` | [`name_len`](#name_len-1)  |  |
| enum [`drgn_dwarf_index_tag`](drgn_dwarf_index_tag.md#dwarf__info_8h_1ad65bd7851754881c9b9c251fc33b90fc) * | [`tags`](#tags)  |  |
| `size_t` | [`num_tags`](#num_tags)  |  |
| `struct drgn_dwarf_index_die_vector *` | [`dies`](#dies-1)  |  |
| `uint32_t` | [`index`](#index-3)  |  |

---

{#ns}

### ns

```cpp
struct drgn_namespace_dwarf_index * ns
```

Type: struct [`drgn_namespace_dwarf_index`](drgn_namespace_dwarf_index.md#drgn_namespace_dwarf_index) *

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:2583

---

{#name-14}

### name

```cpp
const char * name
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:2584

---

{#name_len-1}

### name_len

```cpp
size_t name_len
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:2585

---

{#tags}

### tags

```cpp
enum drgn_dwarf_index_tag * tags
```

Type: enum [`drgn_dwarf_index_tag`](drgn_dwarf_index_tag.md#dwarf__info_8h_1ad65bd7851754881c9b9c251fc33b90fc) *

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:2586

---

{#num_tags}

### num_tags

```cpp
size_t num_tags
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:2587

---

{#dies-1}

### dies

```cpp
struct drgn_dwarf_index_die_vector * dies
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:2588

---

{#index-3}

### index

```cpp
uint32_t index
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:2589

