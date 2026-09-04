{#joystickbuttonpressed}

# JoystickButtonPressed

```cpp
#include <Event.hpp>
```

```cpp
struct JoystickButtonPressed
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Event.hpp:223

[Joystick](sf-Joystick.md#joystick) button pressed event subtype.

## Public Attributes

| Return | Name | Description |
|--------|------|-------------|
| `unsigned int` | [`joystickId`](#joystickid)  | Index of the joystick (in range [0 .. Joystick::Count - 1]) |
| `unsigned int` | [`button`](#button)  | Index of the button that has been pressed (in range [0 .. Joystick::ButtonCount - 1]) |

---

{#joystickid}

### joystickId

```cpp
unsigned int joystickId {}
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Event.hpp:225

Index of the joystick (in range [0 .. Joystick::Count - 1])

---

{#button}

### button

```cpp
unsigned int button {}
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Event.hpp:226

Index of the button that has been pressed (in range [0 .. Joystick::ButtonCount - 1])

