{#vertexbuffer}

# VertexBuffer

```cpp
#include <VertexBuffer.hpp>
```

```cpp
class VertexBuffer
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/VertexBuffer.hpp:50

> **Inherits:** [`Drawable`](sf-Drawable.md#drawable), [`GlResource`](sf-GlResource.md#glresource)

[Vertex](sf-Vertex.md#vertex) buffer storage for one or more 2D primitives.

`[sf::VertexBuffer](#vertexbuffer)` is a simple wrapper around a dynamic buffer of vertices and a primitives type.

Unlike `[sf::VertexArray](sf-VertexArray.md#vertexarray)`, the vertex data is stored in graphics memory.

In situations where a large amount of vertex data would have to be transferred from system memory to graphics memory every frame, using `[sf::VertexBuffer](#vertexbuffer)` can help. By using a `[sf::VertexBuffer](#vertexbuffer)`, data that has not been changed between frames does not have to be re-transferred from system to graphics memory as would be the case with `[sf::VertexArray](sf-VertexArray.md#vertexarray)`. If data transfer is a bottleneck, this can lead to performance gains.

Using `[sf::VertexBuffer](#vertexbuffer)`, the user also has the ability to only modify a portion of the buffer in graphics memory. This way, a large buffer can be allocated at the start of the application and only the applicable portions of it need to be updated during the course of the application. This allows the user to take full control of data transfers between system and graphics memory if they need to.

In special cases, the user can make use of multiple threads to update vertex data in multiple distinct regions of the buffer simultaneously. This might make sense when e.g. the position of multiple objects has to be recalculated very frequently. The computation load can be spread across multiple threads as long as there are no other data dependencies.

Simultaneous updates to the vertex buffer are not guaranteed to be carried out by the driver in any specific order. Updating the same region of the buffer from multiple threads will not cause undefined behavior, however the final state of the buffer will be unpredictable.

Simultaneous updates of distinct non-overlapping regions of the buffer are also not guaranteed to complete in a specific order. However, in this case the user can make sure to synchronize the writer threads at well-defined points in their code. The driver will make sure that all pending data transfers complete before the vertex buffer is sourced by the rendering pipeline.

It inherits `[sf::Drawable](sf-Drawable.md#drawable)`, but unlike other drawables it is not transformable.

Example: 
```cpp
std::array<sf::Vertex, 15> vertices;
...
sf::VertexBuffer triangles(sf::PrimitiveType::Triangles);
triangles.create(vertices.size());
triangles.update(vertices.data());
...
window.draw(triangles);
```

**See also**: `[sf::Vertex](sf-Vertex.md#vertex)`, `[sf::VertexArray](sf-VertexArray.md#vertexarray)`

## List of all members

| Name | Kind | Owner |
|------|------|-------|
| [`VertexBuffer`](#vertexbuffer-1) | `function` | Declared here |
| [`VertexBuffer`](#vertexbuffer-2) | `function` | Declared here |
| [`VertexBuffer`](#vertexbuffer-3) | `function` | Declared here |
| [`VertexBuffer`](#vertexbuffer-4) | `function` | Declared here |
| [`VertexBuffer`](#vertexbuffer-5) | `function` | Declared here |
| [`~VertexBuffer`](#vertexbuffer-6) | `function` | Declared here |
| [`create`](#create-11) | `function` | Declared here |
| [`getVertexCount`](#getvertexcount-1) | `function` | Declared here |
| [`update`](#update-11) | `function` | Declared here |
| [`update`](#update-12) | `function` | Declared here |
| [`update`](#update-13) | `function` | Declared here |
| [`operator=`](#operator-80) | `function` | Declared here |
| [`swap`](#swap-1) | `function` | Declared here |
| [`getNativeHandle`](#getnativehandle-4) | `function` | Declared here |
| [`setPrimitiveType`](#setprimitivetype-1) | `function` | Declared here |
| [`getPrimitiveType`](#getprimitivetype-1) | `function` | Declared here |
| [`setUsage`](#setusage) | `function` | Declared here |
| [`getUsage`](#getusage) | `function` | Declared here |
| [`bind`](#bind-3) | `function` | Declared here |
| [`isAvailable`](#isavailable-4) | `function` | Declared here |
| [`Usage`](Usage.md#usage) | `enum` | Declared here |
| [`m_buffer`](#m_buffer-2) | `variable` | Declared here |
| [`m_size`](#m_size-5) | `variable` | Declared here |
| [`m_primitiveType`](#m_primitivetype-1) | `variable` | Declared here |
| [`m_usage`](#m_usage) | `variable` | Declared here |
| [`draw`](#draw-9) | `function` | Declared here |
| [`RenderTarget`](sf-Drawable.md#rendertarget) | `friend` | Inherited from [`Drawable`](sf-Drawable.md#drawable) |
| [`~Drawable`](sf-Drawable.md#drawable-1) | `function` | Inherited from [`Drawable`](sf-Drawable.md#drawable) |
| [`draw`](sf-Drawable.md#draw) | `function` | Inherited from [`Drawable`](sf-Drawable.md#drawable) |
| [`GlResource`](sf-GlResource.md#glresource-1) | `function` | Inherited from [`GlResource`](sf-GlResource.md#glresource) |
| [`m_sharedContext`](sf-GlResource.md#m_sharedcontext) | `variable` | Inherited from [`GlResource`](sf-GlResource.md#glresource) |

## Inherited from [`Drawable`](sf-Drawable.md#drawable)

| Kind | Name | Description |
|------|------|-------------|
| `friend` | [`RenderTarget`](sf-Drawable.md#rendertarget)  |  |
| `function` | [`~Drawable`](sf-Drawable.md#drawable-1) `virtual` | Virtual destructor. |
| `function` | [`draw`](sf-Drawable.md#draw) `virtual` `const` | Draw the object to a render target. |

## Inherited from [`GlResource`](sf-GlResource.md#glresource)

| Kind | Name | Description |
|------|------|-------------|
| `function` | [`GlResource`](sf-GlResource.md#glresource-1)  | Default constructor. |
| `variable` | [`m_sharedContext`](sf-GlResource.md#m_sharedcontext)  | Shared context used to link all contexts together for resource sharing. |

## Public Methods

| Return | Name | Description |
|--------|------|-------------|
|  | [`VertexBuffer`](#vertexbuffer-1)  | Default constructor. |
|  | [`VertexBuffer`](#vertexbuffer-2) `explicit` | Construct a `[VertexBuffer](#vertexbuffer)` with a specific `[PrimitiveType](PrimitiveType.md#primitivetype)` |
|  | [`VertexBuffer`](#vertexbuffer-3) `explicit` | Construct a `[VertexBuffer](#vertexbuffer)` with a specific usage specifier. |
|  | [`VertexBuffer`](#vertexbuffer-4)  | Construct a `[VertexBuffer](#vertexbuffer)` with a specific `[PrimitiveType](PrimitiveType.md#primitivetype)` and usage specifier. |
|  | [`VertexBuffer`](#vertexbuffer-5)  | Copy constructor. |
|  | [`~VertexBuffer`](#vertexbuffer-6) `override` | Destructor. |
| `bool` | [`create`](#create-11) `nodiscard` | Create the vertex buffer. |
| `std::size_t` | [`getVertexCount`](#getvertexcount-1) `const` `nodiscard` | Return the vertex count. |
| `bool` | [`update`](#update-11) `nodiscard` | Update the whole buffer from an array of vertices. |
| `bool` | [`update`](#update-12) `nodiscard` | Update a part of the buffer from an array of vertices. |
| `bool` | [`update`](#update-13) `nodiscard` | Copy the contents of another buffer into this buffer. |
| [`VertexBuffer`](#vertexbuffer) & | [`operator=`](#operator-80)  | Overload of assignment operator. |
| `void` | [`swap`](#swap-1) `noexcept` | Swap the contents of this vertex buffer with those of another. |
| `unsigned int` | [`getNativeHandle`](#getnativehandle-4) `const` `nodiscard` | Get the underlying OpenGL handle of the vertex buffer. |
| `void` | [`setPrimitiveType`](#setprimitivetype-1)  | Set the type of primitives to draw. |
| [`PrimitiveType`](PrimitiveType.md#primitivetype) | [`getPrimitiveType`](#getprimitivetype-1) `const` `nodiscard` | Get the type of primitives drawn by the vertex buffer. |
| `void` | [`setUsage`](#setusage)  | Set the usage specifier of this vertex buffer. |
| [`Usage`](Usage.md#usage) | [`getUsage`](#getusage) `const` `nodiscard` | Get the usage specifier of this vertex buffer. |

---

{#vertexbuffer-1}

### VertexBuffer

```cpp
VertexBuffer() = default
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/VertexBuffer.hpp:76

Default constructor.

Creates an empty vertex buffer.

---

{#vertexbuffer-2}

### VertexBuffer

`explicit`

```cpp
explicit VertexBuffer(PrimitiveType type)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/VertexBuffer.hpp:86

Construct a `[VertexBuffer](#vertexbuffer)` with a specific `[PrimitiveType](PrimitiveType.md#primitivetype)`

Creates an empty vertex buffer and sets its primitive type to `type`.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `type` | [`PrimitiveType`](PrimitiveType.md#primitivetype) | Type of primitive |

---

{#vertexbuffer-3}

### VertexBuffer

`explicit`

```cpp
explicit VertexBuffer(Usage usage)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/VertexBuffer.hpp:96

Construct a `[VertexBuffer](#vertexbuffer)` with a specific usage specifier.

Creates an empty vertex buffer and sets its usage to `usage`.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `usage` | [`Usage`](Usage.md#usage) | [Usage](Usage.md#usage) specifier |

---

{#vertexbuffer-4}

### VertexBuffer

```cpp
VertexBuffer(PrimitiveType type, Usage usage)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/VertexBuffer.hpp:108

Construct a `[VertexBuffer](#vertexbuffer)` with a specific `[PrimitiveType](PrimitiveType.md#primitivetype)` and usage specifier.

Creates an empty vertex buffer and sets its primitive type to `type` and usage to `usage`.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `type` | [`PrimitiveType`](PrimitiveType.md#primitivetype) | Type of primitive |
| `usage` | [`Usage`](Usage.md#usage) | [Usage](Usage.md#usage) specifier |

---

{#vertexbuffer-5}

### VertexBuffer

```cpp
VertexBuffer(const VertexBuffer & copy)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/VertexBuffer.hpp:116

Copy constructor.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `copy` | const [`VertexBuffer`](#vertexbuffer) & | instance to copy |

---

{#vertexbuffer-6}

### ~VertexBuffer

`override`

```cpp
~VertexBuffer() override
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/VertexBuffer.hpp:122

Destructor.

---

{#create-11}

### create

`nodiscard`

```cpp
[[nodiscard]] bool create(std::size_t vertexCount)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/VertexBuffer.hpp:140

Create the vertex buffer.

Creates the vertex buffer and allocates enough graphics memory to hold `vertexCount` vertices. Any previously allocated memory is freed in the process.

In order to deallocate previously allocated memory pass 0 as `vertexCount`. Don't forget to recreate with a non-zero value when graphics memory should be allocated again.

#### Returns
`true` if creation was successful

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `vertexCount` | `std::size_t` | Number of vertices worth of memory to allocate |

---

{#getvertexcount-1}

### getVertexCount

`const` `nodiscard`

```cpp
[[nodiscard]] std::size_t getVertexCount() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/VertexBuffer.hpp:148

Return the vertex count.

#### Returns
Number of vertices in the vertex buffer

---

{#update-11}

### update

`nodiscard`

```cpp
[[nodiscard]] bool update(const Vertex * vertices)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/VertexBuffer.hpp:168

Update the whole buffer from an array of vertices.

The vertex array is assumed to have the same size as the created buffer.

No additional check is performed on the size of the vertex array. Passing invalid arguments will lead to undefined behavior.

This function does nothing if `vertices` is null or if the buffer was not previously created.

#### Returns
`true` if the update was successful

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `vertices` | const [`Vertex`](sf-Vertex.md#vertex) * | Array of vertices to copy to the buffer |

---

{#update-12}

### update

`nodiscard`

```cpp
[[nodiscard]] bool update(const Vertex * vertices, std::size_t vertexCount, unsigned int offset)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/VertexBuffer.hpp:201

Update a part of the buffer from an array of vertices.

`offset` is specified as the number of vertices to skip from the beginning of the buffer.

If `offset` is 0 and `vertexCount` is equal to the size of the currently created buffer, its whole contents are replaced.

If `offset` is 0 and `vertexCount` is greater than the size of the currently created buffer, a new buffer is created containing the vertex data.

If `offset` is 0 and `vertexCount` is less than the size of the currently created buffer, only the corresponding region is updated.

If `offset` is not 0 and `offset` + `vertexCount` is greater than the size of the currently created buffer, the update fails.

No additional check is performed on the size of the vertex array. Passing invalid arguments will lead to undefined behavior.

#### Returns
`true` if the update was successful

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `vertices` | const [`Vertex`](sf-Vertex.md#vertex) * | Array of vertices to copy to the buffer |
| `vertexCount` | `std::size_t` | Number of vertices to copy |
| `offset` | `unsigned int` | Offset in the buffer to copy to |

---

{#update-13}

### update

`nodiscard`

```cpp
[[nodiscard]] bool update(const VertexBuffer & vertexBuffer)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/VertexBuffer.hpp:211

Copy the contents of another buffer into this buffer.

#### Returns
`true` if the copy was successful

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `vertexBuffer` | const [`VertexBuffer`](#vertexbuffer) & | [Vertex](sf-Vertex.md#vertex) buffer whose contents to copy into this vertex buffer |

---

{#operator-80}

### operator=

```cpp
VertexBuffer & operator=(const VertexBuffer & right)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/VertexBuffer.hpp:221

Overload of assignment operator.

#### Returns
Reference to self

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `right` | const [`VertexBuffer`](#vertexbuffer) & | Instance to assign |

---

{#swap-1}

### swap

`noexcept`

```cpp
void swap(VertexBuffer & right) noexcept
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/VertexBuffer.hpp:229

Swap the contents of this vertex buffer with those of another.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `right` | [`VertexBuffer`](#vertexbuffer) & | Instance to swap with |

---

{#getnativehandle-4}

### getNativeHandle

`const` `nodiscard`

```cpp
[[nodiscard]] unsigned int getNativeHandle() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/VertexBuffer.hpp:241

Get the underlying OpenGL handle of the vertex buffer.

You shouldn't need to use this function, unless you have very specific stuff to implement that SFML doesn't support, or implement a temporary workaround until a bug is fixed.

#### Returns
OpenGL handle of the vertex buffer or 0 if not yet created

---

{#setprimitivetype-1}

### setPrimitiveType

```cpp
void setPrimitiveType(PrimitiveType type)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/VertexBuffer.hpp:254

Set the type of primitives to draw.

This function defines how the vertices must be interpreted when it's time to draw them.

The default primitive type is `[sf::PrimitiveType::Points](graphics.md#group__graphics_1gga5ee56ac1339984909610713096283b1ba75dd5f1160a3f02b6fae89c54361a1b3)`.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `type` | [`PrimitiveType`](PrimitiveType.md#primitivetype) | Type of primitive |

---

{#getprimitivetype-1}

### getPrimitiveType

`const` `nodiscard`

```cpp
[[nodiscard]] PrimitiveType getPrimitiveType() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/VertexBuffer.hpp:262

Get the type of primitives drawn by the vertex buffer.

#### Returns
Primitive type

---

{#setusage}

### setUsage

```cpp
void setUsage(Usage usage)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/VertexBuffer.hpp:279

Set the usage specifier of this vertex buffer.

This function provides a hint about how this vertex buffer is going to be used in terms of data update frequency.

After changing the usage specifier, the vertex buffer has to be updated with new data for the usage specifier to take effect.

The default usage type is `[sf::VertexBuffer::Usage::Stream](#classsf_1_1VertexBuffer_1a3a531528684e63ecb45edd51282f5cb7aeae835e83c0494a376229f254f7d3392)`.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `usage` | [`Usage`](Usage.md#usage) | [Usage](Usage.md#usage) specifier |

---

{#getusage}

### getUsage

`const` `nodiscard`

```cpp
[[nodiscard]] Usage getUsage() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/VertexBuffer.hpp:287

Get the usage specifier of this vertex buffer.

#### Returns
[Usage](Usage.md#usage) specifier

## Public Static Methods

| Return | Name | Description |
|--------|------|-------------|
| `void` | [`bind`](#bind-3) `static` | Bind a vertex buffer for rendering. |
| `bool` | [`isAvailable`](#isavailable-4) `static` `nodiscard` | Tell whether or not the system supports vertex buffers. |

---

{#bind-3}

### bind

`static`

```cpp
static void bind(const VertexBuffer * vertexBuffer)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/VertexBuffer.hpp:310

Bind a vertex buffer for rendering.

This function is not part of the graphics API, it mustn't be used when drawing SFML entities. It must be used only if you mix `[sf::VertexBuffer](#vertexbuffer)` with OpenGL code.

```cpp
sf::VertexBuffer vb1, vb2;
...
sf::VertexBuffer::bind(&vb1);
// draw OpenGL stuff that use vb1...
sf::VertexBuffer::bind(&vb2);
// draw OpenGL stuff that use vb2...
sf::VertexBuffer::bind(nullptr);
// draw OpenGL stuff that use no vertex buffer...
```

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `vertexBuffer` | const [`VertexBuffer`](#vertexbuffer) * | Pointer to the vertex buffer to bind, can be null to use no vertex buffer |

---

{#isavailable-4}

### isAvailable

`static` `nodiscard`

```cpp
[[nodiscard]] static bool isAvailable()
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/VertexBuffer.hpp:322

Tell whether or not the system supports vertex buffers.

This function should always be called before using the vertex buffer features. If it returns `false`, then any attempt to use `[sf::VertexBuffer](#vertexbuffer)` will fail.

#### Returns
`true` if vertex buffers are supported, `false` otherwise

## Public Types

| Name | Description |
|------|-------------|
| [`Usage`](#usage)  | [Usage](Usage.md#usage) specifiers. |

---

{#usage}

### Usage

```cpp
enum Usage
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/VertexBuffer.hpp:63

[Usage](Usage.md#usage) specifiers.

If data is going to be updated once or more every frame, set the usage to Stream. If data is going to be set once and used for a long time without being modified, set the usage to Static. For everything else Dynamic should be a good compromise.

| Value | Description |
|-------|-------------|
| `Stream` | Constantly changing data. |
| `Dynamic` | Occasionally changing data. |
| `Static` | Rarely changing data. |
## Private Attributes

| Return | Name | Description |
|--------|------|-------------|
| `unsigned int` | [`m_buffer`](#m_buffer-2)  | Internal buffer identifier. |
| `std::size_t` | [`m_size`](#m_size-5)  | Size in Vertices of the currently allocated buffer. |
| [`PrimitiveType`](PrimitiveType.md#primitivetype) | [`m_primitiveType`](#m_primitivetype-1)  | Type of primitives to draw. |
| [`Usage`](Usage.md#usage) | [`m_usage`](#m_usage)  | How this vertex buffer is to be used. |

---

{#m_buffer-2}

### m_buffer

```cpp
unsigned int m_buffer {}
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/VertexBuffer.hpp:337

Internal buffer identifier.

---

{#m_size-5}

### m_size

```cpp
std::size_t m_size {}
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/VertexBuffer.hpp:338

Size in Vertices of the currently allocated buffer.

---

{#m_primitivetype-1}

### m_primitiveType

```cpp
PrimitiveType m_primitiveType {PrimitiveType::Points}
```

Type: [`PrimitiveType`](PrimitiveType.md#primitivetype)

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/VertexBuffer.hpp:339

Type of primitives to draw.

---

{#m_usage}

### m_usage

```cpp
Usage m_usage {Usage::Stream}
```

Type: [`Usage`](Usage.md#usage)

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/VertexBuffer.hpp:340

How this vertex buffer is to be used.

## Private Methods

| Return | Name | Description |
|--------|------|-------------|
| `void` | [`draw`](#draw-9) `virtual` `const` `override` | Draw the vertex buffer to a render target. |

---

{#draw-9}

### draw

`virtual` `const` `override`

```cpp
virtual void draw(RenderTarget & target, RenderStates states) const override
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/VertexBuffer.hpp:332

Draw the vertex buffer to a render target.

#### Reimplements

- [`draw`](sf-Drawable.md#draw)

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `target` | [`RenderTarget`](sf-RenderTarget.md#rendertarget-1) & | Render target to draw to |
| `states` | [`RenderStates`](sf-RenderStates.md#renderstates) | Current render states |

