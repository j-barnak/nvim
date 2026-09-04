{#languages-1}

# Languages

> [`Internals`](Internals.md#internals)

[Language](Language.md#language) support.

This defines the interface which support for a language must implement, including operators and parsing.

To add a new language:

* Add a [drgn_language_number](drgn_language_number.md#drgn_language_number) for it.
* Define a [drgn_language](drgn_language.md#drgn_language) for it, and set [drgn_language::number](drgn_language.md#number) to the corresponding [drgn_language_number](drgn_language_number.md#drgn_language_number).
* Add it to [drgn.h](#drgnh).
* Add it to [drgn_languages](#drgn_languages).
* Add it to [add_languages()](api.md#add_languages) in the Python bindings.
* Add it to _drgn.pyi.

## Classes

| Name | Description |
|------|-------------|
| [`drgn_language`](drgn_language.md#drgn_language) | [Language](Language.md#language) implementation. |

## Macros

| Name | Description |
|------|-------------|
| [`drgn_default_language`](#drgn_default_language)  | [Language](Language.md#language) to be used when actual language is unknown. |

---

{#drgn_default_language}

### drgn_default_language

```cpp
#define drgn_default_language drgn_language_c
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/language.h:175

[Language](Language.md#language) to be used when actual language is unknown.

## Enumerations

| Name | Description |
|------|-------------|
| [`drgn_language_number`](#drgn_language_number)  | [Language](Language.md#language) numbers. |

---

{#drgn_language_number}

### drgn_language_number

```cpp
enum drgn_language_number
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/language.h:43

[Language](Language.md#language) numbers.

These can be used as indices for storing language-specific data in an array.

| Value | Description |
|-------|-------------|
| `DRGN_LANGUAGE_C` |  |
| `DRGN_LANGUAGE_CPP` |  |
| `DRGN_NUM_LANGUAGES` |  |
## Typedefs

| Return | Name | Description |
|--------|------|-------------|
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_format_type_fn`](#drgn_format_type_fn)  |  |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_format_variable_declaration_fn`](#drgn_format_variable_declaration_fn)  |  |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_format_object_fn`](#drgn_format_object_fn)  |  |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_find_type_fn`](#drgn_find_type_fn)  |  |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_type_subobject_fn`](#drgn_type_subobject_fn)  |  |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_integer_literal_fn`](#drgn_integer_literal_fn)  |  |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_bool_literal_fn`](#drgn_bool_literal_fn)  |  |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_float_literal_fn`](#drgn_float_literal_fn)  |  |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_cast_op`](#drgn_cast_op)  |  |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_implicit_convert_op`](#drgn_implicit_convert_op)  |  |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_bool_op`](#drgn_bool_op)  |  |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_cmp_op`](#drgn_cmp_op)  |  |

---

{#drgn_format_type_fn}

### drgn_format_type_fn

```cpp
using drgn_format_type_fn = struct drgn_error *
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/language.h:49

---

{#drgn_format_variable_declaration_fn}

### drgn_format_variable_declaration_fn

```cpp
using drgn_format_variable_declaration_fn = struct drgn_error *
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/language.h:52

---

{#drgn_format_object_fn}

### drgn_format_object_fn

```cpp
using drgn_format_object_fn = struct drgn_error *
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/language.h:55

---

{#drgn_find_type_fn}

### drgn_find_type_fn

```cpp
using drgn_find_type_fn = struct drgn_error *
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/language.h:58

---

{#drgn_type_subobject_fn}

### drgn_type_subobject_fn

```cpp
using drgn_type_subobject_fn = struct drgn_error *
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/language.h:64

---

{#drgn_integer_literal_fn}

### drgn_integer_literal_fn

```cpp
using drgn_integer_literal_fn = struct drgn_error *
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/language.h:68

---

{#drgn_bool_literal_fn}

### drgn_bool_literal_fn

```cpp
using drgn_bool_literal_fn = struct drgn_error *
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/language.h:70

---

{#drgn_float_literal_fn}

### drgn_float_literal_fn

```cpp
using drgn_float_literal_fn = struct drgn_error *
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/language.h:72

---

{#drgn_cast_op}

### drgn_cast_op

```cpp
using drgn_cast_op = struct drgn_error *
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/language.h:75

---

{#drgn_implicit_convert_op}

### drgn_implicit_convert_op

```cpp
using drgn_implicit_convert_op = struct drgn_error *
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/language.h:78

---

{#drgn_bool_op}

### drgn_bool_op

```cpp
using drgn_bool_op = struct drgn_error *
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/language.h:82

---

{#drgn_cmp_op}

### drgn_cmp_op

```cpp
using drgn_cmp_op = struct drgn_error *
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/language.h:83

## Functions

| Return | Name | Description |
|--------|------|-------------|
| enum [`drgn_format_object_flags`](drgn_format_object_flags.md#drgn_format_object_flags) | [`drgn_passthrough_format_object_flags`](#drgn_passthrough_format_object_flags) `static` `inline` | Return flags that should be passed through when formatting an object recursively. |
| enum [`drgn_format_object_flags`](drgn_format_object_flags.md#drgn_format_object_flags) | [`drgn_member_format_object_flags`](#drgn_member_format_object_flags) `static` `inline` | Return flags that should be passed when formatting object members. |
| enum [`drgn_format_object_flags`](drgn_format_object_flags.md#drgn_format_object_flags) | [`drgn_element_format_object_flags`](#drgn_element_format_object_flags) `static` `inline` | Return flags that should be passed when formatting object elements. |

---

{#drgn_passthrough_format_object_flags}

### drgn_passthrough_format_object_flags

`static` `inline`

```cpp
static inline enum drgn_format_object_flags drgn_passthrough_format_object_flags(enum drgn_format_object_flags flags)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/language.h:182

Return flags that should be passed through when formatting an object recursively.

---

{#drgn_member_format_object_flags}

### drgn_member_format_object_flags

`static` `inline`

```cpp
static inline enum drgn_format_object_flags drgn_member_format_object_flags(enum drgn_format_object_flags flags)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/language.h:199

Return flags that should be passed when formatting object members.

---

{#drgn_element_format_object_flags}

### drgn_element_format_object_flags

`static` `inline`

```cpp
static inline enum drgn_format_object_flags drgn_element_format_object_flags(enum drgn_format_object_flags flags)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/language.h:207

Return flags that should be passed when formatting object elements.

## Variables

| Return | Name | Description |
|--------|------|-------------|
| const struct [`drgn_language`](drgn_language.md#drgn_language) *const | [`drgn_languages`](#drgn_languages)  | Mapping from [drgn_language_number](drgn_language_number.md#drgn_language_number) to [drgn_language](drgn_language.md#drgn_language). |

---

{#drgn_languages}

### drgn_languages

```cpp
const struct drgn_language *const drgn_languages[]
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/language.h:172

Mapping from [drgn_language_number](drgn_language_number.md#drgn_language_number) to [drgn_language](drgn_language.md#drgn_language).

