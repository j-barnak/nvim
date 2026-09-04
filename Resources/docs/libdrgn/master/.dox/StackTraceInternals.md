{#stacktraces}

# Stack traces

> [`Internals`](Internals.md#internals)

Stack trace internals.

This provides the internal data structures used for stack traces.

## Classes

| Name | Description |
|------|-------------|
| [`drgn_stack_frame`](drgn_stack_frame.md#drgn_stack_frame) |  |
| [`drgn_stack_trace`](drgn_stack_trace.md#drgn_stack_trace) |  |

## Functions

| Return | Name | Description |
|--------|------|-------------|
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_parse_addr2line`](#drgn_parse_addr2line)  |  |

---

{#drgn_parse_addr2line}

### drgn_parse_addr2line

```cpp
struct drgn_error * drgn_parse_addr2line(const char * address_str, const char ** sym_name_ret, size_t * sym_name_len_ret, unsigned long long * offset_ret)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/stack_trace.h:44

