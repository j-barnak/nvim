{#drgn_symbol_index}

# drgn_symbol_index

```cpp
#include <symbol.h>
```

```cpp
struct drgn_symbol_index
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/symbol.h:93

An index of symbols, supporting efficient lookup by name or address

While the dynamic symbol finding callback is a very flexible API, many use cases can be served best by simply providing drgn with a known symbol table to index. Drgn can efficiently implement the name and address lookup functions once, and provide a symbol finder implementation, so that clients need not redo this boilerplate.

In the interest of simplicity, the index is immutable once created. This allows us to use simple data structures. If the symbol table needs frequent updates, then registering a custom symbol finder should be preferred.

## Public Attributes

| Return | Name | Description |
|--------|------|-------------|
| struct [`drgn_symbol`](drgn_symbol.md#drgn_symbol) * | [`symbols`](#symbols-1)  | Array of symbols, in sorted order by address |
| `uint64_t *` | [`max_addrs`](#max_addrs)  | Array of max_addr, to aid address lookup |
| `uint32_t` | [`num_syms`](#num_syms-1)  | Number of symbols |
| `char *` | [`strings`](#strings)  | The buffer containing all symbol names |
| `uint32_t *` | [`name_sort`](#name_sort)  | Array of symbol indices, sorted by name. Used by the htab. |
| `struct drgn_symbol_name_table` | [`htab`](#htab)  | Map of symbol names to index |

---

{#symbols-1}

### symbols

```cpp
struct drgn_symbol * symbols
```

Type: struct [`drgn_symbol`](drgn_symbol.md#drgn_symbol) *

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/symbol.h:95

Array of symbols, in sorted order by address

---

{#max_addrs}

### max_addrs

```cpp
uint64_t * max_addrs
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/symbol.h:98

Array of max_addr, to aid address lookup

---

{#num_syms-1}

### num_syms

```cpp
uint32_t num_syms
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/symbol.h:101

Number of symbols

---

{#strings}

### strings

```cpp
char * strings
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/symbol.h:104

The buffer containing all symbol names

---

{#name_sort}

### name_sort

```cpp
uint32_t * name_sort
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/symbol.h:107

Array of symbol indices, sorted by name. Used by the htab.

---

{#htab}

### htab

```cpp
struct drgn_symbol_name_table htab
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/symbol.h:110

Map of symbol names to index

