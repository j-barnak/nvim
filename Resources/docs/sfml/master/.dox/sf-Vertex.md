{#vertex}

# Vertex

```cpp
#include <Vertex.hpp>
```

```cpp
struct Vertex
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Vertex.hpp:43

Point with color and texture coordinates.

By default, the vertex color is white and texture coordinates are (0, 0).

A vertex is an improved point. It has a position and other extra attributes that will be used for drawing: in SFML, vertices also have a color and a pair of texture coordinates.

The vertex is the building block of drawing. Everything which is visible on screen is made of vertices. They are grouped as 2D primitives (lines, triangles, ...), and these primitives are grouped to create even more complex 2D entities such as sprites, texts, etc.

If you use the graphical entities of SFML (sprite, text, shape) you won't have to deal with vertices directly. But if you want to define your own 2D entities, such as tiled maps or particle systems, using vertices will allow you to get maximum performances.

Example: 
```cpp
// define a 100x100 square, red, with a 10x10 texture mapped on it
sf::Vertex vertices[]
{
    {{  0.0f,   0.0f}, sf::Color::Red, { 0.0f,  0.0f}},
    {{  0.0f, 100.0f}, sf::Color::Red, { 0.0f, 10.0f}},
    {{100.0f, 100.0f}, sf::Color::Red, {10.0f, 10.0f}},
    {{  0.0f,   0.0f}, sf::Color::Red, { 0.0f,  0.0f}},
    {{100.0f, 100.0f}, sf::Color::Red, {10.0f, 10.0f}},
    {{100.0f,   0.0f}, sf::Color::Red, {10.0f,  0.0f}}
};

// draw it
window.draw(vertices, 6, sf::PrimitiveType::Triangles);
```

It is recommended to use aggregate initialization to create vertex objects, which initializes the members in order.

On a C++20-compliant compiler (or where supported as an extension) it is possible to use "designated initializers" to only initialize a subset of members, with the restriction of having to follow the same order in which they are defined.

Example: 
```cpp
// C++17 and above
sf::Vertex v0{{5.0f, 5.0f}};                               // explicit 'position', implicit 'color' and 'texCoords'
sf::Vertex v1{{5.0f, 5.0f}, sf::Color::Red};               // explicit 'position' and 'color', implicit 'texCoords'
sf::Vertex v2{{5.0f, 5.0f}, sf::Color::Red, {1.0f, 1.0f}}; // everything is explicitly specified

// C++20 and above (or compilers supporting "designated initializers" as an extension)
sf::Vertex v3{
   .position{5.0f, 5.0f},
   .texCoords{1.0f, 1.0f}
};
```

Note: Although texture coordinates are supposed to be an integer amount of pixels, their type is float because of some buggy graphics drivers that are not able to process integer coordinates correctly.

**See also**: `[sf::VertexArray](sf-VertexArray.md#vertexarray)`

## Public Attributes

| Return | Name | Description |
|--------|------|-------------|
| [`Vector2f`](sf.md#vector2f) | [`position`](#position-10)  | 2D position of the vertex |
| [`Color`](sf-Color.md#color) | [`color`](#color-4)  | [Color](sf-Color.md#color) of the vertex. |
| [`Vector2f`](sf.md#vector2f) | [`texCoords`](#texcoords)  | Coordinates of the texture's pixel to map to the vertex NOLINT(readability-redundant-member-init) |

---

{#position-10}

### position

```cpp
Vector2f position
```

Type: [`Vector2f`](sf.md#vector2f)

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Vertex.hpp:48

2D position of the vertex

---

{#color-4}

### color

```cpp
Color color {Color::White}
```

Type: [`Color`](sf-Color.md#color)

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Vertex.hpp:49

[Color](sf-Color.md#color) of the vertex.

---

{#texcoords}

### texCoords

```cpp
Vector2f texCoords {}
```

Type: [`Vector2f`](sf.md#vector2f)

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Vertex.hpp:50

Coordinates of the texture's pixel to map to the vertex NOLINT(readability-redundant-member-init)

