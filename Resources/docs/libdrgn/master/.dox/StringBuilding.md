{#stringbuilding}

# String building

> [`Internals`](Internals.md#internals)

String builder interface.

[string_builder](string_builder.md#string_builder-1) provides an append-only way to build a string piece by piece. [string_callback](string_callback.md#string_callback) provides an alternative to prepending pieces.

## Classes

| Name | Description |
|------|-------------|
| [`string_builder`](string_builder.md#string_builder-1) | String builder. |
| [`string_callback`](string_callback.md#string_callback) | Callback to append to a string later. |

## Macros

| Name | Description |
|------|-------------|
| [`STRING_BUILDER_INIT`](#string_builder_init)  | String builder initializer. |
| [`STRING_BUILDER`](#string_builder)  | Define and initialize a [string_builder](string_builder.md#string_builder-1) named `sb` that is automatically deinitialized when it goes out of scope. |

---

{#string_builder_init}

### STRING_BUILDER_INIT

```cpp
#define STRING_BUILDER_INIT { 0 }
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/string_builder.h:55

String builder initializer.

---

{#string_builder}

### STRING_BUILDER

```cpp
#define STRING_BUILDER(sb) __attribute__((__cleanup__(string_builder_deinit)))	\
	struct string_builder sb = STRING_BUILDER_INIT
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/string_builder.h:67

Define and initialize a [string_builder](string_builder.md#string_builder-1) named `sb` that is automatically deinitialized when it goes out of scope.

## Functions

| Return | Name | Description |
|--------|------|-------------|
| `void` | [`string_builder_deinit`](#string_builder_deinit) `static` `inline` | Free memory allocated by a [string_builder](string_builder.md#string_builder-1). |
| `char *` | [`string_builder_steal`](#string_builder_steal) `static` `inline` | Steal the string buffer from a [string_builder](string_builder.md#string_builder-1). |
| `bool` | [`string_builder_null_terminate`](#string_builder_null_terminate)  | Null-terminate a [string_builder](string_builder.md#string_builder-1). |
| `bool` | [`string_builder_reserve`](#string_builder_reserve)  | Resize the buffer of a [string_builder](string_builder.md#string_builder-1) to a given capacity. |
| `bool` | [`string_builder_reserve_for_append`](#string_builder_reserve_for_append)  | Resize the buffer of a [string_builder](string_builder.md#string_builder-1) to accomodate appending characters. |
| `bool` | [`string_builder_appendc`](#string_builder_appendc)  | Append a character to a [string_builder](string_builder.md#string_builder-1). |
| `bool` | [`string_builder_appendn`](#string_builder_appendn)  | Append a number of characters from a string to a [string_builder](string_builder.md#string_builder-1). |
| `bool` | [`string_builder_append`](#string_builder_append) `static` `inline` | Append a null-terminated string to a [string_builder](string_builder.md#string_builder-1). |
| `bool` | [`string_builder_appendf`](#string_builder_appendf)  | Append a string to a [string_builder](string_builder.md#string_builder-1) from a printf-style format. |
| `bool bool` | [`string_builder_vappendf`](#string_builder_vappendf)  | Append a string to a [string_builder](string_builder.md#string_builder-1) from vprintf-style arguments. |
| `bool` | [`string_builder_line_break`](#string_builder_line_break)  | Append a newline character to a [string_builder](string_builder.md#string_builder-1) if the string isn't empty and doesn't already end in a newline. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`string_callback_call`](#string_callback_call) `static` `inline` | Call a string callback. |

---

{#string_builder_deinit}

### string_builder_deinit

`static` `inline`

```cpp
static inline void string_builder_deinit(struct string_builder * sb)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/string_builder.h:58

Free memory allocated by a [string_builder](string_builder.md#string_builder-1).

---

{#string_builder_steal}

### string_builder_steal

`static` `inline`

```cpp
static inline char * string_builder_steal(struct string_builder * sb)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/string_builder.h:79

Steal the string buffer from a [string_builder](string_builder.md#string_builder-1).

The string builder can no longer be used except to be passed to string_builder_deinit(), which will do nothing.

#### Returns
String buffer. This must be freed with `free()`.

---

{#string_builder_null_terminate}

### string_builder_null_terminate

```cpp
bool string_builder_null_terminate(struct string_builder * sb)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/string_builder.h:94

Null-terminate a [string_builder](string_builder.md#string_builder-1).

This appends a null character without incrementing [string_builder::len](string_builder.md#len-2).

#### Returns
`true` on success, `false` on error (if we couldn't allocate memory).

---

{#string_builder_reserve}

### string_builder_reserve

```cpp
bool string_builder_reserve(struct string_builder * sb, size_t capacity)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/string_builder.h:106

Resize the buffer of a [string_builder](string_builder.md#string_builder-1) to a given capacity.

On success, the allocated size of the string buffer is at least `capacity`.

#### Returns
`true` on success, `false` on error (if we couldn't allocate memory).

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `sb` | struct [`string_builder`](string_builder.md#string_builder-1) * | String builder. |
| `capacity` | `size_t` | New minimum allocated size of the string buffer. |

---

{#string_builder_reserve_for_append}

### string_builder_reserve_for_append

```cpp
bool string_builder_reserve_for_append(struct string_builder * sb, size_t n)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/string_builder.h:121

Resize the buffer of a [string_builder](string_builder.md#string_builder-1) to accomodate appending characters.

On success, the allocated size of the string buffer is at least `sb->len + n`. This will also allocate extra space so that appends have amortized constant time complexity.

#### Returns
`true` on success, `false` on error (if we couldn't allocate memory).

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `sb` | struct [`string_builder`](string_builder.md#string_builder-1) * | String builder. |
| `n` | `size_t` | Minimum number of additional characters to reserve. |

---

{#string_builder_appendc}

### string_builder_appendc

```cpp
bool string_builder_appendc(struct string_builder * sb, char c)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/string_builder.h:131

Append a character to a [string_builder](string_builder.md#string_builder-1).

#### Returns
`true` on success, `false` on error (if we couldn't allocate memory).

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `sb` | struct [`string_builder`](string_builder.md#string_builder-1) * | String builder. |
| `c` | `char` | Character to append. |

---

{#string_builder_appendn}

### string_builder_appendn

```cpp
bool string_builder_appendn(struct string_builder * sb, const char * str, size_t len)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/string_builder.h:142

Append a number of characters from a string to a [string_builder](string_builder.md#string_builder-1).

#### Returns
`true` on success, `false` on error (if we couldn't allocate memory).

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `sb` | struct [`string_builder`](string_builder.md#string_builder-1) * | String builder. |
| `str` | `const char *` | String to append. |
| `len` | `size_t` | Number of characters from `str` to append. |

---

{#string_builder_append}

### string_builder_append

`static` `inline`

```cpp
static inline bool string_builder_append(struct string_builder * sb, const char * str)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/string_builder.h:153

Append a null-terminated string to a [string_builder](string_builder.md#string_builder-1).

#### Returns
`true` on success, `false` on error (if we couldn't allocate memory).

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `sb` | struct [`string_builder`](string_builder.md#string_builder-1) * | String builder. |
| `str` | `const char *` | String to append. |

---

{#string_builder_appendf}

### string_builder_appendf

```cpp
bool string_builder_appendf(struct string_builder * sb, const char * format, ...)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/string_builder.h:168

Append a string to a [string_builder](string_builder.md#string_builder-1) from a printf-style format.

#### Returns
`true` on success, `false` on error (if we couldn't allocate memory).

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `sb` | struct [`string_builder`](string_builder.md#string_builder-1) * | String builder. |
| `format` | `const char *` | printf-style format string. |

---

{#string_builder_vappendf}

### string_builder_vappendf

```cpp
bool bool string_builder_vappendf(struct string_builder * sb, const char * format, va_list ap)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/string_builder.h:182

Append a string to a [string_builder](string_builder.md#string_builder-1) from vprintf-style arguments.

**See also**: [string_builder_appendf()](#string_builder_appendf)

#### Returns
`true` on success, `false` on error (if we couldn't allocate memory).

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `sb` | struct [`string_builder`](string_builder.md#string_builder-1) * | String builder. |
| `format` | `const char *` | printf-style format string. |
| `ap` | `va_list` | Arguments for the format string. |

---

{#string_builder_line_break}

### string_builder_line_break

```cpp
bool string_builder_line_break(struct string_builder * sb)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/string_builder.h:193

Append a newline character to a [string_builder](string_builder.md#string_builder-1) if the string isn't empty and doesn't already end in a newline.

#### Returns
`true` on success, `false` on error (if we couldn't allocate memory).

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `sb` | struct [`string_builder`](string_builder.md#string_builder-1) * | String builder. |

---

{#string_callback_call}

### string_callback_call

`static` `inline`

```cpp
static inline struct drgn_error * string_callback_call(struct string_callback * str, struct string_builder * sb)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/string_builder.h:228

Call a string callback.

The callback function will be passed [string_callback::str](string_callback.md#str-1) and [string_callback::arg](string_callback.md#arg-3).

#### Returns
`true` on success, `false` on error (if we couldn't allocate memory).

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `str` | struct [`string_callback`](string_callback.md#string_callback) * | String callback. If `NULL`, this is a no-op. |
| `sb` | struct [`string_builder`](string_builder.md#string_builder-1) * | String builder to append to. |

