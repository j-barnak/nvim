{#vertexarray}

# VertexArray

```cpp
#include <VertexArray.hpp>
```

```cpp
class VertexArray
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/VertexArray.hpp:51

> **Inherits:** [`Drawable`](sf-Drawable.md#drawable)

Set of one or more 2D primitives.

`[sf::VertexArray](#vertexarray)` is a very simple wrapper around a dynamic array of vertices and a primitives type.

It inherits `[sf::Drawable](sf-Drawable.md#drawable)`, but unlike other drawables it is not transformable.

Example: 
```cpp
sf::VertexArray lines(sf::PrimitiveType::LineStrip, 4);
lines[0].position = sf::Vector2f(10, 0);
lines[1].position = sf::Vector2f(20, 0);
lines[2].position = sf::Vector2f(30, 5);
lines[3].position = sf::Vector2f(40, 2);

window.draw(lines);
```

**See also**: `[sf::Vertex](sf-Vertex.md#vertex)`

## List of all members

| Name | Kind | Owner |
|------|------|-------|
| [`VertexArray`](#vertexarray-1) | `function` | Declared here |
| [`VertexArray`](#vertexarray-2) | `function` | Declared here |
| [`getVertexCount`](#getvertexcount) | `function` | Declared here |
| [`operator[]`](#operator-78) | `function` | Declared here |
| [`operator[]`](#operator-79) | `function` | Declared here |
| [`clear`](#clear-5) | `function` | Declared here |
| [`resize`](#resize-4) | `function` | Declared here |
| [`append`](#append-1) | `function` | Declared here |
| [`setPrimitiveType`](#setprimitivetype) | `function` | Declared here |
| [`getPrimitiveType`](#getprimitivetype) | `function` | Declared here |
| [`getBounds`](#getbounds) | `function` | Declared here |
| [`begin`](#begin-2) | `function` | Declared here |
| [`begin`](#begin-3) | `function` | Declared here |
| [`end`](#end-2) | `function` | Declared here |
| [`end`](#end-3) | `function` | Declared here |
| [`m_vertices`](#m_vertices-3) | `variable` | Declared here |
| [`m_primitiveType`](#m_primitivetype) | `variable` | Declared here |
| [`draw`](#draw-8) | `function` | Declared here |
| [`RenderTarget`](sf-Drawable.md#rendertarget) | `friend` | Inherited from [`Drawable`](sf-Drawable.md#drawable) |
| [`~Drawable`](sf-Drawable.md#drawable-1) | `function` | Inherited from [`Drawable`](sf-Drawable.md#drawable) |
| [`draw`](sf-Drawable.md#draw) | `function` | Inherited from [`Drawable`](sf-Drawable.md#drawable) |

## Inherited from [`Drawable`](sf-Drawable.md#drawable)

| Kind | Name | Description |
|------|------|-------------|
| `friend` | [`RenderTarget`](sf-Drawable.md#rendertarget)  |  |
| `function` | [`~Drawable`](sf-Drawable.md#drawable-1) `virtual` | Virtual destructor. |
| `function` | [`draw`](sf-Drawable.md#draw) `virtual` `const` | Draw the object to a render target. |

## Public Methods

| Return | Name | Description |
|--------|------|-------------|
|  | [`VertexArray`](#vertexarray-1)  | Default constructor. |
|  | [`VertexArray`](#vertexarray-2) `explicit` | Construct the vertex array with a type and an initial number of vertices. |
| `std::size_t` | [`getVertexCount`](#getvertexcount) `const` `nodiscard` | Return the vertex count. |
| [`Vertex`](sf-Vertex.md#vertex) & | [`operator[]`](#operator-78) `nodiscard` | Get a read-write access to a vertex by its index. |
| const [`Vertex`](sf-Vertex.md#vertex) & | [`operator[]`](#operator-79) `const` `nodiscard` | Get a read-only access to a vertex by its index. |
| `void` | [`clear`](#clear-5)  | Clear the vertex array. |
| `void` | [`resize`](#resize-4)  | Resize the vertex array. |
| `void` | [`append`](#append-1)  | Add a vertex to the array. |
| `void` | [`setPrimitiveType`](#setprimitivetype)  | Set the type of primitives to draw. |
| [`PrimitiveType`](PrimitiveType.md#primitivetype) | [`getPrimitiveType`](#getprimitivetype) `const` `nodiscard` | Get the type of primitives drawn by the vertex array. |
| [`FloatRect`](sf.md#floatrect) | [`getBounds`](#getbounds) `const` `nodiscard` | Compute the bounding rectangle of the vertex array. |
| std::vector< [`Vertex`](sf-Vertex.md#vertex) >::iterator | [`begin`](#begin-2) `nodiscard` | Return an iterator to the beginning of the array. |
| std::vector< [`Vertex`](sf-Vertex.md#vertex) >::const_iterator | [`begin`](#begin-3) `const` `nodiscard` | Return an iterator to the beginning of the array. |
| std::vector< [`Vertex`](sf-Vertex.md#vertex) >::iterator | [`end`](#end-2) `nodiscard` | Return an iterator to the end of the array. |
| std::vector< [`Vertex`](sf-Vertex.md#vertex) >::const_iterator | [`end`](#end-3) `const` `nodiscard` | Return an iterator to the end of the array. |

---

{#vertexarray-1}

### VertexArray

```cpp
VertexArray() = default
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/VertexArray.hpp:60

Default constructor.

Creates an empty vertex array.

---

{#vertexarray-2}

### VertexArray

`explicit`

```cpp
explicit VertexArray(PrimitiveType type, std::size_t vertexCount = 0)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/VertexArray.hpp:69

Construct the vertex array with a type and an initial number of vertices.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `type` | [`PrimitiveType`](PrimitiveType.md#primitivetype) | Type of primitives |
| `vertexCount` | `std::size_t` | Initial number of vertices in the array |

---

{#getvertexcount}

### getVertexCount

`const` `nodiscard`

```cpp
[[nodiscard]] std::size_t getVertexCount() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/VertexArray.hpp:77

Return the vertex count.

#### Returns
Number of vertices in the array

---

{#operator-78}

### operator[]

`nodiscard`

```cpp
[[nodiscard]] Vertex & operator[](std::size_t index)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/VertexArray.hpp:93

Get a read-write access to a vertex by its index.

This function doesn't check `index`, it must be in range [0, `[getVertexCount()](#getvertexcount)` - 1]. The behavior is undefined otherwise.

#### Returns
Reference to the `index`-th vertex

**See also**: `[getVertexCount](#getvertexcount)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `index` | `std::size_t` | Index of the vertex to get |

---

{#operator-79}

### operator[]

`const` `nodiscard`

```cpp
[[nodiscard]] const Vertex & operator[](std::size_t index) const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/VertexArray.hpp:109

Get a read-only access to a vertex by its index.

This function doesn't check `index`, it must be in range [0, `[getVertexCount()](#getvertexcount)` - 1]. The behavior is undefined otherwise.

#### Returns
Const reference to the `index`-th vertex

**See also**: `[getVertexCount](#getvertexcount)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `index` | `std::size_t` | Index of the vertex to get |

---

{#clear-5}

### clear

```cpp
void clear()
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/VertexArray.hpp:120

Clear the vertex array.

This function removes all the vertices from the array. It doesn't deallocate the corresponding memory, so that adding new vertices after clearing doesn't involve reallocating all the memory.

---

{#resize-4}

### resize

```cpp
void resize(std::size_t vertexCount)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/VertexArray.hpp:134

Resize the vertex array.

If `vertexCount` is greater than the current size, the previous vertices are kept and new (default-constructed) vertices are added. If `vertexCount` is less than the current size, existing vertices are removed from the array.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `vertexCount` | `std::size_t` | New size of the array (number of vertices) |

---

{#append-1}

### append

```cpp
void append(const Vertex & vertex)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/VertexArray.hpp:142

Add a vertex to the array.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `vertex` | const [`Vertex`](sf-Vertex.md#vertex) & | [Vertex](sf-Vertex.md#vertex) to add |

---

{#setprimitivetype}

### setPrimitiveType

```cpp
void setPrimitiveType(PrimitiveType type)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/VertexArray.hpp:157

Set the type of primitives to draw.

This function defines how the vertices must be interpreted when it's time to draw them: 

* As points 
* As lines 
* As triangles The default primitive type is `[sf::PrimitiveType::Points](graphics.md#group__graphics_1gga5ee56ac1339984909610713096283b1ba75dd5f1160a3f02b6fae89c54361a1b3)`.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `type` | [`PrimitiveType`](PrimitiveType.md#primitivetype) | Type of primitive |

---

{#getprimitivetype}

### getPrimitiveType

`const` `nodiscard`

```cpp
[[nodiscard]] PrimitiveType getPrimitiveType() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/VertexArray.hpp:165

Get the type of primitives drawn by the vertex array.

#### Returns
Primitive type

---

{#getbounds}

### getBounds

`const` `nodiscard`

```cpp
[[nodiscard]] FloatRect getBounds() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/VertexArray.hpp:176

Compute the bounding rectangle of the vertex array.

This function returns the minimal axis-aligned rectangle that contains all the vertices of the array.

#### Returns
Bounding rectangle of the vertex array

---

{#begin-2}

### begin

`nodiscard`

```cpp
[[nodiscard]] std::vector< Vertex >::iterator begin()
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/VertexArray.hpp:186

Return an iterator to the beginning of the array.

#### Returns
Read-write iterator to the beginning of the vertices

**See also**: `[end](#end-2)`

---

{#begin-3}

### begin

`const` `nodiscard`

```cpp
[[nodiscard]] std::vector< Vertex >::const_iterator begin() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/VertexArray.hpp:196

Return an iterator to the beginning of the array.

#### Returns
Read-only iterator to the beginning of the vertices

**See also**: `[end](#end-2)`

---

{#end-2}

### end

`nodiscard`

```cpp
[[nodiscard]] std::vector< Vertex >::iterator end()
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/VertexArray.hpp:210

Return an iterator to the end of the array.

The end iterator refers to 1 position past the last vertex; thus it represents an invalid vertex and should never be accessed.

#### Returns
Read-write iterator to the end of the vertices

**See also**: `[begin](#begin-2)`

---

{#end-3}

### end

`const` `nodiscard`

```cpp
[[nodiscard]] std::vector< Vertex >::const_iterator end() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/VertexArray.hpp:224

Return an iterator to the end of the array.

The end iterator refers to 1 position past the last vertex; thus it represents an invalid vertex and should never be accessed.

#### Returns
Read-only iterator to the end of the vertices

**See also**: `[begin](#begin-2)`

## Private Attributes

| Return | Name | Description |
|--------|------|-------------|
| std::vector< [`Vertex`](sf-Vertex.md#vertex) > | [`m_vertices`](#m_vertices-3)  | Vertices contained in the array. |
| [`PrimitiveType`](PrimitiveType.md#primitivetype) | [`m_primitiveType`](#m_primitivetype)  | Type of primitives to draw. |

---

{#m_vertices-3}

### m_vertices

```cpp
std::vector< Vertex > m_vertices
```

Type: std::vector< [`Vertex`](sf-Vertex.md#vertex) >

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/VertexArray.hpp:239

Vertices contained in the array.

---

{#m_primitivetype}

### m_primitiveType

```cpp
PrimitiveType m_primitiveType {PrimitiveType::Points}
```

Type: [`PrimitiveType`](PrimitiveType.md#primitivetype)

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/VertexArray.hpp:240

Type of primitives to draw.

## Private Methods

| Return | Name | Description |
|--------|------|-------------|
| `void` | [`draw`](#draw-8) `virtual` `const` `override` | Draw the vertex array to a render target. |

---

{#draw-8}

### draw

`virtual` `const` `override`

```cpp
virtual void draw(RenderTarget & target, RenderStates states) const override
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/VertexArray.hpp:234

Draw the vertex array to a render target.

#### Reimplements

- [`draw`](sf-Drawable.md#draw)

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `target` | [`RenderTarget`](sf-RenderTarget.md#rendertarget-1) & | Render target to draw to |
| `states` | [`RenderStates`](sf-RenderStates.md#renderstates) | Current render states |

