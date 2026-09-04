{#drgntype}

# DrgnType

```cpp
#include <drgnpy.h>
```

```cpp
struct DrgnType
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:177

## Public Attributes

| Return | Name | Description |
|--------|------|-------------|
| PyObject_HEAD struct [`drgn_type`](drgn_type.md#drgn_type) * | [`type`](#type-5)  |  |
| enum [`drgn_qualifiers`](drgn_qualifiers.md#drgn_qualifiers) | [`qualifiers`](#qualifiers-4)  |  |
| `PyObject *` | [`attr_cache`](#attr_cache)  |  |

---

{#type-5}

### type

```cpp
PyObject_HEAD struct drgn_type * type
```

Type: PyObject_HEAD struct [`drgn_type`](drgn_type.md#drgn_type) *

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:179

---

{#qualifiers-4}

### qualifiers

```cpp
enum drgn_qualifiers qualifiers
```

Type: enum [`drgn_qualifiers`](drgn_qualifiers.md#drgn_qualifiers)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:180

---

{#attr_cache}

### attr_cache

```cpp
PyObject * attr_cache
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:185

