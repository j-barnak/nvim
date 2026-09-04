{#paths}

# Paths

> [`Internals`](Internals.md#internals)

Utilities for working with paths.

## Classes

| Name | Description |
|------|-------------|
| [`path_iterator`](path_iterator.md#path_iterator) | Path component iterator. |

## Functions

| Return | Name | Description |
|--------|------|-------------|
| `bool` | [`path_iterator_next`](#path_iterator_next)  | Get the next component from a [path_iterator](path_iterator.md#path_iterator). |
| `bool` | [`path_ends_with`](#path_ends_with)  | Return whether the path `haystack` ends with the path `needle` once both are normalized. |
| `bool` | [`die_matches_filename`](#die_matches_filename)  |  |

---

{#path_iterator_next}

### path_iterator_next

```cpp
bool path_iterator_next(struct path_iterator * it, const char ** component_ret, size_t * component_len_ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/path.h:90

Get the next component from a [path_iterator](path_iterator.md#path_iterator).

Components are emitted in reverse. This will never emit a "." component. It will emit an empty ("") component only for an absolute path. It may emit ".." components if there are any that go above the current directory.

#### Returns
`true` if we returned a componenent, `false` if there were no more components.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `it` | struct [`path_iterator`](path_iterator.md#path_iterator) * | Iterator. |
| `component_ret` | `const char **` | Returned component. |
| `component_len_ret` | `size_t *` | Length of `component`. |

---

{#path_ends_with}

### path_ends_with

```cpp
bool path_ends_with(struct path_iterator * haystack, struct path_iterator * needle)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/path.h:102

Return whether the path `haystack` ends with the path `needle` once both are normalized.

The unit of comparison is a path component, not a character. Thus, "ab/cd/ef" ends with "cd/ef", but not "d/ef".

**See also**: [path_iterator](path_iterator.md#path_iterator)

---

{#die_matches_filename}

### die_matches_filename

```cpp
bool die_matches_filename(Dwarf_Die * die, const char * filename)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/path.h:105

