{#drgn_type_member}

# drgn_type_member

```cpp
#include <drgn.h>
```

```cpp
struct drgn_type_member
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:3474

Member of a structure, union, or class type.

## Public Attributes

| Return | Name | Description |
|--------|------|-------------|
| union [`drgn_lazy_object`](drgn_lazy_object.md#drgn_lazy_object) | [`object`](#object)  | Member as an object. |
| `const char *` | [`name`](#name)  | Member name or `NULL` if it is unnamed. |
| `uint64_t` | [`bit_offset`](#bit_offset)  | Offset in bits from the beginning of the type to the beginning of this member (i.e., for little-endian machines, the least significant bit, and for big-endian machines, the most significant bit). Members are usually aligned to at least a byte, so this is usually a multiple of 8 (but that may not be the case for bit fields). |

---

{#object}

### object

```cpp
union drgn_lazy_object object
```

Type: union [`drgn_lazy_object`](drgn_lazy_object.md#drgn_lazy_object)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:3481

Member as an object.

Access this with [drgn_member_object()](Types.md#drgn_member_object) or [drgn_member_type()](Types.md#drgn_member_type).

---

{#name}

### name

```cpp
const char * name
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:3483

Member name or `NULL` if it is unnamed.

---

{#bit_offset}

### bit_offset

```cpp
uint64_t bit_offset
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:3491

Offset in bits from the beginning of the type to the beginning of this member (i.e., for little-endian machines, the least significant bit, and for big-endian machines, the most significant bit). Members are usually aligned to at least a byte, so this is usually a multiple of 8 (but that may not be the case for bit fields).

