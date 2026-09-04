{#soundrecorder}

# SoundRecorder

```cpp
#include <SoundRecorder.hpp>
```

```cpp
class SoundRecorder
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundRecorder.hpp:48

> **Subclassed by:** [`SoundBufferRecorder`](sf-SoundBufferRecorder.md#soundbufferrecorder)

Abstract base class for capturing sound data.

`[sf::SoundBuffer](sf-SoundBuffer.md#soundbuffer-1)` provides a simple interface to access the audio recording capabilities of the computer (the microphone). As an abstract base class, it only cares about capturing sound samples, the task of making something useful with them is left to the derived class. Note that SFML provides a built-in specialization for saving the captured data to a sound buffer (see `[sf::SoundBufferRecorder](sf-SoundBufferRecorder.md#soundbufferrecorder)`).

A derived class has only one virtual function to override: 

* `onProcessSamples` provides the new chunks of audio samples while the capture happens

Moreover, two additional virtual functions can be overridden as well if necessary: 

* `onStart` is called before the capture happens, to perform custom initializations 
* `onStop` is called after the capture ends, to perform custom cleanup

The audio capture feature may not be supported or activated on every platform, thus it is recommended to check its availability with the [isAvailable()](#isavailable) function. If it returns `false`, then any attempt to use an audio recorder will fail.

If you have multiple sound input devices connected to your computer (for example: microphone, external sound card, webcam mic, ...) you can get a list of all available devices through the `[getAvailableDevices()](#getavailabledevices)` function. You can then select a device by calling `[setDevice()](#setdevice)` with the appropriate device. Otherwise the default capturing device will be used.

By default the recording is in 16-bit mono. Using the setChannelCount method you can change the number of channels used by the audio capture device to record. Note that you have to decide whether you want to record in mono or stereo before starting the recording.

It is important to note that the audio capture happens in a separate thread, so that it doesn't block the rest of the program. In particular, the `onProcessSamples` virtual function (but not `onStart` and not `onStop`) will be called from this separate thread. It is important to keep this in mind, because you may have to take care of synchronization issues if you share data between threads. Another thing to bear in mind is that you must call `[stop()](#stop-1)` in the destructor of your derived class, so that the recording thread finishes before your object is destroyed.

Usage example: 
```cpp
class CustomRecorder : public sf::SoundRecorder
{
public:
    ~CustomRecorder()
    {
        // Make sure to stop the recording thread
        stop();
    }

private:
    bool onStart() override // optional
    {
        // Initialize whatever has to be done before the capture starts
        ...

        // Return true to start playing
        return true;
    }

    [[nodiscard]] bool onProcessSamples(const std::int16_t* samples, std::size_t sampleCount) override
    {
        // Do something with the new chunk of samples (store them, send them, ...)
        ...

        // Return true to continue playing
        return true;
    }

    void onStop() override // optional
    {
        // Clean up whatever has to be done after the capture ends
        ...
    }
};

// Usage
if (CustomRecorder::isAvailable())
{
    CustomRecorder recorder;

    if (!recorder.start())
        return -1;

    ...
    recorder.stop();
}
```

**See also**: `[sf::SoundBufferRecorder](sf-SoundBufferRecorder.md#soundbufferrecorder)`

## Public Methods

| Return | Name | Description |
|--------|------|-------------|
|  | [`~SoundRecorder`](#soundrecorder-1) `virtual` | destructor |
| `bool` | [`start`](#start) `nodiscard` | Start the capture. |
| `void` | [`stop`](#stop-1)  | Stop the capture. |
| `unsigned int` | [`getSampleRate`](#getsamplerate-2) `const` `nodiscard` | Get the sample rate. |
| `bool` | [`setDevice`](#setdevice) `nodiscard` | Set the audio capture device. |
| `const std::string &` | [`getDevice`](#getdevice) `const` `nodiscard` | Get the name of the current audio capture device. |
| `void` | [`setChannelCount`](#setchannelcount)  | Set the channel count of the audio capture device. |
| `unsigned int` | [`getChannelCount`](#getchannelcount-2) `const` `nodiscard` | Get the number of channels used by this recorder. |
| const std::vector< [`SoundChannel`](SoundChannel.md#soundchannel) > & | [`getChannelMap`](#getchannelmap-2) `const` `nodiscard` | Get the map of position in sample frame to sound channel. |

---

{#soundrecorder-1}

### ~SoundRecorder

`virtual`

```cpp
virtual ~SoundRecorder()
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundRecorder.hpp:55

destructor

---

{#start}

### start

`nodiscard`

```cpp
[[nodiscard]] bool start(unsigned int sampleRate = 44100)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundRecorder.hpp:79

Start the capture.

The `sampleRate` parameter defines the number of audio samples captured per second. The higher, the better the quality (for example, 44100 samples/sec is CD quality). This function uses its own thread so that it doesn't block the rest of the program while the capture runs. Please note that only one capture can happen at the same time. You can select which capture device will be used by passing the name to the `[setDevice()](#setdevice)` method. If none was selected before, the default capture device will be used. You can get a list of the names of all available capture devices by calling `[getAvailableDevices()](#getavailabledevices)`.

#### Returns
`true`, if start of capture was successful

**See also**: `[stop](#stop-1)`, `[getAvailableDevices](#getavailabledevices)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `sampleRate` | `unsigned int` | Desired capture rate, in number of samples per second |

---

{#stop-1}

### stop

```cpp
void stop()
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundRecorder.hpp:87

Stop the capture.

**See also**: `[start](#start)`

---

{#getsamplerate-2}

### getSampleRate

`const` `nodiscard`

```cpp
[[nodiscard]] unsigned int getSampleRate() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundRecorder.hpp:99

Get the sample rate.

The sample rate defines the number of audio samples captured per second. The higher, the better the quality (for example, 44100 samples/sec is CD quality).

#### Returns
Sample rate, in samples per second

---

{#setdevice}

### setDevice

`nodiscard`

```cpp
[[nodiscard]] bool setDevice(const std::string & name)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundRecorder.hpp:139

Set the audio capture device.

This function sets the audio capture device to the device with the given `name`. It can be called on the fly (i.e: while recording). If you do so while recording and opening the device fails, it stops the recording.

#### Returns
`true`, if it was able to set the requested device

**See also**: `[getAvailableDevices](#getavailabledevices)`, `[getDefaultDevice](#getdefaultdevice)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `name` | `const std::string &` | The name of the audio capture device |

---

{#getdevice}

### getDevice

`const` `nodiscard`

```cpp
[[nodiscard]] const std::string & getDevice() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundRecorder.hpp:147

Get the name of the current audio capture device.

#### Returns
The name of the current audio capture device

---

{#setchannelcount}

### setChannelCount

```cpp
void setChannelCount(unsigned int channelCount)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundRecorder.hpp:162

Set the channel count of the audio capture device.

This method allows you to specify the number of channels used for recording. Currently only 16-bit mono and 16-bit stereo are supported.

**See also**: `[getChannelCount](#getchannelcount-2)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `channelCount` | `unsigned int` | Number of channels. Currently only mono (1) and stereo (2) are supported. |

---

{#getchannelcount-2}

### getChannelCount

`const` `nodiscard`

```cpp
[[nodiscard]] unsigned int getChannelCount() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundRecorder.hpp:175

Get the number of channels used by this recorder.

Currently only mono and stereo are supported, so the value is either 1 (for mono) or 2 (for stereo).

#### Returns
Number of channels

**See also**: `[setChannelCount](#setchannelcount)`

---

{#getchannelmap-2}

### getChannelMap

`const` `nodiscard`

```cpp
[[nodiscard]] const std::vector< SoundChannel > & getChannelMap() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundRecorder.hpp:186

Get the map of position in sample frame to sound channel.

This is used to map a sample in the sample stream to a position during spatialization.

#### Returns
Map of position in sample frame to sound channel

## Public Static Methods

| Return | Name | Description |
|--------|------|-------------|
| `std::vector< std::string >` | [`getAvailableDevices`](#getavailabledevices) `static` `nodiscard` | Get a list of the names of all available audio capture devices. |
| `std::string` | [`getDefaultDevice`](#getdefaultdevice) `static` `nodiscard` | Get the name of the default audio capture device. |
| `bool` | [`isAvailable`](#isavailable) `static` `nodiscard` | Check if the system supports audio capture. |

---

{#getavailabledevices}

### getAvailableDevices

`static` `nodiscard`

```cpp
[[nodiscard]] static std::vector< std::string > getAvailableDevices()
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundRecorder.hpp:110

Get a list of the names of all available audio capture devices.

This function returns a vector of strings, containing the names of all available audio capture devices.

#### Returns
A vector of strings containing the names

---

{#getdefaultdevice}

### getDefaultDevice

`static` `nodiscard`

```cpp
[[nodiscard]] static std::string getDefaultDevice()
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundRecorder.hpp:122

Get the name of the default audio capture device.

This function returns the name of the default audio capture device. If none is available, an empty string is returned.

#### Returns
The name of the default audio capture device

---

{#isavailable}

### isAvailable

`static` `nodiscard`

```cpp
[[nodiscard]] static bool isAvailable()
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundRecorder.hpp:199

Check if the system supports audio capture.

This function should always be called before using the audio capture features. If it returns `false`, then any attempt to use `[sf::SoundRecorder](#soundrecorder)` or one of its derived classes will fail.

#### Returns
`true` if audio capture is supported, `false` otherwise

## Protected Methods

| Return | Name | Description |
|--------|------|-------------|
|  | [`SoundRecorder`](#soundrecorder-2)  | Default constructor. |
| `bool` | [`onStart`](#onstart-1) `virtual` | Start capturing audio data. |
| `bool` | [`onProcessSamples`](#onprocesssamples-1) `virtual` `nodiscard` | Process a new chunk of recorded samples. |
| `void` | [`onStop`](#onstop-1) `virtual` | Stop capturing audio data. |

---

{#soundrecorder-2}

### SoundRecorder

```cpp
SoundRecorder()
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundRecorder.hpp:208

Default constructor.

This constructor is only meant to be called by derived classes.

---

{#onstart-1}

### onStart

`virtual`

```cpp
virtual bool onStart()
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundRecorder.hpp:221

Start capturing audio data.

This virtual function may be overridden by a derived class if something has to be done every time a new capture starts. If not, this function can be ignored; the default implementation does nothing.

#### Returns
`true` to start the capture, or `false` to abort it

#### Reimplemented by

- [`onStart`](sf-SoundBufferRecorder.md#onstart)

---

{#onprocesssamples-1}

### onProcessSamples

`virtual` `nodiscard`

```cpp
[[nodiscard]] virtual bool onProcessSamples(const std::int16_t * samples, std::size_t sampleCount)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundRecorder.hpp:237

Process a new chunk of recorded samples.

This virtual function is called every time a new chunk of recorded data is available. The derived class can then do whatever it wants with it (storing it, playing it, sending it over the network, etc.).

#### Returns
`true` to continue the capture, or `false` to stop it

#### Reimplemented by

- [`onProcessSamples`](sf-SoundBufferRecorder.md#onprocesssamples)

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `samples` | `const std::int16_t *` | Pointer to the new chunk of recorded samples |
| `sampleCount` | `std::size_t` | Number of samples pointed by `samples` |

---

{#onstop-1}

### onStop

`virtual`

```cpp
virtual void onStop()
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundRecorder.hpp:248

Stop capturing audio data.

This virtual function may be overridden by a derived class if something has to be done every time the capture ends. If not, this function can be ignored; the default implementation does nothing.

#### Reimplemented by

- [`onStop`](sf-SoundBufferRecorder.md#onstop)

## Private Attributes

| Return | Name | Description |
|--------|------|-------------|
| `const std::unique_ptr< Impl >` | [`m_impl`](#m_impl-2)  | Implementation details. |

---

{#m_impl-2}

### m_impl

```cpp
const std::unique_ptr< Impl > m_impl
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundRecorder.hpp:255

Implementation details.

