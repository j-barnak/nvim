{#typecreation}

# Type creation

> [`Internals`](Internals.md#internals) / [`Types`](TypeInternals.md#types-1)

Creating type descriptors.

These functions create type descriptors. They are valid for the lifetime of the program that owns them.

A few kinds of types have variable-length fields: structure, union, and class types have members, enumerated types have enumerators, and function types have parameters. These fields are constructed with a *builder* before creating the type.

## Classes

| Name | Description |
|------|-------------|
| [`drgn_template_parameters_builder`](drgn_template_parameters_builder.md#drgn_template_parameters_builder) | Common builder shared between compound and function types for template parameters. |
| [`drgn_compound_type_builder`](drgn_compound_type_builder.md#drgn_compound_type_builder) | Builder for members of a structure, union, or class type. |
| [`drgn_enum_type_builder`](drgn_enum_type_builder.md#drgn_enum_type_builder) | Builder for enumerators of an enumerated type. |
| [`drgn_function_type_builder`](drgn_function_type_builder.md#drgn_function_type_builder) | Builder for parameters of a function type. |

## Functions

| Return | Name | Description |
|--------|------|-------------|
| struct [`drgn_type`](drgn_type.md#drgn_type) * | [`drgn_void_type`](#drgn_void_type)  | Get the void type for the given [drgn_language](drgn_language.md#drgn_language). |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_int_type_create`](#drgn_int_type_create)  | Create an integer type. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_bool_type_create`](#drgn_bool_type_create)  | Create a boolean type. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_float_type_create`](#drgn_float_type_create)  | Create a floating-point type. |
|  | [`DEFINE_VECTOR_TYPE`](#define_vector_type-4)  |  |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_template_parameters_builder_add`](#drgn_template_parameters_builder_add)  | Add a [drgn_type_template_parameter](drgn_type_template_parameter.md#drgn_type_template_parameter) to a [drgn_template_parameters_builder](drgn_template_parameters_builder.md#drgn_template_parameters_builder). |
|  | [`DEFINE_VECTOR_TYPE`](#define_vector_type-5)  |  |
| `void` | [`drgn_compound_type_builder_init`](#drgn_compound_type_builder_init)  | Initialize a [drgn_compound_type_builder](drgn_compound_type_builder.md#drgn_compound_type_builder). |
| `void` | [`drgn_compound_type_builder_deinit`](#drgn_compound_type_builder_deinit)  | Deinitialize a [drgn_compound_type_builder](drgn_compound_type_builder.md#drgn_compound_type_builder). |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_compound_type_builder_add_member`](#drgn_compound_type_builder_add_member)  | Add a [drgn_type_member](drgn_type_member.md#drgn_type_member) to a [drgn_compound_type_builder](drgn_compound_type_builder.md#drgn_compound_type_builder). |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_compound_type_create`](#drgn_compound_type_create)  | Create a structure, union, or class type. |
|  | [`DEFINE_VECTOR_TYPE`](#define_vector_type-6)  |  |
| `void` | [`drgn_enum_type_builder_init`](#drgn_enum_type_builder_init)  | Initialize a [drgn_enum_type_builder](drgn_enum_type_builder.md#drgn_enum_type_builder). |
| `void` | [`drgn_enum_type_builder_deinit`](#drgn_enum_type_builder_deinit)  | Deinitialize a [drgn_enum_type_builder](drgn_enum_type_builder.md#drgn_enum_type_builder). |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_enum_type_builder_add_signed`](#drgn_enum_type_builder_add_signed)  | Add a [drgn_type_enumerator](drgn_type_enumerator.md#drgn_type_enumerator) with a signed value to a [drgn_enum_type_builder](drgn_enum_type_builder.md#drgn_enum_type_builder). |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_enum_type_builder_add_unsigned`](#drgn_enum_type_builder_add_unsigned)  | Add a [drgn_type_enumerator](drgn_type_enumerator.md#drgn_type_enumerator) with an unsigned value to a [drgn_enum_type_builder](drgn_enum_type_builder.md#drgn_enum_type_builder). |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_enum_type_create`](#drgn_enum_type_create)  | Create an enumerated type. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_incomplete_enum_type_create`](#drgn_incomplete_enum_type_create)  | Create an incomplete enumerated type. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_typedef_type_create`](#drgn_typedef_type_create)  | Create a typedef type. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_pointer_type_create`](#drgn_pointer_type_create)  | Create a pointer type. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_array_type_create`](#drgn_array_type_create)  | Create an array type. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_incomplete_array_type_create`](#drgn_incomplete_array_type_create)  | Create an incomplete array type. |
|  | [`DEFINE_VECTOR_TYPE`](#define_vector_type-7)  |  |
| `void` | [`drgn_function_type_builder_init`](#drgn_function_type_builder_init)  | Initialize a [drgn_function_type_builder](drgn_function_type_builder.md#drgn_function_type_builder). |
| `void` | [`drgn_function_type_builder_deinit`](#drgn_function_type_builder_deinit)  | Deinitialize a [drgn_function_type_builder](drgn_function_type_builder.md#drgn_function_type_builder). |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_function_type_builder_add_parameter`](#drgn_function_type_builder_add_parameter)  | Add a [drgn_type_parameter](drgn_type_parameter.md#drgn_type_parameter) to a [drgn_function_type_builder](drgn_function_type_builder.md#drgn_function_type_builder). |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_function_type_create`](#drgn_function_type_create)  | Create a function type. |

---

{#drgn_void_type}

### drgn_void_type

```cpp
struct drgn_type * drgn_void_type(struct drgn_program * prog, const struct drgn_language * lang)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/type.h:118

Get the void type for the given [drgn_language](drgn_language.md#drgn_language).

The void type does not have any fields, so a program has a single type descriptor per language to represent it. This function cannot fail.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `prog` | struct [`drgn_program`](drgn_program.md#drgn_program) * | [Program](Program.md#program) owning type. |
| `lang` | const struct [`drgn_language`](drgn_language.md#drgn_language) * | [Language](Language.md#language) of the type or `NULL` for the default language of `prog`. |

---

{#drgn_int_type_create}

### drgn_int_type_create

```cpp
struct drgn_error * drgn_int_type_create(struct drgn_program * prog, const char * name, uint64_t size, bool is_signed, enum drgn_byte_order byte_order, const struct drgn_language * lang, struct drgn_type ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/type.h:134

Create an integer type.

#### Returns
`NULL` on success, non-`NULL` on error.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `prog` | struct [`drgn_program`](drgn_program.md#drgn_program) * | [Program](Program.md#program) owning type. |
| `name` | `const char *` | Name of the type. Not copied; must remain valid for the lifetime of `prog`. Must not be `NULL`. |
| `size` | `uint64_t` | Size of the type in bytes. |
| `is_signed` | `bool` | Whether the type is signed. |
| `lang` | const struct [`drgn_language`](drgn_language.md#drgn_language) * | [Language](Language.md#language) of the type or `NULL` for the default language of `prog`. |
| `ret` | struct [`drgn_type`](drgn_type.md#drgn_type) ** | Returned type. |

---

{#drgn_bool_type_create}

### drgn_bool_type_create

```cpp
struct drgn_error * drgn_bool_type_create(struct drgn_program * prog, const char * name, uint64_t size, enum drgn_byte_order byte_order, const struct drgn_language * lang, struct drgn_type ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/type.h:153

Create a boolean type.

#### Returns
`NULL` on success, non-`NULL` on error.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `prog` | struct [`drgn_program`](drgn_program.md#drgn_program) * | [Program](Program.md#program) owning type. |
| `name` | `const char *` | Name of the type. Not copied; must remain valid for the lifetime of `prog`. Must not be `NULL`. |
| `size` | `uint64_t` | Size of the type in bytes. |
| `lang` | const struct [`drgn_language`](drgn_language.md#drgn_language) * | [Language](Language.md#language) of the type or `NULL` for the default language of `prog`. |
| `ret` | struct [`drgn_type`](drgn_type.md#drgn_type) ** | Returned type. |

---

{#drgn_float_type_create}

### drgn_float_type_create

```cpp
struct drgn_error * drgn_float_type_create(struct drgn_program * prog, const char * name, uint64_t size, enum drgn_byte_order byte_order, const struct drgn_language * lang, struct drgn_type ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/type.h:171

Create a floating-point type.

#### Returns
`NULL` on success, non-`NULL` on error.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `prog` | struct [`drgn_program`](drgn_program.md#drgn_program) * | [Program](Program.md#program) owning type. |
| `name` | `const char *` | Name of the type. Not copied; must remain valid for the lifetime of `prog`. Must not be `NULL`. |
| `size` | `uint64_t` | Size of the type in bytes. |
| `lang` | const struct [`drgn_language`](drgn_language.md#drgn_language) * | [Language](Language.md#language) of the type or `NULL` for the default language of `prog`. |
| `ret` | struct [`drgn_type`](drgn_type.md#drgn_type) ** | Returned type. |

---

{#define_vector_type-4}

### DEFINE_VECTOR_TYPE

```cpp
DEFINE_VECTOR_TYPE(drgn_type_template_parameter_vector, struct drgn_type_template_parameter)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/type.h:177

---

{#drgn_template_parameters_builder_add}

### drgn_template_parameters_builder_add

```cpp
struct drgn_error * drgn_template_parameters_builder_add(struct drgn_template_parameters_builder * builder, const union drgn_lazy_object * argument, const char * name, bool is_default)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/type.h:196

Add a [drgn_type_template_parameter](drgn_type_template_parameter.md#drgn_type_template_parameter) to a [drgn_template_parameters_builder](drgn_template_parameters_builder.md#drgn_template_parameters_builder).

On success, `builder` takes ownership of `argument`.

---

{#define_vector_type-5}

### DEFINE_VECTOR_TYPE

```cpp
DEFINE_VECTOR_TYPE(drgn_type_member_vector, struct drgn_type_member)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/type.h:200

---

{#drgn_compound_type_builder_init}

### drgn_compound_type_builder_init

```cpp
void drgn_compound_type_builder_init(struct drgn_compound_type_builder * builder, struct drgn_program * prog, enum drgn_type_kind kind)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/type.h:215

Initialize a [drgn_compound_type_builder](drgn_compound_type_builder.md#drgn_compound_type_builder).

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `kind` | enum [`drgn_type_kind`](drgn_type_kind.md#drgn_type_kind) | One of [DRGN_TYPE_STRUCT](api.md#drgn_type_struct), [DRGN_TYPE_UNION](api.md#drgn_type_union), or [DRGN_TYPE_CLASS](api.md#drgn_type_class). |

---

{#drgn_compound_type_builder_deinit}

### drgn_compound_type_builder_deinit

```cpp
void drgn_compound_type_builder_deinit(struct drgn_compound_type_builder * builder)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/type.h:225

Deinitialize a [drgn_compound_type_builder](drgn_compound_type_builder.md#drgn_compound_type_builder).

No-op if [drgn_compound_type_create()](#drgn_compound_type_create) succeeded.

---

{#drgn_compound_type_builder_add_member}

### drgn_compound_type_builder_add_member

```cpp
struct drgn_error * drgn_compound_type_builder_add_member(struct drgn_compound_type_builder * builder, const union drgn_lazy_object * object, const char * name, uint64_t bit_offset)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/type.h:233

Add a [drgn_type_member](drgn_type_member.md#drgn_type_member) to a [drgn_compound_type_builder](drgn_compound_type_builder.md#drgn_compound_type_builder).

On success, `builder` takes ownership of `object`.

---

{#drgn_compound_type_create}

### drgn_compound_type_create

```cpp
struct drgn_error * drgn_compound_type_create(struct drgn_compound_type_builder * builder, const char * tag, uint64_t size, bool is_complete, const struct drgn_language * lang, struct drgn_type ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/type.h:257

Create a structure, union, or class type.

On success, this takes ownership of `builder`.

#### Returns
`NULL` on success, non-`NULL` on error.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `builder` | struct [`drgn_compound_type_builder`](drgn_compound_type_builder.md#drgn_compound_type_builder) * | Builder containing members and template parameters. `object/`argument` and``name` of each member and template parameter must remain valid for the lifetime of `prog`. If incomplete, must not contain any members. |
| `tag` | `const char *` | Name of the type. Not copied; must remain valid for the lifetime of `prog`. May be `NULL` if the type is anonymous. |
| `size` | `uint64_t` | Size of the type in bytes. Must be zero if the type is incomplete. |
| `is_complete` | `bool` | Whether the type is complete. |
| `lang` | const struct [`drgn_language`](drgn_language.md#drgn_language) * | [Language](Language.md#language) of the type or `NULL` for the default language of `prog`. |
| `ret` | struct [`drgn_type`](drgn_type.md#drgn_type) ** | Returned type. |

---

{#define_vector_type-6}

### DEFINE_VECTOR_TYPE

```cpp
DEFINE_VECTOR_TYPE(drgn_type_enumerator_vector, struct drgn_type_enumerator)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/type.h:262

---

{#drgn_enum_type_builder_init}

### drgn_enum_type_builder_init

```cpp
void drgn_enum_type_builder_init(struct drgn_enum_type_builder * builder, struct drgn_program * prog)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/type.h:271

Initialize a [drgn_enum_type_builder](drgn_enum_type_builder.md#drgn_enum_type_builder).

---

{#drgn_enum_type_builder_deinit}

### drgn_enum_type_builder_deinit

```cpp
void drgn_enum_type_builder_deinit(struct drgn_enum_type_builder * builder)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/type.h:279

Deinitialize a [drgn_enum_type_builder](drgn_enum_type_builder.md#drgn_enum_type_builder).

No-op if [drgn_enum_type_create()](#drgn_enum_type_create) succeeded.

---

{#drgn_enum_type_builder_add_signed}

### drgn_enum_type_builder_add_signed

```cpp
struct drgn_error * drgn_enum_type_builder_add_signed(struct drgn_enum_type_builder * builder, const char * name, int64_t svalue)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/type.h:286

Add a [drgn_type_enumerator](drgn_type_enumerator.md#drgn_type_enumerator) with a signed value to a [drgn_enum_type_builder](drgn_enum_type_builder.md#drgn_enum_type_builder).

---

{#drgn_enum_type_builder_add_unsigned}

### drgn_enum_type_builder_add_unsigned

```cpp
struct drgn_error * drgn_enum_type_builder_add_unsigned(struct drgn_enum_type_builder * builder, const char * name, uint64_t uvalue)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/type.h:294

Add a [drgn_type_enumerator](drgn_type_enumerator.md#drgn_type_enumerator) with an unsigned value to a [drgn_enum_type_builder](drgn_enum_type_builder.md#drgn_enum_type_builder).

---

{#drgn_enum_type_create}

### drgn_enum_type_create

```cpp
struct drgn_error * drgn_enum_type_create(struct drgn_enum_type_builder * builder, const char * tag, struct drgn_type * compatible_type, const struct drgn_language * lang, struct drgn_type ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/type.h:313

Create an enumerated type.

On success, this takes ownership of `builder`.

#### Returns
`NULL` on success, non-`NULL` on error.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `builder` | struct [`drgn_enum_type_builder`](drgn_enum_type_builder.md#drgn_enum_type_builder) * | Builder containing enumerators. `name` of each enumerator must remain valid for the lifetime of `builder->prog`. |
| `tag` | `const char *` | Name of the type. This string is not copied. It may be `NULL` if the type is anonymous. |
| `compatible_type` | struct [`drgn_type`](drgn_type.md#drgn_type) * | Type compatible with this enumerated type. Must be an integer type. |
| `lang` | const struct [`drgn_language`](drgn_language.md#drgn_language) * | [Language](Language.md#language) of the type or `NULL` for the default language of `builder->prog`. |
| `ret` | struct [`drgn_type`](drgn_type.md#drgn_type) ** | Returned type. |

---

{#drgn_incomplete_enum_type_create}

### drgn_incomplete_enum_type_create

```cpp
struct drgn_error * drgn_incomplete_enum_type_create(struct drgn_program * prog, const char * tag, const struct drgn_language * lang, struct drgn_type ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/type.h:333

Create an incomplete enumerated type.

`compatible_type` is set to `NULL` and `num_enumerators` is set to zero.

#### Returns
`NULL` on success, non-`NULL` on error.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `prog` | struct [`drgn_program`](drgn_program.md#drgn_program) * | [Program](Program.md#program) owning type. |
| `tag` | `const char *` | Name of the type. Not copied; must remain valid for the lifetime of `prog`. May be `NULL` if the type is anonymous. |
| `lang` | const struct [`drgn_language`](drgn_language.md#drgn_language) * | [Language](Language.md#language) of the type or `NULL` for the default language of `prog`. |
| `ret` | struct [`drgn_type`](drgn_type.md#drgn_type) ** | Returned type. |

---

{#drgn_typedef_type_create}

### drgn_typedef_type_create

```cpp
struct drgn_error * drgn_typedef_type_create(struct drgn_program * prog, const char * name, struct drgn_qualified_type aliased_type, const struct drgn_language * lang, struct drgn_type ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/type.h:350

Create a typedef type.

#### Returns
`NULL` on success, non-`NULL` on error.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `prog` | struct [`drgn_program`](drgn_program.md#drgn_program) * | [Program](Program.md#program) owning type. |
| `name` | `const char *` | Name of the type. Not copied; must remain valid for the lifetime of `prog`. Must not be `NULL`. |
| `aliased_type` | struct [`drgn_qualified_type`](drgn_qualified_type.md#drgn_qualified_type) | Type aliased by the typedef. |
| `lang` | const struct [`drgn_language`](drgn_language.md#drgn_language) * | [Language](Language.md#language) of the type or `NULL` for the default language of `prog`. |
| `ret` | struct [`drgn_type`](drgn_type.md#drgn_type) ** | Returned type. |

---

{#drgn_pointer_type_create}

### drgn_pointer_type_create

```cpp
struct drgn_error * drgn_pointer_type_create(struct drgn_program * prog, struct drgn_qualified_type referenced_type, uint64_t size, enum drgn_byte_order byte_order, const struct drgn_language * lang, struct drgn_type ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/type.h:367

Create a pointer type.

#### Returns
`NULL` on success, non-`NULL` on error.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `prog` | struct [`drgn_program`](drgn_program.md#drgn_program) * | [Program](Program.md#program) owning type. |
| `referenced_type` | struct [`drgn_qualified_type`](drgn_qualified_type.md#drgn_qualified_type) | Type referenced by the pointer type. |
| `size` | `uint64_t` | Size of the type in bytes. |
| `lang` | const struct [`drgn_language`](drgn_language.md#drgn_language) * | [Language](Language.md#language) of the type or `NULL` for the default language of `prog`. |
| `ret` | struct [`drgn_type`](drgn_type.md#drgn_type) ** | Returned type. |

---

{#drgn_array_type_create}

### drgn_array_type_create

```cpp
struct drgn_error * drgn_array_type_create(struct drgn_program * prog, struct drgn_qualified_type element_type, uint64_t length, const struct drgn_language * lang, struct drgn_type ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/type.h:385

Create an array type.

#### Returns
`NULL` on success, non-`NULL` on error.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `prog` | struct [`drgn_program`](drgn_program.md#drgn_program) * | [Program](Program.md#program) owning type. |
| `element_type` | struct [`drgn_qualified_type`](drgn_qualified_type.md#drgn_qualified_type) | Type of an element in the array type. |
| `length` | `uint64_t` | Number of elements in the array type. |
| `lang` | const struct [`drgn_language`](drgn_language.md#drgn_language) * | [Language](Language.md#language) of the type or `NULL` for the default language of `prog`. |
| `ret` | struct [`drgn_type`](drgn_type.md#drgn_type) ** | Returned type. |

---

{#drgn_incomplete_array_type_create}

### drgn_incomplete_array_type_create

```cpp
struct drgn_error * drgn_incomplete_array_type_create(struct drgn_program * prog, struct drgn_qualified_type element_type, const struct drgn_language * lang, struct drgn_type ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/type.h:403

Create an incomplete array type.

`length` is set to zero.

#### Returns
`NULL` on success, non-`NULL` on error.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `prog` | struct [`drgn_program`](drgn_program.md#drgn_program) * | [Program](Program.md#program) owning type. |
| `element_type` | struct [`drgn_qualified_type`](drgn_qualified_type.md#drgn_qualified_type) | Type of an element in the array type. |
| `lang` | const struct [`drgn_language`](drgn_language.md#drgn_language) * | [Language](Language.md#language) of the type or `NULL` for the default language of `prog`. |
| `ret` | struct [`drgn_type`](drgn_type.md#drgn_type) ** | Returned type. |

---

{#define_vector_type-7}

### DEFINE_VECTOR_TYPE

```cpp
DEFINE_VECTOR_TYPE(drgn_type_parameter_vector, struct drgn_type_parameter)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/type.h:408

---

{#drgn_function_type_builder_init}

### drgn_function_type_builder_init

```cpp
void drgn_function_type_builder_init(struct drgn_function_type_builder * builder, struct drgn_program * prog)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/type.h:417

Initialize a [drgn_function_type_builder](drgn_function_type_builder.md#drgn_function_type_builder).

---

{#drgn_function_type_builder_deinit}

### drgn_function_type_builder_deinit

```cpp
void drgn_function_type_builder_deinit(struct drgn_function_type_builder * builder)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/type.h:426

Deinitialize a [drgn_function_type_builder](drgn_function_type_builder.md#drgn_function_type_builder).

No-op if [drgn_function_type_create()](#drgn_function_type_create) succeeded.

---

{#drgn_function_type_builder_add_parameter}

### drgn_function_type_builder_add_parameter

```cpp
struct drgn_error * drgn_function_type_builder_add_parameter(struct drgn_function_type_builder * builder, const union drgn_lazy_object * default_argument, const char * name)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/type.h:434

Add a [drgn_type_parameter](drgn_type_parameter.md#drgn_type_parameter) to a [drgn_function_type_builder](drgn_function_type_builder.md#drgn_function_type_builder).

On success, `builder` takes ownership of `default_argument`.

---

{#drgn_function_type_create}

### drgn_function_type_create

```cpp
struct drgn_error * drgn_function_type_create(struct drgn_function_type_builder * builder, struct drgn_qualified_type return_type, bool is_variadic, const struct drgn_language * lang, struct drgn_type ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/type.h:454

Create a function type.

On success, this takes ownership of `builder`.

#### Returns
`NULL` on success, non-`NULL` on error.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `builder` | struct [`drgn_function_type_builder`](drgn_function_type_builder.md#drgn_function_type_builder) * | Builder containing parameters and template parameters. `default_argument/`argument` and``name` of each parameter and template parameter must remain valid for the lifetime of `prog`. |
| `return_type` | struct [`drgn_qualified_type`](drgn_qualified_type.md#drgn_qualified_type) | Type returned by the function type. |
| `is_variadic` | `bool` | Whether the function type is variadic. |
| `lang` | const struct [`drgn_language`](drgn_language.md#drgn_language) * | [Language](Language.md#language) of the type or `NULL` for the default language of `prog`. |
| `ret` | struct [`drgn_type`](drgn_type.md#drgn_type) ** | Returned type. |

