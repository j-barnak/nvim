{#rendertexture}

# RenderTexture

```cpp
#include <RenderTexture.hpp>
```

```cpp
class RenderTexture
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/RenderTexture.hpp:53

> **Inherits:** [`RenderTarget`](sf-RenderTarget.md#rendertarget-1)

Target for off-screen 2D rendering into a texture.

`[sf::RenderTexture](#rendertexture)` is the little brother of `[sf::RenderWindow](sf-RenderWindow.md#renderwindow)`. It implements the same 2D drawing and OpenGL-related functions (see their base class `[sf::RenderTarget](sf-RenderTarget.md#rendertarget-1)` for more details), the difference is that the result is stored in an off-screen texture rather than being show in a window.

Rendering to a texture can be useful in a variety of situations: 

* precomputing a complex static texture (like a level's background from multiple tiles) 
* applying post-effects to the whole scene with shaders 
* creating a sprite from a 3D object rendered with OpenGL 
* etc.

Usage example:

```cpp
// Create a new render-window
sf::RenderWindow window(sf::VideoMode({800, 600}), "SFML window");

// Create a new render-texture
sf::RenderTexture texture({500, 500});

// The main loop
while (window.isOpen())
{
   // Event processing
   // ...

   // Clear the whole texture with red color
   texture.clear(sf::Color::Red);

   // Draw stuff to the texture
   texture.draw(sprite);  // sprite is a sf::Sprite
   texture.draw(shape);   // shape is a sf::Shape
   texture.draw(text);    // text is a sf::Text

   // We're done drawing to the texture
   texture.display();

   // Now we start rendering to the window, clear it first
   window.clear();

   // Draw the texture
   sf::Sprite sprite(texture.getTexture());
   window.draw(sprite);

   // End the current frame and display its contents on screen
   window.display();
}
```

Like `[sf::RenderWindow](sf-RenderWindow.md#renderwindow)`, `[sf::RenderTexture](#rendertexture)` is still able to render direct OpenGL stuff. It is even possible to mix together OpenGL calls and regular SFML drawing commands. If you need a depth buffer for 3D rendering, don't forget to request it when calling `RenderTexture::create`.

**See also**: `[sf::RenderTarget](sf-RenderTarget.md#rendertarget-1)`, `[sf::RenderWindow](sf-RenderWindow.md#renderwindow)`, `[sf::View](sf-View.md#view)`, `[sf::Texture](sf-Texture.md#texture-2)`

## List of all members

| Name | Kind | Owner |
|------|------|-------|
| [`RenderTexture`](#rendertexture-1) | `function` | Declared here |
| [`RenderTexture`](#rendertexture-2) | `function` | Declared here |
| [`~RenderTexture`](#rendertexture-3) | `function` | Declared here |
| [`RenderTexture`](#rendertexture-4) | `function` | Declared here |
| [`operator=`](#operator-72) | `function` | Declared here |
| [`RenderTexture`](#rendertexture-5) | `function` | Declared here |
| [`operator=`](#operator-73) | `function` | Declared here |
| [`resize`](#resize-2) | `function` | Declared here |
| [`setSmooth`](#setsmooth-1) | `function` | Declared here |
| [`isSmooth`](#issmooth-1) | `function` | Declared here |
| [`setRepeated`](#setrepeated) | `function` | Declared here |
| [`isRepeated`](#isrepeated) | `function` | Declared here |
| [`generateMipmap`](#generatemipmap) | `function` | Declared here |
| [`setActive`](#setactive-3) | `function` | Declared here |
| [`display`](#display-1) | `function` | Declared here |
| [`getSize`](#getsize-8) | `function` | Declared here |
| [`isSrgb`](#issrgb-1) | `function` | Declared here |
| [`getTexture`](#gettexture-1) | `function` | Declared here |
| [`getMaximumAntiAliasingLevel`](#getmaximumantialiasinglevel) | `function` | Declared here |
| [`m_impl`](#m_impl-9) | `variable` | Declared here |
| [`m_texture`](#m_texture) | `variable` | Declared here |
| [`~RenderTarget`](sf-RenderTarget.md#rendertarget-2) | `function` | Inherited from [`RenderTarget`](sf-RenderTarget.md#rendertarget-1) |
| [`RenderTarget`](sf-RenderTarget.md#rendertarget-3) | `function` | Inherited from [`RenderTarget`](sf-RenderTarget.md#rendertarget-1) |
| [`operator=`](sf-RenderTarget.md#operator-70) | `function` | Inherited from [`RenderTarget`](sf-RenderTarget.md#rendertarget-1) |
| [`RenderTarget`](sf-RenderTarget.md#rendertarget-4) | `function` | Inherited from [`RenderTarget`](sf-RenderTarget.md#rendertarget-1) |
| [`operator=`](sf-RenderTarget.md#operator-71) | `function` | Inherited from [`RenderTarget`](sf-RenderTarget.md#rendertarget-1) |
| [`clear`](sf-RenderTarget.md#clear-3) | `function` | Inherited from [`RenderTarget`](sf-RenderTarget.md#rendertarget-1) |
| [`clearStencil`](sf-RenderTarget.md#clearstencil) | `function` | Inherited from [`RenderTarget`](sf-RenderTarget.md#rendertarget-1) |
| [`clear`](sf-RenderTarget.md#clear-4) | `function` | Inherited from [`RenderTarget`](sf-RenderTarget.md#rendertarget-1) |
| [`setView`](sf-RenderTarget.md#setview) | `function` | Inherited from [`RenderTarget`](sf-RenderTarget.md#rendertarget-1) |
| [`getView`](sf-RenderTarget.md#getview) | `function` | Inherited from [`RenderTarget`](sf-RenderTarget.md#rendertarget-1) |
| [`getDefaultView`](sf-RenderTarget.md#getdefaultview) | `function` | Inherited from [`RenderTarget`](sf-RenderTarget.md#rendertarget-1) |
| [`getViewport`](sf-RenderTarget.md#getviewport) | `function` | Inherited from [`RenderTarget`](sf-RenderTarget.md#rendertarget-1) |
| [`getScissor`](sf-RenderTarget.md#getscissor) | `function` | Inherited from [`RenderTarget`](sf-RenderTarget.md#rendertarget-1) |
| [`mapPixelToCoords`](sf-RenderTarget.md#mappixeltocoords) | `function` | Inherited from [`RenderTarget`](sf-RenderTarget.md#rendertarget-1) |
| [`mapPixelToCoords`](sf-RenderTarget.md#mappixeltocoords-1) | `function` | Inherited from [`RenderTarget`](sf-RenderTarget.md#rendertarget-1) |
| [`mapCoordsToPixel`](sf-RenderTarget.md#mapcoordstopixel) | `function` | Inherited from [`RenderTarget`](sf-RenderTarget.md#rendertarget-1) |
| [`mapCoordsToPixel`](sf-RenderTarget.md#mapcoordstopixel-1) | `function` | Inherited from [`RenderTarget`](sf-RenderTarget.md#rendertarget-1) |
| [`draw`](sf-RenderTarget.md#draw-1) | `function` | Inherited from [`RenderTarget`](sf-RenderTarget.md#rendertarget-1) |
| [`draw`](sf-RenderTarget.md#draw-2) | `function` | Inherited from [`RenderTarget`](sf-RenderTarget.md#rendertarget-1) |
| [`draw`](sf-RenderTarget.md#draw-3) | `function` | Inherited from [`RenderTarget`](sf-RenderTarget.md#rendertarget-1) |
| [`draw`](sf-RenderTarget.md#draw-4) | `function` | Inherited from [`RenderTarget`](sf-RenderTarget.md#rendertarget-1) |
| [`getSize`](sf-RenderTarget.md#getsize-7) | `function` | Inherited from [`RenderTarget`](sf-RenderTarget.md#rendertarget-1) |
| [`isSrgb`](sf-RenderTarget.md#issrgb) | `function` | Inherited from [`RenderTarget`](sf-RenderTarget.md#rendertarget-1) |
| [`setActive`](sf-RenderTarget.md#setactive-2) | `function` | Inherited from [`RenderTarget`](sf-RenderTarget.md#rendertarget-1) |
| [`pushGLStates`](sf-RenderTarget.md#pushglstates) | `function` | Inherited from [`RenderTarget`](sf-RenderTarget.md#rendertarget-1) |
| [`popGLStates`](sf-RenderTarget.md#popglstates) | `function` | Inherited from [`RenderTarget`](sf-RenderTarget.md#rendertarget-1) |
| [`resetGLStates`](sf-RenderTarget.md#resetglstates) | `function` | Inherited from [`RenderTarget`](sf-RenderTarget.md#rendertarget-1) |
| [`RenderTarget`](sf-RenderTarget.md#rendertarget-5) | `function` | Inherited from [`RenderTarget`](sf-RenderTarget.md#rendertarget-1) |
| [`initialize`](sf-RenderTarget.md#initialize-4) | `function` | Inherited from [`RenderTarget`](sf-RenderTarget.md#rendertarget-1) |
| [`m_defaultView`](sf-RenderTarget.md#m_defaultview) | `variable` | Inherited from [`RenderTarget`](sf-RenderTarget.md#rendertarget-1) |
| [`m_view`](sf-RenderTarget.md#m_view) | `variable` | Inherited from [`RenderTarget`](sf-RenderTarget.md#rendertarget-1) |
| [`m_cache`](sf-RenderTarget.md#m_cache) | `variable` | Inherited from [`RenderTarget`](sf-RenderTarget.md#rendertarget-1) |
| [`m_id`](sf-RenderTarget.md#m_id) | `variable` | Inherited from [`RenderTarget`](sf-RenderTarget.md#rendertarget-1) |
| [`applyCurrentView`](sf-RenderTarget.md#applycurrentview) | `function` | Inherited from [`RenderTarget`](sf-RenderTarget.md#rendertarget-1) |
| [`applyBlendMode`](sf-RenderTarget.md#applyblendmode) | `function` | Inherited from [`RenderTarget`](sf-RenderTarget.md#rendertarget-1) |
| [`applyStencilMode`](sf-RenderTarget.md#applystencilmode) | `function` | Inherited from [`RenderTarget`](sf-RenderTarget.md#rendertarget-1) |
| [`applyTransform`](sf-RenderTarget.md#applytransform) | `function` | Inherited from [`RenderTarget`](sf-RenderTarget.md#rendertarget-1) |
| [`applyTexture`](sf-RenderTarget.md#applytexture) | `function` | Inherited from [`RenderTarget`](sf-RenderTarget.md#rendertarget-1) |
| [`applyShader`](sf-RenderTarget.md#applyshader) | `function` | Inherited from [`RenderTarget`](sf-RenderTarget.md#rendertarget-1) |
| [`setupDraw`](sf-RenderTarget.md#setupdraw) | `function` | Inherited from [`RenderTarget`](sf-RenderTarget.md#rendertarget-1) |
| [`drawPrimitives`](sf-RenderTarget.md#drawprimitives) | `function` | Inherited from [`RenderTarget`](sf-RenderTarget.md#rendertarget-1) |
| [`cleanupDraw`](sf-RenderTarget.md#cleanupdraw) | `function` | Inherited from [`RenderTarget`](sf-RenderTarget.md#rendertarget-1) |

## Inherited from [`RenderTarget`](sf-RenderTarget.md#rendertarget-1)

| Kind | Name | Description |
|------|------|-------------|
| `function` | [`~RenderTarget`](sf-RenderTarget.md#rendertarget-2) `virtual` | Destructor. |
| `function` | [`RenderTarget`](sf-RenderTarget.md#rendertarget-3)  | Deleted copy constructor. |
| `function` | [`operator=`](sf-RenderTarget.md#operator-70)  | Deleted copy assignment. |
| `function` | [`RenderTarget`](sf-RenderTarget.md#rendertarget-4) `noexcept` | Move constructor. |
| `function` | [`operator=`](sf-RenderTarget.md#operator-71) `noexcept` | Move assignment. |
| `function` | [`clear`](sf-RenderTarget.md#clear-3)  | Clear the entire target with a single color. |
| `function` | [`clearStencil`](sf-RenderTarget.md#clearstencil)  | Clear the stencil buffer to a specific value. |
| `function` | [`clear`](sf-RenderTarget.md#clear-4)  | Clear the entire target with a single color and stencil value. |
| `function` | [`setView`](sf-RenderTarget.md#setview)  | Change the current active view. |
| `function` | [`getView`](sf-RenderTarget.md#getview) `const` `nodiscard` | Get the view currently in use in the render target. |
| `function` | [`getDefaultView`](sf-RenderTarget.md#getdefaultview) `const` `nodiscard` | Get the default view of the render target. |
| `function` | [`getViewport`](sf-RenderTarget.md#getviewport) `const` `nodiscard` | Get the viewport of a view, applied to this render target. |
| `function` | [`getScissor`](sf-RenderTarget.md#getscissor) `const` `nodiscard` | Get the scissor rectangle of a view, applied to this render target. |
| `function` | [`mapPixelToCoords`](sf-RenderTarget.md#mappixeltocoords) `const` `nodiscard` | Convert a point from target coordinates to world coordinates, using the current view. |
| `function` | [`mapPixelToCoords`](sf-RenderTarget.md#mappixeltocoords-1) `const` `nodiscard` | Convert a point from target coordinates to world coordinates. |
| `function` | [`mapCoordsToPixel`](sf-RenderTarget.md#mapcoordstopixel) `const` `nodiscard` | Convert a point from world coordinates to target coordinates, using the current view. |
| `function` | [`mapCoordsToPixel`](sf-RenderTarget.md#mapcoordstopixel-1) `const` `nodiscard` | Convert a point from world coordinates to target coordinates. |
| `function` | [`draw`](sf-RenderTarget.md#draw-1)  | Draw a drawable object to the render target. |
| `function` | [`draw`](sf-RenderTarget.md#draw-2)  | Draw primitives defined by an array of vertices. |
| `function` | [`draw`](sf-RenderTarget.md#draw-3)  | Draw primitives defined by a vertex buffer. |
| `function` | [`draw`](sf-RenderTarget.md#draw-4)  | Draw primitives defined by a vertex buffer. |
| `function` | [`getSize`](sf-RenderTarget.md#getsize-7) `virtual` `const` `nodiscard` | Return the size of the rendering region of the target. |
| `function` | [`isSrgb`](sf-RenderTarget.md#issrgb) `virtual` `const` `nodiscard` | Tell if the render target will use sRGB encoding when drawing on it. |
| `function` | [`setActive`](sf-RenderTarget.md#setactive-2) `virtual` `nodiscard` | Activate or deactivate the render target for rendering. |
| `function` | [`pushGLStates`](sf-RenderTarget.md#pushglstates)  | Save the current OpenGL render states and matrices. |
| `function` | [`popGLStates`](sf-RenderTarget.md#popglstates)  | Restore the previously saved OpenGL render states and matrices. |
| `function` | [`resetGLStates`](sf-RenderTarget.md#resetglstates)  | Reset the internal OpenGL states so that the target is ready for drawing. |
| `function` | [`RenderTarget`](sf-RenderTarget.md#rendertarget-5)  | Default constructor. |
| `function` | [`initialize`](sf-RenderTarget.md#initialize-4)  | Performs the common initialization step after creation. |
| `variable` | [`m_defaultView`](sf-RenderTarget.md#m_defaultview)  | Default view. |
| `variable` | [`m_view`](sf-RenderTarget.md#m_view)  | Current view. |
| `variable` | [`m_cache`](sf-RenderTarget.md#m_cache)  | Render states cache. |
| `variable` | [`m_id`](sf-RenderTarget.md#m_id)  | Unique number that identifies the [RenderTarget](sf-RenderTarget.md#rendertarget-1). |
| `function` | [`applyCurrentView`](sf-RenderTarget.md#applycurrentview)  | Apply the current view. |
| `function` | [`applyBlendMode`](sf-RenderTarget.md#applyblendmode)  | Apply a new blending mode. |
| `function` | [`applyStencilMode`](sf-RenderTarget.md#applystencilmode)  | Apply a new stencil mode. |
| `function` | [`applyTransform`](sf-RenderTarget.md#applytransform)  | Apply a new transform. |
| `function` | [`applyTexture`](sf-RenderTarget.md#applytexture)  | Apply a new texture. |
| `function` | [`applyShader`](sf-RenderTarget.md#applyshader)  | Apply a new shader. |
| `function` | [`setupDraw`](sf-RenderTarget.md#setupdraw)  | Setup environment for drawing. |
| `function` | [`drawPrimitives`](sf-RenderTarget.md#drawprimitives)  | Draw the primitives. |
| `function` | [`cleanupDraw`](sf-RenderTarget.md#cleanupdraw)  | Clean up environment after drawing. |

## Public Methods

| Return | Name | Description |
|--------|------|-------------|
|  | [`RenderTexture`](#rendertexture-1)  | Default constructor. |
|  | [`RenderTexture`](#rendertexture-2)  | Construct a render-texture. |
|  | [`~RenderTexture`](#rendertexture-3) `override` | Destructor. |
|  | [`RenderTexture`](#rendertexture-4)  | Deleted copy constructor. |
| [`RenderTexture`](#rendertexture) & | [`operator=`](#operator-72)  | Deleted copy assignment. |
|  | [`RenderTexture`](#rendertexture-5) `noexcept` | Move constructor. |
| [`RenderTexture`](#rendertexture) & | [`operator=`](#operator-73) `noexcept` | Move assignment operator. |
| `bool` | [`resize`](#resize-2) `nodiscard` | Resize the render-texture. |
| `void` | [`setSmooth`](#setsmooth-1)  | Enable or disable texture smoothing. |
| `bool` | [`isSmooth`](#issmooth-1) `const` `nodiscard` | Tell whether the smooth filtering is enabled or not. |
| `void` | [`setRepeated`](#setrepeated)  | Enable or disable texture repeating. |
| `bool` | [`isRepeated`](#isrepeated) `const` `nodiscard` | Tell whether the texture is repeated or not. |
| `bool` | [`generateMipmap`](#generatemipmap) `nodiscard` | Generate a mipmap using the current texture data. |
| `bool` | [`setActive`](#setactive-3) `virtual` `nodiscard` `override` | Activate or deactivate the render-texture for rendering. |
| `void` | [`display`](#display-1)  | Update the contents of the target texture. |
| [`Vector2u`](sf.md#vector2u) | [`getSize`](#getsize-8) `virtual` `const` `nodiscard` `override` | Return the size of the rendering region of the texture. |
| `bool` | [`isSrgb`](#issrgb-1) `virtual` `const` `nodiscard` `override` | Tell if the render-texture will use sRGB encoding when drawing on it. |
| const [`Texture`](sf-Texture.md#texture-2) & | [`getTexture`](#gettexture-1) `const` `nodiscard` | Get a read-only reference to the target texture. |

---

{#rendertexture-1}

### RenderTexture

```cpp
RenderTexture()
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/RenderTexture.hpp:64

Default constructor.

Constructs a render-texture with width 0 and height 0.

**See also**: `[resize](#resize-2)`

---

{#rendertexture-2}

### RenderTexture

```cpp
RenderTexture(Vector2u size, const ContextSettings & settings = {})
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/RenderTexture.hpp:83

Construct a render-texture.

The last parameter, `settings`, is useful if you want to enable multi-sampling or use the render-texture for OpenGL rendering that requires a depth or stencil buffer. Otherwise it is unnecessary, and you should leave this parameter at its default value.

After creation, the contents of the render-texture are undefined. Call `[RenderTexture::clear](sf-RenderTarget.md#clear-3)` first to ensure a single color fill.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `size` | [`Vector2u`](sf.md#vector2u) | Width and height of the render-texture |
| `settings` | const [`ContextSettings`](sf-ContextSettings.md#contextsettings) & | Additional settings for the underlying OpenGL texture and context |

#### Exceptions

| Exception | Description |
|-----------|-------------|
| `sf::Exception` | if creation was unsuccessful |

---

{#rendertexture-3}

### ~RenderTexture

`override`

```cpp
~RenderTexture() override
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/RenderTexture.hpp:89

Destructor.

---

{#rendertexture-4}

### RenderTexture

```cpp
RenderTexture(const RenderTexture &) = delete
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/RenderTexture.hpp:95

Deleted copy constructor.

---

{#operator-72}

### operator=

```cpp
RenderTexture & operator=(const RenderTexture &) = delete
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/RenderTexture.hpp:101

Deleted copy assignment.

---

{#rendertexture-5}

### RenderTexture

`noexcept`

```cpp
RenderTexture(RenderTexture &&) noexcept
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/RenderTexture.hpp:107

Move constructor.

---

{#operator-73}

### operator=

`noexcept`

```cpp
RenderTexture & operator=(RenderTexture &&) noexcept
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/RenderTexture.hpp:113

Move assignment operator.

---

{#resize-2}

### resize

`nodiscard`

```cpp
[[nodiscard]] bool resize(Vector2u size, const ContextSettings & settings = {})
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/RenderTexture.hpp:132

Resize the render-texture.

The last parameter, `settings`, is useful if you want to enable multi-sampling or use the render-texture for OpenGL rendering that requires a depth or stencil buffer. Otherwise it is unnecessary, and you should leave this parameter at its default value.

After resizing, the contents of the render-texture are undefined. Call `[RenderTexture::clear](sf-RenderTarget.md#clear-3)` first to ensure a single color fill.

#### Returns
`true` if resizing has been successful, `false` if it failed

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `size` | [`Vector2u`](sf.md#vector2u) | Width and height of the render-texture |
| `settings` | const [`ContextSettings`](sf-ContextSettings.md#contextsettings) & | Additional settings for the underlying OpenGL texture and context |

---

{#setsmooth-1}

### setSmooth

```cpp
void setSmooth(bool smooth)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/RenderTexture.hpp:153

Enable or disable texture smoothing.

This function is similar to `[Texture::setSmooth](sf-Texture.md#setsmooth-2)`. This parameter is disabled by default.

**See also**: `[isSmooth](#issmooth-1)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `smooth` | `bool` | `true` to enable smoothing, `false` to disable it |

---

{#issmooth-1}

### isSmooth

`const` `nodiscard`

```cpp
[[nodiscard]] bool isSmooth() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/RenderTexture.hpp:163

Tell whether the smooth filtering is enabled or not.

#### Returns
`true` if texture smoothing is enabled

**See also**: `[setSmooth](#setsmooth-1)`

---

{#setrepeated}

### setRepeated

```cpp
void setRepeated(bool repeated)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/RenderTexture.hpp:176

Enable or disable texture repeating.

This function is similar to `[Texture::setRepeated](sf-Texture.md#setrepeated-1)`. This parameter is disabled by default.

**See also**: `[isRepeated](#isrepeated)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `repeated` | `bool` | `true` to enable repeating, `false` to disable it |

---

{#isrepeated}

### isRepeated

`const` `nodiscard`

```cpp
[[nodiscard]] bool isRepeated() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/RenderTexture.hpp:186

Tell whether the texture is repeated or not.

#### Returns
`true` if texture is repeated

**See also**: `[setRepeated](#setrepeated)`

---

{#generatemipmap}

### generateMipmap

`nodiscard`

```cpp
[[nodiscard]] bool generateMipmap()
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/RenderTexture.hpp:202

Generate a mipmap using the current texture data.

This function is similar to `[Texture::generateMipmap](sf-Texture.md#generatemipmap-1)` and operates on the texture used as the target for drawing. Be aware that any draw operation may modify the base level image data. For this reason, calling this function only makes sense after all drawing is completed and display has been called. Not calling display after subsequent drawing will lead to undefined behavior if a mipmap had been previously generated.

#### Returns
`true` if mipmap generation was successful, `false` if unsuccessful

---

{#setactive-3}

### setActive

`virtual` `nodiscard` `override`

```cpp
[[nodiscard]] virtual bool setActive(bool active = true) override
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/RenderTexture.hpp:219

Activate or deactivate the render-texture for rendering.

This function makes the render-texture's context current for future OpenGL rendering operations (so you shouldn't care about it if you're not doing direct OpenGL stuff). Only one context can be current in a thread, so if you want to draw OpenGL geometry to another render target (like a [RenderWindow](sf-RenderWindow.md#renderwindow)) don't forget to activate it again.

#### Returns
`true` if operation was successful, `false` otherwise

#### Reimplements

- [`setActive`](sf-RenderTarget.md#setactive-2)

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `active` | `bool` | `true` to activate, `false` to deactivate |

---

{#display-1}

### display

```cpp
void display()
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/RenderTexture.hpp:230

Update the contents of the target texture.

This function updates the target texture with what has been drawn so far. Like for windows, calling this function is mandatory at the end of rendering. Not calling it may leave the texture in an undefined state.

---

{#getsize-8}

### getSize

`virtual` `const` `nodiscard` `override`

```cpp
[[nodiscard]] virtual Vector2u getSize() const override
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/RenderTexture.hpp:241

Return the size of the rendering region of the texture.

The returned value is the size that you passed to the create function.

#### Returns
Size in pixels

#### Reimplements

- [`getSize`](sf-RenderTarget.md#getsize-7)

---

{#issrgb-1}

### isSrgb

`virtual` `const` `nodiscard` `override`

```cpp
[[nodiscard]] virtual bool isSrgb() const override
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/RenderTexture.hpp:252

Tell if the render-texture will use sRGB encoding when drawing on it.

You can request sRGB encoding for a render-texture by having the sRgbCapable flag set for the context parameter of `create()` method

#### Returns
`true` if the render-texture use sRGB encoding, `false` otherwise

#### Reimplements

- [`isSrgb`](sf-RenderTarget.md#issrgb)

---

{#gettexture-1}

### getTexture

`const` `nodiscard`

```cpp
[[nodiscard]] const Texture & getTexture() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/RenderTexture.hpp:268

Get a read-only reference to the target texture.

After drawing to the render-texture and calling Display, you can retrieve the updated texture using this function, and draw it using a sprite (for example). The internal `[sf::Texture](sf-Texture.md#texture-2)` of a render-texture is always the same instance, so that it is possible to call this function once and keep a reference to the texture even after it is modified.

#### Returns
Const reference to the texture

## Public Static Methods

| Return | Name | Description |
|--------|------|-------------|
| `unsigned int` | [`getMaximumAntiAliasingLevel`](#getmaximumantialiasinglevel) `static` `nodiscard` | Get the maximum anti-aliasing level supported by the system. |

---

{#getmaximumantialiasinglevel}

### getMaximumAntiAliasingLevel

`static` `nodiscard`

```cpp
[[nodiscard]] static unsigned int getMaximumAntiAliasingLevel()
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/RenderTexture.hpp:140

Get the maximum anti-aliasing level supported by the system.

#### Returns
The maximum anti-aliasing level supported by the system

## Private Attributes

| Return | Name | Description |
|--------|------|-------------|
| `std::unique_ptr< priv::RenderTextureImpl >` | [`m_impl`](#m_impl-9)  | Platform/hardware specific implementation. |
| [`Texture`](sf-Texture.md#texture-2) | [`m_texture`](#m_texture)  | Target texture to draw on. |

---

{#m_impl-9}

### m_impl

```cpp
std::unique_ptr< priv::RenderTextureImpl > m_impl
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/RenderTexture.hpp:274

Platform/hardware specific implementation.

---

{#m_texture}

### m_texture

```cpp
Texture m_texture
```

Type: [`Texture`](sf-Texture.md#texture-2)

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/RenderTexture.hpp:275

Target texture to draw on.

