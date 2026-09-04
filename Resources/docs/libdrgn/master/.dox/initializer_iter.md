{#initializer_iter}

# initializer_iter

```cpp
struct initializer_iter
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/language_c.c:878

## Public Attributes

| Return | Name | Description |
|--------|------|-------------|
| struct [`drgn_error`](drgn_error.md#drgn_error) *(* | [`next`](#next-3)  |  |
| `void(*` | [`reset`](#reset)  |  |
| struct [`drgn_error`](drgn_error.md#drgn_error) *(* | [`append_designation`](#append_designation)  |  |

---

{#next-3}

### next

```cpp
struct drgn_error *(* next)(struct initializer_iter *, struct drgn_object *)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/language_c.c:3965

---

{#reset}

### reset

```cpp
void(* reset)(struct initializer_iter *)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/language_c.c:881

---

{#append_designation}

### append_designation

```cpp
struct drgn_error *(* append_designation)(struct initializer_iter *, struct string_builder *)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/language_c.c:881

