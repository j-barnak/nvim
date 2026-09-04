{#drgn_dwarf_cfi}

# drgn_dwarf_cfi

```cpp
#include <dwarf_info.h>
```

```cpp
struct drgn_dwarf_cfi
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.h:43

DWARF Call Frame Information.

## Public Attributes

| Return | Name | Description |
|--------|------|-------------|
| struct [`drgn_dwarf_cie`](drgn_dwarf_cie.md#drgn_dwarf_cie) * | [`cies`](#cies)  | Array of DWARF Common Information Entries. |
| struct [`drgn_dwarf_fde`](drgn_dwarf_fde.md#drgn_dwarf_fde) * | [`fdes`](#fdes)  | Array of DWARF Frame Description Entries sorted by initial_location. |
| `size_t` | [`num_fdes`](#num_fdes)  | Number of elements in [drgn_dwarf_cfi::fdes](#fdes). |

---

{#cies}

### cies

```cpp
struct drgn_dwarf_cie * cies
```

Type: struct [`drgn_dwarf_cie`](drgn_dwarf_cie.md#drgn_dwarf_cie) *

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.h:45

Array of DWARF Common Information Entries.

---

{#fdes}

### fdes

```cpp
struct drgn_dwarf_fde * fdes
```

Type: struct [`drgn_dwarf_fde`](drgn_dwarf_fde.md#drgn_dwarf_fde) *

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.h:49

Array of DWARF Frame Description Entries sorted by initial_location.

---

{#num_fdes}

### num_fdes

```cpp
size_t num_fdes
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.h:51

Number of elements in [drgn_dwarf_cfi::fdes](#fdes).

