{#drgn_error}

# drgn_error

```cpp
#include <error.h>
```

```cpp
struct drgn_error
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/error.h:28

libdrgn error.

All functions in libdrgn that can return an error return this type.

## Public Attributes

| Return | Name | Description |
|--------|------|-------------|
| `int8_t` | [`_code`](#_code)  |  |
| `int` | [`_errno`](#_errno)  |  |
| `char *` | [`_path`](#_path)  |  |
| `uint64_t` | [`_address`](#_address)  |  |
| union [`drgn_error`](#drgn_error) | [``](#unknown-10)  |  |
| `char *` | [`_message`](#_message)  |  |
| `void *` | [`_python_exc`](#_python_exc)  |  |

---

{#_code}

### _code

```cpp
int8_t _code
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/error.h:29

---

{#_errno}

### _errno

```cpp
int _errno
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/error.h:44

---

{#_path}

### _path

```cpp
char * _path
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/error.h:45

---

{#_address}

### _address

```cpp
uint64_t _address
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/error.h:48

---

{#unknown-10}

### 

```cpp
union drgn_error
```

Type: union [`drgn_error`](#drgn_error)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/error.h:49

---

{#_message}

### _message

```cpp
char * _message
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/error.h:50

---

{#_python_exc}

### _python_exc

```cpp
void * _python_exc
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/error.h:51

## Private Attributes

| Return | Name | Description |
|--------|------|-------------|
| `bool` | [`_needs_destroy`](#_needs_destroy)  | Whether this error needs to be passed to [drgn_error_destroy()](ErrorHandling.md#drgn_error_destroy). |

---

{#_needs_destroy}

### _needs_destroy

```cpp
bool _needs_destroy
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/error.h:40

Whether this error needs to be passed to [drgn_error_destroy()](ErrorHandling.md#drgn_error_destroy).

This is `true` for the error codes returned from [drgn_error_create()](ErrorHandling.md#drgn_error_create) and its related functions. Certain errors are statically allocated and do not need to be passed to [drgn_error_destroy()](ErrorHandling.md#drgn_error_destroy) (but they can be).

