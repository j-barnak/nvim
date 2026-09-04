{#touch}

# Touch

Give access to the real-time state of the touches.

`[sf::Touch](#touch)` provides an interface to the state of the touches.

:::warning
This namespace is deprecated and will be removed in a future release. Events should be used instead.

:::

This namespace allows users to query the touches state at any time and directly, without having to deal with a window and its events. Compared to the `TouchBegan`, `TouchMoved` and `TouchEnded` events, `[sf::Touch](#touch)` can retrieve the state of the touches at any time (you don't need to store and update a boolean on your side in order to know if a touch is down), and you always get the real state of the touches, even if they happen when your window is out of focus and no event is triggered.

The getPosition function can be used to retrieve the current position of a touch. There are two versions: one that operates in global coordinates (relative to the desktop) and one that operates in window coordinates (relative to a specific window).

Touches are identified by an index (the "finger"), so that in multi-touch events, individual touches can be tracked correctly. As long as a finger touches the screen, it will keep the same index even if other fingers start or stop touching the screen in the meantime. As a consequence, active touch indices may not always be sequential (i.e. touch number 0 may be released while touch number 1 is still down).

Usage example: 
```cpp
if (sf::Touch::isDown(0))
{
    // touch 0 is down
}

// get global position of touch 1
sf::Vector2i globalPos = sf::Touch::getPosition(1);

// get position of touch 1 relative to a window
sf::Vector2i relativePos = sf::Touch::getPosition(1, window);
```

**See also**: `[sf::Joystick](sf-Joystick.md#joystick)`, `[sf::Keyboard](sf-Keyboard.md#keyboard)`, `[sf::Mouse](sf-Mouse.md#mouse)`

## Functions

| Return | Name | Description |
|--------|------|-------------|
| [`SFML_WINDOW_API`](api.md#sfml_window_api) bool | [`isDown`](#isdown) `nodiscard` | Check if a touch event is currently down. |
| [`SFML_WINDOW_API`](api.md#sfml_window_api)[`Vector2i`](sf.md#vector2i) | [`getPosition`](#getposition-5) `nodiscard` | Get the current position of a touch in desktop coordinates. |
| [`SFML_WINDOW_API`](api.md#sfml_window_api)[`Vector2i`](sf.md#vector2i) | [`getPosition`](#getposition-6) `nodiscard` | Get the current position of a touch in window coordinates. |

---

{#isdown}

### isDown

`nodiscard`

```cpp
[[nodiscard]] SFML_WINDOW_API bool isDown(unsigned int finger)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Touch.hpp:55

Check if a touch event is currently down.

> Deprecated: Use `[sf::Event::TouchBegan](sf-Event-TouchBegan.md#touchbegan)` and `[sf::Event::TouchEnded](sf-Event-TouchEnded.md#touchended)`

#### Returns
`true` if *finger* is currently touching the screen, `false` otherwise

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `finger` | `unsigned int` | Finger index |

---

{#getposition-5}

### getPosition

`nodiscard`

```cpp
[[nodiscard]] SFML_WINDOW_APIVector2i getPosition(unsigned int finger)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Touch.hpp:74

Get the current position of a touch in desktop coordinates.

This function returns the current touch position in global (desktop) coordinates.

> Deprecated: Use position member of `[sf::Event::TouchBegan](sf-Event-TouchBegan.md#touchbegan)`, `[sf::Event::TouchEnded](sf-Event-TouchEnded.md#touchended)` and `[sf::Event::TouchMoved](sf-Event-TouchMoved.md#touchmoved)`

#### Returns
Current position of *finger*, or undefined if it's not down

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `finger` | `unsigned int` | Finger index |

---

{#getposition-6}

### getPosition

`nodiscard`

```cpp
[[nodiscard]] SFML_WINDOW_APIVector2i getPosition(unsigned int finger, const WindowBase & relativeTo)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Touch.hpp:93

Get the current position of a touch in window coordinates.

This function returns the current touch position relative to the given window.

> Deprecated: Use position member of `[sf::Event::TouchBegan](sf-Event-TouchBegan.md#touchbegan)`, `[sf::Event::TouchEnded](sf-Event-TouchEnded.md#touchended)` and `[sf::Event::TouchMoved](sf-Event-TouchMoved.md#touchmoved)`

#### Returns
Current position of *finger*, or undefined if it's not down

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `finger` | `unsigned int` | Finger index |
| `relativeTo` | const [`WindowBase`](sf-WindowBase.md#windowbase-2) & | Reference window |

