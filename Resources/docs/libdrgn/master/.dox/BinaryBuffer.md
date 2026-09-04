{#binarybuffer}

# Binary buffer

> [`Internals`](Internals.md#internals)

Binary format parsing.

A [binary_buffer](binary_buffer.md#binary_buffer) is a buffer for parsing binary data safely. It has a position ([binary_buffer::pos](binary_buffer.md#pos-1)) and various functions to read from the current position and advance it.

The `binary_buffer_next*` functions read a value from the buffer and advance the position past the read value. They return an error if the desired value is out of bounds of the buffer. They also save the previous position for error reporting ([binary_buffer::prev](binary_buffer.md#prev)). On error, they do not advance the position or change the previous position.

The `binary_buffer_skip*` functions are similar, except that they skip past unneeded data in the buffer and don't change the previous position.

Errors are formatted through a callback ([binary_buffer_error_fn](#binary_buffer_error_fn)) which can provide information about, e.g., what file contained the bad data. The [binary_buffer](binary_buffer.md#binary_buffer) can be embedded in a structure containing additional context.

## Classes

| Name | Description |
|------|-------------|
| [`binary_buffer`](binary_buffer.md#binary_buffer) | Buffer of binary data to parse. |

## Macros

| Name | Description |
|------|-------------|
| [`DEFINE_NEXT_INT`](#define_next_int)  |  |
| [`bswap_8`](#bswap_8)  |  |

---

{#define_next_int}

### DEFINE_NEXT_INT

```cpp
#define DEFINE_NEXT_INT(bits)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/binary_buffer.h:208

---

{#bswap_8}

### bswap_8

```cpp
#define bswap_8(x) (x)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/binary_buffer.h:267

## Typedefs

| Return | Name | Description |
|--------|------|-------------|
| struct [`drgn_error`](drgn_error.md#drgn_error) *(* | [`binary_buffer_error_fn`](#binary_buffer_error_fn)  | Binary buffer error formatting function. |

---

{#binary_buffer_error_fn}

### binary_buffer_error_fn

```cpp
using binary_buffer_error_fn = struct drgn_error *(*
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/binary_buffer.h:1

Binary buffer error formatting function.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `bb` |  | Buffer. |
| `pos` |  | Position in the buffer where the error occurred. |
| `message` |  | Error message. |

## Functions

| Return | Name | Description |
|--------|------|-------------|
| `void` | [`binary_buffer_init`](#binary_buffer_init) `static` `inline` | Initialize a [binary_buffer](binary_buffer.md#binary_buffer). |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`binary_buffer_error`](#binary_buffer_error)  | Report an error at the previous buffer position ([binary_buffer::prev](binary_buffer.md#prev)). |
| struct [`drgn_error`](drgn_error.md#drgn_error) | [`__format__`](#__format__)  |  |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`binary_buffer_error_at`](#binary_buffer_error_at)  | Report an error at a given position in the buffer. |
| struct [`drgn_error`](drgn_error.md#drgn_error) | [`__format__`](#__format__-1)  |  |
| `bool` | [`binary_buffer_has_next`](#binary_buffer_has_next) `static` `inline` | Return whether there are any bytes in the buffer after the current position. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`binary_buffer_check_bounds`](#binary_buffer_check_bounds) `static` `inline` |  |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`binary_buffer_skip`](#binary_buffer_skip) `static` `inline` | Advance the current buffer position by `n` bytes. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`binary_buffer_next_uint`](#binary_buffer_next_uint) `static` `inline` | Get an unsigned integer of the given size at the current buffer position and advance the position. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`binary_buffer_next_sint`](#binary_buffer_next_sint) `static` `inline` | Get a signed integer of the given size at the current buffer position and advance the position. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`binary_buffer_next_uleb128`](#binary_buffer_next_uleb128) `static` `inline` | Decode an Unsigned Little-Endian Base 128 (ULEB128) number at the current buffer position and advance the position. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`binary_buffer_next_sleb128`](#binary_buffer_next_sleb128) `static` `inline` | Decode a Signed Little-Endian Base 128 (SLEB128) number at the current buffer position and advance the position. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`binary_buffer_next_sleb128_into_u64`](#binary_buffer_next_sleb128_into_u64) `static` `inline` | Like binary_buffer_next_sleb128(), but return the value as a `uint64_t`. Negative values are sign extended. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`binary_buffer_skip_leb128`](#binary_buffer_skip_leb128) `static` `inline` | Skip past a LEB128 number at the current buffer position. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`binary_buffer_next_string`](#binary_buffer_next_string) `static` `inline` | Get a null-terminated string at the current buffer position and advance the position. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`binary_buffer_skip_string`](#binary_buffer_skip_string) `static` `inline` | Skip past a null-terminated string at the current buffer position. |

---

{#binary_buffer_init}

### binary_buffer_init

`static` `inline`

```cpp
static inline void binary_buffer_init(struct binary_buffer * bb, const void * buf, size_t len, bool little_endian, binary_buffer_error_fn error_fn)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/binary_buffer.h:105

Initialize a [binary_buffer](binary_buffer.md#binary_buffer).

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `buf` | `const void *` | Pointer to data. |
| `len` | `size_t` | Length of data in bytes. |
| `little_endian` | `bool` | Whether the data is little endian. |
| `error_fn` | [`binary_buffer_error_fn`](#binary_buffer_error_fn) | Error formatting callback. |

---

{#binary_buffer_error}

### binary_buffer_error

```cpp
struct drgn_error * binary_buffer_error(struct binary_buffer * bb, const char * format, ...)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/binary_buffer.h:119

Report an error at the previous buffer position ([binary_buffer::prev](binary_buffer.md#prev)).

---

{#__format__}

### __format__

```cpp
struct drgn_error __format__(__printf__, 2, 3)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/binary_buffer.h:121

---

{#binary_buffer_error_at}

### binary_buffer_error_at

```cpp
struct drgn_error * binary_buffer_error_at(struct binary_buffer * bb, const char * pos, const char * format, ...)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/binary_buffer.h:124

Report an error at a given position in the buffer.

---

{#__format__-1}

### __format__

```cpp
struct drgn_error __format__(__printf__, 3, 4)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/binary_buffer.h:127

---

{#binary_buffer_has_next}

### binary_buffer_has_next

`static` `inline`

```cpp
static inline bool binary_buffer_has_next(struct binary_buffer * bb)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/binary_buffer.h:135

Return whether there are any bytes in the buffer after the current position.

#### Returns
`true` if there bytes remaining, `false` if the position is at the end of the buffer.

---

{#binary_buffer_check_bounds}

### binary_buffer_check_bounds

`static` `inline`

```cpp
static inline struct drgn_error * binary_buffer_check_bounds(struct binary_buffer * bb, uint64_t n)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/binary_buffer.h:141

---

{#binary_buffer_skip}

### binary_buffer_skip

`static` `inline`

```cpp
static inline struct drgn_error * binary_buffer_skip(struct binary_buffer * bb, uint64_t n)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/binary_buffer.h:153

Advance the current buffer position by `n` bytes.

---

{#binary_buffer_next_uint}

### binary_buffer_next_uint

`static` `inline`

```cpp
static inline struct drgn_error * binary_buffer_next_uint(struct binary_buffer * bb, size_t size, uint64_t * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/binary_buffer.h:287

Get an unsigned integer of the given size at the current buffer position and advance the position.

The byte order is determined by the `little_endian` parameter that was passed to binary_buffer_init().

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `size` | `size_t` | Size in bytes. Must be no larger than 8. |
| `ret` | `uint64_t *` | Returned value. |

---

{#binary_buffer_next_sint}

### binary_buffer_next_sint

`static` `inline`

```cpp
static inline struct drgn_error * binary_buffer_next_sint(struct binary_buffer * bb, size_t size, int64_t * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/binary_buffer.h:325

Get a signed integer of the given size at the current buffer position and advance the position.

The byte order is determined by the `little_endian` parameter that was passed to binary_buffer_init().

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `size` | `size_t` | Size in bytes. Must be no larger than 8. |
| `ret` | `int64_t *` | Returned value. |

---

{#binary_buffer_next_uleb128}

### binary_buffer_next_uleb128

`static` `inline`

```cpp
static inline struct drgn_error * binary_buffer_next_uleb128(struct binary_buffer * bb, uint64_t * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/binary_buffer.h:348

Decode an Unsigned Little-Endian Base 128 (ULEB128) number at the current buffer position and advance the position.

If the number does not fit in a `uint64_t`, an error is returned.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `ret` | `uint64_t *` | Returned value. |

---

{#binary_buffer_next_sleb128}

### binary_buffer_next_sleb128

`static` `inline`

```cpp
static inline struct drgn_error * binary_buffer_next_sleb128(struct binary_buffer * bb, int64_t * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/binary_buffer.h:400

Decode a Signed Little-Endian Base 128 (SLEB128) number at the current buffer position and advance the position.

If the number does not fit in an `int64_t`, an error is returned.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `ret` | `int64_t *` | Returned value. |

---

{#binary_buffer_next_sleb128_into_u64}

### binary_buffer_next_sleb128_into_u64

`static` `inline`

```cpp
static inline struct drgn_error * binary_buffer_next_sleb128_into_u64(struct binary_buffer * bb, uint64_t * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/binary_buffer.h:453

Like binary_buffer_next_sleb128(), but return the value as a `uint64_t`. Negative values are sign extended.

---

{#binary_buffer_skip_leb128}

### binary_buffer_skip_leb128

`static` `inline`

```cpp
static inline struct drgn_error * binary_buffer_skip_leb128(struct binary_buffer * bb)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/binary_buffer.h:465

Skip past a LEB128 number at the current buffer position.

---

{#binary_buffer_next_string}

### binary_buffer_next_string

`static` `inline`

```cpp
static inline struct drgn_error * binary_buffer_next_string(struct binary_buffer * bb, const char ** str_ret, size_t * len_ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/binary_buffer.h:485

Get a null-terminated string at the current buffer position and advance the position.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `str_ret` | `const char **` | Returned string (i.e., the buffer position on entry). |
| `len_ret` | `size_t *` | Returned string length not including the null byte. |

---

{#binary_buffer_skip_string}

### binary_buffer_skip_string

`static` `inline`

```cpp
static inline struct drgn_error * binary_buffer_skip_string(struct binary_buffer * bb)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/binary_buffer.h:501

Skip past a null-terminated string at the current buffer position.

