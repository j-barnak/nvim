{#threads}

# Threads

Threads in a program.

## Classes

| Name | Description |
|------|-------------|
| [`drgn_thread_iterator`](drgn_thread_iterator.md#drgn_thread_iterator) | An iterator over all the threads in a program. |

## Functions

| Return | Name | Description |
|--------|------|-------------|
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_thread_dup`](#drgn_thread_dup)  | Create a copy of a [drgn_thread](drgn_thread.md#drgn_thread). |
| `void` | [`drgn_thread_destroy`](#drgn_thread_destroy)  | Free a [drgn_thread](drgn_thread.md#drgn_thread). |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_thread_iterator_create`](#drgn_thread_iterator_create)  | Get an iterator over all of the threads in the program. |
| `void` | [`drgn_thread_iterator_destroy`](#drgn_thread_iterator_destroy)  | Free a [drgn_thread_iterator](drgn_thread_iterator.md#drgn_thread_iterator). |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_thread_iterator_next`](#drgn_thread_iterator_next)  | Get the next thread from a [drgn_thread_iterator](drgn_thread_iterator.md#drgn_thread_iterator). |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_program_find_thread`](#drgn_program_find_thread)  | Get the thread with the given thread ID. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_program_main_thread`](#drgn_program_main_thread)  | Get the main program thread. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_program_crashed_thread`](#drgn_program_crashed_thread)  | Get the thread that caused the program to crash. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_thread_object`](#drgn_thread_object)  | Get the object for the given thread. This is currently only defined for the Linux kernel. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_thread_name`](#drgn_thread_name)  | Get name for the thread represented by `thread`. |

---

{#drgn_thread_dup}

### drgn_thread_dup

```cpp
struct drgn_error * drgn_thread_dup(const struct drgn_thread * thread, struct drgn_thread ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:4541

Create a copy of a [drgn_thread](drgn_thread.md#drgn_thread).

#### Returns
`NULL` on success, non-`NULL` on error.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `thread` | const struct [`drgn_thread`](drgn_thread.md#drgn_thread) * | [Thread](Thread.md#thread) to copy. |
| `ret` | struct [`drgn_thread`](drgn_thread.md#drgn_thread) ** | Returned copy. On success, must be destroyed with [drgn_thread_destroy()](#drgn_thread_destroy). |

---

{#drgn_thread_destroy}

### drgn_thread_destroy

```cpp
void drgn_thread_destroy(struct drgn_thread * thread)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:4545

Free a [drgn_thread](drgn_thread.md#drgn_thread).

---

{#drgn_thread_iterator_create}

### drgn_thread_iterator_create

```cpp
struct drgn_error * drgn_thread_iterator_create(struct drgn_program * prog, struct drgn_thread_iterator ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:4563

Get an iterator over all of the threads in the program.

#### Returns
`NULL` on success, non-`NULL` on error.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `ret` | struct [`drgn_thread_iterator`](drgn_thread_iterator.md#drgn_thread_iterator) ** | Returned iterator, which can be advanced with [drgn_thread_iterator_next](#drgn_thread_iterator_next), and must be destroyed with [drgn_thread_iterator_destroy](#drgn_thread_iterator_destroy). |

---

{#drgn_thread_iterator_destroy}

### drgn_thread_iterator_destroy

```cpp
void drgn_thread_iterator_destroy(struct drgn_thread_iterator * it)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:4567

Free a [drgn_thread_iterator](drgn_thread_iterator.md#drgn_thread_iterator).

---

{#drgn_thread_iterator_next}

### drgn_thread_iterator_next

```cpp
struct drgn_error * drgn_thread_iterator_next(struct drgn_thread_iterator * it, struct drgn_thread ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:4579

Get the next thread from a [drgn_thread_iterator](drgn_thread_iterator.md#drgn_thread_iterator).

#### Returns
`NULL` on success, non-`NULL` on error.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `ret` | struct [`drgn_thread`](drgn_thread.md#drgn_thread) ** | Borrowed thread handle, or `NULL` if there are no more threads. This is valid until until the next call to [drgn_thread_iterator_next()](#drgn_thread_iterator_next) with the same `it`, or until `it` is destroyed. It may be copied with [drgn_thread_dup()](#drgn_thread_dup) if it is needed for longer. This must NOT be destroyed with [drgn_thread_destroy()](#drgn_thread_destroy). |

---

{#drgn_program_find_thread}

### drgn_program_find_thread

```cpp
struct drgn_error * drgn_program_find_thread(struct drgn_program * prog, uint32_t tid, struct drgn_thread ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:4590

Get the thread with the given thread ID.

#### Returns
`NULL` on success, non-`NULL` on error.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `tid` | `uint32_t` | [Thread](Thread.md#thread) ID. |
| `ret` | struct [`drgn_thread`](drgn_thread.md#drgn_thread) ** | New thread handle, or `NULL` if not found. On success, must be destroyed with [drgn_thread_destroy()](#drgn_thread_destroy). |

---

{#drgn_program_main_thread}

### drgn_program_main_thread

```cpp
struct drgn_error * drgn_program_main_thread(struct drgn_program * prog, struct drgn_thread ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:4602

Get the main program thread.

#### Returns
`NULL` on success, non-`NULL` on error.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `ret` | struct [`drgn_thread`](drgn_thread.md#drgn_thread) ** | Borrowed thread handle, or `NULL` if not found. This is valid for the lifetime of `prog`. This must NOT be destroyed with [drgn_thread_destroy()](#drgn_thread_destroy). |

---

{#drgn_program_crashed_thread}

### drgn_program_crashed_thread

```cpp
struct drgn_error * drgn_program_crashed_thread(struct drgn_program * prog, struct drgn_thread ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:4613

Get the thread that caused the program to crash.

#### Returns
`NULL` on success, non-`NULL` on error.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `ret` | struct [`drgn_thread`](drgn_thread.md#drgn_thread) ** | Borrowed thread handle, or `NULL` if not found. This is valid for the lifetime of `prog`. This must NOT be destroyed with [drgn_thread_destroy()](#drgn_thread_destroy). |

---

{#drgn_thread_object}

### drgn_thread_object

```cpp
struct drgn_error * drgn_thread_object(struct drgn_thread * thread, const struct drgn_object ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:4625

Get the object for the given thread. This is currently only defined for the Linux kernel.

#### Returns
`NULL` on success, non-`NULL` on error.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `ret` | const struct [`drgn_object`](drgn_object.md#drgn_object-1) ** | Returned object. This must not be modified and is valid for the lifetime of `thread`. It can be copied with [drgn_object_copy()](ObjectHelpers.md#drgn_object_copy) if it is needed for longer. |

---

{#drgn_thread_name}

### drgn_thread_name

```cpp
struct drgn_error * drgn_thread_name(struct drgn_thread * thread, char ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:4643

Get name for the thread represented by `thread`.

#### Returns
`NULL` on success, non-`NULL` on error.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `ret` | `char **` | Returned thread name, or `NULL` if not found. On success, it should be freed with free(). On error, it is not modified. |

