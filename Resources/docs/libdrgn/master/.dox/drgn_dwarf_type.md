{#drgn_dwarf_type}

# drgn_dwarf_type

```cpp
#include <dwarf_info.h>
```

```cpp
struct drgn_dwarf_type
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.h:158

Cached type in a [drgn_debug_info](drgn_debug_info.md#drgn_debug_info).

## Public Attributes

| Return | Name | Description |
|--------|------|-------------|
| struct [`drgn_type`](drgn_type.md#drgn_type) * | [`type`](#type-7)  |  |
| enum [`drgn_qualifiers`](drgn_qualifiers.md#drgn_qualifiers) | [`qualifiers`](#qualifiers-6)  |  |
| `bool` | [`is_incomplete_array`](#is_incomplete_array)  | Whether this is an incomplete array type or a typedef of one. |

---

{#type-7}

### type

```cpp
struct drgn_type * type
```

Type: struct [`drgn_type`](drgn_type.md#drgn_type) *

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.h:159

---

{#qualifiers-6}

### qualifiers

```cpp
enum drgn_qualifiers qualifiers
```

Type: enum [`drgn_qualifiers`](drgn_qualifiers.md#drgn_qualifiers)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.h:160

---

{#is_incomplete_array}

### is_incomplete_array

```cpp
bool is_incomplete_array
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.h:167

Whether this is an incomplete array type or a typedef of one.

This is used to work around a GCC bug; see drgn_type_from_dwarf_internal().

