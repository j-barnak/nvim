{#drgn_register}

# drgn_register

```cpp
#include <platform.h>
```

```cpp
struct drgn_register
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/platform.h:40

A processor register.

## Public Attributes

| Return | Name | Description |
|--------|------|-------------|
| `const char *const  *` | [`names`](#names)  | Human-readable names of this register. |
| `size_t` | [`num_names`](#num_names)  | Number of names in [names](#names). |
| [`drgn_register_number`](CallFrameInformation.md#drgn_register_number) | [`regno`](#regno)  | Internal register number. |

---

{#names}

### names

```cpp
const char *const  * names
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/platform.h:42

Human-readable names of this register.

---

{#num_names}

### num_names

```cpp
size_t num_names
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/platform.h:44

Number of names in [names](#names).

---

{#regno}

### regno

```cpp
drgn_register_number regno
```

Type: [`drgn_register_number`](CallFrameInformation.md#drgn_register_number)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/platform.h:46

Internal register number.

