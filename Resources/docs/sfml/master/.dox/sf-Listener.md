{#listener}

# Listener

The audio listener is the point in the scene from where all the sounds are heard.

The audio listener defines the global properties of the audio environment, it defines where and how sounds and musics are heard. If `[sf::View](sf-View.md#view)` is the eyes of the user, then `[sf::Listener](#listener)` are their ears (by the way, they are often linked together &ndash; same position, orientation, etc.).

`[sf::Listener](#listener)` is a simple interface, which allows to setup the listener in the 3D audio environment (position, direction and up vector), and to adjust the global volume.

Usage example: 
```cpp
// Move the listener to the position (1, 0, -5)
sf::Listener::setPosition({1, 0, -5});

// Make it face the right axis (1, 0, 0)
sf::Listener::setDirection({1, 0, 0});

// Reduce the global volume
sf::Listener::setGlobalVolume(50);
```

## Classes

| Name | Description |
|------|-------------|
| [`Cone`](sf-Listener-Cone.md#cone-1) | Structure defining the properties of a directional cone. |

## Functions

| Return | Name | Description |
|--------|------|-------------|
| [`SFML_AUDIO_API`](api.md#sfml_audio_api) void | [`setGlobalVolume`](#setglobalvolume)  | Change the global volume of all the sounds and musics. |
| [`SFML_AUDIO_API`](api.md#sfml_audio_api) float | [`getGlobalVolume`](#getglobalvolume) `nodiscard` | Get the current value of the global volume. |
| [`SFML_AUDIO_API`](api.md#sfml_audio_api) void | [`setPosition`](#setposition-1)  | Set the position of the listener in the scene. |
| [`SFML_AUDIO_API`](api.md#sfml_audio_api)[`Vector3f`](sf.md#vector3f) | [`getPosition`](#getposition-1) `nodiscard` | Get the current position of the listener in the scene. |
| [`SFML_AUDIO_API`](api.md#sfml_audio_api) void | [`setDirection`](#setdirection-1)  | Set the forward vector of the listener in the scene. |
| [`SFML_AUDIO_API`](api.md#sfml_audio_api)[`Vector3f`](sf.md#vector3f) | [`getDirection`](#getdirection-1) `nodiscard` | Get the current forward vector of the listener in the scene. |
| [`SFML_AUDIO_API`](api.md#sfml_audio_api) void | [`setVelocity`](#setvelocity-1)  | Set the velocity of the listener in the scene. |
| [`SFML_AUDIO_API`](api.md#sfml_audio_api)[`Vector3f`](sf.md#vector3f) | [`getVelocity`](#getvelocity-1) `nodiscard` | Get the current forward vector of the listener in the scene. |
| [`SFML_AUDIO_API`](api.md#sfml_audio_api) void | [`setCone`](#setcone-1)  | Set the cone properties of the listener in the audio scene. |
| [`SFML_AUDIO_API`](api.md#sfml_audio_api)[`Listener::Cone`](sf-Listener-Cone.md#cone-1) | [`getCone`](#getcone-1) `nodiscard` | Get the cone properties of the listener in the audio scene. |
| [`SFML_AUDIO_API`](api.md#sfml_audio_api) void | [`setUpVector`](#setupvector)  | Set the upward vector of the listener in the scene. |
| [`SFML_AUDIO_API`](api.md#sfml_audio_api)[`Vector3f`](sf.md#vector3f) | [`getUpVector`](#getupvector) `nodiscard` | Get the current upward vector of the listener in the scene. |

---

{#setglobalvolume}

### setGlobalVolume

```cpp
SFML_AUDIO_API void setGlobalVolume(float volume)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/Listener.hpp:73

Change the global volume of all the sounds and musics.

`volume` is a number between 0 and 100; it is combined with the individual volume of each sound / music. The default value for the volume is 100 (maximum).

**See also**: `[getGlobalVolume](#getglobalvolume)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `volume` | `float` | New global volume, in the range [0, 100] |

---

{#getglobalvolume}

### getGlobalVolume

`nodiscard`

```cpp
[[nodiscard]] SFML_AUDIO_API float getGlobalVolume()
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/Listener.hpp:83

Get the current value of the global volume.

#### Returns
Current global volume, in the range [0, 100]

**See also**: `[setGlobalVolume](#setglobalvolume)`

---

{#setposition-1}

### setPosition

```cpp
SFML_AUDIO_API void setPosition(const Vector3f & position)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/Listener.hpp:95

Set the position of the listener in the scene.

The default listener's position is (0, 0, 0).

**See also**: `[getPosition](#getposition-1)`, `[setDirection](#setdirection-1)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `position` | const [`Vector3f`](sf.md#vector3f) & | New listener's position |

---

{#getposition-1}

### getPosition

`nodiscard`

```cpp
[[nodiscard]] SFML_AUDIO_APIVector3f getPosition()
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/Listener.hpp:105

Get the current position of the listener in the scene.

#### Returns
[Listener](#listener)'s position

**See also**: `[setPosition](#setposition-1)`

---

{#setdirection-1}

### setDirection

```cpp
SFML_AUDIO_API void setDirection(const Vector3f & direction)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/Listener.hpp:122

Set the forward vector of the listener in the scene.

The direction (also called "at vector") is the vector pointing forward from the listener's perspective. Together with the up vector, it defines the 3D orientation of the listener in the scene. The direction vector doesn't have to be normalized. The default listener's direction is (0, 0, -1).

**See also**: `[getDirection](#getdirection-1)`, `[setUpVector](#setupvector)`, `[setPosition](#setposition-1)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `direction` | const [`Vector3f`](sf.md#vector3f) & | New listener's direction |

---

{#getdirection-1}

### getDirection

`nodiscard`

```cpp
[[nodiscard]] SFML_AUDIO_APIVector3f getDirection()
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/Listener.hpp:132

Get the current forward vector of the listener in the scene.

#### Returns
[Listener](#listener)'s forward vector (not normalized)

**See also**: `[setDirection](#setdirection-1)`

---

{#setvelocity-1}

### setVelocity

```cpp
SFML_AUDIO_API void setVelocity(const Vector3f & velocity)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/Listener.hpp:144

Set the velocity of the listener in the scene.

The default listener's velocity is (0, 0, -1).

**See also**: `[getVelocity](#getvelocity-1)`, `[getDirection](#getdirection-1)`, `[setUpVector](#setupvector)`, `[setPosition](#setposition-1)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `velocity` | const [`Vector3f`](sf.md#vector3f) & | New listener's velocity |

---

{#getvelocity-1}

### getVelocity

`nodiscard`

```cpp
[[nodiscard]] SFML_AUDIO_APIVector3f getVelocity()
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/Listener.hpp:154

Get the current forward vector of the listener in the scene.

#### Returns
[Listener](#listener)'s velocity

**See also**: `[setVelocity](#setvelocity-1)`

---

{#setcone-1}

### setCone

```cpp
SFML_AUDIO_API void setCone(const Listener::Cone & cone)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/Listener.hpp:167

Set the cone properties of the listener in the audio scene.

The cone defines how directional attenuation is applied. The default cone of a sound is (2 * PI, 2 * PI, 1).

**See also**: `[getCone](#getcone-1)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `cone` | const [`Listener::Cone`](sf-Listener-Cone.md#cone-1) & | [Cone](sf-Listener-Cone.md#cone-1) properties of the listener in the scene |

---

{#getcone-1}

### getCone

`nodiscard`

```cpp
[[nodiscard]] SFML_AUDIO_APIListener::Cone getCone()
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/Listener.hpp:177

Get the cone properties of the listener in the audio scene.

#### Returns
[Cone](sf-Listener-Cone.md#cone-1) properties of the listener

**See also**: `[setCone](#setcone-1)`

---

{#setupvector}

### setUpVector

```cpp
SFML_AUDIO_API void setUpVector(const Vector3f & upVector)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/Listener.hpp:194

Set the upward vector of the listener in the scene.

The up vector is the vector that points upward from the listener's perspective. Together with the direction, it defines the 3D orientation of the listener in the scene. The up vector doesn't have to be normalized. The default listener's up vector is (0, 1, 0). It is usually not necessary to change it, especially in 2D scenarios.

**See also**: `[getUpVector](#getupvector)`, `[setDirection](#setdirection-1)`, `[setPosition](#setposition-1)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `upVector` | const [`Vector3f`](sf.md#vector3f) & | New listener's up vector |

---

{#getupvector}

### getUpVector

`nodiscard`

```cpp
[[nodiscard]] SFML_AUDIO_APIVector3f getUpVector()
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/Listener.hpp:204

Get the current upward vector of the listener in the scene.

#### Returns
[Listener](#listener)'s upward vector (not normalized)

**See also**: `[setUpVector](#setupvector)`

