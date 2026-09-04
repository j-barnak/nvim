{#srvrecord}

# SrvRecord

```cpp
#include <Dns.hpp>
```

```cpp
struct SrvRecord
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Dns.hpp:107

A DNS SRV record.

## Public Attributes

| Return | Name | Description |
|--------|------|-------------|
| [`sf::String`](sf-String.md#string) | [`target`](#target)  | The domain name of the target host. |
| `std::uint16_t` | [`port`](#port)  | The port on the target host of the service. |
| `std::uint16_t` | [`weight`](#weight)  | Server selection mechanism, larger weights should be given a proportionately higher probability of being selected. |
| `std::uint16_t` | [`priority`](#priority)  | The priority of the target host, a client must attempt to contact the target host with the lowest-numbered priority it can reach. |

---

{#target}

### target

```cpp
sf::String target
```

Type: [`sf::String`](sf-String.md#string)

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Dns.hpp:109

The domain name of the target host.

---

{#port}

### port

```cpp
std::uint16_t port {}
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Dns.hpp:110

The port on the target host of the service.

---

{#weight}

### weight

```cpp
std::uint16_t weight {}
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Dns.hpp:111

Server selection mechanism, larger weights should be given a proportionately higher probability of being selected.

---

{#priority}

### priority

```cpp
std::uint16_t priority {}
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Dns.hpp:112

The priority of the target host, a client must attempt to contact the target host with the lowest-numbered priority it can reach.

