{#udpsocket-1}

# UdpSocket

```cpp
#include <UdpSocket.hpp>
```

```cpp
class UdpSocket
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/UdpSocket.hpp:49

> **Inherits:** [`Socket`](sf-Socket.md#socket)

Specialized socket using the UDP protocol.

A UDP socket is a connectionless socket. Instead of connecting once to a remote host, like TCP sockets, it can send to and receive from any host at any time.

It is a datagram protocol: bounded blocks of data (datagrams) are transferred over the network rather than a continuous stream of data (TCP). Therefore, one call to send will always match one call to receive (if the datagram is not lost), with the same data that was sent.

The UDP protocol is lightweight but unreliable. Unreliable means that datagrams may be duplicated, be lost or arrive reordered. However, if a datagram arrives, its data is guaranteed to be valid.

UDP is generally used for real-time communication (audio or video streaming, real-time games, etc.) where speed is crucial and lost data doesn't matter much.

Sending and receiving data can use either the low-level or the high-level functions. The low-level functions process a raw sequence of bytes, whereas the high-level interface uses packets (see `[sf::Packet](sf-Packet.md#packet)`), which are easier to use and provide more safety regarding the data that is exchanged. You can look at the `[sf::Packet](sf-Packet.md#packet)` class to get more details about how they work.

It is important to note that `[UdpSocket](#udpsocket-1)` is unable to send datagrams bigger than `MaxDatagramSize`. In this case, it returns an error and doesn't send anything. This applies to both raw data and packets. Indeed, even packets are unable to split and recompose data, due to the unreliability of the protocol (dropped, mixed or duplicated datagrams may lead to a big mess when trying to recompose a packet).

If the socket is bound to a port, it is automatically unbound from it when the socket is destroyed. However, you can unbind the socket explicitly with the Unbind function if necessary, to stop receiving messages or make the port available for other sockets.

Usage example: 
```cpp
// ----- The client -----

// Create a socket and bind it to the port 55001
sf::UdpSocket socket;
socket.bind(55001);

// Send a message to 192.168.1.50 on port 55002
std::string message = "Hi, I am " + sf::IpAddress::getLocalAddress().toString();
socket.send(message.c_str(), message.size() + 1, "192.168.1.50", 55002);

// Receive an answer (most likely from 192.168.1.50, but could be anyone else)
std::array<char, 1024> buffer;
std::size_t received = 0;
std::optional<sf::IpAddress> sender;
unsigned short port;
if (socket.receive(buffer.data(), buffer.size(), received, sender, port) == sf::Socket::Status::Done)
    std::cout << sender->toString() << " said: " << buffer.data() << std::endl;

// ----- The server -----

// Create a socket and bind it to the port 55002
sf::UdpSocket socket;
socket.bind(55002);

// Receive a message from anyone
std::array<char, 1024> buffer;
std::size_t received = 0;
std::optional<sf::IpAddress> sender;
unsigned short port;
if (socket.receive(buffer.data(), buffer.size(), received, sender, port) == sf::Socket::Status::Done)
    std::cout << sender->toString() << " said: " << buffer.data() << std::endl;

// Send an answer
std::string message = "Welcome " + sender.toString();
socket.send(message.c_str(), message.size() + 1, sender, port);
```

**See also**: `[sf::Socket](sf-Socket.md#socket)`, `[sf::TcpSocket](sf-TcpSocket.md#tcpsocket-1)`, `[sf::Packet](sf-Packet.md#packet)`

## List of all members

| Name | Kind | Owner |
|------|------|-------|
| [`UdpSocket`](#udpsocket-2) | `function` | Declared here |
| [`getLocalPort`](#getlocalport-2) | `function` | Declared here |
| [`bind`](#bind) | `function` | Declared here |
| [`unbind`](#unbind) | `function` | Declared here |
| [`send`](#send-3) | `function` | Declared here |
| [`receive`](#receive-2) | `function` | Declared here |
| [`send`](#send-4) | `function` | Declared here |
| [`receive`](#receive-3) | `function` | Declared here |
| [`MaxDatagramSize`](#maxdatagramsize) | `variable` | Declared here |
| [`m_buffer`](#m_buffer-1) | `variable` | Declared here |
| [`SocketSelector`](sf-Socket.md#socketselector) | `friend` | Inherited from [`Socket`](sf-Socket.md#socket) |
| [`~Socket`](sf-Socket.md#socket-1) | `function` | Inherited from [`Socket`](sf-Socket.md#socket) |
| [`Socket`](sf-Socket.md#socket-2) | `function` | Inherited from [`Socket`](sf-Socket.md#socket) |
| [`operator=`](sf-Socket.md#operator-64) | `function` | Inherited from [`Socket`](sf-Socket.md#socket) |
| [`Socket`](sf-Socket.md#socket-3) | `function` | Inherited from [`Socket`](sf-Socket.md#socket) |
| [`operator=`](sf-Socket.md#operator-65) | `function` | Inherited from [`Socket`](sf-Socket.md#socket) |
| [`setBlocking`](sf-Socket.md#setblocking) | `function` | Inherited from [`Socket`](sf-Socket.md#socket) |
| [`isBlocking`](sf-Socket.md#isblocking) | `function` | Inherited from [`Socket`](sf-Socket.md#socket) |
| [`AnyPort`](sf-Socket.md#anyport) | `variable` | Inherited from [`Socket`](sf-Socket.md#socket) |
| [`Socket`](sf-Socket.md#socket-4) | `function` | Inherited from [`Socket`](sf-Socket.md#socket) |
| [`getNativeHandle`](sf-Socket.md#getnativehandle-1) | `function` | Inherited from [`Socket`](sf-Socket.md#socket) |
| [`create`](sf-Socket.md#create-9) | `function` | Inherited from [`Socket`](sf-Socket.md#socket) |
| [`create`](sf-Socket.md#create-10) | `function` | Inherited from [`Socket`](sf-Socket.md#socket) |
| [`close`](sf-Socket.md#close-4) | `function` | Inherited from [`Socket`](sf-Socket.md#socket) |
| [`Status`](Status.md#status-3) | `enum` | Inherited from [`Socket`](sf-Socket.md#socket) |
| [`m_type`](sf-Socket.md#m_type) | `variable` | Inherited from [`Socket`](sf-Socket.md#socket) |
| [`m_socket`](sf-Socket.md#m_socket) | `variable` | Inherited from [`Socket`](sf-Socket.md#socket) |
| [`m_isBlocking`](sf-Socket.md#m_isblocking) | `variable` | Inherited from [`Socket`](sf-Socket.md#socket) |

## Inherited from [`Socket`](sf-Socket.md#socket)

| Kind | Name | Description |
|------|------|-------------|
| `friend` | [`SocketSelector`](sf-Socket.md#socketselector)  |  |
| `function` | [`~Socket`](sf-Socket.md#socket-1) `virtual` | Destructor. |
| `function` | [`Socket`](sf-Socket.md#socket-2)  | Deleted copy constructor. |
| `function` | [`operator=`](sf-Socket.md#operator-64)  | Deleted copy assignment. |
| `function` | [`Socket`](sf-Socket.md#socket-3) `noexcept` | Move constructor. |
| `function` | [`operator=`](sf-Socket.md#operator-65) `noexcept` | Move assignment. |
| `function` | [`setBlocking`](sf-Socket.md#setblocking)  | Set the blocking state of the socket. |
| `function` | [`isBlocking`](sf-Socket.md#isblocking) `const` `nodiscard` | Tell whether the socket is in blocking or non-blocking mode. |
| `variable` | [`AnyPort`](sf-Socket.md#anyport) `static` `constexpr` | Some special values used by sockets. |
| `function` | [`Socket`](sf-Socket.md#socket-4) `explicit` | Default constructor. |
| `function` | [`getNativeHandle`](sf-Socket.md#getnativehandle-1) `const` `nodiscard` | Return the internal handle of the socket. |
| `function` | [`create`](sf-Socket.md#create-9)  | Create the internal representation of the socket. |
| `function` | [`create`](sf-Socket.md#create-10)  | Create the internal representation of the socket from a socket handle. |
| `function` | [`close`](sf-Socket.md#close-4)  | Close the socket gracefully. |
| `enum` | [`Status`](Status.md#status-3)  | [Status](Status.md#status-3) codes that may be returned by socket functions. |
| `variable` | [`m_type`](sf-Socket.md#m_type)  | [Type](Type.md#classsf_1_1Socket_1a5d3ff44e56e68f02816bb0fabc34adf8) of the socket (TCP or UDP) |
| `variable` | [`m_socket`](sf-Socket.md#m_socket)  | [Socket](sf-Socket.md#socket) descriptor. |
| `variable` | [`m_isBlocking`](sf-Socket.md#m_isblocking)  | Current blocking mode of the socket. |

## Public Methods

| Return | Name | Description |
|--------|------|-------------|
|  | [`UdpSocket`](#udpsocket-2)  | Default constructor. |
| `unsigned short` | [`getLocalPort`](#getlocalport-2) `const` `nodiscard` | Get the port to which the socket is bound locally. |
| [`Status`](Status.md#status-3) | [`bind`](#bind) `nodiscard` | Bind the socket to a specific port. |
| `void` | [`unbind`](#unbind)  | Unbind the socket from the local port to which it is bound. |
| [`Status`](Status.md#status-3) | [`send`](#send-3) `nodiscard` | Send raw data to a remote peer. |
| [`Status`](Status.md#status-3) | [`receive`](#receive-2) `nodiscard` | Receive raw data from a remote peer. |
| [`Status`](Status.md#status-3) | [`send`](#send-4) `nodiscard` | Send a formatted packet of data to a remote peer. |
| [`Status`](Status.md#status-3) | [`receive`](#receive-3) `nodiscard` | Receive a formatted packet of data from a remote peer. |

---

{#udpsocket-2}

### UdpSocket

```cpp
UdpSocket()
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/UdpSocket.hpp:62

Default constructor.

---

{#getlocalport-2}

### getLocalPort

`const` `nodiscard`

```cpp
[[nodiscard]] unsigned short getLocalPort() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/UdpSocket.hpp:75

Get the port to which the socket is bound locally.

If the socket is not bound to a port, this function returns 0.

#### Returns
Port to which the socket is bound

**See also**: `[bind](#bind)`

---

{#bind}

### bind

`nodiscard`

```cpp
[[nodiscard]] Status bind(unsigned short port, IpAddress address = IpAddress::Any)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/UdpSocket.hpp:100

Bind the socket to a specific port.

Binding the socket to a port is necessary for being able to receive data on that port.

When providing `[sf::Socket::AnyPort](sf-Socket.md#anyport)` as port, the listener will request an available port from the system. The chosen port can be retrieved by calling `[getLocalPort()](#getlocalport-2)`.

Since the socket can only be bound to a single port at any given moment, if it is already bound when this function is called, it will be unbound from the previous port before being bound to the new one.

#### Returns
[Status](Status.md#status-3) code

**See also**: `[unbind](#unbind)`, `[getLocalPort](#getlocalport-2)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `port` | `unsigned short` | Port to bind the socket to |
| `address` | [`IpAddress`](sf-IpAddress.md#ipaddress) | Address of the interface to bind to |

---

{#unbind}

### unbind

```cpp
void unbind()
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/UdpSocket.hpp:114

Unbind the socket from the local port to which it is bound.

The port that the socket was previously bound to is immediately made available to the operating system after this function is called. This means that a subsequent call to `[bind()](#bind)` will be able to re-bind the port if no other process has done so in the mean time. If the socket is not bound to a port, this function has no effect.

**See also**: `[bind](#bind)`

---

{#send-3}

### send

`nodiscard`

```cpp
[[nodiscard]] Status send(const void * data, std::size_t size, IpAddress remoteAddress, unsigned short remotePort)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/UdpSocket.hpp:133

Send raw data to a remote peer.

Make sure that `size` is not greater than `[UdpSocket::MaxDatagramSize](#maxdatagramsize)`, otherwise this function will fail and no data will be sent.

#### Returns
[Status](Status.md#status-3) code

**See also**: `[receive](#receive-2)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `data` | `const void *` | Pointer to the sequence of bytes to send |
| `size` | `std::size_t` | Number of bytes to send |
| `remoteAddress` | [`IpAddress`](sf-IpAddress.md#ipaddress) | Address of the receiver |
| `remotePort` | `unsigned short` | Port of the receiver to send the data to |

---

{#receive-2}

### receive

`nodiscard`

```cpp
[[nodiscard]] Status receive(void * data, std::size_t size, std::size_t & received, std::optional< IpAddress > & remoteAddress, unsigned short & remotePort)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/UdpSocket.hpp:156

Receive raw data from a remote peer.

In blocking mode, this function will wait until some bytes are actually received. Be careful to use a buffer which is large enough for the data that you intend to receive, if it is too small then an error will be returned and *all* the data will be lost.

#### Returns
[Status](Status.md#status-3) code

**See also**: `[send](#send-3)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `data` | `void *` | Pointer to the array to fill with the received bytes |
| `size` | `std::size_t` | Maximum number of bytes that can be received |
| `received` | `std::size_t &` | This variable is filled with the actual number of bytes received |
| `remoteAddress` | std::optional< [`IpAddress`](sf-IpAddress.md#ipaddress) > & | Address of the peer that sent the data |
| `remotePort` | `unsigned short &` | Port of the peer that sent the data |

---

{#send-4}

### send

`nodiscard`

```cpp
[[nodiscard]] Status send(Packet & packet, IpAddress remoteAddress, unsigned short remotePort)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/UdpSocket.hpp:178

Send a formatted packet of data to a remote peer.

Make sure that the packet size is not greater than `[UdpSocket::MaxDatagramSize](#maxdatagramsize)`, otherwise this function will fail and no data will be sent.

#### Returns
[Status](Status.md#status-3) code

**See also**: `[receive](#receive-2)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `packet` | [`Packet`](sf-Packet.md#packet) & | [Packet](sf-Packet.md#packet) to send |
| `remoteAddress` | [`IpAddress`](sf-IpAddress.md#ipaddress) | Address of the receiver |
| `remotePort` | `unsigned short` | Port of the receiver to send the data to |

---

{#receive-3}

### receive

`nodiscard`

```cpp
[[nodiscard]] Status receive(Packet & packet, std::optional< IpAddress > & remoteAddress, unsigned short & remotePort)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/UdpSocket.hpp:195

Receive a formatted packet of data from a remote peer.

In blocking mode, this function will wait until the whole packet has been received.

#### Returns
[Status](Status.md#status-3) code

**See also**: `[send](#send-3)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `packet` | [`Packet`](sf-Packet.md#packet) & | [Packet](sf-Packet.md#packet) to fill with the received data |
| `remoteAddress` | std::optional< [`IpAddress`](sf-IpAddress.md#ipaddress) > & | Address of the peer that sent the data |
| `remotePort` | `unsigned short &` | Port of the peer that sent the data |

## Public Static Attributes

| Return | Name | Description |
|--------|------|-------------|
| `std::size_t` | [`MaxDatagramSize`](#maxdatagramsize) `static` `constexpr` | The maximum number of bytes that can be sent in a single UDP datagram. |

---

{#maxdatagramsize}

### MaxDatagramSize

`static` `constexpr`

```cpp
std::size_t MaxDatagramSize {65507}
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/UdpSocket.hpp:56

The maximum number of bytes that can be sent in a single UDP datagram.

## Private Attributes

| Return | Name | Description |
|--------|------|-------------|
| `std::vector< std::byte >` | [`m_buffer`](#m_buffer-1)  | Temporary buffer holding the received data in Receive(Packet) |

---

{#m_buffer-1}

### m_buffer

```cpp
std::vector< std::byte > m_buffer {MaxDatagramSize}
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/UdpSocket.hpp:201

Temporary buffer holding the received data in Receive(Packet)

