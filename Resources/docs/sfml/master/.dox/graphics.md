{#graphicsmodule}

# Graphics module

2D graphics module: sprites, text, shapes, ...

## Classes

| Name | Description |
|------|-------------|
| [`BlendMode`](sf-BlendMode.md#blendmode) | Blending modes for drawing. |
| [`CircleShape`](sf-CircleShape.md#circleshape) | Specialized shape representing a circle. |
| [`Color`](sf-Color.md#color) | Utility class for manipulating RGBA colors. |
| [`ConvexShape`](sf-ConvexShape.md#convexshape) | Specialized shape representing a convex polygon. |
| [`Drawable`](sf-Drawable.md#drawable) | Abstract base class for objects that can be drawn to a render target. |
| [`Font`](sf-Font.md#font) | Class for loading and manipulating character fonts. |
| [`Image`](sf-Image.md#image) | Class for loading, manipulating and saving images. |
| [`Rect`](sf-Rect.md#rect) | Utility class for manipulating 2D axis aligned rectangles. |
| [`RectangleShape`](sf-RectangleShape.md#rectangleshape) | Specialized shape representing a rectangle. |
| [`RenderStates`](sf-RenderStates.md#renderstates) | Define the states used for drawing to a `[RenderTarget](sf-RenderTarget.md#rendertarget-1)` |
| [`RenderTarget`](sf-RenderTarget.md#rendertarget-1) | Base class for all render targets (window, texture, ...) |
| [`RenderTexture`](sf-RenderTexture.md#rendertexture) | Target for off-screen 2D rendering into a texture. |
| [`RenderWindow`](sf-RenderWindow.md#renderwindow) | [Window](sf-Window.md#window) that can serve as a target for 2D drawing. |
| [`Shader`](sf-Shader.md#shader-1) | [Shader](sf-Shader.md#shader-1) class (vertex, geometry and fragment) |
| [`Shape`](sf-Shape.md#shape) | Base class for textured shapes with outline. |
| [`Sprite`](sf-Sprite.md#sprite) | [Drawable](sf-Drawable.md#drawable) representation of a texture, with its own transformations, color, etc. |
| [`StencilMode`](sf-StencilMode.md#stencilmode-1) | Stencil modes for drawing. |
| [`Text`](sf-Text.md#text-1) | Graphical text that can be drawn to a render target. |
| [`Texture`](sf-Texture.md#texture-2) | [Image](sf-Image.md#image) living on the graphics card that can be used for drawing. |
| [`Transform`](sf-Transform.md#transform-1) | 3x3 transform matrix |
| [`Transformable`](sf-Transformable.md#transformable) | Decomposed transform defined by a position, a rotation and a scale. |
| [`VertexArray`](sf-VertexArray.md#vertexarray) | Set of one or more 2D primitives. |
| [`VertexBuffer`](sf-VertexBuffer.md#vertexbuffer) | [Vertex](sf-Vertex.md#vertex) buffer storage for one or more 2D primitives. |
| [`View`](sf-View.md#view) | 2D camera that defines what region is shown on screen |
| [`Glyph`](sf-Glyph.md#glyph) | Structure describing a glyph. |
| [`Vertex`](sf-Vertex.md#vertex) | Point with color and texture coordinates. |

## Enumerations

| Name | Description |
|------|-------------|
| [`CoordinateType`](#coordinatetype)  | Types of texture coordinates that can be used for rendering. |
| [`PrimitiveType`](#primitivetype)  | Types of primitives that a `[sf::VertexArray](sf-VertexArray.md#vertexarray)` can render. |

---

{#coordinatetype}

### CoordinateType

```cpp
enum CoordinateType
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/CoordinateType.hpp:37

Types of texture coordinates that can be used for rendering.

**See also**: `[sf::Texture::bind](sf-Texture.md#bind-2)`

| Value | Description |
|-------|-------------|
| `Normalized` | [Texture](sf-Texture.md#texture-2) coordinates in range [0 .. 1]. |
| `Pixels` | [Texture](sf-Texture.md#texture-2) coordinates in range [0 .. size]. |

---

{#primitivetype}

### PrimitiveType

```cpp
enum PrimitiveType
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/PrimitiveType.hpp:38

Types of primitives that a `[sf::VertexArray](sf-VertexArray.md#vertexarray)` can render.

Points and lines have no area, therefore their thickness will always be 1 pixel, regardless the current transform and view.

| Value | Description |
|-------|-------------|
| `Points` | List of individual points. |
| `Lines` | List of individual lines. |
| `LineStrip` | List of connected lines, a point uses the previous point to form a line. |
| `Triangles` | List of individual triangles. |
| `TriangleStrip` | List of connected triangles, a point uses the two previous points to form a triangle. |
| `TriangleFan` | List of connected triangles, a point uses the common center and the previous point to form a triangle. |
