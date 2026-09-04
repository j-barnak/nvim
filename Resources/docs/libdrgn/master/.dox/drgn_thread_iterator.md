{#drgn_thread_iterator}

# drgn_thread_iterator

```cpp
#include <drgn.h>
```

```cpp
struct drgn_thread_iterator
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.c:48

An iterator over all the threads in a program.

## Public Attributes

| Return | Name | Description |
|--------|------|-------------|
| struct [`drgn_program`](drgn_program.md#drgn_program) * | [`prog`](#prog-1)  |  |
| `struct drgn_thread_set_iterator` | [`iterator`](#iterator)  |  |
| `DIR *` | [`tasks_dir`](#tasks_dir)  |  |
| struct [`linux_helper_task_iterator`](linux_helper_task_iterator.md#linux_helper_task_iterator) | [`task_iter`](#task_iter)  |  |
| struct [`drgn_thread`](drgn_thread.md#drgn_thread) | [`entry`](#entry)  |  |
| union [`drgn_thread_iterator`](#drgn_thread_iterator) | [``](#unknown-4)  |  |

---

{#prog-1}

### prog

```cpp
struct drgn_program * prog
```

Type: struct [`drgn_program`](drgn_program.md#drgn_program) *

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.c:49

---

{#iterator}

### iterator

```cpp
struct drgn_thread_set_iterator iterator
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.c:52

---

{#tasks_dir}

### tasks_dir

```cpp
DIR * tasks_dir
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.c:56

---

{#task_iter}

### task_iter

```cpp
struct linux_helper_task_iterator task_iter
```

Type: struct [`linux_helper_task_iterator`](linux_helper_task_iterator.md#linux_helper_task_iterator)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.c:58

---

{#entry}

### entry

```cpp
struct drgn_thread entry
```

Type: struct [`drgn_thread`](drgn_thread.md#drgn_thread)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.c:61

---

{#unknown-4}

### 

```cpp
union drgn_thread_iterator
```

Type: union [`drgn_thread_iterator`](#drgn_thread_iterator)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/program.c:63

