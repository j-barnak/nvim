{#objectiterator}

# ObjectIterator

```cpp
#include <drgnpy.h>
```

```cpp
struct ObjectIterator
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:229

## Public Attributes

| Return | Name | Description |
|--------|------|-------------|
| PyObject_HEAD [`DrgnObject`](DrgnObject.md#drgnobject) * | [`obj`](#obj-3)  |  |
| `uint64_t` | [`index`](#index-1)  |  |
| `uint64_t` | [`end`](#end-3)  |  |
| `int` | [`step`](#step)  |  |

---

{#obj-3}

### obj

```cpp
PyObject_HEAD DrgnObject * obj
```

Type: PyObject_HEAD [`DrgnObject`](DrgnObject.md#drgnobject) *

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:231

---

{#index-1}

### index

```cpp
uint64_t index
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:232

---

{#end-3}

### end

```cpp
uint64_t end
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:232

---

{#step}

### step

```cpp
int step
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:233

