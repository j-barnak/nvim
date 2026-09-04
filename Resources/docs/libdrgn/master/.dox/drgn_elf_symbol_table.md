{#drgn_elf_symbol_table}

# drgn_elf_symbol_table

```cpp
#include <elf_symtab.h>
```

```cpp
struct drgn_elf_symbol_table
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/elf_symtab.h:30

[Symbol](Symbol.md#symbol) table from an ELF file.

## Public Attributes

| Return | Name | Description |
|--------|------|-------------|
| struct [`drgn_elf_file`](drgn_elf_file.md#drgn_elf_file) * | [`file`](#file-1)  | File containing symbol table. `NULL` if not found yet. |
| `uint64_t` | [`bias`](#bias)  | Bias to apply to addresses from the file. |
| `const char *` | [`data`](#data-1)  | [Symbol](Symbol.md#symbol) table section data. |
| `size_t` | [`num_symbols`](#num_symbols)  | Number of symbols in table. |
| `size_t` | [`num_local_symbols`](#num_local_symbols)  | Number of local symbols in table. |
| `Elf_Data *` | [`strtab`](#strtab)  | String table section used by symbol table. |
| `Elf_Data *` | [`shndx`](#shndx)  | Optional `SHT_SYMTAB_SHNDX` section used by symbol table. |

---

{#file-1}

### file

```cpp
struct drgn_elf_file * file
```

Type: struct [`drgn_elf_file`](drgn_elf_file.md#drgn_elf_file) *

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/elf_symtab.h:32

File containing symbol table. `NULL` if not found yet.

---

{#bias}

### bias

```cpp
uint64_t bias
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/elf_symtab.h:34

Bias to apply to addresses from the file.

---

{#data-1}

### data

```cpp
const char * data
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/elf_symtab.h:36

[Symbol](Symbol.md#symbol) table section data.

---

{#num_symbols}

### num_symbols

```cpp
size_t num_symbols
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/elf_symtab.h:38

Number of symbols in table.

---

{#num_local_symbols}

### num_local_symbols

```cpp
size_t num_local_symbols
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/elf_symtab.h:40

Number of local symbols in table.

---

{#strtab}

### strtab

```cpp
Elf_Data * strtab
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/elf_symtab.h:42

String table section used by symbol table.

---

{#shndx}

### shndx

```cpp
Elf_Data * shndx
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/elf_symtab.h:44

Optional `SHT_SYMTAB_SHNDX` section used by symbol table.

