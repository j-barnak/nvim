{#cone-1}

# Cone

```cpp
#include <Listener.hpp>
```

```cpp
struct Cone
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/Listener.hpp:54

Structure defining the properties of a directional cone.

Sounds will play at gain 1 when they are positioned within the inner angle of the cone. Sounds will play at `outerGain` when they are positioned outside the outer angle of the cone. The gain declines linearly from 1 to `outerGain` as the sound moves from the inner angle to the outer angle.

## Public Attributes

| Return | Name | Description |
|--------|------|-------------|
| [`Angle`](sf-Angle.md#angle) | [`innerAngle`](#innerangle-1)  | Inner angle. |
| [`Angle`](sf-Angle.md#angle) | [`outerAngle`](#outerangle-1)  | Outer angle. |
| `float` | [`outerGain`](#outergain-1)  | Outer gain. |

---

{#innerangle-1}

### innerAngle

```cpp
Angle innerAngle
```

Type: [`Angle`](sf-Angle.md#angle)

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/Listener.hpp:56

Inner angle.

---

{#outerangle-1}

### outerAngle

```cpp
Angle outerAngle
```

Type: [`Angle`](sf-Angle.md#angle)

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/Listener.hpp:57

Outer angle.

---

{#outergain-1}

### outerGain

```cpp
float outerGain {}
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/Listener.hpp:58

Outer gain.

