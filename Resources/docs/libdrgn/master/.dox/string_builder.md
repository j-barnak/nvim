{#string_builder-1}

# string_builder

```cpp
#include <string_builder.h>
```

```cpp
struct string_builder
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/string_builder.h:41

String builder.

A string builder consists of a buffer and a length. The buffer is resized as needed. The buffer can only be appended to; see [string_callback](string_callback.md#string_callback) for an alternative to insertion.

## Public Attributes

| Return | Name | Description |
|--------|------|-------------|
| `char *` | [`str`](#str)  | Current string buffer. |
| `size_t` | [`len`](#len-2)  | Length of `str`. |
| `size_t` | [`capacity`](#capacity)  | Allocated size of `str`. |

---

{#str}

### str

```cpp
char * str
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/string_builder.h:47

Current string buffer.

This may be reallocated when appending.

---

{#len-2}

### len

```cpp
size_t len
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/string_builder.h:49

Length of `str`.

---

{#capacity}

### capacity

```cpp
size_t capacity
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/string_builder.h:51

Allocated size of `str`.

