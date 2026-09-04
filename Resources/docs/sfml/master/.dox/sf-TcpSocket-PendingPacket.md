{#pendingpacket}

# PendingPacket

```cpp
struct PendingPacket
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/TcpSocket.hpp:603

Structure holding the data of a pending packet.

## Public Attributes

| Return | Name | Description |
|--------|------|-------------|
| `std::uint32_t` | [`size`](#size-3)  | Data of packet size. |
| `std::size_t` | [`sizeReceived`](#sizereceived)  | Number of size bytes received so far. |
| `std::vector< std::byte >` | [`data`](#data-1)  | Data of the packet. |

---

{#size-3}

### size

```cpp
std::uint32_t size {}
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/TcpSocket.hpp:605

Data of packet size.

---

{#sizereceived}

### sizeReceived

```cpp
std::size_t sizeReceived {}
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/TcpSocket.hpp:606

Number of size bytes received so far.

---

{#data-1}

### data

```cpp
std::vector< std::byte > data
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/TcpSocket.hpp:607

Data of the packet.

