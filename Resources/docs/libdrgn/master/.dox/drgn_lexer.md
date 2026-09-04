{#drgn_lexer-1}

# drgn_lexer

```cpp
#include <lexer.h>
```

```cpp
struct drgn_lexer
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/lexer.h:69

Lexer instance.

A lexer comprises a lexer function, a position, and a stack of tokens. Tokens can be pushed and popped onto the stack. When the stack is empty, a pop calls the lexer function instead.

## Public Attributes

| Return | Name | Description |
|--------|------|-------------|
| [`drgn_lexer_func`](Lexer.md#drgn_lexer_func) | [`func`](#func)  | Lexer function. |
| `const char *` | [`p`](#p)  | Current position in the string. |
| `struct drgn_token_vector` | [`stack`](#stack-1)  | Stack of tokens. |

---

{#func}

### func

```cpp
drgn_lexer_func func
```

Type: [`drgn_lexer_func`](Lexer.md#drgn_lexer_func)

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/lexer.h:71

Lexer function.

---

{#p}

### p

```cpp
const char * p
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/lexer.h:73

Current position in the string.

---

{#stack-1}

### stack

```cpp
struct drgn_token_vector stack
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/lexer.h:75

Stack of tokens.

