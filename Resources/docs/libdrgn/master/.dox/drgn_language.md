{#drgn_language}

# drgn_language

```cpp
#include <language.h>
```

```cpp
struct drgn_language
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/language.h:95

[Language](Language.md#language) implementation.

This mainly provides callbacks used to implement the higher-level libdrgn helpers. These callbacks handle the language-specific parts of the helpers.

In particular, the operator callbacks should do appropriate type checking for the language and call the implementation in [Objects](ObjectInternals.md#objects-1).

## Public Attributes

| Return | Name | Description |
|--------|------|-------------|
| `const char *` | [`name`](#name-6)  | Name of this programming language. |
| enum [`drgn_language_number`](drgn_language_number.md#drgn_language_number) | [`number`](#number)  | Number of this programming language. |
| `bool` | [`has_namespaces`](#has_namespaces)  | Whether this language has namespaces. |
| [`drgn_format_type_fn`](LanguageInternals.md#drgn_format_type_fn) * | [`format_type_name`](#format_type_name)  | Implement [drgn_format_type_name()](Types.md#drgn_format_type_name). |
| [`drgn_format_type_fn`](LanguageInternals.md#drgn_format_type_fn) * | [`format_type`](#format_type)  | Implement [drgn_format_type()](Types.md#drgn_format_type). |
| [`drgn_format_variable_declaration_fn`](LanguageInternals.md#drgn_format_variable_declaration_fn) * | [`format_variable_declaration`](#format_variable_declaration)  | Implement [drgn_format_variable_declaration()](Types.md#drgn_format_variable_declaration). |
| [`drgn_format_object_fn`](LanguageInternals.md#drgn_format_object_fn) * | [`format_object`](#format_object)  | Implement [drgn_format_object()](ObjectHelpers.md#drgn_format_object). |
| [`drgn_find_type_fn`](LanguageInternals.md#drgn_find_type_fn) * | [`find_type`](#find_type)  | Implement [drgn_program_find_type()](Programs.md#drgn_program_find_type). |
| [`drgn_type_subobject_fn`](LanguageInternals.md#drgn_type_subobject_fn) * | [`type_subobject`](#type_subobject)  | Get the type, offset, and bit field size of a subobject of a type. |
| [`drgn_integer_literal_fn`](LanguageInternals.md#drgn_integer_literal_fn) * | [`integer_literal`](#integer_literal)  | Set an object to an integer literal. |
| [`drgn_bool_literal_fn`](LanguageInternals.md#drgn_bool_literal_fn) * | [`bool_literal`](#bool_literal)  | Set an object to a boolean literal. |
| [`drgn_float_literal_fn`](LanguageInternals.md#drgn_float_literal_fn) * | [`float_literal`](#float_literal)  | Set an object to a floating-point literal. |
| [`drgn_cast_op`](LanguageInternals.md#drgn_cast_op) * | [`op_cast`](#op_cast)  |  |
| [`drgn_implicit_convert_op`](LanguageInternals.md#drgn_implicit_convert_op) * | [`op_implicit_convert`](#op_implicit_convert)  |  |
| [`drgn_bool_op`](LanguageInternals.md#drgn_bool_op) * | [`op_bool`](#op_bool)  |  |
| [`drgn_cmp_op`](LanguageInternals.md#drgn_cmp_op) * | [`op_cmp`](#op_cmp)  |  |
| [`drgn_binary_op`](ObjectOperators.md#drgn_binary_op) * | [`op_add`](#op_add)  |  |
| [`drgn_binary_op`](ObjectOperators.md#drgn_binary_op) * | [`op_sub`](#op_sub)  |  |
| [`drgn_binary_op`](ObjectOperators.md#drgn_binary_op) * | [`op_mul`](#op_mul)  |  |
| [`drgn_binary_op`](ObjectOperators.md#drgn_binary_op) * | [`op_div`](#op_div)  |  |
| [`drgn_binary_op`](ObjectOperators.md#drgn_binary_op) * | [`op_mod`](#op_mod)  |  |
| [`drgn_binary_op`](ObjectOperators.md#drgn_binary_op) * | [`op_lshift`](#op_lshift)  |  |
| [`drgn_binary_op`](ObjectOperators.md#drgn_binary_op) * | [`op_rshift`](#op_rshift)  |  |
| [`drgn_binary_op`](ObjectOperators.md#drgn_binary_op) * | [`op_and`](#op_and)  |  |
| [`drgn_binary_op`](ObjectOperators.md#drgn_binary_op) * | [`op_or`](#op_or)  |  |
| [`drgn_binary_op`](ObjectOperators.md#drgn_binary_op) * | [`op_xor`](#op_xor)  |  |
| [`drgn_unary_op`](ObjectOperators.md#drgn_unary_op) * | [`op_pos`](#op_pos)  |  |
| [`drgn_unary_op`](ObjectOperators.md#drgn_unary_op) * | [`op_neg`](#op_neg)  |  |
| [`drgn_unary_op`](ObjectOperators.md#drgn_unary_op) * | [`op_not`](#op_not)  |  |

---

{#name-6}

### name

```cpp
const char * name
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/language.h:97

Name of this programming language.

---

{#number}

### number

```cpp
enum drgn_language_number number
```

Type: enum [`drgn_language_number`](drgn_language_number.md#drgn_language_number)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/language.h:99

Number of this programming language.

---

{#has_namespaces}

### has_namespaces

```cpp
bool has_namespaces
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/language.h:101

Whether this language has namespaces.

---

{#format_type_name}

### format_type_name

```cpp
drgn_format_type_fn * format_type_name
```

Type: [`drgn_format_type_fn`](LanguageInternals.md#drgn_format_type_fn) *

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/language.h:103

Implement [drgn_format_type_name()](Types.md#drgn_format_type_name).

---

{#format_type}

### format_type

```cpp
drgn_format_type_fn * format_type
```

Type: [`drgn_format_type_fn`](LanguageInternals.md#drgn_format_type_fn) *

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/language.h:105

Implement [drgn_format_type()](Types.md#drgn_format_type).

---

{#format_variable_declaration}

### format_variable_declaration

```cpp
drgn_format_variable_declaration_fn * format_variable_declaration
```

Type: [`drgn_format_variable_declaration_fn`](LanguageInternals.md#drgn_format_variable_declaration_fn) *

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/language.h:107

Implement [drgn_format_variable_declaration()](Types.md#drgn_format_variable_declaration).

---

{#format_object}

### format_object

```cpp
drgn_format_object_fn * format_object
```

Type: [`drgn_format_object_fn`](LanguageInternals.md#drgn_format_object_fn) *

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/language.h:109

Implement [drgn_format_object()](ObjectHelpers.md#drgn_format_object).

---

{#find_type}

### find_type

```cpp
drgn_find_type_fn * find_type
```

Type: [`drgn_find_type_fn`](LanguageInternals.md#drgn_find_type_fn) *

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/language.h:116

Implement [drgn_program_find_type()](Programs.md#drgn_program_find_type).

This should parse `name` and call [drgn_program_find_type_impl()](TypeInternals.md#drgn_program_find_type_impl).

---

{#type_subobject}

### type_subobject

```cpp
drgn_type_subobject_fn * type_subobject
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/language.h:130

Get the type, offset, and bit field size of a subobject of a type.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `type` |  | Starting type. |
| `designator` |  | One or more member references or array subscripts. |
| `expect_member` |  | Require a member reference first. |
| `type_ret` |  | If not `NULL`, returned subobject type. |
| `bit_offset_ret` |  | If not `NULL`, returned offset in bits of subobject from the beginning of `type`. |
| `bit_field_size_ret` |  | If not `NULL`, returned bit field size of subobject. |

---

{#integer_literal}

### integer_literal

```cpp
drgn_integer_literal_fn * integer_literal
```

Type: [`drgn_integer_literal_fn`](LanguageInternals.md#drgn_integer_literal_fn) *

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/language.h:137

Set an object to an integer literal.

This should set `res` to the given value and appropriate type for an integer literal in the language.

---

{#bool_literal}

### bool_literal

```cpp
drgn_bool_literal_fn * bool_literal
```

Type: [`drgn_bool_literal_fn`](LanguageInternals.md#drgn_bool_literal_fn) *

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/language.h:144

Set an object to a boolean literal.

This should set `res` to the given value and the boolean type in the language.

---

{#float_literal}

### float_literal

```cpp
drgn_float_literal_fn * float_literal
```

Type: [`drgn_float_literal_fn`](LanguageInternals.md#drgn_float_literal_fn) *

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/language.h:151

Set an object to a floating-point literal.

This should set `res` to the given value and appropriate type for a floating-point literal in the language.

---

{#op_cast}

### op_cast

```cpp
drgn_cast_op * op_cast
```

Type: [`drgn_cast_op`](LanguageInternals.md#drgn_cast_op) *

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/language.h:152

---

{#op_implicit_convert}

### op_implicit_convert

```cpp
drgn_implicit_convert_op * op_implicit_convert
```

Type: [`drgn_implicit_convert_op`](LanguageInternals.md#drgn_implicit_convert_op) *

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/language.h:153

---

{#op_bool}

### op_bool

```cpp
drgn_bool_op * op_bool
```

Type: [`drgn_bool_op`](LanguageInternals.md#drgn_bool_op) *

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/language.h:154

---

{#op_cmp}

### op_cmp

```cpp
drgn_cmp_op * op_cmp
```

Type: [`drgn_cmp_op`](LanguageInternals.md#drgn_cmp_op) *

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/language.h:155

---

{#op_add}

### op_add

```cpp
drgn_binary_op * op_add
```

Type: [`drgn_binary_op`](ObjectOperators.md#drgn_binary_op) *

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/language.h:156

---

{#op_sub}

### op_sub

```cpp
drgn_binary_op * op_sub
```

Type: [`drgn_binary_op`](ObjectOperators.md#drgn_binary_op) *

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/language.h:157

---

{#op_mul}

### op_mul

```cpp
drgn_binary_op * op_mul
```

Type: [`drgn_binary_op`](ObjectOperators.md#drgn_binary_op) *

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/language.h:158

---

{#op_div}

### op_div

```cpp
drgn_binary_op * op_div
```

Type: [`drgn_binary_op`](ObjectOperators.md#drgn_binary_op) *

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/language.h:159

---

{#op_mod}

### op_mod

```cpp
drgn_binary_op * op_mod
```

Type: [`drgn_binary_op`](ObjectOperators.md#drgn_binary_op) *

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/language.h:160

---

{#op_lshift}

### op_lshift

```cpp
drgn_binary_op * op_lshift
```

Type: [`drgn_binary_op`](ObjectOperators.md#drgn_binary_op) *

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/language.h:161

---

{#op_rshift}

### op_rshift

```cpp
drgn_binary_op * op_rshift
```

Type: [`drgn_binary_op`](ObjectOperators.md#drgn_binary_op) *

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/language.h:162

---

{#op_and}

### op_and

```cpp
drgn_binary_op * op_and
```

Type: [`drgn_binary_op`](ObjectOperators.md#drgn_binary_op) *

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/language.h:163

---

{#op_or}

### op_or

```cpp
drgn_binary_op * op_or
```

Type: [`drgn_binary_op`](ObjectOperators.md#drgn_binary_op) *

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/language.h:164

---

{#op_xor}

### op_xor

```cpp
drgn_binary_op * op_xor
```

Type: [`drgn_binary_op`](ObjectOperators.md#drgn_binary_op) *

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/language.h:165

---

{#op_pos}

### op_pos

```cpp
drgn_unary_op * op_pos
```

Type: [`drgn_unary_op`](ObjectOperators.md#drgn_unary_op) *

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/language.h:166

---

{#op_neg}

### op_neg

```cpp
drgn_unary_op * op_neg
```

Type: [`drgn_unary_op`](ObjectOperators.md#drgn_unary_op) *

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/language.h:167

---

{#op_not}

### op_not

```cpp
drgn_unary_op * op_not
```

Type: [`drgn_unary_op`](ObjectOperators.md#drgn_unary_op) *

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/language.h:168

