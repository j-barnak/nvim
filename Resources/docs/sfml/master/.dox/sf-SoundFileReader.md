{#soundfilereader}

# SoundFileReader

```cpp
#include <SoundFileReader.hpp>
```

```cpp
class SoundFileReader
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundFileReader.hpp:48

Abstract base class for sound file decoding.

This class allows users to read audio file formats not natively supported by SFML, and thus extend the set of supported readable audio formats.

A valid sound file reader must override the open, seek and write functions, as well as providing a static check function; the latter is used by SFML to find a suitable writer for a given input file.

To register a new reader, use the `[sf::SoundFileFactory::registerReader](sf-SoundFileFactory.md#registerreader)` template function.

Usage example: 
```cpp
class MySoundFileReader : public sf::SoundFileReader
{
public:

    [[nodiscard]] static bool check(sf::InputStream& stream)
    {
        // typically, read the first few header bytes and check fields that identify the format
        // return true if the reader can handle the format
    }

    [[nodiscard]] std::optional<sf::SoundFileReader::Info> open(sf::InputStream& stream) override
    {
        // read the sound file header and fill the sound attributes
        // (channel count, sample count and sample rate)
        // return true on success
    }

    void seek(std::uint64_t sampleOffset) override
    {
        // advance to the sampleOffset-th sample from the beginning of the
        sound
    }

    std::uint64_t read(std::int16_t* samples, std::uint64_t maxCount) override
    {
        // read up to 'maxCount' samples into the 'samples' array,
        // convert them (for example from normalized float) if they are not stored
        // as 16-bits signed integers in the file
        // return the actual number of samples read
    }
};

sf::SoundFileFactory::registerReader<MySoundFileReader>();
```

**See also**: `[sf::InputSoundFile](sf-InputSoundFile.md#inputsoundfile)`, `[sf::SoundFileFactory](sf-SoundFileFactory.md#soundfilefactory)`, `[sf::SoundFileWriter](sf-SoundFileWriter.md#soundfilewriter)`

## Public Methods

| Return | Name | Description |
|--------|------|-------------|
|  | [`~SoundFileReader`](#soundfilereader-1) `virtual` | Virtual destructor. |
| std::optional< [`Info`](sf-SoundFileReader-Info.md#info) > | [`open`](#open) `virtual` `nodiscard` | Open a sound file for reading. |
| `void` | [`seek`](#seek-2) `virtual` | Change the current read position to the given sample offset. |
| `std::uint64_t` | [`read`](#read-1) `virtual` `nodiscard` | Read audio samples from the open file. |

---

{#soundfilereader-1}

### ~SoundFileReader

`virtual`

```cpp
virtual ~SoundFileReader() = default
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundFileReader.hpp:67

Virtual destructor.

---

{#open}

### open

`virtual` `nodiscard`

```cpp
[[nodiscard]] virtual std::optional< Info > open(InputStream & stream)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundFileReader.hpp:81

Open a sound file for reading.

The provided stream reference is valid as long as the `[SoundFileReader](#soundfilereader)` is alive, so it is safe to use/store it during the whole lifetime of the reader.

#### Returns
Properties of the loaded sound if the file was successfully opened, `std::nullopt` otherwise

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `stream` | [`InputStream`](sf-InputStream.md#inputstream) & | Source stream to read from |

---

{#seek-2}

### seek

`virtual`

```cpp
virtual void seek(std::uint64_t sampleOffset)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundFileReader.hpp:96

Change the current read position to the given sample offset.

The sample offset takes the channels into account. If you have a time offset instead, you can easily find the corresponding sample offset with the following formula: `timeInSeconds * sampleRate * channelCount` If the given offset exceeds to total number of samples, this function must jump to the end of the file.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `sampleOffset` | `std::uint64_t` | Index of the sample to jump to, relative to the beginning |

---

{#read-1}

### read

`virtual` `nodiscard`

```cpp
[[nodiscard]] virtual std::uint64_t read(std::int16_t * samples, std::uint64_t maxCount)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundFileReader.hpp:107

Read audio samples from the open file.

#### Returns
Number of samples actually read (may be less than *maxCount*)

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `samples` | `std::int16_t *` | Pointer to the sample array to fill |
| `maxCount` | `std::uint64_t` | Maximum number of samples to read |

