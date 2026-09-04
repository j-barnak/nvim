{#serializationdeserialization}

# Serialization/deserialization

> [`Internals`](Internals.md#internals)

Serialization and deserialization of bits to and from memory.

## Macros

| Name | Description |
|------|-------------|
| [`struct64_assign_member`](#struct64_assign_member)  |  |
| [`struct64_bswap_member`](#struct64_bswap_member)  |  |
| [`struct64_bswap_member_inplace`](#struct64_bswap_member_inplace)  |  |
| [`struct64_memcpy_member`](#struct64_memcpy_member)  |  |
| [`struct64_ignore_member`](#struct64_ignore_member)  |  |
| [`deserialize_struct64`](#deserialize_struct64)  |  |
| [`deserialize_struct64_inplace`](#deserialize_struct64_inplace)  |  |

---

{#struct64_assign_member}

### struct64_assign_member

```cpp
#define struct64_assign_member(member) do {				\
	typeof_member(_struct64_src_type, member) _struct64_tmp;	\
	memcpy(&_struct64_tmp,						\
	       _struct64_src + offsetof(_struct64_src_type, member),	\
	       sizeof(_struct64_tmp));					\
	_struct64_dst->member = _struct64_tmp;				\
} while (0)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/serialize.h:180

---

{#struct64_bswap_member}

### struct64_bswap_member

```cpp
#define struct64_bswap_member(member)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/serialize.h:188

---

{#struct64_bswap_member_inplace}

### struct64_bswap_member_inplace

```cpp
#define struct64_bswap_member_inplace(member) do {		\
	_Static_assert(sizeof(_struct64_dst->member) == 8 ||	\
		       sizeof(_struct64_dst->member) == 4 ||	\
		       sizeof(_struct64_dst->member) == 2 ||	\
		       sizeof(_struct64_dst->member) == 1,	\
		       "scalar member has invalid size");	\
	if (sizeof(_struct64_dst->member) == 8) {		\
		uint64_t _struct64_tmp;				\
		memcpy(&_struct64_tmp, &_struct64_dst->member,	\
		       sizeof(_struct64_tmp));			\
		_struct64_tmp = bswap_64(_struct64_tmp);	\
		memcpy(&_struct64_dst->member, &_struct64_tmp,	\
		       sizeof(_struct64_tmp));			\
	} else if (sizeof(_struct64_dst->member) == 4) {	\
		uint32_t _struct64_tmp;				\
		memcpy(&_struct64_tmp, &_struct64_dst->member,	\
		       sizeof(_struct64_tmp));			\
		_struct64_tmp = bswap_32(_struct64_tmp);	\
		memcpy(&_struct64_dst->member, &_struct64_tmp,	\
		       sizeof(_struct64_tmp));			\
	} else if (sizeof(_struct64_dst->member) == 2) {	\
		uint16_t _struct64_tmp;				\
		memcpy(&_struct64_tmp, &_struct64_dst->member,	\
		       sizeof(_struct64_tmp));			\
		_struct64_tmp = bswap_16(_struct64_tmp);	\
		memcpy(&_struct64_dst->member, &_struct64_tmp,	\
		       sizeof(_struct64_tmp));			\
	}							\
} while (0)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/serialize.h:227

---

{#struct64_memcpy_member}

### struct64_memcpy_member

```cpp
#define struct64_memcpy_member(member) do {					\
	_Static_assert(sizeof(_struct64_dst->member)				\
		       == sizeof_member(_struct64_src_type, member),		\
		       "64-bit and 32-bit members have different sizes");	\
	memcpy(&_struct64_dst->member,						\
	       _struct64_src + offsetof(_struct64_src_type, member),		\
	       sizeof(_struct64_dst->member));					\
} while (0)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/serialize.h:257

---

{#struct64_ignore_member}

### struct64_ignore_member

```cpp
#define struct64_ignore_member(member)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/serialize.h:266

---

{#deserialize_struct64}

### deserialize_struct64

```cpp
#define deserialize_struct64(struct64p, type32, visit_members, buf, is_64_bit, bswap) do {										\
	__auto_type _struct64_dst = (struct64p);				\
	/*									\
	 * We want to type check buf like a function parameter, so do two	\
	 * implicit conversions instead of an explicit cast.			\
	 */									\
	const void *_struct64_buf = (buf);					\
	const char *_struct64_src = _struct64_buf;				\
	if (is_64_bit) {							\
		if (bswap) {							\
			typedef typeof(*_struct64_dst) _struct64_src_type;	\
			visit_members(struct64_bswap_member,			\
				      struct64_memcpy_member);			\
		} else {							\
			memcpy(_struct64_dst, buf, sizeof(*_struct64_dst));	\
		}								\
	} else {								\
		typedef typeof(type32) _struct64_src_type;			\
		if (bswap) {							\
			visit_members(struct64_bswap_member,			\
				      struct64_memcpy_member);			\
		} else {							\
			visit_members(struct64_assign_member,			\
				      struct64_memcpy_member);			\
		}								\
	}									\
} while (0)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/serialize.h:304

---

{#deserialize_struct64_inplace}

### deserialize_struct64_inplace

```cpp
#define deserialize_struct64_inplace(struct64p, type32, visit_members, is_64_bit, bswap) do {			\
	__auto_type _struct64_dst = (struct64p);				\
	if (!(is_64_bit)) {							\
		typedef typeof(type32) _struct64_src_type;			\
		_Alignas(_struct64_src_type) char				\
			_struct64_src[sizeof(_struct64_src_type)];		\
		memcpy(_struct64_src, _struct64_dst, sizeof(_struct64_src));	\
		if (bswap) {							\
			visit_members(struct64_bswap_member,			\
				      struct64_memcpy_member);			\
		} else {							\
			visit_members(struct64_assign_member,			\
				      struct64_memcpy_member);			\
		}								\
	} else if (bswap) {							\
		visit_members(struct64_bswap_member_inplace,			\
			      struct64_ignore_member);				\
	}									\
} while (0)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/serialize.h:334

## Functions

| Return | Name | Description |
|--------|------|-------------|
| `int64_t` | [`truncate_signed`](#truncate_signed) `static` `inline` | Truncate a signed integer to `bit_size` bits with sign extension. |
| `uint64_t` | [`truncate_unsigned`](#truncate_unsigned) `static` `inline` | Truncate an unsigned integer to `bit_size` bits. |
| `int8_t` | [`truncate_signed8`](#truncate_signed8) `static` `inline` |  |
| `uint8_t` | [`truncate_unsigned8`](#truncate_unsigned8) `static` `inline` |  |
| `void` | [`copy_lsbytes_fill`](#copy_lsbytes_fill) `static` `inline` | Copy the `src_size` least-significant bytes from `src` to the `dst_size` least-significant bytes of `dst`. |
| `void` | [`copy_lsbytes`](#copy_lsbytes) `static` `inline` | Copy the `src_size` least-significant bytes from `src` to the `dst_size` least-significant bytes of `dst`. |
| `uint8_t` | [`copy_bits_first_mask`](#copy_bits_first_mask) `static` `inline` | Return a bit mask with bits `[bit_offset, 7]` set. |
| `uint8_t` | [`copy_bits_last_mask`](#copy_bits_last_mask) `static` `inline` | Return a bit mask with bits `[0, last_bit % 8]` set. |
| `void` | [`copy_bits`](#copy_bits)  | Copy `bit_size` bits from `src` at bit offset `src_bit_offset` to `dst` at bit offset `dst_bit_offset`. |
| `void` | [`serialize_bits`](#serialize_bits)  | Serialize bits to a memory buffer. |
| `uint64_t` | [`deserialize_bits`](#deserialize_bits)  | Deserialize bits from a memory buffer. |

---

{#truncate_signed}

### truncate_signed

`static` `inline`

```cpp
static inline int64_t truncate_signed(int64_t svalue, uint64_t bit_size)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/serialize.h:34

Truncate a signed integer to `bit_size` bits with sign extension.

---

{#truncate_unsigned}

### truncate_unsigned

`static` `inline`

```cpp
static inline uint64_t truncate_unsigned(uint64_t uvalue, uint64_t bit_size)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/serialize.h:40

Truncate an unsigned integer to `bit_size` bits.

---

{#truncate_signed8}

### truncate_signed8

`static` `inline`

```cpp
static inline int8_t truncate_signed8(int8_t svalue, int bit_size)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/serialize.h:45

---

{#truncate_unsigned8}

### truncate_unsigned8

`static` `inline`

```cpp
static inline uint8_t truncate_unsigned8(uint8_t uvalue, int bit_size)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/serialize.h:50

---

{#copy_lsbytes_fill}

### copy_lsbytes_fill

`static` `inline`

```cpp
static inline void copy_lsbytes_fill(void * dst, size_t dst_size, bool dst_little_endian, const void * src, size_t src_size, bool src_little_endian, int fill)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/serialize.h:62

Copy the `src_size` least-significant bytes from `src` to the `dst_size` least-significant bytes of `dst`.

If `src_size > dst_size`, the extra bytes are discarded. If `src_size < dst_size`, the extra bytes are filled with `fill`.

---

{#copy_lsbytes}

### copy_lsbytes

`static` `inline`

```cpp
static inline void copy_lsbytes(void * dst, size_t dst_size, bool dst_little_endian, const void * src, size_t src_size, bool src_little_endian)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/serialize.h:96

Copy the `src_size` least-significant bytes from `src` to the `dst_size` least-significant bytes of `dst`.

If `src_size > dst_size`, the extra bytes are discarded. If `src_size < dst_size`, the extra bytes are zero-filled.

---

{#copy_bits_first_mask}

### copy_bits_first_mask

`static` `inline`

```cpp
static inline uint8_t copy_bits_first_mask(unsigned int bit_offset, bool lsb0)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/serialize.h:109

Return a bit mask with bits `[bit_offset, 7]` set.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `lsb0` | `bool` | See [copy_bits()](#copy_bits). |

---

{#copy_bits_last_mask}

### copy_bits_last_mask

`static` `inline`

```cpp
static inline uint8_t copy_bits_last_mask(uint64_t last_bit, bool lsb0)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/serialize.h:119

Return a bit mask with bits `[0, last_bit % 8]` set.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `lsb0` | `bool` | See [copy_bits()](#copy_bits). |

---

{#copy_bits}

### copy_bits

```cpp
void copy_bits(void * dst, unsigned int dst_bit_offset, const void * src, unsigned int src_bit_offset, uint64_t bit_size, bool lsb0)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/serialize.h:140

Copy `bit_size` bits from `src` at bit offset `src_bit_offset` to `dst` at bit offset `dst_bit_offset`.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `dst` | `void *` | Destination buffer. |
| `dst_bit_offset` | [`unsigned`](api.md#unsigned) int | Offset in bits from the beginning of `dst` to copy to. Must be < 8. |
| `src` | `const void *` | Source buffer. |
| `src_bit_offset` | [`unsigned`](api.md#unsigned) int | Offset in bits from the beginning of `src` to copy from. Must be < 8. |
| `bit_size` | `uint64_t` | Number of bits to copy. |
| `lsb0` | `bool` | If `true`, bits within a byte are numbered from least significant (0) to most significant (7); if `false`, they are numbered from most significant (0) to least significant (7). This determines the interpretation of `dst_bit_offset` and `src_bit_offset`. |

---

{#serialize_bits}

### serialize_bits

```cpp
void serialize_bits(void * buf, uint64_t bit_offset, uint64_t uvalue, uint8_t bit_size, bool little_endian)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/serialize.h:159

Serialize bits to a memory buffer.

Note that this does not perform any bounds checking, so the caller must check that `bit_offset + bit_size` is within the buffer.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `buf` | `void *` | Memory buffer to write to. |
| `bit_offset` | `uint64_t` | Offset in bits from the beginning of `buf` to where to write. This is interpreted differently based on `little_endian`. |
| `uvalue` | `uint64_t` | Bits to write, in host order. |
| `bit_size` | `uint8_t` | Number of bits in `uvalue`. This must be greater than zero and no more than 64. Note that this is not checked or truncated, so if `uvalue` has more than this many bits, the results will likely be incorrect. |
| `little_endian` | `bool` | Whether the bits should be written out in little-endian order. |

---

{#deserialize_bits}

### deserialize_bits

```cpp
uint64_t deserialize_bits(const void * buf, uint64_t bit_offset, uint8_t bit_size, bool little_endian)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/serialize.h:177

Deserialize bits from a memory buffer.

Note that this does not perform any bounds checking, so the caller must check that `bit_offset + bit_size` is within the buffer.

#### Returns
The read bits in host order.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `buf` | `const void *` | Memory buffer to read from. |
| `bit_offset` | `uint64_t` | Offset in bits from the beginning of `buf` to where to read from. This is interpreted differently based on `little_endian`. |
| `bit_size` | `uint8_t` | Number of bits to read. This must be greater than zero and no more than 64. |
| `little_endian` | `bool` | Whether the bits should be interpreted in little-endian order. |

