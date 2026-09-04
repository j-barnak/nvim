{#drgn_memory_reader}

# drgn_memory_reader

```cpp
#include <memory_reader.h>
```

```cpp
struct drgn_memory_reader
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/memory_reader.h:43

Memory reader.

A memory reader maps the segments of memory in an address space to callbacks which can be used to read memory from those segments.

## Public Attributes

| Return | Name | Description |
|--------|------|-------------|
| `struct drgn_memory_segment_tree` | [`virtual_segments`](#virtual_segments)  | Virtual memory segments. |
| `struct drgn_memory_segment_tree` | [`physical_segments`](#physical_segments)  | Physical memory segments. |

---

{#virtual_segments}

### virtual_segments

```cpp
struct drgn_memory_segment_tree virtual_segments
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/memory_reader.h:45

Virtual memory segments.

---

{#physical_segments}

### physical_segments

```cpp
struct drgn_memory_segment_tree physical_segments
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/memory_reader.h:47

Physical memory segments.

