{#pgtable_iterator}

# pgtable_iterator

```cpp
#include <platform.h>
```

```cpp
struct pgtable_iterator
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/platform.h:123

Page table iterator.

## Public Attributes

| Return | Name | Description |
|--------|------|-------------|
| `uint64_t` | [`pgtable`](#pgtable)  | Address of the top-level page table to iterate. |
| `uint64_t` | [`virt_addr`](#virt_addr)  | Current virtual address to translate. |
| `void *` | [`arch`](#arch-1)  | Architecture-specific data. |

---

{#pgtable}

### pgtable

```cpp
uint64_t pgtable
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/platform.h:125

Address of the top-level page table to iterate.

---

{#virt_addr}

### virt_addr

```cpp
uint64_t virt_addr
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/platform.h:127

Current virtual address to translate.

---

{#arch-1}

### arch

```cpp
void * arch
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/platform.h:129

Architecture-specific data.

