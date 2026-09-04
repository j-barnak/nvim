{#soundfilewriter}

# SoundFileWriter

```cpp
#include <SoundFileWriter.hpp>
```

```cpp
class SoundFileWriter
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundFileWriter.hpp:46

Abstract base class for sound file encoding.

This class allows users to write audio file formats not natively supported by SFML, and thus extend the set of supported writable audio formats.

A valid sound file writer must override the open and write functions, as well as providing a static check function; the latter is used by SFML to find a suitable writer for a given filename.

To register a new writer, use the `[sf::SoundFileFactory::registerWriter](sf-SoundFileFactory.md#registerwriter)` template function.

Usage example: 
```cpp
class MySoundFileWriter : public sf::SoundFileWriter
{
public:

    [[nodiscard]] static bool check(const std::filesystem::path& filename)
    {
        // typically, check the extension
        // return true if the writer can handle the format
    }

    [[nodiscard]] bool open(const std::filesystem::path& filename, unsigned int sampleRate, unsigned int channelCount, const std::vector<SoundChannel>& channelMap) override
    {
        // open the file 'filename' for writing,
        // write the given sample rate and channel count to the file header
        // return true on success
    }

    void write(const std::int16_t* samples, std::uint64_t count) override
    {
        // write 'count' samples stored at address 'samples',
        // convert them (for example to normalized float) if the format requires it
    }
};

sf::SoundFileFactory::registerWriter<MySoundFileWriter>();
```

**See also**: `[sf::OutputSoundFile](sf-OutputSoundFile.md#outputsoundfile)`, `[sf::SoundFileFactory](sf-SoundFileFactory.md#soundfilefactory)`, `[sf::SoundFileReader](sf-SoundFileReader.md#soundfilereader)`

## Public Methods

| Return | Name | Description |
|--------|------|-------------|
|  | [`~SoundFileWriter`](#soundfilewriter-1) `virtual` | Virtual destructor. |
| `bool` | [`open`](#open-1) `virtual` `nodiscard` | Open a sound file for writing. |
| `void` | [`write`](#write-1) `virtual` | Write audio samples to the open file. |

---

{#soundfilewriter-1}

### ~SoundFileWriter

`virtual`

```cpp
virtual ~SoundFileWriter() = default
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundFileWriter.hpp:53

Virtual destructor.

---

{#open-1}

### open

`virtual` `nodiscard`

```cpp
[[nodiscard]] virtual bool open(const std::filesystem::path & filename, unsigned int sampleRate, unsigned int channelCount, const std::vector< SoundChannel > & channelMap)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundFileWriter.hpp:66

Open a sound file for writing.

#### Returns
`true` if the file was successfully opened

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `filename` | `const std::filesystem::path &` | Path of the file to open |
| `sampleRate` | `unsigned int` | Sample rate of the sound |
| `channelCount` | `unsigned int` | Number of channels of the sound |
| `channelMap` | const std::vector< [`SoundChannel`](SoundChannel.md#soundchannel) > & | Map of position in sample frame to sound channel |

---

{#write-1}

### write

`virtual`

```cpp
virtual void write(const std::int16_t * samples, std::uint64_t count)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundFileWriter.hpp:78

Write audio samples to the open file.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `samples` | `const std::int16_t *` | Pointer to the sample array to write |
| `count` | `std::uint64_t` | Number of samples to write |

