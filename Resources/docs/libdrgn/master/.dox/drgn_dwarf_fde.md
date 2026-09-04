{#drgn_dwarf_fde}

# drgn_dwarf_fde

```cpp
#include <dwarf_info.h>
```

```cpp
struct drgn_dwarf_fde
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.h:33

DWARF Frame Description Entry.

## Public Attributes

| Return | Name | Description |
|--------|------|-------------|
| `uint64_t` | [`initial_location`](#initial_location)  |  |
| `uint64_t` | [`address_range`](#address_range)  |  |
| `size_t` | [`cie`](#cie)  |  |
| `const char *` | [`instructions`](#instructions)  |  |
| `size_t` | [`instructions_size`](#instructions_size)  |  |

---

{#initial_location}

### initial_location

```cpp
uint64_t initial_location
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.h:34

---

{#address_range}

### address_range

```cpp
uint64_t address_range
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.h:35

---

{#cie}

### cie

```cpp
size_t cie
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.h:37

---

{#instructions}

### instructions

```cpp
const char * instructions
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.h:38

---

{#instructions_size}

### instructions_size

```cpp
size_t instructions_size
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.h:39

