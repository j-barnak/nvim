{#logging-1}

# Logging

> [`Internals`](Internals.md#internals)

Logging functions.

## Functions

| Return | Name | Description |
|--------|------|-------------|
| `bool` | [`drgn_log_is_enabled`](#drgn_log_is_enabled)  | Return whether the given log level is enabled. |

---

{#drgn_log_is_enabled}

### drgn_log_is_enabled

```cpp
bool drgn_log_is_enabled(struct drgn_program * prog, enum drgn_log_level level)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/log.h:35

Return whether the given log level is enabled.

This can be used to avoid expensive computations that are only needed for logging.

