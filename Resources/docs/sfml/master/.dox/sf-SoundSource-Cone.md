{#cone}

# Cone

```cpp
#include <SoundSource.hpp>
```

```cpp
struct Cone
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundSource.hpp:72

Structure defining the properties of a directional cone.

Sounds will play at gain 1 when the listener is positioned within the inner angle of the cone. Sounds will play at `outerGain` when the listener is positioned outside the outer angle of the cone. The gain declines linearly from 1 to `outerGain` as the listener moves from the inner angle to the outer angle.

## Public Attributes

| Return | Name | Description |
|--------|------|-------------|
| [`Angle`](sf-Angle.md#angle) | [`innerAngle`](#innerangle)  | Inner angle. |
| [`Angle`](sf-Angle.md#angle) | [`outerAngle`](#outerangle)  | Outer angle. |
| `float` | [`outerGain`](#outergain)  | Outer gain. |

---

{#innerangle}

### innerAngle

```cpp
Angle innerAngle
```

Type: [`Angle`](sf-Angle.md#angle)

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundSource.hpp:74

Inner angle.

---

{#outerangle}

### outerAngle

```cpp
Angle outerAngle
```

Type: [`Angle`](sf-Angle.md#angle)

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundSource.hpp:75

Outer angle.

---

{#outergain}

### outerGain

```cpp
float outerGain {}
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Audio/SoundSource.hpp:76

Outer gain.

