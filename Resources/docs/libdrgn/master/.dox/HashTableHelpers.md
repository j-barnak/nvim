{#hashtablehelpers}

# Hash table helpers

> [`Internals`](Internals.md#internals) / [`Hash tables`](HashTables.md#hashtables)

Hash functions and comparators for use with [Hash tables](HashTables.md#hashtables).

F14 resolves collisions by double hashing. Rather than using two independent hash functions, this provides two options for efficiently deriving a pair of hashes from a single input hash function depending on whether the hash function is *avalanching*. See hash_pair_from_avalanching_hash() and hash_pair_from_non_avalanching_hash().

This provides:

* Functions for double hashing common key types: `*_hash_pair()`.
* Primitives for double hashing more complicated key types.
* Equality functions for common key types: `*_eq()`.

## Macros

| Name | Description |
|------|-------------|
| [`int_key_hash_pair`](#int_key_hash_pair)  |  |
| [`ptr_key_hash_pair`](#ptr_key_hash_pair)  |  |
| [`scalar_key_eq`](#scalar_key_eq)  |  |
| [`hash_combine`](#hash_combine)  | Hash two integers. |
| [`c_string_key_hash_pair`](#c_string_key_hash_pair)  |  |
| [`c_string_key_eq`](#c_string_key_eq)  |  |

---

{#int_key_hash_pair}

### int_key_hash_pair

```cpp
#define int_key_hash_pair(key) ({				\
	__auto_type _key = *(key);				\
	_Static_assert(sizeof(_key) <= sizeof(uint64_t),	\
		       "unsupported integer size");		\
	sizeof(_key) > sizeof(size_t) ?				\
	hash_pair_from_avalanching_hash(hash_64_to_32(_key)) :	\
	hash_pair_from_non_avalanching_hash(_key);		\
})
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/hash_table.h:1840

---

{#ptr_key_hash_pair}

### ptr_key_hash_pair

```cpp
#define ptr_key_hash_pair(key) ({		\
	uintptr_t _ptr = (uintptr_t)*(key);	\
	int_key_hash_pair(&_ptr);		\
})
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/hash_table.h:1860

---

{#scalar_key_eq}

### scalar_key_eq

```cpp
#define scalar_key_eq(a, b) ((bool)(*(a) == *(b)))
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/hash_table.h:1875

---

{#hash_combine}

### hash_combine

```cpp
#define hash_combine(a, b) ({							\
	_Static_assert(sizeof(a) <= sizeof(uint64_t) &&				\
		       sizeof(b) <= sizeof(uint64_t),				\
		       "unsupported integer size");				\
	size_t _a = sizeof(a) > sizeof(size_t) ? hash_64_to_32(a) : (a);	\
	size_t _b = sizeof(b) > sizeof(size_t) ? hash_64_to_32(b) : (b);	\
	hash_64_to_32(((uint64_t)_a << 32) | _b);				\
})
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/hash_table.h:1914

Hash two integers.

This is an avalanching hash function. It can be used for any integer types. The two integers can have different types.

This can be used to combine input hash functions in order to hash records with multiple fields (e.g., structures or arrays). For example:

```cpp
struct point3d {
        int x, y, z;
};

static struct hash_pair point3d_key_hash_pair(const struct point3d *key)
{
        return hash_pair_from_avalanching_hash(hash_combine(hash_combine(key->x, key->y), key->z));
}
```

Note that the input hash functions need not be avalanching; the output will be avalanching regardless.

---

{#c_string_key_hash_pair}

### c_string_key_hash_pair

```cpp
#define c_string_key_hash_pair(key) hash_pair_from_avalanching_hash(hash_c_string(*(key)))
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/hash_table.h:1950

---

{#c_string_key_eq}

### c_string_key_eq

```cpp
#define c_string_key_eq(a, b) ((bool)(strcmp(*(a), *(b)) == 0))
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/hash_table.h:1958

## Functions

| Return | Name | Description |
|--------|------|-------------|
| struct [`hash_pair`](hash_pair.md#hash_pair) | [`hash_pair_from_avalanching_hash`](#hash_pair_from_avalanching_hash) `static` `inline` | Split an avalanching hash into a [hash_pair](hash_pair.md#hash_pair). |
| struct [`hash_pair`](hash_pair.md#hash_pair) | [`hash_pair_from_non_avalanching_hash`](#hash_pair_from_non_avalanching_hash) `static` `inline` | Mix a non-avalanching hash and split it into a [hash_pair](hash_pair.md#hash_pair). |
| `uint32_t` | [`hash_64_to_32`](#hash_64_to_32) `static` `inline` |  |
| `size_t` | [`hash_bytes`](#hash_bytes) `static` `inline` | Hash a byte buffer. |
| `size_t` | [`hash_c_string`](#hash_c_string) `static` `inline` | Hash a null-terminated string. |
| struct [`hash_pair`](hash_pair.md#hash_pair) | [`nstring_hash_pair`](#nstring_hash_pair) `static` `inline` | Double hash a [nstring](nstring.md#nstring). |

---

{#hash_pair_from_avalanching_hash}

### hash_pair_from_avalanching_hash

`static` `inline`

```cpp
static inline struct hash_pair hash_pair_from_avalanching_hash(size_t hash)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/hash_table.h:1667

Split an avalanching hash into a [hash_pair](hash_pair.md#hash_pair).

A hash function is avalanching if each bit of the hash value has a 50% chance of being the same for different inputs. This is true for cryptographic hash functions as well as certain non-cryptographic hash functions including CityHash, MurmurHash, SipHash, and xxHash. Simple hashes like DJBX33A, ad-hoc combinations like `53 * x + y`, and the identity function are not avalanching.

We use the input hash value as the first hash and the upper bits of the input hash value as the second hash (which would otherwise be discarded when masking to select the bucket).

---

{#hash_pair_from_non_avalanching_hash}

### hash_pair_from_non_avalanching_hash

`static` `inline`

```cpp
static inline struct hash_pair hash_pair_from_non_avalanching_hash(size_t hash)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/hash_table.h:1680

Mix a non-avalanching hash and split it into a [hash_pair](hash_pair.md#hash_pair).

This is architecture-dependent.

---

{#hash_64_to_32}

### hash_64_to_32

`static` `inline`

```cpp
static inline uint32_t hash_64_to_32(uint64_t hash)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/hash_table.h:1747

---

{#hash_bytes}

### hash_bytes

`static` `inline`

```cpp
static inline size_t hash_bytes(const void * data, size_t len)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/hash_table.h:1848

Hash a byte buffer.

This is an avalanching hash function.

---

{#hash_c_string}

### hash_c_string

`static` `inline`

```cpp
static inline size_t hash_c_string(const char * s)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/hash_table.h:1858

Hash a null-terminated string.

This is an avalanching hash function.

---

{#nstring_hash_pair}

### nstring_hash_pair

`static` `inline`

```cpp
static inline struct hash_pair nstring_hash_pair(const struct nstring * key)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/hash_table.h:1880

Double hash a [nstring](nstring.md#nstring).

