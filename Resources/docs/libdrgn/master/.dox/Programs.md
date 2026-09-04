{#programs}

# Programs

Debugging programs.

A program being debugged is represented by a [drgn_program](drgn_program.md#drgn_program).

## Groups

| Name | Description |
|------|-------------|
| [`Memory searches`](MemorySearches.md#memorysearches) | Searching program memory for values or patterns. |

## Classes

| Name | Description |
|------|-------------|
| [`drgn_type_finder_ops`](drgn_type_finder_ops.md#drgn_type_finder_ops) | Type finder callback table. |
| [`drgn_object_finder_ops`](drgn_object_finder_ops.md#drgn_object_finder_ops) | Object finder callback table. |
| [`drgn_symbol_finder_ops`](drgn_symbol_finder_ops.md#drgn_symbol_finder_ops) | [Symbol](Symbol.md#symbol) finder callback table. |
| [`drgn_symbol`](drgn_symbol.md#drgn_symbol) | A [drgn_symbol](drgn_symbol.md#drgn_symbol) represents an entry in a program's symbol table. |

## Enumerations

| Name | Description |
|------|-------------|
| [`drgn_program_flags`](#drgn_program_flags)  | Flags which apply to a [drgn_program](drgn_program.md#drgn_program). |
| [``](#unknown-5)  |  |
| [`drgn_find_object_flags`](#drgn_find_object_flags)  | Flags for [drgn_program_find_object()](#drgn_program_find_object). |
| [`drgn_find_symbol_flags`](#drgn_find_symbol_flags)  | Flags for [drgn_symbol_finder_ops::find()](drgn_symbol_finder_ops.md#find-3) |

---

{#drgn_program_flags}

### drgn_program_flags

```cpp
enum drgn_program_flags
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:534

Flags which apply to a [drgn_program](drgn_program.md#drgn_program).

| Value | Description |
|-------|-------------|
| `DRGN_PROGRAM_IS_LINUX_KERNEL` | The program is the Linux kernel. |
| `DRGN_PROGRAM_IS_LIVE` | The program is currently running. |
| `DRGN_PROGRAM_IS_LOCAL` | The program is running on the local machine. |

---

{#unknown-5}

### 

```cpp
enum 
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:612

| Value | Description |
|-------|-------------|
| `DRGN_HANDLER_REGISTER_ENABLE_LAST` | Enable a handler after all enabled handlers. |
| `DRGN_HANDLER_REGISTER_DONT_ENABLE` | Don't enable a handler. |

---

{#drgn_find_object_flags}

### drgn_find_object_flags

```cpp
enum drgn_find_object_flags
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:706

Flags for [drgn_program_find_object()](#drgn_program_find_object).

| Value | Description |
|-------|-------------|
| `DRGN_FIND_OBJECT_CONSTANT` | Find a constant (e.g., enumeration constant or macro). |
| `DRGN_FIND_OBJECT_FUNCTION` | Find a function. |
| `DRGN_FIND_OBJECT_VARIABLE` | Find a variable. |
| `DRGN_FIND_OBJECT_ANY` | Find any kind of object. |

---

{#drgn_find_symbol_flags}

### drgn_find_symbol_flags

```cpp
enum drgn_find_symbol_flags
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:1314

Flags for [drgn_symbol_finder_ops::find()](drgn_symbol_finder_ops.md#find-3)

| Value | Description |
|-------|-------------|
| `DRGN_FIND_SYMBOL_NAME` | Find symbols whose name matches the name argument |
| `DRGN_FIND_SYMBOL_ADDR` | Find symbols whose address matches the addr argument |
| `DRGN_FIND_SYMBOL_ONE` | Find only one symbol |
## Typedefs

| Return | Name | Description |
|--------|------|-------------|
| struct [`drgn_error`](drgn_error.md#drgn_error) *(* | [`drgn_memory_read_fn`](#drgn_memory_read_fn)  | Callback implementing a memory read. |

---

{#drgn_memory_read_fn}

### drgn_memory_read_fn

```cpp
using drgn_memory_read_fn = struct drgn_error *(*
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:563

Callback implementing a memory read.

#### Returns
`NULL` on success, non-`NULL` on error.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `buf` |  | Buffer to read into. |
| `address` |  | Address which we are reading from. |
| `count` |  | Number of bytes to read. |
| `offset` |  | Offset in bytes of `address` from the beginning of the segment. |
| `arg` |  | Argument passed to [drgn_program_add_memory_segment()](#drgn_program_add_memory_segment). |
| `physical` |  | Whether `address` is physical. |

## Functions

| Return | Name | Description |
|--------|------|-------------|
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_program_add_memory_segment`](#drgn_program_add_memory_segment)  | [Register](Register.md#register) a segment of memory in a [drgn_program](drgn_program.md#drgn_program). |
| `bool` | [`drgn_filename_matches`](#drgn_filename_matches)  | Return whether a filename containing a definition (`haystack`) matches a filename being searched for (`needle`). |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_program_register_type_finder`](#drgn_program_register_type_finder)  | [Register](Register.md#register) a type finding callback. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_program_registered_type_finders`](#drgn_program_registered_type_finders)  | Get the names of all registered type finders. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_program_set_enabled_type_finders`](#drgn_program_set_enabled_type_finders)  | Set the list of enabled type finders. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_program_enabled_type_finders`](#drgn_program_enabled_type_finders)  | Get the names of enabled type finders, in order. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_program_register_object_finder`](#drgn_program_register_object_finder)  | [Register](Register.md#register) an object finding callback. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_program_registered_object_finders`](#drgn_program_registered_object_finders)  | Get the names of all registered object finders. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_program_set_enabled_object_finders`](#drgn_program_set_enabled_object_finders)  | Set the list of enabled object finders. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_program_enabled_object_finders`](#drgn_program_enabled_object_finders)  | Get the names of enabled object finders, in order. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_program_set_core_dump`](#drgn_program_set_core_dump)  | Set a [drgn_program](drgn_program.md#drgn_program) to a core dump. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_program_set_core_dump_fd`](#drgn_program_set_core_dump_fd)  | Set a [drgn_program](drgn_program.md#drgn_program) to a core dump from a file descriptor. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_program_set_kernel`](#drgn_program_set_kernel)  | Set a [drgn_program](drgn_program.md#drgn_program) to the running operating system kernel. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_program_set_linux_kernel_custom`](#drgn_program_set_linux_kernel_custom)  | Set a [drgn_program](drgn_program.md#drgn_program) to a custom Linux kernel target. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_program_set_pid`](#drgn_program_set_pid)  | Set a [drgn_program](drgn_program.md#drgn_program) to a running process. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_program_from_core_dump`](#drgn_program_from_core_dump)  | Create a [drgn_program](drgn_program.md#drgn_program) from a core dump file. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_program_from_core_dump_fd`](#drgn_program_from_core_dump_fd)  | Create a [drgn_program](drgn_program.md#drgn_program) from a core dump file descriptor. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_program_from_kernel`](#drgn_program_from_kernel)  | Create a [drgn_program](drgn_program.md#drgn_program) from the running operating system kernel. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_program_from_pid`](#drgn_program_from_pid)  | Create a [drgn_program](drgn_program.md#drgn_program) from the a running program. |
| enum [`drgn_program_flags`](drgn_program_flags.md#drgn_program_flags) | [`drgn_program_flags`](#drgn_program_flags-1)  | Get the set of [drgn_program_flags](drgn_program_flags.md#drgn_program_flags) applying to a [drgn_program](drgn_program.md#drgn_program). |
| const struct [`drgn_platform`](drgn_platform.md#drgn_platform) * | [`drgn_program_platform`](#drgn_program_platform)  | Get the platform of a [drgn_program](drgn_program.md#drgn_program). |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_program_address_size`](#drgn_program_address_size)  | Get the size of an address in a [drgn_program](drgn_program.md#drgn_program). |
| `const char *` | [`drgn_program_core_dump_path`](#drgn_program_core_dump_path)  | Get the path of the core dump that a [drgn_program](drgn_program.md#drgn_program) was created from. |
| const struct [`drgn_language`](drgn_language.md#drgn_language) * | [`drgn_program_language`](#drgn_program_language)  | Get the default language of a [drgn_program](drgn_program.md#drgn_program). |
| `void` | [`drgn_program_set_language`](#drgn_program_set_language)  | Set the default language of a [drgn_program](drgn_program.md#drgn_program). |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_program_read_memory`](#drgn_program_read_memory)  | Read from a program's memory. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_program_read_c_string`](#drgn_program_read_c_string)  | Read a C string from a program's memory. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_program_read_u8`](#drgn_program_read_u8)  |  |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_program_read_u16`](#drgn_program_read_u16)  |  |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_program_read_u32`](#drgn_program_read_u32)  |  |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_program_read_u64`](#drgn_program_read_u64)  |  |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_program_read_word`](#drgn_program_read_word)  |  |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_program_find_type`](#drgn_program_find_type)  | Find a type in a program by name. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_program_find_object`](#drgn_program_find_object)  | Find an object in a program by name. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_program_find_symbol_by_address`](#drgn_program_find_symbol_by_address)  | Get the symbol containing the given address. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_program_find_symbol_by_name`](#drgn_program_find_symbol_by_name)  | Get the symbol corresponding to the given name. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_program_find_symbols_by_name`](#drgn_program_find_symbols_by_name)  | Get all global and local symbols, optionally with the given name. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_program_find_symbols_by_address`](#drgn_program_find_symbols_by_address)  | Get all symbols containing the given address. |
| `bool` | [`drgn_symbol_result_builder_add`](#drgn_symbol_result_builder_add)  | Add or set the return value for a symbol search |
| `size_t` | [`drgn_symbol_result_builder_count`](#drgn_symbol_result_builder_count)  | Get the current number of results in a symbol search result. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_program_register_symbol_finder`](#drgn_program_register_symbol_finder)  | [Register](Register.md#register) a symbol finding callback. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_program_registered_symbol_finders`](#drgn_program_registered_symbol_finders)  | Get the names of all registered symbol finders. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_program_set_enabled_symbol_finders`](#drgn_program_set_enabled_symbol_finders)  | Set the list of enabled symbol finders. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_program_enabled_symbol_finders`](#drgn_program_enabled_symbol_finders)  | Get the names of enabled symbol finders, in order. |

---

{#drgn_program_add_memory_segment}

### drgn_program_add_memory_segment

```cpp
struct drgn_error * drgn_program_add_memory_segment(struct drgn_program * prog, uint64_t address, uint64_t size, drgn_memory_read_fn read_fn, void * arg, bool physical)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:596

[Register](Register.md#register) a segment of memory in a [drgn_program](drgn_program.md#drgn_program).

If the segment overlaps a previously registered segment, the new segment takes precedence. If any part of the segment is beyond the maximum address, that part is ignored.

#### Returns
`NULL` on success, non-`NULL` on error.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `address` | `uint64_t` | Address of the segment. |
| `size` | `uint64_t` | Size of the segment in bytes. |
| `read_fn` | [`drgn_memory_read_fn`](#drgn_memory_read_fn) | Callback to read from segment. |
| `arg` | `void *` | Argument to pass to `read_fn`. |
| `physical` | `bool` | Whether to add a physical memory segment. |

---

{#drgn_filename_matches}

### drgn_filename_matches

```cpp
bool drgn_filename_matches(const char * haystack, const char * needle)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:610

Return whether a filename containing a definition (`haystack`) matches a filename being searched for (`needle`).

The path is matched from right to left, so a definition in `/usr/include/stdio.h` will match `stdio.h`, `include/stdio.h`, `usr/include/stdio.h`, and `/usr/include/stdio.h`. An empty or `NULL``needle` matches any `haystack`.

---

{#drgn_program_register_type_finder}

### drgn_program_register_type_finder

```cpp
struct drgn_error * drgn_program_register_type_finder(struct drgn_program * prog, const char * name, const struct drgn_type_finder_ops * ops, void * arg, size_t enable_index)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:665

[Register](Register.md#register) a type finding callback.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `name` | `const char *` | Finder name. This is copied. |
| `ops` | const struct [`drgn_type_finder_ops`](drgn_type_finder_ops.md#drgn_type_finder_ops) * | Callback table. This is copied. |
| `arg` | `void *` | Argument to pass to callbacks. |
| `enable_index` | `size_t` | Insert the finder into the list of enabled finders at the given index. If [DRGN_HANDLER_REGISTER_ENABLE_LAST](#group__Programs_1gga106ab5141fe935134e70ab83c0689759a8d7b573f89ffb2ef07a718cb778df021) or greater than the number of enabled finders, insert it at the end. If [DRGN_HANDLER_REGISTER_DONT_ENABLE](#group__Programs_1gga106ab5141fe935134e70ab83c0689759ac8bf815074393b125e389935aeb94870), don’t enable the finder. |

---

{#drgn_program_registered_type_finders}

### drgn_program_registered_type_finders

```cpp
struct drgn_error * drgn_program_registered_type_finders(struct drgn_program * prog, const char *** names_ret, size_t * count_ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:678

Get the names of all registered type finders.

The order of the names is arbitrary.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `names_ret` | `const char ***` | Returned array of names. |
| `count_ret` | `size_t *` | Returned number of names in `names_ret`. |

---

{#drgn_program_set_enabled_type_finders}

### drgn_program_set_enabled_type_finders

```cpp
struct drgn_error * drgn_program_set_enabled_type_finders(struct drgn_program * prog, const char *const * names, size_t count)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:691

Set the list of enabled type finders.

Finders are called in the same order as the list until a type is found.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `names` | `const char *const *` | Names of finders to enable, in order. |
| `count` | `size_t` | Number of names in `names`. |

---

{#drgn_program_enabled_type_finders}

### drgn_program_enabled_type_finders

```cpp
struct drgn_error * drgn_program_enabled_type_finders(struct drgn_program * prog, const char *** names_ret, size_t * count_ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:701

Get the names of enabled type finders, in order.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `names_ret` | `const char ***` | Returned array of names. |
| `count_ret` | `size_t *` | Returned number of names in `names_ret`. |

---

{#drgn_program_register_object_finder}

### drgn_program_register_object_finder

```cpp
struct drgn_error * drgn_program_register_object_finder(struct drgn_program * prog, const char * name, const struct drgn_object_finder_ops * ops, void * arg, size_t enable_index)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:762

[Register](Register.md#register) an object finding callback.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `name` | `const char *` | Finder name. This is copied. |
| `ops` | const struct [`drgn_object_finder_ops`](drgn_object_finder_ops.md#drgn_object_finder_ops) * | Callback table. This is copied. |
| `arg` | `void *` | Argument to pass to callbacks. |
| `enable_index` | `size_t` | Insert the finder into the list of enabled finders at the given index. If [DRGN_HANDLER_REGISTER_ENABLE_LAST](#group__Programs_1gga106ab5141fe935134e70ab83c0689759a8d7b573f89ffb2ef07a718cb778df021) or greater than the number of enabled finders, insert it at the end. If [DRGN_HANDLER_REGISTER_DONT_ENABLE](#group__Programs_1gga106ab5141fe935134e70ab83c0689759ac8bf815074393b125e389935aeb94870), don’t enable the finder. |

---

{#drgn_program_registered_object_finders}

### drgn_program_registered_object_finders

```cpp
struct drgn_error * drgn_program_registered_object_finders(struct drgn_program * prog, const char *** names_ret, size_t * count_ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:775

Get the names of all registered object finders.

The order of the names is arbitrary.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `names_ret` | `const char ***` | Returned array of names. |
| `count_ret` | `size_t *` | Returned number of names in `names_ret`. |

---

{#drgn_program_set_enabled_object_finders}

### drgn_program_set_enabled_object_finders

```cpp
struct drgn_error * drgn_program_set_enabled_object_finders(struct drgn_program * prog, const char *const * names, size_t count)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:788

Set the list of enabled object finders.

Finders are called in the same order as the list until a object is found.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `names` | `const char *const *` | Names of finders to enable, in order. |
| `count` | `size_t` | Number of names in `names`. |

---

{#drgn_program_enabled_object_finders}

### drgn_program_enabled_object_finders

```cpp
struct drgn_error * drgn_program_enabled_object_finders(struct drgn_program * prog, const char *** names_ret, size_t * count_ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:799

Get the names of enabled object finders, in order.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `names_ret` | `const char ***` | Returned array of names. |
| `count_ret` | `size_t *` | Returned number of names in `names_ret`. |

---

{#drgn_program_set_core_dump}

### drgn_program_set_core_dump

```cpp
struct drgn_error * drgn_program_set_core_dump(struct drgn_program * prog, const char * path)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:810

Set a [drgn_program](drgn_program.md#drgn_program) to a core dump.

**See also**: [drgn_program_from_core_dump()](#drgn_program_from_core_dump)

#### Returns
`NULL` on success, non-`NULL` on error.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `path` | `const char *` | Core dump file path. |

---

{#drgn_program_set_core_dump_fd}

### drgn_program_set_core_dump_fd

```cpp
struct drgn_error * drgn_program_set_core_dump_fd(struct drgn_program * prog, int fd)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:819

Set a [drgn_program](drgn_program.md#drgn_program) to a core dump from a file descriptor.

#### Returns
`NULL` on success, non-`NULL` on error.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `fd` | `int` | Core dump file descriptor. |

---

{#drgn_program_set_kernel}

### drgn_program_set_kernel

```cpp
struct drgn_error * drgn_program_set_kernel(struct drgn_program * prog)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:826

Set a [drgn_program](drgn_program.md#drgn_program) to the running operating system kernel.

#### Returns
`NULL` on success, non-`NULL` on error.

---

{#drgn_program_set_linux_kernel_custom}

### drgn_program_set_linux_kernel_custom

```cpp
struct drgn_error * drgn_program_set_linux_kernel_custom(struct drgn_program * prog, const char * vmcoreinfo, size_t vmcoreinfo_size, bool is_live)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:846

Set a [drgn_program](drgn_program.md#drgn_program) to a custom Linux kernel target.

This enables debugging a Linux kernel via a custom memory transport (e.g., RDMA, TCP/IP, or VMM introspection). It sets up page table walking for virtual address translation.

Physical memory segment(s) must be registered via [drgn_program_add_memory_segment()](#drgn_program_add_memory_segment) with physical=true before reading memory. [Platform](Platform.md#platform-2) must be set when creating the program.

#### Returns
`NULL` on success, non-`NULL` on error.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `vmcoreinfo` | `const char *` | Raw vmcoreinfo data. If vmcoreinfo was already set when creating the program, this is ignored. |
| `vmcoreinfo_size` | `size_t` | Size of vmcoreinfo data in bytes. |
| `is_live` | `bool` | Whether the kernel is currently running. |

---

{#drgn_program_set_pid}

### drgn_program_set_pid

```cpp
struct drgn_error * drgn_program_set_pid(struct drgn_program * prog, pid_t pid)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:858

Set a [drgn_program](drgn_program.md#drgn_program) to a running process.

**See also**: [drgn_program_from_pid()](#drgn_program_from_pid)

#### Returns
`NULL` on success, non-`NULL` on error.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `pid` | `pid_t` | Process ID. |

---

{#drgn_program_from_core_dump}

### drgn_program_from_core_dump

```cpp
struct drgn_error * drgn_program_from_core_dump(const char * path, struct drgn_program ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:889

Create a [drgn_program](drgn_program.md#drgn_program) from a core dump file.

The type of program (e.g., userspace or kernel) is determined automatically.

#### Returns
`NULL` on success, non-`NULL` on error.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `path` | `const char *` | Core dump file path. |
| `ret` | struct [`drgn_program`](drgn_program.md#drgn_program) ** | Returned program. |

---

{#drgn_program_from_core_dump_fd}

### drgn_program_from_core_dump_fd

```cpp
struct drgn_error * drgn_program_from_core_dump_fd(int fd, struct drgn_program ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:902

Create a [drgn_program](drgn_program.md#drgn_program) from a core dump file descriptor.

Same as [drgn_program_from_core_dump](#drgn_program_from_core_dump) but with an already-opened file descriptor.

#### Returns
`NULL` on success, non-`NULL` on error.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `fd` | `int` | Core dump file path descriptor. |
| `ret` | struct [`drgn_program`](drgn_program.md#drgn_program) ** | Returned program. |

---

{#drgn_program_from_kernel}

### drgn_program_from_kernel

```cpp
struct drgn_error * drgn_program_from_kernel(struct drgn_program ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:913

Create a [drgn_program](drgn_program.md#drgn_program) from the running operating system kernel.

This requires root privileges.

#### Returns
`NULL` on success, non-`NULL` on error.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `ret` | struct [`drgn_program`](drgn_program.md#drgn_program) ** | Returned program. |

---

{#drgn_program_from_pid}

### drgn_program_from_pid

```cpp
struct drgn_error * drgn_program_from_pid(pid_t pid, struct drgn_program ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:925

Create a [drgn_program](drgn_program.md#drgn_program) from the a running program.

On Linux, this requires `PTRACE_MODE_ATTACH_FSCREDS` permissions (see `ptrace(2)`).

#### Returns
`NULL` on success, non-`NULL` on error.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `pid` | `pid_t` | Process ID of the program to debug. |
| `ret` | struct [`drgn_program`](drgn_program.md#drgn_program) ** | Returned program. |

---

{#drgn_program_flags-1}

### drgn_program_flags

```cpp
enum drgn_program_flags drgn_program_flags(struct drgn_program * prog)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:928

Get the set of [drgn_program_flags](drgn_program_flags.md#drgn_program_flags) applying to a [drgn_program](drgn_program.md#drgn_program).

---

{#drgn_program_platform}

### drgn_program_platform

```cpp
const struct drgn_platform * drgn_program_platform(struct drgn_program * prog)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:937

Get the platform of a [drgn_program](drgn_program.md#drgn_program).

This remains valid until the program is destroyed. It should *not* be destroyed with [drgn_platform_destroy()](Platforms.md#drgn_platform_destroy). 
#### Returns
non-`NULL` on success, `NULL` if the platform is not known yet.

---

{#drgn_program_address_size}

### drgn_program_address_size

```cpp
struct drgn_error * drgn_program_address_size(struct drgn_program * prog, uint64_t * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:944

Get the size of an address in a [drgn_program](drgn_program.md#drgn_program).

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `ret` | `uint64_t *` | Returned address size, in bytes. |

---

{#drgn_program_core_dump_path}

### drgn_program_core_dump_path

```cpp
const char * drgn_program_core_dump_path(struct drgn_program * prog)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:953

Get the path of the core dump that a [drgn_program](drgn_program.md#drgn_program) was created from.

#### Returns
Path which is valid until the program is destroyed, or `NULL` if the program was not created from a core dump.

---

{#drgn_program_language}

### drgn_program_language

```cpp
const struct drgn_language * drgn_program_language(struct drgn_program * prog)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:956

Get the default language of a [drgn_program](drgn_program.md#drgn_program).

---

{#drgn_program_set_language}

### drgn_program_set_language

```cpp
void drgn_program_set_language(struct drgn_program * prog, const struct drgn_language * lang)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:959

Set the default language of a [drgn_program](drgn_program.md#drgn_program).

---

{#drgn_program_read_memory}

### drgn_program_read_memory

```cpp
struct drgn_error * drgn_program_read_memory(struct drgn_program * prog, void * buf, uint64_t address, size_t count, bool physical)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:973

Read from a program's memory.

#### Returns
`NULL` on success, non-`NULL` on error.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `prog` | struct [`drgn_program`](drgn_program.md#drgn_program) * | [Program](Program.md#program) to read from. |
| `buf` | `void *` | Buffer to read into. |
| `address` | `uint64_t` | Starting address in memory to read. |
| `count` | `size_t` | Number of bytes to read. |
| `physical` | `bool` | Whether `address` is physical. A program may support only virtual or physical addresses or both. |

---

{#drgn_program_read_c_string}

### drgn_program_read_c_string

```cpp
struct drgn_error * drgn_program_read_c_string(struct drgn_program * prog, uint64_t address, bool physical, size_t max_size, char ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:992

Read a C string from a program's memory.

This reads up to and including the terminating null byte.

#### Returns
`NULL` on success, non-`NULL` on error.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `prog` | struct [`drgn_program`](drgn_program.md#drgn_program) * | [Program](Program.md#program) to read from. |
| `address` | `uint64_t` | Starting address in memory to read. |
| `physical` | `bool` | Whether `address` is physical. See [drgn_program_read_memory()](#drgn_program_read_memory). |
| `max_size` | `size_t` | Stop after this many bytes are read, not including the null byte. A null byte is appended to `ret` in this case. |
| `ret` | `char **` | Returned string. On success, it must be freed with `free()`. On error, it is not modified. |

---

{#drgn_program_read_u8}

### drgn_program_read_u8

```cpp
struct drgn_error * drgn_program_read_u8(struct drgn_program * prog, uint64_t address, bool physical, uint8_t * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:996

---

{#drgn_program_read_u16}

### drgn_program_read_u16

```cpp
struct drgn_error * drgn_program_read_u16(struct drgn_program * prog, uint64_t address, bool physical, uint16_t * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:1000

---

{#drgn_program_read_u32}

### drgn_program_read_u32

```cpp
struct drgn_error * drgn_program_read_u32(struct drgn_program * prog, uint64_t address, bool physical, uint32_t * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:1004

---

{#drgn_program_read_u64}

### drgn_program_read_u64

```cpp
struct drgn_error * drgn_program_read_u64(struct drgn_program * prog, uint64_t address, bool physical, uint64_t * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:1008

---

{#drgn_program_read_word}

### drgn_program_read_word

```cpp
struct drgn_error * drgn_program_read_word(struct drgn_program * prog, uint64_t address, bool physical, uint64_t * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:1012

---

{#drgn_program_find_type}

### drgn_program_find_type

```cpp
struct drgn_error * drgn_program_find_type(struct drgn_program * prog, const char * name, const char * filename, struct drgn_qualified_type * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:1226

Find a type in a program by name.

The returned type is valid for the lifetime of the [drgn_program](drgn_program.md#drgn_program).

#### Returns
`NULL` on success, non-`NULL` on error.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `prog` | struct [`drgn_program`](drgn_program.md#drgn_program) * | [Program](Program.md#program). |
| `name` | `const char *` | Name of the type. |
| `filename` | `const char *` | Filename containing the type definition. This is matched with [drgn_filename_matches()](#drgn_filename_matches). If multiple definitions match, one is returned arbitrarily. |
| `ret` | struct [`drgn_qualified_type`](drgn_qualified_type.md#drgn_qualified_type) * | Returned type. |

---

{#drgn_program_find_object}

### drgn_program_find_object

```cpp
struct drgn_error * drgn_program_find_object(struct drgn_program * prog, const char * name, const char * filename, enum drgn_find_object_flags flags, struct drgn_object * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:1246

Find an object in a program by name.

The object can be a variable, constant, or function depending on `flags`.

#### Returns
`NULL` on success, non-`NULL` on error.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `prog` | struct [`drgn_program`](drgn_program.md#drgn_program) * | [Program](Program.md#program). |
| `name` | `const char *` | Name of the object. |
| `filename` | `const char *` | Filename containing the object definition. This is matched with [drgn_filename_matches()](#drgn_filename_matches). If multiple definitions match, one is returned arbitrarily. |
| `flags` | enum [`drgn_find_object_flags`](drgn_find_object_flags.md#drgn_find_object_flags) | Flags indicating what kind of object to look for. |
| `ret` | struct [`drgn_object`](drgn_object.md#drgn_object-1) * | Returned object. This must have already been initialized with [drgn_object_init()](Objects.md#drgn_object_init). |

---

{#drgn_program_find_symbol_by_address}

### drgn_program_find_symbol_by_address

```cpp
struct drgn_error * drgn_program_find_symbol_by_address(struct drgn_program * prog, uint64_t address, struct drgn_symbol ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:1269

Get the symbol containing the given address.

#### Returns
`NULL` on success, non-`NULL` on error.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `ret` | struct [`drgn_symbol`](drgn_symbol.md#drgn_symbol) ** | The returned symbol. It should be freed with [drgn_symbol_destroy()](Symbols.md#drgn_symbol_destroy). |

---

{#drgn_program_find_symbol_by_name}

### drgn_program_find_symbol_by_name

```cpp
struct drgn_error * drgn_program_find_symbol_by_name(struct drgn_program * prog, const char * name, struct drgn_symbol ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:1279

Get the symbol corresponding to the given name.

#### Returns
`NULL` on success, non-`NULL` on error.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `ret` | struct [`drgn_symbol`](drgn_symbol.md#drgn_symbol) ** | The returned symbol. It should be freed with [drgn_symbol_destroy()](Symbols.md#drgn_symbol_destroy). |

---

{#drgn_program_find_symbols_by_name}

### drgn_program_find_symbols_by_name

```cpp
struct drgn_error * drgn_program_find_symbols_by_name(struct drgn_program * prog, const char * name, struct drgn_symbol *** syms_ret, size_t * count_ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:1293

Get all global and local symbols, optionally with the given name.

#### Returns
`NULL` on success, non-`NULL` on error.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `prog` | struct [`drgn_program`](drgn_program.md#drgn_program) * | [Program](Program.md#program). |
| `name` | `const char *` | Name to match. If `NULL`, returns all symbols. |
| `syms_ret` | struct [`drgn_symbol`](drgn_symbol.md#drgn_symbol) *** | Returned array of symbols. On success, this must be freed with [drgn_symbols_destroy()](Symbols.md#drgn_symbols_destroy). |
| `count_ret` | `size_t *` | Returned number of symbols in `syms_ret`. |

---

{#drgn_program_find_symbols_by_address}

### drgn_program_find_symbols_by_address

```cpp
struct drgn_error * drgn_program_find_symbols_by_address(struct drgn_program * prog, uint64_t address, struct drgn_symbol *** syms_ret, size_t * count_ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:1308

Get all symbols containing the given address.

#### Returns
`NULL` on success, non-`NULL` on error.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `prog` | struct [`drgn_program`](drgn_program.md#drgn_program) * | [Program](Program.md#program). |
| `address` | `uint64_t` | Address to search for. |
| `syms_ret` | struct [`drgn_symbol`](drgn_symbol.md#drgn_symbol) *** | Returned array of symbols. On success, this must be freed with [drgn_symbols_destroy()](Symbols.md#drgn_symbols_destroy). |
| `count_ret` | `size_t *` | Returned number of symbols in `syms_ret`. |

---

{#drgn_symbol_result_builder_add}

### drgn_symbol_result_builder_add

```cpp
bool drgn_symbol_result_builder_add(struct drgn_symbol_result_builder * builder, struct drgn_symbol * symbol)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:1335

Add or set the return value for a symbol search

[Symbol](Symbol.md#symbol) finders should call this with each symbol search result. If the symbol search was [DRGN_FIND_SYMBOL_ONE](#group__Programs_1gga68a2d31672c92f6653ea1836a5de860dab362c2f2c3f86cb859eea1e70c78bc3c), then only the most recent symbol added to the builder will be returned. Otherwise, all symbols added to the builder are returned. Returns true on success, or false on an allocation failure.

---

{#drgn_symbol_result_builder_count}

### drgn_symbol_result_builder_count

```cpp
size_t drgn_symbol_result_builder_count(const struct drgn_symbol_result_builder * builder)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:1339

Get the current number of results in a symbol search result.

---

{#drgn_program_register_symbol_finder}

### drgn_program_register_symbol_finder

```cpp
struct drgn_error * drgn_program_register_symbol_finder(struct drgn_program * prog, const char * name, const struct drgn_symbol_finder_ops * ops, void * arg, size_t enable_index)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:1390

[Register](Register.md#register) a symbol finding callback.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `name` | `const char *` | Finder name. This is copied. |
| `ops` | const struct [`drgn_symbol_finder_ops`](drgn_symbol_finder_ops.md#drgn_symbol_finder_ops) * | Callback table. This is copied. |
| `arg` | `void *` | Argument to pass to callbacks. |
| `enable_index` | `size_t` | Insert the finder into the list of enabled finders at the given index. If [DRGN_HANDLER_REGISTER_ENABLE_LAST](#group__Programs_1gga106ab5141fe935134e70ab83c0689759a8d7b573f89ffb2ef07a718cb778df021) or greater than the number of enabled finders, insert it at the end. If [DRGN_HANDLER_REGISTER_DONT_ENABLE](#group__Programs_1gga106ab5141fe935134e70ab83c0689759ac8bf815074393b125e389935aeb94870), don’t enable the finder. |

---

{#drgn_program_registered_symbol_finders}

### drgn_program_registered_symbol_finders

```cpp
struct drgn_error * drgn_program_registered_symbol_finders(struct drgn_program * prog, const char *** names_ret, size_t * count_ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:1403

Get the names of all registered symbol finders.

The order of the names is arbitrary.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `names_ret` | `const char ***` | Returned array of names. |
| `count_ret` | `size_t *` | Returned number of names in `names_ret`. |

---

{#drgn_program_set_enabled_symbol_finders}

### drgn_program_set_enabled_symbol_finders

```cpp
struct drgn_error * drgn_program_set_enabled_symbol_finders(struct drgn_program * prog, const char *const * names, size_t count)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:1419

Set the list of enabled symbol finders.

Finders are called in the same order as the list. In case of a search for multiple symbols, then the results of all callbacks are concatenated. If the search is for a single symbol, then the first callback which finds a symbol will short-circuit the search.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `names` | `const char *const *` | Names of finders to enable, in order. |
| `count` | `size_t` | Number of names in `names`. |

---

{#drgn_program_enabled_symbol_finders}

### drgn_program_enabled_symbol_finders

```cpp
struct drgn_error * drgn_program_enabled_symbol_finders(struct drgn_program * prog, const char *** names_ret, size_t * count_ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:1430

Get the names of enabled symbol finders, in order.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `names_ret` | `const char ***` | Returned array of names. |
| `count_ret` | `size_t *` | Returned number of names in `names_ret`. |

