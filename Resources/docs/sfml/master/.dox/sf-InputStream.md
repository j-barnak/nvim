{#inputstream}

# InputStream

```cpp
#include <InputStream.hpp>
```

```cpp
class InputStream
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/InputStream.hpp:45

> **Subclassed by:** [`FileInputStream`](sf-FileInputStream.md#fileinputstream), [`MemoryInputStream`](sf-MemoryInputStream.md#memoryinputstream)

Abstract class for custom file input streams.

This class allows users to define their own file input sources from which SFML can load resources.

SFML resource classes like `[sf::Texture](sf-Texture.md#texture-2)` and `[sf::SoundBuffer](sf-SoundBuffer.md#soundbuffer-1)` provide `loadFromFile` and `loadFromMemory` functions, which read data from conventional sources. However, if you have data coming from a different source (over a network, embedded, encrypted, compressed, etc) you can derive your own class from `[sf::InputStream](#inputstream)` and load SFML resources with their `loadFromStream` function.

Usage example: 
```cpp
// custom stream class that reads from inside a zip file
class ZipStream : public sf::InputStream
{
public:

    ZipStream(const std::string& archive);

    [[nodiscard]] bool open(const std::filesystem::path& filename);

    [[nodiscard]] std::optional<std::size_t> read(void* data, std::size_t size);

    [[nodiscard]] std::optional<std::size_t> seek(std::size_t position);

    [[nodiscard]] std::optional<std::size_t> tell();

    std::optional<std::size_t> getSize();

private:

    ...
};

// now you can load textures...
ZipStream stream("resources.zip");

if (!stream.open("images/img.png"))
{
    // Handle error...
}

const sf::Texture texture(stream);

// musics...
sf::Music music;
ZipStream stream("resources.zip");

if (!stream.open("musics/msc.ogg"))
{
    // Handle error...
}

if (!music.openFromStream(stream))
{
    // Handle error...
}

// etc.
```

**See also**: `[FileInputStream](sf-FileInputStream.md#fileinputstream)`, `[MemoryInputStream](sf-MemoryInputStream.md#memoryinputstream)`

## Public Methods

| Return | Name | Description |
|--------|------|-------------|
|  | [`~InputStream`](#inputstream-1) `virtual` | Virtual destructor. |
| `std::optional< std::size_t >` | [`read`](#read-3) `virtual` `nodiscard` | Read data from the stream. |
| `std::optional< std::size_t >` | [`seek`](#seek-4) `virtual` `nodiscard` | Change the current reading position. |
| `std::optional< std::size_t >` | [`tell`](#tell-1) `virtual` `nodiscard` | Get the current reading position in the stream. |
| `std::optional< std::size_t >` | [`getSize`](#getsize-1) `virtual` | Return the size of the stream. |

---

{#inputstream-1}

### ~InputStream

`virtual`

```cpp
virtual ~InputStream() = default
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/InputStream.hpp:52

Virtual destructor.

---

{#read-3}

### read

`virtual` `nodiscard`

```cpp
[[nodiscard]] virtual std::optional< std::size_t > read(void * data, std::size_t size)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/InputStream.hpp:66

Read data from the stream.

After reading, the stream's reading position must be advanced by the amount of bytes read.

#### Returns
The number of bytes actually read, or `std::nullopt` on error

#### Reimplemented by

- [`read`](sf-FileInputStream.md#read-2)
- [`read`](sf-MemoryInputStream.md#read-4)

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `data` | `void *` | Buffer where to copy the read data |
| `size` | `std::size_t` | Desired number of bytes to read |

---

{#seek-4}

### seek

`virtual` `nodiscard`

```cpp
[[nodiscard]] virtual std::optional< std::size_t > seek(std::size_t position)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/InputStream.hpp:76

Change the current reading position.

#### Returns
The position actually sought to, or `std::nullopt` on error

#### Reimplemented by

- [`seek`](sf-FileInputStream.md#seek-3)
- [`seek`](sf-MemoryInputStream.md#seek-5)

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `position` | `std::size_t` | The position to seek to, from the beginning |

---

{#tell-1}

### tell

`virtual` `nodiscard`

```cpp
[[nodiscard]] virtual std::optional< std::size_t > tell()
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/InputStream.hpp:84

Get the current reading position in the stream.

#### Returns
The current position, or `std::nullopt` on error.

#### Reimplemented by

- [`tell`](sf-FileInputStream.md#tell)
- [`tell`](sf-MemoryInputStream.md#tell-2)

---

{#getsize-1}

### getSize

`virtual`

```cpp
virtual std::optional< std::size_t > getSize()
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/InputStream.hpp:92

Return the size of the stream.

#### Returns
The total number of bytes available in the stream, or `std::nullopt` on error

#### Reimplemented by

- [`getSize`](sf-FileInputStream.md#getsize)
- [`getSize`](sf-MemoryInputStream.md#getsize-2)

