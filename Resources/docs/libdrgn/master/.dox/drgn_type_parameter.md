{#drgn_type_parameter}

# drgn_type_parameter

```cpp
#include <drgn.h>
```

```cpp
struct drgn_type_parameter
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:3507

Parameter of a function type.

## Public Attributes

| Return | Name | Description |
|--------|------|-------------|
| union [`drgn_lazy_object`](drgn_lazy_object.md#drgn_lazy_object) | [`default_argument`](#default_argument)  | Parameter type and default argument. |
| `const char *` | [`name`](#name-2)  | Parameter name or `NULL` if it is unnamed. |

---

{#default_argument}

### default_argument

```cpp
union drgn_lazy_object default_argument
```

Type: union [`drgn_lazy_object`](drgn_lazy_object.md#drgn_lazy_object)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:3514

Parameter type and default argument.

Access this with [drgn_parameter_default_argument()](Types.md#drgn_parameter_default_argument) or [drgn_parameter_type()](Types.md#drgn_parameter_type).

---

{#name-2}

### name

```cpp
const char * name
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:3516

Parameter name or `NULL` if it is unnamed.

