{#platforms-1}

# Platforms

> [`Internals`](Internals.md#internals)

[Platform](Platform.md#platform-2) internals.

drgn's external representation of a platform is [drgn_platform](drgn_platform.md#drgn_platform). Internally, architecture-specific handling is mainly in [drgn_architecture_info](drgn_architecture_info.md#drgn_architecture_info). See [drgn_architecture_info](drgn_architecture_info.md#drgn_architecture_info) for instructions on adding support for a new architecture.

## Classes

| Name | Description |
|------|-------------|
| [`drgn_register`](drgn_register.md#drgn_register) | A processor register. |
| [`drgn_register_layout`](drgn_register_layout.md#drgn_register_layout) | Offset and size of a register in [drgn_register_state::buf](drgn_register_state.md#buf-2). |
| [`drgn_relocating_section`](drgn_relocating_section.md#drgn_relocating_section) | ELF section to apply relocations to. |
| [`pgtable_iterator`](pgtable_iterator.md#pgtable_iterator) | Page table iterator. |
| [`drgn_architecture_info`](drgn_architecture_info.md#drgn_architecture_info) | Architecture-specific information and callbacks. |
| [`drgn_platform`](drgn_platform.md#drgn_platform) | The environment that a program runs on. |

## Macros

| Name | Description |
|------|-------------|
| [`DRGN_AARCH64_RA_SIGN_STATE_REGNO`](#drgn_aarch64_ra_sign_state_regno)  |  |
| [`DRGN_UNKNOWN_RELOCATION_TYPE`](#drgn_unknown_relocation_type)  | Create an error for an unknown ELF relocation type. |

---

{#drgn_aarch64_ra_sign_state_regno}

### DRGN_AARCH64_RA_SIGN_STATE_REGNO

```cpp
#define DRGN_AARCH64_RA_SIGN_STATE_REGNO 0
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/platform.h:57

---

{#drgn_unknown_relocation_type}

### DRGN_UNKNOWN_RELOCATION_TYPE

```cpp
#define DRGN_UNKNOWN_RELOCATION_TYPE(r_type) drgn_error_format(DRGN_ERROR_BAD_DATA,				\
			  "unknown relocation type %" PRIu32 " in %s; "	\
			  "please report this to %s",			\
			  (r_type), __func__, PACKAGE_BUGREPORT)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/platform.h:107

Create an error for an unknown ELF relocation type.

## Typedefs

| Return | Name | Description |
|--------|------|-------------|
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`apply_elf_reloc_fn`](#apply_elf_reloc_fn)  | Apply an ELF relocation. If `r_addend` is `NULL`, then this is an `ElfN_Rel` relocation. Otherwise, this is an `ElfN_Rela` relocation. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`pgtable_iterator_next_fn`](#pgtable_iterator_next_fn)  | Translate the current virtual address from a page table iterator. |

---

{#apply_elf_reloc_fn}

### apply_elf_reloc_fn

```cpp
using apply_elf_reloc_fn = struct drgn_error *
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/platform.h:118

Apply an ELF relocation. If `r_addend` is `NULL`, then this is an `ElfN_Rel` relocation. Otherwise, this is an `ElfN_Rela` relocation.

---

{#pgtable_iterator_next_fn}

### pgtable_iterator_next_fn

```cpp
using pgtable_iterator_next_fn = struct drgn_error *
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/platform.h:118

Translate the current virtual address from a page table iterator.

Abstractly, a virtual address lies in a range of addresses in the address space. A range may be a mapped page, a page table gap, or a range of invalid addresses (e.g., non-canonical addresses on x86-64). This finds the range containing the current virtual address (`it->virt_addr`), returns the first virtual address of that range and the physical address it maps to (if any), and updates `it->virt_addr` to the end of the range.

This does not merge contiguous ranges. For example, if two adjacent mapped pages have adjacent physical addresses, this returns each page separately. This makes it possible to distinguish between contiguous pages and "huge
pages" on architectures that support different page sizes. Similarly, if two adjacent entries at level 2 of the page table are empty, this returns each gap separately.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `it` |  | Iterator. |
| `virt_addr_ret` |  | Returned first virtual address in the range containing the current virtual address. |
| `phys_addr_ret` |  | Returned physical address that `virt_addr_ret` maps to, or `UINT64_MAX` if it is not mapped. |

## Functions

| Return | Name | Description |
|--------|------|-------------|
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_orc_to_cfi_x86_64`](#drgn_orc_to_cfi_x86_64)  |  |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_reloc_add64`](#drgn_reloc_add64)  |  |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_reloc_add32`](#drgn_reloc_add32)  |  |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_reloc_add16`](#drgn_reloc_add16)  |  |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_reloc_add8`](#drgn_reloc_add8)  |  |
| const struct [`drgn_register`](drgn_register.md#drgn_register) * | [`drgn_register_by_name_unknown`](#drgn_register_by_name_unknown)  | Implementation of [drgn_architecture_info::register_by_name](drgn_architecture_info.md#register_by_name) that always returns `NULL`. |
| `bool` | [`drgn_platforms_equal`](#drgn_platforms_equal) `static` `inline` |  |
| `bool` | [`drgn_platform_is_little_endian`](#drgn_platform_is_little_endian) `static` `inline` |  |
| `bool` | [`drgn_platform_bswap`](#drgn_platform_bswap) `static` `inline` |  |
| `bool` | [`drgn_platform_is_64_bit`](#drgn_platform_is_64_bit) `static` `inline` |  |
| `uint8_t` | [`drgn_platform_address_size`](#drgn_platform_address_size) `static` `inline` |  |
| `uint64_t` | [`drgn_platform_address_mask`](#drgn_platform_address_mask) `static` `inline` |  |
| `void` | [`drgn_platform_from_arch`](#drgn_platform_from_arch)  | Initialize a [drgn_platform](drgn_platform.md#drgn_platform) from an architecture, word size, and endianness. |
| `void` | [`drgn_platform_from_elf`](#drgn_platform_from_elf)  | Initialize a [drgn_platform](drgn_platform.md#drgn_platform) from an ELF header. |

---

{#drgn_orc_to_cfi_x86_64}

### drgn_orc_to_cfi_x86_64

```cpp
struct drgn_error * drgn_orc_to_cfi_x86_64(const struct drgn_orc_entry * orc, struct drgn_cfi_row ** row_ret, bool * interrupted_ret, drgn_register_number * ret_addr_regno_ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/platform.h:60

---

{#drgn_reloc_add64}

### drgn_reloc_add64

```cpp
struct drgn_error * drgn_reloc_add64(const struct drgn_relocating_section * relocating, uint64_t r_offset, const int64_t * r_addend, uint64_t addend)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/platform.h:94

---

{#drgn_reloc_add32}

### drgn_reloc_add32

```cpp
struct drgn_error * drgn_reloc_add32(const struct drgn_relocating_section * relocating, uint64_t r_offset, const int64_t * r_addend, uint32_t addend)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/platform.h:97

---

{#drgn_reloc_add16}

### drgn_reloc_add16

```cpp
struct drgn_error * drgn_reloc_add16(const struct drgn_relocating_section * relocating, uint64_t r_offset, const int64_t * r_addend, uint16_t addend)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/platform.h:100

---

{#drgn_reloc_add8}

### drgn_reloc_add8

```cpp
struct drgn_error * drgn_reloc_add8(const struct drgn_relocating_section * relocating, uint64_t r_offset, const int64_t * r_addend, uint8_t addend)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/platform.h:103

---

{#drgn_register_by_name_unknown}

### drgn_register_by_name_unknown

```cpp
const struct drgn_register * drgn_register_by_name_unknown(const char * name)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/platform.h:517

Implementation of [drgn_architecture_info::register_by_name](drgn_architecture_info.md#register_by_name) that always returns `NULL`.

---

{#drgn_platforms_equal}

### drgn_platforms_equal

`static` `inline`

```cpp
static inline bool drgn_platforms_equal(const struct drgn_platform * a, const struct drgn_platform * b)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/platform.h:536

---

{#drgn_platform_is_little_endian}

### drgn_platform_is_little_endian

`static` `inline`

```cpp
static inline bool drgn_platform_is_little_endian(const struct drgn_platform * platform)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/platform.h:543

---

{#drgn_platform_bswap}

### drgn_platform_bswap

`static` `inline`

```cpp
static inline bool drgn_platform_bswap(const struct drgn_platform * platform)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/platform.h:548

---

{#drgn_platform_is_64_bit}

### drgn_platform_is_64_bit

`static` `inline`

```cpp
static inline bool drgn_platform_is_64_bit(const struct drgn_platform * platform)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/platform.h:553

---

{#drgn_platform_address_size}

### drgn_platform_address_size

`static` `inline`

```cpp
static inline uint8_t drgn_platform_address_size(const struct drgn_platform * platform)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/platform.h:559

---

{#drgn_platform_address_mask}

### drgn_platform_address_mask

`static` `inline`

```cpp
static inline uint64_t drgn_platform_address_mask(const struct drgn_platform * platform)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/platform.h:565

---

{#drgn_platform_from_arch}

### drgn_platform_from_arch

```cpp
void drgn_platform_from_arch(const struct drgn_architecture_info * arch, bool is_64_bit, bool is_little_endian, struct drgn_platform * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/platform.h:577

Initialize a [drgn_platform](drgn_platform.md#drgn_platform) from an architecture, word size, and endianness.

The default flags for the architecture are used other than the word size and endianness.

---

{#drgn_platform_from_elf}

### drgn_platform_from_elf

```cpp
void drgn_platform_from_elf(GElf_Ehdr * ehdr, struct drgn_platform * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/platform.h:582

Initialize a [drgn_platform](drgn_platform.md#drgn_platform) from an ELF header.

## Variables

| Return | Name | Description |
|--------|------|-------------|
| struct [`drgn_error`](drgn_error.md#drgn_error) | [`drgn_invalid_relocation_offset`](#drgn_invalid_relocation_offset)  |  |
| const struct [`drgn_architecture_info`](drgn_architecture_info.md#drgn_architecture_info) | [`arch_info_unknown`](#arch_info_unknown)  |  |
| const struct [`drgn_architecture_info`](drgn_architecture_info.md#drgn_architecture_info) | [`arch_info_x86_64`](#arch_info_x86_64)  |  |
| const struct [`drgn_architecture_info`](drgn_architecture_info.md#drgn_architecture_info) | [`arch_info_i386`](#arch_info_i386)  |  |
| const struct [`drgn_architecture_info`](drgn_architecture_info.md#drgn_architecture_info) | [`arch_info_aarch64`](#arch_info_aarch64)  |  |
| const struct [`drgn_architecture_info`](drgn_architecture_info.md#drgn_architecture_info) | [`arch_info_arm`](#arch_info_arm)  |  |
| const struct [`drgn_architecture_info`](drgn_architecture_info.md#drgn_architecture_info) | [`arch_info_ppc64`](#arch_info_ppc64)  |  |
| const struct [`drgn_architecture_info`](drgn_architecture_info.md#drgn_architecture_info) | [`arch_info_riscv64`](#arch_info_riscv64)  |  |
| const struct [`drgn_architecture_info`](drgn_architecture_info.md#drgn_architecture_info) | [`arch_info_riscv32`](#arch_info_riscv32)  |  |
| const struct [`drgn_architecture_info`](drgn_architecture_info.md#drgn_architecture_info) | [`arch_info_s390x`](#arch_info_s390x)  |  |
| const struct [`drgn_architecture_info`](drgn_architecture_info.md#drgn_architecture_info) | [`arch_info_s390`](#arch_info_s390)  |  |
| const struct [`drgn_architecture_info`](drgn_architecture_info.md#drgn_architecture_info) | [`arch_info_loongarch64`](#arch_info_loongarch64)  |  |

---

{#drgn_invalid_relocation_offset}

### drgn_invalid_relocation_offset

```cpp
struct drgn_error drgn_invalid_relocation_offset
```

Type: struct [`drgn_error`](drgn_error.md#drgn_error)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/platform.h:72

---

{#arch_info_unknown}

### arch_info_unknown

```cpp
const struct drgn_architecture_info arch_info_unknown
```

Type: const struct [`drgn_architecture_info`](drgn_architecture_info.md#drgn_architecture_info)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/platform.h:519

---

{#arch_info_x86_64}

### arch_info_x86_64

```cpp
const struct drgn_architecture_info arch_info_x86_64
```

Type: const struct [`drgn_architecture_info`](drgn_architecture_info.md#drgn_architecture_info)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/platform.h:520

---

{#arch_info_i386}

### arch_info_i386

```cpp
const struct drgn_architecture_info arch_info_i386
```

Type: const struct [`drgn_architecture_info`](drgn_architecture_info.md#drgn_architecture_info)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/platform.h:521

---

{#arch_info_aarch64}

### arch_info_aarch64

```cpp
const struct drgn_architecture_info arch_info_aarch64
```

Type: const struct [`drgn_architecture_info`](drgn_architecture_info.md#drgn_architecture_info)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/platform.h:522

---

{#arch_info_arm}

### arch_info_arm

```cpp
const struct drgn_architecture_info arch_info_arm
```

Type: const struct [`drgn_architecture_info`](drgn_architecture_info.md#drgn_architecture_info)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/platform.h:523

---

{#arch_info_ppc64}

### arch_info_ppc64

```cpp
const struct drgn_architecture_info arch_info_ppc64
```

Type: const struct [`drgn_architecture_info`](drgn_architecture_info.md#drgn_architecture_info)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/platform.h:524

---

{#arch_info_riscv64}

### arch_info_riscv64

```cpp
const struct drgn_architecture_info arch_info_riscv64
```

Type: const struct [`drgn_architecture_info`](drgn_architecture_info.md#drgn_architecture_info)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/platform.h:525

---

{#arch_info_riscv32}

### arch_info_riscv32

```cpp
const struct drgn_architecture_info arch_info_riscv32
```

Type: const struct [`drgn_architecture_info`](drgn_architecture_info.md#drgn_architecture_info)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/platform.h:526

---

{#arch_info_s390x}

### arch_info_s390x

```cpp
const struct drgn_architecture_info arch_info_s390x
```

Type: const struct [`drgn_architecture_info`](drgn_architecture_info.md#drgn_architecture_info)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/platform.h:527

---

{#arch_info_s390}

### arch_info_s390

```cpp
const struct drgn_architecture_info arch_info_s390
```

Type: const struct [`drgn_architecture_info`](drgn_architecture_info.md#drgn_architecture_info)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/platform.h:528

---

{#arch_info_loongarch64}

### arch_info_loongarch64

```cpp
const struct drgn_architecture_info arch_info_loongarch64
```

Type: const struct [`drgn_architecture_info`](drgn_architecture_info.md#drgn_architecture_info)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/platform.h:529

