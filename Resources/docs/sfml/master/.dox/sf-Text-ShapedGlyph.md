{#shapedglyph}

# ShapedGlyph

```cpp
#include <Text.hpp>
```

```cpp
struct ShapedGlyph
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Text.hpp:127

Structure describing a glyph after shaping.

## Public Attributes

| Return | Name | Description |
|--------|------|-------------|
| [`Glyph`](sf-Glyph.md#glyph) | [`glyph`](#glyph-1)  |  |
| [`Vector2f`](sf.md#vector2f) | [`position`](#position-9)  | Position of the glyph within a text. |
| `std::uint32_t` | [`cluster`](#cluster)  | Cluster ID. |
| [`TextDirection`](TextDirection.md#textdirection) | [`textDirection`](#textdirection-1)  | [Text](sf-Text.md#text-1) direction. |
| `float` | [`baseline`](#baseline)  | The baseline position of the line this glyph is a part of. |
| `std::size_t` | [`vertexOffset`](#vertexoffset)  | Starting offset of the vertex data belonging to this glyph. |
| `std::size_t` | [`vertexCount`](#vertexcount)  | Count of vertices belonging to this glyph. |

---

{#glyph-1}

### glyph

```cpp
Glyph glyph
```

Type: [`Glyph`](sf-Glyph.md#glyph)

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Text.hpp:129

---

{#position-9}

### position

```cpp
Vector2f position
```

Type: [`Vector2f`](sf.md#vector2f)

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Text.hpp:131

Position of the glyph within a text.

---

{#cluster}

### cluster

```cpp
std::uint32_t cluster {}
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Text.hpp:132

Cluster ID.

---

{#textdirection-1}

### textDirection

```cpp
TextDirection textDirection {}
```

Type: [`TextDirection`](TextDirection.md#textdirection)

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Text.hpp:133

[Text](sf-Text.md#text-1) direction.

---

{#baseline}

### baseline

```cpp
float baseline {}
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Text.hpp:134

The baseline position of the line this glyph is a part of.

---

{#vertexoffset}

### vertexOffset

```cpp
std::size_t vertexOffset {}
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Text.hpp:135

Starting offset of the vertex data belonging to this glyph.

---

{#vertexcount}

### vertexCount

```cpp
std::size_t vertexCount {}
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Text.hpp:136

Count of vertices belonging to this glyph.

