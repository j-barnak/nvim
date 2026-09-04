{#mousebuttonreleased}

# MouseButtonReleased

```cpp
#include <Event.hpp>
```

```cpp
struct MouseButtonReleased
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Event.hpp:155

[Mouse](sf-Mouse.md#mouse) button released event subtype.

## Public Attributes

| Return | Name | Description |
|--------|------|-------------|
| [`Mouse::Button`](Button.md#button-4) | [`button`](#button-3)  | Code of the button that has been released. |
| [`Vector2i`](sf.md#vector2i) | [`position`](#position-2)  | Position of the mouse pointer, relative to the top left of the owner window. |

---

{#button-3}

### button

```cpp
Mouse::Button button {}
```

Type: [`Mouse::Button`](Button.md#button-4)

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Event.hpp:157

Code of the button that has been released.

---

{#position-2}

### position

```cpp
Vector2i position
```

Type: [`Vector2i`](sf.md#vector2i)

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Event.hpp:158

Position of the mouse pointer, relative to the top left of the owner window.

