{#lazyobjects}

# Lazy objects

> [`Internals`](Internals.md#internals)

Lazily-evaluated objects.

The graph of objects and types in a program can be very deep (and often cyclical), so drgn lazily evaluates objects in some cases.

## Typedefs

| Return | Name | Description |
|--------|------|-------------|
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_object_thunk_fn`](#drgn_object_thunk_fn)  | Callback to evaluate and/or free a [drgn_lazy_object](drgn_lazy_object.md#drgn_lazy_object). |

---

{#drgn_object_thunk_fn}

### drgn_object_thunk_fn

```cpp
using drgn_object_thunk_fn = struct drgn_error *
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:3392

Callback to evaluate and/or free a [drgn_lazy_object](drgn_lazy_object.md#drgn_lazy_object).

If `res` is not `NULL`, then this should return the object in `res` and free `arg` if necessary. If this returns an error, it may be called again (so `arg` must remain valid).

If `res` is `NULL`, then this should free `arg` if necessary; it must not return an error.

#### Returns
`NULL` on success, non-`NULL` on error.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `res` |  | Result object (if evaluating) or `NULL` (if freeing). This is already initialized and should not be deinitialized on error. |
| `arg` |  | Callback argument passed to drgn_lazy_object_init_thunk(). |

## Functions

| Return | Name | Description |
|--------|------|-------------|
| `void` | [`drgn_lazy_object_init_thunk`](#drgn_lazy_object_init_thunk) `static` `inline` | Initialize an unevaluated [drgn_lazy_object](drgn_lazy_object.md#drgn_lazy_object). |
| `bool` | [`drgn_lazy_object_is_evaluated`](#drgn_lazy_object_is_evaluated) `static` `inline` | Return whether a [drgn_lazy_object](drgn_lazy_object.md#drgn_lazy_object) has been evaluated. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_lazy_object_evaluate`](#drgn_lazy_object_evaluate)  | Evaluate a [drgn_lazy_object](drgn_lazy_object.md#drgn_lazy_object). |
| `void` | [`drgn_lazy_object_deinit`](#drgn_lazy_object_deinit)  | Free a [drgn_lazy_object](drgn_lazy_object.md#drgn_lazy_object). |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_lazy_object_check_prog`](#drgn_lazy_object_check_prog)  | Check whether a [drgn_lazy_object](drgn_lazy_object.md#drgn_lazy_object) belongs to a given [drgn_program](drgn_program.md#drgn_program). |

---

{#drgn_lazy_object_init_thunk}

### drgn_lazy_object_init_thunk

`static` `inline`

```cpp
static inline void drgn_lazy_object_init_thunk(union drgn_lazy_object * lazy_obj, struct drgn_program * prog, drgn_object_thunk_fn * fn, void * arg)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/lazy_object.h:39

Initialize an unevaluated [drgn_lazy_object](drgn_lazy_object.md#drgn_lazy_object).

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `lazy_obj` | union [`drgn_lazy_object`](drgn_lazy_object.md#drgn_lazy_object) * | Lazy object to initialize. |
| `prog` | struct [`drgn_program`](drgn_program.md#drgn_program) * | [Program](Program.md#program) owning the lazy object. |
| `fn` | [`drgn_object_thunk_fn`](#drgn_object_thunk_fn) * | Thunk callback. |
| `arg` | `void *` | Argument to pass to `fn`. |

---

{#drgn_lazy_object_is_evaluated}

### drgn_lazy_object_is_evaluated

`static` `inline`

```cpp
static inline bool drgn_lazy_object_is_evaluated(const union drgn_lazy_object * lazy_obj)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/lazy_object.h:51

Return whether a [drgn_lazy_object](drgn_lazy_object.md#drgn_lazy_object) has been evaluated.

---

{#drgn_lazy_object_evaluate}

### drgn_lazy_object_evaluate

```cpp
struct drgn_error * drgn_lazy_object_evaluate(union drgn_lazy_object * lazy_obj)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/lazy_object.h:63

Evaluate a [drgn_lazy_object](drgn_lazy_object.md#drgn_lazy_object).

If this success, then the lazy object is considered evaluated and future calls will always succeed. If this fails, then the lazy object remains in a valid, unevaluated state.

---

{#drgn_lazy_object_deinit}

### drgn_lazy_object_deinit

```cpp
void drgn_lazy_object_deinit(union drgn_lazy_object * lazy_obj)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/lazy_object.h:72

Free a [drgn_lazy_object](drgn_lazy_object.md#drgn_lazy_object).

If the object has been evaluated, then this deinitializes [drgn_lazy_object::obj](#obj). Otherwise, this calls [drgn_lazy_object::fn](#fn) to free [drgn_lazy_object::arg](#arg-1).

---

{#drgn_lazy_object_check_prog}

### drgn_lazy_object_check_prog

```cpp
struct drgn_error * drgn_lazy_object_check_prog(const union drgn_lazy_object * lazy_obj, struct drgn_program * prog)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/lazy_object.h:80

Check whether a [drgn_lazy_object](drgn_lazy_object.md#drgn_lazy_object) belongs to a given [drgn_program](drgn_program.md#drgn_program).

#### Returns
`NULL` if the program matches, non-`NULL` if not.

