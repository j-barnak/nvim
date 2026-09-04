{#memoryreader}

# Memory reader

> [`Internals`](Internals.md#internals)

Memory reading interface.

[drgn_memory_reader](drgn_memory_reader.md#drgn_memory_reader) provides a common interface for registering regions of memory in a program and reading from memory.

[drgn_memory_reader](drgn_memory_reader.md#drgn_memory_reader) does not have a notion of the maximum address or address overflow/wrap-around. Those must be handled at a higher layer.

## Classes

| Name | Description |
|------|-------------|
| [`drgn_memory_reader`](drgn_memory_reader.md#drgn_memory_reader) | Memory reader. |
| [`drgn_memory_file_segment`](drgn_memory_file_segment.md#drgn_memory_file_segment) | Argument for [drgn_read_memory_file()](#drgn_read_memory_file). |

## Functions

| Return | Name | Description |
|--------|------|-------------|
|  | [`DEFINE_BINARY_SEARCH_TREE_TYPE`](#define_binary_search_tree_type-2)  |  |
| `void` | [`drgn_memory_reader_init`](#drgn_memory_reader_init)  | Initialize a [drgn_memory_reader](drgn_memory_reader.md#drgn_memory_reader). |
| `void` | [`drgn_memory_reader_deinit`](#drgn_memory_reader_deinit)  | Deinitialize a [drgn_memory_reader](drgn_memory_reader.md#drgn_memory_reader). |
| `void` | [`drgn_memory_reader_clear`](#drgn_memory_reader_clear)  | Remove all segments from a [drgn_memory_reader](drgn_memory_reader.md#drgn_memory_reader). |
| `void` | [`drgn_memory_reader_clear_virtual`](#drgn_memory_reader_clear_virtual)  | Remove all virtual memory segments from a [drgn_memory_reader](drgn_memory_reader.md#drgn_memory_reader). |
| `bool` | [`drgn_memory_reader_empty`](#drgn_memory_reader_empty)  | Return whether a [drgn_memory_reader](drgn_memory_reader.md#drgn_memory_reader) has no segments. |
| `bool` | [`drgn_memory_reader_empty_virtual`](#drgn_memory_reader_empty_virtual)  | Return whether a [drgn_memory_reader](drgn_memory_reader.md#drgn_memory_reader) has no virtual memory segments. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_memory_reader_add_segment`](#drgn_memory_reader_add_segment)  | Add a segment to a [drgn_memory_reader](drgn_memory_reader.md#drgn_memory_reader). |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_memory_reader_read`](#drgn_memory_reader_read)  | Read from a [drgn_memory_reader](drgn_memory_reader.md#drgn_memory_reader). |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_read_memory_file`](#drgn_read_memory_file)  | [drgn_memory_read_fn](Programs.md#drgn_memory_read_fn) which reads from a file. |

---

{#define_binary_search_tree_type-2}

### DEFINE_BINARY_SEARCH_TREE_TYPE

```cpp
DEFINE_BINARY_SEARCH_TREE_TYPE(drgn_memory_segment_tree, struct drgn_memory_segment)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/memory_reader.h:34

---

{#drgn_memory_reader_init}

### drgn_memory_reader_init

```cpp
void drgn_memory_reader_init(struct drgn_memory_reader * reader)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/memory_reader.h:55

Initialize a [drgn_memory_reader](drgn_memory_reader.md#drgn_memory_reader).

The reader is initialized with no segments.

---

{#drgn_memory_reader_deinit}

### drgn_memory_reader_deinit

```cpp
void drgn_memory_reader_deinit(struct drgn_memory_reader * reader)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/memory_reader.h:58

Deinitialize a [drgn_memory_reader](drgn_memory_reader.md#drgn_memory_reader).

---

{#drgn_memory_reader_clear}

### drgn_memory_reader_clear

```cpp
void drgn_memory_reader_clear(struct drgn_memory_reader * reader)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/memory_reader.h:61

Remove all segments from a [drgn_memory_reader](drgn_memory_reader.md#drgn_memory_reader).

---

{#drgn_memory_reader_clear_virtual}

### drgn_memory_reader_clear_virtual

```cpp
void drgn_memory_reader_clear_virtual(struct drgn_memory_reader * reader)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/memory_reader.h:64

Remove all virtual memory segments from a [drgn_memory_reader](drgn_memory_reader.md#drgn_memory_reader).

---

{#drgn_memory_reader_empty}

### drgn_memory_reader_empty

```cpp
bool drgn_memory_reader_empty(struct drgn_memory_reader * reader)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/memory_reader.h:67

Return whether a [drgn_memory_reader](drgn_memory_reader.md#drgn_memory_reader) has no segments.

---

{#drgn_memory_reader_empty_virtual}

### drgn_memory_reader_empty_virtual

```cpp
bool drgn_memory_reader_empty_virtual(struct drgn_memory_reader * reader)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/memory_reader.h:70

Return whether a [drgn_memory_reader](drgn_memory_reader.md#drgn_memory_reader) has no virtual memory segments.

---

{#drgn_memory_reader_add_segment}

### drgn_memory_reader_add_segment

```cpp
struct drgn_error * drgn_memory_reader_add_segment(struct drgn_memory_reader * reader, uint64_t min_address, uint64_t max_address, drgn_memory_read_fn read_fn, void * arg, bool physical)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/memory_reader.h:84

Add a segment to a [drgn_memory_reader](drgn_memory_reader.md#drgn_memory_reader).

#### Returns
`NULL` on success, non-`NULL` on error.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `reader` | struct [`drgn_memory_reader`](drgn_memory_reader.md#drgn_memory_reader) * | Memory reader. |
| `min_address` | `uint64_t` | Start address (inclusive). |
| `max_address` | `uint64_t` | End address (inclusive). Must be `>= min_address`. |
| `read_fn` | [`drgn_memory_read_fn`](Programs.md#drgn_memory_read_fn) | Callback to read from segment. |
| `arg` | `void *` | Argument to pass to `read_fn`. |
| `physical` | `bool` | Whether to add a physical memory segment. |

---

{#drgn_memory_reader_read}

### drgn_memory_reader_read

```cpp
struct drgn_error * drgn_memory_reader_read(struct drgn_memory_reader * reader, void * buf, uint64_t address, size_t count, bool physical)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/memory_reader.h:100

Read from a [drgn_memory_reader](drgn_memory_reader.md#drgn_memory_reader).

#### Returns
`NULL` on success, non-`NULL` on error.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `reader` | struct [`drgn_memory_reader`](drgn_memory_reader.md#drgn_memory_reader) * | Memory reader. |
| `buf` | `void *` | Buffer to read into. |
| `address` | `uint64_t` | Starting address in memory to read. |
| `count` | `size_t` | Number of bytes to read. `address + count - 1` must be `<= UINT64_MAX` |
| `physical` | `bool` | Whether `address` is physical. |

---

{#drgn_read_memory_file}

### drgn_read_memory_file

```cpp
struct drgn_error * drgn_read_memory_file(void * buf, uint64_t address, size_t count, uint64_t offset, void * arg, bool physical)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/memory_reader.h:129

[drgn_memory_read_fn](Programs.md#drgn_memory_read_fn) which reads from a file.

