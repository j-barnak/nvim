{#linux_helper_task_iterator}

# linux_helper_task_iterator

```cpp
#include <helpers.h>
```

```cpp
struct linux_helper_task_iterator
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/helpers.h:74

## Public Attributes

| Return | Name | Description |
|--------|------|-------------|
| struct [`drgn_object`](drgn_object.md#drgn_object-1) | [`tasks_node`](#tasks_node)  |  |
| struct [`drgn_object`](drgn_object.md#drgn_object-1) | [`thread_node`](#thread_node)  |  |
| `uint64_t` | [`tasks_head`](#tasks_head)  |  |
| `uint64_t` | [`thread_head`](#thread_head)  |  |
| struct [`drgn_qualified_type`](drgn_qualified_type.md#drgn_qualified_type) | [`task_struct_type`](#task_struct_type)  |  |
| `bool` | [`done`](#done)  |  |

---

{#tasks_node}

### tasks_node

```cpp
struct drgn_object tasks_node
```

Type: struct [`drgn_object`](drgn_object.md#drgn_object-1)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/helpers.h:75

---

{#thread_node}

### thread_node

```cpp
struct drgn_object thread_node
```

Type: struct [`drgn_object`](drgn_object.md#drgn_object-1)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/helpers.h:76

---

{#tasks_head}

### tasks_head

```cpp
uint64_t tasks_head
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/helpers.h:77

---

{#thread_head}

### thread_head

```cpp
uint64_t thread_head
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/helpers.h:78

---

{#task_struct_type}

### task_struct_type

```cpp
struct drgn_qualified_type task_struct_type
```

Type: struct [`drgn_qualified_type`](drgn_qualified_type.md#drgn_qualified_type)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/helpers.h:79

---

{#done}

### done

```cpp
bool done
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/helpers.h:80

