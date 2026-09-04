{#path_iterator}

# path_iterator

```cpp
#include <path.h>
```

```cpp
struct path_iterator
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/path.h:58

Path component iterator.

This iterates over the components of a file path, joining multiple components and normalizing the result. Normalization:

* Collapses redundant "/" separators.
* Removes "." components.
* Removes ".." components when possible.

Components are emitted in **reverse**. So, "a/b/c" is emitted in the order "c", "b", "a" (this allows the implementation to operate in O(n) time and O(1) space).

Absolute paths have an implicit empty component, so "/a/b" is emitted as "b", "a", "".

Relative paths are emitted relative to a hypothetical current directory. A path referring to the current directory (e.g., "." or "a/..") does not emit any components.

".." components above the current directory are included, so "a/b/../../../c" is emitted as "c", "..". However, ".." components above an absolute path are not meaningful, so "/a/b/../../../c" is emitted as "c", "".

A empty path does not emit any components.

## Public Attributes

| Return | Name | Description |
|--------|------|-------------|
| struct [`nstring`](nstring.md#nstring) * | [`components`](#components)  | Array of input components. |
| `size_t` | [`num_components`](#num_components)  | Number of components in [path_iterator::components](#components). |
| `size_t` | [`dot_dot`](#dot_dot)  | Current number of ".." components. |

---

{#components}

### components

```cpp
struct nstring * components
```

Type: struct [`nstring`](nstring.md#nstring) *

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/path.h:66

Array of input components.

The input components are treated as if they were joined with a "/". [nstring::str](nstring.md#str-2) and [nstring::len](nstring.md#len-3) should be initialized for each component. The latter will be modified as the path is iterated.

---

{#num_components}

### num_components

```cpp
size_t num_components
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/path.h:68

Number of components in [path_iterator::components](#components).

---

{#dot_dot}

### dot_dot

```cpp
size_t dot_dot
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/path.h:74

Current number of ".." components.

Initialize this to 0.

