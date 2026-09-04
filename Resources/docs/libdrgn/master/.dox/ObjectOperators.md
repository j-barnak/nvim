{#operators}

# Operators

> [`Objects`](Objects.md#objects)

Object operators.

Various operators are defined on [drgn_object](drgn_object.md#drgn_object-1)s. These operators obey the rules of the programming language of the given objects.

Operators which return a [drgn_object](drgn_object.md#drgn_object-1) have the same calling convention: the result object is the first argument, which must be initialized and may be the same as one or more of the operands; the result is only modified if the operator succeeds.

## Typedefs

| Return | Name | Description |
|--------|------|-------------|
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_binary_op`](#drgn_binary_op)  | [drgn_object](drgn_object.md#drgn_object-1) binary operator. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_unary_op`](#drgn_unary_op)  | [drgn_object](drgn_object.md#drgn_object-1) unary operator. |

---

{#drgn_binary_op}

### drgn_binary_op

```cpp
using drgn_binary_op = struct drgn_error *
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:3166

[drgn_object](drgn_object.md#drgn_object-1) binary operator.

Binary operators apply any language-specific conversions to `lhs` and `rhs`, apply the operator, and store the result in `res`.

#### Returns
`NULL` on success, non-`NULL` on error. `res` is not modified on error.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `res` |  | Operator result. May be the same as `lhs` and/or `rhs`. |
| `lhs` |  | Operator left hand side. |
| `rhs` |  | Operator right hand side. |

---

{#drgn_unary_op}

### drgn_unary_op

```cpp
using drgn_unary_op = struct drgn_error *
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:3181

[drgn_object](drgn_object.md#drgn_object-1) unary operator.

Unary operators apply any language-specific conversions to `obj`, apply the operator, and store the result in `res`.

#### Returns
`NULL` on success, non-`NULL` on error. `res` is not modified on error.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `res` |  | Operator result. May be the same as `obj`. |
| `obj` |  | Operand. |

## Functions

| Return | Name | Description |
|--------|------|-------------|
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_object_cast`](#drgn_object_cast)  | Set a [drgn_object](drgn_object.md#drgn_object-1) to the value of an object explicitly casted to a another type. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_object_implicit_convert`](#drgn_object_implicit_convert)  | Set a [drgn_object](drgn_object.md#drgn_object-1) to the value of an object implicitly converted to a another type. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_object_reinterpret`](#drgn_object_reinterpret)  | Set a [drgn_object](drgn_object.md#drgn_object-1) to the representation of an object reinterpreted as another type. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_object_bool`](#drgn_object_bool)  | Convert a [drgn_object](drgn_object.md#drgn_object-1) to a boolean value. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_object_cmp`](#drgn_object_cmp)  | Compare the value of two [drgn_object](drgn_object.md#drgn_object-1)s. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_object_address_of`](#drgn_object_address_of)  | Get the address of (`&`) a [drgn_object](drgn_object.md#drgn_object-1) as an object. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_object_subscript`](#drgn_object_subscript)  | Subscript (``[]) a [drgn_object](drgn_object.md#drgn_object-1). |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_object_dereference`](#drgn_object_dereference) `static` `inline` | Deference (`*`) a [drgn_object](drgn_object.md#drgn_object-1). |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_object_slice`](#drgn_object_slice)  | Slice (i.e., get an array from a range of another array) a [drgn_object](drgn_object.md#drgn_object-1). |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_object_member`](#drgn_object_member)  | Get a member of a structure, union, or class [drgn_object](drgn_object.md#drgn_object-1) (``.). |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_object_member_dereference`](#drgn_object_member_dereference)  | Get a member of a pointer [drgn_object](drgn_object.md#drgn_object-1) (`->`). |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_object_subobject`](#drgn_object_subobject)  | Get a subobject (member or element) of this object. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_object_container_of`](#drgn_object_container_of)  | Get the containing object of a member [drgn_object](drgn_object.md#drgn_object-1). |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_object_sizeof`](#drgn_object_sizeof)  | Get the size of a [drgn_object](drgn_object.md#drgn_object-1) in bytes. |

---

{#drgn_object_cast}

### drgn_object_cast

```cpp
struct drgn_error * drgn_object_cast(struct drgn_object * res, struct drgn_qualified_type qualified_type, const struct drgn_object * obj)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:3108

Set a [drgn_object](drgn_object.md#drgn_object-1) to the value of an object explicitly casted to a another type.

This uses the programming language's rules for explicit conversions, like the cast operator.

**See also**: [drgn_object_implicit_convert()](#drgn_object_implicit_convert), [drgn_object_reinterpret()](#drgn_object_reinterpret)

#### Returns
`NULL` on success, non-`NULL` on error.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `res` | struct [`drgn_object`](drgn_object.md#drgn_object-1) * | Object to set. Always set to a value object. |
| `qualified_type` | struct [`drgn_qualified_type`](drgn_qualified_type.md#drgn_qualified_type) | New type. |
| `obj` | const struct [`drgn_object`](drgn_object.md#drgn_object-1) * | Object to cast. |

---

{#drgn_object_implicit_convert}

### drgn_object_implicit_convert

```cpp
struct drgn_error * drgn_object_implicit_convert(struct drgn_object * res, struct drgn_qualified_type qualified_type, uint64_t bit_field_size, const struct drgn_object * obj)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:3129

Set a [drgn_object](drgn_object.md#drgn_object-1) to the value of an object implicitly converted to a another type.

This uses the programming language's rules for implicit conversions, like when assigning to a variable or passing arguments to a function call.

**See also**: [drgn_object_cast()](#drgn_object_cast), [drgn_object_reinterpret()](#drgn_object_reinterpret)

#### Returns
`NULL` on success, non-`NULL` on error.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `res` | struct [`drgn_object`](drgn_object.md#drgn_object-1) * | Object to set. Always set to a value object. |
| `qualified_type` | struct [`drgn_qualified_type`](drgn_qualified_type.md#drgn_qualified_type) | New type. |
| `bit_field_size` | `uint64_t` | If the object should be a bit field, its size in bits. Otherwise, 0. |
| `obj` | const struct [`drgn_object`](drgn_object.md#drgn_object-1) * | Object to convert. |

---

{#drgn_object_reinterpret}

### drgn_object_reinterpret

```cpp
struct drgn_error * drgn_object_reinterpret(struct drgn_object * res, struct drgn_qualified_type qualified_type, const struct drgn_object * obj)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:3150

Set a [drgn_object](drgn_object.md#drgn_object-1) to the representation of an object reinterpreted as another type.

This reinterprets the raw memory of the object, so an object can be reinterpreted as any other type.

**See also**: [drgn_object_cast()](#drgn_object_cast), [drgn_object_implicit_convert()](#drgn_object_implicit_convert)

#### Returns
`NULL` on success, non-`NULL` on error.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `res` | struct [`drgn_object`](drgn_object.md#drgn_object-1) * | Object to set. If `obj` is a value, set to a value. If `obj` is a reference, set to a reference. |
| `qualified_type` | struct [`drgn_qualified_type`](drgn_qualified_type.md#drgn_qualified_type) | New type. |
| `obj` | const struct [`drgn_object`](drgn_object.md#drgn_object-1) * | Object to reinterpret. |

---

{#drgn_object_bool}

### drgn_object_bool

```cpp
struct drgn_error * drgn_object_bool(const struct drgn_object * obj, bool * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:3194

Convert a [drgn_object](drgn_object.md#drgn_object-1) to a boolean value.

This gets the "truthiness" of an object according to its programming language.

#### Returns
`NULL` on success, non-`NULL` on error.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `obj` | const struct [`drgn_object`](drgn_object.md#drgn_object-1) * | Object. |
| `ret` | `bool *` | Returned boolean value. |

---

{#drgn_object_cmp}

### drgn_object_cmp

```cpp
struct drgn_error * drgn_object_cmp(const struct drgn_object * lhs, const struct drgn_object * rhs, int * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:3208

Compare the value of two [drgn_object](drgn_object.md#drgn_object-1)s.

This applies any language-specific conversions to `lhs` and `rhs` and compares the resulting values.

#### Returns
`NULL` on success, non-`NULL` on error.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `lhs` | const struct [`drgn_object`](drgn_object.md#drgn_object-1) * | Comparison left hand side. |
| `rhs` | const struct [`drgn_object`](drgn_object.md#drgn_object-1) * | Comparison right hand side. |
| `ret` | `int *` | 0 if the operands are equal, < 0 if `lhs` < `rhs`, and > 0 if `lhs` > `rhs`. |

---

{#drgn_object_address_of}

### drgn_object_address_of

```cpp
struct drgn_error * drgn_object_address_of(struct drgn_object * res, const struct drgn_object * obj)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:3249

Get the address of (`&`) a [drgn_object](drgn_object.md#drgn_object-1) as an object.

This is only possible for reference objects, as value objects don't have an address in the program.

#### Returns
`NULL` on success, non-`NULL` on error. `res` is not modified on error.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `res` | struct [`drgn_object`](drgn_object.md#drgn_object-1) * | Resulting pointer value. May be the same as `obj`. |
| `obj` | const struct [`drgn_object`](drgn_object.md#drgn_object-1) * | Reference object. |

---

{#drgn_object_subscript}

### drgn_object_subscript

```cpp
struct drgn_error * drgn_object_subscript(struct drgn_object * res, const struct drgn_object * obj, int64_t index)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:3263

Subscript (``[]) a [drgn_object](drgn_object.md#drgn_object-1).

This is applicable to pointers and arrays.

#### Returns
`NULL` on success, non-`NULL` on error. `res` is not modified on error.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `res` | struct [`drgn_object`](drgn_object.md#drgn_object-1) * | Resulting element. May be the same as `obj`. |
| `obj` | const struct [`drgn_object`](drgn_object.md#drgn_object-1) * | Object to subscript. |
| `index` | `int64_t` | Element index. |

---

{#drgn_object_dereference}

### drgn_object_dereference

`static` `inline`

```cpp
static inline struct drgn_error * drgn_object_dereference(struct drgn_object * res, const struct drgn_object * obj)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:3278

Deference (`*`) a [drgn_object](drgn_object.md#drgn_object-1).

This is equivalent to [drgn_object_subscript](#drgn_object_subscript) with an index of 0.

#### Returns
`NULL` on success, non-`NULL` on error. `res` is not modified on error.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `res` | struct [`drgn_object`](drgn_object.md#drgn_object-1) * | Deferenced object. May be the same as `obj`. |
| `obj` | const struct [`drgn_object`](drgn_object.md#drgn_object-1) * | Object to dereference. |

---

{#drgn_object_slice}

### drgn_object_slice

```cpp
struct drgn_error * drgn_object_slice(struct drgn_object * res, const struct drgn_object * obj, int64_t start, int64_t end)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:3295

Slice (i.e., get an array from a range of another array) a [drgn_object](drgn_object.md#drgn_object-1).

This is applicable to pointers and arrays.

#### Returns
`NULL` on success, non-`NULL` on error. `res` is not modified on error.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `res` | struct [`drgn_object`](drgn_object.md#drgn_object-1) * | Resulting array. May be the same as `obj`. |
| `obj` | const struct [`drgn_object`](drgn_object.md#drgn_object-1) * | Object to slice. |
| `start` | `int64_t` | Start index (inclusive). |
| `end` | `int64_t` | End index (exclusive). |

---

{#drgn_object_member}

### drgn_object_member

```cpp
struct drgn_error * drgn_object_member(struct drgn_object * res, const struct drgn_object * obj, const char * member_name)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:3308

Get a member of a structure, union, or class [drgn_object](drgn_object.md#drgn_object-1) (``.).

#### Returns
`NULL` on success, non-`NULL` on error. `res` is not modified on error.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `res` | struct [`drgn_object`](drgn_object.md#drgn_object-1) * | Returned member. May be the same as `obj`. |
| `obj` | const struct [`drgn_object`](drgn_object.md#drgn_object-1) * | Object. |
| `member_name` | `const char *` | Name of member. |

---

{#drgn_object_member_dereference}

### drgn_object_member_dereference

```cpp
struct drgn_error * drgn_object_member_dereference(struct drgn_object * res, const struct drgn_object * obj, const char * member_name)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:3323

Get a member of a pointer [drgn_object](drgn_object.md#drgn_object-1) (`->`).

This is applicable to pointers to structures and pointers to unions.

#### Returns
`NULL` on success, non-`NULL` on error. `res` is not modified on error.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `res` | struct [`drgn_object`](drgn_object.md#drgn_object-1) * | Returned member. May be the same as `obj`. |
| `obj` | const struct [`drgn_object`](drgn_object.md#drgn_object-1) * | Object. |
| `member_name` | `const char *` | Name of member. |

---

{#drgn_object_subobject}

### drgn_object_subobject

```cpp
struct drgn_error * drgn_object_subobject(struct drgn_object * res, const struct drgn_object * obj, const char * member_designator)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:3337

Get a subobject (member or element) of this object.

#### Returns
`NULL` on success, non-`NULL` on error. `res` is not modified on error.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `res` | struct [`drgn_object`](drgn_object.md#drgn_object-1) * | Returned subobject. May be the same as `obj`. |
| `obj` | const struct [`drgn_object`](drgn_object.md#drgn_object-1) * | Object. |

---

{#drgn_object_container_of}

### drgn_object_container_of

```cpp
struct drgn_error * drgn_object_container_of(struct drgn_object * res, const struct drgn_object * obj, struct drgn_qualified_type qualified_type, const char * member_designator)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:3356

Get the containing object of a member [drgn_object](drgn_object.md#drgn_object-1).

This corresponds to the `[container_of()](api.md#container_of)` macro commonly used in C.

#### Returns
`NULL` on success, non-`NULL` on error. `res` is not modified on error.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `res` | struct [`drgn_object`](drgn_object.md#drgn_object-1) * | Returned object. May be the same as `obj`. |
| `obj` | const struct [`drgn_object`](drgn_object.md#drgn_object-1) * | Pointer to a member. |
| `qualified_type` | struct [`drgn_qualified_type`](drgn_qualified_type.md#drgn_qualified_type) | Type which contains the member. |
| `member_designator` | `const char *` | Name of the member in `qualified_type`. This can include one or more member references and zero or more array subscripts. |

---

{#drgn_object_sizeof}

### drgn_object_sizeof

```cpp
struct drgn_error * drgn_object_sizeof(const struct drgn_object * obj, uint64_t * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:3367

Get the size of a [drgn_object](drgn_object.md#drgn_object-1) in bytes.

#### Returns
`NULL` on success, non-`NULL` on error.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `obj` | const struct [`drgn_object`](drgn_object.md#drgn_object-1) * | Object. |
| `ret` | `uint64_t *` | Returned size. |

## Variables

| Return | Name | Description |
|--------|------|-------------|
| [`drgn_binary_op`](#drgn_binary_op) | [`drgn_object_add`](#drgn_object_add)  | Add (`+`) two [drgn_object](drgn_object.md#drgn_object-1)s. |
| [`drgn_binary_op`](#drgn_binary_op) | [`drgn_object_sub`](#drgn_object_sub)  | Subtract (`-`) a [drgn_object](drgn_object.md#drgn_object-1) from another. |
| [`drgn_binary_op`](#drgn_binary_op) | [`drgn_object_mul`](#drgn_object_mul)  | Multiply (`*`) two [drgn_object](drgn_object.md#drgn_object-1)s. |
| [`drgn_binary_op`](#drgn_binary_op) | [`drgn_object_div`](#drgn_object_div)  | Divide (`/`) a [drgn_object](drgn_object.md#drgn_object-1) by another. |
| [`drgn_binary_op`](#drgn_binary_op) | [`drgn_object_mod`](#drgn_object_mod)  | Calculate the modulus (`%`) of two [drgn_object](drgn_object.md#drgn_object-1)s. |
| [`drgn_binary_op`](#drgn_binary_op) | [`drgn_object_lshift`](#drgn_object_lshift)  | Left shift (`<<`) a [drgn_object](drgn_object.md#drgn_object-1) by another. |
| [`drgn_binary_op`](#drgn_binary_op) | [`drgn_object_rshift`](#drgn_object_rshift)  | Right shift (`>>`) a [drgn_object](drgn_object.md#drgn_object-1) by another. |
| [`drgn_binary_op`](#drgn_binary_op) | [`drgn_object_and`](#drgn_object_and)  | Calculate the bitwise and (`&`) of two [drgn_object](drgn_object.md#drgn_object-1)s. |
| [`drgn_binary_op`](#drgn_binary_op) | [`drgn_object_or`](#drgn_object_or)  | Calculate the bitwise or (``\|) of two [drgn_object](drgn_object.md#drgn_object-1)s. |
| [`drgn_binary_op`](#drgn_binary_op) | [`drgn_object_xor`](#drgn_object_xor)  | Calculate the bitwise exclusive or (`^`) of two [drgn_object](drgn_object.md#drgn_object-1)s. |
| [`drgn_unary_op`](#drgn_unary_op) | [`drgn_object_pos`](#drgn_object_pos)  | Apply unary plus (`+`) to a [drgn_object](drgn_object.md#drgn_object-1). |
| [`drgn_unary_op`](#drgn_unary_op) | [`drgn_object_neg`](#drgn_object_neg)  | Calculate the arithmetic negation (`-`) of a [drgn_object](drgn_object.md#drgn_object-1). |
| [`drgn_unary_op`](#drgn_unary_op) | [`drgn_object_not`](#drgn_object_not)  | Calculate the bitwise negation (`~`) of a [drgn_object](drgn_object.md#drgn_object-1). |

---

{#drgn_object_add}

### drgn_object_add

```cpp
drgn_binary_op drgn_object_add
```

Type: [`drgn_binary_op`](#drgn_binary_op)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:3212

Add (`+`) two [drgn_object](drgn_object.md#drgn_object-1)s.

---

{#drgn_object_sub}

### drgn_object_sub

```cpp
drgn_binary_op drgn_object_sub
```

Type: [`drgn_binary_op`](#drgn_binary_op)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:3214

Subtract (`-`) a [drgn_object](drgn_object.md#drgn_object-1) from another.

---

{#drgn_object_mul}

### drgn_object_mul

```cpp
drgn_binary_op drgn_object_mul
```

Type: [`drgn_binary_op`](#drgn_binary_op)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:3216

Multiply (`*`) two [drgn_object](drgn_object.md#drgn_object-1)s.

---

{#drgn_object_div}

### drgn_object_div

```cpp
drgn_binary_op drgn_object_div
```

Type: [`drgn_binary_op`](#drgn_binary_op)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:3218

Divide (`/`) a [drgn_object](drgn_object.md#drgn_object-1) by another.

---

{#drgn_object_mod}

### drgn_object_mod

```cpp
drgn_binary_op drgn_object_mod
```

Type: [`drgn_binary_op`](#drgn_binary_op)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:3220

Calculate the modulus (`%`) of two [drgn_object](drgn_object.md#drgn_object-1)s.

---

{#drgn_object_lshift}

### drgn_object_lshift

```cpp
drgn_binary_op drgn_object_lshift
```

Type: [`drgn_binary_op`](#drgn_binary_op)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:3222

Left shift (`<<`) a [drgn_object](drgn_object.md#drgn_object-1) by another.

---

{#drgn_object_rshift}

### drgn_object_rshift

```cpp
drgn_binary_op drgn_object_rshift
```

Type: [`drgn_binary_op`](#drgn_binary_op)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:3224

Right shift (`>>`) a [drgn_object](drgn_object.md#drgn_object-1) by another.

---

{#drgn_object_and}

### drgn_object_and

```cpp
drgn_binary_op drgn_object_and
```

Type: [`drgn_binary_op`](#drgn_binary_op)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:3226

Calculate the bitwise and (`&`) of two [drgn_object](drgn_object.md#drgn_object-1)s.

---

{#drgn_object_or}

### drgn_object_or

```cpp
drgn_binary_op drgn_object_or
```

Type: [`drgn_binary_op`](#drgn_binary_op)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:3228

Calculate the bitwise or (``|) of two [drgn_object](drgn_object.md#drgn_object-1)s.

---

{#drgn_object_xor}

### drgn_object_xor

```cpp
drgn_binary_op drgn_object_xor
```

Type: [`drgn_binary_op`](#drgn_binary_op)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:3230

Calculate the bitwise exclusive or (`^`) of two [drgn_object](drgn_object.md#drgn_object-1)s.

---

{#drgn_object_pos}

### drgn_object_pos

```cpp
drgn_unary_op drgn_object_pos
```

Type: [`drgn_unary_op`](#drgn_unary_op)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:3232

Apply unary plus (`+`) to a [drgn_object](drgn_object.md#drgn_object-1).

---

{#drgn_object_neg}

### drgn_object_neg

```cpp
drgn_unary_op drgn_object_neg
```

Type: [`drgn_unary_op`](#drgn_unary_op)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:3234

Calculate the arithmetic negation (`-`) of a [drgn_object](drgn_object.md#drgn_object-1).

---

{#drgn_object_not}

### drgn_object_not

```cpp
drgn_unary_op drgn_object_not
```

Type: [`drgn_unary_op`](#drgn_unary_op)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:3236

Calculate the bitwise negation (`~`) of a [drgn_object](drgn_object.md#drgn_object-1).

