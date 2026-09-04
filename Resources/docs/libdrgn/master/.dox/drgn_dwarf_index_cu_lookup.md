{#drgn_dwarf_index_cu_lookup}

# drgn_dwarf_index_cu_lookup

```cpp
struct drgn_dwarf_index_cu_lookup
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:141

Indexed CU lookup table entry.

## Public Attributes

| Return | Name | Description |
|--------|------|-------------|
| `uintptr_t` | [`buf`](#buf-4)  | Address of CU data ([drgn_dwarf_index_cu::buf](drgn_dwarf_index_cu.md#buf-3)). |
| `size_t` | [`index`](#index-4)  | Index of CU in [drgn_dwarf_info::index_cus](drgn_dwarf_info.md#index_cus). |

---

{#buf-4}

### buf

```cpp
uintptr_t buf
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:143

Address of CU data ([drgn_dwarf_index_cu::buf](drgn_dwarf_index_cu.md#buf-3)).

---

{#index-4}

### index

```cpp
size_t index
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:145

Index of CU in [drgn_dwarf_info::index_cus](drgn_dwarf_info.md#index_cus).

