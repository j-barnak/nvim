{#u8stringchartraits}

# U8StringCharTraits

```cpp
#include <String.hpp>
```

```cpp
struct U8StringCharTraits
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/String.hpp:49

Character traits for `std::uint8_t`

## Public Static Methods

| Return | Name | Description |
|--------|------|-------------|
| `void` | [`assign`](#assign) `static` `noexcept` |  |
| [`char_type`](#char_type) * | [`assign`](#assign-1) `static` |  |
| `bool` | [`eq`](#eq) `static` `noexcept` |  |
| `bool` | [`lt`](#lt) `static` `noexcept` |  |
| [`char_type`](#char_type) * | [`move`](#move-2) `static` |  |
| [`char_type`](#char_type) * | [`copy`](#copy-1) `static` |  |
| `int` | [`compare`](#compare) `static` |  |
| `std::size_t` | [`length`](#length-3) `static` |  |
| const [`char_type`](#char_type) * | [`find`](#find-1) `static` |  |
| [`char_type`](#char_type) | [`to_char_type`](#to_char_type) `static` `noexcept` |  |
| [`int_type`](#int_type) | [`to_int_type`](#to_int_type) `static` `noexcept` |  |
| `bool` | [`eq_int_type`](#eq_int_type) `static` `noexcept` |  |
| [`int_type`](#int_type) | [`eof`](#eof) `static` `noexcept` |  |
| [`int_type`](#int_type) | [`not_eof`](#not_eof) `static` `noexcept` |  |

---

{#assign}

### assign

`static` `noexcept`

```cpp
static void assign(char_type & c1, char_type c2) noexcept
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/String.hpp:58

---

{#assign-1}

### assign

`static`

```cpp
static char_type * assign(char_type * s, std::size_t n, char_type c)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/String.hpp:59

---

{#eq}

### eq

`static` `noexcept`

```cpp
static bool eq(char_type c1, char_type c2) noexcept
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/String.hpp:60

---

{#lt}

### lt

`static` `noexcept`

```cpp
static bool lt(char_type c1, char_type c2) noexcept
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/String.hpp:61

---

{#move-2}

### move

`static`

```cpp
static char_type * move(char_type * s1, const char_type * s2, std::size_t n)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/String.hpp:62

---

{#copy-1}

### copy

`static`

```cpp
static char_type * copy(char_type * s1, const char_type * s2, std::size_t n)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/String.hpp:63

---

{#compare}

### compare

`static`

```cpp
static int compare(const char_type * s1, const char_type * s2, std::size_t n)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/String.hpp:64

---

{#length-3}

### length

`static`

```cpp
static std::size_t length(const char_type * s)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/String.hpp:65

---

{#find-1}

### find

`static`

```cpp
static const char_type * find(const char_type * s, std::size_t n, const char_type & c)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/String.hpp:66

---

{#to_char_type}

### to_char_type

`static` `noexcept`

```cpp
static char_type to_char_type(int_type i) noexcept
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/String.hpp:67

---

{#to_int_type}

### to_int_type

`static` `noexcept`

```cpp
static int_type to_int_type(char_type c) noexcept
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/String.hpp:68

---

{#eq_int_type}

### eq_int_type

`static` `noexcept`

```cpp
static bool eq_int_type(int_type i1, int_type i2) noexcept
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/String.hpp:69

---

{#eof}

### eof

`static` `noexcept`

```cpp
static int_type eof() noexcept
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/String.hpp:70

---

{#not_eof}

### not_eof

`static` `noexcept`

```cpp
static int_type not_eof(int_type i) noexcept
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/String.hpp:71

## Public Types

| Name | Description |
|------|-------------|
| [`char_type`](#char_type)  |  |
| [`int_type`](#int_type)  |  |
| [`off_type`](#off_type)  |  |
| [`pos_type`](#pos_type)  |  |
| [`state_type`](#state_type)  |  |

---

{#char_type}

### char_type

```cpp
using char_type = std::uint8_t
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/String.hpp:52

---

{#int_type}

### int_type

```cpp
using int_type = std::char_traits< char >::int_type
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/String.hpp:53

---

{#off_type}

### off_type

```cpp
using off_type = std::char_traits< char >::off_type
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/String.hpp:54

---

{#pos_type}

### pos_type

```cpp
using pos_type = std::char_traits< char >::pos_type
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/String.hpp:55

---

{#state_type}

### state_type

```cpp
using state_type = std::char_traits< char >::state_type
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/String.hpp:56

