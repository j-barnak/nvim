{#binarysearchtrees}

# Binary search trees

> [`Internals`](Internals.md#internals)

Generic binary search trees.

This implements a self-balancing binary search tree interface. The interface is generic, strongly typed (entries have a static type, not `void *`), and doesn't have any function pointer overhead. Currently, only splay trees are implemented, but this may be extended to support other variants like red-black trees or AVL trees.

Entries are allocated separately from this interface. The interface is intrusive, i.e., entries must embed a [binary_tree_node](binary_tree_node.md#binary_tree_node).

A binary search tree is defined with [DEFINE_BINARY_SEARCH_TREE()](#define_binary_search_tree). Each generated binary search tree interface is prefixed with a given name; the interface documented here uses the example name `binary_search_tree`, which could be generated with this example code:

```c
typedef {
    ...
    struct binary_tree_node node;
} entry_type;
key_type entry_to_key(const entry_type *entry);
int cmp_func(const key_type *a, const key_type *b);
DEFINE_BINARY_SEARCH_TREE(binary_search_tree, entry_type, node, entry_to_key,
                          cmp_func, splay)
```

**See also**: [Hash tables](HashTables.md#hashtables)

## Classes

| Name | Description |
|------|-------------|
| [`binary_tree_node`](binary_tree_node.md#binary_tree_node) | Node in a binary search tree. |
| [`binary_tree_search_result`](binary_tree_search_result.md#binary_tree_search_result) |  |

## Macros

| Name | Description |
|------|-------------|
| [`DEFINE_BINARY_SEARCH_TREE_TYPE`](#define_binary_search_tree_type)  | Define a binary search tree type without defining its functions. |
| [`DEFINE_BINARY_SEARCH_TREE_FUNCTIONS`](#define_binary_search_tree_functions)  | Define the functions for a binary search tree. |
| [`DEFINE_BINARY_SEARCH_TREE`](#define_binary_search_tree)  | Define a binary search tree interface. |
| [`binary_search_tree_scalar_cmp`](#binary_search_tree_scalar_cmp)  |  |

---

{#define_binary_search_tree_type}

### DEFINE_BINARY_SEARCH_TREE_TYPE

```cpp
#define DEFINE_BINARY_SEARCH_TREE_TYPE(tree, entry_type) typedef typeof(entry_type) tree##_entry_type;			\
								\
struct tree {							\
	struct binary_tree_node *root;				\
};								\
struct DEFINE_BINARY_SEARCH_TREE_needs_semicolon
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/binary_search_tree.h:305

Define a binary search tree type without defining its functions.

This is useful when the binary search tree type must be defined in one place (e.g., a header) but the interface is defined elsewhere (e.g., a source file) with [DEFINE_BINARY_SEARCH_TREE_FUNCTIONS()](#define_binary_search_tree_functions). Otherwise, just use [DEFINE_BINARY_SEARCH_TREE()](#define_binary_search_tree).

**See also**: [DEFINE_BINARY_SEARCH_TREE()](#define_binary_search_tree)

---

{#define_binary_search_tree_functions}

### DEFINE_BINARY_SEARCH_TREE_FUNCTIONS

```cpp
#define DEFINE_BINARY_SEARCH_TREE_FUNCTIONS(tree, member, entry_to_key, cmp_func, variant)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/binary_search_tree.h:325

Define the functions for a binary search tree.

The binary search tree type must have already been defined with [DEFINE_BINARY_SEARCH_TREE_TYPE()](#define_binary_search_tree_type).

Unless the type and function definitions must be in separate places, use [DEFINE_BINARY_SEARCH_TREE()](#define_binary_search_tree) instead.

**See also**: [DEFINE_BINARY_SEARCH_TREE()](#define_binary_search_tree)

---

{#define_binary_search_tree}

### DEFINE_BINARY_SEARCH_TREE

```cpp
#define DEFINE_BINARY_SEARCH_TREE(tree, entry_type, member, entry_to_key, cmp_func, variant) DEFINE_BINARY_SEARCH_TREE_TYPE(tree, entry_type);				\
DEFINE_BINARY_SEARCH_TREE_FUNCTIONS(tree, member, entry_to_key, cmp_func,	\
				    variant)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/binary_search_tree.h:626

Define a binary search tree interface.

This macro defines a binary search tree type along with its functions.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `tree` |  | Name of the type to define. This is prefixed to all of the types and functions defined for that type. |
| `entry_type` |  | Type of entries in the tree. |
| `member` |  | Name of the [binary_tree_node](binary_tree_node.md#binary_tree_node) member in `entry_type`. |
| `entry_to_key` |  | Name of function or macro which is passed a `const entry_type *` and returns the key for that entry. The return type is the `key_type` of the tree. The passed entry is never `NULL`. |
| `cmp_func` |  | Comparison function which takes two `const key_type *` and returns an `int`. The return value must be negative if the first key is less than the second key, positive if the first key is greater than the second key, and zero if they are equal. |
| `variant` |  | The binary search tree implementation to use. Currently this can only be `splay`. |

---

{#binary_search_tree_scalar_cmp}

### binary_search_tree_scalar_cmp

```cpp
#define binary_search_tree_scalar_cmp(a, b) ({	\
	__auto_type _a = *(a);			\
	__auto_type _b = *(b);			\
						\
	_a < _b ? -1 : _a > _b ? 1 : 0;		\
})
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/binary_search_tree.h:635

## Functions

| Return | Name | Description |
|--------|------|-------------|
| `void` | [`drgn_splay_tree_splay`](#drgn_splay_tree_splay)  |  |
| `void` | [`drgn_splay_tree_insert_fixup`](#drgn_splay_tree_insert_fixup) `static` `inline` |  |
| `void` | [`drgn_splay_tree_found`](#drgn_splay_tree_found) `static` `inline` |  |
| `void` | [`drgn_splay_tree_delete`](#drgn_splay_tree_delete)  |  |

---

{#drgn_splay_tree_splay}

### drgn_splay_tree_splay

```cpp
void drgn_splay_tree_splay(struct binary_tree_node ** root, struct binary_tree_node * node, struct binary_tree_node * parent)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/binary_search_tree.h:271

---

{#drgn_splay_tree_insert_fixup}

### drgn_splay_tree_insert_fixup

`static` `inline`

```cpp
static inline void drgn_splay_tree_insert_fixup(struct binary_tree_node ** root, struct binary_tree_node * node, struct binary_tree_node * parent)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/binary_search_tree.h:275

---

{#drgn_splay_tree_found}

### drgn_splay_tree_found

`static` `inline`

```cpp
static inline void drgn_splay_tree_found(struct binary_tree_node ** root, struct binary_tree_node * node)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/binary_search_tree.h:285

---

{#drgn_splay_tree_delete}

### drgn_splay_tree_delete

```cpp
void drgn_splay_tree_delete(struct binary_tree_node ** root, struct binary_tree_node * node)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/binary_search_tree.h:292

