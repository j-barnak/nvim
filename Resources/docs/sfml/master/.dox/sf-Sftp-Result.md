{#result}

# Result

```cpp
#include <Sftp.hpp>
```

```cpp
class Result
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Sftp.hpp:61

> **Subclassed by:** [`AttributesResult`](sf-Sftp-AttributesResult.md#attributesresult), [`ListingResult`](sf-Sftp-ListingResult.md#listingresult), [`PathResult`](sf-Sftp-PathResult.md#pathresult)

SFTP result.

## Public Methods

| Return | Name | Description |
|--------|------|-------------|
|  | [`Result`](#result-1) `explicit` | Constructor. |
| `bool` | [`isOk`](#isok-1) `const` `nodiscard` | Check if the result is a success. |
| [`Value`](Value.md#value-1) | [`getValue`](#getvalue-1) `const` `nodiscard` | Get the result value. |
| `const std::string &` | [`getMessage`](#getmessage-1) `const` `nodiscard` | Get the result message. |

---

{#result-1}

### Result

`explicit`

```cpp
explicit Result(Value value, std::string message = "")
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Sftp.hpp:154

Constructor.

This constructor is used by the SFTP client to build the result.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `value` | [`Value`](Value.md#value-1) | [Result](#result) value |
| `message` | `std::string` | [Result](#result) message |

---

{#isok-1}

### isOk

`const` `nodiscard`

```cpp
[[nodiscard]] bool isOk() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Sftp.hpp:165

Check if the result is a success.

This function is defined for convenience, it is equivalent to testing if the result value is `[Value::Success](#classsf_1_1Sftp_1_1Result_1acd6085c64ba1862db71e62a2606cc810a505a83f220c02df2f85c3810cd9ceb38)`.

#### Returns
`true` if the result is `[Value::Success](#classsf_1_1Sftp_1_1Result_1acd6085c64ba1862db71e62a2606cc810a505a83f220c02df2f85c3810cd9ceb38)`, `false` if it is not `[Value::Success](#classsf_1_1Sftp_1_1Result_1acd6085c64ba1862db71e62a2606cc810a505a83f220c02df2f85c3810cd9ceb38)`

---

{#getvalue-1}

### getValue

`const` `nodiscard`

```cpp
[[nodiscard]] Value getValue() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Sftp.hpp:173

Get the result value.

#### Returns
The result value

---

{#getmessage-1}

### getMessage

`const` `nodiscard`

```cpp
[[nodiscard]] const std::string & getMessage() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Sftp.hpp:181

Get the result message.

#### Returns
The result message

## Public Types

| Name | Description |
|------|-------------|
| [`Value`](#value-1)  | [Result](#result) values. |

---

{#value-1}

### Value

```cpp
enum Value
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Sftp.hpp:68

[Result](#result) values.

| Value | Description |
|-------|-------------|
| `Success` | Operation completed successfully. |
| `Disconnected` | The TCP socket has been disconnected. |
| `Timeout` | Operation timed out. |
| `Refused` | Connection refused. |
| `Error` | Generic error. |
| `BannerReceive` | Error during banner receive. |
| `BannerSend` | Error during banner send. |
| `InvalidMac` | Invalid message authentication code. |
| `AllocationFailure` | Allocation failure. |
| `SocketSend` | Error sending on socket. |
| `KeyExchangeFailure` | Key exchange failed. |
| `HostKeyInitialization` | Host key initialization failed. |
| `HostKeySign` | Host key signing failed. |
| `DecryptError` | Decryption failed. |
| `ProtocolError` | SSH protocol error. |
| `PasswordExpired` | Password expired. |
| `FileError` | File error. |
| `MethodNone` | No method found. |
| `AuthenticationFailed` | Authentication failed. |
| `PublicKeyUnverified` | Public key unverified. |
| `ChannelOutOfOrder` | Channel out of order. |
| `ChannelFailure` | Channel failure. |
| `ChannelRequestDenied` | Channel request denied. |
| `ChannelUnknown` | Channel unknown. |
| `ChannelWindowExceeded` | Channel window exceeded. |
| `ChannelPacketExceeded` | Channel packet exceeded. |
| `ChannelClosed` | Channel closed. |
| `ChannelEofSent` | Channel EOF sent. |
| `ScpProtocol` | SCP protocol error. |
| `ZlibError` | Zlib error. |
| `RequestDenied` | Request denied. |
| `MethodNotSupported` | Method not supported. |
| `InvalidData` | Invalid data. |
| `PublicKeyProtocol` | Public key protocol error. |
| `BufferTooSmall` | Buffer too small. |
| `BadUse` | Bad usage. |
| `CompressError` | Compression error. |
| `OutOfBoundary` | Out of boundary. |
| `AgentProtocol` | Agent protocol error. |
| `SocketRecv` | [Socket](sf-Socket.md#socket) receive error. |
| `EncryptError` | Encryption failed. |
| `BadSocket` | Bad socket. |
| `KnownHosts` | Known hosts error. |
| `ChannelWindowFull` | Channel window full. |
| `KeyFileAuthenticationFailed` | Key file authentication failed. |
| `EndOfFile` | End of file. |
| `NoSuchFile` | No such file. |
| `PermissionDenied` | Permission denied. |
| `Failure` | Failure. |
| `BadMessage` | Bad message. |
| `NoConnection` | No connection. |
| `ConnectionLost` | Connection lost. |
| `OperationUnsupported` | Operation unsupported. |
| `InvalidHandle` | Invalid handle. |
| `NoSuchPath` | No such path. |
| `FileAlreadyExists` | File already exists. |
| `WriteProtect` | Write protect. |
| `NoMedia` | No media. |
| `NoSpaceOnFileSystem` | No space on filesystem. |
| `QuotaExceeded` | Quota exceeded. |
| `UnknownPrincipal` | Unknown principal. |
| `LockConflict` | Lock conflict. |
| `DirectoryNotEmpty` | Directory not empty. |
| `NotADirectory` | Not a directory. |
| `InvalidFilename` | Invalid filename. |
| `LinkLoop` | Link loop. |
| `SftpError` | Generic SFTP error. |
## Private Attributes

| Return | Name | Description |
|--------|------|-------------|
| [`Value`](Value.md#value-1) | [`m_value`](#m_value)  | The contained value. |
| `std::string` | [`m_message`](#m_message-1)  | The contained message. |

---

{#m_value}

### m_value

```cpp
Value m_value
```

Type: [`Value`](Value.md#value-1)

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Sftp.hpp:187

The contained value.

---

{#m_message-1}

### m_message

```cpp
std::string m_message
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Sftp.hpp:188

The contained message.

