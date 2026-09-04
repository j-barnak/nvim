{#binary_buffer}

# binary_buffer

```cpp
#include <binary_buffer.h>
```

```cpp
struct binary_buffer
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/binary_buffer.h:71

Buffer of binary data to parse.

In addition to the functions defined here, `pos`, `prev`, and `end` may be modified directly so long as `pos <= end && prev <= end` remains true.

## Public Attributes

| Return | Name | Description |
|--------|------|-------------|
| `const char *` | [`pos`](#pos-1)  | Current position in the buffer. |
| `const char *` | [`end`](#end)  | Pointer to one byte after the last valid byte in the buffer. |
| `const char *` | [`prev`](#prev)  | Position of the last accessed value. |
| `bool` | [`bswap`](#bswap)  | Whether the data is in the opposite byte order from the host. |
| [`binary_buffer_error_fn`](BinaryBuffer.md#binary_buffer_error_fn) | [`error_fn`](#error_fn)  | Error formatting callback. |

---

{#pos-1}

### pos

```cpp
const char * pos
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/binary_buffer.h:77

Current position in the buffer.

This is advanced by the `binary_buffer_next*` functions.

---

{#end}

### end

```cpp
const char * end
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/binary_buffer.h:79

Pointer to one byte after the last valid byte in the buffer.

---

{#prev}

### prev

```cpp
const char * prev
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/binary_buffer.h:90

Position of the last accessed value.

On success, the `binary_buffer_next*` functions set this to the position of the returned value (i.e., the position on entry). This is useful for reporting errors after validating a value that was just read.

This is not updated by the `binary_buffer_skip*` functions.

---

{#bswap}

### bswap

```cpp
bool bswap
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/binary_buffer.h:92

Whether the data is in the opposite byte order from the host.

---

{#error_fn}

### error_fn

```cpp
binary_buffer_error_fn error_fn
```

Type: [`binary_buffer_error_fn`](BinaryBuffer.md#binary_buffer_error_fn)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/binary_buffer.h:94

Error formatting callback.

