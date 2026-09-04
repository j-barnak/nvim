{#stacktraces-1}

# Stack traces

Call stacks and stack frames.

## Functions

| Return | Name | Description |
|--------|------|-------------|
| `void` | [`drgn_stack_trace_destroy`](#drgn_stack_trace_destroy)  | Destroy a [drgn_stack_trace](drgn_stack_trace.md#drgn_stack_trace). |
| struct [`drgn_program`](drgn_program.md#drgn_program) * | [`drgn_stack_trace_program`](#drgn_stack_trace_program)  | Get the [drgn_program](drgn_program.md#drgn_program) that a [drgn_stack_trace](drgn_stack_trace.md#drgn_stack_trace) came from. |
| `size_t` | [`drgn_stack_trace_num_frames`](#drgn_stack_trace_num_frames)  | Get the number of stack frames in a stack trace. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_format_stack_trace`](#drgn_format_stack_trace)  | Format a stack trace as a string. |
| `bool` | [`drgn_stack_frame_interrupted`](#drgn_stack_frame_interrupted)  | Return whether a stack frame was interrupted (e.g., by a signal). |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_format_stack_frame`](#drgn_format_stack_frame)  | Format a stack frame as a string. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_format_stack_frame_source`](#drgn_format_stack_frame_source)  | Format the source code location of a stack frame as a string. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_stack_frame_name`](#drgn_stack_frame_name)  | Get the best available name for a stack frame. |
| `const char *` | [`drgn_stack_frame_function_name`](#drgn_stack_frame_function_name)  | Get the name of the function at a stack frame. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_stack_frame_source_name`](#drgn_stack_frame_source_name)  | Get the name of the function or symbol at a stack frame's source code location. |
| `bool` | [`drgn_stack_frame_is_inline`](#drgn_stack_frame_is_inline)  | Return whether a stack frame is for an inlined call. |
| `const char *` | [`drgn_stack_frame_source`](#drgn_stack_frame_source)  | Get the source code location of a stack frame. |
| `bool` | [`drgn_stack_frame_pc`](#drgn_stack_frame_pc)  | Get the program counter at a stack frame. |
| `bool` | [`drgn_stack_frame_sp`](#drgn_stack_frame_sp)  | Get the stack pointer at a stack frame. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_stack_frame_symbol`](#drgn_stack_frame_symbol)  | Get the function symbol at a stack frame. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_stack_frame_locals`](#drgn_stack_frame_locals)  | Get the names of local objects in the scope of this frame. |
| `void` | [`drgn_stack_frame_locals_destroy`](#drgn_stack_frame_locals_destroy)  | Free an array of names returned by [drgn_stack_frame_locals()](#drgn_stack_frame_locals). |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_stack_frame_find_object`](#drgn_stack_frame_find_object)  | Find an object in the scope of a stack frame. |
| `bool` | [`drgn_stack_frame_register`](#drgn_stack_frame_register)  | Get the value of a register in a stack frame. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_program_stack_trace`](#drgn_program_stack_trace)  | Get a stack trace for the thread with the given thread ID. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_program_stack_trace_from_pcs`](#drgn_program_stack_trace_from_pcs)  | Get a stack trace with the supplied list of program counters. |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_object_stack_trace`](#drgn_object_stack_trace)  | Get a stack trace for the thread represented by `obj`. |

---

{#drgn_stack_trace_destroy}

### drgn_stack_trace_destroy

```cpp
void drgn_stack_trace_destroy(struct drgn_stack_trace * trace)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:4213

Destroy a [drgn_stack_trace](drgn_stack_trace.md#drgn_stack_trace).

---

{#drgn_stack_trace_program}

### drgn_stack_trace_program

```cpp
struct drgn_program * drgn_stack_trace_program(struct drgn_stack_trace * trace)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:4216

Get the [drgn_program](drgn_program.md#drgn_program) that a [drgn_stack_trace](drgn_stack_trace.md#drgn_stack_trace) came from.

---

{#drgn_stack_trace_num_frames}

### drgn_stack_trace_num_frames

```cpp
size_t drgn_stack_trace_num_frames(struct drgn_stack_trace * trace)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:4219

Get the number of stack frames in a stack trace.

---

{#drgn_format_stack_trace}

### drgn_format_stack_trace

```cpp
struct drgn_error * drgn_format_stack_trace(struct drgn_stack_trace * trace, char ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:4228

Format a stack trace as a string.

#### Returns
`NULL` on success, non-`NULL` on error.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `ret` | `char **` | Returned string. On success, it must be freed with `free()`. On error, it is not modified. |

---

{#drgn_stack_frame_interrupted}

### drgn_stack_frame_interrupted

```cpp
bool drgn_stack_frame_interrupted(struct drgn_stack_trace * trace, size_t frame)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:4232

Return whether a stack frame was interrupted (e.g., by a signal).

---

{#drgn_format_stack_frame}

### drgn_format_stack_frame

```cpp
struct drgn_error * drgn_format_stack_frame(struct drgn_stack_trace * trace, size_t frame, char ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:4241

Format a stack frame as a string.

#### Returns
`NULL` on success, non-`NULL` on error.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `ret` | `char **` | Returned string. On success, it must be freed with `free()`. On error, it is not modified. |

---

{#drgn_format_stack_frame_source}

### drgn_format_stack_frame_source

```cpp
struct drgn_error * drgn_format_stack_frame_source(struct drgn_stack_trace * trace, size_t frame, char ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:4252

Format the source code location of a stack frame as a string.

#### Returns
`NULL` on success, non-`NULL` on error.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `ret` | `char **` | Returned string. On success, it must be freed with `free()`. On error, it is not modified. |

---

{#drgn_stack_frame_name}

### drgn_stack_frame_name

```cpp
struct drgn_error * drgn_stack_frame_name(struct drgn_stack_trace * trace, size_t frame, char ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:4262

Get the best available name for a stack frame.

#### Returns
`NULL` on success, non-`NULL` on error.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `ret` | `char **` | Returned name. On success, it must be freed with `free()`. On error, it is not modified. |

---

{#drgn_stack_frame_function_name}

### drgn_stack_frame_function_name

```cpp
const char * drgn_stack_frame_function_name(struct drgn_stack_trace * trace, size_t frame)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:4271

Get the name of the function at a stack frame.

#### Returns
Function name. This is valid until the stack trace is destroyed; it should not be freed. `NULL` if the name could not be determined.

---

{#drgn_stack_frame_source_name}

### drgn_stack_frame_source_name

```cpp
struct drgn_error * drgn_stack_frame_source_name(struct drgn_stack_trace * trace, size_t frame, char ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:4282

Get the name of the function or symbol at a stack frame's source code location.

#### Returns
`NULL` on success, non-`NULL` on error.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `ret` | `char **` | Returned name, or `NULL` if not found. On success, it must be freed with `free()`. On error, it is not modified. |

---

{#drgn_stack_frame_is_inline}

### drgn_stack_frame_is_inline

```cpp
bool drgn_stack_frame_is_inline(struct drgn_stack_trace * trace, size_t frame)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:4286

Return whether a stack frame is for an inlined call.

---

{#drgn_stack_frame_source}

### drgn_stack_frame_source

```cpp
const char * drgn_stack_frame_source(struct drgn_stack_trace * trace, size_t frame, int * line_ret, int * column_ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:4299

Get the source code location of a stack frame.

#### Returns
Filename. This is valid until the stack trace is destroyed; it should not be freed. `NULL` if the location could not be determined (in which case `*line_ret` and `*column_ret` are not modified).

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `line_ret` | `int *` | Returned line number. Returned as 0 if unknown. May be `NULL` if not needed. |
| `column_ret` | `int *` | Returned column number. Returned as 0 if unknown. May be `NULL` if not needed. |

---

{#drgn_stack_frame_pc}

### drgn_stack_frame_pc

```cpp
bool drgn_stack_frame_pc(struct drgn_stack_trace * trace, size_t frame, uint64_t * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:4309

Get the program counter at a stack frame.

#### Returns
`true` if the program counter is known, `false` if it is not.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `ret` | `uint64_t *` | Returned program counter. |

---

{#drgn_stack_frame_sp}

### drgn_stack_frame_sp

```cpp
bool drgn_stack_frame_sp(struct drgn_stack_trace * trace, size_t frame, uint64_t * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:4318

Get the stack pointer at a stack frame.

#### Returns
`true` if the stack pointer is known, `false` if it is not.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `ret` | `uint64_t *` | Returned stack pointer. |

---

{#drgn_stack_frame_symbol}

### drgn_stack_frame_symbol

```cpp
struct drgn_error * drgn_stack_frame_symbol(struct drgn_stack_trace * trace, size_t frame, struct drgn_symbol ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:4328

Get the function symbol at a stack frame.

#### Returns
`NULL` on success, non-`NULL` on error.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `ret` | struct [`drgn_symbol`](drgn_symbol.md#drgn_symbol) ** | Returned symbol. On success, it should be freed with [drgn_symbol_destroy()](Symbols.md#drgn_symbol_destroy). On error, its contents are undefined. |

---

{#drgn_stack_frame_locals}

### drgn_stack_frame_locals

```cpp
struct drgn_error * drgn_stack_frame_locals(struct drgn_stack_trace * trace, size_t frame, const char *** names_ret, size_t * count_ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:4343

Get the names of local objects in the scope of this frame.

The array of names must be freed with [drgn_stack_frame_locals_destroy()](#drgn_stack_frame_locals_destroy).

#### Returns
`NULL` on success, non-`NULL` on error

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `names_ret` | `const char ***` | Returned array of names. On success, must be freed with [drgn_stack_frame_locals_destroy()](#drgn_stack_frame_locals_destroy). |
| `count_ret` | `size_t *` | Returned number of names in `names_ret`. |

---

{#drgn_stack_frame_locals_destroy}

### drgn_stack_frame_locals_destroy

```cpp
void drgn_stack_frame_locals_destroy(const char ** names, size_t count)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:4355

Free an array of names returned by [drgn_stack_frame_locals()](#drgn_stack_frame_locals).

The individual names from this array are invalid once this function is called. Any string which will be used later should be copied.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `names` | `const char **` | Array of names returned by [drgn_stack_frame_locals()](#drgn_stack_frame_locals). |
| `count` | `size_t` | Count returned by [drgn_stack_frame_locals()](#drgn_stack_frame_locals). |

---

{#drgn_stack_frame_find_object}

### drgn_stack_frame_find_object

```cpp
struct drgn_error * drgn_stack_frame_find_object(struct drgn_stack_trace * trace, size_t frame, const char * name, struct drgn_object * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:4366

Find an object in the scope of a stack frame.

#### Returns
`NULL` on success, non-`NULL` on error.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `name` | `const char *` | Object name. |
| `ret` | struct [`drgn_object`](drgn_object.md#drgn_object-1) * | Returned object. This must have already been initialized with [drgn_object_init()](Objects.md#drgn_object_init). |

---

{#drgn_stack_frame_register}

### drgn_stack_frame_register

```cpp
bool drgn_stack_frame_register(struct drgn_stack_trace * trace, size_t frame, const struct drgn_register * reg, uint64_t * ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:4378

Get the value of a register in a stack frame.

#### Returns
`true` on success, `false` if the value is not known or the register is too large to return in a `uint64_t`.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `reg` | const struct [`drgn_register`](drgn_register.md#drgn_register) * | [Register](Register.md#register) to get. Must be from the platform of the program that the trace was taken from. |
| `ret` | `uint64_t *` | Returned register value. |

---

{#drgn_program_stack_trace}

### drgn_program_stack_trace

```cpp
struct drgn_error * drgn_program_stack_trace(struct drgn_program * prog, uint32_t tid, struct drgn_stack_trace ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:4388

Get a stack trace for the thread with the given thread ID.

#### Returns
`NULL` on success, non-`NULL` on error.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `ret` | struct [`drgn_stack_trace`](drgn_stack_trace.md#drgn_stack_trace) ** | Returned stack trace. On success, it should be freed with [drgn_stack_trace_destroy()](#drgn_stack_trace_destroy). On error, its contents are undefined. |

---

{#drgn_program_stack_trace_from_pcs}

### drgn_program_stack_trace_from_pcs

```cpp
struct drgn_error * drgn_program_stack_trace_from_pcs(struct drgn_program * prog, const uint64_t * pcs, size_t pcs_size, struct drgn_stack_trace ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:4400

Get a stack trace with the supplied list of program counters.

#### Returns
`NULL` on success, non-`NULL` on error.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `ret` | struct [`drgn_stack_trace`](drgn_stack_trace.md#drgn_stack_trace) ** | Returned stack trace. On success, it should be freed with [drgn_stack_trace_destroy()](#drgn_stack_trace_destroy). On error, its contents are undefined. |

---

{#drgn_object_stack_trace}

### drgn_object_stack_trace

```cpp
struct drgn_error * drgn_object_stack_trace(const struct drgn_object * obj, struct drgn_stack_trace ** ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:4410

Get a stack trace for the thread represented by `obj`.

**See also**: [drgn_program_stack_trace()](#drgn_program_stack_trace).

