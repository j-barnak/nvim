{#drgn_lazy_object}

# drgn_lazy_object

```cpp
#include <drgn.h>
```

```cpp
union drgn_lazy_object
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:3407

Lazily-evaluated object.

A lazy object may be in two states: unevaluated, in which case a callback must be called to evaluate the object, or evaluated, in which case the object is cached. To evaluate an object, the callback is called, and the result is cached.

This is for internal use only.

## Public Attributes

| Return | Name | Description |
|--------|------|-------------|
| struct [`drgn_object`](drgn_object.md#drgn_object-1) | [`obj`](#obj)  | Object if it has already been evaluated. |
| struct [`drgn_type`](drgn_type.md#drgn_type) * | [`dummy_type`](#dummy_type)  | Always `NULL` to indicate an unevaluated lazy object. |
| struct [`drgn_program`](drgn_program.md#drgn_program) * | [`prog`](#prog-6)  | [Program](Program.md#program) owning this thunk. |
| [`drgn_object_thunk_fn`](LazyObjects.md#drgn_object_thunk_fn) * | [`fn`](#fn)  | Callback. |
| `void *` | [`arg`](#arg-1)  | Argument passed to drgn_lazy_object::thunk::fn. |
| struct [`drgn_lazy_object`](#drgn_lazy_object) | [`thunk`](#thunk)  | Thunk if the object has not been evaluated yet. |

---

{#obj}

### obj

```cpp
struct drgn_object obj
```

Type: struct [`drgn_object`](drgn_object.md#drgn_object-1)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:3409

Object if it has already been evaluated.

---

{#dummy_type}

### dummy_type

```cpp
struct drgn_type * dummy_type
```

Type: struct [`drgn_type`](drgn_type.md#drgn_type) *

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:3417

Always `NULL` to indicate an unevaluated lazy object.

This must be at the same offset as [drgn_object::type](drgn_object.md#type-1).

---

{#prog-6}

### prog

```cpp
struct drgn_program * prog
```

Type: struct [`drgn_program`](drgn_program.md#drgn_program) *

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:3419

[Program](Program.md#program) owning this thunk.

---

{#fn}

### fn

```cpp
drgn_object_thunk_fn * fn
```

Type: [`drgn_object_thunk_fn`](LazyObjects.md#drgn_object_thunk_fn) *

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:3421

Callback.

---

{#arg-1}

### arg

```cpp
void * arg
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:3423

Argument passed to drgn_lazy_object::thunk::fn.

---

{#thunk}

### thunk

```cpp
struct drgn_lazy_object thunk
```

Type: struct [`drgn_lazy_object`](#drgn_lazy_object)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:3424

Thunk if the object has not been evaluated yet.

