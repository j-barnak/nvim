{#symbols}

# Symbols

[Symbol](Symbol.md#symbol) table entries.

**See also**: [drgn_program_find_symbol_by_address()](Programs.md#drgn_program_find_symbol_by_address)

## Enumerations

| Name | Description |
|------|-------------|
| [`drgn_symbol_binding`](#drgn_symbol_binding)  | [Symbol](Symbol.md#symbol) linkage behavior and visibility. |
| [`drgn_symbol_kind`](#drgn_symbol_kind)  | Kind of entity represented by a symbol. |
| [`drgn_lifetime`](#drgn_lifetime)  | Describes the lifetime of an object provided to drgn |

---

{#drgn_symbol_binding}

### drgn_symbol_binding

```cpp
enum drgn_symbol_binding
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:4097

[Symbol](Symbol.md#symbol) linkage behavior and visibility.

---

{#drgn_symbol_kind}

### drgn_symbol_kind

```cpp
enum drgn_symbol_kind
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:4111

Kind of entity represented by a symbol.

---

{#drgn_lifetime}

### drgn_lifetime

```cpp
enum drgn_lifetime
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:4127

Describes the lifetime of an object provided to drgn

## Functions

| Return | Name | Description |
|--------|------|-------------|
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_symbol_create`](#drgn_symbol_create)  | Create a new [drgn_symbol](drgn_symbol.md#drgn_symbol) with the given values |
| `void` | [`drgn_symbol_destroy`](#drgn_symbol_destroy)  | Destroy a [drgn_symbol](drgn_symbol.md#drgn_symbol). |
| `void` | [`drgn_symbols_destroy`](#drgn_symbols_destroy)  | Destroy each [drgn_symbol](drgn_symbol.md#drgn_symbol) in @syms, and free the array. |
| `const char *` | [`drgn_symbol_name`](#drgn_symbol_name)  | Get the name of a [drgn_symbol](drgn_symbol.md#drgn_symbol). |
| `uint64_t` | [`drgn_symbol_address`](#drgn_symbol_address)  | Get the start address of a [drgn_symbol](drgn_symbol.md#drgn_symbol). |
| `uint64_t` | [`drgn_symbol_size`](#drgn_symbol_size)  | Get the size in bytes of a [drgn_symbol](drgn_symbol.md#drgn_symbol). |
| enum [`drgn_symbol_binding`](drgn_symbol_binding.md#drgn_symbol_binding) | [`drgn_symbol_binding`](#drgn_symbol_binding-1)  | Get the binding of a [drgn_symbol](drgn_symbol.md#drgn_symbol). |
| enum [`drgn_symbol_kind`](drgn_symbol_kind.md#drgn_symbol_kind) | [`drgn_symbol_kind`](#drgn_symbol_kind-1)  | Get the kind of a [drgn_symbol](drgn_symbol.md#drgn_symbol). |
| `bool` | [`drgn_symbol_eq`](#drgn_symbol_eq)  | Return whether two symbols are identical. |

---

{#drgn_symbol_create}

### drgn_symbol_create

```cpp
struct drgn_error * drgn_symbol_create(const char * name, uint64_t address, uint64_t size, enum drgn_symbol_binding binding, enum drgn_symbol_kind kind, enum drgn_lifetime name_lifetime, struct drgn_symbol ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:4160

Create a new [drgn_symbol](drgn_symbol.md#drgn_symbol) with the given values

All parameters should be self-explanatory, except for *name_lifetime*. Clients can use this to describe how drgn should treat the string *name*. Strings with lifetime `STATIC` will never be copied or freed. Strings with lifetime `OWNED` will always be copied or and freed with the symbol. Strings with lifetime EXTERNAL will not be freed, but if the [Symbol](Symbol.md#symbol) is copied, they will be copied.

---

{#drgn_symbol_destroy}

### drgn_symbol_destroy

```cpp
void drgn_symbol_destroy(struct drgn_symbol * sym)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:4165

Destroy a [drgn_symbol](drgn_symbol.md#drgn_symbol).

---

{#drgn_symbols_destroy}

### drgn_symbols_destroy

```cpp
void drgn_symbols_destroy(struct drgn_symbol ** syms, size_t count)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:4175

Destroy each [drgn_symbol](drgn_symbol.md#drgn_symbol) in @syms, and free the array.

This will ignore any `NULL` entry in the array, allowing you to take ownership of any symbol from the array prior to freeing the rest. For each symbol you take ownership of, you must free it with [drgn_symbol_destroy()](#drgn_symbol_destroy).

---

{#drgn_symbol_name}

### drgn_symbol_name

```cpp
const char * drgn_symbol_name(struct drgn_symbol * sym)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:4183

Get the name of a [drgn_symbol](drgn_symbol.md#drgn_symbol).

The returned string is valid until `sym` is destroyed. It should not be freed.

---

{#drgn_symbol_address}

### drgn_symbol_address

```cpp
uint64_t drgn_symbol_address(struct drgn_symbol * sym)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:4186

Get the start address of a [drgn_symbol](drgn_symbol.md#drgn_symbol).

---

{#drgn_symbol_size}

### drgn_symbol_size

```cpp
uint64_t drgn_symbol_size(struct drgn_symbol * sym)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:4189

Get the size in bytes of a [drgn_symbol](drgn_symbol.md#drgn_symbol).

---

{#drgn_symbol_binding-1}

### drgn_symbol_binding

```cpp
enum drgn_symbol_binding drgn_symbol_binding(struct drgn_symbol * sym)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:4192

Get the binding of a [drgn_symbol](drgn_symbol.md#drgn_symbol).

---

{#drgn_symbol_kind-1}

### drgn_symbol_kind

```cpp
enum drgn_symbol_kind drgn_symbol_kind(struct drgn_symbol * sym)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:4195

Get the kind of a [drgn_symbol](drgn_symbol.md#drgn_symbol).

---

{#drgn_symbol_eq}

### drgn_symbol_eq

```cpp
bool drgn_symbol_eq(struct drgn_symbol * a, struct drgn_symbol * b)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:4198

Return whether two symbols are identical.

