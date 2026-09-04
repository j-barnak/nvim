{#videomode}

# VideoMode

```cpp
#include <VideoMode.hpp>
```

```cpp
class VideoMode
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/VideoMode.hpp:43

[VideoMode](#videomode) defines a video mode (size, bpp)

A video mode is defined by a width and a height (in pixels) and a depth (in bits per pixel). Video modes are used to setup windows (`[sf::Window](sf-Window.md#window)`) at creation time.

The main usage of video modes is for fullscreen mode: indeed you must use one of the valid video modes allowed by the OS (which are defined by what the monitor and the graphics card support), otherwise your window creation will just fail.

`[sf::VideoMode](#videomode)` provides a static function for retrieving the list of all the video modes supported by the system: `[getFullscreenModes()](#getfullscreenmodes)`.

A custom video mode can also be checked directly for fullscreen compatibility with its `[isValid()](#isvalid)` function.

Additionally, `[sf::VideoMode](#videomode)` provides a static function to get the mode currently used by the desktop: `[getDesktopMode()](#getdesktopmode)`. This allows to build windows with the same size or pixel depth as the current resolution.

Usage example: 
```cpp
// Display the list of all the video modes available for fullscreen
std::vector<sf::VideoMode> modes = sf::VideoMode::getFullscreenModes();
for (std::size_t i = 0; i < modes.size(); ++i)
{
    sf::VideoMode mode = modes[i];
    std::cout << "Mode #" << i << ": "
              << mode.size.x << "x" << mode.size.y << " - "
              << mode.bitsPerPixel << " bpp" << std::endl;
}

// Create a window with the same pixel depth as the desktop
sf::VideoMode desktop = sf::VideoMode::getDesktopMode();
window.create(sf::VideoMode({1024, 768}, desktop.bitsPerPixel), "SFML window");
```

## Public Attributes

| Return | Name | Description |
|--------|------|-------------|
| [`Vector2u`](sf.md#vector2u) | [`size`](#size-1)  | Video mode width and height, in pixels. |
| `unsigned int` | [`bitsPerPixel`](#bitsperpixel)  | Video mode pixel depth, in bits per pixels. |

---

{#size-1}

### size

```cpp
Vector2u size
```

Type: [`Vector2u`](sf.md#vector2u)

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/VideoMode.hpp:102

Video mode width and height, in pixels.

---

{#bitsperpixel}

### bitsPerPixel

```cpp
unsigned int bitsPerPixel {}
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/VideoMode.hpp:103

Video mode pixel depth, in bits per pixels.

## Public Methods

| Return | Name | Description |
|--------|------|-------------|
|  | [`VideoMode`](#videomode-1)  | Default constructor. |
|  | [`VideoMode`](#videomode-2) `explicit` | Construct the video mode with its attributes. |
| `bool` | [`isValid`](#isvalid) `const` `nodiscard` | Tell whether or not the video mode is valid. |

---

{#videomode-1}

### VideoMode

```cpp
VideoMode() = default
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/VideoMode.hpp:52

Default constructor.

This constructors initializes all members to 0.

---

{#videomode-2}

### VideoMode

`explicit`

```cpp
explicit VideoMode(Vector2u modeSize, unsigned int modeBitsPerPixel = 32)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/VideoMode.hpp:61

Construct the video mode with its attributes.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `modeSize` | [`Vector2u`](sf.md#vector2u) | Width and height in pixels |
| `modeBitsPerPixel` | `unsigned int` | Pixel depths in bits per pixel |

---

{#isvalid}

### isValid

`const` `nodiscard`

```cpp
[[nodiscard]] bool isValid() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/VideoMode.hpp:97

Tell whether or not the video mode is valid.

The validity of video modes is only relevant when using fullscreen windows; otherwise any video mode can be used with no restriction.

#### Returns
`true` if the video mode is valid for fullscreen mode

## Public Static Methods

| Return | Name | Description |
|--------|------|-------------|
| [`VideoMode`](#videomode) | [`getDesktopMode`](#getdesktopmode) `static` `nodiscard` | Get the current desktop video mode. |
| const std::vector< [`VideoMode`](#videomode) > & | [`getFullscreenModes`](#getfullscreenmodes) `static` `nodiscard` | Retrieve all the video modes supported in fullscreen mode. |

---

{#getdesktopmode}

### getDesktopMode

`static` `nodiscard`

```cpp
[[nodiscard]] static VideoMode getDesktopMode()
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/VideoMode.hpp:69

Get the current desktop video mode.

#### Returns
Current desktop video mode

---

{#getfullscreenmodes}

### getFullscreenModes

`static` `nodiscard`

```cpp
[[nodiscard]] static const std::vector< VideoMode > & getFullscreenModes()
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/VideoMode.hpp:85

Retrieve all the video modes supported in fullscreen mode.

When creating a fullscreen window, the video mode is restricted to be compatible with what the graphics driver and monitor support. This function returns the complete list of all video modes that can be used in fullscreen mode. The returned array is sorted from best to worst, so that the first element will always give the best mode (higher width, height and bits-per-pixel).

#### Returns
Array containing all the supported fullscreen modes

