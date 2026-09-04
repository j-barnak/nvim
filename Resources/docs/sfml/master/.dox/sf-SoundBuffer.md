{#soundbuffer-1}

# SoundBuffer

```cpp
#include <SoundBuffer.hpp>
```

```cpp
class SoundBuffer
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundBuffer.hpp:54

Storage for audio samples defining a sound.

A sound buffer holds the data of a sound, which is an array of audio samples. A sample is a 16 bit signed integer that defines the amplitude of the sound at a given time. The sound is then reconstituted by playing these samples at a high rate (for example, 44100 samples per second is the standard rate used for playing CDs). In short, audio samples are like texture pixels, and a `[sf::SoundBuffer](#soundbuffer-1)` is similar to a `[sf::Texture](sf-Texture.md#texture-2)`.

A sound buffer can be loaded from a file, from memory, from a custom stream (see `[sf::InputStream](sf-InputStream.md#inputstream)`) or directly from an array of samples. It can also be saved back to a file.

[Sound](sf-Sound.md#sound) buffers alone are not very useful: they hold the audio data but cannot be played. To do so, you need to use the `[sf::Sound](sf-Sound.md#sound)` class, which provides functions to play/pause/stop the sound as well as changing the way it is outputted (volume, pitch, 3D position, ...). This separation allows more flexibility and better performances: indeed a `[sf::SoundBuffer](#soundbuffer-1)` is a heavy resource, and any operation on it is slow (often too slow for real-time applications). On the other side, a `[sf::Sound](sf-Sound.md#sound)` is a lightweight object, which can use the audio data of a sound buffer and change the way it is played without actually modifying that data. Note that it is also possible to bind several `[sf::Sound](sf-Sound.md#sound)` instances to the same `[sf::SoundBuffer](#soundbuffer-1)`.

It is important to note that the `[sf::Sound](sf-Sound.md#sound)` instance doesn't copy the buffer that it uses, it only keeps a reference to it. Thus, a `[sf::SoundBuffer](#soundbuffer-1)` must not be destructed while it is used by a `[sf::Sound](sf-Sound.md#sound)` (i.e. never write a function that uses a local `[sf::SoundBuffer](#soundbuffer-1)` instance for loading a sound).

When loading sound samples from an array, a channel map needs to be provided, which specifies the mapping of the position in the sample frame to the sound channel. For example when you have six samples in a frame and a 5.1 sound system, the channel map defines how each of those samples map to which speaker channel.

Usage example: 
```cpp
// Load a new sound buffer from a file
const sf::SoundBuffer buffer("sound.wav");

// Create a sound source bound to the buffer
sf::Sound sound1(buffer);

// Play the sound
sound1.play();

// Create another sound source bound to the same buffer
sf::Sound sound2(buffer);

// Play it with a higher pitch -- the first sound remains unchanged
sound2.setPitch(2);
sound2.play();

// Load samples with a channel map
auto samples = std::vector<std::int16_t>();
// ...
auto channelMap = std::vector<sf::SoundChannel>{
    sf::SoundChannel::FrontLeft,
    sf::SoundChannel::FrontCenter,
    sf::SoundChannel::FrontRight,
    sf::SoundChannel::BackRight,
    sf::SoundChannel::BackLeft,
    sf::SoundChannel::LowFrequencyEffects
};
auto soundBuffer = sf::SoundBuffer(samples.data(), samples.size(), channelMap.size(), 44100, channelMap);
auto sound = sf::Sound(soundBuffer);
```

**See also**: `[sf::Sound](sf-Sound.md#sound)`, `[sf::SoundBufferRecorder](sf-SoundBufferRecorder.md#soundbufferrecorder)`

## Friends

| Name | Description |
|------|-------------|
| [`Sound`](#sound-5)  |  |

---

{#sound-5}

### Sound

```cpp
friend class Sound
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundBuffer.hpp:317

## Public Methods

| Return | Name | Description |
|--------|------|-------------|
|  | [`SoundBuffer`](#soundbuffer-2)  | Default constructor. |
|  | [`SoundBuffer`](#soundbuffer-3)  | Copy constructor. |
|  | [`SoundBuffer`](#soundbuffer-4) `explicit` | Construct the sound buffer from a file. |
|  | [`SoundBuffer`](#soundbuffer-5)  | Construct the sound buffer from a file in memory. |
|  | [`SoundBuffer`](#soundbuffer-6) `explicit` | Construct the sound buffer from a custom stream. |
|  | [`SoundBuffer`](#soundbuffer-7)  | Construct the sound buffer from an array of audio samples. |
|  | [`~SoundBuffer`](#soundbuffer-8)  | Destructor. |
| `bool` | [`loadFromFile`](#loadfromfile) `nodiscard` | Load the sound buffer from a file. |
| `bool` | [`loadFromMemory`](#loadfrommemory) `nodiscard` | Load the sound buffer from a file in memory. |
| `bool` | [`loadFromStream`](#loadfromstream) `nodiscard` | Load the sound buffer from a custom stream. |
| `bool` | [`loadFromSamples`](#loadfromsamples) `nodiscard` | Load the sound buffer from an array of audio samples. |
| `bool` | [`saveToFile`](#savetofile) `const` `nodiscard` | Save the sound buffer to an audio file. |
| `const std::int16_t *` | [`getSamples`](#getsamples) `const` `nodiscard` | Get the array of audio samples stored in the buffer. |
| `std::uint64_t` | [`getSampleCount`](#getsamplecount-1) `const` `nodiscard` | Get the number of samples stored in the buffer. |
| `unsigned int` | [`getSampleRate`](#getsamplerate-1) `const` `nodiscard` | Get the sample rate of the sound. |
| `unsigned int` | [`getChannelCount`](#getchannelcount-1) `const` `nodiscard` | Get the number of channels used by the sound. |
| const std::vector< [`SoundChannel`](SoundChannel.md#soundchannel) > & | [`getChannelMap`](#getchannelmap-1) `const` `nodiscard` | Get the map of position in sample frame to sound channel. |
| [`Time`](sf-Time.md#time) | [`getDuration`](#getduration-2) `const` `nodiscard` | Get the total duration of the sound. |
| [`SoundBuffer`](#soundbuffer-1) & | [`operator=`](#operator-5)  | Overload of assignment operator. |

---

{#soundbuffer-2}

### SoundBuffer

```cpp
SoundBuffer() = default
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundBuffer.hpp:64

Default constructor.

Construct an empty sound buffer that does not contain any samples.

---

{#soundbuffer-3}

### SoundBuffer

```cpp
SoundBuffer(const SoundBuffer & copy)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundBuffer.hpp:72

Copy constructor.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `copy` | const [`SoundBuffer`](#soundbuffer-1) & | Instance to copy |

---

{#soundbuffer-4}

### SoundBuffer

`explicit`

```cpp
explicit SoundBuffer(const std::filesystem::path & filename)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundBuffer.hpp:87

Construct the sound buffer from a file.

See the documentation of `[sf::InputSoundFile](sf-InputSoundFile.md#inputsoundfile)` for the list of supported formats.

**See also**: `[loadFromMemory](#loadfrommemory)`, `[loadFromStream](#loadfromstream)`, `[loadFromSamples](#loadfromsamples)`, `[saveToFile](#savetofile)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `filename` | `const std::filesystem::path &` | Path of the sound file to load |

#### Exceptions

| Exception | Description |
|-----------|-------------|
| `sf::Exception` | if loading was unsuccessful |

---

{#soundbuffer-5}

### SoundBuffer

```cpp
SoundBuffer(const void * data, std::size_t sizeInBytes)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundBuffer.hpp:103

Construct the sound buffer from a file in memory.

See the documentation of `[sf::InputSoundFile](sf-InputSoundFile.md#inputsoundfile)` for the list of supported formats.

**See also**: `[loadFromFile](#loadfromfile)`, `[loadFromStream](#loadfromstream)`, `[loadFromSamples](#loadfromsamples)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `data` | `const void *` | Pointer to the file data in memory |
| `sizeInBytes` | `std::size_t` | Size of the data to load, in bytes |

#### Exceptions

| Exception | Description |
|-----------|-------------|
| `sf::Exception` | if loading was unsuccessful |

---

{#soundbuffer-6}

### SoundBuffer

`explicit`

```cpp
explicit SoundBuffer(InputStream & stream)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundBuffer.hpp:118

Construct the sound buffer from a custom stream.

See the documentation of `[sf::InputSoundFile](sf-InputSoundFile.md#inputsoundfile)` for the list of supported formats.

**See also**: `[loadFromFile](#loadfromfile)`, `[loadFromMemory](#loadfrommemory)`, `[loadFromSamples](#loadfromsamples)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `stream` | [`InputStream`](sf-InputStream.md#inputstream) & | Source stream to read from |

#### Exceptions

| Exception | Description |
|-----------|-------------|
| `sf::Exception` | if loading was unsuccessful |

---

{#soundbuffer-7}

### SoundBuffer

```cpp
SoundBuffer(const std::int16_t * samples, std::uint64_t sampleCount, unsigned int channelCount, unsigned int sampleRate, const std::vector< SoundChannel > & channelMap)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundBuffer.hpp:136

Construct the sound buffer from an array of audio samples.

The assumed format of the audio samples is 16 bit signed integer.

**See also**: `[loadFromFile](#loadfromfile)`, `[loadFromMemory](#loadfrommemory)`, `[saveToFile](#savetofile)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `samples` | `const std::int16_t *` | Pointer to the array of samples in memory |
| `sampleCount` | `std::uint64_t` | Number of samples in the array |
| `channelCount` | `unsigned int` | Number of channels (1 = mono, 2 = stereo, ...) |
| `sampleRate` | `unsigned int` | Sample rate (number of samples to play per second) |
| `channelMap` | const std::vector< [`SoundChannel`](SoundChannel.md#soundchannel) > & | Map of position in sample frame to sound channel |

#### Exceptions

| Exception | Description |
|-----------|-------------|
| `sf::Exception` | if loading was unsuccessful |

---

{#soundbuffer-8}

### ~SoundBuffer

```cpp
~SoundBuffer()
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundBuffer.hpp:146

Destructor.

---

{#loadfromfile}

### loadFromFile

`nodiscard`

```cpp
[[nodiscard]] bool loadFromFile(const std::filesystem::path & filename)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundBuffer.hpp:161

Load the sound buffer from a file.

See the documentation of `[sf::InputSoundFile](sf-InputSoundFile.md#inputsoundfile)` for the list of supported formats.

#### Returns
`true` if loading succeeded, `false` if it failed

**See also**: `[loadFromMemory](#loadfrommemory)`, `[loadFromStream](#loadfromstream)`, `[loadFromSamples](#loadfromsamples)`, `[saveToFile](#savetofile)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `filename` | `const std::filesystem::path &` | Path of the sound file to load |

---

{#loadfrommemory}

### loadFromMemory

`nodiscard`

```cpp
[[nodiscard]] bool loadFromMemory(const void * data, std::size_t sizeInBytes)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundBuffer.hpp:177

Load the sound buffer from a file in memory.

See the documentation of `[sf::InputSoundFile](sf-InputSoundFile.md#inputsoundfile)` for the list of supported formats.

#### Returns
`true` if loading succeeded, `false` if it failed

**See also**: `[loadFromFile](#loadfromfile)`, `[loadFromStream](#loadfromstream)`, `[loadFromSamples](#loadfromsamples)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `data` | `const void *` | Pointer to the file data in memory |
| `sizeInBytes` | `std::size_t` | Size of the data to load, in bytes |

---

{#loadfromstream}

### loadFromStream

`nodiscard`

```cpp
[[nodiscard]] bool loadFromStream(InputStream & stream)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundBuffer.hpp:192

Load the sound buffer from a custom stream.

See the documentation of `[sf::InputSoundFile](sf-InputSoundFile.md#inputsoundfile)` for the list of supported formats.

#### Returns
`true` if loading succeeded, `false` if it failed

**See also**: `[loadFromFile](#loadfromfile)`, `[loadFromMemory](#loadfrommemory)`, `[loadFromSamples](#loadfromsamples)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `stream` | [`InputStream`](sf-InputStream.md#inputstream) & | Source stream to read from |

---

{#loadfromsamples}

### loadFromSamples

`nodiscard`

```cpp
[[nodiscard]] bool loadFromSamples(const std::int16_t * samples, std::uint64_t sampleCount, unsigned int channelCount, unsigned int sampleRate, const std::vector< SoundChannel > & channelMap)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundBuffer.hpp:210

Load the sound buffer from an array of audio samples.

The assumed format of the audio samples is 16 bit signed integer.

#### Returns
`true` if loading succeeded, `false` if it failed

**See also**: `[loadFromFile](#loadfromfile)`, `[loadFromMemory](#loadfrommemory)`, `[saveToFile](#savetofile)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `samples` | `const std::int16_t *` | Pointer to the array of samples in memory |
| `sampleCount` | `std::uint64_t` | Number of samples in the array |
| `channelCount` | `unsigned int` | Number of channels (1 = mono, 2 = stereo, ...) |
| `sampleRate` | `unsigned int` | Sample rate (number of samples to play per second) |
| `channelMap` | const std::vector< [`SoundChannel`](SoundChannel.md#soundchannel) > & | Map of position in sample frame to sound channel |

---

{#savetofile}

### saveToFile

`const` `nodiscard`

```cpp
[[nodiscard]] bool saveToFile(const std::filesystem::path & filename) const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundBuffer.hpp:227

Save the sound buffer to an audio file.

See the documentation of `[sf::OutputSoundFile](sf-OutputSoundFile.md#outputsoundfile)` for the list of supported formats.

#### Returns
`true` if saving succeeded, `false` if it failed

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `filename` | `const std::filesystem::path &` | Path of the sound file to write |

---

{#getsamples}

### getSamples

`const` `nodiscard`

```cpp
[[nodiscard]] const std::int16_t * getSamples() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundBuffer.hpp:241

Get the array of audio samples stored in the buffer.

The format of the returned samples is 16 bit signed integer. The total number of samples in this array is given by the `[getSampleCount()](#getsamplecount-1)` function.

#### Returns
Read-only pointer to the array of sound samples

**See also**: `[getSampleCount](#getsamplecount-1)`

---

{#getsamplecount-1}

### getSampleCount

`const` `nodiscard`

```cpp
[[nodiscard]] std::uint64_t getSampleCount() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundBuffer.hpp:254

Get the number of samples stored in the buffer.

The array of samples can be accessed with the `[getSamples()](#getsamples)` function.

#### Returns
Number of samples

**See also**: `[getSamples](#getsamples)`

---

{#getsamplerate-1}

### getSampleRate

`const` `nodiscard`

```cpp
[[nodiscard]] unsigned int getSampleRate() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundBuffer.hpp:268

Get the sample rate of the sound.

The sample rate is the number of samples played per second. The higher, the better the quality (for example, 44100 samples/s is CD quality).

#### Returns
Sample rate (number of samples per second)

**See also**: `[getChannelCount](#getchannelcount-1)`, `[getChannelMap](#getchannelmap-1)`, `[getDuration](#getduration-2)`

---

{#getchannelcount-1}

### getChannelCount

`const` `nodiscard`

```cpp
[[nodiscard]] unsigned int getChannelCount() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundBuffer.hpp:281

Get the number of channels used by the sound.

If the sound is mono then the number of channels will be 1, 2 for stereo, etc.

#### Returns
Number of channels

**See also**: `[getSampleRate](#getsamplerate-1)`, `[getChannelMap](#getchannelmap-1)`, `[getDuration](#getduration-2)`

---

{#getchannelmap-1}

### getChannelMap

`const` `nodiscard`

```cpp
[[nodiscard]] const std::vector< SoundChannel > & getChannelMap() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundBuffer.hpp:294

Get the map of position in sample frame to sound channel.

This is used to map a sample in the sample stream to a position during spatialization.

#### Returns
Map of position in sample frame to sound channel

**See also**: `[getSampleRate](#getsamplerate-1)`, `[getChannelCount](#getchannelcount-1)`, `[getDuration](#getduration-2)`

---

{#getduration-2}

### getDuration

`const` `nodiscard`

```cpp
[[nodiscard]] Time getDuration() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundBuffer.hpp:304

Get the total duration of the sound.

#### Returns
[Sound](sf-Sound.md#sound) duration

**See also**: `[getSampleRate](#getsamplerate-1)`, `[getChannelCount](#getchannelcount-1)`, `[getChannelMap](#getchannelmap-1)`

---

{#operator-5}

### operator=

```cpp
SoundBuffer & operator=(const SoundBuffer & right)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundBuffer.hpp:314

Overload of assignment operator.

#### Returns
Reference to self

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `right` | const [`SoundBuffer`](#soundbuffer-1) & | Instance to assign |

## Private Attributes

| Return | Name | Description |
|--------|------|-------------|
| `std::vector< std::int16_t >` | [`m_samples`](#m_samples)  | Samples buffer. |
| `unsigned int` | [`m_sampleRate`](#m_samplerate-1)  | Number of samples per second. |
| std::vector< [`SoundChannel`](SoundChannel.md#soundchannel) > | [`m_channelMap`](#m_channelmap-1)  | The map of position in sample frame to sound channel. |
| [`Time`](sf-Time.md#time) | [`m_duration`](#m_duration)  | [Sound](sf-Sound.md#sound) duration. |
| `SoundList` | [`m_sounds`](#m_sounds)  | List of sounds that are using this buffer. |

---

{#m_samples}

### m_samples

```cpp
std::vector< std::int16_t > m_samples
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundBuffer.hpp:365

Samples buffer.

---

{#m_samplerate-1}

### m_sampleRate

```cpp
unsigned int m_sampleRate {44100}
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundBuffer.hpp:366

Number of samples per second.

---

{#m_channelmap-1}

### m_channelMap

```cpp
std::vector< SoundChannel > m_channelMap {SoundChannel::Mono}
```

Type: std::vector< [`SoundChannel`](SoundChannel.md#soundchannel) >

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundBuffer.hpp:367

The map of position in sample frame to sound channel.

---

{#m_duration}

### m_duration

```cpp
Time m_duration
```

Type: [`Time`](sf-Time.md#time)

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundBuffer.hpp:368

[Sound](sf-Sound.md#sound) duration.

---

{#m_sounds}

### m_sounds

```cpp
SoundList m_sounds
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundBuffer.hpp:369

List of sounds that are using this buffer.

## Private Methods

| Return | Name | Description |
|--------|------|-------------|
| `bool` | [`initialize`](#initialize) `nodiscard` | Initialize the internal state after loading a new sound. |
| `bool` | [`update`](#update) `nodiscard` | Update the internal buffer with the cached audio samples. |
| `void` | [`attachSound`](#attachsound) `const` | Add a sound to the list of sounds that use this buffer. |
| `void` | [`detachSound`](#detachsound) `const` | Remove a sound from the list of sounds that use this buffer. |

---

{#initialize}

### initialize

`nodiscard`

```cpp
[[nodiscard]] bool initialize(InputSoundFile & file)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundBuffer.hpp:327

Initialize the internal state after loading a new sound.

#### Returns
`true` on successful initialization, `false` on failure

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `file` | [`InputSoundFile`](sf-InputSoundFile.md#inputsoundfile) & | [Sound](sf-Sound.md#sound) file providing access to the new loaded sound |

---

{#update}

### update

`nodiscard`

```cpp
[[nodiscard]] bool update(unsigned int channelCount, unsigned int sampleRate, const std::vector< SoundChannel > & channelMap)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundBuffer.hpp:339

Update the internal buffer with the cached audio samples.

#### Returns
`true` on success, `false` if any error happened

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `channelCount` | `unsigned int` | Number of channels |
| `sampleRate` | `unsigned int` | Sample rate (number of samples per second) |
| `channelMap` | const std::vector< [`SoundChannel`](SoundChannel.md#soundchannel) > & | Map of position in sample frame to sound channel |

---

{#attachsound}

### attachSound

`const`

```cpp
void attachSound(Sound * sound) const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundBuffer.hpp:347

Add a sound to the list of sounds that use this buffer.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `sound` | [`Sound`](sf-Sound.md#sound) * | [Sound](sf-Sound.md#sound) instance to attach |

---

{#detachsound}

### detachSound

`const`

```cpp
void detachSound(Sound * sound) const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundBuffer.hpp:355

Remove a sound from the list of sounds that use this buffer.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `sound` | [`Sound`](sf-Sound.md#sound) * | [Sound](sf-Sound.md#sound) instance to detach |

