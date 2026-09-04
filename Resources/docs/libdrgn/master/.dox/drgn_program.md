{#drgn_program}

# drgn_program

```cpp
#include <program.h>
```

```cpp
struct drgn_program
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.h:62

[Program](Program.md#program) being debugged.

A [drgn_program](#drgn_program) represents a crashed or running program. It supports looking up objects ([drgn_program_find_object()](Programs.md#drgn_program_find_object)) and types ([drgn_program_find_type()](Programs.md#drgn_program_find_type)) by name and reading arbitrary memory from the program ([drgn_program_read_memory()](Programs.md#drgn_program_read_memory)).

A [drgn_program](#drgn_program) is created with [drgn_program_from_core_dump()](Programs.md#drgn_program_from_core_dump), [drgn_program_from_kernel()](Programs.md#drgn_program_from_kernel), or [drgn_program_from_pid()](Programs.md#drgn_program_from_pid). It must be freed with [drgn_program_destroy()](#group__Programs_1ga4b82c2b7e80fe3d4c38d5d9c73a93f71).

## Public Attributes

| Return | Name | Description |
|--------|------|-------------|
| `char *` | [`core_dump_fname_cached`](#core_dump_fname_cached)  | Cached `pr_fname` from `NT_PRPSINFO` note. |
| `uint64_t` | [`at_phdr`](#at_phdr)  |  |
| `uint64_t` | [`at_phnum`](#at_phnum)  |  |
| `uint64_t` | [`at_sysinfo_ehdr`](#at_sysinfo_ehdr)  |  |
| struct [`drgn_program`](#drgn_program) | [`auxv`](#auxv)  | Cache of important parts of auxiliary vector. |
| `bool` | [`auxv_cached`](#auxv_cached)  |  |
| `char` | [`osrelease`](#osrelease)  | `uname -r` |
| `char` | [`build_id`](#build_id)  | Build ID. |
| `uint64_t` | [`page_size`](#page_size)  | `PAGE_SIZE` of the kernel. |
| `uint64_t` | [`kaslr_offset`](#kaslr_offset)  | The offset from the compiled address of the kernel image to its actual address in memory. |
| `uint64_t` | [`kaslr_offset_phys`](#kaslr_offset_phys)  | The offset from physical memory address 0 of the kernel image on s390x. |
| `uint64_t` | [`swapper_pg_dir`](#swapper_pg_dir)  | Kernel page table. |
| `uint64_t` | [`mem_section_length`](#mem_section_length)  | Length of mem_section array (i.e., `NR_SECTION_ROOTS`). |
| `int` | [`section_size_bits`](#section_size_bits)  | `SECTION_SIZE_BITS` of the kernel. Initially 0 if not found in VMCOREINFO, but may be determined by other means and cached later. |
| `int` | [`max_physmem_bits`](#max_physmem_bits)  | `MAX_PHYSMEM_BITS` of the kernel. Initially 0 if not found in VMCOREINFO, but may be determined by other means and cached later. |
| `uint64_t` | [`va_bits`](#va_bits)  | `VA_BITS` on AArch64. |
| `uint64_t` | [`tcr_el1_t1sz`](#tcr_el1_t1sz)  | `TCR_EL1_T1SZ` on AArch64. |
| `uint64_t` | [`kimage_voffset`](#kimage_voffset)  | `kimage_voffset` on AArch64 |
| `uint64_t` | [`phys_base`](#phys_base)  | `phys_base` on x86_64 |
| `bool` | [`pgtable_l5_enabled`](#pgtable_l5_enabled)  | Whether 5-level paging was enabled on x86-64. |
| `bool` | [`arm_lpae`](#arm_lpae)  | Whether LPAE was enabled on Arm. |
| `bool` | [`have_crashtime`](#have_crashtime)  | Whether `CRASHTIME` was in the VMCOREINFO. |
| `bool` | [`have_phys_base`](#have_phys_base)  | Whether `phys_base` was in the VMCOREINFO. |
| `bool` | [`have_kaslr_offset_phys`](#have_kaslr_offset_phys)  | Whether `kaslr_offset_phys` was in the VMCOREINFO. |
| [`unsigned`](api.md#unsigned) int | [`build_id_len`](#build_id_len)  | Length of build ID. |
| `int` | [`page_shift`](#page_shift)  | `PAGE_SHIFT` of the kernel (derived from `PAGE_SIZE`). |
| `char *` | [`raw`](#raw)  | The original vmcoreinfo data, to expose as an object |
| `size_t` | [`raw_size`](#raw_size)  |  |
| struct [`drgn_program`](#drgn_program) | [`vmcoreinfo`](#vmcoreinfo)  |  |
| `uint64_t` | [`thread_size_cached`](#thread_size_cached)  | Value of `THREAD_SIZE` in the kernel, or 0 if not cached yet. |
| `uint64_t` | [`cached_sections_per_root`](#cached_sections_per_root)  | Value of `SECTIONS_PER_ROOT` in the kernel, or 0 if not cached yet. |
| `uint64_t` | [`arch_pfn_offset`](#arch_pfn_offset)  | Value of `ARCH_PFN_OFFSET` in the kernel. |
| `uint64_t` | [`direct_mapping_offset`](#direct_mapping_offset)  |  |
| `uint64_t` | [`mod_text`](#mod_text)  | Cached value of `MOD_TEXT` in the kernel. |
| `uint64_t *` | [`irq_regs_cached`](#irq_regs_cached)  | Cached array of per-cpu __irq_regs values |
| `bool` | [`arch_pfn_offset_cached`](#arch_pfn_offset_cached)  | Whether [drgn_program::arch_pfn_offset](#arch_pfn_offset) has been cached. |
| `bool` | [`direct_mapping_offset_cached`](#direct_mapping_offset_cached)  |  |
| `bool` | [`mod_text_cached`](#mod_text_cached)  | Whether [drgn_program::mod_text](#mod_text) has been cached. |

---

{#core_dump_fname_cached}

### core_dump_fname_cached

```cpp
char * core_dump_fname_cached
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.h:166

Cached `pr_fname` from `NT_PRPSINFO` note.

---

{#at_phdr}

### at_phdr

```cpp
uint64_t at_phdr
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.h:169

---

{#at_phnum}

### at_phnum

```cpp
uint64_t at_phnum
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.h:170

---

{#at_sysinfo_ehdr}

### at_sysinfo_ehdr

```cpp
uint64_t at_sysinfo_ehdr
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.h:171

---

{#auxv}

### auxv

```cpp
struct drgn_program auxv
```

Type: struct [`drgn_program`](#drgn_program)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.h:172

Cache of important parts of auxiliary vector.

---

{#auxv_cached}

### auxv_cached

```cpp
bool auxv_cached
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.h:173

---

{#osrelease}

### osrelease

```cpp
char osrelease[128]
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.h:186

`uname -r`

---

{#build_id}

### build_id

```cpp
char build_id[128]
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.h:188

Build ID.

---

{#page_size}

### page_size

```cpp
uint64_t page_size
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.h:190

`PAGE_SIZE` of the kernel.

---

{#kaslr_offset}

### kaslr_offset

```cpp
uint64_t kaslr_offset
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.h:198

The offset from the compiled address of the kernel image to its actual address in memory.

This is non-zero if kernel address space layout randomization (KASLR) is enabled.

---

{#kaslr_offset_phys}

### kaslr_offset_phys

```cpp
uint64_t kaslr_offset_phys
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.h:203

The offset from physical memory address 0 of the kernel image on s390x.

---

{#swapper_pg_dir}

### swapper_pg_dir

```cpp
uint64_t swapper_pg_dir
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.h:205

Kernel page table.

---

{#mem_section_length}

### mem_section_length

```cpp
uint64_t mem_section_length
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.h:210

Length of mem_section array (i.e., `NR_SECTION_ROOTS`).

---

{#section_size_bits}

### section_size_bits

```cpp
int section_size_bits
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.h:216

`SECTION_SIZE_BITS` of the kernel. Initially 0 if not found in VMCOREINFO, but may be determined by other means and cached later.

---

{#max_physmem_bits}

### max_physmem_bits

```cpp
int max_physmem_bits
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.h:222

`MAX_PHYSMEM_BITS` of the kernel. Initially 0 if not found in VMCOREINFO, but may be determined by other means and cached later.

---

{#va_bits}

### va_bits

```cpp
uint64_t va_bits
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.h:224

`VA_BITS` on AArch64.

---

{#tcr_el1_t1sz}

### tcr_el1_t1sz

```cpp
uint64_t tcr_el1_t1sz
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.h:226

`TCR_EL1_T1SZ` on AArch64.

---

{#kimage_voffset}

### kimage_voffset

```cpp
uint64_t kimage_voffset
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.h:228

`kimage_voffset` on AArch64

---

{#phys_base}

### phys_base

```cpp
uint64_t phys_base
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.h:230

`phys_base` on x86_64

---

{#pgtable_l5_enabled}

### pgtable_l5_enabled

```cpp
bool pgtable_l5_enabled
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.h:234

Whether 5-level paging was enabled on x86-64.

---

{#arm_lpae}

### arm_lpae

```cpp
bool arm_lpae
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.h:236

Whether LPAE was enabled on Arm.

---

{#have_crashtime}

### have_crashtime

```cpp
bool have_crashtime
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.h:238

Whether `CRASHTIME` was in the VMCOREINFO.

---

{#have_phys_base}

### have_phys_base

```cpp
bool have_phys_base
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.h:240

Whether `phys_base` was in the VMCOREINFO.

---

{#have_kaslr_offset_phys}

### have_kaslr_offset_phys

```cpp
bool have_kaslr_offset_phys
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.h:242

Whether `kaslr_offset_phys` was in the VMCOREINFO.

---

{#build_id_len}

### build_id_len

```cpp
unsigned int build_id_len
```

Type: [`unsigned`](api.md#unsigned) int

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.h:244

Length of build ID.

---

{#page_shift}

### page_shift

```cpp
int page_shift
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.h:249

`PAGE_SHIFT` of the kernel (derived from `PAGE_SIZE`).

---

{#raw}

### raw

```cpp
char * raw
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.h:252

The original vmcoreinfo data, to expose as an object

---

{#raw_size}

### raw_size

```cpp
size_t raw_size
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.h:253

---

{#vmcoreinfo}

### vmcoreinfo

```cpp
struct drgn_program vmcoreinfo
```

Type: struct [`drgn_program`](#drgn_program)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.h:254

---

{#thread_size_cached}

### thread_size_cached

```cpp
uint64_t thread_size_cached
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.h:259

Value of `THREAD_SIZE` in the kernel, or 0 if not cached yet.

---

{#cached_sections_per_root}

### cached_sections_per_root

```cpp
uint64_t cached_sections_per_root
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.h:264

Value of `SECTIONS_PER_ROOT` in the kernel, or 0 if not cached yet.

---

{#arch_pfn_offset}

### arch_pfn_offset

```cpp
uint64_t arch_pfn_offset
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.h:266

Value of `ARCH_PFN_OFFSET` in the kernel.

---

{#direct_mapping_offset}

### direct_mapping_offset

```cpp
uint64_t direct_mapping_offset
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.h:271

---

{#mod_text}

### mod_text

```cpp
uint64_t mod_text
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.h:273

Cached value of `MOD_TEXT` in the kernel.

---

{#irq_regs_cached}

### irq_regs_cached

```cpp
uint64_t * irq_regs_cached
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.h:275

Cached array of per-cpu __irq_regs values

---

{#arch_pfn_offset_cached}

### arch_pfn_offset_cached

```cpp
bool arch_pfn_offset_cached
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.h:280

Whether [drgn_program::arch_pfn_offset](#arch_pfn_offset) has been cached.

---

{#direct_mapping_offset_cached}

### direct_mapping_offset_cached

```cpp
bool direct_mapping_offset_cached
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.h:285

---

{#mod_text_cached}

### mod_text_cached

```cpp
bool mod_text_cached
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.h:289

Whether [drgn_program::mod_text](#mod_text) has been cached.

## Private Attributes

| Return | Name | Description |
|--------|------|-------------|
| struct [`drgn_memory_reader`](drgn_memory_reader.md#drgn_memory_reader) | [`reader`](#reader)  |  |
| struct [`drgn_memory_file_segment`](drgn_memory_file_segment.md#drgn_memory_file_segment) * | [`file_segments`](#file_segments)  |  |
| `Elf *` | [`core`](#core)  |  |
| `int` | [`core_fd`](#core_fd)  |  |
| `char *` | [`core_path`](#core_path)  |  |
| `pid_t` | [`pid`](#pid)  |  |
| struct [`drgn_qmp_conn`](drgn_qmp_conn.md#drgn_qmp_conn) | [`qmp_conn`](#qmp_conn)  |  |
| struct [`drgn_handler_list`](drgn_handler_list.md#drgn_handler_list) | [`type_finders`](#type_finders)  | Callbacks for finding types. |
| struct [`drgn_type`](drgn_type.md#drgn_type) | [`void_types`](#void_types)  | Void type for each language. |
| struct [`drgn_type`](drgn_type.md#drgn_type) * | [`primitive_types`](#primitive_types)  | Cache of primitive types. |
| `struct drgn_dedupe_type_set` | [`dedupe_types`](#dedupe_types)  | Cache of deduplicated types. |
| `struct drgn_typep_vector` | [`created_types`](#created_types)  | List of created types that are not deduplicated: types with non-empty lists of members, parameters, template parameters, or enumerators. |
| `struct drgn_member_map` | [`members`](#members)  | Cache for drgn_program_find_member(). |
| `struct drgn_type_set` | [`members_cached`](#members_cached)  | Set of types which have been already cached in drgn_program::members. |
| struct [`drgn_handler_list`](drgn_handler_list.md#drgn_handler_list) | [`object_finders`](#object_finders)  |  |
| struct [`drgn_debug_info`](drgn_debug_info.md#drgn_debug_info) | [`dbinfo`](#dbinfo)  |  |
| struct [`drgn_handler_list`](drgn_handler_list.md#drgn_handler_list) | [`symbol_finders`](#symbol_finders)  |  |
| const struct [`drgn_language`](drgn_language.md#drgn_language) * | [`lang`](#lang)  |  |
| struct [`drgn_platform`](drgn_platform.md#drgn_platform) | [`platform`](#platform)  |  |
| `bool` | [`tried_main_language`](#tried_main_language)  | Whether we have tried determining the default language from "main" since the last time that debug info was added. |
| `bool` | [`has_platform`](#has_platform)  |  |
| enum [`drgn_program_flags`](drgn_program_flags.md#drgn_program_flags) | [`flags`](#flags-1)  |  |
| `struct drgn_thread_set` | [`thread_set`](#thread_set)  |  |
| struct [`drgn_thread`](drgn_thread.md#drgn_thread) * | [`main_thread`](#main_thread)  |  |
| struct [`drgn_thread`](drgn_thread.md#drgn_thread) * | [`crashed_thread`](#crashed_thread)  |  |
| `uint64_t` | [`aarch64_stackframe_offset_cached`](#aarch64_stackframe_offset_cached)  |  |
| `uint64_t` | [`aarch64_insn_pac_mask`](#aarch64_insn_pac_mask)  |  |
| `bool` | [`core_dump_threads_cached`](#core_dump_threads_cached)  |  |
| union [`drgn_program`](#drgn_program) | [``](#unknown-6)  |  |
| struct [`drgn_object`](drgn_object.md#drgn_object-1) | [`vmemmap`](#vmemmap)  |  |
| struct [`pgtable_iterator`](pgtable_iterator.md#pgtable_iterator) | [`pgtable_its`](#pgtable_its)  |  |
| `size_t` | [`address_translation_depth`](#address_translation_depth)  |  |
| [`drgn_log_fn`](Logging.md#drgn_log_fn) * | [`log_fn`](#log_fn)  |  |
| `void *` | [`log_arg`](#log_arg)  |  |
| `FILE *` | [`progress_file`](#progress_file)  |  |
| enum [`drgn_log_level`](drgn_log_level.md#drgn_log_level) | [`log_level`](#log_level)  |  |
| `bool` | [`default_progress_file`](#default_progress_file)  |  |

---

{#reader}

### reader

```cpp
struct drgn_memory_reader reader
```

Type: struct [`drgn_memory_reader`](drgn_memory_reader.md#drgn_memory_reader)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.h:68

---

{#file_segments}

### file_segments

```cpp
struct drgn_memory_file_segment * file_segments
```

Type: struct [`drgn_memory_file_segment`](drgn_memory_file_segment.md#drgn_memory_file_segment) *

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.h:70

---

{#core}

### core

```cpp
Elf * core
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.h:72

---

{#core_fd}

### core_fd

```cpp
int core_fd
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.h:74

---

{#core_path}

### core_path

```cpp
char * core_path
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.h:76

---

{#pid}

### pid

```cpp
pid_t pid
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.h:78

---

{#qmp_conn}

### qmp_conn

```cpp
struct drgn_qmp_conn qmp_conn
```

Type: struct [`drgn_qmp_conn`](drgn_qmp_conn.md#drgn_qmp_conn)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.h:82

---

{#type_finders}

### type_finders

```cpp
struct drgn_handler_list type_finders
```

Type: struct [`drgn_handler_list`](drgn_handler_list.md#drgn_handler_list)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.h:88

Callbacks for finding types.

---

{#void_types}

### void_types

```cpp
struct drgn_type void_types[DRGN_NUM_LANGUAGES]
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.h:90

Void type for each language.

---

{#primitive_types}

### primitive_types

```cpp
struct drgn_type * primitive_types[DRGN_PRIMITIVE_TYPE_NUM]
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.h:92

Cache of primitive types.

---

{#dedupe_types}

### dedupe_types

```cpp
struct drgn_dedupe_type_set dedupe_types
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.h:94

Cache of deduplicated types.

---

{#created_types}

### created_types

```cpp
struct drgn_typep_vector created_types
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.h:105

List of created types that are not deduplicated: types with non-empty lists of members, parameters, template parameters, or enumerators.

Members, parameters, and template parameters contain lazily-evaluated objects, so they cannot be easily deduplicated.

Enumerators could be deduplicated, but it's probably not worth the effort to hash and compare them.

---

{#members}

### members

```cpp
struct drgn_member_map members
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.h:107

Cache for drgn_program_find_member().

---

{#members_cached}

### members_cached

```cpp
struct drgn_type_set members_cached
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.h:112

Set of types which have been already cached in drgn_program::members.

---

{#object_finders}

### object_finders

```cpp
struct drgn_handler_list object_finders
```

Type: struct [`drgn_handler_list`](drgn_handler_list.md#drgn_handler_list)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.h:117

---

{#dbinfo}

### dbinfo

```cpp
struct drgn_debug_info dbinfo
```

Type: struct [`drgn_debug_info`](drgn_debug_info.md#drgn_debug_info)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.h:118

---

{#symbol_finders}

### symbol_finders

```cpp
struct drgn_handler_list symbol_finders
```

Type: struct [`drgn_handler_list`](drgn_handler_list.md#drgn_handler_list)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.h:119

---

{#lang}

### lang

```cpp
const struct drgn_language * lang
```

Type: const struct [`drgn_language`](drgn_language.md#drgn_language) *

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.h:125

---

{#platform}

### platform

```cpp
struct drgn_platform platform
```

Type: struct [`drgn_platform`](drgn_platform.md#drgn_platform)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.h:126

---

{#tried_main_language}

### tried_main_language

```cpp
bool tried_main_language
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.h:131

Whether we have tried determining the default language from "main" since the last time that debug info was added.

---

{#has_platform}

### has_platform

```cpp
bool has_platform
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.h:132

---

{#flags-1}

### flags

```cpp
enum drgn_program_flags flags
```

Type: enum [`drgn_program_flags`](drgn_program_flags.md#drgn_program_flags)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.h:133

---

{#thread_set}

### thread_set

```cpp
struct drgn_thread_set thread_set
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.h:144

---

{#main_thread}

### main_thread

```cpp
struct drgn_thread * main_thread
```

Type: struct [`drgn_thread`](drgn_thread.md#drgn_thread) *

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.h:145

---

{#crashed_thread}

### crashed_thread

```cpp
struct drgn_thread * crashed_thread
```

Type: struct [`drgn_thread`](drgn_thread.md#drgn_thread) *

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.h:146

---

{#aarch64_stackframe_offset_cached}

### aarch64_stackframe_offset_cached

```cpp
uint64_t aarch64_stackframe_offset_cached
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.h:151

---

{#aarch64_insn_pac_mask}

### aarch64_insn_pac_mask

```cpp
uint64_t aarch64_insn_pac_mask
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.h:157

---

{#core_dump_threads_cached}

### core_dump_threads_cached

```cpp
bool core_dump_threads_cached
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.h:158

---

{#unknown-6}

### 

```cpp
union drgn_program
```

Type: union [`drgn_program`](#drgn_program)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.h:291

---

{#vmemmap}

### vmemmap

```cpp
struct drgn_object vmemmap
```

Type: struct [`drgn_object`](drgn_object.md#drgn_object-1)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.h:297

---

{#pgtable_its}

### pgtable_its

```cpp
struct pgtable_iterator pgtable_its[2]
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.h:299

---

{#address_translation_depth}

### address_translation_depth

```cpp
size_t address_translation_depth
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.h:304

---

{#log_fn}

### log_fn

```cpp
drgn_log_fn * log_fn
```

Type: [`drgn_log_fn`](Logging.md#drgn_log_fn) *

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.h:309

---

{#log_arg}

### log_arg

```cpp
void * log_arg
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.h:310

---

{#progress_file}

### progress_file

```cpp
FILE * progress_file
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.h:311

---

{#log_level}

### log_level

```cpp
enum drgn_log_level log_level
```

Type: enum [`drgn_log_level`](drgn_log_level.md#drgn_log_level)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.h:312

---

{#default_progress_file}

### default_progress_file

```cpp
bool default_progress_file
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.h:313

