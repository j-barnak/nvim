{#drgn_module_dwarf_info}

# drgn_module_dwarf_info

```cpp
#include <dwarf_info.h>
```

```cpp
struct drgn_module_dwarf_info
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.h:55

DWARF debugging information for a [drgn_module](drgn_module.md#drgn_module).

## Public Attributes

| Return | Name | Description |
|--------|------|-------------|
| struct [`drgn_dwarf_cfi`](drgn_dwarf_cfi.md#drgn_dwarf_cfi) | [`debug_frame`](#debug_frame)  | Call Frame Information from .debug_frame. |
| struct [`drgn_dwarf_cfi`](drgn_dwarf_cfi.md#drgn_dwarf_cfi) | [`eh_frame`](#eh_frame)  | Call Frame Information from .eh_frame. |
| `uint64_t` | [`pcrel_base`](#pcrel_base)  | Base for `DW_EH_PE_pcrel`. |
| `uint64_t` | [`textrel_base`](#textrel_base)  | Base for `DW_EH_PE_textrel`. |
| `uint64_t` | [`datarel_base`](#datarel_base)  | Base for `DW_EH_PE_datarel`. |

---

{#debug_frame}

### debug_frame

```cpp
struct drgn_dwarf_cfi debug_frame
```

Type: struct [`drgn_dwarf_cfi`](drgn_dwarf_cfi.md#drgn_dwarf_cfi)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.h:57

Call Frame Information from .debug_frame.

---

{#eh_frame}

### eh_frame

```cpp
struct drgn_dwarf_cfi eh_frame
```

Type: struct [`drgn_dwarf_cfi`](drgn_dwarf_cfi.md#drgn_dwarf_cfi)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.h:59

Call Frame Information from .eh_frame.

---

{#pcrel_base}

### pcrel_base

```cpp
uint64_t pcrel_base
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.h:61

Base for `DW_EH_PE_pcrel`.

---

{#textrel_base}

### textrel_base

```cpp
uint64_t textrel_base
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.h:63

Base for `DW_EH_PE_textrel`.

---

{#datarel_base}

### datarel_base

```cpp
uint64_t datarel_base
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.h:65

Base for `DW_EH_PE_datarel`.

