{#lexer}

# Lexer

> [`Internals`](Internals.md#internals)

Lexical analysis.

This is a convenient interface for lexical analysis. [drgn_lexer](drgn_lexer.md#drgn_lexer-1) provides the abstraction of a stack of tokens ([drgn_token](drgn_token.md#drgn_token)) on top of a raw [drgn_lexer_func](#drgn_lexer_func).

## Classes

| Name | Description |
|------|-------------|
| [`drgn_token`](drgn_token.md#drgn_token) | Lexical token. |
| [`drgn_lexer`](drgn_lexer.md#drgn_lexer-1) | Lexer instance. |

## Macros

| Name | Description |
|------|-------------|
| [`DRGN_LEXER_INIT`](#drgn_lexer_init)  | [drgn_lexer](drgn_lexer.md#drgn_lexer-1) initializer. |
| [`DRGN_LEXER`](#drgn_lexer)  | Define and initialize a [drgn_lexer](drgn_lexer.md#drgn_lexer-1) named `lexer` that is automatically deinitialized when it goes out of scope. |

---

{#drgn_lexer_init}

### DRGN_LEXER_INIT

```cpp
#define DRGN_LEXER_INIT(lexer_func, str) { .func = (lexer_func), .p = (str), .stack = VECTOR_INIT }
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/lexer.h:84

[drgn_lexer](drgn_lexer.md#drgn_lexer-1) initializer.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `lexer_func` |  | Lexer function. |
| `str` |  | String to lex. |

---

{#drgn_lexer}

### DRGN_LEXER

```cpp
#define DRGN_LEXER(lexer, lexer_func, str) __attribute__((__cleanup__(drgn_lexer_deinit)))			\
	struct drgn_lexer lexer = DRGN_LEXER_INIT(lexer_func, str)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/lexer.h:101

Define and initialize a [drgn_lexer](drgn_lexer.md#drgn_lexer-1) named `lexer` that is automatically deinitialized when it goes out of scope.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `lexer_func` |  | Lexer function. |
| `str` |  | String to lex. |

## Typedefs

| Return | Name | Description |
|--------|------|-------------|
| struct [`drgn_error`](drgn_error.md#drgn_error) *(* | [`drgn_lexer_func`](#drgn_lexer_func)  | Lexer function. |

---

{#drgn_lexer_func}

### drgn_lexer_func

```cpp
using drgn_lexer_func = struct drgn_error *(*
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/lexer.h:1

Lexer function.

A lexer function does the work of lexing the next token in a string. It should initialize the passed in token and advance [drgn_lexer::p](drgn_lexer.md#p).

## Functions

| Return | Name | Description |
|--------|------|-------------|
|  | [`DEFINE_VECTOR_TYPE`](#define_vector_type-2)  |  |
| `void` | [`drgn_lexer_deinit`](#drgn_lexer_deinit)  | Free memory allocated by a [drgn_lexer](drgn_lexer.md#drgn_lexer-1). |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_lexer_pop`](#drgn_lexer_pop)  | Return the next token from a [drgn_lexer](drgn_lexer.md#drgn_lexer-1). |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_lexer_push`](#drgn_lexer_push)  | Push a token onto the stack of a [drgn_lexer](drgn_lexer.md#drgn_lexer-1). |
| struct [`drgn_error`](drgn_error.md#drgn_error) * | [`drgn_lexer_peek`](#drgn_lexer_peek)  | Return the next token from a [drgn_lexer](drgn_lexer.md#drgn_lexer-1) and leave it on top of the stack. |

---

{#define_vector_type-2}

### DEFINE_VECTOR_TYPE

```cpp
DEFINE_VECTOR_TYPE(drgn_token_vector, struct drgn_token)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/lexer.h:60

---

{#drgn_lexer_deinit}

### drgn_lexer_deinit

```cpp
void drgn_lexer_deinit(struct drgn_lexer * lexer)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/lexer.h:92

Free memory allocated by a [drgn_lexer](drgn_lexer.md#drgn_lexer-1).

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `lexer` | struct [`drgn_lexer`](drgn_lexer.md#drgn_lexer-1) * | Lexer to deinitialize. |

---

{#drgn_lexer_pop}

### drgn_lexer_pop

```cpp
struct drgn_error * drgn_lexer_pop(struct drgn_lexer * lexer, struct drgn_token * token)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/lexer.h:113

Return the next token from a [drgn_lexer](drgn_lexer.md#drgn_lexer-1).

If there are tokens on the stack, this pops and returns the top token. Otherwise, this calls the lexer function to get the next token.

#### Returns
`NULL` on success, non-`NULL` on error.

---

{#drgn_lexer_push}

### drgn_lexer_push

```cpp
struct drgn_error * drgn_lexer_push(struct drgn_lexer * lexer, const struct drgn_token * token)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/lexer.h:123

Push a token onto the stack of a [drgn_lexer](drgn_lexer.md#drgn_lexer-1).

This token must have been returned by [drgn_lexer_pop()](#drgn_lexer_pop).

#### Returns
`NULL` on success, non-`NULL` on error.

---

{#drgn_lexer_peek}

### drgn_lexer_peek

```cpp
struct drgn_error * drgn_lexer_peek(struct drgn_lexer * lexer, struct drgn_token * token)
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/lexer.h:135

Return the next token from a [drgn_lexer](drgn_lexer.md#drgn_lexer-1) and leave it on top of the stack.

This is equivalent to a call to [drgn_lexer_pop()](#drgn_lexer_pop) immediately followed by a call to [drgn_lexer_push()](#drgn_lexer_push).

#### Returns
`NULL` on success, non-`NULL` on error.

