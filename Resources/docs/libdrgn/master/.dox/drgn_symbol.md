{#drgn_symbol}

# drgn_symbol

```cpp
#include <symbol.h>
```

```cpp
struct drgn_symbol
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/symbol.h:17

A [drgn_symbol](#drgn_symbol) represents an entry in a program's symbol table.

## Public Attributes

| Return | Name | Description |
|--------|------|-------------|
| `const char *` | [`name`](#name-4)  |  |
| `uint64_t` | [`address`](#address-1)  |  |
| `uint64_t` | [`size`](#size)  |  |
| enum [`drgn_symbol_binding`](drgn_symbol_binding.md#drgn_symbol_binding) | [`binding`](#binding)  |  |
| enum [`drgn_symbol_kind`](drgn_symbol_kind.md#drgn_symbol_kind) | [`kind`](#kind-1)  |  |
| enum [`drgn_lifetime`](drgn_lifetime.md#drgn_lifetime) | [`name_lifetime`](#name_lifetime)  |  |
| enum [`drgn_lifetime`](drgn_lifetime.md#drgn_lifetime) | [`lifetime`](#lifetime)  |  |

---

{#name-4}

### name

```cpp
const char * name
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/symbol.h:18

---

{#address-1}

### address

```cpp
uint64_t address
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/symbol.h:19

---

{#size}

### size

```cpp
uint64_t size
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/symbol.h:20

---

{#binding}

### binding

```cpp
enum drgn_symbol_binding binding
```

Type: enum [`drgn_symbol_binding`](drgn_symbol_binding.md#drgn_symbol_binding)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/symbol.h:21

---

{#kind-1}

### kind

```cpp
enum drgn_symbol_kind kind
```

Type: enum [`drgn_symbol_kind`](drgn_symbol_kind.md#drgn_symbol_kind)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/symbol.h:22

---

{#name_lifetime}

### name_lifetime

```cpp
enum drgn_lifetime name_lifetime
```

Type: enum [`drgn_lifetime`](drgn_lifetime.md#drgn_lifetime)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/symbol.h:23

---

{#lifetime}

### lifetime

```cpp
enum drgn_lifetime lifetime
```

Type: enum [`drgn_lifetime`](drgn_lifetime.md#drgn_lifetime)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/symbol.h:24

