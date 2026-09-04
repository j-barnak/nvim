{#cursor}

# Cursor

```cpp
#include <Cursor.hpp>
```

```cpp
class Cursor
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Cursor.hpp:50

[Cursor](#cursor) defines the appearance of a system cursor.

:::warning
Features related to [Cursor](#cursor) are not supported on iOS and Android.

:::

This class abstracts the operating system resources associated with either a native system cursor or a custom cursor.

After loading the cursor graphical appearance with either `[createFromPixels()](#createfrompixels)` or `[createFromSystem()](#createfromsystem)`, the cursor can be changed with `[sf::WindowBase::setMouseCursor()](sf-WindowBase.md#setmousecursor)`.

The behavior is undefined if the cursor is destroyed while in use by the window.

Usage example: 
```cpp
sf::Window window;

// ... create window as usual ...

const auto cursor = sf::Cursor::createFromSystem(sf::Cursor::Type::Hand).value();
window.setMouseCursor(cursor);
```

**See also**: `[sf::WindowBase::setMouseCursor](sf-WindowBase.md#setmousecursor)`

## Friends

| Name | Description |
|------|-------------|
| [`WindowBase`](#windowbase)  |  |

---

{#windowbase}

### WindowBase

```cpp
friend class WindowBase
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Cursor.hpp:245

## Public Methods

| Return | Name | Description |
|--------|------|-------------|
|  | [`~Cursor`](#cursor-1)  | Destructor. |
|  | [`Cursor`](#cursor-2)  | Deleted copy constructor. |
| [`Cursor`](#cursor) & | [`operator=`](#operator-19)  | Deleted copy assignment. |
|  | [`Cursor`](#cursor-3) `noexcept` | Move constructor. |
| [`Cursor`](#cursor) & | [`operator=`](#operator-20) `noexcept` | Move assignment. |
|  | [`Cursor`](#cursor-4)  | Construct a cursor with the provided image. |
|  | [`Cursor`](#cursor-5) `explicit` | Create a native system cursor. |

---

{#cursor-1}

### ~Cursor

```cpp
~Cursor()
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Cursor.hpp:121

Destructor.

This destructor releases the system resources associated with this cursor, if any.

---

{#cursor-2}

### Cursor

```cpp
Cursor(const Cursor &) = delete
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Cursor.hpp:127

Deleted copy constructor.

---

{#operator-19}

### operator=

```cpp
Cursor & operator=(const Cursor &) = delete
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Cursor.hpp:133

Deleted copy assignment.

---

{#cursor-3}

### Cursor

`noexcept`

```cpp
Cursor(Cursor &&) noexcept
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Cursor.hpp:139

Move constructor.

---

{#operator-20}

### operator=

`noexcept`

```cpp
Cursor & operator=(Cursor &&) noexcept
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Cursor.hpp:145

Move assignment.

---

{#cursor-4}

### Cursor

```cpp
Cursor(const std::uint8_t * pixels, Vector2u size, Vector2u hotspot)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Cursor.hpp:177

Construct a cursor with the provided image.

`pixels` must be an array of `size` pixels in 32-bit RGBA format. If not, this will cause undefined behavior.

If `pixels` is `nullptr` or either of `size`'s properties are 0, the current cursor is left unchanged and the function will return `false`.

In addition to specifying the pixel data, you can also specify the location of the hotspot of the cursor. The hotspot is the pixel coordinate within the cursor image which will be located exactly where the mouse pointer position is. Any mouse actions that are performed will return the window/screen location of the hotspot.

:::warning
On Unix platforms which do not support colored cursors, the pixels are mapped into a monochrome bitmap: pixels with an alpha channel to 0 are transparent, black if the RGB channel are close to zero, and white otherwise.

:::

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `pixels` | `const std::uint8_t *` | Array of pixels of the image |
| `size` | [`Vector2u`](sf.md#vector2u) | Width and height of the image |
| `hotspot` | [`Vector2u`](sf.md#vector2u) | (x,y) location of the hotspot |

#### Exceptions

| Exception | Description |
|-----------|-------------|
| `sf::Exception` | if the cursor could not be constructed |

---

{#cursor-5}

### Cursor

`explicit`

```cpp
explicit Cursor(Type type)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Cursor.hpp:194

Create a native system cursor.

Refer to the list of cursor available on each system (see `[sf::Cursor::Type](Type.md#type)`) to know whether a given cursor is expected to load successfully or is not supported by the operating system.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `type` | [`Type`](Type.md#type) | Native system cursor type |

#### Exceptions

| Exception | Description |
|-----------|-------------|
| `sf::Exception` | if the corresponding cursor is not natively supported by the operating system |

## Public Static Methods

| Return | Name | Description |
|--------|------|-------------|
| std::optional< [`Cursor`](#cursor) > | [`createFromPixels`](#createfrompixels) `static` `nodiscard` | Create a cursor with the provided image. |
| std::optional< [`Cursor`](#cursor) > | [`createFromSystem`](#createfromsystem) `static` `nodiscard` | Create a native system cursor. |

---

{#createfrompixels}

### createFromPixels

`static` `nodiscard`

```cpp
[[nodiscard]] static std::optional< Cursor > createFromPixels(const std::uint8_t * pixels, Vector2u size, Vector2u hotspot)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Cursor.hpp:226

Create a cursor with the provided image.

`pixels` must be an array of `size` pixels in 32-bit RGBA format. If not, this will cause undefined behavior.

If `pixels` is `nullptr` or either of `size`'s properties are 0, the current cursor is left unchanged and the function will return `false`.

In addition to specifying the pixel data, you can also specify the location of the hotspot of the cursor. The hotspot is the pixel coordinate within the cursor image which will be located exactly where the mouse pointer position is. Any mouse actions that are performed will return the window/screen location of the hotspot.

:::warning
On Unix platforms which do not support colored cursors, the pixels are mapped into a monochrome bitmap: pixels with an alpha channel to 0 are transparent, black if the RGB channel are close to zero, and white otherwise.

:::

#### Returns
[Cursor](#cursor) if the cursor was successfully loaded; `std::nullopt` otherwise

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `pixels` | `const std::uint8_t *` | Array of pixels of the image |
| `size` | [`Vector2u`](sf.md#vector2u) | Width and height of the image |
| `hotspot` | [`Vector2u`](sf.md#vector2u) | (x,y) location of the hotspot |

---

{#createfromsystem}

### createFromSystem

`static` `nodiscard`

```cpp
[[nodiscard]] static std::optional< Cursor > createFromSystem(Type type)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Cursor.hpp:242

Create a native system cursor.

Refer to the list of cursor available on each system (see `[sf::Cursor::Type](Type.md#type)`) to know whether a given cursor is expected to load successfully or is not supported by the operating system.

#### Returns
[Cursor](#cursor) if and only if the corresponding cursor is natively supported by the operating system; `std::nullopt` otherwise

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `type` | [`Type`](Type.md#type) | Native system cursor type |

## Public Types

| Name | Description |
|------|-------------|
| [`Type`](#type)  | Enumeration of the native system cursor types. |

---

{#type}

### Type

```cpp
enum Type
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Cursor.hpp:89

Enumeration of the native system cursor types.

Refer to the following table to determine which cursor is available on which platform.

[Type](Type.md#type)|Linux  |macOS  |Windows
--------- | --------- | --------- | ---------
`[sf::Cursor::Type::Arrow](#classsf_1_1Cursor_1ab9ab152aec1f8a4955e34ccae08f930aa0f4e1aaabd074689b7d3ead824d1ee8e)`|yes  |yes  |yes
`[sf::Cursor::Type::ArrowWait](#classsf_1_1Cursor_1ab9ab152aec1f8a4955e34ccae08f930aae2315b2069e368f88915c29b53b0b211)`|no  |no  |yes
`[sf::Cursor::Type::Wait](#classsf_1_1Cursor_1ab9ab152aec1f8a4955e34ccae08f930aa0f68101772bd5397ef8eb1b632798652)`|yes  |no  |yes
`[sf::Cursor::Type::Text](#classsf_1_1Cursor_1ab9ab152aec1f8a4955e34ccae08f930aa9dffbf69ffba8bc38bc4e01abf4b1675)`|yes  |yes  |yes
`[sf::Cursor::Type::Hand](#classsf_1_1Cursor_1ab9ab152aec1f8a4955e34ccae08f930aaa78b1ac16c0cd02168097fc9a9bd7604)`|yes  |yes  |yes
`[sf::Cursor::Type::SizeHorizontal](#classsf_1_1Cursor_1ab9ab152aec1f8a4955e34ccae08f930aa2bcbe975c410bda244e4b5cdc76acb92)`|yes  |yes  |yes
`[sf::Cursor::Type::SizeVertical](#classsf_1_1Cursor_1ab9ab152aec1f8a4955e34ccae08f930aa0081a84c822d1216a7fb598b28580a63)`|yes  |yes  |yes
`[sf::Cursor::Type::SizeTopLeftBottomRight](#classsf_1_1Cursor_1ab9ab152aec1f8a4955e34ccae08f930aa29fa98d79e5d4fbcd58f51c289932856)`|no  |yes*  |yes
`[sf::Cursor::Type::SizeBottomLeftTopRight](#classsf_1_1Cursor_1ab9ab152aec1f8a4955e34ccae08f930aae0b4a2835909038962ad4513bc3ada18)`|no  |yes*  |yes
`[sf::Cursor::Type::SizeLeft](#classsf_1_1Cursor_1ab9ab152aec1f8a4955e34ccae08f930aa2d63e85c849c2364e6bfb33c3e0738a8)`|yes  |yes**  |yes**
`[sf::Cursor::Type::SizeRight](#classsf_1_1Cursor_1ab9ab152aec1f8a4955e34ccae08f930aae9fca55e52735b9cdad7feb6e9e2a13e)`|yes  |yes**  |yes**
`[sf::Cursor::Type::SizeTop](#classsf_1_1Cursor_1ab9ab152aec1f8a4955e34ccae08f930aaaf0ff4ba0b413f0de34c318d978e2a79)`|yes  |yes**  |yes**
`[sf::Cursor::Type::SizeBottom](#classsf_1_1Cursor_1ab9ab152aec1f8a4955e34ccae08f930aa35d3d1d5c34e6a124d2d57e39014356f)`|yes  |yes**  |yes**
`[sf::Cursor::Type::SizeTopLeft](#classsf_1_1Cursor_1ab9ab152aec1f8a4955e34ccae08f930aa46e9c0755cc2152213a4997d6a26c3b0)`|yes  |yes**  |yes**
`[sf::Cursor::Type::SizeTopRight](#classsf_1_1Cursor_1ab9ab152aec1f8a4955e34ccae08f930aa84f7ef771196cacbd7eab64c1e901504)`|yes  |yes**  |yes**
`[sf::Cursor::Type::SizeBottomLeft](#classsf_1_1Cursor_1ab9ab152aec1f8a4955e34ccae08f930aada08d08fe4d17077b7f622815e84ad11)`|yes  |yes**  |yes**
`[sf::Cursor::Type::SizeBottomRight](#classsf_1_1Cursor_1ab9ab152aec1f8a4955e34ccae08f930aa574c1fd63a9f58096aabd2c78b73c429)`|yes  |yes**  |yes**
`[sf::Cursor::Type::SizeAll](#classsf_1_1Cursor_1ab9ab152aec1f8a4955e34ccae08f930aa6ba8042ceea48823ba6c4c72b9354cea)`|yes  |no  |yes
`[sf::Cursor::Type::Cross](#classsf_1_1Cursor_1ab9ab152aec1f8a4955e34ccae08f930aae76b449b9fc8536af7557ffa6321d269)`|yes  |yes  |yes
`[sf::Cursor::Type::Help](#classsf_1_1Cursor_1ab9ab152aec1f8a4955e34ccae08f930aa6a26f548831e6a8c26bfbbd9f6ec61e0)`|yes  |yes*  |yes
`[sf::Cursor::Type::NotAllowed](#classsf_1_1Cursor_1ab9ab152aec1f8a4955e34ccae08f930aafa89fcc81e9dcfd52671c968fe4e6ddf)`|yes  |yes  |yes

* These cursor types are undocumented so may not be available on all versions, but have been tested on 10.13

** On Windows and macOS, double-headed arrows are used

| Value | Description |
|-------|-------------|
| `Arrow` | Arrow cursor (default) |
| `ArrowWait` | Busy arrow cursor. |
| `Wait` | Busy cursor. |
| `Text` | I-beam, cursor when hovering over a field allowing text entry. |
| `Hand` | Pointing hand cursor. |
| `SizeHorizontal` | Horizontal double arrow cursor. |
| `SizeVertical` | Vertical double arrow cursor. |
| `SizeTopLeftBottomRight` | Double arrow cursor going from top-left to bottom-right. |
| `SizeBottomLeftTopRight` | Double arrow cursor going from bottom-left to top-right. |
| `SizeLeft` | Left arrow cursor on Linux, same as SizeHorizontal on other platforms. |
| `SizeRight` | Right arrow cursor on Linux, same as SizeHorizontal on other platforms. |
| `SizeTop` | Up arrow cursor on Linux, same as SizeVertical on other platforms. |
| `SizeBottom` | Down arrow cursor on Linux, same as SizeVertical on other platforms. |
| `SizeTopLeft` | Top-left arrow cursor on Linux, same as SizeTopLeftBottomRight on other platforms. |
| `SizeBottomRight` | Bottom-right arrow cursor on Linux, same as SizeTopLeftBottomRight on other platforms. |
| `SizeBottomLeft` | Bottom-left arrow cursor on Linux, same as SizeBottomLeftTopRight on other platforms. |
| `SizeTopRight` | Top-right arrow cursor on Linux, same as SizeBottomLeftTopRight on other platforms. |
| `SizeAll` | Combination of SizeHorizontal and SizeVertical. |
| `Cross` | Crosshair cursor. |
| `Help` | Help cursor. |
| `NotAllowed` | Action not allowed cursor. |
## Private Attributes

| Return | Name | Description |
|--------|------|-------------|
| `std::unique_ptr< priv::CursorImpl >` | [`m_impl`](#m_impl-4)  | Platform-specific implementation of the cursor. |

---

{#m_impl-4}

### m_impl

```cpp
std::unique_ptr< priv::CursorImpl > m_impl
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Cursor.hpp:267

Platform-specific implementation of the cursor.

## Private Methods

| Return | Name | Description |
|--------|------|-------------|
|  | [`Cursor`](#cursor-6)  | Default constructor. |
| `const priv::CursorImpl &` | [`getImpl`](#getimpl) `const` `nodiscard` | Get access to the underlying implementation. |

---

{#cursor-6}

### Cursor

```cpp
Cursor()
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Cursor.hpp:251

Default constructor.

---

{#getimpl}

### getImpl

`const` `nodiscard`

```cpp
[[nodiscard]] const priv::CursorImpl & getImpl() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Cursor.hpp:262

Get access to the underlying implementation.

This is primarily designed for `[sf::WindowBase::setMouseCursor](sf-WindowBase.md#setmousecursor)`, hence the friendship.

#### Returns
a reference to the OS-specific implementation

