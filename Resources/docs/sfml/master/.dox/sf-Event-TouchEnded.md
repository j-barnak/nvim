{#touchended}

# TouchEnded

```cpp
#include <Event.hpp>
```

```cpp
struct TouchEnded
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Event.hpp:292

[Touch](sf-Touch.md#touch) ended event subtype.

## Public Attributes

| Return | Name | Description |
|--------|------|-------------|
| `unsigned int` | [`finger`](#finger-1)  | Index of the finger in case of multi-touch events. |
| [`Vector2i`](sf.md#vector2i) | [`position`](#position-6)  | Final position of the touch, relative to the top left of the owner window. |

---

{#finger-1}

### finger

```cpp
unsigned int finger {}
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Event.hpp:294

Index of the finger in case of multi-touch events.

---

{#position-6}

### position

```cpp
Vector2i position
```

Type: [`Vector2i`](sf.md#vector2i)

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Event.hpp:295

Final position of the touch, relative to the top left of the owner window.

