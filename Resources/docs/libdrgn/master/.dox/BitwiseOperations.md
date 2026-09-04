{#bitwiseoperations}

# Bitwise operations

> [`Internals`](Internals.md#internals)

Generic bitwise operations.

## Macros

| Name | Description |
|------|-------------|
| [`ctz`](#ctz)  | Count Trailing Zero bits. |
| [`fls`](#fls)  | Find Last Set bit. |
| [`is_power_of_two`](#is_power_of_two)  | Return whether `x` is a power of two. |
| [`next_power_of_two`](#next_power_of_two)  | Return the smallest power of two greater than or equal to `x`. |
| [`for_each_bit`](#for_each_bit)  | Iterate over each 1-bit in `mask`. |

---

{#ctz}

### ctz

```cpp
#define ctz(x) generic_bitop(x, PP_UNIQUE(_x), builtin_bitop_impl, ctz)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/bitops.h:41

Count Trailing Zero bits.

Return the number of trailing least significant 0-bits in `x`. This is undefined if `x` is zero.

```cpp
ctz(1) == ctz(0b1) == 0
ctz(2) == ctz(0b10) == 1
ctz(12) == ctz(0b1100) == 2
```

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `x` |  | Integer. |

---

{#fls}

### fls

```cpp
#define fls(x) generic_bitop(x, PP_UNIQUE(_x), fls_impl,)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/bitops.h:63

Find Last Set bit.

Return the one-based index of the most significant 1-bit of `x` or 0 if `x` is 0.

```cpp
fls(0) == fls(0b0) == 0
fls(1) == fls(0b1) == 1
fls(13) == fls(0b1101) == 4
```

For unsigned integers, 
```cpp
fls(x) = floor(log2(x)) + 1, if x > 0
         0, if x == 0
```

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `x` |  | Integer. |

---

{#is_power_of_two}

### is_power_of_two

```cpp
#define is_power_of_two(x) is_power_of_two_impl(x, PP_UNIQUE(_x))
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/bitops.h:127

Return whether `x` is a power of two.

```cpp
is_power_of_two(0) == 0
is_power_of_two(1) == 1
is_power_of_two(13) == 0
is_power_of_two(32) == 1
```

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `x` |  | Non-negative integer. |

---

{#next_power_of_two}

### next_power_of_two

```cpp
#define next_power_of_two(x) next_power_of_two_impl(x, PP_UNIQUE(_x))
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/bitops.h:146

Return the smallest power of two greater than or equal to `x`.

```cpp
next_power_of_two(0) == 1 // Zero is not a power of two
next_power_of_two(1) == 1
next_power_of_two(13) == 16
```

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `x` |  | Non-negative integer. |

---

{#for_each_bit}

### for_each_bit

```cpp
#define for_each_bit(i, mask) while (mask && (i = ctz(mask), mask &= mask - 1, 1))
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/bitops.h:172

Iterate over each 1-bit in `mask`.

On each iteration, this sets `i` to the zero-based index of the least significant 1-bit in `mask` and clears that bit in `mask`. It stops iterating when `mask` is zero.

```cpp
// Outputs 0 2 3
unsigned int mask = 13, i;
for_each_bit(i, mask)
        printf("%u ", i);
```

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `i` |  | Iteration variable name. |
| `mask` |  | Integer to iterate over. This is modified. |

