{#response}

# Response

```cpp
#include <Ftp.hpp>
```

```cpp
class Response
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Ftp.hpp:69

> **Subclassed by:** [`DirectoryResponse`](sf-Ftp-DirectoryResponse.md#directoryresponse), [`ListingResponse`](sf-Ftp-ListingResponse.md#listingresponse)

FTP response.

## Public Methods

| Return | Name | Description |
|--------|------|-------------|
|  | [`Response`](#response-1) `explicit` | Default constructor. |
| `bool` | [`isOk`](#isok) `const` `nodiscard` | Check if the status code means a success. |
| [`Status`](Status.md#status-1) | [`getStatus`](#getstatus-3) `const` `nodiscard` | Get the status code of the response. |
| `const std::string &` | [`getMessage`](#getmessage) `const` `nodiscard` | Get the full message contained in the response. |

---

{#response-1}

### Response

`explicit`

```cpp
explicit Response(Status code = Status::InvalidResponse, std::string message = "")
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Ftp.hpp:148

Default constructor.

This constructor is used by the FTP client to build the response.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `code` | [`Status`](Status.md#status-1) | [Response](#response) status code |
| `message` | `std::string` | [Response](#response) message |

---

{#isok}

### isOk

`const` `nodiscard`

```cpp
[[nodiscard]] bool isOk() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Ftp.hpp:159

Check if the status code means a success.

This function is defined for convenience, it is equivalent to testing if the status code is < 400.

#### Returns
`true` if the status is a success, `false` if it is a failure

---

{#getstatus-3}

### getStatus

`const` `nodiscard`

```cpp
[[nodiscard]] Status getStatus() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Ftp.hpp:167

Get the status code of the response.

#### Returns
[Status](Status.md#status-1) code

---

{#getmessage}

### getMessage

`const` `nodiscard`

```cpp
[[nodiscard]] const std::string & getMessage() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Ftp.hpp:175

Get the full message contained in the response.

#### Returns
The response message

## Public Types

| Name | Description |
|------|-------------|
| [`Status`](#status-1)  | [Status](Status.md#status-1) codes possibly returned by a FTP response. |

---

{#status-1}

### Status

```cpp
enum Status
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Ftp.hpp:76

[Status](Status.md#status-1) codes possibly returned by a FTP response.

| Value | Description |
|-------|-------------|
| `RestartMarkerReply` | Restart marker reply. |
| `ServiceReadySoon` | Service ready in N minutes. |
| `DataConnectionAlreadyOpened` | Data connection already opened, transfer starting. |
| `OpeningDataConnection` | File status ok, about to open data connection. |
| `Ok` | Command ok. |
| `PointlessCommand` | Command not implemented. |
| `SystemStatus` | System status, or system help reply. |
| `DirectoryStatus` | Directory status. |
| `FileStatus` | File status. |
| `HelpMessage` | Help message. |
| `SystemType` | NAME system type, where NAME is an official system name from the list in the Assigned Numbers document. |
| `ServiceReady` | Service ready for new user. |
| `ClosingConnection` | Service closing control connection. |
| `DataConnectionOpened` | Data connection open, no transfer in progress. |
| `ClosingDataConnection` | Closing data connection, requested file action successful. |
| `EnteringPassiveMode` | Entering passive mode. |
| `LoggedIn` | User logged in, proceed. Logged out if appropriate. |
| `FileActionOk` | Requested file action ok. |
| `DirectoryOk` | PATHNAME created. |
| `NeedPassword` | User name ok, need password. |
| `NeedAccountToLogIn` | Need account for login. |
| `NeedInformation` | Requested file action pending further information. |
| `ServiceUnavailable` | Service not available, closing control connection. |
| `DataConnectionUnavailable` | Can't open data connection. |
| `TransferAborted` | Connection closed, transfer aborted. |
| `FileActionAborted` | Requested file action not taken. |
| `LocalError` | Requested action aborted, local error in processing. |
| `InsufficientStorageSpace` | Requested action not taken; insufficient storage space in system, file unavailable. |
| `CommandUnknown` | Syntax error, command unrecognized. |
| `ParametersUnknown` | Syntax error in parameters or arguments. |
| `CommandNotImplemented` | Command not implemented. |
| `BadCommandSequence` | Bad sequence of commands. |
| `ParameterNotImplemented` | Command not implemented for that parameter. |
| `NotLoggedIn` | Not logged in. |
| `NeedAccountToStore` | Need account for storing files. |
| `FileUnavailable` | Requested action not taken, file unavailable. |
| `PageTypeUnknown` | Requested action aborted, page type unknown. |
| `NotEnoughMemory` | Requested file action aborted, exceeded storage allocation. |
| `FilenameNotAllowed` | Requested action not taken, file name not allowed. |
| `InvalidResponse` | Not part of the FTP standard, generated by SFML when a received response cannot be parsed. |
| `ConnectionFailed` | Not part of the FTP standard, generated by SFML when the low-level socket connection with the server fails. |
| `ConnectionClosed` | Not part of the FTP standard, generated by SFML when the low-level socket connection is unexpectedly closed. |
| `InvalidFile` | Not part of the FTP standard, generated by SFML when a local file cannot be read or written. |
## Private Attributes

| Return | Name | Description |
|--------|------|-------------|
| [`Status`](Status.md#status-1) | [`m_status`](#m_status)  | [Status](Status.md#status-1) code returned from the server. |
| `std::string` | [`m_message`](#m_message)  | Last message received from the server. |

---

{#m_status}

### m_status

```cpp
Status m_status
```

Type: [`Status`](Status.md#status-1)

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Ftp.hpp:181

[Status](Status.md#status-1) code returned from the server.

---

{#m_message}

### m_message

```cpp
std::string m_message
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Ftp.hpp:182

Last message received from the server.

