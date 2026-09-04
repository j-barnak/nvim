{#drgn_dwarf_expression_context}

# drgn_dwarf_expression_context

```cpp
struct drgn_dwarf_expression_context
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:3788

## Public Attributes

| Return | Name | Description |
|--------|------|-------------|
| struct [`binary_buffer`](binary_buffer.md#binary_buffer) | [`bb`](#bb-3)  |  |
| `const char *` | [`start`](#start-4)  |  |
| struct [`drgn_program`](drgn_program.md#drgn_program) * | [`prog`](#prog-13)  |  |
| struct [`drgn_elf_file`](drgn_elf_file.md#drgn_elf_file) * | [`file`](#file-7)  |  |
| `uint8_t` | [`address_size`](#address_size-2)  |  |
| `Dwarf_Die` | [`cu_die`](#cu_die)  |  |
| `const char *` | [`cu_addr_base`](#cu_addr_base)  |  |
| `Dwarf_Die *` | [`function`](#function)  |  |
| const struct [`drgn_register_state`](drgn_register_state.md#drgn_register_state) * | [`regs`](#regs-1)  |  |

---

{#bb-3}

### bb

```cpp
struct binary_buffer bb
```

Type: struct [`binary_buffer`](binary_buffer.md#binary_buffer)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:3789

---

{#start-4}

### start

```cpp
const char * start
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:3790

---

{#prog-13}

### prog

```cpp
struct drgn_program * prog
```

Type: struct [`drgn_program`](drgn_program.md#drgn_program) *

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:3791

---

{#file-7}

### file

```cpp
struct drgn_elf_file * file
```

Type: struct [`drgn_elf_file`](drgn_elf_file.md#drgn_elf_file) *

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:3792

---

{#address_size-2}

### address_size

```cpp
uint8_t address_size
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:3793

---

{#cu_die}

### cu_die

```cpp
Dwarf_Die cu_die
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:3794

---

{#cu_addr_base}

### cu_addr_base

```cpp
const char * cu_addr_base
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:3795

---

{#function}

### function

```cpp
Dwarf_Die * function
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:3796

---

{#regs-1}

### regs

```cpp
const struct drgn_register_state * regs
```

Type: const struct [`drgn_register_state`](drgn_register_state.md#drgn_register_state) *

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:3797

