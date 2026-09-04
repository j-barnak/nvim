{#helpers}

# Helpers

> [`Objects`](Objects.md#objects)

Object helpers.

Several helpers are provided for working with [drgn_object](drgn_object.md#drgn_object-1)s.

Helpers which return a [drgn_object](drgn_object.md#drgn_object-1) have the same calling convention: the result object is the first argument, which must be initialized and may be the same as the input object argument; the result is only modified if the helper succeeds.

## Classes

| Name | Description |
|------|-------------|
| [`drgn_format_object_options`](drgn_format_object_options.md#drgn_format_object_options) | Formatting options for [drgn_format_object()](#drgn_format_object). |

## Enumerations

| Name | Description |
|------|-------------|
| [`drgn_format_object_flags`](#drgn_format_object_flags)  | Flags to control [drgn_format_object()](#drgn_format_object) output. |

---

{#drgn_format_object_flags}

### drgn_format_object_flags

```cpp
enum drgn_format_object_flags
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:3017

Flags to control [drgn_format_object()](#drgn_format_object) output.

| Value | Description |
|-------|-------------|
| `DRGN_FORMAT_OBJECT_DEREFERENCE` |  |
| `DRGN_FORMAT_OBJECT_SYMBOLIZE` |  |
| `DRGN_FORMAT_OBJECT_STRING` |  |
| `DRGN_FORMAT_OBJECT_CHAR` |  |
| `DRGN_FORMAT_OBJECT_TYPE_NAME` |  |
| `DRGN_FORMAT_OBJECT_MEMBER_TYPE_NAMES` |  |
| `DRGN_FORMAT_OBJECT_ELEMENT_TYPE_NAMES` |  |
| `DRGN_FORMAT_OBJECT_MEMBERS_SAME_LINE` |  |
| `DRGN_FORMAT_OBJECT_ELEMENTS_SAME_LINE` |  |
| `DRGN_FORMAT_OBJECT_MEMBER_NAMES` |  |
| `DRGN_FORMAT_OBJECT_ELEMENT_INDICES` |  |
| `DRGN_FORMAT_OBJECT_IMPLICIT_MEMBERS` |  |
| `DRGN_FORMAT_OBJECT_IMPLICIT_ELEMENTS` |  |
| `DRGN_FORMAT_OBJECT_PRETTY` | Default "pretty" flags. |
| `DRGN_FORMAT_OBJECT_VALID_FLAGS` |  |
## Functions

| Return | Name | Description |
|--------|------|-------------|
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_object_copy`](#drgn_object_copy)  | Set a [drgn_object](drgn_object.md#drgn_object-1) to another object. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_object_fragment`](#drgn_object_fragment)  | Get a [drgn_object](drgn_object.md#drgn_object-1) from a "fragment" of an object. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_object_dereference_offset`](#drgn_object_dereference_offset)  | Get a [drgn_object](drgn_object.md#drgn_object-1) from dereferencing a pointer object with an offset. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_object_read`](#drgn_object_read)  | Read a [drgn_object](drgn_object.md#drgn_object-1). |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_object_read_value`](#drgn_object_read_value)  | Read the value of a [drgn_object](drgn_object.md#drgn_object-1). |
| `void` | [`drgn_object_deinit_value`](#drgn_object_deinit_value)  | Deinitialize a value which was read with [drgn_object_read_value()](#drgn_object_read_value). |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_object_read_bytes`](#drgn_object_read_bytes)  | Get the binary representation of the value of a [drgn_object](drgn_object.md#drgn_object-1). |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_object_read_signed`](#drgn_object_read_signed)  | Get the value of an object encoded with drgn_object_encoding::DRGN_OBJECT_ENCODING_SIGNED. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_object_read_unsigned`](#drgn_object_read_unsigned)  | Get the value of an object encoded with drgn_object_encoding::DRGN_OBJECT_ENCODING_UNSIGNED. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_object_read_integer`](#drgn_object_read_integer)  | Get the value of an object encoded with drgn_object_encoding::DRGN_OBJECT_ENCODING_SIGNED or drgn_object_encoding::DRGN_OBJECT_ENCODING_UNSIGNED. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_object_read_float`](#drgn_object_read_float)  | Get the value of an object encoded with drgn_object_encoding::DRGN_OBJECT_ENCODING_FLOAT. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_object_read_c_string`](#drgn_object_read_c_string)  | Read the null-terminated string pointed to by a [drgn_object](drgn_object.md#drgn_object-1). |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_format_object`](#drgn_format_object)  | Format a [drgn_object](drgn_object.md#drgn_object-1) as a string. |

---

{#drgn_object_copy}

### drgn_object_copy

```cpp
struct drgn_error * drgn_object_copy(struct drgn_object * res, const struct drgn_object * obj)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:2833

Set a [drgn_object](drgn_object.md#drgn_object-1) to another object.

This copies `obj` to `res`. If `obj` is a value, then `res` is set to a value with the same type and value, and similarly if `obj` was a reference, `res` is set to the same reference.

#### Returns
`NULL` on success, non-`NULL` on error.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `res` | struct [`drgn_object`](drgn_object.md#drgn_object-1) * | Destination object. |
| `obj` | const struct [`drgn_object`](drgn_object.md#drgn_object-1) * | Source object. |

---

{#drgn_object_fragment}

### drgn_object_fragment

```cpp
struct drgn_error * drgn_object_fragment(struct drgn_object * res, const struct drgn_object * obj, struct drgn_qualified_type qualified_type, int64_t bit_offset, uint64_t bit_field_size)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:2862

Get a [drgn_object](drgn_object.md#drgn_object-1) from a "fragment" of an object.

This is a low-level interface used to implement [drgn_object_subscript()](ObjectOperators.md#drgn_object_subscript), [drgn_object_member()](ObjectOperators.md#drgn_object_member), and [drgn_object_reinterpret()](ObjectOperators.md#drgn_object_reinterpret). Those functions are usually more convenient.

If multiple elements of an array are accessed (e.g., when iterating through it), it can be more efficient to call [drgn_type_element_info()](Types.md#drgn_type_element_info) once to get the required information and this function with the computed bit offset for each element.

If the same member of a type is accessed repeatedly (e.g., in a loop), it can be more efficient to call drgn_type_find_member() once to get the required information and this function to access the member each time.

**See also**: [drgn_object_dereference_offset](#drgn_object_dereference_offset)

#### Returns
`NULL` on success, non-`NULL` on error.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `res` | struct [`drgn_object`](drgn_object.md#drgn_object-1) * | Destination object. |
| `obj` | const struct [`drgn_object`](drgn_object.md#drgn_object-1) * | Source object. |
| `qualified_type` | struct [`drgn_qualified_type`](drgn_qualified_type.md#drgn_qualified_type) | Result type. |
| `bit_offset` | `int64_t` | Offset in bits from the beginning of `obj`. |
| `bit_field_size` | `uint64_t` | If the object should be a bit field, its size in bits. Otherwise, 0. |

---

{#drgn_object_dereference_offset}

### drgn_object_dereference_offset

```cpp
struct drgn_error * drgn_object_dereference_offset(struct drgn_object * res, const struct drgn_object * obj, struct drgn_qualified_type qualified_type, int64_t bit_offset, uint64_t bit_field_size)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:2888

Get a [drgn_object](drgn_object.md#drgn_object-1) from dereferencing a pointer object with an offset.

This is a low-level interface used to implement [drgn_object_subscript()](ObjectOperators.md#drgn_object_subscript) and [drgn_object_member_dereference()](ObjectOperators.md#drgn_object_member_dereference). Those functions are usually more convenient, but this function can be more efficient if accessing multiple elements or the same member multiple times.

**See also**: [drgn_object_fragment](#drgn_object_fragment)

#### Returns
`NULL` on success, non-`NULL` on error.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `res` | struct [`drgn_object`](drgn_object.md#drgn_object-1) * | Dereferenced object. |
| `obj` | const struct [`drgn_object`](drgn_object.md#drgn_object-1) * | Pointer object. |
| `qualified_type` | struct [`drgn_qualified_type`](drgn_qualified_type.md#drgn_qualified_type) | Result type. |
| `bit_offset` | `int64_t` | Offset in bits from the address given by the value of `obj`. |
| `bit_field_size` | `uint64_t` | If the object should be a bit field, its size in bits. Otherwise, 0. |

---

{#drgn_object_read}

### drgn_object_read

```cpp
struct drgn_error * drgn_object_read(struct drgn_object * res, const struct drgn_object * obj)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:2904

Read a [drgn_object](drgn_object.md#drgn_object-1).

If `obj` is already a value, then this is equivalent to [drgn_object_copy()](#drgn_object_copy). If `is` a reference, then this reads the reference and sets `res` to the value.

#### Returns
`NULL` on success, non-`NULL` on error.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `res` | struct [`drgn_object`](drgn_object.md#drgn_object-1) * | Object to set. |
| `obj` | const struct [`drgn_object`](drgn_object.md#drgn_object-1) * | Object to read. |

---

{#drgn_object_read_value}

### drgn_object_read_value

```cpp
struct drgn_error * drgn_object_read_value(const struct drgn_object * obj, union drgn_value * value, const union drgn_value ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:2921

Read the value of a [drgn_object](drgn_object.md#drgn_object-1).

If `obj` is a value, that value is returned directly. If `is` a reference, the value is read into the provided temporary buffer.

This must be paired with [drgn_object_deinit_value()](#drgn_object_deinit_value).

#### Returns
`NULL` on success, non-`NULL` on error.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `obj` | const struct [`drgn_object`](drgn_object.md#drgn_object-1) * | Object to read. |
| `value` | union [`drgn_value`](drgn_value.md#drgn_value) * | Temporary value to use if necessary. |
| `ret` | const union [`drgn_value`](drgn_value.md#drgn_value) ** | Pointer to the returned value, which is `&obj->value` if `obj` is a value, or `value` if `obj` is a reference. |

---

{#drgn_object_deinit_value}

### drgn_object_deinit_value

```cpp
void drgn_object_deinit_value(const struct drgn_object * obj, const union drgn_value * value)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:2931

Deinitialize a value which was read with [drgn_object_read_value()](#drgn_object_read_value).

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `obj` | const struct [`drgn_object`](drgn_object.md#drgn_object-1) * | Object which was read. |
| `value` | const union [`drgn_value`](drgn_value.md#drgn_value) * | Value returned from [drgn_object_read_value()](#drgn_object_read_value) in `ret`. |

---

{#drgn_object_read_bytes}

### drgn_object_read_bytes

```cpp
struct drgn_error * drgn_object_read_bytes(const struct drgn_object * obj, void * buf)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:2940

Get the binary representation of the value of a [drgn_object](drgn_object.md#drgn_object-1).

---

{#drgn_object_read_signed}

### drgn_object_read_signed

```cpp
struct drgn_error * drgn_object_read_signed(const struct drgn_object * obj, int64_t * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:2953

Get the value of an object encoded with drgn_object_encoding::DRGN_OBJECT_ENCODING_SIGNED.

If the object is not a signed integer, an error is returned.

#### Returns
`NULL` on success, non-`NULL` on error.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `obj` | const struct [`drgn_object`](drgn_object.md#drgn_object-1) * | Object to read. |
| `ret` | `int64_t *` | Returned value. |

---

{#drgn_object_read_unsigned}

### drgn_object_read_unsigned

```cpp
struct drgn_error * drgn_object_read_unsigned(const struct drgn_object * obj, uint64_t * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:2966

Get the value of an object encoded with drgn_object_encoding::DRGN_OBJECT_ENCODING_UNSIGNED.

If the object is not an unsigned integer, an error is returned.

#### Returns
`NULL` on success, non-`NULL` on error.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `obj` | const struct [`drgn_object`](drgn_object.md#drgn_object-1) * | Object to read. |
| `ret` | `uint64_t *` | Returned value. |

---

{#drgn_object_read_integer}

### drgn_object_read_integer

```cpp
struct drgn_error * drgn_object_read_integer(const struct drgn_object * obj, union drgn_value * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:2980

Get the value of an object encoded with drgn_object_encoding::DRGN_OBJECT_ENCODING_SIGNED or drgn_object_encoding::DRGN_OBJECT_ENCODING_UNSIGNED.

If the object is not an integer, an error is returned.

#### Returns
`NULL` on success, non-`NULL` on error.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `obj` | const struct [`drgn_object`](drgn_object.md#drgn_object-1) * | Object to read. |
| `ret` | union [`drgn_value`](drgn_value.md#drgn_value) * | Returned value. |

---

{#drgn_object_read_float}

### drgn_object_read_float

```cpp
struct drgn_error * drgn_object_read_float(const struct drgn_object * obj, double * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:2993

Get the value of an object encoded with drgn_object_encoding::DRGN_OBJECT_ENCODING_FLOAT.

If the object does not have a floating-point type, an error is returned.

#### Returns
`NULL` on success, non-`NULL` on error.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `obj` | const struct [`drgn_object`](drgn_object.md#drgn_object-1) * | Object to read. |
| `ret` | `double *` | Returned value. |

---

{#drgn_object_read_c_string}

### drgn_object_read_c_string

```cpp
struct drgn_error * drgn_object_read_c_string(const struct drgn_object * obj, char ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:3013

Read the null-terminated string pointed to by a [drgn_object](drgn_object.md#drgn_object-1).

This is only valid for pointers and arrays. The element type is ignored; this operates byte-by-byte.

For pointers and flexible arrays, this stops at the first null byte.

For complete arrays, this stops at the first null byte or at the end of the array.

The returned string is always null-terminated.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `obj` | const struct [`drgn_object`](drgn_object.md#drgn_object-1) * | Object to read. |
| `ret` | `char **` | Returned string. On success, it must be freed with `free()`. On error, it is not modified. |

---

{#drgn_format_object}

### drgn_format_object

```cpp
struct drgn_error * drgn_format_object(const struct drgn_object * obj, const struct drgn_format_object_options * options, char ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:3072

Format a [drgn_object](drgn_object.md#drgn_object-1) as a string.

This will format the object similarly to an expression in its programming language.

#### Returns
`NULL` on success, non-`NULL` on error.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `obj` | const struct [`drgn_object`](drgn_object.md#drgn_object-1) * | Object to format. |
| `options` | const struct [`drgn_format_object_options`](drgn_format_object_options.md#drgn_format_object_options) * | Formatting options, or `NULL` to use the default options. |
| `ret` | `char **` | Returned string. On success, it must be freed with `free()`. On error, it is not modified. |

