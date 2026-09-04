{#string_callback}

# string_callback

```cpp
#include <string_builder.h>
```

```cpp
struct string_callback
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/string_builder.h:203

Callback to append to a string later.

Instead of providing functionality to prepend to a [string_builder](string_builder.md#string_builder-1), we achieve the same thing by passing around a callback until all prefixes have been appended, then calling the callback to append the "infix". This avoids the O(n) array shift required for prepend.

## Public Attributes

| Return | Name | Description |
|--------|------|-------------|
| struct [`drgn_error`](drgn_error.md#drgn_error) *(* | [`fn`](#fn-1)  | Callback function. |
| struct [`string_callback`](#string_callback) * | [`str`](#str-1)  | Another string callback to be passed to the callback. |
| `void *` | [`arg`](#arg-3)  | Callback argument. |

---

{#fn-1}

### fn

```cpp
struct drgn_error *(* fn)(struct string_callback *str, void *arg, struct string_builder *sb)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/string_builder.h:51

Callback function.

---

{#str-1}

### str

```cpp
struct string_callback * str
```

Type: struct [`string_callback`](#string_callback) *

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/string_builder.h:212

Another string callback to be passed to the callback.

This is useful for strings that need to be built recursively.

---

{#arg-3}

### arg

```cpp
void * arg
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/string_builder.h:214

Callback argument.

