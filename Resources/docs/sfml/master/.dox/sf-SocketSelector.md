{#socketselector-1}

# SocketSelector

```cpp
#include <SocketSelector.hpp>
```

```cpp
class SocketSelector
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/SocketSelector.hpp:48

Multiplexer that allows to read from multiple sockets.

[Socket](sf-Socket.md#socket) selectors provide a way to wait until data can be received or sent on a set of sockets, instead of just one. This is convenient when you have multiple sockets that may possibly receive data, but you don't know which one will be ready first. In particular, it avoids to use a thread for each socket; with selectors, a single thread can handle all the sockets. When sending large amounts of data, the socket send buffer might fill up and you will have to wait for the data to actually be sent over the network connection before attempting to send more data.

All types of sockets can be used in a selector: 

* `[sf::TcpListener](sf-TcpListener.md#tcplistener)`
* `[sf::TcpSocket](sf-TcpSocket.md#tcpsocket-1)`
* `[sf::UdpSocket](sf-UdpSocket.md#udpsocket-1)`

A selector doesn't store its own copies of the sockets (socket classes are not copyable anyway), it simply keeps a reference to the original sockets that you pass to the "add" function. Therefore, you can't use the selector as a socket container, you must store them outside and make sure that they are alive as long as they are used in the selector.

Using a selector is simple: 

* populate the selector with all the sockets that you want to observe 
* make it wait until there is data available or data can be sent on any of the sockets 
* test each socket to find out which ones are ready for receiving or sending

If scalability is a concern, using callbacks is also possible: 

* add all the sockets that you want to observe to the selector with their own ready callbacks 
* make the selector wait until there is data available or data can be sent on any of the sockets 
* dispatch the callbacks of the sockets that became ready during the wait

Usage example: 
```cpp
// Create a socket to listen to new connections
sf::TcpListener listener;
if (listener.listen(55001) != sf::Socket::Status::Done)
{
    // Handle error...
}

// Create a list to store the future clients
std::vector<sf::TcpSocket> clients;

// Create a selector
sf::SocketSelector selector;

// Add the listener to the selector
selector.add(listener);

// Endless loop that waits for new connections
while (running)
{
    // Make the selector wait for data on any socket
    if (selector.wait())
    {
        // Test the listener
        if (selector.isReady(listener))
        {
            // The listener is ready: there is a pending connection
            sf::TcpSocket client;
            if (listener.accept(client) == sf::Socket::Status::Done)
            {
                // Add the new client to the selector so that we will
                // be notified when they send something
                selector.add(client);

                // Add the new client to the clients list
                clients.push_back(std::move(client));
            }
            else
            {
                // Handle error...
            }
        }
        else
        {
            // The listener socket is not ready, test all other sockets (the clients)
            for (sf::TcpSocket& client : clients)
            {
                if (selector.isReady(client))
                {
                    // The client has sent some data, we can receive it
                    sf::Packet packet;
                    if (client.receive(packet) == sf::Socket::Status::Done)
                    {
                        ...
                    }
                }
            }
        }
    }
}
```

Usage example with callbacks: 
```cpp
// Create a socket to listen to new connections
sf::TcpListener listener;
if (listener.listen(55001) != sf::Socket::Status::Done)
{
    // Handle error...
}

// Create a list to store the future clients
// We use a std::list here because modifications
// don't invalidate references to existing elements
std::list<sf::TcpSocket> clients;

// Create a selector
sf::SocketSelector selector;

// Listeners can only become ready to receive so we don't
// have to check the readiness type in their callback
const auto listenerCallback = [&](sf::SocketSelector::ReadinessType)
{
    // The listener is ready: there is a pending connection
    sf::TcpSocket newSocket;
    if (listener.accept(newSocket) == sf::Socket::Status::Done)
    {
        // Add the new client to the clients list
        auto& client = clients.emplace_back(std::move(newSocket));

        const auto clientCallback = [&client](sf::SocketSelector::ReadinessType readinessType)
        {
            if (readinessType & sf::SocketSelector::Receive)
            {
                // The client has sent some data, we can receive it
                sf::Packet packet;
                if (client.receive(packet) == sf::Socket::Status::Done)
                {
                    ...
                }
            }
        };

        // Add the new client to the selector with an attached
        // callback that will be called when they send something
        selector.add(client, sf::SocketSelector::Receive, clientCallback);
    }
    else
    {
        // Handle error...
    }
};

// Add the listener to the selector with an attached callback
selector.add(listener, sf::SocketSelector::Receive, listenerCallback);

// Endless loop that waits for new connections and receives client data
while (running)
{
    // Make the selector wait for sockets to become ready and dispatch their callbacks
    if (selector.wait())
        selector.dispatchReadyCallbacks();
}
```

**See also**: `[sf::Socket](sf-Socket.md#socket)`

## Public Methods

| Return | Name | Description |
|--------|------|-------------|
|  | [`SocketSelector`](#socketselector-2)  | Default constructor. |
|  | [`~SocketSelector`](#socketselector-3)  | Destructor. |
|  | [`SocketSelector`](#socketselector-4)  | Copy constructor. |
| [`SocketSelector`](#socketselector-1) & | [`operator=`](#operator-66)  | Overload of assignment operator. |
|  | [`SocketSelector`](#socketselector-5) `noexcept` | Move constructor. |
| [`SocketSelector`](#socketselector-1) & | [`operator=`](#operator-67) `noexcept` | Move assignment. |
| `bool` | [`add`](#add)  | Add a new socket to the selector. |
| `bool` | [`remove`](#remove)  | Remove a socket from the selector. |
| `void` | [`clear`](#clear-2)  | Remove all the sockets stored in the selector. |
| `bool` | [`wait`](#wait) `nodiscard` | Wait until one or more sockets are ready to receive or send. |
| `bool` | [`isReady`](#isready) `const` `nodiscard` | Test a socket to know if it is ready to receive or send data. |
| `void` | [`dispatchReadyCallbacks`](#dispatchreadycallbacks)  | Dispatch callbacks of ready sockets. |

---

{#socketselector-2}

### SocketSelector

```cpp
SocketSelector()
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/SocketSelector.hpp:67

Default constructor.

---

{#socketselector-3}

### ~SocketSelector

```cpp
~SocketSelector()
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/SocketSelector.hpp:73

Destructor.

---

{#socketselector-4}

### SocketSelector

```cpp
SocketSelector(const SocketSelector & copy)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/SocketSelector.hpp:81

Copy constructor.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `copy` | const [`SocketSelector`](#socketselector-1) & | Instance to copy |

---

{#operator-66}

### operator=

```cpp
SocketSelector & operator=(const SocketSelector & right)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/SocketSelector.hpp:91

Overload of assignment operator.

#### Returns
Reference to self

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `right` | const [`SocketSelector`](#socketselector-1) & | Instance to assign |

---

{#socketselector-5}

### SocketSelector

`noexcept`

```cpp
SocketSelector(SocketSelector &&) noexcept
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/SocketSelector.hpp:97

Move constructor.

---

{#operator-67}

### operator=

`noexcept`

```cpp
SocketSelector & operator=(SocketSelector &&) noexcept
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/SocketSelector.hpp:103

Move assignment.

---

{#add}

### add

```cpp
bool add(const Socket & socket, ReadinessType readinessType = Receive, std::function< void(ReadinessType readinessType)> readyCallback = {})
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/SocketSelector.hpp:164

Add a new socket to the selector.

The type of readiness to wait for can be specified. Specifying `[SocketSelector::Receive](#classsf_1_1SocketSelector_1acad2d08699208f9e3b38e395cab4017ea6e6be95bd56ee69eb433ff542abeec6d)` will wait for the socket to become ready to receive data from, specifying `[SocketSelector::Send](#classsf_1_1SocketSelector_1acad2d08699208f9e3b38e395cab4017ea4e2260e7259808f3e8ee56dfcf03a1a4)` will wait for the socket to become ready to send data on. Specifying `[SocketSelector::Receive](#classsf_1_1SocketSelector_1acad2d08699208f9e3b38e395cab4017ea6e6be95bd56ee69eb433ff542abeec6d) | [SocketSelector::Send](#classsf_1_1SocketSelector_1acad2d08699208f9e3b38e395cab4017ea4e2260e7259808f3e8ee56dfcf03a1a4)` will wait for the socket to become either ready to send or receive data on.

Adding a socket after it has already been added will just overwrite the existing readiness type with the new value.

This function keeps a weak reference to the socket, so you have to make sure that the socket is not destroyed while it is stored in the selector. This function does nothing if the socket is not valid.

When adding a socket to the selector you can also attach a callback along with it. The callback is called by `dispatchReadyCallbacks` when a socket is determined to be ready after a call to `wait`.

Using attached callbacks instead of having to individually call `isReady` on every socket after every call to `wait` allows for scaling up to a large number of sockets. This is because the overhead of checking for socket readiness using `isReady` grows proportionally to the total number of sockets. When using callbacks calling `isReady` on every socket is no longer necessary.

Because a socket can be ready for receiving, sending or both, the type of readiness is passed to the attached callback as a bitwise combination of `[SocketSelector::Receive](#classsf_1_1SocketSelector_1acad2d08699208f9e3b38e395cab4017ea6e6be95bd56ee69eb433ff542abeec6d)` and/or `[SocketSelector::Send](#classsf_1_1SocketSelector_1acad2d08699208f9e3b38e395cab4017ea4e2260e7259808f3e8ee56dfcf03a1a4)` when it is called by `dispatchReadyCallbacks`. Some systems don't support combined read and write notifications. On these systems, if a socket is ready to be both received from and sent to the callback will be called twice, once with `[SocketSelector::Receive](#classsf_1_1SocketSelector_1acad2d08699208f9e3b38e395cab4017ea6e6be95bd56ee69eb433ff542abeec6d)` and once with `[SocketSelector::Send](#classsf_1_1SocketSelector_1acad2d08699208f9e3b38e395cab4017ea4e2260e7259808f3e8ee56dfcf03a1a4)`.

To remove the attached callback of a socket, call `add` again with an empty function.

By default, no readiness callback is attached when adding a socket.

#### Returns
`true` if the socket was added successfully, `false` otherwise

**See also**: `[remove](#remove)`, `[clear](#clear-2)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `socket` | const [`Socket`](sf-Socket.md#socket) & | Reference to the socket to add |
| `readinessType` | [`ReadinessType`](#readinesstype) | Type of readiness to wait for, a bitwise combination of `[SocketSelector::Receive](#classsf_1_1SocketSelector_1acad2d08699208f9e3b38e395cab4017ea6e6be95bd56ee69eb433ff542abeec6d)` and/or `[SocketSelector::Send](#classsf_1_1SocketSelector_1acad2d08699208f9e3b38e395cab4017ea4e2260e7259808f3e8ee56dfcf03a1a4)` |
| `readyCallback` | std::function< void([`ReadinessType`](#readinesstype) readinessType)> | Ready callback to attach to the socket, pass an empty function to remove the ready callback |

---

{#remove}

### remove

```cpp
bool remove(const Socket & socket)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/SocketSelector.hpp:181

Remove a socket from the selector.

This function doesn't destroy the socket, it simply removes the reference that the selector has to it.

#### Returns
`true` if the socket was removed successfully, `false` otherwise

**See also**: `[add](#add)`, `[clear](#clear-2)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `socket` | const [`Socket`](sf-Socket.md#socket) & | Reference to the socket to remove |

---

{#clear-2}

### clear

```cpp
void clear()
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/SocketSelector.hpp:193

Remove all the sockets stored in the selector.

This function doesn't destroy any instance, it simply removes all the references that the selector has to external sockets.

**See also**: `[add](#add)`, `[remove](#remove)`

---

{#wait}

### wait

`nodiscard`

```cpp
[[nodiscard]] bool wait(Time timeout = Time::Zero)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/SocketSelector.hpp:212

Wait until one or more sockets are ready to receive or send.

This function returns as soon as at least one socket has some data available to be received or data can be sent, depending on how the socket was added to this selector. To know which sockets are ready, use the `isReady` function. If you use a timeout and no socket is ready before the timeout is over, the function returns `false`.

#### Returns
`true` if there are sockets ready, `false` otherwise

**See also**: `[isReady](#isready)`, `[dispatchReadyCallbacks](#dispatchreadycallbacks)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `timeout` | [`Time`](sf-Time.md#time) | Maximum time to wait, (use [Time::Zero](sf-Time.md#zero-1) for infinity) |

---

{#isready}

### isReady

`const` `nodiscard`

```cpp
[[nodiscard]] bool isReady(const Socket & socket, ReadinessType readinessType = Receive) const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/SocketSelector.hpp:232

Test a socket to know if it is ready to receive or send data.

This function must be used after a call to `wait`, to know which sockets are ready to receive or send data. If a socket is ready, a call to receive or send will never block because we know that there is data available to read or we can write. Note that if this function returns `true` for a [TcpListener](sf-TcpListener.md#tcplistener), this means that it is ready to accept a new connection.

#### Returns
`true` if the socket is ready to read, `false` otherwise

**See also**: `[wait](#wait)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `socket` | const [`Socket`](sf-Socket.md#socket) & | [Socket](sf-Socket.md#socket) to test |
| `readinessType` | [`ReadinessType`](#readinesstype) | Type of readiness to check for, a bitwise combination of `[SocketSelector::Receive](#classsf_1_1SocketSelector_1acad2d08699208f9e3b38e395cab4017ea6e6be95bd56ee69eb433ff542abeec6d)` and/or `[SocketSelector::Send](#classsf_1_1SocketSelector_1acad2d08699208f9e3b38e395cab4017ea4e2260e7259808f3e8ee56dfcf03a1a4)` |

---

{#dispatchreadycallbacks}

### dispatchReadyCallbacks

```cpp
void dispatchReadyCallbacks()
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/SocketSelector.hpp:252

Dispatch callbacks of ready sockets.

After calling `wait` returns `true`, at least one socket is ready to receive or send data. Calling `dispatchReadyCallbacks` will call the attached ready callback for every socket that is ready to either receive or send data. Sockets that don't have a callback attached can still be individually checked using `isReady`.

The readiness state of each socket is maintained until the next call to `wait`. Calling `dispatchReadyCallbacks` multiple times after a single call to `wait` will run the exact same callbacks with the exact same passed arguments.

**See also**: `[wait](#wait)`

## Public Types

| Name | Description |
|------|-------------|
| [``](#unknown)  | Type of readiness to check for. |
| [`ReadinessType`](#readinesstype)  | Bitwise combination of readiness types. |

---

{#unknown}

### 

```cpp
enum 
```

Type: [`ReadinessType`](#readinesstype)

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/SocketSelector.hpp:57

Type of readiness to check for.

| Value | Description |
|-------|-------------|
| `Receive` | Check if sockets are ready to be received from. |
| `Send` | Check if sockets are ready to be sent to. |

---

{#readinesstype}

### ReadinessType

```cpp
using ReadinessType = std::uint32_t
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/SocketSelector.hpp:51

Bitwise combination of readiness types.

## Private Attributes

| Return | Name | Description |
|--------|------|-------------|
| `std::unique_ptr< SocketSelectorImpl >` | [`m_impl`](#m_impl-7)  | Opaque pointer to the implementation (which requires OS-specific types) |

---

{#m_impl-7}

### m_impl

```cpp
std::unique_ptr< SocketSelectorImpl > m_impl
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/SocketSelector.hpp:260

Opaque pointer to the implementation (which requires OS-specific types)

