{#errorhandling}

# Error handling

Error handling in libdrgn.

Operations in libdrgn can fail for various reasons. libdrgn returns errors as [drgn_error](drgn_error.md#drgn_error).

## Classes

| Name | Description |
|------|-------------|
| [`drgn_error`](drgn_error.md#drgn_error) | libdrgn error. |

## Enumerations

| Name | Description |
|------|-------------|
| [`drgn_error_code`](#drgn_error_code)  | Error code for a [drgn_error](drgn_error.md#drgn_error). |

---

{#drgn_error_code}

### drgn_error_code

```cpp
enum drgn_error_code
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:61

Error code for a [drgn_error](drgn_error.md#drgn_error).

## Functions

| Return | Name | Description |
|--------|------|-------------|
| enum [`drgn_error_code`](drgn_error_code.md#drgn_error_code) | [`__attribute__`](#__attribute__-6)  |  |
| enum [`drgn_error_code`](drgn_error_code.md#drgn_error_code) | [`drgn_error_code`](#drgn_error_code-1)  | Get the error code of a [drgn_error](drgn_error.md#drgn_error). |
| `const char *` | [`drgn_error_message`](#drgn_error_message)  | Get the error message of a [drgn_error](drgn_error.md#drgn_error). |
| `int` | [`drgn_error_os_errno`](#drgn_error_os_errno)  | Get the `errno` value of a system call error. |
| `const char *` | [`drgn_error_os_path`](#drgn_error_os_path)  | Get the path of the file that encountered a system call error. |
| `uint64_t` | [`drgn_error_fault_address`](#drgn_error_fault_address)  | Get the address that caused a fault error. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_error_create`](#drgn_error_create)  | Create a [drgn_error](drgn_error.md#drgn_error). |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_error_format`](#drgn_error_format)  | Create a [drgn_error](drgn_error.md#drgn_error) from a printf-style format. |
| struct [`drgn_error`](drgn_error.md#drgn_error) | [`__format__`](#__format__-3)  |  |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_error_create_os`](#drgn_error_create_os)  | Create a [DRGN_ERROR_OS](api.md#drgn_error_os)[drgn_error](drgn_error.md#drgn_error). |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_error_format_os`](#drgn_error_format_os)  | Create a [DRGN_ERROR_OS](api.md#drgn_error_os)[drgn_error](drgn_error.md#drgn_error) with a printf-style formatted path. |
| struct [`drgn_error`](drgn_error.md#drgn_error) | [`__format__`](#__format__-4)  |  |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_error_create_fault`](#drgn_error_create_fault)  | Create a [DRGN_ERROR_FAULT](api.md#drgn_error_fault)[drgn_error](drgn_error.md#drgn_error). |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_error_format_fault`](#drgn_error_format_fault)  | Create a [DRGN_ERROR_FAULT](api.md#drgn_error_fault)[drgn_error](drgn_error.md#drgn_error) with a printf-style formatted message. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_error_copy`](#drgn_error_copy)  |  |
| `char *` | [`drgn_error_string`](#drgn_error_string)  | Return a string representation of a [drgn_error](drgn_error.md#drgn_error). |
| `int` | [`drgn_error_fwrite`](#drgn_error_fwrite)  | Write a [drgn_error](drgn_error.md#drgn_error) followed by a newline to a `stdio` stream. |
| `int` | [`drgn_error_dwrite`](#drgn_error_dwrite)  | Write a [drgn_error](drgn_error.md#drgn_error) followed by a newline to a file descriptor. |
| `void` | [`drgn_error_destroy`](#drgn_error_destroy)  | Free a [drgn_error](drgn_error.md#drgn_error). |

---

{#__attribute__-6}

### __attribute__

```cpp
enum drgn_error_code __attribute__((__packed__))
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:1

---

{#drgn_error_code-1}

### drgn_error_code

```cpp
enum drgn_error_code drgn_error_code(struct drgn_error * err)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:120

Get the error code of a [drgn_error](drgn_error.md#drgn_error).

---

{#drgn_error_message}

### drgn_error_message

```cpp
const char * drgn_error_message(struct drgn_error * err)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:127

Get the error message of a [drgn_error](drgn_error.md#drgn_error).

#### Returns
Human-readable message. Valid until `err` is destroyed.

---

{#drgn_error_os_errno}

### drgn_error_os_errno

```cpp
int drgn_error_os_errno(struct drgn_error * err)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:134

Get the `errno` value of a system call error.

#### Returns
Error number, or 0 if error code is not [DRGN_ERROR_OS](api.md#drgn_error_os).

---

{#drgn_error_os_path}

### drgn_error_os_path

```cpp
const char * drgn_error_os_path(struct drgn_error * err)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:142

Get the path of the file that encountered a system call error.

#### Returns
Path (valid until `err` is destroyed), or `NULL` if error code is not [DRGN_ERROR_OS](api.md#drgn_error_os) or the error was not caused by a file.

---

{#drgn_error_fault_address}

### drgn_error_fault_address

```cpp
uint64_t drgn_error_fault_address(struct drgn_error * err)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:149

Get the address that caused a fault error.

#### Returns
Address, or 0 if error code is not [DRGN_ERROR_FAULT](api.md#drgn_error_fault).

---

{#drgn_error_create}

### drgn_error_create

```cpp
struct drgn_error * drgn_error_create(enum drgn_error_code code, const char * message)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:177

Create a [drgn_error](drgn_error.md#drgn_error).

#### Returns
A new error with the given code and message. If there is a failure to allocate memory for the error or the message, [drgn_enomem](#drgn_enomem) is returned instead.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `code` | enum [`drgn_error_code`](drgn_error_code.md#drgn_error_code) | Error code. |
| `message` | `const char *` | Human-readable error message. This string is copied. |

---

{#drgn_error_format}

### drgn_error_format

```cpp
struct drgn_error * drgn_error_format(enum drgn_error_code code, const char * format, ...)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:191

Create a [drgn_error](drgn_error.md#drgn_error) from a printf-style format.

#### Returns
A new error with the given code and formatted message. If there is a failure to allocate memory for the error or the message, [drgn_enomem](#drgn_enomem) is returned instead.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `code` | enum [`drgn_error_code`](drgn_error_code.md#drgn_error_code) | Error code. |
| `format` | `const char *` | printf-style format string. |

---

{#__format__-3}

### __format__

```cpp
struct drgn_error __format__(__printf__, 2, 3)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:193

---

{#drgn_error_create_os}

### drgn_error_create_os

```cpp
struct drgn_error * drgn_error_create_os(const char * message, int errnum, const char * path)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:204

Create a [DRGN_ERROR_OS](api.md#drgn_error_os)[drgn_error](drgn_error.md#drgn_error).

**See also**: [drgn_error_create()](#drgn_error_create).

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `errnum` | `int` | Error number (i.e., `errno`). |
| `path` | `const char *` | If not `NULL`, the path of the file which encountered the error. This string is copied. |

---

{#drgn_error_format_os}

### drgn_error_format_os

```cpp
struct drgn_error * drgn_error_format_os(const char * message, int errnum, const char * path_format, ...)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:216

Create a [DRGN_ERROR_OS](api.md#drgn_error_os)[drgn_error](drgn_error.md#drgn_error) with a printf-style formatted path.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `errnum` | `int` | Error number (i.e., `errno`). |
| `path_format` | `const char *` | printf-style format string for path. |

---

{#__format__-4}

### __format__

```cpp
struct drgn_error __format__(__printf__, 3, 4)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:218

---

{#drgn_error_create_fault}

### drgn_error_create_fault

```cpp
struct drgn_error * drgn_error_create_fault(const char * message, uint64_t address)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:226

Create a [DRGN_ERROR_FAULT](api.md#drgn_error_fault)[drgn_error](drgn_error.md#drgn_error).

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `message` | `const char *` | Human-readable error message. This string is copied. |
| `address` | `uint64_t` | Address where the fault happened. |

---

{#drgn_error_format_fault}

### drgn_error_format_fault

```cpp
struct drgn_error * drgn_error_format_fault(uint64_t address, const char * format, ...)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:238

Create a [DRGN_ERROR_FAULT](api.md#drgn_error_fault)[drgn_error](drgn_error.md#drgn_error) with a printf-style formatted message.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `address` | `uint64_t` | Address where the fault happened. |
| `format` | `const char *` | printf-style format string for message. |

---

{#drgn_error_copy}

### drgn_error_copy

```cpp
struct drgn_error * drgn_error_copy(struct drgn_error * src)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:252

---

{#drgn_error_string}

### drgn_error_string

```cpp
char * drgn_error_string(struct drgn_error * err)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:262

Return a string representation of a [drgn_error](drgn_error.md#drgn_error).

#### Returns
Returned string, or `NULL` if memory could not be allocated. On success, must be freed with `free()`.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `err` | struct [`drgn_error`](drgn_error.md#drgn_error) * | Error to write. |

---

{#drgn_error_fwrite}

### drgn_error_fwrite

```cpp
int drgn_error_fwrite(FILE * file, struct drgn_error * err)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:271

Write a [drgn_error](drgn_error.md#drgn_error) followed by a newline to a `stdio` stream.

#### Returns
Non-negative on success, negative on failure.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `file` | `FILE *` | File to write to (usually `stderr`). |
| `err` | struct [`drgn_error`](drgn_error.md#drgn_error) * | Error to write. |

---

{#drgn_error_dwrite}

### drgn_error_dwrite

```cpp
int drgn_error_dwrite(int fd, struct drgn_error * err)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:280

Write a [drgn_error](drgn_error.md#drgn_error) followed by a newline to a file descriptor.

#### Returns
Non-negative on success, negative on failure.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `fd` | `int` | File descriptor to write to. |
| `err` | struct [`drgn_error`](drgn_error.md#drgn_error) * | Error to write. |

---

{#drgn_error_destroy}

### drgn_error_destroy

```cpp
void drgn_error_destroy(struct drgn_error * err)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:290

Free a [drgn_error](drgn_error.md#drgn_error).

This must be called on any error returned from libdrgn unless otherwise noted.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `err` | struct [`drgn_error`](drgn_error.md#drgn_error) * | Error to destroy. If `NULL`, this is a no-op. |

## Variables

| Return | Name | Description |
|--------|------|-------------|
| struct [`drgn_error`](drgn_error.md#drgn_error) | [`drgn_enomem`](#drgn_enomem)  | Out of memory [drgn_error](drgn_error.md#drgn_error). |
| struct [`drgn_error`](drgn_error.md#drgn_error) | [`drgn_not_found`](#drgn_not_found)  | Non-fatal lookup [drgn_error](drgn_error.md#drgn_error). |

---

{#drgn_enomem}

### drgn_enomem

```cpp
struct drgn_error drgn_enomem
```

Type: struct [`drgn_error`](drgn_error.md#drgn_error)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:158

Out of memory [drgn_error](drgn_error.md#drgn_error).

This has a code of [DRGN_ERROR_NO_MEMORY](api.md#drgn_error_no_memory). It can be returned if a memory allocation fails in order to avoid doing another memory allocation. It does not need to be passed to [drgn_error_destroy()](#drgn_error_destroy) (but it can be).

---

{#drgn_not_found}

### drgn_not_found

```cpp
struct drgn_error drgn_not_found
```

Type: struct [`drgn_error`](drgn_error.md#drgn_error)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:166

Non-fatal lookup [drgn_error](drgn_error.md#drgn_error).

This has a code of [DRGN_ERROR_LOOKUP](api.md#drgn_error_lookup). It does not need to be passed to [drgn_error_destroy()](#drgn_error_destroy) (but it can be).

