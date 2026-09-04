{#drgn_orc_entry}

# drgn_orc_entry

```cpp
#include <orc.h>
```

```cpp
struct drgn_orc_entry
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/orc.h:40

## Public Attributes

| Return | Name | Description |
|--------|------|-------------|
| `int16_t` | [`sp_offset`](#sp_offset)  |  |
| `int16_t` | [`bp_offset`](#bp_offset)  |  |
| `uint16_t` | [`flags`](#flags-3)  | Bit layout by version: |

---

{#sp_offset}

### sp_offset

```cpp
int16_t sp_offset
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/orc.h:41

---

{#bp_offset}

### bp_offset

```cpp
int16_t bp_offset
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/orc.h:42

---

{#flags-3}

### flags

```cpp
uint16_t flags
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/orc.h:55

Bit layout by version:

Version  |0  |1  |2  |3  |4  |5  |6  |7  |8  |9  |10  |11
--------- | --------- | --------- | --------- | --------- | --------- | --------- | --------- | --------- | --------- | --------- | --------- | ---------
3  |sp_reg  |bp_reg  |type  |S
2  |sp_reg  |bp_reg  |type  |S  |E
1  |sp_reg  |bp_reg  |type  |E  |

S = signal E = end

