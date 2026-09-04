{#drgn_dwarf_die_iterator}

# drgn_dwarf_die_iterator

```cpp
struct drgn_dwarf_die_iterator
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:2808

Iterator over DWARF DIEs in a [drgn_module](drgn_module.md#drgn_module).

## Public Attributes

| Return | Name | Description |
|--------|------|-------------|
| `struct dwarf_die_vector` | [`dies`](#dies)  | Stack of current DIE and its ancestors. |
| `Dwarf *` | [`dwarf`](#dwarf-2)  | Dwarf handle that we're iterating over. For split DWARF, this is the main file. |
| `const char *` | [`cu_end`](#cu_end)  | End of current CU (for bounds checking). For split DWARF, this is in the split file. |
| `Dwarf_Off` | [`next_cu_off`](#next_cu_off)  | Offset of next CU. For split DWARF, this is in the main file. |
| `bool` | [`debug_types`](#debug_types)  | Whether current CU is from .debug_types. |

---

{#dies}

### dies

```cpp
struct dwarf_die_vector dies
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:2810

Stack of current DIE and its ancestors.

---

{#dwarf-2}

### dwarf

```cpp
Dwarf * dwarf
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:2815

Dwarf handle that we're iterating over. For split DWARF, this is the main file.

---

{#cu_end}

### cu_end

```cpp
const char * cu_end
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:2820

End of current CU (for bounds checking). For split DWARF, this is in the split file.

---

{#next_cu_off}

### next_cu_off

```cpp
Dwarf_Off next_cu_off
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:2822

Offset of next CU. For split DWARF, this is in the main file.

---

{#debug_types}

### debug_types

```cpp
bool debug_types
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:2824

Whether current CU is from .debug_types.

