{#joystickmoved}

# JoystickMoved

```cpp
#include <Event.hpp>
```

```cpp
struct JoystickMoved
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Event.hpp:243

[Joystick](sf-Joystick.md#joystick) axis move event subtype.

## Public Attributes

| Return | Name | Description |
|--------|------|-------------|
| `unsigned int` | [`joystickId`](#joystickid-4)  | Index of the joystick (in range [0 .. Joystick::Count - 1]) |
| [`Joystick::Axis`](Axis.md#axis-1) | [`axis`](#axis)  | Axis on which the joystick moved. |
| `float` | [`position`](#position)  | New position on the axis (in range [-100 .. 100]) |

---

{#joystickid-4}

### joystickId

```cpp
unsigned int joystickId {}
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Event.hpp:245

Index of the joystick (in range [0 .. Joystick::Count - 1])

---

{#axis}

### axis

```cpp
Joystick::Axis axis {}
```

Type: [`Joystick::Axis`](Axis.md#axis-1)

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Event.hpp:246

Axis on which the joystick moved.

---

{#position}

### position

```cpp
float position {}
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Event.hpp:247

New position on the axis (in range [-100 .. 100])

