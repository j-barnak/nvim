{#socket}

# Socket

```cpp
#include <Socket.hpp>
```

```cpp
class Socket
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Socket.hpp:42

> **Subclassed by:** [`TcpListener`](sf-TcpListener.md#tcplistener), [`TcpSocket`](sf-TcpSocket.md#tcpsocket-1), [`UdpSocket`](sf-UdpSocket.md#udpsocket-1)

Base class for all the socket types.

This class mainly defines internal stuff to be used by derived classes.

The only public features that it defines, and which is therefore common to all the socket classes, is the blocking state. All sockets can be set as blocking or non-blocking.

In blocking mode, socket functions will hang until the operation completes, which means that the entire program (well, in fact the current thread if you use multiple ones) will be stuck waiting for your socket operation to complete.

In non-blocking mode, all the socket functions will return immediately. If the socket is not ready to complete the requested operation, the function simply returns the proper status code (`[Socket::Status::NotReady](#classsf_1_1Socket_1a51bf0fd51057b98a10fbb866246176dcadd353567e8118a2b8df4e822e59084ab)`).

The default mode, which is blocking, is the one that is generally used, in combination with threads or selectors. The non-blocking mode is rather used in real-time applications that run an endless loop that can poll the socket often enough, and cannot afford blocking this loop.

**See also**: `[sf::TcpListener](sf-TcpListener.md#tcplistener)`, `[sf::TcpSocket](sf-TcpSocket.md#tcpsocket-1)`, `[sf::UdpSocket](sf-UdpSocket.md#udpsocket-1)`

## Friends

| Name | Description |
|------|-------------|
| [`SocketSelector`](#socketselector)  |  |

---

{#socketselector}

### SocketSelector

```cpp
friend class SocketSelector
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Socket.hpp:187

## Public Methods

| Return | Name | Description |
|--------|------|-------------|
|  | [`~Socket`](#socket-1) `virtual` | Destructor. |
|  | [`Socket`](#socket-2)  | Deleted copy constructor. |
| [`Socket`](#socket) & | [`operator=`](#operator-64)  | Deleted copy assignment. |
|  | [`Socket`](#socket-3) `noexcept` | Move constructor. |
| [`Socket`](#socket) & | [`operator=`](#operator-65) `noexcept` | Move assignment. |
| `void` | [`setBlocking`](#setblocking)  | Set the blocking state of the socket. |
| `bool` | [`isBlocking`](#isblocking) `const` `nodiscard` | Tell whether the socket is in blocking or non-blocking mode. |

---

{#socket-1}

### ~Socket

`virtual`

```cpp
virtual ~Socket()
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Socket.hpp:69

Destructor.

---

{#socket-2}

### Socket

```cpp
Socket(const Socket &) = delete
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Socket.hpp:75

Deleted copy constructor.

---

{#operator-64}

### operator=

```cpp
Socket & operator=(const Socket &) = delete
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Socket.hpp:81

Deleted copy assignment.

---

{#socket-3}

### Socket

`noexcept`

```cpp
Socket(Socket && socket) noexcept
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Socket.hpp:87

Move constructor.

---

{#operator-65}

### operator=

`noexcept`

```cpp
Socket & operator=(Socket && socket) noexcept
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Socket.hpp:93

Move assignment.

---

{#setblocking}

### setBlocking

```cpp
void setBlocking(bool blocking)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Socket.hpp:112

Set the blocking state of the socket.

In blocking mode, calls will not return until they have completed their task. For example, a call to Receive in blocking mode won't return until some data was actually received. In non-blocking mode, calls will always return immediately, using the return code to signal whether there was data available or not. By default, all sockets are blocking.

**See also**: `[isBlocking](#isblocking)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `blocking` | `bool` | `true` to set the socket as blocking, `false` for non-blocking |

---

{#isblocking}

### isBlocking

`const` `nodiscard`

```cpp
[[nodiscard]] bool isBlocking() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Socket.hpp:122

Tell whether the socket is in blocking or non-blocking mode.

#### Returns
`true` if the socket is blocking, `false` otherwise

**See also**: `[setBlocking](#setblocking)`

## Public Static Attributes

| Return | Name | Description |
|--------|------|-------------|
| `unsigned short` | [`AnyPort`](#anyport) `static` `constexpr` | Some special values used by sockets. |

---

{#anyport}

### AnyPort

`static` `constexpr`

```cpp
unsigned short AnyPort {0}
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Socket.hpp:63

Some special values used by sockets.

Special value that tells the system to pick any available port

## Protected Methods

| Return | Name | Description |
|--------|------|-------------|
|  | [`Socket`](#socket-4) `explicit` | Default constructor. |
| [`SocketHandle`](sf.md#sockethandle) | [`getNativeHandle`](#getnativehandle-1) `const` `nodiscard` | Return the internal handle of the socket. |
| `void` | [`create`](#create-9)  | Create the internal representation of the socket. |
| `void` | [`create`](#create-10)  | Create the internal representation of the socket from a socket handle. |
| `void` | [`close`](#close-4)  | Close the socket gracefully. |

---

{#socket-4}

### Socket

`explicit`

```cpp
explicit Socket(Type type)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Socket.hpp:143

Default constructor.

This constructor can only be accessed by derived classes.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `type` | [`Type`](Type.md#classsf_1_1Socket_1a5d3ff44e56e68f02816bb0fabc34adf8) | [Type](Type.md#classsf_1_1Socket_1a5d3ff44e56e68f02816bb0fabc34adf8) of the socket (TCP or UDP) |

---

{#getnativehandle-1}

### getNativeHandle

`const` `nodiscard`

```cpp
[[nodiscard]] SocketHandle getNativeHandle() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Socket.hpp:155

Return the internal handle of the socket.

The returned handle may be invalid if the socket was not created yet (or already destroyed). This function can only be accessed by derived classes.

#### Returns
The internal (OS-specific) handle of the socket

---

{#create-9}

### create

```cpp
void create(IpAddress::Type addressType = IpAddress::Type::IpV4)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Socket.hpp:165

Create the internal representation of the socket.

This function can only be accessed by derived classes.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `addressType` | [`IpAddress::Type`](Type.md#type-3) | The address type of the socket |

---

{#create-10}

### create

```cpp
void create(SocketHandle handle)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Socket.hpp:176

Create the internal representation of the socket from a socket handle.

This function can only be accessed by derived classes.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `handle` | [`SocketHandle`](sf.md#sockethandle) | OS-specific handle of the socket to wrap |

---

{#close-4}

### close

```cpp
void close()
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Socket.hpp:184

Close the socket gracefully.

This function can only be accessed by derived classes.

## Public Types

| Name | Description |
|------|-------------|
| [`Status`](#status-3)  | [Status](Status.md#status-3) codes that may be returned by socket functions. |

---

{#status-3}

### Status

```cpp
enum Status
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Socket.hpp:49

[Status](Status.md#status-3) codes that may be returned by socket functions.

| Value | Description |
|-------|-------------|
| `Done` | The socket has sent / received the data. |
| `NotReady` | The socket is not ready to send / receive data yet. |
| `Partial` | The socket sent a part of the data. |
| `Disconnected` | The TCP socket has been disconnected. |
| `Error` | An unexpected error happened. |
## Private Attributes

| Return | Name | Description |
|--------|------|-------------|
| [`Type`](Type.md#classsf_1_1Socket_1a5d3ff44e56e68f02816bb0fabc34adf8) | [`m_type`](#m_type)  | [Type](Type.md#classsf_1_1Socket_1a5d3ff44e56e68f02816bb0fabc34adf8) of the socket (TCP or UDP) |
| [`SocketHandle`](sf.md#sockethandle) | [`m_socket`](#m_socket)  | [Socket](#socket) descriptor. |
| `bool` | [`m_isBlocking`](#m_isblocking)  | Current blocking mode of the socket. |

---

{#m_type}

### m_type

```cpp
Type m_type
```

Type: [`Type`](Type.md#classsf_1_1Socket_1a5d3ff44e56e68f02816bb0fabc34adf8)

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Socket.hpp:192

[Type](Type.md#classsf_1_1Socket_1a5d3ff44e56e68f02816bb0fabc34adf8) of the socket (TCP or UDP)

---

{#m_socket}

### m_socket

```cpp
SocketHandle m_socket
```

Type: [`SocketHandle`](sf.md#sockethandle)

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Socket.hpp:193

[Socket](#socket) descriptor.

---

{#m_isblocking}

### m_isBlocking

```cpp
bool m_isBlocking {true}
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Socket.hpp:194

Current blocking mode of the socket.

