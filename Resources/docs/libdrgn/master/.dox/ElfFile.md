{#elffiles}

# ELF files

> [`Internals`](Internals.md#internals)

ELF file handling.

## Classes

| Name | Description |
|------|-------------|
| [`drgn_elf_file`](drgn_elf_file.md#drgn_elf_file) | An ELF file used by a [drgn_module](drgn_module.md#drgn_module). |
| [`drgn_elf_file_section_buffer`](drgn_elf_file_section_buffer.md#drgn_elf_file_section_buffer) |  |

## Macros

| Name | Description |
|------|-------------|
| [`_cleanup_elf_end_`](#_cleanup_elf_end_)  |  |

---

{#_cleanup_elf_end_}

### _cleanup_elf_end_

```cpp
#define _cleanup_elf_end_ __attribute__((__cleanup__(elf_endp)))
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/elf_file.h:38

## Functions

| Return | Name | Description |
|--------|------|-------------|
| `void` | [`elf_endp`](#elf_endp) `static` `inline` |  |
| `void` | [`truncate_elf_string_data`](#truncate_elf_string_data)  | Truncate any bytes beyond the last null character in an ELF string table. |
| `bool` | [`elf_data_contains_ptr`](#elf_data_contains_ptr) `static` `inline` |  |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_elf_file_create`](#drgn_elf_file_create)  | Create a [drgn_elf_file](drgn_elf_file.md#drgn_elf_file). |
| `void` | [`drgn_elf_file_destroy`](#drgn_elf_file_destroy)  |  |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_elf_file_read_section`](#drgn_elf_file_read_section)  | Read the raw data from an ELF section, decompressing it first if it is compressed. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_elf_file_read_cached_section`](#drgn_elf_file_read_cached_section)  | Read a cached ELF section. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_elf_file_get_dwarf`](#drgn_elf_file_get_dwarf)  |  |
| `bool` | [`drgn_elf_file_is_little_endian`](#drgn_elf_file_is_little_endian) `static` `inline` |  |
| `bool` | [`drgn_elf_file_bswap`](#drgn_elf_file_bswap) `static` `inline` |  |
| `bool` | [`drgn_elf_file_is_64_bit`](#drgn_elf_file_is_64_bit) `static` `inline` |  |
| `uint8_t` | [`drgn_elf_file_address_size`](#drgn_elf_file_address_size) `static` `inline` |  |
| `uint64_t` | [`drgn_elf_file_address_mask`](#drgn_elf_file_address_mask) `static` `inline` |  |
| `bool` | [`drgn_elf_file_has_dwarf`](#drgn_elf_file_has_dwarf) `static` `inline` |  |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_elf_file_section_error`](#drgn_elf_file_section_error)  |  |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_elf_file_section_errorf`](#drgn_elf_file_section_errorf)  |  |
| struct [`drgn_error`](drgn_error.md#drgn_error) | [`__format__`](#__format__-2)  |  |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_elf_file_section_buffer_error`](#drgn_elf_file_section_buffer_error)  |  |
| `void` | [`drgn_elf_file_section_buffer_init`](#drgn_elf_file_section_buffer_init) `static` `inline` |  |
| `void` | [`drgn_elf_file_section_buffer_init_index`](#drgn_elf_file_section_buffer_init_index) `static` `inline` | Initialize a [binary_buffer](binary_buffer.md#binary_buffer) for a cached ELF section that has already been read. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_elf_file_section_buffer_read`](#drgn_elf_file_section_buffer_read) `static` `inline` | Read a cached ELF section (applying ELF relocations if needed) and initialize a [binary_buffer](binary_buffer.md#binary_buffer) for it. |
| `bool` | [`drgn_elf_file_address_range`](#drgn_elf_file_address_range)  | Return the virtual address range of an ELF file. |
| `int` | [`elf_is_vmlinux`](#elf_is_vmlinux)  | Return whether an ELF file is a vmlinux file. |
| `ssize_t` | [`elf_vmlinux_release`](#elf_vmlinux_release)  | Get the Linux release from a vmlinux file. |

---

{#elf_endp}

### elf_endp

`static` `inline`

```cpp
static inline void elf_endp(Elf ** elfp)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/elf_file.h:39

---

{#truncate_elf_string_data}

### truncate_elf_string_data

```cpp
void truncate_elf_string_data(Elf_Data * data)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/elf_file.h:50

Truncate any bytes beyond the last null character in an ELF string table.

This sets `data->d_size` so that any string table index less than `data->d_size` is guaranteed to be valid.

---

{#elf_data_contains_ptr}

### elf_data_contains_ptr

`static` `inline`

```cpp
static inline bool elf_data_contains_ptr(Elf_Data * data, const void * ptr)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/elf_file.h:52

---

{#drgn_elf_file_create}

### drgn_elf_file_create

```cpp
struct drgn_error * drgn_elf_file_create(struct drgn_module * module, const char * path, int fd, char * image, Elf * elf, struct drgn_elf_file ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/elf_file.h:135

Create a [drgn_elf_file](drgn_elf_file.md#drgn_elf_file).

On success, this takes ownership of `fd`, `image`, and `elf`. `path` is copied.

---

{#drgn_elf_file_destroy}

### drgn_elf_file_destroy

```cpp
void drgn_elf_file_destroy(struct drgn_elf_file * file)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/elf_file.h:139

---

{#drgn_elf_file_read_section}

### drgn_elf_file_read_section

```cpp
struct drgn_error * drgn_elf_file_read_section(struct drgn_elf_file * file, Elf_Scn * scn, bool apply_relocations, Elf_Data ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/elf_file.h:150

Read the raw data from an ELF section, decompressing it first if it is compressed.

This returns an error if the section type is `SHT_NOBITS`.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `apply_relocations` | `bool` | Whether to apply ELF relocations to the file first. |

---

{#drgn_elf_file_read_cached_section}

### drgn_elf_file_read_cached_section

```cpp
struct drgn_error * drgn_elf_file_read_cached_section(struct drgn_elf_file * file, enum drgn_section_index scn, Elf_Data ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/elf_file.h:161

Read a cached ELF section.

This applies ELF relocations to the file first if needed.

---

{#drgn_elf_file_get_dwarf}

### drgn_elf_file_get_dwarf

```cpp
struct drgn_error * drgn_elf_file_get_dwarf(struct drgn_elf_file * file, Dwarf ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/elf_file.h:164

---

{#drgn_elf_file_is_little_endian}

### drgn_elf_file_is_little_endian

`static` `inline`

```cpp
static inline bool drgn_elf_file_is_little_endian(const struct drgn_elf_file * file)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/elf_file.h:168

---

{#drgn_elf_file_bswap}

### drgn_elf_file_bswap

`static` `inline`

```cpp
static inline bool drgn_elf_file_bswap(const struct drgn_elf_file * file)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/elf_file.h:173

---

{#drgn_elf_file_is_64_bit}

### drgn_elf_file_is_64_bit

`static` `inline`

```cpp
static inline bool drgn_elf_file_is_64_bit(const struct drgn_elf_file * file)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/elf_file.h:179

---

{#drgn_elf_file_address_size}

### drgn_elf_file_address_size

`static` `inline`

```cpp
static inline uint8_t drgn_elf_file_address_size(const struct drgn_elf_file * file)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/elf_file.h:185

---

{#drgn_elf_file_address_mask}

### drgn_elf_file_address_mask

`static` `inline`

```cpp
static inline uint64_t drgn_elf_file_address_mask(const struct drgn_elf_file * file)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/elf_file.h:191

---

{#drgn_elf_file_has_dwarf}

### drgn_elf_file_has_dwarf

`static` `inline`

```cpp
static inline bool drgn_elf_file_has_dwarf(const struct drgn_elf_file * file)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/elf_file.h:196

---

{#drgn_elf_file_section_error}

### drgn_elf_file_section_error

```cpp
struct drgn_error * drgn_elf_file_section_error(struct drgn_elf_file * file, Elf_Scn * scn, Elf_Data * data, const char * ptr, const char * message)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/elf_file.h:203

---

{#drgn_elf_file_section_errorf}

### drgn_elf_file_section_errorf

```cpp
struct drgn_error * drgn_elf_file_section_errorf(struct drgn_elf_file * file, Elf_Scn * scn, Elf_Data * data, const char * ptr, const char * format, ...)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/elf_file.h:209

---

{#__format__-2}

### __format__

```cpp
struct drgn_error __format__(__printf__, 5, 6)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/elf_file.h:212

---

{#drgn_elf_file_section_buffer_error}

### drgn_elf_file_section_buffer_error

```cpp
struct drgn_error * drgn_elf_file_section_buffer_error(struct binary_buffer * bb, const char * ptr, const char * message)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/elf_file.h:221

---

{#drgn_elf_file_section_buffer_init}

### drgn_elf_file_section_buffer_init

`static` `inline`

```cpp
static inline void drgn_elf_file_section_buffer_init(struct drgn_elf_file_section_buffer * buffer, struct drgn_elf_file * file, Elf_Scn * scn, Elf_Data * data)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/elf_file.h:226

---

{#drgn_elf_file_section_buffer_init_index}

### drgn_elf_file_section_buffer_init_index

`static` `inline`

```cpp
static inline void drgn_elf_file_section_buffer_init_index(struct drgn_elf_file_section_buffer * buffer, struct drgn_elf_file * file, enum drgn_section_index scn)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/elf_file.h:243

Initialize a [binary_buffer](binary_buffer.md#binary_buffer) for a cached ELF section that has already been read.

---

{#drgn_elf_file_section_buffer_read}

### drgn_elf_file_section_buffer_read

`static` `inline`

```cpp
static inline struct drgn_error * drgn_elf_file_section_buffer_read(struct drgn_elf_file_section_buffer * buffer, struct drgn_elf_file * file, enum drgn_section_index scn)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/elf_file.h:256

Read a cached ELF section (applying ELF relocations if needed) and initialize a [binary_buffer](binary_buffer.md#binary_buffer) for it.

---

{#drgn_elf_file_address_range}

### drgn_elf_file_address_range

```cpp
bool drgn_elf_file_address_range(struct drgn_elf_file * file, uint64_t * start_ret, uint64_t * end_ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/elf_file.h:275

Return the virtual address range of an ELF file.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `start_ret` | `uint64_t *` | Minimum virtual address (inclusive). |
| `end_ret` | `uint64_t *` | Maximum virtual address (exclusive). |

---

{#elf_is_vmlinux}

### elf_is_vmlinux

```cpp
int elf_is_vmlinux(Elf * elf)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/elf_file.h:283

Return whether an ELF file is a vmlinux file.

#### Returns
> 0 if the file is vmlinux, 0 if it is not, < 0 on libelf error.

---

{#elf_vmlinux_release}

### elf_vmlinux_release

```cpp
ssize_t elf_vmlinux_release(Elf * elf, const char ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/elf_file.h:291

Get the Linux release from a vmlinux file.

#### Returns
Length of `ret` on success, 0 if not found, < 0 on libelf error.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `ret` | `const char **` | Returned release. |

