{#mousebuttonpressed}

# MouseButtonPressed

```cpp
#include <Event.hpp>
```

```cpp
struct MouseButtonPressed
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Event.hpp:145

[Mouse](sf-Mouse.md#mouse) button pressed event subtype.

## Public Attributes

| Return | Name | Description |
|--------|------|-------------|
| [`Mouse::Button`](Button.md#button-4) | [`button`](#button-2)  | Code of the button that has been pressed. |
| [`Vector2i`](sf.md#vector2i) | [`position`](#position-1)  | Position of the mouse pointer, relative to the top left of the owner window. |

---

{#button-2}

### button

```cpp
Mouse::Button button {}
```

Type: [`Mouse::Button`](Button.md#button-4)

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Event.hpp:147

Code of the button that has been pressed.

---

{#position-1}

### position

```cpp
Vector2i position
```

Type: [`Vector2i`](sf.md#vector2i)

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Event.hpp:148

Position of the mouse pointer, relative to the top left of the owner window.

