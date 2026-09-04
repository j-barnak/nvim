{#drgn_debug_info}

# drgn_debug_info

```cpp
#include <debug_info.h>
```

```cpp
struct drgn_debug_info
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.h:80

Cache of debugging information.

## Public Attributes

| Return | Name | Description |
|--------|------|-------------|
| struct [`drgn_program`](drgn_program.md#drgn_program) * | [`prog`](#prog-3)  | [Program](Program.md#program) owning this cache. |
| struct [`drgn_type_finder`](drgn_type_finder.md#drgn_type_finder) | [`type_finder`](#type_finder)  |  |
| struct [`drgn_object_finder`](drgn_object_finder.md#drgn_object_finder) | [`object_finder`](#object_finder)  |  |
| struct [`drgn_symbol_finder`](drgn_symbol_finder.md#drgn_symbol_finder) | [`symbol_finder`](#symbol_finder)  |  |
| struct [`drgn_module`](drgn_module.md#drgn_module) * | [`main_module`](#main_module)  | Main module. `NULL` if not created yet. |
| `struct drgn_module_table` | [`modules`](#modules-1)  | Table of all modules indexed by name. |
| `uint64_t` | [`modules_generation`](#modules_generation)  | Counter used to detect when [modules](#modules-1) is modified during iteration of a [drgn_created_module_iterator](drgn_created_module_iterator.md#drgn_created_module_iterator). |
| `struct drgn_module_address_tree` | [`modules_by_address`](#modules_by_address)  | Tree of modules sorted by start address. |
| struct [`drgn_module`](drgn_module.md#drgn_module) * | [`modules_pending_indexing`](#modules_pending_indexing)  | Singly-linked list of modules that need to have their DWARF information indexed. |
| struct [`drgn_dwarf_info`](drgn_dwarf_info.md#drgn_dwarf_info) | [`dwarf`](#dwarf)  | DWARF debugging information. |
| struct [`drgn_handler_list`](drgn_handler_list.md#drgn_handler_list) | [`debug_info_finders`](#debug_info_finders)  |  |
| struct [`drgn_debug_info_finder`](drgn_debug_info_finder.md#drgn_debug_info_finder) | [`standard_debug_info_finder`](#standard_debug_info_finder)  |  |
| struct [`drgn_debug_info_options`](drgn_debug_info_options.md#drgn_debug_info_options) | [`options`](#options)  |  |
| `uint64_t` | [`load_debug_info_generation`](#load_debug_info_generation)  | Counter used to detect when loading debugging information is attempted. |
| `uint64_t` | [`supplementary_file_generation`](#supplementary_file_generation)  | Counter used to detect when the wanted supplementary file for a module has changed. |
| `bool` | [`logged_no_debuginfod`](#logged_no_debuginfod)  |  |
| struct [`drgn_map_files_segment`](drgn_map_files_segment.md#drgn_map_files_segment) * | [`map_files_segments`](#map_files_segments)  | Cache of entries in /proc/$pid/map_files used for finding loaded files. Populated the first time we need it or opportunistically when we parse /proc/$pid/maps. Rebuilt whenever we try to open an entry that no longer exists. |
| `size_t` | [`num_map_files_segments`](#num_map_files_segments)  | Number of segments in [map_files_segments](#map_files_segments). |

---

{#prog-3}

### prog

```cpp
struct drgn_program * prog
```

Type: struct [`drgn_program`](drgn_program.md#drgn_program) *

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.h:82

[Program](Program.md#program) owning this cache.

---

{#type_finder}

### type_finder

```cpp
struct drgn_type_finder type_finder
```

Type: struct [`drgn_type_finder`](drgn_type_finder.md#drgn_type_finder)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.h:84

---

{#object_finder}

### object_finder

```cpp
struct drgn_object_finder object_finder
```

Type: struct [`drgn_object_finder`](drgn_object_finder.md#drgn_object_finder)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.h:85

---

{#symbol_finder}

### symbol_finder

```cpp
struct drgn_symbol_finder symbol_finder
```

Type: struct [`drgn_symbol_finder`](drgn_symbol_finder.md#drgn_symbol_finder)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.h:86

---

{#main_module}

### main_module

```cpp
struct drgn_module * main_module
```

Type: struct [`drgn_module`](drgn_module.md#drgn_module) *

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.h:89

Main module. `NULL` if not created yet.

---

{#modules-1}

### modules

```cpp
struct drgn_module_table modules
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.h:96

Table of all modules indexed by name.

Modules with the same name (which should be rare) are on a singly-linked list ([drgn_module::next_same_name](drgn_module.md#next_same_name)).

---

{#modules_generation}

### modules_generation

```cpp
uint64_t modules_generation
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.h:101

Counter used to detect when [modules](#modules-1) is modified during iteration of a [drgn_created_module_iterator](drgn_created_module_iterator.md#drgn_created_module_iterator).

---

{#modules_by_address}

### modules_by_address

```cpp
struct drgn_module_address_tree modules_by_address
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.h:103

Tree of modules sorted by start address.

---

{#modules_pending_indexing}

### modules_pending_indexing

```cpp
struct drgn_module * modules_pending_indexing
```

Type: struct [`drgn_module`](drgn_module.md#drgn_module) *

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.h:108

Singly-linked list of modules that need to have their DWARF information indexed.

---

{#dwarf}

### dwarf

```cpp
struct drgn_dwarf_info dwarf
```

Type: struct [`drgn_dwarf_info`](drgn_dwarf_info.md#drgn_dwarf_info)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.h:110

DWARF debugging information.

---

{#debug_info_finders}

### debug_info_finders

```cpp
struct drgn_handler_list debug_info_finders
```

Type: struct [`drgn_handler_list`](drgn_handler_list.md#drgn_handler_list)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.h:112

---

{#standard_debug_info_finder}

### standard_debug_info_finder

```cpp
struct drgn_debug_info_finder standard_debug_info_finder
```

Type: struct [`drgn_debug_info_finder`](drgn_debug_info_finder.md#drgn_debug_info_finder)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.h:113

---

{#options}

### options

```cpp
struct drgn_debug_info_options options
```

Type: struct [`drgn_debug_info_options`](drgn_debug_info_options.md#drgn_debug_info_options)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.h:114

---

{#load_debug_info_generation}

### load_debug_info_generation

```cpp
uint64_t load_debug_info_generation
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.h:121

Counter used to detect when loading debugging information is attempted.

**See also**: [drgn_module::load_debug_info_generation](drgn_module.md#load_debug_info_generation-1)

---

{#supplementary_file_generation}

### supplementary_file_generation

```cpp
uint64_t supplementary_file_generation
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.h:128

Counter used to detect when the wanted supplementary file for a module has changed.

**See also**: [drgn_module_wanted_supplementary_file::generation](drgn_module_wanted_supplementary_file.md#generation-2)

---

{#logged_no_debuginfod}

### logged_no_debuginfod

```cpp
bool logged_no_debuginfod
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.h:140

---

{#map_files_segments}

### map_files_segments

```cpp
struct drgn_map_files_segment * map_files_segments
```

Type: struct [`drgn_map_files_segment`](drgn_map_files_segment.md#drgn_map_files_segment) *

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.h:148

Cache of entries in /proc/$pid/map_files used for finding loaded files. Populated the first time we need it or opportunistically when we parse /proc/$pid/maps. Rebuilt whenever we try to open an entry that no longer exists.

---

{#num_map_files_segments}

### num_map_files_segments

```cpp
size_t num_map_files_segments
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.h:150

Number of segments in [map_files_segments](#map_files_segments).

