{#page}

# Page

```cpp
struct Page
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Font.hpp:472

Structure defining a page of glyphs.

## Public Attributes

| Return | Name | Description |
|--------|------|-------------|
| `GlyphTable` | [`glyphs`](#glyphs)  | Table mapping code points to their corresponding glyph. |
| [`Texture`](sf-Texture.md#texture-2) | [`texture`](#texture)  | [Texture](sf-Texture.md#texture-2) containing the pixels of the glyphs. |
| `unsigned int` | [`nextRow`](#nextrow)  | Y position of the next new row in the texture. |
| `std::vector< Row >` | [`rows`](#rows)  | List containing the position of all the existing rows. |

---

{#glyphs}

### glyphs

```cpp
GlyphTable glyphs
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Font.hpp:476

Table mapping code points to their corresponding glyph.

---

{#texture}

### texture

```cpp
Texture texture
```

Type: [`Texture`](sf-Texture.md#texture-2)

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Font.hpp:477

[Texture](sf-Texture.md#texture-2) containing the pixels of the glyphs.

---

{#nextrow}

### nextRow

```cpp
unsigned int nextRow {3}
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Font.hpp:478

Y position of the next new row in the texture.

---

{#rows}

### rows

```cpp
std::vector< Row > rows
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Font.hpp:479

List containing the position of all the existing rows.

## Public Methods

| Return | Name | Description |
|--------|------|-------------|
|  | [`Page`](#page-1) `explicit` |  |

---

{#page-1}

### Page

`explicit`

```cpp
explicit Page(bool smooth)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Font.hpp:474

