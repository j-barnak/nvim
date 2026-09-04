{#hexlify}

# Hexlify

> [`Internals`](Internals.md#internals)

Hexadecimal encoding/decoding.

## Functions

| Return | Name | Description |
|--------|------|-------------|
| `void` | [`hexlify`](#hexlify-1)  | Encode binary data to a hexadecimal string. |
| `char *` | [`ahexlify`](#ahexlify)  | Allocate and encode binary data to a hexadecimal string. |
| `bool` | [`unhexlify`](#unhexlify)  | Decode hexadecimal string to binary data. |
| `bool` | [`hex_digit_to_nibble`](#hex_digit_to_nibble) `static` `inline` |  |

---

{#hexlify-1}

### hexlify

```cpp
void hexlify(const void * in, size_t in_len, char * out)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/hexlify.h:40

Encode binary data to a hexadecimal string.

The output string is an even number of lowercase hexadecimal characters with no separators. It is not null-terminated.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `in` | `const void *` | Input binary data. |
| `in_len` | `size_t` | Size of `in` in bytes. |
| `out` | `char *` | Output hexadecimal string of size `2 * in_len` characters. Not null-terminated. |

---

{#ahexlify}

### ahexlify

```cpp
char * ahexlify(const void * in, size_t in_len)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/hexlify.h:54

Allocate and encode binary data to a hexadecimal string.

This is like [hexlify()](#hexlify-1), but it allocates the output string, including a terminating null byte.

#### Returns
Output hexadecimal string, or `NULL` on failure to allocate memory. Unlike [hexlify()](#hexlify-1), this *is* null-terminated. On success, it must be freed with `free()`.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `in` | `const void *` | Input binary data. |
| `in_len` | `size_t` | Size of `in` in bytes. |

---

{#unhexlify}

### unhexlify

```cpp
bool unhexlify(const char * in, size_t in_len, void * out)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/hexlify.h:68

Decode hexadecimal string to binary data.

The input string must be an even number of hexadecimal characters (either lowercase or uppercase) with no separators.

#### Returns
`true` if data was successfully decoded, `false` if not (either because `in_len` was odd or `in` contained non-hexadecimal characters).

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `in` | `const char *` | Input hexadecimal string. Does not need to be null-terminated. |
| `in_len` | `size_t` | Number of characters in `in`. |
| `out` | `void *` | Returned binary data of size `in_len / 2` bytes. |

---

{#hex_digit_to_nibble}

### hex_digit_to_nibble

`static` `inline`

```cpp
static inline bool hex_digit_to_nibble(char c, uint8_t * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/hexlify.h:70

