{#drgn_operand_type}

# drgn_operand_type

```cpp
#include <object.h>
```

```cpp
struct drgn_operand_type
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/object.h:107

Type of an operand or operator result.

This is basically [drgn_qualified_type](drgn_qualified_type.md#drgn_qualified_type) plus a bit field size and cached underlying type.

## Public Attributes

| Return | Name | Description |
|--------|------|-------------|
| struct [`drgn_type`](drgn_type.md#drgn_type) * | [`type`](#type-3)  |  |
| enum [`drgn_qualifiers`](drgn_qualifiers.md#drgn_qualifiers) | [`qualifiers`](#qualifiers-3)  |  |
| struct [`drgn_type`](drgn_type.md#drgn_type) * | [`underlying_type`](#underlying_type-1)  |  |
| `uint64_t` | [`bit_field_size`](#bit_field_size)  |  |

---

{#type-3}

### type

```cpp
struct drgn_type * type
```

Type: struct [`drgn_type`](drgn_type.md#drgn_type) *

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/object.h:108

---

{#qualifiers-3}

### qualifiers

```cpp
enum drgn_qualifiers qualifiers
```

Type: enum [`drgn_qualifiers`](drgn_qualifiers.md#drgn_qualifiers)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/object.h:109

---

{#underlying_type-1}

### underlying_type

```cpp
struct drgn_type * underlying_type
```

Type: struct [`drgn_type`](drgn_type.md#drgn_type) *

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/object.h:110

---

{#bit_field_size}

### bit_field_size

```cpp
uint64_t bit_field_size
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/object.h:111

