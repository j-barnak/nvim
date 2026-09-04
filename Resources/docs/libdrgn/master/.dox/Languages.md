{#languages}

# Languages

Programming languages.

## Functions

| Return | Name | Description |
|--------|------|-------------|
| `const char *` | [`drgn_language_name`](#drgn_language_name)  | Get the name of a [drgn_language](drgn_language.md#drgn_language). |

---

{#drgn_language_name}

### drgn_language_name

```cpp
const char * drgn_language_name(const struct drgn_language * lang)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:311

Get the name of a [drgn_language](drgn_language.md#drgn_language).

## Variables

| Return | Name | Description |
|--------|------|-------------|
| const struct [`drgn_language`](drgn_language.md#drgn_language) | [`drgn_language_c`](#drgn_language_c)  | C |
| const struct [`drgn_language`](drgn_language.md#drgn_language) | [`drgn_language_cpp`](#drgn_language_cpp)  | C++ |

---

{#drgn_language_c}

### drgn_language_c

```cpp
const struct drgn_language drgn_language_c
```

Type: const struct [`drgn_language`](drgn_language.md#drgn_language)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:306

C

---

{#drgn_language_cpp}

### drgn_language_cpp

```cpp
const struct drgn_language drgn_language_cpp
```

Type: const struct [`drgn_language`](drgn_language.md#drgn_language)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:308

C++

