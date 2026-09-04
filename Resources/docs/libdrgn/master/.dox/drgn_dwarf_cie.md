{#drgn_dwarf_cie}

# drgn_dwarf_cie

```cpp
struct drgn_dwarf_cie
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:6855

## Public Attributes

| Return | Name | Description |
|--------|------|-------------|
| `uint8_t` | [`address_size`](#address_size)  |  |
| `uint8_t` | [`address_encoding`](#address_encoding)  |  |
| `bool` | [`have_augmentation_length`](#have_augmentation_length)  |  |
| `bool` | [`signal_frame`](#signal_frame)  |  |
| [`drgn_register_number`](CallFrameInformation.md#drgn_register_number) | [`return_address_register`](#return_address_register)  |  |
| `uint64_t` | [`code_alignment_factor`](#code_alignment_factor)  |  |
| `int64_t` | [`data_alignment_factor`](#data_alignment_factor)  |  |
| `const char *` | [`initial_instructions`](#initial_instructions)  |  |
| `size_t` | [`initial_instructions_size`](#initial_instructions_size)  |  |

---

{#address_size}

### address_size

```cpp
uint8_t address_size
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:6857

---

{#address_encoding}

### address_encoding

```cpp
uint8_t address_encoding
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:6859

---

{#have_augmentation_length}

### have_augmentation_length

```cpp
bool have_augmentation_length
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:6861

---

{#signal_frame}

### signal_frame

```cpp
bool signal_frame
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:6863

---

{#return_address_register}

### return_address_register

```cpp
drgn_register_number return_address_register
```

Type: [`drgn_register_number`](CallFrameInformation.md#drgn_register_number)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:6864

---

{#code_alignment_factor}

### code_alignment_factor

```cpp
uint64_t code_alignment_factor
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:6865

---

{#data_alignment_factor}

### data_alignment_factor

```cpp
int64_t data_alignment_factor
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:6866

---

{#initial_instructions}

### initial_instructions

```cpp
const char * initial_instructions
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:6867

---

{#initial_instructions_size}

### initial_instructions_size

```cpp
size_t initial_instructions_size
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/dwarf_info.c:6868

