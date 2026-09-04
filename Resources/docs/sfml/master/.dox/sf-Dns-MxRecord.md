{#mxrecord}

# MxRecord

```cpp
#include <Dns.hpp>
```

```cpp
struct MxRecord
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Dns.hpp:83

A DNS MX record.

## Public Attributes

| Return | Name | Description |
|--------|------|-------------|
| [`sf::String`](sf-String.md#string) | [`exchange`](#exchange)  | Host willing to act as mail exchange. |
| `std::uint16_t` | [`preference`](#preference)  | Preference of this record among others, lower values are preferred. |

---

{#exchange}

### exchange

```cpp
sf::String exchange
```

Type: [`sf::String`](sf-String.md#string)

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Dns.hpp:85

Host willing to act as mail exchange.

---

{#preference}

### preference

```cpp
std::uint16_t preference {}
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Dns.hpp:86

Preference of this record among others, lower values are preferred.

