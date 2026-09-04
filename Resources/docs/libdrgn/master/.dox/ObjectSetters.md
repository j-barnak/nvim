{#setters}

# Setters

> [`Objects`](Objects.md#objects)

Object setters.

Once a [drgn_object](drgn_object.md#drgn_object-1) is initialized with [drgn_object_init()](Objects.md#drgn_object_init), it may be set any number of times.

## Functions

| Return | Name | Description |
|--------|------|-------------|
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_object_set_signed`](#drgn_object_set_signed)  | Set a [drgn_object](drgn_object.md#drgn_object-1) to a signed value. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_object_set_unsigned`](#drgn_object_set_unsigned)  | Set a [drgn_object](drgn_object.md#drgn_object-1) to an unsigned value. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_object_set_float`](#drgn_object_set_float)  | Set a [drgn_object](drgn_object.md#drgn_object-1) to a floating-point value. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_object_set_from_buffer`](#drgn_object_set_from_buffer)  | Set a [drgn_object](drgn_object.md#drgn_object-1) from a buffer. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_object_set_reference`](#drgn_object_set_reference)  | Set a [drgn_object](drgn_object.md#drgn_object-1) to a reference. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_object_set_absent`](#drgn_object_set_absent)  | Set a [drgn_object](drgn_object.md#drgn_object-1) as absent. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_object_integer_literal`](#drgn_object_integer_literal)  | Set a [drgn_object](drgn_object.md#drgn_object-1) to a integer literal. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_object_bool_literal`](#drgn_object_bool_literal)  | Set a [drgn_object](drgn_object.md#drgn_object-1) to a boolean literal. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_object_float_literal`](#drgn_object_float_literal)  | Set a [drgn_object](drgn_object.md#drgn_object-1) to a floating-point literal. |

---

{#drgn_object_set_signed}

### drgn_object_set_signed

```cpp
struct drgn_error * drgn_object_set_signed(struct drgn_object * res, struct drgn_qualified_type qualified_type, int64_t svalue, uint64_t bit_field_size)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:2678

Set a [drgn_object](drgn_object.md#drgn_object-1) to a signed value.

#### Returns
`NULL` on success, non-`NULL` on error.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `res` | struct [`drgn_object`](drgn_object.md#drgn_object-1) * | Object to set. |
| `qualified_type` | struct [`drgn_qualified_type`](drgn_qualified_type.md#drgn_qualified_type) | Type to set to. |
| `svalue` | `int64_t` | Value to set to. |
| `bit_field_size` | `uint64_t` | If the object should be a bit field, its size in bits. Otherwise, 0. |

---

{#drgn_object_set_unsigned}

### drgn_object_set_unsigned

```cpp
struct drgn_error * drgn_object_set_unsigned(struct drgn_object * res, struct drgn_qualified_type qualified_type, uint64_t uvalue, uint64_t bit_field_size)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:2693

Set a [drgn_object](drgn_object.md#drgn_object-1) to an unsigned value.

#### Returns
`NULL` on success, non-`NULL` on error.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `res` | struct [`drgn_object`](drgn_object.md#drgn_object-1) * | Object to set. |
| `qualified_type` | struct [`drgn_qualified_type`](drgn_qualified_type.md#drgn_qualified_type) | Type to set to. |
| `uvalue` | `uint64_t` | Value to set to. |
| `bit_field_size` | `uint64_t` | If the object should be a bit field, its size in bits. Otherwise, 0. |

---

{#drgn_object_set_float}

### drgn_object_set_float

```cpp
struct drgn_error * drgn_object_set_float(struct drgn_object * res, struct drgn_qualified_type qualified_type, double fvalue)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:2706

Set a [drgn_object](drgn_object.md#drgn_object-1) to a floating-point value.

#### Returns
`NULL` on success, non-`NULL` on error.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `res` | struct [`drgn_object`](drgn_object.md#drgn_object-1) * | Object to set. |
| `qualified_type` | struct [`drgn_qualified_type`](drgn_qualified_type.md#drgn_qualified_type) | Type to set to. |
| `fvalue` | `double` | Value to set to. |

---

{#drgn_object_set_from_buffer}

### drgn_object_set_from_buffer

```cpp
struct drgn_error * drgn_object_set_from_buffer(struct drgn_object * res, struct drgn_qualified_type qualified_type, const void * buf, size_t buf_size, uint64_t bit_offset, uint64_t bit_field_size)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:2727

Set a [drgn_object](drgn_object.md#drgn_object-1) from a buffer.

#### Returns
`NULL` on success, non-`NULL` on error.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `res` | struct [`drgn_object`](drgn_object.md#drgn_object-1) * | Object to set. |
| `qualified_type` | struct [`drgn_qualified_type`](drgn_qualified_type.md#drgn_qualified_type) | Type to set to. |
| `buf` | `const void *` | Buffer to set to. It is copied, so it need not remain valid after this function returns. |
| `buf_size` | `size_t` | Size of `buf`, in bytes. `buf_size * 8` must be at least `bit_size + bit_offset`, where `bit_size` is `bit_field_size` if non-zero and the size of `qualified_type` in bits otherwise. |
| `bit_offset` | `uint64_t` | Offset of the value from the beginning of the buffer, in bits. This is usually 0. It must be aligned to a byte unless the type is scalar. |
| `bit_field_size` | `uint64_t` | If the object should be a bit field, its size in bits. Otherwise, 0. |

---

{#drgn_object_set_reference}

### drgn_object_set_reference

```cpp
struct drgn_error * drgn_object_set_reference(struct drgn_object * res, struct drgn_qualified_type qualified_type, uint64_t address, uint64_t bit_offset, uint64_t bit_field_size)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:2745

Set a [drgn_object](drgn_object.md#drgn_object-1) to a reference.

#### Returns
`NULL` on success, non-`NULL` on error.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `res` | struct [`drgn_object`](drgn_object.md#drgn_object-1) * | Object to set. |
| `qualified_type` | struct [`drgn_qualified_type`](drgn_qualified_type.md#drgn_qualified_type) | Type to set to. |
| `address` | `uint64_t` | Address of the object. |
| `bit_offset` | `uint64_t` | Offset of the value from `address`, in bits. This is usually 0. |
| `bit_field_size` | `uint64_t` | If the object should be a bit field, its size in bits. Otherwise, 0. |

---

{#drgn_object_set_absent}

### drgn_object_set_absent

```cpp
struct drgn_error * drgn_object_set_absent(struct drgn_object * res, struct drgn_qualified_type qualified_type, enum drgn_absence_reason reason, uint64_t bit_field_size)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:2761

Set a [drgn_object](drgn_object.md#drgn_object-1) as absent.

#### Returns
`NULL` on success, non-`NULL` on error.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `res` | struct [`drgn_object`](drgn_object.md#drgn_object-1) * | Object to set. |
| `qualified_type` | struct [`drgn_qualified_type`](drgn_qualified_type.md#drgn_qualified_type) | Type to set to. |
| `reason` | enum [`drgn_absence_reason`](drgn_absence_reason.md#drgn_absence_reason) | Reason object is absent. |
| `bit_field_size` | `uint64_t` | If the object should be a bit field, its size in bits. Otherwise, 0. |

---

{#drgn_object_integer_literal}

### drgn_object_integer_literal

```cpp
struct drgn_error * drgn_object_integer_literal(struct drgn_object * res, uint64_t uvalue)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:2776

Set a [drgn_object](drgn_object.md#drgn_object-1) to a integer literal.

This determines the type based on the programming language of the program that the object belongs to.

#### Returns
`NULL` on success, non-`NULL` on error.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `res` | struct [`drgn_object`](drgn_object.md#drgn_object-1) * | Object to set. |
| `uvalue` | `uint64_t` | Integer value. |

---

{#drgn_object_bool_literal}

### drgn_object_bool_literal

```cpp
struct drgn_error * drgn_object_bool_literal(struct drgn_object * res, bool bvalue)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:2789

Set a [drgn_object](drgn_object.md#drgn_object-1) to a boolean literal.

This determines the type based on the programming language of the program that the object belongs to.

#### Returns
`NULL` on success, non-`NULL` on error.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `res` | struct [`drgn_object`](drgn_object.md#drgn_object-1) * | Object to set. |
| `bvalue` | `bool` | Boolean value. |

---

{#drgn_object_float_literal}

### drgn_object_float_literal

```cpp
struct drgn_error * drgn_object_float_literal(struct drgn_object * res, double fvalue)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:2802

Set a [drgn_object](drgn_object.md#drgn_object-1) to a floating-point literal.

This determines the type based on the programming language of the program that the object belongs to.

#### Returns
`NULL` on success, non-`NULL` on error.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `res` | struct [`drgn_object`](drgn_object.md#drgn_object-1) * | Object to set. |
| `fvalue` | `double` | Floating-point value. |

