{#drgn_value}

# drgn_value

```cpp
#include <drgn.h>
```

```cpp
union drgn_value
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:2447

Value of a [drgn_object](drgn_object.md#drgn_object-1).

## Public Attributes

| Return | Name | Description |
|--------|------|-------------|
| `char *` | [`bufp`](#bufp)  | Pointer to an external buffer for a [DRGN_OBJECT_ENCODING_BUFFER](api.md#drgn_object_encoding_buffer), [DRGN_OBJECT_ENCODING_SIGNED_BIG](api.md#drgn_object_encoding_signed_big), or [DRGN_OBJECT_ENCODING_UNSIGNED_BIG](api.md#drgn_object_encoding_unsigned_big) value. |
| `char` | [`ibuf`](#ibuf)  | Inline buffer for a [DRGN_OBJECT_ENCODING_BUFFER](api.md#drgn_object_encoding_buffer) value. |
| `int64_t` | [`svalue`](#svalue-1)  | [DRGN_OBJECT_ENCODING_SIGNED](api.md#drgn_object_encoding_signed) value. |
| `uint64_t` | [`uvalue`](#uvalue-1)  | [DRGN_OBJECT_ENCODING_UNSIGNED](api.md#drgn_object_encoding_unsigned) value. |
| `double` | [`fvalue`](#fvalue)  | [DRGN_OBJECT_ENCODING_FLOAT](api.md#drgn_object_encoding_float) value. |

---

{#bufp}

### bufp

```cpp
char * bufp
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:2460

Pointer to an external buffer for a [DRGN_OBJECT_ENCODING_BUFFER](api.md#drgn_object_encoding_buffer), [DRGN_OBJECT_ENCODING_SIGNED_BIG](api.md#drgn_object_encoding_signed_big), or [DRGN_OBJECT_ENCODING_UNSIGNED_BIG](api.md#drgn_object_encoding_unsigned_big) value.

For [DRGN_OBJECT_ENCODING_BUFFER](api.md#drgn_object_encoding_buffer), this contains the object's representation in the memory of the program.

For [DRGN_OBJECT_ENCODING_SIGNED_BIG](api.md#drgn_object_encoding_signed_big) and [DRGN_OBJECT_ENCODING_UNSIGNED_BIG](api.md#drgn_object_encoding_unsigned_big), the representation of the value is an implementation detail which may change.

---

{#ibuf}

### ibuf

```cpp
char ibuf[8]
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:2467

Inline buffer for a [DRGN_OBJECT_ENCODING_BUFFER](api.md#drgn_object_encoding_buffer) value.

Tiny buffers (see drgn_value_is_inline()) are stored inline here instead of in a separate allocation.

---

{#svalue-1}

### svalue

```cpp
int64_t svalue
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:2469

[DRGN_OBJECT_ENCODING_SIGNED](api.md#drgn_object_encoding_signed) value.

---

{#uvalue-1}

### uvalue

```cpp
uint64_t uvalue
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:2471

[DRGN_OBJECT_ENCODING_UNSIGNED](api.md#drgn_object_encoding_unsigned) value.

---

{#fvalue}

### fvalue

```cpp
double fvalue
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:2473

[DRGN_OBJECT_ENCODING_FLOAT](api.md#drgn_object_encoding_float) value.

