{#minimummaximumoperations}

# Minimum/maximum operations

> [`Internals`](Internals.md#internals)

Generic minimum/maximum operations.

## Macros

| Name | Description |
|------|-------------|
| [`min`](#min)  | Get the minimum of two expressions with compatible types. |
| [`max`](#max)  | Get the maximum of two expressions with compatible types. |
| [`min_iconst`](#min_iconst)  | Get the minimum of two integer constant expressions, resulting in an integer constant expression. |
| [`max_iconst`](#max_iconst)  | Get the maximum of two integer constant expressions, resulting in an integer constant expression. |

---

{#min}

### min

```cpp
#define min(x, y) cmp_once_impl(x, y, PP_UNIQUE(_x), PP_UNIQUE(_y), <)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/minmax.h:28

Get the minimum of two expressions with compatible types.

---

{#max}

### max

```cpp
#define max(x, y) cmp_once_impl(x, y, PP_UNIQUE(_x), PP_UNIQUE(_y), >)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/minmax.h:30

Get the maximum of two expressions with compatible types.

---

{#min_iconst}

### min_iconst

```cpp
#define min_iconst(x, y) cmp_iconst_impl(x, y, <)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/minmax.h:45

Get the minimum of two integer constant expressions, resulting in an integer constant expression.

---

{#max_iconst}

### max_iconst

```cpp
#define max_iconst(x, y) cmp_iconst_impl(x, y, >)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/minmax.h:50

Get the maximum of two integer constant expressions, resulting in an integer constant expression.

