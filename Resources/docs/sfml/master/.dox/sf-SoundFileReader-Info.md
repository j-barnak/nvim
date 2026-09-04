{#info}

# Info

```cpp
#include <SoundFileReader.hpp>
```

```cpp
struct Info
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundFileReader.hpp:55

Structure holding the audio properties of a sound file.

## Public Attributes

| Return | Name | Description |
|--------|------|-------------|
| `std::uint64_t` | [`sampleCount`](#samplecount)  | Total number of samples in the file. |
| `unsigned int` | [`channelCount`](#channelcount)  | Number of channels of the sound. |
| `unsigned int` | [`sampleRate`](#samplerate)  | Samples rate of the sound, in samples per second. |
| std::vector< [`SoundChannel`](SoundChannel.md#soundchannel) > | [`channelMap`](#channelmap)  | Map of position in sample frame to sound channel. |

---

{#samplecount}

### sampleCount

```cpp
std::uint64_t sampleCount {}
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundFileReader.hpp:57

Total number of samples in the file.

---

{#channelcount}

### channelCount

```cpp
unsigned int channelCount {}
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundFileReader.hpp:58

Number of channels of the sound.

---

{#samplerate}

### sampleRate

```cpp
unsigned int sampleRate {}
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundFileReader.hpp:59

Samples rate of the sound, in samples per second.

---

{#channelmap}

### channelMap

```cpp
std::vector< SoundChannel > channelMap
```

Type: std::vector< [`SoundChannel`](SoundChannel.md#soundchannel) >

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundFileReader.hpp:60

Map of position in sample frame to sound channel.

