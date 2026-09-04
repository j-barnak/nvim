{#soundbufferrecorder}

# SoundBufferRecorder

```cpp
#include <SoundBufferRecorder.hpp>
```

```cpp
class SoundBufferRecorder
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundBufferRecorder.hpp:48

> **Inherits:** [`SoundRecorder`](sf-SoundRecorder.md#soundrecorder)

Specialized [SoundRecorder](sf-SoundRecorder.md#soundrecorder) which stores the captured audio data into a sound buffer.

`[sf::SoundBufferRecorder](#soundbufferrecorder)` allows to access a recorded sound through a `[sf::SoundBuffer](sf-SoundBuffer.md#soundbuffer-1)`, so that it can be played, saved to a file, etc.

It has the same simple interface as its base class (`[start()](sf-SoundRecorder.md#start)`, `[stop()](sf-SoundRecorder.md#stop-1)`) and adds a function to retrieve the recorded sound buffer (`[getBuffer()](#getbuffer-1)`).

As usual, don't forget to call the `[isAvailable()](sf-SoundRecorder.md#isavailable)` function before using this class (see `[sf::SoundRecorder](sf-SoundRecorder.md#soundrecorder)` for more details about this).

Usage example: 
```cpp
if (sf::SoundBufferRecorder::isAvailable())
{
    // Record some audio data
    sf::SoundBufferRecorder recorder;
    if (!recorder.start())
    {
        // Handle error...
    }
    ...
    recorder.stop();

    // Get the buffer containing the captured audio data
    const sf::SoundBuffer& buffer = recorder.getBuffer();

    // Save it to a file (for example...)
    if (!buffer.saveToFile("my_record.ogg"))
    {
        // Handle error...
    }
}
```

**See also**: `[sf::SoundRecorder](sf-SoundRecorder.md#soundrecorder)`

## List of all members

| Name | Kind | Owner |
|------|------|-------|
| [`~SoundBufferRecorder`](#soundbufferrecorder-1) | `function` | Declared here |
| [`getBuffer`](#getbuffer-1) | `function` | Declared here |
| [`onStart`](#onstart) | `function` | Declared here |
| [`onProcessSamples`](#onprocesssamples) | `function` | Declared here |
| [`onStop`](#onstop) | `function` | Declared here |
| [`m_samples`](#m_samples-1) | `variable` | Declared here |
| [`m_buffer`](#m_buffer) | `variable` | Declared here |
| [`~SoundRecorder`](sf-SoundRecorder.md#soundrecorder-1) | `function` | Inherited from [`SoundRecorder`](sf-SoundRecorder.md#soundrecorder) |
| [`start`](sf-SoundRecorder.md#start) | `function` | Inherited from [`SoundRecorder`](sf-SoundRecorder.md#soundrecorder) |
| [`stop`](sf-SoundRecorder.md#stop-1) | `function` | Inherited from [`SoundRecorder`](sf-SoundRecorder.md#soundrecorder) |
| [`getSampleRate`](sf-SoundRecorder.md#getsamplerate-2) | `function` | Inherited from [`SoundRecorder`](sf-SoundRecorder.md#soundrecorder) |
| [`setDevice`](sf-SoundRecorder.md#setdevice) | `function` | Inherited from [`SoundRecorder`](sf-SoundRecorder.md#soundrecorder) |
| [`getDevice`](sf-SoundRecorder.md#getdevice) | `function` | Inherited from [`SoundRecorder`](sf-SoundRecorder.md#soundrecorder) |
| [`setChannelCount`](sf-SoundRecorder.md#setchannelcount) | `function` | Inherited from [`SoundRecorder`](sf-SoundRecorder.md#soundrecorder) |
| [`getChannelCount`](sf-SoundRecorder.md#getchannelcount-2) | `function` | Inherited from [`SoundRecorder`](sf-SoundRecorder.md#soundrecorder) |
| [`getChannelMap`](sf-SoundRecorder.md#getchannelmap-2) | `function` | Inherited from [`SoundRecorder`](sf-SoundRecorder.md#soundrecorder) |
| [`getAvailableDevices`](sf-SoundRecorder.md#getavailabledevices) | `function` | Inherited from [`SoundRecorder`](sf-SoundRecorder.md#soundrecorder) |
| [`getDefaultDevice`](sf-SoundRecorder.md#getdefaultdevice) | `function` | Inherited from [`SoundRecorder`](sf-SoundRecorder.md#soundrecorder) |
| [`isAvailable`](sf-SoundRecorder.md#isavailable) | `function` | Inherited from [`SoundRecorder`](sf-SoundRecorder.md#soundrecorder) |
| [`SoundRecorder`](sf-SoundRecorder.md#soundrecorder-2) | `function` | Inherited from [`SoundRecorder`](sf-SoundRecorder.md#soundrecorder) |
| [`onStart`](sf-SoundRecorder.md#onstart-1) | `function` | Inherited from [`SoundRecorder`](sf-SoundRecorder.md#soundrecorder) |
| [`onProcessSamples`](sf-SoundRecorder.md#onprocesssamples-1) | `function` | Inherited from [`SoundRecorder`](sf-SoundRecorder.md#soundrecorder) |
| [`onStop`](sf-SoundRecorder.md#onstop-1) | `function` | Inherited from [`SoundRecorder`](sf-SoundRecorder.md#soundrecorder) |
| [`m_impl`](sf-SoundRecorder.md#m_impl-2) | `variable` | Inherited from [`SoundRecorder`](sf-SoundRecorder.md#soundrecorder) |

## Inherited from [`SoundRecorder`](sf-SoundRecorder.md#soundrecorder)

| Kind | Name | Description |
|------|------|-------------|
| `function` | [`~SoundRecorder`](sf-SoundRecorder.md#soundrecorder-1) `virtual` | destructor |
| `function` | [`start`](sf-SoundRecorder.md#start) `nodiscard` | Start the capture. |
| `function` | [`stop`](sf-SoundRecorder.md#stop-1)  | Stop the capture. |
| `function` | [`getSampleRate`](sf-SoundRecorder.md#getsamplerate-2) `const` `nodiscard` | Get the sample rate. |
| `function` | [`setDevice`](sf-SoundRecorder.md#setdevice) `nodiscard` | Set the audio capture device. |
| `function` | [`getDevice`](sf-SoundRecorder.md#getdevice) `const` `nodiscard` | Get the name of the current audio capture device. |
| `function` | [`setChannelCount`](sf-SoundRecorder.md#setchannelcount)  | Set the channel count of the audio capture device. |
| `function` | [`getChannelCount`](sf-SoundRecorder.md#getchannelcount-2) `const` `nodiscard` | Get the number of channels used by this recorder. |
| `function` | [`getChannelMap`](sf-SoundRecorder.md#getchannelmap-2) `const` `nodiscard` | Get the map of position in sample frame to sound channel. |
| `function` | [`getAvailableDevices`](sf-SoundRecorder.md#getavailabledevices) `static` `nodiscard` | Get a list of the names of all available audio capture devices. |
| `function` | [`getDefaultDevice`](sf-SoundRecorder.md#getdefaultdevice) `static` `nodiscard` | Get the name of the default audio capture device. |
| `function` | [`isAvailable`](sf-SoundRecorder.md#isavailable) `static` `nodiscard` | Check if the system supports audio capture. |
| `function` | [`SoundRecorder`](sf-SoundRecorder.md#soundrecorder-2)  | Default constructor. |
| `function` | [`onStart`](sf-SoundRecorder.md#onstart-1) `virtual` | Start capturing audio data. |
| `function` | [`onProcessSamples`](sf-SoundRecorder.md#onprocesssamples-1) `virtual` `nodiscard` | Process a new chunk of recorded samples. |
| `function` | [`onStop`](sf-SoundRecorder.md#onstop-1) `virtual` | Stop capturing audio data. |
| `variable` | [`m_impl`](sf-SoundRecorder.md#m_impl-2)  | Implementation details. |

## Public Methods

| Return | Name | Description |
|--------|------|-------------|
|  | [`~SoundBufferRecorder`](#soundbufferrecorder-1) `override` | destructor |
| const [`SoundBuffer`](sf-SoundBuffer.md#soundbuffer-1) & | [`getBuffer`](#getbuffer-1) `const` `nodiscard` | Get the sound buffer containing the captured audio data. |

---

{#soundbufferrecorder-1}

### ~SoundBufferRecorder

`override`

```cpp
~SoundBufferRecorder() override
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundBufferRecorder.hpp:55

destructor

---

{#getbuffer-1}

### getBuffer

`const` `nodiscard`

```cpp
[[nodiscard]] const SoundBuffer & getBuffer() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundBufferRecorder.hpp:68

Get the sound buffer containing the captured audio data.

The sound buffer is valid only after the capture has ended. This function provides a read-only access to the internal sound buffer, but it can be copied if you need to make any modification to it.

#### Returns
Read-only access to the sound buffer

## Protected Methods

| Return | Name | Description |
|--------|------|-------------|
| `bool` | [`onStart`](#onstart) `virtual` `nodiscard` `override` | Start capturing audio data. |
| `bool` | [`onProcessSamples`](#onprocesssamples) `virtual` `nodiscard` `override` | Process a new chunk of recorded samples. |
| `void` | [`onStop`](#onstop) `virtual` `override` | Stop capturing audio data. |

---

{#onstart}

### onStart

`virtual` `nodiscard` `override`

```cpp
[[nodiscard]] virtual bool onStart() override
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundBufferRecorder.hpp:77

Start capturing audio data.

#### Returns
`true` to start the capture, or `false` to abort it

#### Reimplements

- [`onStart`](sf-SoundRecorder.md#onstart-1)

---

{#onprocesssamples}

### onProcessSamples

`virtual` `nodiscard` `override`

```cpp
[[nodiscard]] virtual bool onProcessSamples(const std::int16_t * samples, std::size_t sampleCount) override
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundBufferRecorder.hpp:88

Process a new chunk of recorded samples.

#### Returns
`true` to continue the capture, or `false` to stop it

#### Reimplements

- [`onProcessSamples`](sf-SoundRecorder.md#onprocesssamples-1)

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `samples` | `const std::int16_t *` | Pointer to the new chunk of recorded samples |
| `sampleCount` | `std::size_t` | Number of samples pointed by *samples* |

---

{#onstop}

### onStop

`virtual` `override`

```cpp
virtual void onStop() override
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundBufferRecorder.hpp:94

Stop capturing audio data.

#### Reimplements

- [`onStop`](sf-SoundRecorder.md#onstop-1)

## Private Attributes

| Return | Name | Description |
|--------|------|-------------|
| `std::vector< std::int16_t >` | [`m_samples`](#m_samples-1)  | Temporary sample buffer to hold the recorded data. |
| [`SoundBuffer`](sf-SoundBuffer.md#soundbuffer-1) | [`m_buffer`](#m_buffer)  | [Sound](sf-Sound.md#sound) buffer that will contain the recorded data. |

---

{#m_samples-1}

### m_samples

```cpp
std::vector< std::int16_t > m_samples
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundBufferRecorder.hpp:100

Temporary sample buffer to hold the recorded data.

---

{#m_buffer}

### m_buffer

```cpp
SoundBuffer m_buffer
```

Type: [`SoundBuffer`](sf-SoundBuffer.md#soundbuffer-1)

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundBufferRecorder.hpp:101

[Sound](sf-Sound.md#sound) buffer that will contain the recorded data.

