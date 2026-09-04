{#drgn_qualified_type}

# drgn_qualified_type

```cpp
#include <drgn.h>
```

```cpp
struct drgn_qualified_type
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:380

Qualified type.

A type with qualifiers.

**See also**: [drgn_qualifiers](drgn_qualifiers.md#drgn_qualifiers)

## Public Attributes

| Return | Name | Description |
|--------|------|-------------|
| struct [`drgn_type`](drgn_type.md#drgn_type) * | [`type`](#type)  | Unqualified type. |
| enum [`drgn_qualifiers`](drgn_qualifiers.md#drgn_qualifiers) | [`qualifiers`](#qualifiers)  | Bitmask of qualifiers on this type. |

---

{#type}

### type

```cpp
struct drgn_type * type
```

Type: struct [`drgn_type`](drgn_type.md#drgn_type) *

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:382

Unqualified type.

---

{#qualifiers}

### qualifiers

```cpp
enum drgn_qualifiers qualifiers
```

Type: enum [`drgn_qualifiers`](drgn_qualifiers.md#drgn_qualifiers)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:384

Bitmask of qualifiers on this type.

