{#programs-1}

# Programs

> [`Internals`](Internals.md#internals)

[Program](Program.md#program) internals.

## Classes

| Name | Description |
|------|-------------|
| [`drgn_thread`](drgn_thread.md#drgn_thread) | A thread in a program. |
| [`drgn_program`](drgn_program.md#drgn_program) | [Program](Program.md#program) being debugged. |

## Macros

| Name | Description |
|------|-------------|
| [`SEARCH_MEMORY_UINT_SIZES`](#search_memory_uint_sizes)  |  |
| [`drgn_blocking_guard`](#drgn_blocking_guard)  | Scope guard that wraps [drgn_begin_blocking()](#drgn_begin_blocking) and [drgn_end_blocking()](#drgn_end_blocking). |

---

{#search_memory_uint_sizes}

### SEARCH_MEMORY_UINT_SIZES

```cpp
#define SEARCH_MEMORY_UINT_SIZES X(16) X(32) X(64)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.h:60

---

{#drgn_blocking_guard}

### drgn_blocking_guard

```cpp
#define drgn_blocking_guard(name) drgn_blocking_state name						\
	__attribute__((__cleanup__(drgn_blocking_guard_cleanup), __unused__)) =	\
		drgn_begin_blocking()
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.h:547

Scope guard that wraps [drgn_begin_blocking()](#drgn_begin_blocking) and [drgn_end_blocking()](#drgn_end_blocking).

## Typedefs

| Return | Name | Description |
|--------|------|-------------|
| struct [`drgn_blocking_state`](#drgn_blocking_state) * | [`drgn_blocking_state`](#drgn_blocking_state)  | Opaque state used for blocking operations. |

---

{#drgn_blocking_state}

### drgn_blocking_state

```cpp
using drgn_blocking_state = struct drgn_blocking_state *
```

Type: struct [`drgn_blocking_state`](#drgn_blocking_state) *

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.h:511

Opaque state used for blocking operations.

## Functions

| Return | Name | Description |
|--------|------|-------------|
|  | [`DEFINE_VECTOR_TYPE`](#define_vector_type-3)  |  |
|  | [`DEFINE_HASH_TABLE_TYPE`](#define_hash_table_type-3)  |  |
| `void` | [`drgn_program_init`](#drgn_program_init)  | Initialize a [drgn_program](drgn_program.md#drgn_program). |
| `void` | [`drgn_program_deinit`](#drgn_program_deinit)  | Deinitialize a [drgn_program](drgn_program.md#drgn_program). |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_program_check_initialized`](#drgn_program_check_initialized)  | Return an error if the program's memory has already been initialized or its target has been set. |
| `void` | [`drgn_program_set_platform`](#drgn_program_set_platform)  | Set the [drgn_platform](drgn_platform.md#drgn_platform) of a [drgn_program](drgn_program.md#drgn_program) if it hasn't been set yet. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_program_init_core_dump`](#drgn_program_init_core_dump)  | Implement [drgn_program_from_core_dump()](Programs.md#drgn_program_from_core_dump) on an initialized [drgn_program](drgn_program.md#drgn_program). |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_program_init_core_dump_fd`](#drgn_program_init_core_dump_fd)  | Implement [drgn_program_from_core_dump_fd()](Programs.md#drgn_program_from_core_dump_fd) on an initialized [drgn_program](drgn_program.md#drgn_program). |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_program_init_kernel`](#drgn_program_init_kernel)  | Implement [drgn_program_from_kernel()](Programs.md#drgn_program_from_kernel) on an initialized [drgn_program](drgn_program.md#drgn_program). |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_program_init_pid`](#drgn_program_init_pid)  | Implement [drgn_program_from_pid()](Programs.md#drgn_program_from_pid) on an initialized [drgn_program](drgn_program.md#drgn_program). |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_program_cache_auxv`](#drgn_program_cache_auxv)  |  |
| `bool` | [`drgn_program_is_userspace_process`](#drgn_program_is_userspace_process) `static` `inline` | Return whether a [drgn_program](drgn_program.md#drgn_program) is a userspace process running on the local machine. |
| `bool` | [`drgn_program_is_userspace_core`](#drgn_program_is_userspace_core) `static` `inline` | Return whether a [drgn_program](drgn_program.md#drgn_program) is a core dump of a userspace process. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_program_is_little_endian`](#drgn_program_is_little_endian) `static` `inline` |  |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_program_bswap`](#drgn_program_bswap) `static` `inline` | Return whether a [drgn_program](drgn_program.md#drgn_program) has a different endianness than the host system. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_program_is_64_bit`](#drgn_program_is_64_bit) `static` `inline` |  |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_program_address_mask`](#drgn_program_address_mask) `static` `inline` |  |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_program_untagged_addr`](#drgn_program_untagged_addr) `static` `inline` |  |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_thread_dup_internal`](#drgn_thread_dup_internal)  |  |
| `void` | [`drgn_thread_deinit`](#drgn_thread_deinit)  |  |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_program_find_prstatus`](#drgn_program_find_prstatus)  | Find the `NT_PRSTATUS` note with the given "PID". |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_program_cache_prstatus_entry`](#drgn_program_cache_prstatus_entry)  | Cache the `NT_PRSTATUS` note provided by `data` in `prog`. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_program_find_symbol_by_address_internal`](#drgn_program_find_symbol_by_address_internal)  |  |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_program_register_type_finder_impl`](#drgn_program_register_type_finder_impl)  |  |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_program_register_object_finder_impl`](#drgn_program_register_object_finder_impl)  |  |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_program_register_symbol_finder_impl`](#drgn_program_register_symbol_finder_impl)  |  |
| [`drgn_blocking_state`](#drgn_blocking_state) | [`drgn_begin_blocking`](#drgn_begin_blocking)  | Call before a blocking (I/O or long-running) operation. |
| `void` | [`drgn_end_blocking`](#drgn_end_blocking)  | Call after a blocking (I/O or long-running) operation. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_blocking_check_signals`](#drgn_blocking_check_signals)  | Call periodically during a blocking operation to check for pending signals. |
| `void` | [`drgn_blocking_guard_cleanup`](#drgn_blocking_guard_cleanup) `static` `inline` |  |

---

{#define_vector_type-3}

### DEFINE_VECTOR_TYPE

```cpp
DEFINE_VECTOR_TYPE(drgn_typep_vector, struct drgn_type *)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.h:57

---

{#define_hash_table_type-3}

### DEFINE_HASH_TABLE_TYPE

```cpp
DEFINE_HASH_TABLE_TYPE(drgn_thread_set, struct drgn_thread)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.h:58

---

{#drgn_program_init}

### drgn_program_init

```cpp
void drgn_program_init(struct drgn_program * prog, const struct drgn_platform * platform)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.h:317

Initialize a [drgn_program](drgn_program.md#drgn_program).

---

{#drgn_program_deinit}

### drgn_program_deinit

```cpp
void drgn_program_deinit(struct drgn_program * prog)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.h:321

Deinitialize a [drgn_program](drgn_program.md#drgn_program).

---

{#drgn_program_check_initialized}

### drgn_program_check_initialized

```cpp
struct drgn_error * drgn_program_check_initialized(struct drgn_program * prog)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.h:327

Return an error if the program's memory has already been initialized or its target has been set.

---

{#drgn_program_set_platform}

### drgn_program_set_platform

```cpp
void drgn_program_set_platform(struct drgn_program * prog, const struct drgn_platform * platform)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.h:333

Set the [drgn_platform](drgn_platform.md#drgn_platform) of a [drgn_program](drgn_program.md#drgn_program) if it hasn't been set yet.

---

{#drgn_program_init_core_dump}

### drgn_program_init_core_dump

```cpp
struct drgn_error * drgn_program_init_core_dump(struct drgn_program * prog, const char * path)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.h:340

Implement [drgn_program_from_core_dump()](Programs.md#drgn_program_from_core_dump) on an initialized [drgn_program](drgn_program.md#drgn_program).

---

{#drgn_program_init_core_dump_fd}

### drgn_program_init_core_dump_fd

```cpp
struct drgn_error * drgn_program_init_core_dump_fd(struct drgn_program * prog, int fd)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.h:347

Implement [drgn_program_from_core_dump_fd()](Programs.md#drgn_program_from_core_dump_fd) on an initialized [drgn_program](drgn_program.md#drgn_program).

---

{#drgn_program_init_kernel}

### drgn_program_init_kernel

```cpp
struct drgn_error * drgn_program_init_kernel(struct drgn_program * prog)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.h:354

Implement [drgn_program_from_kernel()](Programs.md#drgn_program_from_kernel) on an initialized [drgn_program](drgn_program.md#drgn_program).

---

{#drgn_program_init_pid}

### drgn_program_init_pid

```cpp
struct drgn_error * drgn_program_init_pid(struct drgn_program * prog, pid_t pid)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.h:359

Implement [drgn_program_from_pid()](Programs.md#drgn_program_from_pid) on an initialized [drgn_program](drgn_program.md#drgn_program).

---

{#drgn_program_cache_auxv}

### drgn_program_cache_auxv

```cpp
struct drgn_error * drgn_program_cache_auxv(struct drgn_program * prog)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.h:361

---

{#drgn_program_is_userspace_process}

### drgn_program_is_userspace_process

`static` `inline`

```cpp
static inline bool drgn_program_is_userspace_process(struct drgn_program * prog)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.h:368

Return whether a [drgn_program](drgn_program.md#drgn_program) is a userspace process running on the local machine.

---

{#drgn_program_is_userspace_core}

### drgn_program_is_userspace_core

`static` `inline`

```cpp
static inline bool drgn_program_is_userspace_core(struct drgn_program * prog)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.h:378

Return whether a [drgn_program](drgn_program.md#drgn_program) is a core dump of a userspace process.

---

{#drgn_program_is_little_endian}

### drgn_program_is_little_endian

`static` `inline`

```cpp
static inline struct drgn_error * drgn_program_is_little_endian(struct drgn_program * prog, bool * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.h:386

---

{#drgn_program_bswap}

### drgn_program_bswap

`static` `inline`

```cpp
static inline struct drgn_error * drgn_program_bswap(struct drgn_program * prog, bool * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.h:401

Return whether a [drgn_program](drgn_program.md#drgn_program) has a different endianness than the host system.

---

{#drgn_program_is_64_bit}

### drgn_program_is_64_bit

`static` `inline`

```cpp
static inline struct drgn_error * drgn_program_is_64_bit(struct drgn_program * prog, bool * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.h:412

---

{#drgn_program_address_mask}

### drgn_program_address_mask

`static` `inline`

```cpp
static inline struct drgn_error * drgn_program_address_mask(const struct drgn_program * prog, uint64_t * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.h:423

---

{#drgn_program_untagged_addr}

### drgn_program_untagged_addr

`static` `inline`

```cpp
static inline struct drgn_error * drgn_program_untagged_addr(const struct drgn_program * prog, uint64_t * address)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.h:434

---

{#drgn_thread_dup_internal}

### drgn_thread_dup_internal

```cpp
struct drgn_error * drgn_thread_dup_internal(const struct drgn_thread * thread, struct drgn_thread * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.h:446

---

{#drgn_thread_deinit}

### drgn_thread_deinit

```cpp
void drgn_thread_deinit(struct drgn_thread * thread)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.h:449

---

{#drgn_program_find_prstatus}

### drgn_program_find_prstatus

```cpp
struct drgn_error * drgn_program_find_prstatus(struct drgn_program * prog, uint32_t tid, struct nstring * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.h:460

Find the `NT_PRSTATUS` note with the given "PID".

For userspace, the PID is the thread ID. For the kernel, it's complicated; see drgn_get_initial_registers_from_kernel_core_dump().

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `ret` | struct [`nstring`](nstring.md#nstring) * | Returned note data. If not found, `ret->str` is set to `NULL` and `ret->len` is set to zero. |

---

{#drgn_program_cache_prstatus_entry}

### drgn_program_cache_prstatus_entry

```cpp
struct drgn_error * drgn_program_cache_prstatus_entry(struct drgn_program * prog, const char * data, size_t size, uint32_t * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.h:471

Cache the `NT_PRSTATUS` note provided by `data` in `prog`.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `data` | `const char *` | The pointer to the note data. |
| `size` | `size_t` | Size of data in note. |
| `ret` | `uint32_t *` | [Thread](Thread.md#thread) ID from note. |

---

{#drgn_program_find_symbol_by_address_internal}

### drgn_program_find_symbol_by_address_internal

```cpp
struct drgn_error * drgn_program_find_symbol_by_address_internal(struct drgn_program * prog, uint64_t address, struct drgn_symbol ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.h:485

---

{#drgn_program_register_type_finder_impl}

### drgn_program_register_type_finder_impl

```cpp
struct drgn_error * drgn_program_register_type_finder_impl(struct drgn_program * prog, struct drgn_type_finder * finder, const char * name, const struct drgn_type_finder_ops * ops, void * arg, size_t enable_index)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.h:490

---

{#drgn_program_register_object_finder_impl}

### drgn_program_register_object_finder_impl

```cpp
struct drgn_error * drgn_program_register_object_finder_impl(struct drgn_program * prog, struct drgn_object_finder * finder, const char * name, const struct drgn_object_finder_ops * ops, void * arg, size_t enable_index)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.h:497

---

{#drgn_program_register_symbol_finder_impl}

### drgn_program_register_symbol_finder_impl

```cpp
struct drgn_error * drgn_program_register_symbol_finder_impl(struct drgn_program * prog, struct drgn_symbol_finder * finder, const char * name, const struct drgn_symbol_finder_ops * ops, void * arg, size_t enable_index)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.h:504

---

{#drgn_begin_blocking}

### drgn_begin_blocking

```cpp
drgn_blocking_state drgn_begin_blocking(void)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.h:520

Call before a blocking (I/O or long-running) operation.

Must be paired with [drgn_end_blocking()](#drgn_end_blocking).

#### Returns
Opaque state to pass to [drgn_end_blocking()](#drgn_end_blocking).

---

{#drgn_end_blocking}

### drgn_end_blocking

```cpp
void drgn_end_blocking(drgn_blocking_state state)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.h:527

Call after a blocking (I/O or long-running) operation.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `state` | [`drgn_blocking_state`](#drgn_blocking_state) | Return value of [drgn_begin_blocking()](#drgn_begin_blocking). |

---

{#drgn_blocking_check_signals}

### drgn_blocking_check_signals

```cpp
struct drgn_error * drgn_blocking_check_signals(drgn_blocking_state * statep)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.h:535

Call periodically during a blocking operation to check for pending signals.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `statep` | [`drgn_blocking_state`](#drgn_blocking_state) * | Pointer to return value of [drgn_begin_blocking()](#drgn_begin_blocking). |

---

{#drgn_blocking_guard_cleanup}

### drgn_blocking_guard_cleanup

`static` `inline`

```cpp
static inline void drgn_blocking_guard_cleanup(drgn_blocking_state * statep)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.h:538

