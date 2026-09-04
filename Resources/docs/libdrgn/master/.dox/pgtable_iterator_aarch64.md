{#pgtable_iterator_aarch64}

# pgtable_iterator_aarch64

```cpp
struct pgtable_iterator_aarch64
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/arch_aarch64.c:410

## Public Attributes

| Return | Name | Description |
|--------|------|-------------|
| `uint64_t` | [`va_bits`](#va_bits-1)  |  |
| `uint64_t` | [`va_range_min`](#va_range_min)  |  |
| `uint64_t` | [`va_range_max`](#va_range_max)  |  |
| `int` | [`levels`](#levels-1)  |  |
| `uint16_t` | [`entries_per_level`](#entries_per_level)  |  |
| `uint16_t` | [`last_level_num_entries`](#last_level_num_entries)  |  |
| `uint64_t` | [`cached_virt_addr`](#cached_virt_addr-1)  |  |
| `uint64_t` | [`table`](#table)  |  |
| `uint64_t` | [`pa_low_mask`](#pa_low_mask)  |  |
| `uint64_t` | [`pa_high_mask`](#pa_high_mask)  |  |
| `int` | [`pa_high_shift`](#pa_high_shift)  |  |

---

{#va_bits-1}

### va_bits

```cpp
uint64_t va_bits
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/arch_aarch64.c:411

---

{#va_range_min}

### va_range_min

```cpp
uint64_t va_range_min
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/arch_aarch64.c:413

---

{#va_range_max}

### va_range_max

```cpp
uint64_t va_range_max
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/arch_aarch64.c:413

---

{#levels-1}

### levels

```cpp
int levels
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/arch_aarch64.c:414

---

{#entries_per_level}

### entries_per_level

```cpp
uint16_t entries_per_level
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/arch_aarch64.c:415

---

{#last_level_num_entries}

### last_level_num_entries

```cpp
uint16_t last_level_num_entries
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/arch_aarch64.c:416

---

{#cached_virt_addr-1}

### cached_virt_addr

```cpp
uint64_t cached_virt_addr
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/arch_aarch64.c:417

---

{#table}

### table

```cpp
uint64_t table[5]
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/arch_aarch64.c:418

---

{#pa_low_mask}

### pa_low_mask

```cpp
uint64_t pa_low_mask
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/arch_aarch64.c:419

---

{#pa_high_mask}

### pa_high_mask

```cpp
uint64_t pa_high_mask
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/arch_aarch64.c:420

---

{#pa_high_shift}

### pa_high_shift

```cpp
int pa_high_shift
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/arch_aarch64.c:421

