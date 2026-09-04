{#sourcelocations}

# Source locations

Source code locations.

## Classes

| Name | Description |
|------|-------------|
| [`drgn_source_location_list`](drgn_source_location_list.md#drgn_source_location_list) | List of source code locations. |

## Functions

| Return | Name | Description |
|--------|------|-------------|
| `void` | [`drgn_source_location_list_destroy`](#drgn_source_location_list_destroy)  | Destroy a [drgn_source_location_list](drgn_source_location_list.md#drgn_source_location_list). |
| struct [`drgn_program`](drgn_program.md#drgn_program) * | [`drgn_source_location_list_program`](#drgn_source_location_list_program)  | Get the [drgn_program](drgn_program.md#drgn_program) that a [drgn_source_location_list](drgn_source_location_list.md#drgn_source_location_list) came from. |
| `size_t` | [`drgn_source_location_list_length`](#drgn_source_location_list_length)  | Get the number of locations in a source location list. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_format_source_location_list`](#drgn_format_source_location_list)  | Format a source location list as a string. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_format_source_location_list_at`](#drgn_format_source_location_list_at)  | Format a single location in a source location list as a string. |
| `const char *` | [`drgn_source_location_list_source_at`](#drgn_source_location_list_source_at)  | Get the filename, line number, and column number at a single location in a source location list. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_source_location_list_name_at`](#drgn_source_location_list_name_at)  | Get the name of the function or symbol at a single location in a source location list. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_program_source_location`](#drgn_program_source_location)  | Find the source code location containing a code address. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_program_addr2line`](#drgn_program_addr2line)  | Find the source code location containing a code address given as a symbol name or hexadecimal address, optionally followed by a `+` character and a decimal or hexadecimal offset |

---

{#drgn_source_location_list_destroy}

### drgn_source_location_list_destroy

```cpp
void drgn_source_location_list_destroy(struct drgn_source_location_list * locs)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:4431

Destroy a [drgn_source_location_list](drgn_source_location_list.md#drgn_source_location_list).

---

{#drgn_source_location_list_program}

### drgn_source_location_list_program

```cpp
struct drgn_program * drgn_source_location_list_program(struct drgn_source_location_list * locs)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:4437

Get the [drgn_program](drgn_program.md#drgn_program) that a [drgn_source_location_list](drgn_source_location_list.md#drgn_source_location_list) came from.

---

{#drgn_source_location_list_length}

### drgn_source_location_list_length

```cpp
size_t drgn_source_location_list_length(struct drgn_source_location_list * locs)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:4440

Get the number of locations in a source location list.

---

{#drgn_format_source_location_list}

### drgn_format_source_location_list

```cpp
struct drgn_error * drgn_format_source_location_list(struct drgn_source_location_list * locs, char ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:4450

Format a source location list as a string.

#### Returns
`NULL` on success, non-`NULL` on error.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `ret` | `char **` | Returned string. On success, it must be freed with `free()`. On error, it is not modified. |

---

{#drgn_format_source_location_list_at}

### drgn_format_source_location_list_at

```cpp
struct drgn_error * drgn_format_source_location_list_at(struct drgn_source_location_list * locs, size_t i, char ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:4461

Format a single location in a source location list as a string.

#### Returns
`NULL` on success, non-`NULL` on error.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `ret` | `char **` | Returned string. On success, it must be freed with `free()`. On error, it is not modified. |

---

{#drgn_source_location_list_source_at}

### drgn_source_location_list_source_at

```cpp
const char * drgn_source_location_list_source_at(struct drgn_source_location_list * locs, size_t i, int * line_ret, int * column_ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:4477

Get the filename, line number, and column number at a single location in a source location list.

#### Returns
Filename. This is valid until the source location list is destroyed; it should not be freed. `NULL` if the location could not be determined (in which case `*line_ret` and `*column_ret` are not modified).

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `line_ret` | `int *` | Returned line number. Returned as 0 if unknown. May be `NULL` if not needed. |
| `column_ret` | `int *` | Returned column number. Returned as 0 if unknown. May be `NULL` if not needed. |

---

{#drgn_source_location_list_name_at}

### drgn_source_location_list_name_at

```cpp
struct drgn_error * drgn_source_location_list_name_at(struct drgn_source_location_list * locs, size_t i, char ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:4489

Get the name of the function or symbol at a single location in a source location list.

#### Returns
`NULL` on success, non-`NULL` on error.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `ret` | `char **` | Returned name, or `NULL` if not found. On success, it must be freed with `free()`. On error, it is not modified. |

---

{#drgn_program_source_location}

### drgn_program_source_location

```cpp
struct drgn_error * drgn_program_source_location(struct drgn_program * prog, uint64_t address, struct drgn_source_location_list ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:4500

Find the source code location containing a code address.

#### Returns
`NULL` on success, non-`NULL` on error.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `address` | `uint64_t` | Code address. |
| `ret` | struct [`drgn_source_location_list`](drgn_source_location_list.md#drgn_source_location_list) ** | Returned source location list. |

---

{#drgn_program_addr2line}

### drgn_program_addr2line

```cpp
struct drgn_error * drgn_program_addr2line(struct drgn_program * prog, const char * address, struct drgn_source_location_list ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:4513

Find the source code location containing a code address given as a symbol name or hexadecimal address, optionally followed by a `+` character and a decimal or hexadecimal offset

#### Returns
`NULL` on success, non-`NULL` on error.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `address` | `const char *` | Code address. |
| `ret` | struct [`drgn_source_location_list`](drgn_source_location_list.md#drgn_source_location_list) ** | Returned source location list. |

