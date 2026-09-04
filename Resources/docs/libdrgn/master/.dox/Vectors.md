{#vectors}

# Vectors

> [`Internals`](Internals.md#internals)

Dynamic arrays (a.k.a. vectors).

This is an implementation of generic, strongly-typed vectors.

A vector is defined with [DEFINE_VECTOR()](#define_vector). Each generated vector interface is prefixed with a given name; the interface documented here uses the example name `vector`.

## Macros

| Name | Description |
|------|-------------|
| [`vector_inline_minimal`](#vector_inline_minimal)  | Inline as many entries as possible without making the vector type larger than if `inline_size` was 0. |
| [`DEFINE_VECTOR_TYPE`](#define_vector_type-8)  | Define a vector type without defining its functions. |
| [`DEFINE_VECTOR_TYPE_I2`](#define_vector_type_i2)  |  |
| [`DEFINE_VECTOR_TYPE_I3`](#define_vector_type_i3)  |  |
| [`DEFINE_VECTOR_TYPE_I4`](#define_vector_type_i4)  |  |
| [`DEFINE_VECTOR_FUNCTIONS`](#define_vector_functions)  | Define the functions for a vector. |
| [`DEFINE_VECTOR`](#define_vector)  | Define a vector interface. |
| [`VECTOR_INIT`](#vector_init)  | Empty vector initializer. |
| [`VECTOR`](#vector)  | Define and initialize an empty vector of type `vector_type` named `vector` that is automatically deinitialized when it goes out of scope. |
| [`vector_for_each`](#vector_for_each)  | Iterate over every entry in a vector. |

---

{#vector_inline_minimal}

### vector_inline_minimal

```cpp
#define vector_inline_minimal -1
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/vector.h:273

Inline as many entries as possible without making the vector type larger than if `inline_size` was 0.

This can be passed as the `inline_size` argument to [DEFINE_VECTOR()](#define_vector).

---

{#define_vector_type-8}

### DEFINE_VECTOR_TYPE

```cpp
#define DEFINE_VECTOR_TYPE(...) PP_OVERLOAD(DEFINE_VECTOR_TYPE_I, __VA_ARGS__)(__VA_ARGS__)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/vector.h:284

Define a vector type without defining its functions.

This is useful when the vector type must be defined in one place (e.g., a header) but the interface is defined elsewhere (e.g., a source file) with [DEFINE_VECTOR_FUNCTIONS()](#define_vector_functions). Otherwise, just use [DEFINE_VECTOR()](#define_vector).

This takes the same arguments as [DEFINE_VECTOR()](#define_vector).

---

{#define_vector_type_i2}

### DEFINE_VECTOR_TYPE_I2

```cpp
#define DEFINE_VECTOR_TYPE_I2(vector, entry_type) DEFINE_VECTOR_TYPE_I3(vector, entry_type, 0)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/vector.h:286

---

{#define_vector_type_i3}

### DEFINE_VECTOR_TYPE_I3

```cpp
#define DEFINE_VECTOR_TYPE_I3(vector, entry_type, inline_size) DEFINE_VECTOR_TYPE_I4(vector, entry_type, inline_size, size_t)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/vector.h:288

---

{#define_vector_type_i4}

### DEFINE_VECTOR_TYPE_I4

```cpp
#define DEFINE_VECTOR_TYPE_I4(vector, entry_type, inline_size, size_type)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/vector.h:290

---

{#define_vector_functions}

### DEFINE_VECTOR_FUNCTIONS

```cpp
#define DEFINE_VECTOR_FUNCTIONS(vector)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/vector.h:345

Define the functions for a vector.

The vector type must have already been defined with [DEFINE_VECTOR_TYPE()](#define_vector_type-8).

Unless the type and function definitions must be in separate places, use [DEFINE_VECTOR()](#define_vector) instead.

**See also**: [DEFINE_VECTOR()](#define_vector)

---

{#define_vector}

### DEFINE_VECTOR

```cpp
#define DEFINE_VECTOR(vector, ...) DEFINE_VECTOR_TYPE(vector, __VA_ARGS__);	\
DEFINE_VECTOR_FUNCTIONS(vector)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/vector.h:601

Define a vector interface.

This macro defines a vector type along with its functions. It accepts a variable number of arguments:

```cpp
DEFINE_VECTOR(vector, entry_type);
DEFINE_VECTOR(vector, entry_type, inline_size);
DEFINE_VECTOR(vector, entry_type, inline_size, size_type);
```

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `vector` |  | Name of the type to define. This is prefixed to all of the types and functions defined for that type. |

---

{#vector_init}

### VECTOR_INIT

```cpp
#define VECTOR_INIT { { 0 } }
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/vector.h:612

Empty vector initializer.

This can be used to initialize a vector when declaring it.

**See also**: vector_init()

---

{#vector}

### VECTOR

```cpp
#define VECTOR(vector_type, vector) __attribute__((__cleanup__(vector_type##_deinit)))	\
	struct vector_type vector = VECTOR_INIT
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/vector.h:618

Define and initialize an empty vector of type `vector_type` named `vector` that is automatically deinitialized when it goes out of scope.

---

{#vector_for_each}

### vector_for_each

```cpp
#define vector_for_each(vector_type, it, vector) for (vector_type##_entry_type *it,				\
	     *it##__end = ({						\
			struct vector_type *it##__vector = (vector);	\
			it = vector_type##_begin(it##__vector);		\
			vector_type##_end(it##__vector);		\
	     });							\
	     it != it##__end; it++)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/vector.h:638

Iterate over every entry in a vector.

This is roughly equivalent to

```cpp
for (entry_type *it = vector_begin(vector), *end = vector_end(vector);
     it != end; it++)
```

Except that `vector` is only evaluated once.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `vector_type` |  | Name of vector type. |
| `it` |  | Name of iteration variable. |
| `vector` |  | Vector to iterate over. |

