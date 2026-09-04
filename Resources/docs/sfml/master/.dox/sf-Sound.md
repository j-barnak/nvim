{#sound}

# Sound

```cpp
#include <Sound.hpp>
```

```cpp
class Sound
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/Sound.hpp:47

> **Inherits:** [`SoundSource`](sf-SoundSource.md#soundsource)

Regular sound that can be played in the audio environment.

`[sf::Sound](#sound)` is the class to use to play sounds. It provides: 

* Control (play, pause, stop) 
* Ability to modify output parameters in real-time (pitch, volume, ...) 
* 3D spatial features (position, attenuation, ...).
`[sf::Sound](#sound)` is perfect for playing short sounds that can fit in memory and require no latency, like foot steps or gun shots. For longer sounds, like background musics or long speeches, rather see `[sf::Music](sf-Music.md#music)` (which is based on streaming).

In order to work, a sound must be given a buffer of audio data to play. Audio data (samples) is stored in `[sf::SoundBuffer](sf-SoundBuffer.md#soundbuffer-1),` and attached to a sound when it is created or with the `[setBuffer()](#setbuffer)` function. The buffer object attached to a sound must remain alive as long as the sound uses it. Note that multiple sounds can use the same sound buffer at the same time.

Usage example: 
```cpp
const sf::SoundBuffer buffer("sound.wav");
sf::Sound sound(buffer);
sound.play();
```

**See also**: `[sf::SoundBuffer](sf-SoundBuffer.md#soundbuffer-1)`, `[sf::Music](sf-Music.md#music)`

## List of all members

| Name | Kind | Owner |
|------|------|-------|
| [`SoundBuffer`](#soundbuffer) | `friend` | Declared here |
| [`Sound`](#sound-1) | `function` | Declared here |
| [`Sound`](#sound-2) | `function` | Declared here |
| [`Sound`](#sound-3) | `function` | Declared here |
| [`~Sound`](#sound-4) | `function` | Declared here |
| [`play`](#play) | `function` | Declared here |
| [`pause`](#pause) | `function` | Declared here |
| [`stop`](#stop) | `function` | Declared here |
| [`setBuffer`](#setbuffer) | `function` | Declared here |
| [`setBuffer`](#setbuffer-1) | `function` | Declared here |
| [`setLooping`](#setlooping) | `function` | Declared here |
| [`setPlayingOffset`](#setplayingoffset) | `function` | Declared here |
| [`setEffectProcessor`](#seteffectprocessor) | `function` | Declared here |
| [`getBuffer`](#getbuffer) | `function` | Declared here |
| [`isLooping`](#islooping) | `function` | Declared here |
| [`getPlayingOffset`](#getplayingoffset) | `function` | Declared here |
| [`getStatus`](#getstatus) | `function` | Declared here |
| [`operator=`](#operator-4) | `function` | Declared here |
| [`m_impl`](#m_impl-1) | `variable` | Declared here |
| [`detachBuffer`](#detachbuffer) | `function` | Declared here |
| [`getSound`](#getsound) | `function` | Declared here |
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
| `variable` | [`m_device`](sf-AudioResource.md#m_device)  | [Sound](#sound) device. |

## Friends

| Name | Description |
|------|-------------|
| [`SoundBuffer`](#soundbuffer)  |  |

---

{#soundbuffer}

### SoundBuffer

```cpp
friend class SoundBuffer
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/Sound.hpp:223

## Public Methods

| Return | Name | Description |
|--------|------|-------------|
|  | [`Sound`](#sound-1) `explicit` | Construct the sound with a buffer. |
|  | [`Sound`](#sound-2)  | Disallow construction from a temporary sound buffer. |
|  | [`Sound`](#sound-3)  | Copy constructor. |
|  | [`~Sound`](#sound-4) `override` | Destructor. |
| `void` | [`play`](#play) `virtual` `override` | Start or resume playing the sound. |
| `void` | [`pause`](#pause) `virtual` `override` | Pause the sound. |
| `void` | [`stop`](#stop) `virtual` `override` | stop playing the sound |
| `void` | [`setBuffer`](#setbuffer)  | Set the source buffer containing the audio data to play. |
| `void` | [`setBuffer`](#setbuffer-1)  | Disallow setting from a temporary sound buffer. |
| `void` | [`setLooping`](#setlooping)  | Set whether or not the sound should loop after reaching the end. |
| `void` | [`setPlayingOffset`](#setplayingoffset)  | Change the current playing position of the sound. |
| `void` | [`setEffectProcessor`](#seteffectprocessor) `virtual` `override` | Set the effect processor to be applied to the sound. |
| const [`SoundBuffer`](sf-SoundBuffer.md#soundbuffer-1) & | [`getBuffer`](#getbuffer) `const` `nodiscard` | Get the audio buffer attached to the sound. |
| `bool` | [`isLooping`](#islooping) `const` `nodiscard` | Tell whether or not the sound is in loop mode. |
| [`Time`](sf-Time.md#time) | [`getPlayingOffset`](#getplayingoffset) `const` `nodiscard` | Get the current playing position of the sound. |
| [`Status`](Status.md#status) | [`getStatus`](#getstatus) `virtual` `const` `nodiscard` `override` | Get the current status of the sound (stopped, paused, playing) |
| [`Sound`](#sound) & | [`operator=`](#operator-4)  | Overload of assignment operator. |

---

{#sound-1}

### Sound

`explicit`

```cpp
explicit Sound(const SoundBuffer & buffer)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/Sound.hpp:56

Construct the sound with a buffer.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `buffer` | const [`SoundBuffer`](sf-SoundBuffer.md#soundbuffer-1) & | [Sound](#sound) buffer containing the audio data to play with the sound |

---

{#sound-2}

### Sound

```cpp
Sound(const SoundBuffer && buffer) = delete
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/Sound.hpp:62

Disallow construction from a temporary sound buffer.

---

{#sound-3}

### Sound

```cpp
Sound(const Sound & copy)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/Sound.hpp:70

Copy constructor.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `copy` | const [`Sound`](#sound) & | Instance to copy |

---

{#sound-4}

### ~Sound

`override`

```cpp
~Sound() override
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/Sound.hpp:76

Destructor.

---

{#play}

### play

`virtual` `override`

```cpp
virtual void play() override
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/Sound.hpp:90

Start or resume playing the sound.

This function starts the stream if it was stopped, resumes it if it was paused, and restarts it from beginning if it was it already playing. This function uses its own thread so that it doesn't block the rest of the program while the sound is played.

**See also**: `[pause](#pause)`, `[stop](#stop)`

#### Reimplements

- [`play`](sf-SoundSource.md#play-1)

---

{#pause}

### pause

`virtual` `override`

```cpp
virtual void pause() override
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/Sound.hpp:101

Pause the sound.

This function pauses the sound if it was playing, otherwise (sound already paused or stopped) it has no effect.

**See also**: `[play](#play)`, `[stop](#stop)`

#### Reimplements

- [`pause`](sf-SoundSource.md#pause-1)

---

{#stop}

### stop

`virtual` `override`

```cpp
virtual void stop() override
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/Sound.hpp:113

stop playing the sound

This function stops the sound if it was playing or paused, and does nothing if it was already stopped. It also resets the playing position (unlike `[pause()](#pause)`).

**See also**: `[play](#play)`, `[pause](#pause)`

#### Reimplements

- [`stop`](sf-SoundSource.md#stop-2)

---

{#setbuffer}

### setBuffer

```cpp
void setBuffer(const SoundBuffer & buffer)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/Sound.hpp:127

Set the source buffer containing the audio data to play.

It is important to note that the sound buffer is not copied, thus the `[sf::SoundBuffer](sf-SoundBuffer.md#soundbuffer-1)` instance must remain alive as long as it is attached to the sound.

**See also**: `[getBuffer](#getbuffer)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `buffer` | const [`SoundBuffer`](sf-SoundBuffer.md#soundbuffer-1) & | [Sound](#sound) buffer to attach to the sound |

---

{#setbuffer-1}

### setBuffer

```cpp
void setBuffer(const SoundBuffer && buffer) = delete
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/Sound.hpp:133

Disallow setting from a temporary sound buffer.

---

{#setlooping}

### setLooping

```cpp
void setLooping(bool loop)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/Sound.hpp:148

Set whether or not the sound should loop after reaching the end.

If set, the sound will restart from beginning after reaching the end and so on, until it is stopped or `setLooping(false)` is called. The default looping state for sound is `false`.

**See also**: `[isLooping](#islooping)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `loop` | `bool` | `true` to play in loop, `false` to play once |

---

{#setplayingoffset}

### setPlayingOffset

```cpp
void setPlayingOffset(Time timeOffset)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/Sound.hpp:163

Change the current playing position of the sound.

The playing position can be changed when the sound is either paused or playing. Changing the playing position when the sound is stopped has no effect, since playing the sound will reset its position.

**See also**: `[getPlayingOffset](#getplayingoffset)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `timeOffset` | [`Time`](sf-Time.md#time) | New playing position, from the beginning of the sound |

---

{#seteffectprocessor}

### setEffectProcessor

`virtual` `override`

```cpp
virtual void setEffectProcessor(EffectProcessor effectProcessor) override
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/Sound.hpp:174

Set the effect processor to be applied to the sound.

The effect processor is a callable that will be called with sound data to be processed.

#### Reimplements

- [`setEffectProcessor`](sf-SoundSource.md#seteffectprocessor-1)

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `effectProcessor` | [`EffectProcessor`](sf-SoundSource.md#effectprocessor) | The effect processor to attach to this sound, attach an empty processor to disable processing |

---

{#getbuffer}

### getBuffer

`const` `nodiscard`

```cpp
[[nodiscard]] const SoundBuffer & getBuffer() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/Sound.hpp:182

Get the audio buffer attached to the sound.

#### Returns
[Sound](#sound) buffer attached to the sound

---

{#islooping}

### isLooping

`const` `nodiscard`

```cpp
[[nodiscard]] bool isLooping() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/Sound.hpp:192

Tell whether or not the sound is in loop mode.

#### Returns
`true` if the sound is looping, `false` otherwise

**See also**: `[setLooping](#setlooping)`

---

{#getplayingoffset}

### getPlayingOffset

`const` `nodiscard`

```cpp
[[nodiscard]] Time getPlayingOffset() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/Sound.hpp:202

Get the current playing position of the sound.

#### Returns
Current playing position, from the beginning of the sound

**See also**: `[setPlayingOffset](#setplayingoffset)`

---

{#getstatus}

### getStatus

`virtual` `const` `nodiscard` `override`

```cpp
[[nodiscard]] virtual Status getStatus() const override
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/Sound.hpp:210

Get the current status of the sound (stopped, paused, playing)

#### Returns
Current status of the sound

#### Reimplements

- [`getStatus`](sf-SoundSource.md#getstatus-1)

---

{#operator-4}

### operator=

```cpp
Sound & operator=(const Sound & right)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/Sound.hpp:220

Overload of assignment operator.

#### Returns
Reference to self

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `right` | const [`Sound`](#sound) & | Instance to assign |

## Private Attributes

| Return | Name | Description |
|--------|------|-------------|
| `const std::unique_ptr< Impl >` | [`m_impl`](#m_impl-1)  | Implementation details. |

---

{#m_impl-1}

### m_impl

```cpp
const std::unique_ptr< Impl > m_impl
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/Sound.hpp:246

Implementation details.

## Private Methods

| Return | Name | Description |
|--------|------|-------------|
| `void` | [`detachBuffer`](#detachbuffer)  | Detach sound from its internal buffer. |
| `void *` | [`getSound`](#getsound) `virtual` `const` `nodiscard` `override` | Get the sound object. |

---

{#detachbuffer}

### detachBuffer

```cpp
void detachBuffer()
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/Sound.hpp:232

Detach sound from its internal buffer.

This allows the sound buffer to temporarily detach the sounds that use it when the sound buffer gets updated.

---

{#getsound}

### getSound

`virtual` `const` `nodiscard` `override`

```cpp
[[nodiscard]] virtual void * getSound() const override
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/Sound.hpp:240

Get the sound object.

#### Returns
The sound object

#### Reimplements

- [`getSound`](sf-SoundSource.md#getsound-1)

