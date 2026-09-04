{#tcpsocket-1}

# TcpSocket

```cpp
#include <TcpSocket.hpp>
```

```cpp
class TcpSocket
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/TcpSocket.hpp:57

> **Inherits:** [`Socket`](sf-Socket.md#socket)

Specialized socket using the TCP protocol.

TCP is a connected protocol, which means that a TCP socket can only communicate with the host it is connected to. It can't send or receive anything if it is not connected.

The TCP protocol is reliable but adds a slight overhead. It ensures that your data will always be received in order and without errors (no data corrupted, lost or duplicated).

When a socket is connected to a remote host, you can retrieve information about this host with the `getRemoteAddress` and `getRemotePort` functions. You can also get the local port to which the socket is bound (which is automatically chosen when the socket is connected), with the getLocalPort function.

Sending and receiving data can use either the low-level or the high-level functions. The low-level functions process a raw sequence of bytes, and cannot ensure that one call to Send will exactly match one call to Receive at the other end of the socket.

The high-level interface uses packets (see `[sf::Packet](sf-Packet.md#packet)`), which are easier to use and provide more safety regarding the data that is exchanged. You can look at the `[sf::Packet](sf-Packet.md#packet)` class to get more details about how they work.

The socket is automatically disconnected when it is destroyed, but if you want to explicitly close the connection while the socket instance is still alive, you can call disconnect.

Usage example: 
```cpp
// ----- The client -----

// Create a socket and connect it to 192.168.1.50 on port 55001
sf::TcpSocket socket;
socket.connect("192.168.1.50", 55001);

// Send a message to the connected host
std::string message = "Hi, I am a client";
socket.send(message.c_str(), message.size() + 1);

// Receive an answer from the server
std::array<char, 1024> buffer;
std::size_t received = 0;
socket.receive(buffer.data(), buffer.size(), received);
std::cout << "The server said: " << buffer.data() << std::endl;

// ----- The server -----

// Create a listener to wait for incoming connections on port 55001
sf::TcpListener listener;
listener.listen(55001);

// Wait for a connection
sf::TcpSocket socket;
listener.accept(socket);
std::cout << "New client connected: " << socket.getRemoteAddress().value() << std::endl;

// Receive a message from the client
std::array<char, 1024> buffer;
std::size_t received = 0;
socket.receive(buffer.data(), buffer.size(), received);
std::cout << "The client said: " << buffer.data() << std::endl;

// Send an answer
std::string message = "Welcome, client";
socket.send(message.c_str(), message.size() + 1);
```

**See also**: `[sf::Socket](sf-Socket.md#socket)`, `[sf::UdpSocket](sf-UdpSocket.md#udpsocket-1)`, `[sf::Packet](sf-Packet.md#packet)`

## List of all members

| Name | Kind | Owner |
|------|------|-------|
| [`TcpListener`](#tcplistener-2) | `friend` | Declared here |
| [`TcpSocket`](#tcpsocket-2) | `function` | Declared here |
| [`~TcpSocket`](#tcpsocket-3) | `function` | Declared here |
| [`TcpSocket`](#tcpsocket-4) | `function` | Declared here |
| [`operator=`](#operator-68) | `function` | Declared here |
| [`TcpSocket`](#tcpsocket-5) | `function` | Declared here |
| [`operator=`](#operator-69) | `function` | Declared here |
| [`getLocalPort`](#getlocalport-1) | `function` | Declared here |
| [`getRemoteAddress`](#getremoteaddress) | `function` | Declared here |
| [`getRemotePort`](#getremoteport) | `function` | Declared here |
| [`connect`](#connect-2) | `function` | Declared here |
| [`disconnect`](#disconnect-2) | `function` | Declared here |
| [`setupTlsClient`](#setuptlsclient) | `function` | Declared here |
| [`setupTlsClient`](#setuptlsclient-1) | `function` | Declared here |
| [`setupTlsClient`](#setuptlsclient-2) | `function` | Declared here |
| [`setupTlsClient`](#setuptlsclient-3) | `function` | Declared here |
| [`setupTlsServer`](#setuptlsserver) | `function` | Declared here |
| [`setupTlsServer`](#setuptlsserver-1) | `function` | Declared here |
| [`getCurrentCiphersuiteName`](#getcurrentciphersuitename) | `function` | Declared here |
| [`send`](#send) | `function` | Declared here |
| [`send`](#send-1) | `function` | Declared here |
| [`receive`](#receive) | `function` | Declared here |
| [`send`](#send-2) | `function` | Declared here |
| [`receive`](#receive-1) | `function` | Declared here |
| [`TlsStatus`](TlsStatus.md#tlsstatus) | `enum` | Declared here |
| [`m_impl`](#m_impl-8) | `variable` | Declared here |
| [`m_pendingPacket`](#m_pendingpacket) | `variable` | Declared here |
| [`m_blockToSendBuffer`](#m_blocktosendbuffer) | `variable` | Declared here |
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

## Friends

| Name | Description |
|------|-------------|
| [`TcpListener`](#tcplistener-2)  |  |

---

{#tcplistener-2}

### TcpListener

```cpp
friend class TcpListener
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/TcpSocket.hpp:597

## Public Methods

| Return | Name | Description |
|--------|------|-------------|
|  | [`TcpSocket`](#tcpsocket-2)  | Default constructor. |
|  | [`~TcpSocket`](#tcpsocket-3) `override` | Destructor. |
|  | [`TcpSocket`](#tcpsocket-4)  | Deleted copy constructor. |
| [`TcpSocket`](#tcpsocket-1) & | [`operator=`](#operator-68)  | Deleted copy assignment. |
|  | [`TcpSocket`](#tcpsocket-5) `noexcept` | Move constructor. |
| [`TcpSocket`](#tcpsocket-1) & | [`operator=`](#operator-69) `noexcept` | Move assignment. |
| `unsigned short` | [`getLocalPort`](#getlocalport-1) `const` `nodiscard` | Get the port to which the socket is bound locally. |
| std::optional< [`IpAddress`](sf-IpAddress.md#ipaddress) > | [`getRemoteAddress`](#getremoteaddress) `const` `nodiscard` | Get the address of the connected peer. |
| `unsigned short` | [`getRemotePort`](#getremoteport) `const` `nodiscard` | Get the port of the connected peer to which the socket is connected. |
| [`Status`](Status.md#status-3) | [`connect`](#connect-2) `nodiscard` | Connect the socket to a remote peer. |
| `void` | [`disconnect`](#disconnect-2)  | Disconnect the socket from its remote peer. |
| [`TlsStatus`](TlsStatus.md#tlsstatus) | [`setupTlsClient`](#setuptlsclient)  | Set up transport layer security as a client. |
| [`TlsStatus`](TlsStatus.md#tlsstatus) | [`setupTlsClient`](#setuptlsclient-1)  | Set up transport layer security as a client. |
| [`TlsStatus`](TlsStatus.md#tlsstatus) | [`setupTlsClient`](#setuptlsclient-2)  | Set up transport layer security as a client. |
| [`TlsStatus`](TlsStatus.md#tlsstatus) | [`setupTlsClient`](#setuptlsclient-3)  | Set up transport layer security as a client. |
| [`TlsStatus`](TlsStatus.md#tlsstatus) | [`setupTlsServer`](#setuptlsserver)  | Set up transport layer security as a server. |
| [`TlsStatus`](TlsStatus.md#tlsstatus) | [`setupTlsServer`](#setuptlsserver-1)  | Set up transport layer security as a server. |
| `std::optional< std::string >` | [`getCurrentCiphersuiteName`](#getcurrentciphersuitename) `const` `nodiscard` | Get the name of the TLS ciphersuite currently in use. |
| [`Status`](Status.md#status-3) | [`send`](#send) `nodiscard` | Send raw data to the remote peer. |
| [`Status`](Status.md#status-3) | [`send`](#send-1) `nodiscard` | Send raw data to the remote peer. |
| [`Status`](Status.md#status-3) | [`receive`](#receive) `nodiscard` | Receive raw data from the remote peer. |
| [`Status`](Status.md#status-3) | [`send`](#send-2) `nodiscard` | Send a formatted packet of data to the remote peer. |
| [`Status`](Status.md#status-3) | [`receive`](#receive-1) `nodiscard` | Receive a formatted packet of data from the remote peer. |

---

{#tcpsocket-2}

### TcpSocket

```cpp
TcpSocket()
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/TcpSocket.hpp:76

Default constructor.

---

{#tcpsocket-3}

### ~TcpSocket

`override`

```cpp
~TcpSocket() override
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/TcpSocket.hpp:82

Destructor.

---

{#tcpsocket-4}

### TcpSocket

```cpp
TcpSocket(const TcpSocket &) = delete
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/TcpSocket.hpp:88

Deleted copy constructor.

---

{#operator-68}

### operator=

```cpp
TcpSocket & operator=(const TcpSocket &) = delete
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/TcpSocket.hpp:94

Deleted copy assignment.

---

{#tcpsocket-5}

### TcpSocket

`noexcept`

```cpp
TcpSocket(TcpSocket &&) noexcept
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/TcpSocket.hpp:100

Move constructor.

---

{#operator-69}

### operator=

`noexcept`

```cpp
TcpSocket & operator=(TcpSocket &&) noexcept
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/TcpSocket.hpp:106

Move assignment.

---

{#getlocalport-1}

### getLocalPort

`const` `nodiscard`

```cpp
[[nodiscard]] unsigned short getLocalPort() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/TcpSocket.hpp:118

Get the port to which the socket is bound locally.

If the socket is not connected, this function returns 0.

#### Returns
Port to which the socket is bound

**See also**: `[connect](#connect-2)`, `[getRemotePort](#getremoteport)`

---

{#getremoteaddress}

### getRemoteAddress

`const` `nodiscard`

```cpp
[[nodiscard]] std::optional< IpAddress > getRemoteAddress() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/TcpSocket.hpp:131

Get the address of the connected peer.

If the socket is not connected, this function returns an unset optional.

#### Returns
Address of the remote peer

**See also**: `[getRemotePort](#getremoteport)`

---

{#getremoteport}

### getRemotePort

`const` `nodiscard`

```cpp
[[nodiscard]] unsigned short getRemotePort() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/TcpSocket.hpp:144

Get the port of the connected peer to which the socket is connected.

If the socket is not connected, this function returns 0.

#### Returns
Remote port to which the socket is connected

**See also**: `[getRemoteAddress](#getremoteaddress)`

---

{#connect-2}

### connect

`nodiscard`

```cpp
[[nodiscard]] Status connect(IpAddress remoteAddress, unsigned short remotePort, Time timeout = Time::Zero)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/TcpSocket.hpp:164

Connect the socket to a remote peer.

In blocking mode, this function may take a while, especially if the remote peer is not reachable. The last parameter allows you to stop trying to connect after a given timeout. If the socket is already connected, the connection is forcibly disconnected before attempting to connect again.

#### Returns
[Status](Status.md#status-3) code

**See also**: `[disconnect](#disconnect-2)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `remoteAddress` | [`IpAddress`](sf-IpAddress.md#ipaddress) | Address of the remote peer |
| `remotePort` | `unsigned short` | Port of the remote peer |
| `timeout` | [`Time`](sf-Time.md#time) | Optional maximum time to wait |

---

{#disconnect-2}

### disconnect

```cpp
void disconnect()
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/TcpSocket.hpp:175

Disconnect the socket from its remote peer.

This function gracefully closes the connection. If the socket is not connected, this function has no effect.

**See also**: `[connect](#connect-2)`

---

{#setuptlsclient}

### setupTlsClient

```cpp
TlsStatus setupTlsClient(const sf::String & hostname, bool verifyPeer = true)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/TcpSocket.hpp:229

Set up transport layer security as a client.

Once the TCP connection is connected, transport layer security can be set up.

All the necessary cryptographic initialization will be performed when this function is called.

If this function is called before the TCP connection is connected, it will return `[TlsStatus::NotConnected](#classsf_1_1TcpSocket_1a9a86e52dd790031dbb71fdec9ee49f7ca4075072d219e061ca0f3124f8fbef463)` and must be called again once the TCP connection is connected.

If this function started TLS setup but could not finish it within this call e.g. because this socket was set to non-blocking, it will return `[TlsStatus::HandshakeStarted](#classsf_1_1TcpSocket_1a9a86e52dd790031dbb71fdec9ee49f7caabe8fc205c65abb83d4cf1e207c0ffad)` and this function will have to be called repeatedly until `[TlsStatus::HandshakeComplete](#classsf_1_1TcpSocket_1a9a86e52dd790031dbb71fdec9ee49f7ca2fb8d9ac195da6ca22590a5e553169ec)` is returned. If this socket is blocking, `[TlsStatus::HandshakeComplete](#classsf_1_1TcpSocket_1a9a86e52dd790031dbb71fdec9ee49f7ca2fb8d9ac195da6ca22590a5e553169ec)` should be returned within the same function call if TLS setup was successful.

If `[TlsStatus::Error](#classsf_1_1TcpSocket_1a9a86e52dd790031dbb71fdec9ee49f7ca902b0d55fddef6f8d651fe1035b7d4bd)` is returned, something went wrong with TLS setup and the connection must be reconnected and TLS setup reattempted after it is connected again.

If verification is enabled, this function verifies the peer using the system provided certificate store. If the peer does not have a certificate that was signed by a certificate authority i.e. a self-signed certificate, the entire certificate chain can be provided using the alternative overload.

Servers that host multiple services under different names need to know which of those services we want to connect to in order to reply with the correct certificate chain. Server name indication (SNI) is used for this purpose. The hostname provided to this function is sent to the server if it supports SNI in order for it to return the corresponding certificate chain. The hostname is then used to verify the certificate chain that was returned by the server. If the server does not support SNI or only serves a single certificate chain, the hostname will only be used for verification.

#### Returns
TLS status code

**See also**: `[setupTlsServer](#setuptlsserver)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `hostname` | const [`sf::String`](sf-String.md#string) & | Hostname of the remote peer, used for verification |
| `verifyPeer` | `bool` | `true` to enable peer verification, `false` to disable it |

---

{#setuptlsclient-1}

### setupTlsClient

```cpp
TlsStatus setupTlsClient(const sf::String & hostname, const char * certificateChainData)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/TcpSocket.hpp:287

Set up transport layer security as a client.

Once the TCP connection is connected, transport layer security can be set up.

All the necessary cryptographic initialization will be performed when this function is called.

If this function is called before the TCP connection is connected, it will return `[TlsStatus::NotConnected](#classsf_1_1TcpSocket_1a9a86e52dd790031dbb71fdec9ee49f7ca4075072d219e061ca0f3124f8fbef463)` and must be called again once the TCP connection is connected.

If this function started TLS setup but could not finish it within this call e.g. because this socket was set to non-blocking, it will return `[TlsStatus::HandshakeStarted](#classsf_1_1TcpSocket_1a9a86e52dd790031dbb71fdec9ee49f7caabe8fc205c65abb83d4cf1e207c0ffad)` and this function will have to be called repeatedly until `[TlsStatus::HandshakeComplete](#classsf_1_1TcpSocket_1a9a86e52dd790031dbb71fdec9ee49f7ca2fb8d9ac195da6ca22590a5e553169ec)` is returned. If this socket is blocking, `[TlsStatus::HandshakeComplete](#classsf_1_1TcpSocket_1a9a86e52dd790031dbb71fdec9ee49f7ca2fb8d9ac195da6ca22590a5e553169ec)` should be returned within the same function call if TLS setup was successful.

If `[TlsStatus::Error](#classsf_1_1TcpSocket_1a9a86e52dd790031dbb71fdec9ee49f7ca902b0d55fddef6f8d651fe1035b7d4bd)` is returned, something went wrong with TLS setup and the connection must be reconnected and TLS setup reattempted after it is connected again.

Servers that host multiple services under different names need to know which of those services we want to connect to in order to reply with the correct certificate chain. Server name indication (SNI) is used for this purpose. The hostname provided to this function is sent to the server if it supports SNI in order for it to return the corresponding certificate chain. The hostname is then used to verify the certificate chain that was returned by the server. If the server does not support SNI or only serves a single certificate chain, the hostname will only be used for verification.

When calling this overload, the certificate chain to verify the host with has to be provided. Verification is always enabled when calling this overload.

The certificate data should be provided in PEM format.

This overload is provided to prevent a const char* argument resulting in the `bool verifyPeer` overload being called instead of the `std::string_view` overload.

#### Returns
TLS status code

**See also**: `[setupTlsServer](#setuptlsserver)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `hostname` | const [`sf::String`](sf-String.md#string) & | Hostname of the remote peer, used for verification |
| `certificateChainData` | `const char *` | Null terminated string containing certificate chain data in PEM encoding |

---

{#setuptlsclient-2}

### setupTlsClient

```cpp
TlsStatus setupTlsClient(const sf::String & hostname, const std::byte * certificateChainData, std::size_t certificateChainSize)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/TcpSocket.hpp:342

Set up transport layer security as a client.

Once the TCP connection is connected, transport layer security can be set up.

All the necessary cryptographic initialization will be performed when this function is called.

If this function is called before the TCP connection is connected, it will return `[TlsStatus::NotConnected](#classsf_1_1TcpSocket_1a9a86e52dd790031dbb71fdec9ee49f7ca4075072d219e061ca0f3124f8fbef463)` and must be called again once the TCP connection is connected.

If this function started TLS setup but could not finish it within this call e.g. because this socket was set to non-blocking, it will return `[TlsStatus::HandshakeStarted](#classsf_1_1TcpSocket_1a9a86e52dd790031dbb71fdec9ee49f7caabe8fc205c65abb83d4cf1e207c0ffad)` and this function will have to be called repeatedly until `[TlsStatus::HandshakeComplete](#classsf_1_1TcpSocket_1a9a86e52dd790031dbb71fdec9ee49f7ca2fb8d9ac195da6ca22590a5e553169ec)` is returned. If this socket is blocking, `[TlsStatus::HandshakeComplete](#classsf_1_1TcpSocket_1a9a86e52dd790031dbb71fdec9ee49f7ca2fb8d9ac195da6ca22590a5e553169ec)` should be returned within the same function call if TLS setup was successful.

If `[TlsStatus::Error](#classsf_1_1TcpSocket_1a9a86e52dd790031dbb71fdec9ee49f7ca902b0d55fddef6f8d651fe1035b7d4bd)` is returned, something went wrong with TLS setup and the connection must be reconnected and TLS setup reattempted after it is connected again.

Servers that host multiple services under different names need to know which of those services we want to connect to in order to reply with the correct certificate chain. Server name indication (SNI) is used for this purpose. The hostname provided to this function is sent to the server if it supports SNI in order for it to return the corresponding certificate chain. The hostname is then used to verify the certificate chain that was returned by the server. If the server does not support SNI or only serves a single certificate chain, the hostname will only be used for verification.

When calling this overload, the certificate chain to verify the host with has to be provided. Verification is always enabled when calling this overload.

The certificate data can be provided in PEM or DER format.

#### Returns
TLS status code

**See also**: `[setupTlsServer](#setuptlsserver)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `hostname` | const [`sf::String`](sf-String.md#string) & | Hostname of the remote peer, used for verification |
| `certificateChainData` | `const std::byte *` | Certificate chain data in PEM or DER encoding |
| `certificateChainSize` | `std::size_t` | Size of the certificate chain data |

---

{#setuptlsclient-3}

### setupTlsClient

```cpp
TlsStatus setupTlsClient(const sf::String & hostname, std::string_view certificateChainData)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/TcpSocket.hpp:396

Set up transport layer security as a client.

Once the TCP connection is connected, transport layer security can be set up.

All the necessary cryptographic initialization will be performed when this function is called.

If this function is called before the TCP connection is connected, it will return `[TlsStatus::NotConnected](#classsf_1_1TcpSocket_1a9a86e52dd790031dbb71fdec9ee49f7ca4075072d219e061ca0f3124f8fbef463)` and must be called again once the TCP connection is connected.

If this function started TLS setup but could not finish it within this call e.g. because this socket was set to non-blocking, it will return `[TlsStatus::HandshakeStarted](#classsf_1_1TcpSocket_1a9a86e52dd790031dbb71fdec9ee49f7caabe8fc205c65abb83d4cf1e207c0ffad)` and this function will have to be called repeatedly until `[TlsStatus::HandshakeComplete](#classsf_1_1TcpSocket_1a9a86e52dd790031dbb71fdec9ee49f7ca2fb8d9ac195da6ca22590a5e553169ec)` is returned. If this socket is blocking, `[TlsStatus::HandshakeComplete](#classsf_1_1TcpSocket_1a9a86e52dd790031dbb71fdec9ee49f7ca2fb8d9ac195da6ca22590a5e553169ec)` should be returned within the same function call if TLS setup was successful.

If `[TlsStatus::Error](#classsf_1_1TcpSocket_1a9a86e52dd790031dbb71fdec9ee49f7ca902b0d55fddef6f8d651fe1035b7d4bd)` is returned, something went wrong with TLS setup and the connection must be reconnected and TLS setup reattempted after it is connected again.

Servers that host multiple services under different names need to know which of those services we want to connect to in order to reply with the correct certificate chain. Server name indication (SNI) is used for this purpose. The hostname provided to this function is sent to the server if it supports SNI in order for it to return the corresponding certificate chain. The hostname is then used to verify the certificate chain that was returned by the server. If the server does not support SNI or only serves a single certificate chain, the hostname will only be used for verification.

When calling this overload, the certificate chain to verify the host with has to be provided. Verification is always enabled when calling this overload.

The certificate data should be provided in PEM format.

#### Returns
TLS status code

**See also**: `[setupTlsServer](#setuptlsserver)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `hostname` | const [`sf::String`](sf-String.md#string) & | Hostname of the remote peer, used for verification |
| `certificateChainData` | `std::string_view` | Certificate chain data in PEM encoding |

---

{#setuptlsserver}

### setupTlsServer

```cpp
TlsStatus setupTlsServer(const std::byte * certificateChainData, std::size_t certificateChainSize, const std::byte * privateKeyData, std::size_t privateKeySize, const std::byte * privateKeyPasswordData, std::size_t privateKeyPasswordSize)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/TcpSocket.hpp:445

Set up transport layer security as a server.

Once the TCP connection is connected, transport layer security can be set up.

All the necessary cryptographic initialization will be performed when this function is called.

If this function is called before the TCP connection is connected, it will return `[TlsStatus::NotConnected](#classsf_1_1TcpSocket_1a9a86e52dd790031dbb71fdec9ee49f7ca4075072d219e061ca0f3124f8fbef463)` and must be called again once the TCP connection is connected.

If this function started TLS setup but could not finish it within this call e.g. because this socket was set to non-blocking, it will return `[TlsStatus::HandshakeStarted](#classsf_1_1TcpSocket_1a9a86e52dd790031dbb71fdec9ee49f7caabe8fc205c65abb83d4cf1e207c0ffad)` and this function will have to be called repeatedly until `[TlsStatus::HandshakeComplete](#classsf_1_1TcpSocket_1a9a86e52dd790031dbb71fdec9ee49f7ca2fb8d9ac195da6ca22590a5e553169ec)` is returned. If this socket is blocking, `[TlsStatus::HandshakeComplete](#classsf_1_1TcpSocket_1a9a86e52dd790031dbb71fdec9ee49f7ca2fb8d9ac195da6ca22590a5e553169ec)` should be returned within the same function call if TLS setup was successful.

If `[TlsStatus::Error](#classsf_1_1TcpSocket_1a9a86e52dd790031dbb71fdec9ee49f7ca902b0d55fddef6f8d651fe1035b7d4bd)` is returned, something went wrong with TLS setup and the connection must be disconnected. The client must reconnect and reattempt TLS setup again.

As a server, a certificate chain as well as a private key must be provided.

The certificate and private key data can be provided in PEM or DER format.

If the private key is secured by a password, the password must be provided.

#### Returns
TLS status code

**See also**: `[setupTlsClient](#setuptlsclient)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `certificateChainData` | `const std::byte *` | Certificate chain data in PEM or DER encoding |
| `certificateChainSize` | `std::size_t` | Size of the certificate chain data |
| `privateKeyData` | `const std::byte *` | Private key data in PEM or DER encoding |
| `privateKeySize` | `std::size_t` | Size of the private key data |
| `privateKeyPasswordData` | `const std::byte *` | Private key password data |
| `privateKeyPasswordSize` | `std::size_t` | Size of the private key password data |

---

{#setuptlsserver-1}

### setupTlsServer

```cpp
TlsStatus setupTlsServer(std::string_view certificateChainData, std::string_view privateKeyData, std::string_view privateKeyPasswordData = {})
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/TcpSocket.hpp:496

Set up transport layer security as a server.

Once the TCP connection is connected, transport layer security can be set up.

All the necessary cryptographic initialization will be performed when this function is called.

If this function is called before the TCP connection is connected, it will return `[TlsStatus::NotConnected](#classsf_1_1TcpSocket_1a9a86e52dd790031dbb71fdec9ee49f7ca4075072d219e061ca0f3124f8fbef463)` and must be called again once the TCP connection is connected.

If this function started TLS setup but could not finish it within this call e.g. because this socket was set to non-blocking, it will return `[TlsStatus::HandshakeStarted](#classsf_1_1TcpSocket_1a9a86e52dd790031dbb71fdec9ee49f7caabe8fc205c65abb83d4cf1e207c0ffad)` and this function will have to be called repeatedly until `[TlsStatus::HandshakeComplete](#classsf_1_1TcpSocket_1a9a86e52dd790031dbb71fdec9ee49f7ca2fb8d9ac195da6ca22590a5e553169ec)` is returned. If this socket is blocking, `[TlsStatus::HandshakeComplete](#classsf_1_1TcpSocket_1a9a86e52dd790031dbb71fdec9ee49f7ca2fb8d9ac195da6ca22590a5e553169ec)` should be returned within the same function call if TLS setup was successful.

If `[TlsStatus::Error](#classsf_1_1TcpSocket_1a9a86e52dd790031dbb71fdec9ee49f7ca902b0d55fddef6f8d651fe1035b7d4bd)` is returned, something went wrong with TLS setup and the connection must be disconnected. The client must reconnect and reattempt TLS setup again.

As a server, a certificate chain as well as a private key must be provided.

The certificate and private key data should be provided in PEM format.

If the private key is secured by a password, the password must be provided.

#### Returns
TLS status code

**See also**: `[setupTlsClient](#setuptlsclient)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `certificateChainData` | `std::string_view` | Certificate chain data in PEM encoding |
| `privateKeyData` | `std::string_view` | Private key data in PEM encoding |
| `privateKeyPasswordData` | `std::string_view` | Private key password if required |

---

{#getcurrentciphersuitename}

### getCurrentCiphersuiteName

`const` `nodiscard`

```cpp
[[nodiscard]] std::optional< std::string > getCurrentCiphersuiteName() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/TcpSocket.hpp:508

Get the name of the TLS ciphersuite currently in use.

#### Returns
TLS ciphersuite currently in use or `std::nullopt` if TLS is not set up

**See also**: `[setupTlsClient](#setuptlsclient)`, `[setupTlsServer](#setuptlsserver)`

---

{#send}

### send

`nodiscard`

```cpp
[[nodiscard]] Status send(const void * data, std::size_t size)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/TcpSocket.hpp:526

Send raw data to the remote peer.

To be able to handle partial sends over non-blocking sockets, use the `send(const void*, std::size_t, std::size_t&)` overload instead. This function will fail if the socket is not connected.

#### Returns
[Status](Status.md#status-3) code

**See also**: `[receive](#receive)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `data` | `const void *` | Pointer to the sequence of bytes to send |
| `size` | `std::size_t` | Number of bytes to send |

---

{#send-1}

### send

`nodiscard`

```cpp
[[nodiscard]] Status send(const void * data, std::size_t size, std::size_t & sent)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/TcpSocket.hpp:542

Send raw data to the remote peer.

This function will fail if the socket is not connected.

#### Returns
[Status](Status.md#status-3) code

**See also**: `[receive](#receive)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `data` | `const void *` | Pointer to the sequence of bytes to send |
| `size` | `std::size_t` | Number of bytes to send |
| `sent` | `std::size_t &` | The number of bytes sent will be written here |

---

{#receive}

### receive

`nodiscard`

```cpp
[[nodiscard]] Status receive(void * data, std::size_t size, std::size_t & received)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/TcpSocket.hpp:560

Receive raw data from the remote peer.

In blocking mode, this function will wait until some bytes are actually received. This function will fail if the socket is not connected.

#### Returns
[Status](Status.md#status-3) code

**See also**: `[send](#send)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `data` | `void *` | Pointer to the array to fill with the received bytes |
| `size` | `std::size_t` | Maximum number of bytes that can be received |
| `received` | `std::size_t &` | This variable is filled with the actual number of bytes received |

---

{#send-2}

### send

`nodiscard`

```cpp
[[nodiscard]] Status send(Packet & packet)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/TcpSocket.hpp:578

Send a formatted packet of data to the remote peer.

In non-blocking mode, if this function returns `[sf::Socket::Status::Partial](sf-Socket.md#classsf_1_1Socket_1a51bf0fd51057b98a10fbb866246176dca44ffd38a6dea695cbe2b34efdcc6cf27)`, you *must* retry sending the same unmodified packet before sending anything else in order to guarantee the packet arrives at the remote peer uncorrupted. This function will fail if the socket is not connected.

#### Returns
[Status](Status.md#status-3) code

**See also**: `[receive](#receive)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `packet` | [`Packet`](sf-Packet.md#packet) & | [Packet](sf-Packet.md#packet) to send |

---

{#receive-1}

### receive

`nodiscard`

```cpp
[[nodiscard]] Status receive(Packet & packet)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/TcpSocket.hpp:594

Receive a formatted packet of data from the remote peer.

In blocking mode, this function will wait until the whole packet has been received. This function will fail if the socket is not connected.

#### Returns
[Status](Status.md#status-3) code

**See also**: `[send](#send)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `packet` | [`Packet`](sf-Packet.md#packet) & | [Packet](sf-Packet.md#packet) to fill with the received data |

## Public Types

| Name | Description |
|------|-------------|
| [`TlsStatus`](#tlsstatus)  | TLS status codes that may be returned by TLS setup. |

---

{#tlsstatus}

### TlsStatus

```cpp
enum TlsStatus
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/TcpSocket.hpp:64

TLS status codes that may be returned by TLS setup.

| Value | Description |
|-------|-------------|
| `NotConnected` | TCP connection not yet connected. |
| `HandshakeStarted` | TLS handshake has been started. |
| `HandshakeComplete` | TLS handshake is complete, stream is encrypted. |
| `Error` | An unexpected error happened. |
## Private Attributes

| Return | Name | Description |
|--------|------|-------------|
| `std::unique_ptr< Impl >` | [`m_impl`](#m_impl-8)  | Implementation details. |
| `PendingPacket` | [`m_pendingPacket`](#m_pendingpacket)  | Temporary data of the packet currently being received. |
| `std::vector< std::byte >` | [`m_blockToSendBuffer`](#m_blocktosendbuffer)  | Buffer used to prepare data being sent from the socket. |

---

{#m_impl-8}

### m_impl

```cpp
std::unique_ptr< Impl > m_impl
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/TcpSocket.hpp:614

Implementation details.

---

{#m_pendingpacket}

### m_pendingPacket

```cpp
PendingPacket m_pendingPacket
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/TcpSocket.hpp:615

Temporary data of the packet currently being received.

---

{#m_blocktosendbuffer}

### m_blockToSendBuffer

```cpp
std::vector< std::byte > m_blockToSendBuffer
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/TcpSocket.hpp:616

Buffer used to prepare data being sent from the socket.

