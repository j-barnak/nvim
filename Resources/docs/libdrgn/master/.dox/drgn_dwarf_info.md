{#drgn_dwarf_info}

# drgn_dwarf_info

```cpp
#include <dwarf_info.h>
```

```cpp
struct drgn_dwarf_info
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.h:176

DWARF debugging information for a program/[drgn_debug_info](drgn_debug_info.md#drgn_debug_info).

## Public Attributes

| Return | Name | Description |
|--------|------|-------------|
| struct [`drgn_namespace_dwarf_index`](drgn_namespace_dwarf_index.md#drgn_namespace_dwarf_index) | [`global`](#global)  | Global namespace index. |
| `struct drgn_dwarf_base_type_map` | [`base_types`](#base_types)  | Mapping from name to `DW_TAG_base_type` DIE address with that name. |
| `struct drgn_dwarf_specification_map` | [`specifications`](#specifications)  | Map from the address of a DIE to the address of a top-level DIE with a `DW_AT_specification` or `DW_AT_abstract_origin` attribute that refers to it. |
| `struct drgn_dwarf_index_cu_vector` | [`index_cus`](#index_cus)  | Indexed compilation units. |
| struct [`drgn_dwarf_index_cu_lookup`](drgn_dwarf_index_cu_lookup.md#drgn_dwarf_index_cu_lookup) * | [`index_cu_lookup`](#index_cu_lookup)  | Lookup table for indexed compilation units sorted on buffer address. |
| `struct drgn_dwarf_type_map` | [`types`](#types-2)  | Cache of parsed types. |
| `struct drgn_dwarf_type_map` | [`cant_be_incomplete_array_types`](#cant_be_incomplete_array_types)  | Cache of parsed types which appear to be incomplete array types but can't be. |

---

{#global}

### global

```cpp
struct drgn_namespace_dwarf_index global
```

Type: struct [`drgn_namespace_dwarf_index`](drgn_namespace_dwarf_index.md#drgn_namespace_dwarf_index)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.h:178

Global namespace index.

---

{#base_types}

### base_types

```cpp
struct drgn_dwarf_base_type_map base_types
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.h:186

Mapping from name to `DW_TAG_base_type` DIE address with that name.

Unlike user-defined types and variables, there can only be one base type with a given name in the entire program, so we don't store them in a drgn_dwarf_index_die_map.

---

{#specifications}

### specifications

```cpp
struct drgn_dwarf_specification_map specifications
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.h:192

Map from the address of a DIE to the address of a top-level DIE with a `DW_AT_specification` or `DW_AT_abstract_origin` attribute that refers to it.

---

{#index_cus}

### index_cus

```cpp
struct drgn_dwarf_index_cu_vector index_cus
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.h:194

Indexed compilation units.

---

{#index_cu_lookup}

### index_cu_lookup

```cpp
struct drgn_dwarf_index_cu_lookup * index_cu_lookup
```

Type: struct [`drgn_dwarf_index_cu_lookup`](drgn_dwarf_index_cu_lookup.md#drgn_dwarf_index_cu_lookup) *

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.h:200

Lookup table for indexed compilation units sorted on buffer address.

Size is equal to that of [index_cus](#index_cus).

---

{#types-2}

### types

```cpp
struct drgn_dwarf_type_map types
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.h:208

Cache of parsed types.

The key is the address of the DIE (`Dwarf_Die::addr`). The value is a [drgn_dwarf_type](drgn_dwarf_type.md#drgn_dwarf_type).

---

{#cant_be_incomplete_array_types}

### cant_be_incomplete_array_types

```cpp
struct drgn_dwarf_type_map cant_be_incomplete_array_types
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.h:215

Cache of parsed types which appear to be incomplete array types but can't be.

See drgn_type_from_dwarf_internal().

