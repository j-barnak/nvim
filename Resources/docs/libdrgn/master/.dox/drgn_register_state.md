{#drgn_register_state}

# drgn_register_state

```cpp
#include <register_state.h>
```

```cpp
struct drgn_register_state
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/register_state.h:49

State of processor registers (e.g., in a stack frame), including the program counter and Canonical Frame Address (some of which may not be known).

## Public Attributes

| Return | Name | Description |
|--------|------|-------------|
| struct [`drgn_module`](drgn_module.md#drgn_module) * | [`module`](#module-2)  | Cached [drgn_module](drgn_module.md#drgn_module) that contains the program counter. |
| `uint32_t` | [`regs_size`](#regs_size)  | Total size of registers allocated in [drgn_register_state::buf](#buf-2). |
| `uint16_t` | [`num_regs`](#num_regs-1)  | Number of registers allocated in [drgn_register_state::buf](#buf-2). |
| `bool` | [`interrupted`](#interrupted)  | Whether this frame was interrupted (e.g., by a signal). |
| `uint64_t` | [`_pc`](#_pc)  | [Program](Program.md#program) counter. Access with [drgn_register_state_get_pc()](RegisterState.md#drgn_register_state_get_pc). |
| `uint64_t` | [`_cfa`](#_cfa)  | Canonical Frame Address. Access with [drgn_register_state_get_cfa()](RegisterState.md#drgn_register_state_get_cfa). |
| [`unsigned`](api.md#unsigned) char | [`buf`](#buf-2)  | Buffer of register values followed by bitset indicating which register values are known. |

---

{#module-2}

### module

```cpp
struct drgn_module * module
```

Type: struct [`drgn_module`](drgn_module.md#drgn_module) *

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/register_state.h:56

Cached [drgn_module](drgn_module.md#drgn_module) that contains the program counter.

This is `NULL` if the program counter is not known or if the containing module could not be found.

---

{#regs_size}

### regs_size

```cpp
uint32_t regs_size
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/register_state.h:58

Total size of registers allocated in [drgn_register_state::buf](#buf-2).

---

{#num_regs-1}

### num_regs

```cpp
uint16_t num_regs
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/register_state.h:60

Number of registers allocated in [drgn_register_state::buf](#buf-2).

---

{#interrupted}

### interrupted

```cpp
bool interrupted
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/register_state.h:62

Whether this frame was interrupted (e.g., by a signal).

---

{#_pc}

### _pc

```cpp
uint64_t _pc
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/register_state.h:64

[Program](Program.md#program) counter. Access with [drgn_register_state_get_pc()](RegisterState.md#drgn_register_state_get_pc).

---

{#_cfa}

### _cfa

```cpp
uint64_t _cfa
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/register_state.h:69

Canonical Frame Address. Access with [drgn_register_state_get_cfa()](RegisterState.md#drgn_register_state_get_cfa).

---

{#buf-2}

### buf

```cpp
unsigned char buf[]
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/register_state.h:85

Buffer of register values followed by bitset indicating which register values are known.

The layout of the register values is architecture-specific and defined by DRGN_ARCH_REGISTER_LAYOUT.

Bit 0 of the bitset is whether the PC is known, bit 1 is whether the CFA is known, and the remaining [drgn_register_state::num_regs](#num_regs-1) bits are whether each register is known.

Registers beyond [drgn_register_state::regs_size](#regs_size)/[drgn_register_state::num_regs](#num_regs-1) are not allocated here and are assumed to be unknown.

