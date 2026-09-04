{#http}

# Http

```cpp
#include <Http.hpp>
```

```cpp
class Http
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Http.hpp:50

A HTTP client.

`[sf::Http](#http)` is a very simple HTTP client that allows you to communicate with a web server. You can retrieve web pages, send data to an interactive resource, download a remote file, etc. The HTTPS protocol is supported using TLS connections only.

The HTTP client is split into 3 classes: 

* `[sf::Http::Request](sf-Http-Request.md#request)`
* `[sf::Http::Response](sf-Http-Response.md#response-2)`
* `[sf::Http](#http)`
`[sf::Http::Request](sf-Http-Request.md#request)` builds the request that will be sent to the server. A request is made of: 

* a method (what you want to do) 
* a target URI (usually the name of the web page or file) 
* one or more header fields (options that you can pass to the server) 
* an optional body (for POST requests)
`[sf::Http::Response](sf-Http-Response.md#response-2)` parse the response from the web server and provides getters to read them. The response contains: 

* a status code 
* header fields (that may be answers to the ones that you requested) 
* a body, which contains the contents of the requested resource
`[sf::Http](#http)` provides a simple function, SendRequest, to send a `[sf::Http::Request](sf-Http-Request.md#request)` and return the corresponding `[sf::Http::Response](sf-Http-Response.md#response-2)` from the server.

Usage example: 
```cpp
// Create a new HTTP client
sf::Http http;

// We'll work on https://www.sfml-dev.org
http.setHost("https://www.sfml-dev.org");

// Prepare a request to get the '/learn/' page
sf::Http::Request request("/learn/");

// Send the request
sf::Http::Response response = http.sendRequest(request);

// Check the status code and display the result
sf::Http::Response::Status status = response.getStatus();
if (status == sf::Http::Response::Status::Ok)
{
    std::cout << response.getBody() << std::endl;
}
else
{
    std::cout << "Error " << status << std::endl;
}
```

## Public Methods

| Return | Name | Description |
|--------|------|-------------|
|  | [`Http`](#http-1)  | Default constructor. |
|  | [`Http`](#http-2)  | Construct the HTTP client with the target host. |
|  | [`Http`](#http-3)  | Deleted copy constructor. |
| [`Http`](#http) & | [`operator=`](#operator-27)  | Deleted copy assignment. |
| `bool` | [`setHost`](#sethost)  | Set the target host. |
| [`Response`](sf-Http-Response.md#response-2) | [`sendRequest`](#sendrequest) `const` `nodiscard` | Send a HTTP request and return the server's response. |

---

{#http-1}

### Http

```cpp
Http() = default
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Http.hpp:343

Default constructor.

---

{#http-2}

### Http

```cpp
Http(const std::string & host, unsigned short port = 0, std::optional< IpAddress::Type > addressType = std::nullopt)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Http.hpp:360

Construct the HTTP client with the target host.

This is equivalent to calling `setHost(host, port)`. The port has a default value of 0, which means that the HTTP client will use the right port according to the protocol used (80 for HTTP). You should leave it like this unless you really need a port other than the standard one, or use an unknown protocol.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `host` | `const std::string &` | Web server to connect to |
| `port` | `unsigned short` | Port to use for the connection |
| `addressType` | std::optional< [`IpAddress::Type`](Type.md#type-3) > | Address type to use for the connection, `std::nullopt` to specify no preference |

---

{#http-3}

### Http

```cpp
Http(const Http &) = delete
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Http.hpp:366

Deleted copy constructor.

---

{#operator-27}

### operator=

```cpp
Http & operator=(const Http &) = delete
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Http.hpp:372

Deleted copy assignment.

---

{#sethost}

### setHost

```cpp
bool setHost(const std::string & host, unsigned short port = 0, std::optional< IpAddress::Type > addressType = std::nullopt)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Http.hpp:393

Set the target host.

This function just stores the host address and port, it doesn't actually connect to it until you send a request. It does however try to resolve the address. The port has a default value of 0, which means that the HTTP client will use the right port according to the protocol used (80 for HTTP). You should leave it like this unless you really need a port other than the standard one, or use an unknown protocol.

#### Returns
`true` if the host has been resolved and is valid, `false` otherwise

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `host` | `const std::string &` | Web server to connect to |
| `port` | `unsigned short` | Port to use for the connection |
| `addressType` | std::optional< [`IpAddress::Type`](Type.md#type-3) > | Address type to use for the connection, `std::nullopt` to specify no preference |

---

{#sendrequest}

### sendRequest

`const` `nodiscard`

```cpp
[[nodiscard]] Response sendRequest(const Request & request, Time timeout = Time::Zero, bool verifyServer = true) const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Http.hpp:414

Send a HTTP request and return the server's response.

You must have a valid host before sending a request (see `setHost`). Any missing mandatory header field in the request will be added with an appropriate value. Warning: this function waits for the server's response and may not return instantly; use a thread if you don't want to block your application, or use a timeout to limit the time to wait. A value of `[Time::Zero](sf-Time.md#zero-1)` means that the client will use the system default timeout (which is usually pretty long).

#### Returns
Server's response

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `request` | const [`Request`](sf-Http-Request.md#request) & | [Request](sf-Http-Request.md#request) to send |
| `timeout` | [`Time`](sf-Time.md#time) | Maximum time to wait |
| `verifyServer` | `bool` | Verify the server if using HTTPS |

## Private Attributes

| Return | Name | Description |
|--------|------|-------------|
| std::vector< [`IpAddress`](sf-IpAddress.md#ipaddress) > | [`m_hosts`](#m_hosts)  | Web host addresses. |
| std::optional< [`IpAddress::Type`](Type.md#type-3) > | [`m_addressType`](#m_addresstype)  | Address type. |
| `std::string` | [`m_hostName`](#m_hostname)  | Web host name. |
| `unsigned short` | [`m_port`](#m_port)  | Port used for connection with host. |
| `bool` | [`m_https`](#m_https)  | Use HTTPS. |

---

{#m_hosts}

### m_hosts

```cpp
std::vector< IpAddress > m_hosts
```

Type: std::vector< [`IpAddress`](sf-IpAddress.md#ipaddress) >

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Http.hpp:420

Web host addresses.

---

{#m_addresstype}

### m_addressType

```cpp
std::optional< IpAddress::Type > m_addressType
```

Type: std::optional< [`IpAddress::Type`](Type.md#type-3) >

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Http.hpp:421

Address type.

---

{#m_hostname}

### m_hostName

```cpp
std::string m_hostName
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Http.hpp:422

Web host name.

---

{#m_port}

### m_port

```cpp
unsigned short m_port {}
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Http.hpp:423

Port used for connection with host.

---

{#m_https}

### m_https

```cpp
bool m_https {}
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Http.hpp:424

Use HTTPS.

