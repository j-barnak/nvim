{#userspace_loaded_module_iterator}

# userspace_loaded_module_iterator

```cpp
struct userspace_loaded_module_iterator
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.c:3490

## Public Attributes

| Return | Name | Description |
|--------|------|-------------|
| struct [`drgn_module_iterator`](drgn_module_iterator.md#drgn_module_iterator) | [`it`](#it-4)  |  |
| `int` | [`state`](#state)  |  |
| `bool` | [`read_main_phdrs`](#read_main_phdrs)  |  |
| `bool` | [`have_main_dyn`](#have_main_dyn)  |  |
| `bool` | [`have_vdso_dyn`](#have_vdso_dyn)  |  |
| struct [`drgn_mapped_file_segment`](drgn_mapped_file_segment.md#drgn_mapped_file_segment) * | [`file_segments`](#file_segments-1)  |  |
| `size_t` | [`num_file_segments`](#num_file_segments)  |  |
| `uint64_t` | [`main_phoff`](#main_phoff)  |  |
| `uint64_t` | [`main_bias`](#main_bias)  |  |
| `uint64_t` | [`main_dyn_vaddr`](#main_dyn_vaddr)  |  |
| `uint64_t` | [`main_dyn_memsz`](#main_dyn_memsz)  |  |
| `uint64_t` | [`vdso_dyn_vaddr`](#vdso_dyn_vaddr)  |  |
| `uint64_t` | [`link_map`](#link_map)  |  |
| `void *` | [`phdrs_buf`](#phdrs_buf)  |  |
| `size_t` | [`phdrs_buf_capacity`](#phdrs_buf_capacity)  |  |
| `void *` | [`segment_buf`](#segment_buf)  |  |
| `size_t` | [`segment_buf_capacity`](#segment_buf_capacity)  |  |

---

{#it-4}

### it

```cpp
struct drgn_module_iterator it
```

Type: struct [`drgn_module_iterator`](drgn_module_iterator.md#drgn_module_iterator)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.c:3491

---

{#state}

### state

```cpp
int state
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.c:3492

---

{#read_main_phdrs}

### read_main_phdrs

```cpp
bool read_main_phdrs
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.c:3493

---

{#have_main_dyn}

### have_main_dyn

```cpp
bool have_main_dyn
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.c:3494

---

{#have_vdso_dyn}

### have_vdso_dyn

```cpp
bool have_vdso_dyn
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.c:3495

---

{#file_segments-1}

### file_segments

```cpp
struct drgn_mapped_file_segment * file_segments
```

Type: struct [`drgn_mapped_file_segment`](drgn_mapped_file_segment.md#drgn_mapped_file_segment) *

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.c:3497

---

{#num_file_segments}

### num_file_segments

```cpp
size_t num_file_segments
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.c:3498

---

{#main_phoff}

### main_phoff

```cpp
uint64_t main_phoff
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.c:3500

---

{#main_bias}

### main_bias

```cpp
uint64_t main_bias
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.c:3501

---

{#main_dyn_vaddr}

### main_dyn_vaddr

```cpp
uint64_t main_dyn_vaddr
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.c:3502

---

{#main_dyn_memsz}

### main_dyn_memsz

```cpp
uint64_t main_dyn_memsz
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.c:3503

---

{#vdso_dyn_vaddr}

### vdso_dyn_vaddr

```cpp
uint64_t vdso_dyn_vaddr
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.c:3504

---

{#link_map}

### link_map

```cpp
uint64_t link_map
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.c:3505

---

{#phdrs_buf}

### phdrs_buf

```cpp
void * phdrs_buf
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.c:3508

---

{#phdrs_buf_capacity}

### phdrs_buf_capacity

```cpp
size_t phdrs_buf_capacity
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.c:3509

---

{#segment_buf}

### segment_buf

```cpp
void * segment_buf
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.c:3512

---

{#segment_buf_capacity}

### segment_buf_capacity

```cpp
size_t segment_buf_capacity
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/debug_info.c:3513

