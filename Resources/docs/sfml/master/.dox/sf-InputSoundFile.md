{#inputsoundfile}

# InputSoundFile

```cpp
#include <InputSoundFile.hpp>
```

```cpp
class InputSoundFile
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/InputSoundFile.hpp:51

Provide read access to sound files.

This class decodes audio samples from a sound file. It is used internally by higher-level classes such as `[sf::SoundBuffer](sf-SoundBuffer.md#soundbuffer-1)` and `[sf::Music](sf-Music.md#music)`, but can also be useful if you want to process or analyze audio files without playing them, or if you want to implement your own version of `[sf::Music](sf-Music.md#music)` with more specific features.

Usage example: 
```cpp
// Open a sound file
sf::InputSoundFile file("music.ogg");

// Print the sound attributes
std::cout << "duration: " << file.getDuration().asSeconds() << '\n'
          << "channels: " << file.getChannelCount() << '\n'
          << "sample rate: " << file.getSampleRate() << '\n'
          << "sample count: " << file.getSampleCount() << std::endl;

// Read and process batches of samples until the end of file is reached
std::array<std::int16_t, 1024> samples;
std::uint64_t count;
do
{
    count = file.read(samples.data(), samples.size());

    // process, analyze, play, convert, or whatever
    // you want to do with the samples...
}
while (count > 0);
```

**See also**: `[sf::SoundFileReader](sf-SoundFileReader.md#soundfilereader)`, `[sf::OutputSoundFile](sf-OutputSoundFile.md#outputsoundfile)`

## Public Methods

| Return | Name | Description |
|--------|------|-------------|
|  | [`InputSoundFile`](#inputsoundfile-1)  | Default constructor. |
|  | [`InputSoundFile`](#inputsoundfile-2) `explicit` | Construct a sound file from the disk for reading. |
|  | [`InputSoundFile`](#inputsoundfile-3)  | Construct a sound file in memory for reading. |
|  | [`InputSoundFile`](#inputsoundfile-4) `explicit` | Construct a sound file from a custom stream for reading. |
| `bool` | [`openFromFile`](#openfromfile) `nodiscard` | Open a sound file from the disk for reading. |
| `bool` | [`openFromMemory`](#openfrommemory) `nodiscard` | Open a sound file in memory for reading. |
| `bool` | [`openFromStream`](#openfromstream) `nodiscard` | Open a sound file from a custom stream for reading. |
| `std::uint64_t` | [`getSampleCount`](#getsamplecount) `const` `nodiscard` | Get the total number of audio samples in the file. |
| `unsigned int` | [`getChannelCount`](#getchannelcount) `const` `nodiscard` | Get the number of channels used by the sound. |
| `unsigned int` | [`getSampleRate`](#getsamplerate) `const` `nodiscard` | Get the sample rate of the sound. |
| const std::vector< [`SoundChannel`](SoundChannel.md#soundchannel) > & | [`getChannelMap`](#getchannelmap) `const` `nodiscard` | Get the map of position in sample frame to sound channel. |
| [`Time`](sf-Time.md#time) | [`getDuration`](#getduration) `const` `nodiscard` | Get the total duration of the sound file. |
| [`Time`](sf-Time.md#time) | [`getTimeOffset`](#gettimeoffset) `const` `nodiscard` | Get the read offset of the file in time. |
| `std::uint64_t` | [`getSampleOffset`](#getsampleoffset) `const` `nodiscard` | Get the read offset of the file in samples. |
| `void` | [`seek`](#seek)  | Change the current read position to the given sample offset. |
| `void` | [`seek`](#seek-1)  | Change the current read position to the given time offset. |
| `std::uint64_t` | [`read`](#read) `nodiscard` | Read audio samples from the open file. |
| `void` | [`close`](#close)  | Close the current file. |

---

{#inputsoundfile-1}

### InputSoundFile

```cpp
InputSoundFile() = default
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/InputSoundFile.hpp:61

Default constructor.

Construct an input sound file that is not associated with a file to read.

---

{#inputsoundfile-2}

### InputSoundFile

`explicit`

```cpp
explicit InputSoundFile(const std::filesystem::path & filename)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/InputSoundFile.hpp:74

Construct a sound file from the disk for reading.

The supported audio formats are: WAV (PCM only), OGG/Vorbis, FLAC, MP3. The supported sample sizes for FLAC and WAV are 8, 16, 24 and 32 bit.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `filename` | `const std::filesystem::path &` | Path of the sound file to load |

#### Exceptions

| Exception | Description |
|-----------|-------------|
| `sf::Exception` | if opening the file was unsuccessful |

---

{#inputsoundfile-3}

### InputSoundFile

```cpp
InputSoundFile(const void * data, std::size_t sizeInBytes)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/InputSoundFile.hpp:88

Construct a sound file in memory for reading.

The supported audio formats are: WAV (PCM only), OGG/Vorbis, FLAC. The supported sample sizes for FLAC and WAV are 8, 16, 24 and 32 bit.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `data` | `const void *` | Pointer to the file data in memory |
| `sizeInBytes` | `std::size_t` | Size of the data to load, in bytes |

#### Exceptions

| Exception | Description |
|-----------|-------------|
| `sf::Exception` | if opening the file was unsuccessful |

---

{#inputsoundfile-4}

### InputSoundFile

`explicit`

```cpp
explicit InputSoundFile(InputStream & stream)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/InputSoundFile.hpp:101

Construct a sound file from a custom stream for reading.

The supported audio formats are: WAV (PCM only), OGG/Vorbis, FLAC. The supported sample sizes for FLAC and WAV are 8, 16, 24 and 32 bit.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `stream` | [`InputStream`](sf-InputStream.md#inputstream) & | Source stream to read from |

#### Exceptions

| Exception | Description |
|-----------|-------------|
| `sf::Exception` | if opening the file was unsuccessful |

---

{#openfromfile}

### openFromFile

`nodiscard`

```cpp
[[nodiscard]] bool openFromFile(const std::filesystem::path & filename)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/InputSoundFile.hpp:114

Open a sound file from the disk for reading.

The supported audio formats are: WAV (PCM only), OGG/Vorbis, FLAC, MP3. The supported sample sizes for FLAC and WAV are 8, 16, 24 and 32 bit.

#### Returns
`true` if the file was successfully opened

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `filename` | `const std::filesystem::path &` | Path of the sound file to load |

---

{#openfrommemory}

### openFromMemory

`nodiscard`

```cpp
[[nodiscard]] bool openFromMemory(const void * data, std::size_t sizeInBytes)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/InputSoundFile.hpp:128

Open a sound file in memory for reading.

The supported audio formats are: WAV (PCM only), OGG/Vorbis, FLAC. The supported sample sizes for FLAC and WAV are 8, 16, 24 and 32 bit.

#### Returns
`true` if the file was successfully opened

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `data` | `const void *` | Pointer to the file data in memory |
| `sizeInBytes` | `std::size_t` | Size of the data to load, in bytes |

---

{#openfromstream}

### openFromStream

`nodiscard`

```cpp
[[nodiscard]] bool openFromStream(InputStream & stream)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/InputSoundFile.hpp:141

Open a sound file from a custom stream for reading.

The supported audio formats are: WAV (PCM only), OGG/Vorbis, FLAC. The supported sample sizes for FLAC and WAV are 8, 16, 24 and 32 bit.

#### Returns
`true` if the file was successfully opened

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `stream` | [`InputStream`](sf-InputStream.md#inputstream) & | Source stream to read from |

---

{#getsamplecount}

### getSampleCount

`const` `nodiscard`

```cpp
[[nodiscard]] std::uint64_t getSampleCount() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/InputSoundFile.hpp:149

Get the total number of audio samples in the file.

#### Returns
Number of samples

---

{#getchannelcount}

### getChannelCount

`const` `nodiscard`

```cpp
[[nodiscard]] unsigned int getChannelCount() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/InputSoundFile.hpp:157

Get the number of channels used by the sound.

#### Returns
Number of channels (1 = mono, 2 = stereo)

---

{#getsamplerate}

### getSampleRate

`const` `nodiscard`

```cpp
[[nodiscard]] unsigned int getSampleRate() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/InputSoundFile.hpp:165

Get the sample rate of the sound.

#### Returns
Sample rate, in samples per second

---

{#getchannelmap}

### getChannelMap

`const` `nodiscard`

```cpp
[[nodiscard]] const std::vector< SoundChannel > & getChannelMap() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/InputSoundFile.hpp:178

Get the map of position in sample frame to sound channel.

This is used to map a sample in the sample stream to a position during spatialization.

#### Returns
Map of position in sample frame to sound channel

**See also**: `[getSampleRate](#getsamplerate)`, `[getChannelCount](#getchannelcount)`, `[getDuration](#getduration)`

---

{#getduration}

### getDuration

`const` `nodiscard`

```cpp
[[nodiscard]] Time getDuration() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/InputSoundFile.hpp:189

Get the total duration of the sound file.

This function is provided for convenience, the duration is deduced from the other sound file attributes.

#### Returns
Duration of the sound file

---

{#gettimeoffset}

### getTimeOffset

`const` `nodiscard`

```cpp
[[nodiscard]] Time getTimeOffset() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/InputSoundFile.hpp:197

Get the read offset of the file in time.

#### Returns
[Time](sf-Time.md#time) position

---

{#getsampleoffset}

### getSampleOffset

`const` `nodiscard`

```cpp
[[nodiscard]] std::uint64_t getSampleOffset() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/InputSoundFile.hpp:205

Get the read offset of the file in samples.

#### Returns
Sample position

---

{#seek}

### seek

```cpp
void seek(std::uint64_t sampleOffset)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/InputSoundFile.hpp:224

Change the current read position to the given sample offset.

This function takes a sample offset to provide maximum precision. If you need to jump to a given time, use the other overload.

The sample offset takes the channels into account. If you have a time offset instead, you can easily find the corresponding sample offset with the following formula: `timeInSeconds * sampleRate * channelCount` If the given offset exceeds to total number of samples, this function jumps to the end of the sound file.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `sampleOffset` | `std::uint64_t` | Index of the sample to jump to, relative to the beginning |

---

{#seek-1}

### seek

```cpp
void seek(Time timeOffset)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/InputSoundFile.hpp:238

Change the current read position to the given time offset.

Using a time offset is handy but imprecise. If you need an accurate result, consider using the overload which takes a sample offset.

If the given time exceeds to total duration, this function jumps to the end of the sound file.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `timeOffset` | [`Time`](sf-Time.md#time) | [Time](sf-Time.md#time) to jump to, relative to the beginning |

---

{#read}

### read

`nodiscard`

```cpp
[[nodiscard]] std::uint64_t read(std::int16_t * samples, std::uint64_t maxCount)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/InputSoundFile.hpp:249

Read audio samples from the open file.

#### Returns
Number of samples actually read (may be less than *maxCount*)

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `samples` | `std::int16_t *` | Pointer to the sample array to fill |
| `maxCount` | `std::uint64_t` | Maximum number of samples to read |

---

{#close}

### close

```cpp
void close()
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/InputSoundFile.hpp:255

Close the current file.

## Private Attributes

| Return | Name | Description |
|--------|------|-------------|
| std::unique_ptr< [`SoundFileReader`](sf-SoundFileReader.md#soundfilereader) > | [`m_reader`](#m_reader)  | Reader that handles I/O on the file's format. |
| std::unique_ptr< [`InputStream`](sf-InputStream.md#inputstream), StreamDeleter > | [`m_stream`](#m_stream)  | Input stream used to access the file's data. |
| `std::uint64_t` | [`m_sampleOffset`](#m_sampleoffset)  | Sample Read Position. |
| `std::uint64_t` | [`m_sampleCount`](#m_samplecount)  | Total number of samples in the file. |
| `unsigned int` | [`m_sampleRate`](#m_samplerate)  | Number of samples per second. |
| std::vector< [`SoundChannel`](SoundChannel.md#soundchannel) > | [`m_channelMap`](#m_channelmap)  | The map of position in sample frame to sound channel. |

---

{#m_reader}

### m_reader

```cpp
std::unique_ptr< SoundFileReader > m_reader
```

Type: std::unique_ptr< [`SoundFileReader`](sf-SoundFileReader.md#soundfilereader) >

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/InputSoundFile.hpp:278

Reader that handles I/O on the file's format.

---

{#m_stream}

### m_stream

```cpp
std::unique_ptr< InputStream, StreamDeleter > m_stream {nullptr, false}
```

Type: std::unique_ptr< [`InputStream`](sf-InputStream.md#inputstream), StreamDeleter >

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/InputSoundFile.hpp:279

Input stream used to access the file's data.

---

{#m_sampleoffset}

### m_sampleOffset

```cpp
std::uint64_t m_sampleOffset {}
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/InputSoundFile.hpp:280

Sample Read Position.

---

{#m_samplecount}

### m_sampleCount

```cpp
std::uint64_t m_sampleCount {}
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/InputSoundFile.hpp:281

Total number of samples in the file.

---

{#m_samplerate}

### m_sampleRate

```cpp
unsigned int m_sampleRate {}
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/InputSoundFile.hpp:282

Number of samples per second.

---

{#m_channelmap}

### m_channelMap

```cpp
std::vector< SoundChannel > m_channelMap
```

Type: std::vector< [`SoundChannel`](SoundChannel.md#soundchannel) >

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/InputSoundFile.hpp:283

The map of position in sample frame to sound channel.

