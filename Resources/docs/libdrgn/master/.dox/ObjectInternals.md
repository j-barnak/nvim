{#objects-1}

# Objects

> [`Internals`](Internals.md#internals)

Object internals.

This provides the language-agnostic part of operator implementations. The operators have defined behavior for various cases where C is undefined or implementation-defined (e.g., signed arithmetic is modular, signed bitwise operators operate on the two's complement representation, right shifts are arithmetic).

## Classes

| Name | Description |
|------|-------------|
| [`drgn_object_finder`](drgn_object_finder.md#drgn_object_finder) |  |
| [`drgn_object_type`](drgn_object_type.md#drgn_object_type-1) | Type-related fields from [drgn_object](drgn_object.md#drgn_object-1). |
| [`drgn_operand_type`](drgn_operand_type.md#drgn_operand_type) | Type of an operand or operator result. |

## Typedefs

| Return | Name | Description |
|--------|------|-------------|
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_binary_op_impl`](#drgn_binary_op_impl)  | Binary operator implementation. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_shift_op_impl`](#drgn_shift_op_impl)  | Shift operator implementation. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_unary_op_impl`](#drgn_unary_op_impl)  | Unary operator implementation. |

---

{#drgn_binary_op_impl}

### drgn_binary_op_impl

```cpp
using drgn_binary_op_impl = struct drgn_error *
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/object.h:240

Binary operator implementation.

Operator implementations with this type convert `lhs` and `rhs` to `op_type`, apply the operator, and store the result in `res`.

#### Returns
`NULL` on success, non-`NULL` on error. `res` is not modified on error.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `res` |  | Operator result. May be the same as `lhs` and/or `rhs`. |
| `op_type` |  | Result type. |
| `lhs` |  | Operator left hand side. |
| `rhs` |  | Operator right hand side. |

---

{#drgn_shift_op_impl}

### drgn_shift_op_impl

```cpp
using drgn_shift_op_impl = struct drgn_error *
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/object.h:259

Shift operator implementation.

Operator implementations with this type convert `lhs` to `lhs_type` and `rhs` to `rhs_type` and store the result in `res`.

#### Returns
`NULL` on success, non-`NULL` on error. `res` is not modified on error.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `res` |  | Operator result. May be the same as `lhs` and/or `rhs`. |
| `lhs` |  | Operator left hand side. |
| `lhs_type` |  | Type of left hand side and result. |
| `rhs` |  | Operator right hand side. |
| `rhs_type` |  | Type of right hand side. |

---

{#drgn_unary_op_impl}

### drgn_unary_op_impl

```cpp
using drgn_unary_op_impl = struct drgn_error *
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/object.h:278

Unary operator implementation.

Operator implementations with this type convert `obj` to `op_type` and store the result in `res`.

#### Returns
`NULL` on success, non-`NULL` on error. `res` is not modified on error.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `res` |  | Operator result. May be the same as `obj`. |
| `op_type` |  | Result type. |
| `obj` |  | Operand. |

## Functions

| Return | Name | Description |
|--------|------|-------------|
| `bool` | [`drgn_value_zalloc`](#drgn_value_zalloc) `static` `inline` | Allocate a zero-initialized [drgn_value](drgn_value.md#drgn_value). |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_object_is_zero`](#drgn_object_is_zero)  | Get whether an object is zero. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_object_is_zero_or_incomplete`](#drgn_object_is_zero_or_incomplete)  | Like [drgn_object_is_zero()](#drgn_object_is_zero), but also returns true for incomplete objects. |
| struct [`drgn_qualified_type`](drgn_qualified_type.md#drgn_qualified_type) | [`drgn_object_type_qualified`](#drgn_object_type_qualified) `static` `inline` | Convert a [drgn_object_type](drgn_object_type.md#drgn_object_type-1) to a [drgn_qualified_type](drgn_qualified_type.md#drgn_qualified_type). |
| struct [`drgn_qualified_type`](drgn_qualified_type.md#drgn_qualified_type) | [`drgn_operand_type_qualified`](#drgn_operand_type_qualified) `static` `inline` | Convert a [drgn_operand_type](drgn_operand_type.md#drgn_operand_type) to a [drgn_qualified_type](drgn_qualified_type.md#drgn_qualified_type). |
| struct [`drgn_operand_type`](drgn_operand_type.md#drgn_operand_type) | [`drgn_object_operand_type`](#drgn_object_operand_type) `static` `inline` | Get the [drgn_operand_type](drgn_operand_type.md#drgn_operand_type) of a [drgn_object](drgn_object.md#drgn_object-1). |
| `void` | [`drgn_object_reinit`](#drgn_object_reinit) `static` `inline` | Deinitialize the value of a [drgn_object](drgn_object.md#drgn_object-1) and reinitialize the kind and type fields. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_object_type`](#drgn_object_type)  | Compute the type-related fields of a [drgn_object](drgn_object.md#drgn_object-1) from a [drgn_qualified_type](drgn_qualified_type.md#drgn_qualified_type) and a bit field size. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_object_set_signed_internal`](#drgn_object_set_signed_internal)  | Like [drgn_object_set_signed()](ObjectSetters.md#drgn_object_set_signed) but [drgn_object_type()](#drgn_object_type) was already called and the type is already known to be a signed integer type. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_object_set_unsigned_internal`](#drgn_object_set_unsigned_internal)  | Like [drgn_object_set_unsigned()](ObjectSetters.md#drgn_object_set_unsigned) but [drgn_object_type()](#drgn_object_type) was already called and the type is already known to be an unsigned integer type. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_object_set_float_internal`](#drgn_object_set_float_internal)  | Like [drgn_object_set_float()](ObjectSetters.md#drgn_object_set_float) but [drgn_object_type()](#drgn_object_type) was already called and the type is already known to be a floating-point type. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_object_set_from_buffer_internal`](#drgn_object_set_from_buffer_internal)  | Like [drgn_object_set_from_buffer()](ObjectSetters.md#drgn_object_set_from_buffer) but [drgn_object_type()](#drgn_object_type) was already called and the bounds of the buffer have already been checked. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_object_set_reference_internal`](#drgn_object_set_reference_internal)  | Like [drgn_object_set_reference()](ObjectSetters.md#drgn_object_set_reference) but [drgn_object_type()](#drgn_object_type) was already called. |
| `void` | [`drgn_object_set_absent_internal`](#drgn_object_set_absent_internal) `static` `inline` | Like [drgn_object_set_absent()](ObjectSetters.md#drgn_object_set_absent) but [drgn_object_type()](#drgn_object_type) was already called. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_object_fragment_internal`](#drgn_object_fragment_internal)  |  |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_op_cast`](#drgn_op_cast)  | Implement object type casting. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_op_cmp_impl`](#drgn_op_cmp_impl)  | Implement object comparison for signed, unsigned, and floating-point objects. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_op_cmp_pointers`](#drgn_op_cmp_pointers)  | Implement object comparison for pointers and reference buffer objects. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_op_add_to_pointer`](#drgn_op_add_to_pointer)  | Implement pointer arithmetic. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_op_sub_pointers`](#drgn_op_sub_pointers)  | Implement pointer subtraction. |

---

{#drgn_value_zalloc}

### drgn_value_zalloc

`static` `inline`

```cpp
static inline bool drgn_value_zalloc(uint64_t size, union drgn_value * value_ret, char ** buf_ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/object.h:45

Allocate a zero-initialized [drgn_value](drgn_value.md#drgn_value).

---

{#drgn_object_is_zero}

### drgn_object_is_zero

```cpp
struct drgn_error * drgn_object_is_zero(const struct drgn_object * obj, bool * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/object.h:69

Get whether an object is zero.

For scalars, this is true iff its value is zero. For structures, unions, and classes, this is true iff all of its members are zero. For arrays, this is true iff all of its elements are zero. Note that this ignores padding.

---

{#drgn_object_is_zero_or_incomplete}

### drgn_object_is_zero_or_incomplete

```cpp
struct drgn_error * drgn_object_is_zero_or_incomplete(const struct drgn_object * obj, bool * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/object.h:77

Like [drgn_object_is_zero()](#drgn_object_is_zero), but also returns true for incomplete objects.

---

{#drgn_object_type_qualified}

### drgn_object_type_qualified

`static` `inline`

```cpp
static inline struct drgn_qualified_type drgn_object_type_qualified(const struct drgn_object_type * type)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/object.h:93

Convert a [drgn_object_type](drgn_object_type.md#drgn_object_type-1) to a [drgn_qualified_type](drgn_qualified_type.md#drgn_qualified_type).

---

{#drgn_operand_type_qualified}

### drgn_operand_type_qualified

`static` `inline`

```cpp
static inline struct drgn_qualified_type drgn_operand_type_qualified(const struct drgn_operand_type * type)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/object.h:116

Convert a [drgn_operand_type](drgn_operand_type.md#drgn_operand_type) to a [drgn_qualified_type](drgn_qualified_type.md#drgn_qualified_type).

---

{#drgn_object_operand_type}

### drgn_object_operand_type

`static` `inline`

```cpp
static inline struct drgn_operand_type drgn_object_operand_type(const struct drgn_object * obj)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/object.h:126

Get the [drgn_operand_type](drgn_operand_type.md#drgn_operand_type) of a [drgn_object](drgn_object.md#drgn_object-1).

---

{#drgn_object_reinit}

### drgn_object_reinit

`static` `inline`

```cpp
static inline void drgn_object_reinit(struct drgn_object * obj, const struct drgn_object_type * type, enum drgn_object_kind kind)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/object.h:140

Deinitialize the value of a [drgn_object](drgn_object.md#drgn_object-1) and reinitialize the kind and type fields.

---

{#drgn_object_type}

### drgn_object_type

```cpp
struct drgn_error * drgn_object_type(struct drgn_qualified_type qualified_type, uint64_t bit_field_size, struct drgn_object_type * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/object.h:159

Compute the type-related fields of a [drgn_object](drgn_object.md#drgn_object-1) from a [drgn_qualified_type](drgn_qualified_type.md#drgn_qualified_type) and a bit field size.

---

{#drgn_object_set_signed_internal}

### drgn_object_set_signed_internal

```cpp
struct drgn_error * drgn_object_set_signed_internal(struct drgn_object * res, const struct drgn_object_type * type, int64_t svalue)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/object.h:167

Like [drgn_object_set_signed()](ObjectSetters.md#drgn_object_set_signed) but [drgn_object_type()](#drgn_object_type) was already called and the type is already known to be a signed integer type.

---

{#drgn_object_set_unsigned_internal}

### drgn_object_set_unsigned_internal

```cpp
struct drgn_error * drgn_object_set_unsigned_internal(struct drgn_object * res, const struct drgn_object_type * type, uint64_t uvalue)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/object.h:176

Like [drgn_object_set_unsigned()](ObjectSetters.md#drgn_object_set_unsigned) but [drgn_object_type()](#drgn_object_type) was already called and the type is already known to be an unsigned integer type.

---

{#drgn_object_set_float_internal}

### drgn_object_set_float_internal

```cpp
struct drgn_error * drgn_object_set_float_internal(struct drgn_object * res, const struct drgn_object_type * type, double fvalue)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/object.h:185

Like [drgn_object_set_float()](ObjectSetters.md#drgn_object_set_float) but [drgn_object_type()](#drgn_object_type) was already called and the type is already known to be a floating-point type.

---

{#drgn_object_set_from_buffer_internal}

### drgn_object_set_from_buffer_internal

```cpp
struct drgn_error * drgn_object_set_from_buffer_internal(struct drgn_object * res, const struct drgn_object_type * type, const void * buf, uint64_t bit_offset)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/object.h:194

Like [drgn_object_set_from_buffer()](ObjectSetters.md#drgn_object_set_from_buffer) but [drgn_object_type()](#drgn_object_type) was already called and the bounds of the buffer have already been checked.

---

{#drgn_object_set_reference_internal}

### drgn_object_set_reference_internal

```cpp
struct drgn_error * drgn_object_set_reference_internal(struct drgn_object * res, const struct drgn_object_type * type, uint64_t address, uint64_t bit_offset)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/object.h:203

Like [drgn_object_set_reference()](ObjectSetters.md#drgn_object_set_reference) but [drgn_object_type()](#drgn_object_type) was already called.

---

{#drgn_object_set_absent_internal}

### drgn_object_set_absent_internal

`static` `inline`

```cpp
static inline void drgn_object_set_absent_internal(struct drgn_object * res, const struct drgn_object_type * type, enum drgn_absence_reason reason)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/object.h:212

Like [drgn_object_set_absent()](ObjectSetters.md#drgn_object_set_absent) but [drgn_object_type()](#drgn_object_type) was already called.

---

{#drgn_object_fragment_internal}

### drgn_object_fragment_internal

```cpp
struct drgn_error * drgn_object_fragment_internal(struct drgn_object * res, const struct drgn_object * obj, const struct drgn_object_type * type, int64_t bit_offset, uint64_t bit_field_size)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/object.h:221

---

{#drgn_op_cast}

### drgn_op_cast

```cpp
struct drgn_error * drgn_op_cast(struct drgn_object * res, const struct drgn_object_type * type, const struct drgn_object * obj, const struct drgn_operand_type * obj_type)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/object.h:376

Implement object type casting.

If `obj_type` is a pointer type and `obj` is a buffer, then the reference address of `obj` is used.

---

{#drgn_op_cmp_impl}

### drgn_op_cmp_impl

```cpp
struct drgn_error * drgn_op_cmp_impl(const struct drgn_object * lhs, const struct drgn_object * rhs, const struct drgn_operand_type * op_type, int * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/object.h:386

Implement object comparison for signed, unsigned, and floating-point objects.

This converts `lhs` and `rhs` to `type` before comparing.

---

{#drgn_op_cmp_pointers}

### drgn_op_cmp_pointers

```cpp
struct drgn_error * drgn_op_cmp_pointers(const struct drgn_object * lhs, const struct drgn_object * rhs, int * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/object.h:396

Implement object comparison for pointers and reference buffer objects.

When comparing reference buffer objects, their address is used.

---

{#drgn_op_add_to_pointer}

### drgn_op_add_to_pointer

```cpp
struct drgn_error * drgn_op_add_to_pointer(struct drgn_object * res, const struct drgn_operand_type * op_type, uint64_t referenced_size, bool negate, const struct drgn_object * ptr, const struct drgn_object * index)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/object.h:416

Implement pointer arithmetic.

This converts `ptr` to `op_type`, adds or subtracts `index * referenced_size`, and stores the result in `res`.

#### Returns
`NULL` on success, non-`NULL` on error. `res` is not modified on error.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `res` | struct [`drgn_object`](drgn_object.md#drgn_object-1) * | Operator result. May be the same as `ptr` or `index`. |
| `op_type` | const struct [`drgn_operand_type`](drgn_operand_type.md#drgn_operand_type) * | Result type. |
| `referenced_size` | `uint64_t` | Size of the object pointed to by `ptr`. |
| `negate` | `bool` | Subtract `index` instead of adding. |
| `ptr` | const struct [`drgn_object`](drgn_object.md#drgn_object-1) * | Pointer. |
| `index` | const struct [`drgn_object`](drgn_object.md#drgn_object-1) * | Value to add to/subtract from pointer. |

---

{#drgn_op_sub_pointers}

### drgn_op_sub_pointers

```cpp
struct drgn_error * drgn_op_sub_pointers(struct drgn_object * res, const struct drgn_operand_type * op_type, uint64_t referenced_size, const struct drgn_object * lhs, const struct drgn_object * rhs)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/object.h:436

Implement pointer subtraction.

This stores `(lhs - rhs) / referenced_size` in `res`.

#### Returns
`NULL` on success, non-`NULL` on error. `res` is not modified on error.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `res` | struct [`drgn_object`](drgn_object.md#drgn_object-1) * | Operator result. May be the same as `lhs` and/or `rhs`. |
| `op_type` | const struct [`drgn_operand_type`](drgn_operand_type.md#drgn_operand_type) * | Result type. Must be a signed integer type. |
| `referenced_size` | `uint64_t` | Size of the object pointed to by `lhs` and `rhs`. |
| `lhs` | const struct [`drgn_object`](drgn_object.md#drgn_object-1) * | Operator left hand side. |
| `rhs` | const struct [`drgn_object`](drgn_object.md#drgn_object-1) * | Operator right hand side. |

## Variables

| Return | Name | Description |
|--------|------|-------------|
| [`drgn_binary_op_impl`](#drgn_binary_op_impl) | [`drgn_op_add_impl`](#drgn_op_add_impl)  | Implement addition for signed, unsigned, and floating-point objects. |
| [`drgn_binary_op_impl`](#drgn_binary_op_impl) | [`drgn_op_sub_impl`](#drgn_op_sub_impl)  | Implement subtraction for signed, unsigned, and floating-point objects. |
| [`drgn_binary_op_impl`](#drgn_binary_op_impl) | [`drgn_op_mul_impl`](#drgn_op_mul_impl)  | Implement multiplication for signed, unsigned, and floating-point objects. |
| [`drgn_binary_op_impl`](#drgn_binary_op_impl) | [`drgn_op_div_impl`](#drgn_op_div_impl)  | Implement division for signed, unsigned, and floating-point objects. |
| [`drgn_binary_op_impl`](#drgn_binary_op_impl) | [`drgn_op_mod_impl`](#drgn_op_mod_impl)  | Implement modulo for signed and unsigned objects. |
| [`drgn_shift_op_impl`](#drgn_shift_op_impl) | [`drgn_op_lshift_impl`](#drgn_op_lshift_impl)  | Implement left shift for signed and unsigned objects. |
| [`drgn_shift_op_impl`](#drgn_shift_op_impl) | [`drgn_op_rshift_impl`](#drgn_op_rshift_impl)  | Implement right shift for signed and unsigned objects. |
| [`drgn_binary_op_impl`](#drgn_binary_op_impl) | [`drgn_op_and_impl`](#drgn_op_and_impl)  | Implement bitwise and for signed and unsigned objects. |
| [`drgn_binary_op_impl`](#drgn_binary_op_impl) | [`drgn_op_or_impl`](#drgn_op_or_impl)  | Implement bitwise or for signed and unsigned objects. |
| [`drgn_binary_op_impl`](#drgn_binary_op_impl) | [`drgn_op_xor_impl`](#drgn_op_xor_impl)  | Implement bitwise xor for signed and unsigned objects. |
| [`drgn_unary_op_impl`](#drgn_unary_op_impl) | [`drgn_op_pos_impl`](#drgn_op_pos_impl)  | Implement the unary plus operator for signed, unsigned, and floating-point objects. |
| [`drgn_unary_op_impl`](#drgn_unary_op_impl) | [`drgn_op_neg_impl`](#drgn_op_neg_impl)  | Implement negation for signed, unsigned, and floating-point objects. |
| [`drgn_unary_op_impl`](#drgn_unary_op_impl) | [`drgn_op_not_impl`](#drgn_op_not_impl)  | Implement bitwise negation for signed and unsigned objects. |

---

{#drgn_op_add_impl}

### drgn_op_add_impl

```cpp
drgn_binary_op_impl drgn_op_add_impl
```

Type: [`drgn_binary_op_impl`](#drgn_binary_op_impl)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/object.h:287

Implement addition for signed, unsigned, and floating-point objects.

Integer results are reduced modulo 2^width.

---

{#drgn_op_sub_impl}

### drgn_op_sub_impl

```cpp
drgn_binary_op_impl drgn_op_sub_impl
```

Type: [`drgn_binary_op_impl`](#drgn_binary_op_impl)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/object.h:293

Implement subtraction for signed, unsigned, and floating-point objects.

Integer results are reduced modulo 2^width.

---

{#drgn_op_mul_impl}

### drgn_op_mul_impl

```cpp
drgn_binary_op_impl drgn_op_mul_impl
```

Type: [`drgn_binary_op_impl`](#drgn_binary_op_impl)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/object.h:299

Implement multiplication for signed, unsigned, and floating-point objects.

Integer results are reduced modulo 2^width.

---

{#drgn_op_div_impl}

### drgn_op_div_impl

```cpp
drgn_binary_op_impl drgn_op_div_impl
```

Type: [`drgn_binary_op_impl`](#drgn_binary_op_impl)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/object.h:306

Implement division for signed, unsigned, and floating-point objects.

Integer results are truncated towards zero. A [DRGN_ERROR_ZERO_DIVISION](api.md#drgn_error_zero_division) error is returned if `rhs` is zero.

---

{#drgn_op_mod_impl}

### drgn_op_mod_impl

```cpp
drgn_binary_op_impl drgn_op_mod_impl
```

Type: [`drgn_binary_op_impl`](#drgn_binary_op_impl)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/object.h:313

Implement modulo for signed and unsigned objects.

The result has the sign of the dividend. A [DRGN_ERROR_ZERO_DIVISION](api.md#drgn_error_zero_division) error is returned if `rhs` is zero.

---

{#drgn_op_lshift_impl}

### drgn_op_lshift_impl

```cpp
drgn_shift_op_impl drgn_op_lshift_impl
```

Type: [`drgn_shift_op_impl`](#drgn_shift_op_impl)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/object.h:322

Implement left shift for signed and unsigned objects.

For signed integers, this acts on the two's complement representation. The result is reduced modulo 2^width. In particular, if `rhs` is greater than the width of the result, then the result is zero. An error is returned if `rhs` is negative.

---

{#drgn_op_rshift_impl}

### drgn_op_rshift_impl

```cpp
drgn_shift_op_impl drgn_op_rshift_impl
```

Type: [`drgn_shift_op_impl`](#drgn_shift_op_impl)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/object.h:331

Implement right shift for signed and unsigned objects.

For signed integers, this is an arithmetic shift. For unsigned integers, it is logical. The result is reduced modulo 2^width. In particular, if `rhs` is greater than the width of the result, then the result is zero. An error is returned if `rhs` is negative.

---

{#drgn_op_and_impl}

### drgn_op_and_impl

```cpp
drgn_binary_op_impl drgn_op_and_impl
```

Type: [`drgn_binary_op_impl`](#drgn_binary_op_impl)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/object.h:337

Implement bitwise and for signed and unsigned objects.

For signed integers, this acts on the two's complement representation.

---

{#drgn_op_or_impl}

### drgn_op_or_impl

```cpp
drgn_binary_op_impl drgn_op_or_impl
```

Type: [`drgn_binary_op_impl`](#drgn_binary_op_impl)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/object.h:343

Implement bitwise or for signed and unsigned objects.

For signed integers, this acts on the two's complement representation.

---

{#drgn_op_xor_impl}

### drgn_op_xor_impl

```cpp
drgn_binary_op_impl drgn_op_xor_impl
```

Type: [`drgn_binary_op_impl`](#drgn_binary_op_impl)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/object.h:349

Implement bitwise xor for signed and unsigned objects.

For signed integers, this acts on the two's complement representation.

---

{#drgn_op_pos_impl}

### drgn_op_pos_impl

```cpp
drgn_unary_op_impl drgn_op_pos_impl
```

Type: [`drgn_unary_op_impl`](#drgn_unary_op_impl)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/object.h:356

Implement the unary plus operator for signed, unsigned, and floating-point objects.

This converts `obj` without otherwise changing the value.

---

{#drgn_op_neg_impl}

### drgn_op_neg_impl

```cpp
drgn_unary_op_impl drgn_op_neg_impl
```

Type: [`drgn_unary_op_impl`](#drgn_unary_op_impl)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/object.h:362

Implement negation for signed, unsigned, and floating-point objects.

Integer results are reduced modulo 2^width.

---

{#drgn_op_not_impl}

### drgn_op_not_impl

```cpp
drgn_unary_op_impl drgn_op_not_impl
```

Type: [`drgn_unary_op_impl`](#drgn_unary_op_impl)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/object.h:368

Implement bitwise negation for signed and unsigned objects.

For signed integers, this acts on the two's complement representation.

