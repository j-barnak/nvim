{#soundstream}

# SoundStream

```cpp
#include <SoundStream.hpp>
```

```cpp
class SoundStream
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundStream.hpp:51

> **Inherits:** [`SoundSource`](sf-SoundSource.md#soundsource)
> **Subclassed by:** [`Music`](sf-Music.md#music)

Abstract base class for streamed audio sources.

Unlike audio buffers (see `[sf::SoundBuffer](sf-SoundBuffer.md#soundbuffer-1)`), audio streams are never completely loaded in memory. Instead, the audio data is acquired continuously while the stream is playing. This behavior allows to play a sound with no loading delay, and keeps the memory consumption very low.

[Sound](sf-Sound.md#sound) sources that need to be streamed are usually big files (compressed audio musics that would eat hundreds of MB in memory) or files that would take a lot of time to be received (sounds played over the network).

`[sf::SoundStream](#soundstream)` is a base class that doesn't care about the stream source, which is left to the derived class. SFML provides a built-in specialization for big files (see `[sf::Music](sf-Music.md#music)`). No network stream source is provided, but you can write your own by combining this class with the network module.

A derived class has to override two virtual functions: 

* `onGetData` fills a new chunk of audio data to be played 
* `onSeek` changes the current playing position in the source

It is important to note that each [SoundStream](#soundstream) is played in its own separate thread, so that the streaming loop doesn't block the rest of the program. In particular, the `onGetData` and `onSeek` virtual functions may sometimes be called from this separate thread. It is important to keep this in mind, because you may have to take care of synchronization issues if you share data between threads.

Usage example: 
```cpp
class CustomStream : public sf::SoundStream
{
public:

    [[nodiscard]] bool open(const std::string& location)
    {
        // Open the source and get audio settings
        ...
        unsigned int channelCount = 2; // Stereo
        unsigned int sampleRate = 44100; // 44100 Hz

        // Initialize the stream -- important!
        initialize(channelCount, sampleRate, {sf::SoundChannel::FrontLeft, sf::SoundChannel::FrontRight});
        return true;
    }

private:

    bool onGetData(Chunk& data) override
    {
        // Fill the chunk with audio data from the stream source
        // (note: must not be empty if you want to continue playing)
        data.samples = ...;

        // Return true to continue playing
        data.sampleCount = ...;
        return true;
    }

    void onSeek(sf::Time timeOffset) override
    {
        // Change the current position in the stream source
        ...
    }
};

// Usage
CustomStream stream;
stream.open("path/to/stream");
stream.play();
```

**See also**: `[sf::Music](sf-Music.md#music)`

## List of all members

| Name | Kind | Owner |
|------|------|-------|
| [`~SoundStream`](#soundstream-1) | `function` | Declared here |
| [`SoundStream`](#soundstream-2) | `function` | Declared here |
| [`operator=`](#operator-8) | `function` | Declared here |
| [`play`](#play-2) | `function` | Declared here |
| [`pause`](#pause-2) | `function` | Declared here |
| [`stop`](#stop-3) | `function` | Declared here |
| [`getChannelCount`](#getchannelcount-3) | `function` | Declared here |
| [`getSampleRate`](#getsamplerate-3) | `function` | Declared here |
| [`getChannelMap`](#getchannelmap-3) | `function` | Declared here |
| [`getStatus`](#getstatus-2) | `function` | Declared here |
| [`setPlayingOffset`](#setplayingoffset-1) | `function` | Declared here |
| [`getPlayingOffset`](#getplayingoffset-1) | `function` | Declared here |
| [`setLooping`](#setlooping-1) | `function` | Declared here |
| [`isLooping`](#islooping-1) | `function` | Declared here |
| [`setEffectProcessor`](#seteffectprocessor-2) | `function` | Declared here |
| [`SoundStream`](#soundstream-3) | `function` | Declared here |
| [`initialize`](#initialize-1) | `function` | Declared here |
| [`onGetData`](#ongetdata-1) | `function` | Declared here |
| [`onSeek`](#onseek-1) | `function` | Declared here |
| [`onLoop`](#onloop-1) | `function` | Declared here |
| [`m_impl`](#m_impl-3) | `variable` | Declared here |
| [`getSound`](#getsound-2) | `function` | Declared here |
| [`SoundSource`](sf-SoundSource.md#soundsource-1) | `function` | Inherited from [`SoundSource`](sf-SoundSource.md#soundsource) |
| [`SoundSource`](sf-SoundSource.md#soundsource-2) | `function` | Inherited from [`SoundSource`](sf-SoundSource.md#soundsource) |
| [`operator=`](sf-SoundSource.md#operator-6) | `function` | Inherited from [`SoundSource`](sf-SoundSource.md#soundsource) |
| [`~SoundSource`](sf-SoundSource.md#soundsource-3) | `function` | Inherited from [`SoundSource`](sf-SoundSource.md#soundsource) |
| [`setPitch`](sf-SoundSource.md#setpitch) | `function` | Inherited from [`SoundSource`](sf-SoundSource.md#soundsource) |
| [`setPan`](sf-SoundSource.md#setpan) | `function` | Inherited from [`SoundSource`](sf-SoundSource.md#soundsource) |
| [`setVolume`](sf-SoundSource.md#setvolume) | `function` | Inherited from [`SoundSource`](sf-SoundSource.md#soundsource) |
| [`setSpatializationEnabled`](sf-SoundSource.md#setspatializationenabled) | `function` | Inherited from [`SoundSource`](sf-SoundSource.md#soundsource) |
| [`setPosition`](sf-SoundSource.md#setposition) | `function` | Inherited from [`SoundSource`](sf-SoundSource.md#soundsource) |
| [`setDirection`](sf-SoundSource.md#setdirection) | `function` | Inherited from [`SoundSource`](sf-SoundSource.md#soundsource) |
| [`setCone`](sf-SoundSource.md#setcone) | `function` | Inherited from [`SoundSource`](sf-SoundSource.md#soundsource) |
| [`setVelocity`](sf-SoundSource.md#setvelocity) | `function` | Inherited from [`SoundSource`](sf-SoundSource.md#soundsource) |
| [`setDopplerFactor`](sf-SoundSource.md#setdopplerfactor) | `function` | Inherited from [`SoundSource`](sf-SoundSource.md#soundsource) |
| [`setDirectionalAttenuationFactor`](sf-SoundSource.md#setdirectionalattenuationfactor) | `function` | Inherited from [`SoundSource`](sf-SoundSource.md#soundsource) |
| [`setRelativeToListener`](sf-SoundSource.md#setrelativetolistener) | `function` | Inherited from [`SoundSource`](sf-SoundSource.md#soundsource) |
| [`setMinDistance`](sf-SoundSource.md#setmindistance) | `function` | Inherited from [`SoundSource`](sf-SoundSource.md#soundsource) |
| [`setMaxDistance`](sf-SoundSource.md#setmaxdistance) | `function` | Inherited from [`SoundSource`](sf-SoundSource.md#soundsource) |
| [`setMinGain`](sf-SoundSource.md#setmingain) | `function` | Inherited from [`SoundSource`](sf-SoundSource.md#soundsource) |
| [`setMaxGain`](sf-SoundSource.md#setmaxgain) | `function` | Inherited from [`SoundSource`](sf-SoundSource.md#soundsource) |
| [`setAttenuation`](sf-SoundSource.md#setattenuation) | `function` | Inherited from [`SoundSource`](sf-SoundSource.md#soundsource) |
| [`setEffectProcessor`](sf-SoundSource.md#seteffectprocessor-1) | `function` | Inherited from [`SoundSource`](sf-SoundSource.md#soundsource) |
| [`getPitch`](sf-SoundSource.md#getpitch) | `function` | Inherited from [`SoundSource`](sf-SoundSource.md#soundsource) |
| [`getPan`](sf-SoundSource.md#getpan) | `function` | Inherited from [`SoundSource`](sf-SoundSource.md#soundsource) |
| [`getVolume`](sf-SoundSource.md#getvolume) | `function` | Inherited from [`SoundSource`](sf-SoundSource.md#soundsource) |
| [`isSpatializationEnabled`](sf-SoundSource.md#isspatializationenabled) | `function` | Inherited from [`SoundSource`](sf-SoundSource.md#soundsource) |
| [`getPosition`](sf-SoundSource.md#getposition) | `function` | Inherited from [`SoundSource`](sf-SoundSource.md#soundsource) |
| [`getDirection`](sf-SoundSource.md#getdirection) | `function` | Inherited from [`SoundSource`](sf-SoundSource.md#soundsource) |
| [`getCone`](sf-SoundSource.md#getcone) | `function` | Inherited from [`SoundSource`](sf-SoundSource.md#soundsource) |
| [`getVelocity`](sf-SoundSource.md#getvelocity) | `function` | Inherited from [`SoundSource`](sf-SoundSource.md#soundsource) |
| [`getDopplerFactor`](sf-SoundSource.md#getdopplerfactor) | `function` | Inherited from [`SoundSource`](sf-SoundSource.md#soundsource) |
| [`getDirectionalAttenuationFactor`](sf-SoundSource.md#getdirectionalattenuationfactor) | `function` | Inherited from [`SoundSource`](sf-SoundSource.md#soundsource) |
| [`isRelativeToListener`](sf-SoundSource.md#isrelativetolistener) | `function` | Inherited from [`SoundSource`](sf-SoundSource.md#soundsource) |
| [`getMinDistance`](sf-SoundSource.md#getmindistance) | `function` | Inherited from [`SoundSource`](sf-SoundSource.md#soundsource) |
| [`getMaxDistance`](sf-SoundSource.md#getmaxdistance) | `function` | Inherited from [`SoundSource`](sf-SoundSource.md#soundsource) |
| [`getMinGain`](sf-SoundSource.md#getmingain) | `function` | Inherited from [`SoundSource`](sf-SoundSource.md#soundsource) |
| [`getMaxGain`](sf-SoundSource.md#getmaxgain) | `function` | Inherited from [`SoundSource`](sf-SoundSource.md#soundsource) |
| [`getAttenuation`](sf-SoundSource.md#getattenuation) | `function` | Inherited from [`SoundSource`](sf-SoundSource.md#soundsource) |
| [`operator=`](sf-SoundSource.md#operator-7) | `function` | Inherited from [`SoundSource`](sf-SoundSource.md#soundsource) |
| [`play`](sf-SoundSource.md#play-1) | `function` | Inherited from [`SoundSource`](sf-SoundSource.md#soundsource) |
| [`pause`](sf-SoundSource.md#pause-1) | `function` | Inherited from [`SoundSource`](sf-SoundSource.md#soundsource) |
| [`stop`](sf-SoundSource.md#stop-2) | `function` | Inherited from [`SoundSource`](sf-SoundSource.md#soundsource) |
| [`getStatus`](sf-SoundSource.md#getstatus-1) | `function` | Inherited from [`SoundSource`](sf-SoundSource.md#soundsource) |
| [`SoundSource`](sf-SoundSource.md#soundsource-4) | `function` | Inherited from [`SoundSource`](sf-SoundSource.md#soundsource) |
| [`Status`](Status.md#status) | `enum` | Inherited from [`SoundSource`](sf-SoundSource.md#soundsource) |
| [`EffectProcessor`](sf-SoundSource.md#effectprocessor) | `typedef` | Inherited from [`SoundSource`](sf-SoundSource.md#soundsource) |
| [`getSound`](sf-SoundSource.md#getsound-1) | `function` | Inherited from [`SoundSource`](sf-SoundSource.md#soundsource) |
| [`AudioResource`](sf-AudioResource.md#audioresource-1) | `function` | Inherited from [`AudioResource`](sf-AudioResource.md#audioresource) |
| [`operator=`](sf-AudioResource.md#operator) | `function` | Inherited from [`AudioResource`](sf-AudioResource.md#audioresource) |
| [`AudioResource`](sf-AudioResource.md#audioresource-2) | `function` | Inherited from [`AudioResource`](sf-AudioResource.md#audioresource) |
| [`operator=`](sf-AudioResource.md#operator-1) | `function` | Inherited from [`AudioResource`](sf-AudioResource.md#audioresource) |
| [`AudioResource`](sf-AudioResource.md#audioresource-3) | `function` | Inherited from [`AudioResource`](sf-AudioResource.md#audioresource) |
| [`m_device`](sf-AudioResource.md#m_device) | `variable` | Inherited from [`AudioResource`](sf-AudioResource.md#audioresource) |

## Inherited from [`SoundSource`](sf-SoundSource.md#soundsource)

| Kind | Name | Description |
|------|------|-------------|
| `function` | [`SoundSource`](sf-SoundSource.md#soundsource-1)  | Copy constructor. |
| `function` | [`SoundSource`](sf-SoundSource.md#soundsource-2) `noexcept` | Move constructor. |
| `function` | [`operator=`](sf-SoundSource.md#operator-6) `noexcept` | Move assignment. |
| `function` | [`~SoundSource`](sf-SoundSource.md#soundsource-3) `virtual` | Destructor. |
| `function` | [`setPitch`](sf-SoundSource.md#setpitch)  | Set the pitch of the sound. |
| `function` | [`setPan`](sf-SoundSource.md#setpan)  | Set the pan of the sound. |
| `function` | [`setVolume`](sf-SoundSource.md#setvolume)  | Set the volume of the sound. |
| `function` | [`setSpatializationEnabled`](sf-SoundSource.md#setspatializationenabled)  | Set whether spatialization of the sound is enabled. |
| `function` | [`setPosition`](sf-SoundSource.md#setposition)  | Set the 3D position of the sound in the audio scene. |
| `function` | [`setDirection`](sf-SoundSource.md#setdirection)  | Set the 3D direction of the sound in the audio scene. |
| `function` | [`setCone`](sf-SoundSource.md#setcone)  | Set the cone properties of the sound in the audio scene. |
| `function` | [`setVelocity`](sf-SoundSource.md#setvelocity)  | Set the 3D velocity of the sound in the audio scene. |
| `function` | [`setDopplerFactor`](sf-SoundSource.md#setdopplerfactor)  | Set the doppler factor of the sound. |
| `function` | [`setDirectionalAttenuationFactor`](sf-SoundSource.md#setdirectionalattenuationfactor)  | Set the directional attenuation factor of the sound. |
| `function` | [`setRelativeToListener`](sf-SoundSource.md#setrelativetolistener)  | Make the sound's position relative to the listener or absolute. |
| `function` | [`setMinDistance`](sf-SoundSource.md#setmindistance)  | Set the minimum distance of the sound. |
| `function` | [`setMaxDistance`](sf-SoundSource.md#setmaxdistance)  | Set the maximum distance of the sound. |
| `function` | [`setMinGain`](sf-SoundSource.md#setmingain)  | Set the minimum gain of the sound. |
| `function` | [`setMaxGain`](sf-SoundSource.md#setmaxgain)  | Set the maximum gain of the sound. |
| `function` | [`setAttenuation`](sf-SoundSource.md#setattenuation)  | Set the attenuation factor of the sound. |
| `function` | [`setEffectProcessor`](sf-SoundSource.md#seteffectprocessor-1) `virtual` | Set the effect processor to be applied to the sound. |
| `function` | [`getPitch`](sf-SoundSource.md#getpitch) `const` `nodiscard` | Get the pitch of the sound. |
| `function` | [`getPan`](sf-SoundSource.md#getpan) `const` `nodiscard` | Get the pan of the sound. |
| `function` | [`getVolume`](sf-SoundSource.md#getvolume) `const` `nodiscard` | Get the volume of the sound. |
| `function` | [`isSpatializationEnabled`](sf-SoundSource.md#isspatializationenabled) `const` `nodiscard` | Tell whether spatialization of the sound is enabled. |
| `function` | [`getPosition`](sf-SoundSource.md#getposition) `const` `nodiscard` | Get the 3D position of the sound in the audio scene. |
| `function` | [`getDirection`](sf-SoundSource.md#getdirection) `const` `nodiscard` | Get the 3D direction of the sound in the audio scene. |
| `function` | [`getCone`](sf-SoundSource.md#getcone) `const` `nodiscard` | Get the cone properties of the sound in the audio scene. |
| `function` | [`getVelocity`](sf-SoundSource.md#getvelocity) `const` `nodiscard` | Get the 3D velocity of the sound in the audio scene. |
| `function` | [`getDopplerFactor`](sf-SoundSource.md#getdopplerfactor) `const` `nodiscard` | Get the doppler factor of the sound. |
| `function` | [`getDirectionalAttenuationFactor`](sf-SoundSource.md#getdirectionalattenuationfactor) `const` `nodiscard` | Get the directional attenuation factor of the sound. |
| `function` | [`isRelativeToListener`](sf-SoundSource.md#isrelativetolistener) `const` `nodiscard` | Tell whether the sound's position is relative to the listener or is absolute. |
| `function` | [`getMinDistance`](sf-SoundSource.md#getmindistance) `const` `nodiscard` | Get the minimum distance of the sound. |
| `function` | [`getMaxDistance`](sf-SoundSource.md#getmaxdistance) `const` `nodiscard` | Get the maximum distance of the sound. |
| `function` | [`getMinGain`](sf-SoundSource.md#getmingain) `const` `nodiscard` | Get the minimum gain of the sound. |
| `function` | [`getMaxGain`](sf-SoundSource.md#getmaxgain) `const` `nodiscard` | Get the maximum gain of the sound. |
| `function` | [`getAttenuation`](sf-SoundSource.md#getattenuation) `const` `nodiscard` | Get the attenuation factor of the sound. |
| `function` | [`operator=`](sf-SoundSource.md#operator-7)  | Overload of assignment operator. |
| `function` | [`play`](sf-SoundSource.md#play-1) `virtual` | Start or resume playing the sound source. |
| `function` | [`pause`](sf-SoundSource.md#pause-1) `virtual` | Pause the sound source. |
| `function` | [`stop`](sf-SoundSource.md#stop-2) `virtual` | Stop playing the sound source. |
| `function` | [`getStatus`](sf-SoundSource.md#getstatus-1) `virtual` `const` `nodiscard` | Get the current status of the sound (stopped, paused, playing) |
| `function` | [`SoundSource`](sf-SoundSource.md#soundsource-4)  | Default constructor. |
| `enum` | [`Status`](Status.md#status)  | Enumeration of the sound source states. |
| `typedef` | [`EffectProcessor`](sf-SoundSource.md#effectprocessor)  | Callable that is provided with sound data for processing. |
| `function` | [`getSound`](sf-SoundSource.md#getsound-1) `virtual` `const` `nodiscard` | Get the sound object. |

## Inherited from [`AudioResource`](sf-AudioResource.md#audioresource)

| Kind | Name | Description |
|------|------|-------------|
| `function` | [`AudioResource`](sf-AudioResource.md#audioresource-1)  | Copy constructor. |
| `function` | [`operator=`](sf-AudioResource.md#operator)  | Copy assignment. |
| `function` | [`AudioResource`](sf-AudioResource.md#audioresource-2) `noexcept` | Move constructor. |
| `function` | [`operator=`](sf-AudioResource.md#operator-1) `noexcept` | Move assignment. |
| `function` | [`AudioResource`](sf-AudioResource.md#audioresource-3)  | Default constructor. |
| `variable` | [`m_device`](sf-AudioResource.md#m_device)  | [Sound](sf-Sound.md#sound) device. |

## Public Methods

| Return | Name | Description |
|--------|------|-------------|
|  | [`~SoundStream`](#soundstream-1) `override` | Destructor. |
|  | [`SoundStream`](#soundstream-2) `noexcept` | Move constructor. |
| [`SoundStream`](#soundstream) & | [`operator=`](#operator-8) `noexcept` | Move assignment. |
| `void` | [`play`](#play-2) `virtual` `override` | Start or resume playing the audio stream. |
| `void` | [`pause`](#pause-2) `virtual` `override` | Pause the audio stream. |
| `void` | [`stop`](#stop-3) `virtual` `override` | Stop playing the audio stream. |
| `unsigned int` | [`getChannelCount`](#getchannelcount-3) `const` `nodiscard` | Return the number of channels of the stream. |
| `unsigned int` | [`getSampleRate`](#getsamplerate-3) `const` `nodiscard` | Get the stream sample rate of the stream. |
| const std::vector< [`SoundChannel`](SoundChannel.md#soundchannel) > & | [`getChannelMap`](#getchannelmap-3) `const` `nodiscard` | Get the map of position in sample frame to sound channel. |
| [`Status`](Status.md#status) | [`getStatus`](#getstatus-2) `virtual` `const` `nodiscard` `override` | Get the current status of the stream (stopped, paused, playing) |
| `void` | [`setPlayingOffset`](#setplayingoffset-1)  | Change the current playing position of the stream. |
| [`Time`](sf-Time.md#time) | [`getPlayingOffset`](#getplayingoffset-1) `const` `nodiscard` | Get the current playing position of the stream. |
| `void` | [`setLooping`](#setlooping-1)  | Set whether or not the stream should loop after reaching the end. |
| `bool` | [`isLooping`](#islooping-1) `const` `nodiscard` | Tell whether or not the stream is in loop mode. |
| `void` | [`setEffectProcessor`](#seteffectprocessor-2) `virtual` `override` | Set the effect processor to be applied to the sound. |

---

{#soundstream-1}

### ~SoundStream

`override`

```cpp
~SoundStream() override
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundStream.hpp:68

Destructor.

---

{#soundstream-2}

### SoundStream

`noexcept`

```cpp
SoundStream(SoundStream &&) noexcept
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundStream.hpp:74

Move constructor.

---

{#operator-8}

### operator=

`noexcept`

```cpp
SoundStream & operator=(SoundStream &&) noexcept
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundStream.hpp:80

Move assignment.

---

{#play-2}

### play

`virtual` `override`

```cpp
virtual void play() override
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundStream.hpp:94

Start or resume playing the audio stream.

This function starts the stream if it was stopped, resumes it if it was paused, and restarts it from the beginning if it was already playing. This function uses its own thread so that it doesn't block the rest of the program while the stream is played.

**See also**: `[pause](#pause-2)`, `[stop](#stop-3)`

#### Reimplements

- [`play`](sf-SoundSource.md#play-1)

---

{#pause-2}

### pause

`virtual` `override`

```cpp
virtual void pause() override
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundStream.hpp:105

Pause the audio stream.

This function pauses the stream if it was playing, otherwise (stream already paused or stopped) it has no effect.

**See also**: `[play](#play-2)`, `[stop](#stop-3)`

#### Reimplements

- [`pause`](sf-SoundSource.md#pause-1)

---

{#stop-3}

### stop

`virtual` `override`

```cpp
virtual void stop() override
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundStream.hpp:117

Stop playing the audio stream.

This function stops the stream if it was playing or paused, and does nothing if it was already stopped. It also resets the playing position (unlike `[pause()](#pause-2)`).

**See also**: `[play](#play-2)`, `[pause](#pause-2)`

#### Reimplements

- [`stop`](sf-SoundSource.md#stop-2)

---

{#getchannelcount-3}

### getChannelCount

`const` `nodiscard`

```cpp
[[nodiscard]] unsigned int getChannelCount() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundStream.hpp:127

Return the number of channels of the stream.

1 channel means a mono sound, 2 means stereo, etc.

#### Returns
Number of channels

---

{#getsamplerate-3}

### getSampleRate

`const` `nodiscard`

```cpp
[[nodiscard]] unsigned int getSampleRate() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundStream.hpp:138

Get the stream sample rate of the stream.

The sample rate is the number of audio samples played per second. The higher, the better the quality.

#### Returns
Sample rate, in number of samples per second

---

{#getchannelmap-3}

### getChannelMap

`const` `nodiscard`

```cpp
[[nodiscard]] const std::vector< SoundChannel > & getChannelMap() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundStream.hpp:149

Get the map of position in sample frame to sound channel.

This is used to map a sample in the sample stream to a position during spatialization.

#### Returns
Map of position in sample frame to sound channel

---

{#getstatus-2}

### getStatus

`virtual` `const` `nodiscard` `override`

```cpp
[[nodiscard]] virtual Status getStatus() const override
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundStream.hpp:157

Get the current status of the stream (stopped, paused, playing)

#### Returns
Current status

#### Reimplements

- [`getStatus`](sf-SoundSource.md#getstatus-1)

---

{#setplayingoffset-1}

### setPlayingOffset

```cpp
void setPlayingOffset(Time timeOffset)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundStream.hpp:172

Change the current playing position of the stream.

The playing position can be changed when the stream is either paused or playing. Changing the playing position when the stream is stopped has no effect, since playing the stream would reset its position.

**See also**: `[getPlayingOffset](#getplayingoffset-1)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `timeOffset` | [`Time`](sf-Time.md#time) | New playing position, from the beginning of the stream |

---

{#getplayingoffset-1}

### getPlayingOffset

`const` `nodiscard`

```cpp
[[nodiscard]] Time getPlayingOffset() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundStream.hpp:182

Get the current playing position of the stream.

#### Returns
Current playing position, from the beginning of the stream

**See also**: `[setPlayingOffset](#setplayingoffset-1)`

---

{#setlooping-1}

### setLooping

```cpp
void setLooping(bool loop)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundStream.hpp:197

Set whether or not the stream should loop after reaching the end.

If set, the stream will restart from beginning after reaching the end and so on, until it is stopped or `setLooping(false)` is called. The default looping state for streams is `false`.

**See also**: `[isLooping](#islooping-1)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `loop` | `bool` | `true` to play in loop, `false` to play once |

---

{#islooping-1}

### isLooping

`const` `nodiscard`

```cpp
[[nodiscard]] bool isLooping() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundStream.hpp:207

Tell whether or not the stream is in loop mode.

#### Returns
`true` if the stream is looping, `false` otherwise

**See also**: `[setLooping](#setlooping-1)`

---

{#seteffectprocessor-2}

### setEffectProcessor

`virtual` `override`

```cpp
virtual void setEffectProcessor(EffectProcessor effectProcessor) override
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundStream.hpp:218

Set the effect processor to be applied to the sound.

The effect processor is a callable that will be called with sound data to be processed.

#### Reimplements

- [`setEffectProcessor`](sf-SoundSource.md#seteffectprocessor-1)

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `effectProcessor` | [`EffectProcessor`](sf-SoundSource.md#effectprocessor) | The effect processor to attach to this sound, attach an empty processor to disable processing |

## Protected Methods

| Return | Name | Description |
|--------|------|-------------|
|  | [`SoundStream`](#soundstream-3)  | Default constructor. |
| `void` | [`initialize`](#initialize-1)  | Define the audio stream parameters. |
| `bool` | [`onGetData`](#ongetdata-1) `virtual` `nodiscard` | Request a new chunk of audio samples from the stream source. |
| `void` | [`onSeek`](#onseek-1) `virtual` | Change the current playing position in the stream source. |
| `std::optional< std::uint64_t >` | [`onLoop`](#onloop-1) `virtual` | Change the current playing position in the stream source to the beginning of the loop. |

---

{#soundstream-3}

### SoundStream

```cpp
SoundStream()
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundStream.hpp:227

Default constructor.

This constructor is only meant to be called by derived classes.

---

{#initialize-1}

### initialize

```cpp
void initialize(unsigned int channelCount, unsigned int sampleRate, const std::vector< SoundChannel > & channelMap)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundStream.hpp:244

Define the audio stream parameters.

This function must be called by derived classes as soon as they know the audio settings of the stream to play. Any attempt to manipulate the stream (`[play()](#play-2)`, ...) before calling this function will fail. It can be called multiple times if the settings of the audio stream change, but only when the stream is stopped.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `channelCount` | `unsigned int` | Number of channels of the stream |
| `sampleRate` | `unsigned int` | Sample rate, in samples per second |
| `channelMap` | const std::vector< [`SoundChannel`](SoundChannel.md#soundchannel) > & | Map of position in sample frame to sound channel |

---

{#ongetdata-1}

### onGetData

`virtual` `nodiscard`

```cpp
[[nodiscard]] virtual bool onGetData(Chunk & data)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundStream.hpp:263

Request a new chunk of audio samples from the stream source.

This function must be overridden by derived classes to provide the audio samples to play. It is called continuously by the streaming loop, in a separate thread. The source can choose to stop the streaming loop at any time, by returning `false` to the caller. If you return `true` (i.e. continue streaming) it is important that the returned array of samples is not empty; this would stop the stream due to an internal limitation.

#### Returns
`true` to continue playback, `false` to stop

#### Reimplemented by

- [`onGetData`](sf-Music.md#ongetdata)

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `data` | [`Chunk`](sf-SoundStream-Chunk.md#chunk) & | [Chunk](sf-SoundStream-Chunk.md#chunk) of data to fill |

---

{#onseek-1}

### onSeek

`virtual`

```cpp
virtual void onSeek(Time timeOffset)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundStream.hpp:274

Change the current playing position in the stream source.

This function must be overridden by derived classes to allow random seeking into the stream source.

#### Reimplemented by

- [`onSeek`](sf-Music.md#onseek)

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `timeOffset` | [`Time`](sf-Time.md#time) | New playing position, relative to the beginning of the stream |

---

{#onloop-1}

### onLoop

`virtual`

```cpp
virtual std::optional< std::uint64_t > onLoop()
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundStream.hpp:286

Change the current playing position in the stream source to the beginning of the loop.

This function can be overridden by derived classes to allow implementation of custom loop points. Otherwise, it just calls `onSeek(Time::Zero)` and returns 0.

#### Returns
The seek position after looping (or `std::nullopt` if there's no loop)

#### Reimplemented by

- [`onLoop`](sf-Music.md#onloop)

## Private Attributes

| Return | Name | Description |
|--------|------|-------------|
| `std::unique_ptr< Impl >` | [`m_impl`](#m_impl-3)  | Implementation details. |

---

{#m_impl-3}

### m_impl

```cpp
std::unique_ptr< Impl > m_impl
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundStream.hpp:301

Implementation details.

## Private Methods

| Return | Name | Description |
|--------|------|-------------|
| `void *` | [`getSound`](#getsound-2) `virtual` `const` `nodiscard` `override` | Get the sound object. |

---

{#getsound-2}

### getSound

`virtual` `const` `nodiscard` `override`

```cpp
[[nodiscard]] virtual void * getSound() const override
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundStream.hpp:295

Get the sound object.

#### Returns
The sound object

#### Reimplements

- [`getSound`](sf-SoundSource.md#getsound-1)

