{#drgn_memory_file_segment}

# drgn_memory_file_segment

```cpp
#include <memory_reader.h>
```

```cpp
struct drgn_memory_file_segment
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/memory_reader.h:105

Argument for [drgn_read_memory_file()](MemoryReader.md#drgn_read_memory_file).

## Public Attributes

| Return | Name | Description |
|--------|------|-------------|
| `uint64_t` | [`file_offset`](#file_offset)  | Offset in the file where the segment starts. |
| `uint64_t` | [`file_size`](#file_size)  | Size of the segment in the file. This may be less than the size of the segment in memory. |
| `int` | [`fd`](#fd-1)  | File descriptor. |
| `bool` | [`eio_is_fault`](#eio_is_fault)  | If `true`, EIO is treated as a fault. Otherwise, it is treated as an OS error. |
| `bool` | [`zerofill`](#zerofill)  | If `true`, reads between [file_size](#file_size) and the size of the segment in memory will be returned as zeroes. Otherwise, such reads will result in a fault. |

---

{#file_offset}

### file_offset

```cpp
uint64_t file_offset
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/memory_reader.h:107

Offset in the file where the segment starts.

---

{#file_size}

### file_size

```cpp
uint64_t file_size
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/memory_reader.h:112

Size of the segment in the file. This may be less than the size of the segment in memory.

---

{#fd-1}

### fd

```cpp
int fd
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/memory_reader.h:114

File descriptor.

---

{#eio_is_fault}

### eio_is_fault

```cpp
bool eio_is_fault
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/memory_reader.h:119

If `true`, EIO is treated as a fault. Otherwise, it is treated as an OS error.

---

{#zerofill}

### zerofill

```cpp
bool zerofill
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/memory_reader.h:125

If `true`, reads between [file_size](#file_size) and the size of the segment in memory will be returned as zeroes. Otherwise, such reads will result in a fault.

