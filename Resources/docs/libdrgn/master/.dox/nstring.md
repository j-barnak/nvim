{#nstring}

# nstring

```cpp
#include <nstring.h>
```

```cpp
struct nstring
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/nstring.h:17

A string with a stored length.

## Public Attributes

| Return | Name | Description |
|--------|------|-------------|
| `const char *` | [`str`](#str-2)  | The string, which is not necessarily null-terminated and may have embedded null bytes. |
| `size_t` | [`len`](#len-3)  | The length in bytes of the string. |

---

{#str-2}

### str

```cpp
const char * str
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/nstring.h:22

The string, which is not necessarily null-terminated and may have embedded null bytes.

---

{#len-3}

### len

```cpp
size_t len
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/nstring.h:24

The length in bytes of the string.

