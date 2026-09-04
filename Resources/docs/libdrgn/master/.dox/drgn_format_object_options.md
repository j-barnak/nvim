{#drgn_format_object_options}

# drgn_format_object_options

```cpp
#include <drgn.h>
```

```cpp
struct drgn_format_object_options
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:3044

Formatting options for [drgn_format_object()](ObjectHelpers.md#drgn_format_object).

## Public Attributes

| Return | Name | Description |
|--------|------|-------------|
| `size_t` | [`columns`](#columns)  | Number of columns to limit output to when the expression can be reasonably wrapped. The default is `SIZE_MAX`. |
| enum [`drgn_format_object_flags`](drgn_format_object_flags.md#drgn_format_object_flags) | [`flags`](#flags)  | Flags to control formatting. The default is [DRGN_FORMAT_OBJECT_PRETTY](ObjectHelpers.md#group__ObjectHelpers_1gga556d7ac78ce378321d7a201fc673e173aa5e0ea60593ee19f4c1d903395735abc). |
| `int` | [`integer_base`](#integer_base)  | Base to format integers in (8, 10, or 16). The default is 10. |

---

{#columns}

### columns

```cpp
size_t columns
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:3049

Number of columns to limit output to when the expression can be reasonably wrapped. The default is `SIZE_MAX`.

---

{#flags}

### flags

```cpp
enum drgn_format_object_flags flags
```

Type: enum [`drgn_format_object_flags`](drgn_format_object_flags.md#drgn_format_object_flags)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:3054

Flags to control formatting. The default is [DRGN_FORMAT_OBJECT_PRETTY](ObjectHelpers.md#group__ObjectHelpers_1gga556d7ac78ce378321d7a201fc673e173aa5e0ea60593ee19f4c1d903395735abc).

---

{#integer_base}

### integer_base

```cpp
int integer_base
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:3056

Base to format integers in (8, 10, or 16). The default is 10.

