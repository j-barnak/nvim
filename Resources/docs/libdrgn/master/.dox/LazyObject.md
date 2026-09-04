{#lazyobject}

# LazyObject

```cpp
#include <drgnpy.h>
```

```cpp
struct LazyObject
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:307

## Public Attributes

| Return | Name | Description |
|--------|------|-------------|
| `PyObject_HEAD PyObject *` | [`obj`](#obj-2)  |  |
| union [`drgn_lazy_object`](drgn_lazy_object.md#drgn_lazy_object) * | [`lazy_obj`](#lazy_obj)  |  |

---

{#obj-2}

### obj

```cpp
PyObject_HEAD PyObject * obj
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:309

---

{#lazy_obj}

### lazy_obj

```cpp
union drgn_lazy_object * lazy_obj
```

Type: union [`drgn_lazy_object`](drgn_lazy_object.md#drgn_lazy_object) *

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:317

