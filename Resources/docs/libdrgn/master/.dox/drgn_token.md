{#drgn_token}

# drgn_token

```cpp
#include <lexer.h>
```

```cpp
struct drgn_token
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/lexer.h:46

Lexical token.

## Public Attributes

| Return | Name | Description |
|--------|------|-------------|
| `int` | [`kind`](#kind-4)  | Kind of token as defined by the lexer function. |
| `const char *` | [`value`](#value-1)  | String value of the token (i.e., the lexeme). |
| `size_t` | [`len`](#len-1)  | Length of the token value. |

---

{#kind-4}

### kind

```cpp
int kind
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/lexer.h:48

Kind of token as defined by the lexer function.

---

{#value-1}

### value

```cpp
const char * value
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/lexer.h:55

String value of the token (i.e., the lexeme).

This points to the contents of the original string, so it isn't null-terminated.

---

{#len-1}

### len

```cpp
size_t len
```

Defined in /home/jared/.local/share/nvim/docs/libdrgn/master/libdrgn/lexer.h:57

Length of the token value.

