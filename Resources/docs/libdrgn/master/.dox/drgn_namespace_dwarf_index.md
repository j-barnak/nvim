{#drgn_namespace_dwarf_index}

# drgn_namespace_dwarf_index

```cpp
#include <dwarf_info.h>
```

```cpp
struct drgn_namespace_dwarf_index
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.h:114

DWARF information for a namespace or nested definitions in a class, struct, or union.

## Public Attributes

| Return | Name | Description |
|--------|------|-------------|
| struct [`drgn_debug_info`](drgn_debug_info.md#drgn_debug_info) * | [`dbinfo`](#dbinfo-1)  | Debugging information cache that owns this index. |
| `const char *` | [`name`](#name-15)  | (Null-terminated) name of this namespace. |
| `size_t` | [`name_len`](#name_len-2)  | Length of [name](#name-15). |
| struct [`drgn_namespace_dwarf_index`](#drgn_namespace_dwarf_index) * | [`parent`](#parent-2)  | Parent namespace, or `NULL` if it is the global namespace. |
| `struct drgn_namespace_table` | [`children`](#children)  | Children namespaces indexed by name. |
| `struct drgn_dwarf_index_die_map` | [`map`](#map)  | Mapping for each [drgn_dwarf_index_tag](drgn_dwarf_index_tag.md#dwarf__info_8h_1ad65bd7851754881c9b9c251fc33b90fc) from name to a list of matching DIE addresses. |
| `size_t` | [`cus_indexed`](#cus_indexed)  | Number of CUs that were indexed the last time that this namespace was indexed. |
| `uint32_t` | [`dies_indexed`](#dies_indexed)  | Number of DIEs for each namespace-like tag in the parent's index that were indexed the last time that this namespace was indexed. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`saved_err`](#saved_err)  | Saved error from a previous index. |

---

{#dbinfo-1}

### dbinfo

```cpp
struct drgn_debug_info * dbinfo
```

Type: struct [`drgn_debug_info`](drgn_debug_info.md#drgn_debug_info) *

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.h:116

Debugging information cache that owns this index.

---

{#name-15}

### name

```cpp
const char * name
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.h:118

(Null-terminated) name of this namespace.

---

{#name_len-2}

### name_len

```cpp
size_t name_len
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.h:120

Length of [name](#name-15).

---

{#parent-2}

### parent

```cpp
struct drgn_namespace_dwarf_index * parent
```

Type: struct [`drgn_namespace_dwarf_index`](#drgn_namespace_dwarf_index) *

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.h:122

Parent namespace, or `NULL` if it is the global namespace.

---

{#children}

### children

```cpp
struct drgn_namespace_table children
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.h:124

Children namespaces indexed by name.

---

{#map}

### map

```cpp
struct drgn_dwarf_index_die_map map[DRGN_DWARF_INDEX_MAP_SIZE]
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.h:142

Mapping for each [drgn_dwarf_index_tag](drgn_dwarf_index_tag.md#dwarf__info_8h_1ad65bd7851754881c9b9c251fc33b90fc) from name to a list of matching DIE addresses.

This has a few quirks:

* `base_type` DIEs are in [drgn_dwarf_info::base_types](drgn_dwarf_info.md#base_types), not here.
* `enumerator` entries store the addresses of the parent `enumeration_type` DIEs instead.
* `namespace` entries also include the addresses of `class_type`, `structure_type`, and `union_type` DIEs that have children and `DW_AT_declaration`. This is because class, struct, and union declaration DIEs can contain nested definitions, so we want to index the children of those declarations, but we don't want to encounter the declarations when looking for the actual type.
* Otherwise, this does not include DIEs with `DW_AT_declaration`.

---

{#cus_indexed}

### cus_indexed

```cpp
size_t cus_indexed
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.h:147

Number of CUs that were indexed the last time that this namespace was indexed.

---

{#dies_indexed}

### dies_indexed

```cpp
uint32_t dies_indexed[DRGN_DWARF_INDEX_NUM_NAMESPACE_TAGS]
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.h:152

Number of DIEs for each namespace-like tag in the parent's index that were indexed the last time that this namespace was indexed.

---

{#saved_err}

### saved_err

```cpp
struct drgn_error * saved_err
```

Type: struct [`drgn_error`](drgn_error.md#drgn_error) *

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.h:154

Saved error from a previous index.

