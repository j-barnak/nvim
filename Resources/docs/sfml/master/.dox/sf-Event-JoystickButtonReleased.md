{#joystickbuttonreleased}

# JoystickButtonReleased

```cpp
#include <Event.hpp>
```

```cpp
struct JoystickButtonReleased
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Event.hpp:233

[Joystick](sf-Joystick.md#joystick) button released event subtype.

## Public Attributes

| Return | Name | Description |
|--------|------|-------------|
| `unsigned int` | [`joystickId`](#joystickid-1)  | Index of the joystick (in range [0 .. Joystick::Count - 1]) |
| `unsigned int` | [`button`](#button-1)  | Index of the button that has been released (in range [0 .. Joystick::ButtonCount - 1]) |

---

{#joystickid-1}

### joystickId

```cpp
unsigned int joystickId {}
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Event.hpp:235

Index of the joystick (in range [0 .. Joystick::Count - 1])

---

{#button-1}

### button

```cpp
unsigned int button {}
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Event.hpp:236

Index of the button that has been released (in range [0 .. Joystick::ButtonCount - 1])

