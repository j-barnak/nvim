{#listingresponse}

# ListingResponse

```cpp
#include <Ftp.hpp>
```

```cpp
class ListingResponse
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Ftp.hpp:220

> **Inherits:** [`Response`](sf-Ftp-Response.md#response)

Specialization of FTP response returning a file name listing.

## List of all members

| Name | Kind | Owner |
|------|------|-------|
| [`ListingResponse`](#listingresponse-1) | `function` | Declared here |
| [`getListing`](#getlisting) | `function` | Declared here |
| [`m_listing`](#m_listing) | `variable` | Declared here |
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
|  | [`ListingResponse`](#listingresponse-1)  | Default constructor. |
| `const std::vector< std::string > &` | [`getListing`](#getlisting) `const` `nodiscard` | Return the array of directory/file names. |

---

{#listingresponse-1}

### ListingResponse

```cpp
ListingResponse(const Response & response, const std::string & data)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Ftp.hpp:230

Default constructor.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `response` | const [`Response`](sf-Ftp-Response.md#response) & | Source response |
| `data` | `const std::string &` | Data containing the raw listing |

---

{#getlisting}

### getListing

`const` `nodiscard`

```cpp
[[nodiscard]] const std::vector< std::string > & getListing() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Ftp.hpp:238

Return the array of directory/file names.

#### Returns
Array containing the requested listing

## Private Attributes

| Return | Name | Description |
|--------|------|-------------|
| `std::vector< std::string >` | [`m_listing`](#m_listing)  | Directory/file names extracted from the data. |

---

{#m_listing}

### m_listing

```cpp
std::vector< std::string > m_listing
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Ftp.hpp:244

Directory/file names extracted from the data.

