{#music}

# Music

```cpp
#include <Music.hpp>
```

```cpp
class Music
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/Music.hpp:52

> **Inherits:** [`SoundStream`](sf-SoundStream.md#soundstream)

Streamed music played from an audio file.

Musics are sounds that are streamed rather than completely loaded in memory. This is especially useful for compressed musics that usually take hundreds of MB when they are uncompressed: by streaming it instead of loading it entirely, you avoid saturating the memory and have almost no loading delay. This implies that the underlying resource (file, stream or memory buffer) must remain valid for the lifetime of the `[sf::Music](#music)` object.

Apart from that, a `[sf::Music](#music)` has almost the same features as the `[sf::SoundBuffer](sf-SoundBuffer.md#soundbuffer-1)` / `[sf::Sound](sf-Sound.md#sound)` pair: you can play/pause/stop it, request its parameters (channels, sample rate), change the way it is played (pitch, volume, 3D position, ...), etc.

As a sound stream, a music is played in its own thread in order not to block the rest of the program. This means that you can leave the music alone after calling `[play()](sf-SoundStream.md#play-2)`, it will manage itself very well.

Usage example: 
```cpp
// Open a music from an audio file
sf::Music music("music.ogg");

// Change some parameters
music.setPosition({0, 1, 10}); // change its 3D position
music.setPitch(2);             // increase the pitch
music.setVolume(50);           // reduce the volume
music.setLooping(true);        // make it loop

// Play it
music.play();
```

**See also**: `[sf::Sound](sf-Sound.md#sound)`, `[sf::SoundStream](sf-SoundStream.md#soundstream)`

## List of all members

| Name | Kind | Owner |
|------|------|-------|
| [`Music`](#music-1) | `function` | Declared here |
| [`Music`](#music-2) | `function` | Declared here |
| [`Music`](#music-3) | `function` | Declared here |
| [`Music`](#music-4) | `function` | Declared here |
| [`~Music`](#music-5) | `function` | Declared here |
| [`Music`](#music-6) | `function` | Declared here |
| [`operator=`](#operator-3) | `function` | Declared here |
| [`openFromFile`](#openfromfile-1) | `function` | Declared here |
| [`openFromMemory`](#openfrommemory-1) | `function` | Declared here |
| [`openFromStream`](#openfromstream-1) | `function` | Declared here |
| [`getDuration`](#getduration-1) | `function` | Declared here |
| [`getLoopPoints`](#getlooppoints) | `function` | Declared here |
| [`setLoopPoints`](#setlooppoints) | `function` | Declared here |
| [`onGetData`](#ongetdata) | `function` | Declared here |
| [`onSeek`](#onseek) | `function` | Declared here |
| [`onLoop`](#onloop) | `function` | Declared here |
| [`TimeSpan`](#timespan) | `typedef` | Declared here |
| [`m_impl`](#m_impl) | `variable` | Declared here |
| [`timeToSamples`](#timetosamples) | `function` | Declared here |
| [`samplesToTime`](#samplestotime) | `function` | Declared here |
| [`~SoundStream`](sf-SoundStream.md#soundstream-1) | `function` | Inherited from [`SoundStream`](sf-SoundStream.md#soundstream) |
| [`SoundStream`](sf-SoundStream.md#soundstream-2) | `function` | Inherited from [`SoundStream`](sf-SoundStream.md#soundstream) |
| [`operator=`](sf-SoundStream.md#operator-8) | `function` | Inherited from [`SoundStream`](sf-SoundStream.md#soundstream) |
| [`play`](sf-SoundStream.md#play-2) | `function` | Inherited from [`SoundStream`](sf-SoundStream.md#soundstream) |
| [`pause`](sf-SoundStream.md#pause-2) | `function` | Inherited from [`SoundStream`](sf-SoundStream.md#soundstream) |
| [`stop`](sf-SoundStream.md#stop-3) | `function` | Inherited from [`SoundStream`](sf-SoundStream.md#soundstream) |
| [`getChannelCount`](sf-SoundStream.md#getchannelcount-3) | `function` | Inherited from [`SoundStream`](sf-SoundStream.md#soundstream) |
| [`getSampleRate`](sf-SoundStream.md#getsamplerate-3) | `function` | Inherited from [`SoundStream`](sf-SoundStream.md#soundstream) |
| [`getChannelMap`](sf-SoundStream.md#getchannelmap-3) | `function` | Inherited from [`SoundStream`](sf-SoundStream.md#soundstream) |
| [`getStatus`](sf-SoundStream.md#getstatus-2) | `function` | Inherited from [`SoundStream`](sf-SoundStream.md#soundstream) |
| [`setPlayingOffset`](sf-SoundStream.md#setplayingoffset-1) | `function` | Inherited from [`SoundStream`](sf-SoundStream.md#soundstream) |
| [`getPlayingOffset`](sf-SoundStream.md#getplayingoffset-1) | `function` | Inherited from [`SoundStream`](sf-SoundStream.md#soundstream) |
| [`setLooping`](sf-SoundStream.md#setlooping-1) | `function` | Inherited from [`SoundStream`](sf-SoundStream.md#soundstream) |
| [`isLooping`](sf-SoundStream.md#islooping-1) | `function` | Inherited from [`SoundStream`](sf-SoundStream.md#soundstream) |
| [`setEffectProcessor`](sf-SoundStream.md#seteffectprocessor-2) | `function` | Inherited from [`SoundStream`](sf-SoundStream.md#soundstream) |
| [`SoundStream`](sf-SoundStream.md#soundstream-3) | `function` | Inherited from [`SoundStream`](sf-SoundStream.md#soundstream) |
| [`initialize`](sf-SoundStream.md#initialize-1) | `function` | Inherited from [`SoundStream`](sf-SoundStream.md#soundstream) |
| [`onGetData`](sf-SoundStream.md#ongetdata-1) | `function` | Inherited from [`SoundStream`](sf-SoundStream.md#soundstream) |
| [`onSeek`](sf-SoundStream.md#onseek-1) | `function` | Inherited from [`SoundStream`](sf-SoundStream.md#soundstream) |
| [`onLoop`](sf-SoundStream.md#onloop-1) | `function` | Inherited from [`SoundStream`](sf-SoundStream.md#soundstream) |
| [`m_impl`](sf-SoundStream.md#m_impl-3) | `variable` | Inherited from [`SoundStream`](sf-SoundStream.md#soundstream) |
| [`getSound`](sf-SoundStream.md#getsound-2) | `function` | Inherited from [`SoundStream`](sf-SoundStream.md#soundstream) |
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

## Inherited from [`SoundStream`](sf-SoundStream.md#soundstream)

| Kind | Name | Description |
|------|------|-------------|
| `function` | [`~SoundStream`](sf-SoundStream.md#soundstream-1) `override` | Destructor. |
| `function` | [`SoundStream`](sf-SoundStream.md#soundstream-2) `noexcept` | Move constructor. |
| `function` | [`operator=`](sf-SoundStream.md#operator-8) `noexcept` | Move assignment. |
| `function` | [`play`](sf-SoundStream.md#play-2) `virtual` `override` | Start or resume playing the audio stream. |
| `function` | [`pause`](sf-SoundStream.md#pause-2) `virtual` `override` | Pause the audio stream. |
| `function` | [`stop`](sf-SoundStream.md#stop-3) `virtual` `override` | Stop playing the audio stream. |
| `function` | [`getChannelCount`](sf-SoundStream.md#getchannelcount-3) `const` `nodiscard` | Return the number of channels of the stream. |
| `function` | [`getSampleRate`](sf-SoundStream.md#getsamplerate-3) `const` `nodiscard` | Get the stream sample rate of the stream. |
| `function` | [`getChannelMap`](sf-SoundStream.md#getchannelmap-3) `const` `nodiscard` | Get the map of position in sample frame to sound channel. |
| `function` | [`getStatus`](sf-SoundStream.md#getstatus-2) `virtual` `const` `nodiscard` `override` | Get the current status of the stream (stopped, paused, playing) |
| `function` | [`setPlayingOffset`](sf-SoundStream.md#setplayingoffset-1)  | Change the current playing position of the stream. |
| `function` | [`getPlayingOffset`](sf-SoundStream.md#getplayingoffset-1) `const` `nodiscard` | Get the current playing position of the stream. |
| `function` | [`setLooping`](sf-SoundStream.md#setlooping-1)  | Set whether or not the stream should loop after reaching the end. |
| `function` | [`isLooping`](sf-SoundStream.md#islooping-1) `const` `nodiscard` | Tell whether or not the stream is in loop mode. |
| `function` | [`setEffectProcessor`](sf-SoundStream.md#seteffectprocessor-2) `virtual` `override` | Set the effect processor to be applied to the sound. |
| `function` | [`SoundStream`](sf-SoundStream.md#soundstream-3)  | Default constructor. |
| `function` | [`initialize`](sf-SoundStream.md#initialize-1)  | Define the audio stream parameters. |
| `function` | [`onGetData`](sf-SoundStream.md#ongetdata-1) `virtual` `nodiscard` | Request a new chunk of audio samples from the stream source. |
| `function` | [`onSeek`](sf-SoundStream.md#onseek-1) `virtual` | Change the current playing position in the stream source. |
| `function` | [`onLoop`](sf-SoundStream.md#onloop-1) `virtual` | Change the current playing position in the stream source to the beginning of the loop. |
| `variable` | [`m_impl`](sf-SoundStream.md#m_impl-3)  | Implementation details. |
| `function` | [`getSound`](sf-SoundStream.md#getsound-2) `virtual` `const` `nodiscard` `override` | Get the sound object. |

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
|  | [`Music`](#music-1)  | Default constructor. |
|  | [`Music`](#music-2) `explicit` | Construct a music from an audio file. |
|  | [`Music`](#music-3)  | Construct a music from an audio file in memory. |
|  | [`Music`](#music-4) `explicit` | Construct a music from an audio file in a custom stream. |
|  | [`~Music`](#music-5) `override` | Destructor. |
|  | [`Music`](#music-6) `noexcept` | Move constructor. |
| [`Music`](#music) & | [`operator=`](#operator-3) `noexcept` | Move assignment. |
| `bool` | [`openFromFile`](#openfromfile-1) `nodiscard` | Open a music from an audio file. |
| `bool` | [`openFromMemory`](#openfrommemory-1) `nodiscard` | Open a music from an audio file in memory. |
| `bool` | [`openFromStream`](#openfromstream-1) `nodiscard` | Open a music from an audio file in a custom stream. |
| [`Time`](sf-Time.md#time) | [`getDuration`](#getduration-1) `const` `nodiscard` | Get the total duration of the music. |
| [`TimeSpan`](#timespan) | [`getLoopPoints`](#getlooppoints) `const` `nodiscard` | Get the positions of the of the sound's looping sequence. |
| `void` | [`setLoopPoints`](#setlooppoints)  | Sets the beginning and duration of the sound's looping sequence using `[sf::Time](sf-Time.md#time)` |

---

{#music-1}

### Music

```cpp
Music()
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/Music.hpp:75

Default constructor.

Construct an empty music that does not contain any data.

---

{#music-2}

### Music

`explicit`

```cpp
explicit Music(const std::filesystem::path & filename)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/Music.hpp:96

Construct a music from an audio file.

This function doesn't start playing the music (call `[play()](sf-SoundStream.md#play-2)` to do so). See the documentation of `[sf::InputSoundFile](sf-InputSoundFile.md#inputsoundfile)` for the list of supported formats.

:::warning
Since the music is not loaded at once but rather streamed continuously, the file must remain accessible until the `[sf::Music](#music)` object loads a new music or is destroyed.

:::

**See also**: `[openFromMemory](#openfrommemory-1)`, `[openFromStream](#openfromstream-1)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `filename` | `const std::filesystem::path &` | Path of the music file to open |

#### Exceptions

| Exception | Description |
|-----------|-------------|
| `sf::Exception` | if loading was unsuccessful |

---

{#music-3}

### Music

```cpp
Music(const void * data, std::size_t sizeInBytes)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/Music.hpp:119

Construct a music from an audio file in memory.

This function doesn't start playing the music (call `[play()](sf-SoundStream.md#play-2)` to do so). See the documentation of `[sf::InputSoundFile](sf-InputSoundFile.md#inputsoundfile)` for the list of supported formats.

:::warning
Since the music is not loaded at once but rather streamed continuously, the *data* buffer must remain accessible until the `[sf::Music](#music)` object loads a new music or is destroyed. That is, you can't deallocate the buffer right after calling this function.

:::

**See also**: `[openFromFile](#openfromfile-1)`, `[openFromStream](#openfromstream-1)`

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

{#music-4}

### Music

`explicit`

```cpp
explicit Music(InputStream & stream)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/Music.hpp:140

Construct a music from an audio file in a custom stream.

This function doesn't start playing the music (call `[play()](sf-SoundStream.md#play-2)` to do so). See the documentation of `[sf::InputSoundFile](sf-InputSoundFile.md#inputsoundfile)` for the list of supported formats.

:::warning
Since the music is not loaded at once but rather streamed continuously, the `stream` must remain accessible until the `[sf::Music](#music)` object loads a new music or is destroyed.

:::

**See also**: `[openFromFile](#openfromfile-1)`, `[openFromMemory](#openfrommemory-1)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `stream` | [`InputStream`](sf-InputStream.md#inputstream) & | Source stream to read from |

#### Exceptions

| Exception | Description |
|-----------|-------------|
| `sf::Exception` | if loading was unsuccessful |

---

{#music-5}

### ~Music

`override`

```cpp
~Music() override
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/Music.hpp:146

Destructor.

---

{#music-6}

### Music

`noexcept`

```cpp
Music(Music &&) noexcept
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/Music.hpp:152

Move constructor.

---

{#operator-3}

### operator=

`noexcept`

```cpp
Music & operator=(Music &&) noexcept
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/Music.hpp:158

Move assignment.

---

{#openfromfile-1}

### openFromFile

`nodiscard`

```cpp
[[nodiscard]] bool openFromFile(const std::filesystem::path & filename)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/Music.hpp:179

Open a music from an audio file.

This function doesn't start playing the music (call `[play()](sf-SoundStream.md#play-2)` to do so). See the documentation of `[sf::InputSoundFile](sf-InputSoundFile.md#inputsoundfile)` for the list of supported formats.

:::warning
Since the music is not loaded at once but rather streamed continuously, the file must remain accessible until the `[sf::Music](#music)` object loads a new music or is destroyed.

:::

#### Returns
`true` if loading succeeded, `false` if it failed

**See also**: `[openFromMemory](#openfrommemory-1)`, `[openFromStream](#openfromstream-1)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `filename` | `const std::filesystem::path &` | Path of the music file to open |

---

{#openfrommemory-1}

### openFromMemory

`nodiscard`

```cpp
[[nodiscard]] bool openFromMemory(const void * data, std::size_t sizeInBytes)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/Music.hpp:202

Open a music from an audio file in memory.

This function doesn't start playing the music (call `[play()](sf-SoundStream.md#play-2)` to do so). See the documentation of `[sf::InputSoundFile](sf-InputSoundFile.md#inputsoundfile)` for the list of supported formats.

:::warning
Since the music is not loaded at once but rather streamed continuously, the `data` buffer must remain accessible until the `[sf::Music](#music)` object loads a new music or is destroyed. That is, you can't deallocate the buffer right after calling this function.

:::

#### Returns
`true` if loading succeeded, `false` if it failed

**See also**: `[openFromFile](#openfromfile-1)`, `[openFromStream](#openfromstream-1)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `data` | `const void *` | Pointer to the file data in memory |
| `sizeInBytes` | `std::size_t` | Size of the data to load, in bytes |

---

{#openfromstream-1}

### openFromStream

`nodiscard`

```cpp
[[nodiscard]] bool openFromStream(InputStream & stream)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/Music.hpp:223

Open a music from an audio file in a custom stream.

This function doesn't start playing the music (call `[play()](sf-SoundStream.md#play-2)` to do so). See the documentation of `[sf::InputSoundFile](sf-InputSoundFile.md#inputsoundfile)` for the list of supported formats.

:::warning
Since the music is not loaded at once but rather streamed continuously, the `stream` must remain accessible until the `[sf::Music](#music)` object loads a new music or is destroyed.

:::

#### Returns
`true` if loading succeeded, `false` if it failed

**See also**: `[openFromFile](#openfromfile-1)`, `[openFromMemory](#openfrommemory-1)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `stream` | [`InputStream`](sf-InputStream.md#inputstream) & | Source stream to read from |

---

{#getduration-1}

### getDuration

`const` `nodiscard`

```cpp
[[nodiscard]] Time getDuration() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/Music.hpp:231

Get the total duration of the music.

#### Returns
[Music](#music) duration

---

{#getlooppoints}

### getLoopPoints

`const` `nodiscard`

```cpp
[[nodiscard]] TimeSpan getLoopPoints() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/Music.hpp:248

Get the positions of the of the sound's looping sequence.

#### Returns
Loop [Time](sf-Time.md#time) position class.

:::warning
Since `[setLoopPoints()](#setlooppoints)` performs some adjustments on the provided values and rounds them to internal samples, a call to `[getLoopPoints()](#getlooppoints)` is not guaranteed to return the same times passed into a previous call to `[setLoopPoints()](#setlooppoints)`. However, it is guaranteed to return times that will map to the valid internal samples of this [Music](#music) if they are later passed to `[setLoopPoints()](#setlooppoints)`.

:::

**See also**: `[setLoopPoints](#setlooppoints)`

---

{#setlooppoints}

### setLoopPoints

```cpp
void setLoopPoints(TimeSpan timePoints)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/Music.hpp:270

Sets the beginning and duration of the sound's looping sequence using `[sf::Time](sf-Time.md#time)`

`[setLoopPoints()](#setlooppoints)` allows for specifying the beginning offset and the duration of the loop such that, when the music is enabled for looping, it will seamlessly seek to the beginning whenever it encounters the end of the duration. Valid ranges for `timePoints.offset` and `timePoints.length` are [0, Dur) and (0, Dur-offset] respectively, where Dur is the value returned by `[getDuration()](#getduration-1)`. Note that the EOF "loop point" from the end to the beginning of the stream is still honored, in case the caller seeks to a point after the end of the loop range. This function can be safely called at any point after a stream is opened, and will be applied to a playing sound without affecting the current playing offset.

:::warning
Setting the loop points while the stream's status is Paused will set its status to Stopped. The playing offset will be unaffected.

:::

**See also**: `[getLoopPoints](#getlooppoints)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `timePoints` | [`TimeSpan`](#timespan) | The definition of the loop. Can be any time points within the sound's length |

## Protected Methods

| Return | Name | Description |
|--------|------|-------------|
| `bool` | [`onGetData`](#ongetdata) `virtual` `nodiscard` `override` | Request a new chunk of audio samples from the stream source. |
| `void` | [`onSeek`](#onseek) `virtual` `override` | Change the current playing position in the stream source. |
| `std::optional< std::uint64_t >` | [`onLoop`](#onloop) `virtual` `override` | Change the current playing position in the stream source to the loop offset. |

---

{#ongetdata}

### onGetData

`virtual` `nodiscard` `override`

```cpp
[[nodiscard]] virtual bool onGetData(Chunk & data) override
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/Music.hpp:284

Request a new chunk of audio samples from the stream source.

This function fills the chunk from the next samples to read from the audio file.

#### Returns
`true` to continue playback, `false` to stop

#### Reimplements

- [`onGetData`](sf-SoundStream.md#ongetdata-1)

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `data` | [`Chunk`](sf-SoundStream-Chunk.md#chunk) & | [Chunk](sf-SoundStream-Chunk.md#chunk) of data to fill |

---

{#onseek}

### onSeek

`virtual` `override`

```cpp
virtual void onSeek(Time timeOffset) override
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/Music.hpp:292

Change the current playing position in the stream source.

#### Reimplements

- [`onSeek`](sf-SoundStream.md#onseek-1)

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `timeOffset` | [`Time`](sf-Time.md#time) | New playing position, from the beginning of the music |

---

{#onloop}

### onLoop

`virtual` `override`

```cpp
virtual std::optional< std::uint64_t > onLoop() override
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/Music.hpp:304

Change the current playing position in the stream source to the loop offset.

This is called by the underlying `[SoundStream](sf-SoundStream.md#soundstream)` whenever it needs us to reset the seek position for a loop. We then determine whether we are looping on a loop point or the end-of-file, perform the seek, and return the new position.

#### Returns
The seek position after looping (or `std::nullopt` if there's no loop)

#### Reimplements

- [`onLoop`](sf-SoundStream.md#onloop-1)

## Public Types

| Name | Description |
|------|-------------|
| [`TimeSpan`](#timespan)  |  |

---

{#timespan}

### TimeSpan

```cpp
using TimeSpan = Span< Time >
```

Type: [`Span`](sf-Music-Span.md#span)< [`Time`](sf-Time.md#time) >

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/Music.hpp:67

## Private Attributes

| Return | Name | Description |
|--------|------|-------------|
| `std::unique_ptr< Impl >` | [`m_impl`](#m_impl)  | Implementation details. |

---

{#m_impl}

### m_impl

```cpp
std::unique_ptr< Impl > m_impl
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/Music.hpp:331

Implementation details.

## Private Methods

| Return | Name | Description |
|--------|------|-------------|
| `std::uint64_t` | [`timeToSamples`](#timetosamples) `const` `nodiscard` | Helper to convert an `[sf::Time](sf-Time.md#time)` to a sample position. |
| [`Time`](sf-Time.md#time) | [`samplesToTime`](#samplestotime) `const` `nodiscard` | Helper to convert a sample position to an `[sf::Time](sf-Time.md#time)` |

---

{#timetosamples}

### timeToSamples

`const` `nodiscard`

```cpp
[[nodiscard]] std::uint64_t timeToSamples(Time position) const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/Music.hpp:315

Helper to convert an `[sf::Time](sf-Time.md#time)` to a sample position.

#### Returns
The number of samples elapsed at the given time

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `position` | [`Time`](sf-Time.md#time) | [Time](sf-Time.md#time) to convert to samples |

---

{#samplestotime}

### samplesToTime

`const` `nodiscard`

```cpp
[[nodiscard]] Time samplesToTime(std::uint64_t samples) const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/Music.hpp:325

Helper to convert a sample position to an `[sf::Time](sf-Time.md#time)`

#### Returns
The [Time](sf-Time.md#time) position of the given sample

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `samples` | `std::uint64_t` | Sample count to convert to [Time](sf-Time.md#time) |

