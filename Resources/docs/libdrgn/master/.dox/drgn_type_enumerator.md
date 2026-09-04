{#drgn_type_enumerator}

# drgn_type_enumerator

```cpp
#include <drgn.h>
```

```cpp
struct drgn_type_enumerator
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:3495

Value of an enumerated type.

## Public Attributes

| Return | Name | Description |
|--------|------|-------------|
| `const char *` | [`name`](#name-1)  | Enumerator name. |
| `int64_t` | [`svalue`](#svalue)  | Enumerator value if the type is signed. |
| `uint64_t` | [`uvalue`](#uvalue)  | Enumerator value if the type is unsigned. |
| union [`drgn_type_enumerator`](#drgn_type_enumerator) | [``](#unknown)  |  |

---

{#name-1}

### name

```cpp
const char * name
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:3497

Enumerator name.

---

{#svalue}

### svalue

```cpp
int64_t svalue
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:3500

Enumerator value if the type is signed.

---

{#uvalue}

### uvalue

```cpp
uint64_t uvalue
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:3502

Enumerator value if the type is unsigned.

---

{#unknown}

### 

```cpp
union drgn_type_enumerator
```

Type: union [`drgn_type_enumerator`](#drgn_type_enumerator)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:3503

