{#packet}

# Packet

```cpp
#include <Packet.hpp>
```

```cpp
class Packet
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Packet.hpp:48

Utility class to build blocks of data to transfer over the network.

Packets provide a safe and easy way to serialize data, in order to send it over the network using sockets (`[sf::TcpSocket](sf-TcpSocket.md#tcpsocket-1)`, `[sf::UdpSocket](sf-UdpSocket.md#udpsocket-1)`).

Packets solve 2 fundamental problems that arise when transferring data over the network: 

* data is interpreted correctly according to the endianness 
* the bounds of the packet are preserved (one send == one receive)

The `[sf::Packet](#packet)` class provides both input and output modes. It is designed to follow the behavior of standard C++ streams, using operators >> and << to extract and insert data.

It is recommended to use only fixed-size types (like `std::int32_t`, etc.), to avoid possible differences between the sender and the receiver. Indeed, the native C++ types may have different sizes on two platforms and your data may be corrupted if that happens.

Usage example: 
```cpp
std::uint32_t x = 24;
std::string s = "hello";
double d = 5.89;

// Group the variables to send into a packet
sf::Packet packet;
packet << x << s << d;

// Send it over the network (socket is a valid sf::TcpSocket)
socket.send(packet);

-----------------------------------------------------------------

// Receive the packet at the other end
sf::Packet packet;
socket.receive(packet);

// Extract the variables contained in the packet
std::uint32_t x;
std::string s;
double d;
if (packet >> x >> s >> d)
{
    // Data extracted successfully...
}
```

Packets have built-in `operator>>` and << overloads for standard types: 

* `bool`
* fixed-size integer types (`int[8|16|32]_t`, `uint[8|16|32]_t`) 
* floating point numbers (`float`, `double`) 
* string types (`char*`, `wchar_t*`, `std::string`, `std::wstring`, `[sf::String](sf-String.md#string)`)

Like standard streams, it is also possible to define your own overloads of operators >> and << in order to handle your custom types.

```cpp
struct MyStruct
{
    float       number{};
    std::int8_t integer{};
    std::string str;
};

sf::Packet& operator <<(sf::Packet& packet, const MyStruct& m)
{
    return packet << m.number << m.integer << m.str;
}

sf::Packet& operator >>(sf::Packet& packet, MyStruct& m)
{
    return packet >> m.number >> m.integer >> m.str;
}
```

Packets also provide an extra feature that allows to apply custom transformations to the data before it is sent, and after it is received. This is typically used to handle automatic compression or encryption of the data. This is achieved by inheriting from `[sf::Packet](#packet)`, and overriding the onSend and onReceive functions.

Here is an example: 
```cpp
class ZipPacket : public sf::Packet
{
    const void* onSend(std::size_t& size) override
    {
        const void* srcData = getData();
        std::size_t srcSize = getDataSize();

        return MySuperZipFunction(srcData, srcSize, &size);
    }

    void onReceive(const void* data, std::size_t size) override
    {
        std::size_t dstSize;
        const void* dstData = MySuperUnzipFunction(data, size, &dstSize);

        append(dstData, dstSize);
    }
};

// Use like regular packets:
ZipPacket packet;
packet << x << s << d;
...
```

**See also**: `[sf::TcpSocket](sf-TcpSocket.md#tcpsocket-1)`, `[sf::UdpSocket](sf-UdpSocket.md#udpsocket-1)`

## Friends

| Name | Description |
|------|-------------|
| [`TcpSocket`](#tcpsocket)  |  |
| [`UdpSocket`](#udpsocket)  |  |

---

{#tcpsocket}

### TcpSocket

```cpp
friend class TcpSocket
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Packet.hpp:364

---

{#udpsocket}

### UdpSocket

```cpp
friend class UdpSocket
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Packet.hpp:365

## Public Methods

| Return | Name | Description |
|--------|------|-------------|
|  | [`Packet`](#packet-1)  | Default constructor. |
|  | [`~Packet`](#packet-2) `virtual` | Virtual destructor. |
|  | [`Packet`](#packet-3)  | Copy constructor. |
| [`Packet`](#packet) & | [`operator=`](#operator-29)  | Copy assignment. |
|  | [`Packet`](#packet-4) `noexcept` | Move constructor. |
| [`Packet`](#packet) & | [`operator=`](#operator-30) `noexcept` | Move assignment. |
| `void` | [`append`](#append)  | Append data to the end of the packet. |
| `std::size_t` | [`getReadPosition`](#getreadposition) `const` `nodiscard` | Get the current reading position in the packet. |
| `void` | [`clear`](#clear-1)  | Clear the packet. |
| `const void *` | [`getData`](#getdata-1) `const` `nodiscard` | Get a pointer to the data contained in the packet. |
| `std::size_t` | [`getDataSize`](#getdatasize) `const` `nodiscard` | Get the size of the data contained in the packet. |
| `bool` | [`endOfPacket`](#endofpacket) `const` `nodiscard` | Tell if the reading position has reached the end of the packet. |
|  | [`operator bool`](#operatorbool) `const` `explicit` | Test the validity of the packet, for reading. |
| [`Packet`](#packet) & | [`operator>>`](#operator-31)  | Overload of `operator>>` to read data from the packet |
| [`Packet`](#packet) & | [`operator>>`](#operator-32)  | This is an overloaded member function, provided for convenience. It differs from the above function only in what argument(s) it accepts. |
| [`Packet`](#packet) & | [`operator>>`](#operator-33)  | This is an overloaded member function, provided for convenience. It differs from the above function only in what argument(s) it accepts. |
| [`Packet`](#packet) & | [`operator>>`](#operator-34)  | This is an overloaded member function, provided for convenience. It differs from the above function only in what argument(s) it accepts. |
| [`Packet`](#packet) & | [`operator>>`](#operator-35)  | This is an overloaded member function, provided for convenience. It differs from the above function only in what argument(s) it accepts. |
| [`Packet`](#packet) & | [`operator>>`](#operator-36)  | This is an overloaded member function, provided for convenience. It differs from the above function only in what argument(s) it accepts. |
| [`Packet`](#packet) & | [`operator>>`](#operator-37)  | This is an overloaded member function, provided for convenience. It differs from the above function only in what argument(s) it accepts. |
| [`Packet`](#packet) & | [`operator>>`](#operator-38)  | This is an overloaded member function, provided for convenience. It differs from the above function only in what argument(s) it accepts. |
| [`Packet`](#packet) & | [`operator>>`](#operator-39)  | This is an overloaded member function, provided for convenience. It differs from the above function only in what argument(s) it accepts. |
| [`Packet`](#packet) & | [`operator>>`](#operator-40)  | This is an overloaded member function, provided for convenience. It differs from the above function only in what argument(s) it accepts. |
| [`Packet`](#packet) & | [`operator>>`](#operator-41)  | This is an overloaded member function, provided for convenience. It differs from the above function only in what argument(s) it accepts. |
| [`Packet`](#packet) & | [`operator>>`](#operator-42)  | This is an overloaded member function, provided for convenience. It differs from the above function only in what argument(s) it accepts. |
| [`Packet`](#packet) & | [`operator>>`](#operator-43)  | This is an overloaded member function, provided for convenience. It differs from the above function only in what argument(s) it accepts. |
| [`Packet`](#packet) & | [`operator>>`](#operator-44)  | This is an overloaded member function, provided for convenience. It differs from the above function only in what argument(s) it accepts. |
| [`Packet`](#packet) & | [`operator>>`](#operator-45)  | This is an overloaded member function, provided for convenience. It differs from the above function only in what argument(s) it accepts. |
| [`Packet`](#packet) & | [`operator>>`](#operator-46)  | This is an overloaded member function, provided for convenience. It differs from the above function only in what argument(s) it accepts. |
| [`Packet`](#packet) & | [`operator<<`](#operator-47)  | Overload of `operator<<` to write data into the packet |
| [`Packet`](#packet) & | [`operator<<`](#operator-48)  | This is an overloaded member function, provided for convenience. It differs from the above function only in what argument(s) it accepts. |
| [`Packet`](#packet) & | [`operator<<`](#operator-49)  | This is an overloaded member function, provided for convenience. It differs from the above function only in what argument(s) it accepts. |
| [`Packet`](#packet) & | [`operator<<`](#operator-50)  | This is an overloaded member function, provided for convenience. It differs from the above function only in what argument(s) it accepts. |
| [`Packet`](#packet) & | [`operator<<`](#operator-51)  | This is an overloaded member function, provided for convenience. It differs from the above function only in what argument(s) it accepts. |
| [`Packet`](#packet) & | [`operator<<`](#operator-52)  | This is an overloaded member function, provided for convenience. It differs from the above function only in what argument(s) it accepts. |
| [`Packet`](#packet) & | [`operator<<`](#operator-53)  | This is an overloaded member function, provided for convenience. It differs from the above function only in what argument(s) it accepts. |
| [`Packet`](#packet) & | [`operator<<`](#operator-54)  | This is an overloaded member function, provided for convenience. It differs from the above function only in what argument(s) it accepts. |
| [`Packet`](#packet) & | [`operator<<`](#operator-55)  | This is an overloaded member function, provided for convenience. It differs from the above function only in what argument(s) it accepts. |
| [`Packet`](#packet) & | [`operator<<`](#operator-56)  | This is an overloaded member function, provided for convenience. It differs from the above function only in what argument(s) it accepts. |
| [`Packet`](#packet) & | [`operator<<`](#operator-57)  | This is an overloaded member function, provided for convenience. It differs from the above function only in what argument(s) it accepts. |
| [`Packet`](#packet) & | [`operator<<`](#operator-58)  | This is an overloaded member function, provided for convenience. It differs from the above function only in what argument(s) it accepts. |
| [`Packet`](#packet) & | [`operator<<`](#operator-59)  | This is an overloaded member function, provided for convenience. It differs from the above function only in what argument(s) it accepts. |
| [`Packet`](#packet) & | [`operator<<`](#operator-60)  | This is an overloaded member function, provided for convenience. It differs from the above function only in what argument(s) it accepts. |
| [`Packet`](#packet) & | [`operator<<`](#operator-61)  | This is an overloaded member function, provided for convenience. It differs from the above function only in what argument(s) it accepts. |
| [`Packet`](#packet) & | [`operator<<`](#operator-62)  | This is an overloaded member function, provided for convenience. It differs from the above function only in what argument(s) it accepts. |

---

{#packet-1}

### Packet

```cpp
Packet() = default
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Packet.hpp:57

Default constructor.

Creates an empty packet.

---

{#packet-2}

### ~Packet

`virtual`

```cpp
virtual ~Packet() = default
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Packet.hpp:63

Virtual destructor.

---

{#packet-3}

### Packet

```cpp
Packet(const Packet &) = default
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Packet.hpp:69

Copy constructor.

---

{#operator-29}

### operator=

```cpp
Packet & operator=(const Packet &) = default
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Packet.hpp:75

Copy assignment.

---

{#packet-4}

### Packet

`noexcept`

```cpp
Packet(Packet &&) noexcept = default
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Packet.hpp:81

Move constructor.

---

{#operator-30}

### operator=

`noexcept`

```cpp
Packet & operator=(Packet &&) noexcept = default
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Packet.hpp:87

Move assignment.

---

{#append}

### append

```cpp
void append(const void * data, std::size_t sizeInBytes)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Packet.hpp:99

Append data to the end of the packet.

**See also**: `[clear](#clear-1)`

**See also**: `[getReadPosition](#getreadposition)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `data` | `const void *` | Pointer to the sequence of bytes to append |
| `sizeInBytes` | `std::size_t` | Number of bytes to append |

---

{#getreadposition}

### getReadPosition

`const` `nodiscard`

```cpp
[[nodiscard]] std::size_t getReadPosition() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Packet.hpp:111

Get the current reading position in the packet.

The next read operation will read data from this position

#### Returns
The byte offset of the current read position

**See also**: `[append](#append)`

---

{#clear-1}

### clear

```cpp
void clear()
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Packet.hpp:121

Clear the packet.

After calling Clear, the packet is empty.

**See also**: `[append](#append)`

---

{#getdata-1}

### getData

`const` `nodiscard`

```cpp
[[nodiscard]] const void * getData() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Packet.hpp:136

Get a pointer to the data contained in the packet.

Warning: the returned pointer may become invalid after you append data to the packet, therefore it should never be stored. The return pointer is a `nullptr` if the packet is empty.

#### Returns
Pointer to the data

**See also**: `[getDataSize](#getdatasize)`

---

{#getdatasize}

### getDataSize

`const` `nodiscard`

```cpp
[[nodiscard]] std::size_t getDataSize() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Packet.hpp:149

Get the size of the data contained in the packet.

This function returns the number of bytes pointed to by what `getData` returns.

#### Returns
Data size, in bytes

**See also**: `[getData](#getdata-1)`

---

{#endofpacket}

### endOfPacket

`const` `nodiscard`

```cpp
[[nodiscard]] bool endOfPacket() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Packet.hpp:163

Tell if the reading position has reached the end of the packet.

This function is useful to know if there is some data left to be read, without actually reading it.

#### Returns
`true` if all data was read, `false` otherwise

**See also**: `operator` bool

---

{#operatorbool}

### operator bool

`const` `explicit`

```cpp
explicit operator bool() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Packet.hpp:199

Test the validity of the packet, for reading.

This operator allows to test the packet as a boolean variable, to check if a reading operation was successful.

A packet will be in an invalid state if it has no more data to read.

This behavior is the same as standard C++ streams.

Usage example: 
```cpp
float x;
packet >> x;
if (packet)
{
   // ok, x was extracted successfully
}

// -- or --

float x;
if (packet >> x)
{
   // ok, x was extracted successfully
}
```

#### Returns
`true` if last data extraction from packet was successful

**See also**: `[endOfPacket](#endofpacket)`

---

{#operator-31}

### operator>>

```cpp
Packet & operator>>(bool & data)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Packet.hpp:205

Overload of `operator>>` to read data from the packet

---

{#operator-32}

### operator>>

```cpp
Packet & operator>>(std::int8_t & data)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Packet.hpp:210

This is an overloaded member function, provided for convenience. It differs from the above function only in what argument(s) it accepts.

---

{#operator-33}

### operator>>

```cpp
Packet & operator>>(std::uint8_t & data)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Packet.hpp:215

This is an overloaded member function, provided for convenience. It differs from the above function only in what argument(s) it accepts.

---

{#operator-34}

### operator>>

```cpp
Packet & operator>>(std::int16_t & data)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Packet.hpp:220

This is an overloaded member function, provided for convenience. It differs from the above function only in what argument(s) it accepts.

---

{#operator-35}

### operator>>

```cpp
Packet & operator>>(std::uint16_t & data)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Packet.hpp:225

This is an overloaded member function, provided for convenience. It differs from the above function only in what argument(s) it accepts.

---

{#operator-36}

### operator>>

```cpp
Packet & operator>>(std::int32_t & data)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Packet.hpp:230

This is an overloaded member function, provided for convenience. It differs from the above function only in what argument(s) it accepts.

---

{#operator-37}

### operator>>

```cpp
Packet & operator>>(std::uint32_t & data)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Packet.hpp:235

This is an overloaded member function, provided for convenience. It differs from the above function only in what argument(s) it accepts.

---

{#operator-38}

### operator>>

```cpp
Packet & operator>>(std::int64_t & data)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Packet.hpp:240

This is an overloaded member function, provided for convenience. It differs from the above function only in what argument(s) it accepts.

---

{#operator-39}

### operator>>

```cpp
Packet & operator>>(std::uint64_t & data)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Packet.hpp:245

This is an overloaded member function, provided for convenience. It differs from the above function only in what argument(s) it accepts.

---

{#operator-40}

### operator>>

```cpp
Packet & operator>>(float & data)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Packet.hpp:250

This is an overloaded member function, provided for convenience. It differs from the above function only in what argument(s) it accepts.

---

{#operator-41}

### operator>>

```cpp
Packet & operator>>(double & data)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Packet.hpp:255

This is an overloaded member function, provided for convenience. It differs from the above function only in what argument(s) it accepts.

---

{#operator-42}

### operator>>

```cpp
Packet & operator>>(char * data)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Packet.hpp:260

This is an overloaded member function, provided for convenience. It differs from the above function only in what argument(s) it accepts.

---

{#operator-43}

### operator>>

```cpp
Packet & operator>>(std::string & data)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Packet.hpp:265

This is an overloaded member function, provided for convenience. It differs from the above function only in what argument(s) it accepts.

---

{#operator-44}

### operator>>

```cpp
Packet & operator>>(wchar_t * data)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Packet.hpp:270

This is an overloaded member function, provided for convenience. It differs from the above function only in what argument(s) it accepts.

---

{#operator-45}

### operator>>

```cpp
Packet & operator>>(std::wstring & data)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Packet.hpp:275

This is an overloaded member function, provided for convenience. It differs from the above function only in what argument(s) it accepts.

---

{#operator-46}

### operator>>

```cpp
Packet & operator>>(String & data)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Packet.hpp:280

This is an overloaded member function, provided for convenience. It differs from the above function only in what argument(s) it accepts.

---

{#operator-47}

### operator<<

```cpp
Packet & operator<<(bool data)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Packet.hpp:286

Overload of `operator<<` to write data into the packet

---

{#operator-48}

### operator<<

```cpp
Packet & operator<<(std::int8_t data)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Packet.hpp:291

This is an overloaded member function, provided for convenience. It differs from the above function only in what argument(s) it accepts.

---

{#operator-49}

### operator<<

```cpp
Packet & operator<<(std::uint8_t data)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Packet.hpp:296

This is an overloaded member function, provided for convenience. It differs from the above function only in what argument(s) it accepts.

---

{#operator-50}

### operator<<

```cpp
Packet & operator<<(std::int16_t data)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Packet.hpp:301

This is an overloaded member function, provided for convenience. It differs from the above function only in what argument(s) it accepts.

---

{#operator-51}

### operator<<

```cpp
Packet & operator<<(std::uint16_t data)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Packet.hpp:306

This is an overloaded member function, provided for convenience. It differs from the above function only in what argument(s) it accepts.

---

{#operator-52}

### operator<<

```cpp
Packet & operator<<(std::int32_t data)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Packet.hpp:311

This is an overloaded member function, provided for convenience. It differs from the above function only in what argument(s) it accepts.

---

{#operator-53}

### operator<<

```cpp
Packet & operator<<(std::uint32_t data)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Packet.hpp:316

This is an overloaded member function, provided for convenience. It differs from the above function only in what argument(s) it accepts.

---

{#operator-54}

### operator<<

```cpp
Packet & operator<<(std::int64_t data)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Packet.hpp:321

This is an overloaded member function, provided for convenience. It differs from the above function only in what argument(s) it accepts.

---

{#operator-55}

### operator<<

```cpp
Packet & operator<<(std::uint64_t data)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Packet.hpp:326

This is an overloaded member function, provided for convenience. It differs from the above function only in what argument(s) it accepts.

---

{#operator-56}

### operator<<

```cpp
Packet & operator<<(float data)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Packet.hpp:331

This is an overloaded member function, provided for convenience. It differs from the above function only in what argument(s) it accepts.

---

{#operator-57}

### operator<<

```cpp
Packet & operator<<(double data)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Packet.hpp:336

This is an overloaded member function, provided for convenience. It differs from the above function only in what argument(s) it accepts.

---

{#operator-58}

### operator<<

```cpp
Packet & operator<<(const char * data)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Packet.hpp:341

This is an overloaded member function, provided for convenience. It differs from the above function only in what argument(s) it accepts.

---

{#operator-59}

### operator<<

```cpp
Packet & operator<<(const std::string & data)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Packet.hpp:346

This is an overloaded member function, provided for convenience. It differs from the above function only in what argument(s) it accepts.

---

{#operator-60}

### operator<<

```cpp
Packet & operator<<(const wchar_t * data)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Packet.hpp:351

This is an overloaded member function, provided for convenience. It differs from the above function only in what argument(s) it accepts.

---

{#operator-61}

### operator<<

```cpp
Packet & operator<<(const std::wstring & data)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Packet.hpp:356

This is an overloaded member function, provided for convenience. It differs from the above function only in what argument(s) it accepts.

---

{#operator-62}

### operator<<

```cpp
Packet & operator<<(const String & data)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Packet.hpp:361

This is an overloaded member function, provided for convenience. It differs from the above function only in what argument(s) it accepts.

## Protected Methods

| Return | Name | Description |
|--------|------|-------------|
| `const void *` | [`onSend`](#onsend) `virtual` | Called before the packet is sent over the network. |
| `void` | [`onReceive`](#onreceive) `virtual` | Called after the packet is received over the network. |

---

{#onsend}

### onSend

`virtual`

```cpp
virtual const void * onSend(std::size_t & size)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Packet.hpp:385

Called before the packet is sent over the network.

This function can be defined by derived classes to transform the data before it is sent; this can be used for compression, encryption, etc. The function must return a pointer to the modified data, as well as the number of bytes pointed. The default implementation provides the packet's data without transforming it.

#### Returns
Pointer to the array of bytes to send

**See also**: `[onReceive](#onreceive)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `size` | `std::size_t &` | Variable to fill with the size of data to send |

---

{#onreceive}

### onReceive

`virtual`

```cpp
virtual void onReceive(const void * data, std::size_t size)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Packet.hpp:404

Called after the packet is received over the network.

This function can be defined by derived classes to transform the data after it is received; this can be used for decompression, decryption, etc. The function receives a pointer to the received data, and must fill the packet with the transformed bytes. The default implementation fills the packet directly without transforming the data.

**See also**: `[onSend](#onsend)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `data` | `const void *` | Pointer to the received bytes |
| `size` | `std::size_t` | Number of bytes |

## Private Attributes

| Return | Name | Description |
|--------|------|-------------|
| `std::vector< std::byte >` | [`m_data`](#m_data-2)  | Data stored in the packet. |
| `std::size_t` | [`m_readPos`](#m_readpos)  | Current reading position in the packet. |
| `std::size_t` | [`m_sendPos`](#m_sendpos)  | Current send position in the packet (for handling partial sends) |
| `bool` | [`m_isValid`](#m_isvalid)  | Reading state of the packet. |

---

{#m_data-2}

### m_data

```cpp
std::vector< std::byte > m_data
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Packet.hpp:422

Data stored in the packet.

---

{#m_readpos}

### m_readPos

```cpp
std::size_t m_readPos {}
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Packet.hpp:423

Current reading position in the packet.

---

{#m_sendpos}

### m_sendPos

```cpp
std::size_t m_sendPos {}
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Packet.hpp:424

Current send position in the packet (for handling partial sends)

---

{#m_isvalid}

### m_isValid

```cpp
bool m_isValid {true}
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Packet.hpp:425

Reading state of the packet.

## Private Methods

| Return | Name | Description |
|--------|------|-------------|
| `bool` | [`checkSize`](#checksize)  | Check if the packet can extract a given number of bytes. |

---

{#checksize}

### checkSize

```cpp
bool checkSize(std::size_t size)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Packet.hpp:417

Check if the packet can extract a given number of bytes.

This function updates accordingly the state of the packet.

#### Returns
`true` if *size* bytes can be read from the packet

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `size` | `std::size_t` | Size to check |

