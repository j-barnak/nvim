{#audioresource}

# AudioResource

```cpp
#include <AudioResource.hpp>
```

```cpp
class AudioResource
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/AudioResource.hpp:41

> **Subclassed by:** [`SoundSource`](sf-SoundSource.md#soundsource)

Base class for classes that require an audio device.

This class is for internal use only, it must be the base of every class that requires a valid audio device in order to work.

## Public Methods

| Return | Name | Description |
|--------|------|-------------|
|  | [`AudioResource`](#audioresource-1)  | Copy constructor. |
| [`AudioResource`](#audioresource) & | [`operator=`](#operator)  | Copy assignment. |
|  | [`AudioResource`](#audioresource-2) `noexcept` | Move constructor. |
| [`AudioResource`](#audioresource) & | [`operator=`](#operator-1) `noexcept` | Move assignment. |

---

{#audioresource-1}

### AudioResource

```cpp
AudioResource(const AudioResource &) = default
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/AudioResource.hpp:48

Copy constructor.

---

{#operator}

### operator=

```cpp
AudioResource & operator=(const AudioResource &) = default
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/AudioResource.hpp:54

Copy assignment.

---

{#audioresource-2}

### AudioResource

`noexcept`

```cpp
AudioResource(AudioResource &&) noexcept = default
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/AudioResource.hpp:60

Move constructor.

---

{#operator-1}

### operator=

`noexcept`

```cpp
AudioResource & operator=(AudioResource &&) noexcept = default
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/AudioResource.hpp:66

Move assignment.

## Protected Methods

| Return | Name | Description |
|--------|------|-------------|
|  | [`AudioResource`](#audioresource-3)  | Default constructor. |

---

{#audioresource-3}

### AudioResource

```cpp
AudioResource()
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/AudioResource.hpp:73

Default constructor.

## Private Attributes

| Return | Name | Description |
|--------|------|-------------|
| `std::shared_ptr< void >` | [`m_device`](#m_device)  | [Sound](sf-Sound.md#sound) device. |

---

{#m_device}

### m_device

```cpp
std::shared_ptr< void > m_device
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/AudioResource.hpp:79

[Sound](sf-Sound.md#sound) device.

