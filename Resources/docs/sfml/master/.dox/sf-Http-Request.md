{#request}

# Request

```cpp
#include <Http.hpp>
```

```cpp
class Request
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Http.hpp:57

HTTP request.

## Friends

| Name | Description |
|------|-------------|
| [`Http`](#http-4)  |  |

---

{#http-4}

### Http

```cpp
friend class Http
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Http.hpp:149

## Public Methods

| Return | Name | Description |
|--------|------|-------------|
|  | [`Request`](#request-1)  | Default constructor. |
| `void` | [`setField`](#setfield)  | Set the value of a field. |
| `void` | [`setMethod`](#setmethod)  | Set the request method. |
| `void` | [`setUri`](#seturi)  | Set the requested URI. |
| `void` | [`setHttpVersion`](#sethttpversion)  | Set the HTTP version for the request. |
| `void` | [`setBody`](#setbody)  | Set the body of the request. |

---

{#request-1}

### Request

```cpp
Request(const std::string & uri = "/", Method method = Method::Get, const std::string & body = "")
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Http.hpp:84

Default constructor.

This constructor creates a GET request, with the root URI ("/") and an empty body.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `uri` | `const std::string &` | Target URI |
| `method` | [`Method`](Method.md#method) | [Method](Method.md#method) to use for the request |
| `body` | `const std::string &` | Content of the request's body |

---

{#setfield}

### setField

```cpp
void setField(const std::string & field, const std::string & value)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Http.hpp:99

Set the value of a field.

The field is created if it doesn't exist. The name of the field is case-insensitive. By default, a request doesn't contain any field (but the mandatory fields are added later by the HTTP client when sending the request).

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `field` | `const std::string &` | Name of the field to set |
| `value` | `const std::string &` | Value of the field |

---

{#setmethod}

### setMethod

```cpp
void setMethod(Method method)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Http.hpp:111

Set the request method.

See the [Method](Method.md#method) enumeration for a complete list of all the available methods. The method is `[Http::Request::Method::Get](#classsf_1_1Http_1_1Request_1a620f8bff6f43e1378f321bf53fbf5598ac55582518cba2c464f29f5bae1c68def)` by default.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `method` | [`Method`](Method.md#method) | [Method](Method.md#method) to use for the request |

---

{#seturi}

### setUri

```cpp
void setUri(const std::string & uri)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Http.hpp:123

Set the requested URI.

The URI is the resource (usually a web page or a file) that you want to get or post. The URI is "/" (the root page) by default.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `uri` | `const std::string &` | URI to request, relative to the host |

---

{#sethttpversion}

### setHttpVersion

```cpp
void setHttpVersion(unsigned int major, unsigned int minor)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Http.hpp:134

Set the HTTP version for the request.

The HTTP version is 1.0 by default.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `major` | `unsigned int` | Major HTTP version number |
| `minor` | `unsigned int` | Minor HTTP version number |

---

{#setbody}

### setBody

```cpp
void setBody(const std::string & body)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Http.hpp:146

Set the body of the request.

The body of a request is optional and only makes sense for POST requests. It is ignored for all other methods. The body is empty by default.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `body` | `const std::string &` | Content of the body |

## Public Types

| Name | Description |
|------|-------------|
| [`Method`](#method)  | Enumerate the available HTTP methods for a request. |

---

{#method}

### Method

```cpp
enum Method
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Http.hpp:64

Enumerate the available HTTP methods for a request.

| Value | Description |
|-------|-------------|
| `Get` | [Request](#request) in get mode, standard method to retrieve a page. |
| `Post` | [Request](#request) in post mode, usually to send data to a page. |
| `Head` | [Request](#request) a page's header only. |
| `Put` | [Request](#request) in put mode, useful for a REST API. |
| `Delete` | [Request](#request) in delete mode, useful for a REST API. |
## Private Attributes

| Return | Name | Description |
|--------|------|-------------|
| `FieldTable` | [`m_fields`](#m_fields)  | Fields of the header associated to their value. |
| [`Method`](Method.md#method) | [`m_method`](#m_method)  | [Method](Method.md#method) to use for the request. |
| `std::string` | [`m_uri`](#m_uri)  | Target URI of the request. |
| `unsigned int` | [`m_majorVersion`](#m_majorversion)  | Major HTTP version. |
| `unsigned int` | [`m_minorVersion`](#m_minorversion)  | Minor HTTP version. |
| `std::string` | [`m_body`](#m_body)  | Body of the request. |

---

{#m_fields}

### m_fields

```cpp
FieldTable m_fields
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Http.hpp:182

Fields of the header associated to their value.

---

{#m_method}

### m_method

```cpp
Method m_method
```

Type: [`Method`](Method.md#method)

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Http.hpp:183

[Method](Method.md#method) to use for the request.

---

{#m_uri}

### m_uri

```cpp
std::string m_uri
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Http.hpp:184

Target URI of the request.

---

{#m_majorversion}

### m_majorVersion

```cpp
unsigned int m_majorVersion {1}
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Http.hpp:185

Major HTTP version.

---

{#m_minorversion}

### m_minorVersion

```cpp
unsigned int m_minorVersion {}
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Http.hpp:186

Minor HTTP version.

---

{#m_body}

### m_body

```cpp
std::string m_body
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Http.hpp:187

Body of the request.

## Private Methods

| Return | Name | Description |
|--------|------|-------------|
| `std::string` | [`prepare`](#prepare) `const` `nodiscard` | Prepare the final request to send to the server. |
| `bool` | [`hasField`](#hasfield) `const` `nodiscard` | Check if the request defines a field. |

---

{#prepare}

### prepare

`const` `nodiscard`

```cpp
[[nodiscard]] std::string prepare() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Http.hpp:160

Prepare the final request to send to the server.

This is used internally by [Http](sf-Http.md#http) before sending the request to the web server.

#### Returns
[String](sf-String.md#string) containing the request, ready to be sent

---

{#hasfield}

### hasField

`const` `nodiscard`

```cpp
[[nodiscard]] bool hasField(const std::string & field) const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Http.hpp:172

Check if the request defines a field.

This function uses case-insensitive comparisons.

#### Returns
`true` if the field exists, `false` otherwise

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `field` | `const std::string &` | Name of the field to test |

