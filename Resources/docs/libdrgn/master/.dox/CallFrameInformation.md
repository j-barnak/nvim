{#callframeinformation}

# Call frame information

> [`Internals`](Internals.md#internals)

Call frame information for stack unwinding.

This defines a generic representation for Call Frame Information (CFI), which describes how to determine the Canonical Frame Address (CFA) and previous register values while unwinding a stack trace.

## Classes

| Name | Description |
|------|-------------|
| [`drgn_cfi_rule`](drgn_cfi_rule.md#drgn_cfi_rule) | Rule for determining a single register value or CFA. |
| [`drgn_cfi_row`](drgn_cfi_row.md#drgn_cfi_row-1) | "Row" of call frame information, i.e., how to get the CFA and the previous value of each register at a single location in the program. |

## Macros

| Name | Description |
|------|-------------|
| [`DRGN_MAX_REGISTER_NUMBER`](#drgn_max_register_number)  | Maximum valid register number. |
| [`DRGN_REGISTER_NUMBER_UNKNOWN`](#drgn_register_number_unknown)  | Placeholder number for unknown register. |
| [`DRGN_CFI_ROW`](#drgn_cfi_row)  | Initializer for a static [drgn_cfi_row](drgn_cfi_row.md#drgn_cfi_row-1) given initializers for [drgn_cfi_row::reg_rules](drgn_cfi_row.md#reg_rules). |
| [`DRGN_CFI_SAME_VALUE_INIT`](#drgn_cfi_same_value_init)  | Initializer for a rule in [drgn_cfi_row::reg_rules](drgn_cfi_row.md#reg_rules) specifying that the register with the given number has the same value in the caller. |
| [`drgn_empty_cfi_row`](#drgn_empty_cfi_row)  | Static [drgn_cfi_row](drgn_cfi_row.md#drgn_cfi_row-1) with all rules set to [DRGN_CFI_RULE_UNDEFINED](api.md#drgn_cfi_rule_undefined). |
| [`_cleanup_cfi_row_`](#_cleanup_cfi_row_)  |  |

---

{#drgn_max_register_number}

### DRGN_MAX_REGISTER_NUMBER

```cpp
#define DRGN_MAX_REGISTER_NUMBER ((drgn_register_number)-3)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/cfi.h:42

Maximum valid register number.

---

{#drgn_register_number_unknown}

### DRGN_REGISTER_NUMBER_UNKNOWN

```cpp
#define DRGN_REGISTER_NUMBER_UNKNOWN ((drgn_register_number)-1)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/cfi.h:44

Placeholder number for unknown register.

---

{#drgn_cfi_row}

### DRGN_CFI_ROW

```cpp
#define DRGN_CFI_ROW(...) {						\
	.num_regs = (sizeof((struct drgn_cfi_rule []){ __VA_ARGS__ })	\
		     / sizeof(struct drgn_cfi_rule)),			\
	.reg_rules = { __VA_ARGS__ },					\
}
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/cfi.h:156

Initializer for a static [drgn_cfi_row](drgn_cfi_row.md#drgn_cfi_row-1) given initializers for [drgn_cfi_row::reg_rules](drgn_cfi_row.md#reg_rules).

---

{#drgn_cfi_same_value_init}

### DRGN_CFI_SAME_VALUE_INIT

```cpp
#define DRGN_CFI_SAME_VALUE_INIT(number) [(number)] = {						\
		.kind = DRGN_CFI_RULE_REGISTER_PLUS_OFFSET,	\
		.regno = (number),				\
	}
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/cfi.h:166

Initializer for a rule in [drgn_cfi_row::reg_rules](drgn_cfi_row.md#reg_rules) specifying that the register with the given number has the same value in the caller.

---

{#drgn_empty_cfi_row}

### drgn_empty_cfi_row

```cpp
#define drgn_empty_cfi_row ((struct drgn_cfi_row *)&drgn_empty_cfi_row_impl)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/cfi.h:176

Static [drgn_cfi_row](drgn_cfi_row.md#drgn_cfi_row-1) with all rules set to [DRGN_CFI_RULE_UNDEFINED](api.md#drgn_cfi_rule_undefined).

---

{#_cleanup_cfi_row_}

### _cleanup_cfi_row_

```cpp
#define _cleanup_cfi_row_ __attribute__((__cleanup__(drgn_cfi_row_destroyp)))
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/cfi.h:185

## Enumerations

| Name | Description |
|------|-------------|
| [`drgn_cfi_rule_kind`](#drgn_cfi_rule_kind)  | Kinds of CFI rules. |

---

{#drgn_cfi_rule_kind}

### drgn_cfi_rule_kind

```cpp
enum drgn_cfi_rule_kind
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/cfi.h:47

Kinds of CFI rules.

## Typedefs

| Return | Name | Description |
|--------|------|-------------|
| `uint16_t` | [`drgn_register_number`](#drgn_register_number)  | Numeric identifier for a register. |

---

{#drgn_register_number}

### drgn_register_number

```cpp
using drgn_register_number = uint16_t
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/cfi.h:39

Numeric identifier for a register.

These are only unique within an architecture, and they are not necessarily the same as the register numbers used by DWARF.

## Functions

| Return | Name | Description |
|--------|------|-------------|
| enum [`drgn_cfi_rule_kind`](drgn_cfi_rule_kind.md#drgn_cfi_rule_kind) | [`__attribute__`](#__attribute__-2)  |  |
| `void` | [`drgn_cfi_row_destroy`](#drgn_cfi_row_destroy) `static` `inline` | Free a [drgn_cfi_row](drgn_cfi_row.md#drgn_cfi_row-1). |
| `void` | [`drgn_cfi_row_destroyp`](#drgn_cfi_row_destroyp) `static` `inline` |  |
| `bool` | [`drgn_cfi_row_copy`](#drgn_cfi_row_copy)  | Copy the rules from one [drgn_cfi_row](drgn_cfi_row.md#drgn_cfi_row-1) to another. |
| `void` | [`drgn_cfi_row_get_cfa`](#drgn_cfi_row_get_cfa) `static` `inline` | Get the rule for the Canonical Frame Address in a [drgn_cfi_row](drgn_cfi_row.md#drgn_cfi_row-1). |
| `bool` | [`drgn_cfi_row_set_cfa`](#drgn_cfi_row_set_cfa)  | Set the rule for the Canonical Frame Address in a [drgn_cfi_row](drgn_cfi_row.md#drgn_cfi_row-1). |
| `void` | [`drgn_cfi_row_get_register`](#drgn_cfi_row_get_register)  | Get the rule for a register in a [drgn_cfi_row](drgn_cfi_row.md#drgn_cfi_row-1). |
| `bool` | [`drgn_cfi_row_set_register`](#drgn_cfi_row_set_register)  | Set the rule for a register in a [drgn_cfi_row](drgn_cfi_row.md#drgn_cfi_row-1). |

---

{#__attribute__-2}

### __attribute__

```cpp
enum drgn_cfi_rule_kind __attribute__((__packed__))
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/cfi.h:39

---

{#drgn_cfi_row_destroy}

### drgn_cfi_row_destroy

`static` `inline`

```cpp
static inline void drgn_cfi_row_destroy(struct drgn_cfi_row * row)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/cfi.h:179

Free a [drgn_cfi_row](drgn_cfi_row.md#drgn_cfi_row-1).

---

{#drgn_cfi_row_destroyp}

### drgn_cfi_row_destroyp

`static` `inline`

```cpp
static inline void drgn_cfi_row_destroyp(struct drgn_cfi_row ** rowp)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/cfi.h:186

---

{#drgn_cfi_row_copy}

### drgn_cfi_row_copy

```cpp
bool drgn_cfi_row_copy(struct drgn_cfi_row ** dst, const struct drgn_cfi_row * src)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/cfi.h:192

Copy the rules from one [drgn_cfi_row](drgn_cfi_row.md#drgn_cfi_row-1) to another.

---

{#drgn_cfi_row_get_cfa}

### drgn_cfi_row_get_cfa

`static` `inline`

```cpp
static inline void drgn_cfi_row_get_cfa(const struct drgn_cfi_row * row, struct drgn_cfi_rule * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/cfi.h:200

Get the rule for the Canonical Frame Address in a [drgn_cfi_row](drgn_cfi_row.md#drgn_cfi_row-1).

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `ret` | struct [`drgn_cfi_rule`](drgn_cfi_rule.md#drgn_cfi_rule) * | Returned rule. |

---

{#drgn_cfi_row_set_cfa}

### drgn_cfi_row_set_cfa

```cpp
bool drgn_cfi_row_set_cfa(struct drgn_cfi_row ** row, const struct drgn_cfi_rule * rule)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/cfi.h:212

Set the rule for the Canonical Frame Address in a [drgn_cfi_row](drgn_cfi_row.md#drgn_cfi_row-1).

#### Returns
`true` on success, `false` on failure to allocate memory.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `rule` | const struct [`drgn_cfi_rule`](drgn_cfi_rule.md#drgn_cfi_rule) * | Rule to set to. |

---

{#drgn_cfi_row_get_register}

### drgn_cfi_row_get_register

```cpp
void drgn_cfi_row_get_register(const struct drgn_cfi_row * row, drgn_register_number regno, struct drgn_cfi_rule * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/cfi.h:220

Get the rule for a register in a [drgn_cfi_row](drgn_cfi_row.md#drgn_cfi_row-1).

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `regno` | [`drgn_register_number`](#drgn_register_number) | [Register](Register.md#register) number. |

---

{#drgn_cfi_row_set_register}

### drgn_cfi_row_set_register

```cpp
bool drgn_cfi_row_set_register(struct drgn_cfi_row ** row, drgn_register_number regno, const struct drgn_cfi_rule * rule)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/cfi.h:231

Set the rule for a register in a [drgn_cfi_row](drgn_cfi_row.md#drgn_cfi_row-1).

#### Returns
`true` on success, `false` on failure to allocate memory.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `regno` | [`drgn_register_number`](#drgn_register_number) | [Register](Register.md#register) number. |
| `rule` | const struct [`drgn_cfi_rule`](drgn_cfi_rule.md#drgn_cfi_rule) * | Rule to set to. |

## Variables

| Return | Name | Description |
|--------|------|-------------|
| struct [`drgn_cfi_rule`](drgn_cfi_rule.md#drgn_cfi_rule) | [`__attribute__`](#__attribute__-3)  |  |
| const struct [`drgn_cfi_row`](drgn_cfi_row.md#drgn_cfi_row-1) | [`drgn_empty_cfi_row_impl`](#drgn_empty_cfi_row_impl)  |  |

---

{#__attribute__-3}

### __attribute__

```cpp
struct drgn_cfi_rule __attribute__
```

Type: struct [`drgn_cfi_rule`](drgn_cfi_rule.md#drgn_cfi_rule)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/cfi.h:123

---

{#drgn_empty_cfi_row_impl}

### drgn_empty_cfi_row_impl

```cpp
const struct drgn_cfi_row drgn_empty_cfi_row_impl
```

Type: const struct [`drgn_cfi_row`](drgn_cfi_row.md#drgn_cfi_row-1)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/cfi.h:172

