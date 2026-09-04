{#mousewheelscrolled}

# MouseWheelScrolled

```cpp
#include <Event.hpp>
```

```cpp
struct MouseWheelScrolled
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Event.hpp:134

[Mouse](sf-Mouse.md#mouse) wheel scrolled event subtype.

## Public Attributes

| Return | Name | Description |
|--------|------|-------------|
| [`Mouse::Wheel`](Wheel.md#wheel-1) | [`wheel`](#wheel)  | Which wheel (for mice with multiple ones) |
| `float` | [`delta`](#delta-1)  | Wheel offset (positive is up/left, negative is down/right). High-precision mice may use non-integral offsets. |
| [`Vector2i`](sf.md#vector2i) | [`position`](#position-4)  | Position of the mouse pointer, relative to the top left of the owner window. |

---

{#wheel}

### wheel

```cpp
Mouse::Wheel wheel {}
```

Type: [`Mouse::Wheel`](Wheel.md#wheel-1)

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Event.hpp:136

Which wheel (for mice with multiple ones)

---

{#delta-1}

### delta

```cpp
float delta {}
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Event.hpp:137

Wheel offset (positive is up/left, negative is down/right). High-precision mice may use non-integral offsets.

---

{#position-4}

### position

```cpp
Vector2i position
```

Type: [`Vector2i`](sf.md#vector2i)

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Event.hpp:138

Position of the mouse pointer, relative to the top left of the owner window.

