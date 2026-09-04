{#directoryresponse}

# DirectoryResponse

```cpp
#include <Ftp.hpp>
```

```cpp
class DirectoryResponse
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Ftp.hpp:189

> **Inherits:** [`Response`](sf-Ftp-Response.md#response)

Specialization of FTP response returning a directory.

## List of all members

| Name | Kind | Owner |
|------|------|-------|
| [`DirectoryResponse`](#directoryresponse-1) | `function` | Declared here |
| [`getDirectory`](#getdirectory) | `function` | Declared here |
| [`m_directory`](#m_directory) | `variable` | Declared here |
| [`Response`](sf-Ftp-Response.md#response-1) | `function` | Inherited from [`Response`](sf-Ftp-Response.md#response) |
| [`isOk`](sf-Ftp-Response.md#isok) | `function` | Inherited from [`Response`](sf-Ftp-Response.md#response) |
| [`getStatus`](sf-Ftp-Response.md#getstatus-3) | `function` | Inherited from [`Response`](sf-Ftp-Response.md#response) |
| [`getMessage`](sf-Ftp-Response.md#getmessage) | `function` | Inherited from [`Response`](sf-Ftp-Response.md#response) |
| [`Status`](Status.md#status-1) | `enum` | Inherited from [`Response`](sf-Ftp-Response.md#response) |
| [`m_status`](sf-Ftp-Response.md#m_status) | `variable` | Inherited from [`Response`](sf-Ftp-Response.md#response) |
| [`m_message`](sf-Ftp-Response.md#m_message) | `variable` | Inherited from [`Response`](sf-Ftp-Response.md#response) |

## Inherited from [`Response`](sf-Ftp-Response.md#response)

| Kind | Name | Description |
|------|------|-------------|
| `function` | [`Response`](sf-Ftp-Response.md#response-1) `explicit` | Default constructor. |
| `function` | [`isOk`](sf-Ftp-Response.md#isok) `const` `nodiscard` | Check if the status code means a success. |
| `function` | [`getStatus`](sf-Ftp-Response.md#getstatus-3) `const` `nodiscard` | Get the status code of the response. |
| `function` | [`getMessage`](sf-Ftp-Response.md#getmessage) `const` `nodiscard` | Get the full message contained in the response. |
| `enum` | [`Status`](Status.md#status-1)  | [Status](Status.md#status-1) codes possibly returned by a FTP response. |
| `variable` | [`m_status`](sf-Ftp-Response.md#m_status)  | [Status](Status.md#status-1) code returned from the server. |
| `variable` | [`m_message`](sf-Ftp-Response.md#m_message)  | Last message received from the server. |

## Public Methods

| Return | Name | Description |
|--------|------|-------------|
|  | [`DirectoryResponse`](#directoryresponse-1)  | Default constructor. |
| `const std::filesystem::path &` | [`getDirectory`](#getdirectory) `const` `nodiscard` | Get the directory returned in the response. |

---

{#directoryresponse-1}

### DirectoryResponse

```cpp
DirectoryResponse(const Response & response)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Ftp.hpp:198

Default constructor.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `response` | const [`Response`](sf-Ftp-Response.md#response) & | Source response |

---

{#getdirectory}

### getDirectory

`const` `nodiscard`

```cpp
[[nodiscard]] const std::filesystem::path & getDirectory() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Ftp.hpp:206

Get the directory returned in the response.

#### Returns
Directory name

## Private Attributes

| Return | Name | Description |
|--------|------|-------------|
| `std::filesystem::path` | [`m_directory`](#m_directory)  | Directory extracted from the response message. |

---

{#m_directory}

### m_directory

```cpp
std::filesystem::path m_directory
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Ftp.hpp:212

Directory extracted from the response message.

