{#drgn_architecture_info}

# drgn_architecture_info

```cpp
#include <platform.h>
```

```cpp
struct drgn_architecture_info
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/platform.h:272

Architecture-specific information and callbacks.

To add the bare minimum support for recognizing a new architecture:

* Add a `DRGN_ARCH_FOO` enumerator to [drgn_architecture](drgn_architecture.md#drgn_architecture).
* Add the constant to `class Architecture` in `_drgn.pyi`.
* Create a new `libdrgn/arch_foo.c` file and add it to `libdrgn_common_la_SOURCES` in `libdrgn/Makefile.am`.
* Define `struct [drgn_architecture_info](#drgn_architecture_info) arch_info_foo` in `libdrgn/arch_foo.c` with the following members:
  * [name](#name-7)
  * [arch](#arch-2)
  * [default_flags](#default_flags)
  * [scalar_alignment](#scalar_alignment)
  * [register_by_name](#register_by_name) = [drgn_register_by_name_unknown](PlatformInternals.md#drgn_register_by_name_unknown)
* Add an `extern` declaration of `arch_info_foo` to `[libdrgn/platform.h](#platformh)`.
* Handle the architecture in drgn_platform_from_kdump(), drgn_platform_to_kdump(), [drgn_host_platform](Platforms.md#drgn_host_platform), [drgn_platform_create()](Platforms.md#drgn_platform_create), [drgn_platform_from_elf()](PlatformInternals.md#drgn_platform_from_elf), and qmp_detect_platform().
* Update `docs/support_matrix.rst`.

To support Linux kernel loadable modules:

* Define [apply_elf_reloc](#apply_elf_reloc).
* Update `docs/support_matrix.rst`.

To support stack unwinding:

* Create a new `libdrgn/arch_foo_defs.py` file. See `libdrgn/build-aux/gen_arch_inc_strswitch.py`.
* Add `arch_foo_defs.py` to `ARCH_DEFS_PYS` and remove `libdrgn/arch_foo.c` from `libdrgn_common_la_SOURCES` in `libdrgn/Makefile.am`.
* Add `#include "arch_foo_defs.inc"` to `libdrgn/arch_foo.c`.
* Add `DRGN_ARCHITECTURE_REGISTERS` to `arch_info_foo` and remove [register_by_name](#register_by_name).
* Define the following [drgn_architecture_info](#drgn_architecture_info) members:
  * [default_dwarf_cfi_row](#default_dwarf_cfi_row) (use [DRGN_CFI_ROW](CallFrameInformation.md#drgn_cfi_row))
  * [fallback_unwind](#fallback_unwind)
  * [bad_call_unwind](#bad_call_unwind)
  * [pt_regs_get_initial_registers](#pt_regs_get_initial_registers)
  * [prstatus_get_initial_registers](#prstatus_get_initial_registers)
  * [linux_kernel_get_initial_registers](#linux_kernel_get_initial_registers)
  * [demangle_cfi_registers](#demangle_cfi_registers) (only if needed)
* Implement `drgn_test_get_pt_regs()` in `tests/linux_kernel/kmod/drgn_test.c` (usually by copying `crash_setup_regs()` from the Linux kernel).
* Add the architecture name to `skip_unless_have_stack_tracing()` in `tests/linux_kernel/__init__.py`.
* Update `docs/support_matrix.rst`.

To support virtual address translation:

* Define the [drgn_architecture_info](#drgn_architecture_info) page table iterator members:
  * [linux_kernel_pgtable_iterator_arch_create](#linux_kernel_pgtable_iterator_arch_create)
  * [linux_kernel_pgtable_iterator_arch_destroy](#linux_kernel_pgtable_iterator_arch_destroy)
  * [linux_kernel_pgtable_iterator_init](#linux_kernel_pgtable_iterator_init)
  * [linux_kernel_pgtable_iterator_next](#linux_kernel_pgtable_iterator_next)
* Define the SPARSEMEM constant fallback getters if applicable:
  * [linux_kernel_section_size_bits_fallback](#linux_kernel_section_size_bits_fallback)
  * [linux_kernel_max_physmem_bits_fallback](#linux_kernel_max_physmem_bits_fallback)
* Add the architecture name to `HAVE_FULL_MM_SUPPORT` in `tests/linux_kernel/__init__.py`.
* Update `docs/support_matrix.rst`.

This is an example of how the page table iterator members may be used (ignoring error handling):

```cpp
struct pgtable_iterator it;

// Create the architecture-specific data for the iterator.
arch->linux_kernel_pgtable_iterator_arch_create(prog, &it.arch);

// Initialize the iterator to translate virtual address 0x80000000 using
// the page table "pgtable".
it.pgtable = pgtable;
it.virt_addr = 0x80000000;
arch->linux_kernel_pgtable_iterator_init(prog, &it);
// Iterate up to virtual address 0x90000000.
while (it.virt_addr < 0x90000000) {
        uint64_t virt_addr, phys_addr;
        arch->linux_kernel_pgtable_iterator_next(prog, &it, &virt_addr,
                                                 &phys_addr);
        if (phys_addr == UINT64_MAX) {
                printf("Virtual address range 0x%" PRIx64 "-0x%" PRIx64
                       " is not mapped\n",
                       virt_addr, it.virt_addr);
        } else {
                printf("Virtual address range 0x%" PRIx64 "-0x%" PRIx64
                       " maps to physical address 0x%" PRIx64 "\n",
                       virt_addr, phys_addr);
        }
}

// Reuse the iterator to translate a different address using a different page
// table.
it.pgtable = another_pgtable;
it.virt_addr = 0x11110000;
arch->linux_kernel_pgtable_iterator_init(prog, &it);
uint64_t virt_addr, phys_addr;
arch->linux_kernel_pgtable_iterator_next(prog, &it, &virt_addr, &phys_addr);
if (phys_addr != UINT64_MAX) {
        printf("Virtual address 0x11110000 maps to physical address 0x%" PRIx64 "\n",
               phys_addr + (0x11110000 - virt_addr));
}

// Free the architecture-specific data now that we're done with it.
arch->linux_kernel_pgtable_iterator_arch_destroy(it.arch);
```

## Public Attributes

| Return | Name | Description |
|--------|------|-------------|
| `const char *` | [`name`](#name-7)  | Human-readable name of this architecture. |
| enum [`drgn_architecture`](drgn_architecture.md#drgn_architecture) | [`arch`](#arch-2)  | Architecture identifier. |
| enum [`drgn_platform_flags`](drgn_platform_flags.md#drgn_platform_flags) | [`default_flags`](#default_flags)  | Flags to set for the platform if we're not getting them from elsewhere (like from an ELF file). |
| [`unsigned`](api.md#unsigned) char | [`scalar_alignment`](#scalar_alignment)  | Default alignment of scalar types by size. |
| const struct [`drgn_register`](drgn_register.md#drgn_register) * | [`registers`](#registers)  | Registers visible to the public API. |
| `size_t` | [`num_registers`](#num_registers)  | Number of registers in [registers](#registers). |
| [`drgn_register_number`](CallFrameInformation.md#drgn_register_number) | [`stack_pointer_regno`](#stack_pointer_regno)  | Internal register number of stack pointer. |
| const struct [`drgn_register`](drgn_register.md#drgn_register) *(* | [`register_by_name`](#register_by_name)  | Return the API-visible register with the given name, or `NULL` if it is not recognized. |
| const struct [`drgn_register_layout`](drgn_register_layout.md#drgn_register_layout) * | [`register_layout`](#register_layout)  | Internal register layouts indexed by internal register number. |
| [`drgn_register_number`](CallFrameInformation.md#drgn_register_number)(* | [`dwarf_regno_to_internal`](#dwarf_regno_to_internal)  | Return the internal register number for the given DWARF register number, or [DRGN_REGISTER_NUMBER_UNKNOWN](CallFrameInformation.md#drgn_register_number_unknown) if it is not recognized. |
| const struct [`drgn_cfi_row`](drgn_cfi_row.md#drgn_cfi_row-1) * | [`default_dwarf_cfi_row`](#default_dwarf_cfi_row)  | CFI row containing default rules for DWARF CFI. |
| `void(*` | [`demangle_cfi_registers`](#demangle_cfi_registers)  | Replace mangled registers unwound by CFI with their actual values. |
| struct [`drgn_error`](drgn_error.md#drgn_error) *(* | [`fallback_unwind`](#fallback_unwind)  | Try to unwind a stack frame if CFI wasn't found. Returns &[drgn_stop](Errors.md#drgn_stop) if we couldn't. |
| struct [`drgn_error`](drgn_error.md#drgn_error) *(* | [`bad_call_unwind`](#bad_call_unwind)  | Try to unwind a stack frame assuming that a call was made to a bad program counter. |
| struct [`drgn_error`](drgn_error.md#drgn_error) *(* | [`pt_regs_get_initial_registers`](#pt_regs_get_initial_registers)  | Create a [drgn_register_state](drgn_register_state.md#drgn_register_state) from a Linux `struct pt_regs`. |
| struct [`drgn_error`](drgn_error.md#drgn_error) *(* | [`prstatus_get_initial_registers`](#prstatus_get_initial_registers)  | Create a [drgn_register_state](drgn_register_state.md#drgn_register_state) from the contents of an ELF `NT_PRSTATUS` note. |
| struct [`drgn_error`](drgn_error.md#drgn_error) *(* | [`linux_kernel_get_initial_registers`](#linux_kernel_get_initial_registers)  | Create a [drgn_register_state](drgn_register_state.md#drgn_register_state) from the `struct task_struct` of a scheduled-out Linux kernel thread. |
| [`apply_elf_reloc_fn`](PlatformInternals.md#apply_elf_reloc_fn) * | [`apply_elf_reloc`](#apply_elf_reloc)  | Apply an ELF relocation. |
| struct [`drgn_error`](drgn_error.md#drgn_error) *(* | [`linux_kernel_live_direct_mapping_fallback`](#linux_kernel_live_direct_mapping_fallback)  | Return the address and size of the direct mapping virtual address range. |
| struct [`drgn_error`](drgn_error.md#drgn_error) *(* | [`linux_kernel_direct_mapping_offset`](#linux_kernel_direct_mapping_offset)  | Return the address of the direct mapping virtual address range. |
| struct [`drgn_error`](drgn_error.md#drgn_error) *(* | [`linux_kernel_pgtable_iterator_arch_create`](#linux_kernel_pgtable_iterator_arch_create)  | Allocate architecture-specific data for a Linux kernel page table iterator. |
| `void(*` | [`linux_kernel_pgtable_iterator_arch_destroy`](#linux_kernel_pgtable_iterator_arch_destroy)  | Free architecture-specific data for a Linux kernel page table iterator. |
| `void(*` | [`linux_kernel_pgtable_iterator_init`](#linux_kernel_pgtable_iterator_init)  | (Re)initialize a Linux kernel page table iterator. |
| [`pgtable_iterator_next_fn`](PlatformInternals.md#pgtable_iterator_next_fn) * | [`linux_kernel_pgtable_iterator_next`](#linux_kernel_pgtable_iterator_next)  | Iterate a (user or kernel) page table in the Linux kernel. |
| `int(*` | [`linux_kernel_section_size_bits_fallback`](#linux_kernel_section_size_bits_fallback)  | Get the value of `SECTION_SIZE_BITS` for Linux kernel versions before v5.13. |
| `int(*` | [`linux_kernel_max_physmem_bits_fallback`](#linux_kernel_max_physmem_bits_fallback)  | Get the value of `MAX_PHYSMEM_BITS` for Linux kernel versions before v5.9. |
| `uint64_t(*` | [`untagged_addr`](#untagged_addr)  | Return the canonical form of a virtual address, i.e. apply any transformations that the CPU applies to the address before page table walking. |

---

{#name-7}

### name

```cpp
const char * name
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/platform.h:274

Human-readable name of this architecture.

---

{#arch-2}

### arch

```cpp
enum drgn_architecture arch
```

Type: enum [`drgn_architecture`](drgn_architecture.md#drgn_architecture)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/platform.h:276

Architecture identifier.

---

{#default_flags}

### default_flags

```cpp
enum drgn_platform_flags default_flags
```

Type: enum [`drgn_platform_flags`](drgn_platform_flags.md#drgn_platform_flags)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/platform.h:281

Flags to set for the platform if we're not getting them from elsewhere (like from an ELF file).

---

{#scalar_alignment}

### scalar_alignment

```cpp
unsigned char scalar_alignment[5]
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/platform.h:294

Default alignment of scalar types by size.

`scalar_alignment[i]` is the default alignment of a scalar type with 2i`sizeof(type)` < 2i+1.

This may not be enough to get the correct alignment of some implementation-defined extended types, but for now it's good enough.

You can generate this for a new architecture using `scripts/scalar_alignment.c`.

---

{#registers}

### registers

```cpp
const struct drgn_register * registers
```

Type: const struct [`drgn_register`](drgn_register.md#drgn_register) *

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/platform.h:300

Registers visible to the public API.

This is set by `DRGN_ARCHITECTURE_REGISTERS`.

---

{#num_registers}

### num_registers

```cpp
size_t num_registers
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/platform.h:306

Number of registers in [registers](#registers).

This is set by `DRGN_ARCHITECTURE_REGISTERS`.

---

{#stack_pointer_regno}

### stack_pointer_regno

```cpp
drgn_register_number stack_pointer_regno
```

Type: [`drgn_register_number`](CallFrameInformation.md#drgn_register_number)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/platform.h:312

Internal register number of stack pointer.

This is set by `DRGN_ARCHITECTURE_REGISTERS`.

---

{#register_by_name}

### register_by_name

```cpp
const struct drgn_register *(* register_by_name)(const char *name)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/platform.h:312

Return the API-visible register with the given name, or `NULL` if it is not recognized.

This is set by `DRGN_ARCHITECTURE_REGISTERS`. It cannot be `NULL`. Set it to [drgn_register_by_name_unknown](PlatformInternals.md#drgn_register_by_name_unknown) if not using `DRGN_ARCHITECTURE_REGISTERS`.

---

{#register_layout}

### register_layout

```cpp
const struct drgn_register_layout * register_layout
```

Type: const struct [`drgn_register_layout`](drgn_register_layout.md#drgn_register_layout) *

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/platform.h:327

Internal register layouts indexed by internal register number.

This is set by `DRGN_ARCHITECTURE_REGISTERS`.

---

{#dwarf_regno_to_internal}

### dwarf_regno_to_internal

```cpp
drgn_register_number(* dwarf_regno_to_internal)(uint64_t)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/platform.h:334

Return the internal register number for the given DWARF register number, or [DRGN_REGISTER_NUMBER_UNKNOWN](CallFrameInformation.md#drgn_register_number_unknown) if it is not recognized.

This is set by `DRGN_ARCHITECTURE_REGISTERS`.

---

{#default_dwarf_cfi_row}

### default_dwarf_cfi_row

```cpp
const struct drgn_cfi_row * default_dwarf_cfi_row
```

Type: const struct [`drgn_cfi_row`](drgn_cfi_row.md#drgn_cfi_row-1) *

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/platform.h:336

CFI row containing default rules for DWARF CFI.

---

{#demangle_cfi_registers}

### demangle_cfi_registers

```cpp
void(* demangle_cfi_registers)(struct drgn_program *, struct drgn_register_state *)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/platform.h:342

Replace mangled registers unwound by CFI with their actual values.

This should be `NULL` if not needed.

---

{#fallback_unwind}

### fallback_unwind

```cpp
struct drgn_error *(* fallback_unwind)(struct drgn_program *, struct drgn_register_state *, struct drgn_register_state **)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/platform.h:342

Try to unwind a stack frame if CFI wasn't found. Returns &[drgn_stop](Errors.md#drgn_stop) if we couldn't.

This typically uses something like frame pointers. If this has to read memory, translate [DRGN_ERROR_FAULT](api.md#drgn_error_fault) errors to &[drgn_stop](Errors.md#drgn_stop).

---

{#bad_call_unwind}

### bad_call_unwind

```cpp
struct drgn_error *(* bad_call_unwind)(struct drgn_program *, struct drgn_register_state *, struct drgn_register_state **)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/platform.h:342

Try to unwind a stack frame assuming that a call was made to a bad program counter.

This should typically undo the effects of a single call instruction and nothing more. If this has to read memory, translate [DRGN_ERROR_FAULT](api.md#drgn_error_fault) errors to &[drgn_stop](Errors.md#drgn_stop).

---

{#pt_regs_get_initial_registers}

### pt_regs_get_initial_registers

```cpp
struct drgn_error *(* pt_regs_get_initial_registers)(const struct drgn_object *obj, struct drgn_register_state **ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/platform.h:342

Create a [drgn_register_state](drgn_register_state.md#drgn_register_state) from a Linux `struct pt_regs`.

This should check that the object is sufficiently large with drgn_object_size(), call [drgn_register_state_create()](RegisterState.md#drgn_register_state_create) with `interrupted = true`, and initialize it from the contents of [drgn_object_buffer()](Objects.md#drgn_object_buffer).

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `obj` |  | `struct pt_regs` as a value buffer object. |
| `ret` |  | Returned registers. |

---

{#prstatus_get_initial_registers}

### prstatus_get_initial_registers

```cpp
struct drgn_error *(* prstatus_get_initial_registers)(struct drgn_program *prog, const void *prstatus, size_t size, struct drgn_register_state **ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/platform.h:342

Create a [drgn_register_state](drgn_register_state.md#drgn_register_state) from the contents of an ELF `NT_PRSTATUS` note.

This should check that `size` is sufficiently large, call [drgn_register_state_create()](RegisterState.md#drgn_register_state_create) with `interrupted = true`, and initialize it from `prstatus`.

Refer to `struct elf_prstatus` in the Linux kernel source for the format, and in particular, the `elf_gregset_t pr_reg` member. `elf_gregset_t` has an architecture-specific layout; on many architectures, it is identical to or a prefix of `struct pt_regs`. `pr_reg` is typically at offset 112 on 64-bit platforms and 72 on 32-bit platforms.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `prstatus` |  | Buffer of `NT_PRSTATUS` contents. |
| `size` |  | Size of `prstatus` in bytes. |
| `ret` |  | Returned registers. |

---

{#linux_kernel_get_initial_registers}

### linux_kernel_get_initial_registers

```cpp
struct drgn_error *(* linux_kernel_get_initial_registers)(const struct drgn_object *task_obj, struct drgn_register_state **ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/platform.h:342

Create a [drgn_register_state](drgn_register_state.md#drgn_register_state) from the `struct task_struct` of a scheduled-out Linux kernel thread.

This should should call [drgn_register_state_create()](RegisterState.md#drgn_register_state_create) with `interrupted = false` and initialize it from the saved thread context.

Refer to this architecture's implementation of `switch_to()` in the Linux kernel, which usually saves the context to one of these places:

* `struct thread_struct` (`struct task_struct::thread`).
* The thread stack (`struct task_struct::stack`).
* `struct thread_info` (either `struct task_struct::thread_info` or on the stack, see `task_thread_info()` in the Linux kernel).

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `task_obj` |  | `struct task_struct` object. |
| `ret` |  | Returned registers. |

---

{#apply_elf_reloc}

### apply_elf_reloc

```cpp
apply_elf_reloc_fn * apply_elf_reloc
```

Type: [`apply_elf_reloc_fn`](PlatformInternals.md#apply_elf_reloc_fn) *

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/platform.h:431

Apply an ELF relocation.

This should use the pre-defined drgn_reloc_addN() functions whenever possible. Note that this is only used to relocate debugging information sections, so typically only simple absolute and PC-relative relocations need to be implemented.

---

{#linux_kernel_live_direct_mapping_fallback}

### linux_kernel_live_direct_mapping_fallback

```cpp
struct drgn_error *(* linux_kernel_live_direct_mapping_fallback)(struct drgn_program *prog, uint64_t *address_ret, uint64_t *size_ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/platform.h:431

Return the address and size of the direct mapping virtual address range.

This is a hack which is only called when debugging a live Linux kernel older than v4.11.

---

{#linux_kernel_direct_mapping_offset}

### linux_kernel_direct_mapping_offset

```cpp
struct drgn_error *(* linux_kernel_direct_mapping_offset)(struct drgn_program *prog, uint64_t *address_ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/platform.h:431

Return the address of the direct mapping virtual address range.

This hook is used for [linux_helper_direct_mapping_offset()](api.md#linux_helper_direct_mapping_offset). It is optional: if not provided, we can infer it using a page table walk and a symbol from the direct mapping.

---

{#linux_kernel_pgtable_iterator_arch_create}

### linux_kernel_pgtable_iterator_arch_create

```cpp
struct drgn_error *(* linux_kernel_pgtable_iterator_arch_create)(struct drgn_program *, void **ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/platform.h:431

Allocate architecture-specific data for a Linux kernel page table iterator.

`*ret` must not be modified on error.

---

{#linux_kernel_pgtable_iterator_arch_destroy}

### linux_kernel_pgtable_iterator_arch_destroy

```cpp
void(* linux_kernel_pgtable_iterator_arch_destroy)(void *)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/platform.h:463

Free architecture-specific data for a Linux kernel page table iterator.

---

{#linux_kernel_pgtable_iterator_init}

### linux_kernel_pgtable_iterator_init

```cpp
void(* linux_kernel_pgtable_iterator_init)(struct drgn_program *, struct pgtable_iterator *)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/platform.h:473

(Re)initialize a Linux kernel page table iterator.

This is called each time that the iterator will be used to translate a contiguous range of virtual addresses from a single page table. It is called with [pgtable_iterator::pgtable](pgtable_iterator.md#pgtable) set to the address of the page table to use and [pgtable_iterator::virt_addr](pgtable_iterator.md#virt_addr) set to the starting virtual address to translate.

---

{#linux_kernel_pgtable_iterator_next}

### linux_kernel_pgtable_iterator_next

```cpp
pgtable_iterator_next_fn * linux_kernel_pgtable_iterator_next
```

Type: [`pgtable_iterator_next_fn`](PlatformInternals.md#pgtable_iterator_next_fn) *

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/platform.h:490

Iterate a (user or kernel) page table in the Linux kernel.

This is called after [linux_kernel_pgtable_iterator_init()](#linux_kernel_pgtable_iterator_init) to translate the starting address and may be called again without reinitializing the iterator to translate subsequent adjacent addresses in the same page table.

If the caller needs to translate from a different page table or virtual address, it will call [linux_kernel_pgtable_iterator_init()](#linux_kernel_pgtable_iterator_init) before calling this function again.

**See also**: [pgtable_iterator_next_fn](PlatformInternals.md#pgtable_iterator_next_fn)

---

{#linux_kernel_section_size_bits_fallback}

### linux_kernel_section_size_bits_fallback

```cpp
int(* linux_kernel_section_size_bits_fallback)(struct drgn_program *)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/platform.h:495

Get the value of `SECTION_SIZE_BITS` for Linux kernel versions before v5.13.

---

{#linux_kernel_max_physmem_bits_fallback}

### linux_kernel_max_physmem_bits_fallback

```cpp
int(* linux_kernel_max_physmem_bits_fallback)(struct drgn_program *)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/platform.h:504

Get the value of `MAX_PHYSMEM_BITS` for Linux kernel versions before v5.9.

If this is omitted but [linux_kernel_section_size_bits_fallback](#linux_kernel_section_size_bits_fallback) is defined, then this will be computed from `NR_SECTION_ROOTS` and `SECTION_SIZE_BITS` instead.

---

{#untagged_addr}

### untagged_addr

```cpp
uint64_t(* untagged_addr)(uint64_t addr)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/platform.h:510

Return the canonical form of a virtual address, i.e. apply any transformations that the CPU applies to the address before page table walking.

