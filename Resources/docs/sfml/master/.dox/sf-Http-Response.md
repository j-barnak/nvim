{#response-2}

# Response

```cpp
#include <Http.hpp>
```

```cpp
class Response
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Http.hpp:194

HTTP response.

## Friends

| Name | Description |
|------|-------------|
| [`Http`](#http-5)  |  |

---

{#http-5}

### Http

```cpp
friend class Http
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Http.hpp:299

## Public Methods

| Return | Name | Description |
|--------|------|-------------|
| `const std::string &` | [`getField`](#getfield) `const` `nodiscard` | Get the value of a field. |
| [`Status`](Status.md#status-2) | [`getStatus`](#getstatus-4) `const` `nodiscard` | Get the response status code. |
| `unsigned int` | [`getMajorHttpVersion`](#getmajorhttpversion) `const` `nodiscard` | Get the major HTTP version number of the response. |
| `unsigned int` | [`getMinorHttpVersion`](#getminorhttpversion) `const` `nodiscard` | Get the minor HTTP version number of the response. |
| `const std::string &` | [`getBody`](#getbody) `const` `nodiscard` | Get the body of the response. |

---

{#getfield}

### getField

`const` `nodiscard`

```cpp
[[nodiscard]] const std::string & getField(const std::string & field) const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Http.hpp:249

Get the value of a field.

If the field `field` is not found in the response header, the empty string is returned. This function uses case-insensitive comparisons.

#### Returns
Value of the field, or empty string if not found

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `field` | `const std::string &` | Name of the field to get |

---

{#getstatus-4}

### getStatus

`const` `nodiscard`

```cpp
[[nodiscard]] Status getStatus() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Http.hpp:262

Get the response status code.

The status code should be the first thing to be checked after receiving a response, it defines whether it is a success, a failure or anything else (see the [Status](Status.md#status-2) enumeration).

#### Returns
[Status](Status.md#status-2) code of the response

---

{#getmajorhttpversion}

### getMajorHttpVersion

`const` `nodiscard`

```cpp
[[nodiscard]] unsigned int getMajorHttpVersion() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Http.hpp:272

Get the major HTTP version number of the response.

#### Returns
Major HTTP version number

**See also**: `[getMinorHttpVersion](#getminorhttpversion)`

---

{#getminorhttpversion}

### getMinorHttpVersion

`const` `nodiscard`

```cpp
[[nodiscard]] unsigned int getMinorHttpVersion() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Http.hpp:282

Get the minor HTTP version number of the response.

#### Returns
Minor HTTP version number

**See also**: `[getMajorHttpVersion](#getmajorhttpversion)`

---

{#getbody}

### getBody

`const` `nodiscard`

```cpp
[[nodiscard]] const std::string & getBody() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Http.hpp:296

Get the body of the response.

The body of a response may contain: 

* the requested page (for GET requests) 
* a response from the server (for POST requests) 
* nothing (for HEAD requests) 
* an error message (in case of an error)

#### Returns
The response body

## Public Types

| Name | Description |
|------|-------------|
| [`Status`](#status-2)  | Enumerate all the valid status codes for a response. |

---

{#status-2}

### Status

```cpp
enum Status
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Http.hpp:201

Enumerate all the valid status codes for a response.

| Value | Description |
|-------|-------------|
| `Ok` | Most common code returned when operation was successful. |
| `Created` | The resource has successfully been created. |
| `Accepted` | The request has been accepted, but will be processed later by the server. |
| `NoContent` | The server didn't send any data in return. |
| `ResetContent` | The server informs the client that it should clear the view (form) that caused the request to be sent. |
| `PartialContent` | The server has sent a part of the resource, as a response to a partial GET request. |
| `MultipleChoices` | The requested page can be accessed from several locations. |
| `MovedPermanently` | The requested page has permanently moved to a new location. |
| `MovedTemporarily` | The requested page has temporarily moved to a new location. |
| `NotModified` | For conditional requests, means the requested page hasn't changed and doesn't need to be refreshed. |
| `BadRequest` | The server couldn't understand the request (syntax error) |
| `Unauthorized` | The requested page needs an authentication to be accessed. |
| `Forbidden` | The requested page cannot be accessed at all, even with authentication. |
| `NotFound` | The requested page doesn't exist. |
| `RangeNotSatisfiable` | The server can't satisfy the partial GET request (with a "Range" header field) |
| `InternalServerError` | The server encountered an unexpected error. |
| `NotImplemented` | The server doesn't implement a requested feature. |
| `BadGateway` | The gateway server has received an error from the source server. |
| `ServiceNotAvailable` | The server is temporarily unavailable (overloaded, in maintenance, ...) |
| `GatewayTimeout` | The gateway server couldn't receive a response from the source server. |
| `VersionNotSupported` | The server doesn't support the requested HTTP version. |
| `InvalidResponse` | [Response](#response-2) is not a valid HTTP one. |
| `ConnectionFailed` | Connection with server failed. |
## Private Attributes

| Return | Name | Description |
|--------|------|-------------|
| `FieldTable` | [`m_fields`](#m_fields-1)  | Fields of the header. |
| [`Status`](Status.md#status-2) | [`m_status`](#m_status-1)  | [Status](Status.md#status-2) code. |
| `unsigned int` | [`m_majorVersion`](#m_majorversion-1)  | Major HTTP version. |
| `unsigned int` | [`m_minorVersion`](#m_minorversion-1)  | Minor HTTP version. |
| `std::string` | [`m_body`](#m_body-1)  | Body of the response. |

---

{#m_fields-1}

### m_fields

```cpp
FieldTable m_fields
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Http.hpp:332

Fields of the header.

---

{#m_status-1}

### m_status

```cpp
Status m_status {Status::ConnectionFailed}
```

Type: [`Status`](Status.md#status-2)

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Http.hpp:333

[Status](Status.md#status-2) code.

---

{#m_majorversion-1}

### m_majorVersion

```cpp
unsigned int m_majorVersion {}
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Http.hpp:334

Major HTTP version.

---

{#m_minorversion-1}

### m_minorVersion

```cpp
unsigned int m_minorVersion {}
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Http.hpp:335

Minor HTTP version.

---

{#m_body-1}

### m_body

```cpp
std::string m_body
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Http.hpp:336

Body of the response.

## Private Methods

| Return | Name | Description |
|--------|------|-------------|
| `void` | [`parse`](#parse)  | Construct the header from a response string. |
| `void` | [`parseFields`](#parsefields)  | Read values passed in the answer header. |

---

{#parse}

### parse

```cpp
void parse(const std::string & data)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Http.hpp:310

Construct the header from a response string.

This function is used by `[Http](sf-Http.md#http)` to build the response of a request.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `data` | `const std::string &` | Content of the response to parse |

---

{#parsefields}

### parseFields

```cpp
void parseFields(std::istream & in)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Http.hpp:322

Read values passed in the answer header.

This function is used by `[Http](sf-Http.md#http)` to extract values passed in the response.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `in` | `std::istream &` | [String](sf-String.md#string) stream containing the header values |

