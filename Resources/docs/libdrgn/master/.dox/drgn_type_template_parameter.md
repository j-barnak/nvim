{#drgn_type_template_parameter}

# drgn_type_template_parameter

```cpp
#include <drgn.h>
```

```cpp
struct drgn_type_template_parameter
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:3520

Template parameter of a structure, union, class, or function type.

## Public Attributes

| Return | Name | Description |
|--------|------|-------------|
| union [`drgn_lazy_object`](drgn_lazy_object.md#drgn_lazy_object) | [`argument`](#argument)  | Template parameter type or value. |
| `const char *` | [`name`](#name-3)  | Template parameter name or `NULL` if it is unnamed. |
| `bool` | [`is_default`](#is_default)  | Whether the argument is the default. |

---

{#argument}

### argument

```cpp
union drgn_lazy_object argument
```

Type: union [`drgn_lazy_object`](drgn_lazy_object.md#drgn_lazy_object)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:3527

Template parameter type or value.

Access this with [drgn_template_parameter_type()](Types.md#drgn_template_parameter_type) and [drgn_template_parameter_object()](Types.md#drgn_template_parameter_object).

---

{#name-3}

### name

```cpp
const char * name
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:3529

Template parameter name or `NULL` if it is unnamed.

---

{#is_default}

### is_default

```cpp
bool is_default
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:3531

Whether the argument is the default.

