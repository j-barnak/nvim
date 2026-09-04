{#errors}

# Errors

> [`Internals`](Internals.md#internals)

Common errors.

## Macros

| Name | Description |
|------|-------------|
| [`DRGN_ERROR_INIT`](#drgn_error_init)  |  |
| [`drgn_recursion_guard`](#drgn_recursion_guard)  | Scope guard that counts recursive calls and returns with a [DRGN_ERROR_RECURSION](api.md#drgn_error_recursion) error if the recursion depth exceeds a limit. |
| [`drgn_recursion_guard_impl`](#drgn_recursion_guard_impl)  |  |

---

{#drgn_error_init}

### DRGN_ERROR_INIT

```cpp
#define DRGN_ERROR_INIT(code, message) { ._code = (code), ._message = (message) }
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/error.h:57

---

{#drgn_recursion_guard}

### drgn_recursion_guard

```cpp
#define drgn_recursion_guard(limit, message) drgn_recursion_guard_impl(limit, message, PP_UNIQUE(recursion_count))
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/error.h:170

Scope guard that counts recursive calls and returns with a [DRGN_ERROR_RECURSION](api.md#drgn_error_recursion) error if the recursion depth exceeds a limit.

```cpp
struct drgn_error *my_recursive_function(int n)
{
        drgn_recursion_guard(1000, "maximum recursion depth exceeded");
        if (n <= 0)
                return NULL;
        return my_recursive_function(n - 1);
}
```

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `limit` |  | Maximum recursion depth. For example, 0 means that the function may be called but may not make any recursive calls. |
| `message` |  | Error message if limit is exceeded. |

---

{#drgn_recursion_guard_impl}

### drgn_recursion_guard_impl

```cpp
#define drgn_recursion_guard_impl(limit, message, unique_recursion_count) static _Thread_local int unique_recursion_count = 0;			\
	if (unique_recursion_count > (limit))					\
		return drgn_error_create(DRGN_ERROR_RECURSION, (message));	\
	unique_recursion_count++;						\
	__attribute__((__cleanup__(drgn_recursion_guard_cleanup), __unused__))	\
	int *PP_UNIQUE(recursion_count_ptr) = &unique_recursion_count
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/error.h:178

## Functions

| Return | Name | Description |
|--------|------|-------------|
| `bool` | [`drgn_error_is_fatal`](#drgn_error_is_fatal) `static` `inline` | Return whether an error is fatal, meaning that it should usually be returned to the caller instead of being handled or logged. |
| `bool` | [`string_builder_append_error`](#string_builder_append_error)  | Append a formatted [drgn_error](drgn_error.md#drgn_error) to a [string_builder](string_builder.md#string_builder-1). |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_error_libelf`](#drgn_error_libelf)  | Create a [drgn_error](drgn_error.md#drgn_error) from the libelf error indicator. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_error_libdw`](#drgn_error_libdw)  | Create a [drgn_error](drgn_error.md#drgn_error) from the libdw error indicator. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_type_error`](#drgn_type_error)  | Create a [drgn_error](drgn_error.md#drgn_error) with a type name. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_qualified_type_error`](#drgn_qualified_type_error)  | Create a [drgn_error](drgn_error.md#drgn_error) with a qualified type name. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_2_qualified_types_error`](#drgn_2_qualified_types_error)  | Create a [drgn_error](drgn_error.md#drgn_error) with two qualified type names. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_error_incomplete_type`](#drgn_error_incomplete_type)  | Create a [drgn_error](drgn_error.md#drgn_error) for an incomplete type. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_error_binary_op`](#drgn_error_binary_op)  | Create a [drgn_error](drgn_error.md#drgn_error) for invalid types to a binary operator. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_error_unary_op`](#drgn_error_unary_op)  | Create a [drgn_error](drgn_error.md#drgn_error) for an invalid type to a unary operator. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_error_symbol_not_found`](#drgn_error_symbol_not_found)  | Create a [drgn_error](drgn_error.md#drgn_error) for a failed symbol lookup. |
| `void` | [`drgn_recursion_guard_cleanup`](#drgn_recursion_guard_cleanup) `static` `inline` |  |
| `bool` | [`drgn_error_catch`](#drgn_error_catch) `static` `inline` | Catch a certain kind of [drgn_error](drgn_error.md#drgn_error) and free it |

---

{#drgn_error_is_fatal}

### drgn_error_is_fatal

`static` `inline`

```cpp
static inline bool drgn_error_is_fatal(struct drgn_error * err)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/error.h:71

Return whether an error is fatal, meaning that it should usually be returned to the caller instead of being handled or logged.

---

{#string_builder_append_error}

### string_builder_append_error

```cpp
bool string_builder_append_error(struct string_builder * sb, struct drgn_error * err)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/error.h:84

Append a formatted [drgn_error](drgn_error.md#drgn_error) to a [string_builder](string_builder.md#string_builder-1).

#### Returns
`true` on success, `false` on error (if we couldn't allocate memory).

---

{#drgn_error_libelf}

### drgn_error_libelf

```cpp
struct drgn_error * drgn_error_libelf(void)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/error.h:88

Create a [drgn_error](drgn_error.md#drgn_error) from the libelf error indicator.

---

{#drgn_error_libdw}

### drgn_error_libdw

```cpp
struct drgn_error * drgn_error_libdw(void)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/error.h:92

Create a [drgn_error](drgn_error.md#drgn_error) from the libdw error indicator.

---

{#drgn_type_error}

### drgn_type_error

```cpp
struct drgn_error * drgn_type_error(const char * format, struct drgn_type * type)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/error.h:103

Create a [drgn_error](drgn_error.md#drgn_error) with a type name.

The error code will be [DRGN_ERROR_TYPE](api.md#drgn_error_type).

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `format` | `const char *` | Format string for the type error. Must contain s, which will be replaced with the type name, and no other conversion specifications. |

---

{#drgn_qualified_type_error}

### drgn_qualified_type_error

```cpp
struct drgn_error * drgn_qualified_type_error(const char * format, struct drgn_qualified_type qualified_type)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/error.h:112

Create a [drgn_error](drgn_error.md#drgn_error) with a qualified type name.

**See also**: [drgn_type_error()](#drgn_type_error).

---

{#drgn_2_qualified_types_error}

### drgn_2_qualified_types_error

```cpp
struct drgn_error * drgn_2_qualified_types_error(const char * format, struct drgn_qualified_type qualified_type1, struct drgn_qualified_type qualified_type2)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/error.h:124

Create a [drgn_error](drgn_error.md#drgn_error) with two qualified type names.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `format` | `const char *` | Format string for the type error. Must contain two `s`, which will be replaced with the two type names, and no other conversion specifications. |

---

{#drgn_error_incomplete_type}

### drgn_error_incomplete_type

```cpp
struct drgn_error * drgn_error_incomplete_type(const char * format, struct drgn_type * type)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/error.h:134

Create a [drgn_error](drgn_error.md#drgn_error) for an incomplete type.

**See also**: [drgn_type_error()](#drgn_type_error).

---

{#drgn_error_binary_op}

### drgn_error_binary_op

```cpp
struct drgn_error * drgn_error_binary_op(const char * op_name, struct drgn_operand_type * type1, struct drgn_operand_type * type2)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/error.h:138

Create a [drgn_error](drgn_error.md#drgn_error) for invalid types to a binary operator.

---

{#drgn_error_unary_op}

### drgn_error_unary_op

```cpp
struct drgn_error * drgn_error_unary_op(const char * op_name, struct drgn_operand_type * type)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/error.h:144

Create a [drgn_error](drgn_error.md#drgn_error) for an invalid type to a unary operator.

---

{#drgn_error_symbol_not_found}

### drgn_error_symbol_not_found

```cpp
struct drgn_error * drgn_error_symbol_not_found(uint64_t address)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/error.h:149

Create a [drgn_error](drgn_error.md#drgn_error) for a failed symbol lookup.

---

{#drgn_recursion_guard_cleanup}

### drgn_recursion_guard_cleanup

`static` `inline`

```cpp
static inline void drgn_recursion_guard_cleanup(int ** guard)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/error.h:173

---

{#drgn_error_catch}

### drgn_error_catch

`static` `inline`

```cpp
static inline bool drgn_error_catch(struct drgn_error ** errp, enum drgn_error_code code)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/error.h:193

Catch a certain kind of [drgn_error](drgn_error.md#drgn_error) and free it

If *errp* points to a non-`NULL` error whose code matches *code*, then the free the error (if necessary), replace the pointer value with `NULL`, and return `true`. Otherwise, return `false`, and *err* is not modified.

## Variables

| Return | Name | Description |
|--------|------|-------------|
| struct [`drgn_error`](drgn_error.md#drgn_error) | [`drgn_stop`](#drgn_stop)  | Global stop iteration error. |
| struct [`drgn_error`](drgn_error.md#drgn_error) | [`drgn_error_object_absent`](#drgn_error_object_absent)  | Global [DRGN_ERROR_OBJECT_ABSENT](api.md#drgn_error_object_absent-1) error. |

---

{#drgn_stop}

### drgn_stop

```cpp
struct drgn_error drgn_stop
```

Type: struct [`drgn_error`](drgn_error.md#drgn_error)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/error.h:62

Global stop iteration error.

---

{#drgn_error_object_absent}

### drgn_error_object_absent

```cpp
struct drgn_error drgn_error_object_absent
```

Type: struct [`drgn_error`](drgn_error.md#drgn_error)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/error.h:65

Global [DRGN_ERROR_OBJECT_ABSENT](api.md#drgn_error_object_absent-1) error.

