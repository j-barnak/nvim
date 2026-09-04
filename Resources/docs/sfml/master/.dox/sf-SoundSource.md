{#soundsource}

# SoundSource

```cpp
#include <SoundSource.hpp>
```

```cpp
class SoundSource
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundSource.hpp:47

> **Inherits:** [`AudioResource`](sf-AudioResource.md#audioresource)
> **Subclassed by:** [`Sound`](sf-Sound.md#sound), [`SoundStream`](sf-SoundStream.md#soundstream)

Base class defining a sound's properties.

`[sf::SoundSource](#soundsource)` is not meant to be used directly, it only serves as a common base for all audio objects that can live in the audio environment.

It defines several properties for the sound: pitch, volume, position, attenuation, etc. All of them can be changed at any time with no impact on performances.

**See also**: `[sf::Sound](sf-Sound.md#sound)`, `[sf::SoundStream](sf-SoundStream.md#soundstream)`

## List of all members

| Name | Kind | Owner |
|------|------|-------|
| [`SoundSource`](#soundsource-1) | `function` | Declared here |
| [`SoundSource`](#soundsource-2) | `function` | Declared here |
| [`operator=`](#operator-6) | `function` | Declared here |
| [`~SoundSource`](#soundsource-3) | `function` | Declared here |
| [`setPitch`](#setpitch) | `function` | Declared here |
| [`setPan`](#setpan) | `function` | Declared here |
| [`setVolume`](#setvolume) | `function` | Declared here |
| [`setSpatializationEnabled`](#setspatializationenabled) | `function` | Declared here |
| [`setPosition`](#setposition) | `function` | Declared here |
| [`setDirection`](#setdirection) | `function` | Declared here |
| [`setCone`](#setcone) | `function` | Declared here |
| [`setVelocity`](#setvelocity) | `function` | Declared here |
| [`setDopplerFactor`](#setdopplerfactor) | `function` | Declared here |
| [`setDirectionalAttenuationFactor`](#setdirectionalattenuationfactor) | `function` | Declared here |
| [`setRelativeToListener`](#setrelativetolistener) | `function` | Declared here |
| [`setMinDistance`](#setmindistance) | `function` | Declared here |
| [`setMaxDistance`](#setmaxdistance) | `function` | Declared here |
| [`setMinGain`](#setmingain) | `function` | Declared here |
| [`setMaxGain`](#setmaxgain) | `function` | Declared here |
| [`setAttenuation`](#setattenuation) | `function` | Declared here |
| [`setEffectProcessor`](#seteffectprocessor-1) | `function` | Declared here |
| [`getPitch`](#getpitch) | `function` | Declared here |
| [`getPan`](#getpan) | `function` | Declared here |
| [`getVolume`](#getvolume) | `function` | Declared here |
| [`isSpatializationEnabled`](#isspatializationenabled) | `function` | Declared here |
| [`getPosition`](#getposition) | `function` | Declared here |
| [`getDirection`](#getdirection) | `function` | Declared here |
| [`getCone`](#getcone) | `function` | Declared here |
| [`getVelocity`](#getvelocity) | `function` | Declared here |
| [`getDopplerFactor`](#getdopplerfactor) | `function` | Declared here |
| [`getDirectionalAttenuationFactor`](#getdirectionalattenuationfactor) | `function` | Declared here |
| [`isRelativeToListener`](#isrelativetolistener) | `function` | Declared here |
| [`getMinDistance`](#getmindistance) | `function` | Declared here |
| [`getMaxDistance`](#getmaxdistance) | `function` | Declared here |
| [`getMinGain`](#getmingain) | `function` | Declared here |
| [`getMaxGain`](#getmaxgain) | `function` | Declared here |
| [`getAttenuation`](#getattenuation) | `function` | Declared here |
| [`operator=`](#operator-7) | `function` | Declared here |
| [`play`](#play-1) | `function` | Declared here |
| [`pause`](#pause-1) | `function` | Declared here |
| [`stop`](#stop-2) | `function` | Declared here |
| [`getStatus`](#getstatus-1) | `function` | Declared here |
| [`SoundSource`](#soundsource-4) | `function` | Declared here |
| [`Status`](Status.md#status) | `enum` | Declared here |
| [`EffectProcessor`](#effectprocessor) | `typedef` | Declared here |
| [`getSound`](#getsound-1) | `function` | Declared here |
| [`AudioResource`](sf-AudioResource.md#audioresource-1) | `function` | Inherited from [`AudioResource`](sf-AudioResource.md#audioresource) |
| [`operator=`](sf-AudioResource.md#operator) | `function` | Inherited from [`AudioResource`](sf-AudioResource.md#audioresource) |
| [`AudioResource`](sf-AudioResource.md#audioresource-2) | `function` | Inherited from [`AudioResource`](sf-AudioResource.md#audioresource) |
| [`operator=`](sf-AudioResource.md#operator-1) | `function` | Inherited from [`AudioResource`](sf-AudioResource.md#audioresource) |
| [`AudioResource`](sf-AudioResource.md#audioresource-3) | `function` | Inherited from [`AudioResource`](sf-AudioResource.md#audioresource) |
| [`m_device`](sf-AudioResource.md#m_device) | `variable` | Inherited from [`AudioResource`](sf-AudioResource.md#audioresource) |

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
|  | [`SoundSource`](#soundsource-1)  | Copy constructor. |
|  | [`SoundSource`](#soundsource-2) `noexcept` | Move constructor. |
| [`SoundSource`](#soundsource) & | [`operator=`](#operator-6) `noexcept` | Move assignment. |
|  | [`~SoundSource`](#soundsource-3) `virtual` | Destructor. |
| `void` | [`setPitch`](#setpitch)  | Set the pitch of the sound. |
| `void` | [`setPan`](#setpan)  | Set the pan of the sound. |
| `void` | [`setVolume`](#setvolume)  | Set the volume of the sound. |
| `void` | [`setSpatializationEnabled`](#setspatializationenabled)  | Set whether spatialization of the sound is enabled. |
| `void` | [`setPosition`](#setposition)  | Set the 3D position of the sound in the audio scene. |
| `void` | [`setDirection`](#setdirection)  | Set the 3D direction of the sound in the audio scene. |
| `void` | [`setCone`](#setcone)  | Set the cone properties of the sound in the audio scene. |
| `void` | [`setVelocity`](#setvelocity)  | Set the 3D velocity of the sound in the audio scene. |
| `void` | [`setDopplerFactor`](#setdopplerfactor)  | Set the doppler factor of the sound. |
| `void` | [`setDirectionalAttenuationFactor`](#setdirectionalattenuationfactor)  | Set the directional attenuation factor of the sound. |
| `void` | [`setRelativeToListener`](#setrelativetolistener)  | Make the sound's position relative to the listener or absolute. |
| `void` | [`setMinDistance`](#setmindistance)  | Set the minimum distance of the sound. |
| `void` | [`setMaxDistance`](#setmaxdistance)  | Set the maximum distance of the sound. |
| `void` | [`setMinGain`](#setmingain)  | Set the minimum gain of the sound. |
| `void` | [`setMaxGain`](#setmaxgain)  | Set the maximum gain of the sound. |
| `void` | [`setAttenuation`](#setattenuation)  | Set the attenuation factor of the sound. |
| `void` | [`setEffectProcessor`](#seteffectprocessor-1) `virtual` | Set the effect processor to be applied to the sound. |
| `float` | [`getPitch`](#getpitch) `const` `nodiscard` | Get the pitch of the sound. |
| `float` | [`getPan`](#getpan) `const` `nodiscard` | Get the pan of the sound. |
| `float` | [`getVolume`](#getvolume) `const` `nodiscard` | Get the volume of the sound. |
| `bool` | [`isSpatializationEnabled`](#isspatializationenabled) `const` `nodiscard` | Tell whether spatialization of the sound is enabled. |
| [`Vector3f`](sf.md#vector3f) | [`getPosition`](#getposition) `const` `nodiscard` | Get the 3D position of the sound in the audio scene. |
| [`Vector3f`](sf.md#vector3f) | [`getDirection`](#getdirection) `const` `nodiscard` | Get the 3D direction of the sound in the audio scene. |
| [`Cone`](sf-SoundSource-Cone.md#cone) | [`getCone`](#getcone) `const` `nodiscard` | Get the cone properties of the sound in the audio scene. |
| [`Vector3f`](sf.md#vector3f) | [`getVelocity`](#getvelocity) `const` `nodiscard` | Get the 3D velocity of the sound in the audio scene. |
| `float` | [`getDopplerFactor`](#getdopplerfactor) `const` `nodiscard` | Get the doppler factor of the sound. |
| `float` | [`getDirectionalAttenuationFactor`](#getdirectionalattenuationfactor) `const` `nodiscard` | Get the directional attenuation factor of the sound. |
| `bool` | [`isRelativeToListener`](#isrelativetolistener) `const` `nodiscard` | Tell whether the sound's position is relative to the listener or is absolute. |
| `float` | [`getMinDistance`](#getmindistance) `const` `nodiscard` | Get the minimum distance of the sound. |
| `float` | [`getMaxDistance`](#getmaxdistance) `const` `nodiscard` | Get the maximum distance of the sound. |
| `float` | [`getMinGain`](#getmingain) `const` `nodiscard` | Get the minimum gain of the sound. |
| `float` | [`getMaxGain`](#getmaxgain) `const` `nodiscard` | Get the maximum gain of the sound. |
| `float` | [`getAttenuation`](#getattenuation) `const` `nodiscard` | Get the attenuation factor of the sound. |
| [`SoundSource`](#soundsource) & | [`operator=`](#operator-7)  | Overload of assignment operator. |
| `void` | [`play`](#play-1) `virtual` | Start or resume playing the sound source. |
| `void` | [`pause`](#pause-1) `virtual` | Pause the sound source. |
| `void` | [`stop`](#stop-2) `virtual` | Stop playing the sound source. |
| [`Status`](Status.md#status) | [`getStatus`](#getstatus-1) `virtual` `const` `nodiscard` | Get the current status of the sound (stopped, paused, playing) |

---

{#soundsource-1}

### SoundSource

```cpp
SoundSource(const SoundSource &) = default
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundSource.hpp:167

Copy constructor.

---

{#soundsource-2}

### SoundSource

`noexcept`

```cpp
SoundSource(SoundSource &&) noexcept = default
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundSource.hpp:173

Move constructor.

---

{#operator-6}

### operator=

`noexcept`

```cpp
SoundSource & operator=(SoundSource &&) noexcept = default
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundSource.hpp:179

Move assignment.

---

{#soundsource-3}

### ~SoundSource

`virtual`

```cpp
virtual ~SoundSource() = default
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundSource.hpp:185

Destructor.

---

{#setpitch}

### setPitch

```cpp
void setPitch(float pitch)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundSource.hpp:201

Set the pitch of the sound.

The pitch represents the perceived fundamental frequency of a sound; thus you can make a sound more acute or grave by changing its pitch. A side effect of changing the pitch is to modify the playing speed of the sound as well. The default value for the pitch is 1.

**See also**: `[getPitch](#getpitch)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `pitch` | `float` | New pitch to apply to the sound |

---

{#setpan}

### setPan

```cpp
void setPan(float pan)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundSource.hpp:216

Set the pan of the sound.

Using panning, a mono sound can be panned between stereo channels. When the pan is set to -1, the sound is played only on the left channel, when the pan is set to +1, the sound is played only on the right channel.

**See also**: `[getPan](#getpan)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `pan` | `float` | New pan to apply to the sound [-1, +1] |

---

{#setvolume}

### setVolume

```cpp
void setVolume(float volume)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundSource.hpp:229

Set the volume of the sound.

The volume is a value between 0 (mute) and 100 (full volume). The default value for the volume is 100.

**See also**: `[getVolume](#getvolume)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `volume` | `float` | Volume of the sound |

---

{#setspatializationenabled}

### setSpatializationEnabled

```cpp
void setSpatializationEnabled(bool enabled)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundSource.hpp:244

Set whether spatialization of the sound is enabled.

Spatialization is the application of various effects to simulate a sound being emitted at a virtual position in 3D space and exhibiting various physical phenomena such as directional attenuation and doppler shift.

**See also**: `[isSpatializationEnabled](#isspatializationenabled)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `enabled` | `bool` | `true` to enable spatialization, `false` to disable |

---

{#setposition}

### setPosition

```cpp
void setPosition(const Vector3f & position)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundSource.hpp:258

Set the 3D position of the sound in the audio scene.

Only sounds with one channel (mono sounds) can be spatialized. The default position of a sound is (0, 0, 0).

**See also**: `[getPosition](#getposition)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `position` | const [`Vector3f`](sf.md#vector3f) & | Position of the sound in the scene |

---

{#setdirection}

### setDirection

```cpp
void setDirection(const Vector3f & direction)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundSource.hpp:273

Set the 3D direction of the sound in the audio scene.

The direction defines where the sound source is facing in 3D space. It will affect how the sound is attenuated if facing away from the listener. The default direction of a sound is (0, 0, -1).

**See also**: `[getDirection](#getdirection)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `direction` | const [`Vector3f`](sf.md#vector3f) & | Direction of the sound in the scene |

---

{#setcone}

### setCone

```cpp
void setCone(const Cone & cone)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundSource.hpp:286

Set the cone properties of the sound in the audio scene.

The cone defines how directional attenuation is applied. The default cone of a sound is (2 * PI, 2 * PI, 1).

**See also**: `[getCone](#getcone)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `cone` | const [`Cone`](sf-SoundSource-Cone.md#cone) & | [Cone](sf-SoundSource-Cone.md#cone) properties of the sound in the scene |

---

{#setvelocity}

### setVelocity

```cpp
void setVelocity(const Vector3f & velocity)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundSource.hpp:301

Set the 3D velocity of the sound in the audio scene.

The velocity is used to determine how to doppler shift the sound. Sounds moving towards the listener will be perceived to have a higher pitch and sounds moving away from the listener will be perceived to have a lower pitch.

**See also**: `[getVelocity](#getvelocity)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `velocity` | const [`Vector3f`](sf.md#vector3f) & | Velocity of the sound in the scene |

---

{#setdopplerfactor}

### setDopplerFactor

```cpp
void setDopplerFactor(float factor)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundSource.hpp:314

Set the doppler factor of the sound.

The doppler factor determines how strong the doppler shift will be.

**See also**: `[getDopplerFactor](#getdopplerfactor)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `factor` | `float` | New doppler factor to apply to the sound |

---

{#setdirectionalattenuationfactor}

### setDirectionalAttenuationFactor

```cpp
void setDirectionalAttenuationFactor(float factor)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundSource.hpp:331

Set the directional attenuation factor of the sound.

Depending on the virtual position of an output channel relative to the listener (such as in surround sound setups), sounds will be attenuated when emitting them from certain channels. This factor determines how strong the attenuation based on output channel position relative to the listener is.

**See also**: `[getDirectionalAttenuationFactor](#getdirectionalattenuationfactor)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `factor` | `float` | New directional attenuation factor to apply to the sound |

---

{#setrelativetolistener}

### setRelativeToListener

```cpp
void setRelativeToListener(bool relative)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundSource.hpp:347

Make the sound's position relative to the listener or absolute.

Making a sound relative to the listener will ensure that it will always be played the same way regardless of the position of the listener. This can be useful for non-spatialized sounds, sounds that are produced by the listener, or sounds attached to it. The default value is `false` (position is absolute).

**See also**: `[isRelativeToListener](#isrelativetolistener)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `relative` | `bool` | `true` to set the position relative, `false` to set it absolute |

---

{#setmindistance}

### setMinDistance

```cpp
void setMinDistance(float distance)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundSource.hpp:364

Set the minimum distance of the sound.

The "minimum distance" of a sound is the maximum distance at which it is heard at its maximum volume. Further than the minimum distance, it will start to fade out according to its attenuation factor. A value of 0 ("inside the head
of the listener") is an invalid value and is forbidden. The default value of the minimum distance is 1.

**See also**: `[getMinDistance](#getmindistance)`, `[setAttenuation](#setattenuation)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `distance` | `float` | New minimum distance of the sound |

---

{#setmaxdistance}

### setMaxDistance

```cpp
void setMaxDistance(float distance)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundSource.hpp:381

Set the maximum distance of the sound.

The "maximum distance" of a sound is the minimum distance at which it is heard at its minimum volume. Closer than the maximum distance, it will start to fade in according to its attenuation factor. The default value of the maximum distance is the maximum value a float can represent.

**See also**: `[getMaxDistance](#getmaxdistance)`, `[setAttenuation](#setattenuation)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `distance` | `float` | New maximum distance of the sound |

---

{#setmingain}

### setMinGain

```cpp
void setMinGain(float gain)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundSource.hpp:395

Set the minimum gain of the sound.

When the sound is further away from the listener than the "maximum distance" the attenuated gain is clamped so it cannot go below the minimum gain value.

**See also**: `[getMinGain](#getmingain)`, `[setAttenuation](#setattenuation)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `gain` | `float` | New minimum gain of the sound |

---

{#setmaxgain}

### setMaxGain

```cpp
void setMaxGain(float gain)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundSource.hpp:409

Set the maximum gain of the sound.

When the sound is closer from the listener than the "minimum distance" the attenuated gain is clamped so it cannot go above the maximum gain value.

**See also**: `[getMaxGain](#getmaxgain)`, `[setAttenuation](#setattenuation)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `gain` | `float` | New maximum gain of the sound |

---

{#setattenuation}

### setAttenuation

```cpp
void setAttenuation(float attenuation)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundSource.hpp:428

Set the attenuation factor of the sound.

The attenuation is a multiplicative factor which makes the sound more or less loud according to its distance from the listener. An attenuation of 0 will produce a non-attenuated sound, i.e. its volume will always be the same whether it is heard from near or from far. On the other hand, an attenuation value such as 100 will make the sound fade out very quickly as it gets further from the listener. The default value of the attenuation is 1.

**See also**: `[getAttenuation](#getattenuation)`, `[setMinDistance](#setmindistance)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `attenuation` | `float` | New attenuation factor of the sound |

---

{#seteffectprocessor-1}

### setEffectProcessor

`virtual`

```cpp
virtual void setEffectProcessor(EffectProcessor effectProcessor)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundSource.hpp:439

Set the effect processor to be applied to the sound.

The effect processor is a callable that will be called with sound data to be processed.

#### Reimplemented by

- [`setEffectProcessor`](sf-Sound.md#seteffectprocessor)
- [`setEffectProcessor`](sf-SoundStream.md#seteffectprocessor-2)

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `effectProcessor` | [`EffectProcessor`](#effectprocessor) | The effect processor to attach to this sound, attach an empty processor to disable processing |

---

{#getpitch}

### getPitch

`const` `nodiscard`

```cpp
[[nodiscard]] float getPitch() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundSource.hpp:449

Get the pitch of the sound.

#### Returns
Pitch of the sound

**See also**: `[setPitch](#setpitch)`

---

{#getpan}

### getPan

`const` `nodiscard`

```cpp
[[nodiscard]] float getPan() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundSource.hpp:459

Get the pan of the sound.

#### Returns
Pan of the sound

**See also**: `[setPan](#setpan)`

---

{#getvolume}

### getVolume

`const` `nodiscard`

```cpp
[[nodiscard]] float getVolume() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundSource.hpp:469

Get the volume of the sound.

#### Returns
Volume of the sound, in the range [0, 100]

**See also**: `[setVolume](#setvolume)`

---

{#isspatializationenabled}

### isSpatializationEnabled

`const` `nodiscard`

```cpp
[[nodiscard]] bool isSpatializationEnabled() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundSource.hpp:479

Tell whether spatialization of the sound is enabled.

#### Returns
`true` if spatialization is enabled, `false` if it's disabled

**See also**: `[setSpatializationEnabled](#setspatializationenabled)`

---

{#getposition}

### getPosition

`const` `nodiscard`

```cpp
[[nodiscard]] Vector3f getPosition() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundSource.hpp:489

Get the 3D position of the sound in the audio scene.

#### Returns
Position of the sound

**See also**: `[setPosition](#setposition)`

---

{#getdirection}

### getDirection

`const` `nodiscard`

```cpp
[[nodiscard]] Vector3f getDirection() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundSource.hpp:499

Get the 3D direction of the sound in the audio scene.

#### Returns
Direction of the sound

**See also**: `[setDirection](#setdirection)`

---

{#getcone}

### getCone

`const` `nodiscard`

```cpp
[[nodiscard]] Cone getCone() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundSource.hpp:509

Get the cone properties of the sound in the audio scene.

#### Returns
[Cone](sf-SoundSource-Cone.md#cone) properties of the sound

**See also**: `[setCone](#setcone)`

---

{#getvelocity}

### getVelocity

`const` `nodiscard`

```cpp
[[nodiscard]] Vector3f getVelocity() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundSource.hpp:519

Get the 3D velocity of the sound in the audio scene.

#### Returns
Velocity of the sound

**See also**: `[setVelocity](#setvelocity)`

---

{#getdopplerfactor}

### getDopplerFactor

`const` `nodiscard`

```cpp
[[nodiscard]] float getDopplerFactor() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundSource.hpp:529

Get the doppler factor of the sound.

#### Returns
Doppler factor of the sound

**See also**: `[setDopplerFactor](#setdopplerfactor)`

---

{#getdirectionalattenuationfactor}

### getDirectionalAttenuationFactor

`const` `nodiscard`

```cpp
[[nodiscard]] float getDirectionalAttenuationFactor() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundSource.hpp:539

Get the directional attenuation factor of the sound.

#### Returns
Directional attenuation factor of the sound

**See also**: `[setDirectionalAttenuationFactor](#setdirectionalattenuationfactor)`

---

{#isrelativetolistener}

### isRelativeToListener

`const` `nodiscard`

```cpp
[[nodiscard]] bool isRelativeToListener() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundSource.hpp:550

Tell whether the sound's position is relative to the listener or is absolute.

#### Returns
`true` if the position is relative, `false` if it's absolute

**See also**: `[setRelativeToListener](#setrelativetolistener)`

---

{#getmindistance}

### getMinDistance

`const` `nodiscard`

```cpp
[[nodiscard]] float getMinDistance() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundSource.hpp:560

Get the minimum distance of the sound.

#### Returns
Minimum distance of the sound

**See also**: `[setMinDistance](#setmindistance)`, `[getAttenuation](#getattenuation)`

---

{#getmaxdistance}

### getMaxDistance

`const` `nodiscard`

```cpp
[[nodiscard]] float getMaxDistance() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundSource.hpp:570

Get the maximum distance of the sound.

#### Returns
Maximum distance of the sound

**See also**: `[setMaxDistance](#setmaxdistance)`, `[getAttenuation](#getattenuation)`

---

{#getmingain}

### getMinGain

`const` `nodiscard`

```cpp
[[nodiscard]] float getMinGain() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundSource.hpp:580

Get the minimum gain of the sound.

#### Returns
Minimum gain of the sound

**See also**: `[setMinGain](#setmingain)`, `[getAttenuation](#getattenuation)`

---

{#getmaxgain}

### getMaxGain

`const` `nodiscard`

```cpp
[[nodiscard]] float getMaxGain() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundSource.hpp:590

Get the maximum gain of the sound.

#### Returns
Maximum gain of the sound

**See also**: `[setMaxGain](#setmaxgain)`, `[getAttenuation](#getattenuation)`

---

{#getattenuation}

### getAttenuation

`const` `nodiscard`

```cpp
[[nodiscard]] float getAttenuation() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundSource.hpp:600

Get the attenuation factor of the sound.

#### Returns
Attenuation factor of the sound

**See also**: `[setAttenuation](#setattenuation)`, `[getMinDistance](#getmindistance)`

---

{#operator-7}

### operator=

```cpp
SoundSource & operator=(const SoundSource & right)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundSource.hpp:610

Overload of assignment operator.

#### Returns
Reference to self

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `right` | const [`SoundSource`](#soundsource) & | Instance to assign |

---

{#play-1}

### play

`virtual`

```cpp
virtual void play()
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundSource.hpp:622

Start or resume playing the sound source.

This function starts the source if it was stopped, resumes it if it was paused, and restarts it from the beginning if it was already playing.

**See also**: `[pause](#pause-1)`, `[stop](#stop-2)`

#### Reimplemented by

- [`play`](sf-Sound.md#play)
- [`play`](sf-SoundStream.md#play-2)

---

{#pause-1}

### pause

`virtual`

```cpp
virtual void pause()
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundSource.hpp:633

Pause the sound source.

This function pauses the source if it was playing, otherwise (source already paused or stopped) it has no effect.

**See also**: `[play](#play-1)`, `[stop](#stop-2)`

#### Reimplemented by

- [`pause`](sf-Sound.md#pause)
- [`pause`](sf-SoundStream.md#pause-2)

---

{#stop-2}

### stop

`virtual`

```cpp
virtual void stop()
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundSource.hpp:645

Stop playing the sound source.

This function stops the source if it was playing or paused, and does nothing if it was already stopped. It also resets the playing position (unlike `[pause()](#pause-1)`).

**See also**: `[play](#play-1)`, `[pause](#pause-1)`

#### Reimplemented by

- [`stop`](sf-Sound.md#stop)
- [`stop`](sf-SoundStream.md#stop-3)

---

{#getstatus-1}

### getStatus

`virtual` `const` `nodiscard`

```cpp
[[nodiscard]] virtual Status getStatus() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundSource.hpp:653

Get the current status of the sound (stopped, paused, playing)

#### Returns
Current status of the sound

#### Reimplemented by

- [`getStatus`](sf-Sound.md#getstatus)
- [`getStatus`](sf-SoundStream.md#getstatus-2)

## Protected Methods

| Return | Name | Description |
|--------|------|-------------|
|  | [`SoundSource`](#soundsource-4)  | Default constructor. |

---

{#soundsource-4}

### SoundSource

```cpp
SoundSource() = default
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundSource.hpp:662

Default constructor.

This constructor is meant to be called by derived classes only.

## Public Types

| Name | Description |
|------|-------------|
| [`Status`](#status)  | Enumeration of the sound source states. |
| [`EffectProcessor`](#effectprocessor)  | Callable that is provided with sound data for processing. |

---

{#status}

### Status

```cpp
enum Status
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundSource.hpp:54

Enumeration of the sound source states.

| Value | Description |
|-------|-------------|
| `Stopped` | [Sound](sf-Sound.md#sound) is not playing. |
| `Paused` | [Sound](sf-Sound.md#sound) is paused. |
| `Playing` | [Sound](sf-Sound.md#sound) is playing. |

---

{#effectprocessor}

### EffectProcessor

```cpp
using EffectProcessor = std::function< void(const float *inputFrames, unsigned int &inputFrameCount, float *outputFrames, unsigned int &outputFrameCount, unsigned int frameChannelCount)>
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundSource.hpp:160

Callable that is provided with sound data for processing.

When the audio engine sources sound data from sound sources it will pass the data through an effects processor if one is set. The sound data will already be converted to the internal floating point format and have the same sample rate as the audio device and engine. The device sample rate can differ from the sample rate of the source data so keep this in mind when setting up processing that is dependent on the sample rate. The sample rate of the current playback device can be retrieved using `[sf::PlaybackDevice::getDeviceSampleRate()](sf-PlaybackDevice.md#getdevicesamplerate)`.

[Sound](sf-Sound.md#sound) data that is processed this way is provided in frames. Each frame contains 1 floating point sample per channel. If e.g. the data source provides stereo data, each frame will contain 2 floats.

The effects processor function takes 4 parameters:

* The input data frames, channels interleaved
* The number of input data frames available
* The buffer to write output data frames to, channels interleaved
* The number of output data frames that the output buffer can hold
* The channel count

The input and output frame counts are in/out parameters.

When this function is called, the input count will contain the number of frames available in the input buffer. The output count will contain the size of the output buffer i.e. the maximum number of frames that can be written to the output buffer.

Attempting to read more frames than the input frame count or write more frames than the output frame count will result in undefined behaviour.

It is important to note that the channel count of the audio engine currently sourcing data from this sound will always be provided in `frameChannelCount`. This can be different from the channel count of the sound source so make sure to size necessary processing buffers according to the engine channel count and not the sound source channel count.

When done processing the frames, the input and output frame counts must be updated to reflect the actual number of frames that were read from the input and written to the output.

The processing function should always try to process as much sound data as possible i.e. always try to fill the output buffer to the maximum. In certain situations for specific effects it can be possible that the input frame count and output frame count aren't equal. As long as the frame counts are updated accordingly this is perfectly valid.

If the audio engine determines that no audio data is available from the data source, the input data frames pointer is set to `nullptr` and the input frame count is set to 0. In this case it is up to the function to decide how to handle the situation. For specific effects e.g. Echo/Delay buffered data might still be able to be written to the output buffer even if there is no longer any input data.

An important thing to remember is that this function is directly called by the audio engine. Because the audio engine runs on an internal thread of its own, make sure access to shared data is synchronized appropriately.

Because this function is stored by the `[SoundSource](#soundsource)` object it will be able to be called as long as the `[SoundSource](#soundsource)` object hasn't yet been destroyed. Make sure that any data this function references outlives the [SoundSource](#soundsource) object otherwise use-after-free errors will occur.

## Private Methods

| Return | Name | Description |
|--------|------|-------------|
| `void *` | [`getSound`](#getsound-1) `virtual` `const` `nodiscard` | Get the sound object. |

---

{#getsound-1}

### getSound

`virtual` `const` `nodiscard`

```cpp
[[nodiscard]] virtual void * getSound() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundSource.hpp:671

Get the sound object.

#### Returns
The sound object

#### Reimplemented by

- [`getSound`](sf-Sound.md#getsound)
- [`getSound`](sf-SoundStream.md#getsound-2)

