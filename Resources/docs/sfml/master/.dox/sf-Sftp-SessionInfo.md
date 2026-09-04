{#sessioninfo}

# SessionInfo

```cpp
#include <Sftp.hpp>
```

```cpp
struct SessionInfo
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Sftp.hpp:304

Structure containing information about an active SFTP session.

## Public Attributes

| Return | Name | Description |
|--------|------|-------------|
| [`HostKey`](sf-Sftp-SessionInfo-HostKey.md#hostkey-1) | [`hostKey`](#hostkey)  | Host key. |
| `std::string` | [`keyExchangeAlgorithm`](#keyexchangealgorithm)  | Key exchange algorithm used in the session (RFC 4253) |
| `std::string` | [`hostKeyAlgorithm`](#hostkeyalgorithm)  | Host key algorithm used in the session (RFC 4253) |
| `std::string` | [`clientToServerEncryptionAlgorithm`](#clienttoserverencryptionalgorithm)  | Client to server encryption algorithm used in the session (RFC 4253) |
| `std::string` | [`serverToClientEncryptionAlgorithm`](#servertoclientencryptionalgorithm)  | Server to client encryption algorithm used in the session (RFC 4253) |
| `std::string` | [`clientToServerMacAlgorithm`](#clienttoservermacalgorithm)  | Client to server message authentication code algorithm used in the session (RFC 4253) |
| `std::string` | [`serverToClientMacAlgorithm`](#servertoclientmacalgorithm)  | Server to client message authentication code algorithm used in the session (RFC 4253) |
| `std::string` | [`clientToServerCompressionAlgorithm`](#clienttoservercompressionalgorithm)  | Client to server compression algorithm used in the session (RFC 4253) |
| `std::string` | [`serverToClientCompressionAlgorithm`](#servertoclientcompressionalgorithm)  | Server to client compression algorithm used in the session (RFC 4253) |

---

{#hostkey}

### hostKey

```cpp
HostKey hostKey
```

Type: [`HostKey`](sf-Sftp-SessionInfo-HostKey.md#hostkey-1)

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Sftp.hpp:329

Host key.

---

{#keyexchangealgorithm}

### keyExchangeAlgorithm

```cpp
std::string keyExchangeAlgorithm
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Sftp.hpp:330

Key exchange algorithm used in the session (RFC 4253)

---

{#hostkeyalgorithm}

### hostKeyAlgorithm

```cpp
std::string hostKeyAlgorithm
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Sftp.hpp:331

Host key algorithm used in the session (RFC 4253)

---

{#clienttoserverencryptionalgorithm}

### clientToServerEncryptionAlgorithm

```cpp
std::string clientToServerEncryptionAlgorithm
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Sftp.hpp:332

Client to server encryption algorithm used in the session (RFC 4253)

---

{#servertoclientencryptionalgorithm}

### serverToClientEncryptionAlgorithm

```cpp
std::string serverToClientEncryptionAlgorithm
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Sftp.hpp:333

Server to client encryption algorithm used in the session (RFC 4253)

---

{#clienttoservermacalgorithm}

### clientToServerMacAlgorithm

```cpp
std::string clientToServerMacAlgorithm
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Sftp.hpp:334

Client to server message authentication code algorithm used in the session (RFC 4253)

---

{#servertoclientmacalgorithm}

### serverToClientMacAlgorithm

```cpp
std::string serverToClientMacAlgorithm
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Sftp.hpp:335

Server to client message authentication code algorithm used in the session (RFC 4253)

---

{#clienttoservercompressionalgorithm}

### clientToServerCompressionAlgorithm

```cpp
std::string clientToServerCompressionAlgorithm
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Sftp.hpp:336

Client to server compression algorithm used in the session (RFC 4253)

---

{#servertoclientcompressionalgorithm}

### serverToClientCompressionAlgorithm

```cpp
std::string serverToClientCompressionAlgorithm
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Sftp.hpp:337

Server to client compression algorithm used in the session (RFC 4253)

