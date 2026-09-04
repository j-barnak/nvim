{#drgn_object-1}

# drgn_object

```cpp
#include <drgn.h>
```

```cpp
struct drgn_object
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:2524

Object in a program.

A [drgn_object](#drgn_object-1) represents a symbol or value in a program. It can be in the memory of the program (a "reference"), a temporary computed value (a "value"), or "absent".

A [drgn_object](#drgn_object-1) must be initialized with [drgn_object_init()](Objects.md#drgn_object_init) before it is used. It can then be set and otherwise changed repeatedly. When the object is no longer needed, it must be deinitialized [drgn_object_deinit()](Objects.md#drgn_object_deinit).

It is more effecient to initialize an object once and reuse it rather than creating a new one repeatedly (e.g., in a loop).

Members of a [drgn_object](#drgn_object-1) should not be modified except through the provided functions.

## Public Attributes

| Return | Name | Description |
|--------|------|-------------|
| struct [`drgn_type`](drgn_type.md#drgn_type) * | [`type`](#type-1)  | Type of this object. |
| `uint64_t` | [`bit_size`](#bit_size)  | Size of this object in bits. |
| enum [`drgn_qualifiers`](drgn_qualifiers.md#drgn_qualifiers) | [`qualifiers`](#qualifiers-1)  | Qualifiers on [drgn_object::type](#type-1). |
| enum [`drgn_object_encoding`](drgn_object_encoding.md#drgn_object_encoding) | [`encoding`](#encoding)  | How this object is encoded. |
| enum [`drgn_object_kind`](drgn_object_kind.md#drgn_object_kind) | [`kind`](#kind)  | Kind of this object. |
| `bool` | [`is_bit_field`](#is_bit_field)  | Whether this object is a bit field. |
| `bool` | [`little_endian`](#little_endian)  | Whether this object is little-endian. |
| `uint8_t` | [`bit_offset`](#bit_offset-1)  | Offset in bits from `address`. |
| union [`drgn_value`](drgn_value.md#drgn_value) | [`value`](#value)  | Value of value object. |
| `uint64_t` | [`address`](#address)  | Address of reference object. |
| enum [`drgn_absence_reason`](drgn_absence_reason.md#drgn_absence_reason) | [`absence_reason`](#absence_reason)  | Reason object is absent. |
| union [`drgn_object`](#drgn_object-1) | [`__attribute__`](#__attribute__-1)  |  |

---

{#type-1}

### type

```cpp
struct drgn_type * type
```

Type: struct [`drgn_type`](drgn_type.md#drgn_type) *

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:2526

Type of this object.

---

{#bit_size}

### bit_size

```cpp
uint64_t bit_size
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:2533

Size of this object in bits.

This is usually the size of [drgn_object::type](#type-1), but it may be smaller if this is a bit field ([drgn_object::is_bit_field](#is_bit_field)).

---

{#qualifiers-1}

### qualifiers

```cpp
enum drgn_qualifiers qualifiers
```

Type: enum [`drgn_qualifiers`](drgn_qualifiers.md#drgn_qualifiers)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:2535

Qualifiers on [drgn_object::type](#type-1).

---

{#encoding}

### encoding

```cpp
enum drgn_object_encoding encoding
```

Type: enum [`drgn_object_encoding`](drgn_object_encoding.md#drgn_object_encoding)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:2537

How this object is encoded.

---

{#kind}

### kind

```cpp
enum drgn_object_kind kind
```

Type: enum [`drgn_object_kind`](drgn_object_kind.md#drgn_object_kind)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:2539

Kind of this object.

---

{#is_bit_field}

### is_bit_field

```cpp
bool is_bit_field
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:2541

Whether this object is a bit field.

---

{#little_endian}

### little_endian

```cpp
bool little_endian
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:2551

Whether this object is little-endian.

Valid only for scalars (i.e., [DRGN_OBJECT_ENCODING_SIGNED](api.md#drgn_object_encoding_signed), [DRGN_OBJECT_ENCODING_UNSIGNED](api.md#drgn_object_encoding_unsigned), [DRGN_OBJECT_ENCODING_SIGNED_BIG](api.md#drgn_object_encoding_signed_big), [DRGN_OBJECT_ENCODING_UNSIGNED_BIG](api.md#drgn_object_encoding_unsigned_big), [DRGN_OBJECT_ENCODING_FLOAT](api.md#drgn_object_encoding_float), or [DRGN_OBJECT_ENCODING_INCOMPLETE_INTEGER](api.md#drgn_object_encoding_incomplete_integer)).

---

{#bit_offset-1}

### bit_offset

```cpp
uint8_t bit_offset
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:2557

Offset in bits from `address`.

Valid only for reference objects.

---

{#value}

### value

```cpp
union drgn_value value
```

Type: union [`drgn_value`](drgn_value.md#drgn_value)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:2560

Value of value object.

---

{#address}

### address

```cpp
uint64_t address
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:2562

Address of reference object.

---

{#absence_reason}

### absence_reason

```cpp
enum drgn_absence_reason absence_reason
```

Type: enum [`drgn_absence_reason`](drgn_absence_reason.md#drgn_absence_reason)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:2564

Reason object is absent.

---

{#__attribute__-1}

### __attribute__

```cpp
union drgn_object __attribute__
```

Type: union [`drgn_object`](#drgn_object-1)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:2565

