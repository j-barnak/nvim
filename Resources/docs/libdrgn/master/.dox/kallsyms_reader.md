{#kallsyms_reader}

# kallsyms_reader

```cpp
struct kallsyms_reader
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/kallsyms.c:46

This struct contains the tables necessary to reconstruct kallsyms names.

vmlinux (core kernel) kallsyms names are compressed using table compression. There is some description of it in the kernel's "scripts/kallsyms.c", but this is a brief overview that should make the code below comprehensible.

Table compression uses the remaining 128 characters not defined by ASCII and maps them to common substrings (e.g. the prefix "write_"). Each name is represented as a sequence of bytes which refers to strings in this table. The two arrays below comprise this table:

* token_table: this is one long string with all of the tokens concatenated together, e.g. "a\0b\0c\0...z\0write_\0read_\0..."
* token_index: this is a 256-entry long array containing the index into token_table where you'll find that token's string.

To decode a string, for each byte you simply index into token_index, then use that to index into token_table, and copy that string into your buffer.

The actual kallsyms symbol names are concatenated into a buffer called "names". The first byte in a name is the length (in tokens, not decoded bytes) of the symbol name. The remaining "length" bytes are decoded via the table as described above. The first decoded byte is a character representing what type of symbol this is (e.g. text, data structure, etc).

## Public Attributes

| Return | Name | Description |
|--------|------|-------------|
| `uint32_t` | [`num_syms`](#num_syms)  |  |
| `uint8_t *` | [`names`](#names-1)  |  |
| `size_t` | [`names_len`](#names_len)  |  |
| `char *` | [`token_table`](#token_table)  |  |
| `uint16_t *` | [`token_index`](#token_index)  |  |
| `bool` | [`long_names`](#long_names)  |  |

---

{#num_syms}

### num_syms

```cpp
uint32_t num_syms
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/kallsyms.c:47

---

{#names-1}

### names

```cpp
uint8_t * names
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/kallsyms.c:48

---

{#names_len}

### names_len

```cpp
size_t names_len
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/kallsyms.c:49

---

{#token_table}

### token_table

```cpp
char * token_table
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/kallsyms.c:50

---

{#token_index}

### token_index

```cpp
uint16_t * token_index
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/kallsyms.c:51

---

{#long_names}

### long_names

```cpp
bool long_names
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/kallsyms.c:52

