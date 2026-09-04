{#audiomodule}

# Audio module

Sounds, streaming (musics or custom sources), recording, spatialization.

## Classes

| Name | Description |
|------|-------------|
| [`AudioResource`](sf-AudioResource.md#audioresource) | Base class for classes that require an audio device. |
| [`InputSoundFile`](sf-InputSoundFile.md#inputsoundfile) | Provide read access to sound files. |
| [`Music`](sf-Music.md#music) | Streamed music played from an audio file. |
| [`OutputSoundFile`](sf-OutputSoundFile.md#outputsoundfile) | Provide write access to sound files. |
| [`Sound`](sf-Sound.md#sound) | Regular sound that can be played in the audio environment. |
| [`SoundBuffer`](sf-SoundBuffer.md#soundbuffer-1) | Storage for audio samples defining a sound. |
| [`SoundBufferRecorder`](sf-SoundBufferRecorder.md#soundbufferrecorder) | Specialized [SoundRecorder](sf-SoundRecorder.md#soundrecorder) which stores the captured audio data into a sound buffer. |
| [`SoundFileFactory`](sf-SoundFileFactory.md#soundfilefactory) | Manages and instantiates sound file readers and writers. |
| [`SoundFileReader`](sf-SoundFileReader.md#soundfilereader) | Abstract base class for sound file decoding. |
| [`SoundFileWriter`](sf-SoundFileWriter.md#soundfilewriter) | Abstract base class for sound file encoding. |
| [`SoundRecorder`](sf-SoundRecorder.md#soundrecorder) | Abstract base class for capturing sound data. |
| [`SoundSource`](sf-SoundSource.md#soundsource) | Base class defining a sound's properties. |
| [`SoundStream`](sf-SoundStream.md#soundstream) | Abstract base class for streamed audio sources. |

## Enumerations

| Name | Description |
|------|-------------|
| [`SoundChannel`](#soundchannel)  | Types of sound channels that can be read/written from sound buffers/files. |

---

{#soundchannel}

### SoundChannel

```cpp
enum SoundChannel
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundChannel.hpp:41

Types of sound channels that can be read/written from sound buffers/files.

In multi-channel audio, each sound channel can be assigned a position. The position of the channel is used to determine where to place a sound when it is spatialized. Assigning an incorrect sound channel will result in multi-channel audio being positioned incorrectly when using spatialization.

| Value | Description |
|-------|-------------|
| `Unspecified` |  |
| `Mono` |  |
| `FrontLeft` |  |
| `FrontRight` |  |
| `FrontCenter` |  |
| `FrontLeftOfCenter` |  |
| `FrontRightOfCenter` |  |
| `LowFrequencyEffects` |  |
| `BackLeft` |  |
| `BackRight` |  |
| `BackCenter` |  |
| `SideLeft` |  |
| `SideRight` |  |
| `TopCenter` |  |
| `TopFrontLeft` |  |
| `TopFrontRight` |  |
| `TopFrontCenter` |  |
| `TopBackLeft` |  |
| `TopBackRight` |  |
| `TopBackCenter` |  |
