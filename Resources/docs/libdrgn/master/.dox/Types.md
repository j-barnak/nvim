{#types}

# Types

Type descriptors.

Types in a program are represented by [drgn_type](drgn_type.md#drgn_type).

Type descriptors have various fields depending on the kind of type. For each field `foo`, there is a `drgn_type_kind_has_foo()` helper which returns whether the given kind of type has the field `foo`; a `drgn_type_has_foo()` helper which does the same but takes a type; and a `drgn_type_foo()` helper which returns the field. For members, enumerators, parameters, and template parameters, there is also a `drgn_type_num_foo()` helper.

## Classes

| Name | Description |
|------|-------------|
| [`drgn_qualified_type`](drgn_qualified_type.md#drgn_qualified_type) | Qualified type. |
| [`drgn_type_member`](drgn_type_member.md#drgn_type_member) | Member of a structure, union, or class type. |
| [`drgn_type_enumerator`](drgn_type_enumerator.md#drgn_type_enumerator) | Value of an enumerated type. |
| [`drgn_type_parameter`](drgn_type_parameter.md#drgn_type_parameter) | Parameter of a function type. |
| [`drgn_type_template_parameter`](drgn_type_template_parameter.md#drgn_type_template_parameter) | Template parameter of a structure, union, class, or function type. |
| [`drgn_type`](drgn_type.md#drgn_type) | Type descriptor. |

## Enumerations

| Name | Description |
|------|-------------|
| [`drgn_type_kind`](#drgn_type_kind)  | Kinds of types. |
| [`drgn_qualifiers`](#drgn_qualifiers)  | Type qualifiers. |
| [`drgn_primitive_type`](#drgn_primitive_type)  | Primitive types known to drgn. |

---

{#drgn_type_kind}

### drgn_type_kind

```cpp
enum drgn_type_kind
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:323

Kinds of types.

Every type in a program supported by libdrgn falls into one of these categories.

---

{#drgn_qualifiers}

### drgn_qualifiers

```cpp
enum drgn_qualifiers
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:358

Type qualifiers.

Some languages, like C, have the notion of qualifiers which add properties to a type. Qualifiers are represented as a bitmask; each qualifier is a bit.

---

{#drgn_primitive_type}

### drgn_primitive_type

```cpp
enum drgn_primitive_type
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:3445

Primitive types known to drgn.

## Functions

| Return | Name | Description |
|--------|------|-------------|
| `bool` | [`drgn_type_kind_has_name`](#drgn_type_kind_has_name) `static` `inline` | Get whether a kind of type has a name. This is true for integer, boolean, floating-point, and typedef types. |
| `bool` | [`drgn_type_has_name`](#drgn_type_has_name) `static` `inline` | Get whether a type has a name. **See also**: drgn_type_kind_has_name() |
| `bool` | [`drgn_type_kind_has_size`](#drgn_type_kind_has_size) `static` `inline` | Get whether a kind of type has a size. This is true for integer, boolean, floating-point, structure, union, class, and pointer types. |
| `bool` | [`drgn_type_has_size`](#drgn_type_has_size) `static` `inline` | Get whether a type has a size. **See also**: drgn_type_kind_has_size() |
| `bool` | [`drgn_type_kind_has_is_signed`](#drgn_type_kind_has_is_signed) `static` `inline` | Get whether a kind of type has a signedness. This is true for integer types. |
| `bool` | [`drgn_type_has_is_signed`](#drgn_type_has_is_signed) `static` `inline` | Get whether a type has a signedness. **See also**: drgn_type_kind_has_is_signed() |
| `bool` | [`drgn_type_kind_has_little_endian`](#drgn_type_kind_has_little_endian) `static` `inline` | Get whether a kind of type has a byte order. This is true for integer, boolean, floating-point, and pointer types. |
| `bool` | [`drgn_type_has_little_endian`](#drgn_type_has_little_endian) `static` `inline` | Get whether a type has a byte order. **See also**: drgn_type_kind_has_little_endian() |
| `bool` | [`drgn_type_kind_has_tag`](#drgn_type_kind_has_tag) `static` `inline` | Get whether a kind of type has a tag. This is true for structure, union, class, and enumerated types. |
| `bool` | [`drgn_type_has_tag`](#drgn_type_has_tag) `static` `inline` | Get whether a type has a tag. **See also**: drgn_type_kind_has_tag() |
| `bool` | [`drgn_type_kind_has_members`](#drgn_type_kind_has_members) `static` `inline` | Get whether a kind of type has members. This is true for structure, union, and class types. |
| `bool` | [`drgn_type_has_members`](#drgn_type_has_members) `static` `inline` | Get whether a type has members. **See also**: drgn_type_kind_has_members() |
| `bool` | [`drgn_type_kind_has_type`](#drgn_type_kind_has_type) `static` `inline` | Get whether a kind of type has a wrapped type. This is true for enumerated, typedef, pointer, array, and function types. |
| `bool` | [`drgn_type_has_type`](#drgn_type_has_type) `static` `inline` | Get whether a type has a wrapped type. **See also**: drgn_type_kind_has_type() |
| `bool` | [`drgn_type_kind_has_enumerators`](#drgn_type_kind_has_enumerators) `static` `inline` | Get whether a kind of type has enumerators. This is true for enumerated types. |
| `bool` | [`drgn_type_has_enumerators`](#drgn_type_has_enumerators) `static` `inline` | Get whether a type has enumerators. **See also**: drgn_type_kind_has_enumerators() |
| `bool` | [`drgn_type_kind_has_length`](#drgn_type_kind_has_length) `static` `inline` | Get whether a kind of type has a length. This is true for array types. |
| `bool` | [`drgn_type_has_length`](#drgn_type_has_length) `static` `inline` | Get whether a type has a length. **See also**: drgn_type_kind_has_length() |
| `bool` | [`drgn_type_kind_has_parameters`](#drgn_type_kind_has_parameters) `static` `inline` | Get whether a kind of type has parameters. This is true for function types. |
| `bool` | [`drgn_type_has_parameters`](#drgn_type_has_parameters) `static` `inline` | Get whether a type has parameters. **See also**: drgn_type_kind_has_parameters() |
| `bool` | [`drgn_type_kind_has_is_variadic`](#drgn_type_kind_has_is_variadic) `static` `inline` | Get whether a kind of type can be variadic. This is true for function types. |
| `bool` | [`drgn_type_has_is_variadic`](#drgn_type_has_is_variadic) `static` `inline` | Get whether a type can be variadic. **See also**: drgn_type_kind_has_is_variadic() |
| `bool` | [`drgn_type_kind_has_template_parameters`](#drgn_type_kind_has_template_parameters) `static` `inline` | Get whether a kind of type can have template parameters. |
| `bool` | [`drgn_type_has_template_parameters`](#drgn_type_has_template_parameters) `static` `inline` | Get whether a type can have template parameters. |
| struct [`drgn_qualified_type`](drgn_qualified_type.md#drgn_qualified_type) | [`drgn_qualified_type_unaliased`](#drgn_qualified_type_unaliased)  | Remove all top-level typedefs from a [drgn_qualified_type](drgn_qualified_type.md#drgn_qualified_type). |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_member_object`](#drgn_member_object)  | Get the object corresponding to a [drgn_type_member](drgn_type_member.md#drgn_type_member). |
| struct [`drgn_error`](drgn_error.md#drgn_error) struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_member_type`](#drgn_member_type)  | Get the type of a [drgn_type_member](drgn_type_member.md#drgn_type_member). |
| struct [`drgn_error`](drgn_error.md#drgn_error) struct [`drgn_error`](drgn_error.md#drgn_error) struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_parameter_default_argument`](#drgn_parameter_default_argument)  | Get the default argument of a [drgn_type_parameter](drgn_type_parameter.md#drgn_type_parameter). |
| struct [`drgn_error`](drgn_error.md#drgn_error) struct [`drgn_error`](drgn_error.md#drgn_error) struct [`drgn_error`](drgn_error.md#drgn_error) struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_parameter_type`](#drgn_parameter_type)  | Get the type of a [drgn_type_parameter](drgn_type_parameter.md#drgn_type_parameter). |
| struct [`drgn_error`](drgn_error.md#drgn_error) struct [`drgn_error`](drgn_error.md#drgn_error) struct [`drgn_error`](drgn_error.md#drgn_error) struct [`drgn_error`](drgn_error.md#drgn_error) struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_template_parameter_type`](#drgn_template_parameter_type)  | Get the type of a [drgn_type_template_parameter](drgn_type_template_parameter.md#drgn_type_template_parameter). |
| struct [`drgn_error`](drgn_error.md#drgn_error) struct [`drgn_error`](drgn_error.md#drgn_error) struct [`drgn_error`](drgn_error.md#drgn_error) struct [`drgn_error`](drgn_error.md#drgn_error) struct [`drgn_error`](drgn_error.md#drgn_error) struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_template_parameter_object`](#drgn_template_parameter_object)  | Get the value of a [drgn_type_template_parameter](drgn_type_template_parameter.md#drgn_type_template_parameter). |
| struct [`drgn_error`](drgn_error.md#drgn_error) struct [`drgn_error`](drgn_error.md#drgn_error) struct [`drgn_error`](drgn_error.md#drgn_error) struct [`drgn_error`](drgn_error.md#drgn_error) struct [`drgn_error`](drgn_error.md#drgn_error) struct [`drgn_error`](drgn_error.md#drgn_error) struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_type_sizeof`](#drgn_type_sizeof)  | Get the size of a type in bytes. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_type_alignof`](#drgn_type_alignof)  | Get the alignment requirement of a type. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_type_offsetof`](#drgn_type_offsetof)  | Get the offset in bytes of a member from the start of a structure, union, or class type. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_type_find_member_len`](#drgn_type_find_member_len)  | Like drgn_type_find_member(), but takes the length of `member_name`. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_type_find_member`](#drgn_type_find_member) `static` `inline` | Find a member in a [drgn_type](drgn_type.md#drgn_type) by name. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_type_has_member_len`](#drgn_type_has_member_len)  | Like drgn_type_has_member(), but takes the length of `member_name`. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_type_has_member`](#drgn_type_has_member) `static` `inline` | Return whether a [drgn_type](drgn_type.md#drgn_type) has a member with the given name. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_type_element_info`](#drgn_type_element_info)  | Get the element type and size of an array or pointer [drgn_type](drgn_type.md#drgn_type). |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_format_type_name`](#drgn_format_type_name)  | Format the name of a type as a string. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_format_type`](#drgn_format_type)  | Format the definition of a type as a string. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_format_variable_declaration`](#drgn_format_variable_declaration)  | Format a variable declaration with the given type and name. |

---

{#drgn_type_kind_has_name}

### drgn_type_kind_has_name

`static` `inline`

```cpp
static inline bool drgn_type_kind_has_name(enum drgn_type_kind kind)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:3565

Get whether a kind of type has a name. This is true for integer, boolean, floating-point, and typedef types.

---

{#drgn_type_has_name}

### drgn_type_has_name

`static` `inline`

```cpp
static inline bool drgn_type_has_name(struct drgn_type * type)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:3573

Get whether a type has a name. **See also**: drgn_type_kind_has_name()

---

{#drgn_type_kind_has_size}

### drgn_type_kind_has_size

`static` `inline`

```cpp
static inline bool drgn_type_kind_has_size(enum drgn_type_kind kind)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:3587

Get whether a kind of type has a size. This is true for integer, boolean, floating-point, structure, union, class, and pointer types.

---

{#drgn_type_has_size}

### drgn_type_has_size

`static` `inline`

```cpp
static inline bool drgn_type_has_size(struct drgn_type * type)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:3598

Get whether a type has a size. **See also**: drgn_type_kind_has_size()

---

{#drgn_type_kind_has_is_signed}

### drgn_type_kind_has_is_signed

`static` `inline`

```cpp
static inline bool drgn_type_kind_has_is_signed(enum drgn_type_kind kind)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:3612

Get whether a kind of type has a signedness. This is true for integer types.

---

{#drgn_type_has_is_signed}

### drgn_type_has_is_signed

`static` `inline`

```cpp
static inline bool drgn_type_has_is_signed(struct drgn_type * type)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:3617

Get whether a type has a signedness. **See also**: drgn_type_kind_has_is_signed()

---

{#drgn_type_kind_has_little_endian}

### drgn_type_kind_has_little_endian

`static` `inline`

```cpp
static inline bool drgn_type_kind_has_little_endian(enum drgn_type_kind kind)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:3632

Get whether a kind of type has a byte order. This is true for integer, boolean, floating-point, and pointer types.

---

{#drgn_type_has_little_endian}

### drgn_type_has_little_endian

`static` `inline`

```cpp
static inline bool drgn_type_has_little_endian(struct drgn_type * type)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:3642

Get whether a type has a byte order. **See also**: drgn_type_kind_has_little_endian()

---

{#drgn_type_kind_has_tag}

### drgn_type_kind_has_tag

`static` `inline`

```cpp
static inline bool drgn_type_kind_has_tag(enum drgn_type_kind kind)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:3659

Get whether a kind of type has a tag. This is true for structure, union, class, and enumerated types.

---

{#drgn_type_has_tag}

### drgn_type_has_tag

`static` `inline`

```cpp
static inline bool drgn_type_has_tag(struct drgn_type * type)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:3667

Get whether a type has a tag. **See also**: drgn_type_kind_has_tag()

---

{#drgn_type_kind_has_members}

### drgn_type_kind_has_members

`static` `inline`

```cpp
static inline bool drgn_type_kind_has_members(enum drgn_type_kind kind)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:3681

Get whether a kind of type has members. This is true for structure, union, and class types.

---

{#drgn_type_has_members}

### drgn_type_has_members

`static` `inline`

```cpp
static inline bool drgn_type_has_members(struct drgn_type * type)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:3688

Get whether a type has members. **See also**: drgn_type_kind_has_members()

---

{#drgn_type_kind_has_type}

### drgn_type_kind_has_type

`static` `inline`

```cpp
static inline bool drgn_type_kind_has_type(enum drgn_type_kind kind)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:3709

Get whether a kind of type has a wrapped type. This is true for enumerated, typedef, pointer, array, and function types.

---

{#drgn_type_has_type}

### drgn_type_has_type

`static` `inline`

```cpp
static inline bool drgn_type_has_type(struct drgn_type * type)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:3718

Get whether a type has a wrapped type. **See also**: drgn_type_kind_has_type()

---

{#drgn_type_kind_has_enumerators}

### drgn_type_kind_has_enumerators

`static` `inline`

```cpp
static inline bool drgn_type_kind_has_enumerators(enum drgn_type_kind kind)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:3743

Get whether a kind of type has enumerators. This is true for enumerated types.

---

{#drgn_type_has_enumerators}

### drgn_type_has_enumerators

`static` `inline`

```cpp
static inline bool drgn_type_has_enumerators(struct drgn_type * type)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:3748

Get whether a type has enumerators. **See also**: drgn_type_kind_has_enumerators()

---

{#drgn_type_kind_has_length}

### drgn_type_kind_has_length

`static` `inline`

```cpp
static inline bool drgn_type_kind_has_length(enum drgn_type_kind kind)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:3766

Get whether a kind of type has a length. This is true for array types.

---

{#drgn_type_has_length}

### drgn_type_has_length

`static` `inline`

```cpp
static inline bool drgn_type_has_length(struct drgn_type * type)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:3771

Get whether a type has a length. **See also**: drgn_type_kind_has_length()

---

{#drgn_type_kind_has_parameters}

### drgn_type_kind_has_parameters

`static` `inline`

```cpp
static inline bool drgn_type_kind_has_parameters(enum drgn_type_kind kind)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:3785

Get whether a kind of type has parameters. This is true for function types.

---

{#drgn_type_has_parameters}

### drgn_type_has_parameters

`static` `inline`

```cpp
static inline bool drgn_type_has_parameters(struct drgn_type * type)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:3790

Get whether a type has parameters. **See also**: drgn_type_kind_has_parameters()

---

{#drgn_type_kind_has_is_variadic}

### drgn_type_kind_has_is_variadic

`static` `inline`

```cpp
static inline bool drgn_type_kind_has_is_variadic(enum drgn_type_kind kind)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:3810

Get whether a kind of type can be variadic. This is true for function types.

---

{#drgn_type_has_is_variadic}

### drgn_type_has_is_variadic

`static` `inline`

```cpp
static inline bool drgn_type_has_is_variadic(struct drgn_type * type)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:3815

Get whether a type can be variadic. **See also**: drgn_type_kind_has_is_variadic()

---

{#drgn_type_kind_has_template_parameters}

### drgn_type_kind_has_template_parameters

`static` `inline`

```cpp
static inline bool drgn_type_kind_has_template_parameters(enum drgn_type_kind kind)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:3828

Get whether a kind of type can have template parameters.

---

{#drgn_type_has_template_parameters}

### drgn_type_has_template_parameters

`static` `inline`

```cpp
static inline bool drgn_type_has_template_parameters(struct drgn_type * type)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:3836

Get whether a type can have template parameters.

---

{#drgn_qualified_type_unaliased}

### drgn_qualified_type_unaliased

```cpp
struct drgn_qualified_type drgn_qualified_type_unaliased(struct drgn_qualified_type qualified_type)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:3856

Remove all top-level typedefs from a [drgn_qualified_type](drgn_qualified_type.md#drgn_qualified_type).

---

{#drgn_member_object}

### drgn_member_object

```cpp
struct drgn_error * drgn_member_object(struct drgn_type_member * member, const struct drgn_object ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:3865

Get the object corresponding to a [drgn_type_member](drgn_type_member.md#drgn_type_member).

#### Returns
`NULL` on success, non-`NULL` on error.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `member` | struct [`drgn_type_member`](drgn_type_member.md#drgn_type_member) * | Member. |
| `ret` | const struct [`drgn_object`](drgn_object.md#drgn_object-1) ** | Returned object. |

---

{#drgn_member_type}

### drgn_member_type

```cpp
struct drgn_error struct drgn_error * drgn_member_type(struct drgn_type_member * member, struct drgn_qualified_type * type_ret, uint64_t * bit_field_size_ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:3878

Get the type of a [drgn_type_member](drgn_type_member.md#drgn_type_member).

#### Returns
`NULL` on success, non-`NULL` on error.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `member` | struct [`drgn_type_member`](drgn_type_member.md#drgn_type_member) * | Member. |
| `type_ret` | struct [`drgn_qualified_type`](drgn_qualified_type.md#drgn_qualified_type) * | Returned type. |
| `bit_field_size_ret` | `uint64_t *` | If the member is a bit field, returned size of the field in bits. Otherwise, returned as 0. Can be `NULL` if not needed. |

---

{#drgn_parameter_default_argument}

### drgn_parameter_default_argument

```cpp
struct drgn_error struct drgn_error struct drgn_error * drgn_parameter_default_argument(struct drgn_type_parameter * parameter, const struct drgn_object ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:3891

Get the default argument of a [drgn_type_parameter](drgn_type_parameter.md#drgn_type_parameter).

#### Returns
`NULL` on success, non-`NULL` on error.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `parameter` | struct [`drgn_type_parameter`](drgn_type_parameter.md#drgn_type_parameter) * | Parameter. |
| `ret` | const struct [`drgn_object`](drgn_object.md#drgn_object-1) ** | Returned object. |

---

{#drgn_parameter_type}

### drgn_parameter_type

```cpp
struct drgn_error struct drgn_error struct drgn_error struct drgn_error * drgn_parameter_type(struct drgn_type_parameter * parameter, struct drgn_qualified_type * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:3902

Get the type of a [drgn_type_parameter](drgn_type_parameter.md#drgn_type_parameter).

#### Returns
`NULL` on success, non-`NULL` on error.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `parameter` | struct [`drgn_type_parameter`](drgn_type_parameter.md#drgn_type_parameter) * | Parameter. |
| `ret` | struct [`drgn_qualified_type`](drgn_qualified_type.md#drgn_qualified_type) * | Returned type. |

---

{#drgn_template_parameter_type}

### drgn_template_parameter_type

```cpp
struct drgn_error struct drgn_error struct drgn_error struct drgn_error struct drgn_error * drgn_template_parameter_type(struct drgn_type_template_parameter * parameter, struct drgn_qualified_type * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:3917

Get the type of a [drgn_type_template_parameter](drgn_type_template_parameter.md#drgn_type_template_parameter).

If the template parameter is a non-type template parameter, this is the type of its value.

#### Returns
`NULL` on success, non-`NULL` on error.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `parameter` | struct [`drgn_type_template_parameter`](drgn_type_template_parameter.md#drgn_type_template_parameter) * | Template parameter. |
| `ret` | struct [`drgn_qualified_type`](drgn_qualified_type.md#drgn_qualified_type) * | Returned type. |

---

{#drgn_template_parameter_object}

### drgn_template_parameter_object

```cpp
struct drgn_error struct drgn_error struct drgn_error struct drgn_error struct drgn_error struct drgn_error * drgn_template_parameter_object(struct drgn_type_template_parameter * parameter, const struct drgn_object ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:3930

Get the value of a [drgn_type_template_parameter](drgn_type_template_parameter.md#drgn_type_template_parameter).

#### Returns
`NULL` on success, non-`NULL` on error.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `parameter` | struct [`drgn_type_template_parameter`](drgn_type_template_parameter.md#drgn_type_template_parameter) * | Template parameter. |
| `ret` | const struct [`drgn_object`](drgn_object.md#drgn_object-1) ** | Returned object. If `parameter` is a type template parameter, this is returned as `NULL`. |

---

{#drgn_type_sizeof}

### drgn_type_sizeof

```cpp
struct drgn_error struct drgn_error struct drgn_error struct drgn_error struct drgn_error struct drgn_error struct drgn_error * drgn_type_sizeof(struct drgn_type * type, uint64_t * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:3945

Get the size of a type in bytes.

Unlike [drgn_type_size()](#group__Types_1gafb3c449077486e735b3cfe729b043d36), this is applicable to any type which has a meaningful size, including typedefs and arrays. Void, function, and incomplete types do not have a size; an error is returned for those types.

#### Returns
`NULL` on success, non-`NULL` on error.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `type` | struct [`drgn_type`](drgn_type.md#drgn_type) * | Type. |
| `ret` | `uint64_t *` | Returned size. |

---

{#drgn_type_alignof}

### drgn_type_alignof

```cpp
struct drgn_error * drgn_type_alignof(struct drgn_qualified_type qualified_type, uint64_t * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:3956

Get the alignment requirement of a type.

This corresponds to `_Alignof()` in C.

#### Returns
`NULL` on success, non-`NULL` on error.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `ret` | `uint64_t *` | Returned alignment. |

---

{#drgn_type_offsetof}

### drgn_type_offsetof

```cpp
struct drgn_error * drgn_type_offsetof(struct drgn_type * type, const char * member_designator, uint64_t * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:3969

Get the offset in bytes of a member from the start of a structure, union, or class type.

This corresponds to `offsetof()` in C.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `type` | struct [`drgn_type`](drgn_type.md#drgn_type) * | Type which contains the member. |
| `member_designator` | `const char *` | Name of the member in `type`. This can include one or more member references and zero or more array subscripts. |

---

{#drgn_type_find_member_len}

### drgn_type_find_member_len

```cpp
struct drgn_error * drgn_type_find_member_len(struct drgn_type * type, const char * member_name, size_t member_name_len, struct drgn_type_member ** member_ret, uint64_t * bit_offset_ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:3977

Like drgn_type_find_member(), but takes the length of `member_name`.

---

{#drgn_type_find_member}

### drgn_type_find_member

`static` `inline`

```cpp
static inline struct drgn_error * drgn_type_find_member(struct drgn_type * type, const char * member_name, struct drgn_type_member ** member_ret, uint64_t * bit_offset_ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:3997

Find a member in a [drgn_type](drgn_type.md#drgn_type) by name.

If the type has any unnamed members, this also matches members of those unnamed members, recursively.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `type` | struct [`drgn_type`](drgn_type.md#drgn_type) * | Structure, union, or class type. |
| `member_name` | `const char *` | Name of member. |
| `member_ret` | struct [`drgn_type_member`](drgn_type_member.md#drgn_type_member) ** | Returned member. |
| `bit_offset_ret` | `uint64_t *` | Returned offset in bits from the beginning of `type` to the beginning of the member. This can be different from [drgn_type_member::bit_offset](drgn_type_member.md#bit_offset) if the returned member was found in an unnamed member of `type`. |

---

{#drgn_type_has_member_len}

### drgn_type_has_member_len

```cpp
struct drgn_error * drgn_type_has_member_len(struct drgn_type * type, const char * member_name, size_t member_name_len, bool * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:4006

Like drgn_type_has_member(), but takes the length of `member_name`.

---

{#drgn_type_has_member}

### drgn_type_has_member

`static` `inline`

```cpp
static inline struct drgn_error * drgn_type_has_member(struct drgn_type * type, const char * member_name, bool * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:4016

Return whether a [drgn_type](drgn_type.md#drgn_type) has a member with the given name.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `type` | struct [`drgn_type`](drgn_type.md#drgn_type) * | Structure, union, or class type. |
| `member_name` | `const char *` | Name of member. |

---

{#drgn_type_element_info}

### drgn_type_element_info

```cpp
struct drgn_error * drgn_type_element_info(struct drgn_type * type, bool * is_pointer_ret, struct drgn_qualified_type * element_type_ret, uint64_t * element_bit_size_ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:4035

Get the element type and size of an array or pointer [drgn_type](drgn_type.md#drgn_type).

#### Returns
`NULL` on success, non-`NULL` on error.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `type` | struct [`drgn_type`](drgn_type.md#drgn_type) * | Array or pointer type. |
| `is_pointer_ret` | `bool *` | Whether `type` is a pointer type. |
| `element_type_ret` | struct [`drgn_qualified_type`](drgn_qualified_type.md#drgn_qualified_type) * | Returned element type. |
| `element_bit_size_ret` | `uint64_t *` | Returned size in bits of one element. Element `i` is at bit offset `i * bit_size`. |

---

{#drgn_format_type_name}

### drgn_format_type_name

```cpp
struct drgn_error * drgn_format_type_name(struct drgn_qualified_type qualified_type, char ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:4051

Format the name of a type as a string.

This will format the name of the type as it would be referred to in its programming language.

#### Returns
`NULL` on success, non-`NULL` on error.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `qualified_type` | struct [`drgn_qualified_type`](drgn_qualified_type.md#drgn_qualified_type) | Type to format. |
| `ret` | `char **` | Returned string. On success, it must be freed with `free()`. On error, it is not modified. |

---

{#drgn_format_type}

### drgn_format_type

```cpp
struct drgn_error * drgn_format_type(struct drgn_qualified_type qualified_type, char ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:4063

Format the definition of a type as a string.

This will format the type as it would be defined in its programming language.

#### Returns
`NULL` on success, non-`NULL` on error.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `qualified_type` | struct [`drgn_qualified_type`](drgn_qualified_type.md#drgn_qualified_type) | Type to format. |
| `ret` | `char **` | Returned string. On success, it must be freed with `free()`. On error, it is not modified. |

---

{#drgn_format_variable_declaration}

### drgn_format_variable_declaration

```cpp
struct drgn_error * drgn_format_variable_declaration(struct drgn_qualified_type qualified_type, const char * name, char ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:4080

Format a variable declaration with the given type and name.

This will format the variable as it would be declared in its programming language.

#### Returns
`NULL` on success, non-`NULL` on error.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `qualified_type` | struct [`drgn_qualified_type`](drgn_qualified_type.md#drgn_qualified_type) | Variable type. |
| `name` | `const char *` | Variable name. |
| `ret` | `char **` | Returned string. On success, it must be freed with `free()`. On error, it is not modified. |

## Variables

| Return | Name | Description |
|--------|------|-------------|
| struct [`drgn_qualified_type`](drgn_qualified_type.md#drgn_qualified_type) | [`__attribute__`](#__attribute__)  |  |

---

{#__attribute__}

### __attribute__

```cpp
struct drgn_qualified_type __attribute__
```

Type: struct [`drgn_qualified_type`](drgn_qualified_type.md#drgn_qualified_type)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:385

