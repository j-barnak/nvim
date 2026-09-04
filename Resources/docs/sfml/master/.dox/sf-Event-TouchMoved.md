{#touchmoved}

# TouchMoved

```cpp
#include <Event.hpp>
```

```cpp
struct TouchMoved
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Event.hpp:282

[Touch](sf-Touch.md#touch) moved event subtype.

## Public Attributes

| Return | Name | Description |
|--------|------|-------------|
| `unsigned int` | [`finger`](#finger-2)  | Index of the finger in case of multi-touch events. |
| [`Vector2i`](sf.md#vector2i) | [`position`](#position-7)  | Current position of the touch, relative to the top left of the owner window. |

---

{#finger-2}

### finger

```cpp
unsigned int finger {}
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Event.hpp:284

Index of the finger in case of multi-touch events.

---

{#position-7}

### position

```cpp
Vector2i position
```

Type: [`Vector2i`](sf.md#vector2i)

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Event.hpp:285

Current position of the touch, relative to the top left of the owner window.

