{#drgn_dwarf_index_cu}

# drgn_dwarf_index_cu

```cpp
struct drgn_dwarf_index_cu
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:77

DWARF compilation unit indexed in a [drgn_namespace_dwarf_index](drgn_namespace_dwarf_index.md#drgn_namespace_dwarf_index).

## Public Attributes

| Return | Name | Description |
|--------|------|-------------|
| struct [`drgn_elf_file`](drgn_elf_file.md#drgn_elf_file) * | [`file`](#file-2)  | File containing CU. |
| `const char *` | [`buf`](#buf-3)  | Address of CU data. |
| `size_t` | [`len`](#len-4)  | Length of CU data. |
| `uint8_t` | [`version`](#version-1)  | DWARF version from CU header. |
| `uint8_t` | [`unit_type`](#unit_type)  | `DW_UT_*` type from CU header. |
| `uint8_t` | [`address_size`](#address_size-1)  | Address size from CU header. |
| `bool` | [`is_64_bit`](#is_64_bit)  | Whether CU uses 64-bit DWARF format. |
| `enum drgn_section_index` | [`scn`](#scn-1)  | Section containing CU (DRGN_SCN_DEBUG_INFO or DRGN_SCN_DEBUG_TYPES). |
| `uint32_t *` | [`abbrev_decls`](#abbrev_decls)  | Mapping from DWARF abbreviation code to instructions for that abbreviation. |
| `size_t` | [`num_abbrev_decls`](#num_abbrev_decls)  | Number of abbreviation codes. |
| `const char *` | [`pending_abbrev`](#pending_abbrev)  | Pointer in .debug_abbrev for this CU. |
| union [`drgn_dwarf_index_cu`](#drgn_dwarf_index_cu) | [``](#unknown-13)  |  |
| `uint8_t *` | [`abbrev_insns`](#abbrev_insns)  | Buffer of [drgn_dwarf_index_abbrev_insn](api.md#drgn_dwarf_index_abbrev_insn) instructions for all abbreviation codes. |
| `const char *` | [`str_offsets`](#str_offsets)  | Pointer in `.debug_str_offsets` section to string offset entries for this CU. |
| `Dwarf_CU *` | [`libdw_cu`](#libdw_cu)  | libdw structure for this CU. |

---

{#file-2}

### file

```cpp
struct drgn_elf_file * file
```

Type: struct [`drgn_elf_file`](drgn_elf_file.md#drgn_elf_file) *

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:79

File containing CU.

---

{#buf-3}

### buf

```cpp
const char * buf
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:81

Address of CU data.

---

{#len-4}

### len

```cpp
size_t len
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:83

Length of CU data.

---

{#version-1}

### version

```cpp
uint8_t version
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:85

DWARF version from CU header.

---

{#unit_type}

### unit_type

```cpp
uint8_t unit_type
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:87

`DW_UT_*` type from CU header.

---

{#address_size-1}

### address_size

```cpp
uint8_t address_size
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:89

Address size from CU header.

---

{#is_64_bit}

### is_64_bit

```cpp
bool is_64_bit
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:91

Whether CU uses 64-bit DWARF format.

---

{#scn-1}

### scn

```cpp
enum drgn_section_index scn
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:96

Section containing CU (DRGN_SCN_DEBUG_INFO or DRGN_SCN_DEBUG_TYPES).

---

{#abbrev_decls}

### abbrev_decls

```cpp
uint32_t * abbrev_decls
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:109

Mapping from DWARF abbreviation code to instructions for that abbreviation.

This is indexed on the DWARF abbreviation code minus one. I.e., `abbrev_insns[abbrev_decls[abbrev_code - 1]]` is the first instruction for that abbreviation code.

Technically, abbreviation codes don't have to be sequential. In practice, GCC and Clang seem to always generate sequential codes starting at one, so we can get away with a flat array.

---

{#num_abbrev_decls}

### num_abbrev_decls

```cpp
size_t num_abbrev_decls
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:112

Number of abbreviation codes.

---

{#pending_abbrev}

### pending_abbrev

```cpp
const char * pending_abbrev
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:122

Pointer in .debug_abbrev for this CU.

This is only used before indexing, then it is replaced by `abbrev_decls`, `num_abbrev_decls`, and `abbrev_insns`. It is a union with `num_abbrev_decls` rather than one of the other two fields because that way we don't need to worry about accidentally freeing it.

---

{#unknown-13}

### 

```cpp
union drgn_dwarf_index_cu
```

Type: union [`drgn_dwarf_index_cu`](#drgn_dwarf_index_cu)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:123

---

{#abbrev_insns}

### abbrev_insns

```cpp
uint8_t * abbrev_insns
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:130

Buffer of [drgn_dwarf_index_abbrev_insn](api.md#drgn_dwarf_index_abbrev_insn) instructions for all abbreviation codes.

These are all stored in one array for cache locality.

---

{#str_offsets}

### str_offsets

```cpp
const char * str_offsets
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:135

Pointer in `.debug_str_offsets` section to string offset entries for this CU.

---

{#libdw_cu}

### libdw_cu

```cpp
Dwarf_CU * libdw_cu
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:137

libdw structure for this CU.

