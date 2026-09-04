{#debugginginformation}

# Debugging information

> [`Internals`](Internals.md#internals)

Caching of debugging information.

[drgn_debug_info](drgn_debug_info.md#drgn_debug_info) caches debugging information (currently DWARF and ORC). It translates the debugging information to types and objects.

## Classes

| Name | Description |
|------|-------------|
| [`drgn_debug_info_finder`](drgn_debug_info_finder.md#drgn_debug_info_finder) |  |
| [`drgn_debug_info`](drgn_debug_info.md#drgn_debug_info) | Cache of debugging information. |
| [`drgn_module_iterator`](drgn_module_iterator.md#drgn_module_iterator) |  |
| [`drgn_module_address_range`](drgn_module_address_range.md#drgn_module_address_range-1) |  |
| [`drgn_module`](drgn_module.md#drgn_module) |  |
| [`depmod_index`](depmod_index.md#depmod_index) |  |
| [`drgn_kmod_walk_inode`](drgn_kmod_walk_inode.md#drgn_kmod_walk_inode) |  |
| [`drgn_kmod_walk_state`](drgn_kmod_walk_state.md#drgn_kmod_walk_state) |  |
| [`drgn_standard_debug_info_find_state`](drgn_standard_debug_info_find_state.md#drgn_standard_debug_info_find_state) |  |
| [`drgn_module_orc_info`](drgn_module_orc_info.md#drgn_module_orc_info) | ORC unwinder data for a [drgn_module](drgn_module.md#drgn_module). |

## Enumerations

| Name | Description |
|------|-------------|
| [`drgn_module_file_mask`](#drgn_module_file_mask)  | Bitmask of files in a [drgn_module](drgn_module.md#drgn_module). |

---

{#drgn_module_file_mask}

### drgn_module_file_mask

```cpp
enum drgn_module_file_mask
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.h:185

Bitmask of files in a [drgn_module](drgn_module.md#drgn_module).

## Typedefs

| Return | Name | Description |
|--------|------|-------------|
| `void` | [`drgn_module_iterator_destroy_fn`](#drgn_module_iterator_destroy_fn)  |  |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_module_iterator_next_fn`](#drgn_module_iterator_next_fn)  |  |

---

{#drgn_module_iterator_destroy_fn}

### drgn_module_iterator_destroy_fn

```cpp
using drgn_module_iterator_destroy_fn = void
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.h:160

---

{#drgn_module_iterator_next_fn}

### drgn_module_iterator_next_fn

```cpp
using drgn_module_iterator_next_fn = struct drgn_error *
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.h:162

## Functions

| Return | Name | Description |
|--------|------|-------------|
| `bool` | [`drgn_have_debuginfod`](#drgn_have_debuginfod) `static` `inline` |  |
|  | [`DEFINE_HASH_TABLE_TYPE`](#define_hash_table_type)  |  |
|  | [`DEFINE_HASH_TABLE_TYPE`](#define_hash_table_type-1)  |  |
|  | [`DEFINE_BINARY_SEARCH_TREE_TYPE`](#define_binary_search_tree_type-1)  |  |
| `void` | [`drgn_debug_info_init`](#drgn_debug_info_init)  | Initialize a [drgn_debug_info](drgn_debug_info.md#drgn_debug_info). |
| `void` | [`drgn_debug_info_deinit`](#drgn_debug_info_deinit)  | Deinitialize a [drgn_debug_info](drgn_debug_info.md#drgn_debug_info). |
| `void` | [`drgn_module_iterator_init`](#drgn_module_iterator_init) `static` `inline` |  |
| enum [`drgn_module_file_mask`](drgn_module_file_mask.md#drgn_module_file_mask) | [`__attribute__`](#__attribute__-4)  |  |
|  | [`DEFINE_HASH_MAP_TYPE`](#define_hash_map_type)  |  |
| `void` | [`drgn_module_delete`](#drgn_module_delete)  | Delete a partially-initialized module. This can only be called before the module is returned from public API. |
| `void` | [`drgn_module_deletep`](#drgn_module_deletep) `static` `inline` |  |
|  | [`DEFINE_VECTOR_TYPE`](#define_vector_type)  |  |
|  | [`DEFINE_HASH_MAP_TYPE`](#define_hash_map_type-1)  |  |
|  | [`DEFINE_VECTOR_TYPE`](#define_vector_type-1)  |  |
|  | [`DEFINE_HASH_SET_TYPE`](#define_hash_set_type)  |  |
| `void` | [`drgn_standard_debug_info_find_state_deinit`](#drgn_standard_debug_info_find_state_deinit)  |  |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_module_try_standard_file`](#drgn_module_try_standard_file)  |  |
| `bool` | [`drgn_module_wants_file`](#drgn_module_wants_file) `static` `inline` |  |
| const struct [`drgn_language`](drgn_language.md#drgn_language) * | [`drgn_debug_info_main_language`](#drgn_debug_info_main_language)  | Get the language of the program's `main` function or `NULL` if it could not be found. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_debug_info_find_type`](#drgn_debug_info_find_type)  | [drgn_type_finder_ops::find()](drgn_type_finder_ops.md#find-1) that uses debugging information. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_debug_info_find_object`](#drgn_debug_info_find_object)  | [drgn_object_finder_ops::find()](drgn_object_finder_ops.md#find-2) that uses debugging information. |
| struct [`drgn_elf_file`](drgn_elf_file.md#drgn_elf_file) * | [`drgn_module_find_dwarf_file`](#drgn_module_find_dwarf_file)  |  |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_module_create_split_dwarf_file`](#drgn_module_create_split_dwarf_file)  |  |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_module_find_cfi`](#drgn_module_find_cfi)  | Get the Call Frame Information in a [drgn_module](drgn_module.md#drgn_module) at a given program counter. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`open_elf_file`](#open_elf_file)  |  |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`find_elf_file`](#find_elf_file)  |  |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`elf_address_range`](#elf_address_range)  |  |

---

{#drgn_have_debuginfod}

### drgn_have_debuginfod

`static` `inline`

```cpp
static inline bool drgn_have_debuginfod(void)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.h:62

---

{#define_hash_table_type}

### DEFINE_HASH_TABLE_TYPE

```cpp
DEFINE_HASH_TABLE_TYPE(drgn_elf_file_dwarf_table, struct drgn_elf_file *)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.h:68

---

{#define_hash_table_type-1}

### DEFINE_HASH_TABLE_TYPE

```cpp
DEFINE_HASH_TABLE_TYPE(drgn_module_table, struct drgn_module *)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.h:69

---

{#define_binary_search_tree_type-1}

### DEFINE_BINARY_SEARCH_TREE_TYPE

```cpp
DEFINE_BINARY_SEARCH_TREE_TYPE(drgn_module_address_tree, struct drgn_module_address_range)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.h:70

---

{#drgn_debug_info_init}

### drgn_debug_info_init

```cpp
void drgn_debug_info_init(struct drgn_debug_info * dbinfo, struct drgn_program * prog)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.h:154

Initialize a [drgn_debug_info](drgn_debug_info.md#drgn_debug_info).

---

{#drgn_debug_info_deinit}

### drgn_debug_info_deinit

```cpp
void drgn_debug_info_deinit(struct drgn_debug_info * dbinfo)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.h:158

Deinitialize a [drgn_debug_info](drgn_debug_info.md#drgn_debug_info).

---

{#drgn_module_iterator_init}

### drgn_module_iterator_init

`static` `inline`

```cpp
static inline void drgn_module_iterator_init(struct drgn_module_iterator * it, struct drgn_program * prog, drgn_module_iterator_destroy_fn * destroy, drgn_module_iterator_next_fn * next)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.h:173

---

{#__attribute__-4}

### __attribute__

```cpp
enum drgn_module_file_mask __attribute__((__packed__))
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.h:173

---

{#define_hash_map_type}

### DEFINE_HASH_MAP_TYPE

```cpp
DEFINE_HASH_MAP_TYPE(drgn_module_section_address_map, char *, uint64_t)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.h:190

---

{#drgn_module_delete}

### drgn_module_delete

```cpp
void drgn_module_delete(struct drgn_module * module)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.h:309

Delete a partially-initialized module. This can only be called before the module is returned from public API.

---

{#drgn_module_deletep}

### drgn_module_deletep

`static` `inline`

```cpp
static inline void drgn_module_deletep(struct drgn_module ** modulep)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.h:311

---

{#define_vector_type}

### DEFINE_VECTOR_TYPE

```cpp
DEFINE_VECTOR_TYPE(char_p_vector, char *)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.h:324

---

{#define_hash_map_type-1}

### DEFINE_HASH_MAP_TYPE

```cpp
DEFINE_HASH_MAP_TYPE(drgn_kmod_walk_module_map, const char *, struct char_p_vector)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.h:326

---

{#define_vector_type-1}

### DEFINE_VECTOR_TYPE

```cpp
DEFINE_VECTOR_TYPE(drgn_kmod_walk_stack, struct drgn_kmod_walk_stack_entry)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.h:329

---

{#define_hash_set_type}

### DEFINE_HASH_SET_TYPE

```cpp
DEFINE_HASH_SET_TYPE(drgn_kmod_walk_inode_set, struct drgn_kmod_walk_inode)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.h:337

---

{#drgn_standard_debug_info_find_state_deinit}

### drgn_standard_debug_info_find_state_deinit

```cpp
void drgn_standard_debug_info_find_state_deinit(struct drgn_standard_debug_info_find_state * state)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.h:359

---

{#drgn_module_try_standard_file}

### drgn_module_try_standard_file

```cpp
struct drgn_error * drgn_module_try_standard_file(struct drgn_module * module, const struct drgn_debug_info_options * options, const char * path, int fd, bool check_build_id, const uint32_t * expected_crc)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.h:363

---

{#drgn_module_wants_file}

### drgn_module_wants_file

`static` `inline`

```cpp
static inline bool drgn_module_wants_file(struct drgn_module * module)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.h:368

---

{#drgn_debug_info_main_language}

### drgn_debug_info_main_language

```cpp
const struct drgn_language * drgn_debug_info_main_language(struct drgn_debug_info * dbinfo)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.h:379

Get the language of the program's `main` function or `NULL` if it could not be found.

---

{#drgn_debug_info_find_type}

### drgn_debug_info_find_type

```cpp
struct drgn_error * drgn_debug_info_find_type(uint64_t kinds, const char * name, size_t name_len, const char * filename, void * arg, struct drgn_qualified_type * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.h:382

[drgn_type_finder_ops::find()](drgn_type_finder_ops.md#find-1) that uses debugging information.

---

{#drgn_debug_info_find_object}

### drgn_debug_info_find_object

```cpp
struct drgn_error * drgn_debug_info_find_object(const char * name, size_t name_len, const char * filename, enum drgn_find_object_flags flags, void * arg, struct drgn_object * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.h:389

[drgn_object_finder_ops::find()](drgn_object_finder_ops.md#find-2) that uses debugging information.

---

{#drgn_module_find_dwarf_file}

### drgn_module_find_dwarf_file

```cpp
struct drgn_elf_file * drgn_module_find_dwarf_file(struct drgn_module * module, Dwarf * dwarf)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.h:394

---

{#drgn_module_create_split_dwarf_file}

### drgn_module_create_split_dwarf_file

```cpp
struct drgn_error * drgn_module_create_split_dwarf_file(struct drgn_module * module, const char * name, Dwarf * dwarf, struct drgn_elf_file ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.h:398

---

{#drgn_module_find_cfi}

### drgn_module_find_cfi

```cpp
struct drgn_error * drgn_module_find_cfi(struct drgn_program * prog, struct drgn_module * module, uint64_t pc, struct drgn_elf_file ** file_ret, struct drgn_cfi_row ** row_ret, bool * interrupted_ret, drgn_register_number * ret_addr_regno_ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.h:416

Get the Call Frame Information in a [drgn_module](drgn_module.md#drgn_module) at a given program counter.

#### Returns
`NULL` on success, non-`NULL` on error. In particular, &[drgn_not_found](ErrorHandling.md#drgn_not_found) if CFI wasn't found.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `module` | struct [`drgn_module`](drgn_module.md#drgn_module) * | [Module](Module.md#module-3) containing `pc`. |
| `pc` | `uint64_t` | [Program](Program.md#program) counter. |
| `file_ret` | struct [`drgn_elf_file`](drgn_elf_file.md#drgn_elf_file) ** | Returned file containing CFI. |
| `row_ret` | struct [`drgn_cfi_row`](drgn_cfi_row.md#drgn_cfi_row-1) ** | Returned CFI row. |
| `interrupted_ret` | `bool *` | Whether the found frame interrupted its caller. |
| `ret_addr_regno_ret` | [`drgn_register_number`](CallFrameInformation.md#drgn_register_number) * | Returned return address register number. |

---

{#open_elf_file}

### open_elf_file

```cpp
struct drgn_error * open_elf_file(const char * path, int * fd_ret, Elf ** elf_ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.h:421

---

{#find_elf_file}

### find_elf_file

```cpp
struct drgn_error * find_elf_file(char ** path_ret, int * fd_ret, Elf ** elf_ret, const char *const * path_formats, ...)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.h:423

---

{#elf_address_range}

### elf_address_range

```cpp
struct drgn_error * elf_address_range(Elf * elf, uint64_t bias, uint64_t * start_ret, uint64_t * end_ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.h:426

## Variables

| Return | Name | Description |
|--------|------|-------------|
| struct [`drgn_module_address_range`](drgn_module_address_range.md#drgn_module_address_range-1) | [`__attribute__`](#__attribute__-5)  |  |

---

{#__attribute__-5}

### __attribute__

```cpp
struct drgn_module_address_range __attribute__
```

Type: struct [`drgn_module_address_range`](drgn_module_address_range.md#drgn_module_address_range-1)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.h:199

