{#drgn_module}

# drgn_module

```cpp
#include <debug_info.h>
```

```cpp
struct drgn_module
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.h:201

## Public Attributes

| Return | Name | Description |
|--------|------|-------------|
| struct [`drgn_program`](drgn_program.md#drgn_program) * | [`prog`](#prog-5)  |  |
| enum [`drgn_module_kind`](drgn_module_kind.md#drgn_module_kind) | [`kind`](#kind-3)  |  |
| `char *` | [`name`](#name-5)  | [Module](Module.md#module-3) name. |
| `uint64_t` | [`info`](#info)  | Kind-specific info. |
| struct [`drgn_module`](#drgn_module) * | [`next_same_name`](#next_same_name)  | Next module with the same name in [drgn_debug_info::modules](drgn_debug_info.md#modules-1). |
| `void *` | [`build_id`](#build_id-1)  | Raw binary build ID. `NULL` if the module does not have a build ID. |
| `size_t` | [`build_id_len`](#build_id_len-1)  | Length of [drgn_module::build_id](#build_id-1) in bytes. Zero if the module does not have a build ID. |
| `char *` | [`build_id_str`](#build_id_str)  | Build ID as a null-terminated hexadecimal string. `NULL` if the module does not have a build ID. |
| struct [`drgn_module_address_range`](drgn_module_address_range.md#drgn_module_address_range-1) * | [`address_ranges`](#address_ranges)  | Load address ranges. `NULL` if not known yet. |
| `size_t` | [`num_address_ranges`](#num_address_ranges)  | Number of ranges in [address_ranges](#address_ranges). |
| struct [`drgn_module_address_range`](drgn_module_address_range.md#drgn_module_address_range-1) | [`single_address_range`](#single_address_range)  | Placeholder assigned to [address_ranges](#address_ranges) in two cases: |
| struct [`drgn_elf_file`](drgn_elf_file.md#drgn_elf_file) * | [`loaded_file`](#loaded_file)  |  |
| struct [`drgn_elf_file`](drgn_elf_file.md#drgn_elf_file) * | [`debug_file`](#debug_file)  |  |
| struct [`drgn_elf_file`](drgn_elf_file.md#drgn_elf_file) * | [`supplementary_debug_file`](#supplementary_debug_file)  |  |
| struct [`drgn_elf_file`](drgn_elf_file.md#drgn_elf_file) * | [`gnu_debugdata_file`](#gnu_debugdata_file)  |  |
| `struct drgn_elf_file_dwarf_table` | [`split_dwarf_files`](#split_dwarf_files)  | Table mapping libdw handle to corresponding [drgn_elf_file](drgn_elf_file.md#drgn_elf_file). |
| `uint64_t` | [`loaded_file_bias`](#loaded_file_bias)  |  |
| `uint64_t` | [`debug_file_bias`](#debug_file_bias)  |  |
| enum [`drgn_module_file_status`](drgn_module_file_status.md#drgn_module_file_status) | [`loaded_file_status`](#loaded_file_status)  |  |
| enum [`drgn_module_file_status`](drgn_module_file_status.md#drgn_module_file_status) | [`debug_file_status`](#debug_file_status)  |  |
| enum [`drgn_supplementary_file_kind`](drgn_supplementary_file_kind.md#drgn_supplementary_file_kind) | [`supplementary_debug_file_kind`](#supplementary_debug_file_kind)  |  |
| struct [`drgn_module_dwarf_info`](drgn_module_dwarf_info.md#drgn_module_dwarf_info) | [`dwarf`](#dwarf-1)  | DWARF debugging information. |
| struct [`drgn_module_orc_info`](drgn_module_orc_info.md#drgn_module_orc_info) | [`orc`](#orc)  | ORC unwinder information. |
| struct [`drgn_elf_symbol_table`](drgn_elf_symbol_table.md#drgn_elf_symbol_table) | [`elf_symtab`](#elf_symtab)  | ELF symbol table. |
| struct [`drgn_elf_symbol_table`](drgn_elf_symbol_table.md#drgn_elf_symbol_table) | [`gnu_debugdata_symtab`](#gnu_debugdata_symtab)  | [Symbol](Symbol.md#symbol) table from the gnu_debugdata_file |
| `bool` | [`parsed_debug_frame`](#parsed_debug_frame)  | Whether .debug_frame has been parsed. |
| `bool` | [`parsed_eh_frame`](#parsed_eh_frame)  | Whether .eh_frame has been parsed. |
| `bool` | [`parsed_orc`](#parsed_orc)  | Whether ORC unwinder data has been parsed. |
| enum [`drgn_module_file_mask`](drgn_module_file_mask.md#drgn_module_file_mask) | [`elf_symtab_pending_files`](#elf_symtab_pending_files)  | Which files need to be checked for an ELF symbol table. |
| `bool` | [`have_full_symtab`](#have_full_symtab)  | Whether a full symbol table has been found (as opposed to a dynamic symbol table, which only contains a subset of symbols). |
| `struct drgn_module_section_address_map` | [`section_addresses`](#section_addresses)  | Mapping from section name to address. |
| `uint64_t` | [`section_addresses_generation`](#section_addresses_generation)  | Counter used to detect when [section_addresses](#section_addresses) is modified during iteration of a [drgn_module_section_address_iterator](drgn_module_section_address_iterator.md#drgn_module_section_address_iterator). |
| `uint64_t` | [`load_debug_info_generation`](#load_debug_info_generation-1)  | Counter used to detect when loading debugging information is attempted. |
| struct [`drgn_module_wanted_supplementary_file`](drgn_module_wanted_supplementary_file.md#drgn_module_wanted_supplementary_file) * | [`wanted_supplementary_debug_file`](#wanted_supplementary_debug_file)  |  |
| struct [`drgn_module`](#drgn_module) * | [`pending_indexing_next`](#pending_indexing_next)  | Node in [drgn_debug_info::modules_pending_indexing](drgn_debug_info.md#modules_pending_indexing). |
| struct [`drgn_object`](drgn_object.md#drgn_object-1) | [`object`](#object-2)  | Object the module was created from |

---

{#prog-5}

### prog

```cpp
struct drgn_program * prog
```

Type: struct [`drgn_program`](drgn_program.md#drgn_program) *

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.h:202

---

{#kind-3}

### kind

```cpp
enum drgn_module_kind kind
```

Type: enum [`drgn_module_kind`](drgn_module_kind.md#drgn_module_kind)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.h:203

---

{#name-5}

### name

```cpp
char * name
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.h:206

[Module](Module.md#module-3) name.

---

{#info}

### info

```cpp
uint64_t info
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.h:208

Kind-specific info.

---

{#next_same_name}

### next_same_name

```cpp
struct drgn_module * next_same_name
```

Type: struct [`drgn_module`](#drgn_module) *

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.h:211

Next module with the same name in [drgn_debug_info::modules](drgn_debug_info.md#modules-1).

---

{#build_id-1}

### build_id

```cpp
void * build_id
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.h:216

Raw binary build ID. `NULL` if the module does not have a build ID.

---

{#build_id_len-1}

### build_id_len

```cpp
size_t build_id_len
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.h:221

Length of [drgn_module::build_id](#build_id-1) in bytes. Zero if the module does not have a build ID.

---

{#build_id_str}

### build_id_str

```cpp
char * build_id_str
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.h:230

Build ID as a null-terminated hexadecimal string. `NULL` if the module does not have a build ID.

Used for logging and finding debugging information.

This is allocated together with [drgn_module::build_id](#build_id-1).

---

{#address_ranges}

### address_ranges

```cpp
struct drgn_module_address_range * address_ranges
```

Type: struct [`drgn_module_address_range`](drgn_module_address_range.md#drgn_module_address_range-1) *

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.h:232

Load address ranges. `NULL` if not known yet.

---

{#num_address_ranges}

### num_address_ranges

```cpp
size_t num_address_ranges
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.h:234

Number of ranges in [address_ranges](#address_ranges).

---

{#single_address_range}

### single_address_range

```cpp
struct drgn_module_address_range single_address_range
```

Type: struct [`drgn_module_address_range`](drgn_module_address_range.md#drgn_module_address_range-1)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.h:246

Placeholder assigned to [address_ranges](#address_ranges) in two cases:

1. If [num_address_ranges](#num_address_ranges) is 1. This lets us avoid allocating the address ranges separately. This is a minor optimization for the common case, but more importantly, `drgn_module_maybe_use_elf_file()` can't handle [drgn_module_set_address_range()](Modules.md#drgn_module_set_address_range) failing.
1. If the address range is known to be empty. This allows us to distinguish between that and the unknown case.

---

{#loaded_file}

### loaded_file

```cpp
struct drgn_elf_file * loaded_file
```

Type: struct [`drgn_elf_file`](drgn_elf_file.md#drgn_elf_file) *

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.h:248

---

{#debug_file}

### debug_file

```cpp
struct drgn_elf_file * debug_file
```

Type: struct [`drgn_elf_file`](drgn_elf_file.md#drgn_elf_file) *

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.h:249

---

{#supplementary_debug_file}

### supplementary_debug_file

```cpp
struct drgn_elf_file * supplementary_debug_file
```

Type: struct [`drgn_elf_file`](drgn_elf_file.md#drgn_elf_file) *

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.h:250

---

{#gnu_debugdata_file}

### gnu_debugdata_file

```cpp
struct drgn_elf_file * gnu_debugdata_file
```

Type: struct [`drgn_elf_file`](drgn_elf_file.md#drgn_elf_file) *

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.h:251

---

{#split_dwarf_files}

### split_dwarf_files

```cpp
struct drgn_elf_file_dwarf_table split_dwarf_files
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.h:253

Table mapping libdw handle to corresponding [drgn_elf_file](drgn_elf_file.md#drgn_elf_file).

---

{#loaded_file_bias}

### loaded_file_bias

```cpp
uint64_t loaded_file_bias
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.h:254

---

{#debug_file_bias}

### debug_file_bias

```cpp
uint64_t debug_file_bias
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.h:255

---

{#loaded_file_status}

### loaded_file_status

```cpp
enum drgn_module_file_status loaded_file_status
```

Type: enum [`drgn_module_file_status`](drgn_module_file_status.md#drgn_module_file_status)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.h:256

---

{#debug_file_status}

### debug_file_status

```cpp
enum drgn_module_file_status debug_file_status
```

Type: enum [`drgn_module_file_status`](drgn_module_file_status.md#drgn_module_file_status)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.h:257

---

{#supplementary_debug_file_kind}

### supplementary_debug_file_kind

```cpp
enum drgn_supplementary_file_kind supplementary_debug_file_kind
```

Type: enum [`drgn_supplementary_file_kind`](drgn_supplementary_file_kind.md#drgn_supplementary_file_kind)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.h:258

---

{#dwarf-1}

### dwarf

```cpp
struct drgn_module_dwarf_info dwarf
```

Type: struct [`drgn_module_dwarf_info`](drgn_module_dwarf_info.md#drgn_module_dwarf_info)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.h:261

DWARF debugging information.

---

{#orc}

### orc

```cpp
struct drgn_module_orc_info orc
```

Type: struct [`drgn_module_orc_info`](drgn_module_orc_info.md#drgn_module_orc_info)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.h:263

ORC unwinder information.

---

{#elf_symtab}

### elf_symtab

```cpp
struct drgn_elf_symbol_table elf_symtab
```

Type: struct [`drgn_elf_symbol_table`](drgn_elf_symbol_table.md#drgn_elf_symbol_table)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.h:265

ELF symbol table.

---

{#gnu_debugdata_symtab}

### gnu_debugdata_symtab

```cpp
struct drgn_elf_symbol_table gnu_debugdata_symtab
```

Type: struct [`drgn_elf_symbol_table`](drgn_elf_symbol_table.md#drgn_elf_symbol_table)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.h:267

[Symbol](Symbol.md#symbol) table from the gnu_debugdata_file

---

{#parsed_debug_frame}

### parsed_debug_frame

```cpp
bool parsed_debug_frame
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.h:270

Whether .debug_frame has been parsed.

---

{#parsed_eh_frame}

### parsed_eh_frame

```cpp
bool parsed_eh_frame
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.h:272

Whether .eh_frame has been parsed.

---

{#parsed_orc}

### parsed_orc

```cpp
bool parsed_orc
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.h:274

Whether ORC unwinder data has been parsed.

---

{#elf_symtab_pending_files}

### elf_symtab_pending_files

```cpp
enum drgn_module_file_mask elf_symtab_pending_files
```

Type: enum [`drgn_module_file_mask`](drgn_module_file_mask.md#drgn_module_file_mask)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.h:276

Which files need to be checked for an ELF symbol table.

---

{#have_full_symtab}

### have_full_symtab

```cpp
bool have_full_symtab
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.h:281

Whether a full symbol table has been found (as opposed to a dynamic symbol table, which only contains a subset of symbols).

---

{#section_addresses}

### section_addresses

```cpp
struct drgn_module_section_address_map section_addresses
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.h:284

Mapping from section name to address.

---

{#section_addresses_generation}

### section_addresses_generation

```cpp
uint64_t section_addresses_generation
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.h:289

Counter used to detect when [section_addresses](#section_addresses) is modified during iteration of a [drgn_module_section_address_iterator](drgn_module_section_address_iterator.md#drgn_module_section_address_iterator).

---

{#load_debug_info_generation-1}

### load_debug_info_generation

```cpp
uint64_t load_debug_info_generation
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.h:297

Counter used to detect when loading debugging information is attempted.

**See also**: [drgn_debug_info::load_debug_info_generation](drgn_debug_info.md#load_debug_info_generation)

---

{#wanted_supplementary_debug_file}

### wanted_supplementary_debug_file

```cpp
struct drgn_module_wanted_supplementary_file * wanted_supplementary_debug_file
```

Type: struct [`drgn_module_wanted_supplementary_file`](drgn_module_wanted_supplementary_file.md#drgn_module_wanted_supplementary_file) *

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.h:298

---

{#pending_indexing_next}

### pending_indexing_next

```cpp
struct drgn_module * pending_indexing_next
```

Type: struct [`drgn_module`](#drgn_module) *

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.h:300

Node in [drgn_debug_info::modules_pending_indexing](drgn_debug_info.md#modules_pending_indexing).

---

{#object-2}

### object

```cpp
struct drgn_object object
```

Type: struct [`drgn_object`](drgn_object.md#drgn_object-1)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.h:302

Object the module was created from

