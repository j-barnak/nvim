{#fileinputstream}

# FileInputStream

```cpp
#include <FileInputStream.hpp>
```

```cpp
class FileInputStream
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/FileInputStream.hpp:56

> **Inherits:** [`InputStream`](sf-InputStream.md#inputstream)

Implementation of input stream based on a file.

This class is a specialization of `[InputStream](sf-InputStream.md#inputstream)` that reads from a file on disk.

It wraps a file in the common `[InputStream](sf-InputStream.md#inputstream)` interface and therefore allows to use generic classes or functions that accept such a stream, with a file on disk as the data source.

In addition to the virtual functions inherited from `[InputStream](sf-InputStream.md#inputstream)`, `[FileInputStream](#fileinputstream)` adds a function to specify the file to open.

SFML resource classes can usually be loaded directly from a filename, so this class shouldn't be useful to you unless you create your own algorithms that operate on an [InputStream](sf-InputStream.md#inputstream).

Usage example: 
```cpp
void process(InputStream& stream);

std::optional stream = sf::FileInputStream::open("some_file.dat");
if (stream)
   process(*stream);
```

**See also**: `[InputStream](sf-InputStream.md#inputstream)`, `[MemoryInputStream](sf-MemoryInputStream.md#memoryinputstream)`

## List of all members

| Name | Kind | Owner |
|------|------|-------|
| [`FileInputStream`](#fileinputstream-1) | `function` | Declared here |
| [`~FileInputStream`](#fileinputstream-2) | `function` | Declared here |
| [`FileInputStream`](#fileinputstream-3) | `function` | Declared here |
| [`operator=`](#operator-9) | `function` | Declared here |
| [`FileInputStream`](#fileinputstream-4) | `function` | Declared here |
| [`operator=`](#operator-10) | `function` | Declared here |
| [`FileInputStream`](#fileinputstream-5) | `function` | Declared here |
| [`open`](#open-2) | `function` | Declared here |
| [`read`](#read-2) | `function` | Declared here |
| [`seek`](#seek-3) | `function` | Declared here |
| [`tell`](#tell) | `function` | Declared here |
| [`getSize`](#getsize) | `function` | Declared here |
| [`m_file`](#m_file) | `variable` | Declared here |
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
|  | [`FileInputStream`](#fileinputstream-1)  | Default constructor. |
|  | [`~FileInputStream`](#fileinputstream-2) `override` | Default destructor. |
|  | [`FileInputStream`](#fileinputstream-3)  | Deleted copy constructor. |
| [`FileInputStream`](#fileinputstream) & | [`operator=`](#operator-9)  | Deleted copy assignment. |
|  | [`FileInputStream`](#fileinputstream-4) `noexcept` | Move constructor. |
| [`FileInputStream`](#fileinputstream) & | [`operator=`](#operator-10) `noexcept` | Move assignment. |
|  | [`FileInputStream`](#fileinputstream-5) `explicit` | Construct the stream from a file path. |
| `bool` | [`open`](#open-2) `nodiscard` | Open the stream from a file path. |
| `std::optional< std::size_t >` | [`read`](#read-2) `virtual` `nodiscard` `override` | Read data from the stream. |
| `std::optional< std::size_t >` | [`seek`](#seek-3) `virtual` `nodiscard` `override` | Change the current reading position. |
| `std::optional< std::size_t >` | [`tell`](#tell) `virtual` `nodiscard` `override` | Get the current reading position in the stream. |
| `std::optional< std::size_t >` | [`getSize`](#getsize) `virtual` `override` | Return the size of the stream. |

---

{#fileinputstream-1}

### FileInputStream

```cpp
FileInputStream()
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/FileInputStream.hpp:66

Default constructor.

Construct a file input stream that is not associated with a file to read.

---

{#fileinputstream-2}

### ~FileInputStream

`override`

```cpp
~FileInputStream() override
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/FileInputStream.hpp:72

Default destructor.

---

{#fileinputstream-3}

### FileInputStream

```cpp
FileInputStream(const FileInputStream &) = delete
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/FileInputStream.hpp:78

Deleted copy constructor.

---

{#operator-9}

### operator=

```cpp
FileInputStream & operator=(const FileInputStream &) = delete
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/FileInputStream.hpp:84

Deleted copy assignment.

---

{#fileinputstream-4}

### FileInputStream

`noexcept`

```cpp
FileInputStream(FileInputStream &&) noexcept
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/FileInputStream.hpp:90

Move constructor.

---

{#operator-10}

### operator=

`noexcept`

```cpp
FileInputStream & operator=(FileInputStream &&) noexcept
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/FileInputStream.hpp:96

Move assignment.

---

{#fileinputstream-5}

### FileInputStream

`explicit`

```cpp
explicit FileInputStream(const std::filesystem::path & filename)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/FileInputStream.hpp:106

Construct the stream from a file path.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `filename` | `const std::filesystem::path &` | Name of the file to open |

#### Exceptions

| Exception | Description |
|-----------|-------------|
| `sf::Exception` | on error |

---

{#open-2}

### open

`nodiscard`

```cpp
[[nodiscard]] bool open(const std::filesystem::path & filename)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/FileInputStream.hpp:116

Open the stream from a file path.

#### Returns
`true` on success, `false` on error

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `filename` | `const std::filesystem::path &` | Name of the file to open |

---

{#read-2}

### read

`virtual` `nodiscard` `override`

```cpp
[[nodiscard]] virtual std::optional< std::size_t > read(void * data, std::size_t size) override
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/FileInputStream.hpp:130

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

{#seek-3}

### seek

`virtual` `nodiscard` `override`

```cpp
[[nodiscard]] virtual std::optional< std::size_t > seek(std::size_t position) override
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/FileInputStream.hpp:140

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

{#tell}

### tell

`virtual` `nodiscard` `override`

```cpp
[[nodiscard]] virtual std::optional< std::size_t > tell() override
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/FileInputStream.hpp:148

Get the current reading position in the stream.

#### Returns
The current position, or `std::nullopt` on error.

#### Reimplements

- [`tell`](sf-InputStream.md#tell-1)

---

{#getsize}

### getSize

`virtual` `override`

```cpp
virtual std::optional< std::size_t > getSize() override
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/FileInputStream.hpp:156

Return the size of the stream.

#### Returns
The total number of bytes available in the stream, or `std::nullopt` on error

#### Reimplements

- [`getSize`](sf-InputStream.md#getsize-1)

## Private Attributes

| Return | Name | Description |
|--------|------|-------------|
| `std::unique_ptr< std::FILE, FileCloser >` | [`m_file`](#m_file)  | stdio file stream |

---

{#m_file}

### m_file

```cpp
std::unique_ptr< std::FILE, FileCloser > m_file
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/FileInputStream.hpp:175

stdio file stream

