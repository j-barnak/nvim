{#elf_symtab_search_state}

# elf_symtab_search_state

```cpp
struct elf_symtab_search_state
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/elf_symtab.c:544

## Public Attributes

| Return | Name | Description |
|--------|------|-------------|
| `const char *` | [`sizeless_name`](#sizeless_name)  |  |
| `uint64_t` | [`sizeless_addr`](#sizeless_addr)  |  |
| `size_t` | [`sizeless_sym_idx`](#sizeless_sym_idx)  |  |
| struct [`drgn_elf_symbol_table`](drgn_elf_symbol_table.md#drgn_elf_symbol_table) * | [`sizeless_symtab`](#sizeless_symtab)  |  |
| `Elf64_Sym` | [`sizeless_sym`](#sizeless_sym)  |  |
| struct [`drgn_symbol`](drgn_symbol.md#drgn_symbol) * | [`best_sym`](#best_sym)  |  |
| `uint64_t` | [`max_end_addr`](#max_end_addr)  |  |

---

{#sizeless_name}

### sizeless_name

```cpp
const char * sizeless_name
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/elf_symtab.c:551

---

{#sizeless_addr}

### sizeless_addr

```cpp
uint64_t sizeless_addr
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/elf_symtab.c:552

---

{#sizeless_sym_idx}

### sizeless_sym_idx

```cpp
size_t sizeless_sym_idx
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/elf_symtab.c:553

---

{#sizeless_symtab}

### sizeless_symtab

```cpp
struct drgn_elf_symbol_table * sizeless_symtab
```

Type: struct [`drgn_elf_symbol_table`](drgn_elf_symbol_table.md#drgn_elf_symbol_table) *

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/elf_symtab.c:554

---

{#sizeless_sym}

### sizeless_sym

```cpp
Elf64_Sym sizeless_sym
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/elf_symtab.c:555

---

{#best_sym}

### best_sym

```cpp
struct drgn_symbol * best_sym
```

Type: struct [`drgn_symbol`](drgn_symbol.md#drgn_symbol) *

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/elf_symtab.c:559

---

{#max_end_addr}

### max_end_addr

```cpp
uint64_t max_end_addr
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/elf_symtab.c:565

