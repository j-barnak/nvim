{#joystickdisconnected}

# JoystickDisconnected

```cpp
#include <Event.hpp>
```

```cpp
struct JoystickDisconnected
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Event.hpp:263

[Joystick](sf-Joystick.md#joystick) disconnected event subtype.

## Public Attributes

| Return | Name | Description |
|--------|------|-------------|
| `unsigned int` | [`joystickId`](#joystickid-3)  | Index of the joystick (in range [0 .. Joystick::Count - 1]) |

---

{#joystickid-3}

### joystickId

```cpp
unsigned int joystickId {}
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Event.hpp:265

Index of the joystick (in range [0 .. Joystick::Count - 1])

