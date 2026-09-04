{#drgn_module_orc_info}

# drgn_module_orc_info

```cpp
#include <orc_info.h>
```

```cpp
struct drgn_module_orc_info
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/orc_info.h:30

ORC unwinder data for a [drgn_module](drgn_module.md#drgn_module).

## Public Attributes

| Return | Name | Description |
|--------|------|-------------|
| struct [`uint64_range`](uint64_range.md#uint64_range) * | [`preferred`](#preferred)  | Ranges where unwinding with ORC should be preferred over DWARF CFI, sorted by start address. |
| `size_t` | [`num_preferred`](#num_preferred)  | Number of ranges in [preferred](#preferred). |
| `uint64_t` | [`pc_base`](#pc_base)  | Base for calculating program counter corresponding to an ORC unwinder entry. |
| `int32_t *` | [`pc_offsets`](#pc_offsets)  | Offsets for calculating program counter corresponding to an ORC unwinder entry. |
| struct [`drgn_orc_entry`](drgn_orc_entry.md#drgn_orc_entry) * | [`entries`](#entries)  | ORC unwinder entries. |
| [`unsigned`](api.md#unsigned) int | [`num_entries`](#num_entries)  | Number of ORC unwinder entries. |
| `int` | [`version`](#version)  | Version of the ORC format. See [orc.h](#orch). |
| `bool` | [`bswap`](#bswap-1)  | Whether to byte swap data |

---

{#preferred}

### preferred

```cpp
struct uint64_range * preferred
```

Type: struct [`uint64_range`](uint64_range.md#uint64_range) *

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/orc_info.h:38

Ranges where unwinding with ORC should be preferred over DWARF CFI, sorted by start address.

ORC may be preferred if configured by the user or for special ORC entries; see drgn_raw_orc_entry_is_preferred().

---

{#num_preferred}

### num_preferred

```cpp
size_t num_preferred
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/orc_info.h:40

Number of ranges in [preferred](#preferred).

---

{#pc_base}

### pc_base

```cpp
uint64_t pc_base
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/orc_info.h:50

Base for calculating program counter corresponding to an ORC unwinder entry.

This is the address of the `.orc_unwind_ip` ELF section. It is the actual loaded location, with any bias already applied.

**See also**: [drgn_module_orc_info::entries](#entries)

---

{#pc_offsets}

### pc_offsets

```cpp
int32_t * pc_offsets
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/orc_info.h:60

Offsets for calculating program counter corresponding to an ORC unwinder entry.

This is the contents of the `.orc_unwind_ip` ELF section, byte swapped to the host's byte order if necessary.

**See also**: [drgn_module_orc_info::entries](#entries)

---

{#entries}

### entries

```cpp
struct drgn_orc_entry * entries
```

Type: struct [`drgn_orc_entry`](drgn_orc_entry.md#drgn_orc_entry) *

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/orc_info.h:72

ORC unwinder entries.

This is the contents of the `.orc_unwind` ELF section, byte swapped to the host's byte order and normalized to the latest version of the format if necessary.

Entry `i` specifies how to unwind the stack if `orc_pc(i) <= PC < orc_pc(i + 1)`, where `orc_pc(i) = pc_base + 4 * i + pc_offsets[i]`.

---

{#num_entries}

### num_entries

```cpp
unsigned int num_entries
```

Type: [`unsigned`](api.md#unsigned) int

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/orc_info.h:74

Number of ORC unwinder entries.

---

{#version}

### version

```cpp
int version
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/orc_info.h:76

Version of the ORC format. See [orc.h](#orch).

---

{#bswap-1}

### bswap

```cpp
bool bswap
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/orc_info.h:78

Whether to byte swap data

