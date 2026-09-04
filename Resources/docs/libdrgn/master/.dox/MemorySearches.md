{#memorysearches}

# Memory searches

> [`Programs`](Programs.md#programs)

Searching program memory for values or patterns.

## Classes

| Name | Description |
|------|-------------|
| [`drgn_memory_search_iterator`](drgn_memory_search_iterator.md#drgn_memory_search_iterator) | An iterator over all matches of a value or pattern in memory. |

## Functions

| Return | Name | Description |
|--------|------|-------------|
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_program_search_memory`](#drgn_program_search_memory)  | Search for all non-overlapping occurrences of a byte string in memory. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_search_memory_for_object`](#drgn_search_memory_for_object)  | Search for all occurrences of an object's value in memory. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_program_search_memory_u16`](#drgn_program_search_memory_u16)  | Search for all occurrences of a 16-bit unsigned integer in memory. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_program_search_memory_u32`](#drgn_program_search_memory_u32)  | Like [drgn_program_search_memory_u16()](#drgn_program_search_memory_u16), but for a 32-bit unsigned integer. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_program_search_memory_u64`](#drgn_program_search_memory_u64)  | Like [drgn_program_search_memory_u16()](#drgn_program_search_memory_u16), but for a 64-bit unsigned integer. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_program_search_memory_word`](#drgn_program_search_memory_word)  | Like [drgn_program_search_memory_u16()](#drgn_program_search_memory_u16), but for a program word-sized unsigned integer. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_program_search_memory_u16_multi`](#drgn_program_search_memory_u16_multi)  | Search for all occurrences of one or more 16-bit unsigned integers in memory. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_program_search_memory_u32_multi`](#drgn_program_search_memory_u32_multi)  | Like [drgn_program_search_memory_u16_multi()](#drgn_program_search_memory_u16_multi), but for 32-bit unsigned integers. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_program_search_memory_u64_multi`](#drgn_program_search_memory_u64_multi)  | Like [drgn_program_search_memory_u16_multi()](#drgn_program_search_memory_u16_multi), but for 64-bit unsigned integers. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_program_search_memory_word_multi`](#drgn_program_search_memory_word_multi)  | Like [drgn_program_search_memory_u16_multi()](#drgn_program_search_memory_u16_multi), but for program word-sized unsigned integers. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_program_search_memory_regex`](#drgn_program_search_memory_regex)  | Search for all non-overlapping matches of a regular expression pattern in memory. |
| `void` | [`drgn_memory_search_iterator_destroy`](#drgn_memory_search_iterator_destroy)  | Destroy a [drgn_memory_search_iterator](drgn_memory_search_iterator.md#drgn_memory_search_iterator). |
| struct [`drgn_program`](drgn_program.md#drgn_program) * | [`drgn_memory_search_iterator_program`](#drgn_memory_search_iterator_program)  | Get the program that a memory search iterator is from. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_memory_search_iterator_next`](#drgn_memory_search_iterator_next)  | Get the next match from a memory search. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_memory_search_iterator_set_address_range`](#drgn_memory_search_iterator_set_address_range)  | Limit the address range of a memory search. |

---

{#drgn_program_search_memory}

### drgn_program_search_memory

```cpp
struct drgn_error * drgn_program_search_memory(struct drgn_program * prog, const void * needle, size_t size, uint64_t alignment, struct drgn_memory_search_iterator ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:1042

Search for all non-overlapping occurrences of a byte string in memory.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `size` | `size_t` | Size of `needle` in bytes. |
| `alignment` | `uint64_t` | Only consider addresses aligned to this value. Must be a power of two. |
| `ret` | struct [`drgn_memory_search_iterator`](drgn_memory_search_iterator.md#drgn_memory_search_iterator) ** | Returned memory search iterator. |

---

{#drgn_search_memory_for_object}

### drgn_search_memory_for_object

```cpp
struct drgn_error * drgn_search_memory_for_object(const struct drgn_object * obj, struct drgn_memory_search_iterator ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:1054

Search for all occurrences of an object's value in memory.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `obj` | const struct [`drgn_object`](drgn_object.md#drgn_object-1) * | Object whose value to search for. Its value is copied, so it need not remain valid after this function returns. |
| `ret` | struct [`drgn_memory_search_iterator`](drgn_memory_search_iterator.md#drgn_memory_search_iterator) ** | Returned memory search iterator. |

---

{#drgn_program_search_memory_u16}

### drgn_program_search_memory_u16

```cpp
struct drgn_error * drgn_program_search_memory_u16(struct drgn_program * prog, uint16_t value, struct drgn_memory_search_iterator ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:1066

Search for all occurrences of a 16-bit unsigned integer in memory.

Natural alignment is assumed.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `value` | `uint16_t` | Value to search for. |
| `ret` | struct [`drgn_memory_search_iterator`](drgn_memory_search_iterator.md#drgn_memory_search_iterator) ** | Returned memory search iterator. |

---

{#drgn_program_search_memory_u32}

### drgn_program_search_memory_u32

```cpp
struct drgn_error * drgn_program_search_memory_u32(struct drgn_program * prog, uint32_t value, struct drgn_memory_search_iterator ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:1074

Like [drgn_program_search_memory_u16()](#drgn_program_search_memory_u16), but for a 32-bit unsigned integer.

---

{#drgn_program_search_memory_u64}

### drgn_program_search_memory_u64

```cpp
struct drgn_error * drgn_program_search_memory_u64(struct drgn_program * prog, uint64_t value, struct drgn_memory_search_iterator ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:1082

Like [drgn_program_search_memory_u16()](#drgn_program_search_memory_u16), but for a 64-bit unsigned integer.

---

{#drgn_program_search_memory_word}

### drgn_program_search_memory_word

```cpp
struct drgn_error * drgn_program_search_memory_word(struct drgn_program * prog, uint64_t value, struct drgn_memory_search_iterator ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:1092

Like [drgn_program_search_memory_u16()](#drgn_program_search_memory_u16), but for a program word-sized unsigned integer.

It is an error if `value` is out of range of the program word size.

---

{#drgn_program_search_memory_u16_multi}

### drgn_program_search_memory_u16_multi

```cpp
struct drgn_error * drgn_program_search_memory_u16_multi(struct drgn_program * prog, const uint16_t * values, size_t num_values, uint16_t ignore_mask, const uint16_t(*) ranges, size_t num_ranges, struct drgn_memory_search_iterator ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:1112

Search for all occurrences of one or more 16-bit unsigned integers in memory.

Natural alignment is assumed.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `values` | `const uint16_t *` | Values to search for. This is copied, so it need not remain valid after this function returns. May be `NULL` if `num_values` is 0. |
| `num_values` | `size_t` | Number of values in `values`. |
| `ignore_mask` | `uint16_t` | Mask of bits to ignore when comparing to `values`. |
| `ranges` | `const uint16_t(*)` | Ranges to search for. `ranges[i][0]` is the minimum (inclusive) and `ranges[i][1]` is the maximum (inclusive). This is copied, so it need not remain valid after this function returns. May be `NULL` if `num_ranges` is 0. |
| `num_ranges` | `size_t` | Number of ranges in `ranges`. |
| `ret` | struct [`drgn_memory_search_iterator`](drgn_memory_search_iterator.md#drgn_memory_search_iterator) ** | Returned memory search iterator. |

---

{#drgn_program_search_memory_u32_multi}

### drgn_program_search_memory_u32_multi

```cpp
struct drgn_error * drgn_program_search_memory_u32_multi(struct drgn_program * prog, const uint32_t * values, size_t num_values, uint32_t ignore_mask, const uint32_t(*) ranges, size_t num_ranges, struct drgn_memory_search_iterator ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:1124

Like [drgn_program_search_memory_u16_multi()](#drgn_program_search_memory_u16_multi), but for 32-bit unsigned integers.

---

{#drgn_program_search_memory_u64_multi}

### drgn_program_search_memory_u64_multi

```cpp
struct drgn_error * drgn_program_search_memory_u64_multi(struct drgn_program * prog, const uint64_t * values, size_t num_values, uint64_t ignore_mask, const uint64_t(*) ranges, size_t num_ranges, struct drgn_memory_search_iterator ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:1136

Like [drgn_program_search_memory_u16_multi()](#drgn_program_search_memory_u16_multi), but for 64-bit unsigned integers.

---

{#drgn_program_search_memory_word_multi}

### drgn_program_search_memory_word_multi

```cpp
struct drgn_error * drgn_program_search_memory_word_multi(struct drgn_program * prog, const uint64_t * values, size_t num_values, uint64_t ignore_mask, const uint64_t(*) ranges, size_t num_ranges, struct drgn_memory_search_iterator ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:1150

Like [drgn_program_search_memory_u16_multi()](#drgn_program_search_memory_u16_multi), but for program word-sized unsigned integers.

It is an error if any value is out of range of the program word size.

---

{#drgn_program_search_memory_regex}

### drgn_program_search_memory_regex

```cpp
struct drgn_error * drgn_program_search_memory_regex(struct drgn_program * prog, const void * pattern, size_t pattern_len, bool utf8, struct drgn_memory_search_iterator ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:1169

Search for all non-overlapping matches of a regular expression pattern in memory.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `pattern` | `const void *` | PCRE regular expression to search for. This need not remain valid after this function returns. |
| `pattern_len` | `size_t` | Length of `pattern` in bytes. |
| `utf8` | `bool` | If `false`, search for 8-bit strings. If `true`, search for Unicode strings. |
| `ret` | struct [`drgn_memory_search_iterator`](drgn_memory_search_iterator.md#drgn_memory_search_iterator) ** | Returned memory search iterator. |

---

{#drgn_memory_search_iterator_destroy}

### drgn_memory_search_iterator_destroy

```cpp
void drgn_memory_search_iterator_destroy(struct drgn_memory_search_iterator * it)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:1174

Destroy a [drgn_memory_search_iterator](drgn_memory_search_iterator.md#drgn_memory_search_iterator).

---

{#drgn_memory_search_iterator_program}

### drgn_memory_search_iterator_program

```cpp
struct drgn_program * drgn_memory_search_iterator_program(const struct drgn_memory_search_iterator * it)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:1178

Get the program that a memory search iterator is from.

---

{#drgn_memory_search_iterator_next}

### drgn_memory_search_iterator_next

```cpp
struct drgn_error * drgn_memory_search_iterator_next(struct drgn_memory_search_iterator * it, uint64_t * addr_ret, const void ** match_ret, size_t * match_len_ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:1191

Get the next match from a memory search.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `addr_ret` | `uint64_t *` | Returned address of match. May be `NULL`. |
| `match_ret` | `const void **` | Returned match. This is valid until the next call to [drgn_memory_search_iterator_next()](#drgn_memory_search_iterator_next) or [drgn_memory_search_iterator_set_address_range()](#drgn_memory_search_iterator_set_address_range) with the same `it`, or until `it` is destroyed. May be `NULL`. |
| `match_len_ret` | `size_t *` | Length of `match_ret` in bytes. May be `NULL`. |

---

{#drgn_memory_search_iterator_set_address_range}

### drgn_memory_search_iterator_set_address_range

```cpp
struct drgn_error * drgn_memory_search_iterator_set_address_range(struct drgn_memory_search_iterator * it, uint64_t min_address, uint64_t max_address, bool physical)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:1206

Limit the address range of a memory search.

This can be called before, during, or after iteration.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `min_address` | `uint64_t` | Minimum address to search (inclusive). |
| `max_address` | `uint64_t` | Maximum address to search (inclusive). |
| `physical` | `bool` | If `false`, search virtual memory. If `true`, search physical memory. |

