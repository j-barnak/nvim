{#rendertarget-1}

# RenderTarget

```cpp
#include <RenderTarget.hpp>
```

```cpp
class RenderTarget
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/RenderTarget.hpp:62

> **Subclassed by:** [`RenderTexture`](sf-RenderTexture.md#rendertexture), [`RenderWindow`](sf-RenderWindow.md#renderwindow)

Base class for all render targets (window, texture, ...)

`[sf::RenderTarget](#rendertarget-1)` defines the common behavior of all the 2D render targets usable in the graphics module. It makes it possible to draw 2D entities like sprites, shapes, text without using any OpenGL command directly.

A `[sf::RenderTarget](#rendertarget-1)` is also able to use views (`[sf::View](sf-View.md#view)`), which are a kind of 2D cameras. With views you can globally scroll, rotate or zoom everything that is drawn, without having to transform every single entity. See the documentation of `[sf::View](sf-View.md#view)` for more details and sample pieces of code about this class.

On top of that, render targets are still able to render direct OpenGL stuff. It is even possible to mix together OpenGL calls and regular SFML drawing commands. When doing so, make sure that OpenGL states are not messed up by calling the `pushGLStates`/`popGLStates` functions.

While render targets are moveable, it is not valid to move them between threads. This will cause your program to crash. The problem boils down to OpenGL being limited with regard to how it works in multithreaded environments. Please ensure you only move render targets within the same thread.

**See also**: `[sf::RenderWindow](sf-RenderWindow.md#renderwindow)`, `[sf::RenderTexture](sf-RenderTexture.md#rendertexture)`, `[sf::View](sf-View.md#view)`

## Public Methods

| Return | Name | Description |
|--------|------|-------------|
|  | [`~RenderTarget`](#rendertarget-2) `virtual` | Destructor. |
|  | [`RenderTarget`](#rendertarget-3)  | Deleted copy constructor. |
| [`RenderTarget`](#rendertarget-1) & | [`operator=`](#operator-70)  | Deleted copy assignment. |
|  | [`RenderTarget`](#rendertarget-4) `noexcept` | Move constructor. |
| [`RenderTarget`](#rendertarget-1) & | [`operator=`](#operator-71) `noexcept` | Move assignment. |
| `void` | [`clear`](#clear-3)  | Clear the entire target with a single color. |
| `void` | [`clearStencil`](#clearstencil)  | Clear the stencil buffer to a specific value. |
| `void` | [`clear`](#clear-4)  | Clear the entire target with a single color and stencil value. |
| `void` | [`setView`](#setview)  | Change the current active view. |
| const [`View`](sf-View.md#view) & | [`getView`](#getview) `const` `nodiscard` | Get the view currently in use in the render target. |
| const [`View`](sf-View.md#view) & | [`getDefaultView`](#getdefaultview) `const` `nodiscard` | Get the default view of the render target. |
| [`IntRect`](sf.md#intrect) | [`getViewport`](#getviewport) `const` `nodiscard` | Get the viewport of a view, applied to this render target. |
| [`IntRect`](sf.md#intrect) | [`getScissor`](#getscissor) `const` `nodiscard` | Get the scissor rectangle of a view, applied to this render target. |
| [`Vector2f`](sf.md#vector2f) | [`mapPixelToCoords`](#mappixeltocoords) `const` `nodiscard` | Convert a point from target coordinates to world coordinates, using the current view. |
| [`Vector2f`](sf.md#vector2f) | [`mapPixelToCoords`](#mappixeltocoords-1) `const` `nodiscard` | Convert a point from target coordinates to world coordinates. |
| [`Vector2i`](sf.md#vector2i) | [`mapCoordsToPixel`](#mapcoordstopixel) `const` `nodiscard` | Convert a point from world coordinates to target coordinates, using the current view. |
| [`Vector2i`](sf.md#vector2i) | [`mapCoordsToPixel`](#mapcoordstopixel-1) `const` `nodiscard` | Convert a point from world coordinates to target coordinates. |
| `void` | [`draw`](#draw-1)  | Draw a drawable object to the render target. |
| `void` | [`draw`](#draw-2)  | Draw primitives defined by an array of vertices. |
| `void` | [`draw`](#draw-3)  | Draw primitives defined by a vertex buffer. |
| `void` | [`draw`](#draw-4)  | Draw primitives defined by a vertex buffer. |
| [`Vector2u`](sf.md#vector2u) | [`getSize`](#getsize-7) `virtual` `const` `nodiscard` | Return the size of the rendering region of the target. |
| `bool` | [`isSrgb`](#issrgb) `virtual` `const` `nodiscard` | Tell if the render target will use sRGB encoding when drawing on it. |
| `bool` | [`setActive`](#setactive-2) `virtual` `nodiscard` | Activate or deactivate the render target for rendering. |
| `void` | [`pushGLStates`](#pushglstates)  | Save the current OpenGL render states and matrices. |
| `void` | [`popGLStates`](#popglstates)  | Restore the previously saved OpenGL render states and matrices. |
| `void` | [`resetGLStates`](#resetglstates)  | Reset the internal OpenGL states so that the target is ready for drawing. |

---

{#rendertarget-2}

### ~RenderTarget

`virtual`

```cpp
virtual ~RenderTarget() = default
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/RenderTarget.hpp:69

Destructor.

---

{#rendertarget-3}

### RenderTarget

```cpp
RenderTarget(const RenderTarget &) = delete
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/RenderTarget.hpp:75

Deleted copy constructor.

---

{#operator-70}

### operator=

```cpp
RenderTarget & operator=(const RenderTarget &) = delete
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/RenderTarget.hpp:81

Deleted copy assignment.

---

{#rendertarget-4}

### RenderTarget

`noexcept`

```cpp
RenderTarget(RenderTarget &&) noexcept = default
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/RenderTarget.hpp:87

Move constructor.

---

{#operator-71}

### operator=

`noexcept`

```cpp
RenderTarget & operator=(RenderTarget &&) noexcept = default
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/RenderTarget.hpp:93

Move assignment.

---

{#clear-3}

### clear

```cpp
void clear(Color color = Color::Black)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/RenderTarget.hpp:104

Clear the entire target with a single color.

This function is usually called once every frame, to clear the previous contents of the target.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `color` | [`Color`](sf-Color.md#color) | Fill color to use to clear the render target |

---

{#clearstencil}

### clearStencil

```cpp
void clearStencil(StencilValue stencilValue)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/RenderTarget.hpp:115

Clear the stencil buffer to a specific value.

The specified value is truncated to the bit width of the current stencil buffer.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `stencilValue` | [`StencilValue`](sf-StencilValue.md#stencilvalue) | Stencil value to clear to |

---

{#clear-4}

### clear

```cpp
void clear(Color color, StencilValue stencilValue)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/RenderTarget.hpp:127

Clear the entire target with a single color and stencil value.

The specified stencil value is truncated to the bit width of the current stencil buffer.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `color` | [`Color`](sf-Color.md#color) | Fill color to use to clear the render target |
| `stencilValue` | [`StencilValue`](sf-StencilValue.md#stencilvalue) | Stencil value to clear to |

---

{#setview}

### setView

```cpp
void setView(const View & view)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/RenderTarget.hpp:148

Change the current active view.

The view is like a 2D camera, it controls which part of the 2D scene is visible, and how it is viewed in the render target. The new view will affect everything that is drawn, until another view is set. The render target keeps its own copy of the view object, so it is not necessary to keep the original one alive after calling this function. To restore the original view of the target, you can pass the result of `[getDefaultView()](#getdefaultview)` to this function.

**See also**: `[getView](#getview)`, `[getDefaultView](#getdefaultview)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `view` | const [`View`](sf-View.md#view) & | New view to use |

---

{#getview}

### getView

`const` `nodiscard`

```cpp
[[nodiscard]] const View & getView() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/RenderTarget.hpp:158

Get the view currently in use in the render target.

#### Returns
The view object that is currently used

**See also**: `[setView](#setview)`, `[getDefaultView](#getdefaultview)`

---

{#getdefaultview}

### getDefaultView

`const` `nodiscard`

```cpp
[[nodiscard]] const View & getDefaultView() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/RenderTarget.hpp:171

Get the default view of the render target.

The default view has the initial size of the render target, and never changes after the target has been created.

#### Returns
The default view of the render target

**See also**: `[setView](#setview)`, `[getView](#getview)`

---

{#getviewport}

### getViewport

`const` `nodiscard`

```cpp
[[nodiscard]] IntRect getViewport(const View & view) const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/RenderTarget.hpp:186

Get the viewport of a view, applied to this render target.

The viewport is defined in the view as a ratio, this function simply applies this ratio to the current dimensions of the render target to calculate the pixels rectangle that the viewport actually covers in the target.

#### Returns
Viewport rectangle, expressed in pixels

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `view` | const [`View`](sf-View.md#view) & | The view for which we want to compute the viewport |

---

{#getscissor}

### getScissor

`const` `nodiscard`

```cpp
[[nodiscard]] IntRect getScissor(const View & view) const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/RenderTarget.hpp:201

Get the scissor rectangle of a view, applied to this render target.

The scissor rectangle is defined in the view as a ratio. This function simply applies this ratio to the current dimensions of the render target to calculate the pixels rectangle that the scissor rectangle actually covers in the target.

#### Returns
Scissor rectangle, expressed in pixels

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `view` | const [`View`](sf-View.md#view) & | The view for which we want to compute the scissor rectangle |

---

{#mappixeltocoords}

### mapPixelToCoords

`const` `nodiscard`

```cpp
[[nodiscard]] Vector2f mapPixelToCoords(Vector2i point) const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/RenderTarget.hpp:221

Convert a point from target coordinates to world coordinates, using the current view.

This function is an overload of the mapPixelToCoords function that implicitly uses the current view. It is equivalent to: 
```cpp
target.mapPixelToCoords(point, target.getView());
```

#### Returns
The converted point, in "world" coordinates

**See also**: `[mapCoordsToPixel](#mapcoordstopixel)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `point` | [`Vector2i`](sf.md#vector2i) | Pixel to convert |

---

{#mappixeltocoords-1}

### mapPixelToCoords

`const` `nodiscard`

```cpp
[[nodiscard]] Vector2f mapPixelToCoords(Vector2i point, const View & view) const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/RenderTarget.hpp:252

Convert a point from target coordinates to world coordinates.

This function finds the 2D position that matches the given pixel of the render target. In other words, it does the inverse of what the graphics card does, to find the initial position of a rendered pixel.

Initially, both coordinate systems (world units and target pixels) match perfectly. But if you define a custom view or resize your render target, this assertion is not `true` anymore, i.e. a point located at (10, 50) in your render target may map to the point (150, 75) in your 2D world &ndash; if the view is translated by (140, 25).

For render-windows, this function is typically used to find which point (or object) is located below the mouse cursor.

This version uses a custom view for calculations, see the other overload of the function if you want to use the current view of the render target.

#### Returns
The converted point, in "world" units

**See also**: `[mapCoordsToPixel](#mapcoordstopixel)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `point` | [`Vector2i`](sf.md#vector2i) | Pixel to convert |
| `view` | const [`View`](sf-View.md#view) & | The view to use for converting the point |

---

{#mapcoordstopixel}

### mapCoordsToPixel

`const` `nodiscard`

```cpp
[[nodiscard]] Vector2i mapCoordsToPixel(Vector2f point) const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/RenderTarget.hpp:272

Convert a point from world coordinates to target coordinates, using the current view.

This function is an overload of the `mapCoordsToPixel` function that implicitly uses the current view. It is equivalent to: 
```cpp
target.mapCoordsToPixel(point, target.getView());
```

#### Returns
The converted point, in target coordinates (pixels)

**See also**: `[mapPixelToCoords](#mappixeltocoords)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `point` | [`Vector2f`](sf.md#vector2f) | Point to convert |

---

{#mapcoordstopixel-1}

### mapCoordsToPixel

`const` `nodiscard`

```cpp
[[nodiscard]] Vector2i mapCoordsToPixel(Vector2f point, const View & view) const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/RenderTarget.hpp:299

Convert a point from world coordinates to target coordinates.

This function finds the pixel of the render target that matches the given 2D point. In other words, it goes through the same process as the graphics card, to compute the final position of a rendered point.

Initially, both coordinate systems (world units and target pixels) match perfectly. But if you define a custom view or resize your render target, this assertion is not `true` anymore, i.e. a point located at (150, 75) in your 2D world may map to the pixel (10, 50) of your render target &ndash; if the view is translated by (140, 25).

This version uses a custom view for calculations, see the other overload of the function if you want to use the current view of the render target.

#### Returns
The converted point, in target coordinates (pixels)

**See also**: `[mapPixelToCoords](#mappixeltocoords)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `point` | [`Vector2f`](sf.md#vector2f) | Point to convert |
| `view` | const [`View`](sf-View.md#view) & | The view to use for converting the point |

---

{#draw-1}

### draw

```cpp
void draw(const Drawable & drawable, const RenderStates & states = RenderStates::Default)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/RenderTarget.hpp:308

Draw a drawable object to the render target.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `drawable` | const [`Drawable`](sf-Drawable.md#drawable) & | Object to draw |
| `states` | const [`RenderStates`](sf-RenderStates.md#renderstates) & | Render states to use for drawing |

---

{#draw-2}

### draw

```cpp
void draw(const Vertex * vertices, std::size_t vertexCount, PrimitiveType type, const RenderStates & states = RenderStates::Default)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/RenderTarget.hpp:319

Draw primitives defined by an array of vertices.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `vertices` | const [`Vertex`](sf-Vertex.md#vertex) * | Pointer to the vertices |
| `vertexCount` | `std::size_t` | Number of vertices in the array |
| `type` | [`PrimitiveType`](PrimitiveType.md#primitivetype) | Type of primitives to draw |
| `states` | const [`RenderStates`](sf-RenderStates.md#renderstates) & | Render states to use for drawing |

---

{#draw-3}

### draw

```cpp
void draw(const VertexBuffer & vertexBuffer, const RenderStates & states = RenderStates::Default)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/RenderTarget.hpp:331

Draw primitives defined by a vertex buffer.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `vertexBuffer` | const [`VertexBuffer`](sf-VertexBuffer.md#vertexbuffer) & | [Vertex](sf-Vertex.md#vertex) buffer |
| `states` | const [`RenderStates`](sf-RenderStates.md#renderstates) & | Render states to use for drawing |

---

{#draw-4}

### draw

```cpp
void draw(const VertexBuffer & vertexBuffer, std::size_t firstVertex, std::size_t vertexCount, const RenderStates & states = RenderStates::Default)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/RenderTarget.hpp:342

Draw primitives defined by a vertex buffer.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `vertexBuffer` | const [`VertexBuffer`](sf-VertexBuffer.md#vertexbuffer) & | [Vertex](sf-Vertex.md#vertex) buffer |
| `firstVertex` | `std::size_t` | Index of the first vertex to render |
| `vertexCount` | `std::size_t` | Number of vertices to render |
| `states` | const [`RenderStates`](sf-RenderStates.md#renderstates) & | Render states to use for drawing |

---

{#getsize-7}

### getSize

`virtual` `const` `nodiscard`

```cpp
[[nodiscard]] virtual Vector2u getSize() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/RenderTarget.hpp:353

Return the size of the rendering region of the target.

#### Returns
Size in pixels

#### Reimplemented by

- [`getSize`](sf-RenderTexture.md#getsize-8)
- [`getSize`](sf-RenderWindow.md#getsize-9)

---

{#issrgb}

### isSrgb

`virtual` `const` `nodiscard`

```cpp
[[nodiscard]] virtual bool isSrgb() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/RenderTarget.hpp:361

Tell if the render target will use sRGB encoding when drawing on it.

#### Returns
`true` if the render target use sRGB encoding, `false` otherwise

#### Reimplemented by

- [`isSrgb`](sf-RenderTexture.md#issrgb-1)
- [`isSrgb`](sf-RenderWindow.md#issrgb-2)

---

{#setactive-2}

### setActive

`virtual` `nodiscard`

```cpp
[[nodiscard]] virtual bool setActive(bool active = true)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/RenderTarget.hpp:383

Activate or deactivate the render target for rendering.

This function makes the render target's context current for future OpenGL rendering operations (so you shouldn't care about it if you're not doing direct OpenGL stuff). A render target's context is active only on the current thread, if you want to make it active on another thread you have to deactivate it on the previous thread first if it was active. Only one context can be current in a thread, so if you want to draw OpenGL geometry to another render target don't forget to activate it again. Activating a render target will automatically deactivate the previously active context (if any).

#### Returns
`true` if operation was successful, `false` otherwise

#### Reimplemented by

- [`setActive`](sf-RenderTexture.md#setactive-3)
- [`setActive`](sf-RenderWindow.md#setactive-4)

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `active` | `bool` | `true` to activate, `false` to deactivate |

---

{#pushglstates}

### pushGLStates

```cpp
void pushGLStates()
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/RenderTarget.hpp:417

Save the current OpenGL render states and matrices.

This function can be used when you mix SFML drawing and direct OpenGL rendering. Combined with popGLStates, it ensures that: 

* SFML's internal states are not messed up by your OpenGL code 
* your OpenGL states are not modified by a call to a SFML function

More specifically, it must be used around code that calls `draw` functions. Example: 
```cpp
// OpenGL code here...
window.pushGLStates();
window.draw(...);
window.draw(...);
window.popGLStates();
// OpenGL code here...
```

Note that this function is quite expensive: it saves all the possible OpenGL states and matrices, even the ones you don't care about. Therefore it should be used wisely. It is provided for convenience, but the best results will be achieved if you handle OpenGL states yourself (because you know which states have really changed, and need to be saved and restored). Take a look at the resetGLStates function if you do so.

**See also**: `[popGLStates](#popglstates)`

---

{#popglstates}

### popGLStates

```cpp
void popGLStates()
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/RenderTarget.hpp:428

Restore the previously saved OpenGL render states and matrices.

See the description of `pushGLStates` to get a detailed description of these functions.

**See also**: `[pushGLStates](#pushglstates)`

---

{#resetglstates}

### resetGLStates

```cpp
void resetGLStates()
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/RenderTarget.hpp:451

Reset the internal OpenGL states so that the target is ready for drawing.

This function can be used when you mix SFML drawing and direct OpenGL rendering, if you choose not to use `pushGLStates`/`popGLStates`. It makes sure that all OpenGL states needed by SFML are set, so that subsequent `[draw()](#draw-1)` calls will work as expected.

Example: 
```cpp
// OpenGL code here...
glPushAttrib(...);
window.resetGLStates();
window.draw(...);
window.draw(...);
glPopAttrib(...);
// OpenGL code here...
```

## Protected Methods

| Return | Name | Description |
|--------|------|-------------|
|  | [`RenderTarget`](#rendertarget-5)  | Default constructor. |
| `void` | [`initialize`](#initialize-4)  | Performs the common initialization step after creation. |

---

{#rendertarget-5}

### RenderTarget

```cpp
RenderTarget() = default
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/RenderTarget.hpp:458

Default constructor.

---

{#initialize-4}

### initialize

```cpp
void initialize()
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/RenderTarget.hpp:467

Performs the common initialization step after creation.

The derived classes must call this function after the target is created and ready for drawing.

## Private Attributes

| Return | Name | Description |
|--------|------|-------------|
| [`View`](sf-View.md#view) | [`m_defaultView`](#m_defaultview)  | Default view. |
| [`View`](sf-View.md#view) | [`m_view`](#m_view)  | Current view. |
| `StatesCache` | [`m_cache`](#m_cache)  | Render states cache. |
| `std::uint64_t` | [`m_id`](#m_id)  | Unique number that identifies the [RenderTarget](#rendertarget-1). |

---

{#m_defaultview}

### m_defaultView

```cpp
View m_defaultView
```

Type: [`View`](sf-View.md#view)

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/RenderTarget.hpp:567

Default view.

---

{#m_view}

### m_view

```cpp
View m_view
```

Type: [`View`](sf-View.md#view)

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/RenderTarget.hpp:568

Current view.

---

{#m_cache}

### m_cache

```cpp
StatesCache m_cache {}
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/RenderTarget.hpp:569

Render states cache.

---

{#m_id}

### m_id

```cpp
std::uint64_t m_id {}
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/RenderTarget.hpp:570

Unique number that identifies the [RenderTarget](#rendertarget-1).

## Private Methods

| Return | Name | Description |
|--------|------|-------------|
| `void` | [`applyCurrentView`](#applycurrentview)  | Apply the current view. |
| `void` | [`applyBlendMode`](#applyblendmode)  | Apply a new blending mode. |
| `void` | [`applyStencilMode`](#applystencilmode)  | Apply a new stencil mode. |
| `void` | [`applyTransform`](#applytransform)  | Apply a new transform. |
| `void` | [`applyTexture`](#applytexture)  | Apply a new texture. |
| `void` | [`applyShader`](#applyshader)  | Apply a new shader. |
| `void` | [`setupDraw`](#setupdraw)  | Setup environment for drawing. |
| `void` | [`drawPrimitives`](#drawprimitives)  | Draw the primitives. |
| `void` | [`cleanupDraw`](#cleanupdraw)  | Clean up environment after drawing. |

---

{#applycurrentview}

### applyCurrentView

```cpp
void applyCurrentView()
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/RenderTarget.hpp:474

Apply the current view.

---

{#applyblendmode}

### applyBlendMode

```cpp
void applyBlendMode(const BlendMode & mode)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/RenderTarget.hpp:482

Apply a new blending mode.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `mode` | const [`BlendMode`](sf-BlendMode.md#blendmode) & | Blending mode to apply |

---

{#applystencilmode}

### applyStencilMode

```cpp
void applyStencilMode(const StencilMode & mode)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/RenderTarget.hpp:490

Apply a new stencil mode.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `mode` | const [`StencilMode`](sf-StencilMode.md#stencilmode-1) & | Stencil mode to apply |

---

{#applytransform}

### applyTransform

```cpp
void applyTransform(const Transform & transform)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/RenderTarget.hpp:498

Apply a new transform.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `transform` | const [`Transform`](sf-Transform.md#transform-1) & | [Transform](sf-Transform.md#transform-1) to apply |

---

{#applytexture}

### applyTexture

```cpp
void applyTexture(const Texture * texture, CoordinateType coordinateType = CoordinateType::Pixels)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/RenderTarget.hpp:507

Apply a new texture.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `texture` | const [`Texture`](sf-Texture.md#texture-2) * | [Texture](sf-Texture.md#texture-2) to apply |
| `coordinateType` | [`CoordinateType`](CoordinateType.md#coordinatetype) | The texture coordinate type to use |

---

{#applyshader}

### applyShader

```cpp
void applyShader(const Shader * shader)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/RenderTarget.hpp:515

Apply a new shader.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `shader` | const [`Shader`](sf-Shader.md#shader-1) * | [Shader](sf-Shader.md#shader-1) to apply |

---

{#setupdraw}

### setupDraw

```cpp
void setupDraw(bool useVertexCache, const RenderStates & states)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/RenderTarget.hpp:524

Setup environment for drawing.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `useVertexCache` | `bool` | Are we going to use the vertex cache? |
| `states` | const [`RenderStates`](sf-RenderStates.md#renderstates) & | Render states to use for drawing |

---

{#drawprimitives}

### drawPrimitives

```cpp
void drawPrimitives(PrimitiveType type, std::size_t firstVertex, std::size_t vertexCount)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/RenderTarget.hpp:534

Draw the primitives.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `type` | [`PrimitiveType`](PrimitiveType.md#primitivetype) | Type of primitives to draw |
| `firstVertex` | `std::size_t` | Index of the first vertex to use when drawing |
| `vertexCount` | `std::size_t` | Number of vertices to use when drawing |

---

{#cleanupdraw}

### cleanupDraw

```cpp
void cleanupDraw(const RenderStates & states)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/RenderTarget.hpp:542

Clean up environment after drawing.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `states` | const [`RenderStates`](sf-RenderStates.md#renderstates) & | Render states used for drawing |

