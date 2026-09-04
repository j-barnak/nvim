{#objects}

# Objects

Objects in a program.

A [drgn_object](drgn_object.md#drgn_object-1) represents an object (e.g., variable, constant, or function) in a program.

Various operators and helpers are defined on objects; see [Operators](ObjectOperators.md#operators) and [Helpers](ObjectHelpers.md#helpers).

Many operations are language-specific. C is currently the only supported language.

In drgn's emulation of C:

* Signed and unsigned integer arithmetic is reduced modulo 2^width.
* Integer division truncates towards zero.
* Modulo has the sign of the dividend.
* Division or modulo by 0 returns an error.
* Shifts are reduced modulo 2^width. In particular, a shift by a value greater than the width returns 0.
* Shifts by a negative number return an error.
* Bitwise operators on signed integers act on the two's complement representation.
* Pointer arithmetic is supported.
* Integer literal have the first type of `int`, `long`, `long long`, and `unsigned long long` which can represent the value.
* Boolean literals have type `int` (**not**`_Bool`).
* Floating-point literals have type `double`.

## Groups

| Name | Description |
|------|-------------|
| [`Setters`](ObjectSetters.md#setters) | Object setters. |
| [`Helpers`](ObjectHelpers.md#helpers) | Object helpers. |
| [`Operators`](ObjectOperators.md#operators) | Object operators. |

## Classes

| Name | Description |
|------|-------------|
| [`drgn_object`](drgn_object.md#drgn_object-1) | Object in a program. |

## Macros

| Name | Description |
|------|-------------|
| [`drgn_object_buffer`](#drgn_object_buffer)  | Return an object's buffer. |
| [`DRGN_OBJECT`](#drgn_object)  | Define and initialize a [drgn_object](drgn_object.md#drgn_object-1) named `obj` that is automatically deinitialized when it goes out of scope. |

---

{#drgn_object_buffer}

### drgn_object_buffer

```cpp
#define drgn_object_buffer(obj) ({						\
	__auto_type _obj = (obj);						\
	drgn_object_is_inline(_obj) ? _obj->value.ibuf : _obj->value.bufp;	\
})
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:2584

Return an object's buffer.

---

{#drgn_object}

### DRGN_OBJECT

```cpp
#define DRGN_OBJECT(obj, prog) struct drgn_object obj					\
	__attribute__((__cleanup__(drgn_object_deinit))) =	\
	drgn_object_initializer(prog)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:2636

Define and initialize a [drgn_object](drgn_object.md#drgn_object-1) named `obj` that is automatically deinitialized when it goes out of scope.

This is equivalent to

```cpp
struct drgn_object obj;
drgn_object_init(&obj, prog);
...
drgn_object_deinit(&obj);
```

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `obj` |  | Name of object. |
| `prog` |  | [Program](Program.md#program) containing the object. |

## Enumerations

| Name | Description |
|------|-------------|
| [`drgn_object_kind`](#drgn_object_kind)  | Kinds of objects. |
| [`drgn_object_encoding`](#drgn_object_encoding)  | Object encodings. |
| [`drgn_absence_reason`](#drgn_absence_reason)  | Reason object is absent. |

---

{#drgn_object_kind}

### drgn_object_kind

```cpp
enum drgn_object_kind
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:2353

Kinds of objects.

---

{#drgn_object_encoding}

### drgn_object_encoding

```cpp
enum drgn_object_encoding
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:2371

Object encodings.

The value of a [drgn_object](drgn_object.md#drgn_object-1) may be encoded in various ways depending on its type. This determines which field of a [drgn_value](drgn_value.md#drgn_value) is used.

The incomplete encodings are only possible for reference objects; values have a complete type.

---

{#drgn_absence_reason}

### drgn_absence_reason

```cpp
enum drgn_absence_reason
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:2498

Reason object is absent.

| Value | Description |
|-------|-------------|
| `DRGN_ABSENCE_REASON_OTHER` | Another reason not listed below. |
| `DRGN_ABSENCE_REASON_OPTIMIZED_OUT` | Object was optimized out by the compiler. |
| `DRGN_ABSENCE_REASON_NOT_IMPLEMENTED` | Encountered unknown debugging information. |
## Functions

| Return | Name | Description |
|--------|------|-------------|
| `bool` | [`drgn_object_encoding_is_complete`](#drgn_object_encoding_is_complete) `static` `inline` | Return whether a type corresponding to an object encoding is complete. |
| `uint64_t` | [`drgn_value_size`](#drgn_value_size) `static` `inline` | Return the number of bytes needed to store the given number of bits. |
| `bool` | [`drgn_value_is_inline`](#drgn_value_is_inline) `static` `inline` | Return whether the given number of bits can be stored in the inline buffer of a [drgn_value](drgn_value.md#drgn_value) ([drgn_value::ibuf](#ibuf)). |
| `uint64_t` | [`drgn_object_size`](#drgn_object_size) `static` `inline` | Return the number of bytes needed to store an object's value. |
| `bool` | [`drgn_object_is_inline`](#drgn_object_is_inline) `static` `inline` | Return whether an object's value can be stored in the inline buffer of a [drgn_value](drgn_value.md#drgn_value) ([drgn_value::ibuf](#ibuf)). |
| struct [`drgn_qualified_type`](drgn_qualified_type.md#drgn_qualified_type) | [`drgn_object_qualified_type`](#drgn_object_qualified_type) `static` `inline` | Get the type of a [drgn_object](drgn_object.md#drgn_object-1). |
| `void` | [`drgn_object_init`](#drgn_object_init)  | Initialize a [drgn_object](drgn_object.md#drgn_object-1). |
| `void` | [`drgn_object_deinit`](#drgn_object_deinit)  | Deinitialize a [drgn_object](drgn_object.md#drgn_object-1). |
| struct [`drgn_object`](drgn_object.md#drgn_object-1) | [`drgn_object_initializer`](#drgn_object_initializer)  |  |
| struct [`drgn_program`](drgn_program.md#drgn_program) * | [`drgn_object_program`](#drgn_object_program) `static` `inline` | Get the program that a [drgn_object](drgn_object.md#drgn_object-1) is from. |
| const struct [`drgn_language`](drgn_language.md#drgn_language) * | [`drgn_object_language`](#drgn_object_language) `static` `inline` | Get the language of a [drgn_object](drgn_object.md#drgn_object-1) from its type. |

---

{#drgn_object_encoding_is_complete}

### drgn_object_encoding_is_complete

`static` `inline`

```cpp
static inline bool drgn_object_encoding_is_complete(enum drgn_object_encoding encoding)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:2441

Return whether a type corresponding to an object encoding is complete.

**See also**: [drgn_type_is_complete()](#group__Types_1ga532be651b0c47061e5afe83acd31ffec)

---

{#drgn_value_size}

### drgn_value_size

`static` `inline`

```cpp
static inline uint64_t drgn_value_size(uint64_t bits)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:2481

Return the number of bytes needed to store the given number of bits.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `bits` | `uint64_t` | Number of bits. |

---

{#drgn_value_is_inline}

### drgn_value_is_inline

`static` `inline`

```cpp
static inline bool drgn_value_is_inline(uint64_t bits)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:2492

Return whether the given number of bits can be stored in the inline buffer of a [drgn_value](drgn_value.md#drgn_value) ([drgn_value::ibuf](#ibuf)).

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `bits` | `uint64_t` | Number of bits. |

---

{#drgn_object_size}

### drgn_object_size

`static` `inline`

```cpp
static inline uint64_t drgn_object_size(const struct drgn_object * obj)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:2569

Return the number of bytes needed to store an object's value.

---

{#drgn_object_is_inline}

### drgn_object_is_inline

`static` `inline`

```cpp
static inline bool drgn_object_is_inline(const struct drgn_object * obj)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:2578

Return whether an object's value can be stored in the inline buffer of a [drgn_value](drgn_value.md#drgn_value) ([drgn_value::ibuf](#ibuf)).

---

{#drgn_object_qualified_type}

### drgn_object_qualified_type

`static` `inline`

```cpp
static inline struct drgn_qualified_type drgn_object_qualified_type(const struct drgn_object * obj)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:2591

Get the type of a [drgn_object](drgn_object.md#drgn_object-1).

---

{#drgn_object_init}

### drgn_object_init

```cpp
void drgn_object_init(struct drgn_object * obj, struct drgn_program * prog)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:2608

Initialize a [drgn_object](drgn_object.md#drgn_object-1).

The object is initialized to an absent object with a void type. This must be paired with a call to [drgn_object_deinit()](#drgn_object_deinit).

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `obj` | struct [`drgn_object`](drgn_object.md#drgn_object-1) * | Object to initialize. |
| `prog` | struct [`drgn_program`](drgn_program.md#drgn_program) * | [Program](Program.md#program) containing the object. |

---

{#drgn_object_deinit}

### drgn_object_deinit

```cpp
void drgn_object_deinit(struct drgn_object * obj)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:2618

Deinitialize a [drgn_object](drgn_object.md#drgn_object-1).

The object cannot be used after this unless it is reinitialized with [drgn_object_init()](#drgn_object_init).

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `obj` | struct [`drgn_object`](drgn_object.md#drgn_object-1) * | Object to deinitialize. |

---

{#drgn_object_initializer}

### drgn_object_initializer

```cpp
struct drgn_object drgn_object_initializer(struct drgn_program * prog)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:2640

---

{#drgn_object_program}

### drgn_object_program

`static` `inline`

```cpp
static inline struct drgn_program * drgn_object_program(const struct drgn_object * obj)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:2644

Get the program that a [drgn_object](drgn_object.md#drgn_object-1) is from.

---

{#drgn_object_language}

### drgn_object_language

`static` `inline`

```cpp
static inline const struct drgn_language * drgn_object_language(const struct drgn_object * obj)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/drgn.h:2651

Get the language of a [drgn_object](drgn_object.md#drgn_object-1) from its type.

