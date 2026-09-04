{#dns}

# Dns

Perform Domain Name System queries to lookup DNS records for various purposes.

The `[sf::Dns](#dns)` functions allow querying the Domain Name System. The Domain Name System contains many different kinds of records. The most common records are A and AAAA records used to resolve hostnames to IPv4 and IPv6 addresses respectively. Additionally, other kinds of records such as MX, SRV and TXT records can be queried.

Usage example: 
```cpp
std::vector<sf::IpAddress> addresses0 = sf::Dns::resolve("127.0.0.1");            // the local host address
std::vector<sf::IpAddress> addresses1 = sf::Dns::resolve("my_computer");          // a list of local addresses created from a network name
std::vector<sf::IpAddress> addresses2 = sf::Dns::resolve("89.54.1.169");          // a distant IPv4 address
std::vector<sf::IpAddress> addresses3 = sf::Dns::resolve("2606:4700:4700::1111"); // a distant IPv6 address
std::vector<sf::IpAddress> addresses4 = sf::Dns::resolve("www.google.com");       // a list of distant address created from a network name

for (const sf::IpAddress& address : addresses4)
{
    if (address.isV4())
    {
        // Do something with IPv4 address
    }
    else
    {
        // Do something with IPv6 address
    }
}

std::vector<sf::String>              nsRecords  = sf::Dns::queryNs("sfml-dev.org");
std::vector<sf::Dns::MxRecord>       mxRecords  = sf::Dns::queryMx("sfml-dev.org");
std::vector<std::vector<sf::String>> txtRecords = sf::Dns::queryTxt("sfml-dev.org");
std::vector<sf::Dns::SrvRecord>      srvRecords = sf::Dns::querySrv("_irc._tcp.sfml-dev.org");
```

## Classes

| Name | Description |
|------|-------------|
| [`MxRecord`](sf-Dns-MxRecord.md#mxrecord) | A DNS MX record. |
| [`SrvRecord`](sf-Dns-SrvRecord.md#srvrecord) | A DNS SRV record. |

## Functions

| Return | Name | Description |
|--------|------|-------------|
| [`SFML_NETWORK_API`](api.md#sfml_network_api) std::optional< std::vector< [`IpAddress`](sf-IpAddress.md#ipaddress) > > | [`resolve`](#resolve-1) `nodiscard` | Resolve a hostname into a list of IP addresses. |
| [`SFML_NETWORK_API`](api.md#sfml_network_api) std::vector< [`sf::String`](sf-String.md#string) > | [`queryNs`](#queryns) `nodiscard` | Query NS records for a hostname. |
| [`SFML_NETWORK_API`](api.md#sfml_network_api) std::vector< [`MxRecord`](sf-Dns-MxRecord.md#mxrecord) > | [`queryMx`](#querymx) `nodiscard` | Query MX records for a hostname. |
| [`SFML_NETWORK_API`](api.md#sfml_network_api) std::vector< [`SrvRecord`](sf-Dns-SrvRecord.md#srvrecord) > | [`querySrv`](#querysrv) `nodiscard` | Query SRV records for a hostname. |
| [`SFML_NETWORK_API`](api.md#sfml_network_api) std::vector< std::vector< [`sf::String`](sf-String.md#string) > > | [`queryTxt`](#querytxt) `nodiscard` | Query TXT records for a hostname. |
| [`SFML_NETWORK_API`](api.md#sfml_network_api) std::optional< [`IpAddress`](sf-IpAddress.md#ipaddress) > | [`getPublicAddress`](#getpublicaddress-1) `nodiscard` | Get the computer's public address via DNS. |

---

{#resolve-1}

### resolve

`nodiscard`

```cpp
[[nodiscard]] SFML_NETWORK_API std::optional< std::vector< IpAddress > > resolve(const sf::String & hostname, const std::vector< sf::IpAddress > & servers = {}, std::optional< sf::Time > timeout = sf::seconds(1))
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Dns.hpp:60

Resolve a hostname into a list of IP addresses.

#### Returns
List of IP addresses the given hostname resolves to, `std::nullopt` is returned if name resolution fails, an empty list is returned if the hostname could not be resolved to any address

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `hostname` | const [`sf::String`](sf-String.md#string) & | Hostname to resolve |
| `servers` | const std::vector< [`sf::IpAddress`](sf-IpAddress.md#ipaddress) > & | The list of servers to query, if empty use the default servers |
| `timeout` | std::optional< [`sf::Time`](sf-Time.md#time) > | Query timeout if using a provided list of servers, `std::nullopt` to wait forever |

---

{#queryns}

### queryNs

`nodiscard`

```cpp
[[nodiscard]] SFML_NETWORK_API std::vector< sf::String > queryNs(const sf::String & hostname, const std::vector< sf::IpAddress > & servers = {}, std::optional< sf::Time > timeout = sf::seconds(1))
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Dns.hpp:75

Query NS records for a hostname.

#### Returns
List of NS record strings, an empty list is returned if there are no NS records for the hostname

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `hostname` | const [`sf::String`](sf-String.md#string) & | Hostname to query NS records for |
| `servers` | const std::vector< [`sf::IpAddress`](sf-IpAddress.md#ipaddress) > & | The list of servers to query, if empty use the default servers |
| `timeout` | std::optional< [`sf::Time`](sf-Time.md#time) > | Query timeout if using a provided list of servers, `std::nullopt` to wait forever |

---

{#querymx}

### queryMx

`nodiscard`

```cpp
[[nodiscard]] SFML_NETWORK_API std::vector< MxRecord > queryMx(const sf::String & hostname, const std::vector< sf::IpAddress > & servers = {}, std::optional< sf::Time > timeout = sf::seconds(1))
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Dns.hpp:99

Query MX records for a hostname.

#### Returns
List of MX records, an empty list is returned if there are no MX records for the hostname

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `hostname` | const [`sf::String`](sf-String.md#string) & | Hostname to query MX records for |
| `servers` | const std::vector< [`sf::IpAddress`](sf-IpAddress.md#ipaddress) > & | The list of servers to query, if empty use the default servers |
| `timeout` | std::optional< [`sf::Time`](sf-Time.md#time) > | Query timeout if using a provided list of servers, `std::nullopt` to wait forever |

---

{#querysrv}

### querySrv

`nodiscard`

```cpp
[[nodiscard]] SFML_NETWORK_API std::vector< SrvRecord > querySrv(const sf::String & hostname, const std::vector< sf::IpAddress > & servers = {}, std::optional< sf::Time > timeout = sf::seconds(1))
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Dns.hpp:125

Query SRV records for a hostname.

#### Returns
List of SRV records, an empty list is returned if there are no SRV records for the hostname

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `hostname` | const [`sf::String`](sf-String.md#string) & | Hostname to query SRV records for |
| `servers` | const std::vector< [`sf::IpAddress`](sf-IpAddress.md#ipaddress) > & | The list of servers to query, if empty use the default servers |
| `timeout` | std::optional< [`sf::Time`](sf-Time.md#time) > | Query timeout if using a provided list of servers, `std::nullopt` to wait forever |

---

{#querytxt}

### queryTxt

`nodiscard`

```cpp
[[nodiscard]] SFML_NETWORK_API std::vector< std::vector< sf::String > > queryTxt(const sf::String & hostname, const std::vector< sf::IpAddress > & servers = {}, std::optional< sf::Time > timeout = sf::seconds(1))
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Dns.hpp:139

Query TXT records for a hostname.

#### Returns
List of TXT record string lists, an empty list is returned if there are no TXT records for the hostname

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `hostname` | const [`sf::String`](sf-String.md#string) & | Hostname to query TXT records for |
| `servers` | const std::vector< [`sf::IpAddress`](sf-IpAddress.md#ipaddress) > & | The list of servers to query, if empty use the default servers |
| `timeout` | std::optional< [`sf::Time`](sf-Time.md#time) > | Query timeout if using a provided list of servers, `std::nullopt` to wait forever |

---

{#getpublicaddress-1}

### getPublicAddress

`nodiscard`

```cpp
[[nodiscard]] SFML_NETWORK_API std::optional< IpAddress > getPublicAddress(std::optional< Time > timeout = std::nullopt, IpAddress::Type type = IpAddress::Type::IpV4)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Dns.hpp:172

Get the computer's public address via DNS.

The public address is the address of the computer from the point of view of the internet, i.e. something like 89.54.1.169 or 2600:1901:0:13e0::1 as opposed to a private or local address like 192.168.1.56 or fe80::1234:5678:9abc. It is necessary for communication with hosts outside of the local network.

The only way to reliably get the public address is to send data to a host on the internet and see what the origin address is; as a consequence, this function depends on both your network connection and the server, and may be very slow. You should try to use it as little as possible. Because this function depends on the network connection and on a distant server, you can specify a time limit if you don't want your program to get stuck waiting in case there is a problem; this limit is deactivated by default.

This function makes use of DNS queries get the public address.

#### Returns
Public IP address of the computer on success, `std::nullopt` otherwise

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `timeout` | std::optional< [`Time`](sf-Time.md#time) > | Maximum time to wait, `std::nullopt` to wait forever |
| `type` | [`IpAddress::Type`](Type.md#type-3) | The type of public address to get |

