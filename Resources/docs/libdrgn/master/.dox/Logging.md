{#logging}

# Logging

Logging configuration.

drgn can log to a file ([drgn_program_set_log_file()](#drgn_program_set_log_file)) or an arbitrary callback ([drgn_program_set_log_callback()](#drgn_program_set_log_callback)). Messages can be filtered based on the log level ([drgn_program_set_log_level()](#drgn_program_set_log_level)).

By default, the log file is set to `stderr` and the log level is [DRGN_LOG_NONE](#drgn_log_none), so logging is disabled.

Additionally, drgn can display a progress bar for some operations, like downloading debugging information. By default, progress bars are displayed on standard error if standard error is a terminal, the log file is set to `stderr`, and the log level is less than or equal to [DRGN_LOG_WARNING](#group__Logging_1ggac1399b9efea54691c398494738906c83a6ad988e5dc9e97a09fdcbf4bc720cca9), but this can be changed ([drgn_program_set_progress_file()](#drgn_program_set_progress_file)).

## Macros

| Name | Description |
|------|-------------|
| [`DRGN_LOG_NONE`](#drgn_log_none)  | Don't log anything. |

---

{#drgn_log_none}

### DRGN_LOG_NONE

```cpp
#define DRGN_LOG_NONE (DRGN_LOG_CRITICAL + 1)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:2251

Don't log anything.

## Enumerations

| Name | Description |
|------|-------------|
| [`drgn_log_level`](#drgn_log_level)  | Log levels. |

---

{#drgn_log_level}

### drgn_log_level

```cpp
enum drgn_log_level
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:2243

Log levels.

| Value | Description |
|-------|-------------|
| `DRGN_LOG_DEBUG` |  |
| `DRGN_LOG_INFO` |  |
| `DRGN_LOG_WARNING` |  |
| `DRGN_LOG_ERROR` |  |
| `DRGN_LOG_CRITICAL` |  |
## Typedefs

| Return | Name | Description |
|--------|------|-------------|
| `void` | [`drgn_log_fn`](#drgn_log_fn)  | Log callback. |

---

{#drgn_log_fn}

### drgn_log_fn

```cpp
using drgn_log_fn = void
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:2286

Log callback.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `prog` |  | [Program](Program.md#program) message was logged to. |
| `arg` |  | `callback_arg` passed to [drgn_program_set_log_callback()](#drgn_program_set_log_callback). |
| `level` |  | Message level. |
| `format` |  | printf-style format of message. |
| `ap` |  | Arguments for `format`. |
| `err` |  | Error to append after formatted message if non-`NULL`. This can be formatted with [drgn_error_string()](ErrorHandling.md#drgn_error_string), [drgn_error_fwrite()](ErrorHandling.md#drgn_error_fwrite), or [drgn_error_dwrite()](ErrorHandling.md#drgn_error_dwrite). |

## Functions

| Return | Name | Description |
|--------|------|-------------|
| `void` | [`drgn_program_set_log_level`](#drgn_program_set_log_level)  | Set the minimum log level. |
| `int` | [`drgn_program_get_log_level`](#drgn_program_get_log_level)  | Get the minimum log level. |
| `void` | [`drgn_program_set_log_file`](#drgn_program_set_log_file)  | Write logs to the given file. |
| `void` | [`drgn_program_set_log_callback`](#drgn_program_set_log_callback)  | Set a callback to log to. |
| `void` | [`drgn_program_get_log_callback`](#drgn_program_get_log_callback)  | Get the current log callback. |
| `void` | [`drgn_program_set_progress_file`](#drgn_program_set_progress_file)  | Write progress bars to the given file. |

---

{#drgn_program_set_log_level}

### drgn_program_set_log_level

```cpp
void drgn_program_set_log_level(struct drgn_program * prog, int level)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:2261

Set the minimum log level.

Messages below this level will not be logged.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `level` | `int` | Minimum [drgn_log_level](drgn_log_level.md#drgn_log_level) to log, or [DRGN_LOG_NONE](#drgn_log_none) to disable logging. |

---

{#drgn_program_get_log_level}

### drgn_program_get_log_level

```cpp
int drgn_program_get_log_level(struct drgn_program * prog)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:2269

Get the minimum log level.

#### Returns
Minimum [drgn_log_level](drgn_log_level.md#drgn_log_level) being logged, or [DRGN_LOG_NONE](#drgn_log_none) if logging is disabled.

---

{#drgn_program_set_log_file}

### drgn_program_set_log_file

```cpp
void drgn_program_set_log_file(struct drgn_program * prog, FILE * file)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:2272

Write logs to the given file.

---

{#drgn_program_set_log_callback}

### drgn_program_set_log_callback

```cpp
void drgn_program_set_log_callback(struct drgn_program * prog, drgn_log_fn * callback, void * callback_arg)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:2297

Set a callback to log to.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `callback` | [`drgn_log_fn`](#drgn_log_fn) * | Callback to call for each log message. This is only called if the message's level is at least the current log level. |
| `callback_arg` | `void *` | Argument to pass to callback. |

---

{#drgn_program_get_log_callback}

### drgn_program_get_log_callback

```cpp
void drgn_program_get_log_callback(struct drgn_program * prog, drgn_log_fn ** callback_ret, void ** callback_arg_ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:2306

Get the current log callback.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `callback_ret` | [`drgn_log_fn`](#drgn_log_fn) ** | Returned callback. |
| `callback_arg_ret` | `void **` | Returned callback argument. |

---

{#drgn_program_set_progress_file}

### drgn_program_set_progress_file

```cpp
void drgn_program_set_progress_file(struct drgn_program * prog, FILE * file)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:2315

Write progress bars to the given file.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `file` | `FILE *` | File, or `NULL` to disable progress bars. |

