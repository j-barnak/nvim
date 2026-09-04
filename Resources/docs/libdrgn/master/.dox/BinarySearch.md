{#binarysearch}

# Binary search

> [`Internals`](Internals.md#internals)

Generic binary search macros.

## Macros

| Name | Description |
|------|-------------|
| [`binary_search_ge`](#binary_search_ge)  |  |
| [`binary_search_ge_i`](#binary_search_ge_i)  |  |
| [`binary_search_gt`](#binary_search_gt)  |  |
| [`binary_search_gt_i`](#binary_search_gt_i)  |  |
| [`scalar_less`](#scalar_less)  | Compare two scalars (e.g., integers, floating-point numbers, pointers) for [binary_search_ge()](#binary_search_ge) or [binary_search_gt()](#binary_search_gt). |

---

{#binary_search_ge}

### binary_search_ge

```cpp
#define binary_search_ge(array_arg, nmemb_arg, key_arg, less) binary_search_ge_i(array_arg, nmemb_arg, key_arg, less,			\
			   PP_UNIQUE(array), PP_UNIQUE(key), PP_UNIQUE(lo),	\
			   PP_UNIQUE(hi), PP_UNIQUE(mid))
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/binary_search.h:70

---

{#binary_search_ge_i}

### binary_search_ge_i

```cpp
#define binary_search_ge_i(array_arg, nmemb_arg, key_arg, less, array, key, lo, hi, mid) ({										\
	__auto_type key = (key_arg);						\
	__auto_type array = (array_arg);					\
	size_t lo = 0;								\
	size_t hi = (nmemb_arg);						\
	while (lo < hi) {							\
		size_t mid = lo + (hi - lo) / 2;				\
		if (less(&array[mid], key))					\
			lo = mid + 1;						\
		else								\
			hi = mid;						\
	}									\
	lo;									\
})
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/binary_search.h:75

---

{#binary_search_gt}

### binary_search_gt

```cpp
#define binary_search_gt(array_arg, size_arg, value_arg, less) binary_search_gt_i(array_arg, size_arg, value_arg, less,		\
			   PP_UNIQUE(array), PP_UNIQUE(value), PP_UNIQUE(lo),	\
			   PP_UNIQUE(hi), PP_UNIQUE(mid))
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/binary_search.h:133

---

{#binary_search_gt_i}

### binary_search_gt_i

```cpp
#define binary_search_gt_i(array_arg, size_arg, value_arg, less, array, value, lo, hi, mid) ({										\
	__auto_type array = (array_arg);					\
	__auto_type value = (value_arg);					\
	size_t lo = 0;								\
	size_t hi = (size_arg);							\
	while (lo < hi) {							\
		size_t mid = lo + (hi - lo) / 2;				\
		if (less(value, &array[mid]))					\
			hi = mid;						\
		else								\
			lo = mid + 1;						\
	}									\
	lo;									\
})
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/binary_search.h:138

---

{#scalar_less}

### scalar_less

```cpp
#define scalar_less(a, b) (*(a) < *(b))
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/binary_search.h:159

Compare two scalars (e.g., integers, floating-point numbers, pointers) for [binary_search_ge()](#binary_search_ge) or [binary_search_gt()](#binary_search_gt).

