{#mouse}

# Mouse

Give access to the real-time state of the mouse.

`[sf::Mouse](#mouse)` provides an interface to the state of the mouse. A single mouse is assumed.

This namespace allows users to query the mouse state at any time and directly, without having to deal with a window and its events. Compared to the `MouseMoved`, `MouseButtonPressed` and `MouseButtonReleased` events, `[sf::Mouse](#mouse)` can retrieve the state of the cursor and the buttons at any time (you don't need to store and update a boolean on your side in order to know if a button is pressed or released), and you always get the real state of the mouse, even if it is moved, pressed or released when your window is out of focus and no event is triggered.

The `setPosition` and `getPosition` functions can be used to change or retrieve the current position of the mouse pointer. There are two versions: one that operates in global coordinates (relative to the desktop) and one that operates in window coordinates (relative to a specific window).

Usage example: 
```cpp
if (sf::Mouse::isButtonPressed(sf::Mouse::Button::Left))
{
    // left click...
}

// get global mouse position
sf::Vector2i position = sf::Mouse::getPosition();

// set mouse position relative to a window
sf::Mouse::setPosition(sf::Vector2i(100, 200), window);
```

**See also**: `[sf::Joystick](sf-Joystick.md#joystick)`, `[sf::Keyboard](sf-Keyboard.md#keyboard)`, `[sf::Touch](sf-Touch.md#touch)`

## Enumerations

| Name | Description |
|------|-------------|
| [`Button`](#button-4)  | [Mouse](#mouse) buttons. |
| [`Wheel`](#wheel-1)  | [Mouse](#mouse) wheels. |

---

{#button-4}

### Button

```cpp
enum Button
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Mouse.hpp:49

[Mouse](#mouse) buttons.

| Value | Description |
|-------|-------------|
| `Left` | The left mouse button. |
| `Right` | The right mouse button. |
| `Middle` | The middle (wheel) mouse button. |
| `Extra1` | The first extra mouse button. |
| `Extra2` | The second extra mouse button. |

---

{#wheel-1}

### Wheel

```cpp
enum Wheel
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Mouse.hpp:65

[Mouse](#mouse) wheels.

| Value | Description |
|-------|-------------|
| `Vertical` | The vertical mouse wheel. |
| `Horizontal` | The horizontal mouse wheel. |
## Functions

| Return | Name | Description |
|--------|------|-------------|
| [`SFML_WINDOW_API`](api.md#sfml_window_api) bool | [`isButtonPressed`](#isbuttonpressed-1) `nodiscard` | Check if a mouse button is pressed. |
| [`SFML_WINDOW_API`](api.md#sfml_window_api)[`Vector2i`](sf.md#vector2i) | [`getPosition`](#getposition-3) `nodiscard` | Get the current position of the mouse in desktop coordinates. |
| [`SFML_WINDOW_API`](api.md#sfml_window_api)[`Vector2i`](sf.md#vector2i) | [`getPosition`](#getposition-4) `nodiscard` | Get the current position of the mouse in window coordinates. |
| [`SFML_WINDOW_API`](api.md#sfml_window_api) void | [`setPosition`](#setposition-3)  | Set the current position of the mouse in desktop coordinates. |
| [`SFML_WINDOW_API`](api.md#sfml_window_api) void | [`setPosition`](#setposition-4)  | Set the current position of the mouse in window coordinates. |

---

{#isbuttonpressed-1}

### isButtonPressed

`nodiscard`

```cpp
[[nodiscard]] SFML_WINDOW_API bool isButtonPressed(Button button)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Mouse.hpp:82

Check if a mouse button is pressed.

:::warning
Checking the state of buttons `[Mouse::Button::Extra1](#namespacesf_1_1Mouse_1a4fb128be433f9aafe66bc0c605daaa90a113f84d105af2b8016b3896117c9deab)` and `[Mouse::Button::Extra2](#namespacesf_1_1Mouse_1a4fb128be433f9aafe66bc0c605daaa90a83dca46dd08ad782e968d586375715e1)` is not supported on Linux with X11.

:::

#### Returns
`true` if the button is pressed, `false` otherwise

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `button` | [`Button`](Button.md#button-4) | [Button](Button.md#button-4) to check |

---

{#getposition-3}

### getPosition

`nodiscard`

```cpp
[[nodiscard]] SFML_WINDOW_APIVector2i getPosition()
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Mouse.hpp:93

Get the current position of the mouse in desktop coordinates.

This function returns the global position of the mouse cursor on the desktop.

#### Returns
Current position of the mouse

---

{#getposition-4}

### getPosition

`nodiscard`

```cpp
[[nodiscard]] SFML_WINDOW_APIVector2i getPosition(const WindowBase & relativeTo)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Mouse.hpp:106

Get the current position of the mouse in window coordinates.

This function returns the current position of the mouse cursor, relative to the given window.

#### Returns
Current position of the mouse

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `relativeTo` | const [`WindowBase`](sf-WindowBase.md#windowbase-2) & | Reference window |

---

{#setposition-3}

### setPosition

```cpp
SFML_WINDOW_API void setPosition(Vector2i position)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Mouse.hpp:121

Set the current position of the mouse in desktop coordinates.

This function sets the global position of the mouse cursor on the desktop.

:::warning
On macOS the OS API used for `setPosition` requires granting of Accessibility permission for your application. See also: [https://support.apple.com/guide/mac-help/allow-accessibility-apps-to-access-your-mac-mh43185/](https://support.apple.com/guide/mac-help/allow-accessibility-apps-to-access-your-mac-mh43185/)

:::

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `position` | [`Vector2i`](sf.md#vector2i) | New position of the mouse |

---

{#setposition-4}

### setPosition

```cpp
SFML_WINDOW_API void setPosition(Vector2i position, const WindowBase & relativeTo)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Mouse.hpp:137

Set the current position of the mouse in window coordinates.

This function sets the current position of the mouse cursor, relative to the given window.

:::warning
On macOS the OS API used for `setPosition` requires granting of Accessibility permission for your application. See also: [https://support.apple.com/guide/mac-help/allow-accessibility-apps-to-access-your-mac-mh43185/](https://support.apple.com/guide/mac-help/allow-accessibility-apps-to-access-your-mac-mh43185/)

:::

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `position` | [`Vector2i`](sf.md#vector2i) | New position of the mouse |
| `relativeTo` | const [`WindowBase`](sf-WindowBase.md#windowbase-2) & | Reference window |

## Variables

| Return | Name | Description |
|--------|------|-------------|
| `unsigned int` | [`ButtonCount`](#buttoncount-1) `static` `constexpr` | The total number of mouse buttons. |

---

{#buttoncount-1}

### ButtonCount

`static` `constexpr`

```cpp
unsigned int ButtonCount {5}
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Mouse.hpp:59

The total number of mouse buttons.

