{#drgn_cfi_row-1}

# drgn_cfi_row

```cpp
#include <cfi.h>
```

```cpp
struct drgn_cfi_row
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/cfi.h:136

"Row" of call frame information, i.e., how to get the CFA and the previous value of each register at a single location in the program.

A row may be allocated statically or on the heap. Static rows are created with [DRGN_CFI_ROW()](CallFrameInformation.md#drgn_cfi_row). The first time a static row would be modified (with [drgn_cfi_row_copy()](CallFrameInformation.md#drgn_cfi_row_copy), [drgn_cfi_row_set_cfa()](CallFrameInformation.md#drgn_cfi_row_set_cfa), or [drgn_cfi_row_set_register()](CallFrameInformation.md#drgn_cfi_row_set_register)), it is first copied to the heap. Subsequent modifications reuse the heap allocation, growing it if necessary. The allocation must be freed with drgn_cfi_row_destroy().

## Public Attributes

| Return | Name | Description |
|--------|------|-------------|
| `uint16_t` | [`allocated_rules`](#allocated_rules)  | Number of rules allocated, including the CFA rule. |
| `uint16_t` | [`num_regs`](#num_regs)  | Number of initialized elements in `reg_rules`. |
| struct [`drgn_cfi_rule`](drgn_cfi_rule.md#drgn_cfi_rule) | [`cfa_rule`](#cfa_rule)  | Canonical Frame Address rule. |
| struct [`drgn_cfi_rule`](drgn_cfi_rule.md#drgn_cfi_rule) | [`reg_rules`](#reg_rules)  | [Register](Register.md#register) rules. |

---

{#allocated_rules}

### allocated_rules

```cpp
uint16_t allocated_rules
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/cfi.h:143

Number of rules allocated, including the CFA rule.

If the row is statically allocated, then this is zero, even if `num_regs` is non-zero. Otherwise, it is at least `num_regs + 1`.

---

{#num_regs}

### num_regs

```cpp
uint16_t num_regs
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/cfi.h:145

Number of initialized elements in `reg_rules`.

---

{#cfa_rule}

### cfa_rule

```cpp
struct drgn_cfi_rule cfa_rule
```

Type: struct [`drgn_cfi_rule`](drgn_cfi_rule.md#drgn_cfi_rule)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/cfi.h:147

Canonical Frame Address rule.

---

{#reg_rules}

### reg_rules

```cpp
struct drgn_cfi_rule reg_rules[]
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/cfi.h:149

[Register](Register.md#register) rules.

