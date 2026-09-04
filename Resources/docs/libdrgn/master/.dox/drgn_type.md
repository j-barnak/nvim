{#drgn_type}

# drgn_type

```cpp
#include <drgn_internal.h>
```

```cpp
struct drgn_type
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn_internal.h:35

Type descriptor.

Access it with the getters in [Types](Types.md#types).

## Public Attributes

| Return | Name | Description |
|--------|------|-------------|
| `const char *` | [`_name`](#_name)  |  |
| `const char *` | [`_tag`](#_tag)  |  |
| struct [`drgn_type_parameter`](drgn_type_parameter.md#drgn_type_parameter) * | [`_parameters`](#_parameters)  |  |
| `uint64_t` | [`_size`](#_size)  |  |
| `uint64_t` | [`_length`](#_length)  |  |
| struct [`drgn_type_enumerator`](drgn_type_enumerator.md#drgn_type_enumerator) * | [`_enumerators`](#_enumerators)  |  |
| `size_t` | [`_num_parameters`](#_num_parameters)  |  |
| struct [`drgn_type`](#drgn_type) * | [`_type`](#_type)  |  |
| struct [`drgn_type_member`](drgn_type_member.md#drgn_type_member) * | [`_members`](#_members)  |  |

---

{#_name}

### _name

```cpp
const char * _name
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn_internal.h:45

---

{#_tag}

### _tag

```cpp
const char * _tag
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn_internal.h:46

---

{#_parameters}

### _parameters

```cpp
struct drgn_type_parameter * _parameters
```

Type: struct [`drgn_type_parameter`](drgn_type_parameter.md#drgn_type_parameter) *

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn_internal.h:47

---

{#_size}

### _size

```cpp
uint64_t _size
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn_internal.h:50

---

{#_length}

### _length

```cpp
uint64_t _length
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn_internal.h:51

---

{#_enumerators}

### _enumerators

```cpp
struct drgn_type_enumerator * _enumerators
```

Type: struct [`drgn_type_enumerator`](drgn_type_enumerator.md#drgn_type_enumerator) *

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn_internal.h:52

---

{#_num_parameters}

### _num_parameters

```cpp
size_t _num_parameters
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn_internal.h:53

---

{#_type}

### _type

```cpp
struct drgn_type * _type
```

Type: struct [`drgn_type`](#drgn_type) *

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn_internal.h:56

---

{#_members}

### _members

```cpp
struct drgn_type_member * _members
```

Type: struct [`drgn_type_member`](drgn_type_member.md#drgn_type_member) *

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn_internal.h:57

## Private Attributes

| Return | Name | Description |
|--------|------|-------------|
| enum [`drgn_type_kind`](drgn_type_kind.md#drgn_type_kind) | [`_kind`](#_kind)  |  |
| enum [`drgn_primitive_type`](drgn_primitive_type.md#drgn_primitive_type) | [`_primitive`](#_primitive)  |  |
| enum [`drgn_qualifiers`](drgn_qualifiers.md#drgn_qualifiers) | [`_qualifiers`](#_qualifiers)  |  |
| enum [`drgn_type_flags`](api.md#drgn_type_flags) | [`_flags`](#_flags)  |  |
| struct [`drgn_program`](drgn_program.md#drgn_program) * | [`_program`](#_program)  |  |
| const struct [`drgn_language`](drgn_language.md#drgn_language) * | [`_language`](#_language)  |  |
| union [`drgn_type`](#drgn_type) | [``](#unknown-1)  |  |
| union [`drgn_type`](#drgn_type) | [``](#unknown-2)  |  |
| union [`drgn_type`](#drgn_type) | [``](#unknown-3)  |  |

---

{#_kind}

### _kind

```cpp
enum drgn_type_kind _kind
```

Type: enum [`drgn_type_kind`](drgn_type_kind.md#drgn_type_kind)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn_internal.h:37

---

{#_primitive}

### _primitive

```cpp
enum drgn_primitive_type _primitive
```

Type: enum [`drgn_primitive_type`](drgn_primitive_type.md#drgn_primitive_type)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn_internal.h:38

---

{#_qualifiers}

### _qualifiers

```cpp
enum drgn_qualifiers _qualifiers
```

Type: enum [`drgn_qualifiers`](drgn_qualifiers.md#drgn_qualifiers)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn_internal.h:40

---

{#_flags}

### _flags

```cpp
enum drgn_type_flags _flags
```

Type: enum [`drgn_type_flags`](api.md#drgn_type_flags)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn_internal.h:41

---

{#_program}

### _program

```cpp
struct drgn_program * _program
```

Type: struct [`drgn_program`](drgn_program.md#drgn_program) *

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn_internal.h:42

---

{#_language}

### _language

```cpp
const struct drgn_language * _language
```

Type: const struct [`drgn_language`](drgn_language.md#drgn_language) *

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn_internal.h:43

---

{#unknown-1}

### 

```cpp
union drgn_type
```

Type: union [`drgn_type`](#drgn_type)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn_internal.h:48

---

{#unknown-2}

### 

```cpp
union drgn_type
```

Type: union [`drgn_type`](#drgn_type)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn_internal.h:54

---

{#unknown-3}

### 

```cpp
union drgn_type
```

Type: union [`drgn_type`](#drgn_type)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn_internal.h:58

