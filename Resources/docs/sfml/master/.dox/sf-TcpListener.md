{#tcplistener}

# TcpListener

```cpp
#include <TcpListener.hpp>
```

```cpp
class TcpListener
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/TcpListener.hpp:44

> **Inherits:** [`Socket`](sf-Socket.md#socket)

[Socket](sf-Socket.md#socket) that listens to new TCP connections.

A listener socket is a special type of socket that listens to a given port and waits for connections on that port. This is all it can do.

When a new connection is received, you must call accept and the listener returns a new instance of `[sf::TcpSocket](sf-TcpSocket.md#tcpsocket-1)` that is properly initialized and can be used to communicate with the new client.

[Listener](sf-Listener.md#listener) sockets are specific to the TCP protocol, UDP sockets are connectionless and can therefore communicate directly. As a consequence, a listener socket will always return the new connections as `[sf::TcpSocket](sf-TcpSocket.md#tcpsocket-1)` instances.

A listener is automatically closed on destruction, like all other types of socket. However if you want to stop listening before the socket is destroyed, you can call its `[close()](#close-5)` function.

Usage example: 
```cpp
// Create a listener socket and make it wait for new
// connections on port 55001
sf::TcpListener listener;
listener.listen(55001);

// Endless loop that waits for new connections
while (running)
{
    sf::TcpSocket client;
    if (listener.accept(client) == sf::Socket::Done)
    {
        // A new client just connected!
        std::cout << "New connection received from " << client.getRemoteAddress().value() << std::endl;
        doSomethingWith(client);
    }
}
```

**See also**: `[sf::TcpSocket](sf-TcpSocket.md#tcpsocket-1)`, `[sf::Socket](sf-Socket.md#socket)`

## List of all members

| Name | Kind | Owner |
|------|------|-------|
| [`TcpListener`](#tcplistener-1) | `function` | Declared here |
| [`getLocalPort`](#getlocalport) | `function` | Declared here |
| [`listen`](#listen) | `function` | Declared here |
| [`close`](#close-5) | `function` | Declared here |
| [`accept`](#accept) | `function` | Declared here |
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
|  | [`TcpListener`](#tcplistener-1)  | Default constructor. |
| `unsigned short` | [`getLocalPort`](#getlocalport) `const` `nodiscard` | Get the port to which the socket is bound locally. |
| [`Status`](Status.md#status-3) | [`listen`](#listen) `nodiscard` | Start listening for incoming connection attempts. |
| `void` | [`close`](#close-5)  | Stop listening and close the socket. |
| [`Status`](Status.md#status-3) | [`accept`](#accept) `nodiscard` | Accept a new connection. |

---

{#tcplistener-1}

### TcpListener

```cpp
TcpListener()
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/TcpListener.hpp:51

Default constructor.

---

{#getlocalport}

### getLocalPort

`const` `nodiscard`

```cpp
[[nodiscard]] unsigned short getLocalPort() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/TcpListener.hpp:64

Get the port to which the socket is bound locally.

If the socket is not listening to a port, this function returns 0.

#### Returns
Port to which the socket is bound

**See also**: `[listen](#listen)`

---

{#listen}

### listen

`nodiscard`

```cpp
[[nodiscard]] Status listen(unsigned short port, IpAddress address = IpAddress::Any)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/TcpListener.hpp:88

Start listening for incoming connection attempts.

This function makes the socket start listening on the specified port, waiting for incoming connection attempts.

If the socket is already listening on a port when this function is called, it will stop listening on the old port before starting to listen on the new port.

When providing `[sf::Socket::AnyPort](sf-Socket.md#anyport)` as port, the listener will request an available port from the system. The chosen port can be retrieved by calling `[getLocalPort()](#getlocalport)`.

#### Returns
[Status](Status.md#status-3) code

**See also**: `[accept](#accept)`, `[close](#close-5)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `port` | `unsigned short` | Port to listen on for incoming connection attempts |
| `address` | [`IpAddress`](sf-IpAddress.md#ipaddress) | Address of the interface to listen on |

---

{#close-5}

### close

```cpp
void close()
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/TcpListener.hpp:99

Stop listening and close the socket.

This function gracefully stops the listener. If the socket is not listening, this function has no effect.

**See also**: `[listen](#listen)`

---

{#accept}

### accept

`nodiscard`

```cpp
[[nodiscard]] Status accept(TcpSocket & socket)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/TcpListener.hpp:114

Accept a new connection.

If the socket is in blocking mode, this function will not return until a connection is actually received.

#### Returns
[Status](Status.md#status-3) code

**See also**: `[listen](#listen)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `socket` | [`TcpSocket`](sf-TcpSocket.md#tcpsocket-1) & | [Socket](sf-Socket.md#socket) that will hold the new connection |

