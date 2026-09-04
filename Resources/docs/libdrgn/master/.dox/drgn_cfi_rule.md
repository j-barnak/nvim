{#drgn_cfi_rule}

# drgn_cfi_rule

```cpp
#include <cfi.h>
```

```cpp
struct drgn_cfi_rule
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/cfi.h:90

Rule for determining a single register value or CFA.

## Public Attributes

| Return | Name | Description |
|--------|------|-------------|
| enum [`drgn_cfi_rule_kind`](drgn_cfi_rule_kind.md#drgn_cfi_rule_kind) | [`kind`](#kind-2)  | Rule kind. |
| `bool` | [`push_cfa`](#push_cfa)  | Whether to push the CFA before evaluating the DWARF expression for [DRGN_CFI_RULE_AT_DWARF_EXPRESSION](api.md#drgn_cfi_rule_at_dwarf_expression) or [DRGN_CFI_RULE_DWARF_EXPRESSION](api.md#drgn_cfi_rule_dwarf_expression). |
| [`drgn_register_number`](CallFrameInformation.md#drgn_register_number) | [`regno`](#regno-1)  | [Register](Register.md#register) number for [DRGN_CFI_RULE_REGISTER_PLUS_OFFSET](api.md#drgn_cfi_rule_register_plus_offset). |
| `int64_t` | [`offset`](#offset)  | Offset for [DRGN_CFI_RULE_AT_CFA_PLUS_OFFSET](api.md#drgn_cfi_rule_at_cfa_plus_offset), [DRGN_CFI_RULE_CFA_PLUS_OFFSET](api.md#drgn_cfi_rule_cfa_plus_offset), [DRGN_CFI_RULE_AT_REGISTER_PLUS_OFFSET](api.md#drgn_cfi_rule_at_register_plus_offset), [DRGN_CFI_RULE_AT_REGISTER_ADD_OFFSET](api.md#drgn_cfi_rule_at_register_add_offset), and [DRGN_CFI_RULE_REGISTER_PLUS_OFFSET](api.md#drgn_cfi_rule_register_plus_offset). |
| `uint64_t` | [`constant`](#constant)  | Constant for [DRGN_CFI_RULE_CONSTANT](api.md#drgn_cfi_rule_constant). |
| `const char *` | [`expr`](#expr)  | Pointer to expression data. |
| `size_t` | [`expr_size`](#expr_size)  | Size of [drgn_cfi_rule::expr](#expr). |
| union [`drgn_cfi_rule`](#drgn_cfi_rule) | [``](#unknown-9)  |  |

---

{#kind-2}

### kind

```cpp
enum drgn_cfi_rule_kind kind
```

Type: enum [`drgn_cfi_rule_kind`](drgn_cfi_rule_kind.md#drgn_cfi_rule_kind)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/cfi.h:92

Rule kind.

---

{#push_cfa}

### push_cfa

```cpp
bool push_cfa
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/cfi.h:98

Whether to push the CFA before evaluating the DWARF expression for [DRGN_CFI_RULE_AT_DWARF_EXPRESSION](api.md#drgn_cfi_rule_at_dwarf_expression) or [DRGN_CFI_RULE_DWARF_EXPRESSION](api.md#drgn_cfi_rule_dwarf_expression).

---

{#regno-1}

### regno

```cpp
drgn_register_number regno
```

Type: [`drgn_register_number`](CallFrameInformation.md#drgn_register_number)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/cfi.h:100

[Register](Register.md#register) number for [DRGN_CFI_RULE_REGISTER_PLUS_OFFSET](api.md#drgn_cfi_rule_register_plus_offset).

---

{#offset}

### offset

```cpp
int64_t offset
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/cfi.h:109

Offset for [DRGN_CFI_RULE_AT_CFA_PLUS_OFFSET](api.md#drgn_cfi_rule_at_cfa_plus_offset), [DRGN_CFI_RULE_CFA_PLUS_OFFSET](api.md#drgn_cfi_rule_cfa_plus_offset), [DRGN_CFI_RULE_AT_REGISTER_PLUS_OFFSET](api.md#drgn_cfi_rule_at_register_plus_offset), [DRGN_CFI_RULE_AT_REGISTER_ADD_OFFSET](api.md#drgn_cfi_rule_at_register_add_offset), and [DRGN_CFI_RULE_REGISTER_PLUS_OFFSET](api.md#drgn_cfi_rule_register_plus_offset).

---

{#constant}

### constant

```cpp
uint64_t constant
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/cfi.h:111

Constant for [DRGN_CFI_RULE_CONSTANT](api.md#drgn_cfi_rule_constant).

---

{#expr}

### expr

```cpp
const char * expr
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/cfi.h:118

Pointer to expression data.

---

{#expr_size}

### expr_size

```cpp
size_t expr_size
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/cfi.h:120

Size of [drgn_cfi_rule::expr](#expr).

---

{#unknown-9}

### 

```cpp
union drgn_cfi_rule
```

Type: union [`drgn_cfi_rule`](#drgn_cfi_rule)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/cfi.h:122

