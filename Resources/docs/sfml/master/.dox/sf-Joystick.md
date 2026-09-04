{#joystick}

# Joystick

Give access to the real-time state of the joysticks.

`[sf::Joystick](#joystick)` provides an interface to the state of the joysticks. Each joystick is identified by an index that is passed to the functions in this namespace.

This namespace allows users to query the state of joysticks at any time and directly, without having to deal with a window and its events. Compared to the `JoystickMoved`, `JoystickButtonPressed` and `JoystickButtonReleased` events, `[sf::Joystick](#joystick)` can retrieve the state of axes and buttons of joysticks at any time (you don't need to store and update a boolean on your side in order to know if a button is pressed or released), and you always get the real state of joysticks, even if they are moved, pressed or released when your window is out of focus and no event is triggered.

SFML supports: 

* 8 joysticks (`sf::Joystick::Count`) 
* 32 buttons per joystick (`sf::Joystick::ButtonCount`) 
* 8 axes per joystick (`sf::Joystick::AxisCount`)

Unlike the keyboard or mouse, the state of joysticks is sometimes not directly available (depending on the OS), therefore an `[update()](#update-1)` function must be called in order to update the current state of joysticks. When you have a window with event handling, this is done automatically, you don't need to call anything. But if you have no window, or if you want to check joysticks state before creating one, you must call `[sf::Joystick::update](#update-1)` explicitly.

Usage example: 
```cpp
// Is joystick #0 connected?
bool connected = sf::Joystick::isConnected(0);

// How many buttons does joystick #0 support?
unsigned int buttons = sf::Joystick::getButtonCount(0);

// Does joystick #0 define a X axis?
bool hasX = sf::Joystick::hasAxis(0, sf::Joystick::Axis::X);

// Is button #2 pressed on joystick #0?
bool pressed = sf::Joystick::isButtonPressed(0, 2);

// What's the current position of the Y axis on joystick #0?
float position = sf::Joystick::getAxisPosition(0, sf::Joystick::Axis::Y);
```

**See also**: `[sf::Keyboard](sf-Keyboard.md#keyboard)`, `[sf::Mouse](sf-Mouse.md#mouse)`

## Classes

| Name | Description |
|------|-------------|
| [`Identification`](sf-Joystick-Identification.md#identification) | Structure holding a joystick's identification. |

## Enumerations

| Name | Description |
|------|-------------|
| [`Axis`](#axis-1)  | Axes supported by SFML joysticks. |

---

{#axis-1}

### Axis

```cpp
enum Axis
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Joystick.hpp:54

Axes supported by SFML joysticks.

| Value | Description |
|-------|-------------|
| `X` | The X axis. |
| `Y` | The Y axis. |
| `Z` | The Z axis. |
| `R` | The R axis. |
| `U` | The U axis. |
| `V` | The V axis. |
| `PovX` | The X axis of the point-of-view hat. |
| `PovY` | The Y axis of the point-of-view hat. |
## Functions

| Return | Name | Description |
|--------|------|-------------|
| [`SFML_WINDOW_API`](api.md#sfml_window_api) bool | [`isConnected`](#isconnected) `nodiscard` | Check if a joystick is connected. |
| [`SFML_WINDOW_API`](api.md#sfml_window_api) unsigned int | [`getButtonCount`](#getbuttoncount) `nodiscard` | Return the number of buttons supported by a joystick. |
| [`SFML_WINDOW_API`](api.md#sfml_window_api) bool | [`hasAxis`](#hasaxis) `nodiscard` | Check if a joystick supports a given axis. |
| [`SFML_WINDOW_API`](api.md#sfml_window_api) bool | [`isButtonPressed`](#isbuttonpressed) `nodiscard` | Check if a joystick button is pressed. |
| [`SFML_WINDOW_API`](api.md#sfml_window_api) float | [`getAxisPosition`](#getaxisposition) `nodiscard` | Get the current position of a joystick axis. |
| [`SFML_WINDOW_API`](api.md#sfml_window_api)[`Identification`](sf-Joystick-Identification.md#identification) | [`getIdentification`](#getidentification) `nodiscard` | Get the joystick information. |
| [`SFML_WINDOW_API`](api.md#sfml_window_api) void | [`update`](#update-1)  | Update the states of all joysticks. |

---

{#isconnected}

### isConnected

`nodiscard`

```cpp
[[nodiscard]] SFML_WINDOW_API bool isConnected(unsigned int joystick)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Joystick.hpp:85

Check if a joystick is connected.

#### Returns
`true` if the joystick is connected, `false` otherwise

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `joystick` | `unsigned int` | Index of the joystick to check |

---

{#getbuttoncount}

### getButtonCount

`nodiscard`

```cpp
[[nodiscard]] SFML_WINDOW_API unsigned int getButtonCount(unsigned int joystick)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Joystick.hpp:97

Return the number of buttons supported by a joystick.

If the joystick is not connected, this function returns 0.

#### Returns
Number of buttons supported by the joystick

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `joystick` | `unsigned int` | Index of the joystick |

---

{#hasaxis}

### hasAxis

`nodiscard`

```cpp
[[nodiscard]] SFML_WINDOW_API bool hasAxis(unsigned int joystick, Axis axis)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Joystick.hpp:110

Check if a joystick supports a given axis.

If the joystick is not connected, this function returns `false`.

#### Returns
`true` if the joystick supports the axis, `false` otherwise

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `joystick` | `unsigned int` | Index of the joystick |
| `axis` | [`Axis`](Axis.md#axis-1) | [Axis](Axis.md#axis-1) to check |

---

{#isbuttonpressed}

### isButtonPressed

`nodiscard`

```cpp
[[nodiscard]] SFML_WINDOW_API bool isButtonPressed(unsigned int joystick, unsigned int button)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Joystick.hpp:123

Check if a joystick button is pressed.

If the joystick is not connected, this function returns `false`.

#### Returns
`true` if the button is pressed, `false` otherwise

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `joystick` | `unsigned int` | Index of the joystick |
| `button` | `unsigned int` | Button to check |

---

{#getaxisposition}

### getAxisPosition

`nodiscard`

```cpp
[[nodiscard]] SFML_WINDOW_API float getAxisPosition(unsigned int joystick, Axis axis)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Joystick.hpp:136

Get the current position of a joystick axis.

If the joystick is not connected, this function returns 0.

#### Returns
Current position of the axis, in range [-100 .. 100]

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `joystick` | `unsigned int` | Index of the joystick |
| `axis` | [`Axis`](Axis.md#axis-1) | [Axis](Axis.md#axis-1) to check |

---

{#getidentification}

### getIdentification

`nodiscard`

```cpp
[[nodiscard]] SFML_WINDOW_APIIdentification getIdentification(unsigned int joystick)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Joystick.hpp:146

Get the joystick information.

#### Returns
Structure containing joystick information.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `joystick` | `unsigned int` | Index of the joystick |

---

{#update-1}

### update

```cpp
SFML_WINDOW_API void update()
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Joystick.hpp:157

Update the states of all joysticks.

This function is used internally by SFML, so you normally don't have to call it explicitly. However, you may need to call it if you have no window yet (or no window at all): in this case the joystick states are not updated automatically.

## Variables

| Return | Name | Description |
|--------|------|-------------|
| `unsigned int` | [`Count`](#count) `static` `constexpr` | Constants related to joysticks capabilities. |
| `unsigned int` | [`ButtonCount`](#buttoncount) `static` `constexpr` | Maximum number of supported buttons. |
| `unsigned int` | [`AxisCount`](#axiscount) `static` `constexpr` | Maximum number of supported axes. |

---

{#count}

### Count

`static` `constexpr`

```cpp
unsigned int Count {8}
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Joystick.hpp:45

Constants related to joysticks capabilities.

Maximum number of supported joysticks

---

{#buttoncount}

### ButtonCount

`static` `constexpr`

```cpp
unsigned int ButtonCount {32}
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Joystick.hpp:46

Maximum number of supported buttons.

---

{#axiscount}

### AxisCount

`static` `constexpr`

```cpp
unsigned int AxisCount {8}
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Joystick.hpp:47

Maximum number of supported axes.

