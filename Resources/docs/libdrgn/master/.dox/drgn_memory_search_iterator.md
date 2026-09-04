{#drgn_memory_search_iterator}

# drgn_memory_search_iterator

```cpp
#include <drgn.h>
```

```cpp
struct drgn_memory_search_iterator
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/memory_reader.c:428

An iterator over all matches of a value or pattern in memory.

## Public Attributes

| Return | Name | Description |
|--------|------|-------------|
| struct [`drgn_program`](drgn_program.md#drgn_program) * | [`prog`](#prog-2)  |  |
| enum [`drgn_memory_search_iterator`](#drgn_memory_search_iterator) | [`mode`](#mode)  |  |
| `void *` | [`needle`](#needle)  |  |
| `size_t` | [`size`](#size-1)  |  |
| `uint64_t` | [`alignment_mask`](#alignment_mask)  |  |
| struct [`drgn_memory_search_iterator`](#drgn_memory_search_iterator) | [`memmem`](#memmem)  |  |
| union [`drgn_memory_search_iterator`](#drgn_memory_search_iterator) | [``](#unknown-7)  |  |
| [`unsigned`](api.md#unsigned) char * | [`buf`](#buf)  |  |
| `size_t` | [`buf_available`](#buf_available)  |  |
| `size_t` | [`pos`](#pos)  |  |
| `uint64_t` | [`buf_address`](#buf_address)  |  |
| `size_t` | [`buf_capacity`](#buf_capacity)  |  |
| `size_t` | [`read_alignment_mask`](#read_alignment_mask)  |  |
| `uint64_t` | [`min_address`](#min_address)  |  |
| `uint64_t` | [`max_address`](#max_address)  |  |
| `uint64_t` | [`address_offset`](#address_offset)  |  |
| `int` | [`physical`](#physical)  |  |

---

{#prog-2}

### prog

```cpp
struct drgn_program * prog
```

Type: struct [`drgn_program`](drgn_program.md#drgn_program) *

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/memory_reader.c:429

---

{#mode}

### mode

```cpp
enum drgn_memory_search_iterator mode
```

Type: enum [`drgn_memory_search_iterator`](#drgn_memory_search_iterator)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/memory_reader.c:440

---

{#needle}

### needle

```cpp
void * needle
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/memory_reader.c:444

---

{#size-1}

### size

```cpp
size_t size
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/memory_reader.c:445

---

{#alignment_mask}

### alignment_mask

```cpp
uint64_t alignment_mask
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/memory_reader.c:446

---

{#memmem}

### memmem

```cpp
struct drgn_memory_search_iterator memmem
```

Type: struct [`drgn_memory_search_iterator`](#drgn_memory_search_iterator)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/memory_reader.c:447

---

{#unknown-7}

### 

```cpp
union drgn_memory_search_iterator
```

Type: union [`drgn_memory_search_iterator`](#drgn_memory_search_iterator)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/memory_reader.c:471

---

{#buf}

### buf

```cpp
unsigned char * buf
```

Type: [`unsigned`](api.md#unsigned) char *

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/memory_reader.c:473

---

{#buf_available}

### buf_available

```cpp
size_t buf_available
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/memory_reader.c:474

---

{#pos}

### pos

```cpp
size_t pos
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/memory_reader.c:475

---

{#buf_address}

### buf_address

```cpp
uint64_t buf_address
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/memory_reader.c:476

---

{#buf_capacity}

### buf_capacity

```cpp
size_t buf_capacity
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/memory_reader.c:478

---

{#read_alignment_mask}

### read_alignment_mask

```cpp
size_t read_alignment_mask
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/memory_reader.c:480

---

{#min_address}

### min_address

```cpp
uint64_t min_address
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/memory_reader.c:482

---

{#max_address}

### max_address

```cpp
uint64_t max_address
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/memory_reader.c:483

---

{#address_offset}

### address_offset

```cpp
uint64_t address_offset
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/memory_reader.c:484

---

{#physical}

### physical

```cpp
int physical
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/memory_reader.c:486

## Public Types

| Name | Description |
|------|-------------|
| [``](#unknown-8)  |  |

---

{#unknown-8}

### 

```cpp
enum 
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/memory_reader.c:431

| Value | Description |
|-------|-------------|
| `DRGN_MEMORY_SEARCH_ITERATOR_MODE_MEMMEM` |  |
| `SEARCH_MEMORY_UINT_SIZES` |  |
