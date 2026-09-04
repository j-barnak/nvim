{#contextsettings}

# ContextSettings

```cpp
#include <ContextSettings.hpp>
```

```cpp
class ContextSettings
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/ContextSettings.hpp:38

Structure defining the settings of the OpenGL context attached to a window.

[ContextSettings](#contextsettings) allows to define several advanced settings of the OpenGL context attached to a window. All these settings with the exception of the compatibility flag and anti-aliasing level have no impact on the regular SFML rendering (graphics module), so you may need to use this structure only if you're using SFML as a windowing system for custom OpenGL rendering.

The depthBits and stencilBits members define the number of bits per pixel requested for the (respectively) depth and stencil buffers.

antiAliasingLevel represents the requested number of multisampling levels for anti-aliasing.

majorVersion and minorVersion define the version of the OpenGL context that you want. Only versions greater or equal to 3.0 are relevant; versions lesser than 3.0 are all handled the same way (i.e. you can use any version < 3.0 if you don't want an OpenGL 3 context).

When requesting a context with a version greater or equal to 3.2, you have the option of specifying whether the context should follow the core or compatibility profile of all newer (>= 3.2) OpenGL specifications. For versions 3.0 and 3.1 there is only the core profile. By default a compatibility context is created. You only need to specify the core flag if you want a core profile context to use with your own OpenGL rendering. **Warning: The graphics module will not function if you request a core profile context. Make sure the attributes are set to Default if you want to use the graphics module.**

Setting the debug attribute flag will request a context with additional debugging features enabled. Depending on the system, this might be required for advanced OpenGL debugging. OpenGL debugging is disabled by default.

**Special Note for macOS:** Apple only supports choosing between either a legacy context (OpenGL 2.1) or a core context (OpenGL version depends on the operating system version but is at least 3.2). Compatibility contexts are not supported. Further information is available on the [OpenGL Capabilities Tables](https://developer.apple.com/opengl/capabilities/index.html) page. macOS also currently does not support debug contexts.

Please note that these values are only a hint. No failure will be reported if one or more of these values are not supported by the system; instead, SFML will try to find the closest valid match. You can then retrieve the settings that the window actually used to create its context, with `[Window::getSettings()](sf-Window.md#getsettings-1)`.

## Public Attributes

| Return | Name | Description |
|--------|------|-------------|
| `unsigned int` | [`depthBits`](#depthbits)  | Bits of the depth buffer. |
| `unsigned int` | [`stencilBits`](#stencilbits)  | Bits of the stencil buffer. |
| `unsigned int` | [`antiAliasingLevel`](#antialiasinglevel)  | Level of anti-aliasing. |
| `unsigned int` | [`majorVersion`](#majorversion)  | Major number of the context version to create. |
| `unsigned int` | [`minorVersion`](#minorversion)  | Minor number of the context version to create. |
| `std::uint32_t` | [`attributeFlags`](#attributeflags)  | The attribute flags to create the context with. |
| `bool` | [`sRgbCapable`](#srgbcapable)  | Whether the context framebuffer is sRGB capable. |

---

{#depthbits}

### depthBits

```cpp
unsigned int depthBits {}
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/ContextSettings.hpp:55

Bits of the depth buffer.

---

{#stencilbits}

### stencilBits

```cpp
unsigned int stencilBits {}
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/ContextSettings.hpp:56

Bits of the stencil buffer.

---

{#antialiasinglevel}

### antiAliasingLevel

```cpp
unsigned int antiAliasingLevel {}
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/ContextSettings.hpp:57

Level of anti-aliasing.

---

{#majorversion}

### majorVersion

```cpp
unsigned int majorVersion {1}
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/ContextSettings.hpp:58

Major number of the context version to create.

---

{#minorversion}

### minorVersion

```cpp
unsigned int minorVersion {1}
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/ContextSettings.hpp:59

Minor number of the context version to create.

---

{#attributeflags}

### attributeFlags

```cpp
std::uint32_t attributeFlags {Attribute::Default}
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/ContextSettings.hpp:60

The attribute flags to create the context with.

---

{#srgbcapable}

### sRgbCapable

```cpp
bool sRgbCapable {}
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/ContextSettings.hpp:61

Whether the context framebuffer is sRGB capable.

## Public Types

| Name | Description |
|------|-------------|
| [`Attribute`](#attribute)  | Enumeration of the context attribute flags. |

---

{#attribute}

### Attribute

```cpp
enum Attribute
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/ContextSettings.hpp:44

Enumeration of the context attribute flags.

| Value | Description |
|-------|-------------|
| `Default` | Non-debug, compatibility context (this and the core attribute are mutually exclusive) |
| `Core` | Core attribute. |
| `Debug` | Debug attribute. |
