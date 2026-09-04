{#hostkey-1}

# HostKey

```cpp
#include <Sftp.hpp>
```

```cpp
struct HostKey
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Sftp.hpp:310

Host key used to identify a host.

## Public Attributes

| Return | Name | Description |
|--------|------|-------------|
| [`Type`](Type.md#type-6) | [`type`](#type-5)  | Host key type. |
| `std::vector< std::byte >` | [`data`](#data)  | Host key data. |
| `std::array< std::byte, 20 >` | [`sha1`](#sha1)  | Host key SHA1 hash. |
| `std::array< std::byte, 32 >` | [`sha256`](#sha256)  | Host key SHA256 hash. |

---

{#type-5}

### type

```cpp
Type type = Type::Unknown
```

Type: [`Type`](Type.md#type-6)

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Sftp.hpp:323

Host key type.

---

{#data}

### data

```cpp
std::vector< std::byte > data
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Sftp.hpp:324

Host key data.

---

{#sha1}

### sha1

```cpp
std::array< std::byte, 20 > sha1 {}
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Sftp.hpp:325

Host key SHA1 hash.

---

{#sha256}

### sha256

```cpp
std::array< std::byte, 32 > sha256 {}
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Sftp.hpp:326

Host key SHA256 hash.

## Public Types

| Name | Description |
|------|-------------|
| [`Type`](#type-6)  |  |

---

{#type-6}

### Type

```cpp
enum Type
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Sftp.hpp:312

| Value | Description |
|-------|-------------|
| `Unknown` | Unknown key type. |
| `Rsa` | RSA. |
| `Dsa` | DSA. |
| `Ecdsa256` | NIST P-256 ECDSA. |
| `Ecdsa384` | NIST P-384 ECDSA. |
| `Ecdsa521` | NIST P-521 ECDSA. |
| `Ed25519` | ED25519. |
