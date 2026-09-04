{#registerstate}

# Register state

> [`Internals`](Internals.md#internals)

Buffer of processor register values.

This defines [drgn_register_state](drgn_register_state.md#drgn_register_state) for storing the values of processor registers.

Several macros defined here take a register identifier as defined in an architecture definition file. These are intended for use in the corresponding architecture support file. These macros also have function equivalents (with names ending in `_impl`) that take the register number, offset, and size instead.

## Classes

| Name | Description |
|------|-------------|
| [`drgn_register_state`](drgn_register_state.md#drgn_register_state) | State of processor registers (e.g., in a stack frame), including the program counter and Canonical Frame Address (some of which may not be known). |
| [`optional_uint64`](optional_uint64.md#optional_uint64) | A `uint64_t` which may or may not be present. |

## Macros

| Name | Description |
|------|-------------|
| [`DRGN_REGISTER_NUMBER`](#drgn_register_number-1)  | Return the internal register number of a register. |
| [`DRGN_REGISTER_OFFSET`](#drgn_register_offset)  | Return the offset of a register in the register buffer. |
| [`DRGN_REGISTER_SIZE`](#drgn_register_size)  | Return the size of a register in bytes. |
| [`DRGN_REGISTER_END`](#drgn_register_end)  | Return one past the last byte of a register in the register buffer. |
| [`drgn_register_state_create`](#drgn_register_state_create)  | Create a [drgn_register_state](drgn_register_state.md#drgn_register_state) large enough to store up to and including a given register. |
| [`drgn_register_state_set_pc_from_register`](#drgn_register_state_set_pc_from_register)  | Set the value of the program counter in a [drgn_register_state](drgn_register_state.md#drgn_register_state) from the value of a register and mark it as known. |
| [`drgn_register_state_get_u64`](#drgn_register_state_get_u64)  | Get the least significant 64 bits of a register in a [drgn_register_state](drgn_register_state.md#drgn_register_state). |
| [`drgn_register_state_set_from_buffer`](#drgn_register_state_set_from_buffer)  | Set the value of a register in a [drgn_register_state](drgn_register_state.md#drgn_register_state) from a buffer and mark it as known. |
| [`drgn_register_state_set_range_from_buffer`](#drgn_register_state_set_range_from_buffer)  | Set the values of a range of adjacent registers in a [drgn_register_state](drgn_register_state.md#drgn_register_state) from a buffer and mark them as known. |
| [`drgn_register_state_set_from_u64`](#drgn_register_state_set_from_u64)  | Set the value of a register in a [drgn_register_state](drgn_register_state.md#drgn_register_state) from a `uint64_t` and mark it as known. |

---

{#drgn_register_number-1}

### DRGN_REGISTER_NUMBER

```cpp
#define DRGN_REGISTER_NUMBER(id) DRGN_REGISTER_NUMBER__##id
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/register_state.h:93

Return the internal register number of a register.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `id` |  | [Register](Register.md#register) identifier. |

---

{#drgn_register_offset}

### DRGN_REGISTER_OFFSET

```cpp
#define DRGN_REGISTER_OFFSET(id) offsetof(struct drgn_arch_register_layout, id)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/register_state.h:100

Return the offset of a register in the register buffer.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `id` |  | [Register](Register.md#register) identifier. |

---

{#drgn_register_size}

### DRGN_REGISTER_SIZE

```cpp
#define DRGN_REGISTER_SIZE(id) sizeof(((struct drgn_arch_register_layout *)0)->id)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/register_state.h:107

Return the size of a register in bytes.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `id` |  | [Register](Register.md#register) identifier. |

---

{#drgn_register_end}

### DRGN_REGISTER_END

```cpp
#define DRGN_REGISTER_END(id) (DRGN_REGISTER_OFFSET(id) + DRGN_REGISTER_SIZE(id))
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/register_state.h:114

Return one past the last byte of a register in the register buffer.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `id` |  | [Register](Register.md#register) identifier. |

---

{#drgn_register_state_create}

### drgn_register_state_create

```cpp
#define drgn_register_state_create(last_reg, interrupted) drgn_register_state_create_impl(DRGN_REGISTER_END(last_reg),		\
					DRGN_REGISTER_NUMBER(last_reg) + 1,	\
					interrupted)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/register_state.h:128

Create a [drgn_register_state](drgn_register_state.md#drgn_register_state) large enough to store up to and including a given register.

#### Returns
New register state on success, `NULL` on failure to allocate memory.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `last_reg` |  | Identifier of last register to allocate. |
| `interrupted` |  | [drgn_register_state::interrupted](drgn_register_state.md#interrupted) |

---

{#drgn_register_state_set_pc_from_register}

### drgn_register_state_set_pc_from_register

```cpp
#define drgn_register_state_set_pc_from_register(prog, regs, reg) drgn_register_state_set_pc_from_register_impl(prog, regs,		\
						      DRGN_REGISTER_NUMBER(reg),\
						      DRGN_REGISTER_OFFSET(reg),\
						      DRGN_REGISTER_SIZE(reg))
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/register_state.h:227

Set the value of the program counter in a [drgn_register_state](drgn_register_state.md#drgn_register_state) from the value of a register and mark it as known.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `reg` |  | Identifier of register to set from. Value must be known. |

---

{#drgn_register_state_get_u64}

### drgn_register_state_get_u64

```cpp
#define drgn_register_state_get_u64(prog, regs, reg) drgn_register_state_get_u64_impl(prog, regs,			\
					 DRGN_REGISTER_NUMBER(reg),	\
					 DRGN_REGISTER_OFFSET(reg),	\
					 DRGN_REGISTER_SIZE(reg))
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/register_state.h:261

Get the least significant 64 bits of a register in a [drgn_register_state](drgn_register_state.md#drgn_register_state).

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `reg` |  | Identifier of register to get. |

---

{#drgn_register_state_set_from_buffer}

### drgn_register_state_set_from_buffer

```cpp
#define drgn_register_state_set_from_buffer(regs, reg, buf) drgn_register_state_set_from_buffer_impl(regs,				\
						 DRGN_REGISTER_NUMBER(reg),	\
						 DRGN_REGISTER_OFFSET(reg),	\
						 DRGN_REGISTER_SIZE(reg),	\
						 buf)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/register_state.h:287

Set the value of a register in a [drgn_register_state](drgn_register_state.md#drgn_register_state) from a buffer and mark it as known.

The buffer must be at least as large as the register.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `reg` |  | Identifier of register to set. Number must be less than [drgn_register_state::num_regs](drgn_register_state.md#num_regs-1). |

---

{#drgn_register_state_set_range_from_buffer}

### drgn_register_state_set_range_from_buffer

```cpp
#define drgn_register_state_set_range_from_buffer(regs, first_reg, last_reg, buf) drgn_register_state_set_range_from_buffer_impl(regs,				\
						       DRGN_REGISTER_NUMBER(first_reg),	\
						       DRGN_REGISTER_NUMBER(last_reg),	\
						       DRGN_REGISTER_OFFSET(first_reg),	\
						       DRGN_REGISTER_END(last_reg),	\
						       buf)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/register_state.h:316

Set the values of a range of adjacent registers in a [drgn_register_state](drgn_register_state.md#drgn_register_state) from a buffer and mark them as known.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `first_reg` |  | Identifier of first register to set (inclusive). Number must be less than or equal to number of `last_reg`. |
| `last_reg` |  | Identifier of last register to set (inclusive). Number must be less than [drgn_register_state::num_regs](drgn_register_state.md#num_regs-1). |

---

{#drgn_register_state_set_from_u64}

### drgn_register_state_set_from_u64

```cpp
#define drgn_register_state_set_from_u64(prog, regs, reg, value) drgn_register_state_set_from_u64_impl(prog, regs,			\
					      DRGN_REGISTER_NUMBER(reg),	\
					      DRGN_REGISTER_OFFSET(reg),	\
					      DRGN_REGISTER_SIZE(reg), value)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/register_state.h:347

Set the value of a register in a [drgn_register_state](drgn_register_state.md#drgn_register_state) from a `uint64_t` and mark it as known.

If the register is smaller than 8 bytes, then the value is truncated to the least significant bytes. If it is larger, then the value is zero-extended.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `reg` |  | Identifier of register to set. Number must be less than [drgn_register_state::num_regs](drgn_register_state.md#num_regs-1). |

## Functions

| Return | Name | Description |
|--------|------|-------------|
| struct [`drgn_register_state`](drgn_register_state.md#drgn_register_state) * | [`drgn_register_state_create_impl`](#drgn_register_state_create_impl)  |  |
| struct [`drgn_register_state`](drgn_register_state.md#drgn_register_state) * | [`drgn_register_state_dup`](#drgn_register_state_dup)  | Create a copy of a [drgn_register_state](drgn_register_state.md#drgn_register_state). |
| `void` | [`drgn_register_state_destroy`](#drgn_register_state_destroy) `static` `inline` | Free a [drgn_register_state](drgn_register_state.md#drgn_register_state). |
| `bool` | [`drgn_register_state_has_register`](#drgn_register_state_has_register)  | Get whether the value of a register is known in a [drgn_register_state](drgn_register_state.md#drgn_register_state). |
| `void` | [`drgn_register_state_set_has_register`](#drgn_register_state_set_has_register)  | Mark a register as known in a [drgn_register_state](drgn_register_state.md#drgn_register_state). |
| `void` | [`drgn_register_state_set_has_register_range`](#drgn_register_state_set_has_register_range)  | Mark a range of adjacent registers as known in a [drgn_register_state](drgn_register_state.md#drgn_register_state). |
| `void` | [`drgn_register_state_unset_has_register`](#drgn_register_state_unset_has_register)  | Mark a register as unknown in a [drgn_register_state](drgn_register_state.md#drgn_register_state). |
| struct [`optional_uint64`](optional_uint64.md#optional_uint64) | [`drgn_register_state_get_pc`](#drgn_register_state_get_pc)  | Get the value of the program counter in a [drgn_register_state](drgn_register_state.md#drgn_register_state). |
| `void` | [`drgn_register_state_set_pc`](#drgn_register_state_set_pc)  | Set the value of the program counter in a [drgn_register_state](drgn_register_state.md#drgn_register_state) and mark it as known. |
| `void` | [`drgn_register_state_set_pc_from_register_impl`](#drgn_register_state_set_pc_from_register_impl) `static` `inline` |  |
| struct [`optional_uint64`](optional_uint64.md#optional_uint64) | [`drgn_register_state_get_cfa`](#drgn_register_state_get_cfa)  | Get the value of the Canonical Frame Address in a [drgn_register_state](drgn_register_state.md#drgn_register_state). |
| `void` | [`drgn_register_state_set_cfa`](#drgn_register_state_set_cfa)  | Set the value of the Canonical Frame Address in a [drgn_register_state](drgn_register_state.md#drgn_register_state) and mark it as known. |
| struct [`optional_uint64`](optional_uint64.md#optional_uint64) | [`drgn_register_state_get_u64_impl`](#drgn_register_state_get_u64_impl)  |  |
| `void` | [`drgn_register_state_set_from_buffer_impl`](#drgn_register_state_set_from_buffer_impl) `static` `inline` |  |
| `void` | [`drgn_register_state_set_range_from_buffer_impl`](#drgn_register_state_set_range_from_buffer_impl) `static` `inline` |  |
| `void` | [`drgn_register_state_set_from_u64_impl`](#drgn_register_state_set_from_u64_impl) `static` `inline` |  |

---

{#drgn_register_state_create_impl}

### drgn_register_state_create_impl

```cpp
struct drgn_register_state * drgn_register_state_create_impl(uint32_t regs_size, uint16_t num_regs, bool interrupted)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/register_state.h:116

---

{#drgn_register_state_dup}

### drgn_register_state_dup

```cpp
struct drgn_register_state * drgn_register_state_dup(const struct drgn_register_state * regs)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/register_state.h:139

Create a copy of a [drgn_register_state](drgn_register_state.md#drgn_register_state).

#### Returns
New register state on success, `NULL` on failure to allocate memory.

---

{#drgn_register_state_destroy}

### drgn_register_state_destroy

`static` `inline`

```cpp
static inline void drgn_register_state_destroy(struct drgn_register_state * regs)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/register_state.h:143

Free a [drgn_register_state](drgn_register_state.md#drgn_register_state).

---

{#drgn_register_state_has_register}

### drgn_register_state_has_register

```cpp
bool drgn_register_state_has_register(const struct drgn_register_state * regs, drgn_register_number regno)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/register_state.h:154

Get whether the value of a register is known in a [drgn_register_state](drgn_register_state.md#drgn_register_state).

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `regno` | [`drgn_register_number`](CallFrameInformation.md#drgn_register_number) | [Register](Register.md#register) number to check. May be `DRGN_REGISTER_NUMBER_UNKNOWN`, in which case this always returns `false`. |

---

{#drgn_register_state_set_has_register}

### drgn_register_state_set_has_register

```cpp
void drgn_register_state_set_has_register(struct drgn_register_state * regs, drgn_register_number regno)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/register_state.h:164

Mark a register as known in a [drgn_register_state](drgn_register_state.md#drgn_register_state).

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `regno` | [`drgn_register_number`](CallFrameInformation.md#drgn_register_number) | [Register](Register.md#register) number to mark as known. Must be less than [drgn_register_state::num_regs](drgn_register_state.md#num_regs-1). |

---

{#drgn_register_state_set_has_register_range}

### drgn_register_state_set_has_register_range

```cpp
void drgn_register_state_set_has_register_range(struct drgn_register_state * regs, drgn_register_number first_regno, drgn_register_number last_regno)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/register_state.h:176

Mark a range of adjacent registers as known in a [drgn_register_state](drgn_register_state.md#drgn_register_state).

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `first_regno` | [`drgn_register_number`](CallFrameInformation.md#drgn_register_number) | First register number to mark as known (inclusive). Must be less than or equal to `last_regno`. |
| `last_regno` | [`drgn_register_number`](CallFrameInformation.md#drgn_register_number) | Last register number to mark as known (inclusive). Must be less than [drgn_register_state::num_regs](drgn_register_state.md#num_regs-1). |

---

{#drgn_register_state_unset_has_register}

### drgn_register_state_unset_has_register

```cpp
void drgn_register_state_unset_has_register(struct drgn_register_state * regs, drgn_register_number regno)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/register_state.h:185

Mark a register as unknown in a [drgn_register_state](drgn_register_state.md#drgn_register_state).

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `regno` | [`drgn_register_number`](CallFrameInformation.md#drgn_register_number) | [Register](Register.md#register) number to mark as unknown. |

---

{#drgn_register_state_get_pc}

### drgn_register_state_get_pc

```cpp
struct optional_uint64 drgn_register_state_get_pc(const struct drgn_register_state * regs)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/register_state.h:196

Get the value of the program counter in a [drgn_register_state](drgn_register_state.md#drgn_register_state).

---

{#drgn_register_state_set_pc}

### drgn_register_state_set_pc

```cpp
void drgn_register_state_set_pc(struct drgn_program * prog, struct drgn_register_state * regs, uint64_t pc)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/register_state.h:203

Set the value of the program counter in a [drgn_register_state](drgn_register_state.md#drgn_register_state) and mark it as known.

---

{#drgn_register_state_set_pc_from_register_impl}

### drgn_register_state_set_pc_from_register_impl

`static` `inline`

```cpp
static inline void drgn_register_state_set_pc_from_register_impl(struct drgn_program * prog, struct drgn_register_state * regs, drgn_register_number regno, size_t reg_offset, size_t reg_size)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/register_state.h:207

---

{#drgn_register_state_get_cfa}

### drgn_register_state_get_cfa

```cpp
struct optional_uint64 drgn_register_state_get_cfa(const struct drgn_register_state * regs)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/register_state.h:237

Get the value of the Canonical Frame Address in a [drgn_register_state](drgn_register_state.md#drgn_register_state).

---

{#drgn_register_state_set_cfa}

### drgn_register_state_set_cfa

```cpp
void drgn_register_state_set_cfa(struct drgn_program * prog, struct drgn_register_state * regs, uint64_t cfa)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/register_state.h:244

Set the value of the Canonical Frame Address in a [drgn_register_state](drgn_register_state.md#drgn_register_state) and mark it as known.

---

{#drgn_register_state_get_u64_impl}

### drgn_register_state_get_u64_impl

```cpp
struct optional_uint64 drgn_register_state_get_u64_impl(struct drgn_program * prog, struct drgn_register_state * regs, drgn_register_number regno, size_t reg_offset, size_t reg_size)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/register_state.h:249

---

{#drgn_register_state_set_from_buffer_impl}

### drgn_register_state_set_from_buffer_impl

`static` `inline`

```cpp
static inline void drgn_register_state_set_from_buffer_impl(struct drgn_register_state * regs, drgn_register_number regno, size_t reg_offset, size_t reg_size, const void * buf)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/register_state.h:269

---

{#drgn_register_state_set_range_from_buffer_impl}

### drgn_register_state_set_range_from_buffer_impl

`static` `inline`

```cpp
static inline void drgn_register_state_set_range_from_buffer_impl(struct drgn_register_state * regs, drgn_register_number first_regno, drgn_register_number last_regno, size_t first_reg_offset, size_t last_reg_end, const void * buf)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/register_state.h:295

---

{#drgn_register_state_set_from_u64_impl}

### drgn_register_state_set_from_u64_impl

`static` `inline`

```cpp
static inline void drgn_register_state_set_from_u64_impl(struct drgn_program * prog, struct drgn_register_state * regs, drgn_register_number regno, size_t reg_offset, size_t reg_size, uint64_t value)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/register_state.h:325

