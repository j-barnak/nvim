{#modules}

# Modules

Modules in a program and debugging information.

## Classes

| Name | Description |
|------|-------------|
| [`drgn_debug_info_finder_ops`](drgn_debug_info_finder_ops.md#drgn_debug_info_finder_ops) | Debugging information finder callback table. |

## Enumerations

| Name | Description |
|------|-------------|
| [`drgn_module_kind`](#drgn_module_kind)  | Kinds of modules. |
| [`drgn_module_file_status`](#drgn_module_file_status)  | Status of a file in a [drgn_module](drgn_module.md#drgn_module). |
| [`drgn_supplementary_file_kind`](#drgn_supplementary_file_kind)  | Kind of supplementary file. |
| [`drgn_kmod_search_method`](#drgn_kmod_search_method)  | Methods of searching for loadable kernel module debugging information. |

---

{#drgn_module_kind}

### drgn_module_kind

```cpp
enum drgn_module_kind
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:1453

Kinds of modules.

---

{#drgn_module_file_status}

### drgn_module_file_status

```cpp
enum drgn_module_file_status
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:1752

Status of a file in a [drgn_module](drgn_module.md#drgn_module).

| Value | Description |
|-------|-------------|
| `DRGN_MODULE_FILE_WANT` | File has not been found and should be searched for. |
| `DRGN_MODULE_FILE_HAVE` | File has already been found and assigned. |
| `DRGN_MODULE_FILE_DONT_WANT` | File has not been found, but it should not be searched for. |
| `DRGN_MODULE_FILE_DONT_NEED` | File has not been found and is not needed. |
| `DRGN_MODULE_FILE_WANT_SUPPLEMENTARY` | File has been found, but it requires a supplementary file before it can be used. |

---

{#drgn_supplementary_file_kind}

### drgn_supplementary_file_kind

```cpp
enum drgn_supplementary_file_kind
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:1769

Kind of supplementary file.

| Value | Description |
|-------|-------------|
| `DRGN_SUPPLEMENTARY_FILE_NONE` | Not known or not needed. |
| `DRGN_SUPPLEMENTARY_FILE_GNU_DEBUGALTLINK` | GNU-style supplementary debug file referred to by a `.gnu_debugaltlink` section. |

---

{#drgn_kmod_search_method}

### drgn_kmod_search_method

```cpp
enum drgn_kmod_search_method
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:2104

Methods of searching for loadable kernel module debugging information.

## Functions

| Return | Name | Description |
|--------|------|-------------|
| struct [`drgn_module`](drgn_module.md#drgn_module) * | [`drgn_module_find_by_name`](#drgn_module_find_by_name)  | Find the created [drgn_module](drgn_module.md#drgn_module) with the given `name`. |
| struct [`drgn_module`](drgn_module.md#drgn_module) * | [`drgn_module_find_by_address`](#drgn_module_find_by_address)  | Find the created [drgn_module](drgn_module.md#drgn_module) containing the given `address`. |
| struct [`drgn_module`](drgn_module.md#drgn_module) * | [`drgn_module_find_main`](#drgn_module_find_main)  | Find the main module. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_module_find_or_create_main`](#drgn_module_find_or_create_main)  | Find the main module, creating it if it doesn't already exist. |
| struct [`drgn_module`](drgn_module.md#drgn_module) * | [`drgn_module_find_shared_library`](#drgn_module_find_shared_library)  | Find a shared library module. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_module_find_or_create_shared_library`](#drgn_module_find_or_create_shared_library)  | Find a shared library module, creating it if it doesn't already exist. |
| struct [`drgn_module`](drgn_module.md#drgn_module) * | [`drgn_module_find_vdso`](#drgn_module_find_vdso)  | Find a vDSO module. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_module_find_or_create_vdso`](#drgn_module_find_or_create_vdso)  | Find a vDSO module, creating it if it doesn't already exist. |
| struct [`drgn_module`](drgn_module.md#drgn_module) * | [`drgn_module_find_relocatable`](#drgn_module_find_relocatable)  | Find a relocatable module. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_module_find_or_create_relocatable`](#drgn_module_find_or_create_relocatable)  | Find a relocatable module, creating it if it doesn't already exist. |
| struct [`drgn_module`](drgn_module.md#drgn_module) * | [`drgn_module_find_extra`](#drgn_module_find_extra)  | Find an extra module. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_module_find_or_create_extra`](#drgn_module_find_or_create_extra)  | Find an extra module, creating it if it doesn't already exist. |
| struct [`drgn_program`](drgn_program.md#drgn_program) * | [`drgn_module_program`](#drgn_module_program)  | Get the program that a module is from. |
| enum [`drgn_module_kind`](drgn_module_kind.md#drgn_module_kind) | [`drgn_module_kind`](#drgn_module_kind-1)  | Get the kind of a module. |
| `const char *` | [`drgn_module_name`](#drgn_module_name)  | Get the name of a module. |
| `uint64_t` | [`drgn_module_info`](#drgn_module_info)  | Get the kind-specific info of a module. |
| `bool` | [`drgn_module_num_address_ranges`](#drgn_module_num_address_ranges)  | Get the number of address ranges where a module is loaded. |
| `bool` | [`drgn_module_address_range`](#drgn_module_address_range)  | Get the `i-th` address range where a module is loaded. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_module_set_address_range`](#drgn_module_set_address_range)  | Set the address range of a module. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_module_set_address_ranges`](#drgn_module_set_address_ranges)  | Set the address ranges of a module. |
| `void` | [`drgn_module_unset_address_ranges`](#drgn_module_unset_address_ranges)  | Unset the address ranges for a module. |
| `bool` | [`drgn_module_contains_address`](#drgn_module_contains_address)  | Return whether a module's address ranges contain `address`. |
| `const char *` | [`drgn_module_build_id`](#drgn_module_build_id)  | Get the unique byte string (e.g., GNU build ID) identifying files used by a module. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_module_set_build_id`](#drgn_module_set_build_id)  | Set the unique byte string (e.g., GNU build ID) identifying files used by a module. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_module_get_section_address`](#drgn_module_get_section_address)  | Get the address of a section with the given name in a relocatable module. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_module_set_section_address`](#drgn_module_set_section_address)  | Set the address of a section with the given name in a relocatable module. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_module_delete_section_address`](#drgn_module_delete_section_address)  | Unset the address of a section with the given name in a relocatable module. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_module_num_section_addresses`](#drgn_module_num_section_addresses)  | Get the number of section addresses currently set in a relocatable module. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_module_section_address_iterator_create`](#drgn_module_section_address_iterator_create)  | Create a [drgn_module_section_address_iterator](drgn_module_section_address_iterator.md#drgn_module_section_address_iterator). |
| `void` | [`drgn_module_section_address_iterator_destroy`](#drgn_module_section_address_iterator_destroy)  | Destroy a [drgn_module_section_address_iterator](drgn_module_section_address_iterator.md#drgn_module_section_address_iterator). |
| struct [`drgn_module`](drgn_module.md#drgn_module) * | [`drgn_module_section_address_iterator_module`](#drgn_module_section_address_iterator_module)  | Get the module that a [drgn_module_section_address_iterator](drgn_module_section_address_iterator.md#drgn_module_section_address_iterator) is for. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_module_section_address_iterator_next`](#drgn_module_section_address_iterator_next)  | Get the next section name and address from a [drgn_module_section_address_iterator](drgn_module_section_address_iterator.md#drgn_module_section_address_iterator). |
| enum [`drgn_module_file_status`](drgn_module_file_status.md#drgn_module_file_status) | [`drgn_module_loaded_file_status`](#drgn_module_loaded_file_status)  | Get the status of a module's loaded file. |
| `bool` | [`drgn_module_set_loaded_file_status`](#drgn_module_set_loaded_file_status)  | Set the status of a module's loaded file. |
| `bool` | [`drgn_module_wants_loaded_file`](#drgn_module_wants_loaded_file)  | Get whether a module wants a loaded file. |
| `const char *` | [`drgn_module_loaded_file_path`](#drgn_module_loaded_file_path)  | Get the absolute path of a module's loaded file, or `NULL` if not known. |
| `uint64_t` | [`drgn_module_loaded_file_bias`](#drgn_module_loaded_file_bias)  | Get the difference between the load address in the program and addresses in a module's loaded file. |
| enum [`drgn_module_file_status`](drgn_module_file_status.md#drgn_module_file_status) | [`drgn_module_debug_file_status`](#drgn_module_debug_file_status)  |  |
| `bool` | [`drgn_module_set_debug_file_status`](#drgn_module_set_debug_file_status)  |  |
| `bool` | [`drgn_module_wants_debug_file`](#drgn_module_wants_debug_file)  | Get whether a module wants a debug file. |
| `const char *` | [`drgn_module_debug_file_path`](#drgn_module_debug_file_path)  | Get the absolute path of a module's debug file, or `NULL` if not known. |
| `uint64_t` | [`drgn_module_debug_file_bias`](#drgn_module_debug_file_bias)  | Get the difference between the load address in the program and addresses in a module's debug file. |
| enum [`drgn_supplementary_file_kind`](drgn_supplementary_file_kind.md#drgn_supplementary_file_kind) | [`drgn_module_supplementary_debug_file_kind`](#drgn_module_supplementary_debug_file_kind)  | Get the kind of a module's supplementary debug file. |
| `const char *` | [`drgn_module_supplementary_debug_file_path`](#drgn_module_supplementary_debug_file_path)  | Get the absolute path of a module's supplementary debug file, or `NULL` if not known or not needed. |
| enum [`drgn_supplementary_file_kind`](drgn_supplementary_file_kind.md#drgn_supplementary_file_kind) | [`drgn_module_wanted_supplementary_debug_file`](#drgn_module_wanted_supplementary_debug_file)  | Get information about the supplementary debug file that a module currently wants. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_module_object`](#drgn_module_object)  | Return the object associated with this module. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_module_set_object`](#drgn_module_set_object)  | Set the object associated with this module. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_program_register_debug_info_finder`](#drgn_program_register_debug_info_finder)  | [Register](Register.md#register) a debugging information finding callback. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_program_registered_debug_info_finders`](#drgn_program_registered_debug_info_finders)  | Get the names of all registered debugging information finders. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_program_set_enabled_debug_info_finders`](#drgn_program_set_enabled_debug_info_finders)  | Set the list of enabled debugging information finders. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_program_enabled_debug_info_finders`](#drgn_program_enabled_debug_info_finders)  | Get the names of enabled debugging information finders, in order. |
| `const char *const *` | [`drgn_debug_info_options_get_directories`](#drgn_debug_info_options_get_directories)  | Get the list of directories to search for debugging information files. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_debug_info_options_set_directories`](#drgn_debug_info_options_set_directories)  | Set the list of directories to search for debugging information files. |
| struct [`drgn_error`](drgn_error.md#drgn_error) bool | [`drgn_debug_info_options_get_try_module_name`](#drgn_debug_info_options_get_try_module_name)  | Get whether to try module names that look like filesystem paths. |
| `void` | [`drgn_debug_info_options_set_try_module_name`](#drgn_debug_info_options_set_try_module_name)  | Set whether to try module names that look like filesystem paths. |
| `bool` | [`drgn_debug_info_options_get_try_build_id`](#drgn_debug_info_options_get_try_build_id)  | Get whether to try files by build ID. |
| `void` | [`drgn_debug_info_options_set_try_build_id`](#drgn_debug_info_options_set_try_build_id)  | Set whether to try files by build ID. |
| `const char *const *` | [`drgn_debug_info_options_get_debug_link_directories`](#drgn_debug_info_options_get_debug_link_directories)  | Get the list of directories to search for by debug link. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_debug_info_options_set_debug_link_directories`](#drgn_debug_info_options_set_debug_link_directories)  | Set the list of directories to search for by debug link. |
| struct [`drgn_error`](drgn_error.md#drgn_error) bool | [`drgn_debug_info_options_get_try_debug_link`](#drgn_debug_info_options_get_try_debug_link)  | Get whether to try files by debug link. |
| `void` | [`drgn_debug_info_options_set_try_debug_link`](#drgn_debug_info_options_set_try_debug_link)  | Set whether to try files by debug link. |
| `bool` | [`drgn_debug_info_options_get_try_procfs`](#drgn_debug_info_options_get_try_procfs)  | Get whether to try files via procfs for local processes. |
| `void` | [`drgn_debug_info_options_set_try_procfs`](#drgn_debug_info_options_set_try_procfs)  | Set whether to try files via procfs for local processes. |
| `bool` | [`drgn_debug_info_options_get_try_embedded_vdso`](#drgn_debug_info_options_get_try_embedded_vdso)  | Get whether to try the vDSO embedded in a process's memory/core dump. |
| `void` | [`drgn_debug_info_options_set_try_embedded_vdso`](#drgn_debug_info_options_set_try_embedded_vdso)  | Set whether to try the vDSO embedded in a process's memory/core dump. |
| `bool` | [`drgn_debug_info_options_get_try_reuse`](#drgn_debug_info_options_get_try_reuse)  | Get whether to reuse a module's loaded file as its debug file or vice versa. |
| `void` | [`drgn_debug_info_options_set_try_reuse`](#drgn_debug_info_options_set_try_reuse)  | Set whether to reuse a module's loaded file as its debug file or vice versa. |
| `bool` | [`drgn_debug_info_options_get_try_supplementary`](#drgn_debug_info_options_get_try_supplementary)  | Get whether to try finding supplementary files. |
| `void` | [`drgn_debug_info_options_set_try_supplementary`](#drgn_debug_info_options_set_try_supplementary)  | Set whether to try finding supplementary files. |
| `const char *const *` | [`drgn_debug_info_options_get_kernel_directories`](#drgn_debug_info_options_get_kernel_directories)  | Get the list of directories to search for kernel debugging information files. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_debug_info_options_set_kernel_directories`](#drgn_debug_info_options_set_kernel_directories)  | Set the list of directories to search for kernel debugging information files. |
| enum [`drgn_kmod_search_method`](drgn_kmod_search_method.md#drgn_kmod_search_method) | [`drgn_debug_info_options_get_try_kmod`](#drgn_debug_info_options_get_try_kmod)  | Get how to search for loadable kernel module debugging information. |
| `void` | [`drgn_debug_info_options_set_try_kmod`](#drgn_debug_info_options_set_try_kmod)  | Set how to search for loadable kernel module debugging information. |
| struct [`drgn_debug_info_options`](drgn_debug_info_options.md#drgn_debug_info_options) * | [`drgn_program_debug_info_options`](#drgn_program_debug_info_options)  | Get the default debugging information options for `prog`. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_find_standard_debug_info`](#drgn_find_standard_debug_info)  | Load debugging information for the given modules from the standard locations. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_module_try_file`](#drgn_module_try_file)  | Try to use the given file for a module. |
| `void` | [`drgn_module_iterator_destroy`](#drgn_module_iterator_destroy)  | Destroy a [drgn_module_iterator](drgn_module_iterator.md#drgn_module_iterator). |
| struct [`drgn_program`](drgn_program.md#drgn_program) * | [`drgn_module_iterator_program`](#drgn_module_iterator_program)  | Get the program that a module iterator is from. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_module_iterator_next`](#drgn_module_iterator_next)  | Get the next module in a module iterator. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_created_module_iterator_create`](#drgn_created_module_iterator_create)  | Create an iterator over created modules. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_loaded_module_iterator_create`](#drgn_loaded_module_iterator_create)  | Create an iterator that determines what executables, libraries, etc. are loaded in the program and creates modules to represent them. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_create_loaded_modules`](#drgn_create_loaded_modules)  | Determine what executables, libraries, etc. are loaded in the program and create modules to represent them. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_program_load_debug_info`](#drgn_program_load_debug_info)  | Load debugging information for the given set of files and/or modules. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_load_module_debug_info`](#drgn_load_module_debug_info)  | Load debugging information for the given modules using the enabled debugging information finders. |

---

{#drgn_module_find_by_name}

### drgn_module_find_by_name

```cpp
struct drgn_module * drgn_module_find_by_name(struct drgn_program * prog, const char * name)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:1477

Find the created [drgn_module](drgn_module.md#drgn_module) with the given `name`.

If there are multiple modules with the given name, one is returned arbitrarily.

#### Returns
[Module](Module.md#module-3), or `NULL` if not found.

---

{#drgn_module_find_by_address}

### drgn_module_find_by_address

```cpp
struct drgn_module * drgn_module_find_by_address(struct drgn_program * prog, uint64_t address)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:1485

Find the created [drgn_module](drgn_module.md#drgn_module) containing the given `address`.

#### Returns
[Module](Module.md#module-3), or `NULL` if not found.

---

{#drgn_module_find_main}

### drgn_module_find_main

```cpp
struct drgn_module * drgn_module_find_main(struct drgn_program * prog, const char * name)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:1493

Find the main module.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `name` | `const char *` | [Module](Module.md#module-3) name, or `NULL` to match any name. |

---

{#drgn_module_find_or_create_main}

### drgn_module_find_or_create_main

```cpp
struct drgn_error * drgn_module_find_or_create_main(struct drgn_program * prog, const char * name, struct drgn_module ** ret, bool * new_ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:1502

Find the main module, creating it if it doesn't already exist.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `new_ret` | `bool *` | `true` if the module was newly created, `false` if it was found. |

---

{#drgn_module_find_shared_library}

### drgn_module_find_shared_library

```cpp
struct drgn_module * drgn_module_find_shared_library(struct drgn_program * prog, const char * name, uint64_t dynamic_address)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:1508

Find a shared library module.

---

{#drgn_module_find_or_create_shared_library}

### drgn_module_find_or_create_shared_library

```cpp
struct drgn_error * drgn_module_find_or_create_shared_library(struct drgn_program * prog, const char * name, uint64_t dynamic_address, struct drgn_module ** ret, bool * new_ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:1519

Find a shared library module, creating it if it doesn't already exist.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `new_ret` | `bool *` | `true` if the module was newly created, `false` if it was found. |

---

{#drgn_module_find_vdso}

### drgn_module_find_vdso

```cpp
struct drgn_module * drgn_module_find_vdso(struct drgn_program * prog, const char * name, uint64_t dynamic_address)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:1526

Find a vDSO module.

---

{#drgn_module_find_or_create_vdso}

### drgn_module_find_or_create_vdso

```cpp
struct drgn_error * drgn_module_find_or_create_vdso(struct drgn_program * prog, const char * name, uint64_t dynamic_address, struct drgn_module ** ret, bool * new_ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:1536

Find a vDSO module, creating it if it doesn't already exist.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `new_ret` | `bool *` | `true` if the module was newly created, `false` if it was found. |

---

{#drgn_module_find_relocatable}

### drgn_module_find_relocatable

```cpp
struct drgn_module * drgn_module_find_relocatable(struct drgn_program * prog, const char * name, uint64_t address)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:1543

Find a relocatable module.

---

{#drgn_module_find_or_create_relocatable}

### drgn_module_find_or_create_relocatable

```cpp
struct drgn_error * drgn_module_find_or_create_relocatable(struct drgn_program * prog, const char * name, uint64_t address, struct drgn_module ** ret, bool * new_ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:1554

Find a relocatable module, creating it if it doesn't already exist.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `new_ret` | `bool *` | `true` if the module was newly created, `false` if it was found. |

---

{#drgn_module_find_extra}

### drgn_module_find_extra

```cpp
struct drgn_module * drgn_module_find_extra(struct drgn_program * prog, const char * name, uint64_t id)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:1578

Find an extra module.

---

{#drgn_module_find_or_create_extra}

### drgn_module_find_or_create_extra

```cpp
struct drgn_error * drgn_module_find_or_create_extra(struct drgn_program * prog, const char * name, uint64_t id, struct drgn_module ** ret, bool * new_ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:1587

Find an extra module, creating it if it doesn't already exist.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `new_ret` | `bool *` | `true` if the module was newly created, `false` if it was found. |

---

{#drgn_module_program}

### drgn_module_program

```cpp
struct drgn_program * drgn_module_program(const struct drgn_module * module)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:1594

Get the program that a module is from.

---

{#drgn_module_kind-1}

### drgn_module_kind

```cpp
enum drgn_module_kind drgn_module_kind(const struct drgn_module * module)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:1597

Get the kind of a module.

---

{#drgn_module_name}

### drgn_module_name

```cpp
const char * drgn_module_name(const struct drgn_module * module)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:1600

Get the name of a module.

---

{#drgn_module_info}

### drgn_module_info

```cpp
uint64_t drgn_module_info(const struct drgn_module * module)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:1612

Get the kind-specific info of a module.

* For the main module, it is always 0.
* For shared library and vDSO modules, it is the address of the dynamic section.
* For relocatable modules, it is an address identifying the module (e.g., for Linux kernel loadable modules, it is the base address).
* For extra modules, it is an arbitrary identification number.

---

{#drgn_module_num_address_ranges}

### drgn_module_num_address_ranges

```cpp
bool drgn_module_num_address_ranges(const struct drgn_module * module, size_t * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:1622

Get the number of address ranges where a module is loaded.

#### Returns
`true` on success (including if address ranges are empty), `false` if address ranges are not set.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `ret` | `size_t *` | Returned number of address ranges (zero if address ranges are empty or not set). |

---

{#drgn_module_address_range}

### drgn_module_address_range

```cpp
bool drgn_module_address_range(const struct drgn_module * module, size_t i, uint64_t * start_ret, uint64_t * end_ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:1633

Get the `i-th` address range where a module is loaded.

#### Returns
`true` on success, `false` if `i` is out of bounds (i.e., if it is greater than [drgn_module_num_address_ranges()](#drgn_module_num_address_ranges)).

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `start_ret` | `uint64_t *` | Minimum address (inclusive). |
| `end_ret` | `uint64_t *` | Maximum address (exclusive). |

---

{#drgn_module_set_address_range}

### drgn_module_set_address_range

```cpp
struct drgn_error * drgn_module_set_address_range(struct drgn_module * module, uint64_t start, uint64_t end)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:1646

Set the address range of a module.

This is equivalent to:

```cpp
uint64_t range[2] = {start, end};
drgn_module_set_address_ranges(module, &range, 1);
```

---

{#drgn_module_set_address_ranges}

### drgn_module_set_address_ranges

```cpp
struct drgn_error * drgn_module_set_address_ranges(struct drgn_module * module, uint64_t ranges, size_t num_ranges)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:1657

Set the address ranges of a module.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `ranges` | `uint64_t` | Ranges to set. The first element of each range is the start. The second is the end. The start must be less than the end. This is copied, so it need not remain valid after this function returns. |
| `num_ranges` | `size_t` | Number of ranges in `ranges`. |

---

{#drgn_module_unset_address_ranges}

### drgn_module_unset_address_ranges

```cpp
void drgn_module_unset_address_ranges(struct drgn_module * module)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:1662

Unset the address ranges for a module.

---

{#drgn_module_contains_address}

### drgn_module_contains_address

```cpp
bool drgn_module_contains_address(const struct drgn_module * module, uint64_t address)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:1665

Return whether a module's address ranges contain `address`.

---

{#drgn_module_build_id}

### drgn_module_build_id

```cpp
const char * drgn_module_build_id(const struct drgn_module * module, const void ** raw_ret, size_t * raw_len_ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:1678

Get the unique byte string (e.g., GNU build ID) identifying files used by a module.

#### Returns
Lowercase hexadecimal representation of build ID. `NULL` if not known. Valid until the build ID is changed.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `raw_ret` | `const void **` | Returned raw build ID. `NULL` if not known. Valid until the build ID is changed. |
| `raw_len_ret` | `size_t *` | Size of returned build ID, in bytes. 0 if not known. |

---

{#drgn_module_set_build_id}

### drgn_module_set_build_id

```cpp
struct drgn_error * drgn_module_set_build_id(struct drgn_module * module, const void * build_id, size_t build_id_len)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:1689

Set the unique byte string (e.g., GNU build ID) identifying files used by a module.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `build_id` | `const void *` | New build ID. |
| `build_id_len` | `size_t` | New size of build ID, in bytes. May be 0 to unset the build ID. |

---

{#drgn_module_get_section_address}

### drgn_module_get_section_address

```cpp
struct drgn_error * drgn_module_get_section_address(struct drgn_module * module, const char * name, uint64_t * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:1694

Get the address of a section with the given name in a relocatable module.

---

{#drgn_module_set_section_address}

### drgn_module_set_section_address

```cpp
struct drgn_error * drgn_module_set_section_address(struct drgn_module * module, const char * name, uint64_t address)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:1703

Set the address of a section with the given name in a relocatable module.

This is not allowed after a file has been assigned to the module.

---

{#drgn_module_delete_section_address}

### drgn_module_delete_section_address

```cpp
struct drgn_error * drgn_module_delete_section_address(struct drgn_module * module, const char * name)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:1712

Unset the address of a section with the given name in a relocatable module.

This is not allowed after a file has been assigned to the module.

---

{#drgn_module_num_section_addresses}

### drgn_module_num_section_addresses

```cpp
struct drgn_error * drgn_module_num_section_addresses(struct drgn_module * module, size_t * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:1718

Get the number of section addresses currently set in a relocatable module.

---

{#drgn_module_section_address_iterator_create}

### drgn_module_section_address_iterator_create

```cpp
struct drgn_error * drgn_module_section_address_iterator_create(struct drgn_module * module, struct drgn_module_section_address_iterator ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:1726

Create a [drgn_module_section_address_iterator](drgn_module_section_address_iterator.md#drgn_module_section_address_iterator).

---

{#drgn_module_section_address_iterator_destroy}

### drgn_module_section_address_iterator_destroy

```cpp
void drgn_module_section_address_iterator_destroy(struct drgn_module_section_address_iterator * it)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:1731

Destroy a [drgn_module_section_address_iterator](drgn_module_section_address_iterator.md#drgn_module_section_address_iterator).

---

{#drgn_module_section_address_iterator_module}

### drgn_module_section_address_iterator_module

```cpp
struct drgn_module * drgn_module_section_address_iterator_module(struct drgn_module_section_address_iterator * it)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:1735

Get the module that a [drgn_module_section_address_iterator](drgn_module_section_address_iterator.md#drgn_module_section_address_iterator) is for.

---

{#drgn_module_section_address_iterator_next}

### drgn_module_section_address_iterator_next

```cpp
struct drgn_error * drgn_module_section_address_iterator_next(struct drgn_module_section_address_iterator * it, const char ** name_ret, uint64_t * address_ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:1747

Get the next section name and address from a [drgn_module_section_address_iterator](drgn_module_section_address_iterator.md#drgn_module_section_address_iterator).

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `name_ret` | `const char **` | Returned name. Valid until the the next call to [drgn_module_section_address_iterator_next()](#drgn_module_section_address_iterator_next) or [drgn_module_section_address_iterator_destroy()](#drgn_module_section_address_iterator_destroy) on @it. |
| `address_ret` | `uint64_t *` | Returned address. |

---

{#drgn_module_loaded_file_status}

### drgn_module_loaded_file_status

```cpp
enum drgn_module_file_status drgn_module_loaded_file_status(const struct drgn_module * module)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:1781

Get the status of a module's loaded file.

---

{#drgn_module_set_loaded_file_status}

### drgn_module_set_loaded_file_status

```cpp
bool drgn_module_set_loaded_file_status(struct drgn_module * module, enum drgn_module_file_status status)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:1784

Set the status of a module's loaded file.

---

{#drgn_module_wants_loaded_file}

### drgn_module_wants_loaded_file

```cpp
bool drgn_module_wants_loaded_file(const struct drgn_module * module)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:1793

Get whether a module wants a loaded file.

For future-proofness, debug info finders should prefer this over comparing [drgn_module_loaded_file_status()](#drgn_module_loaded_file_status) directly.

---

{#drgn_module_loaded_file_path}

### drgn_module_loaded_file_path

```cpp
const char * drgn_module_loaded_file_path(const struct drgn_module * module)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:1796

Get the absolute path of a module's loaded file, or `NULL` if not known.

---

{#drgn_module_loaded_file_bias}

### drgn_module_loaded_file_bias

```cpp
uint64_t drgn_module_loaded_file_bias(const struct drgn_module * module)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:1802

Get the difference between the load address in the program and addresses in a module's loaded file.

---

{#drgn_module_debug_file_status}

### drgn_module_debug_file_status

```cpp
enum drgn_module_file_status drgn_module_debug_file_status(const struct drgn_module * module)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:1805

---

{#drgn_module_set_debug_file_status}

### drgn_module_set_debug_file_status

```cpp
bool drgn_module_set_debug_file_status(struct drgn_module * module, enum drgn_module_file_status status)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:1807

---

{#drgn_module_wants_debug_file}

### drgn_module_wants_debug_file

```cpp
bool drgn_module_wants_debug_file(const struct drgn_module * module)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:1816

Get whether a module wants a debug file.

For future-proofness, debug info finders should prefer this over comparing [drgn_module_debug_file_status()](#drgn_module_debug_file_status) directly.

---

{#drgn_module_debug_file_path}

### drgn_module_debug_file_path

```cpp
const char * drgn_module_debug_file_path(const struct drgn_module * module)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:1819

Get the absolute path of a module's debug file, or `NULL` if not known.

---

{#drgn_module_debug_file_bias}

### drgn_module_debug_file_bias

```cpp
uint64_t drgn_module_debug_file_bias(const struct drgn_module * module)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:1825

Get the difference between the load address in the program and addresses in a module's debug file.

---

{#drgn_module_supplementary_debug_file_kind}

### drgn_module_supplementary_debug_file_kind

```cpp
enum drgn_supplementary_file_kind drgn_module_supplementary_debug_file_kind(const struct drgn_module * module)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:1829

Get the kind of a module's supplementary debug file.

---

{#drgn_module_supplementary_debug_file_path}

### drgn_module_supplementary_debug_file_path

```cpp
const char * drgn_module_supplementary_debug_file_path(const struct drgn_module * module)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:1836

Get the absolute path of a module's supplementary debug file, or `NULL` if not known or not needed.

---

{#drgn_module_wanted_supplementary_debug_file}

### drgn_module_wanted_supplementary_debug_file

```cpp
enum drgn_supplementary_file_kind drgn_module_wanted_supplementary_debug_file(struct drgn_module * module, const char ** debug_file_path_ret, const char ** supplementary_path_ret, const void ** checksum_ret, size_t * checksum_len_ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:1851

Get information about the supplementary debug file that a module currently wants.

#### Returns
Kind of supplementary file.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `debug_file_path_ret` | `const char **` | Path of main file that wants the supplementary file. |
| `supplementary_path_ret` | `const char **` | Path to supplementary file. This may be absolute or relative to `debug_file_path_ret`. |
| `checksum_ret` | `const void **` | Unique identifier of the supplementary file. |
| `checksum_len_ret` | `size_t *` | Size of unique identifier, in bytes. |

---

{#drgn_module_object}

### drgn_module_object

```cpp
struct drgn_error * drgn_module_object(const struct drgn_module * module, struct drgn_object * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:1868

Return the object associated with this module.

For some modules, there may be an object related to it. For example, drgn automatically identifies the Linux kernel `struct module *` associated with loadable modules, and associates it with them. Users may set or replace an associated object with drgn_set_module_object().

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `ret` | struct [`drgn_object`](drgn_object.md#drgn_object-1) * | Initialized object where the module object is placed |

---

{#drgn_module_set_object}

### drgn_module_set_object

```cpp
struct drgn_error * drgn_module_set_object(struct drgn_module * module, const struct drgn_object * obj)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:1875

Set the object associated with this module.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `obj` | const struct [`drgn_object`](drgn_object.md#drgn_object-1) * | A new (or replacement) object for the module |

---

{#drgn_program_register_debug_info_finder}

### drgn_program_register_debug_info_finder

```cpp
struct drgn_error * drgn_program_register_debug_info_finder(struct drgn_program * prog, const char * name, const struct drgn_debug_info_finder_ops * ops, void * arg, size_t enable_index)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:1914

[Register](Register.md#register) a debugging information finding callback.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `name` | `const char *` | Finder name. This is copied. |
| `ops` | const struct [`drgn_debug_info_finder_ops`](drgn_debug_info_finder_ops.md#drgn_debug_info_finder_ops) * | Callback table. This is copied. |
| `arg` | `void *` | Argument to pass to callbacks. |
| `enable_index` | `size_t` | Insert the finder into the list of enabled finders at the given index. If [DRGN_HANDLER_REGISTER_ENABLE_LAST](Programs.md#group__Programs_1gga106ab5141fe935134e70ab83c0689759a8d7b573f89ffb2ef07a718cb778df021) or greater than the number of enabled finders, insert it at the end. If [DRGN_HANDLER_REGISTER_DONT_ENABLE](Programs.md#group__Programs_1gga106ab5141fe935134e70ab83c0689759ac8bf815074393b125e389935aeb94870), don’t enable the finder. |

---

{#drgn_program_registered_debug_info_finders}

### drgn_program_registered_debug_info_finders

```cpp
struct drgn_error * drgn_program_registered_debug_info_finders(struct drgn_program * prog, const char *** names_ret, size_t * count_ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:1928

Get the names of all registered debugging information finders.

The order of the names is arbitrary.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `names_ret` | `const char ***` | Returned array of names. |
| `count_ret` | `size_t *` | Returned number of names in `names_ret`. |

---

{#drgn_program_set_enabled_debug_info_finders}

### drgn_program_set_enabled_debug_info_finders

```cpp
struct drgn_error * drgn_program_set_enabled_debug_info_finders(struct drgn_program * prog, const char *const * names, size_t count)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:1942

Set the list of enabled debugging information finders.

Finders are called in the same order as the list until all wanted files have been found.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `names` | `const char *const *` | Names of finders to enable, in order. |
| `count` | `size_t` | Number of names in `names`. |

---

{#drgn_program_enabled_debug_info_finders}

### drgn_program_enabled_debug_info_finders

```cpp
struct drgn_error * drgn_program_enabled_debug_info_finders(struct drgn_program * prog, const char *** names_ret, size_t * count_ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:1953

Get the names of enabled debugging information finders, in order.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `names_ret` | `const char ***` | Returned array of names. |
| `count_ret` | `size_t *` | Returned number of names in `names_ret`. |

---

{#drgn_debug_info_options_get_directories}

### drgn_debug_info_options_get_directories

```cpp
const char *const * drgn_debug_info_options_get_directories(const struct drgn_debug_info_options * options)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:1981

Get the list of directories to search for debugging information files.

#### Returns
Null-terminated list of directories. Valid until [drgn_debug_info_options_set_directories()](#drgn_debug_info_options_set_directories) or [drgn_debug_info_options_destroy()](#group__Modules_1ga3560c98bc3705d9ccfb45e9d09418ec7) is called on `options`.

---

{#drgn_debug_info_options_set_directories}

### drgn_debug_info_options_set_directories

```cpp
struct drgn_error * drgn_debug_info_options_set_directories(struct drgn_debug_info_options * options, const char *const * value)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:1990

Set the list of directories to search for debugging information files.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `value` | `const char *const *` | Null-terminated list of directories. It is copied, so it need not remain valid after this function returns. |

---

{#drgn_debug_info_options_get_try_module_name}

### drgn_debug_info_options_get_try_module_name

```cpp
struct drgn_error bool drgn_debug_info_options_get_try_module_name(const struct drgn_debug_info_options * options)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:1996

Get whether to try module names that look like filesystem paths.

---

{#drgn_debug_info_options_set_try_module_name}

### drgn_debug_info_options_set_try_module_name

```cpp
void drgn_debug_info_options_set_try_module_name(struct drgn_debug_info_options * options, bool value)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:2000

Set whether to try module names that look like filesystem paths.

---

{#drgn_debug_info_options_get_try_build_id}

### drgn_debug_info_options_get_try_build_id

```cpp
bool drgn_debug_info_options_get_try_build_id(const struct drgn_debug_info_options * options)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:2005

Get whether to try files by build ID.

---

{#drgn_debug_info_options_set_try_build_id}

### drgn_debug_info_options_set_try_build_id

```cpp
void drgn_debug_info_options_set_try_build_id(struct drgn_debug_info_options * options, bool value)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:2009

Set whether to try files by build ID.

---

{#drgn_debug_info_options_get_debug_link_directories}

### drgn_debug_info_options_get_debug_link_directories

```cpp
const char *const * drgn_debug_info_options_get_debug_link_directories(const struct drgn_debug_info_options * options)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:2020

Get the list of directories to search for by debug link.

#### Returns
Null-terminated list of directories. Valid until [drgn_debug_info_options_set_debug_link_directories()](#drgn_debug_info_options_set_debug_link_directories) or [drgn_debug_info_options_destroy()](#group__Modules_1ga3560c98bc3705d9ccfb45e9d09418ec7) is called on `options`.

---

{#drgn_debug_info_options_set_debug_link_directories}

### drgn_debug_info_options_set_debug_link_directories

```cpp
struct drgn_error * drgn_debug_info_options_set_debug_link_directories(struct drgn_debug_info_options * options, const char *const * value)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:2029

Set the list of directories to search for by debug link.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `value` | `const char *const *` | Null-terminated list of directories. It is copied, so it need not remain valid after this function returns. |

---

{#drgn_debug_info_options_get_try_debug_link}

### drgn_debug_info_options_get_try_debug_link

```cpp
struct drgn_error bool drgn_debug_info_options_get_try_debug_link(const struct drgn_debug_info_options * options)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:2035

Get whether to try files by debug link.

---

{#drgn_debug_info_options_set_try_debug_link}

### drgn_debug_info_options_set_try_debug_link

```cpp
void drgn_debug_info_options_set_try_debug_link(struct drgn_debug_info_options * options, bool value)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:2039

Set whether to try files by debug link.

---

{#drgn_debug_info_options_get_try_procfs}

### drgn_debug_info_options_get_try_procfs

```cpp
bool drgn_debug_info_options_get_try_procfs(const struct drgn_debug_info_options * options)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:2044

Get whether to try files via procfs for local processes.

---

{#drgn_debug_info_options_set_try_procfs}

### drgn_debug_info_options_set_try_procfs

```cpp
void drgn_debug_info_options_set_try_procfs(struct drgn_debug_info_options * options, bool value)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:2048

Set whether to try files via procfs for local processes.

---

{#drgn_debug_info_options_get_try_embedded_vdso}

### drgn_debug_info_options_get_try_embedded_vdso

```cpp
bool drgn_debug_info_options_get_try_embedded_vdso(const struct drgn_debug_info_options * options)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:2053

Get whether to try the vDSO embedded in a process's memory/core dump.

---

{#drgn_debug_info_options_set_try_embedded_vdso}

### drgn_debug_info_options_set_try_embedded_vdso

```cpp
void drgn_debug_info_options_set_try_embedded_vdso(struct drgn_debug_info_options * options, bool value)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:2057

Set whether to try the vDSO embedded in a process's memory/core dump.

---

{#drgn_debug_info_options_get_try_reuse}

### drgn_debug_info_options_get_try_reuse

```cpp
bool drgn_debug_info_options_get_try_reuse(const struct drgn_debug_info_options * options)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:2064

Get whether to reuse a module's loaded file as its debug file or vice versa.

---

{#drgn_debug_info_options_set_try_reuse}

### drgn_debug_info_options_set_try_reuse

```cpp
void drgn_debug_info_options_set_try_reuse(struct drgn_debug_info_options * options, bool value)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:2070

Set whether to reuse a module's loaded file as its debug file or vice versa.

---

{#drgn_debug_info_options_get_try_supplementary}

### drgn_debug_info_options_get_try_supplementary

```cpp
bool drgn_debug_info_options_get_try_supplementary(const struct drgn_debug_info_options * options)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:2075

Get whether to try finding supplementary files.

---

{#drgn_debug_info_options_set_try_supplementary}

### drgn_debug_info_options_set_try_supplementary

```cpp
void drgn_debug_info_options_set_try_supplementary(struct drgn_debug_info_options * options, bool value)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:2079

Set whether to try finding supplementary files.

---

{#drgn_debug_info_options_get_kernel_directories}

### drgn_debug_info_options_get_kernel_directories

```cpp
const char *const * drgn_debug_info_options_get_kernel_directories(const struct drgn_debug_info_options * options)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:2090

Get the list of directories to search for kernel debugging information files.

#### Returns
Null-terminated list of directories. Valid until [drgn_debug_info_options_set_kernel_directories()](#drgn_debug_info_options_set_kernel_directories) or [drgn_debug_info_options_destroy()](#group__Modules_1ga3560c98bc3705d9ccfb45e9d09418ec7) is called on `options`.

---

{#drgn_debug_info_options_set_kernel_directories}

### drgn_debug_info_options_set_kernel_directories

```cpp
struct drgn_error * drgn_debug_info_options_set_kernel_directories(struct drgn_debug_info_options * options, const char *const * value)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:2099

Set the list of directories to search for kernel debugging information files.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `value` | `const char *const *` | Null-terminated list of directories. It is copied, so it need not remain valid after this function returns. |

---

{#drgn_debug_info_options_get_try_kmod}

### drgn_debug_info_options_get_try_kmod

```cpp
enum drgn_kmod_search_method drgn_debug_info_options_get_try_kmod(const struct drgn_debug_info_options * options)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:2114

Get how to search for loadable kernel module debugging information.

---

{#drgn_debug_info_options_set_try_kmod}

### drgn_debug_info_options_set_try_kmod

```cpp
void drgn_debug_info_options_set_try_kmod(struct drgn_debug_info_options * options, enum drgn_kmod_search_method value)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:2118

Set how to search for loadable kernel module debugging information.

---

{#drgn_program_debug_info_options}

### drgn_program_debug_info_options

```cpp
struct drgn_debug_info_options * drgn_program_debug_info_options(struct drgn_program * prog)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:2128

Get the default debugging information options for `prog`.

#### Returns
[Program](Program.md#program) options. May be modified as needed. Must not be passed to [drgn_debug_info_options_destroy()](#group__Modules_1ga3560c98bc3705d9ccfb45e9d09418ec7).

---

{#drgn_find_standard_debug_info}

### drgn_find_standard_debug_info

```cpp
struct drgn_error * drgn_find_standard_debug_info(struct drgn_module *const * modules, size_t num_modules, struct drgn_debug_info_options * options)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:2137

Load debugging information for the given modules from the standard locations.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `options` | struct [`drgn_debug_info_options`](drgn_debug_info_options.md#drgn_debug_info_options) * | Options to use, or `NULL` to use the program's default options. |

---

{#drgn_module_try_file}

### drgn_module_try_file

```cpp
struct drgn_error * drgn_module_try_file(struct drgn_module * module, const char * path, int fd, bool force)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:2151

Try to use the given file for a module.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `path` | `const char *` | Path to file. |
| `fd` | `int` | If nonnegative, an open file descriptor referring to the file. This always takes ownership of the file descriptor even if the file is not used or on error. |
| `force` | `bool` | If `true`, don't check whether the file matches the module. |

---

{#drgn_module_iterator_destroy}

### drgn_module_iterator_destroy

```cpp
void drgn_module_iterator_destroy(struct drgn_module_iterator * it)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:2159

Destroy a [drgn_module_iterator](drgn_module_iterator.md#drgn_module_iterator).

---

{#drgn_module_iterator_program}

### drgn_module_iterator_program

```cpp
struct drgn_program * drgn_module_iterator_program(const struct drgn_module_iterator * it)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:2163

Get the program that a module iterator is from.

---

{#drgn_module_iterator_next}

### drgn_module_iterator_next

```cpp
struct drgn_error * drgn_module_iterator_next(struct drgn_module_iterator * it, struct drgn_module ** ret, bool * new_ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:2171

Get the next module in a module iterator.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `ret` | struct [`drgn_module`](drgn_module.md#drgn_module) ** | Returned module, or `NULL` if there are no more modules. |
| `new_ret` | `bool *` | Whether the module was newly created. May be `NULL`. |

---

{#drgn_created_module_iterator_create}

### drgn_created_module_iterator_create

```cpp
struct drgn_error * drgn_created_module_iterator_create(struct drgn_program * prog, struct drgn_module_iterator ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:2177

Create an iterator over created modules.

---

{#drgn_loaded_module_iterator_create}

### drgn_loaded_module_iterator_create

```cpp
struct drgn_error * drgn_loaded_module_iterator_create(struct drgn_program * prog, struct drgn_module_iterator ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:2185

Create an iterator that determines what executables, libraries, etc. are loaded in the program and creates modules to represent them.

---

{#drgn_create_loaded_modules}

### drgn_create_loaded_modules

```cpp
struct drgn_error * drgn_create_loaded_modules(struct drgn_program * prog)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:2197

Determine what executables, libraries, etc. are loaded in the program and create modules to represent them.

This is a shortcut for creating an iterator with [drgn_loaded_module_iterator_create()](#drgn_loaded_module_iterator_create) and calling [drgn_module_iterator_next()](#drgn_module_iterator_next) until it is exhausted.

---

{#drgn_program_load_debug_info}

### drgn_program_load_debug_info

```cpp
struct drgn_error * drgn_program_load_debug_info(struct drgn_program * prog, const char ** paths, size_t n, bool load_default, bool load_main)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:2207

Load debugging information for the given set of files and/or modules.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `load_default` | `bool` | Whether to load all debugging information for all loaded modules. This implies `load_main`. |
| `load_main` | `bool` | Whether to load all debugging information for the main module. |

---

{#drgn_load_module_debug_info}

### drgn_load_module_debug_info

```cpp
struct drgn_error * drgn_load_module_debug_info(struct drgn_module ** modules, size_t * num_modules)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:2216

Load debugging information for the given modules using the enabled debugging information finders.

