{#hash_pair}

# hash_pair

```cpp
#include <hash_table.h>
```

```cpp
struct hash_pair
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/hash_table.h:80

Double hash.

**See also**: [Hash table helpers](HashTableHelpers.md#hashtablehelpers)

## Public Attributes

| Return | Name | Description |
|--------|------|-------------|
| `size_t` | [`first`](#first)  | First hash. |
| `size_t` | [`second`](#second)  | Second hash. |

---

{#first}

### first

```cpp
size_t first
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/hash_table.h:86

First hash.

F14 uses this to select the chunk.

---

{#second}

### second

```cpp
size_t second
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/hash_table.h:100

Second hash.

F14 uses this as the tag within the chunk and as the probe stride when a chunk overflows.

Only the 8 least-significant bits of this are used; the rest are zero (the folly implementation insists that storing this as `size_t` generates better code). The 8th bit is always set. This is derived from [hash_pair::first](#first); see hash_pair_from_avalanching_hash() and hash_pair_from_non_avalanching_hash().

