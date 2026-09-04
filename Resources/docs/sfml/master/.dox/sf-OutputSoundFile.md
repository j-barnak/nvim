{#outputsoundfile}

# OutputSoundFile

```cpp
#include <OutputSoundFile.hpp>
```

```cpp
class OutputSoundFile
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/OutputSoundFile.hpp:48

Provide write access to sound files.

This class encodes audio samples to a sound file. It is used internally by higher-level classes such as `[sf::SoundBuffer](sf-SoundBuffer.md#soundbuffer-1)`, but can also be useful if you want to create audio files from custom data sources, like generated audio samples.

Usage example: 
```cpp
// Create a sound file, ogg/vorbis format, 44100 Hz, stereo
sf::OutputSoundFile file("music.ogg", 44100, 2, {sf::SoundChannel::FrontLeft, sf::SoundChannel::FrontRight});

while (...)
{
    // Read or generate audio samples from your custom source
    std::vector<std::int16_t> samples = ...;

    // Write them to the file
    file.write(samples.data(), samples.size());
}
```

**See also**: `[sf::SoundFileWriter](sf-SoundFileWriter.md#soundfilewriter)`, `[sf::InputSoundFile](sf-InputSoundFile.md#inputsoundfile)`

## Public Methods

| Return | Name | Description |
|--------|------|-------------|
|  | [`OutputSoundFile`](#outputsoundfile-1)  | Default constructor. |
|  | [`OutputSoundFile`](#outputsoundfile-2)  | Construct the sound file from the disk for writing. |
| `bool` | [`openFromFile`](#openfromfile-2) `nodiscard` | Open the sound file from the disk for writing. |
| `void` | [`write`](#write)  | Write audio samples to the file. |
| `void` | [`close`](#close-1)  | Close the current file. |

---

{#outputsoundfile-1}

### OutputSoundFile

```cpp
OutputSoundFile() = default
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/OutputSoundFile.hpp:58

Default constructor.

Construct an output sound file that is not associated with a file to write.

---

{#outputsoundfile-2}

### OutputSoundFile

```cpp
OutputSoundFile(const std::filesystem::path & filename, unsigned int sampleRate, unsigned int channelCount, const std::vector< SoundChannel > & channelMap)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/OutputSoundFile.hpp:73

Construct the sound file from the disk for writing.

The supported audio formats are: WAV, OGG/Vorbis, FLAC.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `filename` | `const std::filesystem::path &` | Path of the sound file to write |
| `sampleRate` | `unsigned int` | Sample rate of the sound |
| `channelCount` | `unsigned int` | Number of channels in the sound |
| `channelMap` | const std::vector< [`SoundChannel`](SoundChannel.md#soundchannel) > & | Map of position in sample frame to sound channel |

#### Exceptions

| Exception | Description |
|-----------|-------------|
| `sf::Exception` | if the file could not be opened successfully |

---

{#openfromfile-2}

### openFromFile

`nodiscard`

```cpp
[[nodiscard]] bool openFromFile(const std::filesystem::path & filename, unsigned int sampleRate, unsigned int channelCount, const std::vector< SoundChannel > & channelMap)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/OutputSoundFile.hpp:91

Open the sound file from the disk for writing.

The supported audio formats are: WAV, OGG/Vorbis, FLAC.

#### Returns
`true` if the file was successfully opened

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `filename` | `const std::filesystem::path &` | Path of the sound file to write |
| `sampleRate` | `unsigned int` | Sample rate of the sound |
| `channelCount` | `unsigned int` | Number of channels in the sound |
| `channelMap` | const std::vector< [`SoundChannel`](SoundChannel.md#soundchannel) > & | Map of position in sample frame to sound channel |

---

{#write}

### write

```cpp
void write(const std::int16_t * samples, std::uint64_t count)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/OutputSoundFile.hpp:103

Write audio samples to the file.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `samples` | `const std::int16_t *` | Pointer to the sample array to write |
| `count` | `std::uint64_t` | Number of samples to write |

---

{#close-1}

### close

```cpp
void close()
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/OutputSoundFile.hpp:109

Close the current file.

## Private Attributes

| Return | Name | Description |
|--------|------|-------------|
| std::unique_ptr< [`SoundFileWriter`](sf-SoundFileWriter.md#soundfilewriter) > | [`m_writer`](#m_writer)  | Writer that handles I/O on the file's format. |

---

{#m_writer}

### m_writer

```cpp
std::unique_ptr< SoundFileWriter > m_writer
```

Type: std::unique_ptr< [`SoundFileWriter`](sf-SoundFileWriter.md#soundfilewriter) >

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/OutputSoundFile.hpp:115

Writer that handles I/O on the file's format.

