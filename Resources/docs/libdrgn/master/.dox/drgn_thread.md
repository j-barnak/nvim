{#drgn_thread}

# drgn_thread

```cpp
#include <program.h>
```

```cpp
struct drgn_thread
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.h:50

A thread in a program.

## Public Attributes

| Return | Name | Description |
|--------|------|-------------|
| struct [`drgn_program`](drgn_program.md#drgn_program) * | [`prog`](#prog)  |  |
| `uint32_t` | [`tid`](#tid)  |  |
| struct [`nstring`](nstring.md#nstring) | [`prstatus`](#prstatus)  |  |
| struct [`drgn_object`](drgn_object.md#drgn_object-1) | [`object`](#object-1)  |  |

---

{#prog}

### prog

```cpp
struct drgn_program * prog
```

Type: struct [`drgn_program`](drgn_program.md#drgn_program) *

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.h:51

---

{#tid}

### tid

```cpp
uint32_t tid
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.h:52

---

{#prstatus}

### prstatus

```cpp
struct nstring prstatus
```

Type: struct [`nstring`](nstring.md#nstring)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.h:53

---

{#object-1}

### object

```cpp
struct drgn_object object
```

Type: struct [`drgn_object`](drgn_object.md#drgn_object-1)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.h:54

