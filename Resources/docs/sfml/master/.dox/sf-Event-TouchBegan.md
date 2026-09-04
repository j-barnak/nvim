{#touchbegan}

# TouchBegan

```cpp
#include <Event.hpp>
```

```cpp
struct TouchBegan
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Event.hpp:272

[Touch](sf-Touch.md#touch) began event subtype.

## Public Attributes

| Return | Name | Description |
|--------|------|-------------|
| `unsigned int` | [`finger`](#finger)  | Index of the finger in case of multi-touch events. |
| [`Vector2i`](sf.md#vector2i) | [`position`](#position-5)  | Start position of the touch, relative to the top left of the owner window. |

---

{#finger}

### finger

```cpp
unsigned int finger {}
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Event.hpp:274

Index of the finger in case of multi-touch events.

---

{#position-5}

### position

```cpp
Vector2i position
```

Type: [`Vector2i`](sf.md#vector2i)

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Window/Event.hpp:275

Start position of the touch, relative to the top left of the owner window.

