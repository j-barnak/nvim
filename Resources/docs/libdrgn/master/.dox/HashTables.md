{#hashtables}

# Hash tables

> [`Internals`](Internals.md#internals)

High performance generic hash tables.

This is an implementation of Facebook's [F14](https://github.com/facebook/folly/blob/master/folly/container/F14.md), which provides both high performance and good memory efficiency by using SIMD instructions to allow for a high load factor.

These hash tables are generic, strongly typed (i.e., keys and values have static types rather than `void *`), and don't have any function pointer overhead.

On non-x86 platforms, this falls back to a slower implementation that doesn't use SIMD.

Abstractly, a hash table stores *entries* which can be looked up by *key*. A hash table is defined with [DEFINE_HASH_TABLE()](#define_hash_table) (or the higher-level wrappers, [DEFINE_HASH_MAP()](#define_hash_map) and [DEFINE_HASH_SET()](#define_hash_set)). Each generated hash table interface is prefixed with a given name; the interface documented here uses the example name `hash_table`, which could be generated with this example code:

```c
key_type entry_to_key(const entry_type *entry);
struct hash_pair hash_func(const key_type *key);
bool eq_func(const key_type *a, const key_type *b);
DEFINE_HASH_TABLE(hash_table, entry_type, entry_to_key, hash_func, eq_func);
```

**See also**: [Binary search trees](BinarySearchTrees.md#binarysearchtrees)

## Groups

| Name | Description |
|------|-------------|
| [`Hash table helpers`](HashTableHelpers.md#hashtablehelpers) | Hash functions and comparators for use with [Hash tables](#hashtables). |

## Classes

| Name | Description |
|------|-------------|
| [`hash_pair`](hash_pair.md#hash_pair) | Double hash. |

## Macros

| Name | Description |
|------|-------------|
| [`hash_table_empty_chunk`](#hash_table_empty_chunk)  |  |
| [`HASH_TABLE_CHUNK_MATCH`](#hash_table_chunk_match)  |  |
| [`HASH_TABLE_CHUNK_OCCUPIED`](#hash_table_chunk_occupied)  |  |
| [`DEFINE_HASH_TABLE_TYPE`](#define_hash_table_type-2)  | Define a hash table type without defining its functions. |
| [`HASH_TABLE_SEARCH_IMPL`](#hash_table_search_impl)  |  |
| [`HASH_TABLE_SEARCH_BY_INDEX_ITEM_TO_KEY`](#hash_table_search_by_index_item_to_key)  |  |
| [`DEFINE_HASH_TABLE_FUNCTIONS`](#define_hash_table_functions)  | Define the functions for a hash table. |
| [`DEFINE_HASH_TABLE`](#define_hash_table)  | Define a hash table interface. |
| [`DEFINE_HASH_MAP_TYPE`](#define_hash_map_type-2)  | Define a hash map type without defining its functions. |
| [`HASH_MAP_ENTRY_TO_KEY`](#hash_map_entry_to_key)  |  |
| [`DEFINE_HASH_MAP_FUNCTIONS`](#define_hash_map_functions)  | Define the functions for a hash map. |
| [`DEFINE_HASH_MAP`](#define_hash_map)  | Define a hash map interface. |
| [`DEFINE_HASH_SET_TYPE`](#define_hash_set_type-1)  | Define a hash set type without defining its functions. |
| [`HASH_SET_ENTRY_TO_KEY`](#hash_set_entry_to_key)  |  |
| [`DEFINE_HASH_SET_FUNCTIONS`](#define_hash_set_functions)  | Define the functions for a hash set. |
| [`DEFINE_HASH_SET`](#define_hash_set)  | Define a hash set interface. |
| [`HASH_TABLE_INIT`](#hash_table_init)  | Empty hash table initializer. |
| [`HASH_TABLE`](#hash_table)  | Define and initialize an empty hash_table of type `table_type` named `table` that is automatically deinitialized when it goes out of scope. |
| [`hash_table_for_each`](#hash_table_for_each)  | Iterate over every entry in a hash_table. |

---

{#hash_table_empty_chunk}

### hash_table_empty_chunk

```cpp
#define hash_table_empty_chunk (void *)hash_table_empty_chunk_header
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/hash_table.h:473

---

{#hash_table_chunk_match}

### HASH_TABLE_CHUNK_MATCH

```cpp
#define HASH_TABLE_CHUNK_MATCH(table) static inline unsigned int table##_chunk_match(struct table##_chunk *chunk,	\
					       size_t needle)			\
{										\
	unsigned int mask, i;							\
	for (mask = 0, i = 0; i < table##_chunk_capacity; i++) {		\
		if (chunk->tags[i] == needle)					\
			mask |= 1U << i;					\
	}									\
	return mask;								\
}
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/hash_table.h:493

---

{#hash_table_chunk_occupied}

### HASH_TABLE_CHUNK_OCCUPIED

```cpp
#define HASH_TABLE_CHUNK_OCCUPIED(table) static inline unsigned int table##_chunk_occupied(struct table##_chunk *chunk)	\
{										\
	unsigned int mask, i;							\
	for (mask = 0, i = 0; i < table##_chunk_capacity; i++) {		\
		if (chunk->tags[i])						\
			mask |= 1U << i;					\
	}									\
	return mask;								\
}
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/hash_table.h:505

---

{#define_hash_table_type-2}

### DEFINE_HASH_TABLE_TYPE

```cpp
#define DEFINE_HASH_TABLE_TYPE(table, entry_type) typedef typeof(entry_type) table##_entry_type;					\
										\
enum {										\
	/*									\
	 * Whether this table uses the vector storage policy.			\
	 *									\
	 * The vector policy provides the best performance and memory		\
	 * efficiency for medium and large entries.				\
	 */									\
	table##_vector_policy = sizeof(table##_entry_type) >= 24,		\
};										\
										\
/*										\
 * The vector storage policy stores 32-bit indices, so it only needs 32-bit	\
 * sizes.									\
 */										\
typedef_if(table##_size_type, table##_vector_policy, uint32_t, size_t);		\
										\
struct table {									\
	struct table##_chunk *chunks;						\
	struct hash_table_size_and_chunk_shift size_and_chunk_shift;		\
	union {									\
		/* Allocated together with chunks. */				\
		table##_entry_type *vector;					\
		uintptr_t first_packed;						\
	};									\
};										\
struct DEFINE_HASH_TABLE_needs_semicolon
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/hash_table.h:527

Define a hash table type without defining its functions.

This is useful when the hash table type must be defined in one place (e.g., a header) but the interface is defined elsewhere (e.g., a source file) with [DEFINE_HASH_TABLE_FUNCTIONS()](#define_hash_table_functions). Otherwise, just use [DEFINE_HASH_TABLE()](#define_hash_table).

**See also**: [DEFINE_HASH_TABLE()](#define_hash_table)

---

{#hash_table_search_impl}

### HASH_TABLE_SEARCH_IMPL

```cpp
#define HASH_TABLE_SEARCH_IMPL(table, func, key_type, item_to_key, eq_func) static struct table##_iterator table##_##func(struct table *table,		\
					      const key_type *key,		\
					      struct hash_pair hp)		\
{										\
	const size_t delta = hash_table_probe_delta(hp);			\
	size_t index = hp.first;						\
	for (size_t tries = 0; tries >> table##_chunk_shift(table) == 0;	\
	     tries++) {								\
		struct table##_chunk *chunk =					\
			&table->chunks[table##_modulo_by_chunk_count(table, index)];	\
		if (sizeof(*chunk) > 64)					\
			__builtin_prefetch(&chunk->items[8]);			\
		unsigned int mask = table##_chunk_match(chunk, hp.second), i;	\
		for_each_bit(i, mask) {						\
			table##_item_type *item = &chunk->items[i];		\
			key_type item_key = item_to_key(table, item);		\
			if (likely(eq_func(key, &item_key))) {			\
				return (struct table##_iterator){		\
					.item = item,				\
					.index = i,				\
				};						\
			}							\
		}								\
		if (likely(chunk->outbound_overflow_count == 0))		\
			break;							\
		index += delta;							\
	}									\
	return (struct table##_iterator){};					\
}
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/hash_table.h:561

---

{#hash_table_search_by_index_item_to_key}

### HASH_TABLE_SEARCH_BY_INDEX_ITEM_TO_KEY

```cpp
#define HASH_TABLE_SEARCH_BY_INDEX_ITEM_TO_KEY(table, item) (*(uint32_t *)item)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/hash_table.h:592

---

{#define_hash_table_functions}

### DEFINE_HASH_TABLE_FUNCTIONS

```cpp
#define DEFINE_HASH_TABLE_FUNCTIONS(table, entry_to_key, hash_func, eq_func)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/hash_table.h:603

Define the functions for a hash table.

The hash table type must have already been defined with [DEFINE_HASH_TABLE_TYPE()](#define_hash_table_type-2).

Unless the type and function definitions must be in separate places, use [DEFINE_HASH_TABLE()](#define_hash_table) instead.

---

{#define_hash_table}

### DEFINE_HASH_TABLE

```cpp
#define DEFINE_HASH_TABLE(table, entry_type, entry_to_key, hash_func, eq_func) DEFINE_HASH_TABLE_TYPE(table, entry_type);					\
DEFINE_HASH_TABLE_FUNCTIONS(table, entry_to_key, hash_func, eq_func)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/hash_table.h:1589

Define a hash table interface.

This macro defines a hash table type along with its functions.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `table` |  | Name of the type to define. This is prefixed to all of the types and functions defined for that type. |
| `entry_type` |  | Type of entries in the table. |
| `entry_to_key` |  | Name of function or macro which is passed a `const entry_type *` and returns the key for that entry. The return type is the `key_type` of the hash table. The passed entry is never `NULL`. |
| `hash_func` |  | Hash function which takes a `const key_type *` and returns a [hash_pair](hash_pair.md#hash_pair). |
| `eq_func` |  | Comparison function which takes two `const key_type *` and returns a `bool`. |

---

{#define_hash_map_type-2}

### DEFINE_HASH_MAP_TYPE

```cpp
#define DEFINE_HASH_MAP_TYPE(table, key_type, value_type) struct table##_entry {						\
	typeof(key_type) key;					\
	typeof(value_type) value;				\
};								\
DEFINE_HASH_TABLE_TYPE(table, struct table##_entry)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/hash_table.h:1600

Define a hash map type without defining its functions.

The functions are defined with [DEFINE_HASH_MAP_FUNCTIONS()](#define_hash_map_functions).

**See also**: [DEFINE_HASH_MAP()](#define_hash_map), [DEFINE_HASH_TABLE_TYPE()](#define_hash_table_type-2)

---

{#hash_map_entry_to_key}

### HASH_MAP_ENTRY_TO_KEY

```cpp
#define HASH_MAP_ENTRY_TO_KEY(entry) ((entry)->key)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/hash_table.h:1607

---

{#define_hash_map_functions}

### DEFINE_HASH_MAP_FUNCTIONS

```cpp
#define DEFINE_HASH_MAP_FUNCTIONS(table, hash_func, eq_func) DEFINE_HASH_TABLE_FUNCTIONS(table, HASH_MAP_ENTRY_TO_KEY, hash_func, eq_func)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/hash_table.h:1620

Define the functions for a hash map.

The hash map type must have already been defined with [DEFINE_HASH_MAP_TYPE()](#define_hash_map_type-2).

Unless the type and function definitions must be in separate places, use [DEFINE_HASH_MAP()](#define_hash_map) instead.

**See also**: [DEFINE_HASH_TABLE_FUNCTIONS](#define_hash_table_functions)

---

{#define_hash_map}

### DEFINE_HASH_MAP

```cpp
#define DEFINE_HASH_MAP(table, key_type, value_type, hash_func, eq_func) DEFINE_HASH_MAP_TYPE(table, key_type, value_type);				\
DEFINE_HASH_MAP_FUNCTIONS(table, hash_func, eq_func)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/hash_table.h:1643

Define a hash map interface.

This is a higher-level wrapper for [DEFINE_HASH_TABLE()](#define_hash_table) with entries of the following type (with the example name `hash_map`):

```c
struct hash_map_entry {
    key_type key;
    value_type value;
};
```

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `table` |  | Name of the map type to define. This is prefixed to all of the types and functions defined for that type. |
| `key_type` |  | Type of keys in the map. |
| `value_type` |  | Type of values in the map. |
| `hash_func` |  | See [DEFINE_HASH_TABLE()](#define_hash_table). |
| `eq_func` |  | See [DEFINE_HASH_TABLE()](#define_hash_table). |

---

{#define_hash_set_type-1}

### DEFINE_HASH_SET_TYPE

```cpp
#define DEFINE_HASH_SET_TYPE DEFINE_HASH_TABLE_TYPE
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/hash_table.h:1654

Define a hash set type without defining its functions.

The functions are defined with [DEFINE_HASH_SET_FUNCTIONS()](#define_hash_set_functions).

**See also**: [DEFINE_HASH_SET()](#define_hash_set), [DEFINE_HASH_TABLE_TYPE()](#define_hash_table_type-2)

---

{#hash_set_entry_to_key}

### HASH_SET_ENTRY_TO_KEY

```cpp
#define HASH_SET_ENTRY_TO_KEY(entry) (*(entry))
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/hash_table.h:1656

---

{#define_hash_set_functions}

### DEFINE_HASH_SET_FUNCTIONS

```cpp
#define DEFINE_HASH_SET_FUNCTIONS(table, hash_func, eq_func) DEFINE_HASH_TABLE_FUNCTIONS(table, HASH_SET_ENTRY_TO_KEY, hash_func, eq_func)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/hash_table.h:1669

Define the functions for a hash set.

The hash set type must have already been defined with [DEFINE_HASH_SET_TYPE()](#define_hash_set_type-1).

Unless the type and function definitions must be in separate places, use [DEFINE_HASH_SET()](#define_hash_set) instead.

**See also**: [DEFINE_HASH_TABLE_FUNCTIONS](#define_hash_table_functions)

---

{#define_hash_set}

### DEFINE_HASH_SET

```cpp
#define DEFINE_HASH_SET(table, key_type, hash_func, eq_func) DEFINE_HASH_SET_TYPE(table, key_type);				\
DEFINE_HASH_SET_FUNCTIONS(table, hash_func, eq_func)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/hash_table.h:1684

Define a hash set interface.

This is a higher-level wrapper for [DEFINE_HASH_TABLE()](#define_hash_table) where `entry_type` is the same as `key_type`.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `table` |  | Name of the set type to define. This is prefixed to all of the types and functions defined for that type. |
| `key_type` |  | Type of keys in the set. |
| `hash_func` |  | See [DEFINE_HASH_TABLE()](#define_hash_table). |
| `eq_func` |  | See [DEFINE_HASH_TABLE()](#define_hash_table). |

---

{#hash_table_init}

### HASH_TABLE_INIT

```cpp
#define HASH_TABLE_INIT { hash_table_empty_chunk }
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/hash_table.h:1695

Empty hash table initializer.

This can be used to initialize a hash table when declaring it.

**See also**: hash_table_init()

---

{#hash_table}

### HASH_TABLE

```cpp
#define HASH_TABLE(table_type, table) __attribute__((__cleanup__(table_type##_deinit)))	\
	struct table_type table = HASH_TABLE_INIT
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/hash_table.h:1701

Define and initialize an empty hash_table of type `table_type` named `table` that is automatically deinitialized when it goes out of scope.

---

{#hash_table_for_each}

### hash_table_for_each

```cpp
#define hash_table_for_each(table_type, it, table) for (struct table_type##_iterator it = table_type##_first(table);	\
	     it.entry; it = table_type##_next(it))
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/hash_table.h:1712

Iterate over every entry in a hash_table.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `table_type` |  | Name of hash table type. |
| `it` |  | Name of iterator variable. |
| `table` |  | Hash table to iterate over. |

## Enumerations

| Name | Description |
|------|-------------|
| [``](#unknown-11)  |  |

---

{#unknown-11}

### 

```cpp
enum 
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/hash_table.h:323

| Value | Description |
|-------|-------------|
| `hash_table_chunk_alignment` |  |
## Functions

| Return | Name | Description |
|--------|------|-------------|
| `size_t` | [`hash_table_probe_delta`](#hash_table_probe_delta) `static` `inline` |  |
| `size_t` | [`hash_table_chunk_count`](#hash_table_chunk_count) `static` `inline` |  |
| `size_t` | [`hash_table_modulo_by_chunk_count`](#hash_table_modulo_by_chunk_count) `static` `inline` |  |

---

{#hash_table_probe_delta}

### hash_table_probe_delta

`static` `inline`

```cpp
static inline size_t hash_table_probe_delta(struct hash_pair hp)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/hash_table.h:325

---

{#hash_table_chunk_count}

### hash_table_chunk_count

`static` `inline`

```cpp
static inline size_t hash_table_chunk_count(struct hash_table_size_and_chunk_shift * scs)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/hash_table.h:447

---

{#hash_table_modulo_by_chunk_count}

### hash_table_modulo_by_chunk_count

`static` `inline`

```cpp
static inline size_t hash_table_modulo_by_chunk_count(struct hash_table_size_and_chunk_shift * scs, size_t index)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/hash_table.h:453

## Variables

| Return | Name | Description |
|--------|------|-------------|
| `const uint8_t` | [`hosted_overflow_count_inc`](#hosted_overflow_count_inc) `static` |  |
| `const uint8_t` | [`hosted_overflow_count_dec`](#hosted_overflow_count_dec) `static` |  |
| `const uint8_t` | [`hash_table_empty_chunk_header`](#hash_table_empty_chunk_header)  |  |

---

{#hosted_overflow_count_inc}

### hosted_overflow_count_inc

`static`

```cpp
const uint8_t hosted_overflow_count_inc = 0x10
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/hash_table.h:330

---

{#hosted_overflow_count_dec}

### hosted_overflow_count_dec

`static`

```cpp
const uint8_t hosted_overflow_count_dec = -0x10
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/hash_table.h:331

---

{#hash_table_empty_chunk_header}

### hash_table_empty_chunk_header

```cpp
const uint8_t hash_table_empty_chunk_header[]
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/hash_table.h:472

