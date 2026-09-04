# API Reference

## Groups

| Name | Description |
|------|-------------|
| [`Audio module`](audio.md#audiomodule) | Sounds, streaming (musics or custom sources), recording, spatialization. |
| [`System module`](system.md#systemmodule) | Base module of SFML, defining various utilities. It provides vector classes, Unicode strings and conversion functions, threads and mutexes, timing classes. |
| [`Window module`](window.md#windowmodule) | Provides OpenGL-based windows, and abstractions for events and input handling. |
| [`Network module`](network.md#networkmodule) | Socket-based communication, utilities and higher-level network protocols (HTTP, FTP). |
| [`Graphics module`](graphics.md#graphicsmodule) | 2D graphics module: sprites, text, shapes, ... |

## Namespaces

| Name | Description |
|------|-------------|
| [`sf`](sf.md#sf) |  |
| [`Dns`](sf-Dns.md#dns) | Perform Domain Name System queries to lookup DNS records for various purposes. |
| [`Glsl`](sf-Glsl.md#glsl) | Namespace with GLSL types. |
| [`priv`](sf-priv.md#priv) |  |
| [`Mouse`](sf-Mouse.md#mouse) | Give access to the real-time state of the mouse. |
| [`Style`](sf-Style.md#style-1) |  |
| [`Touch`](sf-Touch.md#touch) | Give access to the real-time state of the touches. |
| [`Sensor`](sf-Sensor.md#sensor) | Give access to the real-time state of the sensors. |
| [`Vulkan`](sf-Vulkan.md#vulkan) | [Vulkan](sf-Vulkan.md#vulkan) helper functions. |
| [`Joystick`](sf-Joystick.md#joystick) | Give access to the real-time state of the joysticks. |
| [`Keyboard`](sf-Keyboard.md#keyboard) | Give access to the real-time state of the keyboard. |
| [`Listener`](sf-Listener.md#listener) | The audio listener is the point in the scene from where all the sounds are heard. |
| [`Literals`](sf-Literals.md#literals) |  |
| [`Clipboard`](sf-Clipboard.md#clipboard) | Give access to the system clipboard. |
| [`PlaybackDevice`](sf-PlaybackDevice.md#playbackdevice) |  |

## Classes

| Name | Description |
|------|-------------|
| [`Result`](sf-Sftp-Result.md#result) | SFTP result. |
| [`Span`](sf-Music-Span.md#span) | Structure defining a time range using the template type. |
| [`Request`](sf-Http-Request.md#request) | HTTP request. |
| [`Closed`](sf-Event-Closed.md#closed) | [Closed](sf-Event-Closed.md#closed) event subtype. |
| [`Response`](sf-Http-Response.md#response-2) | HTTP response. |
| [`Resized`](sf-Event-Resized.md#resized) | [Resized](sf-Event-Resized.md#resized) event subtype. |
| [`PathResult`](sf-Sftp-PathResult.md#pathresult) | [Result](sf-Sftp-Result.md#result) of an operation returning a path. |
| [`Attributes`](sf-Sftp-Attributes.md#attributes) | File or directory attributes. |
| [`FocusLost`](sf-Event-FocusLost.md#focuslost) | Lost focus event subtype. |
| [`MouseLeft`](sf-Event-MouseLeft.md#mouseleft) | [Mouse](sf-Mouse.md#mouse) left event subtype. |
| [`Cone`](sf-SoundSource-Cone.md#cone) | Structure defining the properties of a directional cone. |
| [`KeyPressed`](sf-Event-KeyPressed.md#keypressed) | Key pressed event subtype. |
| [`MouseMoved`](sf-Event-MouseMoved.md#mousemoved) | [Mouse](sf-Mouse.md#mouse) move event subtype. |
| [`SessionInfo`](sf-Sftp-SessionInfo.md#sessioninfo) | Structure containing information about an active SFTP session. |
| [`TouchBegan`](sf-Event-TouchBegan.md#touchbegan) | [Touch](sf-Touch.md#touch) began event subtype. |
| [`TouchEnded`](sf-Event-TouchEnded.md#touchended) | [Touch](sf-Touch.md#touch) ended event subtype. |
| [`TouchMoved`](sf-Event-TouchMoved.md#touchmoved) | [Touch](sf-Touch.md#touch) moved event subtype. |
| [`Chunk`](sf-SoundStream-Chunk.md#chunk) | Structure defining a chunk of audio data to stream. |
| [`FocusGained`](sf-Event-FocusGained.md#focusgained) | Gained focus event subtype. |
| [`KeyReleased`](sf-Event-KeyReleased.md#keyreleased) | Key released event subtype. |
| [`ListingResult`](sf-Sftp-ListingResult.md#listingresult) | [Result](sf-Sftp-Result.md#result) of an operation returning a directory listing. |
| [`TextEntered`](sf-Event-TextEntered.md#textentered) | [Text](sf-Text.md#text-1) event subtype. |
| [`MouseEntered`](sf-Event-MouseEntered.md#mouseentered) | [Mouse](sf-Mouse.md#mouse) entered event subtype. |
| [`JoystickMoved`](sf-Event-JoystickMoved.md#joystickmoved) | [Joystick](sf-Joystick.md#joystick) axis move event subtype. |
| [`MouseMovedRaw`](sf-Event-MouseMovedRaw.md#mousemovedraw) | [Mouse](sf-Mouse.md#mouse) move raw event subtype. |
| [`SensorChanged`](sf-Event-SensorChanged.md#sensorchanged) | [Sensor](sf-Sensor.md#sensor) event subtype. |
| [`AttributesResult`](sf-Sftp-AttributesResult.md#attributesresult) | [Result](sf-Sftp-Result.md#result) of an operation returning attributes. |
| [`Info`](sf-SoundFileReader-Info.md#info) | Structure holding the audio properties of a sound file. |
| [`JoystickConnected`](sf-Event-JoystickConnected.md#joystickconnected) | [Joystick](sf-Joystick.md#joystick) connected event subtype. |
| [`PendingPacket`](sf-TcpSocket-PendingPacket.md#pendingpacket) | Structure holding the data of a pending packet. |
| [`MouseButtonPressed`](sf-Event-MouseButtonPressed.md#mousebuttonpressed) | [Mouse](sf-Mouse.md#mouse) button pressed event subtype. |
| [`MouseWheelScrolled`](sf-Event-MouseWheelScrolled.md#mousewheelscrolled) | [Mouse](sf-Mouse.md#mouse) wheel scrolled event subtype. |
| [`StatesCache`](sf-RenderTarget-StatesCache.md#statescache) | Render states cache. |
| [`CurrentTextureType`](sf-Shader-CurrentTextureType.md#currenttexturetype) | Special type that can be passed to [setUniform()](sf-Shader.md#setuniform), and that represents the texture of the object being drawn. |
| [`MouseButtonReleased`](sf-Event-MouseButtonReleased.md#mousebuttonreleased) | [Mouse](sf-Mouse.md#mouse) button released event subtype. |
| [`FileCloser`](sf-FileInputStream-FileCloser.md#filecloser) | Deleter for stdio file stream that closes the file stream. |
| [`JoystickDisconnected`](sf-Event-JoystickDisconnected.md#joystickdisconnected) | [Joystick](sf-Joystick.md#joystick) disconnected event subtype. |
| [`HostKey`](sf-Sftp-SessionInfo-HostKey.md#hostkey-1) | Host key used to identify a host. |
| [`JoystickButtonPressed`](sf-Event-JoystickButtonPressed.md#joystickbuttonpressed) | [Joystick](sf-Joystick.md#joystick) button pressed event subtype. |
| [`JoystickButtonReleased`](sf-Event-JoystickButtonReleased.md#joystickbuttonreleased) | [Joystick](sf-Joystick.md#joystick) button released event subtype. |
| [`StreamDeleter`](sf-InputSoundFile-StreamDeleter.md#streamdeleter) | Deleter for input streams that only conditionally deletes. |
| [`TransientContextLock`](sf-GlResource-TransientContextLock.md#transientcontextlock) | RAII helper class to temporarily lock an available context for use. |

## Macros

---

{#sfml_version_major}

### SFML_VERSION_MAJOR

```cpp
#define SFML_VERSION_MAJOR 3
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Config.hpp:31

---

{#sfml_version_minor}

### SFML_VERSION_MINOR

```cpp
#define SFML_VERSION_MINOR 2
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Config.hpp:32

---

{#sfml_version_patch}

### SFML_VERSION_PATCH

```cpp
#define SFML_VERSION_PATCH 0
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Config.hpp:33

---

{#sfml_version_is_release}

### SFML_VERSION_IS_RELEASE

```cpp
#define SFML_VERSION_IS_RELEASE false
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Config.hpp:34

---

{#sfml_debug}

### SFML_DEBUG

```cpp
#define SFML_DEBUG
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Config.hpp:127

---

{#sfml_api_export}

### SFML_API_EXPORT

```cpp
#define SFML_API_EXPORT [[gnu::visibility("default")]]
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Config.hpp:153

---

{#sfml_api_import}

### SFML_API_IMPORT

```cpp
#define SFML_API_IMPORT [[gnu::visibility("default")]]
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Config.hpp:154

---

{#sfml_define_discrete_gpu_preference}

### SFML_DEFINE_DISCRETE_GPU_PREFERENCE

```cpp
#define SFML_DEFINE_DISCRETE_GPU_PREFERENCE
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/GpuPreference.hpp:68

A macro to encourage usage of the discrete GPU.

In order to inform the Nvidia/AMD driver that an SFML application could benefit from using the more powerful discrete GPU, special symbols have to be publicly exported from the final executable.

SFML defines a helper macro to easily do this.

Place `SFML_DEFINE_DISCRETE_GPU_PREFERENCE` in the global scope of a source file that will be linked into the final executable. Typically it is best to place it where the main function is also defined.

---

{#sfml_audio_api}

### SFML_AUDIO_API

```cpp
#define SFML_AUDIO_API SFML_API_IMPORT
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/Export.hpp:42

---

{#sfml_system_api}

### SFML_SYSTEM_API

```cpp
#define SFML_SYSTEM_API SFML_API_IMPORT
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/System/Export.hpp:42

---

{#sfml_window_api}

### SFML_WINDOW_API

```cpp
#define SFML_WINDOW_API SFML_API_IMPORT
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Export.hpp:42

---

{#sfml_network_api}

### SFML_NETWORK_API

```cpp
#define SFML_NETWORK_API SFML_API_IMPORT
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Export.hpp:42

---

{#sfml_graphics_api}

### SFML_GRAPHICS_API

```cpp
#define SFML_GRAPHICS_API SFML_API_IMPORT
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Export.hpp:42

## Typedefs

---

{#vkinstance}

### VkInstance

```cpp
using VkInstance = struct VkInstance_T *
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Vulkan.hpp:35

---

{#vksurfacekhr}

### VkSurfaceKHR

```cpp
using VkSurfaceKHR = std::uint64_t
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Vulkan.hpp:47

Generated by [Moxygen](https://0state.com/moxygen)