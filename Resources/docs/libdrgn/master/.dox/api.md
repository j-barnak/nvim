# API Reference

## Groups

| Name | Description |
|------|-------------|
| [`Types`](Types.md#types) | Type descriptors. |
| [`Modules`](Modules.md#modules) | Modules in a program and debugging information. |
| [`Logging`](Logging.md#logging) | Logging configuration. |
| [`Objects`](Objects.md#objects) | Objects in a program. |
| [`Symbols`](Symbols.md#symbols) | [Symbol](Symbol.md#symbol) table entries. |
| [`Threads`](Threads.md#threads) | Threads in a program. |
| [`Programs`](Programs.md#programs) | Debugging programs. |
| [`Languages`](Languages.md#languages) | Programming languages. |
| [`Platforms`](Platforms.md#platforms) | [Program](Program.md#program) platforms (i.e., architecture and ABI). |
| [`Internals`](Internals.md#internals) | Internal implementation |
| [`Stack traces`](StackTraces.md#stacktraces-1) | Call stacks and stack frames. |
| [`Error handling`](ErrorHandling.md#errorhandling) | Error handling in libdrgn. |
| [`Source locations`](SourceLocations.md#sourcelocations) | Source code locations. |

## Classes

| Name | Description |
|------|-------------|
| [`Module`](Module.md#module-3) |  |
| [`Symbol`](Symbol.md#symbol) |  |
| [`Thread`](Thread.md#thread) |  |
| [`nstring`](nstring.md#nstring) | A string with a stored length. |
| [`Program`](Program.md#program) |  |
| [`DrgnType`](DrgnType.md#drgntype) |  |
| [`Language`](Language.md#language) |  |
| [`Platform`](Platform.md#platform-2) |  |
| [`Register`](Register.md#register) |  |
| [`enum_arg`](enum_arg.md#enum_arg) |  |
| [`path_arg`](path_arg.md#path_arg) |  |
| [`pt_level`](pt_level.md#pt_level) |  |
| [`dat_level`](dat_level.md#dat_level) |  |
| [`DrgnObject`](DrgnObject.md#drgnobject) |  |
| [`index_arg`](index_arg.md#index_arg) |  |
| [`LazyObject`](LazyObject.md#lazyobject) |  |
| [`StackFrame`](StackFrame.md#stackframe) |  |
| [`StackTrace`](StackTrace.md#stacktrace) |  |
| [`TypeMember`](TypeMember.md#typemember) |  |
| [`SymbolIndex`](SymbolIndex.md#symbolindex) |  |
| [`TypeKindSet`](TypeKindSet.md#typekindset) |  |
| [`c_declarator`](c_declarator.md#c_declarator) |  |
| [`drgn_handler`](drgn_handler.md#drgn_handler) |  |
| [`pgtable_data`](pgtable_data.md#pgtable_data) |  |
| [`TypeParameter`](TypeParameter.md#typeparameter) |  |
| [`uint64_range`](uint64_range.md#uint64_range) |  |
| [`byteorder_arg`](byteorder_arg.md#byteorder_arg) |  |
| [`cityhash_pair`](cityhash_pair.md#cityhash_pair) |  |
| [`DrgnType_Attr`](DrgnType_Attr.md#drgntype_attr) |  |
| [`ModuleIterator`](ModuleIterator.md#moduleiterator) |  |
| [`ObjectIterator`](ObjectIterator.md#objectiterator) |  |
| [`ThreadIterator`](ThreadIterator.md#threaditerator) |  |
| [`TypeEnumerator`](TypeEnumerator.md#typeenumerator) |  |
| [`drgn_link_map`](drgn_link_map.md#drgn_link_map) |  |
| [`drgn_qmp_conn`](drgn_qmp_conn.md#drgn_qmp_conn) |  |
| [`array_dimension`](array_dimension.md#array_dimension) |  |
| [`DebugInfoOptions`](DebugInfoOptions.md#debuginfooptions) |  |
| [`drgn_dwarf_cfi`](drgn_dwarf_cfi.md#drgn_dwarf_cfi) | DWARF Call Frame Information. |
| [`drgn_dwarf_cie`](drgn_dwarf_cie.md#drgn_dwarf_cie) |  |
| [`drgn_dwarf_fde`](drgn_dwarf_fde.md#drgn_dwarf_fde) | DWARF Frame Description Entry. |
| [`drgn_enum_type`](drgn_enum_type.md#drgn_enum_type) |  |
| [`drgn_orc_entry`](drgn_orc_entry.md#drgn_orc_entry) |  |
| [`kallsyms_reader`](kallsyms_reader.md#kallsyms_reader) | This struct contains the tables necessary to reconstruct kallsyms names. |
| [`drgn_dwarf_info`](drgn_dwarf_info.md#drgn_dwarf_info) | DWARF debugging information for a program/[drgn_debug_info](drgn_debug_info.md#drgn_debug_info). |
| [`drgn_dwarf_type`](drgn_dwarf_type.md#drgn_dwarf_type) | Cached type in a [drgn_debug_info](drgn_debug_info.md#drgn_debug_info). |
| [`drgn_link_map32`](drgn_link_map32.md#drgn_link_map32) |  |
| [`initializer_iter`](initializer_iter.md#initializer_iter) |  |
| [`drgn_mapped_file`](drgn_mapped_file.md#drgn_mapped_file) |  |
| [`SourceLocationList`](SourceLocationList.md#sourcelocationlist) |  |
| [`drgn_handler_list`](drgn_handler_list.md#drgn_handler_list) |  |
| [`drgn_symbol_index`](drgn_symbol_index.md#drgn_symbol_index) | An index of symbols, supporting efficient lookup by name or address |
| [`kallsyms_locations`](kallsyms_locations.md#kallsyms_locations) |  |
| [`path_sequence_arg`](path_sequence_arg.md#path_sequence_arg) |  |
| [`TypeKindSetIterator`](TypeKindSetIterator.md#typekindsetiterator) |  |
| [`drgn_compound_type`](drgn_compound_type.md#drgn_compound_type) |  |
| [`drgn_extended_type`](drgn_extended_type.md#drgn_extended_type) |  |
| [`drgn_symbol_finder`](drgn_symbol_finder.md#drgn_symbol_finder) |  |
| [`MemorySearchIterator`](MemorySearchIterator.md#memorysearchiterator) |  |
| [`depmod_index_buffer`](depmod_index_buffer.md#depmod_index_buffer) |  |
| [`drgn_memory_segment`](drgn_memory_segment.md#drgn_memory_segment) | Memory segment in a [drgn_memory_reader](drgn_memory_reader.md#drgn_memory_reader). |
| [`drgn_templated_type`](drgn_templated_type.md#drgn_templated_type) |  |
| [`TypeTemplateParameter`](TypeTemplateParameter.md#typetemplateparameter) |  |
| [`drgn_c_family_lexer`](drgn_c_family_lexer.md#drgn_c_family_lexer) |  |
| [`drgn_dwarf_index_cu`](drgn_dwarf_index_cu.md#drgn_dwarf_index_cu) | DWARF compilation unit indexed in a [drgn_namespace_dwarf_index](drgn_namespace_dwarf_index.md#drgn_namespace_dwarf_index). |
| [`ModuleSectionAddresses`](ModuleSectionAddresses.md#modulesectionaddresses) |  |
| [`pgtable_iterator_arm`](pgtable_iterator_arm.md#pgtable_iterator_arm) |  |
| [`load_debug_info_file`](load_debug_info_file.md#load_debug_info_file) |  |
| [`array_initializer_iter`](array_initializer_iter.md#array_initializer_iter) |  |
| [`load_debug_info_state`](load_debug_info_state.md#load_debug_info_state) |  |
| [`pgtable_iterator_ppc64`](pgtable_iterator_ppc64.md#pgtable_iterator_ppc64) |  |
| [`pgtable_iterator_s390x`](pgtable_iterator_s390x.md#pgtable_iterator_s390x) |  |
| [`drgn_map_files_segment`](drgn_map_files_segment.md#drgn_map_files_segment) |  |
| [`drgn_module_dwarf_info`](drgn_module_dwarf_info.md#drgn_module_dwarf_info) | DWARF debugging information for a [drgn_module](drgn_module.md#drgn_module). |
| [`format_object_flag_arg`](format_object_flag_arg.md#format_object_flag_arg) |  |
| [`drgn_debug_info_options`](drgn_debug_info_options.md#drgn_debug_info_options) |  |
| [`drgn_dwarf_die_iterator`](drgn_dwarf_die_iterator.md#drgn_dwarf_die_iterator) | Iterator over DWARF DIEs in a [drgn_module](drgn_module.md#drgn_module). |
| [`drgn_map_files_segments`](drgn_map_files_segments.md#drgn_map_files_segments) |  |
| [`elf_symtab_search_state`](elf_symtab_search_state.md#elf_symtab_search_state) |  |
| [`pgtable_iterator_aarch64`](pgtable_iterator_aarch64.md#pgtable_iterator_aarch64) |  |
| [`pgtable_iterator_x86_64`](pgtable_iterator_x86_64.md#pgtable_iterator_x86_64) |  |
| [`process_mapped_file_key`](process_mapped_file_key.md#process_mapped_file_key) |  |
| [`compound_initializer_iter`](compound_initializer_iter.md#compound_initializer_iter) |  |
| [`drgn_mapped_file_segment`](drgn_mapped_file_segment.md#drgn_mapped_file_segment) |  |
| [`load_debug_info_provided`](load_debug_info_provided.md#load_debug_info_provided) |  |
| [`compound_initializer_state`](compound_initializer_state.md#compound_initializer_state) |  |
| [`drgn_dwarf_die_thunk_arg`](drgn_dwarf_die_thunk_arg.md#drgn_dwarf_die_thunk_arg) |  |
| [`drgn_dwarf_index_iterator`](drgn_dwarf_index_iterator.md#drgn_dwarf_index_iterator) | Iterator over DWARF debugging information. |
| [`drgn_mapped_file_segments`](drgn_mapped_file_segments.md#drgn_mapped_file_segments) |  |
| [`drgn_symbol_index_builder`](drgn_symbol_index_builder.md#drgn_symbol_index_builder) |  |
| [`process_mapped_file_entry`](process_mapped_file_entry.md#process_mapped_file_entry) |  |
| [`drgn_namespace_dwarf_index`](drgn_namespace_dwarf_index.md#drgn_namespace_dwarf_index) | DWARF information for a namespace or nested definitions in a class, struct, or union. |
| [`drgn_symbol_result_builder`](drgn_symbol_result_builder.md#drgn_symbol_result_builder) |  |
| [`linux_helper_task_iterator`](linux_helper_task_iterator.md#linux_helper_task_iterator) |  |
| [`core_loaded_module_iterator`](core_loaded_module_iterator.md#core_loaded_module_iterator) |  |
| [`drgn_dwarf_index_cu_buffer`](drgn_dwarf_index_cu_buffer.md#drgn_dwarf_index_cu_buffer) |  |
| [`drgn_dwarf_index_cu_lookup`](drgn_dwarf_index_cu_lookup.md#drgn_dwarf_index_cu_lookup) | Indexed CU lookup table entry. |
| [`drgn_kmod_walk_stack_entry`](drgn_kmod_walk_stack_entry.md#drgn_kmod_walk_stack_entry) |  |
| [`ModuleSectionAddressesIterator`](ModuleSectionAddressesIterator.md#modulesectionaddressesiterator) |  |
| [`drgn_created_module_iterator`](drgn_created_module_iterator.md#drgn_created_module_iterator) |  |
| [`drgn_dwarf_member_thunk_arg`](drgn_dwarf_member_thunk_arg.md#drgn_dwarf_member_thunk_arg) |  |
| [`drgn_dwarf_expression_context`](drgn_dwarf_expression_context.md#drgn_dwarf_expression_context) |  |
| [`drgn_qemu_process_mem_segment`](drgn_qemu_process_mem_segment.md#drgn_qemu_process_mem_segment) |  |
| [`process_loaded_module_iterator`](process_loaded_module_iterator.md#process_loaded_module_iterator) |  |
| [`userspace_loaded_module_iterator`](userspace_loaded_module_iterator.md#userspace_loaded_module_iterator) |  |
| [`linux_kernel_loaded_module_iterator`](linux_kernel_loaded_module_iterator.md#linux_kernel_loaded_module_iterator) |  |
| [`drgn_module_section_address_iterator`](drgn_module_section_address_iterator.md#drgn_module_section_address_iterator) |  |
| [`drgn_module_wanted_supplementary_file`](drgn_module_wanted_supplementary_file.md#drgn_module_wanted_supplementary_file) |  |

## Macros

---

{#format}

### FORMAT

```cpp
#define FORMAT "/proc/self/fd/%d"
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/io.c:74

---

{#nt_file}

### NT_FILE

```cpp
#define NT_FILE 0x46494c45
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/include/elf.h:14

---

{#em_riscv}

### EM_RISCV

```cpp
#define EM_RISCV 243
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/include/elf.h:17

---

{#r_riscv_none}

### R_RISCV_NONE

```cpp
#define R_RISCV_NONE 0
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/include/elf.h:20

---

{#r_riscv_32}

### R_RISCV_32

```cpp
#define R_RISCV_32 1
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/include/elf.h:23

---

{#r_riscv_64}

### R_RISCV_64

```cpp
#define R_RISCV_64 2
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/include/elf.h:26

---

{#r_riscv_relative}

### R_RISCV_RELATIVE

```cpp
#define R_RISCV_RELATIVE 3
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/include/elf.h:29

---

{#r_riscv_copy}

### R_RISCV_COPY

```cpp
#define R_RISCV_COPY 4
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/include/elf.h:32

---

{#r_riscv_jump_slot}

### R_RISCV_JUMP_SLOT

```cpp
#define R_RISCV_JUMP_SLOT 5
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/include/elf.h:35

---

{#r_riscv_tls_dtpmod32}

### R_RISCV_TLS_DTPMOD32

```cpp
#define R_RISCV_TLS_DTPMOD32 6
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/include/elf.h:38

---

{#r_riscv_tls_dtpmod64}

### R_RISCV_TLS_DTPMOD64

```cpp
#define R_RISCV_TLS_DTPMOD64 7
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/include/elf.h:41

---

{#r_riscv_tls_dtprel32}

### R_RISCV_TLS_DTPREL32

```cpp
#define R_RISCV_TLS_DTPREL32 8
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/include/elf.h:44

---

{#r_riscv_tls_dtprel64}

### R_RISCV_TLS_DTPREL64

```cpp
#define R_RISCV_TLS_DTPREL64 9
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/include/elf.h:47

---

{#r_riscv_tls_tprel32}

### R_RISCV_TLS_TPREL32

```cpp
#define R_RISCV_TLS_TPREL32 10
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/include/elf.h:50

---

{#r_riscv_tls_tprel64}

### R_RISCV_TLS_TPREL64

```cpp
#define R_RISCV_TLS_TPREL64 11
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/include/elf.h:53

---

{#r_riscv_branch}

### R_RISCV_BRANCH

```cpp
#define R_RISCV_BRANCH 16
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/include/elf.h:56

---

{#r_riscv_jal}

### R_RISCV_JAL

```cpp
#define R_RISCV_JAL 17
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/include/elf.h:59

---

{#r_riscv_call}

### R_RISCV_CALL

```cpp
#define R_RISCV_CALL 18
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/include/elf.h:62

---

{#r_riscv_call_plt}

### R_RISCV_CALL_PLT

```cpp
#define R_RISCV_CALL_PLT 19
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/include/elf.h:65

---

{#r_riscv_got_hi20}

### R_RISCV_GOT_HI20

```cpp
#define R_RISCV_GOT_HI20 20
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/include/elf.h:68

---

{#r_riscv_tls_got_hi20}

### R_RISCV_TLS_GOT_HI20

```cpp
#define R_RISCV_TLS_GOT_HI20 21
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/include/elf.h:71

---

{#r_riscv_tls_gd_hi20}

### R_RISCV_TLS_GD_HI20

```cpp
#define R_RISCV_TLS_GD_HI20 22
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/include/elf.h:74

---

{#r_riscv_pcrel_hi20}

### R_RISCV_PCREL_HI20

```cpp
#define R_RISCV_PCREL_HI20 23
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/include/elf.h:77

---

{#r_riscv_pcrel_lo12_i}

### R_RISCV_PCREL_LO12_I

```cpp
#define R_RISCV_PCREL_LO12_I 24
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/include/elf.h:80

---

{#r_riscv_pcrel_lo12_s}

### R_RISCV_PCREL_LO12_S

```cpp
#define R_RISCV_PCREL_LO12_S 25
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/include/elf.h:83

---

{#r_riscv_hi20}

### R_RISCV_HI20

```cpp
#define R_RISCV_HI20 26
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/include/elf.h:86

---

{#r_riscv_lo12_i}

### R_RISCV_LO12_I

```cpp
#define R_RISCV_LO12_I 27
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/include/elf.h:89

---

{#r_riscv_lo12_s}

### R_RISCV_LO12_S

```cpp
#define R_RISCV_LO12_S 28
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/include/elf.h:92

---

{#r_riscv_tprel_hi20}

### R_RISCV_TPREL_HI20

```cpp
#define R_RISCV_TPREL_HI20 29
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/include/elf.h:95

---

{#r_riscv_tprel_lo12_i}

### R_RISCV_TPREL_LO12_I

```cpp
#define R_RISCV_TPREL_LO12_I 30
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/include/elf.h:98

---

{#r_riscv_tprel_lo12_s}

### R_RISCV_TPREL_LO12_S

```cpp
#define R_RISCV_TPREL_LO12_S 31
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/include/elf.h:101

---

{#r_riscv_tprel_add}

### R_RISCV_TPREL_ADD

```cpp
#define R_RISCV_TPREL_ADD 32
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/include/elf.h:104

---

{#r_riscv_add8}

### R_RISCV_ADD8

```cpp
#define R_RISCV_ADD8 33
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/include/elf.h:107

---

{#r_riscv_add16}

### R_RISCV_ADD16

```cpp
#define R_RISCV_ADD16 34
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/include/elf.h:110

---

{#r_riscv_add32}

### R_RISCV_ADD32

```cpp
#define R_RISCV_ADD32 35
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/include/elf.h:113

---

{#r_riscv_add64}

### R_RISCV_ADD64

```cpp
#define R_RISCV_ADD64 36
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/include/elf.h:116

---

{#r_riscv_sub8}

### R_RISCV_SUB8

```cpp
#define R_RISCV_SUB8 37
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/include/elf.h:119

---

{#r_riscv_sub16}

### R_RISCV_SUB16

```cpp
#define R_RISCV_SUB16 38
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/include/elf.h:122

---

{#r_riscv_sub32}

### R_RISCV_SUB32

```cpp
#define R_RISCV_SUB32 39
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/include/elf.h:125

---

{#r_riscv_sub64}

### R_RISCV_SUB64

```cpp
#define R_RISCV_SUB64 40
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/include/elf.h:128

---

{#r_riscv_align}

### R_RISCV_ALIGN

```cpp
#define R_RISCV_ALIGN 43
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/include/elf.h:131

---

{#r_riscv_rvc_branch}

### R_RISCV_RVC_BRANCH

```cpp
#define R_RISCV_RVC_BRANCH 44
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/include/elf.h:134

---

{#r_riscv_rvc_jump}

### R_RISCV_RVC_JUMP

```cpp
#define R_RISCV_RVC_JUMP 45
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/include/elf.h:137

---

{#r_riscv_relax}

### R_RISCV_RELAX

```cpp
#define R_RISCV_RELAX 51
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/include/elf.h:140

---

{#r_riscv_sub6}

### R_RISCV_SUB6

```cpp
#define R_RISCV_SUB6 52
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/include/elf.h:143

---

{#r_riscv_set6}

### R_RISCV_SET6

```cpp
#define R_RISCV_SET6 53
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/include/elf.h:146

---

{#r_riscv_set8}

### R_RISCV_SET8

```cpp
#define R_RISCV_SET8 54
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/include/elf.h:149

---

{#r_riscv_set16}

### R_RISCV_SET16

```cpp
#define R_RISCV_SET16 55
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/include/elf.h:152

---

{#r_riscv_set32}

### R_RISCV_SET32

```cpp
#define R_RISCV_SET32 56
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/include/elf.h:155

---

{#r_riscv_32_pcrel}

### R_RISCV_32_PCREL

```cpp
#define R_RISCV_32_PCREL 57
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/include/elf.h:158

---

{#nt_arm_pac_mask}

### NT_ARM_PAC_MASK

```cpp
#define NT_ARM_PAC_MASK 0x406
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/include/elf.h:161

---

{#em_loongarch}

### EM_LOONGARCH

```cpp
#define EM_LOONGARCH 258
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/include/elf.h:164

---

{#drgn_version_major}

### DRGN_VERSION_MAJOR

```cpp
#define DRGN_VERSION_MAJOR 0
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:43

Major version of drgn.

---

{#drgn_version_minor}

### DRGN_VERSION_MINOR

```cpp
#define DRGN_VERSION_MINOR 2
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:45

Minor version of drgn.

---

{#drgn_version_patch}

### DRGN_VERSION_PATCH

```cpp
#define DRGN_VERSION_PATCH 0
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:47

Patch level of drgn.

---

{#drgn_accessor_linkage}

### DRGN_ACCESSOR_LINKAGE

```cpp
#define DRGN_ACCESSOR_LINKAGE extern
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:388

---

{#add_new_exception}

### add_new_exception

```cpp
#define add_new_exception(m, name, base) ({				\
		name = PyErr_NewExceptionWithDoc("_drgn." #name,		\
						 drgn_##name##_DOC, base,	\
						 NULL);				\
		!name || PyModule_AddObjectRef(m, #name, name);			\
	})
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/main.c:352

---

{#_unused_}

### _unused_

```cpp
#define _unused_ __attribute__((__unused__))
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/util.h:21

---

{#libdrgn_public}

### LIBDRGN_PUBLIC

```cpp
#define LIBDRGN_PUBLIC __attribute__((__visibility__("default")))
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/util.h:24

---

{#fallthrough}

### fallthrough

```cpp
#define fallthrough do {} while (0)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/util.h:30

---

{#unreachable}

### UNREACHABLE

```cpp
#define UNREACHABLE() assert(false && "should not be reachable")
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/util.h:36

---

{#host_little_endian}

### HOST_LITTLE_ENDIAN

```cpp
#define HOST_LITTLE_ENDIAN (__BYTE_ORDER__ == __ORDER_LITTLE_ENDIAN__)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/util.h:39

---

{#switch_enum}

### SWITCH_ENUM

```cpp
#define SWITCH_ENUM(expr) _Pragma("GCC diagnostic push")				\
	_Pragma("GCC diagnostic error \"-Wswitch-enum\"")	\
	_Pragma("GCC diagnostic error \"-Wswitch-default\"")	\
	switch (expr)						\
	_Pragma("GCC diagnostic pop")
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/util.h:49

Switch statement with an enum controlling expression that must have a case for every enumeration value and a default case.

m4/my_c_switch_enum.m4 checks whether this works and defines a stub version if not. Keep this definition in sync with the check.

---

{#likely}

### likely

```cpp
#define likely(x) __builtin_expect(!!(x), 1)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/util.h:57

---

{#unlikely}

### unlikely

```cpp
#define unlikely(x) __builtin_expect(!!(x), 0)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/util.h:58

---

{#types_compatible}

### types_compatible

```cpp
#define types_compatible(a, b) __builtin_types_compatible_p(typeof(a), typeof(b))
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/util.h:61

Return whether two types or expressions have compatible types.

---

{#is_array}

### is_array

```cpp
#define is_array(x) (!types_compatible(x, &(x)[0]))
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/util.h:64

Return whether an expression is an array.

---

{#static_assert_expression}

### static_assert_expression

```cpp
#define static_assert_expression(assert_expression, message, eval_expression) _Generic(sizeof(struct { _Static_assert(assert_expression, message); int _; }),\
		 default: (eval_expression))
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/util.h:70

`static_assert(assert_expression, message)` as an expression that evaluates to `eval_expression`.

---

{#sizeof_member}

### sizeof_member

```cpp
#define sizeof_member(type, member) sizeof(((type *)0)->member)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/util.h:74

---

{#typeof_member}

### typeof_member

```cpp
#define typeof_member(type, member) typeof(((type *)0)->member)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/util.h:76

---

{#container_of}

### container_of

```cpp
#define container_of(ptr, type, member) static_assert_expression(					\
	types_compatible(*(ptr), ((type *)0)->member)		\
	|| types_compatible(*(ptr), void),			\
	"pointer does not match member type",			\
	(type *)((char *)(ptr) - offsetof(type, member))	\
)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/util.h:78

---

{#malloc_flexible_array}

### malloc_flexible_array

```cpp
#define malloc_flexible_array(type, member, count) malloc_flexible_array_impl(sizeof(type),						\
				   static_assert_expression(is_array(((type *)0)->member),	\
							    "not an array",			\
							    sizeof(((type *)0)->member[0])),	\
				   count)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/util.h:122

Allocate a structure with a flexible array member.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `type` |  | Structure type. |
| `member` |  | Name of flexible array member in `type`. |
| `count` |  | Number of flexible array elements to allocate. |

---

{#max_decimal_length_impl}

### max_decimal_length_impl

```cpp
#define max_decimal_length_impl(n) ((n) * 643 / 2136 + 1)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/util.h:186

---

{#max_decimal_length}

### max_decimal_length

```cpp
#define max_decimal_length(type) ((type)-1 < 0								\
	/*									\
	 * Let f(x) = floor(log10(x)) + 1, which is the number of decimal	\
	 * digits in a positive integer x.					\
	 *									\
	 * For an n-bit two's-complement integer, the worst case is the minimum	\
	 * value, -2^(n - 1), which is f(2^(n - 1)) decimal digits plus the	\
	 * minus sign.								\
	 */									\
	 ? max_decimal_length_impl(sizeof(type) * CHAR_BIT - 1) + 1		\
	/*									\
	 * For an n-bit unsigned integer, the worst case is the maximum value,	\
	 * 2^n - 1. Note that for any positive integer x, 2^x is not a power of	\
	 * 10, so floor(log10(2^x - 1)) = floor(log10(2^x)). Therefore,		\
	 *   f(2^x - 1)								\
	 * = floor(log10(2^x - 1)) + 1						\
	 * = floor(log10(2^x)) + 1						\
	 * = f(2^x).								\
	 */									\
	 : max_decimal_length_impl(sizeof(type) * CHAR_BIT))
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/util.h:192

Get the maximum number of characters required to format an integer type in base 10. This is an integer constant expression.

---

{#add_to_possibly_null_pointer}

### add_to_possibly_null_pointer

```cpp
#define add_to_possibly_null_pointer(ptr, i) ((typeof(ptr))((uintptr_t)(ptr) + (i) * sizeof(*(ptr))))
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/util.h:229

Safely add to a pointer which may be `NULL`.

`NULL + 0` is undefined behavior, but it often arises naturally, like when computing the end of a dynamic array: `arr + length`. This works around the undefined behavior: `[add_to_possibly_null_pointer(NULL, 0)](#add_to_possibly_null_pointer)` is defined as `NULL`.

A more natural definition would be `i == 0 ? ptr : ptr + i`, but some versions of GCC and Clang generate an unnecessary branch or conditional move ([https://gcc.gnu.org/bugzilla/show_bug.cgi?id=97225](https://gcc.gnu.org/bugzilla/show_bug.cgi?id=97225)). Note that in standard C, it is undefined behavior to cast to `uintptr_t`, do arithmetic, and cast back, but GCC allows this as long as the result is within the same object: [https://gcc.gnu.org/onlinedocs/gcc/Arrays-and-pointers-implementation.html](https://gcc.gnu.org/onlinedocs/gcc/Arrays-and-pointers-implementation.html).

---

{#array_size}

### array_size

```cpp
#define array_size(arr)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/array.h:28

Return the number of elements in an array.

---

{#array_for_each}

### array_for_each

```cpp
#define array_for_each(var, arr)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/array.h:40

Iterate over every element in an array.

The element is declared as `element_type *var` in the scope of the loop.

---

{#emit_error}

### emit_error

```cpp
#define emit_error(err) (							\
	/*									\
	 * The call to drgn_error_code() resolves the error for the subsequent	\
	 * direct accesses.							\
	 */									\
	drgn_error_code(err) == DRGN_ERROR_OS ?					\
		/* This is easier than dealing with strerror_r(). */		\
		(errno = err->_errno,						\
		 err->_message[0] && err->_path ?				\
		 emit_error_format("%s: %s: %m", err->_message, err->_path) :	\
		 err->_message[0] || err->_path ?				\
		 emit_error_format("%s: %m",					\
				   err->_message[0]				\
				   ? err->_message : err->_path) :		\
		 emit_error_format("%m"))					\
	: err->_code == DRGN_ERROR_FAULT ?					\
		emit_error_format("%s: 0x%" PRIx64, err->_message,		\
				  err->_address)				\
	:									\
		emit_error_string(err->_message)				\
)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/error.c:204

---

{#emit_error_format}

### emit_error_format

```cpp
#define emit_error_format(..., ...) (asprintf(&tmp, ##__VA_ARGS__) < 0 ? NULL : tmp)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/error.c:239

---

{#emit_error_string}

### emit_error_string

```cpp
#define emit_error_string(s, s, s, s) dprintf(fd, "%s\n", s)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/error.c:258

---

{#emit_error_format}

### emit_error_format

```cpp
#define emit_error_format(..., ...) (asprintf(&tmp, ##__VA_ARGS__) < 0 ? NULL : tmp)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/error.c:239

---

{#emit_error_string}

### emit_error_string

```cpp
#define emit_error_string(s, s, s, s) dprintf(fd, "%s\n", s)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/error.c:258

---

{#emit_error_format-1}

### emit_error_format

```cpp
#define emit_error_format(format, ..., format, ...) dprintf(fd, format "\n", ##__VA_ARGS__)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/error.c:257

---

{#emit_error_string}

### emit_error_string

```cpp
#define emit_error_string(s, s, s, s) dprintf(fd, "%s\n", s)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/error.c:258

---

{#emit_error_format-1}

### emit_error_format

```cpp
#define emit_error_format(format, ..., format, ...) dprintf(fd, format "\n", ##__VA_ARGS__)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/error.c:257

---

{#emit_error_string}

### emit_error_string

```cpp
#define emit_error_string(s, s, s, s) dprintf(fd, "%s\n", s)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/error.c:258

---

{#format-1}

### FORMAT

```cpp
#define FORMAT "cpu.%" PRIuFAST64 ".PRSTATUS"
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/kdump.c:335

---

{#drgn_bitmap_word_bits}

### DRGN_BITMAP_WORD_BITS

```cpp
#define DRGN_BITMAP_WORD_BITS (sizeof(unsigned long) * CHAR_BIT)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/bitmap.h:11

---

{#drgn_num_threads}

### drgn_num_threads

```cpp
#define drgn_num_threads 1
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/openmp.h:18

---

{#py_ssize_t_clean}

### PY_SSIZE_T_CLEAN

```cpp
#define PY_SSIZE_T_CLEAN
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:7

---

{#pythreadstate_getunchecked}

### PyThreadState_GetUnchecked

```cpp
#define PyThreadState_GetUnchecked _PyThreadState_UncheckedGet
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:80

---

{#py_hashpointer}

### Py_HashPointer

```cpp
#define Py_HashPointer _Py_HashPointer
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:84

---

{#drgnpy_public}

### DRGNPY_PUBLIC

```cpp
#define DRGNPY_PUBLIC __attribute__((__visibility__("default")))
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:87

---

{#py_return_bool}

### Py_RETURN_BOOL

```cpp
#define Py_RETURN_BOOL(cond) do {	\
	if (cond)			\
		Py_RETURN_TRUE;		\
	else				\
		Py_RETURN_FALSE;	\
} while (0)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:122

---

{#setter_no_delete}

### SETTER_NO_DELETE

```cpp
#define SETTER_NO_DELETE(name, value) do {				\
	if (!(value)) {							\
		PyErr_Format(PyExc_AttributeError,			\
			     "can't delete '%s' attribute", (name));	\
		return -1;						\
	}								\
} while (0)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:133

Return from a PyGetSetDef setter with an error if attempting to delete the attribute.

---

{#pygilstate_guard}

### PyGILState_guard

```cpp
#define PyGILState_guard() __attribute__((__cleanup__(PyGILState_Releasep), __unused__))	\
	PyGILState_STATE PP_UNIQUE(gstate) = PyGILState_Ensure()
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:147

Scope guard that wraps PyGILState_Ensure() and PyGILState_Release().

---

{#_cleanup_pydecref_}

### _cleanup_pydecref_

```cpp
#define _cleanup_pydecref_ _cleanup_(pydecrefp)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:156

Call `Py_XDECREF()` when the variable goes out of scope.

---

{#drgnpy_recursion_guard}

### drgnpy_recursion_guard

```cpp
#define drgnpy_recursion_guard(where, ret) if (Py_EnterRecursiveCall(where))				\
		return (ret);						\
	__attribute__((__cleanup__(Py_LeaveRecursiveCallp), __unused__))\
	int PP_UNIQUE(recursive_call) = 0
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:162

Scope guard that wraps `Py_EnterRecursiveCall()` and `Py_LeaveRecursiveCall()`, returning `ret` if the limit is reached.

---

{#drgn_initialize_python_guard}

### drgn_initialize_python_guard

```cpp
#define drgn_initialize_python_guard(success_ret) __attribute__((__cleanup__(PyGILState_Releasep), __unused__))		\
	PyGILState_STATE PP_UNIQUE(gstate) = drgn_initialize_python(success_ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:406

---

{#call_tp_alloc}

### call_tp_alloc

```cpp
#define call_tp_alloc(type) ((type *)type##_type.tp_alloc(&type##_type, 0))
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:418

---

{#path_arg-1}

### PATH_ARG

```cpp
#define PATH_ARG(name, ...) __attribute__((__cleanup__(path_cleanup)))	\
	struct path_arg name = { __VA_ARGS__ }
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:533

---

{#path_sequence_arg-1}

### PATH_SEQUENCE_ARG

```cpp
#define PATH_SEQUENCE_ARG(name, ...) __attribute__((__cleanup__(path_sequence_cleanup)))			\
	struct path_sequence_arg name = { .args = VECTOR_INIT, __VA_ARGS__ }
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:549

---

{#module_file_status_getset}

### MODULE_FILE_STATUS_GETSET

```cpp
#define MODULE_FILE_STATUS_GETSET(which)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/module.c:398

---

{#drgn_object_initializer-1}

### DRGN_OBJECT_INITIALIZER

```cpp
#define DRGN_OBJECT_INITIALIZER(prog) (struct drgn_object){					\
		.type = &(prog)->void_types[DRGN_LANGUAGE_C],	\
		.encoding = DRGN_OBJECT_ENCODING_NONE,		\
		.kind = DRGN_OBJECT_ABSENT,			\
		.absence_reason = DRGN_ABSENCE_REASON_OTHER,	\
	}
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/object.c:22

---

{#binary_op}

### BINARY_OP

```cpp
#define BINARY_OP(op_name) LIBDRGN_PUBLIC struct drgn_error *						\
drgn_object_##op_name(struct drgn_object *res, const struct drgn_object *lhs,	\
		      const struct drgn_object *rhs)				\
{										\
	const struct drgn_language *lang = drgn_object_language(lhs);		\
										\
	if (drgn_object_program(lhs) != drgn_object_program(res) ||		\
	    drgn_object_program(rhs) != drgn_object_program(res)) {		\
		return drgn_error_create(DRGN_ERROR_INVALID_ARGUMENT,		\
					 "objects are from different programs");\
	}									\
	if (!lang->op_##op_name) {						\
		return drgn_error_format(DRGN_ERROR_INVALID_ARGUMENT,		\
					 "%s does not implement " #op_name,	\
					 lang->name);				\
	}									\
	return lang->op_##op_name(res, lhs, rhs);				\
}
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/object.c:1563

---

{#unary_op}

### UNARY_OP

```cpp
#define UNARY_OP(op_name) LIBDRGN_PUBLIC struct drgn_error *						\
drgn_object_##op_name(struct drgn_object *res, const struct drgn_object *obj)	\
{										\
	const struct drgn_language *lang = drgn_object_language(obj);		\
										\
	if (drgn_object_program(res) != drgn_object_program(obj)) {		\
		return drgn_error_create(DRGN_ERROR_INVALID_ARGUMENT,		\
					 "objects are from different programs");\
	}									\
	if (!lang->op_##op_name) {						\
		return drgn_error_format(DRGN_ERROR_INVALID_ARGUMENT,		\
					 "%s does not implement " #op_name,	\
					 lang->name);				\
	}									\
	return lang->op_##op_name(res, obj);					\
}
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/object.c:1594

---

{#binary_op_signed_2c}

### BINARY_OP_SIGNED_2C

```cpp
#define BINARY_OP_SIGNED_2C(res, type, lhs, op, rhs) ({				\
	struct drgn_error *_err;						\
	const struct drgn_object_type *_type = (type);				\
	union {									\
		int64_t svalue;							\
		uint64_t uvalue;						\
	} lhs_tmp, rhs_tmp, tmp;						\
	_err = binary_operands_signed((lhs), (rhs), _type->bit_size,		\
				      &lhs_tmp.svalue, &rhs_tmp.svalue);	\
	if (!_err) {								\
		tmp.uvalue = lhs_tmp.uvalue op rhs_tmp.uvalue;			\
		_err = drgn_object_set_signed_internal((res), _type,		\
						       tmp.svalue);		\
	}									\
	_err;									\
})
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/object.c:2007

---

{#binary_op_unsigned}

### BINARY_OP_UNSIGNED

```cpp
#define BINARY_OP_UNSIGNED(res, type, lhs, op, rhs) ({				\
	struct drgn_error *_err;						\
	const struct drgn_object_type *_type = (type);				\
	uint64_t lhs_uvalue, rhs_uvalue;					\
										\
	_err = binary_operands_unsigned((lhs), (rhs), _type->bit_size,		\
					&lhs_uvalue, &rhs_uvalue);		\
	if (!_err) {								\
		_err = drgn_object_set_unsigned_internal((res), _type,		\
							 lhs_uvalue op rhs_uvalue);\
	}									\
	_err;									\
})
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/object.c:2024

---

{#binary_op_float}

### BINARY_OP_FLOAT

```cpp
#define BINARY_OP_FLOAT(res, type, lhs, op, rhs) ({				\
	struct drgn_error *_err;						\
	double lhs_fvalue, rhs_fvalue;						\
	_err = binary_operands_float((lhs), (rhs), &lhs_fvalue, &rhs_fvalue);	\
	if (!_err) {								\
		_err = drgn_object_set_float_internal((res), (type),		\
					              lhs_fvalue op rhs_fvalue);\
	}									\
	_err;									\
})
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/object.c:2038

---

{#cmp}

### CMP

```cpp
#define CMP(lhs, rhs) ({				\
	__auto_type _lhs = (lhs);			\
	__auto_type _rhs = (rhs);			\
							\
	(_lhs > _rhs ? 1 : _lhs < _rhs ? -1 : 0);	\
})
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/object.c:2049

---

{#arithmetic_binary_op}

### ARITHMETIC_BINARY_OP

```cpp
#define ARITHMETIC_BINARY_OP(op_name, op) struct drgn_error *								\
drgn_op_##op_name##_impl(struct drgn_object *res,				\
			 const struct drgn_operand_type *op_type,		\
			 const struct drgn_object *lhs,				\
			 const struct drgn_object *rhs)				\
{										\
	struct drgn_error *err;							\
	struct drgn_object_type type;						\
	err = drgn_object_type_operand(op_type, &type);				\
	if (err)								\
		return err;							\
	switch (type.encoding) {						\
	case DRGN_OBJECT_ENCODING_SIGNED:					\
		return BINARY_OP_SIGNED_2C(res, &type, lhs, op, rhs);		\
	case DRGN_OBJECT_ENCODING_UNSIGNED:					\
		return BINARY_OP_UNSIGNED(res, &type, lhs, op, rhs);		\
	case DRGN_OBJECT_ENCODING_FLOAT:					\
		return BINARY_OP_FLOAT(res, &type, lhs, op, rhs);		\
	default:								\
		return drgn_error_create(DRGN_ERROR_TYPE,			\
					 "invalid result type for " #op_name);	\
	}									\
}
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/object.c:2120

---

{#integer_binary_op}

### INTEGER_BINARY_OP

```cpp
#define INTEGER_BINARY_OP(op_name, op) struct drgn_error *								\
drgn_op_##op_name##_impl(struct drgn_object *res,				\
			 const struct drgn_operand_type *op_type,		\
			 const struct drgn_object *lhs,				\
			 const struct drgn_object *rhs)				\
{										\
	struct drgn_error *err;							\
	struct drgn_object_type type;						\
	err = drgn_object_type_operand(op_type, &type);				\
	if (err)								\
		return err;							\
	switch (type.encoding) {						\
	case DRGN_OBJECT_ENCODING_SIGNED:					\
		return BINARY_OP_SIGNED_2C(res, &type, lhs, op, rhs);		\
	case DRGN_OBJECT_ENCODING_UNSIGNED:					\
		return BINARY_OP_UNSIGNED(res, &type, lhs, op, rhs);		\
	default:								\
		return drgn_error_create(DRGN_ERROR_TYPE,			\
					 "invalid result type for " #op_name);	\
	}									\
}
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/object.c:2525

---

{#unary_op_signed_2c}

### UNARY_OP_SIGNED_2C

```cpp
#define UNARY_OP_SIGNED_2C(res, type, op, obj) ({				\
	struct drgn_error *_err;						\
	const struct drgn_object_type *_type = (type);				\
	union {									\
		int64_t svalue;							\
		uint64_t uvalue;						\
	} tmp;									\
	_err = drgn_object_convert_signed((obj), _type->bit_size, &tmp.svalue);	\
	if (!_err) {								\
		tmp.uvalue = op tmp.uvalue;					\
		_err = drgn_object_set_signed_internal((res), _type,		\
						       tmp.svalue);		\
	}									\
	_err;									\
})
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/object.c:2553

---

{#unary_op_unsigned}

### UNARY_OP_UNSIGNED

```cpp
#define UNARY_OP_UNSIGNED(res, type, op, obj) ({				\
	struct drgn_error *_err;						\
	const struct drgn_object_type *_type = (type);				\
	uint64_t uvalue;							\
	_err = drgn_object_convert_unsigned((obj), _type->bit_size, &uvalue);	\
	if (!_err) {								\
		_err = drgn_object_set_unsigned_internal((res), _type,		\
							 op uvalue);		\
	}									\
	_err;									\
})
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/object.c:2569

---

{#arithmetic_unary_op}

### ARITHMETIC_UNARY_OP

```cpp
#define ARITHMETIC_UNARY_OP(op_name, op) struct drgn_error *								\
drgn_op_##op_name##_impl(struct drgn_object *res,				\
			 const struct drgn_operand_type *op_type,		\
			 const struct drgn_object *obj)				\
{										\
	struct drgn_error *err;							\
	struct drgn_object_type type;						\
	err = drgn_object_type_operand(op_type, &type);				\
	if (err)								\
		return err;							\
	switch (type.encoding) {						\
	case DRGN_OBJECT_ENCODING_SIGNED:					\
		return UNARY_OP_SIGNED_2C(res, &type, op, obj);			\
	case DRGN_OBJECT_ENCODING_UNSIGNED:					\
		return UNARY_OP_UNSIGNED(res, &type, op, obj);			\
	case DRGN_OBJECT_ENCODING_FLOAT: {					\
		double fvalue;							\
		err = drgn_object_convert_float(obj, &fvalue);			\
		if (err)							\
			return err;						\
		return drgn_object_set_float_internal(res, &type, op fvalue);	\
										\
	}									\
	default:								\
		return drgn_error_create(DRGN_ERROR_TYPE,			\
					 "invalid result type for " #op_name);	\
	}									\
}
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/object.c:2581

---

{#less_than_start}

### less_than_start

```cpp
#define less_than_start(a, b) (*(a) < (b)->address)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/symbol.c:371

---

{#less_than_end}

### less_than_end

```cpp
#define less_than_end(a, b) (*(a) < *(b))
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/symbol.c:379

---

{#_cleanup_symbol_}

### _cleanup_symbol_

```cpp
#define _cleanup_symbol_ _cleanup_(drgn_symbol_cleanup)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/symbol.h:43

---

{#_cleanup_}

### _cleanup_

```cpp
#define _cleanup_(x) __attribute__((__cleanup__(x)))
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/cleanup.h:19

---

{#_cleanup_free_}

### _cleanup_free_

```cpp
#define _cleanup_free_ _cleanup_(freep)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/cleanup.h:22

Call `free()` when the variable goes out of scope.

---

{#_cleanup_fclose_}

### _cleanup_fclose_

```cpp
#define _cleanup_fclose_ _cleanup_(fclosep)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/cleanup.h:29

Call `fclose()` when the variable goes out of scope.

---

{#_cleanup_close_}

### _cleanup_close_

```cpp
#define _cleanup_close_ _cleanup_(closep)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/cleanup.h:37

Call `close()` when the variable goes out of scope.

---

{#_cleanup_closedir_}

### _cleanup_closedir_

```cpp
#define _cleanup_closedir_ _cleanup_(closedirp)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/cleanup.h:45

Call `closedir()` when the variable goes out of scope.

---

{#no_cleanup_ptr}

### no_cleanup_ptr

```cpp
#define no_cleanup_ptr(p) ({ __auto_type __ptr = (p); (p) = NULL; __ptr; })
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/cleanup.h:58

Get the value of a pointer variable and reset it to `NULL`.

This can be used to avoid freeing a variable declared with *cleanup_free* or another scope guard that is a no-op for `NULL`.

---

{#return_ptr}

### return_ptr

```cpp
#define return_ptr(p) return no_cleanup_ptr(p)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/cleanup.h:65

Return a pointer declared with [_cleanup_free_](#_cleanup_free_) without freeing it.

This can also be used for other scope guards that are a no-op for `NULL`.

---

{#drgn_handler_list_for_each_registered}

### drgn_handler_list_for_each_registered

```cpp
#define drgn_handler_list_for_each_registered(handler, list) for (struct drgn_handler *handler = (list)->head; handler;	\
	     handler = handler->next)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/handler.c:36

---

{#drgn_handler_list_deinit}

### drgn_handler_list_deinit

```cpp
#define drgn_handler_list_deinit(type, handler, list, ...) do {	\
	type *handler = (type *)(list)->head;			\
	while (handler) {					\
		__VA_ARGS__					\
		handler = (type *)drgn_handler_free_and_next((struct drgn_handler *)handler);\
	}							\
} while (0)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/handler.h:75

---

{#drgn_handler_list_for_each_enabled}

### drgn_handler_list_for_each_enabled

```cpp
#define drgn_handler_list_for_each_enabled(type, handler, list) for (type *handler = (type *)(list)->head;			\
	     handler && ((struct drgn_handler *)handler)->enabled;	\
	     handler = (type *)((struct drgn_handler *)handler)->next)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/handler.h:83

---

{#drgn_program_finder}

### DRGN_PROGRAM_FINDER

```cpp
#define DRGN_PROGRAM_FINDER(which)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.c:221

---

{#format-2}

### FORMAT

```cpp
#define FORMAT "/proc/%" PRIu32 "/comm"
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.c:1693

---

{#format-2}

### FORMAT

```cpp
#define FORMAT "/proc/%" PRIu32 "/comm"
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.c:1693

---

{#visit_aux_members}

### visit_aux_members

```cpp
#define visit_aux_members(visit_scalar_member, visit_raw_member) do {	\
	visit_scalar_member(a_type);					\
	visit_scalar_member(a_un.a_val);				\
} while (0)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.c:924

---

{#pr_fname_len}

### PR_FNAME_LEN

```cpp
#define PR_FNAME_LEN 16
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.c:1033

---

{#format-2}

### FORMAT

```cpp
#define FORMAT "/proc/%" PRIu32 "/comm"
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.c:1693

---

{#format-2}

### FORMAT

```cpp
#define FORMAT "/proc/%" PRIu32 "/comm"
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.c:1693

---

{#format-2}

### FORMAT

```cpp
#define FORMAT "/proc/%" PRIu32 "/comm"
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.c:1693

---

{#define_program_read_u}

### DEFINE_PROGRAM_READ_U

```cpp
#define DEFINE_PROGRAM_READ_U(n) LIBDRGN_PUBLIC struct drgn_error *						\
drgn_program_read_u##n(struct drgn_program *prog, uint64_t address,		\
		       bool physical, uint##n##_t *ret)				\
{										\
	bool bswap;								\
	struct drgn_error *err = drgn_program_bswap(prog, &bswap);		\
	if (err)								\
		return err;							\
	uint##n##_t tmp;							\
	err = drgn_program_read_memory(prog, &tmp, address, sizeof(tmp),	\
				       physical);				\
	if (err)								\
		return err;							\
	if (bswap)								\
		tmp = bswap_##n(tmp);						\
	*ret = tmp;								\
	return NULL;								\
}
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.c:1957

---

{#drgn_c_family_lexer-1}

### DRGN_C_FAMILY_LEXER

```cpp
#define DRGN_C_FAMILY_LEXER(c_family_lexer, str, cpp_) __attribute__((__cleanup__(drgn_c_family_lexer_deinit)))		\
	struct drgn_c_family_lexer c_family_lexer = {				\
		.lexer = DRGN_LEXER_INIT(drgn_c_family_lexer_func, (str)),	\
		.cpp = (cpp_),							\
	}
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/c_lexer.h:66

---

{#cityhash_c1}

### cityhash_c1

```cpp
#define cityhash_c1 UINT32_C(0xcc9e2d51)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/cityhash.h:31

---

{#cityhash_c2}

### cityhash_c2

```cpp
#define cityhash_c2 UINT32_C(0x1b873593)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/cityhash.h:32

---

{#cityhash_c3}

### cityhash_c3

```cpp
#define cityhash_c3 UINT32_C(0xe6546b64)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/cityhash.h:33

---

{#cityhash_k0}

### cityhash_k0

```cpp
#define cityhash_k0 UINT64_C(0xc3a5c85c97cb3127)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/cityhash.h:170

---

{#cityhash_k1}

### cityhash_k1

```cpp
#define cityhash_k1 UINT64_C(0xb492b66fbe98f273)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/cityhash.h:171

---

{#cityhash_k2}

### cityhash_k2

```cpp
#define cityhash_k2 UINT64_C(0x9ae16a3b2f90404f)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/cityhash.h:172

---

{#type_if}

### type_if

```cpp
#define type_if(condition, if_true, if_false) __typeof__(							\
       /* + 1 avoids a non-standard zero-length array. */	\
       *_Generic((int (*)[!(condition) + 1])0,			\
		 int (*)[1]: (__typeof__(if_true) *)0,		\
		 int (*)[2]: (__typeof__(if_false) *)0)		\
)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/generics.h:20

Choose a type based on a condition.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `condition` |  | Controlling integer constant expression. |
| `if_true` |  | Type if `condition` is non-zero. |
| `if_false` |  | Type if `condition` is zero. |

---

{#typedef_if}

### typedef_if

```cpp
#define typedef_if(name, condition, if_true, if_false) typedef type_if(condition, if_true, if_false) name
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/generics.h:36

Define a typedef based on a condition.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `name` |  | Name of type. |
| `condition` |  | Controlling integer constant expression. |
| `if_true` |  | Type if `condition` is non-zero. |
| `if_false` |  | Type if `condition` is zero. |

---

{#max_symbol_length}

### MAX_SYMBOL_LENGTH

```cpp
#define MAX_SYMBOL_LENGTH 0x10000
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/kallsyms.c:68

---

{#define_drgn_reloc_add}

### DEFINE_DRGN_RELOC_ADD

```cpp
#define DEFINE_DRGN_RELOC_ADD(bits) struct drgn_error *								\
drgn_reloc_add##bits(const struct drgn_relocating_section *relocating,		\
		     uint64_t r_offset, const int64_t *r_addend,		\
		     uint##bits##_t addend)					\
{										\
	uint##bits##_t value;							\
	if (r_offset > relocating->buf_size ||					\
	    relocating->buf_size - r_offset < sizeof(value))			\
		return &drgn_invalid_relocation_offset;				\
	if (r_addend) {								\
		value = *r_addend;						\
	} else {								\
		memcpy(&value, relocating->buf + r_offset, sizeof(value));	\
		if (relocating->bswap)						\
			value = bswap_##bits(value);				\
	}									\
	value += addend;							\
	if (relocating->bswap)							\
		value = bswap_##bits(value);					\
	memcpy(relocating->buf + r_offset, &value, sizeof(value));		\
	return NULL;								\
}
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/platform.c:231

---

{#bswap_8-1}

### bswap_8

```cpp
#define bswap_8(x) (x)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/platform.c:257

---

{#drgn_accessor_linkage-1}

### DRGN_ACCESSOR_LINKAGE

```cpp
#define DRGN_ACCESSOR_LINKAGE LIBDRGN_PUBLIC extern
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/accessors.c:5

---

{#orc_header_size}

### ORC_HEADER_SIZE

```cpp
#define ORC_HEADER_SIZE 20
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/orc_info.c:24

---

{#get_symbol}

### get_symbol

```cpp
#define get_symbol(name, var, optional) err = drgn_program_find_symbol_by_name(module->prog, name, &sym); \
	if (!err) { \
		var = sym->address; \
		drgn_symbol_destroy(sym); \
		sym = NULL; \
	} else if (optional && drgn_error_catch(&err, DRGN_ERROR_LOOKUP)) { \
		sym = NULL; \
	} else { \
		drgn_error_catch(&err, DRGN_ERROR_LOOKUP); \
		return err; \
	}
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/orc_info.c:451

---

{#less_than_uint64_range_start}

### less_than_uint64_range_start

```cpp
#define less_than_uint64_range_start(a, b) (*(a) < (b)->start)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/orc_info.c:742

---

{#less_than_orc_pc}

### less_than_orc_pc

```cpp
#define less_than_orc_pc(a, b) (*(a) < drgn_orc_pc(module, (b) - module->orc.pc_offsets))
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/orc_info.c:760

---

{#drgn_ck_err}

### drgn_ck_err

```cpp
#define drgn_ck_err(err, code, message) drgn_ck_err_impl(err, PP_UNIQUE(_err), code, message)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/tests/test_util.h:12

---

{#drgn_ck_err_impl}

### drgn_ck_err_impl

```cpp
#define drgn_ck_err_impl(err, unique_err, code, message) do {			\
	struct drgn_error *unique_err = (err);					\
	ck_assert_msg(unique_err, "Assertion '%s != NULL' failed", #err);	\
	ck_assert_int_eq(drgn_error_code(unique_err), (code));			\
	ck_assert_str_eq(drgn_error_message(unique_err), (message));		\
	drgn_error_destroy(unique_err);						\
} while (0)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/tests/test_util.h:13

---

{#drgn_ck_err_substr}

### drgn_ck_err_substr

```cpp
#define drgn_ck_err_substr(err, code, message) drgn_ck_err_substr_impl(err, PP_UNIQUE(_err), code, message)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/tests/test_util.h:21

---

{#drgn_ck_err_substr_impl}

### drgn_ck_err_substr_impl

```cpp
#define drgn_ck_err_substr_impl(err, unique_err, code, message) do {		\
	struct drgn_error *unique_err = (err);					\
	ck_assert_msg(unique_err, "Assertion '%s != NULL' failed", #err);	\
	ck_assert_int_eq(drgn_error_code(unique_err), (code));			\
	ck_assert(strstr(drgn_error_message(unique_err), (message)));		\
	drgn_error_destroy(unique_err);						\
} while (0)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/tests/test_util.h:23

---

{#drgn_ck_no_err}

### drgn_ck_no_err

```cpp
#define drgn_ck_no_err(err) drgn_ck_no_err_impl(err, PP_UNIQUE(_err))
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/tests/test_util.h:31

---

{#drgn_ck_no_err_impl}

### drgn_ck_no_err_impl

```cpp
#define drgn_ck_no_err_impl(err, unique_err) do {				\
	struct drgn_error *unique_err = (err);					\
	ck_assert_msg(!unique_err, "Assertion '!(%s)' failed: error: %s", #err,	\
		      unique_err ? drgn_error_message(unique_err) : "");	\
} while (0)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/tests/test_util.h:32

---

{#_ck_assert_ptr_null}

### _ck_assert_ptr_null

```cpp
#define _ck_assert_ptr_null(X, OP) do { \
  const void* _ck_x = (X); \
  ck_assert_msg(_ck_x OP NULL, \
  "Assertion '%s' failed: %s == %#lx", \
  #X" "#OP" NULL", \
  #X, (unsigned long)(uintptr_t)_ck_x); \
} while (0)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/tests/test_util.h:42

---

{#ck_assert_ptr_null}

### ck_assert_ptr_null

```cpp
#define ck_assert_ptr_null(X) _ck_assert_ptr_null(X, ==)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/tests/test_util.h:51

---

{#ck_assert_ptr_nonnull}

### ck_assert_ptr_nonnull

```cpp
#define ck_assert_ptr_nonnull(X) _ck_assert_ptr_null(X, !=)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/tests/test_util.h:55

---

{#ck_max_assert_mem_print_size}

### CK_MAX_ASSERT_MEM_PRINT_SIZE

```cpp
#define CK_MAX_ASSERT_MEM_PRINT_SIZE 64
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/tests/test_util.h:60

---

{#_ck_assert_mem}

### _ck_assert_mem

```cpp
#define _ck_assert_mem(X, OP, Y, L) do { \
  const uint8_t* _ck_x = (const uint8_t*)(X); \
  const uint8_t* _ck_y = (const uint8_t*)(Y); \
  size_t _ck_l = (L); \
  char _ck_x_str[CK_MAX_ASSERT_MEM_PRINT_SIZE * 2 + 1]; \
  char _ck_y_str[CK_MAX_ASSERT_MEM_PRINT_SIZE * 2 + 1]; \
  static const char _ck_hexdigits[] = "0123456789abcdef"; \
  size_t _ck_i; \
  size_t _ck_maxl = (_ck_l > CK_MAX_ASSERT_MEM_PRINT_SIZE) ? CK_MAX_ASSERT_MEM_PRINT_SIZE : _ck_l; \
  for (_ck_i = 0; _ck_i < _ck_maxl; _ck_i++) { \
    _ck_x_str[_ck_i * 2  ]   = _ck_hexdigits[(_ck_x[_ck_i] >> 4) & 0xF]; \
    _ck_y_str[_ck_i * 2  ]   = _ck_hexdigits[(_ck_y[_ck_i] >> 4) & 0xF]; \
    _ck_x_str[_ck_i * 2 + 1] = _ck_hexdigits[_ck_x[_ck_i] & 0xF]; \
    _ck_y_str[_ck_i * 2 + 1] = _ck_hexdigits[_ck_y[_ck_i] & 0xF]; \
  } \
  _ck_x_str[_ck_i * 2] = 0; \
  _ck_y_str[_ck_i * 2] = 0; \
  if (_ck_maxl != _ck_l) { \
    _ck_x_str[_ck_i * 2 - 2] = '.'; \
    _ck_y_str[_ck_i * 2 - 2] = '.'; \
    _ck_x_str[_ck_i * 2 - 1] = '.'; \
    _ck_y_str[_ck_i * 2 - 1] = '.'; \
  } \
  ck_assert_msg(0 OP memcmp(_ck_y, _ck_x, _ck_l), \
    "Assertion '%s' failed: %s == \"%s\", %s == \"%s\"", #X" "#OP" "#Y, #X, _ck_x_str, #Y, _ck_y_str); \
} while (0)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/tests/test_util.h:64

---

{#ck_assert_mem_eq}

### ck_assert_mem_eq

```cpp
#define ck_assert_mem_eq(X, Y, L) _ck_assert_mem(X, ==, Y, L)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/tests/test_util.h:92

---

{#ck_assert_mem_ne}

### ck_assert_mem_ne

```cpp
#define ck_assert_mem_ne(X, Y, L) _ck_assert_mem(X, !=, Y, L)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/tests/test_util.h:96

---

{#ck_assert_mem_lt}

### ck_assert_mem_lt

```cpp
#define ck_assert_mem_lt(X, Y, L) _ck_assert_mem(X, <, Y, L)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/tests/test_util.h:100

---

{#ck_assert_mem_le}

### ck_assert_mem_le

```cpp
#define ck_assert_mem_le(X, Y, L) _ck_assert_mem(X, <=, Y, L)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/tests/test_util.h:104

---

{#ck_assert_mem_gt}

### ck_assert_mem_gt

```cpp
#define ck_assert_mem_gt(X, Y, L) _ck_assert_mem(X, >, Y, L)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/tests/test_util.h:108

---

{#ck_assert_mem_ge}

### ck_assert_mem_ge

```cpp
#define ck_assert_mem_ge(X, Y, L) _ck_assert_mem(X, >=, Y, L)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/tests/test_util.h:112

---

{#case_r_riscv_add_sub}

### CASE_R_RISCV_ADD_SUB

```cpp
#define CASE_R_RISCV_ADD_SUB(bits)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/arch_riscv.c:34

---

{#bswap_8-2}

### bswap_8

```cpp
#define bswap_8(x) (x)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/arch_riscv.c:67

---

{#region_invalid}

### REGION_INVALID

```cpp
#define REGION_INVALID 0x20
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/arch_s390x.c:263

---

{#segment_invalid}

### SEGMENT_INVALID

```cpp
#define SEGMENT_INVALID 0x20
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/arch_s390x.c:264

---

{#page_invalid}

### PAGE_INVALID

```cpp
#define PAGE_INVALID 0x400
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/arch_s390x.c:265

---

{#region_large}

### REGION_LARGE

```cpp
#define REGION_LARGE 0x400
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/arch_s390x.c:267

---

{#segment_large}

### SEGMENT_LARGE

```cpp
#define SEGMENT_LARGE 0x400
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/arch_s390x.c:268

---

{#page_large}

### PAGE_LARGE

```cpp
#define PAGE_LARGE 0x800
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/arch_s390x.c:269

---

{#drgn_module_try_files_log}

### drgn_module_try_files_log

```cpp
#define drgn_module_try_files_log(module, how_format, ...) ({										\
	struct drgn_module *_module = (module);					\
	bool _want_loaded = _module->loaded_file_status == DRGN_MODULE_FILE_WANT;\
	bool _want_debug = _module->debug_file_status == DRGN_MODULE_FILE_WANT;	\
	bool _want_supplementary_debug = _module->debug_file_status		\
					 == DRGN_MODULE_FILE_WANT_SUPPLEMENTARY;\
	drgn_log_debug(_module->prog,						\
		       "%s (%s%s): " how_format " %s%s%s file%s", _module->name,\
		       _module->build_id_str ? "build ID " : "no build ID",	\
		       _module->build_id_str ?: "",				\
		       ## __VA_ARGS__,						\
		       _want_loaded ? "loaded" : "",				\
		       _want_loaded && (_want_debug || _want_supplementary_debug)\
		       ? " and " : "",						\
		       _want_debug ? "debug"					\
		       : _want_supplementary_debug ? "supplementary debug" : "",\
		       _want_loaded && (_want_debug || _want_supplementary_debug)\
		       ? "s" : "");						\
})
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.c:1768

---

{#drgn_map_files_segments-1}

### DRGN_MAP_FILES_SEGMENTS

```cpp
#define DRGN_MAP_FILES_SEGMENTS(name) _cleanup_(drgn_map_files_segments_deinit)			\
	struct drgn_map_files_segments name = { VECTOR_INIT, true }
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.c:2029

---

{#dir_format}

### DIR_FORMAT

```cpp
#define DIR_FORMAT "/proc/%ld/map_files"
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.c:2083

---

{#entry_format}

### ENTRY_FORMAT

```cpp
#define ENTRY_FORMAT "/%" PRIx64 "-%" PRIx64
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.c:2084

---

{#less_than_start-1}

### less_than_start

```cpp
#define less_than_start(a, b, a, b) (*(a) < (b)->start)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.c:3551

---

{#format-3}

### FORMAT

```cpp
#define FORMAT "/proc/%ld/map_files"
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.c:4717

---

{#drgn_mapped_file_segments-1}

### DRGN_MAPPED_FILE_SEGMENTS

```cpp
#define DRGN_MAPPED_FILE_SEGMENTS(name) _cleanup_(drgn_mapped_file_segments_deinit)			\
	struct drgn_mapped_file_segments name = { VECTOR_INIT, true }
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.c:3434

---

{#less_than_start-1}

### less_than_start

```cpp
#define less_than_start(a, b, a, b) (*(a) < (b)->start)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.c:3551

---

{#visit_elf_ehdr_members}

### visit_elf_ehdr_members

```cpp
#define visit_elf_ehdr_members(visit_scalar_member, visit_raw_member) do {	\
	visit_raw_member(e_ident);						\
	visit_scalar_member(e_type);						\
	visit_scalar_member(e_machine);						\
	visit_scalar_member(e_version);						\
	visit_scalar_member(e_entry);						\
	visit_scalar_member(e_phoff);						\
	visit_scalar_member(e_shoff);						\
	visit_scalar_member(e_flags);						\
	visit_scalar_member(e_ehsize);						\
	visit_scalar_member(e_phentsize);					\
	visit_scalar_member(e_phnum);						\
	visit_scalar_member(e_shentsize);					\
	visit_scalar_member(e_shnum);						\
	visit_scalar_member(e_shstrndx);					\
} while (0)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.c:3598

---

{#visit_phdr_members}

### visit_phdr_members

```cpp
#define visit_phdr_members(visit_scalar_member, visit_raw_member) do {	\
	visit_scalar_member(p_type);					\
	visit_scalar_member(p_flags);					\
	visit_scalar_member(p_offset);					\
	visit_scalar_member(p_vaddr);					\
	visit_scalar_member(p_paddr);					\
	visit_scalar_member(p_filesz);					\
	visit_scalar_member(p_memsz);					\
	visit_scalar_member(p_align);					\
} while (0)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.c:3669

---

{#visit_elf_dyn_members}

### visit_elf_dyn_members

```cpp
#define visit_elf_dyn_members(visit_scalar_member, visit_raw_member) do {	\
	visit_scalar_member(d_tag);						\
	visit_scalar_member(d_un.d_val);					\
} while (0)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.c:3732

---

{#read_struct64}

### read_struct64

```cpp
#define read_struct64(prog, struct64p, address, type32, visit_members) read_struct64_impl(prog, struct64p, address, type32, visit_members,	\
			   PP_UNIQUE(prog), PP_UNIQUE(struct64p),		\
			   PP_UNIQUE(is_64_bit), PP_UNIQUE(err))
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.c:4119

---

{#read_struct64_impl}

### read_struct64_impl

```cpp
#define read_struct64_impl(prog, struct64p, address, type32, visit_members, unique_prog, unique_struct64, unique_is_64_bit, unique_err) ({					\
	struct drgn_program *unique_prog = (prog);				\
	__auto_type unique_struct64p = (struct64p);				\
	static_assert(sizeof(*unique_struct64p) >= sizeof(type32),		\
		      "64-bit type is smaller than 32-bit type");		\
	const bool unique_is_64_bit =						\
		drgn_platform_is_64_bit(&unique_prog->platform);		\
	struct drgn_error *unique_err =						\
		drgn_program_read_memory(unique_prog, unique_struct64p,		\
					 (address),				\
					 unique_is_64_bit			\
					 ? sizeof(*unique_struct64p)		\
					 : sizeof(type32), false);		\
	if (!unique_err) {							\
		deserialize_struct64_inplace(unique_struct64p, type32,		\
					     visit_members, unique_is_64_bit,	\
					     drgn_platform_bswap(&unique_prog->platform));\
	}									\
	unique_err;								\
})
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.c:4125

---

{#visit_r_debug_members}

### visit_r_debug_members

```cpp
#define visit_r_debug_members(visit_scalar_member, visit_raw_member) do {	\
	visit_scalar_member(r_version);						\
	visit_scalar_member(r_map);						\
} while (0)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.c:4204

---

{#visit_link_map_members}

### visit_link_map_members

```cpp
#define visit_link_map_members(visit_scalar_member, visit_raw_member) do {	\
	visit_scalar_member(l_addr);						\
	visit_scalar_member(l_name);						\
	visit_scalar_member(l_ld);						\
	visit_scalar_member(l_next);						\
} while (0)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.c:4339

---

{#format-3}

### FORMAT

```cpp
#define FORMAT "/proc/%ld/map_files"
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.c:4717

---

{#format-3}

### FORMAT

```cpp
#define FORMAT "/proc/%ld/map_files"
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.c:4717

---

{#visit_nt_file_segment_members}

### visit_nt_file_segment_members

```cpp
#define visit_nt_file_segment_members(visit_scalar_member, visit_raw_member) do {	\
	visit_scalar_member(start);							\
	visit_scalar_member(end);							\
	visit_scalar_member(file_offset);						\
} while (0)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.c:4903

---

{#less_than_cu_lookup_buf}

### less_than_cu_lookup_buf

```cpp
#define less_than_cu_lookup_buf(a, b) (*(a) < (b)->buf)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:409

---

{#x}

### X

```cpp
#define X(name, name, name) case DW_TAG_##name: dwarf_index_tag = DRGN_DWARF_INDEX_##name; break;
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:5522

---

{#top}

### TOP

```cpp
#define TOP() (dwarf_die_vector_last(&dies))
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:3132

---

{#top}

### TOP

```cpp
#define TOP() (dwarf_die_vector_last(&dies))
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:3132

---

{#x-1}

### X

```cpp
#define X(name, _) if (opcode == name) return true;
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:3851

---

{#check}

### CHECK

```cpp
#define CHECK(n) do {								\
	size_t _n = (n);							\
	if (uint64_vector_size(stack) < _n) {					\
		return binary_buffer_error(&ctx->bb,				\
					   "DWARF expression stack underflow");	\
	}									\
} while (0)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:3908

---

{#elem}

### ELEM

```cpp
#define ELEM(i) *uint64_vector_at(stack, uint64_vector_size(stack) - 1 - (i))
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:3916

---

{#push}

### PUSH

```cpp
#define PUSH(x) do {					\
	uint64_t push = (x);				\
	if (!uint64_vector_append(stack, &push))	\
		return &drgn_enomem;			\
} while (0)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:3918

---

{#push_mask}

### PUSH_MASK

```cpp
#define PUSH_MASK(x) PUSH((x) & address_mask)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:3924

---

{#unop_mask}

### UNOP_MASK

```cpp
#define UNOP_MASK(op) do {			\
	CHECK(1);				\
	ELEM(0) = (op ELEM(0)) & address_mask;	\
} while (0)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:4171

---

{#binop}

### BINOP

```cpp
#define BINOP(op) do {			\
	CHECK(2);			\
	ELEM(1) = ELEM(1) op ELEM(0);	\
	uint64_vector_pop(stack);	\
} while (0)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:4175

---

{#binop_mask}

### BINOP_MASK

```cpp
#define BINOP_MASK(op) do {				\
	CHECK(2);					\
	ELEM(1) = (ELEM(1) op ELEM(0)) & address_mask;	\
	uint64_vector_pop(stack);			\
} while (0)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:4180

---

{#relop}

### RELOP

```cpp
#define RELOP(op) do {						\
	CHECK(2);						\
	ELEM(1) = (truncate_signed(ELEM(1), address_bits) op	\
		   truncate_signed(ELEM(0), address_bits));	\
	uint64_vector_pop(stack);				\
} while (0)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:4278

---

{#x}

### X

```cpp
#define X(name, name, name) case DW_TAG_##name: dwarf_index_tag = DRGN_DWARF_INDEX_##name; break;
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:5522

---

{#x}

### X

```cpp
#define X(name, name, name) case DW_TAG_##name: dwarf_index_tag = DRGN_DWARF_INDEX_##name; break;
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:5522

---

{#less_than_initial_location}

### less_than_initial_location

```cpp
#define less_than_initial_location(a, b) (*(a) < (b)->initial_location)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:7334

---

{#visit_elf_sym_members}

### visit_elf_sym_members

```cpp
#define visit_elf_sym_members(visit_scalar_member, visit_raw_member) do {	\
	visit_scalar_member(st_name);						\
	visit_scalar_member(st_info);						\
	visit_scalar_member(st_other);						\
	visit_scalar_member(st_shndx);						\
	visit_scalar_member(st_value);						\
	visit_scalar_member(st_size);						\
} while (0)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/elf_symtab.c:589

---

{#binary_op-1}

### BINARY_OP

```cpp
#define BINARY_OP(op_name, op, check) static struct drgn_error *c_op_##op_name(struct drgn_object *res,		\
					 const struct drgn_object *lhs,		\
					 const struct drgn_object *rhs)		\
{										\
	struct drgn_error *err;							\
										\
	struct drgn_operand_type lhs_type, rhs_type, type;			\
	err = c_operand_type(lhs, &lhs_type, NULL, NULL);			\
	if (err)								\
		return err;							\
	err = c_operand_type(rhs, &rhs_type, NULL, NULL);			\
	if (err)								\
		return err;							\
	if (!drgn_type_is_##check(lhs_type.underlying_type) ||			\
	    !drgn_type_is_##check(rhs_type.underlying_type))			\
		return drgn_error_binary_op("binary "#op, &lhs_type,		\
					    &rhs_type);				\
										\
	err = c_common_real_type(drgn_object_program(lhs), &lhs_type,		\
				 &rhs_type, &type);				\
	if (err)								\
		return err;							\
										\
	return drgn_op_##op_name##_impl(res, &type, lhs, rhs);			\
}
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/language_c.c:3843

---

{#shift_op}

### SHIFT_OP

```cpp
#define SHIFT_OP(op_name, op) static struct drgn_error *c_op_##op_name(struct drgn_object *res,		\
					 const struct drgn_object *lhs,		\
					 const struct drgn_object *rhs)		\
{										\
	struct drgn_error *err;							\
										\
	struct drgn_operand_type lhs_type, rhs_type;				\
	err = c_operand_type(lhs, &lhs_type, NULL, NULL);			\
	if (err)								\
		return err;							\
	err = c_operand_type(rhs, &rhs_type, NULL, NULL);			\
	if (err)								\
		return err;							\
	if (!drgn_type_is_integer(lhs_type.underlying_type) ||			\
	    !drgn_type_is_integer(rhs_type.underlying_type))			\
		return drgn_error_binary_op("binary " #op, &lhs_type,		\
					    &rhs_type);				\
										\
	err = c_integer_promotions(drgn_object_program(lhs), &lhs_type);	\
	if (err)								\
		return err;							\
	err = c_integer_promotions(drgn_object_program(lhs), &rhs_type);	\
	if (err)								\
		return err;							\
										\
	return drgn_op_##op_name##_impl(res, lhs, &lhs_type, rhs, &rhs_type);	\
}
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/language_c.c:3877

---

{#unary_op-1}

### UNARY_OP

```cpp
#define UNARY_OP(op_name, op, check) static struct drgn_error *c_op_##op_name(struct drgn_object *res,	\
					 const struct drgn_object *obj)	\
{									\
	struct drgn_error *err;						\
									\
	struct drgn_operand_type type;					\
	err = c_operand_type(obj, &type, NULL, NULL);			\
	if (err)							\
		return err;						\
	if (!drgn_type_is_##check(type.underlying_type))		\
		return drgn_error_unary_op("unary " #op, &type);	\
									\
	err = c_integer_promotions(drgn_object_program(obj), &type);	\
	if (err)							\
		return err;						\
									\
	return drgn_op_##op_name##_impl(res, &type, obj);		\
}
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/language_c.c:3909

---

{#_cleanup_stack_trace_}

### _cleanup_stack_trace_

```cpp
#define _cleanup_stack_trace_ _cleanup_(drgn_stack_trace_destroyp)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/stack_trace.c:36

---

{#drgnpy_lazy_object_evaluated}

### DRGNPY_LAZY_OBJECT_EVALUATED

```cpp
#define DRGNPY_LAZY_OBJECT_EVALUATED ((union drgn_lazy_object *)&drgnpy_lazy_object_evaluated)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/type.c:15

---

{#drgnpy_lazy_object_callable}

### DRGNPY_LAZY_OBJECT_CALLABLE

```cpp
#define DRGNPY_LAZY_OBJECT_CALLABLE ((union drgn_lazy_object *)&drgnpy_lazy_object_callable)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/type.c:17

---

{#drgntype_attr-1}

### DrgnType_ATTR

```cpp
#define DrgnType_ATTR(name) static struct DrgnType_Attr DrgnType_attr_##name = {	\
	.id = _Py_static_string_init(#name),		\
	.getter = DrgnType_get_##name,			\
}
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/type.c:369

---

{#append_member}

### append_member

```cpp
#define append_member(parts, type_obj, first, member) ({			\
	int _ret = 0;								\
	if (drgn_type_has_##member((type_obj)->type)) {				\
		_cleanup_pydecref_ PyObject *_obj =				\
			DrgnType_getter((type_obj), &DrgnType_attr_##member);	\
		if (_obj) {							\
			_ret = append_field((parts), (first), #member"=%R",	\
					    _obj);				\
		} else {							\
			_ret = -1;						\
		}								\
	}									\
	_ret;									\
})
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/type.c:508

---

{#compound_type_arg_format}

### compound_type_arg_format

```cpp
#define compound_type_arg_format "O|O&O$OO&O&"
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/type.c:1681

---

{#start_kernel_map}

### START_KERNEL_MAP

```cpp
#define START_KERNEL_MAP UINT64_C(0xffffffff80000000)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/arch_x86_64.c:23

---

{#set_at_cfa_rule}

### SET_AT_CFA_RULE

```cpp
#define SET_AT_CFA_RULE(reg, cfa_offset) do {					\
	rule.kind = DRGN_CFI_RULE_AT_CFA_PLUS_OFFSET;				\
	rule.offset = cfa_offset;						\
	if (!drgn_cfi_row_set_register(row_ret, DRGN_REGISTER_NUMBER(reg),	\
				       &rule))					\
		return &drgn_enomem;						\
} while (0)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/arch_x86_64.c:122

---

{#set_same_value_rule}

### SET_SAME_VALUE_RULE

```cpp
#define SET_SAME_VALUE_RULE(reg) do {						\
	rule.kind = DRGN_CFI_RULE_REGISTER_PLUS_OFFSET;				\
	rule.regno = DRGN_REGISTER_NUMBER(reg);					\
	rule.offset = 0;							\
	if (!drgn_cfi_row_set_register(row_ret, DRGN_REGISTER_NUMBER(reg),	\
				       &rule))					\
		return &drgn_enomem;						\
} while (0)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/arch_x86_64.c:155

---

{#copy_register}

### COPY_REGISTER

```cpp
#define COPY_REGISTER(id, member_name) do {					\
	struct drgn_type_member *member;					\
	uint64_t bit_offset;							\
	err = drgn_type_find_member(frame_obj->type, member_name, &member,	\
				    &bit_offset);				\
	if (err)								\
		goto err;							\
	if (bit_offset / 8 + DRGN_REGISTER_SIZE(id) > frame_size) {		\
		err = drgn_error_create(DRGN_ERROR_OUT_OF_BOUNDS,		\
					"out of bounds of value");		\
		goto err;							\
	}									\
	drgn_register_state_set_from_buffer(regs, id,				\
					    frame_buf + bit_offset / 8);	\
} while (0)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/arch_x86_64.c:408

---

{#simple_drgn_exceptions}

### SIMPLE_DRGN_EXCEPTIONS

```cpp
#define SIMPLE_DRGN_EXCEPTIONS X(DRGN_ERROR_INVALID_ARGUMENT, PyExc_ValueError)		\
	X(DRGN_ERROR_OVERFLOW, PyExc_OverflowError)			\
	X(DRGN_ERROR_RECURSION, PyExc_RecursionError)			\
	X(DRGN_ERROR_MISSING_DEBUG_INFO, MissingDebugInfoError)		\
	X(DRGN_ERROR_SYNTAX, PyExc_SyntaxError)				\
	X(DRGN_ERROR_LOOKUP, PyExc_LookupError)				\
	X(DRGN_ERROR_TYPE, PyExc_TypeError)				\
	X(DRGN_ERROR_ZERO_DIVISION, PyExc_ZeroDivisionError)		\
	X(DRGN_ERROR_OUT_OF_BOUNDS, OutOfBoundsError)			\
	X(DRGN_ERROR_OBJECT_ABSENT, ObjectAbsentError)			\
	X(DRGN_ERROR_NOT_IMPLEMENTED, PyExc_NotImplementedError)	\
	X(DRGN_ERROR_UNSUPPORTED_OPERATION, UnsupportedOperation)	\
	X(DRGN_ERROR_RUNTIME, PyExc_RuntimeError)			\
	X(DRGN_ERROR_BAD_DATA, BadDataError)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/error.c:85

---

{#drgn_error_python}

### DRGN_ERROR_PYTHON

```cpp
#define DRGN_ERROR_PYTHON (-1)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/error.c:101

---

{#x-2}

### X

```cpp
#define X(code, type, code, type) case code:					\
		PyErr_SetString(type, err->_message);	\
		break;
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/error.c:275

---

{#x-2}

### X

```cpp
#define X(code, type, code, type) case code:					\
		PyErr_SetString(type, err->_message);	\
		break;
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/error.c:275

---

{#linux_kernel_get_primitive}

### LINUX_KERNEL_GET_PRIMITIVE

```cpp
#define LINUX_KERNEL_GET_PRIMITIVE(name, primitive_type, signed_unsigned, expr) static struct drgn_error *linux_kernel_get_##name(struct drgn_program *prog,	\
						  struct drgn_object *ret)	\
{										\
	struct drgn_error *err;							\
	struct drgn_qualified_type qualified_type;				\
	err = drgn_program_find_primitive_type(prog, (primitive_type),		\
					       &qualified_type.type);		\
	if (err)								\
		return err;							\
	qualified_type.qualifiers = 0;						\
	return drgn_object_set_##signed_unsigned(ret, qualified_type, (expr),	\
						 0);				\
}
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/linux_kernel.c:170

---

{#linux_kernel_get_primitive_wrapper}

### LINUX_KERNEL_GET_PRIMITIVE_WRAPPER

```cpp
#define LINUX_KERNEL_GET_PRIMITIVE_WRAPPER(name, primitive_type) static struct drgn_error *linux_kernel_get_##name(struct drgn_program *prog,	\
						  struct drgn_object *ret)	\
{										\
	struct drgn_error *err;							\
	typeof(_Generic(&linux_kernel_get_##name##_impl,			\
			struct drgn_error *(*)(struct drgn_program *,		\
					       uint64_t *): (uint64_t)0,	\
			struct drgn_error *(*)(struct drgn_program *,		\
					       int64_t *): (int64_t)0))		\
	value;									\
	err = linux_kernel_get_##name##_impl(prog, &value);			\
	if (err)								\
		return err;							\
	struct drgn_qualified_type qualified_type;				\
	err = drgn_program_find_primitive_type(prog, (primitive_type),		\
					       &qualified_type.type);		\
	if (err)								\
		return err;							\
	qualified_type.qualifiers = 0;						\
	return _Generic(value,							\
			uint64_t: drgn_object_set_unsigned,			\
			int64_t: drgn_object_set_signed)			\
		       (ret, qualified_type, value, 0);				\
}
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/linux_kernel.c:185

---

{#symbol_start_end}

### SYMBOL_START_END

```cpp
#define SYMBOL_START_END(symname_start, symname_end) do { \
		struct drgn_symbol_cleanup_symbol_ *sym_start = NULL; \
		struct drgn_symbol_cleanup_symbol_ *sym_end = NULL; \
		err = drgn_program_find_symbol_by_name(prog, symname_start, &sym_start); \
		if (drgn_error_catch(&err, DRGN_ERROR_LOOKUP)) \
			break; \
		else if (err) \
			return err; \
		err = drgn_program_find_symbol_by_name(prog, symname_end, &sym_end); \
		if (err) \
			return err; \
		prog->thread_size_cached = sym_end->address - sym_start->address; \
		return drgn_object_set_unsigned(ret, qualified_type, \
						prog->thread_size_cached, 0); \
	} while (0)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/linux_kernel.c:275

---

{#kdump_signature}

### KDUMP_SIGNATURE

```cpp
#define KDUMP_SIGNATURE "KDUMP   "
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/linux_kernel.h:44

---

{#kdump_sig_len}

### KDUMP_SIG_LEN

```cpp
#define KDUMP_SIG_LEN (sizeof(KDUMP_SIGNATURE) - 1)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/linux_kernel.h:45

---

{#flattened_signature}

### FLATTENED_SIGNATURE

```cpp
#define FLATTENED_SIGNATURE "makedumpfile\0\0\0"
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/linux_kernel.h:49

---

{#flattened_sig_len}

### FLATTENED_SIG_LEN

```cpp
#define FLATTENED_SIG_LEN sizeof(FLATTENED_SIGNATURE)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/linux_kernel.h:50

---

{#drgn_accessor_linkage-2}

### DRGN_ACCESSOR_LINKAGE

```cpp
#define DRGN_ACCESSOR_LINKAGE static inline
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn_internal.h:18

---

{#x-3}

### X

```cpp
#define X(bits, bits, bits, bits, bits) case DRGN_MEMORY_SEARCH_ITERATOR_MODE_U##bits:				\
		return drgn_memory_search_iterator_next_u##bits(it,		\
								&blocking_state,\
								addr_ret,	\
								match_ret,	\
								match_len_ret);	\
	case DRGN_MEMORY_SEARCH_ITERATOR_MODE_U##bits##_MULTI:			\
		return drgn_memory_search_iterator_next_u##bits##_multi(it,	\
									&blocking_state,\
									addr_ret,\
									match_ret,\
									match_len_ret);
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/memory_reader.c:1399

---

{#x-3}

### X

```cpp
#define X(bits, bits, bits, bits, bits) case DRGN_MEMORY_SEARCH_ITERATOR_MODE_U##bits:				\
		return drgn_memory_search_iterator_next_u##bits(it,		\
								&blocking_state,\
								addr_ret,	\
								match_ret,	\
								match_len_ret);	\
	case DRGN_MEMORY_SEARCH_ITERATOR_MODE_U##bits##_MULTI:			\
		return drgn_memory_search_iterator_next_u##bits##_multi(it,	\
									&blocking_state,\
									addr_ret,\
									match_ret,\
									match_len_ret);
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/memory_reader.c:1399

---

{#x-3}

### X

```cpp
#define X(bits, bits, bits, bits, bits) case DRGN_MEMORY_SEARCH_ITERATOR_MODE_U##bits:				\
		return drgn_memory_search_iterator_next_u##bits(it,		\
								&blocking_state,\
								addr_ret,	\
								match_ret,	\
								match_len_ret);	\
	case DRGN_MEMORY_SEARCH_ITERATOR_MODE_U##bits##_MULTI:			\
		return drgn_memory_search_iterator_next_u##bits##_multi(it,	\
									&blocking_state,\
									addr_ret,\
									match_ret,\
									match_len_ret);
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/memory_reader.c:1399

---

{#x-3}

### X

```cpp
#define X(bits, bits, bits, bits, bits) case DRGN_MEMORY_SEARCH_ITERATOR_MODE_U##bits:				\
		return drgn_memory_search_iterator_next_u##bits(it,		\
								&blocking_state,\
								addr_ret,	\
								match_ret,	\
								match_len_ret);	\
	case DRGN_MEMORY_SEARCH_ITERATOR_MODE_U##bits##_MULTI:			\
		return drgn_memory_search_iterator_next_u##bits##_multi(it,	\
									&blocking_state,\
									addr_ret,\
									match_ret,\
									match_len_ret);
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/memory_reader.c:1399

---

{#x-3}

### X

```cpp
#define X(bits, bits, bits, bits, bits) case DRGN_MEMORY_SEARCH_ITERATOR_MODE_U##bits:				\
		return drgn_memory_search_iterator_next_u##bits(it,		\
								&blocking_state,\
								addr_ret,	\
								match_ret,	\
								match_len_ret);	\
	case DRGN_MEMORY_SEARCH_ITERATOR_MODE_U##bits##_MULTI:			\
		return drgn_memory_search_iterator_next_u##bits##_multi(it,	\
									&blocking_state,\
									addr_ret,\
									match_ret,\
									match_len_ret);
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/memory_reader.c:1399

---

{#x-4}

### X

```cpp
#define X(bits) else if (match_len == sizeof(uint##bits##_t)) {	\
			uint##bits##_t value;			\
			memcpy(&value, match, sizeof(value));	\
			if (bswap)				\
				value = bswap_##bits(value);	\
			tmp = PyLong_FromUInt##bits(value);	\
		}
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/memory_search.c:139

---

{#flags-7}

### FLAGS

```cpp
#define FLAGS X(dereference, DRGN_FORMAT_OBJECT_DEREFERENCE)			\
	X(symbolize, DRGN_FORMAT_OBJECT_SYMBOLIZE)			\
	X(string, DRGN_FORMAT_OBJECT_STRING)				\
	X(char, DRGN_FORMAT_OBJECT_CHAR)				\
	X(type_name, DRGN_FORMAT_OBJECT_TYPE_NAME)			\
	X(member_type_names, DRGN_FORMAT_OBJECT_MEMBER_TYPE_NAMES)	\
	X(element_type_names, DRGN_FORMAT_OBJECT_ELEMENT_TYPE_NAMES)	\
	X(members_same_line, DRGN_FORMAT_OBJECT_MEMBERS_SAME_LINE)	\
	X(elements_same_line, DRGN_FORMAT_OBJECT_ELEMENTS_SAME_LINE)	\
	X(member_names, DRGN_FORMAT_OBJECT_MEMBER_NAMES)		\
	X(element_indices, DRGN_FORMAT_OBJECT_ELEMENT_INDICES)		\
	X(implicit_members, DRGN_FORMAT_OBJECT_IMPLICIT_MEMBERS)	\
	X(implicit_elements, DRGN_FORMAT_OBJECT_IMPLICIT_ELEMENTS)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/object.c:968

---

{#x-5}

### X

```cpp
#define X(name, value, name, value, name, value, name, value) format_object_flag_converter, &name##_arg,
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/object.c:1009

---

{#x-5}

### X

```cpp
#define X(name, value, name, value, name, value, name, value) format_object_flag_converter, &name##_arg,
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/object.c:1009

---

{#x-5}

### X

```cpp
#define X(name, value, name, value, name, value, name, value) format_object_flag_converter, &name##_arg,
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/object.c:1009

---

{#x-5}

### X

```cpp
#define X(name, value, name, value, name, value, name, value) format_object_flag_converter, &name##_arg,
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/object.c:1009

---

{#drgnobject_binary_op}

### DrgnObject_BINARY_OP

```cpp
#define DrgnObject_BINARY_OP(op)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/object.c:1118

---

{#drgnobject_unary_op}

### DrgnObject_UNARY_OP

```cpp
#define DrgnObject_UNARY_OP(op) static DrgnObject *DrgnObject_##op(DrgnObject *self)		\
{								\
	struct drgn_error *err;					\
	_cleanup_pydecref_DrgnObject *res =			\
		DrgnObject_alloc(DrgnObject_prog(self));	\
	if (!res)						\
		return NULL;					\
	err = drgn_object_##op(&res->obj, &self->obj);		\
	if (err)						\
		return set_drgn_error(err);			\
	return_ptr(res);					\
}
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/object.c:1174

---

{#drgnobject_round_method}

### DrgnObject_round_method

```cpp
#define DrgnObject_round_method(func) static PyObject *DrgnObject_##func(DrgnObject *self)			\
{									\
	if (!drgn_type_is_arithmetic(self->obj.type)) {			\
		return set_error_type_name("cannot round '%s'",		\
					   drgn_object_qualified_type(&self->obj));\
	}								\
	if (self->obj.encoding != DRGN_OBJECT_ENCODING_FLOAT)		\
		return DrgnObject_value(self);				\
	union drgn_value value_mem;					\
	const union drgn_value *value;					\
	struct drgn_error *err =					\
		drgn_object_read_value(&self->obj, &value_mem, &value);	\
	if (err)							\
		return set_drgn_error(err);				\
	PyObject *ret = PyLong_FromDouble(func(value->fvalue));		\
	drgn_object_deinit_value(&self->obj, value);			\
	return ret;							\
}
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/object.c:1323

---

{#drgnobject_cast_op}

### DrgnObject_CAST_OP

```cpp
#define DrgnObject_CAST_OP(op) DrgnObject *op(PyObject *self, PyObject *args, PyObject *kwds)			\
{										\
	static char *keywords[] = {"type", "obj", NULL};			\
	struct drgn_error *err;							\
	PyObject *type_obj;							\
	DrgnObject *obj;							\
	if (!PyArg_ParseTupleAndKeywords(args, kwds, "OO!:" #op, keywords,	\
					 &type_obj, &DrgnObject_type, &obj))	\
		return NULL;							\
										\
	struct drgn_qualified_type qualified_type;				\
	if (Program_type_arg(DrgnObject_prog(obj), type_obj, false,		\
			     &qualified_type) == -1)				\
		return NULL;							\
										\
	_cleanup_pydecref_DrgnObject *res =					\
		DrgnObject_alloc(DrgnObject_prog(obj));				\
	if (!res)								\
		return NULL;							\
										\
	err = drgn_object_##op(&res->obj, qualified_type, &obj->obj);		\
	if (err)								\
		return set_drgn_error(err);					\
	return_ptr(res);							\
}
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/object.c:1769

---

{#debug_info_finder_arg}

### debug_info_finder_arg

```cpp
#define debug_info_finder_arg(self, fn) PyObject *arg = fn;
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/program.c:721

---

{#type_finder_arg}

### type_finder_arg

```cpp
#define type_finder_arg(self, fn) _cleanup_pydecref_ PyObject *arg = Py_BuildValue("OO", self, fn);	\
	if (!arg)								\
		return NULL;
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/program.c:722

---

{#object_finder_arg}

### object_finder_arg

```cpp
#define object_finder_arg(self, fn) PyObject *arg = fn;
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/program.c:726

---

{#symbol_finder_arg}

### symbol_finder_arg

```cpp
#define symbol_finder_arg type_finder_arg
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/program.c:727

---

{#define_program_finder_methods}

### DEFINE_PROGRAM_FINDER_METHODS

```cpp
#define DEFINE_PROGRAM_FINDER_METHODS(which)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/program.c:729

---

{#method_read}

### METHOD_READ

```cpp
#define METHOD_READ(x, type) static PyObject *Program_read_##x(Program *self, PyObject *args,		\
				  PyObject *kwds)				\
{										\
	static char *keywords[] = {"address", "physical", NULL};		\
	struct drgn_error *err;							\
	struct index_arg address = {};						\
	int physical = 0;							\
	type tmp;								\
										\
	if (!PyArg_ParseTupleAndKeywords(args, kwds, "O&|p:read_"#x, keywords,	\
					 index_converter, &address, &physical))	\
	    return NULL;							\
										\
	err = drgn_program_read_##x(&self->prog, address.uvalue, physical,	\
				    &tmp);					\
	if (err)								\
		return set_drgn_error(err);					\
	if (sizeof(tmp) <= sizeof(unsigned long))				\
		return PyLong_FromUnsignedLong(tmp);				\
	else									\
		return PyLong_FromUnsignedLongLong(tmp);			\
}
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/program.c:1550

---

{#x-6}

### X

```cpp
#define X(bits, bits) {"search_memory_u" #bits, (PyCFunction)Program_search_memory_u##bits,	\
	 METH_VARARGS | METH_KEYWORDS,						\
	 drgn_Program_search_memory_u##bits##_DOC},
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/program.c:2351

---

{#program_finder_method_defs}

### PROGRAM_FINDER_METHOD_DEFS

```cpp
#define PROGRAM_FINDER_METHOD_DEFS(which) {"register_" #which "_finder",						\
	 (PyCFunction)Program_register_##which##_finder,			\
	 METH_VARARGS | METH_KEYWORDS,						\
	 drgn_Program_register_##which##_finder_DOC},				\
	{"registered_" #which "_finders",					\
	 (PyCFunction)Program_registered_##which##_finders, METH_NOARGS,	\
	 drgn_Program_registered_##which##_finders_DOC},			\
	{"set_enabled_" #which "_finders",					\
	 (PyCFunction)Program_set_enabled_##which##_finders,			\
	 METH_VARARGS | METH_KEYWORDS,						\
	 drgn_Program_set_enabled_##which##_finders_DOC},			\
	{"enabled_" #which "_finders",						\
	 (PyCFunction)Program_enabled_##which##_finders, METH_NOARGS,		\
	 drgn_Program_enabled_##which##_finders_DOC}
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/program.c:2262

---

{#method_def_read}

### METHOD_DEF_READ

```cpp
#define METHOD_DEF_READ(x) {"read_"#x, (PyCFunction)Program_read_##x,			\
	 METH_VARARGS | METH_KEYWORDS, drgn_Program_read_##x##_DOC}
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/program.c:2340

---

{#x-6}

### X

```cpp
#define X(bits, bits) {"search_memory_u" #bits, (PyCFunction)Program_search_memory_u##bits,	\
	 METH_VARARGS | METH_KEYWORDS,						\
	 drgn_Program_search_memory_u##bits##_DOC},
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/program.c:2351

---

{#typekindset_or_op}

### TypeKindSet_OR_OP

```cpp
#define TypeKindSet_OR_OP(name, op) static PyObject *TypeKindSet_##name(PyObject *left, PyObject *right)		\
{										\
	/* Both operands must only contain TypeKind elements. */		\
	uint64_t left_kinds;							\
	int left_r = TypeKindSet_mask_from_iterable(left, &left_kinds);		\
	if (left_r < 0)								\
		return NULL;							\
	if (left_r > 0)								\
		Py_RETURN_NOTIMPLEMENTED;					\
										\
	uint64_t right_kinds;							\
	int right_r = TypeKindSet_mask_from_iterable(right, &right_kinds);	\
	if (right_r < 0)							\
		return NULL;							\
	if (right_r > 0)							\
		Py_RETURN_NOTIMPLEMENTED;					\
										\
	return TypeKindSet_wrap(left_kinds op right_kinds);			\
}
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/type_kind_set.c:264

---

{#drgn_register_state_known_bitset}

### drgn_register_state_known_bitset

```cpp
#define drgn_register_state_known_bitset(regs) ({	\
	__auto_type _state = (regs);			\
	&_state->buf[_state->regs_size];		\
})
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/register_state.c:8

---

{#x-7}

### X

```cpp
#define X(name, _) if (value == name) return #name;
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_constants.c:9

---

{#x-8}

### X

```cpp
#define X(name, value) name = value,
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_constants.h:22

---

{#dw_access_definitions}

### DW_ACCESS_DEFINITIONS

```cpp
#define DW_ACCESS_DEFINITIONS X(DW_ACCESS_public, 0x1) \
	X(DW_ACCESS_protected, 0x2) \
	X(DW_ACCESS_private, 0x3)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_constants.h:24

---

{#dw_addr_definitions}

### DW_ADDR_DEFINITIONS

```cpp
#define DW_ADDR_DEFINITIONS X(DW_ADDR_none, 0x0) \
	X(DW_ADDR_TI_PTR8, 0x8) \
	X(DW_ADDR_TI_PTR16, 0x10) \
	X(DW_ADDR_TI_PTR22, 0x16) \
	X(DW_ADDR_TI_PTR23, 0x17) \
	X(DW_ADDR_TI_PTR24, 0x18) \
	X(DW_ADDR_TI_PTR32, 0x20)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_constants.h:30

---

{#dw_at_definitions}

### DW_AT_DEFINITIONS

```cpp
#define DW_AT_DEFINITIONS
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_constants.h:40

---

{#dw_ate_definitions}

### DW_ATE_DEFINITIONS

```cpp
#define DW_ATE_DEFINITIONS
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_constants.h:374

---

{#dw_cc_definitions}

### DW_CC_DEFINITIONS

```cpp
#define DW_CC_DEFINITIONS
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_constants.h:417

---

{#dw_cfa_definitions}

### DW_CFA_DEFINITIONS

```cpp
#define DW_CFA_DEFINITIONS
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_constants.h:453

---

{#dw_children_definitions}

### DW_CHILDREN_DEFINITIONS

```cpp
#define DW_CHILDREN_DEFINITIONS X(DW_CHILDREN_no, 0x0) \
	X(DW_CHILDREN_yes, 0x1)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_constants.h:494

---

{#dw_defaulted_definitions}

### DW_DEFAULTED_DEFINITIONS

```cpp
#define DW_DEFAULTED_DEFINITIONS X(DW_DEFAULTED_no, 0x0) \
	X(DW_DEFAULTED_in_class, 0x1) \
	X(DW_DEFAULTED_out_of_class, 0x2)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_constants.h:499

---

{#dw_ds_definitions}

### DW_DS_DEFINITIONS

```cpp
#define DW_DS_DEFINITIONS X(DW_DS_unsigned, 0x1) \
	X(DW_DS_leading_overpunch, 0x2) \
	X(DW_DS_trailing_overpunch, 0x3) \
	X(DW_DS_leading_separate, 0x4) \
	X(DW_DS_trailing_separate, 0x5)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_constants.h:505

---

{#dw_dsc_definitions}

### DW_DSC_DEFINITIONS

```cpp
#define DW_DSC_DEFINITIONS X(DW_DSC_label, 0x0) \
	X(DW_DSC_range, 0x1)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_constants.h:513

---

{#dw_eh_pe_definitions}

### DW_EH_PE_DEFINITIONS

```cpp
#define DW_EH_PE_DEFINITIONS X(DW_EH_PE_absptr, 0x0) \
	X(DW_EH_PE_uleb128, 0x1) \
	X(DW_EH_PE_udata2, 0x2) \
	X(DW_EH_PE_udata4, 0x3) \
	X(DW_EH_PE_udata8, 0x4) \
	X(DW_EH_PE_sleb128, 0x9) \
	X(DW_EH_PE_sdata2, 0xa) \
	X(DW_EH_PE_sdata4, 0xb) \
	X(DW_EH_PE_sdata8, 0xc) \
	X(DW_EH_PE_signed, 0x8) \
	X(DW_EH_PE_pcrel, 0x10) \
	X(DW_EH_PE_textrel, 0x20) \
	X(DW_EH_PE_datarel, 0x30) \
	X(DW_EH_PE_funcrel, 0x40) \
	X(DW_EH_PE_aligned, 0x50) \
	X(DW_EH_PE_indirect, 0x80) \
	X(DW_EH_PE_omit, 0xff)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_constants.h:518

---

{#dw_end_definitions}

### DW_END_DEFINITIONS

```cpp
#define DW_END_DEFINITIONS X(DW_END_default, 0x0) \
	X(DW_END_big, 0x1) \
	X(DW_END_little, 0x2) \
	X(DW_END_lo_user, 0x40) \
	X(DW_END_hi_user, 0xff)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_constants.h:538

---

{#dw_form_definitions}

### DW_FORM_DEFINITIONS

```cpp
#define DW_FORM_DEFINITIONS
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_constants.h:546

---

{#dw_id_definitions}

### DW_ID_DEFINITIONS

```cpp
#define DW_ID_DEFINITIONS X(DW_ID_case_sensitive, 0x0) \
	X(DW_ID_up_case, 0x1) \
	X(DW_ID_down_case, 0x2) \
	X(DW_ID_case_insensitive, 0x3)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_constants.h:597

---

{#dw_idx_definitions}

### DW_IDX_DEFINITIONS

```cpp
#define DW_IDX_DEFINITIONS X(DW_IDX_compile_unit, 0x1) \
	X(DW_IDX_type_unit, 0x2) \
	X(DW_IDX_die_offset, 0x3) \
	X(DW_IDX_parent, 0x4) \
	X(DW_IDX_type_hash, 0x5) \
	X(DW_IDX_GNU_internal, 0x2000) \
	X(DW_IDX_lo_user, 0x2000) \
	X(DW_IDX_GNU_external, 0x2001) \
	X(DW_IDX_GNU_main, 0x2002) \
	X(DW_IDX_GNU_language, 0x2003) \
	X(DW_IDX_GNU_linkage_name, 0x2004) \
	X(DW_IDX_hi_user, 0x3fff)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_constants.h:604

---

{#dw_inl_definitions}

### DW_INL_DEFINITIONS

```cpp
#define DW_INL_DEFINITIONS X(DW_INL_not_inlined, 0x0) \
	X(DW_INL_inlined, 0x1) \
	X(DW_INL_declared_not_inlined, 0x2) \
	X(DW_INL_declared_inlined, 0x3)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_constants.h:619

---

{#dw_lang_definitions}

### DW_LANG_DEFINITIONS

```cpp
#define DW_LANG_DEFINITIONS
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_constants.h:626

---

{#dw_lle_definitions}

### DW_LLE_DEFINITIONS

```cpp
#define DW_LLE_DEFINITIONS X(DW_LLE_end_of_list, 0x0) \
	X(DW_LLE_base_addressx, 0x1) \
	X(DW_LLE_startx_endx, 0x2) \
	X(DW_LLE_startx_length, 0x3) \
	X(DW_LLE_offset_pair, 0x4) \
	X(DW_LLE_default_location, 0x5) \
	X(DW_LLE_base_address, 0x6) \
	X(DW_LLE_start_end, 0x7) \
	X(DW_LLE_start_length, 0x8)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_constants.h:696

---

{#dw_lnct_definitions}

### DW_LNCT_DEFINITIONS

```cpp
#define DW_LNCT_DEFINITIONS X(DW_LNCT_path, 0x1) \
	X(DW_LNCT_directory_index, 0x2) \
	X(DW_LNCT_timestamp, 0x3) \
	X(DW_LNCT_size, 0x4) \
	X(DW_LNCT_MD5, 0x5) \
	X(DW_LNCT_GNU_subprogram_name, 0x6) \
	X(DW_LNCT_GNU_decl_file, 0x7) \
	X(DW_LNCT_GNU_decl_line, 0x8) \
	X(DW_LNCT_lo_user, 0x2000) \
	X(DW_LNCT_LLVM_source, 0x2001) \
	X(DW_LNCT_LLVM_is_MD5, 0x2002) \
	X(DW_LNCT_hi_user, 0x3fff)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_constants.h:708

---

{#dw_lne_definitions}

### DW_LNE_DEFINITIONS

```cpp
#define DW_LNE_DEFINITIONS X(DW_LNE_end_sequence, 0x1) \
	X(DW_LNE_set_address, 0x2) \
	X(DW_LNE_define_file, 0x3) \
	X(DW_LNE_set_discriminator, 0x4) \
	X(DW_LNE_HP_negate_is_UV_update, 0x11) \
	X(DW_LNE_HP_push_context, 0x12) \
	X(DW_LNE_HP_pop_context, 0x13) \
	X(DW_LNE_HP_set_file_line_column, 0x14) \
	X(DW_LNE_HP_set_routine_name, 0x15) \
	X(DW_LNE_HP_set_sequence, 0x16) \
	X(DW_LNE_HP_negate_post_semantics, 0x17) \
	X(DW_LNE_HP_negate_function_exit, 0x18) \
	X(DW_LNE_HP_negate_front_end_logical, 0x19) \
	X(DW_LNE_HP_define_proc, 0x20) \
	X(DW_LNE_HP_source_file_correlation, 0x80) \
	X(DW_LNE_lo_user, 0x80) \
	X(DW_LNE_hi_user, 0xff)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_constants.h:723

---

{#dw_lns_definitions}

### DW_LNS_DEFINITIONS

```cpp
#define DW_LNS_DEFINITIONS X(DW_LNS_copy, 0x1) \
	X(DW_LNS_advance_pc, 0x2) \
	X(DW_LNS_advance_line, 0x3) \
	X(DW_LNS_set_file, 0x4) \
	X(DW_LNS_set_column, 0x5) \
	X(DW_LNS_negate_stmt, 0x6) \
	X(DW_LNS_set_basic_block, 0x7) \
	X(DW_LNS_const_add_pc, 0x8) \
	X(DW_LNS_fixed_advance_pc, 0x9) \
	X(DW_LNS_set_prologue_end, 0xa) \
	X(DW_LNS_set_epilogue_begin, 0xb) \
	X(DW_LNS_set_isa, 0xc) \
	X(DW_LNS_set_address_from_logical, 0xd) \
	X(DW_LNS_set_subprogram, 0xd) \
	X(DW_LNS_inlined_call, 0xe) \
	X(DW_LNS_pop_context, 0xf)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_constants.h:743

---

{#dw_macinfo_definitions}

### DW_MACINFO_DEFINITIONS

```cpp
#define DW_MACINFO_DEFINITIONS X(DW_MACINFO_define, 0x1) \
	X(DW_MACINFO_undef, 0x2) \
	X(DW_MACINFO_start_file, 0x3) \
	X(DW_MACINFO_end_file, 0x4) \
	X(DW_MACINFO_vendor_ext, 0xff)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_constants.h:762

---

{#dw_macro_definitions}

### DW_MACRO_DEFINITIONS

```cpp
#define DW_MACRO_DEFINITIONS X(DW_MACRO_define, 0x1) \
	X(DW_MACRO_undef, 0x2) \
	X(DW_MACRO_start_file, 0x3) \
	X(DW_MACRO_end_file, 0x4) \
	X(DW_MACRO_define_strp, 0x5) \
	X(DW_MACRO_undef_strp, 0x6) \
	X(DW_MACRO_import, 0x7) \
	X(DW_MACRO_define_sup, 0x8) \
	X(DW_MACRO_undef_sup, 0x9) \
	X(DW_MACRO_import_sup, 0xa) \
	X(DW_MACRO_define_strx, 0xb) \
	X(DW_MACRO_undef_strx, 0xc) \
	X(DW_MACRO_lo_user, 0xe0) \
	X(DW_MACRO_hi_user, 0xff)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_constants.h:770

---

{#dw_op_definitions}

### DW_OP_DEFINITIONS

```cpp
#define DW_OP_DEFINITIONS
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_constants.h:787

---

{#dw_op_str_unknown_format}

### DW_OP_STR_UNKNOWN_FORMAT

```cpp
#define DW_OP_STR_UNKNOWN_FORMAT "DW_OP_<0x%x>"
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_constants.h:993

---

{#dw_op_str_buf_len}

### DW_OP_STR_BUF_LEN

```cpp
#define DW_OP_STR_BUF_LEN (sizeof(DW_OP_STR_UNKNOWN_FORMAT) - 2 + 2 * sizeof(int))
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_constants.h:994

---

{#dw_ord_definitions}

### DW_ORD_DEFINITIONS

```cpp
#define DW_ORD_DEFINITIONS X(DW_ORD_row_major, 0x0) \
	X(DW_ORD_col_major, 0x1)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_constants.h:1003

---

{#dw_rle_definitions}

### DW_RLE_DEFINITIONS

```cpp
#define DW_RLE_DEFINITIONS X(DW_RLE_end_of_list, 0x0) \
	X(DW_RLE_base_addressx, 0x1) \
	X(DW_RLE_startx_endx, 0x2) \
	X(DW_RLE_startx_length, 0x3) \
	X(DW_RLE_offset_pair, 0x4) \
	X(DW_RLE_base_address, 0x5) \
	X(DW_RLE_start_end, 0x6) \
	X(DW_RLE_start_length, 0x7)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_constants.h:1008

---

{#dw_sect_definitions}

### DW_SECT_DEFINITIONS

```cpp
#define DW_SECT_DEFINITIONS X(DW_SECT_INFO, 0x1) \
	X(DW_SECT_TYPES, 0x2) \
	X(DW_SECT_ABBREV, 0x3) \
	X(DW_SECT_LINE, 0x4) \
	X(DW_SECT_LOCLISTS, 0x5) \
	X(DW_SECT_STR_OFFSETS, 0x6) \
	X(DW_SECT_MACRO, 0x7) \
	X(DW_SECT_RNGLISTS, 0x8)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_constants.h:1019

---

{#dw_tag_definitions}

### DW_TAG_DEFINITIONS

```cpp
#define DW_TAG_DEFINITIONS
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_constants.h:1030

---

{#dw_tag_str_unknown_format}

### DW_TAG_STR_UNKNOWN_FORMAT

```cpp
#define DW_TAG_STR_UNKNOWN_FORMAT "DW_TAG_<0x%x>"
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_constants.h:1154

---

{#dw_tag_str_buf_len}

### DW_TAG_STR_BUF_LEN

```cpp
#define DW_TAG_STR_BUF_LEN (sizeof(DW_TAG_STR_UNKNOWN_FORMAT) - 2 + 2 * sizeof(int))
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_constants.h:1155

---

{#dw_ut_definitions}

### DW_UT_DEFINITIONS

```cpp
#define DW_UT_DEFINITIONS X(DW_UT_compile, 0x1) \
	X(DW_UT_type, 0x2) \
	X(DW_UT_partial, 0x3) \
	X(DW_UT_skeleton, 0x4) \
	X(DW_UT_split_compile, 0x5) \
	X(DW_UT_split_type, 0x6) \
	X(DW_UT_lo_user, 0x80) \
	X(DW_UT_hi_user, 0xff)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_constants.h:1164

---

{#dw_virtuality_definitions}

### DW_VIRTUALITY_DEFINITIONS

```cpp
#define DW_VIRTUALITY_DEFINITIONS X(DW_VIRTUALITY_none, 0x0) \
	X(DW_VIRTUALITY_virtual, 0x1) \
	X(DW_VIRTUALITY_pure_virtual, 0x2)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_constants.h:1175

---

{#dw_vis_definitions}

### DW_VIS_DEFINITIONS

```cpp
#define DW_VIS_DEFINITIONS X(DW_VIS_local, 0x1) \
	X(DW_VIS_exported, 0x2) \
	X(DW_VIS_qualified, 0x3)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_constants.h:1181

---

{#list_option}

### LIST_OPTION

```cpp
#define LIST_OPTION(name, name, name, name, name, name) if (!drgn_format_debug_info_options_list(&sb, #name, &first,	\
						 options->name,		\
						 drgn_debug_info_options_default_##name))\
		return NULL;
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info_options.c:308

---

{#bool_option}

### BOOL_OPTION

```cpp
#define BOOL_OPTION(name, default_value, name, default_value, name, default_value, name, default_value, name, default_value, name, default_value) if (!drgn_format_debug_info_options_bool(&sb, #name, &first,		\
						 options->name, default_value))	\
		return NULL;
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info_options.c:313

---

{#enum_option}

### ENUM_OPTION

```cpp
#define ENUM_OPTION(name, type, default_value, name, type, default_value, name, type, default_value, name, type, default_value, name, type, default_value, name, type, default_value) if (!type##_format(&sb, #name, &first, options->name, default_value))	\
		return NULL;
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info_options.c:317

---

{#list_option}

### LIST_OPTION

```cpp
#define LIST_OPTION(name, name, name, name, name, name) if (!drgn_format_debug_info_options_list(&sb, #name, &first,	\
						 options->name,		\
						 drgn_debug_info_options_default_##name))\
		return NULL;
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info_options.c:308

---

{#bool_option}

### BOOL_OPTION

```cpp
#define BOOL_OPTION(name, default_value, name, default_value, name, default_value, name, default_value, name, default_value, name, default_value) if (!drgn_format_debug_info_options_bool(&sb, #name, &first,		\
						 options->name, default_value))	\
		return NULL;
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info_options.c:313

---

{#enum_option}

### ENUM_OPTION

```cpp
#define ENUM_OPTION(name, type, default_value, name, type, default_value, name, type, default_value, name, type, default_value, name, type, default_value, name, type, default_value) if (!type##_format(&sb, #name, &first, options->name, default_value))	\
		return NULL;
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info_options.c:317

---

{#list_option}

### LIST_OPTION

```cpp
#define LIST_OPTION(name, name, name, name, name, name) if (!drgn_format_debug_info_options_list(&sb, #name, &first,	\
						 options->name,		\
						 drgn_debug_info_options_default_##name))\
		return NULL;
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info_options.c:308

---

{#bool_option}

### BOOL_OPTION

```cpp
#define BOOL_OPTION(name, default_value, name, default_value, name, default_value, name, default_value, name, default_value, name, default_value) if (!drgn_format_debug_info_options_bool(&sb, #name, &first,		\
						 options->name, default_value))	\
		return NULL;
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info_options.c:313

---

{#enum_option}

### ENUM_OPTION

```cpp
#define ENUM_OPTION(name, type, default_value, name, type, default_value, name, type, default_value, name, type, default_value, name, type, default_value, name, type, default_value) if (!type##_format(&sb, #name, &first, options->name, default_value))	\
		return NULL;
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info_options.c:317

---

{#list_option}

### LIST_OPTION

```cpp
#define LIST_OPTION(name, name, name, name, name, name) if (!drgn_format_debug_info_options_list(&sb, #name, &first,	\
						 options->name,		\
						 drgn_debug_info_options_default_##name))\
		return NULL;
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info_options.c:308

---

{#bool_option}

### BOOL_OPTION

```cpp
#define BOOL_OPTION(name, default_value, name, default_value, name, default_value, name, default_value, name, default_value, name, default_value) if (!drgn_format_debug_info_options_bool(&sb, #name, &first,		\
						 options->name, default_value))	\
		return NULL;
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info_options.c:313

---

{#enum_option}

### ENUM_OPTION

```cpp
#define ENUM_OPTION(name, type, default_value, name, type, default_value, name, type, default_value, name, type, default_value, name, type, default_value, name, type, default_value) if (!type##_format(&sb, #name, &first, options->name, default_value))	\
		return NULL;
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info_options.c:317

---

{#drgn_debug_info_options_get}

### DRGN_DEBUG_INFO_OPTIONS_GET

```cpp
#define DRGN_DEBUG_INFO_OPTIONS_GET(type, name) LIBDRGN_PUBLIC type								\
drgn_debug_info_options_get_##name(const struct drgn_debug_info_options *options)\
{										\
	return options->name;							\
}
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info_options.c:161

---

{#drgn_debug_info_options_getset}

### DRGN_DEBUG_INFO_OPTIONS_GETSET

```cpp
#define DRGN_DEBUG_INFO_OPTIONS_GETSET(type, name) DRGN_DEBUG_INFO_OPTIONS_GET(type, name)						\
										\
LIBDRGN_PUBLIC void								\
drgn_debug_info_options_set_##name(struct drgn_debug_info_options *options,	\
				   type value)					\
{										\
	options->name = value;							\
}
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info_options.c:168

---

{#list_option}

### LIST_OPTION

```cpp
#define LIST_OPTION(name, name, name, name, name, name) if (!drgn_format_debug_info_options_list(&sb, #name, &first,	\
						 options->name,		\
						 drgn_debug_info_options_default_##name))\
		return NULL;
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info_options.c:308

---

{#bool_option}

### BOOL_OPTION

```cpp
#define BOOL_OPTION(name, default_value, name, default_value, name, default_value, name, default_value, name, default_value, name, default_value) if (!drgn_format_debug_info_options_bool(&sb, #name, &first,		\
						 options->name, default_value))	\
		return NULL;
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info_options.c:313

---

{#enum_option}

### ENUM_OPTION

```cpp
#define ENUM_OPTION(name, type, default_value, name, type, default_value, name, type, default_value, name, type, default_value, name, type, default_value, name, type, default_value) if (!type##_format(&sb, #name, &first, options->name, default_value))	\
		return NULL;
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info_options.c:317

---

{#list_option}

### LIST_OPTION

```cpp
#define LIST_OPTION(name, name, name, name, name, name) if (!drgn_format_debug_info_options_list(&sb, #name, &first,	\
						 options->name,		\
						 drgn_debug_info_options_default_##name))\
		return NULL;
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info_options.c:308

---

{#bool_option}

### BOOL_OPTION

```cpp
#define BOOL_OPTION(name, default_value, name, default_value, name, default_value, name, default_value, name, default_value, name, default_value) if (!drgn_format_debug_info_options_bool(&sb, #name, &first,		\
						 options->name, default_value))	\
		return NULL;
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info_options.c:313

---

{#enum_option}

### ENUM_OPTION

```cpp
#define ENUM_OPTION(name, type, default_value, name, type, default_value, name, type, default_value, name, type, default_value, name, type, default_value, name, type, default_value) if (!type##_format(&sb, #name, &first, options->name, default_value))	\
		return NULL;
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info_options.c:317

---

{#drgn_debug_info_options-1}

### DRGN_DEBUG_INFO_OPTIONS

```cpp
#define DRGN_DEBUG_INFO_OPTIONS LIST_OPTION(directories)			\
	BOOL_OPTION(try_module_name, true)		\
	BOOL_OPTION(try_build_id, true)			\
	LIST_OPTION(debug_link_directories)		\
	BOOL_OPTION(try_debug_link, true)		\
	BOOL_OPTION(try_procfs, true)			\
	BOOL_OPTION(try_embedded_vdso, true)		\
	BOOL_OPTION(try_reuse, true)			\
	BOOL_OPTION(try_supplementary, true)		\
	LIST_OPTION(kernel_directories)			\
	ENUM_OPTION(try_kmod, drgn_kmod_search_method,	\
		    DRGN_KMOD_SEARCH_DEPMOD_OR_WALK)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info_options.h:10

---

{#list_option-1}

### LIST_OPTION

```cpp
#define LIST_OPTION(name) const char * const *name;
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info_options.h:25

---

{#bool_option-1}

### BOOL_OPTION

```cpp
#define BOOL_OPTION(name, default_value) bool name;
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info_options.h:26

---

{#enum_option-1}

### ENUM_OPTION

```cpp
#define ENUM_OPTION(name, type, default_value) enum type name;
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info_options.h:27

---

{#is_node}

### is_node

```cpp
#define is_node(entry_value) (((entry_value) & 3) == internal_flag && (entry_value) >= node_min)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/linux_kernel_helpers.c:467

---

{#format-4}

### FORMAT

```cpp
#define FORMAT "numbers[%" PRIu64 "].pid_chain"
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/linux_kernel_helpers.c:795

---

{#pid_links_format}

### PID_LINKS_FORMAT

```cpp
#define PID_LINKS_FORMAT "pid_links[%" PRIu64 "]"
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/linux_kernel_helpers.c:896

---

{#pids_node_format}

### PIDS_NODE_FORMAT

```cpp
#define PIDS_NODE_FORMAT "pids[%" PRIu64 "].node"
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/linux_kernel_helpers.c:897

---

{#_cleanup_json_object_}

### _cleanup_json_object_

```cpp
#define _cleanup_json_object_ _cleanup_(json_object_putp)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/qemu_machine_protocol.c:41

---

{#qmp_cmd_no_args}

### QMP_CMD_NO_ARGS

```cpp
#define QMP_CMD_NO_ARGS(cmd) "{\"execute\":\"" cmd "\"}\r\n"
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/qemu_machine_protocol.c:164

---

{#qmp_execute_no_args}

### QMP_EXECUTE_NO_ARGS

```cpp
#define QMP_EXECUTE_NO_ARGS(conn, cmd, ret) qmp_execute_str(conn, QMP_CMD_NO_ARGS(cmd), sizeof(QMP_CMD_NO_ARGS(cmd)) - 1, ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/qemu_machine_protocol.c:165

---

{#debuginfooptions_setter}

### DebugInfoOptions_SETTER

```cpp
#define DebugInfoOptions_SETTER(name) static int DebugInfoOptions_set_##name(DebugInfoOptions *self, PyObject *value,	\
				       void *arg)				\
{										\
	SETTER_NO_DELETE(#name, value);						\
	if (!DebugInfoOptions_##name##_converter(value, self->options))		\
		return -1;							\
	return 0;								\
}
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/debug_info_options.c:26

---

{#list_option-2}

### LIST_OPTION

```cpp
#define LIST_OPTION(name, name, name, name, name) {#name, (getter)DebugInfoOptions_get_##name,	\
	 (setter)DebugInfoOptions_set_##name,		\
	 drgn_DebugInfoOptions_##name##_DOC},
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/debug_info_options.c:196

---

{#bool_option-2}

### BOOL_OPTION

```cpp
#define BOOL_OPTION(name, default_value, name, default_value, name, default_value) LIST_OPTION(name)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/debug_info_options.c:200

---

{#drgn_kmod_search_method_class}

### drgn_kmod_search_method_class

```cpp
#define drgn_kmod_search_method_class KmodSearchMethod_class
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/debug_info_options.c:75

---

{#enum_option-2}

### ENUM_OPTION

```cpp
#define ENUM_OPTION(name, type, default_value, name, type, default_value, name, type, default_value) LIST_OPTION(name)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/debug_info_options.c:201

---

{#bool_option-2}

### BOOL_OPTION

```cpp
#define BOOL_OPTION(name, default_value, name, default_value, name, default_value) LIST_OPTION(name)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/debug_info_options.c:200

---

{#enum_option-2}

### ENUM_OPTION

```cpp
#define ENUM_OPTION(name, type, default_value, name, type, default_value, name, type, default_value) LIST_OPTION(name)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/debug_info_options.c:201

---

{#list_option-2}

### LIST_OPTION

```cpp
#define LIST_OPTION(name, name, name, name, name) {#name, (getter)DebugInfoOptions_get_##name,	\
	 (setter)DebugInfoOptions_set_##name,		\
	 drgn_DebugInfoOptions_##name##_DOC},
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/debug_info_options.c:196

---

{#list_option-2}

### LIST_OPTION

```cpp
#define LIST_OPTION(name, name, name, name, name) {#name, (getter)DebugInfoOptions_get_##name,	\
	 (setter)DebugInfoOptions_set_##name,		\
	 drgn_DebugInfoOptions_##name##_DOC},
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/debug_info_options.c:196

---

{#list_option-2}

### LIST_OPTION

```cpp
#define LIST_OPTION(name, name, name, name, name) {#name, (getter)DebugInfoOptions_get_##name,	\
	 (setter)DebugInfoOptions_set_##name,		\
	 drgn_DebugInfoOptions_##name##_DOC},
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/debug_info_options.c:196

---

{#list_option-2}

### LIST_OPTION

```cpp
#define LIST_OPTION(name, name, name, name, name) {#name, (getter)DebugInfoOptions_get_##name,	\
	 (setter)DebugInfoOptions_set_##name,		\
	 drgn_DebugInfoOptions_##name##_DOC},
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/debug_info_options.c:196

---

{#bool_option-2}

### BOOL_OPTION

```cpp
#define BOOL_OPTION(name, default_value, name, default_value, name, default_value) LIST_OPTION(name)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/debug_info_options.c:200

---

{#enum_option-2}

### ENUM_OPTION

```cpp
#define ENUM_OPTION(name, type, default_value, name, type, default_value, name, type, default_value) LIST_OPTION(name)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/debug_info_options.c:201

## Enumerations

---

{#unknown-17}

### 

```cpp
enum 
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/orc.h:58

| Value | Description |
|-------|-------------|
| `DRGN_ORC_TYPE_UNDEFINED` |  |
| `DRGN_ORC_TYPE_END_OF_STACK` |  |
| `DRGN_ORC_TYPE_CALL` |  |
| `DRGN_ORC_TYPE_REGS` |  |
| `DRGN_ORC_TYPE_REGS_PARTIAL` |  |

---

{#unknown-18}

### 

```cpp
enum 
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/orc.h:68

| Value | Description |
|-------|-------------|
| `DRGN_ORC_REG_UNDEFINED` |  |
| `DRGN_ORC_REG_AX` |  |
| `DRGN_ORC_REG_DX` |  |
| `DRGN_ORC_REG_SP` |  |
| `DRGN_ORC_REG_BP` |  |
| `DRGN_ORC_REG_DI` |  |
| `DRGN_ORC_REG_R10` |  |
| `DRGN_ORC_REG_R13` |  |
| `DRGN_ORC_REG_PREV_SP` |  |
| `DRGN_ORC_REG_SP_INDIRECT` |  |
| `DRGN_ORC_REG_BP_INDIRECT` |  |

---

{#unknown-19}

### 

```cpp
enum 
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/c_lexer.h:14

| Value | Description |
|-------|-------------|
| `C_TOKEN_EOF` |  |
| `MIN_KEYWORD_TOKEN` |  |
| `MIN_SPECIFIER_TOKEN` |  |
| `C_TOKEN_VOID` |  |
| `C_TOKEN_CHAR` |  |
| `C_TOKEN_SHORT` |  |
| `C_TOKEN_INT` |  |
| `C_TOKEN_LONG` |  |
| `C_TOKEN_SIGNED` |  |
| `C_TOKEN_UNSIGNED` |  |
| `C_TOKEN_BOOL` |  |
| `C_TOKEN_FLOAT` |  |
| `C_TOKEN_DOUBLE` |  |
| `MAX_SPECIFIER_TOKEN` |  |
| `MIN_QUALIFIER_TOKEN` |  |
| `C_TOKEN_CONST` |  |
| `C_TOKEN_RESTRICT` |  |
| `C_TOKEN_VOLATILE` |  |
| `C_TOKEN_ATOMIC` |  |
| `MAX_QUALIFIER_TOKEN` |  |
| `C_TOKEN_STRUCT` |  |
| `C_TOKEN_UNION` |  |
| `C_TOKEN_CLASS` |  |
| `C_TOKEN_ENUM` |  |
| `MAX_KEYWORD_TOKEN` |  |
| `C_TOKEN_LPAREN` |  |
| `C_TOKEN_RPAREN` |  |
| `C_TOKEN_LBRACKET` |  |
| `C_TOKEN_RBRACKET` |  |
| `C_TOKEN_ASTERISK` |  |
| `C_TOKEN_DOT` |  |
| `C_TOKEN_NUMBER` |  |
| `C_TOKEN_IDENTIFIER` |  |
| `C_TOKEN_TEMPLATE_ARGUMENTS` |  |
| `C_TOKEN_COLON` |  |

---

{#drgn_dwarf_file_type}

### drgn_dwarf_file_type

```cpp
enum drgn_dwarf_file_type
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/elf_file.c:38

| Value | Description |
|-------|-------------|
| `DRGN_DWARF_FILE_NONE` |  |
| `DRGN_DWARF_FILE_GNU_LTO` |  |
| `DRGN_DWARF_FILE_DWO` |  |
| `DRGN_DWARF_FILE_PLAIN` |  |

---

{#unknown-20}

### 

```cpp
enum 
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.c:3472

| Value | Description |
|-------|-------------|
| `USERSPACE_LOADED_MODULE_ITERATOR_STATE_MAIN` |  |
| `USERSPACE_LOADED_MODULE_ITERATOR_STATE_VDSO` |  |
| `USERSPACE_LOADED_MODULE_ITERATOR_STATE_R_DEBUG` |  |
| `USERSPACE_LOADED_MODULE_ITERATOR_STATE_LINK_MAP` |  |

---

{#drgn_dwarf_index_abbrev_insn}

### drgn_dwarf_index_abbrev_insn

```cpp
enum drgn_dwarf_index_abbrev_insn
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:289

DWARF abbreviation table instructions.

The DWARF abbreviation table can be large and contains more information than is strictly necessary for indexing. So, we translate the table into a series of instructions which specify how to process a DIE. This instruction stream omits unnecessary information and is more compact (and thus more cache friendly), which is important for the tight DIE parsing loop.

| Value | Description |
|-------|-------------|
| `INSN_MAX_SKIP` |  |
| `INSN_SKIP_BLOCK` |  |
| `INSN_SKIP_BLOCK1` |  |
| `INSN_SKIP_BLOCK2` |  |
| `INSN_SKIP_BLOCK4` |  |
| `INSN_SKIP_LEB128` |  |
| `INSN_SKIP_STRING` |  |
| `INSN_SIBLING_REF1` |  |
| `INSN_SIBLING_REF2` |  |
| `INSN_SIBLING_REF4` |  |
| `INSN_SIBLING_REF8` |  |
| `INSN_SIBLING_REF_UDATA` |  |
| `INSN_NAME_STRP4` |  |
| `INSN_NAME_STRP8` |  |
| `INSN_NAME_STRING` |  |
| `INSN_NAME_STRX` |  |
| `INSN_NAME_STRX1` |  |
| `INSN_NAME_STRX2` |  |
| `INSN_NAME_STRX3` |  |
| `INSN_NAME_STRX4` |  |
| `INSN_NAME_STRP_ALT4` |  |
| `INSN_NAME_STRP_ALT8` |  |
| `INSN_DECLARATION_FLAG` |  |
| `INSN_SPECIFICATION_REF1` |  |
| `INSN_SPECIFICATION_REF2` |  |
| `INSN_SPECIFICATION_REF4` |  |
| `INSN_SPECIFICATION_REF8` |  |
| `INSN_SPECIFICATION_REF_UDATA` |  |
| `INSN_SPECIFICATION_REF_ADDR4` |  |
| `INSN_SPECIFICATION_REF_ADDR8` |  |
| `INSN_SPECIFICATION_REF_ALT4` |  |
| `INSN_SPECIFICATION_REF_ALT8` |  |
| `INSN_INDIRECT` |  |
| `INSN_SIBLING_INDIRECT` |  |
| `INSN_NAME_INDIRECT` |  |
| `INSN_DECLARATION_INDIRECT` |  |
| `INSN_SPECIFICATION_INDIRECT` |  |
| `NUM_INSNS` |  |
| `INSN_END` |  |
| `INSN_DIE_FLAG_TAG_MASK` |  |
| `INSN_DIE_TAG_imported_unit` |  |
| `INSN_DIE_NUM_TAGS` |  |
| `INSN_DIE_FLAG_SUBPROGRAM_NO_PC` |  |
| `INSN_DIE_FLAG_DECLARATION` |  |
| `INSN_DIE_FLAG_CHILDREN` |  |

---

{#c_type_specifier}

### c_type_specifier

```cpp
enum c_type_specifier
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/language_c.c:1925

| Value | Description |
|-------|-------------|
| `SPECIFIER_ERROR` |  |
| `SPECIFIER_VOID` |  |
| `SPECIFIER_CHAR` |  |
| `SPECIFIER_SIGNED_CHAR` |  |
| `SPECIFIER_UNSIGNED_CHAR` |  |
| `SPECIFIER_SHORT` |  |
| `SPECIFIER_SHORT_INT` |  |
| `SPECIFIER_SIGNED_SHORT_INT` |  |
| `SPECIFIER_UNSIGNED_SHORT_INT` |  |
| `SPECIFIER_SIGNED_SHORT` |  |
| `SPECIFIER_UNSIGNED_SHORT` |  |
| `SPECIFIER_INT` |  |
| `SPECIFIER_SIGNED_INT` |  |
| `SPECIFIER_UNSIGNED_INT` |  |
| `SPECIFIER_LONG` |  |
| `SPECIFIER_LONG_INT` |  |
| `SPECIFIER_SIGNED_LONG` |  |
| `SPECIFIER_UNSIGNED_LONG` |  |
| `SPECIFIER_SIGNED_LONG_INT` |  |
| `SPECIFIER_UNSIGNED_LONG_INT` |  |
| `SPECIFIER_LONG_LONG` |  |
| `SPECIFIER_LONG_LONG_INT` |  |
| `SPECIFIER_SIGNED_LONG_LONG_INT` |  |
| `SPECIFIER_UNSIGNED_LONG_LONG_INT` |  |
| `SPECIFIER_SIGNED_LONG_LONG` |  |
| `SPECIFIER_UNSIGNED_LONG_LONG` |  |
| `SPECIFIER_SIGNED` |  |
| `SPECIFIER_UNSIGNED` |  |
| `SPECIFIER_BOOL` |  |
| `SPECIFIER_FLOAT` |  |
| `SPECIFIER_DOUBLE` |  |
| `SPECIFIER_LONG_DOUBLE` |  |
| `SPECIFIER_NONE` |  |
| `NUM_SPECIFIER_STATES` |  |

---

{#kernel_module_address_ranges_version}

### kernel_module_address_ranges_version

```cpp
enum kernel_module_address_ranges_version
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/linux_kernel.c:1721

| Value | Description |
|-------|-------------|
| `MODULE_MEMORY` |  |
| `MODULE_LAYOUT` |  |
| `IN_MODULE` |  |

---

{#drgn_type_flags}

### drgn_type_flags

```cpp
enum drgn_type_flags
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn_internal.h:23

| Value | Description |
|-------|-------------|
| `DRGN_TYPE_FLAG_IS_COMPLETE` |  |
| `DRGN_TYPE_FLAG_IS_SIGNED` |  |
| `DRGN_TYPE_FLAG_LITTLE_ENDIAN` |  |
| `DRGN_TYPE_FLAG_IS_VARIADIC` |  |

---

{#unknown-21}

### 

```cpp
enum 
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_constants.h:28

| Value | Description |
|-------|-------------|
| `DW_ACCESS_DEFINITIONS` |  |

---

{#unknown-22}

### 

```cpp
enum 
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_constants.h:38

| Value | Description |
|-------|-------------|
| `DW_ADDR_DEFINITIONS` |  |

---

{#unknown-23}

### 

```cpp
enum 
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_constants.h:372

| Value | Description |
|-------|-------------|
| `DW_AT_DEFINITIONS` |  |

---

{#unknown-24}

### 

```cpp
enum 
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_constants.h:415

| Value | Description |
|-------|-------------|
| `DW_ATE_DEFINITIONS` |  |

---

{#unknown-25}

### 

```cpp
enum 
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_constants.h:451

| Value | Description |
|-------|-------------|
| `DW_CC_DEFINITIONS` |  |

---

{#unknown-26}

### 

```cpp
enum 
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_constants.h:492

| Value | Description |
|-------|-------------|
| `DW_CFA_DEFINITIONS` |  |

---

{#unknown-27}

### 

```cpp
enum 
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_constants.h:497

| Value | Description |
|-------|-------------|
| `DW_CHILDREN_DEFINITIONS` |  |

---

{#unknown-28}

### 

```cpp
enum 
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_constants.h:503

| Value | Description |
|-------|-------------|
| `DW_DEFAULTED_DEFINITIONS` |  |

---

{#unknown-29}

### 

```cpp
enum 
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_constants.h:511

| Value | Description |
|-------|-------------|
| `DW_DS_DEFINITIONS` |  |

---

{#unknown-30}

### 

```cpp
enum 
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_constants.h:516

| Value | Description |
|-------|-------------|
| `DW_DSC_DEFINITIONS` |  |

---

{#unknown-31}

### 

```cpp
enum 
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_constants.h:536

| Value | Description |
|-------|-------------|
| `DW_EH_PE_DEFINITIONS` |  |

---

{#unknown-32}

### 

```cpp
enum 
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_constants.h:544

| Value | Description |
|-------|-------------|
| `DW_END_DEFINITIONS` |  |

---

{#unknown-33}

### 

```cpp
enum 
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_constants.h:595

| Value | Description |
|-------|-------------|
| `DW_FORM_DEFINITIONS` |  |

---

{#unknown-34}

### 

```cpp
enum 
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_constants.h:602

| Value | Description |
|-------|-------------|
| `DW_ID_DEFINITIONS` |  |

---

{#unknown-35}

### 

```cpp
enum 
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_constants.h:617

| Value | Description |
|-------|-------------|
| `DW_IDX_DEFINITIONS` |  |

---

{#unknown-36}

### 

```cpp
enum 
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_constants.h:624

| Value | Description |
|-------|-------------|
| `DW_INL_DEFINITIONS` |  |

---

{#unknown-37}

### 

```cpp
enum 
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_constants.h:694

| Value | Description |
|-------|-------------|
| `DW_LANG_DEFINITIONS` |  |

---

{#unknown-38}

### 

```cpp
enum 
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_constants.h:706

| Value | Description |
|-------|-------------|
| `DW_LLE_DEFINITIONS` |  |

---

{#unknown-39}

### 

```cpp
enum 
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_constants.h:721

| Value | Description |
|-------|-------------|
| `DW_LNCT_DEFINITIONS` |  |

---

{#unknown-40}

### 

```cpp
enum 
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_constants.h:741

| Value | Description |
|-------|-------------|
| `DW_LNE_DEFINITIONS` |  |

---

{#unknown-41}

### 

```cpp
enum 
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_constants.h:760

| Value | Description |
|-------|-------------|
| `DW_LNS_DEFINITIONS` |  |

---

{#unknown-42}

### 

```cpp
enum 
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_constants.h:768

| Value | Description |
|-------|-------------|
| `DW_MACINFO_DEFINITIONS` |  |

---

{#unknown-43}

### 

```cpp
enum 
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_constants.h:785

| Value | Description |
|-------|-------------|
| `DW_MACRO_DEFINITIONS` |  |

---

{#unknown-44}

### 

```cpp
enum 
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_constants.h:992

| Value | Description |
|-------|-------------|
| `DW_OP_DEFINITIONS` |  |

---

{#unknown-45}

### 

```cpp
enum 
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_constants.h:1006

| Value | Description |
|-------|-------------|
| `DW_ORD_DEFINITIONS` |  |

---

{#unknown-46}

### 

```cpp
enum 
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_constants.h:1017

| Value | Description |
|-------|-------------|
| `DW_RLE_DEFINITIONS` |  |

---

{#unknown-47}

### 

```cpp
enum 
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_constants.h:1028

| Value | Description |
|-------|-------------|
| `DW_SECT_DEFINITIONS` |  |

---

{#unknown-48}

### 

```cpp
enum 
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_constants.h:1153

| Value | Description |
|-------|-------------|
| `DW_TAG_DEFINITIONS` |  |

---

{#unknown-49}

### 

```cpp
enum 
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_constants.h:1173

| Value | Description |
|-------|-------------|
| `DW_UT_DEFINITIONS` |  |

---

{#unknown-50}

### 

```cpp
enum 
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_constants.h:1179

| Value | Description |
|-------|-------------|
| `DW_VIRTUALITY_DEFINITIONS` |  |

---

{#unknown-51}

### 

```cpp
enum 
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_constants.h:1185

| Value | Description |
|-------|-------------|
| `DW_VIS_DEFINITIONS` |  |
## Functions

---

{#read_all}

### read_all

```cpp
ssize_t read_all(int fd, void * buf, size_t count)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/io.c:15

Wrapper around \manpage{read,2} that never returns less bytes than requested unless it hits end-of-file.

---

{#write_all}

### write_all

```cpp
int write_all(int fd, const void * buf, size_t count)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/io.c:36

Wrapper around \manpage{write,2} that never writes less bytes than requested.

#### Returns
0 on success, -1 on error.

---

{#pread_all}

### pread_all

```cpp
ssize_t pread_all(int fd, void * buf, size_t count, off_t offset)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/io.c:51

Wrapper around \manpage{pread,2} that never returns less bytes than requested unless it hits end-of-file.

---

{#fd_canonical_path}

### fd_canonical_path

```cpp
char * fd_canonical_path(int fd, const char * path)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/io.c:72

Get the canonical path of a file descriptor.

This returns the first of the following that succeeds:

1. `readlink("/proc/self/fd/{fd}")`
1. `realpath(path)` if `path` is not `NULL`
1. `"/proc/self/fd/{fd}"` if `path` is `NULL`, `path` otherwise

#### Returns
Returned path, or `NULL` if memory could not be allocated. On success, must be freed with `free()`.

---

{#read_all-1}

### read_all

```cpp
ssize_t read_all(int fd, void * buf, size_t count)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/io.h:20

Wrapper around \manpage{read,2} that never returns less bytes than requested unless it hits end-of-file.

---

{#write_all-1}

### write_all

```cpp
int write_all(int fd, const void * buf, size_t count)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/io.h:27

Wrapper around \manpage{write,2} that never writes less bytes than requested.

#### Returns
0 on success, -1 on error.

---

{#pread_all-1}

### pread_all

```cpp
ssize_t pread_all(int fd, void * buf, size_t count, off_t offset)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/io.h:33

Wrapper around \manpage{pread,2} that never returns less bytes than requested unless it hits end-of-file.

---

{#fd_canonical_path-1}

### fd_canonical_path

```cpp
char * fd_canonical_path(int fd, const char * path)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/io.h:47

Get the canonical path of a file descriptor.

This returns the first of the following that succeeds:

1. `readlink("/proc/self/fd/{fd}")`
1. `realpath(path)` if `path` is not `NULL`
1. `"/proc/self/fd/{fd}"` if `path` is `NULL`, `path` otherwise

#### Returns
Returned path, or `NULL` if memory could not be allocated. On success, must be freed with `free()`.

---

{#drgn_cfi_row_reserve}

### drgn_cfi_row_reserve

`static`

```cpp
static bool drgn_cfi_row_reserve(struct drgn_cfi_row ** row, uint16_t num_rules)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/cfi.c:36

---

{#drgn_file_log_fn}

### drgn_file_log_fn

`static`

```cpp
static void drgn_file_log_fn(struct drgn_program * prog, void * arg, enum drgn_log_level level, const char * format, va_list ap, struct drgn_error * err)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/log.c:23

---

{#drgn_error_log}

### drgn_error_log

```cpp
void drgn_error_log(enum drgn_log_level level, struct drgn_program * prog, struct drgn_error * err, const char * format, ...)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/log.c:74

---

{#drgn_program_get_progress_file}

### drgn_program_get_progress_file

```cpp
FILE * drgn_program_get_progress_file(struct drgn_program * prog, int * columns_ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/log.c:93

---

{#drgn_program_get_progress_file-1}

### drgn_program_get_progress_file

```cpp
FILE * drgn_program_get_progress_file(struct drgn_program * prog, int * columns_ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/log.h:91

---

{#drgn_orc_sp_reg}

### drgn_orc_sp_reg

`static` `inline`

```cpp
static inline int drgn_orc_sp_reg(const struct drgn_orc_entry * orc)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/orc.h:82

---

{#drgn_orc_bp_reg}

### drgn_orc_bp_reg

`static` `inline`

```cpp
static inline int drgn_orc_bp_reg(const struct drgn_orc_entry * orc)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/orc.h:87

---

{#drgn_orc_type}

### drgn_orc_type

`static` `inline`

```cpp
static inline int drgn_orc_type(const struct drgn_orc_entry * orc)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/orc.h:92

---

{#drgn_orc_signal}

### drgn_orc_signal

`static` `inline`

```cpp
static inline bool drgn_orc_signal(const struct drgn_orc_entry * orc)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/orc.h:97

---

{#add_type}

### add_type

`static`

```cpp
static int add_type(PyObject * module, PyTypeObject * type)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/main.c:16

---

{#add_bool}

### add_bool

`static`

```cpp
static int add_bool(PyObject * module, const char * name, bool value)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/main.c:28

---

{#get_default_prog_impl}

### get_default_prog_impl

`static` `inline`

```cpp
static inline Program * get_default_prog_impl(void)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/main.c:42

---

{#get_default_prog}

### get_default_prog

`static`

```cpp
static PyObject * get_default_prog(PyObject * self, PyObject * Py_UNUSED)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/main.c:52

---

{#set_default_prog}

### set_default_prog

`static`

```cpp
static PyObject * set_default_prog(PyObject * self, PyObject * arg)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/main.c:57

---

{#filename_matches}

### filename_matches

`static`

```cpp
static PyObject * filename_matches(PyObject * self, PyObject * args, PyObject * kwds)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/main.c:72

---

{#sizeof_}

### sizeof_

`static`

```cpp
static PyObject * sizeof_(PyObject * self, PyObject * arg)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/main.c:105

---

{#default_prog_find_type}

### default_prog_find_type

`static`

```cpp
static Program * default_prog_find_type(PyObject * arg, struct drgn_qualified_type * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/main.c:146

---

{#alignof_}

### alignof_

`static`

```cpp
static PyObject * alignof_(PyObject * self, PyObject * arg)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/main.c:168

---

{#offsetof_}

### offsetof_

`static`

```cpp
static PyObject * offsetof_(PyObject * self, PyObject * args, PyObject * kwds)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/main.c:192

---

{#add_type_aliases}

### add_type_aliases

`static`

```cpp
static int add_type_aliases(PyObject * m)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/main.c:310

---

{#pyinit__drgn}

### PyInit__drgn

```cpp
PyMODINIT_FUNC PyInit__drgn(void)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/main.c:346

---

{#drgn_initialize_python}

### drgn_initialize_python

```cpp
PyGILState_STATE drgn_initialize_python(bool * success_ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/main.c:504

---

{#typeof}

### typeof

```cpp
typeof(serialize_bits)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/test.c:17

---

{#typeof-1}

### typeof

```cpp
typeof(deserialize_bits)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/test.c:25

---

{#drgn_primitive_type_is_signed}

### drgn_primitive_type_is_signed

`static` `inline`

```cpp
static inline bool drgn_primitive_type_is_signed(enum drgn_primitive_type primitive)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/type.c:154

Return whether a primitive type is always a signed integer type.

---

{#drgn_member_key_hash_pair}

### drgn_member_key_hash_pair

`static`

```cpp
static struct hash_pair drgn_member_key_hash_pair(const struct drgn_member_key * key)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/type.c:170

---

{#drgn_member_key_eq}

### drgn_member_key_eq

`static`

```cpp
static bool drgn_member_key_eq(const struct drgn_member_key * a, const struct drgn_member_key * b)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/type.c:181

---

{#define_hash_map_functions-1}

### DEFINE_HASH_MAP_FUNCTIONS

```cpp
DEFINE_HASH_MAP_FUNCTIONS(drgn_member_map, drgn_member_key_hash_pair, drgn_member_key_eq)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/type.c:188

---

{#define_hash_set_functions-1}

### DEFINE_HASH_SET_FUNCTIONS

```cpp
DEFINE_HASH_SET_FUNCTIONS(drgn_type_set, ptr_key_hash_pair, scalar_key_eq)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/type.c:191

---

{#drgn_member_object-1}

### drgn_member_object

```cpp
LIBDRGN_PUBLIC struct drgn_error * drgn_member_object(struct drgn_type_member * member, const struct drgn_object ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/type.c:194

---

{#drgn_member_type-1}

### drgn_member_type

```cpp
LIBDRGN_PUBLIC struct drgn_error * drgn_member_type(struct drgn_type_member * member, struct drgn_qualified_type * type_ret, uint64_t * bit_field_size_ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/type.c:204

---

{#drgn_parameter_default_argument-1}

### drgn_parameter_default_argument

```cpp
LIBDRGN_PUBLIC struct drgn_error * drgn_parameter_default_argument(struct drgn_type_parameter * parameter, const struct drgn_object ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/type.c:222

---

{#drgn_parameter_type-1}

### drgn_parameter_type

```cpp
LIBDRGN_PUBLIC struct drgn_error * drgn_parameter_type(struct drgn_type_parameter * parameter, struct drgn_qualified_type * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/type.c:233

---

{#drgn_template_parameter_type-1}

### drgn_template_parameter_type

```cpp
LIBDRGN_PUBLIC struct drgn_error * drgn_template_parameter_type(struct drgn_type_template_parameter * parameter, struct drgn_qualified_type * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/type.c:244

---

{#drgn_template_parameter_object-1}

### drgn_template_parameter_object

```cpp
LIBDRGN_PUBLIC struct drgn_error * drgn_template_parameter_object(struct drgn_type_template_parameter * parameter, const struct drgn_object ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/type.c:255

---

{#drgn_type_dedupe_hash_pair}

### drgn_type_dedupe_hash_pair

`static`

```cpp
static struct hash_pair drgn_type_dedupe_hash_pair(struct drgn_type *const * entry)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/type.c:270

---

{#drgn_type_dedupe_eq}

### drgn_type_dedupe_eq

`static`

```cpp
static bool drgn_type_dedupe_eq(struct drgn_type *const * entry_a, struct drgn_type *const * entry_b)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/type.c:295

---

{#define_hash_set_functions-2}

### DEFINE_HASH_SET_FUNCTIONS

```cpp
DEFINE_HASH_SET_FUNCTIONS(drgn_dedupe_type_set, drgn_type_dedupe_hash_pair, drgn_type_dedupe_eq)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/type.c:331

---

{#define_vector_functions-1}

### DEFINE_VECTOR_FUNCTIONS

```cpp
DEFINE_VECTOR_FUNCTIONS(drgn_typep_vector)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/type.c:334

---

{#find_or_create_type}

### find_or_create_type

`static`

```cpp
static struct drgn_error * find_or_create_type(struct drgn_type * key, struct drgn_type ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/type.c:336

---

{#drgn_type_init_byte_order}

### drgn_type_init_byte_order

`static`

```cpp
static struct drgn_error * drgn_type_init_byte_order(struct drgn_type * type, enum drgn_byte_order byte_order)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/type.c:370

---

{#define_vector_functions-2}

### DEFINE_VECTOR_FUNCTIONS

```cpp
DEFINE_VECTOR_FUNCTIONS(drgn_type_template_parameter_vector)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/type.c:484

---

{#drgn_template_parameters_builder_init}

### drgn_template_parameters_builder_init

`static`

```cpp
static void drgn_template_parameters_builder_init(struct drgn_template_parameters_builder * builder, struct drgn_program * prog)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/type.c:487

---

{#drgn_template_parameters_builder_deinit}

### drgn_template_parameters_builder_deinit

`static`

```cpp
static void drgn_template_parameters_builder_deinit(struct drgn_template_parameters_builder * builder)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/type.c:495

---

{#define_vector_functions-3}

### DEFINE_VECTOR_FUNCTIONS

```cpp
DEFINE_VECTOR_FUNCTIONS(drgn_type_member_vector)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/type.c:522

---

{#define_vector_functions-4}

### DEFINE_VECTOR_FUNCTIONS

```cpp
DEFINE_VECTOR_FUNCTIONS(drgn_type_enumerator_vector)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/type.c:618

---

{#define_vector_functions-5}

### DEFINE_VECTOR_FUNCTIONS

```cpp
DEFINE_VECTOR_FUNCTIONS(drgn_type_parameter_vector)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/type.c:832

---

{#drgn_type_with_byte_order_impl}

### drgn_type_with_byte_order_impl

`static`

```cpp
static struct drgn_error * drgn_type_with_byte_order_impl(struct drgn_type ** type, struct drgn_type ** underlying_type, enum drgn_byte_order byte_order)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/type.c:917

---

{#drgn_format_variable_declaration-1}

### drgn_format_variable_declaration

```cpp
LIBDRGN_PUBLIC struct drgn_error * drgn_format_variable_declaration(struct drgn_qualified_type qualified_type, const char * name, char ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/type.c:1060

---

{#default_size_t_or_ptrdiff_t}

### default_size_t_or_ptrdiff_t

`static`

```cpp
static struct drgn_error * default_size_t_or_ptrdiff_t(struct drgn_program * prog, enum drgn_primitive_type type, struct drgn_type ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/type.c:1439

---

{#drgn_type_cache_members}

### drgn_type_cache_members

`static`

```cpp
static struct drgn_error * drgn_type_cache_members(struct drgn_type * outer_type, struct drgn_type * type, uint64_t bit_offset)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/type.c:1608

---

{#drgn_type_find_member_impl}

### drgn_type_find_member_impl

`static`

```cpp
static struct drgn_error * drgn_type_find_member_impl(struct drgn_type * type, const char * member_name, size_t member_name_len, struct drgn_member_value ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/type.c:1677

---

{#qsort_arg_compar_wrapper}

### qsort_arg_compar_wrapper

`static`

```cpp
static int qsort_arg_compar_wrapper(const void * a, const void * b)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/util.c:8

---

{#qsort_arg}

### qsort_arg

```cpp
void qsort_arg(void * base, size_t nmemb, size_t size, int(*)(const void *, const void *, void *) compar, void * arg)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/util.c:13

Similar to qsort_r (passes *arg* to *compar*) but **not** reentrant

The qsort_r() function's main feature is that it is reentrant, but also adds the convenience of including an argument to the callback function. Unfortunately it is a glibc extension. This provides a similar API but it is only thread-safe, not reentrant. See qsort_r(3) for details.

---

{#strstartswith}

### strstartswith

`static` `inline`

```cpp
static inline bool strstartswith(const char * s, const char * prefix)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/util.h:86

---

{#malloc_array}

### malloc_array

`static` `inline`

```cpp
static inline void * malloc_array(size_t nmemb, size_t size)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/util.h:91

---

{#malloc_flexible_array_impl}

### malloc_flexible_array_impl

`static` `inline`

```cpp
static inline void * malloc_flexible_array_impl(size_t struct_size, size_t element_size, size_t count)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/util.h:102

---

{#malloc64}

### malloc64

`static` `inline`

```cpp
static inline void * malloc64(uint64_t size)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/util.h:129

---

{#realloc_array}

### realloc_array

`static` `inline`

```cpp
static inline void * realloc_array(void * ptr, size_t nmemb, size_t size)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/util.h:138

---

{#memdup}

### memdup

`static` `inline`

```cpp
static inline void * memdup(const void * ptr, size_t size)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/util.h:148

---

{#alloc_or_reuse}

### alloc_or_reuse

`static` `inline`

```cpp
static inline bool alloc_or_reuse(void ** buf, size_t * capacity, size_t size)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/util.h:156

---

{#uint_max}

### uint_max

`static` `inline`

```cpp
static inline uint64_t uint_max(int n)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/util.h:171

Return the maximum value of an `n-byte` unsigned integer.

---

{#qsort_arg-1}

### qsort_arg

```cpp
void qsort_arg(void * base, size_t nmemb, size_t size, int(*)(const void *, const void *, void *) compar, void * arg)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/util.h:225

Similar to qsort_r (passes *arg* to *compar*) but **not** reentrant

The qsort_r() function's main feature is that it is reentrant, but also adds the convenience of including an argument to the callback function. Unfortunately it is a glibc extension. This provides a similar API but it is only thread-safe, not reentrant. See qsort_r(3) for details.

---

{#drgn_error_create_nodup}

### drgn_error_create_nodup

`static`

```cpp
static struct drgn_error * drgn_error_create_nodup(enum drgn_error_code code, char * message)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/error.c:62

---

{#drgn_error_format_os-1}

### drgn_error_format_os

```cpp
LIBDRGN_PUBLIC struct drgn_error * drgn_error_format_os(const char * message, int errnum, const char * path_format, ...)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/error.c:97

---

{#drgn_error_format-1}

### drgn_error_format

```cpp
LIBDRGN_PUBLIC struct drgn_error * drgn_error_format(enum drgn_error_code code, const char * format, ...)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/error.c:142

---

{#drgn_error_format_fault-1}

### drgn_error_format_fault

```cpp
LIBDRGN_PUBLIC struct drgn_error * drgn_error_format_fault(uint64_t address, const char * format, ...)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/error.c:169

---

{#drgn_platform_from_kdump}

### drgn_platform_from_kdump

`static`

```cpp
static struct drgn_error * drgn_platform_from_kdump(kdump_ctx_t * ctx, struct drgn_platform * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/kdump.c:14

---

{#drgn_platform_to_kdump}

### drgn_platform_to_kdump

`static`

```cpp
static struct drgn_error * drgn_platform_to_kdump(kdump_ctx_t * ctx, const struct drgn_platform * platform)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/kdump.c:73

---

{#drgn_read_kdump}

### drgn_read_kdump

`static`

```cpp
static struct drgn_error * drgn_read_kdump(void * buf, uint64_t address, size_t count, uint64_t offset, void * arg, bool physical)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/kdump.c:113

---

{#prefer_drgn_vaddr_reader}

### prefer_drgn_vaddr_reader

`static`

```cpp
static bool prefer_drgn_vaddr_reader(void)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/kdump.c:130

---

{#drgn_program_set_kdump}

### drgn_program_set_kdump

```cpp
struct drgn_error * drgn_program_set_kdump(struct drgn_program * prog)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/kdump.c:136

---

{#drgn_program_cache_kdump_threads}

### drgn_program_cache_kdump_threads

```cpp
struct drgn_error * drgn_program_cache_kdump_threads(struct drgn_program * prog)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/kdump.c:310

---

{#define_vector_functions-6}

### DEFINE_VECTOR_FUNCTIONS

```cpp
DEFINE_VECTOR_FUNCTIONS(drgn_token_vector)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/lexer.c:7

---

{#drgn_bitmap_create}

### drgn_bitmap_create

`static` `inline`

```cpp
static inline unsigned long * drgn_bitmap_create(size_t num_bits)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/bitmap.h:13

---

{#drgn_bitmap_test_bit}

### drgn_bitmap_test_bit

`static` `inline`

```cpp
static inline bool drgn_bitmap_test_bit(const unsigned long * bitmap, size_t i)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/bitmap.h:20

---

{#drgn_bitmap_set_bit}

### drgn_bitmap_set_bit

`static` `inline`

```cpp
static inline void drgn_bitmap_set_bit(unsigned long * bitmap, size_t i)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/bitmap.h:26

---

{#drgn_bitmap_clear_bit}

### drgn_bitmap_clear_bit

`static` `inline`

```cpp
static inline void drgn_bitmap_clear_bit(unsigned long * bitmap, size_t i)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/bitmap.h:32

---

{#omp_get_thread_num}

### omp_get_thread_num

`static` `inline`

```cpp
static inline int omp_get_thread_num(void)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/openmp.h:13

---

{#drgn_init_num_threads}

### drgn_init_num_threads

`static` `inline`

```cpp
static inline void drgn_init_num_threads(void)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/openmp.h:19

---

{#pyobject_callnoargs}

### PyObject_CallNoArgs

`static` `inline`

```cpp
static inline PyObject * PyObject_CallNoArgs(PyObject * func)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:25

---

{#pyobject_callonearg}

### PyObject_CallOneArg

`static` `inline`

```cpp
static inline PyObject * PyObject_CallOneArg(PyObject * callable, PyObject * arg)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:29

---

{#pymodule_addobjectref}

### PyModule_AddObjectRef

`static` `inline`

```cpp
static inline int PyModule_AddObjectRef(PyObject * mod, const char * name, PyObject * value)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:36

---

{#pyerr_getraisedexception}

### PyErr_GetRaisedException

`static` `inline`

```cpp
static inline PyObject * PyErr_GetRaisedException(void)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:48

---

{#pyerr_setraisedexception}

### PyErr_SetRaisedException

`static` `inline`

```cpp
static inline void PyErr_SetRaisedException(PyObject * exc)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:63

---

{#pymodule_add}

### PyModule_Add

`static` `inline`

```cpp
static inline int PyModule_Add(PyObject * mod, const char * name, PyObject * value)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:72

---

{#pylong_isnegative}

### PyLong_IsNegative

```cpp
int PyLong_IsNegative(PyObject * obj)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:90

---

{#pylong_fromint64}

### PyLong_FromInt64

`static` `inline`

```cpp
static inline PyObject * PyLong_FromInt64(int64_t value)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:93

---

{#pylong_fromuint32}

### PyLong_FromUInt32

`static` `inline`

```cpp
static inline PyObject * PyLong_FromUInt32(uint32_t value)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:97

---

{#pylong_fromuint64}

### PyLong_FromUInt64

`static` `inline`

```cpp
static inline PyObject * PyLong_FromUInt64(uint64_t value)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:101

---

{#pylong_asint64}

### PyLong_AsInt64

```cpp
int PyLong_AsInt64(PyObject * obj, int64_t * value)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:106

---

{#pylong_asuint32}

### PyLong_AsUInt32

```cpp
int PyLong_AsUInt32(PyObject * obj, uint32_t * value)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:107

---

{#pylong_asuint64}

### PyLong_AsUInt64

```cpp
int PyLong_AsUInt64(PyObject * obj, uint64_t * value)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:108

---

{#pylong_fromuint8}

### PyLong_FromUInt8

`static` `inline`

```cpp
static inline PyObject * PyLong_FromUInt8(uint8_t value)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:112

---

{#pylong_fromuint16}

### PyLong_FromUInt16

`static` `inline`

```cpp
static inline PyObject * PyLong_FromUInt16(uint16_t value)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:116

---

{#pylong_asuint16}

### PyLong_AsUInt16

```cpp
int PyLong_AsUInt16(PyObject * obj, uint16_t * value)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:120

---

{#pydecrefp}

### pydecrefp

`static` `inline`

```cpp
static inline void pydecrefp(void * p)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:141

---

{#pygilstate_releasep}

### PyGILState_Releasep

`static` `inline`

```cpp
static inline void PyGILState_Releasep(PyGILState_STATE * gstatep)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:150

---

{#py_leaverecursivecallp}

### Py_LeaveRecursiveCallp

`static` `inline`

```cpp
static inline void Py_LeaveRecursiveCallp(int * unused)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:167

---

{#define_hash_set_type-4}

### DEFINE_HASH_SET_TYPE

```cpp
DEFINE_HASH_SET_TYPE(pyobjectp_set, PyObject *)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:241

---

{#drgn_initialize_python-1}

### drgn_initialize_python

```cpp
PyGILState_STATE drgn_initialize_python(bool * success_ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:404

---

{#add_module_constants}

### add_module_constants

```cpp
int add_module_constants(PyObject * m)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:410

---

{#init_logging}

### init_logging

```cpp
int init_logging(void)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:411

---

{#drgn_error_from_python}

### drgn_error_from_python

```cpp
struct drgn_error * drgn_error_from_python(void)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:413

---

{#set_drgn_error}

### set_drgn_error

```cpp
void * set_drgn_error(struct drgn_error * err)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:414

---

{#set_error_type_name}

### set_error_type_name

```cpp
void * set_error_type_name(const char * format, struct drgn_qualified_type qualified_type)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:415

---

{#memorysearchiterator_wrap}

### MemorySearchIterator_wrap

```cpp
PyObject * MemorySearchIterator_wrap(PyTypeObject * type, struct drgn_memory_search_iterator * it)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:420

---

{#module_wrap}

### Module_wrap

```cpp
PyObject * Module_wrap(struct drgn_module * module)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:423

---

{#module_prog}

### Module_prog

`static` `inline`

```cpp
static inline Program * Module_prog(Module * module)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:424

---

{#add_wantedsupplementaryfile}

### add_WantedSupplementaryFile

```cpp
int add_WantedSupplementaryFile(PyObject * m)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:430

---

{#init_module_section_addresses}

### init_module_section_addresses

```cpp
int init_module_section_addresses(void)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:431

---

{#language_wrap}

### Language_wrap

```cpp
PyObject * Language_wrap(const struct drgn_language * language)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:433

---

{#language_converter}

### language_converter

```cpp
int language_converter(PyObject * o, void * p)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:434

---

{#add_languages}

### add_languages

```cpp
int add_languages(void)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:435

---

{#typekindset_wrap}

### TypeKindSet_wrap

```cpp
PyObject * TypeKindSet_wrap(uint64_t mask)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:437

---

{#init_type_kind_set}

### init_type_kind_set

```cpp
int init_type_kind_set(void)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:438

---

{#drgnobject_alloc}

### DrgnObject_alloc

`static` `inline`

```cpp
static inline DrgnObject * DrgnObject_alloc(Program * prog)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:440

---

{#drgnobject_prog}

### DrgnObject_prog

`static` `inline`

```cpp
static inline Program * DrgnObject_prog(DrgnObject * obj)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:449

---

{#drgnobject_null}

### DrgnObject_NULL

```cpp
PyObject * DrgnObject_NULL(PyObject * self, PyObject * args, PyObject * kwds)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:453

---

{#cast}

### cast

```cpp
DrgnObject * cast(PyObject * self, PyObject * args, PyObject * kwds)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:454

---

{#implicit_convert}

### implicit_convert

```cpp
DrgnObject * implicit_convert(PyObject * self, PyObject * args, PyObject * kwds)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:455

---

{#reinterpret}

### reinterpret

```cpp
DrgnObject * reinterpret(PyObject * self, PyObject * args, PyObject * kwds)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:456

---

{#drgnobject_container_of}

### DrgnObject_container_of

```cpp
DrgnObject * DrgnObject_container_of(PyObject * self, PyObject * args, PyObject * kwds)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:457

---

{#platform_wrap}

### Platform_wrap

```cpp
PyObject * Platform_wrap(const struct drgn_platform * platform)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:460

---

{#program_hold_object}

### Program_hold_object

```cpp
int Program_hold_object(Program * prog, PyObject * obj)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:462

---

{#program_hold_reserve}

### Program_hold_reserve

```cpp
bool Program_hold_reserve(Program * prog, size_t n)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:463

---

{#program_type_arg}

### Program_type_arg

```cpp
int Program_type_arg(Program * prog, PyObject * type_obj, bool can_be_none, struct drgn_qualified_type * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:464

---

{#program_from_core_dump}

### program_from_core_dump

```cpp
Program * program_from_core_dump(PyObject * self, PyObject * args, PyObject * kwds)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:466

---

{#program_from_kernel}

### program_from_kernel

```cpp
Program * program_from_kernel(PyObject * self)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:467

---

{#program_from_pid}

### program_from_pid

```cpp
Program * program_from_pid(PyObject * self, PyObject * args, PyObject * kwds)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:468

---

{#add_sourcelocation}

### add_SourceLocation

```cpp
int add_SourceLocation(PyObject * m)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:470

---

{#sourcelocationlist_wrap}

### SourceLocationList_wrap

```cpp
PyObject * SourceLocationList_wrap(struct drgn_source_location_list * locs)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:471

---

{#symbol_wrap}

### Symbol_wrap

```cpp
PyObject * Symbol_wrap(struct drgn_symbol * sym, PyObject * name_obj)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:473

---

{#symbol_list_wrap}

### Symbol_list_wrap

```cpp
PyObject * Symbol_list_wrap(struct drgn_symbol ** symbols, size_t count, PyObject * name_obj)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:474

---

{#thread_wrap}

### Thread_wrap

```cpp
PyObject * Thread_wrap(struct drgn_thread * drgn_thread)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:477

---

{#stacktrace_wrap}

### StackTrace_wrap

```cpp
PyObject * StackTrace_wrap(struct drgn_stack_trace * trace)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:479

---

{#drgntype_prog}

### DrgnType_prog

`static` `inline`

```cpp
static inline Program * DrgnType_prog(DrgnType * type)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:481

---

{#drgntype_wrap}

### DrgnType_wrap

```cpp
PyObject * DrgnType_wrap(struct drgn_qualified_type qualified_type)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:485

---

{#program_void_type}

### Program_void_type

```cpp
DrgnType * Program_void_type(Program * self, PyObject * args, PyObject * kwds)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:486

---

{#program_int_type}

### Program_int_type

```cpp
DrgnType * Program_int_type(Program * self, PyObject * args, PyObject * kwds)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:487

---

{#program_bool_type}

### Program_bool_type

```cpp
DrgnType * Program_bool_type(Program * self, PyObject * args, PyObject * kwds)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:488

---

{#program_float_type}

### Program_float_type

```cpp
DrgnType * Program_float_type(Program * self, PyObject * args, PyObject * kwds)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:489

---

{#program_struct_type}

### Program_struct_type

```cpp
DrgnType * Program_struct_type(Program * self, PyObject * args, PyObject * kwds)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:490

---

{#program_union_type}

### Program_union_type

```cpp
DrgnType * Program_union_type(Program * self, PyObject * args, PyObject * kwds)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:491

---

{#program_class_type}

### Program_class_type

```cpp
DrgnType * Program_class_type(Program * self, PyObject * args, PyObject * kwds)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:492

---

{#program_enum_type}

### Program_enum_type

```cpp
DrgnType * Program_enum_type(Program * self, PyObject * args, PyObject * kwds)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:493

---

{#program_typedef_type}

### Program_typedef_type

```cpp
DrgnType * Program_typedef_type(Program * self, PyObject * args, PyObject * kwds)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:494

---

{#program_pointer_type}

### Program_pointer_type

```cpp
DrgnType * Program_pointer_type(Program * self, PyObject * args, PyObject * kwds)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:495

---

{#program_array_type}

### Program_array_type

```cpp
DrgnType * Program_array_type(Program * self, PyObject * args, PyObject * kwds)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:496

---

{#program_function_type}

### Program_function_type

```cpp
DrgnType * Program_function_type(Program * self, PyObject * args, PyObject * kwds)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:497

---

{#append_string}

### append_string

```cpp
int append_string(PyObject * parts, const char * s)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:499

---

{#append_u64_hex}

### append_u64_hex

```cpp
int append_u64_hex(PyObject * parts, uint64_t value)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:500

---

{#append_format}

### append_format

```cpp
int append_format(PyObject * parts, const char * format, ...)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:501

---

{#append_attr_repr}

### append_attr_repr

```cpp
int append_attr_repr(PyObject * parts, PyObject * obj, const char * attr_name)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:502

---

{#append_attr_str}

### append_attr_str

```cpp
int append_attr_str(PyObject * parts, PyObject * obj, const char * attr_name)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:503

---

{#join_strings}

### join_strings

```cpp
PyObject * join_strings(PyObject * parts)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:504

---

{#repr_pretty_from_str}

### repr_pretty_from_str

```cpp
PyObject * repr_pretty_from_str(PyObject * self, PyObject * args, PyObject * kwds)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:506

---

{#index_converter}

### index_converter

```cpp
int index_converter(PyObject * o, void * p)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:517

---

{#u64_converter}

### u64_converter

```cpp
int u64_converter(PyObject * o, void * p)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:519

---

{#path_converter}

### path_converter

```cpp
int path_converter(PyObject * o, void * p)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:530

---

{#path_cleanup}

### path_cleanup

```cpp
void path_cleanup(struct path_arg * path)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:531

---

{#define_vector_type-9}

### DEFINE_VECTOR_TYPE

```cpp
DEFINE_VECTOR_TYPE(path_arg_vector, struct path_arg)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:537

---

{#path_sequence_converter}

### path_sequence_converter

```cpp
int path_sequence_converter(PyObject * o, void * p)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:545

---

{#path_sequence_cleanup}

### path_sequence_cleanup

```cpp
void path_sequence_cleanup(struct path_sequence_arg * paths)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:546

---

{#path_sequence_size}

### path_sequence_size

```cpp
size_t path_sequence_size(struct path_sequence_arg * paths)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:547

---

{#enum_converter}

### enum_converter

```cpp
int enum_converter(PyObject * o, void * p)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:558

---

{#drgnpy_linux_helper_direct_mapping_offset}

### drgnpy_linux_helper_direct_mapping_offset

```cpp
PyObject * drgnpy_linux_helper_direct_mapping_offset(PyObject * self, PyObject * arg)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:560

---

{#drgnpy_linux_helper_read_vm}

### drgnpy_linux_helper_read_vm

```cpp
PyObject * drgnpy_linux_helper_read_vm(PyObject * self, PyObject * args, PyObject * kwds)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:562

---

{#drgnpy_linux_helper_follow_phys}

### drgnpy_linux_helper_follow_phys

```cpp
PyObject * drgnpy_linux_helper_follow_phys(PyObject * self, PyObject * args, PyObject * kwds)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:564

---

{#drgnpy_linux_helper_per_cpu_ptr}

### drgnpy_linux_helper_per_cpu_ptr

```cpp
DrgnObject * drgnpy_linux_helper_per_cpu_ptr(PyObject * self, PyObject * args, PyObject * kwds)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:566

---

{#drgnpy_linux_helper_cpu_curr}

### drgnpy_linux_helper_cpu_curr

```cpp
DrgnObject * drgnpy_linux_helper_cpu_curr(PyObject * self, PyObject * args)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:568

---

{#drgnpy_linux_helper_idle_task}

### drgnpy_linux_helper_idle_task

```cpp
DrgnObject * drgnpy_linux_helper_idle_task(PyObject * self, PyObject * args)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:569

---

{#drgnpy_linux_helper_task_thread_info}

### drgnpy_linux_helper_task_thread_info

```cpp
DrgnObject * drgnpy_linux_helper_task_thread_info(PyObject * self, PyObject * args, PyObject * kwds)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:570

---

{#drgnpy_linux_helper_task_cpu}

### drgnpy_linux_helper_task_cpu

```cpp
PyObject * drgnpy_linux_helper_task_cpu(PyObject * self, PyObject * args, PyObject * kwds)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:572

---

{#drgnpy_linux_helper_task_on_cpu}

### drgnpy_linux_helper_task_on_cpu

```cpp
PyObject * drgnpy_linux_helper_task_on_cpu(PyObject * self, PyObject * args, PyObject * kwds)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:574

---

{#drgnpy_linux_helper_xa_load}

### drgnpy_linux_helper_xa_load

```cpp
DrgnObject * drgnpy_linux_helper_xa_load(PyObject * self, PyObject * args, PyObject * kwds)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:576

---

{#drgnpy_linux_helper_idr_find}

### drgnpy_linux_helper_idr_find

```cpp
DrgnObject * drgnpy_linux_helper_idr_find(PyObject * self, PyObject * args, PyObject * kwds)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:578

---

{#drgnpy_linux_helper_find_pid}

### drgnpy_linux_helper_find_pid

```cpp
DrgnObject * drgnpy_linux_helper_find_pid(PyObject * self, PyObject * args)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:580

---

{#drgnpy_linux_helper_pid_task}

### drgnpy_linux_helper_pid_task

```cpp
DrgnObject * drgnpy_linux_helper_pid_task(PyObject * self, PyObject * args, PyObject * kwds)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:581

---

{#drgnpy_linux_helper_find_task}

### drgnpy_linux_helper_find_task

```cpp
DrgnObject * drgnpy_linux_helper_find_task(PyObject * self, PyObject * args)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:583

---

{#drgnpy_linux_helper_kaslr_offset}

### drgnpy_linux_helper_kaslr_offset

```cpp
PyObject * drgnpy_linux_helper_kaslr_offset(PyObject * self, PyObject * arg)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:584

---

{#drgnpy_linux_helper_pgtable_l5_enabled}

### drgnpy_linux_helper_pgtable_l5_enabled

```cpp
PyObject * drgnpy_linux_helper_pgtable_l5_enabled(PyObject * self, PyObject * arg)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:585

---

{#drgnpy_linux_helper_load_proc_kallsyms}

### drgnpy_linux_helper_load_proc_kallsyms

```cpp
PyObject * drgnpy_linux_helper_load_proc_kallsyms(PyObject * self, PyObject * args, PyObject * kwds)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:586

---

{#drgnpy_linux_helper_load_builtin_kallsyms}

### drgnpy_linux_helper_load_builtin_kallsyms

```cpp
PyObject * drgnpy_linux_helper_load_builtin_kallsyms(PyObject * self, PyObject * args, PyObject * kwds)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:588

---

{#add_wantedsupplementaryfile-1}

### add_WantedSupplementaryFile

```cpp
int add_WantedSupplementaryFile(PyObject * m)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/module.c:10

---

{#module_wrap-1}

### Module_wrap

```cpp
PyObject * Module_wrap(struct drgn_module * module)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/module.c:28

---

{#module_dealloc}

### Module_dealloc

`static`

```cpp
static void Module_dealloc(Module * self)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/module.c:59

---

{#module_traverse}

### Module_traverse

`static`

```cpp
static int Module_traverse(Module * self, visitproc visit, void * arg)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/module.c:67

---

{#append_module_repr_common}

### append_module_repr_common

`static`

```cpp
static int append_module_repr_common(PyObject * parts, Module * self, const char * method_name)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/module.c:74

---

{#module_repr}

### Module_repr

`static`

```cpp
static PyObject * Module_repr(Module * self)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/module.c:83

---

{#module_richcompare}

### Module_richcompare

`static`

```cpp
static PyObject * Module_richcompare(Module * self, PyObject * other, int op)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/module.c:127

---

{#module_hash}

### Module_hash

`static`

```cpp
static Py_hash_t Module_hash(Module * self)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/module.c:138

---

{#module_wanted_supplementary_debug_file}

### Module_wanted_supplementary_debug_file

`static`

```cpp
static PyObject * Module_wanted_supplementary_debug_file(Module * self)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/module.c:143

---

{#module_try_file}

### Module_try_file

`static`

```cpp
static PyObject * Module_try_file(Module * self, PyObject * args, PyObject * kwds)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/module.c:169

---

{#module_get_prog}

### Module_get_prog

`static`

```cpp
static Program * Module_get_prog(Module * self, void * arg)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/module.c:186

---

{#module_get_name}

### Module_get_name

`static`

```cpp
static PyObject * Module_get_name(Module * self, void * arg)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/module.c:193

---

{#module_get_address_ranges}

### Module_get_address_ranges

`static`

```cpp
static PyObject * Module_get_address_ranges(Module * self, void * arg)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/module.c:198

---

{#define_vector-1}

### DEFINE_VECTOR

```cpp
DEFINE_VECTOR(uint64_pair_vector, uint64_t)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/module.c:218

---

{#module_set_address_ranges}

### Module_set_address_ranges

`static`

```cpp
static int Module_set_address_ranges(Module * self, PyObject * value, void * arg)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/module.c:220

---

{#module_get_address_range}

### Module_get_address_range

`static`

```cpp
static PyObject * Module_get_address_range(Module * self, void * arg)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/module.c:277

---

{#module_set_address_range}

### Module_set_address_range

`static`

```cpp
static int Module_set_address_range(Module * self, PyObject * value, void * arg)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/module.c:296

---

{#module_get_build_id}

### Module_get_build_id

`static`

```cpp
static PyObject * Module_get_build_id(Module * self, void * arg)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/module.c:328

---

{#module_set_build_id}

### Module_set_build_id

`static`

```cpp
static int Module_set_build_id(Module * self, PyObject * value, void * arg)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/module.c:337

---

{#module_get_object}

### Module_get_object

`static`

```cpp
static DrgnObject * Module_get_object(Module * self, void * arg)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/module.c:367

---

{#module_set_object}

### Module_set_object

`static`

```cpp
static int Module_set_object(Module * self, PyObject * value, void * arg)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/module.c:381

---

{#module_get_loaded_file_path}

### Module_get_loaded_file_path

`static`

```cpp
static PyObject * Module_get_loaded_file_path(Module * self, void * arg)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/module.c:443

---

{#module_get_loaded_file_bias}

### Module_get_loaded_file_bias

`static`

```cpp
static PyObject * Module_get_loaded_file_bias(Module * self, void * arg)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/module.c:451

---

{#module_get_debug_file_path}

### Module_get_debug_file_path

`static`

```cpp
static PyObject * Module_get_debug_file_path(Module * self, void * arg)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/module.c:458

---

{#module_get_debug_file_bias}

### Module_get_debug_file_bias

`static`

```cpp
static PyObject * Module_get_debug_file_bias(Module * self, void * arg)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/module.c:466

---

{#module_get_supplementary_debug_file_kind}

### Module_get_supplementary_debug_file_kind

`static`

```cpp
static PyObject * Module_get_supplementary_debug_file_kind(Module * self, void * arg)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/module.c:473

---

{#module_get_supplementary_debug_file_path}

### Module_get_supplementary_debug_file_path

`static`

```cpp
static PyObject * Module_get_supplementary_debug_file_path(Module * self, void * arg)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/module.c:484

---

{#module_get_info}

### Module_get_info

`static`

```cpp
static PyObject * Module_get_info(Module * self, void * arg)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/module.c:564

---

{#relocatablemodule_get_section_addresses}

### RelocatableModule_get_section_addresses

`static`

```cpp
static PyObject * RelocatableModule_get_section_addresses(PyObject * self, void * arg)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/module.c:599

---

{#moduleiterator_dealloc}

### ModuleIterator_dealloc

`static`

```cpp
static void ModuleIterator_dealloc(ModuleIterator * self)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/module.c:636

---

{#moduleiterator_traverse}

### ModuleIterator_traverse

`static`

```cpp
static int ModuleIterator_traverse(ModuleIterator * self, visitproc visit, void * arg)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/module.c:648

---

{#moduleiterator_next}

### ModuleIterator_next

`static`

```cpp
static PyObject * ModuleIterator_next(ModuleIterator * self)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/module.c:659

---

{#moduleiteratorwithnew_next}

### ModuleIteratorWithNew_next

`static`

```cpp
static PyObject * ModuleIteratorWithNew_next(ModuleIterator * self)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/module.c:671

---

{#drgn_value_deinit}

### drgn_value_deinit

`static`

```cpp
static void drgn_value_deinit(const struct drgn_object * obj, const union drgn_value * value)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/object.c:42

---

{#drgn_object_reinit_copy}

### drgn_object_reinit_copy

`static` `inline`

```cpp
static inline void drgn_object_reinit_copy(struct drgn_object * dst, const struct drgn_object * src)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/object.c:66

---

{#drgn_object_type_impl}

### drgn_object_type_impl

`static`

```cpp
static struct drgn_error * drgn_object_type_impl(struct drgn_type * type, struct drgn_type * underlying_type, enum drgn_qualifiers qualifiers, uint64_t bit_field_size, struct drgn_object_type * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/object.c:79

---

{#drgn_object_type_operand}

### drgn_object_type_operand

`static`

```cpp
static struct drgn_error * drgn_object_type_operand(const struct drgn_operand_type * op_type, struct drgn_object_type * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/object.c:202

---

{#drgn_value_deserialize}

### drgn_value_deserialize

`static`

```cpp
static void drgn_value_deserialize(union drgn_value * value, const void * buf, uint8_t bit_offset, enum drgn_object_encoding encoding, uint64_t bit_size, bool little_endian)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/object.c:333

---

{#drgn_object_read_reference}

### drgn_object_read_reference

`static`

```cpp
static struct drgn_error * drgn_object_read_reference(const struct drgn_object * obj, union drgn_value * value)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/object.c:686

---

{#drgn_object_value_signed}

### drgn_object_value_signed

`static`

```cpp
static struct drgn_error * drgn_object_value_signed(const struct drgn_object * obj, int64_t * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/object.c:947

---

{#drgn_object_value_unsigned}

### drgn_object_value_unsigned

`static`

```cpp
static struct drgn_error * drgn_object_value_unsigned(const struct drgn_object * obj, uint64_t * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/object.c:964

---

{#drgn_object_value_float}

### drgn_object_value_float

`static`

```cpp
static struct drgn_error * drgn_object_value_float(const struct drgn_object * obj, double * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/object.c:981

---

{#double_to_signed}

### double_to_signed

`static`

```cpp
static int64_t double_to_signed(double fvalue, uint64_t bit_size)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/object.c:1155

---

{#double_to_unsigned}

### double_to_unsigned

`static`

```cpp
static uint64_t double_to_unsigned(double fvalue, uint64_t bit_size)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/object.c:1170

---

{#drgn_object_convert_signed}

### drgn_object_convert_signed

`static`

```cpp
static struct drgn_error * drgn_object_convert_signed(const struct drgn_object * obj, uint64_t bit_size, int64_t * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/object.c:1184

---

{#drgn_object_convert_unsigned}

### drgn_object_convert_unsigned

`static`

```cpp
static struct drgn_error * drgn_object_convert_unsigned(const struct drgn_object * obj, uint64_t bit_size, uint64_t * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/object.c:1216

---

{#drgn_object_convert_float}

### drgn_object_convert_float

`static`

```cpp
static struct drgn_error * drgn_object_convert_float(const struct drgn_object * obj, double * fvalue)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/object.c:1248

---

{#drgn_object_is_zero_impl}

### drgn_object_is_zero_impl

`static`

```cpp
static struct drgn_error * drgn_object_is_zero_impl(const struct drgn_object * obj, bool * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/object.c:1351

---

{#drgn_compound_object_is_zero}

### drgn_compound_object_is_zero

`static`

```cpp
static struct drgn_error * drgn_compound_object_is_zero(const struct drgn_object * obj, struct drgn_type * underlying_type, bool * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/object.c:1291

---

{#drgn_array_object_is_zero}

### drgn_array_object_is_zero

`static`

```cpp
static struct drgn_error * drgn_array_object_is_zero(const struct drgn_object * obj, struct drgn_type * underlying_type, bool * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/object.c:1323

---

{#binary_operands_signed}

### binary_operands_signed

`static` `inline`

```cpp
static inline struct drgn_error * binary_operands_signed(const struct drgn_object * lhs, const struct drgn_object * rhs, uint64_t bit_size, int64_t * lhs_ret, int64_t * rhs_ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/object.c:1865

---

{#binary_operands_unsigned}

### binary_operands_unsigned

`static` `inline`

```cpp
static inline struct drgn_error * binary_operands_unsigned(const struct drgn_object * lhs, const struct drgn_object * rhs, uint64_t bit_size, uint64_t * lhs_ret, uint64_t * rhs_ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/object.c:1878

---

{#binary_operands_float}

### binary_operands_float

`static` `inline`

```cpp
static inline struct drgn_error * binary_operands_float(const struct drgn_object * lhs, const struct drgn_object * rhs, double * lhs_ret, double * rhs_ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/object.c:1891

---

{#pointer_operand}

### pointer_operand

`static`

```cpp
static struct drgn_error * pointer_operand(const struct drgn_object * ptr, uint64_t * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/object.c:1903

---

{#drgn_op_mul_impl-1}

### drgn_op_mul_impl

```cpp
struct drgn_error * drgn_op_mul_impl(struct drgn_object * res, const struct drgn_operand_type * op_type, const struct drgn_object * lhs, const struct drgn_object * rhs)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/object.c:2243

---

{#drgn_op_div_impl-1}

### drgn_op_div_impl

```cpp
struct drgn_error * drgn_op_div_impl(struct drgn_object * res, const struct drgn_operand_type * op_type, const struct drgn_object * lhs, const struct drgn_object * rhs)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/object.c:2292

---

{#drgn_op_mod_impl-1}

### drgn_op_mod_impl

```cpp
struct drgn_error * drgn_op_mod_impl(struct drgn_object * res, const struct drgn_operand_type * op_type, const struct drgn_object * lhs, const struct drgn_object * rhs)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/object.c:2347

---

{#shift_operand}

### shift_operand

`static`

```cpp
static struct drgn_error * shift_operand(const struct drgn_object * rhs, const struct drgn_operand_type * rhs_type, uint64_t * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/object.c:2390

---

{#drgn_op_lshift_impl-1}

### drgn_op_lshift_impl

```cpp
struct drgn_error * drgn_op_lshift_impl(struct drgn_object * res, const struct drgn_object * lhs, const struct drgn_operand_type * lhs_type, const struct drgn_object * rhs, const struct drgn_operand_type * rhs_type)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/object.c:2423

---

{#drgn_op_rshift_impl-1}

### drgn_op_rshift_impl

```cpp
struct drgn_error * drgn_op_rshift_impl(struct drgn_object * res, const struct drgn_object * lhs, const struct drgn_operand_type * lhs_type, const struct drgn_object * rhs, const struct drgn_operand_type * rhs_type)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/object.c:2476

---

{#drgn_op_not_impl-1}

### drgn_op_not_impl

```cpp
struct drgn_error * drgn_op_not_impl(struct drgn_object * res, const struct drgn_operand_type * op_type, const struct drgn_object * obj)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/object.c:2614

---

{#define_vector_functions-7}

### DEFINE_VECTOR_FUNCTIONS

```cpp
DEFINE_VECTOR_FUNCTIONS(symbol_vector)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/symbol.c:16

---

{#drgn_symbol_dup}

### drgn_symbol_dup

```cpp
struct drgn_symbol * drgn_symbol_dup(struct drgn_symbol * sym)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/symbol.c:83

---

{#define_vector_functions-8}

### DEFINE_VECTOR_FUNCTIONS

```cpp
DEFINE_VECTOR_FUNCTIONS(symbolp_vector)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/symbol.c:141

---

{#drgn_symbol_from_elf}

### drgn_symbol_from_elf

`static`

```cpp
static void drgn_symbol_from_elf(const char * name, uint64_t address, const GElf_Sym * elf_sym, struct drgn_symbol * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/symbol.c:157

---

{#drgn_symbol_result_builder_add_from_elf}

### drgn_symbol_result_builder_add_from_elf

```cpp
bool drgn_symbol_result_builder_add_from_elf(struct drgn_symbol_result_builder * builder, const char * name, uint64_t address, const GElf_Sym * elf_sym)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/symbol.c:179

Convert an ELF symbol to a [drgn_symbol](drgn_symbol.md#drgn_symbol) and add it to a result builder.

#### Returns
`true` on success, `false` on failure to allocate memory.

---

{#drgn_symbol_result_builder_init}

### drgn_symbol_result_builder_init

```cpp
void drgn_symbol_result_builder_init(struct drgn_symbol_result_builder * builder, bool one)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/symbol.c:217

Initialize result builder

---

{#drgn_symbol_result_builder_abort}

### drgn_symbol_result_builder_abort

```cpp
void drgn_symbol_result_builder_abort(struct drgn_symbol_result_builder * builder)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/symbol.c:226

Destroy the contents of the result builder

---

{#drgn_symbol_result_builder_single}

### drgn_symbol_result_builder_single

```cpp
struct drgn_symbol * drgn_symbol_result_builder_single(struct drgn_symbol_result_builder * builder)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/symbol.c:238

Return single result

---

{#drgn_symbol_result_builder_array}

### drgn_symbol_result_builder_array

```cpp
void drgn_symbol_result_builder_array(struct drgn_symbol_result_builder * builder, struct drgn_symbol *** syms_ret, size_t * count_ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/symbol.c:243

Return array result

---

{#name_compar}

### name_compar

`static`

```cpp
static int name_compar(const void * lhs, const void * rhs, void * arg)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/symbol.c:250

---

{#addr_compar}

### addr_compar

`static`

```cpp
static int addr_compar(const void * lhs, const void * rhs)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/symbol.c:258

---

{#drgn_symbol_index_init}

### drgn_symbol_index_init

```cpp
struct drgn_error * drgn_symbol_index_init(struct drgn_symbol * symbols, uint32_t count, char * buffer, struct drgn_symbol_index * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/symbol.c:273

Create a symbol index from an array of symbols

This takes ownership of the symbol array and the individual symbols. The *buffer* argument allows us to provide a single backing buffer for all strings (in which case the lifetimes of each symbol name should be static). On error *symbols* and *buffer* are already freed, since the builder took ownership of them.

---

{#drgn_symbol_index_deinit}

### drgn_symbol_index_deinit

```cpp
void drgn_symbol_index_deinit(struct drgn_symbol_index * index)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/symbol.c:353

Deinitialize the symbol index. Safe to call multiple times.

---

{#address_search_range}

### address_search_range

`static`

```cpp
static void address_search_range(struct drgn_symbol_index * index, uint64_t address, uint32_t * start_ret, uint32_t * end_ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/symbol.c:365

---

{#drgn_symbol_index_find}

### drgn_symbol_index_find

```cpp
struct drgn_error * drgn_symbol_index_find(const char * name, uint64_t address, enum drgn_find_symbol_flags flags, void * arg, struct drgn_symbol_result_builder * builder)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/symbol.c:386

The actual implementation of the [Symbol](Symbol.md#symbol) Finder API.

---

{#drgn_symbol_index_builder_init}

### drgn_symbol_index_builder_init

```cpp
void drgn_symbol_index_builder_init(struct drgn_symbol_index_builder * builder)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/symbol.c:438

Create a symbol builder which will efficiently pack string names next to each other in memory, rather than allocating many small strings.

---

{#drgn_symbol_index_builder_deinit}

### drgn_symbol_index_builder_deinit

```cpp
void drgn_symbol_index_builder_deinit(struct drgn_symbol_index_builder * builder)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/symbol.c:445

For destroying a builder on error conditions. It is safe to call this multiple times, including after [drgn_symbol_index_init_from_builder()](#drgn_symbol_index_init_from_builder-1).

---

{#drgn_symbol_index_builder_add}

### drgn_symbol_index_builder_add

```cpp
bool drgn_symbol_index_builder_add(struct drgn_symbol_index_builder * builder, const struct drgn_symbol * ptr)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/symbol.c:452

Add symbol to the builder: the builder does not take ownership of *ptr*, instead making a copy.

---

{#drgn_symbol_index_init_from_builder}

### drgn_symbol_index_init_from_builder

```cpp
struct drgn_error * drgn_symbol_index_init_from_builder(struct drgn_symbol_index * index, struct drgn_symbol_index_builder * builder)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/symbol.c:465

Convert the builder to a symbol index, destroying the builder. On error, the builder and symbol index are both deinitialized, requiring no further cleanup.

---

{#thread_prog}

### Thread_prog

`static`

```cpp
static Program * Thread_prog(Thread * self)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/thread.c:8

---

{#thread_wrap-1}

### Thread_wrap

```cpp
PyObject * Thread_wrap(struct drgn_thread * thread)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/thread.c:13

---

{#thread_dealloc}

### Thread_dealloc

`static`

```cpp
static void Thread_dealloc(Thread * self)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/thread.c:28

---

{#thread_traverse}

### Thread_traverse

`static`

```cpp
static int Thread_traverse(Thread * self, visitproc visit, void * arg)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/thread.c:39

---

{#thread_get_tid}

### Thread_get_tid

`static`

```cpp
static PyObject * Thread_get_tid(Thread * self)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/thread.c:46

---

{#thread_get_object}

### Thread_get_object

`static`

```cpp
static DrgnObject * Thread_get_object(Thread * self)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/thread.c:51

---

{#thread_get_name}

### Thread_get_name

`static`

```cpp
static PyObject * Thread_get_name(Thread * self)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/thread.c:67

---

{#thread_stack_trace}

### Thread_stack_trace

`static`

```cpp
static PyObject * Thread_stack_trace(Thread * self)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/thread.c:79

---

{#threaditerator_dealloc}

### ThreadIterator_dealloc

`static`

```cpp
static void ThreadIterator_dealloc(ThreadIterator * self)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/thread.c:117

---

{#threaditerator_traverse}

### ThreadIterator_traverse

`static`

```cpp
static int ThreadIterator_traverse(ThreadIterator * self, visitproc visit, void * arg)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/thread.c:125

---

{#threaditerator_next}

### ThreadIterator_next

`static`

```cpp
static PyObject * ThreadIterator_next(ThreadIterator * self)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/thread.c:132

---

{#define_vector_type-10}

### DEFINE_VECTOR_TYPE

```cpp
DEFINE_VECTOR_TYPE(symbolp_vector, struct drgn_symbol *)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/symbol.h:33

---

{#drgn_symbol_cleanup}

### drgn_symbol_cleanup

`static` `inline`

```cpp
static inline void drgn_symbol_cleanup(struct drgn_symbol ** p)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/symbol.h:44

---

{#drgn_symbol_result_builder_abort-1}

### drgn_symbol_result_builder_abort

```cpp
void drgn_symbol_result_builder_abort(struct drgn_symbol_result_builder * builder)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/symbol.h:50

Destroy the contents of the result builder

---

{#drgn_symbol_result_builder_init-1}

### drgn_symbol_result_builder_init

```cpp
void drgn_symbol_result_builder_init(struct drgn_symbol_result_builder * builder, bool one)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/symbol.h:53

Initialize result builder

---

{#drgn_symbol_result_builder_add_from_elf-1}

### drgn_symbol_result_builder_add_from_elf

```cpp
bool drgn_symbol_result_builder_add_from_elf(struct drgn_symbol_result_builder * builder, const char * name, uint64_t address, const GElf_Sym * elf_sym)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/symbol.h:62

Convert an ELF symbol to a [drgn_symbol](drgn_symbol.md#drgn_symbol) and add it to a result builder.

#### Returns
`true` on success, `false` on failure to allocate memory.

---

{#drgn_symbol_result_builder_single-1}

### drgn_symbol_result_builder_single

```cpp
struct drgn_symbol * drgn_symbol_result_builder_single(struct drgn_symbol_result_builder * builder)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/symbol.h:68

Return single result

---

{#drgn_symbol_result_builder_array-1}

### drgn_symbol_result_builder_array

```cpp
void drgn_symbol_result_builder_array(struct drgn_symbol_result_builder * builder, struct drgn_symbol *** syms_ret, size_t * count_ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/symbol.h:71

Return array result

---

{#drgn_symbol_dup-1}

### drgn_symbol_dup

```cpp
struct drgn_symbol * drgn_symbol_dup(struct drgn_symbol * sym)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/symbol.h:74

---

{#define_hash_map-1}

### DEFINE_HASH_MAP

```cpp
DEFINE_HASH_MAP(drgn_symbol_name_table, const char *, struct { uint32_t start;uint32_t end;}, c_string_key_hash_pair, c_string_key_eq)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/symbol.h:76

---

{#drgn_symbol_index_init-1}

### drgn_symbol_index_init

```cpp
struct drgn_error * drgn_symbol_index_init(struct drgn_symbol * symbols, uint32_t count, char * buffer, struct drgn_symbol_index * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/symbol.h:123

Create a symbol index from an array of symbols

This takes ownership of the symbol array and the individual symbols. The *buffer* argument allows us to provide a single backing buffer for all strings (in which case the lifetimes of each symbol name should be static). On error *symbols* and *buffer* are already freed, since the builder took ownership of them.

---

{#drgn_symbol_index_deinit-1}

### drgn_symbol_index_deinit

```cpp
void drgn_symbol_index_deinit(struct drgn_symbol_index * index)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/symbol.h:127

Deinitialize the symbol index. Safe to call multiple times.

---

{#define_vector_type-11}

### DEFINE_VECTOR_TYPE

```cpp
DEFINE_VECTOR_TYPE(symbol_vector, struct drgn_symbol)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/symbol.h:129

---

{#drgn_symbol_index_builder_init-1}

### drgn_symbol_index_builder_init

```cpp
void drgn_symbol_index_builder_init(struct drgn_symbol_index_builder * builder)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/symbol.h:141

Create a symbol builder which will efficiently pack string names next to each other in memory, rather than allocating many small strings.

---

{#drgn_symbol_index_builder_deinit-1}

### drgn_symbol_index_builder_deinit

```cpp
void drgn_symbol_index_builder_deinit(struct drgn_symbol_index_builder * builder)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/symbol.h:148

For destroying a builder on error conditions. It is safe to call this multiple times, including after [drgn_symbol_index_init_from_builder()](#drgn_symbol_index_init_from_builder-1).

---

{#drgn_symbol_index_builder_add-1}

### drgn_symbol_index_builder_add

```cpp
bool drgn_symbol_index_builder_add(struct drgn_symbol_index_builder * builder, const struct drgn_symbol * ptr)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/symbol.h:155

Add symbol to the builder: the builder does not take ownership of *ptr*, instead making a copy.

---

{#drgn_symbol_index_init_from_builder-1}

### drgn_symbol_index_init_from_builder

```cpp
struct drgn_error * drgn_symbol_index_init_from_builder(struct drgn_symbol_index * index, struct drgn_symbol_index_builder * builder)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/symbol.h:164

Convert the builder to a symbol index, destroying the builder. On error, the builder and symbol index are both deinitialized, requiring no further cleanup.

---

{#drgn_symbol_index_find-1}

### drgn_symbol_index_find

```cpp
struct drgn_error * drgn_symbol_index_find(const char * name, uint64_t address, enum drgn_find_symbol_flags flags, void * arg, struct drgn_symbol_result_builder * builder)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/symbol.h:171

The actual implementation of the [Symbol](Symbol.md#symbol) Finder API.

---

{#freep}

### freep

`static` `inline`

```cpp
static inline void freep(void * p)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/cleanup.h:23

---

{#fclosep}

### fclosep

`static` `inline`

```cpp
static inline void fclosep(FILE ** fp)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/cleanup.h:30

---

{#closep}

### closep

`static` `inline`

```cpp
static inline void closep(int * fd)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/cleanup.h:38

---

{#closedirp}

### closedirp

`static` `inline`

```cpp
static inline void closedirp(DIR ** dirp)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/cleanup.h:46

---

{#drgn_handler_list_register}

### drgn_handler_list_register

```cpp
struct drgn_error * drgn_handler_list_register(struct drgn_handler_list * list, struct drgn_handler * new_handler, size_t enable_idx, const char * what)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/handler.c:11

---

{#drgn_handler_list_registered}

### drgn_handler_list_registered

```cpp
struct drgn_error * drgn_handler_list_registered(struct drgn_handler_list * list, const char *** names_ret, size_t * count_ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/handler.c:40

---

{#drgn_handler_entry_to_key}

### drgn_handler_entry_to_key

`static` `inline`

```cpp
static inline const char * drgn_handler_entry_to_key(const uintptr_t * entry)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/handler.c:63

---

{#define_hash_table-1}

### DEFINE_HASH_TABLE

```cpp
DEFINE_HASH_TABLE(drgn_handler_table, uintptr_t, drgn_handler_entry_to_key, c_string_key_hash_pair, c_string_key_eq)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/handler.c:68

---

{#drgn_handler_list_set_enabled}

### drgn_handler_list_set_enabled

```cpp
struct drgn_error * drgn_handler_list_set_enabled(struct drgn_handler_list * list, const char *const * names, size_t count, const char * what)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/handler.c:71

---

{#drgn_handler_list_enabled}

### drgn_handler_list_enabled

```cpp
struct drgn_error * drgn_handler_list_enabled(struct drgn_handler_list * list, const char *** names_ret, size_t * count_ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/handler.c:123

---

{#drgn_handler_list_disable}

### drgn_handler_list_disable

```cpp
bool drgn_handler_list_disable(struct drgn_handler_list * list, const char * name)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/handler.c:146

---

{#drgn_handler_list_register-1}

### drgn_handler_list_register

```cpp
struct drgn_error * drgn_handler_list_register(struct drgn_handler_list * list, struct drgn_handler * handler, size_t enable_index, const char * what)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/handler.h:36

---

{#drgn_handler_list_registered-1}

### drgn_handler_list_registered

```cpp
struct drgn_error * drgn_handler_list_registered(struct drgn_handler_list * list, const char *** names_ret, size_t * count_ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/handler.h:41

---

{#drgn_handler_list_set_enabled-1}

### drgn_handler_list_set_enabled

```cpp
struct drgn_error * drgn_handler_list_set_enabled(struct drgn_handler_list * list, const char *const * names, size_t count, const char * what)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/handler.h:45

---

{#drgn_handler_list_enabled-1}

### drgn_handler_list_enabled

```cpp
struct drgn_error * drgn_handler_list_enabled(struct drgn_handler_list * list, const char *** names_ret, size_t * count_ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/handler.h:50

---

{#drgn_handler_list_disable-1}

### drgn_handler_list_disable

```cpp
bool drgn_handler_list_disable(struct drgn_handler_list * list, const char * name)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/handler.h:54

---

{#drgn_handler_is_last_enabled}

### drgn_handler_is_last_enabled

`static` `inline`

```cpp
static inline bool drgn_handler_is_last_enabled(struct drgn_handler * handler)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/handler.h:57

---

{#drgn_handler_free_and_next}

### drgn_handler_free_and_next

`static` `inline`

```cpp
static inline struct drgn_handler * drgn_handler_free_and_next(struct drgn_handler * handler)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/handler.h:64

---

{#linux_helper_direct_mapping_offset}

### linux_helper_direct_mapping_offset

```cpp
struct drgn_error * linux_helper_direct_mapping_offset(struct drgn_program * prog, uint64_t * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/helpers.h:24

---

{#linux_helper_read_vm}

### linux_helper_read_vm

```cpp
struct drgn_error * linux_helper_read_vm(struct drgn_program * prog, uint64_t pgtable, uint64_t virt_addr, void * buf, size_t count)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/helpers.h:27

---

{#linux_helper_follow_phys}

### linux_helper_follow_phys

```cpp
struct drgn_error * linux_helper_follow_phys(struct drgn_program * prog, uint64_t pgtable, uint64_t virt_addr, uint64_t * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/helpers.h:31

---

{#linux_helper_per_cpu_ptr}

### linux_helper_per_cpu_ptr

```cpp
struct drgn_error * linux_helper_per_cpu_ptr(struct drgn_object * res, const struct drgn_object * ptr, uint64_t cpu)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/helpers.h:35

---

{#linux_helper_cpu_curr}

### linux_helper_cpu_curr

```cpp
struct drgn_error * linux_helper_cpu_curr(struct drgn_object * res, uint64_t cpu)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/helpers.h:39

---

{#linux_helper_idle_task}

### linux_helper_idle_task

```cpp
struct drgn_error * linux_helper_idle_task(struct drgn_object * res, uint64_t cpu)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/helpers.h:41

---

{#linux_helper_task_thread_info}

### linux_helper_task_thread_info

```cpp
struct drgn_error * linux_helper_task_thread_info(struct drgn_object * res, const struct drgn_object * task)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/helpers.h:45

---

{#linux_helper_task_cpu}

### linux_helper_task_cpu

```cpp
struct drgn_error * linux_helper_task_cpu(const struct drgn_object * task, uint64_t * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/helpers.h:48

---

{#linux_helper_task_on_cpu}

### linux_helper_task_on_cpu

```cpp
struct drgn_error * linux_helper_task_on_cpu(const struct drgn_object * task, bool * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/helpers.h:51

---

{#linux_helper_xa_load}

### linux_helper_xa_load

```cpp
struct drgn_error * linux_helper_xa_load(struct drgn_object * res, const struct drgn_object * xa, uint64_t index)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/helpers.h:55

---

{#linux_helper_idr_find}

### linux_helper_idr_find

```cpp
struct drgn_error * linux_helper_idr_find(struct drgn_object * res, const struct drgn_object * idr, uint64_t id)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/helpers.h:58

---

{#linux_helper_find_pid}

### linux_helper_find_pid

```cpp
struct drgn_error * linux_helper_find_pid(struct drgn_object * res, const struct drgn_object * ns, uint64_t pid)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/helpers.h:62

---

{#linux_helper_pid_task}

### linux_helper_pid_task

```cpp
struct drgn_error * linux_helper_pid_task(struct drgn_object * res, const struct drgn_object * pid, uint64_t pid_type)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/helpers.h:66

---

{#linux_helper_find_task}

### linux_helper_find_task

```cpp
struct drgn_error * linux_helper_find_task(struct drgn_object * res, const struct drgn_object * ns, uint64_t pid)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/helpers.h:70

---

{#linux_helper_task_iterator_init}

### linux_helper_task_iterator_init

```cpp
struct drgn_error * linux_helper_task_iterator_init(struct linux_helper_task_iterator * it, struct drgn_program * prog)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/helpers.h:84

---

{#linux_helper_task_iterator_deinit}

### linux_helper_task_iterator_deinit

```cpp
void linux_helper_task_iterator_deinit(struct linux_helper_task_iterator * it)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/helpers.h:87

---

{#linux_helper_task_iterator_next}

### linux_helper_task_iterator_next

```cpp
struct drgn_error * linux_helper_task_iterator_next(struct linux_helper_task_iterator * it, struct drgn_object * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/helpers.h:91

Get the next task from a [linux_helper_task_iterator](linux_helper_task_iterator.md#linux_helper_task_iterator).

---

{#nstring_eq}

### nstring_eq

`static` `inline`

```cpp
static inline bool nstring_eq(const struct nstring * a, const struct nstring * b)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/nstring.h:28

Compare two [nstring](nstring.md#nstring) keys for equality.

---

{#drgn_call_plugins_prog}

### drgn_call_plugins_prog

```cpp
void drgn_call_plugins_prog(const char * name, struct drgn_program * prog)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/plugins.h:9

---

{#drgnpy_linux_helper_direct_mapping_offset-1}

### drgnpy_linux_helper_direct_mapping_offset

```cpp
PyObject * drgnpy_linux_helper_direct_mapping_offset(PyObject * self, PyObject * arg)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/helpers.c:9

---

{#drgnpy_linux_helper_read_vm-1}

### drgnpy_linux_helper_read_vm

```cpp
PyObject * drgnpy_linux_helper_read_vm(PyObject * self, PyObject * args, PyObject * kwds)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/helpers.c:23

---

{#drgnpy_linux_helper_follow_phys-1}

### drgnpy_linux_helper_follow_phys

```cpp
PyObject * drgnpy_linux_helper_follow_phys(PyObject * self, PyObject * args, PyObject * kwds)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/helpers.c:52

---

{#drgnpy_linux_helper_per_cpu_ptr-1}

### drgnpy_linux_helper_per_cpu_ptr

```cpp
DrgnObject * drgnpy_linux_helper_per_cpu_ptr(PyObject * self, PyObject * args, PyObject * kwds)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/helpers.c:74

---

{#drgnpy_linux_helper_cpu_curr-1}

### drgnpy_linux_helper_cpu_curr

```cpp
DrgnObject * drgnpy_linux_helper_cpu_curr(PyObject * self, PyObject * args)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/helpers.c:95

---

{#drgnpy_linux_helper_idle_task-1}

### drgnpy_linux_helper_idle_task

```cpp
DrgnObject * drgnpy_linux_helper_idle_task(PyObject * self, PyObject * args)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/helpers.c:113

---

{#drgnpy_linux_helper_task_thread_info-1}

### drgnpy_linux_helper_task_thread_info

```cpp
DrgnObject * drgnpy_linux_helper_task_thread_info(PyObject * self, PyObject * args, PyObject * kwds)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/helpers.c:131

---

{#drgnpy_linux_helper_task_cpu-1}

### drgnpy_linux_helper_task_cpu

```cpp
PyObject * drgnpy_linux_helper_task_cpu(PyObject * self, PyObject * args, PyObject * kwds)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/helpers.c:151

---

{#drgnpy_linux_helper_task_on_cpu-1}

### drgnpy_linux_helper_task_on_cpu

```cpp
PyObject * drgnpy_linux_helper_task_on_cpu(PyObject * self, PyObject * args, PyObject * kwds)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/helpers.c:168

---

{#drgnpy_linux_helper_xa_load-1}

### drgnpy_linux_helper_xa_load

```cpp
DrgnObject * drgnpy_linux_helper_xa_load(PyObject * self, PyObject * args, PyObject * kwds)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/helpers.c:185

---

{#drgnpy_linux_helper_idr_find-1}

### drgnpy_linux_helper_idr_find

```cpp
DrgnObject * drgnpy_linux_helper_idr_find(PyObject * self, PyObject * args, PyObject * kwds)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/helpers.c:206

---

{#drgnpy_linux_helper_find_pid-1}

### drgnpy_linux_helper_find_pid

```cpp
DrgnObject * drgnpy_linux_helper_find_pid(PyObject * self, PyObject * args)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/helpers.c:228

---

{#drgnpy_linux_helper_pid_task-1}

### drgnpy_linux_helper_pid_task

```cpp
DrgnObject * drgnpy_linux_helper_pid_task(PyObject * self, PyObject * args, PyObject * kwds)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/helpers.c:247

---

{#drgnpy_linux_helper_find_task-1}

### drgnpy_linux_helper_find_task

```cpp
DrgnObject * drgnpy_linux_helper_find_task(PyObject * self, PyObject * args)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/helpers.c:268

---

{#drgnpy_linux_helper_kaslr_offset-1}

### drgnpy_linux_helper_kaslr_offset

```cpp
PyObject * drgnpy_linux_helper_kaslr_offset(PyObject * self, PyObject * arg)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/helpers.c:287

---

{#drgnpy_linux_helper_pgtable_l5_enabled-1}

### drgnpy_linux_helper_pgtable_l5_enabled

```cpp
PyObject * drgnpy_linux_helper_pgtable_l5_enabled(PyObject * self, PyObject * arg)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/helpers.c:300

---

{#drgnpy_linux_helper_load_proc_kallsyms-1}

### drgnpy_linux_helper_load_proc_kallsyms

```cpp
PyObject * drgnpy_linux_helper_load_proc_kallsyms(PyObject * self, PyObject * args, PyObject * kwds)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/helpers.c:313

---

{#drgnpy_linux_helper_load_builtin_kallsyms-1}

### drgnpy_linux_helper_load_builtin_kallsyms

```cpp
PyObject * drgnpy_linux_helper_load_builtin_kallsyms(PyObject * self, PyObject * args, PyObject * kwds)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/helpers.c:336

---

{#drgn_call_plugins_prog-1}

### drgn_call_plugins_prog

```cpp
void drgn_call_plugins_prog(const char * name, struct drgn_program * prog)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/plugins.c:8

---

{#drgn_thread_to_key}

### drgn_thread_to_key

`static` `inline`

```cpp
static inline uint32_t drgn_thread_to_key(const struct drgn_thread * entry)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.c:40

---

{#define_hash_table_functions-1}

### DEFINE_HASH_TABLE_FUNCTIONS

```cpp
DEFINE_HASH_TABLE_FUNCTIONS(drgn_thread_set, drgn_thread_to_key, int_key_hash_pair, scalar_key_eq)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.c:45

---

{#drgn_program_check_initialized_virtual}

### drgn_program_check_initialized_virtual

`static`

```cpp
static struct drgn_error * drgn_program_check_initialized_virtual(struct drgn_program * prog)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.c:309

---

{#has_kdump_signature}

### has_kdump_signature

`static`

```cpp
static struct drgn_error * has_kdump_signature(struct drgn_program * prog, const char * path, bool * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.c:320

---

{#drgn_program_set_core_dump_fd_internal}

### drgn_program_set_core_dump_fd_internal

`static`

```cpp
static struct drgn_error * drgn_program_set_core_dump_fd_internal(struct drgn_program * prog, int fd, const char * path)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.c:341

---

{#get_prstatus_pid}

### get_prstatus_pid

`static`

```cpp
static struct drgn_error * get_prstatus_pid(struct drgn_program * prog, const char * data, size_t size, uint32_t * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.c:973

---

{#get_prpsinfo_pid}

### get_prpsinfo_pid

`static`

```cpp
static struct drgn_error * get_prpsinfo_pid(struct drgn_program * prog, const char * data, size_t size, uint32_t * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.c:997

---

{#get_prpsinfo_fname}

### get_prpsinfo_fname

`static`

```cpp
static struct drgn_error * get_prpsinfo_fname(struct drgn_program * prog, const char * data, size_t size, char ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.c:1022

---

{#drgn_program_cache_core_dump_threads}

### drgn_program_cache_core_dump_threads

`static`

```cpp
static struct drgn_error * drgn_program_cache_core_dump_threads(struct drgn_program * prog)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.c:1117

---

{#drgn_thread_iterator_init_linux_kernel}

### drgn_thread_iterator_init_linux_kernel

`static`

```cpp
static struct drgn_error * drgn_thread_iterator_init_linux_kernel(struct drgn_thread_iterator * it)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.c:1247

---

{#drgn_thread_iterator_init_userspace_process}

### drgn_thread_iterator_init_userspace_process

`static`

```cpp
static struct drgn_error * drgn_thread_iterator_init_userspace_process(struct drgn_thread_iterator * it)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.c:1259

---

{#drgn_thread_iterator_init_userspace_core}

### drgn_thread_iterator_init_userspace_core

`static`

```cpp
static struct drgn_error * drgn_thread_iterator_init_userspace_core(struct drgn_thread_iterator * it)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.c:1277

---

{#drgn_thread_iterator_next_linux_kernel}

### drgn_thread_iterator_next_linux_kernel

`static`

```cpp
static struct drgn_error * drgn_thread_iterator_next_linux_kernel(struct drgn_thread_iterator * it, struct drgn_thread ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.c:1324

---

{#drgn_thread_iterator_next_userspace_process}

### drgn_thread_iterator_next_userspace_process

`static`

```cpp
static struct drgn_error * drgn_thread_iterator_next_userspace_process(struct drgn_thread_iterator * it, struct drgn_thread ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.c:1350

---

{#drgn_thread_iterator_next_userspace_core}

### drgn_thread_iterator_next_userspace_core

`static`

```cpp
static void drgn_thread_iterator_next_userspace_core(struct drgn_thread_iterator * it, struct drgn_thread ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.c:1381

---

{#drgn_program_find_thread_linux_kernel}

### drgn_program_find_thread_linux_kernel

`static`

```cpp
static struct drgn_error * drgn_program_find_thread_linux_kernel(struct drgn_program * prog, uint32_t tid, struct drgn_thread ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.c:1407

---

{#drgn_program_find_thread_userspace_process}

### drgn_program_find_thread_userspace_process

`static`

```cpp
static struct drgn_error * drgn_program_find_thread_userspace_process(struct drgn_program * prog, uint32_t tid, struct drgn_thread ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.c:1447

---

{#drgn_program_find_thread_userspace_core}

### drgn_program_find_thread_userspace_core

`static`

```cpp
static struct drgn_error * drgn_program_find_thread_userspace_core(struct drgn_program * prog, uint32_t tid, struct drgn_thread ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.c:1477

---

{#drgn_program_kernel_get_crashed_cpu}

### drgn_program_kernel_get_crashed_cpu

`static`

```cpp
static struct drgn_error * drgn_program_kernel_get_crashed_cpu(struct drgn_program * prog, uint64_t * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.c:1506

---

{#drgn_program_find_thread_kernel_cpu_curr}

### drgn_program_find_thread_kernel_cpu_curr

`static`

```cpp
static struct drgn_error * drgn_program_find_thread_kernel_cpu_curr(struct drgn_program * prog, uint64_t cpu, struct drgn_thread ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.c:1559

---

{#drgn_program_kernel_core_dump_cache_crashed_thread}

### drgn_program_kernel_core_dump_cache_crashed_thread

`static`

```cpp
static struct drgn_error * drgn_program_kernel_core_dump_cache_crashed_thread(struct drgn_program * prog)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.c:1597

---

{#drgn_thread_name_linux_kernel}

### drgn_thread_name_linux_kernel

`static`

```cpp
static struct drgn_error * drgn_thread_name_linux_kernel(struct drgn_thread * thread, char ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.c:1680

---

{#drgn_thread_name_userspace_process}

### drgn_thread_name_userspace_process

`static`

```cpp
static struct drgn_error * drgn_thread_name_userspace_process(struct drgn_thread * thread, char ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.c:1691

---

{#drgn_thread_name_userspace_core}

### drgn_thread_name_userspace_core

`static`

```cpp
static struct drgn_error * drgn_thread_name_userspace_core(struct drgn_thread * thread, char ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.c:1720

---

{#define_vector-2}

### DEFINE_VECTOR

```cpp
DEFINE_VECTOR(char_vector, char)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.c:1917

---

{#drgn_program_symbols_search}

### drgn_program_symbols_search

`static`

```cpp
static struct drgn_error * drgn_program_symbols_search(struct drgn_program * prog, const char * name, uint64_t addr, enum drgn_find_symbol_flags flags, struct drgn_symbol_result_builder * builder)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.c:2075

---

{#drgn_c_family_lexer_func}

### drgn_c_family_lexer_func

```cpp
struct drgn_error * drgn_c_family_lexer_func(struct drgn_lexer * lexer, struct drgn_token * token)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/c_lexer.h:57

---

{#drgn_c_family_lexer_deinit}

### drgn_c_family_lexer_deinit

`static` `inline`

```cpp
static inline void drgn_c_family_lexer_deinit(struct drgn_c_family_lexer * lexer)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/c_lexer.h:61

---

{#cityhash_fetch32}

### cityhash_fetch32

`static` `inline`

```cpp
static inline uint32_t cityhash_fetch32(const uint8_t * p)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/cityhash.h:11

---

{#cityhash_fetch64}

### cityhash_fetch64

`static` `inline`

```cpp
static inline uint64_t cityhash_fetch64(const uint8_t * p)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/cityhash.h:19

---

{#cityhash_fmix}

### cityhash_fmix

`static`

```cpp
static uint32_t cityhash_fmix(uint32_t h)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/cityhash.h:35

---

{#cityhash_rotate32}

### cityhash_rotate32

`static`

```cpp
static uint32_t cityhash_rotate32(uint32_t x, int b)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/cityhash.h:45

---

{#cityhash_mur}

### cityhash_mur

`static`

```cpp
static uint32_t cityhash_mur(uint32_t a, uint32_t h)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/cityhash.h:49

---

{#cityhash32_len_13to24}

### cityhash32_len_13to24

`static`

```cpp
static uint32_t cityhash32_len_13to24(const uint8_t * s, size_t len)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/cityhash.h:58

---

{#cityhash32_len_0to4}

### cityhash32_len_0to4

`static`

```cpp
static uint32_t cityhash32_len_0to4(const uint8_t * s, size_t len)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/cityhash.h:70

---

{#cityhash32_len_5to12}

### cityhash32_len_5to12

`static`

```cpp
static uint32_t cityhash32_len_5to12(const uint8_t * s, size_t len)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/cityhash.h:81

---

{#__attribute__-7}

### __attribute__

`const`

```cpp
__attribute__((__unused__)) const
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/cityhash.h:89

---

{#if}

### if

```cpp
if(len<= 4)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/cityhash.h:93

---

{#while}

### while

```cpp
while(--iters ! = 0)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/cityhash.h:151

---

{#cityhash_rotate}

### cityhash_rotate

`static` `inline`

```cpp
static inline uint64_t cityhash_rotate(uint64_t x, int b)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/cityhash.h:174

---

{#cityhash_shiftmix}

### cityhash_shiftmix

`static` `inline`

```cpp
static inline uint64_t cityhash_shiftmix(uint64_t val)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/cityhash.h:179

---

{#cityhash_128_to_64}

### cityhash_128_to_64

`static` `inline`

```cpp
static inline uint64_t cityhash_128_to_64(uint64_t lo, uint64_t hi)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/cityhash.h:184

---

{#cityhash_len_16}

### cityhash_len_16

`static` `inline`

```cpp
static inline uint64_t cityhash_len_16(uint64_t u, uint64_t v, uint64_t mul)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/cityhash.h:194

---

{#cityhash_len_0to16}

### cityhash_len_0to16

`static`

```cpp
static uint64_t cityhash_len_0to16(const uint8_t * s, size_t len)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/cityhash.h:204

---

{#cityhash_len_17to32}

### cityhash_len_17to32

`static`

```cpp
static uint64_t cityhash_len_17to32(const uint8_t * s, size_t len)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/cityhash.h:230

---

{#cityhash_weak_len_32_with_seeds}

### cityhash_weak_len_32_with_seeds

`static`

```cpp
static struct cityhash_pair cityhash_weak_len_32_with_seeds(const uint8_t * s, uint64_t a, uint64_t b)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/cityhash.h:243

---

{#cityhash_len_33to64}

### cityhash_len_33to64

`static`

```cpp
static uint64_t cityhash_len_33to64(const uint8_t * s, size_t len)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/cityhash.h:260

---

{#while-1}

### while

```cpp
while(len ! = 0)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/cityhash.h:326

---

{#cityhash_128_to_64-1}

### cityhash_128_to_64

```cpp
return cityhash_128_to_64(cityhash_128_to_64(v.first, w.first)+cityhash_shiftmix(y) *cityhash_k1+ z, cityhash_128_to_64(v.second, w.second)+ x)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/cityhash.h:327

---

{#cityhash_size_t}

### cityhash_size_t

`static` `inline`

```cpp
static inline size_t cityhash_size_t(const void * data, size_t len)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/cityhash.h:331

---

{#guess_long_names}

### guess_long_names

`static`

```cpp
static bool guess_long_names(struct drgn_program * prog)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/kallsyms.c:89

---

{#kallsyms_copy_tables}

### kallsyms_copy_tables

`static`

```cpp
static struct drgn_error * kallsyms_copy_tables(struct drgn_program * prog, struct kallsyms_reader * kr, struct kallsyms_locations * loc)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/kallsyms.c:115

Copy the kallsyms names tables from the program into host memory.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `prog` | struct [`drgn_program`](drgn_program.md#drgn_program) * | [Program](Program.md#program) to read from |
| `kr` | struct [`kallsyms_reader`](kallsyms_reader.md#kallsyms_reader) * | [kallsyms_reader](kallsyms_reader.md#kallsyms_reader) to populate |

---

{#kallsyms_binary_buffer_error}

### kallsyms_binary_buffer_error

`static`

```cpp
static struct drgn_error * kallsyms_binary_buffer_error(struct binary_buffer * bb, const char * pos, const char * message)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/kallsyms.c:231

---

{#kallsyms_expand_symbol}

### kallsyms_expand_symbol

`static`

```cpp
static struct drgn_error * kallsyms_expand_symbol(struct kallsyms_reader * kr, struct binary_buffer * names_bb, struct string_builder * sb, char * kind_ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/kallsyms.c:249

Extract the symbol name and type 
#### Returns
NULL on success, or an error

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `kr` | struct [`kallsyms_reader`](kallsyms_reader.md#kallsyms_reader) * | Registry containing kallsyms data |
| `names_bb` | struct [`binary_buffer`](binary_buffer.md#binary_buffer) * | A binary buffer tracking our position within the `kallsyms_names` array |
| `sb` | struct [`string_builder`](string_builder.md#string_builder-1) * | Buffer to write output symbol to |
| `kind_ret` | `char *` | Where to write the symbol kind data |

---

{#search_for_string}

### search_for_string

`static`

```cpp
static struct drgn_error * search_for_string(struct kallsyms_reader * kr, const char * name, size_t * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/kallsyms.c:297

Used to find _stext in the kallsyms before we've moved everything into the [drgn_symbol_index](drgn_symbol_index.md#drgn_symbol_index). Finds the index matching the given name.

---

{#symbol_from_kallsyms}

### symbol_from_kallsyms

`static`

```cpp
static void symbol_from_kallsyms(uint64_t address, char * name, char kind, uint64_t size, struct drgn_symbol * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/kallsyms.c:320

---

{#absolute_percpu}

### absolute_percpu

`static`

```cpp
static uint64_t absolute_percpu(uint64_t base, int32_t val)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/kallsyms.c:361

Compute an address via the CONFIG_KALLSYMS_ABSOLUTE_PERCPU method

---

{#kallsyms_load_addresses}

### kallsyms_load_addresses

`static`

```cpp
static struct drgn_error * kallsyms_load_addresses(struct drgn_program * prog, struct kallsyms_reader * kr, struct kallsyms_locations * loc, uint64_t ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/kallsyms.c:431

Load the kallsyms address information from *prog*

Built-in kallsyms can be stored in (at least) 4 different ways, depending on the kernel version and configuration. Drgn supports all of them.

Absolute kallsyms: [v2.6 era, v6.11) Kconfig: NONE (default when kallsyms is enabled) Addresses are directly stored in: unsigned long kallsyms_addresses[] This was the only option until v4.6, and it was used by all arches.

Base relative: [v4.6, v7.0) Kconfig: [v4.6, 6.11): CONFIG_KALLSYMS_BASE_RELATIVE [v6.11, v7.0): NONE (default when kallsyms is enabled) Addresses are stored as offsets in: int kallsyms_offsets[]. The offsets are from "kallsyms_relative_base". This was added to reduce memory usage on 64-bit architectures. It became the de-facto default, except for architectures with large gaps in symbol addresses (like x86_64).

Absolute percpu: [v4.6, v6.15) Kconfig: CONFIG_KALLSYMS_ABSOLUTE_PERCPU Addresses are encoded in: int kallsyms_offsets[]. Negative values are negated offsets from "kallsyms_relative_base". Positive values are absolute addresses. This alternative was added alongside base-relative encoding, mainly to support x86_64, where percpu addresses were low addresses near zero.

Place relative: [v7.0, present) Kconfig: NONE (default when kallsyms is enabled) Addresses are stored as offsets in: int kallsyms_offsets[]. Offsets are relative to the memory address at which they are stored. This was introduced as a simplification after absolute percpu was eliminated. For some 32-bit architectures kernel relocation is not supported, so these architectures use absolute addresses. Drgn does not support those architectures but this code should work for them nonetheless.

In addition, to read these, the kallsyms variable locations must be encoded in VMCOREINFO. This happened in v6.0, but those commits have been backported in some distributions.

Relevant commit history:

v4.6 - introduces base relative and absolute percpu. 2213e9a66bb87 ("kallsyms: add support for relative offsets in kallsyms address table") v6.0 - adds kallsyms symbols to vmcoreinfo 5fd8fea935a10 ("vmcoreinfo: include kallsyms symbols") f09bddbd86619 ("vmcoreinfo: add kallsyms_num_syms symbol") v6.11 - removes absolute kallsyms 64e166099b69b ("kallsyms: get rid of code for absolute kallsyms") v6.15 - removes absolute percpu 01157ddc58dc2 ("kallsyms: Remove KALLSYMS_ABSOLUTE_PERCPU") v7.0 - replaces base relative with place relative a081b5789255d ("kallsyms: Get rid of kallsyms relative base")

#### Returns
NULL on success, or error

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `prog` | struct [`drgn_program`](drgn_program.md#drgn_program) * | The program to read from |
| `kr` | struct [`kallsyms_reader`](kallsyms_reader.md#kallsyms_reader) * | The symbol registry to fill |

---

{#kallsyms_reader_cleanup}

### kallsyms_reader_cleanup

`static`

```cpp
static void kallsyms_reader_cleanup(struct kallsyms_reader * kr)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/kallsyms.c:555

---

{#drgn_load_builtin_kallsyms}

### drgn_load_builtin_kallsyms

```cpp
struct drgn_error * drgn_load_builtin_kallsyms(struct drgn_program * prog, struct kallsyms_locations * loc, struct drgn_symbol_index * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/kallsyms.c:563

Initialize a symbol index containing symbols from built-in kallsyms tables

---

{#drgn_load_proc_kallsyms}

### drgn_load_proc_kallsyms

```cpp
struct drgn_error * drgn_load_proc_kallsyms(const char * filename, bool modules, struct drgn_symbol_index * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/kallsyms.c:619

Load kallsyms directly from the /proc/kallsyms file

---

{#drgn_load_proc_kallsyms-1}

### drgn_load_proc_kallsyms

```cpp
struct drgn_error * drgn_load_proc_kallsyms(const char * filename, bool modules, struct drgn_symbol_index * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/kallsyms.h:35

Initialize a symbol index containing symbols from /proc/kallsyms

Load kallsyms directly from the /proc/kallsyms file

---

{#drgn_load_builtin_kallsyms-1}

### drgn_load_builtin_kallsyms

```cpp
struct drgn_error * drgn_load_builtin_kallsyms(struct drgn_program * prog, struct kallsyms_locations * loc, struct drgn_symbol_index * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/kallsyms.h:42

Initialize a symbol index containing symbols from built-in kallsyms tables

---

{#fallback_unwind_arm}

### fallback_unwind_arm

`static`

```cpp
static struct drgn_error * fallback_unwind_arm(struct drgn_program * prog, struct drgn_register_state * regs, struct drgn_register_state ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/arch_arm.c:40

---

{#get_initial_registers_from_struct_arm}

### get_initial_registers_from_struct_arm

`static`

```cpp
static struct drgn_error * get_initial_registers_from_struct_arm(struct drgn_program * prog, const void * buf, size_t size, struct drgn_register_state ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/arch_arm.c:55

---

{#pt_regs_get_initial_registers_arm}

### pt_regs_get_initial_registers_arm

`static`

```cpp
static struct drgn_error * pt_regs_get_initial_registers_arm(const struct drgn_object * obj, struct drgn_register_state ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/arch_arm.c:84

---

{#prstatus_get_initial_registers_arm}

### prstatus_get_initial_registers_arm

`static`

```cpp
static struct drgn_error * prstatus_get_initial_registers_arm(struct drgn_program * prog, const void * prstatus, size_t size, struct drgn_register_state ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/arch_arm.c:94

---

{#linux_kernel_get_initial_registers_arm}

### linux_kernel_get_initial_registers_arm

`static`

```cpp
static struct drgn_error * linux_kernel_get_initial_registers_arm(const struct drgn_object * task_obj, struct drgn_register_state ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/arch_arm.c:113

---

{#apply_elf_reloc_arm}

### apply_elf_reloc_arm

`static`

```cpp
static struct drgn_error * apply_elf_reloc_arm(const struct drgn_relocating_section * relocating, uint64_t r_offset, uint32_t r_type, const int64_t * r_addend, uint64_t sym_value)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/arch_arm.c:151

---

{#linux_kernel_pgtable_iterator_arch_create_arm}

### linux_kernel_pgtable_iterator_arch_create_arm

`static`

```cpp
static struct drgn_error * linux_kernel_pgtable_iterator_arch_create_arm(struct drgn_program * prog, void ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/arch_arm.c:186

---

{#linux_kernel_pgtable_iterator_init_arm}

### linux_kernel_pgtable_iterator_init_arm

`static`

```cpp
static void linux_kernel_pgtable_iterator_init_arm(struct drgn_program * prog, struct pgtable_iterator * it)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/arch_arm.c:196

---

{#linux_kernel_pgtable_iterator_next_arm_lpae}

### linux_kernel_pgtable_iterator_next_arm_lpae

`static`

```cpp
static struct drgn_error * linux_kernel_pgtable_iterator_next_arm_lpae(struct drgn_program * prog, struct pgtable_iterator * it, uint64_t * virt_addr_ret, uint64_t * phys_addr_ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/arch_arm.c:205

---

{#linux_kernel_pgtable_iterator_next_arm}

### linux_kernel_pgtable_iterator_next_arm

`static`

```cpp
static struct drgn_error * linux_kernel_pgtable_iterator_next_arm(struct drgn_program * prog, struct pgtable_iterator * it, uint64_t * virt_addr_ret, uint64_t * phys_addr_ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/arch_arm.c:253

---

{#linux_kernel_section_size_bits_fallback_arm}

### linux_kernel_section_size_bits_fallback_arm

`static`

```cpp
static int linux_kernel_section_size_bits_fallback_arm(struct drgn_program * prog)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/arch_arm.c:326

---

{#linux_kernel_max_physmem_bits_fallback_arm}

### linux_kernel_max_physmem_bits_fallback_arm

`static`

```cpp
static int linux_kernel_max_physmem_bits_fallback_arm(struct drgn_program * prog)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/arch_arm.c:331

---

{#drgn_elf_file_create_cleanup}

### drgn_elf_file_create_cleanup

`static`

```cpp
static void drgn_elf_file_create_cleanup(struct drgn_elf_file ** filep)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/elf_file.c:45

---

{#should_apply_relocation_section}

### should_apply_relocation_section

`static`

```cpp
static int should_apply_relocation_section(Elf * elf, size_t shstrndx, const GElf_Shdr * shdr)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/elf_file.c:247

---

{#get_reloc_sym_value}

### get_reloc_sym_value

`static` `inline`

```cpp
static inline struct drgn_error * get_reloc_sym_value(const void * syms, size_t num_syms, const uint64_t * sh_addrs, size_t shdrnum, bool is_64_bit, bool bswap, uint32_t r_sym, uint64_t * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/elf_file.c:269

---

{#apply_elf_relas}

### apply_elf_relas

`static`

```cpp
static struct drgn_error * apply_elf_relas(const struct drgn_relocating_section * relocating, Elf_Data * reloc_data, Elf_Data * symtab_data, const uint64_t * sh_addrs, size_t shdrnum, const struct drgn_platform * platform)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/elf_file.c:312

---

{#apply_elf_rels}

### apply_elf_rels

`static`

```cpp
static struct drgn_error * apply_elf_rels(const struct drgn_relocating_section * relocating, Elf_Data * reloc_data, Elf_Data * symtab_data, const uint64_t * sh_addrs, size_t shdrnum, const struct drgn_platform * platform)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/elf_file.c:382

---

{#drgn_elf_file_apply_relocations}

### drgn_elf_file_apply_relocations

`static`

```cpp
static struct drgn_error * drgn_elf_file_apply_relocations(struct drgn_elf_file * file)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/elf_file.c:445

---

{#drgn_elf_file_section_errorf-1}

### drgn_elf_file_section_errorf

```cpp
struct drgn_error * drgn_elf_file_section_errorf(struct drgn_elf_file * file, Elf_Scn * scn, Elf_Data * data, const char * ptr, const char * format, ...)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/elf_file.c:689

---

{#elf_address_range_from_first_and_last_segment}

### elf_address_range_from_first_and_last_segment

`static`

```cpp
static bool elf_address_range_from_first_and_last_segment(Elf * elf, uint64_t * start_ret, uint64_t * end_ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/elf_file.c:716

---

{#elf_address_range_from_min_and_max_segment}

### elf_address_range_from_min_and_max_segment

`static`

```cpp
static bool elf_address_range_from_min_and_max_segment(Elf * elf, uint64_t * start_ret, uint64_t * end_ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/elf_file.c:763

---

{#define_vector-3}

### DEFINE_VECTOR

```cpp
DEFINE_VECTOR(uint64_range_vector, struct uint64_range)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/orc_info.c:22

---

{#drgn_module_orc_info_deinit}

### drgn_module_orc_info_deinit

```cpp
void drgn_module_orc_info_deinit(struct drgn_module * module)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/orc_info.c:26

---

{#drgn_raw_orc_pc}

### drgn_raw_orc_pc

`static` `inline`

```cpp
static inline uint64_t drgn_raw_orc_pc(struct drgn_module * module, unsigned int i)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/orc_info.c:35

---

{#drgn_raw_orc_entry_is_terminator}

### drgn_raw_orc_entry_is_terminator

`static`

```cpp
static bool drgn_raw_orc_entry_is_terminator(struct drgn_module * module, unsigned int i)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/orc_info.c:46

---

{#drgn_raw_orc_entry_is_preferred}

### drgn_raw_orc_entry_is_preferred

`static`

```cpp
static bool drgn_raw_orc_entry_is_preferred(struct drgn_module * module, unsigned int i)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/orc_info.c:65

---

{#compare_orc_entries}

### compare_orc_entries

`static`

```cpp
static int compare_orc_entries(const void * a, const void * b, void * arg)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/orc_info.c:82

---

{#keep_orc_entry}

### keep_orc_entry

`static`

```cpp
static unsigned int keep_orc_entry(struct drgn_module * module, unsigned int * indices, unsigned int num_entries, unsigned int i)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/orc_info.c:103

---

{#remove_fdes_from_orc}

### remove_fdes_from_orc

`static`

```cpp
static struct drgn_error * remove_fdes_from_orc(struct drgn_module * module, unsigned int * indices, struct uint64_range_vector * preferred, unsigned int * num_entriesp)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/orc_info.c:132

---

{#orc_version_from_header}

### orc_version_from_header

`static`

```cpp
static int orc_version_from_header(const void * buffer)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/orc_info.c:227

---

{#orc_version_from_osrelease}

### orc_version_from_osrelease

`static`

```cpp
static int orc_version_from_osrelease(struct drgn_program * prog)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/orc_info.c:261

---

{#drgn_read_orc_sections}

### drgn_read_orc_sections

`static`

```cpp
static struct drgn_error * drgn_read_orc_sections(struct drgn_module * module)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/orc_info.c:291

---

{#copy_builtin_orc_buffers}

### copy_builtin_orc_buffers

`static`

```cpp
static struct drgn_error * copy_builtin_orc_buffers(struct drgn_module * module, uint64_t num_entries, uint64_t unwind, uint64_t unwind_ip, uint64_t header)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/orc_info.c:392

---

{#drgn_read_vmlinux_orc}

### drgn_read_vmlinux_orc

`static`

```cpp
static struct drgn_error * drgn_read_vmlinux_orc(struct drgn_module * module)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/orc_info.c:442

---

{#drgn_read_builtin_orc}

### drgn_read_builtin_orc

`static`

```cpp
static struct drgn_error * drgn_read_builtin_orc(struct drgn_module * module)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/orc_info.c:497

---

{#drgn_module_clear_orc}

### drgn_module_clear_orc

`static` `inline`

```cpp
static inline void drgn_module_clear_orc(struct drgn_module ** modulep)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/orc_info.c:561

---

{#drgn_module_parse_orc}

### drgn_module_parse_orc

```cpp
struct drgn_error * drgn_module_parse_orc(struct drgn_module * module, bool use_builtin)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/orc_info.c:569

---

{#drgn_module_should_prefer_orc_cfi}

### drgn_module_should_prefer_orc_cfi

```cpp
bool drgn_module_should_prefer_orc_cfi(struct drgn_module * module, uint64_t pc)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/orc_info.c:739

---

{#drgn_orc_pc}

### drgn_orc_pc

`static` `inline`

```cpp
static inline uint64_t drgn_orc_pc(struct drgn_module * module, unsigned int i)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/orc_info.c:750

---

{#drgn_module_find_orc_cfi}

### drgn_module_find_orc_cfi

```cpp
struct drgn_error * drgn_module_find_orc_cfi(struct drgn_module * module, uint64_t pc, struct drgn_cfi_row ** row_ret, bool * interrupted_ret, drgn_register_number * ret_addr_regno_ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/orc_info.c:756

---

{#copy_bits_step}

### copy_bits_step

`static` `inline`

```cpp
static inline uint8_t copy_bits_step(const uint8_t * s, unsigned int src_bit_offset, unsigned int bit_size, unsigned int dst_bit_offset, bool lsb0)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/serialize.c:9

---

{#apply_elf_reloc_i386}

### apply_elf_reloc_i386

`static`

```cpp
static struct drgn_error * apply_elf_reloc_i386(const struct drgn_relocating_section * relocating, uint64_t r_offset, uint32_t r_type, const int64_t * r_addend, uint64_t sym_value)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/arch_i386.c:9

---

{#next_elf_note}

### next_elf_note

```cpp
bool next_elf_note(const void ** p, size_t * size, unsigned int align, bool bswap, GElf_Nhdr * nhdr_ret, const char ** name_ret, const void ** desc_ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/elf_notes.c:10

Parse the next ELF note out of a buffer.

:::note
Alignment of ELF notes is a mess. The [System V gABI](http://www.sco.com/developers/gabi/latest/ch5.pheader.html#note_section) says that the note header and descriptor should be aligned to 4 bytes for 32-bit files and 8 bytes for 64-bit files. However, on Linux, 4-byte alignment is used for both 32-bit and 64-bit files. 

:::

:::note
The only exception as of 2024 is `NT_GNU_PROPERTY_TYPE_0`, which is defined to follow the gABI alignment. See ["PT_NOTE alignment, NT_GNU_PROPERTY_TYPE_0, glibc and gold"](https://public-inbox.org/libc-alpha/13a92cb0-a993-f684-9a96-e02e4afb1bef@redhat.com/). But, note that the 12-byte note header plus the 4-byte `"GNU\0"` name is a multiple of 8 bytes, and the `NT_GNU_PROPERTY_TYPE_0` descriptor is defined to be a multiple of 4 bytes for 32-bit files and 8 bytes for 64-bit files. As a result, `NT_GNU_PROPERTY_TYPE_0` is never actually padded, and 4-byte vs. 8-byte alignment are equivalent for parsing purposes. 

:::

:::note
According to the [gABI Linux Extensions](https://gitlab.com/x86-psABIs/Linux-ABI), consumers are now supposed to use the `p_align` of the `PT_NOTE` segment instead of assuming an alignment. However, the Linux kernel as of 6.0 generates core dumps with `PT_NOTE` segments with a `p_align` of 0 or 1 which are actually aligned to 4 bytes. So, when parsing notes from an ELF file, you need to use 8-byte alignment if `p_align` is 8 and 4-byte alignment otherwise. binutils and elfutils appear to do the same. 

:::

:::note
Before Linux kernel commit f7ba52f302fd ("vmlinux.lds.h: Discard
.note.gnu.property section") (in v6.4), the vmlinux linker script can create a `PT_NOTE` segment with a `p_align` of 8 where the entries other than `NT_GNU_PROPERTY_TYPE_0` are actually aligned to 4 bytes. 

:::

:::note
Finally, there are cases where we don't know `p_align`. For example, `/sys/kernel/notes` contains the contents of the vmlinux `.notes` section, which (ignoring the aforementioned bug) we can assume has 4-byte alignment. As another example, `/sys/module/$module/notes/` contains a file for each note section. Since `NT_GNU_PROPERTY_TYPE_0` can be parsed assuming 4-byte alignment, we can again assume 4-byte alignment. This will work as long as any future note types requiring 8-byte alignment also happen to have an 8-byte aligned header+name and descriptor (but hopefully no one ever adds an 8-byte aligned note again).

:::

#### Returns
`true` if a note was parsed, `false` if there are no more notes.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `p` | `const void **` | Current position. Initialize to the beginning of the buffer. |
| `size` | `size_t *` | Remaining size. Initialize to the size of the buffer. |
| `align` | [`unsigned`](#unsigned) int | Note alignment. Usually `p_align == 8 ? 8 : 4` if the program header is available, otherwise 4. |
| `bswap` | `bool` | Whether the note header needs to be byte-swapped. |
| `name_ret` | `const char **` | Returned note name. |
| `desc_ret` | `const void **` | Returned note descriptor. |

---

{#find_elf_note}

### find_elf_note

```cpp
int find_elf_note(Elf * elf, const char * name, uint32_t type, const void ** ret, size_t * size_ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/elf_notes.c:58

Find an ELF note matching the given name and type.

Note that this currently only checks segments, not sections.

#### Returns
0 on success, -1 on libelf error.

---

{#parse_gnu_build_id_from_notes}

### parse_gnu_build_id_from_notes

```cpp
size_t parse_gnu_build_id_from_notes(const void * buf, size_t size, unsigned int align, bool bswap, const void ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/elf_notes.c:97

Parse a GNU build ID from a buffer containing note data.

#### Returns
Size of returned build ID in bytes, or `NULL` if not found.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `buf` | `const void *` | Buffer containing note data. |
| `size` | `size_t` | Size of `buf` in bytes. |
| `align` | [`unsigned`](#unsigned) int | Note alignment. See [next_elf_note()](#next_elf_note). |
| `bswap` | `bool` | Whether the note header needs to be byte-swapped. |
| `ret` | `const void **` | Returned build ID, or `NULL` if not found. |

---

{#next_elf_note-1}

### next_elf_note

```cpp
bool next_elf_note(const void ** p, size_t * size, unsigned int align, bool bswap, GElf_Nhdr * nhdr_ret, const char ** name_ret, const void ** desc_ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/elf_notes.h:70

Parse the next ELF note out of a buffer.

:::note
Alignment of ELF notes is a mess. The [System V gABI](http://www.sco.com/developers/gabi/latest/ch5.pheader.html#note_section) says that the note header and descriptor should be aligned to 4 bytes for 32-bit files and 8 bytes for 64-bit files. However, on Linux, 4-byte alignment is used for both 32-bit and 64-bit files. 

:::

:::note
The only exception as of 2024 is `NT_GNU_PROPERTY_TYPE_0`, which is defined to follow the gABI alignment. See ["PT_NOTE alignment, NT_GNU_PROPERTY_TYPE_0, glibc and gold"](https://public-inbox.org/libc-alpha/13a92cb0-a993-f684-9a96-e02e4afb1bef@redhat.com/). But, note that the 12-byte note header plus the 4-byte `"GNU\0"` name is a multiple of 8 bytes, and the `NT_GNU_PROPERTY_TYPE_0` descriptor is defined to be a multiple of 4 bytes for 32-bit files and 8 bytes for 64-bit files. As a result, `NT_GNU_PROPERTY_TYPE_0` is never actually padded, and 4-byte vs. 8-byte alignment are equivalent for parsing purposes. 

:::

:::note
According to the [gABI Linux Extensions](https://gitlab.com/x86-psABIs/Linux-ABI), consumers are now supposed to use the `p_align` of the `PT_NOTE` segment instead of assuming an alignment. However, the Linux kernel as of 6.0 generates core dumps with `PT_NOTE` segments with a `p_align` of 0 or 1 which are actually aligned to 4 bytes. So, when parsing notes from an ELF file, you need to use 8-byte alignment if `p_align` is 8 and 4-byte alignment otherwise. binutils and elfutils appear to do the same. 

:::

:::note
Before Linux kernel commit f7ba52f302fd ("vmlinux.lds.h: Discard
.note.gnu.property section") (in v6.4), the vmlinux linker script can create a `PT_NOTE` segment with a `p_align` of 8 where the entries other than `NT_GNU_PROPERTY_TYPE_0` are actually aligned to 4 bytes. 

:::

:::note
Finally, there are cases where we don't know `p_align`. For example, `/sys/kernel/notes` contains the contents of the vmlinux `.notes` section, which (ignoring the aforementioned bug) we can assume has 4-byte alignment. As another example, `/sys/module/$module/notes/` contains a file for each note section. Since `NT_GNU_PROPERTY_TYPE_0` can be parsed assuming 4-byte alignment, we can again assume 4-byte alignment. This will work as long as any future note types requiring 8-byte alignment also happen to have an 8-byte aligned header+name and descriptor (but hopefully no one ever adds an 8-byte aligned note again).

:::

#### Returns
`true` if a note was parsed, `false` if there are no more notes.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `p` | `const void **` | Current position. Initialize to the beginning of the buffer. |
| `size` | `size_t *` | Remaining size. Initialize to the size of the buffer. |
| `align` | [`unsigned`](#unsigned) int | Note alignment. Usually `p_align == 8 ? 8 : 4` if the program header is available, otherwise 4. |
| `bswap` | `bool` | Whether the note header needs to be byte-swapped. |
| `name_ret` | `const char **` | Returned note name. |
| `desc_ret` | `const void **` | Returned note descriptor. |

---

{#find_elf_note-1}

### find_elf_note

```cpp
int find_elf_note(Elf * elf, const char * name, uint32_t type, const void ** ret, size_t * size_ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/elf_notes.h:81

Find an ELF note matching the given name and type.

Note that this currently only checks segments, not sections.

#### Returns
0 on success, -1 on libelf error.

---

{#parse_gnu_build_id_from_notes-1}

### parse_gnu_build_id_from_notes

```cpp
size_t parse_gnu_build_id_from_notes(const void * buf, size_t size, unsigned int align, bool bswap, const void ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/elf_notes.h:95

Parse a GNU build ID from a buffer containing note data.

#### Returns
Size of returned build ID in bytes, or `NULL` if not found.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `buf` | `const void *` | Buffer containing note data. |
| `size` | `size_t` | Size of `buf` in bytes. |
| `align` | [`unsigned`](#unsigned) int | Note alignment. See [next_elf_note()](#next_elf_note). |
| `bswap` | `bool` | Whether the note header needs to be byte-swapped. |
| `ret` | `const void **` | Returned build ID, or `NULL` if not found. |

---

{#drgn_elf_gnu_build_id}

### drgn_elf_gnu_build_id

`static` `inline`

```cpp
static inline ssize_t drgn_elf_gnu_build_id(Elf * elf, const void ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/elf_notes.h:111

---

{#note_header_type}

### note_header_type

`static` `inline`

```cpp
static inline Elf_Type note_header_type(uint64_t p_align)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/elf_notes.h:117

---

{#drgn_call_plugins_prog-2}

### drgn_call_plugins_prog

```cpp
void drgn_call_plugins_prog(const char * name, struct drgn_program * prog)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/no_python.c:38

---

{#fallback_unwind_ppc64}

### fallback_unwind_ppc64

`static`

```cpp
static struct drgn_error * fallback_unwind_ppc64(struct drgn_program * prog, struct drgn_register_state * regs, struct drgn_register_state ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/arch_ppc64.c:49

---

{#get_initial_registers_from_struct_ppc64}

### get_initial_registers_from_struct_ppc64

`static`

```cpp
static struct drgn_error * get_initial_registers_from_struct_ppc64(struct drgn_program * prog, const void * buf, size_t size, bool linux_kernel_prstatus, bool linux_kernel_switched_out, struct drgn_register_state ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/arch_ppc64.c:95

---

{#pt_regs_get_initial_registers_ppc64}

### pt_regs_get_initial_registers_ppc64

`static`

```cpp
static struct drgn_error * pt_regs_get_initial_registers_ppc64(const struct drgn_object * obj, struct drgn_register_state ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/arch_ppc64.c:181

---

{#prstatus_get_initial_registers_ppc64}

### prstatus_get_initial_registers_ppc64

`static`

```cpp
static struct drgn_error * prstatus_get_initial_registers_ppc64(struct drgn_program * prog, const void * prstatus, size_t size, struct drgn_register_state ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/arch_ppc64.c:191

---

{#linux_kernel_get_initial_registers_ppc64}

### linux_kernel_get_initial_registers_ppc64

`static`

```cpp
static struct drgn_error * linux_kernel_get_initial_registers_ppc64(const struct drgn_object * task_obj, struct drgn_register_state ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/arch_ppc64.c:211

---

{#apply_elf_reloc_ppc64}

### apply_elf_reloc_ppc64

`static`

```cpp
static struct drgn_error * apply_elf_reloc_ppc64(const struct drgn_relocating_section * relocating, uint64_t r_offset, uint32_t r_type, const int64_t * r_addend, uint64_t sym_value)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/arch_ppc64.c:264

---

{#get_page_mask}

### get_page_mask

`static` `inline`

```cpp
static inline uint64_t get_page_mask(struct pgtable_iterator_ppc64 * it_arch, int level)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/arch_ppc64.c:315

---

{#get_index}

### get_index

`static`

```cpp
static uint16_t get_index(struct pgtable_iterator_ppc64 * it_arch, uint64_t va, uint16_t level)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/arch_ppc64.c:322

---

{#linux_kernel_pgtable_iterator_arch_create_ppc64}

### linux_kernel_pgtable_iterator_arch_create_ppc64

`static`

```cpp
static struct drgn_error * linux_kernel_pgtable_iterator_arch_create_ppc64(struct drgn_program * prog, void ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/arch_ppc64.c:329

---

{#linux_kernel_pgtable_iterator_init_ppc64}

### linux_kernel_pgtable_iterator_init_ppc64

`static`

```cpp
static void linux_kernel_pgtable_iterator_init_ppc64(struct drgn_program * prog, struct pgtable_iterator * _it)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/arch_ppc64.c:382

---

{#linux_kernel_pgtable_iterator_next_ppc64}

### linux_kernel_pgtable_iterator_next_ppc64

`static`

```cpp
static struct drgn_error * linux_kernel_pgtable_iterator_next_ppc64(struct drgn_program * prog, struct pgtable_iterator * it, uint64_t * virt_addr_ret, uint64_t * phys_addr_ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/arch_ppc64.c:389

---

{#linux_kernel_section_size_bits_fallback_ppc64}

### linux_kernel_section_size_bits_fallback_ppc64

`static`

```cpp
static int linux_kernel_section_size_bits_fallback_ppc64(struct drgn_program * prog)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/arch_ppc64.c:443

---

{#apply_elf_reloc_riscv}

### apply_elf_reloc_riscv

`static`

```cpp
static struct drgn_error * apply_elf_reloc_riscv(const struct drgn_relocating_section * relocating, uint64_t r_offset, uint32_t r_type, const int64_t * r_addend, uint64_t sym_value)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/arch_riscv.c:21

---

{#apply_elf_reloc_s390}

### apply_elf_reloc_s390

`static`

```cpp
static struct drgn_error * apply_elf_reloc_s390(const struct drgn_relocating_section * relocating, uint64_t r_offset, uint32_t r_type, const int64_t * r_addend, uint64_t sym_value)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/arch_s390x.c:35

---

{#pt_regs_get_initial_registers_s390x_impl}

### pt_regs_get_initial_registers_s390x_impl

`static`

```cpp
static struct drgn_error * pt_regs_get_initial_registers_s390x_impl(struct drgn_program * prog, const void * buf, struct drgn_register_state ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/arch_s390x.c:72

---

{#fallback_unwind_s390x}

### fallback_unwind_s390x

`static`

```cpp
static struct drgn_error * fallback_unwind_s390x(struct drgn_program * prog, struct drgn_register_state * regs, struct drgn_register_state ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/arch_s390x.c:92

---

{#pt_regs_get_initial_registers_s390x}

### pt_regs_get_initial_registers_s390x

`static`

```cpp
static struct drgn_error * pt_regs_get_initial_registers_s390x(const struct drgn_object * obj, struct drgn_register_state ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/arch_s390x.c:155

---

{#prstatus_get_initial_registers_s390x}

### prstatus_get_initial_registers_s390x

`static`

```cpp
static struct drgn_error * prstatus_get_initial_registers_s390x(struct drgn_program * prog, const void * prstatus, size_t size, struct drgn_register_state ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/arch_s390x.c:169

---

{#linux_kernel_get_initial_registers_s390x}

### linux_kernel_get_initial_registers_s390x

`static`

```cpp
static struct drgn_error * linux_kernel_get_initial_registers_s390x(const struct drgn_object * task_obj, struct drgn_register_state ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/arch_s390x.c:200

---

{#linux_kernel_pgtable_iterator_arch_create_s390x}

### linux_kernel_pgtable_iterator_arch_create_s390x

`static`

```cpp
static struct drgn_error * linux_kernel_pgtable_iterator_arch_create_s390x(struct drgn_program * prog, void ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/arch_s390x.c:272

---

{#linux_kernel_pgtable_iterator_init_s390x}

### linux_kernel_pgtable_iterator_init_s390x

`static`

```cpp
static void linux_kernel_pgtable_iterator_init_s390x(struct drgn_program * prog, struct pgtable_iterator * it)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/arch_s390x.c:283

---

{#entry_is_invalid}

### entry_is_invalid

`static`

```cpp
static bool entry_is_invalid(uint64_t entry, int level)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/arch_s390x.c:293

---

{#get_mask}

### get_mask

`static`

```cpp
static int get_mask(struct pgtable_iterator_s390x * it_arch, int level)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/arch_s390x.c:310

---

{#get_index-1}

### get_index

`static`

```cpp
static int get_index(struct pgtable_iterator_s390x * it_arch, int level, uint64_t va)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/arch_s390x.c:316

---

{#get_table_length}

### get_table_length

`static`

```cpp
static int get_table_length(uint64_t entry, int level)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/arch_s390x.c:322

---

{#get_table_offset}

### get_table_offset

`static`

```cpp
static int get_table_offset(uint64_t entry, int level)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/arch_s390x.c:335

---

{#get_table_address}

### get_table_address

`static`

```cpp
static uint64_t get_table_address(uint64_t entry, int level, bool * is_large)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/arch_s390x.c:348

---

{#get_level_mask}

### get_level_mask

`static`

```cpp
static uint64_t get_level_mask(int level)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/arch_s390x.c:371

---

{#linux_kernel_pgtable_iterator_next_s390x}

### linux_kernel_pgtable_iterator_next_s390x

`static`

```cpp
static struct drgn_error * linux_kernel_pgtable_iterator_next_s390x(struct drgn_program * prog, struct pgtable_iterator * it, uint64_t * virt_addr_ret, uint64_t * phys_addr_ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/arch_s390x.c:377

---

{#linux_kernel_section_size_bits_fallback_s390x}

### linux_kernel_section_size_bits_fallback_s390x

`static`

```cpp
static int linux_kernel_section_size_bits_fallback_s390x(struct drgn_program * prog)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/arch_s390x.c:472

---

{#dwelf_elf_begin}

### dwelf_elf_begin

`static` `inline`

```cpp
static inline Elf * dwelf_elf_begin(int fd)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.c:51

---

{#define_hash_map_functions-2}

### DEFINE_HASH_MAP_FUNCTIONS

```cpp
DEFINE_HASH_MAP_FUNCTIONS(drgn_module_section_address_map, c_string_key_hash_pair, c_string_key_eq)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.c:57

---

{#drgn_elf_file_dwarf_key}

### drgn_elf_file_dwarf_key

`static` `inline`

```cpp
static inline Dwarf * drgn_elf_file_dwarf_key(struct drgn_elf_file *const * entry)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.c:134

---

{#define_hash_table_functions-2}

### DEFINE_HASH_TABLE_FUNCTIONS

```cpp
DEFINE_HASH_TABLE_FUNCTIONS(drgn_elf_file_dwarf_table, drgn_elf_file_dwarf_key, ptr_key_hash_pair, scalar_key_eq)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.c:138

---

{#define_vector-4}

### DEFINE_VECTOR

```cpp
DEFINE_VECTOR(drgn_module_vector, struct drgn_module *)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.c:140

---

{#drgn_module_entry_name}

### drgn_module_entry_name

`static` `inline`

```cpp
static inline const char * drgn_module_entry_name(struct drgn_module *const * entry)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.c:142

---

{#define_hash_table_functions-3}

### DEFINE_HASH_TABLE_FUNCTIONS

```cpp
DEFINE_HASH_TABLE_FUNCTIONS(drgn_module_table, drgn_module_entry_name, c_string_key_hash_pair, c_string_key_eq)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.c:147

---

{#drgn_module_address_range_key}

### drgn_module_address_range_key

`static` `inline`

```cpp
static inline uint64_t drgn_module_address_range_key(const struct drgn_module_address_range * entry)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.c:151

---

{#define_binary_search_tree_functions-1}

### DEFINE_BINARY_SEARCH_TREE_FUNCTIONS

```cpp
DEFINE_BINARY_SEARCH_TREE_FUNCTIONS(drgn_module_address_tree, node, drgn_module_address_range_key, binary_search_tree_scalar_cmp, splay)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.c:156

---

{#drgn_module_free_section_addresses}

### drgn_module_free_section_addresses

`static`

```cpp
static void drgn_module_free_section_addresses(struct drgn_module * module)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.c:160

---

{#drgn_module_find}

### drgn_module_find

`static`

```cpp
static struct drgn_module * drgn_module_find(struct drgn_program * prog, enum drgn_module_kind kind, const char * name, uint64_t info)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.c:188

---

{#drgn_module_find_or_create}

### drgn_module_find_or_create

`static`

```cpp
static struct drgn_error * drgn_module_find_or_create(struct drgn_program * prog, enum drgn_module_kind kind, const char * name, uint64_t info, struct drgn_module ** ret, bool * new_ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.c:206

---

{#drgn_split_dwarf_elf_file_destroy}

### drgn_split_dwarf_elf_file_destroy

`static`

```cpp
static void drgn_split_dwarf_elf_file_destroy(struct drgn_elf_file * file)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.c:422

---

{#drgn_module_clear_wanted_supplementary_debug_file}

### drgn_module_clear_wanted_supplementary_debug_file

`static`

```cpp
static void drgn_module_clear_wanted_supplementary_debug_file(struct drgn_module * module)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.c:432

---

{#drgn_module_destroy}

### drgn_module_destroy

`static`

```cpp
static void drgn_module_destroy(struct drgn_module * module)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.c:447

---

{#drgn_module_delete_address_ranges}

### drgn_module_delete_address_ranges

`static`

```cpp
static void drgn_module_delete_address_ranges(struct drgn_module * module)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.c:471

---

{#drgn_check_module_address_range_overlap}

### drgn_check_module_address_range_overlap

`static`

```cpp
static struct drgn_error * drgn_check_module_address_range_overlap(struct drgn_module * module, uint64_t start, uint64_t end)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.c:550

---

{#drgn_module_address_range_compare}

### drgn_module_address_range_compare

`static`

```cpp
static int drgn_module_address_range_compare(const void * _a, const void * _b)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.c:609

---

{#drgn_module_alloc_build_id}

### drgn_module_alloc_build_id

`static`

```cpp
static void * drgn_module_alloc_build_id(size_t build_id_len)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.c:717

---

{#drgn_module_set_build_id_impl}

### drgn_module_set_build_id_impl

`static`

```cpp
static void drgn_module_set_build_id_impl(struct drgn_module * module, const void * build_id, size_t build_id_len, void * build_id_buf)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.c:726

---

{#drgn_module_section_addresses_allowed}

### drgn_module_section_addresses_allowed

`static`

```cpp
static struct drgn_error * drgn_module_section_addresses_allowed(struct drgn_module * module, bool modify)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.c:764

---

{#drgn_can_change_module_file_status}

### drgn_can_change_module_file_status

`static`

```cpp
static bool drgn_can_change_module_file_status(enum drgn_module_file_status old_status, enum drgn_module_file_status new_status)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.c:931

---

{#drgn_program_register_debug_info_finder_impl}

### drgn_program_register_debug_info_finder_impl

`static`

```cpp
static struct drgn_error * drgn_program_register_debug_info_finder_impl(struct drgn_program * prog, struct drgn_debug_info_finder * finder, const char * name, const struct drgn_debug_info_finder_ops * ops, void * arg, size_t enable_index)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.c:1103

---

{#drgn_module_set_wanted_gnu_debugaltlink}

### drgn_module_set_wanted_gnu_debugaltlink

`static`

```cpp
static struct drgn_error * drgn_module_set_wanted_gnu_debugaltlink(struct drgn_module * module, struct drgn_elf_file * file)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.c:1182

---

{#drgn_module_copy_section_addresses}

### drgn_module_copy_section_addresses

`static`

```cpp
static struct drgn_error * drgn_module_copy_section_addresses(struct drgn_module * module, struct drgn_elf_file * file)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.c:1239

---

{#elf_main_bias}

### elf_main_bias

`static`

```cpp
static bool elf_main_bias(struct drgn_program * prog, Elf * elf, uint64_t * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.c:1286

---

{#elf_dso_bias}

### elf_dso_bias

`static`

```cpp
static bool elf_dso_bias(struct drgn_program * prog, Elf * elf, uint64_t dynamic_address, uint64_t * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.c:1325

---

{#drgn_module_elf_file_bias}

### drgn_module_elf_file_bias

`static`

```cpp
static bool drgn_module_elf_file_bias(struct drgn_module * module, struct drgn_elf_file * file, uint64_t * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.c:1353

---

{#drgn_module_should_set_address_range_from_elf_file}

### drgn_module_should_set_address_range_from_elf_file

`static`

```cpp
static bool drgn_module_should_set_address_range_from_elf_file(struct drgn_module * module)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.c:1399

---

{#drgn_module_maybe_use_elf_file}

### drgn_module_maybe_use_elf_file

`static`

```cpp
static struct drgn_error * drgn_module_maybe_use_elf_file(struct drgn_module * module, struct drgn_elf_file * file, bool is_gnu_debugaltlink_file)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.c:1418

---

{#drgn_module_try_file_internal}

### drgn_module_try_file_internal

`static`

```cpp
static struct drgn_error * drgn_module_try_file_internal(struct drgn_module * module, const char * path, int fd_, bool check_build_id, const uint32_t * expected_crc)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.c:1629

---

{#drgn_module_try_vdso_in_core}

### drgn_module_try_vdso_in_core

`static`

```cpp
static struct drgn_error * drgn_module_try_vdso_in_core(struct drgn_module * module, const struct drgn_debug_info_options * options)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.c:1790

---

{#drgn_module_try_supplementary_debug_file_log}

### drgn_module_try_supplementary_debug_file_log

`static`

```cpp
static void drgn_module_try_supplementary_debug_file_log(struct drgn_module * module, const char * how)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.c:1871

---

{#drgn_module_try_standard_supplementary_files}

### drgn_module_try_standard_supplementary_files

`static`

```cpp
static struct drgn_error * drgn_module_try_standard_supplementary_files(struct drgn_module * module, const struct drgn_debug_info_options * options)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.c:1891

---

{#drgn_module_wanted_supplementary_debug_file_is_new}

### drgn_module_wanted_supplementary_debug_file_is_new

`static`

```cpp
static bool drgn_module_wanted_supplementary_debug_file_is_new(struct drgn_module * module, uint64_t orig_supplementary_file_generation)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.c:1975

---

{#define_vector-5}

### DEFINE_VECTOR

```cpp
DEFINE_VECTOR(drgn_map_files_segment_vector, struct drgn_map_files_segment)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.c:2013

---

{#drgn_map_files_segments_deinit}

### drgn_map_files_segments_deinit

`static`

```cpp
static void drgn_map_files_segments_deinit(struct drgn_map_files_segments * segments)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.c:2024

---

{#drgn_add_map_files_segment}

### drgn_add_map_files_segment

`static`

```cpp
static struct drgn_error * drgn_add_map_files_segment(struct drgn_map_files_segments * segments, uint64_t start, uint64_t end)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.c:2034

---

{#drgn_map_files_segment_compare}

### drgn_map_files_segment_compare

`static` `inline`

```cpp
static inline int drgn_map_files_segment_compare(const void * _a, const void * _b)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.c:2050

---

{#drgn_debug_info_set_map_files_segments}

### drgn_debug_info_set_map_files_segments

`static`

```cpp
static void drgn_debug_info_set_map_files_segments(struct drgn_debug_info * dbinfo, struct drgn_map_files_segments * segments)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.c:2058

---

{#drgn_module_try_proc_files_for_shared_library}

### drgn_module_try_proc_files_for_shared_library

`static`

```cpp
static struct drgn_error * drgn_module_try_proc_files_for_shared_library(struct drgn_module * module, const struct drgn_debug_info_options * options, bool * tried)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.c:2075

---

{#drgn_module_try_proc_files}

### drgn_module_try_proc_files

`static`

```cpp
static struct drgn_error * drgn_module_try_proc_files(struct drgn_module * module, const struct drgn_debug_info_options * options, bool * tried)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.c:2189

---

{#drgn_module_try_files_by_build_id}

### drgn_module_try_files_by_build_id

`static`

```cpp
static struct drgn_error * drgn_module_try_files_by_build_id(struct drgn_module * module, const struct drgn_debug_info_options * options)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.c:2224

---

{#find_dollar_origin}

### find_dollar_origin

`static`

```cpp
static const char * find_dollar_origin(const char * s, const char ** end_ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.c:2274

---

{#drgn_module_try_files_by_gnu_debuglink}

### drgn_module_try_files_by_gnu_debuglink

`static`

```cpp
static struct drgn_error * drgn_module_try_files_by_gnu_debuglink(struct drgn_module * module, const struct drgn_debug_info_options * options)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.c:2296

---

{#drgn_module_try_standard_files}

### drgn_module_try_standard_files

`static`

```cpp
static struct drgn_error * drgn_module_try_standard_files(struct drgn_module * module, const struct drgn_debug_info_options * options, struct drgn_standard_debug_info_find_state * state)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.c:2411

---

{#drgn_standard_debug_info_find}

### drgn_standard_debug_info_find

`static`

```cpp
static struct drgn_error * drgn_standard_debug_info_find(struct drgn_module *const * modules, size_t num_modules, void * arg)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.c:2534

---

{#drgn_created_module_iterator_next}

### drgn_created_module_iterator_next

`static`

```cpp
static struct drgn_error * drgn_created_module_iterator_next(struct drgn_module_iterator * _it, struct drgn_module ** ret, bool * new_ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.c:3331

---

{#drgn_mapped_file_create}

### drgn_mapped_file_create

`static`

```cpp
static struct drgn_mapped_file * drgn_mapped_file_create(const char * path)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.c:3398

---

{#drgn_mapped_file_destroy}

### drgn_mapped_file_destroy

`static`

```cpp
static void drgn_mapped_file_destroy(struct drgn_mapped_file * file)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.c:3406

---

{#define_vector-6}

### DEFINE_VECTOR

```cpp
DEFINE_VECTOR(drgn_mapped_file_segment_vector, struct drgn_mapped_file_segment)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.c:3418

---

{#drgn_mapped_file_segments_deinit}

### drgn_mapped_file_segments_deinit

`static`

```cpp
static void drgn_mapped_file_segments_deinit(struct drgn_mapped_file_segments * segments)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.c:3429

---

{#drgn_add_mapped_file_segment}

### drgn_add_mapped_file_segment

`static`

```cpp
static struct drgn_error * drgn_add_mapped_file_segment(struct drgn_mapped_file_segments * segments, uint64_t start, uint64_t end, uint64_t file_offset, struct drgn_mapped_file * file)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.c:3439

---

{#userspace_loaded_module_iterator_deinit}

### userspace_loaded_module_iterator_deinit

`static`

```cpp
static void userspace_loaded_module_iterator_deinit(struct userspace_loaded_module_iterator * it)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.c:3517

---

{#drgn_mapped_file_segment_compare}

### drgn_mapped_file_segment_compare

`static` `inline`

```cpp
static inline int drgn_mapped_file_segment_compare(const void * _a, const void * _b)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.c:3524

---

{#userspace_loaded_module_iterator_set_file_segments}

### userspace_loaded_module_iterator_set_file_segments

`static`

```cpp
static void userspace_loaded_module_iterator_set_file_segments(struct userspace_loaded_module_iterator * it, struct drgn_mapped_file_segments * segments)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.c:3533

---

{#find_mapped_file_segment}

### find_mapped_file_segment

`static`

```cpp
static struct drgn_mapped_file_segment * find_mapped_file_segment(struct userspace_loaded_module_iterator * it, uint64_t address)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.c:3548

---

{#userspace_loaded_module_iterator_read_ehdr}

### userspace_loaded_module_iterator_read_ehdr

`static`

```cpp
static struct drgn_error * userspace_loaded_module_iterator_read_ehdr(struct userspace_loaded_module_iterator * it, uint64_t address, GElf_Ehdr * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.c:3561

---

{#userspace_loaded_module_iterator_read_phdrs}

### userspace_loaded_module_iterator_read_phdrs

`static`

```cpp
static struct drgn_error * userspace_loaded_module_iterator_read_phdrs(struct userspace_loaded_module_iterator * it, uint64_t address, uint64_t phnum)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.c:3630

---

{#userspace_loaded_module_iterator_phdr}

### userspace_loaded_module_iterator_phdr

`static`

```cpp
static void userspace_loaded_module_iterator_phdr(struct userspace_loaded_module_iterator * it, size_t i, GElf_Phdr * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.c:3662

---

{#userspace_loaded_module_iterator_read_dynamic}

### userspace_loaded_module_iterator_read_dynamic

`static`

```cpp
static struct drgn_error * userspace_loaded_module_iterator_read_dynamic(struct userspace_loaded_module_iterator * it, uint64_t address, uint64_t size, size_t * num_dyn_ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.c:3687

---

{#userspace_loaded_module_iterator_dyn}

### userspace_loaded_module_iterator_dyn

`static`

```cpp
static void userspace_loaded_module_iterator_dyn(struct userspace_loaded_module_iterator * it, size_t i, GElf_Dyn * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.c:3725

---

{#userspace_loaded_module_iterator_read_main_phdrs}

### userspace_loaded_module_iterator_read_main_phdrs

`static`

```cpp
static struct drgn_error * userspace_loaded_module_iterator_read_main_phdrs(struct userspace_loaded_module_iterator * it)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.c:3744

---

{#identify_module_from_phdrs}

### identify_module_from_phdrs

`static`

```cpp
static struct drgn_error * identify_module_from_phdrs(struct userspace_loaded_module_iterator * it, struct drgn_module * module, size_t phnum, uint64_t bias)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.c:3818

---

{#userspace_loaded_module_iterator_yield_main}

### userspace_loaded_module_iterator_yield_main

`static`

```cpp
static struct drgn_error * userspace_loaded_module_iterator_yield_main(struct userspace_loaded_module_iterator * it, struct drgn_module ** ret, bool * new_ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.c:3903

---

{#userspace_loaded_module_iterator_yield_vdso}

### userspace_loaded_module_iterator_yield_vdso

`static`

```cpp
static struct drgn_error * userspace_loaded_module_iterator_yield_vdso(struct userspace_loaded_module_iterator * it, struct drgn_module ** ret, bool * new_ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.c:3955

---

{#userspace_get_link_map}

### userspace_get_link_map

`static`

```cpp
static struct drgn_error * userspace_get_link_map(struct userspace_loaded_module_iterator * it)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.c:4147

---

{#identify_module_from_link_map}

### identify_module_from_link_map

`static`

```cpp
static struct drgn_error * identify_module_from_link_map(struct userspace_loaded_module_iterator * it, struct drgn_module * module, struct drgn_mapped_file * file, uint64_t l_addr)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.c:4241

---

{#userspace_next_link_map}

### userspace_next_link_map

`static`

```cpp
static struct drgn_error * userspace_next_link_map(struct userspace_loaded_module_iterator * it, struct drgn_link_map * ret, char ** name_ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.c:4318

---

{#yield_from_link_map}

### yield_from_link_map

`static`

```cpp
static struct drgn_error * yield_from_link_map(struct userspace_loaded_module_iterator * it, struct drgn_module ** ret, bool * new_ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.c:4385

---

{#userspace_loaded_module_iterator_next}

### userspace_loaded_module_iterator_next

`static`

```cpp
static struct drgn_error * userspace_loaded_module_iterator_next(struct drgn_module_iterator * _it, struct drgn_module ** ret, bool * new_ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.c:4449

---

{#process_mapped_file_entry_to_key}

### process_mapped_file_entry_to_key

`static`

```cpp
static struct process_mapped_file_key process_mapped_file_entry_to_key(const struct process_mapped_file_entry * entry)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.c:4495

---

{#process_mapped_file_key_hash_pair}

### process_mapped_file_key_hash_pair

`static`

```cpp
static struct hash_pair process_mapped_file_key_hash_pair(const struct process_mapped_file_key * key)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.c:4505

---

{#process_mapped_file_key_eq}

### process_mapped_file_key_eq

`static`

```cpp
static bool process_mapped_file_key_eq(const struct process_mapped_file_key * a, const struct process_mapped_file_key * b)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.c:4512

---

{#define_hash_table-2}

### DEFINE_HASH_TABLE

```cpp
DEFINE_HASH_TABLE(process_mapped_files, struct process_mapped_file_entry, process_mapped_file_entry_to_key, process_mapped_file_key_hash_pair, process_mapped_file_key_eq)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.c:4520

---

{#process_add_mapping}

### process_add_mapping

`static`

```cpp
static struct drgn_error * process_add_mapping(struct process_loaded_module_iterator * it, const char * maps_path, const char * map_files_path, int map_files_fd, bool * logged_readlink_eperm, bool * logged_stat_eperm, struct drgn_map_files_segments * map_files_segments, struct drgn_mapped_file_segments * segments, char * line, size_t line_len)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.c:4531

---

{#process_get_mapped_files}

### process_get_mapped_files

`static`

```cpp
static struct drgn_error * process_get_mapped_files(struct process_loaded_module_iterator * it)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.c:4700

---

{#process_loaded_module_iterator_destroy}

### process_loaded_module_iterator_destroy

`static`

```cpp
static void process_loaded_module_iterator_destroy(struct drgn_module_iterator * _it)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.c:4779

---

{#process_loaded_module_iterator_create}

### process_loaded_module_iterator_create

`static`

```cpp
static struct drgn_error * process_loaded_module_iterator_create(struct drgn_program * prog, struct drgn_module_iterator ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.c:4793

---

{#core_mapped_file_entry_to_key}

### core_mapped_file_entry_to_key

`static`

```cpp
static const char * core_mapped_file_entry_to_key(struct drgn_mapped_file *const * entry)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.c:4814

---

{#define_hash_table-3}

### DEFINE_HASH_TABLE

```cpp
DEFINE_HASH_TABLE(core_mapped_files, struct drgn_mapped_file *, core_mapped_file_entry_to_key, c_string_key_hash_pair, c_string_key_eq)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.c:4819

---

{#parse_nt_file_error}

### parse_nt_file_error

`static`

```cpp
static struct drgn_error * parse_nt_file_error(struct binary_buffer * bb, const char * pos, const char * message)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.c:4828

---

{#core_get_mapped_files}

### core_get_mapped_files

`static`

```cpp
static struct drgn_error * core_get_mapped_files(struct core_loaded_module_iterator * it)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.c:4836

---

{#core_loaded_module_iterator_destroy}

### core_loaded_module_iterator_destroy

`static`

```cpp
static void core_loaded_module_iterator_destroy(struct drgn_module_iterator * _it)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.c:4954

---

{#core_loaded_module_iterator_create}

### core_loaded_module_iterator_create

`static`

```cpp
static struct drgn_error * core_loaded_module_iterator_create(struct drgn_program * prog, struct drgn_module_iterator ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.c:4966

---

{#null_module_iterator_create}

### null_module_iterator_create

`static`

```cpp
static struct drgn_error * null_module_iterator_create(struct drgn_program * prog, struct drgn_module_iterator ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.c:4987

---

{#drgn_module_iterator_destroyp}

### drgn_module_iterator_destroyp

`static` `inline`

```cpp
static inline void drgn_module_iterator_destroyp(struct drgn_module_iterator ** itp)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.c:5012

---

{#define_vector-7}

### DEFINE_VECTOR

```cpp
DEFINE_VECTOR(load_debug_info_file_vector, struct load_debug_info_file)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.c:5040

---

{#load_debug_info_provided_key}

### load_debug_info_provided_key

`static`

```cpp
static struct nstring load_debug_info_provided_key(const struct load_debug_info_provided * provided)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.c:5050

---

{#define_hash_table-4}

### DEFINE_HASH_TABLE

```cpp
DEFINE_HASH_TABLE(load_debug_info_provided_table, struct load_debug_info_provided, load_debug_info_provided_key, nstring_hash_pair, nstring_eq)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.c:5055

---

{#load_debug_info_add_provided_file}

### load_debug_info_add_provided_file

`static`

```cpp
static struct drgn_error * load_debug_info_add_provided_file(struct drgn_program * prog, struct load_debug_info_state * state, const char * path)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.c:5068

---

{#load_debug_info_state_deinit}

### load_debug_info_state_deinit

`static`

```cpp
static void load_debug_info_state_deinit(struct load_debug_info_state * state)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.c:5143

---

{#load_debug_info_find_provided}

### load_debug_info_find_provided

`static`

```cpp
static struct load_debug_info_provided * load_debug_info_find_provided(struct load_debug_info_state * state, const void * build_id, size_t build_id_len)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.c:5159

---

{#load_debug_info_try_provided}

### load_debug_info_try_provided

`static`

```cpp
static struct drgn_error * load_debug_info_try_provided(struct drgn_module * module, struct load_debug_info_provided * provided, enum drgn_module_file_status not_status)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.c:5174

---

{#load_debug_info_try_provided_supplementary_files}

### load_debug_info_try_provided_supplementary_files

`static`

```cpp
static struct drgn_error * load_debug_info_try_provided_supplementary_files(struct drgn_module * module, struct load_debug_info_state * state)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.c:5198

---

{#load_debug_info_try_provided_vmlinux}

### load_debug_info_try_provided_vmlinux

`static`

```cpp
static struct drgn_error * load_debug_info_try_provided_vmlinux(struct drgn_module * module, struct load_debug_info_state * state)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.c:5219

---

{#load_debug_info_try_provided_files}

### load_debug_info_try_provided_files

`static`

```cpp
static struct drgn_error * load_debug_info_try_provided_files(struct drgn_module * module, struct load_debug_info_state * state)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.c:5292

---

{#load_debug_info_log_missing}

### load_debug_info_log_missing

`static`

```cpp
static void load_debug_info_log_missing(struct drgn_module * module, unsigned int max_warnings, unsigned int * num_missing)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.c:5345

---

{#elf_symbols_search}

### elf_symbols_search

`static`

```cpp
static struct drgn_error * elf_symbols_search(const char * name, uint64_t addr, enum drgn_find_symbol_flags flags, void * data, struct drgn_symbol_result_builder * builder)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.c:5627

---

{#dwarf_cu_dwp_section_info}

### dwarf_cu_dwp_section_info

`static` `inline`

```cpp
static inline int dwarf_cu_dwp_section_info(Dwarf_CU * cu, unsigned int section, Dwarf_Off * offsetp, Dwarf_Off * sizep)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:38

---

{#drgn_module_dwarf_info_deinit}

### drgn_module_dwarf_info_deinit

```cpp
void drgn_module_dwarf_info_deinit(struct drgn_module * module)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:49

---

{#define_vector_functions-9}

### DEFINE_VECTOR_FUNCTIONS

```cpp
DEFINE_VECTOR_FUNCTIONS(drgn_dwarf_index_die_vector)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:57

---

{#define_hash_map_functions-3}

### DEFINE_HASH_MAP_FUNCTIONS

```cpp
DEFINE_HASH_MAP_FUNCTIONS(drgn_dwarf_index_die_map, nstring_hash_pair, nstring_eq)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:59

---

{#drgn_namespace_key}

### drgn_namespace_key

`static` `inline`

```cpp
static inline struct nstring drgn_namespace_key(struct drgn_namespace_dwarf_index *const * entry)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:63

---

{#define_hash_table_functions-4}

### DEFINE_HASH_TABLE_FUNCTIONS

```cpp
DEFINE_HASH_TABLE_FUNCTIONS(drgn_namespace_table, drgn_namespace_key, nstring_hash_pair, nstring_eq)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:67

---

{#define_hash_map_functions-4}

### DEFINE_HASH_MAP_FUNCTIONS

```cpp
DEFINE_HASH_MAP_FUNCTIONS(drgn_dwarf_base_type_map, nstring_hash_pair, nstring_eq)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:70

---

{#define_hash_map_functions-5}

### DEFINE_HASH_MAP_FUNCTIONS

```cpp
DEFINE_HASH_MAP_FUNCTIONS(drgn_dwarf_specification_map, int_key_hash_pair, scalar_key_eq)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:73

---

{#define_vector_functions-10}

### DEFINE_VECTOR_FUNCTIONS

```cpp
DEFINE_VECTOR_FUNCTIONS(drgn_dwarf_index_cu_vector)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:148

---

{#define_vector-8}

### DEFINE_VECTOR

```cpp
DEFINE_VECTOR(drgn_module_vector, struct drgn_module *)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:149

---

{#define_hash_map_functions-6}

### DEFINE_HASH_MAP_FUNCTIONS

```cpp
DEFINE_HASH_MAP_FUNCTIONS(drgn_dwarf_type_map, ptr_key_hash_pair, scalar_key_eq)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:151

---

{#drgn_namespace_dwarf_index_init}

### drgn_namespace_dwarf_index_init

`static`

```cpp
static void drgn_namespace_dwarf_index_init(struct drgn_namespace_dwarf_index * dindex, const char * name, size_t name_len, struct drgn_namespace_dwarf_index * parent)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:155

---

{#drgn_namespace_dwarf_index_deinit_one}

### drgn_namespace_dwarf_index_deinit_one

`static`

```cpp
static void drgn_namespace_dwarf_index_deinit_one(struct drgn_namespace_dwarf_index * dindex, struct drgn_namespace_dwarf_index ** stack)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:174

---

{#drgn_namespace_dwarf_index_deinit}

### drgn_namespace_dwarf_index_deinit

`static`

```cpp
static void drgn_namespace_dwarf_index_deinit(struct drgn_namespace_dwarf_index * dindex)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:191

---

{#drgn_dwarf_info_init}

### drgn_dwarf_info_init

```cpp
void drgn_dwarf_info_init(struct drgn_debug_info * dbinfo)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:206

---

{#drgn_dwarf_index_cu_deinit}

### drgn_dwarf_index_cu_deinit

`static`

```cpp
static void drgn_dwarf_index_cu_deinit(struct drgn_dwarf_index_cu * cu)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:219

---

{#drgn_dwarf_info_deinit}

### drgn_dwarf_info_deinit

```cpp
void drgn_dwarf_info_deinit(struct drgn_debug_info * dbinfo)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:225

---

{#dwarf_tag_str}

### dwarf_tag_str

`static`

```cpp
static const char * dwarf_tag_str(Dwarf_Die * die, char buf)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:244

Like [dw_tag_str()](#dw_tag_str), but takes a `Dwarf_Die`.

---

{#drgn_check_address_size}

### drgn_check_address_size

`static` `inline`

```cpp
static inline struct drgn_error * drgn_check_address_size(uint8_t address_size)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:249

---

{#define_vector-9}

### DEFINE_VECTOR

```cpp
DEFINE_VECTOR(uint8_vector, uint8_t)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:369

---

{#define_vector-10}

### DEFINE_VECTOR

```cpp
DEFINE_VECTOR(uint32_vector, uint32_t)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:370

---

{#define_vector-11}

### DEFINE_VECTOR

```cpp
DEFINE_VECTOR(uint64_vector, uint64_t)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:371

---

{#drgn_dwarf_index_cu_buffer_error}

### drgn_dwarf_index_cu_buffer_error

`static`

```cpp
static struct drgn_error * drgn_dwarf_index_cu_buffer_error(struct binary_buffer * bb, const char * pos, const char * message)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:381

---

{#drgn_dwarf_index_cu_buffer_init}

### drgn_dwarf_index_cu_buffer_init

`static`

```cpp
static void drgn_dwarf_index_cu_buffer_init(struct drgn_dwarf_index_cu_buffer * buffer, struct drgn_dwarf_index_cu * cu)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:393

---

{#drgn_dwarf_index_find_cu}

### drgn_dwarf_index_find_cu

`static`

```cpp
static struct drgn_dwarf_index_cu * drgn_dwarf_index_find_cu(struct drgn_debug_info * dbinfo, uintptr_t die_addr)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:405

---

{#drgn_dwarf_dwo_name}

### drgn_dwarf_dwo_name

`static`

```cpp
static const char * drgn_dwarf_dwo_name(Dwarf_Die * die)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:424

---

{#drgn_dwarf_index_read_file}

### drgn_dwarf_index_read_file

`static`

```cpp
static struct drgn_error * drgn_dwarf_index_read_file(struct drgn_elf_file * file, struct drgn_dwarf_index_cu_vector * cus, struct drgn_dwarf_index_cu_vector * partial_units)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:643

---

{#drgn_dwarf_index_read_cus}

### drgn_dwarf_index_read_cus

`static`

```cpp
static struct drgn_error * drgn_dwarf_index_read_cus(struct drgn_elf_file * file, enum drgn_section_index scn, struct drgn_dwarf_index_cu_vector * cus, struct drgn_dwarf_index_cu_vector * partial_units)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:439

---

{#read_strx}

### read_strx

`static`

```cpp
static struct drgn_error * read_strx(struct drgn_dwarf_index_cu_buffer * buffer, uint64_t strx, const char ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:682

---

{#dw_form_to_insn}

### dw_form_to_insn

`static`

```cpp
static struct drgn_error * dw_form_to_insn(struct drgn_dwarf_index_cu * cu, struct binary_buffer * bb, uint64_t form, uint8_t * insn_ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:717

---

{#dw_at_sibling_to_insn}

### dw_at_sibling_to_insn

`static`

```cpp
static struct drgn_error * dw_at_sibling_to_insn(struct binary_buffer * bb, uint64_t form, uint8_t * insn_ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:817

---

{#dw_at_name_to_insn}

### dw_at_name_to_insn

`static`

```cpp
static struct drgn_error * dw_at_name_to_insn(struct drgn_dwarf_index_cu * cu, struct binary_buffer * bb, uint64_t form, uint8_t * insn_ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:847

---

{#dw_at_declaration_to_insn}

### dw_at_declaration_to_insn

`static`

```cpp
static struct drgn_error * dw_at_declaration_to_insn(struct binary_buffer * bb, uint64_t form, uint8_t * insn_ret, uint8_t * die_flags)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:919

---

{#dw_at_specification_to_insn}

### dw_at_specification_to_insn

`static`

```cpp
static struct drgn_error * dw_at_specification_to_insn(struct drgn_dwarf_index_cu * cu, struct binary_buffer * bb, uint64_t form, uint8_t * insn_ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:945

---

{#read_abbrev_decl}

### read_abbrev_decl

`static`

```cpp
static struct drgn_error * read_abbrev_decl(struct drgn_elf_file_section_buffer * buffer, struct drgn_dwarf_index_cu * cu, struct uint32_vector * decls, struct uint8_vector * insns)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:1003

---

{#read_cu}

### read_cu

`static`

```cpp
static struct drgn_error * read_cu(struct drgn_dwarf_index_cu * cu)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:1108

---

{#cu_header_extra_size}

### cu_header_extra_size

`static`

```cpp
static size_t cu_header_extra_size(struct drgn_dwarf_index_cu * cu)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:1135

---

{#cu_header_size}

### cu_header_size

`static`

```cpp
static size_t cu_header_size(struct drgn_dwarf_index_cu * cu)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:1154

---

{#index_specification}

### index_specification

`static`

```cpp
static bool index_specification(struct drgn_dwarf_specification_map * specifications, uintptr_t declaration, uintptr_t addr)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:1164

---

{#read_indirect_insn}

### read_indirect_insn

`static`

```cpp
static struct drgn_error * read_indirect_insn(struct drgn_dwarf_index_cu * cu, struct binary_buffer * bb, uint8_t insn, uint8_t * insn_ret, uint8_t * die_flags)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:1178

---

{#define_vector-12}

### DEFINE_VECTOR

```cpp
DEFINE_VECTOR(drgn_dwarf_index_cu_buffer_stack, struct drgn_dwarf_index_cu_buffer, 1)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:1210

---

{#index_cu_first_pass}

### index_cu_first_pass

`static`

```cpp
static struct drgn_error * index_cu_first_pass(struct drgn_dwarf_specification_map * specifications, struct drgn_dwarf_index_cu_buffer_stack * stack)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:1219

---

{#drgn_dwarf_find_definition}

### drgn_dwarf_find_definition

`static`

```cpp
static bool drgn_dwarf_find_definition(struct drgn_debug_info * dbinfo, uintptr_t die_addr, uintptr_t * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:1527

Find the address of a top-level DIE with a `DW_AT_specification` or `DW_AT_abstract_origin` attribute that refers to the given DIE address.

This can be used to find the definition of a declaration or the concrete out-of-line instance of an abstract instance root.

#### Returns
`true` if a definition DIE was found, `false` if not (in which case `*ret` is not modified).

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `die_addr` | `uintptr_t` | Address of a DIE. |
| `ret` | `uintptr_t *` | Returned address of the definition DIE. |

---

{#index_die}

### index_die

`static`

```cpp
static bool index_die(struct drgn_dwarf_index_die_map map, struct drgn_dwarf_base_type_map * base_types, const char * name, int tag, uintptr_t addr)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:1540

---

{#index_cu_second_pass}

### index_cu_second_pass

`static`

```cpp
static struct drgn_error * index_cu_second_pass(struct drgn_debug_info * dbinfo, struct drgn_dwarf_index_die_map map, struct drgn_dwarf_base_type_map * base_types, struct drgn_dwarf_index_cu_buffer_stack * stack)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:1576

---

{#drgn_dwarf_index_cu_lookup_cmp}

### drgn_dwarf_index_cu_lookup_cmp

`static` `inline`

```cpp
static inline int drgn_dwarf_index_cu_lookup_cmp(const void * _a, const void * _b)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:1994

---

{#drgn_dwarf_index_cus_merge_partial}

### drgn_dwarf_index_cus_merge_partial

`static`

```cpp
static void drgn_dwarf_index_cus_merge_partial(struct drgn_dwarf_index_cu_vector * dst, struct drgn_dwarf_index_cu_vector * src_partial, size_t * partial_pos)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:2002

---

{#drgn_dwarf_index_cus_merge}

### drgn_dwarf_index_cus_merge

`static`

```cpp
static void drgn_dwarf_index_cus_merge(struct drgn_dwarf_index_cu_vector * dst, struct drgn_dwarf_index_cu_vector * src, struct drgn_dwarf_index_cu_vector * src_partial, size_t * pos, size_t * partial_pos)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:2017

---

{#drgn_dwarf_specification_map_merge}

### drgn_dwarf_specification_map_merge

`static`

```cpp
static struct drgn_error * drgn_dwarf_specification_map_merge(struct drgn_dwarf_specification_map * dst, struct drgn_dwarf_specification_map * src, struct drgn_error * err)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:2037

---

{#drgn_dwarf_index_die_map_merge}

### drgn_dwarf_index_die_map_merge

`static`

```cpp
static struct drgn_error * drgn_dwarf_index_die_map_merge(struct drgn_dwarf_index_die_map * dst, struct drgn_dwarf_index_die_map * src, struct drgn_error * err)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:2055

---

{#drgn_dwarf_base_type_map_merge}

### drgn_dwarf_base_type_map_merge

`static`

```cpp
static struct drgn_error * drgn_dwarf_base_type_map_merge(struct drgn_dwarf_base_type_map * dst, struct drgn_dwarf_base_type_map * src, struct drgn_error * err)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:2095

---

{#drgn_dwarf_index_update}

### drgn_dwarf_index_update

`static`

```cpp
static struct drgn_error * drgn_dwarf_index_update(struct drgn_debug_info * dbinfo)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:2113

---

{#index_namespace_impl}

### index_namespace_impl

`static`

```cpp
static struct drgn_error * index_namespace_impl(struct drgn_namespace_dwarf_index * ns)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:2434

---

{#index_namespace}

### index_namespace

`static`

```cpp
static struct drgn_error * index_namespace(struct drgn_namespace_dwarf_index * ns)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:2556

---

{#drgn_dwarf_info_update_index}

### drgn_dwarf_info_update_index

```cpp
struct drgn_error * drgn_dwarf_info_update_index(struct drgn_debug_info * dbinfo)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:2571

---

{#drgn_dwarf_index_iterator_init}

### drgn_dwarf_index_iterator_init

`static`

```cpp
static struct drgn_error * drgn_dwarf_index_iterator_init(struct drgn_dwarf_index_iterator * it, struct drgn_namespace_dwarf_index * ns, const char * name, size_t name_len, const enum drgn_dwarf_index_tag * tags, size_t num_tags)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:2604

Create an iterator over DIEs in a DWARF index namespace.

#### Returns
`NULL` on success, non-`NULL` on error.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `it` | struct [`drgn_dwarf_index_iterator`](drgn_dwarf_index_iterator.md#drgn_dwarf_index_iterator) * | DWARF index iterator to initialize. |
| `ns` | struct [`drgn_namespace_dwarf_index`](drgn_namespace_dwarf_index.md#drgn_namespace_dwarf_index) * | Namespace DWARF index. |
| `name` | `const char *` | Name of DIE to search for. |
| `name_len` | `size_t` | Length of `name`. |
| `tags` | const enum [`drgn_dwarf_index_tag`](drgn_dwarf_index_tag.md#dwarf__info_8h_1ad65bd7851754881c9b9c251fc33b90fc) * | List of DIE tags to search for. |
| `num_tags` | `size_t` | Number of tags in `tags`, or zero to search for any tag. |

---

{#drgn_dwarf_index_iterator_next}

### drgn_dwarf_index_iterator_next

`static`

```cpp
static bool drgn_dwarf_index_iterator_next(struct drgn_dwarf_index_iterator * it, Dwarf_Die * die_ret, struct drgn_elf_file ** file_ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:2637

Get the next matching DIE from a DWARF index iterator.

Note the quirks in [drgn_namespace_dwarf_index::map](drgn_namespace_dwarf_index.md#map) about `DW_TAG_enumerator` and `DW_TAG_namespace`.

#### Returns
`true` on success, `false` if there are no more matching DIEs.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `it` | struct [`drgn_dwarf_index_iterator`](drgn_dwarf_index_iterator.md#drgn_dwarf_index_iterator) * | DWARF index iterator. |
| `die_ret` | `Dwarf_Die *` | Returned DIE. |
| `file_ret` | struct [`drgn_elf_file`](drgn_elf_file.md#drgn_elf_file) ** | If not `NULL`, returned file that DIE came from. |

---

{#drgn_namespace_find_child}

### drgn_namespace_find_child

`static`

```cpp
static struct drgn_error * drgn_namespace_find_child(struct drgn_namespace_dwarf_index * ns, const char * name, size_t name_len, struct drgn_namespace_dwarf_index ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:2691

---

{#drgn_language_from_die}

### drgn_language_from_die

`static`

```cpp
static struct drgn_error * drgn_language_from_die(Dwarf_Die * die, bool fall_back, const struct drgn_language ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:2749

Return the [drgn_language](drgn_language.md#drgn_language) of the CU of the given DIE.

#### Returns
`NULL` on success, non-`NULL` on error.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `fall_back` | `bool` | Whether to fall back if the language is not found or unknown. If `true`, [drgn_default_language](LanguageInternals.md#drgn_default_language) is returned in this case. If `false`, `NULL` is returned. |
| `ret` | const struct [`drgn_language`](drgn_language.md#drgn_language) ** | Returned language. |

---

{#define_vector-13}

### DEFINE_VECTOR

```cpp
DEFINE_VECTOR(dwarf_die_vector, Dwarf_Die)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:2805

---

{#drgn_dwarf_die_iterator_init}

### drgn_dwarf_die_iterator_init

`static`

```cpp
static void drgn_dwarf_die_iterator_init(struct drgn_dwarf_die_iterator * it, Dwarf * dwarf)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:2827

---

{#drgn_dwarf_die_iterator_deinit}

### drgn_dwarf_die_iterator_deinit

`static`

```cpp
static void drgn_dwarf_die_iterator_deinit(struct drgn_dwarf_die_iterator * it)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:2836

---

{#drgn_dwarf_die_iterator_next}

### drgn_dwarf_die_iterator_next

`static`

```cpp
static struct drgn_error * drgn_dwarf_die_iterator_next(struct drgn_dwarf_die_iterator * it, bool children, size_t subtree)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:2866

Return the next DWARF DIE in a [drgn_dwarf_die_iterator](drgn_dwarf_die_iterator.md#drgn_dwarf_die_iterator).

The first call returns the top-level DIE for the first unit in the module. Subsequent calls return children, siblings, and unit DIEs.

This includes the .debug_types section.

#### Returns
`NULL` on success, `&drgn_stop` if there are no more DIEs, in which case the size of `it->dies` equals `subtree` and `it->dies` refers to the root of the iterated subtree, non-`NULL` on error, in which case this should not be called again.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `it` | struct [`drgn_dwarf_die_iterator`](drgn_dwarf_die_iterator.md#drgn_dwarf_die_iterator) * | Iterator containing the returned DIE and its ancestors. The last entry in `it->dies` is the DIE itself, the entry before that is its parent, the entry before that is its grandparent, etc. |
| `children` | `bool` | If `true` and the last returned DIE has children, return its first child (this is a pre-order traversal). Otherwise, return the next DIE at the level less than or equal to the last returned DIE, i.e., the last returned DIE's sibling, or its ancestor's sibling, or the next top-level unit DIE. |
| `subtree` | `size_t` | If zero, iterate over all DIEs in all units. If non-zero, stop after returning all DIEs in the subtree rooted at the DIE that was returned in the last call as entry `subtree - 1` in `it->dies`. |

---

{#drgn_module_find_dwarf_scopes}

### drgn_module_find_dwarf_scopes

```cpp
struct drgn_error * drgn_module_find_dwarf_scopes(struct drgn_module * module, uint64_t pc, uint64_t * bias_ret, Dwarf_Die ** dies_ret, size_t * length_ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:3009

---

{#drgn_find_die_ancestors}

### drgn_find_die_ancestors

```cpp
struct drgn_error * drgn_find_die_ancestors(Dwarf_Die * die, Dwarf_Die ** dies_ret, size_t * length_ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:3104

---

{#drgn_dwarf_next_addrx}

### drgn_dwarf_next_addrx

`static`

```cpp
static struct drgn_error * drgn_dwarf_next_addrx(struct binary_buffer * bb, struct drgn_elf_file * file, Dwarf_Die * cu_die, uint8_t address_size, const char ** addr_base, uint64_t * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:3235

---

{#drgn_dwarf_read_loclistx}

### drgn_dwarf_read_loclistx

`static`

```cpp
static struct drgn_error * drgn_dwarf_read_loclistx(struct drgn_elf_file * file, Dwarf_Die * cu_die, uint8_t offset_size, Dwarf_Word index, Dwarf_Word * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:3314

---

{#drgn_dwarf5_location_list}

### drgn_dwarf5_location_list

`static`

```cpp
static struct drgn_error * drgn_dwarf5_location_list(struct drgn_elf_file * file, Dwarf_Word offset, Dwarf_Die * cu_die, uint8_t address_size, uint64_t pc, const char ** expr_ret, size_t * expr_size_ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:3378

---

{#drgn_dwarf4_split_location_list}

### drgn_dwarf4_split_location_list

`static`

```cpp
static struct drgn_error * drgn_dwarf4_split_location_list(struct drgn_elf_file * file, Dwarf_Word offset, Dwarf_Die * cu_die, uint8_t address_size, uint64_t pc, const char ** expr_ret, size_t * expr_size_ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:3518

---

{#drgn_dwarf4_location_list}

### drgn_dwarf4_location_list

`static`

```cpp
static struct drgn_error * drgn_dwarf4_location_list(struct drgn_elf_file * file, Dwarf_Word offset, Dwarf_Die * cu_die, uint8_t address_size, uint64_t pc, const char ** expr_ret, size_t * expr_size_ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:3629

---

{#drgn_dwarf_location}

### drgn_dwarf_location

`static`

```cpp
static struct drgn_error * drgn_dwarf_location(struct drgn_elf_file * file, Dwarf_Attribute * attr, const struct drgn_register_state * regs, const char ** expr_ret, size_t * expr_size_ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:3698

---

{#drgn_dwarf_expression_buffer_error}

### drgn_dwarf_expression_buffer_error

`static`

```cpp
static struct drgn_error * drgn_dwarf_expression_buffer_error(struct binary_buffer * bb, const char * pos, const char * message)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:3801

---

{#drgn_dwarf_expression_context_init}

### drgn_dwarf_expression_context_init

`static` `inline`

```cpp
static inline struct drgn_error * drgn_dwarf_expression_context_init(struct drgn_dwarf_expression_context * ctx, struct drgn_program * prog, struct drgn_elf_file * file, Dwarf_CU * cu, Dwarf_Die * function, const struct drgn_register_state * regs, const char * expr, size_t expr_size)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:3810

---

{#drgn_dwarf_frame_base}

### drgn_dwarf_frame_base

`static`

```cpp
static struct drgn_error * drgn_dwarf_frame_base(struct drgn_program * prog, struct drgn_elf_file * file, Dwarf_Die * die, const struct drgn_register_state * regs, int * remaining_ops, uint64_t * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:4387

---

{#drgn_dwarf_opcode_is_known}

### drgn_dwarf_opcode_is_known

`static`

```cpp
static bool drgn_dwarf_opcode_is_known(uint8_t opcode)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:3849

---

{#drgn_handle_unknown_dwarf_opcode}

### drgn_handle_unknown_dwarf_opcode

`static`

```cpp
static struct drgn_error * drgn_handle_unknown_dwarf_opcode(struct drgn_dwarf_expression_context * ctx, uint8_t opcode, bool after_simple_location_description)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:3858

---

{#drgn_eval_dwarf_expression}

### drgn_eval_dwarf_expression

`static`

```cpp
static struct drgn_error * drgn_eval_dwarf_expression(struct drgn_dwarf_expression_context * ctx, struct uint64_vector * stack, int * remaining_ops)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:3893

---

{#dwarf_die_is_little_endian}

### dwarf_die_is_little_endian

`static`

```cpp
static struct drgn_error * dwarf_die_is_little_endian(Dwarf_Die * die, bool check_attr, bool * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:4484

Return whether a DWARF DIE is little-endian.

#### Returns
`NULL` on success, non-`NULL` on error.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `check_attr` | `bool` | Whether to check the DW_AT_endianity attribute. If `false`, only the ELF header is checked and this function cannot fail. |

---

{#dwarf_die_byte_order}

### dwarf_die_byte_order

`static`

```cpp
static struct drgn_error * dwarf_die_byte_order(Dwarf_Die * die, bool check_attr, enum drgn_byte_order * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:4518

Like dwarf_die_is_little_endian(), but returns a [drgn_byte_order](drgn_byte_order.md#drgn_byte_order).

---

{#dwarf_type}

### dwarf_type

`static`

```cpp
static int dwarf_type(Dwarf_Die * die, Dwarf_Die * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:4533

---

{#dwarf_flag}

### dwarf_flag

`static`

```cpp
static int dwarf_flag(Dwarf_Die * die, unsigned int name, bool * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:4544

---

{#dwarf_flag_integrate}

### dwarf_flag_integrate

`static`

```cpp
static int dwarf_flag_integrate(Dwarf_Die * die, unsigned int name, bool * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:4556

---

{#dwarf_bytesize64}

### dwarf_bytesize64

`static`

```cpp
static int dwarf_bytesize64(Dwarf_Die * die, uint64_t * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:4568

---

{#drgn_type_from_dwarf_internal}

### drgn_type_from_dwarf_internal

`static`

```cpp
static struct drgn_error * drgn_type_from_dwarf_internal(struct drgn_debug_info * dbinfo, struct drgn_elf_file * file, Dwarf_Die * die, bool can_be_incomplete_array, bool * is_incomplete_array_ret, struct drgn_qualified_type * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:6546

Parse a type from a DWARF debugging information entry.

This is the same as drgn_type_from_dwarf() except that it can be used to work around a bug in GCC < 9.0 that zero length array types are encoded the same as incomplete array types. There are a few places where GCC allows zero-length arrays but not incomplete arrays:

* As the type of a member of a structure with only one member.
* As the type of a structure member other than the last member.
* As the type of a union member.
* As the element type of an array.

In these cases, we know that what appears to be an incomplete array type must actually have a length of zero. In other cases, a subrange DIE without DW_AT_count or DW_AT_upper_bound is ambiguous; we return an incomplete array type.

#### Returns
`NULL` on success, non-`NULL` on error.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `dbinfo` | struct [`drgn_debug_info`](drgn_debug_info.md#drgn_debug_info) * | Debugging information. |
| `file` | struct [`drgn_elf_file`](drgn_elf_file.md#drgn_elf_file) * | File containing `die`. |
| `die` | `Dwarf_Die *` | DIE to parse. |
| `can_be_incomplete_array` | `bool` | Whether the type can be an incomplete array type. If this is `false` and the type appears to be an incomplete array type, its length is set to zero instead. |
| `is_incomplete_array_ret` | `bool *` | Whether the encoded type is an incomplete array type or a typedef of an incomplete array type (regardless of `can_be_incomplete_array`). |
| `ret` | struct [`drgn_qualified_type`](drgn_qualified_type.md#drgn_qualified_type) * | Returned type. |

---

{#drgn_type_from_dwarf}

### drgn_type_from_dwarf

`static` `inline`

```cpp
static inline struct drgn_error * drgn_type_from_dwarf(struct drgn_debug_info * dbinfo, struct drgn_elf_file * file, Dwarf_Die * die, struct drgn_qualified_type * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:4658

Parse a type from a DWARF debugging information entry.

#### Returns
`NULL` on success, non-`NULL` on error.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `dbinfo` | struct [`drgn_debug_info`](drgn_debug_info.md#drgn_debug_info) * | Debugging information. |
| `file` | struct [`drgn_elf_file`](drgn_elf_file.md#drgn_elf_file) * | File containing `die`. |
| `die` | `Dwarf_Die *` | DIE to parse. |
| `ret` | struct [`drgn_qualified_type`](drgn_qualified_type.md#drgn_qualified_type) * | Returned type. |

---

{#drgn_type_from_dwarf_attr}

### drgn_type_from_dwarf_attr

`static`

```cpp
static struct drgn_error * drgn_type_from_dwarf_attr(struct drgn_debug_info * dbinfo, struct drgn_elf_file * file, Dwarf_Die * die, const struct drgn_language * lang, bool can_be_void, bool can_be_incomplete_array, bool * is_incomplete_array_ret, struct drgn_qualified_type * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:4683

Parse a type from the `DW_AT_type` attribute of a DWARF debugging information entry.

#### Returns
`NULL` on success, non-`NULL` on error.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `dbinfo` | struct [`drgn_debug_info`](drgn_debug_info.md#drgn_debug_info) * | Debugging information. |
| `file` | struct [`drgn_elf_file`](drgn_elf_file.md#drgn_elf_file) * | File containing `die`. |
| `die` | `Dwarf_Die *` | DIE with `DW_AT_type` attribute. |
| `lang` | const struct [`drgn_language`](drgn_language.md#drgn_language) * | [Language](Language.md#language) of `die` if it is already known, `NULL` if it should be determined from `die`. |
| `can_be_void` | `bool` | Whether the `DW_AT_type` attribute may be missing, which is interpreted as a void type. If this is false and the `DW_AT_type` attribute is missing, an error is returned. |
| `can_be_incomplete_array` | `bool` | See drgn_type_from_dwarf_internal(). |
| `is_incomplete_array_ret` | `bool *` | See drgn_type_from_dwarf_internal(). |
| `ret` | struct [`drgn_qualified_type`](drgn_qualified_type.md#drgn_qualified_type) * | Returned type. |

---

{#drgn_object_from_dwarf_enumerator}

### drgn_object_from_dwarf_enumerator

`static`

```cpp
static struct drgn_error * drgn_object_from_dwarf_enumerator(struct drgn_debug_info * dbinfo, struct drgn_elf_file * file, Dwarf_Die * die, const char * name, struct drgn_object * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:4725

---

{#drgn_object_from_dwarf_subprogram}

### drgn_object_from_dwarf_subprogram

`static`

```cpp
static struct drgn_error * drgn_object_from_dwarf_subprogram(struct drgn_debug_info * dbinfo, struct drgn_elf_file * file, Dwarf_Die * die, struct drgn_object * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:4764

---

{#read_bits}

### read_bits

`static`

```cpp
static struct drgn_error * read_bits(struct drgn_program * prog, void * dst, unsigned int dst_bit_offset, uint64_t src, unsigned int src_bit_offset, uint64_t bit_size, bool lsb0)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:4784

---

{#drgn_object_from_dwarf_location}

### drgn_object_from_dwarf_location

`static`

```cpp
static struct drgn_error * drgn_object_from_dwarf_location(struct drgn_program * prog, struct drgn_elf_file * file, Dwarf_Die * die, struct drgn_qualified_type qualified_type, const char * expr, size_t expr_size, Dwarf_Die * function_die, const struct drgn_register_state * regs, struct drgn_object * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:4852

---

{#drgn_object_from_dwarf_constant}

### drgn_object_from_dwarf_constant

`static`

```cpp
static struct drgn_error * drgn_object_from_dwarf_constant(struct drgn_debug_info * dbinfo, Dwarf_Die * die, struct drgn_qualified_type qualified_type, Dwarf_Attribute * attr, struct drgn_object * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:5164

---

{#drgn_object_from_dwarf}

### drgn_object_from_dwarf

```cpp
struct drgn_error * drgn_object_from_dwarf(struct drgn_debug_info * dbinfo, struct drgn_elf_file * file, Dwarf_Die * die, Dwarf_Die * type_die, Dwarf_Die * function_die, const struct drgn_register_state * regs, struct drgn_object * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:5201

Create a [drgn_object](drgn_object.md#drgn_object-1) from a `Dwarf_Die`.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `die` | `Dwarf_Die *` | Object DIE (e.g., `DW_TAG_subprogram`, `DW_TAG_variable`, `DW_TAG_formal_parameter`, `DW_TAG_enumerator`, `DW_TAG_template_value_parameter`). |
| `type_die` | `Dwarf_Die *` | DIE of object's type. If `NULL`, use the `DW_AT_type` attribute of `die`. If `die` is a `DW_TAG_enumerator` DIE, this should be its parent. |
| `function_die` | `Dwarf_Die *` | DIE of current function. `NULL` if not in function context. |
| `regs` | const struct [`drgn_register_state`](drgn_register_state.md#drgn_register_state) * | Registers of current stack frame. `NULL` if not in stack frame context. |
| `ret` | struct [`drgn_object`](drgn_object.md#drgn_object-1) * | Returned object. |

---

{#define_vector-14}

### DEFINE_VECTOR

```cpp
DEFINE_VECTOR(const_char_p_vector, const char *)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:5248

---

{#add_dwarf_enumerators}

### add_dwarf_enumerators

`static`

```cpp
static struct drgn_error * add_dwarf_enumerators(Dwarf_Die * enumeration_type, struct const_char_p_vector * vec)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:5250

---

{#drgn_dwarf_scopes_names}

### drgn_dwarf_scopes_names

```cpp
struct drgn_error * drgn_dwarf_scopes_names(Dwarf_Die * scopes, size_t num_scopes, const char *** names_ret, size_t * count_ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:5269

Get an array of names of `DW_TAG_variable` and `DW_TAG_formal_parameter` DIEs in local scopes.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `names_ret` | `const char ***` | Returned array of names. On success, must be freed with `free()`. The individual strings should not be freed. |
| `count_ret` | `size_t *` | Returned number of names in `names_ret`. |

---

{#find_dwarf_enumerator}

### find_dwarf_enumerator

`static`

```cpp
static struct drgn_error * find_dwarf_enumerator(Dwarf_Die * enumeration_type, const char * name, Dwarf_Die * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:5315

---

{#drgn_find_in_dwarf_scopes}

### drgn_find_in_dwarf_scopes

```cpp
struct drgn_error * drgn_find_in_dwarf_scopes(Dwarf_Die * scopes, size_t num_scopes, const char * name, Dwarf_Die * die_ret, Dwarf_Die * type_ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:5334

Find an object DIE in an array of DWARF scopes.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `scopes` | `Dwarf_Die *` | Array of scopes, from outermost to innermost. |
| `num_scopes` | `size_t` | Number of scopes in `scopes`. |
| `die_ret` | `Dwarf_Die *` | Returned object DIE. |
| `type_ret` | `Dwarf_Die *` | If `die_ret` is a `DW_TAG_enumerator` DIE, its parent. Otherwise, undefined. |

---

{#drgn_base_type_from_dwarf}

### drgn_base_type_from_dwarf

`static`

```cpp
static struct drgn_error * drgn_base_type_from_dwarf(struct drgn_debug_info * dbinfo, struct drgn_elf_file * file, Dwarf_Die * die, const struct drgn_language * lang, struct drgn_type ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:5396

---

{#find_namespace_containing_die}

### find_namespace_containing_die

`static`

```cpp
static struct drgn_error * find_namespace_containing_die(struct drgn_debug_info * dbinfo, Dwarf_Die * die, const struct drgn_language * lang, struct drgn_namespace_dwarf_index ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:5453

---

{#drgn_debug_info_find_complete}

### drgn_debug_info_find_complete

`static`

```cpp
static struct drgn_error * drgn_debug_info_find_complete(struct drgn_debug_info * dbinfo, int tag, const char * name, Dwarf_Die * incomplete_die, const struct drgn_language * lang, struct drgn_type ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:5508

---

{#drgn_dwarf_member_thunk_fn}

### drgn_dwarf_member_thunk_fn

`static`

```cpp
static struct drgn_error * drgn_dwarf_member_thunk_fn(struct drgn_object * res, void * arg_)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:5559

---

{#drgn_dwarf_attribute_is_block}

### drgn_dwarf_attribute_is_block

`static` `inline`

```cpp
static inline bool drgn_dwarf_attribute_is_block(Dwarf_Attribute * attr)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:5597

---

{#drgn_dwarf_attribute_is_ptr}

### drgn_dwarf_attribute_is_ptr

`static` `inline`

```cpp
static inline bool drgn_dwarf_attribute_is_ptr(Dwarf_Attribute * attr)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:5610

---

{#invalid_data_member_location}

### invalid_data_member_location

`static`

```cpp
static struct drgn_error * invalid_data_member_location(struct binary_buffer * bb, const char * pos, const char * message)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:5632

---

{#drgn_parse_dwarf_data_member_location}

### drgn_parse_dwarf_data_member_location

`static`

```cpp
static struct drgn_error * drgn_parse_dwarf_data_member_location(Dwarf_Attribute * attr, uint64_t * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:5641

---

{#parse_member_offset}

### parse_member_offset

`static`

```cpp
static struct drgn_error * parse_member_offset(Dwarf_Die * die, union drgn_lazy_object * member_object, bool little_endian, uint64_t * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:5690

---

{#parse_member}

### parse_member

`static`

```cpp
static struct drgn_error * parse_member(struct drgn_debug_info * dbinfo, struct drgn_elf_file * file, Dwarf_Die * die, bool little_endian, bool can_be_incomplete_array, struct drgn_compound_type_builder * builder)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:5790

---

{#drgn_dwarf_template_type_parameter_thunk_fn}

### drgn_dwarf_template_type_parameter_thunk_fn

`static`

```cpp
static struct drgn_error * drgn_dwarf_template_type_parameter_thunk_fn(struct drgn_object * res, void * arg_)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:5843

---

{#drgn_dwarf_template_value_parameter_thunk_fn}

### drgn_dwarf_template_value_parameter_thunk_fn

`static`

```cpp
static struct drgn_error * drgn_dwarf_template_value_parameter_thunk_fn(struct drgn_object * res, void * arg_)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:5866

---

{#maybe_parse_template_parameter}

### maybe_parse_template_parameter

`static`

```cpp
static struct drgn_error * maybe_parse_template_parameter(struct drgn_debug_info * dbinfo, struct drgn_elf_file * file, Dwarf_Die * die, struct drgn_template_parameters_builder * builder)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:5883

---

{#drgn_parse_template_parameter_pack}

### drgn_parse_template_parameter_pack

`static`

```cpp
static struct drgn_error * drgn_parse_template_parameter_pack(struct drgn_debug_info * dbinfo, struct drgn_elf_file * file, Dwarf_Die * die, struct drgn_template_parameters_builder * builder)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:5941

---

{#drgn_compound_type_from_dwarf}

### drgn_compound_type_from_dwarf

`static`

```cpp
static struct drgn_error * drgn_compound_type_from_dwarf(struct drgn_debug_info * dbinfo, struct drgn_elf_file * file, Dwarf_Die * die, const struct drgn_language * lang, enum drgn_type_kind kind, struct drgn_type ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:5962

---

{#parse_enumerator}

### parse_enumerator

`static`

```cpp
static struct drgn_error * parse_enumerator(Dwarf_Die * die, struct drgn_enum_type_builder * builder, bool * is_signed)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:6073

---

{#enum_compatible_type_fallback}

### enum_compatible_type_fallback

`static`

```cpp
static struct drgn_error * enum_compatible_type_fallback(struct drgn_debug_info * dbinfo, Dwarf_Die * die, bool is_signed, const struct drgn_language * lang, struct drgn_type ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:6121

---

{#drgn_enum_type_from_dwarf}

### drgn_enum_type_from_dwarf

`static`

```cpp
static struct drgn_error * drgn_enum_type_from_dwarf(struct drgn_debug_info * dbinfo, struct drgn_elf_file * file, Dwarf_Die * die, const struct drgn_language * lang, struct drgn_type ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:6138

---

{#drgn_typedef_type_from_dwarf}

### drgn_typedef_type_from_dwarf

`static`

```cpp
static struct drgn_error * drgn_typedef_type_from_dwarf(struct drgn_debug_info * dbinfo, struct drgn_elf_file * file, Dwarf_Die * die, const struct drgn_language * lang, bool can_be_incomplete_array, bool * is_incomplete_array_ret, struct drgn_type ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:6223

---

{#drgn_pointer_type_from_dwarf}

### drgn_pointer_type_from_dwarf

`static`

```cpp
static struct drgn_error * drgn_pointer_type_from_dwarf(struct drgn_debug_info * dbinfo, struct drgn_elf_file * file, Dwarf_Die * die, const struct drgn_language * lang, struct drgn_type ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:6250

---

{#define_vector-15}

### DEFINE_VECTOR

```cpp
DEFINE_VECTOR(array_dimension_vector, struct array_dimension)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:6298

---

{#subrange_length}

### subrange_length

`static`

```cpp
static struct drgn_error * subrange_length(Dwarf_Die * die, struct array_dimension * dimension)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:6300

---

{#drgn_array_type_from_dwarf}

### drgn_array_type_from_dwarf

`static`

```cpp
static struct drgn_error * drgn_array_type_from_dwarf(struct drgn_debug_info * dbinfo, struct drgn_elf_file * file, Dwarf_Die * die, const struct drgn_language * lang, bool can_be_incomplete_array, bool * is_incomplete_array_ret, struct drgn_type ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:6346

---

{#drgn_dwarf_formal_parameter_thunk_fn}

### drgn_dwarf_formal_parameter_thunk_fn

`static`

```cpp
static struct drgn_error * drgn_dwarf_formal_parameter_thunk_fn(struct drgn_object * res, void * arg_)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:6416

---

{#parse_formal_parameter}

### parse_formal_parameter

`static`

```cpp
static struct drgn_error * parse_formal_parameter(struct drgn_debug_info * dbinfo, struct drgn_elf_file * file, Dwarf_Die * die, struct drgn_function_type_builder * builder)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:6439

---

{#drgn_function_type_from_dwarf}

### drgn_function_type_from_dwarf

`static`

```cpp
static struct drgn_error * drgn_function_type_from_dwarf(struct drgn_debug_info * dbinfo, struct drgn_elf_file * file, Dwarf_Die * die, const struct drgn_language * lang, struct drgn_type ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:6477

---

{#find_enclosing_namespace}

### find_enclosing_namespace

`static`

```cpp
static struct drgn_error * find_enclosing_namespace(struct drgn_namespace_dwarf_index * global_namespace, const char ** name, size_t * name_len, struct drgn_namespace_dwarf_index ** namespace_ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:6716

---

{#define_vector-16}

### DEFINE_VECTOR

```cpp
DEFINE_VECTOR(drgn_dwarf_fde_vector, struct drgn_dwarf_fde)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:6871

---

{#define_vector-17}

### DEFINE_VECTOR

```cpp
DEFINE_VECTOR(drgn_dwarf_cie_vector, struct drgn_dwarf_cie)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:6872

---

{#define_hash_map-2}

### DEFINE_HASH_MAP

```cpp
DEFINE_HASH_MAP(drgn_dwarf_cie_map, size_t, size_t, int_key_hash_pair, scalar_key_eq)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:6873

---

{#drgn_dwarf_cfi_next_encoded}

### drgn_dwarf_cfi_next_encoded

`static`

```cpp
static struct drgn_error * drgn_dwarf_cfi_next_encoded(struct drgn_elf_file_section_buffer * buffer, uint8_t address_size, uint8_t encoding, uint64_t func_addr, uint64_t * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:6877

---

{#drgn_parse_dwarf_cie}

### drgn_parse_dwarf_cie

`static`

```cpp
static struct drgn_error * drgn_parse_dwarf_cie(struct drgn_elf_file * file, enum drgn_section_index scn, size_t cie_pointer, struct drgn_dwarf_cie * cie)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:6974

---

{#drgn_debug_info_cache_sh_addr}

### drgn_debug_info_cache_sh_addr

`static`

```cpp
static void drgn_debug_info_cache_sh_addr(struct drgn_elf_file * file, enum drgn_section_index scn, uint64_t * addr)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:7148

---

{#drgn_dwarf_fde_compar}

### drgn_dwarf_fde_compar

`static`

```cpp
static int drgn_dwarf_fde_compar(const void * _a, const void * _b)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:7160

---

{#drgn_parse_dwarf_cfi}

### drgn_parse_dwarf_cfi

`static`

```cpp
static struct drgn_error * drgn_parse_dwarf_cfi(struct drgn_dwarf_cfi * cfi, struct drgn_elf_file * file, enum drgn_section_index scn)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:7172

---

{#drgn_find_dwarf_fde}

### drgn_find_dwarf_fde

`static`

```cpp
static struct drgn_dwarf_fde * drgn_find_dwarf_fde(struct drgn_dwarf_cfi * cfi, uint64_t unbiased_pc)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:7331

---

{#drgn_dwarf_cfi_next_offset}

### drgn_dwarf_cfi_next_offset

`static`

```cpp
static struct drgn_error * drgn_dwarf_cfi_next_offset(struct drgn_elf_file_section_buffer * buffer, int64_t * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:7347

---

{#drgn_dwarf_cfi_next_offset_sf}

### drgn_dwarf_cfi_next_offset_sf

`static`

```cpp
static struct drgn_error * drgn_dwarf_cfi_next_offset_sf(struct drgn_elf_file_section_buffer * buffer, struct drgn_dwarf_cie * cie, int64_t * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:7361

---

{#drgn_dwarf_cfi_next_offset_f}

### drgn_dwarf_cfi_next_offset_f

`static`

```cpp
static struct drgn_error * drgn_dwarf_cfi_next_offset_f(struct drgn_elf_file_section_buffer * buffer, struct drgn_dwarf_cie * cie, int64_t * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:7374

---

{#drgn_dwarf_cfi_next_block}

### drgn_dwarf_cfi_next_block

`static`

```cpp
static struct drgn_error * drgn_dwarf_cfi_next_block(struct drgn_elf_file_section_buffer * buffer, const char ** buf_ret, size_t * size_ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:7387

---

{#define_vector-18}

### DEFINE_VECTOR

```cpp
DEFINE_VECTOR(drgn_cfi_row_vector, struct drgn_cfi_row *)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:7404

---

{#drgn_eval_dwarf_cfi}

### drgn_eval_dwarf_cfi

`static`

```cpp
static struct drgn_error * drgn_eval_dwarf_cfi(struct drgn_elf_file * file, enum drgn_section_index scn, struct drgn_dwarf_cie * cie, struct drgn_dwarf_fde * fde, const struct drgn_cfi_row * initial_row, uint64_t target, const char * instructions, size_t instructions_size, struct drgn_cfi_row ** row)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:7407

---

{#drgn_find_cfi_row_in_dwarf_fde}

### drgn_find_cfi_row_in_dwarf_fde

`static`

```cpp
static struct drgn_error * drgn_find_cfi_row_in_dwarf_fde(struct drgn_dwarf_cfi * cfi, struct drgn_elf_file * file, enum drgn_section_index scn, struct drgn_dwarf_fde * fde, uint64_t unbiased_pc, struct drgn_cfi_row ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:7742

---

{#drgn_find_dwarf_cfi}

### drgn_find_dwarf_cfi

`static`

```cpp
static struct drgn_error * drgn_find_dwarf_cfi(struct drgn_dwarf_cfi * cfi, struct drgn_elf_file * file, enum drgn_section_index scn, uint64_t unbiased_pc, struct drgn_cfi_row ** row_ret, bool * interrupted_ret, drgn_register_number * ret_addr_regno_ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:7765

---

{#drgn_module_parse_debug_frame}

### drgn_module_parse_debug_frame

```cpp
struct drgn_error * drgn_module_parse_debug_frame(struct drgn_module * module)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:7784

---

{#drgn_module_find_dwarf_cfi}

### drgn_module_find_dwarf_cfi

```cpp
struct drgn_error * drgn_module_find_dwarf_cfi(struct drgn_module * module, uint64_t pc, struct drgn_cfi_row ** row_ret, bool * interrupted_ret, drgn_register_number * ret_addr_regno_ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:7791

---

{#drgn_module_parse_eh_frame}

### drgn_module_parse_eh_frame

```cpp
struct drgn_error * drgn_module_parse_eh_frame(struct drgn_module * module)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:7801

---

{#drgn_module_find_eh_cfi}

### drgn_module_find_eh_cfi

```cpp
struct drgn_error * drgn_module_find_eh_cfi(struct drgn_module * module, uint64_t pc, struct drgn_cfi_row ** row_ret, bool * interrupted_ret, drgn_register_number * ret_addr_regno_ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:7808

---

{#drgn_eval_cfi_dwarf_expression}

### drgn_eval_cfi_dwarf_expression

```cpp
struct drgn_error * drgn_eval_cfi_dwarf_expression(struct drgn_program * prog, struct drgn_elf_file * file, const struct drgn_cfi_rule * rule, const struct drgn_register_state * regs, void * buf, size_t size)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:7819

---

{#find_elf_file_symtab}

### find_elf_file_symtab

`static`

```cpp
static struct drgn_error * find_elf_file_symtab(struct drgn_elf_file * file, uint64_t bias, struct drgn_elf_file ** file_ret, uint64_t * bias_ret, Elf_Scn ** scn_ret, GElf_Word * strtab_idx_ret, GElf_Word * num_local_symbols_ret, bool * full_symtab_ret, Elf_Scn ** gnu_debugdata_ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/elf_symtab.c:28

---

{#load_gnu_debugdata_file}

### load_gnu_debugdata_file

`static`

```cpp
static struct drgn_error * load_gnu_debugdata_file(struct drgn_module * module, Elf_Scn * gnu_debugdata_scn, struct drgn_elf_file ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/elf_symtab.c:187

---

{#set_elf_symtab}

### set_elf_symtab

`static`

```cpp
static struct drgn_error * set_elf_symtab(struct drgn_elf_symbol_table * symtab, struct drgn_elf_file * file, uint64_t bias, Elf_Scn * symtab_scn, GElf_Word strtab_idx, GElf_Word num_local_symbols)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/elf_symtab.c:198

---

{#cleanup_elf_file}

### cleanup_elf_file

`static`

```cpp
static void cleanup_elf_file(struct drgn_elf_file ** pfile)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/elf_symtab.c:245

---

{#find_module_elf_symtab}

### find_module_elf_symtab

`static`

```cpp
static struct drgn_error * find_module_elf_symtab(struct drgn_module * module)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/elf_symtab.c:253

---

{#elf_symbol_shndx}

### elf_symbol_shndx

`static`

```cpp
static size_t elf_symbol_shndx(struct drgn_elf_symbol_table * symtab, size_t sym_idx, const GElf_Sym * sym)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/elf_symtab.c:383

---

{#elf_symbol_address}

### elf_symbol_address

`static`

```cpp
static bool elf_symbol_address(struct drgn_elf_symbol_table * symtab, size_t sym_idx, const GElf_Sym * sym, uint64_t * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/elf_symtab.c:401

---

{#drgn_symbol_binding_precedence}

### drgn_symbol_binding_precedence

`static`

```cpp
static int drgn_symbol_binding_precedence(const struct drgn_symbol * sym)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/elf_symtab.c:457

---

{#elf_symbol_binding_precedence}

### elf_symbol_binding_precedence

`static`

```cpp
static int elf_symbol_binding_precedence(const GElf_Sym * sym)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/elf_symtab.c:473

---

{#better_addr_match}

### better_addr_match

`static`

```cpp
static bool better_addr_match(const GElf_Sym * a, uint64_t a_addr, const struct drgn_symbol * b)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/elf_symtab.c:487

---

{#better_sizeless_addr_match}

### better_sizeless_addr_match

`static`

```cpp
static bool better_sizeless_addr_match(const GElf_Sym * a, uint64_t a_addr, const GElf_Sym * b, uint64_t b_addr)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/elf_symtab.c:511

---

{#addr_in_sym_section}

### addr_in_sym_section

`static`

```cpp
static bool addr_in_sym_section(struct drgn_elf_symbol_table * symtab, size_t sym_idx, const GElf_Sym * sym, uint64_t unbiased_addr)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/elf_symtab.c:526

---

{#drgn_elf_symbol_table_search}

### drgn_elf_symbol_table_search

`static`

```cpp
static struct drgn_error * drgn_elf_symbol_table_search(struct drgn_elf_symbol_table * symtab, const char * name, uint64_t addr, enum drgn_find_symbol_flags flags, struct elf_symtab_search_state * state, struct drgn_symbol_result_builder * builder)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/elf_symtab.c:569

---

{#__attribute__-8}

### __attribute__

```cpp
const uint8_t hash_table_empty_chunk_header[16] __attribute__((__aligned__(16)))
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/hash_table.c:6

---

{#c_declare_variable}

### c_declare_variable

`static`

```cpp
static struct drgn_error * c_declare_variable(struct drgn_qualified_type qualified_type, struct string_callback * name, size_t indent, bool define_anonymous_type, struct string_builder * sb)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/language_c.c:358

---

{#c_define_type}

### c_define_type

`static`

```cpp
static struct drgn_error * c_define_type(struct drgn_qualified_type qualified_type, size_t indent, struct string_builder * sb)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/language_c.c:517

---

{#append_tabs}

### append_tabs

`static`

```cpp
static bool append_tabs(int n, struct string_builder * sb)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/language_c.c:37

---

{#c_variable_name}

### c_variable_name

`static`

```cpp
static struct drgn_error * c_variable_name(struct string_callback * name, void * arg, struct string_builder * sb)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/language_c.c:46

---

{#c_append_qualifiers}

### c_append_qualifiers

`static`

```cpp
static struct drgn_error * c_append_qualifiers(enum drgn_qualifiers qualifiers, struct string_builder * sb)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/language_c.c:54

---

{#c_declare_basic}

### c_declare_basic

`static`

```cpp
static struct drgn_error * c_declare_basic(struct drgn_qualified_type qualified_type, struct string_callback * name, size_t indent, struct string_builder * sb)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/language_c.c:81

---

{#c_append_tagged_name}

### c_append_tagged_name

`static`

```cpp
static struct drgn_error * c_append_tagged_name(struct drgn_qualified_type qualified_type, size_t indent, bool need_keyword, struct string_builder * sb)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/language_c.c:111

---

{#c_declare_tagged}

### c_declare_tagged

`static`

```cpp
static struct drgn_error * c_declare_tagged(struct drgn_qualified_type qualified_type, struct string_callback * name, size_t indent, bool define_anonymous_type, struct string_builder * sb)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/language_c.c:163

---

{#c_pointer_name}

### c_pointer_name

`static`

```cpp
static struct drgn_error * c_pointer_name(struct string_callback * name, void * arg, struct string_builder * sb)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/language_c.c:190

---

{#c_declare_pointer}

### c_declare_pointer

`static`

```cpp
static struct drgn_error * c_declare_pointer(struct drgn_qualified_type qualified_type, struct string_callback * name, size_t indent, struct string_builder * sb)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/language_c.c:230

---

{#c_array_name}

### c_array_name

`static`

```cpp
static struct drgn_error * c_array_name(struct string_callback * name, void * arg, struct string_builder * sb)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/language_c.c:246

---

{#c_declare_array}

### c_declare_array

`static`

```cpp
static struct drgn_error * c_declare_array(struct drgn_qualified_type qualified_type, struct string_callback * name, size_t indent, struct string_builder * sb)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/language_c.c:269

---

{#c_function_name}

### c_function_name

`static`

```cpp
static struct drgn_error * c_function_name(struct string_callback * name, void * arg, struct string_builder * sb)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/language_c.c:284

---

{#c_declare_function}

### c_declare_function

`static`

```cpp
static struct drgn_error * c_declare_function(struct drgn_qualified_type qualified_type, struct string_callback * name, size_t indent, struct string_builder * sb)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/language_c.c:337

---

{#c_define_compound}

### c_define_compound

`static`

```cpp
static struct drgn_error * c_define_compound(struct drgn_qualified_type qualified_type, size_t indent, struct string_builder * sb)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/language_c.c:392

---

{#c_define_enum}

### c_define_enum

`static`

```cpp
static struct drgn_error * c_define_enum(struct drgn_qualified_type qualified_type, size_t indent, struct string_builder * sb)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/language_c.c:445

---

{#c_define_typedef}

### c_define_typedef

`static`

```cpp
static struct drgn_error * c_define_typedef(struct drgn_qualified_type qualified_type, size_t indent, struct string_builder * sb)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/language_c.c:490

---

{#c_format_type_name_impl}

### c_format_type_name_impl

`static`

```cpp
static struct drgn_error * c_format_type_name_impl(struct drgn_qualified_type qualified_type, struct string_builder * sb)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/language_c.c:551

---

{#c_format_type_name}

### c_format_type_name

`static`

```cpp
static struct drgn_error * c_format_type_name(struct drgn_qualified_type qualified_type, char ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/language_c.c:567

---

{#c_format_type}

### c_format_type

`static`

```cpp
static struct drgn_error * c_format_type(struct drgn_qualified_type qualified_type, char ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/language_c.c:581

---

{#c_format_variable_declaration}

### c_format_variable_declaration

`static`

```cpp
static struct drgn_error * c_format_variable_declaration(struct drgn_qualified_type qualified_type, const char * name, char ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/language_c.c:598

---

{#c_format_object_impl}

### c_format_object_impl

`static`

```cpp
static struct drgn_error * c_format_object_impl(const struct drgn_object * obj, size_t indent, size_t one_line_columns, size_t multi_line_columns, const struct drgn_format_object_options * options, struct string_builder * sb)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/language_c.c:1644

---

{#is_character_type}

### is_character_type

`static`

```cpp
static bool is_character_type(struct drgn_type * type)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/language_c.c:622

---

{#c_format_character}

### c_format_character

`static`

```cpp
static struct drgn_error * c_format_character(unsigned char c, bool escape_single_quote, bool escape_double_quote, struct string_builder * sb)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/language_c.c:635

---

{#c_format_string}

### c_format_string

`static`

```cpp
static struct drgn_error * c_format_string(struct drgn_program * prog, uint64_t address, uint64_t length, struct string_builder * sb)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/language_c.c:691

---

{#c_format_int_object}

### c_format_int_object

`static`

```cpp
static struct drgn_error * c_format_int_object(const struct drgn_object * obj, const struct drgn_format_object_options * options, struct string_builder * sb)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/language_c.c:719

---

{#c_format_float_object}

### c_format_float_object

`static`

```cpp
static struct drgn_error * c_format_float_object(const struct drgn_object * obj, struct string_builder * sb)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/language_c.c:856

---

{#c_format_initializer}

### c_format_initializer

`static`

```cpp
static struct drgn_error * c_format_initializer(struct drgn_program * prog, struct initializer_iter * iter, size_t indent, size_t one_line_columns, size_t multi_line_columns, const struct drgn_format_object_options * options, bool same_line, struct string_builder * sb)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/language_c.c:887

---

{#define_vector-19}

### DEFINE_VECTOR

```cpp
DEFINE_VECTOR(compound_initializer_stack, struct compound_initializer_state)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/language_c.c:1087

---

{#compound_initializer_iter_next}

### compound_initializer_iter_next

`static`

```cpp
static struct drgn_error * compound_initializer_iter_next(struct initializer_iter * iter_, struct drgn_object * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/language_c.c:1097

---

{#compound_initializer_iter_reset}

### compound_initializer_iter_reset

`static`

```cpp
static void compound_initializer_iter_reset(struct initializer_iter * iter_)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/language_c.c:1170

---

{#compound_initializer_append_designation}

### compound_initializer_append_designation

`static`

```cpp
static struct drgn_error * compound_initializer_append_designation(struct initializer_iter * iter_, struct string_builder * sb)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/language_c.c:1180

---

{#c_format_compound_object}

### c_format_compound_object

`static`

```cpp
static struct drgn_error * c_format_compound_object(const struct drgn_object * obj, struct drgn_type * underlying_type, size_t indent, size_t one_line_columns, size_t multi_line_columns, const struct drgn_format_object_options * options, struct string_builder * sb)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/language_c.c:1195

---

{#c_format_enum_object}

### c_format_enum_object

`static`

```cpp
static struct drgn_error * c_format_enum_object(const struct drgn_object * obj, struct drgn_type * underlying_type, struct string_builder * sb)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/language_c.c:1295

---

{#c_format_pointer_object}

### c_format_pointer_object

`static`

```cpp
static struct drgn_error * c_format_pointer_object(const struct drgn_object * obj, struct drgn_type * underlying_type, size_t indent, size_t one_line_columns, size_t multi_line_columns, const struct drgn_format_object_options * options, struct string_builder * sb)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/language_c.c:1348

---

{#array_initializer_iter_next}

### array_initializer_iter_next

`static`

```cpp
static struct drgn_error * array_initializer_iter_next(struct initializer_iter * iter_, struct drgn_object * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/language_c.c:1470

---

{#array_initializer_iter_reset}

### array_initializer_iter_reset

`static`

```cpp
static void array_initializer_iter_reset(struct initializer_iter * iter_)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/language_c.c:1502

---

{#array_initializer_append_designation}

### array_initializer_append_designation

`static`

```cpp
static struct drgn_error * array_initializer_append_designation(struct initializer_iter * iter_, struct string_builder * sb)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/language_c.c:1511

---

{#c_format_array_object}

### c_format_array_object

`static`

```cpp
static struct drgn_error * c_format_array_object(const struct drgn_object * obj, struct drgn_type * underlying_type, size_t indent, size_t one_line_columns, size_t multi_line_columns, const struct drgn_format_object_options * options, struct string_builder * sb)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/language_c.c:1523

---

{#c_format_function_object}

### c_format_function_object

`static`

```cpp
static struct drgn_error * c_format_function_object(const struct drgn_object * obj, struct string_builder * sb)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/language_c.c:1620

---

{#drgn_absence_reason_str}

### drgn_absence_reason_str

`static`

```cpp
static const char * drgn_absence_reason_str(enum drgn_absence_reason reason)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/language_c.c:1629

---

{#c_format_object}

### c_format_object

`static`

```cpp
static struct drgn_error * c_format_object(const struct drgn_object * obj, const struct drgn_format_object_options * options, char ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/language_c.c:1724

---

{#drgn_c_family_lexer_func-1}

### drgn_c_family_lexer_func

```cpp
struct drgn_error * drgn_c_family_lexer_func(struct drgn_lexer * lexer, struct drgn_token * token)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/language_c.c:1742

---

{#c_token_to_u64}

### c_token_to_u64

`static`

```cpp
static struct drgn_error * c_token_to_u64(const struct drgn_token * token, uint64_t * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/language_c.c:1866

---

{#cpp_append_to_identifier}

### cpp_append_to_identifier

`static`

```cpp
static struct drgn_error * cpp_append_to_identifier(struct drgn_lexer * lexer, const char * identifier, size_t * len_ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/language_c.c:2193

---

{#c_parse_specifier_qualifier_list}

### c_parse_specifier_qualifier_list

`static`

```cpp
static struct drgn_error * c_parse_specifier_qualifier_list(struct drgn_program * prog, struct drgn_lexer * lexer, const char * filename, struct drgn_qualified_type * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/language_c.c:2226

---

{#c_parse_abstract_declarator}

### c_parse_abstract_declarator

`static`

```cpp
static struct drgn_error * c_parse_abstract_declarator(struct drgn_program * prog, struct drgn_lexer * lexer, struct c_declarator ** outer, struct c_declarator ** inner)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/language_c.c:2568

---

{#c_parse_optional_type_qualifier_list}

### c_parse_optional_type_qualifier_list

`static`

```cpp
static struct drgn_error * c_parse_optional_type_qualifier_list(struct drgn_lexer * lexer, enum drgn_qualifiers * qualifiers)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/language_c.c:2402

---

{#c_parse_pointer}

### c_parse_pointer

`static`

```cpp
static struct drgn_error * c_parse_pointer(struct drgn_program * prog, struct drgn_lexer * lexer, struct c_declarator ** outer, struct c_declarator ** inner)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/language_c.c:2426

---

{#c_parse_direct_abstract_declarator}

### c_parse_direct_abstract_declarator

`static`

```cpp
static struct drgn_error * c_parse_direct_abstract_declarator(struct drgn_program * prog, struct drgn_lexer * lexer, struct c_declarator ** outer, struct c_declarator ** inner)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/language_c.c:2466

---

{#c_type_from_declarator}

### c_type_from_declarator

`static`

```cpp
static struct drgn_error * c_type_from_declarator(struct drgn_program * prog, struct c_declarator * declarator, struct drgn_qualified_type * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/language_c.c:2607

---

{#c_family_find_type}

### c_family_find_type

`static`

```cpp
static struct drgn_error * c_family_find_type(const struct drgn_language * lang, struct drgn_program * prog, const char * name, const char * filename, struct drgn_qualified_type * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/language_c.c:2656

---

{#c_family_type_subobject}

### c_family_type_subobject

`static`

```cpp
static struct drgn_error * c_family_type_subobject(struct drgn_type * type, const char * designator, bool expect_member, struct drgn_qualified_type * type_ret, uint64_t * bit_offset_ret, uint64_t * bit_field_size_ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/language_c.c:2711

---

{#c_integer_literal}

### c_integer_literal

`static`

```cpp
static struct drgn_error * c_integer_literal(struct drgn_object * res, uint64_t uvalue)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/language_c.c:2845

---

{#c_bool_literal}

### c_bool_literal

`static`

```cpp
static struct drgn_error * c_bool_literal(struct drgn_object * res, bool bvalue)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/language_c.c:2881

---

{#c_float_literal}

### c_float_literal

`static`

```cpp
static struct drgn_error * c_float_literal(struct drgn_object * res, double fvalue)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/language_c.c:2895

---

{#c_can_represent_all_values}

### c_can_represent_all_values

`static`

```cpp
static bool c_can_represent_all_values(struct drgn_type * type1, uint64_t bit_field_size1, struct drgn_type * type2, uint64_t bit_field_size2)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/language_c.c:2925

---

{#c_integer_promotions}

### c_integer_promotions

`static`

```cpp
static struct drgn_error * c_integer_promotions(struct drgn_program * prog, struct drgn_operand_type * type)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/language_c.c:2958

---

{#c_corresponding_unsigned_type}

### c_corresponding_unsigned_type

`static`

```cpp
static struct drgn_error * c_corresponding_unsigned_type(struct drgn_program * prog, enum drgn_primitive_type type, struct drgn_type ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/language_c.c:3062

---

{#c_common_real_type}

### c_common_real_type

`static`

```cpp
static struct drgn_error * c_common_real_type(struct drgn_program * prog, struct drgn_operand_type * type1, struct drgn_operand_type * type2, struct drgn_operand_type * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/language_c.c:3088

---

{#c_types_compatible_impl}

### c_types_compatible_impl

`static`

```cpp
static struct drgn_error * c_types_compatible_impl(struct drgn_qualified_type qualified_type1, struct drgn_qualified_type qualified_type2, bool * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/language_c.c:3279

---

{#c_types_compatible}

### c_types_compatible

`static`

```cpp
static struct drgn_error * c_types_compatible(struct drgn_qualified_type qualified_type1, struct drgn_qualified_type qualified_type2, bool * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/language_c.c:3431

---

{#c_operand_type}

### c_operand_type

`static`

```cpp
static struct drgn_error * c_operand_type(const struct drgn_object * obj, struct drgn_operand_type * type_ret, bool * is_pointer_ret, uint64_t * referenced_size_ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/language_c.c:3439

---

{#c_op_cast}

### c_op_cast

`static`

```cpp
static struct drgn_error * c_op_cast(struct drgn_object * res, struct drgn_qualified_type qualified_type, const struct drgn_object * obj)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/language_c.c:3512

---

{#c_op_implicit_convert}

### c_op_implicit_convert

`static`

```cpp
static struct drgn_error * c_op_implicit_convert(struct drgn_object * res, struct drgn_qualified_type qualified_type, uint64_t bit_field_size, const struct drgn_object * obj)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/language_c.c:3547

---

{#c_pointers_similar}

### c_pointers_similar

`static`

```cpp
static bool c_pointers_similar(const struct drgn_operand_type * lhs_type, const struct drgn_operand_type * rhs_type, uint64_t lhs_size, uint64_t rhs_size)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/language_c.c:3668

---

{#c_op_bool}

### c_op_bool

`static`

```cpp
static struct drgn_error * c_op_bool(const struct drgn_object * obj, bool * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/language_c.c:3680

---

{#c_op_cmp}

### c_op_cmp

`static`

```cpp
static struct drgn_error * c_op_cmp(const struct drgn_object * lhs, const struct drgn_object * rhs, int * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/language_c.c:3717

---

{#c_op_add}

### c_op_add

`static`

```cpp
static struct drgn_error * c_op_add(struct drgn_object * res, const struct drgn_object * lhs, const struct drgn_object * rhs)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/language_c.c:3752

---

{#c_op_sub}

### c_op_sub

`static`

```cpp
static struct drgn_error * c_op_sub(struct drgn_object * res, const struct drgn_object * lhs, const struct drgn_object * rhs)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/language_c.c:3793

---

{#drgn_splay_tree_transplant}

### drgn_splay_tree_transplant

`static` `inline`

```cpp
static inline void drgn_splay_tree_transplant(struct binary_tree_node ** root, struct binary_tree_node * old, struct binary_tree_node * new)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/splay_tree.c:149

---

{#drgn_stack_trace_destroyp}

### drgn_stack_trace_destroyp

`static` `inline`

```cpp
static inline void drgn_stack_trace_destroyp(struct drgn_stack_trace ** tracep)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/stack_trace.c:37

---

{#drgn_stack_trace_append_frame}

### drgn_stack_trace_append_frame

`static`

```cpp
static struct drgn_error * drgn_stack_trace_append_frame(struct drgn_stack_trace ** trace, size_t * capacity, struct drgn_register_state * regs, Dwarf_Die * scopes, size_t num_scopes, size_t function_scope)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/stack_trace.c:43

---

{#drgn_stack_trace_shrink_to_fit}

### drgn_stack_trace_shrink_to_fit

`static`

```cpp
static void drgn_stack_trace_shrink_to_fit(struct drgn_stack_trace ** trace, size_t capacity)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/stack_trace.c:77

---

{#drgn_format_stack_frame_source_impl}

### drgn_format_stack_frame_source_impl

`static`

```cpp
static struct drgn_error * drgn_format_stack_frame_source_impl(struct drgn_stack_trace * trace, size_t frame, struct string_builder * sb)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/stack_trace.c:240

---

{#drgn_get_stack_trace_obj}

### drgn_get_stack_trace_obj

`static`

```cpp
static struct drgn_error * drgn_get_stack_trace_obj(struct drgn_object * res, const struct drgn_object * thread_obj, bool * is_pt_regs_ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/stack_trace.c:658

---

{#drgn_get_initial_registers_from_prstatus}

### drgn_get_initial_registers_from_prstatus

`static`

```cpp
static struct drgn_error * drgn_get_initial_registers_from_prstatus(struct drgn_program * prog, const struct nstring * prstatus, struct drgn_register_state ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/stack_trace.c:705

---

{#drgn_get_initial_registers_from_kernel_core_dump}

### drgn_get_initial_registers_from_kernel_core_dump

`static`

```cpp
static struct drgn_error * drgn_get_initial_registers_from_kernel_core_dump(struct drgn_program * prog, uint64_t cpu, struct drgn_register_state ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/stack_trace.c:721

---

{#drgn_get_initial_registers}

### drgn_get_initial_registers

`static`

```cpp
static struct drgn_error * drgn_get_initial_registers(struct drgn_program * prog, uint32_t tid, const struct drgn_object * thread_obj, struct drgn_register_state ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/stack_trace.c:825

---

{#drgn_add_to_register}

### drgn_add_to_register

`static`

```cpp
static void drgn_add_to_register(void * dst, size_t dst_size, const void * src, size_t src_size, int64_t addend, bool little_endian)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/stack_trace.c:921

---

{#drgn_stack_trace_add_frames}

### drgn_stack_trace_add_frames

`static`

```cpp
static struct drgn_error * drgn_stack_trace_add_frames(struct drgn_stack_trace ** trace, size_t * trace_capacity, struct drgn_register_state * regs)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/stack_trace.c:953

---

{#drgn_unwind_one_register}

### drgn_unwind_one_register

`static`

```cpp
static struct drgn_error * drgn_unwind_one_register(struct drgn_program * prog, struct drgn_elf_file * file, const struct drgn_cfi_rule * rule, const struct drgn_register_state * regs, void * buf, size_t size)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/stack_trace.c:1100

---

{#drgn_unwind_cfa}

### drgn_unwind_cfa

`static`

```cpp
static struct drgn_error * drgn_unwind_cfa(struct drgn_program * prog, struct drgn_elf_file * file, const struct drgn_cfi_row * row, struct drgn_register_state * regs)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/stack_trace.c:1181

---

{#drgn_unwind_with_cfi}

### drgn_unwind_with_cfi

`static`

```cpp
static struct drgn_error * drgn_unwind_with_cfi(struct drgn_program * prog, struct drgn_cfi_row ** row, struct drgn_register_state * regs, struct drgn_register_state ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/stack_trace.c:1206

---

{#drgn_is_bad_call}

### drgn_is_bad_call

`static`

```cpp
static bool drgn_is_bad_call(const struct drgn_register_state * regs)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/stack_trace.c:1284

---

{#drgn_get_stack_trace}

### drgn_get_stack_trace

`static`

```cpp
static struct drgn_error * drgn_get_stack_trace(struct drgn_program * prog, uint32_t tid, const struct drgn_object * obj, const struct nstring * prstatus, struct drgn_stack_trace ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/stack_trace.c:1295

---

{#locs_to_trace}

### locs_to_trace

`static`

```cpp
static struct drgn_stack_trace * locs_to_trace(struct drgn_source_location_list * locs)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/stack_trace.c:1448

---

{#drgn_type_kind_str}

### drgn_type_kind_str

`static`

```cpp
static const char * drgn_type_kind_str(struct drgn_type * type)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/type.c:19

---

{#drgntype_wrap-1}

### DrgnType_wrap

```cpp
DRGNPY_PUBLIC PyObject * DrgnType_wrap(struct drgn_qualified_type qualified_type)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/type.c:24

---

{#drgntype_unwrap}

### DrgnType_unwrap

`static` `inline`

```cpp
static inline struct drgn_qualified_type DrgnType_unwrap(DrgnType * type)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/type.c:38

---

{#drgntype_get_ptr}

### DrgnType_get_ptr

`static`

```cpp
static PyObject * DrgnType_get_ptr(DrgnType * self, void * arg)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/type.c:46

---

{#drgntype_get_prog}

### DrgnType_get_prog

`static`

```cpp
static Program * DrgnType_get_prog(DrgnType * self, void * arg)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/type.c:51

---

{#drgntype_get_kind}

### DrgnType_get_kind

`static`

```cpp
static PyObject * DrgnType_get_kind(DrgnType * self)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/type.c:57

---

{#drgntype_get_primitive}

### DrgnType_get_primitive

`static`

```cpp
static PyObject * DrgnType_get_primitive(DrgnType * self)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/type.c:63

---

{#drgntype_get_qualifiers}

### DrgnType_get_qualifiers

`static`

```cpp
static PyObject * DrgnType_get_qualifiers(DrgnType * self)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/type.c:71

---

{#drgntype_get_language}

### DrgnType_get_language

`static`

```cpp
static PyObject * DrgnType_get_language(DrgnType * self, void * arg)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/type.c:77

---

{#drgntype_get_name}

### DrgnType_get_name

`static`

```cpp
static PyObject * DrgnType_get_name(DrgnType * self)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/type.c:82

---

{#drgntype_get_tag}

### DrgnType_get_tag

`static`

```cpp
static PyObject * DrgnType_get_tag(DrgnType * self)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/type.c:92

---

{#drgntype_get_size}

### DrgnType_get_size

`static`

```cpp
static PyObject * DrgnType_get_size(DrgnType * self)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/type.c:109

---

{#drgntype_get_length}

### DrgnType_get_length

`static`

```cpp
static PyObject * DrgnType_get_length(DrgnType * self)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/type.c:121

---

{#drgntype_get_is_signed}

### DrgnType_get_is_signed

`static`

```cpp
static PyObject * DrgnType_get_is_signed(DrgnType * self)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/type.c:134

---

{#drgntype_get_byteorder}

### DrgnType_get_byteorder

`static`

```cpp
static PyObject * DrgnType_get_byteorder(DrgnType * self, void * arg)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/type.c:148

---

{#drgntype_get_type}

### DrgnType_get_type

`static`

```cpp
static PyObject * DrgnType_get_type(DrgnType * self)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/type.c:164

---

{#typemember_wrap}

### TypeMember_wrap

`static`

```cpp
static TypeMember * TypeMember_wrap(PyObject * parent, struct drgn_type_member * member, uint64_t bit_offset)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/type.c:178

---

{#drgntype_get_members}

### DrgnType_get_members

`static`

```cpp
static PyObject * DrgnType_get_members(DrgnType * self)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/type.c:203

---

{#drgntype_get_enumerators}

### DrgnType_get_enumerators

`static`

```cpp
static PyObject * DrgnType_get_enumerators(DrgnType * self)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/type.c:232

---

{#drgntype_get_parameters}

### DrgnType_get_parameters

`static`

```cpp
static PyObject * DrgnType_get_parameters(DrgnType * self)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/type.c:272

---

{#drgntype_get_is_variadic}

### DrgnType_get_is_variadic

`static`

```cpp
static PyObject * DrgnType_get_is_variadic(DrgnType * self)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/type.c:310

---

{#drgntype_get_template_parameters}

### DrgnType_get_template_parameters

`static`

```cpp
static PyObject * DrgnType_get_template_parameters(DrgnType * self)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/type.c:320

---

{#drgntype_attr-2}

### DrgnType_ATTR

```cpp
DrgnType_ATTR(kind)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/type.c:375

---

{#drgntype_attr-3}

### DrgnType_ATTR

```cpp
DrgnType_ATTR(primitive)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/type.c:376

---

{#drgntype_attr-4}

### DrgnType_ATTR

```cpp
DrgnType_ATTR(qualifiers)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/type.c:377

---

{#drgntype_attr-5}

### DrgnType_ATTR

```cpp
DrgnType_ATTR(tag)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/type.c:379

---

{#drgntype_attr-6}

### DrgnType_ATTR

```cpp
DrgnType_ATTR(size)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/type.c:380

---

{#drgntype_attr-7}

### DrgnType_ATTR

```cpp
DrgnType_ATTR(length)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/type.c:381

---

{#drgntype_attr-8}

### DrgnType_ATTR

```cpp
DrgnType_ATTR(is_signed)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/type.c:382

---

{#drgntype_attr-9}

### DrgnType_ATTR

```cpp
DrgnType_ATTR(type)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/type.c:383

---

{#drgntype_attr-10}

### DrgnType_ATTR

```cpp
DrgnType_ATTR(members)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/type.c:384

---

{#drgntype_attr-11}

### DrgnType_ATTR

```cpp
DrgnType_ATTR(enumerators)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/type.c:385

---

{#drgntype_attr-12}

### DrgnType_ATTR

```cpp
DrgnType_ATTR(parameters)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/type.c:386

---

{#drgntype_attr-13}

### DrgnType_ATTR

```cpp
DrgnType_ATTR(is_variadic)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/type.c:387

---

{#drgntype_attr-14}

### DrgnType_ATTR

```cpp
DrgnType_ATTR(template_parameters)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/type.c:388

---

{#drgntype_cache_attr}

### DrgnType_cache_attr

`static`

```cpp
static int DrgnType_cache_attr(DrgnType * self, struct DrgnType_Attr * attr, PyObject * value)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/type.c:390

---

{#drgntype_getter}

### DrgnType_getter

`static`

```cpp
static PyObject * DrgnType_getter(DrgnType * self, struct DrgnType_Attr * attr)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/type.c:399

---

{#drgntype_dealloc}

### DrgnType_dealloc

`static`

```cpp
static void DrgnType_dealloc(DrgnType * self)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/type.c:466

---

{#drgntype_traverse}

### DrgnType_traverse

`static`

```cpp
static int DrgnType_traverse(DrgnType * self, visitproc visit, void * arg)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/type.c:475

---

{#drgntype_clear}

### DrgnType_clear

`static`

```cpp
static int DrgnType_clear(DrgnType * self)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/type.c:483

---

{#append_field}

### append_field

`static`

```cpp
static int append_field(PyObject * parts, bool * first, const char * format, ...)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/type.c:493

---

{#drgntype_repr}

### DrgnType_repr

`static`

```cpp
static PyObject * DrgnType_repr(DrgnType * self)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/type.c:523

---

{#drgntype_str}

### DrgnType_str

`static`

```cpp
static PyObject * DrgnType_str(DrgnType * self)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/type.c:595

---

{#drgntype_type_name}

### DrgnType_type_name

`static`

```cpp
static PyObject * DrgnType_type_name(DrgnType * self)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/type.c:604

---

{#drgntype_variable_declaration}

### DrgnType_variable_declaration

`static`

```cpp
static PyObject * DrgnType_variable_declaration(DrgnType * self, PyObject * args, PyObject * kwds)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/type.c:614

---

{#drgntype_is_complete}

### DrgnType_is_complete

`static`

```cpp
static PyObject * DrgnType_is_complete(DrgnType * self)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/type.c:632

---

{#qualifiers_converter}

### qualifiers_converter

`static`

```cpp
static int qualifiers_converter(PyObject * o, void * p)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/type.c:637

---

{#drgntype_qualified}

### DrgnType_qualified

`static`

```cpp
static PyObject * DrgnType_qualified(DrgnType * self, PyObject * args, PyObject * kwds)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/type.c:649

---

{#drgntype_unqualified}

### DrgnType_unqualified

`static`

```cpp
static PyObject * DrgnType_unqualified(DrgnType * self)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/type.c:665

---

{#drgntype_unaliased}

### DrgnType_unaliased

`static`

```cpp
static PyObject * DrgnType_unaliased(DrgnType * self)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/type.c:671

---

{#drgntype_unaliased_kind}

### DrgnType_unaliased_kind

`static`

```cpp
static PyObject * DrgnType_unaliased_kind(DrgnType * self)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/type.c:676

---

{#drgntype_member}

### DrgnType_member

`static`

```cpp
static TypeMember * DrgnType_member(DrgnType * self, PyObject * args, PyObject * kwds)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/type.c:682

---

{#drgntype_has_member}

### DrgnType_has_member

`static`

```cpp
static PyObject * DrgnType_has_member(DrgnType * self, PyObject * args, PyObject * kwds)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/type.c:703

---

{#typeenumerator_new}

### TypeEnumerator_new

`static`

```cpp
static TypeEnumerator * TypeEnumerator_new(PyTypeObject * subtype, PyObject * args, PyObject * kwds)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/type.c:761

---

{#typeenumerator_dealloc}

### TypeEnumerator_dealloc

`static`

```cpp
static void TypeEnumerator_dealloc(TypeEnumerator * self)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/type.c:783

---

{#typeenumerator_repr}

### TypeEnumerator_repr

`static`

```cpp
static PyObject * TypeEnumerator_repr(TypeEnumerator * self)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/type.c:791

---

{#typeenumerator_length}

### TypeEnumerator_length

`static`

```cpp
static Py_ssize_t TypeEnumerator_length(PyObject * self)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/type.c:797

---

{#typeenumerator_item}

### TypeEnumerator_item

`static`

```cpp
static PyObject * TypeEnumerator_item(TypeEnumerator * self, Py_ssize_t i)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/type.c:802

---

{#typeenumerator_richcompare}

### TypeEnumerator_richcompare

`static`

```cpp
static PyObject * TypeEnumerator_richcompare(TypeEnumerator * self, TypeEnumerator * other, int op)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/type.c:818

---

{#lazyobject_traverse}

### LazyObject_traverse

`static`

```cpp
static int LazyObject_traverse(LazyObject * self, visitproc visit, void * arg)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/type.c:849

---

{#drgntype_to_absent_drgnobject}

### DrgnType_to_absent_DrgnObject

`static`

```cpp
static DrgnObject * DrgnType_to_absent_DrgnObject(DrgnType * type)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/type.c:870

---

{#pytype_name}

### PyType_name

`static`

```cpp
static const char * PyType_name(PyTypeObject * type)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/type.c:883

---

{#lazyobject_get_borrowed}

### LazyObject_get_borrowed

`static`

```cpp
static DrgnObject * LazyObject_get_borrowed(LazyObject * self)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/type.c:890

---

{#lazyobject_get}

### LazyObject_get

`static`

```cpp
static DrgnObject * LazyObject_get(LazyObject * self, void * arg)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/type.c:951

---

{#lazyobject_get_type}

### LazyObject_get_type

`static`

```cpp
static PyObject * LazyObject_get_type(LazyObject * self, void * arg)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/type.c:958

---

{#lazyobject_dealloc}

### LazyObject_dealloc

`static`

```cpp
static void LazyObject_dealloc(LazyObject * self)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/type.c:966

---

{#append_lazy_object_repr}

### append_lazy_object_repr

`static`

```cpp
static int append_lazy_object_repr(PyObject * parts, LazyObject * self)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/type.c:972

---

{#lazyobject_arg}

### LazyObject_arg

`static`

```cpp
static int LazyObject_arg(PyObject * arg, const char * function_name, bool can_be_absent, PyObject ** obj_ret, union drgn_lazy_object ** state_ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/type.c:997

---

{#typemember_new}

### TypeMember_new

`static`

```cpp
static TypeMember * TypeMember_new(PyTypeObject * subtype, PyObject * args, PyObject * kwds)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/type.c:1032

---

{#typemember_dealloc}

### TypeMember_dealloc

`static`

```cpp
static void TypeMember_dealloc(TypeMember * self)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/type.c:1074

---

{#typemember_get_offset}

### TypeMember_get_offset

`static`

```cpp
static PyObject * TypeMember_get_offset(TypeMember * self, void * arg)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/type.c:1082

---

{#typemember_get_bit_field_size}

### TypeMember_get_bit_field_size

`static`

```cpp
static PyObject * TypeMember_get_bit_field_size(TypeMember * self, void * arg)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/type.c:1095

---

{#typemember_repr}

### TypeMember_repr

`static`

```cpp
static PyObject * TypeMember_repr(TypeMember * self)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/type.c:1106

---

{#typeparameter_new}

### TypeParameter_new

`static`

```cpp
static TypeParameter * TypeParameter_new(PyTypeObject * subtype, PyObject * args, PyObject * kwds)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/type.c:1157

---

{#typeparameter_dealloc}

### TypeParameter_dealloc

`static`

```cpp
static void TypeParameter_dealloc(TypeParameter * self)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/type.c:1191

---

{#typeparameter_repr}

### TypeParameter_repr

`static`

```cpp
static PyObject * TypeParameter_repr(TypeParameter * self)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/type.c:1198

---

{#typetemplateparameter_new}

### TypeTemplateParameter_new

`static`

```cpp
static TypeTemplateParameter * TypeTemplateParameter_new(PyTypeObject * subtype, PyObject * args, PyObject * kwds)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/type.c:1242

---

{#typetemplateparameter_dealloc}

### TypeTemplateParameter_dealloc

`static`

```cpp
static void TypeTemplateParameter_dealloc(TypeTemplateParameter * self)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/type.c:1281

---

{#typetemplateparameter_repr}

### TypeTemplateParameter_repr

`static`

```cpp
static PyObject * TypeTemplateParameter_repr(TypeTemplateParameter * self)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/type.c:1289

---

{#typetemplateparameter_get_argument}

### TypeTemplateParameter_get_argument

`static`

```cpp
static PyObject * TypeTemplateParameter_get_argument(TypeTemplateParameter * self, void * arg)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/type.c:1308

---

{#program_void_type-1}

### Program_void_type

```cpp
DrgnType * Program_void_type(Program * self, PyObject * args, PyObject * kwds)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/type.c:1350

---

{#byteorder_converter}

### byteorder_converter

`static`

```cpp
static int byteorder_converter(PyObject * o, void * p)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/type.c:1374

---

{#program_int_type-1}

### Program_int_type

```cpp
DrgnType * Program_int_type(Program * self, PyObject * args, PyObject * kwds)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/type.c:1401

---

{#program_bool_type-1}

### Program_bool_type

```cpp
DrgnType * Program_bool_type(Program * self, PyObject * args, PyObject * kwds)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/type.c:1456

---

{#program_float_type-1}

### Program_float_type

```cpp
DrgnType * Program_float_type(Program * self, PyObject * args, PyObject * kwds)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/type.c:1510

---

{#py_lazy_object_thunk_fn}

### py_lazy_object_thunk_fn

`static`

```cpp
static struct drgn_error * py_lazy_object_thunk_fn(struct drgn_object * res, void * arg)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/type.c:1565

---

{#lazy_object_from_py}

### lazy_object_from_py

`static`

```cpp
static int lazy_object_from_py(union drgn_lazy_object * lazy_obj, LazyObject * py_lazy_obj, struct drgn_program * prog, bool * can_cache)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/type.c:1578

---

{#unpack_member}

### unpack_member

`static`

```cpp
static int unpack_member(struct drgn_compound_type_builder * builder, PyObject * item, bool * can_cache)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/type.c:1605

---

{#unpack_template_parameter}

### unpack_template_parameter

`static`

```cpp
static int unpack_template_parameter(struct drgn_template_parameters_builder * builder, PyObject * item, bool * can_cache)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/type.c:1644

---

{#program_compound_type}

### Program_compound_type

`static`

```cpp
static DrgnType * Program_compound_type(Program * self, PyObject * args, PyObject * kwds, const char * arg_format, enum drgn_type_kind kind)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/type.c:1683

---

{#program_struct_type-1}

### Program_struct_type

```cpp
DrgnType * Program_struct_type(Program * self, PyObject * args, PyObject * kwds)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/type.c:1818

---

{#program_union_type-1}

### Program_union_type

```cpp
DrgnType * Program_union_type(Program * self, PyObject * args, PyObject * kwds)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/type.c:1825

---

{#program_class_type-1}

### Program_class_type

```cpp
DrgnType * Program_class_type(Program * self, PyObject * args, PyObject * kwds)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/type.c:1832

---

{#unpack_enumerator}

### unpack_enumerator

`static`

```cpp
static int unpack_enumerator(struct drgn_enum_type_builder * builder, PyObject * item, bool is_signed)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/type.c:1839

---

{#program_enum_type-1}

### Program_enum_type

```cpp
DrgnType * Program_enum_type(Program * self, PyObject * args, PyObject * kwds)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/type.c:1873

---

{#program_typedef_type-1}

### Program_typedef_type

```cpp
DrgnType * Program_typedef_type(Program * self, PyObject * args, PyObject * kwds)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/type.c:2001

---

{#program_pointer_type-1}

### Program_pointer_type

```cpp
DrgnType * Program_pointer_type(Program * self, PyObject * args, PyObject * kwds)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/type.c:2050

---

{#program_array_type-1}

### Program_array_type

```cpp
DrgnType * Program_array_type(Program * self, PyObject * args, PyObject * kwds)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/type.c:2103

---

{#unpack_parameter}

### unpack_parameter

`static`

```cpp
static int unpack_parameter(struct drgn_function_type_builder * builder, PyObject * item, bool * can_cache)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/type.c:2148

---

{#program_function_type-1}

### Program_function_type

```cpp
DrgnType * Program_function_type(Program * self, PyObject * args, PyObject * kwds)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/type.c:2184

---

{#append_string-1}

### append_string

```cpp
int append_string(PyObject * parts, const char * s)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/util.c:11

---

{#append_u64_hex-1}

### append_u64_hex

```cpp
int append_u64_hex(PyObject * parts, uint64_t value)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/util.c:19

---

{#append_formatv}

### append_formatv

`static`

```cpp
static int append_formatv(PyObject * parts, const char * format, va_list ap)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/util.c:26

---

{#append_format-1}

### append_format

```cpp
int append_format(PyObject * parts, const char * format, ...)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/util.c:34

---

{#append_attr_repr-1}

### append_attr_repr

```cpp
int append_attr_repr(PyObject * parts, PyObject * obj, const char * attr_name)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/util.c:45

---

{#append_attr_str-1}

### append_attr_str

```cpp
int append_attr_str(PyObject * parts, PyObject * obj, const char * attr_name)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/util.c:57

---

{#join_strings-1}

### join_strings

```cpp
PyObject * join_strings(PyObject * parts)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/util.c:69

---

{#repr_pretty_from_str-1}

### repr_pretty_from_str

```cpp
PyObject * repr_pretty_from_str(PyObject * self, PyObject * args, PyObject * kwds)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/util.c:77

---

{#index_converter-1}

### index_converter

```cpp
int index_converter(PyObject * o, void * p)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/util.c:95

---

{#u64_converter-1}

### u64_converter

```cpp
int u64_converter(PyObject * o, void * p)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/util.c:115

---

{#path_converter-1}

### path_converter

```cpp
int path_converter(PyObject * o, void * p)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/util.c:120

---

{#path_cleanup-1}

### path_cleanup

```cpp
void path_cleanup(struct path_arg * path)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/util.c:167

---

{#define_vector_functions-11}

### DEFINE_VECTOR_FUNCTIONS

```cpp
DEFINE_VECTOR_FUNCTIONS(path_arg_vector)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/util.c:173

---

{#path_sequence_converter-1}

### path_sequence_converter

```cpp
int path_sequence_converter(PyObject * o, void * p)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/util.c:175

---

{#path_sequence_cleanup-1}

### path_sequence_cleanup

```cpp
void path_sequence_cleanup(struct path_sequence_arg * paths)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/util.c:241

---

{#path_sequence_size-1}

### path_sequence_size

```cpp
size_t path_sequence_size(struct path_sequence_arg * paths)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/util.c:251

---

{#enum_converter-1}

### enum_converter

```cpp
int enum_converter(PyObject * o, void * p)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/util.c:256

---

{#pylong_isnegative-1}

### PyLong_IsNegative

```cpp
int PyLong_IsNegative(PyObject * obj)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/util.c:282

---

{#pylong_asint64-1}

### PyLong_AsInt64

```cpp
int PyLong_AsInt64(PyObject * obj, int64_t * value)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/util.c:295

---

{#pylong_asuint32-1}

### PyLong_AsUInt32

```cpp
int PyLong_AsUInt32(PyObject * obj, uint32_t * value)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/util.c:309

---

{#pylong_asuint64-1}

### PyLong_AsUInt64

```cpp
int PyLong_AsUInt64(PyObject * obj, uint64_t * value)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/util.c:326

---

{#pylong_asuint16-1}

### PyLong_AsUInt16

```cpp
int PyLong_AsUInt16(PyObject * obj, uint16_t * value)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/util.c:344

---

{#demangle_cfi_registers_aarch64}

### demangle_cfi_registers_aarch64

`static`

```cpp
static void demangle_cfi_registers_aarch64(struct drgn_program * prog, struct drgn_register_state * regs)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/arch_aarch64.c:55

---

{#get_initial_registers_from_struct_aarch64}

### get_initial_registers_from_struct_aarch64

`static`

```cpp
static struct drgn_error * get_initial_registers_from_struct_aarch64(struct drgn_program * prog, const void * buf, size_t size, struct drgn_register_state ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/arch_aarch64.c:77

---

{#get_stackframe_offset}

### get_stackframe_offset

`static`

```cpp
static struct drgn_error * get_stackframe_offset(struct drgn_program * prog, uint64_t * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/arch_aarch64.c:105

---

{#fallback_unwind_try_pt_regs}

### fallback_unwind_try_pt_regs

`static`

```cpp
static struct drgn_error * fallback_unwind_try_pt_regs(struct drgn_program * prog, uint64_t fp, uint64_t frame, struct drgn_register_state * regs, struct drgn_register_state ** regs_ret, bool * found_ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/arch_aarch64.c:131

---

{#fallback_unwind_aarch64}

### fallback_unwind_aarch64

`static`

```cpp
static struct drgn_error * fallback_unwind_aarch64(struct drgn_program * prog, struct drgn_register_state * regs, struct drgn_register_state ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/arch_aarch64.c:208

---

{#bad_call_unwind_aarch64}

### bad_call_unwind_aarch64

`static`

```cpp
static struct drgn_error * bad_call_unwind_aarch64(struct drgn_program * prog, struct drgn_register_state * regs, struct drgn_register_state ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/arch_aarch64.c:283

---

{#pt_regs_get_initial_registers_aarch64}

### pt_regs_get_initial_registers_aarch64

`static`

```cpp
static struct drgn_error * pt_regs_get_initial_registers_aarch64(const struct drgn_object * obj, struct drgn_register_state ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/arch_aarch64.c:307

---

{#prstatus_get_initial_registers_aarch64}

### prstatus_get_initial_registers_aarch64

`static`

```cpp
static struct drgn_error * prstatus_get_initial_registers_aarch64(struct drgn_program * prog, const void * prstatus, size_t size, struct drgn_register_state ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/arch_aarch64.c:317

---

{#linux_kernel_get_initial_registers_aarch64}

### linux_kernel_get_initial_registers_aarch64

`static`

```cpp
static struct drgn_error * linux_kernel_get_initial_registers_aarch64(const struct drgn_object * task_obj, struct drgn_register_state ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/arch_aarch64.c:337

---

{#apply_elf_reloc_aarch64}

### apply_elf_reloc_aarch64

`static`

```cpp
static struct drgn_error * apply_elf_reloc_aarch64(const struct drgn_relocating_section * relocating, uint64_t r_offset, uint32_t r_type, const int64_t * r_addend, uint64_t sym_value)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/arch_aarch64.c:377

---

{#linux_kernel_pgtable_iterator_arch_create_aarch64}

### linux_kernel_pgtable_iterator_arch_create_aarch64

`static`

```cpp
static struct drgn_error * linux_kernel_pgtable_iterator_arch_create_aarch64(struct drgn_program * prog, void ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/arch_aarch64.c:425

---

{#linux_kernel_pgtable_iterator_init_aarch64}

### linux_kernel_pgtable_iterator_init_aarch64

`static`

```cpp
static void linux_kernel_pgtable_iterator_init_aarch64(struct drgn_program * prog, struct pgtable_iterator * it)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/arch_aarch64.c:528

---

{#linux_kernel_pgtable_iterator_next_aarch64}

### linux_kernel_pgtable_iterator_next_aarch64

`static`

```cpp
static struct drgn_error * linux_kernel_pgtable_iterator_next_aarch64(struct drgn_program * prog, struct pgtable_iterator * it, uint64_t * virt_addr_ret, uint64_t * phys_addr_ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/arch_aarch64.c:545

---

{#linux_kernel_section_size_bits_fallback_aarch64}

### linux_kernel_section_size_bits_fallback_aarch64

`static`

```cpp
static int linux_kernel_section_size_bits_fallback_aarch64(struct drgn_program * prog)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/arch_aarch64.c:624

---

{#untagged_addr_aarch64}

### untagged_addr_aarch64

`static`

```cpp
static uint64_t untagged_addr_aarch64(uint64_t addr)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/arch_aarch64.c:643

---

{#get_registers_from_frame_pointer}

### get_registers_from_frame_pointer

`static`

```cpp
static struct drgn_error * get_registers_from_frame_pointer(struct drgn_program * prog, uint64_t frame_pointer, struct drgn_register_state ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/arch_x86_64.c:216

---

{#bad_call_unwind_x86_64}

### bad_call_unwind_x86_64

`static`

```cpp
static struct drgn_error * bad_call_unwind_x86_64(struct drgn_program * prog, struct drgn_register_state * regs, struct drgn_register_state ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/arch_x86_64.c:242

---

{#get_initial_registers_from_struct_x86_64}

### get_initial_registers_from_struct_x86_64

`static`

```cpp
static struct drgn_error * get_initial_registers_from_struct_x86_64(struct drgn_program * prog, const void * buf, size_t size, bool full_regset, struct drgn_register_state ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/arch_x86_64.c:281

---

{#fallback_unwind_x86_64}

### fallback_unwind_x86_64

`static`

```cpp
static struct drgn_error * fallback_unwind_x86_64(struct drgn_program * prog, struct drgn_register_state * regs, struct drgn_register_state ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/arch_x86_64.c:318

---

{#pt_regs_get_initial_registers_x86_64}

### pt_regs_get_initial_registers_x86_64

`static`

```cpp
static struct drgn_error * pt_regs_get_initial_registers_x86_64(const struct drgn_object * obj, struct drgn_register_state ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/arch_x86_64.c:363

---

{#prstatus_get_initial_registers_x86_64}

### prstatus_get_initial_registers_x86_64

`static`

```cpp
static struct drgn_error * prstatus_get_initial_registers_x86_64(struct drgn_program * prog, const void * prstatus, size_t size, struct drgn_register_state ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/arch_x86_64.c:373

---

{#get_initial_registers_inactive_task_frame}

### get_initial_registers_inactive_task_frame

`static`

```cpp
static struct drgn_error * get_initial_registers_inactive_task_frame(struct drgn_object * frame_obj, struct drgn_register_state ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/arch_x86_64.c:390

---

{#linux_kernel_get_initial_registers_x86_64}

### linux_kernel_get_initial_registers_x86_64

`static`

```cpp
static struct drgn_error * linux_kernel_get_initial_registers_x86_64(const struct drgn_object * task_obj, struct drgn_register_state ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/arch_x86_64.c:446

---

{#apply_elf_reloc_x86_64}

### apply_elf_reloc_x86_64

`static`

```cpp
static struct drgn_error * apply_elf_reloc_x86_64(const struct drgn_relocating_section * relocating, uint64_t r_offset, uint32_t r_type, const int64_t * r_addend, uint64_t sym_value)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/arch_x86_64.c:504

---

{#linux_kernel_live_direct_mapping_fallback_x86_64}

### linux_kernel_live_direct_mapping_fallback_x86_64

`static`

```cpp
static struct drgn_error * linux_kernel_live_direct_mapping_fallback_x86_64(struct drgn_program * prog, uint64_t * address_ret, uint64_t * size_ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/arch_x86_64.c:534

---

{#linux_kernel_direct_mapping_offset_x86_64}

### linux_kernel_direct_mapping_offset_x86_64

`static`

```cpp
static struct drgn_error * linux_kernel_direct_mapping_offset_x86_64(struct drgn_program * prog, uint64_t * address_ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/arch_x86_64.c:558

---

{#linux_kernel_pgtable_iterator_arch_create_x86_64}

### linux_kernel_pgtable_iterator_arch_create_x86_64

`static`

```cpp
static struct drgn_error * linux_kernel_pgtable_iterator_arch_create_x86_64(struct drgn_program * prog, void ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/arch_x86_64.c:577

---

{#linux_kernel_pgtable_iterator_init_x86_64}

### linux_kernel_pgtable_iterator_init_x86_64

`static`

```cpp
static void linux_kernel_pgtable_iterator_init_x86_64(struct drgn_program * prog, struct pgtable_iterator * it)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/arch_x86_64.c:588

---

{#linux_kernel_pgtable_iterator_next_x86_64}

### linux_kernel_pgtable_iterator_next_x86_64

`static`

```cpp
static struct drgn_error * linux_kernel_pgtable_iterator_next_x86_64(struct drgn_program * prog, struct pgtable_iterator * it, uint64_t * virt_addr_ret, uint64_t * phys_addr_ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/arch_x86_64.c:596

---

{#linux_kernel_section_size_bits_fallback_x86_64}

### linux_kernel_section_size_bits_fallback_x86_64

`static`

```cpp
static int linux_kernel_section_size_bits_fallback_x86_64(struct drgn_program * prog)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/arch_x86_64.c:684

---

{#linux_kernel_max_physmem_bits_fallback_x86_64}

### linux_kernel_max_physmem_bits_fallback_x86_64

`static`

```cpp
static int linux_kernel_max_physmem_bits_fallback_x86_64(struct drgn_program * prog)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/arch_x86_64.c:692

---

{#faulterror_init}

### FaultError_init

`static`

```cpp
static int FaultError_init(PyObject * self, PyObject * args, PyObject * kwds)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/error.c:8

---

{#faulterror_str}

### FaultError_str

`static`

```cpp
static PyObject * FaultError_str(PyObject * self)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/error.c:23

---

{#objectnotfounderror_init}

### ObjectNotFoundError_init

`static`

```cpp
static int ObjectNotFoundError_init(PyObject * self, PyObject * args, PyObject * kwds)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/error.c:57

---

{#drgn_error_from_python-1}

### drgn_error_from_python

```cpp
struct drgn_error * drgn_error_from_python(void)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/error.c:103

---

{#drgn_error_set_exception_message}

### drgn_error_set_exception_message

`static`

```cpp
static void drgn_error_set_exception_message(struct drgn_error * err)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/error.c:119

---

{#drgn_error_resolve_other}

### drgn_error_resolve_other

`static`

```cpp
static void drgn_error_resolve_other(struct drgn_error * err)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/error.c:137

---

{#drgn_error_resolve_os}

### drgn_error_resolve_os

`static`

```cpp
static void drgn_error_resolve_os(struct drgn_error * err)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/error.c:160

---

{#drgn_error_resolve_fault}

### drgn_error_resolve_fault

`static`

```cpp
static void drgn_error_resolve_fault(struct drgn_error * err)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/error.c:208

---

{#set_drgn_error-1}

### set_drgn_error

```cpp
void * set_drgn_error(struct drgn_error * err)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/error.c:265

---

{#set_error_type_name-1}

### set_error_type_name

```cpp
void * set_error_type_name(const char * format, struct drgn_qualified_type qualified_type)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/error.c:306

---

{#read_memory_via_pgtable}

### read_memory_via_pgtable

```cpp
struct drgn_error * read_memory_via_pgtable(void * buf, uint64_t address, size_t count, uint64_t offset, void * arg, bool physical)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/linux_kernel.c:45

---

{#proc_kallsyms_symbol_addr}

### proc_kallsyms_symbol_addr

```cpp
struct drgn_error * proc_kallsyms_symbol_addr(const char * name, unsigned long * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/linux_kernel.c:54

---

{#read_vmcoreinfo_fallback}

### read_vmcoreinfo_fallback

```cpp
struct drgn_error * read_vmcoreinfo_fallback(struct drgn_program * prog)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/linux_kernel.c:125

---

{#linux_kernel_get_primitive-1}

### LINUX_KERNEL_GET_PRIMITIVE

`-> vmcoreinfo.page_shift) LINUX_KERNEL_GET_PRIMITIVE(page_size`

```cpp
LINUX_KERNEL_GET_PRIMITIVE(page_shift, DRGN_C_TYPE_INT, signed, prog->vmcoreinfo. page_shift) -> vmcoreinfo.page_shift) LINUX_KERNEL_GET_PRIMITIVE(page_size
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/linux_kernel.c:211

---

{#linux_kernel_get_primitive-2}

### LINUX_KERNEL_GET_PRIMITIVE

`-> vmcoreinfo.page_size - 1)`

```cpp
prog vmcoreinfo page_size LINUX_KERNEL_GET_PRIMITIVE(page_mask, DRGN_C_TYPE_UNSIGNED_LONG, unsigned, ~ prog->vmcoreinfo.page_size - 1) -> vmcoreinfo.page_size - 1)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/linux_kernel.c:217

---

{#linux_kernel_get_uts_release}

### linux_kernel_get_uts_release

`static`

```cpp
static struct drgn_error * linux_kernel_get_uts_release(struct drgn_program * prog, struct drgn_object * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/linux_kernel.c:307

---

{#linux_kernel_get_jiffies}

### linux_kernel_get_jiffies

`static`

```cpp
static struct drgn_error * linux_kernel_get_jiffies(struct drgn_program * prog, struct drgn_object * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/linux_kernel.c:330

---

{#linux_kernel_get_vmcoreinfo}

### linux_kernel_get_vmcoreinfo

`static`

```cpp
static struct drgn_error * linux_kernel_get_vmcoreinfo(struct drgn_program * prog, struct drgn_object * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/linux_kernel.c:358

---

{#linux_kernel_get_vmemmap_address}

### linux_kernel_get_vmemmap_address

`static`

```cpp
static struct drgn_error * linux_kernel_get_vmemmap_address(struct drgn_program * prog, uint64_t * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/linux_kernel.c:381

---

{#linux_kernel_get_vmemmap}

### linux_kernel_get_vmemmap

`static`

```cpp
static struct drgn_error * linux_kernel_get_vmemmap(struct drgn_program * prog, struct drgn_object * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/linux_kernel.c:469

---

{#linux_kernel_get_nr_section_roots_impl}

### linux_kernel_get_nr_section_roots_impl

`static`

```cpp
static struct drgn_error * linux_kernel_get_nr_section_roots_impl(struct drgn_program * prog, uint64_t * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/linux_kernel.c:494

---

{#linux_kernel_get_sections_per_root_impl}

### linux_kernel_get_sections_per_root_impl

`static`

```cpp
static struct drgn_error * linux_kernel_get_sections_per_root_impl(struct drgn_program * prog, uint64_t * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/linux_kernel.c:504

---

{#linux_kernel_get_section_size_bits_impl}

### linux_kernel_get_section_size_bits_impl

`static`

```cpp
static struct drgn_error * linux_kernel_get_section_size_bits_impl(struct drgn_program * prog, int64_t * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/linux_kernel.c:567

---

{#linux_kernel_get_max_physmem_bits_impl}

### linux_kernel_get_max_physmem_bits_impl

`static`

```cpp
static struct drgn_error * linux_kernel_get_max_physmem_bits_impl(struct drgn_program * prog, int64_t * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/linux_kernel.c:588

---

{#linux_kernel_get_arch_pfn_offset_impl}

### linux_kernel_get_arch_pfn_offset_impl

`static`

```cpp
static struct drgn_error * linux_kernel_get_arch_pfn_offset_impl(struct drgn_program * prog, uint64_t * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/linux_kernel.c:654

---

{#is_fedora_kernel}

### is_fedora_kernel

`static`

```cpp
static bool is_fedora_kernel(const char * osrelease)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/linux_kernel.c:707

---

{#drgn_program_finish_set_kernel}

### drgn_program_finish_set_kernel

```cpp
struct drgn_error * drgn_program_finish_set_kernel(struct drgn_program * prog)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/linux_kernel.c:723

---

{#depmod_index_deinit}

### depmod_index_deinit

`static`

```cpp
static void depmod_index_deinit(struct depmod_index * depmod)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/linux_kernel.c:759

---

{#depmod_index_buffer_error}

### depmod_index_buffer_error

`static`

```cpp
static struct drgn_error * depmod_index_buffer_error(struct binary_buffer * bb, const char * pos, const char * message)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/linux_kernel.c:771

---

{#depmod_index_buffer_init}

### depmod_index_buffer_init

`static`

```cpp
static void depmod_index_buffer_init(struct depmod_index_buffer * buffer, struct depmod_index * depmod)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/linux_kernel.c:783

---

{#depmod_index_validate}

### depmod_index_validate

`static`

```cpp
static struct drgn_error * depmod_index_validate(struct depmod_index * depmod)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/linux_kernel.c:791

---

{#depmod_index_init}

### depmod_index_init

`static`

```cpp
static struct drgn_error * depmod_index_init(struct depmod_index * depmod, char * _path, int fd)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/linux_kernel.c:814

---

{#depmod_index_find}

### depmod_index_find

`static`

```cpp
static struct drgn_error * depmod_index_find(struct depmod_index * depmod, const char * name, const char ** path_ret, size_t * len_ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/linux_kernel.c:852

---

{#define_vector_functions-12}

### DEFINE_VECTOR_FUNCTIONS

```cpp
DEFINE_VECTOR_FUNCTIONS(char_p_vector)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/linux_kernel.c:944

---

{#define_hash_map_functions-7}

### DEFINE_HASH_MAP_FUNCTIONS

```cpp
DEFINE_HASH_MAP_FUNCTIONS(drgn_kmod_walk_module_map, c_string_key_hash_pair, c_string_key_eq)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/linux_kernel.c:946

---

{#define_vector_functions-13}

### DEFINE_VECTOR_FUNCTIONS

```cpp
DEFINE_VECTOR_FUNCTIONS(drgn_kmod_walk_stack)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/linux_kernel.c:954

---

{#drgn_kmod_walk_inode_hash_pair}

### drgn_kmod_walk_inode_hash_pair

`static` `inline`

```cpp
static inline struct hash_pair drgn_kmod_walk_inode_hash_pair(const struct drgn_kmod_walk_inode * entry)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/linux_kernel.c:957

---

{#drgn_kmod_walk_inode_eq}

### drgn_kmod_walk_inode_eq

`static` `inline`

```cpp
static inline bool drgn_kmod_walk_inode_eq(const struct drgn_kmod_walk_inode * a, const struct drgn_kmod_walk_inode * b)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/linux_kernel.c:963

---

{#define_hash_set_functions-3}

### DEFINE_HASH_SET_FUNCTIONS

```cpp
DEFINE_HASH_SET_FUNCTIONS(drgn_kmod_walk_inode_set, drgn_kmod_walk_inode_hash_pair, drgn_kmod_walk_inode_eq)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/linux_kernel.c:969

---

{#drgn_kmod_walk_module_map_entry_deinit}

### drgn_kmod_walk_module_map_entry_deinit

`static`

```cpp
static void drgn_kmod_walk_module_map_entry_deinit(struct drgn_kmod_walk_module_map_entry * entry)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/linux_kernel.c:974

---

{#drgn_kmod_walk_state_deinit}

### drgn_kmod_walk_state_deinit

`static`

```cpp
static void drgn_kmod_walk_state_deinit(struct drgn_kmod_walk_state * state)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/linux_kernel.c:982

---

{#drgn_module_try_vmlinux_in_debug_directories}

### drgn_module_try_vmlinux_in_debug_directories

`static`

```cpp
static struct drgn_error * drgn_module_try_vmlinux_in_debug_directories(struct drgn_module * module, const struct drgn_debug_info_options * options, struct string_builder * sb)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/linux_kernel.c:1002

---

{#drgn_module_try_vmlinux_files}

### drgn_module_try_vmlinux_files

```cpp
struct drgn_error * drgn_module_try_vmlinux_files(struct drgn_module * module, const struct drgn_debug_info_options * options)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/linux_kernel.c:1040

---

{#drgn_open_modules_dep}

### drgn_open_modules_dep

`static`

```cpp
static struct drgn_error * drgn_open_modules_dep(struct drgn_program * prog, const struct drgn_debug_info_options * options, struct depmod_index * modules_dep)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/linux_kernel.c:1106

---

{#drgn_module_try_depmod_in_debug_directories}

### drgn_module_try_depmod_in_debug_directories

`static`

```cpp
static struct drgn_error * drgn_module_try_depmod_in_debug_directories(struct drgn_module * module, const struct drgn_debug_info_options * options, struct string_builder * sb, const char * depmod_path, size_t ko_len)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/linux_kernel.c:1161

---

{#drgn_module_try_linux_kmod_depmod}

### drgn_module_try_linux_kmod_depmod

`static`

```cpp
static struct drgn_error * drgn_module_try_linux_kmod_depmod(struct drgn_module * module, const struct drgn_debug_info_options * options, struct drgn_standard_debug_info_find_state * state)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/linux_kernel.c:1199

---

{#drgn_kmod_walk_next_dir}

### drgn_kmod_walk_next_dir

`static`

```cpp
static struct drgn_error * drgn_kmod_walk_next_dir(struct drgn_program * prog, const struct drgn_debug_info_options * options, struct drgn_kmod_walk_state * state)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/linux_kernel.c:1285

---

{#drgn_kmod_walk}

### drgn_kmod_walk

`static`

```cpp
static struct drgn_error * drgn_kmod_walk(struct drgn_program * prog, const struct drgn_debug_info_options * options, struct drgn_kmod_walk_state * state, struct drgn_kmod_walk_module_map_entry * current)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/linux_kernel.c:1340

---

{#drgn_module_try_linux_kmod_files}

### drgn_module_try_linux_kmod_files

```cpp
struct drgn_error * drgn_module_try_linux_kmod_files(struct drgn_module * module, const struct drgn_debug_info_options * options, struct drgn_standard_debug_info_find_state * state)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/linux_kernel.c:1501

---

{#get_gnu_build_id_from_note_file}

### get_gnu_build_id_from_note_file

`static`

```cpp
static const char * get_gnu_build_id_from_note_file(int fd, void ** bufp, size_t * buf_capacityp, const void ** build_id_ret, size_t * build_id_len_ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/linux_kernel.c:1586

---

{#get_build_id_from_sys_kernel_notes}

### get_build_id_from_sys_kernel_notes

`static`

```cpp
static struct drgn_error * get_build_id_from_sys_kernel_notes(void ** buf_ret, const void ** build_id_ret, size_t * build_id_len_ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/linux_kernel.c:1609

---

{#linux_kernel_loaded_module_iterator_destroy}

### linux_kernel_loaded_module_iterator_destroy

`static`

```cpp
static void linux_kernel_loaded_module_iterator_destroy(struct drgn_module_iterator * _it)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/linux_kernel.c:1649

---

{#yield_vmlinux}

### yield_vmlinux

`static`

```cpp
static struct drgn_error * yield_vmlinux(struct linux_kernel_loaded_module_iterator * it, struct drgn_module ** ret, bool * new_ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/linux_kernel.c:1658

---

{#kernel_module_address}

### kernel_module_address

`static`

```cpp
static struct drgn_error * kernel_module_address(const struct drgn_object * module_obj, struct drgn_object * mem, enum kernel_module_address_ranges_version * version_ret, uint64_t * address_ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/linux_kernel.c:1742

---

{#kernel_module_set_address_ranges}

### kernel_module_set_address_ranges

`static`

```cpp
static struct drgn_error * kernel_module_set_address_ranges(struct drgn_module * module, enum kernel_module_address_ranges_version version, const struct drgn_object * module_obj, const struct drgn_object * mem, uint64_t address)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/linux_kernel.c:1790

---

{#kernel_module_set_build_id_live}

### kernel_module_set_build_id_live

`static`

```cpp
static struct drgn_error * kernel_module_set_build_id_live(struct drgn_module * module)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/linux_kernel.c:1865

---

{#kernel_module_set_build_id}

### kernel_module_set_build_id

`static`

```cpp
static struct drgn_error * kernel_module_set_build_id(struct drgn_module * module, const struct drgn_object * module_obj, bool use_sys_module)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/linux_kernel.c:1931

---

{#kernel_module_set_section_addresses_live}

### kernel_module_set_section_addresses_live

`static`

```cpp
static struct drgn_error * kernel_module_set_section_addresses_live(struct drgn_module * module)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/linux_kernel.c:2060

---

{#kernel_module_set_section_addresses}

### kernel_module_set_section_addresses

`static`

```cpp
static struct drgn_error * kernel_module_set_section_addresses(struct drgn_module * module, const struct drgn_object * module_obj, bool use_sys_module)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/linux_kernel.c:2115

---

{#kernel_module_find_or_create_internal}

### kernel_module_find_or_create_internal

`static`

```cpp
static struct drgn_error * kernel_module_find_or_create_internal(const struct drgn_object * module_ptr, const struct drgn_object * module_obj, struct drgn_module ** ret, bool * new_ret, bool create, bool log)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/linux_kernel.c:2293

---

{#drgn_module_find_or_create_linux_kernel_loadable_internal}

### drgn_module_find_or_create_linux_kernel_loadable_internal

`static`

```cpp
static struct drgn_error * drgn_module_find_or_create_linux_kernel_loadable_internal(const struct drgn_object * module_ptr, struct drgn_module ** ret, bool * new_ret, bool create)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/linux_kernel.c:2381

---

{#yield_kernel_module}

### yield_kernel_module

`static`

```cpp
static struct drgn_error * yield_kernel_module(struct linux_kernel_loaded_module_iterator * it, struct drgn_module ** ret, bool * new_ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/linux_kernel.c:2425

---

{#linux_kernel_loaded_module_iterator_next}

### linux_kernel_loaded_module_iterator_next

`static`

```cpp
static struct drgn_error * linux_kernel_loaded_module_iterator_next(struct drgn_module_iterator * _it, struct drgn_module ** ret, bool * new_ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/linux_kernel.c:2499

---

{#linux_kernel_loaded_module_iterator_create}

### linux_kernel_loaded_module_iterator_create

```cpp
struct drgn_error * linux_kernel_loaded_module_iterator_create(struct drgn_program * prog, struct drgn_module_iterator ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/linux_kernel.c:2585

---

{#linux_cpu_present_mask}

### linux_cpu_present_mask

`static`

```cpp
static struct drgn_error * linux_cpu_present_mask(struct drgn_program * prog, uint64_t ** bitmap_ret, size_t * size_ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/linux_kernel.c:2601

---

{#define_vector-20}

### DEFINE_VECTOR

```cpp
DEFINE_VECTOR(uint64_vector, uint64_t)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/linux_kernel.c:2695

---

{#drgn_program_is_irq_regs}

### drgn_program_is_irq_regs

```cpp
struct drgn_error * drgn_program_is_irq_regs(struct drgn_program * prog, uint64_t addr, bool * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/linux_kernel.c:2698

---

{#drgn_program_finish_set_kernel-1}

### drgn_program_finish_set_kernel

```cpp
struct drgn_error * drgn_program_finish_set_kernel(struct drgn_program * prog)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/linux_kernel.h:12

---

{#read_memory_via_pgtable-1}

### read_memory_via_pgtable

```cpp
struct drgn_error * read_memory_via_pgtable(void * buf, uint64_t address, size_t count, uint64_t offset, void * arg, bool physical)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/linux_kernel.h:14

---

{#drgn_program_parse_vmcoreinfo}

### drgn_program_parse_vmcoreinfo

```cpp
struct drgn_error * drgn_program_parse_vmcoreinfo(struct drgn_program * prog, const char * desc, size_t descsz)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/linux_kernel.h:18

---

{#proc_kallsyms_symbol_addr-1}

### proc_kallsyms_symbol_addr

```cpp
struct drgn_error * proc_kallsyms_symbol_addr(const char * name, unsigned long * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/linux_kernel.h:22

---

{#read_vmcoreinfo_fallback-1}

### read_vmcoreinfo_fallback

```cpp
struct drgn_error * read_vmcoreinfo_fallback(struct drgn_program * prog)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/linux_kernel.h:25

---

{#linux_kernel_loaded_module_iterator_create-1}

### linux_kernel_loaded_module_iterator_create

```cpp
struct drgn_error * linux_kernel_loaded_module_iterator_create(struct drgn_program * prog, struct drgn_module_iterator ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/linux_kernel.h:28

---

{#drgn_module_try_vmlinux_files-1}

### drgn_module_try_vmlinux_files

```cpp
struct drgn_error * drgn_module_try_vmlinux_files(struct drgn_module * module, const struct drgn_debug_info_options * options)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/linux_kernel.h:32

---

{#drgn_module_try_linux_kmod_files-1}

### drgn_module_try_linux_kmod_files

```cpp
struct drgn_error * drgn_module_try_linux_kmod_files(struct drgn_module * module, const struct drgn_debug_info_options * options, struct drgn_standard_debug_info_find_state * state)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/linux_kernel.h:36

---

{#drgn_program_is_irq_regs-1}

### drgn_program_is_irq_regs

```cpp
struct drgn_error * drgn_program_is_irq_regs(struct drgn_program * prog, uint64_t addr, bool * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/linux_kernel.h:41

---

{#drgn_program_set_kdump-1}

### drgn_program_set_kdump

`static` `inline`

```cpp
static inline struct drgn_error * drgn_program_set_kdump(struct drgn_program * prog)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/linux_kernel.h:57

---

{#symbolindex_dealloc}

### SymbolIndex_dealloc

`static`

```cpp
static void SymbolIndex_dealloc(SymbolIndex * self)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/symbol_index.c:7

---

{#symbolindex_call}

### SymbolIndex_call

`static`

```cpp
static PyObject * SymbolIndex_call(SymbolIndex * self, PyObject * args, PyObject * kwargs)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/symbol_index.c:13

---

{#symbolindex_new}

### SymbolIndex_new

`static`

```cpp
static PyObject * SymbolIndex_new(PyTypeObject * subtype, PyObject * args, PyObject * kwds)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/symbol_index.c:68

---

{#binary_buffer_error_vat}

### binary_buffer_error_vat

`static`

```cpp
static struct drgn_error * binary_buffer_error_vat(struct binary_buffer * bb, const char * pos, const char * format, va_list ap)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/binary_buffer.c:11

---

{#binary_buffer_error-1}

### binary_buffer_error

```cpp
struct drgn_error * binary_buffer_error(struct binary_buffer * bb, const char * format, ...)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/binary_buffer.c:25

---

{#binary_buffer_error_at-1}

### binary_buffer_error_at

```cpp
struct drgn_error * binary_buffer_error_at(struct binary_buffer * bb, const char * pos, const char * format, ...)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/binary_buffer.c:36

---

{#drgn_type_kind_has_die_addr}

### drgn_type_kind_has_die_addr

`static` `inline`

```cpp
static inline bool drgn_type_kind_has_die_addr(enum drgn_type_kind kind)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn_internal.h:231

---

{#drgn_type_has_die_addr}

### drgn_type_has_die_addr

`static` `inline`

```cpp
static inline bool drgn_type_has_die_addr(struct drgn_type * type)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn_internal.h:240

---

{#drgn_type_die_addr}

### drgn_type_die_addr

`static` `inline`

```cpp
static inline uintptr_t drgn_type_die_addr(struct drgn_type * type)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn_internal.h:245

---

{#drgn_type_init_die_addr}

### drgn_type_init_die_addr

`static` `inline`

```cpp
static inline void drgn_type_init_die_addr(struct drgn_type * type, uintptr_t die_addr)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn_internal.h:251

---

{#drgn_memory_segment_to_key}

### drgn_memory_segment_to_key

`static` `inline`

```cpp
static inline uint64_t drgn_memory_segment_to_key(const struct drgn_memory_segment * entry)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/memory_reader.c:126

---

{#define_binary_search_tree_functions-2}

### DEFINE_BINARY_SEARCH_TREE_FUNCTIONS

```cpp
DEFINE_BINARY_SEARCH_TREE_FUNCTIONS(drgn_memory_segment_tree, node, drgn_memory_segment_to_key, binary_search_tree_scalar_cmp, splay)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/memory_reader.c:131

---

{#free_memory_segment_tree}

### free_memory_segment_tree

`static`

```cpp
static void free_memory_segment_tree(struct drgn_memory_segment_tree * tree)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/memory_reader.c:141

---

{#align_down_mask}

### align_down_mask

`static` `inline`

```cpp
static inline uint64_t align_down_mask(uint64_t value, uint64_t mask)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/memory_reader.c:489

---

{#align_up_mask}

### align_up_mask

`static` `inline`

```cpp
static inline uint64_t align_up_mask(uint64_t value, uint64_t mask)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/memory_reader.c:494

---

{#drgn_memory_search_iterator_create_common}

### drgn_memory_search_iterator_create_common

`static`

```cpp
static struct drgn_memory_search_iterator * drgn_memory_search_iterator_create_common(struct drgn_program * prog, size_t refill_size, uint64_t alignment_mask)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/memory_reader.c:500

---

{#drgn_memory_search_iterator_remaining_bytes}

### drgn_memory_search_iterator_remaining_bytes

`static` `inline`

```cpp
static inline size_t drgn_memory_search_iterator_remaining_bytes(struct drgn_memory_search_iterator * it)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/memory_reader.c:578

---

{#drgn_memory_search_iterator_calc_buf_target}

### drgn_memory_search_iterator_calc_buf_target

`static` `inline`

```cpp
static inline bool drgn_memory_search_iterator_calc_buf_target(struct drgn_memory_search_iterator * it, size_t needed, size_t * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/memory_reader.c:584

---

{#drgn_memory_search_iterator_refill}

### drgn_memory_search_iterator_refill

`static`

```cpp
static struct drgn_error * drgn_memory_search_iterator_refill(struct drgn_memory_search_iterator * it, drgn_blocking_state * blocking_state, size_t needed, uint64_t alignment_mask, bool * gap_ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/memory_reader.c:602

---

{#drgn_memory_search_iterator_next_memmem}

### drgn_memory_search_iterator_next_memmem

`static`

```cpp
static struct drgn_error * drgn_memory_search_iterator_next_memmem(struct drgn_memory_search_iterator * it, drgn_blocking_state * blocking_state, uint64_t * addr_ret, const void ** match_ret, size_t * match_len_ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/memory_reader.c:1048

---

{#drgn_memory_search_iterator_replace_linux_kernel_address_range}

### drgn_memory_search_iterator_replace_linux_kernel_address_range

`static`

```cpp
static struct drgn_error * drgn_memory_search_iterator_replace_linux_kernel_address_range(struct drgn_memory_search_iterator * it)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/memory_reader.c:1425

---

{#memorysearchiterator_wrap-1}

### MemorySearchIterator_wrap

```cpp
PyObject * MemorySearchIterator_wrap(PyTypeObject * type, struct drgn_memory_search_iterator * it)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/memory_search.c:12

---

{#memorysearchiterator_dealloc}

### MemorySearchIterator_dealloc

`static`

```cpp
static void MemorySearchIterator_dealloc(MemorySearchIterator * self)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/memory_search.c:25

---

{#memorysearchiterator_traverse}

### MemorySearchIterator_traverse

`static`

```cpp
static int MemorySearchIterator_traverse(MemorySearchIterator * self, visitproc visit, void * arg)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/memory_search.c:37

---

{#memorysearchiterator_next}

### MemorySearchIterator_next

`static`

```cpp
static PyObject * MemorySearchIterator_next(MemorySearchIterator * self)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/memory_search.c:48

---

{#memorysearchiteratorwithbytes_next}

### MemorySearchIteratorWithBytes_next

`static`

```cpp
static PyObject * MemorySearchIteratorWithBytes_next(MemorySearchIterator * self)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/memory_search.c:60

---

{#memorysearchiteratorwithstr_next}

### MemorySearchIteratorWithStr_next

`static`

```cpp
static PyObject * MemorySearchIteratorWithStr_next(MemorySearchIterator * self)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/memory_search.c:87

---

{#memorysearchiteratorwithint_next}

### MemorySearchIteratorWithInt_next

`static`

```cpp
static PyObject * MemorySearchIteratorWithInt_next(MemorySearchIterator * self)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/memory_search.c:114

---

{#memorysearchiterator_set_address_range}

### MemorySearchIterator_set_address_range

`static`

```cpp
static MemorySearchIterator * MemorySearchIterator_set_address_range(MemorySearchIterator * self, PyObject * args, PyObject * kwds)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/memory_search.c:159

---

{#drgnobject_literal}

### DrgnObject_literal

`static`

```cpp
static int DrgnObject_literal(struct drgn_object * res, PyObject * literal)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/object.c:14

---

{#py_long_to_bytes_for_object_type}

### py_long_to_bytes_for_object_type

`static`

```cpp
static void * py_long_to_bytes_for_object_type(PyObject * value_obj, const struct drgn_object_type * type)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/object.c:50

---

{#serialize_py_object}

### serialize_py_object

`static`

```cpp
static int serialize_py_object(struct drgn_program * prog, char * buf, uint64_t buf_bit_size, uint64_t bit_offset, PyObject * value_obj, const struct drgn_object_type * type)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/object.c:212

---

{#serialize_compound_value}

### serialize_compound_value

`static`

```cpp
static int serialize_compound_value(struct drgn_program * prog, char * buf, uint64_t buf_bit_size, uint64_t bit_offset, PyObject * value_obj, const struct drgn_object_type * type)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/object.c:91

---

{#serialize_array_value}

### serialize_array_value

`static`

```cpp
static int serialize_array_value(struct drgn_program * prog, char * buf, uint64_t buf_bit_size, uint64_t bit_offset, PyObject * value_obj, const struct drgn_object_type * type)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/object.c:167

---

{#buffer_object_from_value}

### buffer_object_from_value

`static`

```cpp
static int buffer_object_from_value(struct drgn_object * res, const struct drgn_object_type * type, PyObject * value_obj)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/object.c:339

---

{#drgnobject_new}

### DrgnObject_new

`static`

```cpp
static DrgnObject * DrgnObject_new(PyTypeObject * subtype, PyObject * args, PyObject * kwds)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/object.c:374

---

{#drgnobject_dealloc}

### DrgnObject_dealloc

`static`

```cpp
static void DrgnObject_dealloc(DrgnObject * self)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/object.c:570

---

{#drgnobject_value_impl}

### DrgnObject_value_impl

`static`

```cpp
static PyObject * DrgnObject_value_impl(struct drgn_object * obj)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/object.c:670

---

{#drgnobject_compound_value}

### DrgnObject_compound_value

`static`

```cpp
static PyObject * DrgnObject_compound_value(struct drgn_object * obj, struct drgn_type * underlying_type)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/object.c:580

---

{#drgnobject_array_value}

### DrgnObject_array_value

`static`

```cpp
static PyObject * DrgnObject_array_value(struct drgn_object * obj, struct drgn_type * underlying_type)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/object.c:633

---

{#drgnobject_value}

### DrgnObject_value

`static`

```cpp
static PyObject * DrgnObject_value(DrgnObject * self)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/object.c:744

---

{#drgnobject_string}

### DrgnObject_string

`static`

```cpp
static PyObject * DrgnObject_string(DrgnObject * self)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/object.c:749

---

{#drgnobject_address_of}

### DrgnObject_address_of

`static`

```cpp
static DrgnObject * DrgnObject_address_of(DrgnObject * self)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/object.c:759

---

{#drgnobject_read}

### DrgnObject_read

`static`

```cpp
static DrgnObject * DrgnObject_read(DrgnObject * self)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/object.c:772

---

{#drgnobject_to_bytes}

### DrgnObject_to_bytes

`static`

```cpp
static PyObject * DrgnObject_to_bytes(DrgnObject * self)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/object.c:796

---

{#drgnobject_from_bytes}

### DrgnObject_from_bytes

`static`

```cpp
static DrgnObject * DrgnObject_from_bytes(PyTypeObject * type, PyObject * args, PyObject * kwds)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/object.c:809

---

{#append_bit_offset}

### append_bit_offset

`static`

```cpp
static int append_bit_offset(PyObject * parts, uint8_t bit_offset)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/object.c:858

---

{#drgnobject_repr}

### DrgnObject_repr

`static`

```cpp
static PyObject * DrgnObject_repr(DrgnObject * self)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/object.c:865

---

{#drgnobject_str}

### DrgnObject_str

`static`

```cpp
static PyObject * DrgnObject_str(DrgnObject * self)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/object.c:934

---

{#format_object_flag_converter}

### format_object_flag_converter

`static`

```cpp
static int format_object_flag_converter(PyObject * o, void * p)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/object.c:948

---

{#drgnobject_format}

### DrgnObject_format

`static`

```cpp
static PyObject * DrgnObject_format(DrgnObject * self, PyObject * args, PyObject * kwds)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/object.c:965

---

{#drgnobject_get_prog}

### DrgnObject_get_prog

`static`

```cpp
static Program * DrgnObject_get_prog(DrgnObject * self, void * arg)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/object.c:1049

---

{#drgnobject_get_type}

### DrgnObject_get_type

`static`

```cpp
static PyObject * DrgnObject_get_type(DrgnObject * self, void * arg)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/object.c:1055

---

{#drgnobject_get_absent}

### DrgnObject_get_absent

`static`

```cpp
static PyObject * DrgnObject_get_absent(DrgnObject * self, void * arg)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/object.c:1060

---

{#drgnobject_get_absence_reason}

### DrgnObject_get_absence_reason

`static`

```cpp
static PyObject * DrgnObject_get_absence_reason(DrgnObject * self, void * arg)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/object.c:1065

---

{#drgnobject_get_address}

### DrgnObject_get_address

`static`

```cpp
static PyObject * DrgnObject_get_address(DrgnObject * self, void * arg)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/object.c:1073

---

{#drgnobject_get_bit_offset}

### DrgnObject_get_bit_offset

`static`

```cpp
static PyObject * DrgnObject_get_bit_offset(DrgnObject * self, void * arg)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/object.c:1081

---

{#drgnobject_get_bit_field_size}

### DrgnObject_get_bit_field_size

`static`

```cpp
static PyObject * DrgnObject_get_bit_field_size(DrgnObject * self, void * arg)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/object.c:1094

---

{#drgnobject_binary_operand}

### DrgnObject_binary_operand

`static`

```cpp
static int DrgnObject_binary_operand(PyObject * self, PyObject * other, struct drgn_object ** obj, struct drgn_object * tmp)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/object.c:1102

---

{#drgnobject_binary_op-1}

### DrgnObject_BINARY_OP

```cpp
DrgnObject_BINARY_OP(add)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/object.c:1162

---

{#drgnobject_int}

### DrgnObject_int

`static`

```cpp
static PyObject * DrgnObject_int(DrgnObject * self)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/object.c:1205

---

{#drgnobject_float}

### DrgnObject_float

`static`

```cpp
static PyObject * DrgnObject_float(DrgnObject * self)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/object.c:1232

---

{#drgnobject_index}

### DrgnObject_index

`static`

```cpp
static PyObject * DrgnObject_index(DrgnObject * self)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/object.c:1269

---

{#drgnobject_round}

### DrgnObject_round

`static`

```cpp
static PyObject * DrgnObject_round(DrgnObject * self, PyObject * args, PyObject * kwds)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/object.c:1289

---

{#drgnobject_round_method-1}

### DrgnObject_round_method

```cpp
DrgnObject_round_method(trunc)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/object.c:1342

---

{#drgnobject_member}

### DrgnObject_member

`static`

```cpp
static DrgnObject * DrgnObject_member(DrgnObject * self, PyObject * args, PyObject * kwds)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/object.c:1379

---

{#drgnobject_subobject}

### DrgnObject_subobject

`static`

```cpp
static DrgnObject * DrgnObject_subobject(DrgnObject * self, PyObject * args, PyObject * kwds)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/object.c:1405

---

{#drgnobject_getattro}

### DrgnObject_getattro

`static`

```cpp
static PyObject * DrgnObject_getattro(DrgnObject * self, PyObject * attr_name)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/object.c:1425

---

{#drgnobject_length}

### DrgnObject_length

`static`

```cpp
static Py_ssize_t DrgnObject_length(DrgnObject * self)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/object.c:1465

---

{#drgnobject_subscript_impl}

### DrgnObject_subscript_impl

`static`

```cpp
static DrgnObject * DrgnObject_subscript_impl(DrgnObject * self, int64_t index)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/object.c:1485

---

{#drgnobject_subscript}

### DrgnObject_subscript

`static`

```cpp
static DrgnObject * DrgnObject_subscript(DrgnObject * self, PyObject * item)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/object.c:1499

---

{#drgnobject_iter_impl}

### DrgnObject_iter_impl

`static`

```cpp
static ObjectIterator * DrgnObject_iter_impl(DrgnObject * self, bool reversed)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/object.c:1561

---

{#drgnobject_iter}

### DrgnObject_iter

`static`

```cpp
static ObjectIterator * DrgnObject_iter(DrgnObject * self)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/object.c:1589

---

{#drgnobject_reversed}

### DrgnObject_reversed

`static`

```cpp
static ObjectIterator * DrgnObject_reversed(DrgnObject * self)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/object.c:1594

---

{#add_to_dir}

### add_to_dir

`static`

```cpp
static int add_to_dir(PyObject * dir, struct drgn_type * type)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/object.c:1599

---

{#drgnobject_dir}

### DrgnObject_dir

`static`

```cpp
static PyObject * DrgnObject_dir(DrgnObject * self)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/object.c:1634

---

{#drgnobject_traverse}

### DrgnObject_traverse

`static`

```cpp
static int DrgnObject_traverse(DrgnObject * self, visitproc visit, void * arg)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/object.c:1732

---

{#drgnobject_null-1}

### DrgnObject_NULL

```cpp
PyObject * DrgnObject_NULL(PyObject * self, PyObject * args, PyObject * kwds)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/object.c:1758

---

{#drgnobject_cast_op-1}

### DrgnObject_CAST_OP

```cpp
DrgnObject_CAST_OP(cast)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/object.c:1796

---

{#drgnobject_cast_op-2}

### DrgnObject_CAST_OP

```cpp
DrgnObject_CAST_OP(reinterpret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/object.c:1834

---

{#objectiterator_dealloc}

### ObjectIterator_dealloc

`static`

```cpp
static void ObjectIterator_dealloc(ObjectIterator * self)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/object.c:1867

---

{#objectiterator_traverse}

### ObjectIterator_traverse

`static`

```cpp
static int ObjectIterator_traverse(ObjectIterator * self, visitproc visit, void * arg)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/object.c:1874

---

{#objectiterator_next}

### ObjectIterator_next

`static`

```cpp
static DrgnObject * ObjectIterator_next(ObjectIterator * self)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/object.c:1881

---

{#objectiterator_length_hint}

### ObjectIterator_length_hint

`static`

```cpp
static PyObject * ObjectIterator_length_hint(ObjectIterator * self)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/object.c:1891

---

{#symbol_wrap-1}

### Symbol_wrap

```cpp
PyObject * Symbol_wrap(struct drgn_symbol * sym, PyObject * name_obj)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/symbol.c:8

---

{#symbol_list_wrap-1}

### Symbol_list_wrap

```cpp
PyObject * Symbol_list_wrap(struct drgn_symbol ** symbols, size_t count, PyObject * name_obj)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/symbol.c:19

---

{#symbol_new}

### Symbol_new

`static`

```cpp
static PyObject * Symbol_new(PyTypeObject * subtype, PyObject * args, PyObject * kwds)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/symbol.c:42

---

{#symbol_dealloc}

### Symbol_dealloc

`static`

```cpp
static void Symbol_dealloc(Symbol * self)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/symbol.c:79

---

{#symbol_richcompare}

### Symbol_richcompare

`static`

```cpp
static PyObject * Symbol_richcompare(Symbol * self, PyObject * other, int op)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/symbol.c:86

---

{#symbol_get_name}

### Symbol_get_name

`static`

```cpp
static PyObject * Symbol_get_name(Symbol * self, void * arg)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/symbol.c:97

---

{#symbol_get_address}

### Symbol_get_address

`static`

```cpp
static PyObject * Symbol_get_address(Symbol * self, void * arg)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/symbol.c:102

---

{#symbol_get_size}

### Symbol_get_size

`static`

```cpp
static PyObject * Symbol_get_size(Symbol * self, void * arg)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/symbol.c:107

---

{#symbol_get_binding}

### Symbol_get_binding

`static`

```cpp
static PyObject * Symbol_get_binding(Symbol * self, void * arg)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/symbol.c:112

---

{#symbol_get_kind}

### Symbol_get_kind

`static`

```cpp
static PyObject * Symbol_get_kind(Symbol * self, void * arg)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/symbol.c:118

---

{#symbol_repr}

### Symbol_repr

`static`

```cpp
static PyObject * Symbol_repr(Symbol * self)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/symbol.c:124

---

{#define_hash_set_functions-4}

### DEFINE_HASH_SET_FUNCTIONS

```cpp
DEFINE_HASH_SET_FUNCTIONS(pyobjectp_set, ptr_key_hash_pair, scalar_key_eq)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/program.c:20

---

{#drgnpy_log_fn}

### drgnpy_log_fn

`static`

```cpp
static void drgnpy_log_fn(struct drgn_program * prog, void * arg, enum drgn_log_level level, const char * format, va_list ap, struct drgn_error * err)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/program.c:27

---

{#get_logging_status}

### get_logging_status

`static`

```cpp
static int get_logging_status(int * log_level_ret, bool * enable_progress_bar_ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/program.c:48

---

{#cache_logging_status}

### cache_logging_status

`static`

```cpp
static int cache_logging_status(void)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/program.c:161

---

{#loggercachewrapper_clear}

### LoggerCacheWrapper_clear

`static`

```cpp
static PyObject * LoggerCacheWrapper_clear(PyObject * self)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/program.c:167

---

{#init_logger_cache_wrapper}

### init_logger_cache_wrapper

`static`

```cpp
static int init_logger_cache_wrapper(void)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/program.c:196

---

{#program_init_logging}

### Program_init_logging

`static`

```cpp
static int Program_init_logging(Program * prog)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/program.c:209

---

{#program_deinit_logging}

### Program_deinit_logging

`static`

```cpp
static void Program_deinit_logging(Program * prog)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/program.c:228

---

{#init_logging-1}

### init_logging

```cpp
int init_logging(void)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/program.c:234

---

{#program_hold_object-1}

### Program_hold_object

```cpp
int Program_hold_object(Program * prog, PyObject * obj)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/program.c:257

---

{#program_hold_reserve-1}

### Program_hold_reserve

```cpp
bool Program_hold_reserve(Program * prog, size_t n)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/program.c:269

---

{#program_type_arg-1}

### Program_type_arg

```cpp
int Program_type_arg(Program * prog, PyObject * type_obj, bool can_be_none, struct drgn_qualified_type * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/program.c:279

---

{#program_new_impl}

### Program_new_impl

`static`

```cpp
static Program * Program_new_impl(const struct drgn_platform * platform)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/program.c:334

---

{#program_new}

### Program_new

`static`

```cpp
static Program * Program_new(PyTypeObject * subtype, PyObject * args, PyObject * kwds)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/program.c:355

---

{#program_dealloc}

### Program_dealloc

`static`

```cpp
static void Program_dealloc(Program * self)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/program.c:412

---

{#program_traverse}

### Program_traverse

`static`

```cpp
static int Program_traverse(Program * self, visitproc visit, void * arg)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/program.c:425

---

{#program_clear}

### Program_clear

`static`

```cpp
static int Program_clear(Program * self)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/program.c:434

---

{#py_memory_read_fn}

### py_memory_read_fn

`static`

```cpp
static struct drgn_error * py_memory_read_fn(void * buf, uint64_t address, size_t count, uint64_t offset, void * arg, bool physical)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/program.c:445

---

{#program_add_memory_segment}

### Program_add_memory_segment

`static`

```cpp
static PyObject * Program_add_memory_segment(Program * self, PyObject * args, PyObject * kwds)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/program.c:477

---

{#py_debug_info_find_fn}

### py_debug_info_find_fn

`static`

```cpp
static struct drgn_error * py_debug_info_find_fn(struct drgn_module *const * modules, size_t num_modules, void * arg)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/program.c:512

---

{#py_type_find_fn_common}

### py_type_find_fn_common

`static` `inline`

```cpp
static inline struct drgn_error * py_type_find_fn_common(PyObject * type_obj, void * arg, struct drgn_qualified_type * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/program.c:534

---

{#py_type_find_fn}

### py_type_find_fn

`static`

```cpp
static struct drgn_error * py_type_find_fn(uint64_t kinds, const char * name, size_t name_len, const char * filename, void * arg, struct drgn_qualified_type * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/program.c:556

---

{#py_type_find_fn_old}

### py_type_find_fn_old

`static`

```cpp
static struct drgn_error * py_type_find_fn_old(uint64_t kinds, const char * name, size_t name_len, const char * filename, void * arg, struct drgn_qualified_type * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/program.c:583

---

{#py_object_find_fn}

### py_object_find_fn

`static`

```cpp
static struct drgn_error * py_object_find_fn(const char * name, size_t name_len, const char * filename, enum drgn_find_object_flags flags, void * arg, struct drgn_object * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/program.c:614

---

{#py_symbol_find_fn}

### py_symbol_find_fn

`static`

```cpp
static struct drgn_error * py_symbol_find_fn(const char * name, uint64_t addr, enum drgn_find_symbol_flags flags, void * arg, struct drgn_symbol_result_builder * builder)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/program.c:647

---

{#deprecated_finder_name_obj}

### deprecated_finder_name_obj

`static`

```cpp
static PyObject * deprecated_finder_name_obj(PyObject * fn)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/program.c:869

---

{#program_add_type_finder}

### Program_add_type_finder

`static`

```cpp
static PyObject * Program_add_type_finder(Program * self, PyObject * args, PyObject * kwds)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/program.c:883

---

{#program_add_object_finder}

### Program_add_object_finder

`static`

```cpp
static PyObject * Program_add_object_finder(Program * self, PyObject * args, PyObject * kwds)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/program.c:922

---

{#program_set_core_dump}

### Program_set_core_dump

`static`

```cpp
static PyObject * Program_set_core_dump(Program * self, PyObject * args, PyObject * kwds)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/program.c:958

---

{#program_set_kernel}

### Program_set_kernel

`static`

```cpp
static PyObject * Program_set_kernel(Program * self)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/program.c:978

---

{#program_set_linux_kernel_custom}

### Program_set_linux_kernel_custom

`static`

```cpp
static PyObject * Program_set_linux_kernel_custom(Program * self, PyObject * args, PyObject * kwds)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/program.c:988

---

{#program_set_pid}

### Program_set_pid

`static`

```cpp
static PyObject * Program_set_pid(Program * self, PyObject * args, PyObject * kwds)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/program.c:1010

---

{#program_set_qemu_qmp}

### Program_set_qemu_qmp

`static`

```cpp
static PyObject * Program_set_qemu_qmp(Program * self, PyObject * args, PyObject * kwds)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/program.c:1026

---

{#program_modules}

### Program_modules

`static`

```cpp
static ModuleIterator * Program_modules(Program * self)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/program.c:1067

---

{#program_loaded_modules}

### Program_loaded_modules

`static`

```cpp
static ModuleIterator * Program_loaded_modules(Program * self)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/program.c:1083

---

{#program_create_loaded_modules}

### Program_create_loaded_modules

`static`

```cpp
static PyObject * Program_create_loaded_modules(Program * self)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/program.c:1101

---

{#module_wrap_find}

### Module_wrap_find

`static` `inline`

```cpp
static inline PyObject * Module_wrap_find(struct drgn_module * module)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/program.c:1109

---

{#program_main_module}

### Program_main_module

`static`

```cpp
static PyObject * Program_main_module(Program * self, PyObject * args, PyObject * kwds)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/program.c:1117

---

{#program_shared_library_module}

### Program_shared_library_module

`static`

```cpp
static PyObject * Program_shared_library_module(Program * self, PyObject * args, PyObject * kwds)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/program.c:1149

---

{#program_vdso_module}

### Program_vdso_module

`static`

```cpp
static PyObject * Program_vdso_module(Program * self, PyObject * args, PyObject * kwds)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/program.c:1182

---

{#program_relocatable_module}

### Program_relocatable_module

`static`

```cpp
static PyObject * Program_relocatable_module(Program * self, PyObject * args, PyObject * kwds)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/program.c:1213

---

{#program_linux_kernel_loadable_module}

### Program_linux_kernel_loadable_module

`static`

```cpp
static PyObject * Program_linux_kernel_loadable_module(Program * self, PyObject * args, PyObject * kwds)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/program.c:1245

---

{#program_extra_module}

### Program_extra_module

`static`

```cpp
static PyObject * Program_extra_module(Program * self, PyObject * args, PyObject * kwds)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/program.c:1286

---

{#program_module}

### Program_module

`static`

```cpp
static PyObject * Program_module(Program * self, PyObject * arg)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/program.c:1316

---

{#program_get_debug_info_options}

### Program_get_debug_info_options

`static`

```cpp
static DebugInfoOptions * Program_get_debug_info_options(Program * self, void * arg)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/program.c:1333

---

{#program_set_debug_info_options}

### Program_set_debug_info_options

`static`

```cpp
static int Program_set_debug_info_options(Program * self, PyObject * value, void * arg)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/program.c:1344

---

{#program_load_debug_info}

### Program_load_debug_info

`static`

```cpp
static PyObject * Program_load_debug_info(Program * self, PyObject * args, PyObject * kwds)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/program.c:1362

---

{#program_load_default_debug_info}

### Program_load_default_debug_info

`static`

```cpp
static PyObject * Program_load_default_debug_info(Program * self)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/program.c:1384

---

{#program_load_module_debug_info}

### Program_load_module_debug_info

`static`

```cpp
static PyObject * Program_load_module_debug_info(Program * self, PyObject * args)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/program.c:1394

---

{#define_vector-21}

### DEFINE_VECTOR

```cpp
DEFINE_VECTOR(drgn_module_vector, struct drgn_module *)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/program.c:1426

---

{#program_find_standard_debug_info}

### Program_find_standard_debug_info

`static`

```cpp
static PyObject * Program_find_standard_debug_info(Program * self, PyObject * args, PyObject * kwds)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/program.c:1428

---

{#program_read}

### Program_read

`static`

```cpp
static PyObject * Program_read(Program * self, PyObject * args, PyObject * kwds)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/program.c:1493

---

{#program_read_c_string}

### Program_read_c_string

`static`

```cpp
static PyObject * Program_read_c_string(Program * self, PyObject * args, PyObject * kwds)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/program.c:1520

---

{#program_search_memory}

### Program_search_memory

`static`

```cpp
static PyObject * Program_search_memory(Program * self, PyObject * args, PyObject * kwds)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/program.c:1575

---

{#program_search_memory_word}

### Program_search_memory_word

`static`

```cpp
static SEARCH_MEMORY_UINT_SIZES PyObject * Program_search_memory_word(Program * self, PyObject * args, PyObject * kwds)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/program.c:1727

---

{#program_search_memory_regex}

### Program_search_memory_regex

`static`

```cpp
static PyObject * Program_search_memory_regex(Program * self, PyObject * args, PyObject * kwds)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/program.c:1740

---

{#program_find_type}

### Program_find_type

`static`

```cpp
static PyObject * Program_find_type(Program * self, PyObject * args, PyObject * kwds)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/program.c:1784

---

{#set_object_not_found_error}

### set_object_not_found_error

`static`

```cpp
static void * set_object_not_found_error(struct drgn_error * err, PyObject * name)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/program.c:1822

---

{#program_find_object}

### Program_find_object

`static`

```cpp
static DrgnObject * Program_find_object(Program * self, PyObject * name_obj, const char * filename, enum drgn_find_object_flags flags)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/program.c:1843

---

{#program_object}

### Program_object

`static`

```cpp
static DrgnObject * Program_object(Program * self, PyObject * args, PyObject * kwds)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/program.c:1870

---

{#program_constant}

### Program_constant

`static`

```cpp
static DrgnObject * Program_constant(Program * self, PyObject * args, PyObject * kwds)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/program.c:1888

---

{#program_function}

### Program_function

`static`

```cpp
static DrgnObject * Program_function(Program * self, PyObject * args, PyObject * kwds)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/program.c:1902

---

{#program_variable}

### Program_variable

`static`

```cpp
static DrgnObject * Program_variable(Program * self, PyObject * args, PyObject * kwds)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/program.c:1916

---

{#program_stack_trace}

### Program_stack_trace

`static`

```cpp
static PyObject * Program_stack_trace(Program * self, PyObject * args, PyObject * kwds)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/program.c:1930

---

{#program_stack_trace_from_pcs}

### Program_stack_trace_from_pcs

`static`

```cpp
static PyObject * Program_stack_trace_from_pcs(Program * self, PyObject * args, PyObject * kwds)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/program.c:1960

---

{#program_source_location}

### Program_source_location

`static`

```cpp
static PyObject * Program_source_location(Program * self, PyObject * arg)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/program.c:2003

---

{#program_symbols}

### Program_symbols

`static`

```cpp
static PyObject * Program_symbols(Program * self, PyObject * args)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/program.c:2028

---

{#program_symbol}

### Program_symbol

`static`

```cpp
static PyObject * Program_symbol(Program * self, PyObject * arg)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/program.c:2060

---

{#program_threads}

### Program_threads

`static`

```cpp
static ThreadIterator * Program_threads(Program * self)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/program.c:2090

---

{#program_thread}

### Program_thread

`static`

```cpp
static PyObject * Program_thread(Program * self, PyObject * args, PyObject * kwds)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/program.c:2107

---

{#program_main_thread}

### Program_main_thread

`static`

```cpp
static PyObject * Program_main_thread(Program * self)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/program.c:2131

---

{#program_crashed_thread}

### Program_crashed_thread

`static`

```cpp
static PyObject * Program_crashed_thread(Program * self)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/program.c:2145

---

{#program_address_size}

### Program_address_size

`static`

```cpp
static PyObject * Program_address_size(Program * self)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/program.c:2159

---

{#program__log}

### Program__log

`static`

```cpp
static PyObject * Program__log(Program * self, PyObject * args, PyObject * kwds)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/program.c:2170

---

{#program_subscript}

### Program_subscript

`static`

```cpp
static DrgnObject * Program_subscript(Program * self, PyObject * key)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/program.c:2180

---

{#program_contains}

### Program_contains

`static`

```cpp
static int Program_contains(Program * self, PyObject * key)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/program.c:2189

---

{#program_get_flags}

### Program_get_flags

`static`

```cpp
static PyObject * Program_get_flags(Program * self, void * arg)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/program.c:2216

---

{#program_get_platform}

### Program_get_platform

`static`

```cpp
static PyObject * Program_get_platform(Program * self, void * arg)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/program.c:2222

---

{#program_get_core_dump_path}

### Program_get_core_dump_path

`static`

```cpp
static PyObject * Program_get_core_dump_path(Program * self, void * arg)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/program.c:2233

---

{#program_get_language}

### Program_get_language

`static`

```cpp
static PyObject * Program_get_language(Program * self, void * arg)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/program.c:2241

---

{#program_set_language}

### Program_set_language

`static`

```cpp
static int Program_set_language(Program * self, PyObject * value, void * arg)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/program.c:2246

---

{#program_from_core_dump-1}

### program_from_core_dump

```cpp
Program * program_from_core_dump(PyObject * self, PyObject * args, PyObject * kwds)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/program.c:2461

---

{#program_from_kernel-1}

### program_from_kernel

```cpp
Program * program_from_kernel(PyObject * self)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/program.c:2485

---

{#program_from_pid-1}

### program_from_pid

```cpp
Program * program_from_pid(PyObject * self, PyObject * args, PyObject * kwds)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/program.c:2498

---

{#typekindset_wrap-1}

### TypeKindSet_wrap

```cpp
PyObject * TypeKindSet_wrap(uint64_t mask)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/type_kind_set.c:10

---

{#init_type_kind_set-1}

### init_type_kind_set

```cpp
int init_type_kind_set(void)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/type_kind_set.c:18

---

{#type_kind_to_str}

### type_kind_to_str

`static` `inline`

```cpp
static inline const char * type_kind_to_str(enum drgn_type_kind kind)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/type_kind_set.c:35

---

{#typekindset_repr}

### TypeKindSet_repr

`static`

```cpp
static PyObject * TypeKindSet_repr(TypeKindSet * self)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/type_kind_set.c:67

---

{#typekind_value}

### TypeKind_value

`static`

```cpp
static int TypeKind_value(PyObject * obj)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/type_kind_set.c:88

---

{#typekindset_mask_from_iterable}

### TypeKindSet_mask_from_iterable

`static`

```cpp
static int TypeKindSet_mask_from_iterable(PyObject * iterable, uint64_t * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/type_kind_set.c:102

---

{#typekindset_new}

### TypeKindSet_new

`static`

```cpp
static TypeKindSet * TypeKindSet_new(PyTypeObject * subtype, PyObject * args, PyObject * kwds)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/type_kind_set.c:137

---

{#typekindset_length}

### TypeKindSet_length

`static`

```cpp
static Py_ssize_t TypeKindSet_length(TypeKindSet * self)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/type_kind_set.c:162

---

{#typekindset_contains}

### TypeKindSet_contains

`static`

```cpp
static int TypeKindSet_contains(TypeKindSet * self, PyObject * other)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/type_kind_set.c:167

---

{#typekindset_hash}

### TypeKindSet_hash

`static`

```cpp
static Py_ssize_t TypeKindSet_hash(TypeKindSet * self)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/type_kind_set.c:177

---

{#typekindset_richcompare}

### TypeKindSet_richcompare

`static`

```cpp
static PyObject * TypeKindSet_richcompare(TypeKindSet * self, PyObject * other, int op)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/type_kind_set.c:182

---

{#typekindset_iter}

### TypeKindSet_iter

`static`

```cpp
static TypeKindSetIterator * TypeKindSet_iter(TypeKindSet * self)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/type_kind_set.c:216

---

{#typekindset_isdisjoint}

### TypeKindSet_isdisjoint

`static`

```cpp
static PyObject * TypeKindSet_isdisjoint(TypeKindSet * self, PyObject * other)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/type_kind_set.c:225

---

{#typekindset_sub}

### TypeKindSet_sub

`static`

```cpp
static PyObject * TypeKindSet_sub(PyObject * left, PyObject * right)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/type_kind_set.c:236

---

{#typekindset_and}

### TypeKindSet_and

`static`

```cpp
static PyObject * TypeKindSet_and(PyObject * left, PyObject * right)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/type_kind_set.c:253

---

{#typekindset_or_op-1}

### TypeKindSet_OR_OP

```cpp
TypeKindSet_OR_OP(xor, ^)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/type_kind_set.c:284

---

{#typekindsetiterator_next}

### TypeKindSetIterator_next

`static`

```cpp
static PyObject * TypeKindSetIterator_next(TypeKindSetIterator * self)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/type_kind_set.c:322

---

{#typekindsetiterator_length_hint}

### TypeKindSetIterator_length_hint

`static`

```cpp
static PyObject * TypeKindSetIterator_length_hint(TypeKindSetIterator * self)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/type_kind_set.c:331

---

{#drgn_register_state_bitset_size}

### drgn_register_state_bitset_size

`static` `inline`

```cpp
static inline uint32_t drgn_register_state_bitset_size(uint16_t num_regs)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/register_state.c:13

---

{#drgn_register_state_is_known}

### drgn_register_state_is_known

`static`

```cpp
static bool drgn_register_state_is_known(const struct drgn_register_state * regs, uint32_t i)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/register_state.c:53

---

{#drgn_register_state_set_known}

### drgn_register_state_set_known

`static`

```cpp
static void drgn_register_state_set_known(struct drgn_register_state * regs, uint32_t i)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/register_state.c:59

---

{#drgn_register_state_set_unknown}

### drgn_register_state_set_unknown

`static`

```cpp
static void drgn_register_state_set_unknown(struct drgn_register_state * regs, uint32_t i)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/register_state.c:66

---

{#string_builder_appendf-1}

### string_builder_appendf

```cpp
bool string_builder_appendf(struct string_builder * sb, const char * format, ...)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/string_builder.c:91

---

{#dw_op_str}

### dw_op_str

```cpp
const char * dw_op_str(int value, char buf)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_constants.c:11

Get the name of a `DW_OP` value.

#### Returns
Static string if the value is known or `buf` if the value is unknown.

---

{#dw_tag_str}

### dw_tag_str

```cpp
const char * dw_tag_str(int value, char buf)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_constants.c:18

Get the name of a `DW_TAG` value.

#### Returns
Static string if the value is known or `buf` if the value is unknown.

---

{#dw_op_str-1}

### dw_op_str

```cpp
const char * dw_op_str(int value, char buf)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_constants.h:1001

Get the name of a `DW_OP` value.

#### Returns
Static string if the value is known or `buf` if the value is unknown.

---

{#dw_tag_str-1}

### dw_tag_str

```cpp
const char * dw_tag_str(int value, char buf)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_constants.h:1162

Get the name of a `DW_TAG` value.

#### Returns
Static string if the value is known or `buf` if the value is unknown.

---

{#language_repr}

### Language_repr

`static`

```cpp
static PyObject * Language_repr(Language * self)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/language.c:8

---

{#language_get_name}

### Language_get_name

`static`

```cpp
static PyObject * Language_get_name(Language * self, void * arg)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/language.c:13

---

{#language_wrap-1}

### Language_wrap

```cpp
PyObject * Language_wrap(const struct drgn_language * language)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/language.c:36

---

{#language_converter-1}

### language_converter

```cpp
int language_converter(PyObject * o, void * p)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/language.c:43

---

{#add_languages-1}

### add_languages

```cpp
int add_languages(void)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/language.c:61

---

{#platform_wrap-1}

### Platform_wrap

```cpp
PyObject * Platform_wrap(const struct drgn_platform * platform)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/platform.c:6

---

{#platform_new}

### Platform_new

`static`

```cpp
static Platform * Platform_new(PyTypeObject * subtype, PyObject * args, PyObject * kwds)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/platform.c:22

---

{#platform_dealloc}

### Platform_dealloc

`static`

```cpp
static void Platform_dealloc(Platform * self)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/platform.c:53

---

{#platform_richcompare}

### Platform_richcompare

`static`

```cpp
static PyObject * Platform_richcompare(Platform * self, PyObject * other, int op)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/platform.c:59

---

{#platform_get_arch}

### Platform_get_arch

`static`

```cpp
static PyObject * Platform_get_arch(Platform * self, void * arg)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/platform.c:71

---

{#platform_get_flags}

### Platform_get_flags

`static`

```cpp
static PyObject * Platform_get_flags(Platform * self, void * arg)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/platform.c:77

---

{#platform_get_registers}

### Platform_get_registers

`static`

```cpp
static PyObject * Platform_get_registers(Platform * self, void * arg)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/platform.c:83

---

{#platform_repr}

### Platform_repr

`static`

```cpp
static PyObject * Platform_repr(Platform * self)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/platform.c:101

---

{#register_richcompare}

### Register_richcompare

`static`

```cpp
static PyObject * Register_richcompare(Register * self, PyObject * other, int op)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/platform.c:134

---

{#register_get_names}

### Register_get_names

`static`

```cpp
static PyObject * Register_get_names(Register * self, void * arg)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/platform.c:145

---

{#register_repr}

### Register_repr

`static`

```cpp
static PyObject * Register_repr(Register * self)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/platform.c:161

---

{#add_sourcelocation-1}

### add_SourceLocation

```cpp
int add_SourceLocation(PyObject * m)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/source_location.c:9

---

{#sourcelocationlist_wrap-1}

### SourceLocationList_wrap

```cpp
PyObject * SourceLocationList_wrap(struct drgn_source_location_list * locs)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/source_location.c:69

---

{#sourcelocationlist_dealloc}

### SourceLocationList_dealloc

`static`

```cpp
static void SourceLocationList_dealloc(SourceLocationList * self)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/source_location.c:80

---

{#sourcelocationlist_traverse}

### SourceLocationList_traverse

`static`

```cpp
static int SourceLocationList_traverse(SourceLocationList * self, visitproc visit, void * arg)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/source_location.c:92

---

{#sourcelocationlist_get_prog}

### SourceLocationList_get_prog

`static`

```cpp
static Program * SourceLocationList_get_prog(SourceLocationList * self, void * arg)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/source_location.c:102

---

{#sourcelocationlist_str}

### SourceLocationList_str

`static`

```cpp
static PyObject * SourceLocationList_str(SourceLocationList * self)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/source_location.c:111

---

{#sourcelocationlist_length}

### SourceLocationList_length

`static`

```cpp
static Py_ssize_t SourceLocationList_length(SourceLocationList * self)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/source_location.c:121

---

{#sourcelocationlist_name}

### SourceLocationList_name

`static`

```cpp
static PyObject * SourceLocationList_name(PyObject * self)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/source_location.c:126

---

{#sourcelocationlist_item}

### SourceLocationList_item

`static`

```cpp
static PyObject * SourceLocationList_item(SourceLocationList * self, Py_ssize_t i)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/source_location.c:143

---

{#run_command}

### run_command

`static`

```cpp
static struct drgn_error * run_command(const char * which, const char * command, struct drgn_program * prog)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/examples/load_debug_info.c:20

---

{#timespec_sub}

### timespec_sub

`static` `inline`

```cpp
static inline struct timespec timespec_sub(struct timespec a, struct timespec b)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/examples/load_debug_info.c:57

---

{#usage}

### usage

`static`

```cpp
static noreturn void usage(bool error)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/examples/load_debug_info.c:72

---

{#main}

### main

```cpp
int main(int argc, char ** argv)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/examples/load_debug_info.c:93

---

{#drgn_debug_info_options_init}

### drgn_debug_info_options_init

```cpp
void drgn_debug_info_options_init(struct drgn_debug_info_options * options)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info_options.c:27

---

{#drgn_debug_info_options_list_destroy}

### drgn_debug_info_options_list_destroy

`static`

```cpp
static void drgn_debug_info_options_list_destroy(const char *const * list, const char *const * default_list)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info_options.c:39

---

{#drgn_debug_info_options_listp_destroy}

### drgn_debug_info_options_listp_destroy

`static`

```cpp
static void drgn_debug_info_options_listp_destroy(const char *const ** listp)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info_options.c:49

---

{#drgn_debug_info_options_deinit}

### drgn_debug_info_options_deinit

```cpp
void drgn_debug_info_options_deinit(struct drgn_debug_info_options * options)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info_options.c:55

---

{#drgn_debug_info_options_list_dup}

### drgn_debug_info_options_list_dup

`static`

```cpp
static struct drgn_error * drgn_debug_info_options_list_dup(const char *const * list, bool allow_empty, const char *const ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info_options.c:89

---

{#drgn_format_debug_info_options_common}

### drgn_format_debug_info_options_common

`static`

```cpp
static DRGN_DEBUG_INFO_OPTIONS bool drgn_format_debug_info_options_common(struct string_builder * sb, const char * name, bool * first)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info_options.c:213

---

{#drgn_debug_info_options_lists_equal}

### drgn_debug_info_options_lists_equal

`static`

```cpp
static bool drgn_debug_info_options_lists_equal(const char *const * a, const char *const * b)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info_options.c:224

---

{#drgn_format_debug_info_options_list}

### drgn_format_debug_info_options_list

`static`

```cpp
static bool drgn_format_debug_info_options_list(struct string_builder * sb, const char * name, bool * first, const char *const * list, const char *const * default_list)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info_options.c:237

---

{#drgn_format_debug_info_options_bool}

### drgn_format_debug_info_options_bool

`static`

```cpp
static bool drgn_format_debug_info_options_bool(struct string_builder * sb, const char * name, bool * first, bool value, bool default_value)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info_options.c:260

---

{#drgn_kmod_search_method_format}

### drgn_kmod_search_method_format

`static`

```cpp
static bool drgn_kmod_search_method_format(struct string_builder * sb, const char * name, bool * first, enum drgn_kmod_search_method value, enum drgn_kmod_search_method default_value)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info_options.c:272

---

{#drgn_format_debug_info_options}

### drgn_format_debug_info_options

```cpp
char * drgn_format_debug_info_options(struct drgn_debug_info_options * options)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info_options.c:303

---

{#drgn_debug_info_options_init-1}

### drgn_debug_info_options_init

```cpp
void drgn_debug_info_options_init(struct drgn_debug_info_options * options)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info_options.h:34

---

{#drgn_debug_info_options_deinit-1}

### drgn_debug_info_options_deinit

```cpp
void drgn_debug_info_options_deinit(struct drgn_debug_info_options * options)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info_options.h:35

---

{#drgn_format_debug_info_options-1}

### drgn_format_debug_info_options

```cpp
char * drgn_format_debug_info_options(struct drgn_debug_info_options * options)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info_options.h:37

---

{#stacktrace_wrap-1}

### StackTrace_wrap

```cpp
PyObject * StackTrace_wrap(struct drgn_stack_trace * trace)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/stack_trace.c:9

---

{#stacktrace_dealloc}

### StackTrace_dealloc

`static`

```cpp
static void StackTrace_dealloc(StackTrace * self)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/stack_trace.c:18

---

{#stacktrace_traverse}

### StackTrace_traverse

`static`

```cpp
static int StackTrace_traverse(StackTrace * self, visitproc visit, void * arg)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/stack_trace.c:29

---

{#stacktrace_get_prog}

### StackTrace_get_prog

`static`

```cpp
static Program * StackTrace_get_prog(StackTrace * self, void * arg)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/stack_trace.c:36

---

{#stacktrace_str}

### StackTrace_str

`static`

```cpp
static PyObject * StackTrace_str(StackTrace * self)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/stack_trace.c:44

---

{#stacktrace_length}

### StackTrace_length

`static`

```cpp
static Py_ssize_t StackTrace_length(StackTrace * self)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/stack_trace.c:54

---

{#stacktrace_item}

### StackTrace_item

`static`

```cpp
static StackFrame * StackTrace_item(StackTrace * self, Py_ssize_t i)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/stack_trace.c:59

---

{#stackframe_dealloc}

### StackFrame_dealloc

`static`

```cpp
static void StackFrame_dealloc(StackFrame * self)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/stack_trace.c:105

---

{#stackframe_traverse}

### StackFrame_traverse

`static`

```cpp
static int StackFrame_traverse(StackFrame * self, visitproc visit, void * arg)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/stack_trace.c:112

---

{#stackframe_str}

### StackFrame_str

`static`

```cpp
static PyObject * StackFrame_str(StackFrame * self)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/stack_trace.c:118

---

{#stackframe_locals}

### StackFrame_locals

`static`

```cpp
static PyObject * StackFrame_locals(StackFrame * self)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/stack_trace.c:128

---

{#stackframe_subscript}

### StackFrame_subscript

`static`

```cpp
static DrgnObject * StackFrame_subscript(StackFrame * self, PyObject * key)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/stack_trace.c:155

---

{#stackframe_contains}

### StackFrame_contains

`static`

```cpp
static int StackFrame_contains(StackFrame * self, PyObject * key)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/stack_trace.c:181

---

{#stackframe_source_name}

### StackFrame_source_name

`static`

```cpp
static PyObject * StackFrame_source_name(StackFrame * self)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/stack_trace.c:204

---

{#stackframe_source}

### StackFrame_source

`static`

```cpp
static PyObject * StackFrame_source(StackFrame * self)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/stack_trace.c:217

---

{#stackframe_symbol}

### StackFrame_symbol

`static`

```cpp
static PyObject * StackFrame_symbol(StackFrame * self)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/stack_trace.c:239

---

{#stackframe_register}

### StackFrame_register

`static`

```cpp
static PyObject * StackFrame_register(StackFrame * self, PyObject * arg)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/stack_trace.c:255

---

{#stackframe_registers}

### StackFrame_registers

`static`

```cpp
static PyObject * StackFrame_registers(StackFrame * self)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/stack_trace.c:278

---

{#stackframe_get_name}

### StackFrame_get_name

`static`

```cpp
static PyObject * StackFrame_get_name(StackFrame * self, void * arg)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/stack_trace.c:308

---

{#stackframe_get_function_name}

### StackFrame_get_function_name

`static`

```cpp
static PyObject * StackFrame_get_function_name(StackFrame * self, void * arg)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/stack_trace.c:318

---

{#stackframe_get_is_inline}

### StackFrame_get_is_inline

`static`

```cpp
static PyObject * StackFrame_get_is_inline(StackFrame * self, void * arg)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/stack_trace.c:328

---

{#stackframe_get_interrupted}

### StackFrame_get_interrupted

`static`

```cpp
static PyObject * StackFrame_get_interrupted(StackFrame * self, void * arg)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/stack_trace.c:333

---

{#stackframe_get_pc}

### StackFrame_get_pc

`static`

```cpp
static PyObject * StackFrame_get_pc(StackFrame * self, void * arg)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/stack_trace.c:339

---

{#stackframe_get_sp}

### StackFrame_get_sp

`static`

```cpp
static PyObject * StackFrame_get_sp(StackFrame * self, void * arg)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/stack_trace.c:351

---

{#end_virtual_address_translation}

### end_virtual_address_translation

`static`

```cpp
static void end_virtual_address_translation(struct drgn_program * prog)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/linux_kernel_helpers.c:16

---

{#begin_virtual_address_translation}

### begin_virtual_address_translation

`static`

```cpp
static struct drgn_error * begin_virtual_address_translation(struct drgn_program * prog, uint64_t pgtable, uint64_t virt_addr, struct pgtable_iterator ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/linux_kernel_helpers.c:22

---

{#linux_helper_direct_mapping_offset-1}

### linux_helper_direct_mapping_offset

```cpp
struct drgn_error * linux_helper_direct_mapping_offset(struct drgn_program * prog, uint64_t * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/linux_kernel_helpers.c:72

---

{#linux_helper_read_vm-1}

### linux_helper_read_vm

```cpp
struct drgn_error * linux_helper_read_vm(struct drgn_program * prog, uint64_t pgtable, uint64_t virt_addr, void * buf, size_t count)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/linux_kernel_helpers.c:156

---

{#linux_helper_follow_phys-1}

### linux_helper_follow_phys

```cpp
struct drgn_error * linux_helper_follow_phys(struct drgn_program * prog, uint64_t pgtable, uint64_t virt_addr, uint64_t * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/linux_kernel_helpers.c:214

---

{#linux_helper_per_cpu_ptr-1}

### linux_helper_per_cpu_ptr

```cpp
struct drgn_error * linux_helper_per_cpu_ptr(struct drgn_object * res, const struct drgn_object * ptr, uint64_t cpu)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/linux_kernel_helpers.c:243

---

{#cpu_rq_member}

### cpu_rq_member

`static`

```cpp
static struct drgn_error * cpu_rq_member(struct drgn_object * res, uint64_t cpu, const char * member_name)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/linux_kernel_helpers.c:278

---

{#linux_helper_cpu_curr-1}

### linux_helper_cpu_curr

```cpp
struct drgn_error * linux_helper_cpu_curr(struct drgn_object * res, uint64_t cpu)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/linux_kernel_helpers.c:301

---

{#linux_helper_idle_task-1}

### linux_helper_idle_task

```cpp
struct drgn_error * linux_helper_idle_task(struct drgn_object * res, uint64_t cpu)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/linux_kernel_helpers.c:306

---

{#linux_helper_task_thread_info-1}

### linux_helper_task_thread_info

```cpp
struct drgn_error * linux_helper_task_thread_info(struct drgn_object * res, const struct drgn_object * task)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/linux_kernel_helpers.c:311

---

{#linux_helper_task_cpu-1}

### linux_helper_task_cpu

```cpp
struct drgn_error * linux_helper_task_cpu(const struct drgn_object * task, uint64_t * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/linux_kernel_helpers.c:338

---

{#linux_helper_task_on_cpu-1}

### linux_helper_task_on_cpu

```cpp
struct drgn_error * linux_helper_task_on_cpu(const struct drgn_object * task, bool * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/linux_kernel_helpers.c:391

---

{#linux_helper_xa_load-1}

### linux_helper_xa_load

```cpp
struct drgn_error * linux_helper_xa_load(struct drgn_object * res, const struct drgn_object * xa, uint64_t index)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/linux_kernel_helpers.c:417

---

{#linux_helper_idr_find-1}

### linux_helper_idr_find

```cpp
struct drgn_error * linux_helper_idr_find(struct drgn_object * res, const struct drgn_object * idr, uint64_t id)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/linux_kernel_helpers.c:627

---

{#find_pid_in_pid_hash}

### find_pid_in_pid_hash

`static`

```cpp
static struct drgn_error * find_pid_in_pid_hash(struct drgn_object * res, const struct drgn_object * ns, const struct drgn_object * pid_hash, uint64_t pid)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/linux_kernel_helpers.c:668

---

{#linux_helper_find_pid-1}

### linux_helper_find_pid

```cpp
struct drgn_error * linux_helper_find_pid(struct drgn_object * res, const struct drgn_object * ns, uint64_t pid)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/linux_kernel_helpers.c:817

---

{#linux_helper_pid_task-1}

### linux_helper_pid_task

```cpp
struct drgn_error * linux_helper_pid_task(struct drgn_object * res, const struct drgn_object * pid, uint64_t pid_type)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/linux_kernel_helpers.c:854

---

{#linux_helper_find_task-1}

### linux_helper_find_task

```cpp
struct drgn_error * linux_helper_find_task(struct drgn_object * res, const struct drgn_object * ns, uint64_t pid)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/linux_kernel_helpers.c:919

---

{#linux_helper_task_iterator_set_thread_node}

### linux_helper_task_iterator_set_thread_node

`static` `inline`

```cpp
static inline struct drgn_error * linux_helper_task_iterator_set_thread_node(struct linux_helper_task_iterator * it)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/linux_kernel_helpers.c:944

---

{#linux_helper_task_iterator_init-1}

### linux_helper_task_iterator_init

```cpp
struct drgn_error * linux_helper_task_iterator_init(struct linux_helper_task_iterator * it, struct drgn_program * prog)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/linux_kernel_helpers.c:966

---

{#linux_helper_task_iterator_deinit-1}

### linux_helper_task_iterator_deinit

```cpp
void linux_helper_task_iterator_deinit(struct linux_helper_task_iterator * it)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/linux_kernel_helpers.c:1013

---

{#linux_helper_task_iterator_next-1}

### linux_helper_task_iterator_next

```cpp
struct drgn_error * linux_helper_task_iterator_next(struct linux_helper_task_iterator * it, struct drgn_object * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/linux_kernel_helpers.c:1020

Get the next task from a [linux_helper_task_iterator](linux_helper_task_iterator.md#linux_helper_task_iterator).

---

{#json_object_putp}

### json_object_putp

`static` `inline`

```cpp
static inline void json_object_putp(struct json_object ** objp)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/qemu_machine_protocol.c:42

---

{#drgn_qmp_conn_deinit}

### drgn_qmp_conn_deinit

```cpp
void drgn_qmp_conn_deinit(struct drgn_qmp_conn * conn)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/qemu_machine_protocol.c:47

---

{#qmp_recv_msg}

### qmp_recv_msg

`static`

```cpp
static struct drgn_error * qmp_recv_msg(struct drgn_qmp_conn * conn, struct json_object ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/qemu_machine_protocol.c:58

---

{#drgn_error_qmp}

### drgn_error_qmp

`static`

```cpp
static struct drgn_error * drgn_error_qmp(struct json_object * obj)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/qemu_machine_protocol.c:112

---

{#qmp_execute_str}

### qmp_execute_str

`static`

```cpp
static struct drgn_error * qmp_execute_str(struct drgn_qmp_conn * conn, const char * cmd, size_t cmd_len, struct json_object ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/qemu_machine_protocol.c:134

---

{#qmp_send_fd}

### qmp_send_fd

`static`

```cpp
static struct drgn_error * qmp_send_fd(struct drgn_qmp_conn * conn, const char * cmd, size_t cmd_len, int fd)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/qemu_machine_protocol.c:169

---

{#qmp_negotiate}

### qmp_negotiate

`static`

```cpp
static struct drgn_error * qmp_negotiate(struct drgn_qmp_conn * conn)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/qemu_machine_protocol.c:215

---

{#qmp_detect_platform}

### qmp_detect_platform

`static`

```cpp
static struct drgn_error * qmp_detect_platform(struct drgn_qmp_conn * conn, struct drgn_platform * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/qemu_machine_protocol.c:233

---

{#parse_qemu_xp}

### parse_qemu_xp

`static`

```cpp
static struct drgn_error * parse_qemu_xp(const char * str, void * buf, size_t count)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/qemu_machine_protocol.c:281

---

{#drgn_qmp_read_memory}

### drgn_qmp_read_memory

`static`

```cpp
static struct drgn_error * drgn_qmp_read_memory(void * buf, uint64_t address, size_t count, uint64_t offset, void * arg, bool physical)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/qemu_machine_protocol.c:333

---

{#qmp_get_peer_pid}

### qmp_get_peer_pid

`static`

```cpp
static pid_t qmp_get_peer_pid(struct drgn_program * prog)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/qemu_machine_protocol.c:379

---

{#define_vector-22}

### DEFINE_VECTOR

```cpp
DEFINE_VECTOR(uint64_range_vector, struct uint64_range)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/qemu_machine_protocol.c:400

---

{#qmp_get_mem_ranges}

### qmp_get_mem_ranges

`static`

```cpp
static struct drgn_error * qmp_get_mem_ranges(struct drgn_qmp_conn * conn, struct uint64_range ** ranges_ret, size_t * num_ram_ranges_ret, size_t * num_rom_ranges_ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/qemu_machine_protocol.c:403

---

{#qmp_gpa2hva}

### qmp_gpa2hva

`static`

```cpp
static struct drgn_error * qmp_gpa2hva(struct drgn_qmp_conn * conn, uint64_t gpa, uint64_t * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/qemu_machine_protocol.c:511

---

{#can_read_process_mem}

### can_read_process_mem

`static`

```cpp
static bool can_read_process_mem(pid_t pid, uintptr_t address)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/qemu_machine_protocol.c:582

---

{#drgn_read_qemu_process_mem}

### drgn_read_qemu_process_mem

`static`

```cpp
static struct drgn_error * drgn_read_qemu_process_mem(void * buf, uint64_t address, size_t count, uint64_t offset, void * arg, bool physical)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/qemu_machine_protocol.c:591

---

{#qmp_setup_process_mem}

### qmp_setup_process_mem

`static`

```cpp
static struct drgn_error * qmp_setup_process_mem(struct drgn_program * prog, pid_t pid, const struct uint64_range * mem_ranges, size_t num_mem_ranges)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/qemu_machine_protocol.c:628

---

{#parse_vmcoreinfo_from_dump}

### parse_vmcoreinfo_from_dump

`static`

```cpp
static struct drgn_error * parse_vmcoreinfo_from_dump(struct drgn_program * prog, int fd)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/qemu_machine_protocol.c:689

---

{#qmp_read_vmcoreinfo}

### qmp_read_vmcoreinfo

`static`

```cpp
static struct drgn_error * qmp_read_vmcoreinfo(struct drgn_program * prog, uint64_t ram_address)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/qemu_machine_protocol.c:740

---

{#qmp_connect_unix}

### qmp_connect_unix

`static`

```cpp
static struct drgn_error * qmp_connect_unix(const char * address, int * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/qemu_machine_protocol.c:784

---

{#qmp_connect_tcp}

### qmp_connect_tcp

`static`

```cpp
static struct drgn_error * qmp_connect_tcp(const char * address, const char * colon, int * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/qemu_machine_protocol.c:806

---

{#drgn_qmp_conn_init}

### drgn_qmp_conn_init

`static` `inline`

```cpp
static inline void drgn_qmp_conn_init(struct drgn_qmp_conn * conn)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/qemu_machine_protocol.h:39

---

{#drgn_qmp_conn_deinit-1}

### drgn_qmp_conn_deinit

`static` `inline`

```cpp
static inline void drgn_qmp_conn_deinit(struct drgn_qmp_conn * conn)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/qemu_machine_protocol.h:40

---

{#modulesectionaddresses_new}

### ModuleSectionAddresses_new

`static`

```cpp
static ModuleSectionAddresses * ModuleSectionAddresses_new(PyTypeObject * subtype, PyObject * args, PyObject * kwds)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/module_section_addresses.c:10

---

{#modulesectionaddresses_dealloc}

### ModuleSectionAddresses_dealloc

`static`

```cpp
static void ModuleSectionAddresses_dealloc(ModuleSectionAddresses * self)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/module_section_addresses.c:29

---

{#modulesectionaddresses_traverse}

### ModuleSectionAddresses_traverse

`static`

```cpp
static int ModuleSectionAddresses_traverse(ModuleSectionAddresses * self, visitproc visit, void * arg)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/module_section_addresses.c:39

---

{#drgn_module_section_address_iterator_destroyp}

### drgn_module_section_address_iterator_destroyp

`static` `inline`

```cpp
static inline void drgn_module_section_address_iterator_destroyp(struct drgn_module_section_address_iterator ** itp)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/module_section_addresses.c:50

---

{#modulesectionaddresses_repr}

### ModuleSectionAddresses_repr

`static`

```cpp
static PyObject * ModuleSectionAddresses_repr(ModuleSectionAddresses * self)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/module_section_addresses.c:55

---

{#modulesectionaddresses_length}

### ModuleSectionAddresses_length

`static`

```cpp
static Py_ssize_t ModuleSectionAddresses_length(ModuleSectionAddresses * self)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/module_section_addresses.c:95

---

{#modulesectionaddresses_subscript}

### ModuleSectionAddresses_subscript

`static`

```cpp
static PyObject * ModuleSectionAddresses_subscript(ModuleSectionAddresses * self, PyObject * key)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/module_section_addresses.c:107

---

{#modulesectionaddresses_ass_subscript}

### ModuleSectionAddresses_ass_subscript

`static`

```cpp
static int ModuleSectionAddresses_ass_subscript(ModuleSectionAddresses * self, PyObject * key, PyObject * value)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/module_section_addresses.c:130

---

{#modulesectionaddresses_iter}

### ModuleSectionAddresses_iter

`static`

```cpp
static ModuleSectionAddressesIterator * ModuleSectionAddresses_iter(ModuleSectionAddresses * self)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/module_section_addresses.c:171

---

{#modulesectionaddressesiterator_dealloc}

### ModuleSectionAddressesIterator_dealloc

`static`

```cpp
static void ModuleSectionAddressesIterator_dealloc(ModuleSectionAddressesIterator * self)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/module_section_addresses.c:210

---

{#modulesectionaddressesiterator_traverse}

### ModuleSectionAddressesIterator_traverse

`static`

```cpp
static int ModuleSectionAddressesIterator_traverse(ModuleSectionAddressesIterator * self, visitproc visit, void * arg)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/module_section_addresses.c:224

---

{#modulesectionaddressesiterator_next}

### ModuleSectionAddressesIterator_next

`static`

```cpp
static PyObject * ModuleSectionAddressesIterator_next(ModuleSectionAddressesIterator * self)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/module_section_addresses.c:237

---

{#init_module_section_addresses-1}

### init_module_section_addresses

```cpp
int init_module_section_addresses(void)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/module_section_addresses.c:260

---

{#debuginfooptions_wrap_list}

### DebugInfoOptions_wrap_list

`static`

```cpp
static PyObject * DebugInfoOptions_wrap_list(const char *const * list)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/debug_info_options.c:7

---

{#drgn_debug_info_options_destroyp}

### drgn_debug_info_options_destroyp

`static` `inline`

```cpp
static inline DRGN_DEBUG_INFO_OPTIONS void drgn_debug_info_options_destroyp(struct drgn_debug_info_options ** optionsp)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/debug_info_options.c:110

---

{#debuginfooptions_new}

### DebugInfoOptions_new

`static`

```cpp
static DebugInfoOptions * DebugInfoOptions_new(PyTypeObject * subtype, PyObject * args, PyObject * kwds)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/debug_info_options.c:115

---

{#debuginfooptions_dealloc}

### DebugInfoOptions_dealloc

`static`

```cpp
static void DebugInfoOptions_dealloc(DebugInfoOptions * self)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/debug_info_options.c:178

---

{#debuginfooptions_traverse}

### DebugInfoOptions_traverse

`static`

```cpp
static int DebugInfoOptions_traverse(DebugInfoOptions * self, visitproc visit, void * arg)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/debug_info_options.c:188

---

{#debuginfooptions_repr}

### DebugInfoOptions_repr

`static`

```cpp
static PyObject * DebugInfoOptions_repr(PyObject * self)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/debug_info_options.c:209

## Variables

---

{#drgn_cfi_rule_undefined}

### DRGN_CFI_RULE_UNDEFINED

```cpp
DRGN_CFI_RULE_UNDEFINED
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/cfi.h:1

[Register](Register.md#register) value in the caller is not known.

---

{#drgn_cfi_rule_at_cfa_plus_offset}

### DRGN_CFI_RULE_AT_CFA_PLUS_OFFSET

```cpp
DRGN_CFI_RULE_AT_CFA_PLUS_OFFSET
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/cfi.h:6

[Register](Register.md#register) value in the caller is stored at the CFA in the current frame plus an offset: `*(cfa + offset)`.

---

{#drgn_cfi_rule_cfa_plus_offset}

### DRGN_CFI_RULE_CFA_PLUS_OFFSET

```cpp
DRGN_CFI_RULE_CFA_PLUS_OFFSET
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/cfi.h:11

[Register](Register.md#register) value in the caller is the CFA in the current frame plus an offset: `cfa + offset`.

---

{#drgn_cfi_rule_at_register_plus_offset}

### DRGN_CFI_RULE_AT_REGISTER_PLUS_OFFSET

```cpp
DRGN_CFI_RULE_AT_REGISTER_PLUS_OFFSET
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/cfi.h:16

[Register](Register.md#register) value in the caller is stored at the value of a register in the current frame plus an offset: `*(reg + offset)`.

---

{#drgn_cfi_rule_at_register_add_offset}

### DRGN_CFI_RULE_AT_REGISTER_ADD_OFFSET

```cpp
DRGN_CFI_RULE_AT_REGISTER_ADD_OFFSET
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/cfi.h:21

[Register](Register.md#register) value in the caller is an offset plus the value stored at the value of a register in the current frame: `(*reg) + offset`.

---

{#drgn_cfi_rule_register_plus_offset}

### DRGN_CFI_RULE_REGISTER_PLUS_OFFSET

```cpp
DRGN_CFI_RULE_REGISTER_PLUS_OFFSET
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/cfi.h:29

[Register](Register.md#register) value in the caller is the value of a register in the current frame plus an offset: `reg + offset`.

Note that this can also be used to represent DWARF's "same value" rule by using the same register with an offset of 0.

---

{#drgn_cfi_rule_at_dwarf_expression}

### DRGN_CFI_RULE_AT_DWARF_EXPRESSION

```cpp
DRGN_CFI_RULE_AT_DWARF_EXPRESSION
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/cfi.h:34

[Register](Register.md#register) value in the caller is stored at the address given by a DWARF expression.

---

{#drgn_cfi_rule_dwarf_expression}

### DRGN_CFI_RULE_DWARF_EXPRESSION

```cpp
DRGN_CFI_RULE_DWARF_EXPRESSION
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/cfi.h:36

[Register](Register.md#register) value in the caller is given by a DWARF expression.

---

{#drgn_cfi_rule_constant}

### DRGN_CFI_RULE_CONSTANT

```cpp
DRGN_CFI_RULE_CONSTANT
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/cfi.h:38

[Register](Register.md#register) value in the caller has a constant value.

---

{#drgn_error_no_memory}

### DRGN_ERROR_NO_MEMORY

```cpp
DRGN_ERROR_NO_MEMORY
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:1

Cannot allocate memory.

---

{#drgn_error_stop}

### DRGN_ERROR_STOP

```cpp
DRGN_ERROR_STOP
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:3

Stop iteration.

---

{#drgn_error_other}

### DRGN_ERROR_OTHER

```cpp
DRGN_ERROR_OTHER
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:5

Miscellaneous error.

---

{#drgn_error_invalid_argument}

### DRGN_ERROR_INVALID_ARGUMENT

```cpp
DRGN_ERROR_INVALID_ARGUMENT
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:7

Invalid argument.

---

{#drgn_error_overflow}

### DRGN_ERROR_OVERFLOW

```cpp
DRGN_ERROR_OVERFLOW
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:9

Integer overflow.

---

{#drgn_error_recursion}

### DRGN_ERROR_RECURSION

```cpp
DRGN_ERROR_RECURSION
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:11

Maximum recursion depth exceeded.

---

{#drgn_error_os}

### DRGN_ERROR_OS

```cpp
DRGN_ERROR_OS
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:13

System call error.

---

{#drgn_error_missing_debug_info}

### DRGN_ERROR_MISSING_DEBUG_INFO

```cpp
DRGN_ERROR_MISSING_DEBUG_INFO
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:15

One or more files do not have debug information.

---

{#drgn_error_syntax}

### DRGN_ERROR_SYNTAX

```cpp
DRGN_ERROR_SYNTAX
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:17

Syntax error while parsing.

---

{#drgn_error_lookup}

### DRGN_ERROR_LOOKUP

```cpp
DRGN_ERROR_LOOKUP
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:19

Entry not found.

---

{#drgn_error_fault}

### DRGN_ERROR_FAULT

```cpp
DRGN_ERROR_FAULT
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:21

Bad memory access.

---

{#drgn_error_type}

### DRGN_ERROR_TYPE

```cpp
DRGN_ERROR_TYPE
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:23

Type error in expression.

---

{#drgn_error_zero_division}

### DRGN_ERROR_ZERO_DIVISION

```cpp
DRGN_ERROR_ZERO_DIVISION
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:25

Division by zero.

---

{#drgn_error_out_of_bounds}

### DRGN_ERROR_OUT_OF_BOUNDS

```cpp
DRGN_ERROR_OUT_OF_BOUNDS
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:27

Array out of bounds

---

{#drgn_error_object_absent-1}

### DRGN_ERROR_OBJECT_ABSENT

```cpp
DRGN_ERROR_OBJECT_ABSENT
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:29

Operation was attempted with absent object.

---

{#drgn_error_not_implemented}

### DRGN_ERROR_NOT_IMPLEMENTED

```cpp
DRGN_ERROR_NOT_IMPLEMENTED
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:31

Functionality is not implemented.

---

{#drgn_error_unsupported_operation}

### DRGN_ERROR_UNSUPPORTED_OPERATION

```cpp
DRGN_ERROR_UNSUPPORTED_OPERATION
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:33

Operation is not supported.

---

{#drgn_error_runtime}

### DRGN_ERROR_RUNTIME

```cpp
DRGN_ERROR_RUNTIME
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:38

Invalid operation detected at runtime (structure was modified while iterating, invalid reentrant call, etc.).

---

{#drgn_error_bad_data}

### DRGN_ERROR_BAD_DATA

```cpp
DRGN_ERROR_BAD_DATA
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:43

External data is corrupted, unrecognized, inconsistent, or otherwise invalid.

---

{#drgn_num_error_codes}

### DRGN_NUM_ERROR_CODES

```cpp
DRGN_NUM_ERROR_CODES
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:45

Number of defined error codes.

---

{#drgn_type_void}

### DRGN_TYPE_VOID

```cpp
DRGN_TYPE_VOID = 1
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:1

Void type.

---

{#drgn_type_int}

### DRGN_TYPE_INT

```cpp
DRGN_TYPE_INT
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:3

Integer type.

---

{#drgn_type_bool}

### DRGN_TYPE_BOOL

```cpp
DRGN_TYPE_BOOL
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:5

Boolean type.

---

{#drgn_type_float}

### DRGN_TYPE_FLOAT

```cpp
DRGN_TYPE_FLOAT
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:7

Floating-point type.

---

{#drgn_type_struct}

### DRGN_TYPE_STRUCT

```cpp
DRGN_TYPE_STRUCT
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:9

Structure type.

---

{#drgn_type_union}

### DRGN_TYPE_UNION

```cpp
DRGN_TYPE_UNION
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:11

Union type.

---

{#drgn_type_class}

### DRGN_TYPE_CLASS

```cpp
DRGN_TYPE_CLASS
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:13

Class type.

---

{#drgn_type_enum}

### DRGN_TYPE_ENUM

```cpp
DRGN_TYPE_ENUM
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:15

Enumerated type.

---

{#drgn_type_typedef}

### DRGN_TYPE_TYPEDEF

```cpp
DRGN_TYPE_TYPEDEF
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:17

Type definition (a.k.a. alias) type.

---

{#drgn_type_pointer}

### DRGN_TYPE_POINTER

```cpp
DRGN_TYPE_POINTER
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:19

Pointer type.

---

{#drgn_type_array}

### DRGN_TYPE_ARRAY

```cpp
DRGN_TYPE_ARRAY
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:21

Array type.

---

{#drgn_type_function}

### DRGN_TYPE_FUNCTION

```cpp
DRGN_TYPE_FUNCTION
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:23

Function type.

---

{#drgn_qualifier_const}

### DRGN_QUALIFIER_CONST

```cpp
DRGN_QUALIFIER_CONST = (1 << 0)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:1

Constant type.

---

{#drgn_qualifier_volatile}

### DRGN_QUALIFIER_VOLATILE

```cpp
DRGN_QUALIFIER_VOLATILE = (1 << 1)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:3

Volatile type.

---

{#drgn_qualifier_restrict}

### DRGN_QUALIFIER_RESTRICT

```cpp
DRGN_QUALIFIER_RESTRICT = (1 << 2)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:5

Restrict type.

---

{#drgn_qualifier_atomic}

### DRGN_QUALIFIER_ATOMIC

```cpp
DRGN_QUALIFIER_ATOMIC = (1 << 3)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:7

Atomic type.

---

{#drgn_all_qualifiers}

### DRGN_ALL_QUALIFIERS

```cpp
DRGN_ALL_QUALIFIERS = (1 << 4) - 1
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:9

Bitmask of all valid qualifiers.

---

{#drgn_module_main}

### DRGN_MODULE_MAIN

```cpp
DRGN_MODULE_MAIN
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:4

Main module. For userspace programs, this is the executable. For the Linux kernel, this is `vmlinux`.

---

{#drgn_module_shared_library}

### DRGN_MODULE_SHARED_LIBRARY

```cpp
DRGN_MODULE_SHARED_LIBRARY
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:6

Shared library (a.k.a. dynamic library or dynamic shared object).

---

{#drgn_module_vdso}

### DRGN_MODULE_VDSO

```cpp
DRGN_MODULE_VDSO
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:8

Virtual dynamic shared object (vDSO).

---

{#drgn_module_relocatable}

### DRGN_MODULE_RELOCATABLE

```cpp
DRGN_MODULE_RELOCATABLE
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:10

Relocatable object (e.g., Linux kernel loadable module).

---

{#drgn_module_extra}

### DRGN_MODULE_EXTRA

```cpp
DRGN_MODULE_EXTRA
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:12

Extra debugging information.

---

{#drgn_kmod_search_none}

### DRGN_KMOD_SEARCH_NONE

```cpp
DRGN_KMOD_SEARCH_NONE
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:0

---

{#drgn_kmod_search_depmod}

### DRGN_KMOD_SEARCH_DEPMOD

```cpp
DRGN_KMOD_SEARCH_DEPMOD
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:1

---

{#drgn_kmod_search_walk}

### DRGN_KMOD_SEARCH_WALK

```cpp
DRGN_KMOD_SEARCH_WALK
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:2

---

{#drgn_kmod_search_depmod_or_walk}

### DRGN_KMOD_SEARCH_DEPMOD_OR_WALK

```cpp
DRGN_KMOD_SEARCH_DEPMOD_OR_WALK
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:3

---

{#drgn_kmod_search_depmod_and_walk}

### DRGN_KMOD_SEARCH_DEPMOD_AND_WALK

```cpp
DRGN_KMOD_SEARCH_DEPMOD_AND_WALK
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:4

---

{#drgn_object_value}

### DRGN_OBJECT_VALUE

```cpp
DRGN_OBJECT_VALUE
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:1

Constant or temporary computed value.

---

{#drgn_object_reference}

### DRGN_OBJECT_REFERENCE

```cpp
DRGN_OBJECT_REFERENCE
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:3

In program memory.

---

{#drgn_object_absent}

### DRGN_OBJECT_ABSENT

```cpp
DRGN_OBJECT_ABSENT
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:5

Absent (e.g. optimized out).

---

{#drgn_object_encoding_buffer}

### DRGN_OBJECT_ENCODING_BUFFER

```cpp
DRGN_OBJECT_ENCODING_BUFFER
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:6

Memory buffer.

This is used for objects with a structure, union, class, or array type.

---

{#drgn_object_encoding_signed}

### DRGN_OBJECT_ENCODING_SIGNED

```cpp
DRGN_OBJECT_ENCODING_SIGNED
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:13

Signed integer.

This is used for objects with a signed integer or signed enumerated type no larger than 64 bits.

---

{#drgn_object_encoding_unsigned}

### DRGN_OBJECT_ENCODING_UNSIGNED

```cpp
DRGN_OBJECT_ENCODING_UNSIGNED
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:20

Unsigned integer.

This is used for objects with a unsigned integer, boolean, or pointer type no larger than 64 bits.

---

{#drgn_object_encoding_signed_big}

### DRGN_OBJECT_ENCODING_SIGNED_BIG

```cpp
DRGN_OBJECT_ENCODING_SIGNED_BIG
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:27

Big signed integer.

This is used for objects with a signed integer or signed enumerated type larger than 64 bits.

---

{#drgn_object_encoding_unsigned_big}

### DRGN_OBJECT_ENCODING_UNSIGNED_BIG

```cpp
DRGN_OBJECT_ENCODING_UNSIGNED_BIG
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:34

Big unsigned integer.

This is used for objects with a unsigned integer, boolean, or pointer type larger than 64 bits.

---

{#drgn_object_encoding_float}

### DRGN_OBJECT_ENCODING_FLOAT

```cpp
DRGN_OBJECT_ENCODING_FLOAT
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:40

Floating-point value.

This used for objects with a floating-point type.

---

{#drgn_object_encoding_none}

### DRGN_OBJECT_ENCODING_NONE

```cpp
DRGN_OBJECT_ENCODING_NONE = -1
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:46

No value.

This is used for reference objects with a void or function type.

---

{#drgn_object_encoding_incomplete_buffer}

### DRGN_OBJECT_ENCODING_INCOMPLETE_BUFFER

```cpp
DRGN_OBJECT_ENCODING_INCOMPLETE_BUFFER = -2
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:53

Incomplete buffer value.

This is used for reference objects with an incomplete structure, union, class, or array type.

---

{#drgn_object_encoding_incomplete_integer}

### DRGN_OBJECT_ENCODING_INCOMPLETE_INTEGER

```cpp
DRGN_OBJECT_ENCODING_INCOMPLETE_INTEGER = -3
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:60

Incomplete integer value.

This is used for reference objects with an incomplete enumerated types.

---

{#drgn_c_type_void}

### DRGN_C_TYPE_VOID

```cpp
DRGN_C_TYPE_VOID
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:1

---

{#drgn_c_type_char}

### DRGN_C_TYPE_CHAR

```cpp
DRGN_C_TYPE_CHAR
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:2

---

{#drgn_c_type_signed_char}

### DRGN_C_TYPE_SIGNED_CHAR

```cpp
DRGN_C_TYPE_SIGNED_CHAR
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:3

---

{#drgn_c_type_unsigned_char}

### DRGN_C_TYPE_UNSIGNED_CHAR

```cpp
DRGN_C_TYPE_UNSIGNED_CHAR
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:4

---

{#drgn_c_type_short}

### DRGN_C_TYPE_SHORT

```cpp
DRGN_C_TYPE_SHORT
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:5

---

{#drgn_c_type_unsigned_short}

### DRGN_C_TYPE_UNSIGNED_SHORT

```cpp
DRGN_C_TYPE_UNSIGNED_SHORT
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:6

---

{#drgn_c_type_int}

### DRGN_C_TYPE_INT

```cpp
DRGN_C_TYPE_INT
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:7

---

{#drgn_c_type_unsigned_int}

### DRGN_C_TYPE_UNSIGNED_INT

```cpp
DRGN_C_TYPE_UNSIGNED_INT
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:8

---

{#drgn_c_type_long}

### DRGN_C_TYPE_LONG

```cpp
DRGN_C_TYPE_LONG
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:9

---

{#drgn_c_type_unsigned_long}

### DRGN_C_TYPE_UNSIGNED_LONG

```cpp
DRGN_C_TYPE_UNSIGNED_LONG
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:10

---

{#drgn_c_type_long_long}

### DRGN_C_TYPE_LONG_LONG

```cpp
DRGN_C_TYPE_LONG_LONG
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:11

---

{#drgn_c_type_unsigned_long_long}

### DRGN_C_TYPE_UNSIGNED_LONG_LONG

```cpp
DRGN_C_TYPE_UNSIGNED_LONG_LONG
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:12

---

{#drgn_c_type_bool}

### DRGN_C_TYPE_BOOL

```cpp
DRGN_C_TYPE_BOOL
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:13

---

{#drgn_c_type_float}

### DRGN_C_TYPE_FLOAT

```cpp
DRGN_C_TYPE_FLOAT
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:14

---

{#drgn_c_type_double}

### DRGN_C_TYPE_DOUBLE

```cpp
DRGN_C_TYPE_DOUBLE
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:15

---

{#drgn_c_type_long_double}

### DRGN_C_TYPE_LONG_DOUBLE

```cpp
DRGN_C_TYPE_LONG_DOUBLE
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:16

---

{#drgn_c_type_size_t}

### DRGN_C_TYPE_SIZE_T

```cpp
DRGN_C_TYPE_SIZE_T
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:17

---

{#drgn_c_type_ptrdiff_t}

### DRGN_C_TYPE_PTRDIFF_T

```cpp
DRGN_C_TYPE_PTRDIFF_T
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:18

---

{#drgn_primitive_type_num}

### DRGN_PRIMITIVE_TYPE_NUM

```cpp
DRGN_PRIMITIVE_TYPE_NUM
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:19

---

{#drgn_not_primitive_type}

### DRGN_NOT_PRIMITIVE_TYPE

```cpp
DRGN_NOT_PRIMITIVE_TYPE = DRGN_PRIMITIVE_TYPE_NUM
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:20

---

{#drgn_symbol_binding_unknown}

### DRGN_SYMBOL_BINDING_UNKNOWN

```cpp
DRGN_SYMBOL_BINDING_UNKNOWN
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:0

---

{#drgn_symbol_binding_local}

### DRGN_SYMBOL_BINDING_LOCAL

```cpp
DRGN_SYMBOL_BINDING_LOCAL
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:6

---

{#drgn_symbol_binding_global}

### DRGN_SYMBOL_BINDING_GLOBAL

```cpp
DRGN_SYMBOL_BINDING_GLOBAL
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:7

---

{#drgn_symbol_binding_weak}

### DRGN_SYMBOL_BINDING_WEAK

```cpp
DRGN_SYMBOL_BINDING_WEAK
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:8

---

{#drgn_symbol_binding_unique}

### DRGN_SYMBOL_BINDING_UNIQUE

```cpp
DRGN_SYMBOL_BINDING_UNIQUE = 11
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:9

---

{#drgn_symbol_kind_unknown}

### DRGN_SYMBOL_KIND_UNKNOWN

```cpp
DRGN_SYMBOL_KIND_UNKNOWN
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:4

---

{#drgn_symbol_kind_object}

### DRGN_SYMBOL_KIND_OBJECT

```cpp
DRGN_SYMBOL_KIND_OBJECT
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:5

---

{#drgn_symbol_kind_func}

### DRGN_SYMBOL_KIND_FUNC

```cpp
DRGN_SYMBOL_KIND_FUNC
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:6

---

{#drgn_symbol_kind_section}

### DRGN_SYMBOL_KIND_SECTION

```cpp
DRGN_SYMBOL_KIND_SECTION
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:7

---

{#drgn_symbol_kind_file}

### DRGN_SYMBOL_KIND_FILE

```cpp
DRGN_SYMBOL_KIND_FILE
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:8

---

{#drgn_symbol_kind_common}

### DRGN_SYMBOL_KIND_COMMON

```cpp
DRGN_SYMBOL_KIND_COMMON
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:9

---

{#drgn_symbol_kind_tls}

### DRGN_SYMBOL_KIND_TLS

```cpp
DRGN_SYMBOL_KIND_TLS
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:10

---

{#drgn_symbol_kind_ifunc}

### DRGN_SYMBOL_KIND_IFUNC

```cpp
DRGN_SYMBOL_KIND_IFUNC = 10
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:11

---

{#drgn_lifetime_static}

### DRGN_LIFETIME_STATIC

```cpp
DRGN_LIFETIME_STATIC
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:4

DRGN_LIFETIME_STATIC: the object is guaranteed to outlive the [drgn_program](drgn_program.md#drgn_program) itself. drgn will not free or copy the object.

---

{#drgn_lifetime_external}

### DRGN_LIFETIME_EXTERNAL

```cpp
DRGN_LIFETIME_EXTERNAL
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:12

DRGN_LIFETIME_EXTERNAL: the object is externally managed. It will live as long as the object it is associated with, but may be freed after. drgn will never free the object. If drgn must copy a data structure, the object will be duplicated, and drgn will own the new object.

---

{#drgn_lifetime_owned}

### DRGN_LIFETIME_OWNED

```cpp
DRGN_LIFETIME_OWNED
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:18

DRGN_LIFETIME_OWNED: the object lifetime is managed by drgn. It should be freed when the containing object is freed. If the containing object is copied, it must also be copied.

---

{#baddataerror}

### BadDataError

```cpp
PyObject * BadDataError
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/main.c:33

---

{#missingdebuginfoerror}

### MissingDebugInfoError

```cpp
PyObject * MissingDebugInfoError
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/main.c:34

---

{#nodefaultprogramerror}

### NoDefaultProgramError

`static`

```cpp
PyObject * NoDefaultProgramError
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/main.c:35

---

{#objectabsenterror}

### ObjectAbsentError

```cpp
PyObject * ObjectAbsentError
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/main.c:36

---

{#outofboundserror}

### OutOfBoundsError

```cpp
PyObject * OutOfBoundsError
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/main.c:37

---

{#unsupportedoperation}

### UnsupportedOperation

```cpp
PyObject * UnsupportedOperation
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/main.c:38

---

{#default_prog}

### default_prog

`static`

```cpp
_Thread_local Program * default_prog
```

Type: _Thread_local [`Program`](Program.md#program) *

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/main.c:40

---

{#drgn_methods}

### drgn_methods

`static`

```cpp
PyMethodDef drgn_methods[]
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/main.c:226

---

{#drgnmodule}

### drgnmodule

`static`

```cpp
struct PyModuleDef drgnmodule = {
	PyModuleDef_HEAD_INIT,
	"_drgn",
	drgn_DOC,
	-1,
	drgn_methods,
}
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/main.c:299

---

{#drgn_primitive_type_spellings}

### drgn_primitive_type_spellings

`static`

```cpp
const char *const  *const drgn_primitive_type_spellings[DRGN_PRIMITIVE_TYPE_NUM]
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/type.c:58

Names of primitive types.

In some languages, like C, the same primitive type can be spelled in multiple ways. For example, "int" can also be spelled "signed int" or "int signed".

This maps each [drgn_primitive_type](drgn_primitive_type.md#drgn_primitive_type) to a `NULL`-terminated array of the different ways to spell that type. The spelling at index zero is the preferred spelling.

---

{#drgn_primitive_type_kind}

### drgn_primitive_type_kind

`static`

```cpp
enum drgn_type_kind drgn_primitive_type_kind[DRGN_PRIMITIVE_TYPE_NUM+1]
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/type.c:130

Mapping from a [drgn_type_primitive](#group__Types_1ga10e2723b7cb2e69497a9bb9c7be67038) to the corresponding [drgn_type_kind](drgn_type_kind.md#drgn_type_kind).

---

{#qsort_arg_compar}

### qsort_arg_compar

`static`

```cpp
_Thread_local int(* qsort_arg_compar)(const void *, const void *, void *)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/util.c:5

---

{#qsort_arg_arg}

### qsort_arg_arg

`static`

```cpp
_Thread_local void * qsort_arg_arg
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/util.c:6

---

{#absencereason_class}

### AbsenceReason_class

```cpp
PyObject * AbsenceReason_class
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:347

---

{#architecture_class}

### Architecture_class

```cpp
PyObject * Architecture_class
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:348

---

{#findobjectflags_class}

### FindObjectFlags_class

```cpp
PyObject * FindObjectFlags_class
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:349

---

{#kmodsearchmethod_class}

### KmodSearchMethod_class

```cpp
PyObject * KmodSearchMethod_class
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:350

---

{#modulefilestatus_class}

### ModuleFileStatus_class

```cpp
PyObject * ModuleFileStatus_class
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:351

---

{#modulesectionaddresses_class}

### ModuleSectionAddresses_class

```cpp
PyObject * ModuleSectionAddresses_class
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:352

---

{#platformflags_class}

### PlatformFlags_class

```cpp
PyObject * PlatformFlags_class
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:353

---

{#primitivetype_class}

### PrimitiveType_class

```cpp
PyObject * PrimitiveType_class
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:354

---

{#programflags_class}

### ProgramFlags_class

```cpp
PyObject * ProgramFlags_class
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:355

---

{#qualifiers_class}

### Qualifiers_class

```cpp
PyObject * Qualifiers_class
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:356

---

{#supplementaryfilekind_class}

### SupplementaryFileKind_class

```cpp
PyObject * SupplementaryFileKind_class
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:357

---

{#symbolbinding_class}

### SymbolBinding_class

```cpp
PyObject * SymbolBinding_class
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:358

---

{#symbolkind_class}

### SymbolKind_class

```cpp
PyObject * SymbolKind_class
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:359

---

{#typekind_class}

### TypeKind_class

```cpp
PyObject * TypeKind_class
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:360

---

{#debuginfooptions_type}

### DebugInfoOptions_type

```cpp
PyTypeObject DebugInfoOptions_type
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:361

---

{#drgnobject_type}

### DrgnObject_type

```cpp
PyTypeObject DrgnObject_type
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:362

---

{#drgntype_type}

### DrgnType_type

```cpp
PyTypeObject DrgnType_type
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:363

---

{#extramodule_type}

### ExtraModule_type

```cpp
PyTypeObject ExtraModule_type
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:364

---

{#faulterror_type}

### FaultError_type

```cpp
PyTypeObject FaultError_type
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:365

---

{#language_type}

### Language_type

```cpp
PyTypeObject Language_type
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:366

---

{#mainmodule_type}

### MainModule_type

```cpp
PyTypeObject MainModule_type
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:367

---

{#memorysearchiteratorwithbytes_type}

### MemorySearchIteratorWithBytes_type

```cpp
PyTypeObject MemorySearchIteratorWithBytes_type
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:368

---

{#memorysearchiteratorwithint_type}

### MemorySearchIteratorWithInt_type

```cpp
PyTypeObject MemorySearchIteratorWithInt_type
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:369

---

{#memorysearchiteratorwithstr_type}

### MemorySearchIteratorWithStr_type

```cpp
PyTypeObject MemorySearchIteratorWithStr_type
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:370

---

{#memorysearchiterator_type}

### MemorySearchIterator_type

```cpp
PyTypeObject MemorySearchIterator_type
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:371

---

{#moduleiteratorwithnew_type}

### ModuleIteratorWithNew_type

```cpp
PyTypeObject ModuleIteratorWithNew_type
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:372

---

{#moduleiterator_type}

### ModuleIterator_type

```cpp
PyTypeObject ModuleIterator_type
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:373

---

{#modulesectionaddressesiterator_type}

### ModuleSectionAddressesIterator_type

```cpp
PyTypeObject ModuleSectionAddressesIterator_type
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:374

---

{#module_type-1}

### Module_type

```cpp
PyTypeObject Module_type
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:375

---

{#objectiterator_type}

### ObjectIterator_type

```cpp
PyTypeObject ObjectIterator_type
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:376

---

{#objectnotfounderror_type}

### ObjectNotFoundError_type

```cpp
PyTypeObject ObjectNotFoundError_type
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:377

---

{#platform_type}

### Platform_type

```cpp
PyTypeObject Platform_type
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:378

---

{#program_type}

### Program_type

```cpp
PyTypeObject Program_type
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:379

---

{#register_type}

### Register_type

```cpp
PyTypeObject Register_type
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:380

---

{#relocatablemodule_type}

### RelocatableModule_type

```cpp
PyTypeObject RelocatableModule_type
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:381

---

{#sharedlibrarymodule_type}

### SharedLibraryModule_type

```cpp
PyTypeObject SharedLibraryModule_type
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:382

---

{#sourcelocationlist_type}

### SourceLocationList_type

```cpp
PyTypeObject SourceLocationList_type
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:383

---

{#sourcelocation_type}

### SourceLocation_type

```cpp
PyObject * SourceLocation_type
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:384

---

{#stackframe_type}

### StackFrame_type

```cpp
PyTypeObject StackFrame_type
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:385

---

{#stacktrace_type}

### StackTrace_type

```cpp
PyTypeObject StackTrace_type
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:386

---

{#symbolindex_type}

### SymbolIndex_type

```cpp
PyTypeObject SymbolIndex_type
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:387

---

{#symbol_type}

### Symbol_type

```cpp
PyTypeObject Symbol_type
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:388

---

{#threaditerator_type}

### ThreadIterator_type

```cpp
PyTypeObject ThreadIterator_type
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:389

---

{#thread_type}

### Thread_type

```cpp
PyTypeObject Thread_type
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:390

---

{#typeenumerator_type}

### TypeEnumerator_type

```cpp
PyTypeObject TypeEnumerator_type
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:391

---

{#typekindsetiterator_type}

### TypeKindSetIterator_type

```cpp
PyTypeObject TypeKindSetIterator_type
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:392

---

{#typekindset_type}

### TypeKindSet_type

```cpp
PyTypeObject TypeKindSet_type
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:393

---

{#typemember_type}

### TypeMember_type

```cpp
PyTypeObject TypeMember_type
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:394

---

{#typeparameter_type}

### TypeParameter_type

```cpp
PyTypeObject TypeParameter_type
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:395

---

{#typetemplateparameter_type}

### TypeTemplateParameter_type

```cpp
PyTypeObject TypeTemplateParameter_type
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:396

---

{#vdsomodule_type}

### VdsoModule_type

```cpp
PyTypeObject VdsoModule_type
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:397

---

{#baddataerror-1}

### BadDataError

```cpp
PyObject * BadDataError
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:398

---

{#missingdebuginfoerror-1}

### MissingDebugInfoError

```cpp
PyObject * MissingDebugInfoError
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:399

---

{#objectabsenterror-1}

### ObjectAbsentError

```cpp
PyObject * ObjectAbsentError
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:400

---

{#outofboundserror-1}

### OutOfBoundsError

```cpp
PyObject * OutOfBoundsError
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:401

---

{#unsupportedoperation-1}

### UnsupportedOperation

```cpp
PyObject * UnsupportedOperation
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/drgnpy.h:402

---

{#wantedsupplementaryfile_class}

### WantedSupplementaryFile_class

`static`

```cpp
PyObject * WantedSupplementaryFile_class
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/module.c:8

---

{#module_methods}

### Module_methods

`static`

```cpp
PyMethodDef Module_methods[]
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/module.c:494

---

{#module_getset}

### Module_getset

`static`

```cpp
PyGetSetDef Module_getset[]
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/module.c:507

---

{#module_type-2}

### Module_type

```cpp
PyTypeObject Module_type = {
	PyVarObject_HEAD_INIT(NULL, 0)
	.tp_name = "_drgn.Module",
	.tp_basicsize = sizeof(Module),
	.tp_dealloc = (destructor)Module_dealloc,
	.tp_repr = (reprfunc)Module_repr,
	.tp_flags = Py_TPFLAGS_DEFAULT | Py_TPFLAGS_HAVE_GC | Py_TPFLAGS_BASETYPE,
	.tp_doc = drgn_Module_DOC,
	.tp_traverse = (traverseproc)Module_traverse,
	.tp_richcompare = (richcmpfunc)Module_richcompare,
	.tp_hash = (hashfunc)Module_hash,
	.tp_methods = Module_methods,
	.tp_getset = Module_getset,
}
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/module.c:541

---

{#mainmodule_type-1}

### MainModule_type

```cpp
PyTypeObject MainModule_type = {
	PyVarObject_HEAD_INIT(NULL, 0)
	.tp_name = "_drgn.MainModule",
	.tp_flags = Py_TPFLAGS_DEFAULT,
	.tp_doc = drgn_MainModule_DOC,
	.tp_base = &Module_type,
}
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/module.c:556

---

{#sharedlibrarymodule_getset}

### SharedLibraryModule_getset

`static`

```cpp
PyGetSetDef SharedLibraryModule_getset[]
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/module.c:569

---

{#sharedlibrarymodule_type-1}

### SharedLibraryModule_type

```cpp
PyTypeObject SharedLibraryModule_type = {
	PyVarObject_HEAD_INIT(NULL, 0)
	.tp_name = "_drgn.SharedLibraryModule",
	.tp_flags = Py_TPFLAGS_DEFAULT,
	.tp_doc = drgn_SharedLibraryModule_DOC,
	.tp_getset = SharedLibraryModule_getset,
	.tp_base = &Module_type,
}
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/module.c:575

---

{#vdsomodule_getset}

### VdsoModule_getset

`static`

```cpp
PyGetSetDef VdsoModule_getset[]
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/module.c:584

---

{#vdsomodule_type-1}

### VdsoModule_type

```cpp
PyTypeObject VdsoModule_type = {
	PyVarObject_HEAD_INIT(NULL, 0)
	.tp_name = "_drgn.VdsoModule",
	.tp_flags = Py_TPFLAGS_DEFAULT,
	.tp_doc = drgn_VdsoModule_DOC,
	.tp_getset = VdsoModule_getset,
	.tp_base = &Module_type,
}
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/module.c:590

---

{#relocatablemodule_getset}

### RelocatableModule_getset

`static`

```cpp
PyGetSetDef RelocatableModule_getset[]
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/module.c:605

---

{#relocatablemodule_type-1}

### RelocatableModule_type

```cpp
PyTypeObject RelocatableModule_type = {
	PyVarObject_HEAD_INIT(NULL, 0)
	.tp_name = "_drgn.RelocatableModule",
	.tp_flags = Py_TPFLAGS_DEFAULT,
	.tp_doc = drgn_RelocatableModule_DOC,
	.tp_getset = RelocatableModule_getset,
	.tp_base = &Module_type,
}
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/module.c:613

---

{#extramodule_getset}

### ExtraModule_getset

`static`

```cpp
PyGetSetDef ExtraModule_getset[]
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/module.c:622

---

{#extramodule_type-1}

### ExtraModule_type

```cpp
PyTypeObject ExtraModule_type = {
	PyVarObject_HEAD_INIT(NULL, 0)
	.tp_name = "_drgn.ExtraModule",
	.tp_flags = Py_TPFLAGS_DEFAULT,
	.tp_doc = drgn_ExtraModule_DOC,
	.tp_getset = ExtraModule_getset,
	.tp_base = &Module_type,
}
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/module.c:627

---

{#moduleiterator_type-1}

### ModuleIterator_type

```cpp
PyTypeObject ModuleIterator_type = {
	PyVarObject_HEAD_INIT(NULL, 0)
	.tp_name = "_drgn._ModuleIterator",
	.tp_basicsize = sizeof(ModuleIterator),
	.tp_dealloc = (destructor)ModuleIterator_dealloc,
	.tp_flags = Py_TPFLAGS_DEFAULT | Py_TPFLAGS_HAVE_GC,
	.tp_traverse = (traverseproc)ModuleIterator_traverse,
	.tp_iter = PyObject_SelfIter,
	.tp_iternext = (iternextfunc)ModuleIterator_next,
}
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/module.c:685

---

{#moduleiteratorwithnew_type-1}

### ModuleIteratorWithNew_type

```cpp
PyTypeObject ModuleIteratorWithNew_type = {
	PyVarObject_HEAD_INIT(NULL, 0)
	.tp_name = "_drgn._ModuleIteratorWithNew",
	.tp_basicsize = sizeof(ModuleIterator),
	.tp_dealloc = (destructor)ModuleIterator_dealloc,
	.tp_flags = Py_TPFLAGS_DEFAULT | Py_TPFLAGS_HAVE_GC,
	.tp_traverse = (traverseproc)ModuleIterator_traverse,
	.tp_iter = PyObject_SelfIter,
	.tp_iternext = (iternextfunc)ModuleIteratorWithNew_next,
}
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/module.c:696

---

{#drgn_float_size_unsupported}

### drgn_float_size_unsupported

`static`

```cpp
struct drgn_error drgn_float_size_unsupported =
	DRGN_ERROR_INIT(DRGN_ERROR_NOT_IMPLEMENTED,
			"float values which are not 32 or 64 bits are not yet supported")
```

Type: struct [`drgn_error`](drgn_error.md#drgn_error)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/object.c:298

---

{#drgn_integer_too_big}

### drgn_integer_too_big

`static`

```cpp
struct drgn_error drgn_integer_too_big =
	DRGN_ERROR_INIT(DRGN_ERROR_OVERFLOW, "integer type is too big")
```

Type: struct [`drgn_error`](drgn_error.md#drgn_error)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/object.c:997

---

{#drgn_zero_division}

### drgn_zero_division

`static`

```cpp
struct drgn_error drgn_zero_division =
	DRGN_ERROR_INIT(DRGN_ERROR_ZERO_DIVISION, "division by zero")
```

Type: struct [`drgn_error`](drgn_error.md#drgn_error)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/object.c:2289

---

{#thread_getset}

### Thread_getset

`static`

```cpp
PyGetSetDef Thread_getset[]
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/thread.c:92

---

{#thread_methods}

### Thread_methods

`static`

```cpp
PyMethodDef Thread_methods[]
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/thread.c:99

---

{#thread_type-1}

### Thread_type

```cpp
PyTypeObject Thread_type = {
	PyVarObject_HEAD_INIT(NULL, 0)
	.tp_name = "_drgn.Thread",
	.tp_basicsize = sizeof(Thread),
	.tp_dealloc = (destructor)Thread_dealloc,
	.tp_flags = Py_TPFLAGS_DEFAULT | Py_TPFLAGS_HAVE_GC,
	.tp_doc = drgn_Thread_DOC,
	.tp_traverse = (traverseproc)Thread_traverse,
	.tp_getset = Thread_getset,
	.tp_methods = Thread_methods,
}
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/thread.c:105

---

{#threaditerator_type-1}

### ThreadIterator_type

```cpp
PyTypeObject ThreadIterator_type = {
	PyVarObject_HEAD_INIT(NULL, 0)
	.tp_name = "_drgn._ThreadIterator",
	.tp_basicsize = sizeof(ThreadIterator),
	.tp_dealloc = (destructor)ThreadIterator_dealloc,
	.tp_flags = Py_TPFLAGS_DEFAULT | Py_TPFLAGS_HAVE_GC,
	.tp_traverse = (traverseproc)ThreadIterator_traverse,
	.tp_iter = PyObject_SelfIter,
	.tp_iternext = (iternextfunc)ThreadIterator_next,
}
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/thread.c:142

---

{#len-5}

### len

```cpp
size_t len {
	const uint8_t *s = data
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/cityhash.h:90

---

{#h}

### h

```cpp
uint32_t h = len
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/cityhash.h:100

---

{#g}

### g

```cpp
uint32_t g = cityhash_c1 * len
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/cityhash.h:100

---

{#f}

### f

```cpp
uint32_t f = g
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/cityhash.h:100

---

{#a0}

### a0

```cpp
uint32_t a0 = cityhash_rotate32(cityhash_fetch32(s + len - 4) * cityhash_c1, 17) * cityhash_c2
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/cityhash.h:101

---

{#a1}

### a1

```cpp
uint32_t a1 = cityhash_rotate32(cityhash_fetch32(s + len - 8) * cityhash_c1, 17) * cityhash_c2
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/cityhash.h:102

---

{#a2}

### a2

```cpp
uint32_t a2 = cityhash_rotate32(cityhash_fetch32(s + len - 16) * cityhash_c1, 17) * cityhash_c2
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/cityhash.h:103

---

{#a3}

### a3

```cpp
uint32_t a3 = cityhash_rotate32(cityhash_fetch32(s + len - 12) * cityhash_c1, 17) * cityhash_c2
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/cityhash.h:104

---

{#a4}

### a4

```cpp
uint32_t a4 = cityhash_rotate32(cityhash_fetch32(s + len - 20) * cityhash_c1, 17) * cityhash_c2
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/cityhash.h:105

---

{#iters}

### iters

```cpp
size_t iters = (len - 1) / 20
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/cityhash.h:121

---

{#do}

### do

```cpp
do {
		a0 = cityhash_rotate32(cityhash_fetch32(s) * cityhash_c1, 17) * cityhash_c2
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/cityhash.h:122

---

{#tmp}

### tmp

```cpp
uint32_t tmp = f
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/cityhash.h:145

---

{#s}

### s

```cpp
s = 20
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/cityhash.h:150

---

{#x-9}

### x

```cpp
uint64_t x = cityhash_fetch64(s + len - 40)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/cityhash.h:294

---

{#y}

### y

```cpp
uint64_t y = (cityhash_fetch64(s + len - 16) +
		      cityhash_fetch64(s + len - 56))
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/cityhash.h:295

---

{#z}

### z

```cpp
uint64_t z = cityhash_128_to_64(cityhash_fetch64(s + len - 48) + len,
					cityhash_fetch64(s + len - 24))
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/cityhash.h:297

---

{#v}

### v

```cpp
struct cityhash_pair v =
		cityhash_weak_len_32_with_seeds(s + len - 64, len, z)
```

Type: struct [`cityhash_pair`](cityhash_pair.md#cityhash_pair)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/cityhash.h:299

---

{#w}

### w

```cpp
struct cityhash_pair w =
		cityhash_weak_len_32_with_seeds(s + len - 32, y + cityhash_k1,
						x)
```

Type: struct [`cityhash_pair`](cityhash_pair.md#cityhash_pair)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/cityhash.h:301

---

{#default_dwarf_cfi_row_arm}

### default_dwarf_cfi_row_arm

`static`

```cpp
const struct drgn_cfi_row default_dwarf_cfi_row_arm = DRGN_CFI_ROW(
	
	
	[DRGN_REGISTER_NUMBER(r13)] = { DRGN_CFI_RULE_CFA_PLUS_OFFSET },
	
	
	DRGN_CFI_SAME_VALUE_INIT(DRGN_REGISTER_NUMBER(r4)),
	DRGN_CFI_SAME_VALUE_INIT(DRGN_REGISTER_NUMBER(r5)),
	DRGN_CFI_SAME_VALUE_INIT(DRGN_REGISTER_NUMBER(r6)),
	DRGN_CFI_SAME_VALUE_INIT(DRGN_REGISTER_NUMBER(r7)),
	DRGN_CFI_SAME_VALUE_INIT(DRGN_REGISTER_NUMBER(r8)),
	DRGN_CFI_SAME_VALUE_INIT(DRGN_REGISTER_NUMBER(r9)),
	DRGN_CFI_SAME_VALUE_INIT(DRGN_REGISTER_NUMBER(r10)),
	DRGN_CFI_SAME_VALUE_INIT(DRGN_REGISTER_NUMBER(r11)),
	DRGN_CFI_SAME_VALUE_INIT(DRGN_REGISTER_NUMBER(r14)),
)
```

Type: const struct [`drgn_cfi_row`](drgn_cfi_row.md#drgn_cfi_row-1)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/arch_arm.c:23

---

{#default_dwarf_cfi_row_ppc64}

### default_dwarf_cfi_row_ppc64

`static`

```cpp
const struct drgn_cfi_row default_dwarf_cfi_row_ppc64 = DRGN_CFI_ROW(
	DRGN_CFI_SAME_VALUE_INIT(DRGN_REGISTER_NUMBER(lr)),
	[DRGN_REGISTER_NUMBER(r1)] = { DRGN_CFI_RULE_CFA_PLUS_OFFSET },
	DRGN_CFI_SAME_VALUE_INIT(DRGN_REGISTER_NUMBER(r14)),
	DRGN_CFI_SAME_VALUE_INIT(DRGN_REGISTER_NUMBER(r15)),
	DRGN_CFI_SAME_VALUE_INIT(DRGN_REGISTER_NUMBER(r16)),
	DRGN_CFI_SAME_VALUE_INIT(DRGN_REGISTER_NUMBER(r17)),
	DRGN_CFI_SAME_VALUE_INIT(DRGN_REGISTER_NUMBER(r18)),
	DRGN_CFI_SAME_VALUE_INIT(DRGN_REGISTER_NUMBER(r19)),
	DRGN_CFI_SAME_VALUE_INIT(DRGN_REGISTER_NUMBER(r20)),
	DRGN_CFI_SAME_VALUE_INIT(DRGN_REGISTER_NUMBER(r21)),
	DRGN_CFI_SAME_VALUE_INIT(DRGN_REGISTER_NUMBER(r22)),
	DRGN_CFI_SAME_VALUE_INIT(DRGN_REGISTER_NUMBER(r23)),
	DRGN_CFI_SAME_VALUE_INIT(DRGN_REGISTER_NUMBER(r24)),
	DRGN_CFI_SAME_VALUE_INIT(DRGN_REGISTER_NUMBER(r25)),
	DRGN_CFI_SAME_VALUE_INIT(DRGN_REGISTER_NUMBER(r26)),
	DRGN_CFI_SAME_VALUE_INIT(DRGN_REGISTER_NUMBER(r27)),
	DRGN_CFI_SAME_VALUE_INIT(DRGN_REGISTER_NUMBER(r28)),
	DRGN_CFI_SAME_VALUE_INIT(DRGN_REGISTER_NUMBER(r29)),
	DRGN_CFI_SAME_VALUE_INIT(DRGN_REGISTER_NUMBER(r30)),
	DRGN_CFI_SAME_VALUE_INIT(DRGN_REGISTER_NUMBER(r31)),
	DRGN_CFI_SAME_VALUE_INIT(DRGN_REGISTER_NUMBER(cr2)),
	DRGN_CFI_SAME_VALUE_INIT(DRGN_REGISTER_NUMBER(cr3)),
	DRGN_CFI_SAME_VALUE_INIT(DRGN_REGISTER_NUMBER(cr4)),
)
```

Type: const struct [`drgn_cfi_row`](drgn_cfi_row.md#drgn_cfi_row-1)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/arch_ppc64.c:19

---

{#pt_levels_radix_4k}

### pt_levels_radix_4k

`static`

```cpp
const struct pt_level pt_levels_radix_4k[]
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/arch_ppc64.c:300

---

{#pt_levels_radix_64k}

### pt_levels_radix_64k

`static`

```cpp
const struct pt_level pt_levels_radix_64k[]
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/arch_ppc64.c:307

---

{#drgn_invalid_rel}

### drgn_invalid_rel

`static`

```cpp
struct drgn_error drgn_invalid_rel =
	DRGN_ERROR_INIT(DRGN_ERROR_BAD_DATA,
			"invalid relocation type for SHT_REL")
```

Type: struct [`drgn_error`](drgn_error.md#drgn_error)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/arch_riscv.c:16

---

{#default_dwarf_cfi_row_s390x}

### default_dwarf_cfi_row_s390x

`static`

```cpp
const struct drgn_cfi_row default_dwarf_cfi_row_s390x = DRGN_CFI_ROW(
	
	
	DRGN_CFI_SAME_VALUE_INIT(DRGN_REGISTER_NUMBER(r6)),
	DRGN_CFI_SAME_VALUE_INIT(DRGN_REGISTER_NUMBER(r7)),
	DRGN_CFI_SAME_VALUE_INIT(DRGN_REGISTER_NUMBER(r8)),
	DRGN_CFI_SAME_VALUE_INIT(DRGN_REGISTER_NUMBER(r9)),
	DRGN_CFI_SAME_VALUE_INIT(DRGN_REGISTER_NUMBER(r10)),
	DRGN_CFI_SAME_VALUE_INIT(DRGN_REGISTER_NUMBER(r11)),
	DRGN_CFI_SAME_VALUE_INIT(DRGN_REGISTER_NUMBER(r12)),
	DRGN_CFI_SAME_VALUE_INIT(DRGN_REGISTER_NUMBER(r13)),
	
	
	DRGN_CFI_SAME_VALUE_INIT(DRGN_REGISTER_NUMBER(r14)),
	DRGN_CFI_SAME_VALUE_INIT(DRGN_REGISTER_NUMBER(r15)),
)
```

Type: const struct [`drgn_cfi_row`](drgn_cfi_row.md#drgn_cfi_row-1)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/arch_s390x.c:17

---

{#dat_levels}

### dat_levels

`static`

```cpp
const struct dat_level dat_levels[]
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/arch_s390x.c:255

---

{#max_memory_read_for_debug_info}

### MAX_MEMORY_READ_FOR_DEBUG_INFO

`static`

```cpp
const uint64_t MAX_MEMORY_READ_FOR_DEBUG_INFO = UINT64_C(1048576)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.c:1766

---

{#max_link_map_list_iterations}

### MAX_LINK_MAP_LIST_ITERATIONS

`static`

```cpp
const int MAX_LINK_MAP_LIST_ITERATIONS = 10000
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.c:3488

---

{#drgn_module_file_mask_loaded}

### DRGN_MODULE_FILE_MASK_LOADED

```cpp
DRGN_MODULE_FILE_MASK_LOADED = 1 << 0
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.h:0

---

{#drgn_module_file_mask_debug}

### DRGN_MODULE_FILE_MASK_DEBUG

```cpp
DRGN_MODULE_FILE_MASK_DEBUG = 1 << 1
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.h:1

---

{#max_imported_unit_depth}

### MAX_IMPORTED_UNIT_DEPTH

`static`

```cpp
const size_t MAX_IMPORTED_UNIT_DEPTH = 128
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:1212

---

{#max_dwarf_expr_ops}

### MAX_DWARF_EXPR_OPS

`static`

```cpp
const int MAX_DWARF_EXPR_OPS = 10000
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:3785

Arbitrary limit for number of operations to execute in a DWARF expression to avoid infinite loops.

---

{#drgn_unknown_dwarf_opcode}

### drgn_unknown_dwarf_opcode

`static`

```cpp
struct drgn_error drgn_unknown_dwarf_opcode =
	DRGN_ERROR_INIT(DRGN_ERROR_NOT_IMPLEMENTED,
			"unknown DWARF expression opcode")
```

Type: struct [`drgn_error`](drgn_error.md#drgn_error)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:3845

---

{#drgn_line_wrap}

### drgn_line_wrap

`static`

```cpp
struct drgn_error drgn_line_wrap =
	DRGN_ERROR_INIT(DRGN_ERROR_STOP, "needs line wrap")
```

Type: struct [`drgn_error`](drgn_error.md#drgn_error)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/language_c.c:875

---

{#specifier_spelling}

### specifier_spelling

`static`

```cpp
const char * specifier_spelling[NUM_SPECIFIER_STATES]
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/language_c.c:1962

---

{#qualifier_from_token}

### qualifier_from_token

`static`

```cpp
enum drgn_qualifiers qualifier_from_token[MAX_QUALIFIER_TOKEN+1]
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/language_c.c:1996

---

{#specifier_transition}

### specifier_transition

`static`

```cpp
enum c_type_specifier specifier_transition[NUM_SPECIFIER_STATES][MAX_SPECIFIER_TOKEN+1]
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/language_c.c:2004

---

{#specifier_kind}

### specifier_kind

`static`

```cpp
enum drgn_primitive_type specifier_kind[NUM_SPECIFIER_STATES]
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/language_c.c:2118

---

{#c_integer_conversion_rank}

### c_integer_conversion_rank

`static`

```cpp
const int c_integer_conversion_rank[]
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/language_c.c:2910

---

{#drgnpy_lazy_object_evaluated-1}

### drgnpy_lazy_object_evaluated

`static`

```cpp
const union drgn_lazy_object drgnpy_lazy_object_evaluated
```

Type: const union [`drgn_lazy_object`](drgn_lazy_object.md#drgn_lazy_object)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/type.c:14

---

{#drgnpy_lazy_object_callable-1}

### drgnpy_lazy_object_callable

`static`

```cpp
const union drgn_lazy_object drgnpy_lazy_object_callable
```

Type: const union [`drgn_lazy_object`](drgn_lazy_object.md#drgn_lazy_object)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/type.c:16

---

{#drgntype_getset}

### DrgnType_getset

`static`

```cpp
PyGetSetDef DrgnType_getset[]
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/type.c:423

---

{#drgntype_methods}

### DrgnType_methods

`static`

```cpp
PyMethodDef DrgnType_methods[]
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/type.c:722

---

{#drgntype_type-1}

### DrgnType_type

```cpp
PyTypeObject DrgnType_type = {
	PyVarObject_HEAD_INIT(NULL, 0)
	.tp_name = "_drgn.Type",
	.tp_basicsize = sizeof(DrgnType),
	.tp_dealloc = (destructor)DrgnType_dealloc,
	.tp_repr = (reprfunc)DrgnType_repr,
	.tp_str = (reprfunc)DrgnType_str,
	.tp_flags = Py_TPFLAGS_DEFAULT | Py_TPFLAGS_HAVE_GC,
	.tp_doc = drgn_Type_DOC,
	.tp_traverse = (traverseproc)DrgnType_traverse,
	.tp_clear = (inquiry)DrgnType_clear,
	.tp_methods = DrgnType_methods,
	.tp_getset = DrgnType_getset,
}
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/type.c:746

---

{#typeenumerator_as_sequence}

### TypeEnumerator_as_sequence

`static`

```cpp
PySequenceMethods TypeEnumerator_as_sequence = {
	.sq_length = TypeEnumerator_length,
	.sq_item = (ssizeargfunc)TypeEnumerator_item,
}
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/type.c:836

---

{#typeenumerator_members}

### TypeEnumerator_members

`static`

```cpp
PyMemberDef TypeEnumerator_members[]
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/type.c:841

---

{#typeenumerator_type-1}

### TypeEnumerator_type

```cpp
PyTypeObject TypeEnumerator_type = {
	PyVarObject_HEAD_INIT(NULL, 0)
	.tp_name = "_drgn.TypeEnumerator",
	.tp_basicsize = sizeof(TypeEnumerator),
	.tp_dealloc = (destructor)TypeEnumerator_dealloc,
	.tp_repr = (reprfunc)TypeEnumerator_repr,
	.tp_as_sequence = &TypeEnumerator_as_sequence,
	.tp_flags = Py_TPFLAGS_DEFAULT | Py_TPFLAGS_HAVE_GC,
	.tp_traverse = (traverseproc)LazyObject_traverse,
	.tp_doc = drgn_TypeEnumerator_DOC,
	.tp_richcompare = (richcmpfunc)TypeEnumerator_richcompare,
	.tp_members = TypeEnumerator_members,
	.tp_new = (newfunc)TypeEnumerator_new,
}
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/type.c:855

---

{#typemember_members}

### TypeMember_members

`static`

```cpp
PyMemberDef TypeMember_members[]
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/type.c:1123

---

{#typemember_getset}

### TypeMember_getset

`static`

```cpp
PyGetSetDef TypeMember_getset[]
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/type.c:1131

---

{#typemember_type-1}

### TypeMember_type

```cpp
PyTypeObject TypeMember_type = {
	PyVarObject_HEAD_INIT(NULL, 0)
	.tp_name = "_drgn.TypeMember",
	.tp_basicsize = sizeof(TypeMember),
	.tp_dealloc = (destructor)TypeMember_dealloc,
	.tp_repr = (reprfunc)TypeMember_repr,
	.tp_flags = Py_TPFLAGS_DEFAULT | Py_TPFLAGS_HAVE_GC,
	.tp_traverse = (traverseproc)LazyObject_traverse,
	.tp_doc = drgn_TypeMember_DOC,
	.tp_members = TypeMember_members,
	.tp_getset = TypeMember_getset,
	.tp_new = (newfunc)TypeMember_new,
}
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/type.c:1143

---

{#typeparameter_members}

### TypeParameter_members

`static`

```cpp
PyMemberDef TypeParameter_members[]
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/type.c:1214

---

{#typeparameter_getset}

### TypeParameter_getset

`static`

```cpp
PyGetSetDef TypeParameter_getset[]
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/type.c:1220

---

{#typeparameter_type-1}

### TypeParameter_type

```cpp
PyTypeObject TypeParameter_type = {
	PyVarObject_HEAD_INIT(NULL, 0)
	.tp_name = "_drgn.TypeParameter",
	.tp_basicsize = sizeof(TypeParameter),
	.tp_dealloc = (destructor)TypeParameter_dealloc,
	.tp_repr = (reprfunc)TypeParameter_repr,
	.tp_flags = Py_TPFLAGS_DEFAULT | Py_TPFLAGS_HAVE_GC,
	.tp_traverse = (traverseproc)LazyObject_traverse,
	.tp_doc = drgn_TypeParameter_DOC,
	.tp_members = TypeParameter_members,
	.tp_getset = TypeParameter_getset,
	.tp_new = (newfunc)TypeParameter_new,
}
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/type.c:1228

---

{#typetemplateparameter_members}

### TypeTemplateParameter_members

`static`

```cpp
PyMemberDef TypeTemplateParameter_members[]
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/type.c:1322

---

{#typetemplateparameter_getset}

### TypeTemplateParameter_getset

`static`

```cpp
PyGetSetDef TypeTemplateParameter_getset[]
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/type.c:1330

---

{#typetemplateparameter_type-1}

### TypeTemplateParameter_type

```cpp
PyTypeObject TypeTemplateParameter_type = {
	PyVarObject_HEAD_INIT(NULL, 0)
	.tp_name = "_drgn.TypeTemplateParameter",
	.tp_basicsize = sizeof(TypeTemplateParameter),
	.tp_dealloc = (destructor)TypeTemplateParameter_dealloc,
	.tp_repr = (reprfunc)TypeTemplateParameter_repr,
	.tp_flags = Py_TPFLAGS_DEFAULT | Py_TPFLAGS_HAVE_GC,
	.tp_traverse = (traverseproc)LazyObject_traverse,
	.tp_doc = drgn_TypeTemplateParameter_DOC,
	.tp_members = TypeTemplateParameter_members,
	.tp_getset = TypeTemplateParameter_getset,
	.tp_new = (newfunc)TypeTemplateParameter_new,
}
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/type.c:1336

---

{#default_dwarf_cfi_row_aarch64}

### default_dwarf_cfi_row_aarch64

`static`

```cpp
const struct drgn_cfi_row default_dwarf_cfi_row_aarch64 = DRGN_CFI_ROW(
	[DRGN_REGISTER_NUMBER(ra_sign_state)] = {
		DRGN_CFI_RULE_CONSTANT, .constant = 0
	},
	
	
	[DRGN_REGISTER_NUMBER(sp)] = { DRGN_CFI_RULE_CFA_PLUS_OFFSET },
	
	
	DRGN_CFI_SAME_VALUE_INIT(DRGN_REGISTER_NUMBER(x19)),
	DRGN_CFI_SAME_VALUE_INIT(DRGN_REGISTER_NUMBER(x20)),
	DRGN_CFI_SAME_VALUE_INIT(DRGN_REGISTER_NUMBER(x21)),
	DRGN_CFI_SAME_VALUE_INIT(DRGN_REGISTER_NUMBER(x22)),
	DRGN_CFI_SAME_VALUE_INIT(DRGN_REGISTER_NUMBER(x23)),
	DRGN_CFI_SAME_VALUE_INIT(DRGN_REGISTER_NUMBER(x24)),
	DRGN_CFI_SAME_VALUE_INIT(DRGN_REGISTER_NUMBER(x25)),
	DRGN_CFI_SAME_VALUE_INIT(DRGN_REGISTER_NUMBER(x26)),
	DRGN_CFI_SAME_VALUE_INIT(DRGN_REGISTER_NUMBER(x27)),
	DRGN_CFI_SAME_VALUE_INIT(DRGN_REGISTER_NUMBER(x28)),
	DRGN_CFI_SAME_VALUE_INIT(DRGN_REGISTER_NUMBER(x29)),
	DRGN_CFI_SAME_VALUE_INIT(DRGN_REGISTER_NUMBER(x30)),
)
```

Type: const struct [`drgn_cfi_row`](drgn_cfi_row.md#drgn_cfi_row-1)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/arch_aarch64.c:31

---

{#default_dwarf_cfi_row_x86_64}

### default_dwarf_cfi_row_x86_64

`static`

```cpp
const struct drgn_cfi_row default_dwarf_cfi_row_x86_64 = DRGN_CFI_ROW(
	
	
	[DRGN_REGISTER_NUMBER(rsp)] = { DRGN_CFI_RULE_CFA_PLUS_OFFSET },
	
	
	DRGN_CFI_SAME_VALUE_INIT(DRGN_REGISTER_NUMBER(rbx)),
	DRGN_CFI_SAME_VALUE_INIT(DRGN_REGISTER_NUMBER(rbp)),
	DRGN_CFI_SAME_VALUE_INIT(DRGN_REGISTER_NUMBER(r12)),
	DRGN_CFI_SAME_VALUE_INIT(DRGN_REGISTER_NUMBER(r13)),
	DRGN_CFI_SAME_VALUE_INIT(DRGN_REGISTER_NUMBER(r14)),
	DRGN_CFI_SAME_VALUE_INIT(DRGN_REGISTER_NUMBER(r15)),
)
```

Type: const struct [`drgn_cfi_row`](drgn_cfi_row.md#drgn_cfi_row-1)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/arch_x86_64.c:25

---

{#faulterror_type-1}

### FaultError_type

```cpp
PyTypeObject FaultError_type = {
	PyVarObject_HEAD_INIT(NULL, 0)
	.tp_name = "_drgn.FaultError",
	.tp_basicsize = sizeof(PyBaseExceptionObject),
	.tp_str = (reprfunc)FaultError_str,
	.tp_flags = Py_TPFLAGS_DEFAULT | Py_TPFLAGS_BASETYPE,
	.tp_doc = drgn_FaultError_DOC,
	.tp_init = (initproc)FaultError_init,
}
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/error.c:47

---

{#objectnotfounderror_type-1}

### ObjectNotFoundError_type

```cpp
PyTypeObject ObjectNotFoundError_type = {
	PyVarObject_HEAD_INIT(NULL, 0)
	.tp_name = "_drgn.ObjectNotFoundError",
	.tp_basicsize = sizeof(PyBaseExceptionObject),
	.tp_flags = Py_TPFLAGS_DEFAULT | Py_TPFLAGS_BASETYPE,
	.tp_doc = drgn_ObjectNotFoundError_DOC,
	.tp_init = (initproc)ObjectNotFoundError_init,
}
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/error.c:76

---

{#drgn_c_type_unsigned_long-1}

### DRGN_C_TYPE_UNSIGNED_LONG

```cpp
DRGN_C_TYPE_UNSIGNED_LONG
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/linux_kernel.c:214

---

{#unsigned}

### unsigned

```cpp
unsigned
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/linux_kernel.c:214

---

{#max_module_list_iterations}

### MAX_MODULE_LIST_ITERATIONS

`static`

```cpp
const int MAX_MODULE_LIST_ITERATIONS = 10000
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/linux_kernel.c:1634

---

{#symbolindex_type-1}

### SymbolIndex_type

```cpp
PyTypeObject SymbolIndex_type = {
	PyVarObject_HEAD_INIT(NULL, 0)
	.tp_name = "_drgn.SymbolIndex",
	.tp_basicsize = sizeof(SymbolIndex),
	.tp_dealloc = (destructor)SymbolIndex_dealloc,
	
	.tp_flags = Py_TPFLAGS_DEFAULT,
	.tp_doc = drgn_SymbolIndex_DOC,
	.tp_call = (ternaryfunc)SymbolIndex_call,
	.tp_new = SymbolIndex_new,
}
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/symbol_index.c:113

---

{#memorysearchiterator_methods}

### MemorySearchIterator_methods

`static`

```cpp
PyMethodDef MemorySearchIterator_methods[]
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/memory_search.c:192

---

{#memorysearchiterator_type-1}

### MemorySearchIterator_type

```cpp
PyTypeObject MemorySearchIterator_type = {
	PyVarObject_HEAD_INIT(NULL, 0)
	.tp_name = "_drgn._MemorySearchIterator",
	.tp_basicsize = sizeof(MemorySearchIterator),
	.tp_dealloc = (destructor)MemorySearchIterator_dealloc,
	.tp_flags = Py_TPFLAGS_DEFAULT | Py_TPFLAGS_HAVE_GC,
	.tp_traverse = (traverseproc)MemorySearchIterator_traverse,
	.tp_iter = PyObject_SelfIter,
	.tp_iternext = (iternextfunc)MemorySearchIterator_next,
	.tp_methods = MemorySearchIterator_methods,
}
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/memory_search.c:200

---

{#memorysearchiteratorwithbytes_type-1}

### MemorySearchIteratorWithBytes_type

```cpp
PyTypeObject MemorySearchIteratorWithBytes_type = {
	PyVarObject_HEAD_INIT(NULL, 0)
	.tp_name = "_drgn._MemorySearchIteratorWithBytes",
	.tp_basicsize = sizeof(MemorySearchIterator),
	.tp_dealloc = (destructor)MemorySearchIterator_dealloc,
	.tp_flags = Py_TPFLAGS_DEFAULT | Py_TPFLAGS_HAVE_GC,
	.tp_traverse = (traverseproc)MemorySearchIterator_traverse,
	.tp_iter = PyObject_SelfIter,
	.tp_iternext = (iternextfunc)MemorySearchIteratorWithBytes_next,
	.tp_methods = MemorySearchIterator_methods,
}
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/memory_search.c:212

---

{#memorysearchiteratorwithstr_type-1}

### MemorySearchIteratorWithStr_type

```cpp
PyTypeObject MemorySearchIteratorWithStr_type = {
	PyVarObject_HEAD_INIT(NULL, 0)
	.tp_name = "_drgn._MemorySearchIteratorWithStr",
	.tp_basicsize = sizeof(MemorySearchIterator),
	.tp_dealloc = (destructor)MemorySearchIterator_dealloc,
	.tp_flags = Py_TPFLAGS_DEFAULT | Py_TPFLAGS_HAVE_GC,
	.tp_traverse = (traverseproc)MemorySearchIterator_traverse,
	.tp_iter = PyObject_SelfIter,
	.tp_iternext = (iternextfunc)MemorySearchIteratorWithStr_next,
	.tp_methods = MemorySearchIterator_methods,
}
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/memory_search.c:224

---

{#memorysearchiteratorwithint_type-1}

### MemorySearchIteratorWithInt_type

```cpp
PyTypeObject MemorySearchIteratorWithInt_type = {
	PyVarObject_HEAD_INIT(NULL, 0)
	.tp_name = "_drgn._MemorySearchIteratorWithInt",
	.tp_basicsize = sizeof(MemorySearchIterator),
	.tp_dealloc = (destructor)MemorySearchIterator_dealloc,
	.tp_flags = Py_TPFLAGS_DEFAULT | Py_TPFLAGS_HAVE_GC,
	.tp_traverse = (traverseproc)MemorySearchIterator_traverse,
	.tp_iter = PyObject_SelfIter,
	.tp_iternext = (iternextfunc)MemorySearchIteratorWithInt_next,
	.tp_methods = MemorySearchIterator_methods,
}
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/memory_search.c:236

---

{#drgnobject_getset}

### DrgnObject_getset

`static`

```cpp
PyGetSetDef DrgnObject_getset[]
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/object.c:1656

---

{#drgnobject_methods}

### DrgnObject_methods

`static`

```cpp
PyMethodDef DrgnObject_methods[]
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/object.c:1672

---

{#drgnobject_as_number}

### DrgnObject_as_number

`static`

```cpp
PyNumberMethods DrgnObject_as_number = {
	.nb_add = (binaryfunc)DrgnObject_add,
	.nb_subtract = (binaryfunc)DrgnObject_sub,
	.nb_multiply = (binaryfunc)DrgnObject_mul,
	.nb_remainder = (binaryfunc)DrgnObject_mod,
	.nb_negative = (unaryfunc)DrgnObject_neg,
	.nb_positive = (unaryfunc)DrgnObject_pos,
	.nb_bool = (inquiry)DrgnObject_bool,
	.nb_invert = (unaryfunc)DrgnObject_not,
	.nb_lshift = (binaryfunc)DrgnObject_lshift,
	.nb_rshift = (binaryfunc)DrgnObject_rshift,
	.nb_and = (binaryfunc)DrgnObject_and,
	.nb_xor = (binaryfunc)DrgnObject_xor,
	.nb_or = (binaryfunc)DrgnObject_or,
	.nb_int = (unaryfunc)DrgnObject_int,
	.nb_float = (unaryfunc)DrgnObject_float,
	.nb_true_divide = (binaryfunc)DrgnObject_div,
	.nb_index = (unaryfunc)DrgnObject_index,
}
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/object.c:1707

---

{#drgnobject_as_mapping}

### DrgnObject_as_mapping

`static`

```cpp
PyMappingMethods DrgnObject_as_mapping = {
	.mp_length = (lenfunc)DrgnObject_length,
	.mp_subscript = (binaryfunc)DrgnObject_subscript,
}
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/object.c:1727

---

{#drgnobject_type-1}

### DrgnObject_type

```cpp
PyTypeObject DrgnObject_type = {
	PyVarObject_HEAD_INIT(NULL, 0)
	.tp_name = "_drgn.Object",
	.tp_basicsize = sizeof(DrgnObject),
	.tp_dealloc = (destructor)DrgnObject_dealloc,
	.tp_repr = (reprfunc)DrgnObject_repr,
	.tp_as_number = &DrgnObject_as_number,
	.tp_as_mapping = &DrgnObject_as_mapping,
	.tp_str = (reprfunc)DrgnObject_str,
	.tp_getattro = (getattrofunc)DrgnObject_getattro,
	.tp_flags = Py_TPFLAGS_DEFAULT | Py_TPFLAGS_HAVE_GC,
	.tp_traverse = (traverseproc)DrgnObject_traverse,
	.tp_doc = drgn_Object_DOC,
	.tp_richcompare = DrgnObject_richcompare,
	.tp_iter = (getiterfunc)DrgnObject_iter,
	.tp_methods = DrgnObject_methods,
	.tp_getset = DrgnObject_getset,
	.tp_new = (newfunc)DrgnObject_new,
}
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/object.c:1738

---

{#objectiterator_methods}

### ObjectIterator_methods

`static`

```cpp
PyMethodDef ObjectIterator_methods[]
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/object.c:1901

---

{#objectiterator_type-1}

### ObjectIterator_type

```cpp
PyTypeObject ObjectIterator_type = {
	PyVarObject_HEAD_INIT(NULL, 0)
	.tp_name = "_drgn._ObjectIterator",
	.tp_basicsize = sizeof(ObjectIterator),
	.tp_dealloc = (destructor)ObjectIterator_dealloc,
	.tp_flags = Py_TPFLAGS_DEFAULT | Py_TPFLAGS_HAVE_GC,
	.tp_traverse = (traverseproc)ObjectIterator_traverse,
	.tp_iter = PyObject_SelfIter,
	.tp_iternext = (iternextfunc)ObjectIterator_next,
	.tp_methods = ObjectIterator_methods,
}
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/object.c:1907

---

{#symbol_getset}

### Symbol_getset

`static`

```cpp
PyGetSetDef Symbol_getset[]
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/symbol.c:144

---

{#symbol_type-1}

### Symbol_type

```cpp
PyTypeObject Symbol_type = {
	PyVarObject_HEAD_INIT(NULL, 0)
	.tp_name = "_drgn.Symbol",
	.tp_basicsize = sizeof(Symbol),
	.tp_dealloc = (destructor)Symbol_dealloc,
	.tp_repr = (reprfunc)Symbol_repr,
	
	.tp_flags = Py_TPFLAGS_DEFAULT,
	.tp_doc = drgn_Symbol_DOC,
	.tp_richcompare = (richcmpfunc)Symbol_richcompare,
	.tp_getset = Symbol_getset,
	.tp_new = Symbol_new,
}
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/symbol.c:153

---

{#percent_s}

### percent_s

`static`

```cpp
PyObject * percent_s
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/program.c:22

---

{#logging_streamhandler}

### logging_StreamHandler

`static`

```cpp
PyObject * logging_StreamHandler
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/program.c:23

---

{#logger}

### logger

`static`

```cpp
PyObject * logger
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/program.c:24

---

{#logger_log}

### logger_log

`static`

```cpp
PyObject * logger_log
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/program.c:25

---

{#cached_log_level}

### cached_log_level

`static`

```cpp
int cached_log_level
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/program.c:157

---

{#cached_enable_progress_bar}

### cached_enable_progress_bar

`static`

```cpp
bool cached_enable_progress_bar
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/program.c:158

---

{#programs-2}

### programs

`static`

```cpp
struct pyobjectp_set programs = HASH_TABLE_INIT
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/program.c:159

---

{#loggercachewrapper_methods}

### LoggerCacheWrapper_methods

`static`

```cpp
PyMethodDef LoggerCacheWrapper_methods[]
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/program.c:185

---

{#loggercachewrapper_type}

### LoggerCacheWrapper_type

`static`

```cpp
PyTypeObject LoggerCacheWrapper_type = {
	PyVarObject_HEAD_INIT(NULL, 0)
	.tp_name = "_drgn._LoggerCacheWrapper",
	.tp_methods = LoggerCacheWrapper_methods,
}
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/program.c:190

---

{#program_methods}

### Program_methods

`static`

```cpp
PyMethodDef Program_methods[]
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/program.c:2273

---

{#program_members}

### Program_members

`static`

```cpp
PyMemberDef Program_members[]
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/program.c:2414

---

{#program_getset}

### Program_getset

`static`

```cpp
PyGetSetDef Program_getset[]
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/program.c:2422

---

{#program_as_mapping}

### Program_as_mapping

`static`

```cpp
PyMappingMethods Program_as_mapping = {
	.mp_subscript = (binaryfunc)Program_subscript,
}
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/program.c:2436

---

{#program_as_sequence}

### Program_as_sequence

`static`

```cpp
PySequenceMethods Program_as_sequence = {
	.sq_contains = (objobjproc)Program_contains,
}
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/program.c:2440

---

{#program_type-1}

### Program_type

```cpp
PyTypeObject Program_type = {
	PyVarObject_HEAD_INIT(NULL, 0)
	.tp_name = "_drgn.Program",
	.tp_basicsize = sizeof(Program),
	.tp_dealloc = (destructor)Program_dealloc,
	.tp_as_sequence = &Program_as_sequence,
	.tp_as_mapping = &Program_as_mapping,
	.tp_flags = Py_TPFLAGS_DEFAULT | Py_TPFLAGS_HAVE_GC,
	.tp_doc = drgn_Program_DOC,
	.tp_traverse = (traverseproc)Program_traverse,
	.tp_clear = (inquiry)Program_clear,
	.tp_methods = Program_methods,
	.tp_members = Program_members,
	.tp_getset = Program_getset,
	.tp_new = (newfunc)Program_new,
}
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/program.c:2444

---

{#collections_abc_set}

### collections_abc_Set

`static`

```cpp
PyObject * collections_abc_Set
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/type_kind_set.c:8

---

{#typekindset_as_sequence}

### TypeKindSet_as_sequence

`static`

```cpp
PySequenceMethods TypeKindSet_as_sequence = {
	.sq_length = (lenfunc)TypeKindSet_length,
	.sq_contains = (objobjproc)TypeKindSet_contains,
}
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/type_kind_set.c:295

---

{#typekindset_methods}

### TypeKindSet_methods

`static`

```cpp
PyMethodDef TypeKindSet_methods[]
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/type_kind_set.c:300

---

{#typekindset_type-1}

### TypeKindSet_type

```cpp
PyTypeObject TypeKindSet_type = {
	PyVarObject_HEAD_INIT(NULL, 0)
	.tp_name = "_drgn.TypeKindSet",
	.tp_basicsize = sizeof(TypeKindSet),
	.tp_repr = (reprfunc)TypeKindSet_repr,
	.tp_as_number = &TypeKindSet_as_number,
	.tp_as_sequence = &TypeKindSet_as_sequence,
	.tp_hash = (hashfunc)TypeKindSet_hash,
	
	.tp_flags = Py_TPFLAGS_DEFAULT,
	.tp_doc = drgn_TypeKindSet_DOC,
	.tp_richcompare = (richcmpfunc)TypeKindSet_richcompare,
	.tp_iter = (getiterfunc)TypeKindSet_iter,
	.tp_methods = TypeKindSet_methods,
	.tp_new = (newfunc)TypeKindSet_new,
}
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/type_kind_set.c:305

---

{#typekindsetiterator_methods}

### TypeKindSetIterator_methods

`static`

```cpp
PyMethodDef TypeKindSetIterator_methods[]
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/type_kind_set.c:336

---

{#typekindsetiterator_type-1}

### TypeKindSetIterator_type

```cpp
PyTypeObject TypeKindSetIterator_type = {
	PyVarObject_HEAD_INIT(NULL, 0)
	.tp_name = "_drgn._TypeKindSetIterator",
	.tp_basicsize = sizeof(TypeKindSetIterator),
	
	.tp_flags = Py_TPFLAGS_DEFAULT,
	.tp_iter = PyObject_SelfIter,
	.tp_iternext = (iternextfunc)TypeKindSetIterator_next,
	.tp_methods = TypeKindSetIterator_methods,
}
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/type_kind_set.c:342

---

{#language_getset}

### Language_getset

`static`

```cpp
PyGetSetDef Language_getset[]
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/language.c:18

---

{#language_type-1}

### Language_type

```cpp
PyTypeObject Language_type = {
	PyVarObject_HEAD_INIT(NULL, 0)
	.tp_name = "_drgn.Language",
	.tp_basicsize = sizeof(Language),
	.tp_repr = (reprfunc)Language_repr,
	
	.tp_flags = Py_TPFLAGS_DEFAULT,
	.tp_doc = drgn_Language_DOC,
	.tp_getset = Language_getset,
}
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/language.c:23

---

{#languages_py}

### languages_py

`static`

```cpp
PyObject * languages_py[DRGN_NUM_LANGUAGES]
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/language.c:34

---

{#platform_getset}

### Platform_getset

`static`

```cpp
PyGetSetDef Platform_getset[]
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/platform.c:112

---

{#platform_type-1}

### Platform_type

```cpp
PyTypeObject Platform_type = {
	PyVarObject_HEAD_INIT(NULL, 0)
	.tp_name = "_drgn.Platform",
	.tp_basicsize = sizeof(Platform),
	.tp_dealloc = (destructor)Platform_dealloc,
	.tp_repr = (reprfunc)Platform_repr,
	
	.tp_flags = Py_TPFLAGS_DEFAULT,
	.tp_doc = drgn_Platform_DOC,
	.tp_richcompare = (richcmpfunc)Platform_richcompare,
	.tp_getset = Platform_getset,
	.tp_new = (newfunc)Platform_new,
}
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/platform.c:120

---

{#register_getset}

### Register_getset

`static`

```cpp
PyGetSetDef Register_getset[]
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/platform.c:169

---

{#register_type-1}

### Register_type

```cpp
PyTypeObject Register_type = {
	PyVarObject_HEAD_INIT(NULL, 0)
	.tp_name = "_drgn.Register",
	.tp_basicsize = sizeof(Register),
	.tp_repr = (reprfunc)Register_repr,
	
	.tp_flags = Py_TPFLAGS_DEFAULT,
	.tp_doc = drgn_Register_DOC,
	.tp_richcompare = (richcmpfunc)Register_richcompare,
	.tp_getset = Register_getset,
}
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/platform.c:174

---

{#sourcelocation_type-1}

### SourceLocation_type

```cpp
PyObject * SourceLocation_type
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/source_location.c:7

---

{#sourcelocationlist_methods}

### SourceLocationList_methods

`static`

```cpp
PyMethodDef SourceLocationList_methods[]
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/source_location.c:172

---

{#sourcelocationlist_as_sequence}

### SourceLocationList_as_sequence

`static`

```cpp
PySequenceMethods SourceLocationList_as_sequence = {
	.sq_length = (lenfunc)SourceLocationList_length,
	.sq_item = (ssizeargfunc)SourceLocationList_item,
}
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/source_location.c:178

---

{#sourcelocationlist_getset}

### SourceLocationList_getset

`static`

```cpp
PyGetSetDef SourceLocationList_getset[]
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/source_location.c:183

---

{#sourcelocationlist_type-1}

### SourceLocationList_type

```cpp
PyTypeObject SourceLocationList_type = {
	PyVarObject_HEAD_INIT(NULL, 0)
	.tp_name = "_drgn.SourceLocationList",
	.tp_basicsize = sizeof(SourceLocationList),
	.tp_dealloc = (destructor)SourceLocationList_dealloc,
	.tp_as_sequence = &SourceLocationList_as_sequence,
	.tp_str = (reprfunc)SourceLocationList_str,
	.tp_flags = Py_TPFLAGS_DEFAULT | Py_TPFLAGS_HAVE_GC,
	.tp_doc = drgn_SourceLocationList_DOC,
	.tp_traverse = (traverseproc)SourceLocationList_traverse,
	.tp_methods = SourceLocationList_methods,
	.tp_getset = SourceLocationList_getset,
}
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/source_location.c:189

---

{#environ}

### environ

```cpp
char ** environ
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/examples/load_debug_info.c:18

---

{#drgn_debug_info_options_default_directories}

### drgn_debug_info_options_default_directories

`static`

```cpp
const char *const drgn_debug_info_options_default_directories[]
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info_options.c:12

---

{#drgn_debug_info_options_directories_allow_empty}

### drgn_debug_info_options_directories_allow_empty

`static`

```cpp
const bool drgn_debug_info_options_directories_allow_empty = false
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info_options.c:15

---

{#drgn_debug_info_options_default_debug_link_directories}

### drgn_debug_info_options_default_debug_link_directories

`static`

```cpp
const char *const drgn_debug_info_options_default_debug_link_directories[]
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info_options.c:17

---

{#drgn_debug_info_options_debug_link_directories_allow_empty}

### drgn_debug_info_options_debug_link_directories_allow_empty

`static`

```cpp
const bool drgn_debug_info_options_debug_link_directories_allow_empty = true
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info_options.c:20

---

{#drgn_debug_info_options_default_kernel_directories}

### drgn_debug_info_options_default_kernel_directories

`static`

```cpp
const char *const drgn_debug_info_options_default_kernel_directories[]
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info_options.c:22

---

{#drgn_debug_info_options_kernel_directories_allow_empty}

### drgn_debug_info_options_kernel_directories_allow_empty

`static`

```cpp
const bool drgn_debug_info_options_kernel_directories_allow_empty = true
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info_options.c:25

---

{#stacktrace_methods}

### StackTrace_methods

`static`

```cpp
PyMethodDef StackTrace_methods[]
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/stack_trace.c:75

---

{#stacktrace_as_sequence}

### StackTrace_as_sequence

`static`

```cpp
PySequenceMethods StackTrace_as_sequence = {
	.sq_length = (lenfunc)StackTrace_length,
	.sq_item = (ssizeargfunc)StackTrace_item,
}
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/stack_trace.c:81

---

{#stacktrace_getset}

### StackTrace_getset

`static`

```cpp
PyGetSetDef StackTrace_getset[]
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/stack_trace.c:86

---

{#stacktrace_type-1}

### StackTrace_type

```cpp
PyTypeObject StackTrace_type = {
	PyVarObject_HEAD_INIT(NULL, 0)
	.tp_name = "_drgn.StackTrace",
	.tp_basicsize = sizeof(StackTrace),
	.tp_dealloc = (destructor)StackTrace_dealloc,
	.tp_as_sequence = &StackTrace_as_sequence,
	.tp_str = (reprfunc)StackTrace_str,
	.tp_flags = Py_TPFLAGS_DEFAULT | Py_TPFLAGS_HAVE_GC,
	.tp_doc = drgn_StackTrace_DOC,
	.tp_traverse = (traverseproc)StackTrace_traverse,
	.tp_methods = StackTrace_methods,
	.tp_getset = StackTrace_getset,
}
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/stack_trace.c:91

---

{#stackframe_methods}

### StackFrame_methods

`static`

```cpp
PyMethodDef StackFrame_methods[]
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/stack_trace.c:363

---

{#stackframe_getset}

### StackFrame_getset

`static`

```cpp
PyGetSetDef StackFrame_getset[]
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/stack_trace.c:383

---

{#stackframe_as_mapping}

### StackFrame_as_mapping

`static`

```cpp
PyMappingMethods StackFrame_as_mapping = {
	.mp_subscript = (binaryfunc)StackFrame_subscript,
}
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/stack_trace.c:396

---

{#stackframe_as_sequence}

### StackFrame_as_sequence

`static`

```cpp
PySequenceMethods StackFrame_as_sequence = {
	.sq_contains = (objobjproc)StackFrame_contains,
}
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/stack_trace.c:400

---

{#stackframe_type-1}

### StackFrame_type

```cpp
PyTypeObject StackFrame_type = {
	PyVarObject_HEAD_INIT(NULL, 0)
	.tp_name = "_drgn.StackFrame",
	.tp_basicsize = sizeof(StackFrame),
	.tp_dealloc = (destructor)StackFrame_dealloc,
	.tp_as_sequence = &StackFrame_as_sequence,
	.tp_as_mapping = &StackFrame_as_mapping,
	.tp_str = (reprfunc)StackFrame_str,
	.tp_flags = Py_TPFLAGS_DEFAULT | Py_TPFLAGS_HAVE_GC,
	.tp_doc = drgn_StackFrame_DOC,
	.tp_traverse = (traverseproc)StackFrame_traverse,
	.tp_methods = StackFrame_methods,
	.tp_getset = StackFrame_getset,
}
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/stack_trace.c:404

---

{#modulesectionaddresses_class-1}

### ModuleSectionAddresses_class

```cpp
PyObject * ModuleSectionAddresses_class
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/module_section_addresses.c:8

---

{#modulesectionaddressesmixin_as_mapping}

### ModuleSectionAddressesMixin_as_mapping

`static`

```cpp
PyMappingMethods ModuleSectionAddressesMixin_as_mapping = {
	.mp_length = (lenfunc)ModuleSectionAddresses_length,
	.mp_subscript = (binaryfunc)ModuleSectionAddresses_subscript,
	.mp_ass_subscript = (objobjargproc)ModuleSectionAddresses_ass_subscript,
}
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/module_section_addresses.c:190

---

{#modulesectionaddressesmixin_type}

### ModuleSectionAddressesMixin_type

`static`

```cpp
PyTypeObject ModuleSectionAddressesMixin_type = {
	PyVarObject_HEAD_INIT(NULL, 0)
	.tp_name = "_drgn.ModuleSectionAddressesMixin",
	.tp_dealloc = (destructor)ModuleSectionAddresses_dealloc,
	.tp_basicsize = sizeof(ModuleSectionAddresses),
	.tp_repr = (reprfunc)ModuleSectionAddresses_repr,
	.tp_as_mapping = &ModuleSectionAddressesMixin_as_mapping,
	.tp_flags = Py_TPFLAGS_DEFAULT | Py_TPFLAGS_HAVE_GC | Py_TPFLAGS_BASETYPE,
	.tp_traverse = (traverseproc)ModuleSectionAddresses_traverse,
	.tp_iter = (getiterfunc)ModuleSectionAddresses_iter,
	.tp_new = (newfunc)ModuleSectionAddresses_new,
}
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/module_section_addresses.c:196

---

{#modulesectionaddressesiterator_type-1}

### ModuleSectionAddressesIterator_type

```cpp
PyTypeObject ModuleSectionAddressesIterator_type = {
	PyVarObject_HEAD_INIT(NULL, 0)
	.tp_name = "_drgn._ModuleSectionAddressesIterator",
	.tp_basicsize = sizeof(ModuleSectionAddressesIterator),
	.tp_dealloc = (destructor)ModuleSectionAddressesIterator_dealloc,
	.tp_flags = Py_TPFLAGS_DEFAULT | Py_TPFLAGS_HAVE_GC,
	.tp_traverse = (traverseproc)ModuleSectionAddressesIterator_traverse,
	.tp_iter = PyObject_SelfIter,
	.tp_iternext = (iternextfunc)ModuleSectionAddressesIterator_next,
}
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/module_section_addresses.c:249

---

{#debuginfooptions_getset}

### DebugInfoOptions_getset

`static`

```cpp
PyGetSetDef DebugInfoOptions_getset[]
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/debug_info_options.c:195

---

{#debuginfooptions_type-1}

### DebugInfoOptions_type

```cpp
PyTypeObject DebugInfoOptions_type = {
	PyVarObject_HEAD_INIT(NULL, 0)
	.tp_name = "_drgn.DebugInfoOptions",
	.tp_dealloc = (destructor)DebugInfoOptions_dealloc,
	.tp_basicsize = sizeof(DebugInfoOptions),
	.tp_repr = DebugInfoOptions_repr,
	.tp_flags = Py_TPFLAGS_DEFAULT | Py_TPFLAGS_HAVE_GC,
	.tp_doc = drgn_DebugInfoOptions_DOC,
	.tp_traverse = (traverseproc)DebugInfoOptions_traverse,
	.tp_getset = DebugInfoOptions_getset,
	.tp_new = (newfunc)DebugInfoOptions_new,
}
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/python/debug_info_options.c:230

Generated by [Moxygen](https://0state.com/moxygen)