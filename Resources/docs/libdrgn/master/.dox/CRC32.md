{#crc-32}

# CRC-32

> [`Internals`](Internals.md#internals)

CRC-32 checksums.

## Functions

| Return | Name | Description |
|--------|------|-------------|
| `uint32_t` | [`crc32_update`](#crc32_update)  | Update a CRC-32 checksum with additional data. |

---

{#crc32_update}

### crc32_update

```cpp
uint32_t crc32_update(uint32_t crc, const void * buf, size_t len)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/crc32.h:45

Update a CRC-32 checksum with additional data.

This uses the IEEE CRC-32 polynomial (*x*32 + *x*26 + *x*23 + *x*22 + *x*16 + *x*12 + *x*11 + *x*10 + *x*8 + *x*7 + *x*5 + *x*4 + *x*2 + *x* + 1).

#### Returns
Updated checksum. This is not bitwise negated as is often required for the final result.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `crc` | `uint32_t` | Checksum to update. For the first call, this is the initial checksum value (often `0xffffffff`). |
| `buf` | `const void *` | Data to checksum. |
| `len` | `size_t` | Size of `buf` in bytes. |

