{#types-1}

# Types

> [`Internals`](Internals.md#internals)

Type internals.

This provides internal helpers for creating and accessing types. Additionally, standard C types need special handling for C's various operator conversion rules, so this provides helpers for working with standard C types.

## Groups

| Name | Description |
|------|-------------|
| [`Type creation`](TypeCreation.md#typecreation) | Creating type descriptors. |

## Classes

| Name | Description |
|------|-------------|
| [`drgn_type_finder`](drgn_type_finder.md#drgn_type_finder) | Registered type finding callback in a [drgn_program](drgn_program.md#drgn_program). |
| [`drgn_member_key`](drgn_member_key.md#drgn_member_key) | `(type, member name)` pair. |
| [`drgn_member_value`](drgn_member_value.md#drgn_member_value) | Type, offset, and bit field size of a type member. |

## Enumerations

| Name | Description |
|------|-------------|
| [`drgn_byte_order`](#drgn_byte_order)  | Byte-order specification. |

---

{#drgn_byte_order}

### drgn_byte_order

```cpp
enum drgn_byte_order
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/type.h:37

Byte-order specification.

| Value | Description |
|-------|-------------|
| `DRGN_BIG_ENDIAN` | Big-endian. |
| `DRGN_LITTLE_ENDIAN` | Little-endian. |
| `DRGN_PROGRAM_ENDIAN` | Endianness of the program. |
## Functions

| Return | Name | Description |
|--------|------|-------------|
| enum [`drgn_byte_order`](drgn_byte_order.md#drgn_byte_order) | [`drgn_byte_order_from_little_endian`](#drgn_byte_order_from_little_endian) `static` `inline` |  |
|  | [`DEFINE_HASH_SET_TYPE`](#define_hash_set_type-2)  |  |
|  | [`DEFINE_HASH_MAP_TYPE`](#define_hash_map_type-3)  |  |
|  | [`DEFINE_HASH_SET_TYPE`](#define_hash_set_type-3)  |  |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_type_with_byte_order`](#drgn_type_with_byte_order)  | Create a copy of a type with a different byte order. |
| enum [`drgn_primitive_type`](drgn_primitive_type.md#drgn_primitive_type) | [`c_parse_specifier_list`](#c_parse_specifier_list)  | Parse the name of an unqualified primitive C type. |
| struct [`drgn_type`](drgn_type.md#drgn_type) * | [`drgn_underlying_type`](#drgn_underlying_type) `static` `inline` | Get the type of a [drgn_type](drgn_type.md#drgn_type) with all typedefs removed. |
| `bool` | [`drgn_enum_type_is_signed`](#drgn_enum_type_is_signed) `static` `inline` | Get whether an enumerated type is signed. |
| `bool` | [`drgn_type_is_anonymous`](#drgn_type_is_anonymous) `static` `inline` | Get whether a type is anonymous (i.e., the type has no name). |
| `bool` | [`drgn_type_is_integer`](#drgn_type_is_integer)  | Returned whether a [drgn_type](drgn_type.md#drgn_type) is an integer type. |
| `bool` | [`drgn_type_is_arithmetic`](#drgn_type_is_arithmetic)  | Return whether a [drgn_type](drgn_type.md#drgn_type) is an arithmetic type. |
| `bool` | [`drgn_type_is_scalar`](#drgn_type_is_scalar)  | Return whether a [drgn_type](drgn_type.md#drgn_type) is a scalar type. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_type_bit_size`](#drgn_type_bit_size)  | Get the size of a type in bits. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_dwarf_type_alignment`](#drgn_dwarf_type_alignment)  |  |
| `void` | [`drgn_program_init_types`](#drgn_program_init_types)  | Initialize type-related fields in a [drgn_program](drgn_program.md#drgn_program). |
| `void` | [`drgn_program_deinit_types`](#drgn_program_deinit_types)  | Deinitialize type-related fields in a [drgn_program](drgn_program.md#drgn_program). |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_program_find_type_impl`](#drgn_program_find_type_impl)  | Find a parsed type in a [drgn_program](drgn_program.md#drgn_program). |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_program_find_primitive_type`](#drgn_program_find_primitive_type)  | Find a primitive type in a [drgn_program](drgn_program.md#drgn_program). |

---

{#drgn_byte_order_from_little_endian}

### drgn_byte_order_from_little_endian

`static` `inline`

```cpp
static inline enum drgn_byte_order drgn_byte_order_from_little_endian(bool little_endian)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/type.h:47

---

{#define_hash_set_type-2}

### DEFINE_HASH_SET_TYPE

```cpp
DEFINE_HASH_SET_TYPE(drgn_dedupe_type_set, struct drgn_type *)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/type.h:59

---

{#define_hash_map_type-3}

### DEFINE_HASH_MAP_TYPE

```cpp
DEFINE_HASH_MAP_TYPE(drgn_member_map, struct drgn_member_key, struct drgn_member_value)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/type.h:87

---

{#define_hash_set_type-3}

### DEFINE_HASH_SET_TYPE

```cpp
DEFINE_HASH_SET_TYPE(drgn_type_set, struct drgn_type *)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/type.h:89

---

{#drgn_type_with_byte_order}

### drgn_type_with_byte_order

```cpp
struct drgn_error * drgn_type_with_byte_order(struct drgn_type ** type, struct drgn_type ** underlying_type, enum drgn_byte_order byte_order)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/type.h:463

Create a copy of a type with a different byte order.

---

{#c_parse_specifier_list}

### c_parse_specifier_list

```cpp
enum drgn_primitive_type c_parse_specifier_list(const char * s)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/type.h:476

Parse the name of an unqualified primitive C type.

#### Returns
The type, or [DRGN_NOT_PRIMITIVE_TYPE](api.md#drgn_not_primitive_type) if `s` is not the name of a primitive C type.

---

{#drgn_underlying_type}

### drgn_underlying_type

`static` `inline`

```cpp
static inline struct drgn_type * drgn_underlying_type(struct drgn_type * type)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/type.h:484

Get the type of a [drgn_type](drgn_type.md#drgn_type) with all typedefs removed.

I.e., the underlying type is the aliased type of the type if it is a typedef, recursively.

---

{#drgn_enum_type_is_signed}

### drgn_enum_type_is_signed

`static` `inline`

```cpp
static inline bool drgn_enum_type_is_signed(struct drgn_type * type)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/type.h:501

Get whether an enumerated type is signed.

This is true if and only if the compatible integer type is signed.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `type` | struct [`drgn_type`](drgn_type.md#drgn_type) * | Enumerated type. It must be complete. |

---

{#drgn_type_is_anonymous}

### drgn_type_is_anonymous

`static` `inline`

```cpp
static inline bool drgn_type_is_anonymous(struct drgn_type * type)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/type.h:513

Get whether a type is anonymous (i.e., the type has no name).

This may be `false` for structure, union, class, and enum types. Otherwise, it is always true.

---

{#drgn_type_is_integer}

### drgn_type_is_integer

```cpp
bool drgn_type_is_integer(struct drgn_type * type)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/type.h:532

Returned whether a [drgn_type](drgn_type.md#drgn_type) is an integer type.

This is true for integer, boolean, and enumerated types, as well typedefs with an underlying type of one of those.

---

{#drgn_type_is_arithmetic}

### drgn_type_is_arithmetic

```cpp
bool drgn_type_is_arithmetic(struct drgn_type * type)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/type.h:540

Return whether a [drgn_type](drgn_type.md#drgn_type) is an arithmetic type.

This is true for integer types (see [drgn_type_is_integer()](#drgn_type_is_integer)) as well as floating-point types and equivalent typedefs.

---

{#drgn_type_is_scalar}

### drgn_type_is_scalar

```cpp
bool drgn_type_is_scalar(struct drgn_type * type)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/type.h:548

Return whether a [drgn_type](drgn_type.md#drgn_type) is a scalar type.

This is true for arithmetic types (see [drgn_type_is_arithmetic()](#drgn_type_is_arithmetic)) as well as pointer types and equivalent typedefs.

---

{#drgn_type_bit_size}

### drgn_type_bit_size

```cpp
struct drgn_error * drgn_type_bit_size(struct drgn_type * type, uint64_t * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/type.h:556

Get the size of a type in bits.

This is the same as multplying the result of [drgn_type_sizeof()](Types.md#drgn_type_sizeof) by 8 except that it handles overflow.

---

{#drgn_dwarf_type_alignment}

### drgn_dwarf_type_alignment

```cpp
struct drgn_error * drgn_dwarf_type_alignment(struct drgn_type * type, uint64_t * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/type.h:559

---

{#drgn_program_init_types}

### drgn_program_init_types

```cpp
void drgn_program_init_types(struct drgn_program * prog)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/type.h:563

Initialize type-related fields in a [drgn_program](drgn_program.md#drgn_program).

---

{#drgn_program_deinit_types}

### drgn_program_deinit_types

```cpp
void drgn_program_deinit_types(struct drgn_program * prog)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/type.h:565

Deinitialize type-related fields in a [drgn_program](drgn_program.md#drgn_program).

---

{#drgn_program_find_type_impl}

### drgn_program_find_type_impl

```cpp
struct drgn_error * drgn_program_find_type_impl(struct drgn_program * prog, uint64_t kinds, const char * name, size_t name_len, const char * filename, struct drgn_qualified_type * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/type.h:583

Find a parsed type in a [drgn_program](drgn_program.md#drgn_program).

This should only be called by implementations of [drgn_language::find_type()](drgn_language.md#find_type)

#### Returns
`NULL` on success, &[drgn_not_found](ErrorHandling.md#drgn_not_found) if the type wasn't found, non-`NULL` on other error.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `name` | `const char *` | Name of the type. |
| `name_len` | `size_t` | Length of `name` in bytes. |
| `filename` | `const char *` | See [drgn_program_find_type()](Programs.md#drgn_program_find_type). |
| `ret` | struct [`drgn_qualified_type`](drgn_qualified_type.md#drgn_qualified_type) * | Returned type. |

---

{#drgn_program_find_primitive_type}

### drgn_program_find_primitive_type

```cpp
struct drgn_error * drgn_program_find_primitive_type(struct drgn_program * prog, enum drgn_primitive_type type, struct drgn_type ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/type.h:591

Find a primitive type in a [drgn_program](drgn_program.md#drgn_program).

## Variables

| Return | Name | Description |
|--------|------|-------------|
| `const char *const` | [`drgn_type_kind_spelling`](#drgn_type_kind_spelling)  | Mapping from [drgn_type_kind](drgn_type_kind.md#drgn_type_kind) to the spelling of that kind. |

---

{#drgn_type_kind_spelling}

### drgn_type_kind_spelling

```cpp
const char *const drgn_type_kind_spelling[]
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/type.h:468

Mapping from [drgn_type_kind](drgn_type_kind.md#drgn_type_kind) to the spelling of that kind.

