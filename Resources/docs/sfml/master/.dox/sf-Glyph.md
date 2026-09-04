{#glyph}

# Glyph

```cpp
#include <Glyph.hpp>
```

```cpp
struct Glyph
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Glyph.hpp:41

Structure describing a glyph.

A glyph is the visual representation of a character.

The `[sf::Glyph](#glyph)` structure provides the information needed to handle the glyph: 

* its coordinates in the font's texture 
* its bounding rectangle 
* the offset to apply to get the starting position of the next glyph
**See also**: `[sf::Font](sf-Font.md#font)`

## Public Attributes

| Return | Name | Description |
|--------|------|-------------|
| `float` | [`advance`](#advance)  | Offset to move horizontally to the next character. |
| `int` | [`lsbDelta`](#lsbdelta)  | Left offset after forced autohint. Internally used by getKerning() |
| `int` | [`rsbDelta`](#rsbdelta)  | Right offset after forced autohint. Internally used by getKerning() |
| [`FloatRect`](sf.md#floatrect) | [`bounds`](#bounds)  | Bounding rectangle of the glyph, in coordinates relative to the baseline. |
| [`IntRect`](sf.md#intrect) | [`textureRect`](#texturerect)  | [Texture](sf-Texture.md#texture-2) coordinates of the glyph inside the font's texture. |

---

{#advance}

### advance

```cpp
float advance {}
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Glyph.hpp:43

Offset to move horizontally to the next character.

---

{#lsbdelta}

### lsbDelta

```cpp
int lsbDelta {}
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Glyph.hpp:44

Left offset after forced autohint. Internally used by getKerning()

---

{#rsbdelta}

### rsbDelta

```cpp
int rsbDelta {}
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Glyph.hpp:45

Right offset after forced autohint. Internally used by getKerning()

---

{#bounds}

### bounds

```cpp
FloatRect bounds
```

Type: [`FloatRect`](sf.md#floatrect)

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Glyph.hpp:46

Bounding rectangle of the glyph, in coordinates relative to the baseline.

---

{#texturerect}

### textureRect

```cpp
IntRect textureRect
```

Type: [`IntRect`](sf.md#intrect)

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Glyph.hpp:47

[Texture](sf-Texture.md#texture-2) coordinates of the glyph inside the font's texture.

