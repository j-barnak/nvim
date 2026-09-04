{#drgn_stack_trace}

# drgn_stack_trace

```cpp
#include <stack_trace.h>
```

```cpp
struct drgn_stack_trace
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/stack_trace.h:37

## Public Attributes

| Return | Name | Description |
|--------|------|-------------|
| struct [`drgn_program`](drgn_program.md#drgn_program) * | [`prog`](#prog-7)  |  |
| `size_t` | [`num_frames`](#num_frames)  |  |
| struct [`drgn_stack_frame`](drgn_stack_frame.md#drgn_stack_frame) | [`frames`](#frames)  |  |

---

{#prog-7}

### prog

```cpp
struct drgn_program * prog
```

Type: struct [`drgn_program`](drgn_program.md#drgn_program) *

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/stack_trace.h:38

---

{#num_frames}

### num_frames

```cpp
size_t num_frames
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/stack_trace.h:39

---

{#frames}

### frames

```cpp
struct drgn_stack_frame frames[]
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/stack_trace.h:40

