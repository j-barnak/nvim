{#elfsymboltables}

# ELF symbol tables

> [`Internals`](Internals.md#internals)

ELF symbol table lookups.

## Classes

| Name | Description |
|------|-------------|
| [`drgn_elf_symbol_table`](drgn_elf_symbol_table.md#drgn_elf_symbol_table) | [Symbol](Symbol.md#symbol) table from an ELF file. |

## Functions

| Return | Name | Description |
|--------|------|-------------|
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_module_elf_symbols_search`](#drgn_module_elf_symbols_search)  | Find matching ELF symbols in a specific module. |

---

{#drgn_module_elf_symbols_search}

### drgn_module_elf_symbols_search

```cpp
struct drgn_error * drgn_module_elf_symbols_search(struct drgn_module * module, const char * name, uint64_t addr, enum drgn_find_symbol_flags flags, struct drgn_symbol_result_builder * builder)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/elf_symtab.h:49

Find matching ELF symbols in a specific module.

