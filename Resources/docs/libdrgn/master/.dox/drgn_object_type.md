{#drgn_object_type-1}

# drgn_object_type

```cpp
#include <object.h>
```

```cpp
struct drgn_object_type
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/object.h:80

Type-related fields from [drgn_object](drgn_object.md#drgn_object-1).

## Public Attributes

| Return | Name | Description |
|--------|------|-------------|
| struct [`drgn_type`](drgn_type.md#drgn_type) * | [`type`](#type-2)  |  |
| struct [`drgn_type`](drgn_type.md#drgn_type) * | [`underlying_type`](#underlying_type)  |  |
| `uint64_t` | [`bit_size`](#bit_size-1)  |  |
| enum [`drgn_qualifiers`](drgn_qualifiers.md#drgn_qualifiers) | [`qualifiers`](#qualifiers-2)  |  |
| enum [`drgn_object_encoding`](drgn_object_encoding.md#drgn_object_encoding) | [`encoding`](#encoding-1)  |  |
| `bool` | [`is_bit_field`](#is_bit_field-1)  |  |
| `bool` | [`little_endian`](#little_endian-1)  |  |

---

{#type-2}

### type

```cpp
struct drgn_type * type
```

Type: struct [`drgn_type`](drgn_type.md#drgn_type) *

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/object.h:81

---

{#underlying_type}

### underlying_type

```cpp
struct drgn_type * underlying_type
```

Type: struct [`drgn_type`](drgn_type.md#drgn_type) *

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/object.h:83

---

{#bit_size-1}

### bit_size

```cpp
uint64_t bit_size
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/object.h:84

---

{#qualifiers-2}

### qualifiers

```cpp
enum drgn_qualifiers qualifiers
```

Type: enum [`drgn_qualifiers`](drgn_qualifiers.md#drgn_qualifiers)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/object.h:85

---

{#encoding-1}

### encoding

```cpp
enum drgn_object_encoding encoding
```

Type: enum [`drgn_object_encoding`](drgn_object_encoding.md#drgn_object_encoding)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/object.h:86

---

{#is_bit_field-1}

### is_bit_field

```cpp
bool is_bit_field
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/object.h:87

---

{#little_endian-1}

### little_endian

```cpp
bool little_endian
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/object.h:88

