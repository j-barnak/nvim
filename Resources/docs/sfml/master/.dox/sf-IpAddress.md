{#ipaddress}

# IpAddress

```cpp
#include <IpAddress.hpp>
```

```cpp
class IpAddress
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/IpAddress.hpp:50

Encapsulate an IPv4 network address.

`[sf::IpAddress](#ipaddress)` is a utility class for manipulating network addresses. It provides a set a implicit constructors and conversion functions to easily build or transform an IP address from/to various representations.

Usage example: 
```cpp
auto a0  = sf::IpAddress::fromString("127.0.0.1");                                                                  // the local host IPv4 address
auto a1  = sf::IpAddress::fromString("::1");                                                                        // the local host IPv6 address
auto a2  = sf::IpAddress::Broadcast;                                                                                // the broadcast address
sf::IpAddress a3(192, 168, 1, 56);                                                                                  // a local IPv4 address
sf::IpAddress a4({0xfe, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x5d, 0x58, 0x84, 0xef, 0xc1, 0x34, 0xfd}); // a local IPv6 address
auto a5  = sf::IpAddress::fromString("89.54.1.169");                                                                // a distant IPv4 address
auto a6  = sf::IpAddress::fromString("2606:4700:4700::1111");                                                       // a distant IPv6 address
auto a7  = sf::IpAddress::getLocalAddress(sf::IpAddress::Type::IpV4);                                               // my IPv4 address on the local network
auto a8  = sf::IpAddress::getLocalAddress(sf::IpAddress::Type::IpV6);                                               // my IPv6 address on the local network
auto a9  = sf::IpAddress::getPublicAddress(sf::Time::Zero, sf::IpAddress::Type::IpV4);                              // my IPv4 address on the internet
auto a10 = sf::IpAddress::getPublicAddress(sf::Time::Zero, sf::IpAddress::Type::IpV6);                              // my IPv6 address on the internet
```

To resolve hostnames to IP addresses, use the [sf::Dns::resolve()](sf-Dns.md#resolve-1) function.

## Friends

| Name | Description |
|------|-------------|
| [`operator<`](#operator-28)  | Overload of `operator<` to compare two IP addresses. |

---

{#operator-28}

### operator<

```cpp
friend bool operator<(IpAddress left, IpAddress right)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/IpAddress.hpp:302

Overload of `operator<` to compare two IP addresses.

#### Returns
`true` if `left` is lesser than `right`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `left` | [`IpAddress`](#ipaddress) | Left operand (a IP address) |
| `right` | [`IpAddress`](#ipaddress) | Right operand (a IP address) |

## Public Methods

| Return | Name | Description |
|--------|------|-------------|
|  | [`IpAddress`](#ipaddress-1)  | Construct an IPv4 address from 4 bytes. |
|  | [`IpAddress`](#ipaddress-2) `explicit` | Construct an IPv4 address from a 32-bit integer. |
|  | [`IpAddress`](#ipaddress-3)  | Construct an IPv6 address from 16 bytes. |
| `std::string` | [`toString`](#tostring) `const` `nodiscard` | Get a string representation of the address. |
| `std::uint32_t` | [`toInteger`](#tointeger) `const` `nodiscard` | Get an integer representation of the address. |
| `std::array< std::uint8_t, 16 >` | [`toBytes`](#tobytes) `const` `nodiscard` | Get an array of bytes representing the address. |
| [`Type`](Type.md#type-3) | [`getType`](#gettype) `const` `nodiscard` | Get the type of this IP address. |
| `bool` | [`isV4`](#isv4) `const` `nodiscard` | Check if this IP address is an IPv4 address. |
| `bool` | [`isV6`](#isv6) `const` `nodiscard` | Check if this IP address is an IPv6 address. |

---

{#ipaddress-1}

### IpAddress

```cpp
IpAddress(std::uint8_t byte0, std::uint8_t byte1, std::uint8_t byte2, std::uint8_t byte3)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/IpAddress.hpp:95

Construct an IPv4 address from 4 bytes.

Calling `IpAddress(a, b, c, d)` is equivalent to calling `[IpAddress::resolve](#resolve)("a.b.c.d")`, but safer as it doesn't have to parse a string to get the address components.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `byte0` | `std::uint8_t` | First byte of the address |
| `byte1` | `std::uint8_t` | Second byte of the address |
| `byte2` | `std::uint8_t` | Third byte of the address |
| `byte3` | `std::uint8_t` | Fourth byte of the address |

---

{#ipaddress-2}

### IpAddress

`explicit`

```cpp
explicit IpAddress(std::uint32_t address)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/IpAddress.hpp:110

Construct an IPv4 address from a 32-bit integer.

This constructor uses the internal representation of the address directly. It should be used for optimization purposes, and only if you got that representation from `[IpAddress::toInteger()](#tointeger)`.

**See also**: `[toInteger](#tointeger)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `address` | `std::uint32_t` | 4 bytes of the address packed into a 32-bit integer |

---

{#ipaddress-3}

### IpAddress

```cpp
IpAddress(std::array< std::uint8_t, 16 > bytes)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/IpAddress.hpp:118

Construct an IPv6 address from 16 bytes.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `bytes` | `std::array< std::uint8_t, 16 >` | Array of 16 bytes containing the address |

---

{#tostring}

### toString

`const` `nodiscard`

```cpp
[[nodiscard]] std::string toString() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/IpAddress.hpp:162

Get a string representation of the address.

The returned string is the decimal representation of the IP address (like "192.168.1.56" or "FF01::101"), even if it was constructed from a host name.

#### Returns
[String](sf-String.md#string) representation of the address

**See also**: `[fromString](#fromstring)`, `[toInteger](#tointeger)`

---

{#tointeger}

### toInteger

`const` `nodiscard`

```cpp
[[nodiscard]] std::uint32_t toInteger() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/IpAddress.hpp:181

Get an integer representation of the address.

This function can only be called if this is an IPv4 address. Check with [isV4()](#isv4) before calling this function.

The returned number is the internal representation of the address, and should be used for optimization purposes only (like sending the address through a socket). The integer produced by this function can then be converted back to a `[sf::IpAddress](#ipaddress)` with the proper constructor.

#### Returns
32-bits unsigned integer representation of the address

**See also**: `[toString](#tostring)`

---

{#tobytes}

### toBytes

`const` `nodiscard`

```cpp
[[nodiscard]] std::array< std::uint8_t, 16 > toBytes() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/IpAddress.hpp:200

Get an array of bytes representing the address.

This function can only be called if this is an IPv6 address. Check with [isV6()](#isv6) before calling this function.

The returned array is the internal representation of the address, and should be used for optimization purposes only (like sending the address through a socket). The array produced by this function can then be converted back to a `[sf::IpAddress](#ipaddress)` with the proper constructor.

#### Returns
16-byte array representation of the address

**See also**: `[toString](#tostring)`

---

{#gettype}

### getType

`const` `nodiscard`

```cpp
[[nodiscard]] Type getType() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/IpAddress.hpp:208

Get the type of this IP address.

#### Returns
The type of this IP address (IPv4 or IPv6)

---

{#isv4}

### isV4

`const` `nodiscard`

```cpp
[[nodiscard]] bool isV4() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/IpAddress.hpp:218

Check if this IP address is an IPv4 address.

Equivalent to [getType()](#gettype) == Type::IPv4

#### Returns
true if this is an IPv4 address, false otherwise

---

{#isv6}

### isV6

`const` `nodiscard`

```cpp
[[nodiscard]] bool isV6() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/IpAddress.hpp:228

Check if this IP address is an IPv6 address.

Equivalent to [getType()](#gettype) == Type::IPv6

#### Returns
true if this is an IPv6 address, false otherwise

## Public Static Attributes

| Return | Name | Description |
|--------|------|-------------|
| const [`IpAddress`](#ipaddress) | [`Any`](#any) `static` | The same as AnyV4. |
| const [`IpAddress`](#ipaddress) | [`LocalHost`](#localhost) `static` | The same as LocalHostV4. |
| const [`IpAddress`](#ipaddress) | [`Broadcast`](#broadcast) `static` | The same as BroadcastV4. |
| const [`IpAddress`](#ipaddress) | [`AnyV4`](#anyv4) `static` | Value representing any IPv4 address (0.0.0.0) |
| const [`IpAddress`](#ipaddress) | [`LocalHostV4`](#localhostv4) `static` | The "localhost" IPv4 address (for connecting a computer to itself locally) |
| const [`IpAddress`](#ipaddress) | [`BroadcastV4`](#broadcastv4) `static` | The "broadcast" IPv4 address (for sending UDP messages to everyone on a local network) |
| const [`IpAddress`](#ipaddress) | [`AnyV6`](#anyv6) `static` | Value representing any IPv6 address (::) |
| const [`IpAddress`](#ipaddress) | [`LocalHostV6`](#localhostv6) `static` | The "localhost" IPv6 address (for connecting a computer to itself locally) |

---

{#any}

### Any

`static`

```cpp
const IpAddress Any
```

Type: const [`IpAddress`](#ipaddress)

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/IpAddress.hpp:288

The same as AnyV4.

---

{#localhost}

### LocalHost

`static`

```cpp
const IpAddress LocalHost
```

Type: const [`IpAddress`](#ipaddress)

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/IpAddress.hpp:289

The same as LocalHostV4.

---

{#broadcast}

### Broadcast

`static`

```cpp
const IpAddress Broadcast
```

Type: const [`IpAddress`](#ipaddress)

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/IpAddress.hpp:290

The same as BroadcastV4.

---

{#anyv4}

### AnyV4

`static`

```cpp
const IpAddress AnyV4
```

Type: const [`IpAddress`](#ipaddress)

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/IpAddress.hpp:291

Value representing any IPv4 address (0.0.0.0)

---

{#localhostv4}

### LocalHostV4

`static`

```cpp
const IpAddress LocalHostV4
```

Type: const [`IpAddress`](#ipaddress)

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/IpAddress.hpp:292

The "localhost" IPv4 address (for connecting a computer to itself locally)

---

{#broadcastv4}

### BroadcastV4

`static`

```cpp
const IpAddress BroadcastV4
```

Type: const [`IpAddress`](#ipaddress)

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/IpAddress.hpp:293

The "broadcast" IPv4 address (for sending UDP messages to everyone on a local network)

---

{#anyv6}

### AnyV6

`static`

```cpp
const IpAddress AnyV6
```

Type: const [`IpAddress`](#ipaddress)

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/IpAddress.hpp:294

Value representing any IPv6 address (::)

---

{#localhostv6}

### LocalHostV6

`static`

```cpp
const IpAddress LocalHostV6
```

Type: const [`IpAddress`](#ipaddress)

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/IpAddress.hpp:295

The "localhost" IPv6 address (for connecting a computer to itself locally)

## Public Static Methods

| Return | Name | Description |
|--------|------|-------------|
| std::optional< [`IpAddress`](#ipaddress) > | [`resolve`](#resolve) `static` `nodiscard` | Construct the address from a null-terminated string view. |
| std::optional< [`IpAddress`](#ipaddress) > | [`fromString`](#fromstring) `static` `nodiscard` | Try to construct an address from its string representation. |
| std::optional< [`IpAddress`](#ipaddress) > | [`getLocalAddress`](#getlocaladdress) `static` `nodiscard` | Get the computer's local address. |
| std::optional< [`IpAddress`](#ipaddress) > | [`getPublicAddress`](#getpublicaddress) `static` `nodiscard` | Get the computer's public address. |

---

{#resolve}

### resolve

`static` `nodiscard`

```cpp
[[nodiscard]] static std::optional< IpAddress > resolve(std::string_view address)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/IpAddress.hpp:79

Construct the address from a null-terminated string view.

> Deprecated: Use `[sf::Dns::resolve()](sf-Dns.md#resolve-1)` instead.

Here *address* can be either a decimal address (ex: "192.168.1.56") or a network name (ex: "localhost").

This function will only resolve to an IPv4 address. Use [Dns::resolve()](sf-Dns.md#resolve-1) to resolve to IPv6 addresses as well.

#### Returns
Address if provided argument was valid, otherwise `std::nullopt`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `address` | `std::string_view` | IP address or network name |

---

{#fromstring}

### fromString

`static` `nodiscard`

```cpp
[[nodiscard]] static std::optional< IpAddress > fromString(std::string_view address)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/IpAddress.hpp:148

Try to construct an address from its string representation.

The string should contain either a valid representation of an IPv4 address in dotted-decimal notation or a valid representation of an IPv6 address in internet standard notation.

Examples:

* 192.168.1.56
* FEDC:BA98:7654:3210:FEDC:BA98:7654:3210
* fedc:ba98:7654:3210:fedc:ba98:7654:3210
* 1080:0:0:0:8:800:200C:417A
* 1080::8:800:200C:417A
* FF01::101
* ::1
* ::
* 0:0:0:0:0:0:13.1.68.3
* ::13.1.68.3
* 0:0:0:0:0:FFFF:129.144.52.38
* ::FFFF:129.144.52.38

#### Returns
Address if provided argument was a valid string represenation of an IP address, otherwise `std::nullopt`

**See also**: `[toString](#tostring)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `address` | `std::string_view` | [String](sf-String.md#string) representation of the address |

---

{#getlocaladdress}

### getLocalAddress

`static` `nodiscard`

```cpp
[[nodiscard]] static std::optional< IpAddress > getLocalAddress(Type type = Type::IpV4)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/IpAddress.hpp:246

Get the computer's local address.

The local address is the address of the computer from the LAN point of view, i.e. something like 192.168.1.56. It is meaningful only for communications over the local network. Unlike getPublicAddress, this function is fast and may be used safely anywhere.

#### Returns
Local IP address of the computer on success, `std::nullopt` otherwise

**See also**: `[getPublicAddress](#getpublicaddress)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `type` | [`Type`](Type.md#type-3) | [Type](Type.md#type-3) of local address |

---

{#getpublicaddress}

### getPublicAddress

`static` `nodiscard`

```cpp
[[nodiscard]] static std::optional< IpAddress > getPublicAddress(Time timeout = Time::Zero, std::optional< Type > type = Type::IpV4, bool secure = false)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/IpAddress.hpp:280

Get the computer's public address.

The public address is the address of the computer from the point of view of the internet, i.e. something like 89.54.1.169 or 2600:1901:0:13e0::1 as opposed to a private or local address like 192.168.1.56 or fe80::1234:5678:9abc. It is necessary for communication with hosts outside of the local network.

The only way to reliably get the public address is to send data to a host on the internet and see what the origin address is; as a consequence, this function depends on both your network connection and the server, and may be very slow. You should try to use it as little as possible. Because this function depends on the network connection and on a distant server, you can specify a time limit if you don't want your program to get stuck waiting in case there is a problem; this limit is deactivated by default.

If tamper resistance is required, setting `secure` to `true` will make use of verified HTTPS connections to get the address.

#### Returns
Public IP address of the computer on success, `std::nullopt` otherwise

**See also**: `[getLocalAddress](#getlocaladdress)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `timeout` | [`Time`](sf-Time.md#time) | Maximum time to wait |
| `type` | std::optional< [`Type`](Type.md#type-3) > | The type of public address to get, `std::nullopt` to specify no preference |
| `secure` | `bool` | true to retrieve the public address via a secure HTTPS connection, false to retrieve via DNS or an insecure connection |

## Public Types

| Name | Description |
|------|-------------|
| [`Type`](#type-3)  | [Type](Type.md#type-3) of IP address. |

---

{#type-3}

### Type

```cpp
enum Type
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/IpAddress.hpp:57

[Type](Type.md#type-3) of IP address.

| Value | Description |
|-------|-------------|
| `IpV4` | IPv4 address. |
| `IpV6` | IPv6 address. |
## Private Attributes

| Return | Name | Description |
|--------|------|-------------|
| `std::variant< V4Data, V6Data >` | [`m_address`](#m_address)  | Address stored as an unsigned 32 bit integer or array of 16 bytes. |

---

{#m_address}

### m_address

```cpp
std::variant< V4Data, V6Data > m_address
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/IpAddress.hpp:310

Address stored as an unsigned 32 bit integer or array of 16 bytes.

