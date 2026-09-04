{#memoryinputstream}

# MemoryInputStream

```cpp
#include <MemoryInputStream.hpp>
```

```cpp
class MemoryInputStream
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/MemoryInputStream.hpp:46

> **Inherits:** [`InputStream`](sf-InputStream.md#inputstream)

Implementation of input stream based on a memory chunk.

This class is a specialization of `[InputStream](sf-InputStream.md#inputstream)` that reads from data in memory.

It wraps a memory chunk in the common `[InputStream](sf-InputStream.md#inputstream)` interface and therefore allows to use generic classes or functions that accept such a stream, with content already loaded in memory.

In addition to the virtual functions inherited from `[InputStream](sf-InputStream.md#inputstream)`, `[MemoryInputStream](#memoryinputstream)` adds a function to specify the pointer and size of the data in memory.

SFML resource classes can usually be loaded directly from memory, so this class shouldn't be useful to you unless you create your own algorithms that operate on an [InputStream](sf-InputStream.md#inputstream).

Usage example: 
```cpp
void process(InputStream& stream);

MemoryInputStream stream(thePtr, theSize);
process(stream);
```

**See also**: `[InputStream](sf-InputStream.md#inputstream)`, `[FileInputStream](sf-FileInputStream.md#fileinputstream)`

## List of all members

| Name | Kind | Owner |
|------|------|-------|
| [`MemoryInputStream`](#memoryinputstream-1) | `function` | Declared here |
| [`read`](#read-4) | `function` | Declared here |
| [`seek`](#seek-5) | `function` | Declared here |
| [`tell`](#tell-2) | `function` | Declared here |
| [`getSize`](#getsize-2) | `function` | Declared here |
| [`m_data`](#m_data) | `variable` | Declared here |
| [`m_size`](#m_size) | `variable` | Declared here |
| [`m_offset`](#m_offset) | `variable` | Declared here |
| [`~InputStream`](sf-InputStream.md#inputstream-1) | `function` | Inherited from [`InputStream`](sf-InputStream.md#inputstream) |
| [`read`](sf-InputStream.md#read-3) | `function` | Inherited from [`InputStream`](sf-InputStream.md#inputstream) |
| [`seek`](sf-InputStream.md#seek-4) | `function` | Inherited from [`InputStream`](sf-InputStream.md#inputstream) |
| [`tell`](sf-InputStream.md#tell-1) | `function` | Inherited from [`InputStream`](sf-InputStream.md#inputstream) |
| [`getSize`](sf-InputStream.md#getsize-1) | `function` | Inherited from [`InputStream`](sf-InputStream.md#inputstream) |

## Inherited from [`InputStream`](sf-InputStream.md#inputstream)

| Kind | Name | Description |
|------|------|-------------|
| `function` | [`~InputStream`](sf-InputStream.md#inputstream-1) `virtual` | Virtual destructor. |
| `function` | [`read`](sf-InputStream.md#read-3) `virtual` `nodiscard` | Read data from the stream. |
| `function` | [`seek`](sf-InputStream.md#seek-4) `virtual` `nodiscard` | Change the current reading position. |
| `function` | [`tell`](sf-InputStream.md#tell-1) `virtual` `nodiscard` | Get the current reading position in the stream. |
| `function` | [`getSize`](sf-InputStream.md#getsize-1) `virtual` | Return the size of the stream. |

## Public Methods

| Return | Name | Description |
|--------|------|-------------|
|  | [`MemoryInputStream`](#memoryinputstream-1)  | Construct the stream from its data. |
| `std::optional< std::size_t >` | [`read`](#read-4) `virtual` `nodiscard` `override` | Read data from the stream. |
| `std::optional< std::size_t >` | [`seek`](#seek-5) `virtual` `nodiscard` `override` | Change the current reading position. |
| `std::optional< std::size_t >` | [`tell`](#tell-2) `virtual` `nodiscard` `override` | Get the current reading position in the stream. |
| `std::optional< std::size_t >` | [`getSize`](#getsize-2) `virtual` `override` | Return the size of the stream. |

---

{#memoryinputstream-1}

### MemoryInputStream

```cpp
MemoryInputStream(const void * data, std::size_t sizeInBytes)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/MemoryInputStream.hpp:56

Construct the stream from its data.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `data` | `const void *` | Pointer to the data in memory |
| `sizeInBytes` | `std::size_t` | Size of the data, in bytes |

---

{#read-4}

### read

`virtual` `nodiscard` `override`

```cpp
[[nodiscard]] virtual std::optional< std::size_t > read(void * data, std::size_t size) override
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/MemoryInputStream.hpp:70

Read data from the stream.

After reading, the stream's reading position must be advanced by the amount of bytes read.

#### Returns
The number of bytes actually read, or `std::nullopt` on error

#### Reimplements

- [`read`](sf-InputStream.md#read-3)

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `data` | `void *` | Buffer where to copy the read data |
| `size` | `std::size_t` | Desired number of bytes to read |

---

{#seek-5}

### seek

`virtual` `nodiscard` `override`

```cpp
[[nodiscard]] virtual std::optional< std::size_t > seek(std::size_t position) override
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/MemoryInputStream.hpp:80

Change the current reading position.

#### Returns
The position actually sought to, or `std::nullopt` on error

#### Reimplements

- [`seek`](sf-InputStream.md#seek-4)

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `position` | `std::size_t` | The position to seek to, from the beginning |

---

{#tell-2}

### tell

`virtual` `nodiscard` `override`

```cpp
[[nodiscard]] virtual std::optional< std::size_t > tell() override
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/MemoryInputStream.hpp:88

Get the current reading position in the stream.

#### Returns
The current position, or `std::nullopt` on error.

#### Reimplements

- [`tell`](sf-InputStream.md#tell-1)

---

{#getsize-2}

### getSize

`virtual` `override`

```cpp
virtual std::optional< std::size_t > getSize() override
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/MemoryInputStream.hpp:96

Return the size of the stream.

#### Returns
The total number of bytes available in the stream, or `std::nullopt` on error

#### Reimplements

- [`getSize`](sf-InputStream.md#getsize-1)

## Private Attributes

| Return | Name | Description |
|--------|------|-------------|
| `const std::byte *` | [`m_data`](#m_data)  | Pointer to the data in memory. |
| `std::size_t` | [`m_size`](#m_size)  | Total size of the data. |
| `std::size_t` | [`m_offset`](#m_offset)  | Current reading position. |

---

{#m_data}

### m_data

```cpp
const std::byte * m_data {}
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/MemoryInputStream.hpp:102

Pointer to the data in memory.

---

{#m_size}

### m_size

```cpp
std::size_t m_size {}
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/MemoryInputStream.hpp:103

Total size of the data.

---

{#m_offset}

### m_offset

```cpp
std::size_t m_offset {}
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/MemoryInputStream.hpp:104

Current reading position.

