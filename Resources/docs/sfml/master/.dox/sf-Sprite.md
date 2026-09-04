{#sprite}

# Sprite

```cpp
#include <Sprite.hpp>
```

```cpp
class Sprite
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Sprite.hpp:50

> **Inherits:** [`Drawable`](sf-Drawable.md#drawable), [`Transformable`](sf-Transformable.md#transformable)

[Drawable](sf-Drawable.md#drawable) representation of a texture, with its own transformations, color, etc.

`[sf::Sprite](#sprite)` is a drawable class that allows to easily display a texture (or a part of it) on a render target.

It inherits all the functions from `[sf::Transformable](sf-Transformable.md#transformable)`: position, rotation, scale, origin. It also adds sprite-specific properties such as the texture to use, the part of it to display, and some convenience functions to change the overall color of the sprite, or to get its bounding rectangle.

`[sf::Sprite](#sprite)` works in combination with the `[sf::Texture](sf-Texture.md#texture-2)` class, which loads and provides the pixel data of a given texture.

The separation of `[sf::Sprite](#sprite)` and `[sf::Texture](sf-Texture.md#texture-2)` allows more flexibility and better performances: indeed a `[sf::Texture](sf-Texture.md#texture-2)` is a heavy resource, and any operation on it is slow (often too slow for real-time applications). On the other side, a `[sf::Sprite](#sprite)` is a lightweight object which can use the pixel data of a `[sf::Texture](sf-Texture.md#texture-2)` and draw it with its own transformation/color/blending attributes.

It is important to note that the `[sf::Sprite](#sprite)` instance doesn't copy the texture that it uses, it only keeps a reference to it. Thus, a `[sf::Texture](sf-Texture.md#texture-2)` must not be destroyed while it is used by a `[sf::Sprite](#sprite)` (i.e. never write a function that uses a local `[sf::Texture](sf-Texture.md#texture-2)` instance for creating a sprite).

See also the note on coordinates and undistorted rendering in `[sf::Transformable](sf-Transformable.md#transformable)`.

Usage example: 
```cpp
// Load a texture
const sf::Texture texture("texture.png");

// Create a sprite
sf::Sprite sprite(texture);
sprite.setTextureRect({{10, 10}, {50, 30}});
sprite.setColor({255, 255, 255, 200});
sprite.setPosition({100.f, 25.f});

// Draw it
window.draw(sprite);
```

**See also**: `[sf::Texture](sf-Texture.md#texture-2)`, `[sf::Transformable](sf-Transformable.md#transformable)`

## List of all members

| Name | Kind | Owner |
|------|------|-------|
| [`Sprite`](#sprite-1) | `function` | Declared here |
| [`Sprite`](#sprite-2) | `function` | Declared here |
| [`Sprite`](#sprite-3) | `function` | Declared here |
| [`Sprite`](#sprite-4) | `function` | Declared here |
| [`setTexture`](#settexture-1) | `function` | Declared here |
| [`setTexture`](#settexture-2) | `function` | Declared here |
| [`setTextureRect`](#settexturerect-1) | `function` | Declared here |
| [`setColor`](#setcolor) | `function` | Declared here |
| [`getTexture`](#gettexture-3) | `function` | Declared here |
| [`getTextureRect`](#gettexturerect-1) | `function` | Declared here |
| [`getColor`](#getcolor) | `function` | Declared here |
| [`getLocalBounds`](#getlocalbounds-1) | `function` | Declared here |
| [`getGlobalBounds`](#getglobalbounds-1) | `function` | Declared here |
| [`m_vertices`](#m_vertices-1) | `variable` | Declared here |
| [`m_texture`](#m_texture-2) | `variable` | Declared here |
| [`m_textureRect`](#m_texturerect-1) | `variable` | Declared here |
| [`draw`](#draw-6) | `function` | Declared here |
| [`updateVertices`](#updatevertices) | `function` | Declared here |
| [`RenderTarget`](sf-Drawable.md#rendertarget) | `friend` | Inherited from [`Drawable`](sf-Drawable.md#drawable) |
| [`~Drawable`](sf-Drawable.md#drawable-1) | `function` | Inherited from [`Drawable`](sf-Drawable.md#drawable) |
| [`draw`](sf-Drawable.md#draw) | `function` | Inherited from [`Drawable`](sf-Drawable.md#drawable) |
| [`Transformable`](sf-Transformable.md#transformable-1) | `function` | Inherited from [`Transformable`](sf-Transformable.md#transformable) |
| [`~Transformable`](sf-Transformable.md#transformable-2) | `function` | Inherited from [`Transformable`](sf-Transformable.md#transformable) |
| [`setPosition`](sf-Transformable.md#setposition-5) | `function` | Inherited from [`Transformable`](sf-Transformable.md#transformable) |
| [`setRotation`](sf-Transformable.md#setrotation) | `function` | Inherited from [`Transformable`](sf-Transformable.md#transformable) |
| [`setScale`](sf-Transformable.md#setscale) | `function` | Inherited from [`Transformable`](sf-Transformable.md#transformable) |
| [`setOrigin`](sf-Transformable.md#setorigin) | `function` | Inherited from [`Transformable`](sf-Transformable.md#transformable) |
| [`getPosition`](sf-Transformable.md#getposition-7) | `function` | Inherited from [`Transformable`](sf-Transformable.md#transformable) |
| [`getRotation`](sf-Transformable.md#getrotation) | `function` | Inherited from [`Transformable`](sf-Transformable.md#transformable) |
| [`getScale`](sf-Transformable.md#getscale) | `function` | Inherited from [`Transformable`](sf-Transformable.md#transformable) |
| [`getOrigin`](sf-Transformable.md#getorigin) | `function` | Inherited from [`Transformable`](sf-Transformable.md#transformable) |
| [`move`](sf-Transformable.md#move) | `function` | Inherited from [`Transformable`](sf-Transformable.md#transformable) |
| [`rotate`](sf-Transformable.md#rotate-2) | `function` | Inherited from [`Transformable`](sf-Transformable.md#transformable) |
| [`scale`](sf-Transformable.md#scale-2) | `function` | Inherited from [`Transformable`](sf-Transformable.md#transformable) |
| [`getTransform`](sf-Transformable.md#gettransform) | `function` | Inherited from [`Transformable`](sf-Transformable.md#transformable) |
| [`getInverseTransform`](sf-Transformable.md#getinversetransform) | `function` | Inherited from [`Transformable`](sf-Transformable.md#transformable) |
| [`m_origin`](sf-Transformable.md#m_origin) | `variable` | Inherited from [`Transformable`](sf-Transformable.md#transformable) |
| [`m_position`](sf-Transformable.md#m_position) | `variable` | Inherited from [`Transformable`](sf-Transformable.md#transformable) |
| [`m_rotation`](sf-Transformable.md#m_rotation) | `variable` | Inherited from [`Transformable`](sf-Transformable.md#transformable) |
| [`m_scale`](sf-Transformable.md#m_scale) | `variable` | Inherited from [`Transformable`](sf-Transformable.md#transformable) |
| [`m_transform`](sf-Transformable.md#m_transform) | `variable` | Inherited from [`Transformable`](sf-Transformable.md#transformable) |
| [`m_inverseTransform`](sf-Transformable.md#m_inversetransform) | `variable` | Inherited from [`Transformable`](sf-Transformable.md#transformable) |
| [`m_transformNeedUpdate`](sf-Transformable.md#m_transformneedupdate) | `variable` | Inherited from [`Transformable`](sf-Transformable.md#transformable) |
| [`m_inverseTransformNeedUpdate`](sf-Transformable.md#m_inversetransformneedupdate) | `variable` | Inherited from [`Transformable`](sf-Transformable.md#transformable) |

## Inherited from [`Drawable`](sf-Drawable.md#drawable)

| Kind | Name | Description |
|------|------|-------------|
| `friend` | [`RenderTarget`](sf-Drawable.md#rendertarget)  |  |
| `function` | [`~Drawable`](sf-Drawable.md#drawable-1) `virtual` | Virtual destructor. |
| `function` | [`draw`](sf-Drawable.md#draw) `virtual` `const` | Draw the object to a render target. |

## Inherited from [`Transformable`](sf-Transformable.md#transformable)

| Kind | Name | Description |
|------|------|-------------|
| `function` | [`Transformable`](sf-Transformable.md#transformable-1)  | Default constructor. |
| `function` | [`~Transformable`](sf-Transformable.md#transformable-2) `virtual` | Virtual destructor. |
| `function` | [`setPosition`](sf-Transformable.md#setposition-5)  | set the position of the object |
| `function` | [`setRotation`](sf-Transformable.md#setrotation)  | set the orientation of the object |
| `function` | [`setScale`](sf-Transformable.md#setscale)  | set the scale factors of the object |
| `function` | [`setOrigin`](sf-Transformable.md#setorigin)  | set the local origin of the object |
| `function` | [`getPosition`](sf-Transformable.md#getposition-7) `const` `nodiscard` | get the position of the object |
| `function` | [`getRotation`](sf-Transformable.md#getrotation) `const` `nodiscard` | get the orientation of the object |
| `function` | [`getScale`](sf-Transformable.md#getscale) `const` `nodiscard` | get the current scale of the object |
| `function` | [`getOrigin`](sf-Transformable.md#getorigin) `const` `nodiscard` | get the local origin of the object |
| `function` | [`move`](sf-Transformable.md#move)  | Move the object by a given offset. |
| `function` | [`rotate`](sf-Transformable.md#rotate-2)  | Rotate the object. |
| `function` | [`scale`](sf-Transformable.md#scale-2)  | Scale the object. |
| `function` | [`getTransform`](sf-Transformable.md#gettransform) `const` `nodiscard` | get the combined transform of the object |
| `function` | [`getInverseTransform`](sf-Transformable.md#getinversetransform) `const` `nodiscard` | get the inverse of the combined transform of the object |
| `variable` | [`m_origin`](sf-Transformable.md#m_origin)  | Origin of translation/rotation/scaling of the object. |
| `variable` | [`m_position`](sf-Transformable.md#m_position)  | Position of the object in the 2D world. |
| `variable` | [`m_rotation`](sf-Transformable.md#m_rotation)  | Orientation of the object. |
| `variable` | [`m_scale`](sf-Transformable.md#m_scale)  | Scale of the object. |
| `variable` | [`m_transform`](sf-Transformable.md#m_transform)  | Combined transformation of the object. |
| `variable` | [`m_inverseTransform`](sf-Transformable.md#m_inversetransform)  | Combined transformation of the object. |
| `variable` | [`m_transformNeedUpdate`](sf-Transformable.md#m_transformneedupdate)  | Does the transform need to be recomputed? |
| `variable` | [`m_inverseTransformNeedUpdate`](sf-Transformable.md#m_inversetransformneedupdate)  | Does the transform need to be recomputed? |

## Public Methods

| Return | Name | Description |
|--------|------|-------------|
|  | [`Sprite`](#sprite-1) `explicit` | Construct the sprite from a source texture. |
|  | [`Sprite`](#sprite-2) `explicit` | Disallow construction from a temporary texture. |
|  | [`Sprite`](#sprite-3)  | Construct the sprite from a sub-rectangle of a source texture. |
|  | [`Sprite`](#sprite-4)  | Disallow construction from a temporary texture. |
| `void` | [`setTexture`](#settexture-1)  | Change the source texture of the sprite. |
| `void` | [`setTexture`](#settexture-2)  | Disallow setting from a temporary texture. |
| `void` | [`setTextureRect`](#settexturerect-1)  | Set the sub-rectangle of the texture that the sprite will display. |
| `void` | [`setColor`](#setcolor)  | Set the global color of the sprite. |
| const [`Texture`](sf-Texture.md#texture-2) & | [`getTexture`](#gettexture-3) `const` `nodiscard` | Get the source texture of the sprite. |
| const [`IntRect`](sf.md#intrect) & | [`getTextureRect`](#gettexturerect-1) `const` `nodiscard` | Get the sub-rectangle of the texture displayed by the sprite. |
| [`Color`](sf-Color.md#color) | [`getColor`](#getcolor) `const` `nodiscard` | Get the global color of the sprite. |
| [`FloatRect`](sf.md#floatrect) | [`getLocalBounds`](#getlocalbounds-1) `const` `nodiscard` | Get the local bounding rectangle of the entity. |
| [`FloatRect`](sf.md#floatrect) | [`getGlobalBounds`](#getglobalbounds-1) `const` `nodiscard` | Get the global bounding rectangle of the entity. |

---

{#sprite-1}

### Sprite

`explicit`

```cpp
explicit Sprite(const Texture & texture)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Sprite.hpp:61

Construct the sprite from a source texture.

**See also**: `[setTexture](#settexture-1)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `texture` | const [`Texture`](sf-Texture.md#texture-2) & | Source texture |

---

{#sprite-2}

### Sprite

`explicit`

```cpp
explicit Sprite(const Texture && texture) = delete
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Sprite.hpp:67

Disallow construction from a temporary texture.

---

{#sprite-3}

### Sprite

```cpp
Sprite(const Texture & texture, const IntRect & rectangle)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Sprite.hpp:78

Construct the sprite from a sub-rectangle of a source texture.

**See also**: `[setTexture](#settexture-1)`, `[setTextureRect](#settexturerect-1)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `texture` | const [`Texture`](sf-Texture.md#texture-2) & | Source texture |
| `rectangle` | const [`IntRect`](sf.md#intrect) & | Sub-rectangle of the texture to assign to the sprite |

---

{#sprite-4}

### Sprite

```cpp
Sprite(const Texture && texture, const IntRect & rectangle) = delete
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Sprite.hpp:84

Disallow construction from a temporary texture.

---

{#settexture-1}

### setTexture

```cpp
void setTexture(const Texture & texture, bool resetRect = false)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Sprite.hpp:105

Change the source texture of the sprite.

The `texture` argument refers to a texture that must exist as long as the sprite uses it. Indeed, the sprite doesn't store its own copy of the texture, but rather keeps a pointer to the one that you passed to this function. If the source texture is destroyed and the sprite tries to use it, the behavior is undefined. If `resetRect` is `true`, the `TextureRect` property of the sprite is automatically adjusted to the size of the new texture. If it is `false`, the texture rect is left unchanged.

**See also**: `[getTexture](#gettexture-3)`, `[setTextureRect](#settexturerect-1)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `texture` | const [`Texture`](sf-Texture.md#texture-2) & | New texture |
| `resetRect` | `bool` | Should the texture rect be reset to the size of the new texture? |

---

{#settexture-2}

### setTexture

```cpp
void setTexture(const Texture && texture, bool resetRect = false) = delete
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Sprite.hpp:111

Disallow setting from a temporary texture.

---

{#settexturerect-1}

### setTextureRect

```cpp
void setTextureRect(const IntRect & rectangle)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Sprite.hpp:125

Set the sub-rectangle of the texture that the sprite will display.

The texture rect is useful when you don't want to display the whole texture, but rather a part of it. By default, the texture rect covers the entire texture.

**See also**: `[getTextureRect](#gettexturerect-1)`, `[setTexture](#settexture-1)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `rectangle` | const [`IntRect`](sf.md#intrect) & | Rectangle defining the region of the texture to display |

---

{#setcolor}

### setColor

```cpp
void setColor(Color color)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Sprite.hpp:140

Set the global color of the sprite.

This color is modulated (multiplied) with the sprite's texture. It can be used to colorize the sprite, or change its global opacity. By default, the sprite's color is opaque white.

**See also**: `[getColor](#getcolor)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `color` | [`Color`](sf-Color.md#color) | New color of the sprite |

---

{#gettexture-3}

### getTexture

`const` `nodiscard`

```cpp
[[nodiscard]] const Texture & getTexture() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Sprite.hpp:153

Get the source texture of the sprite.

The returned reference is const, which means that you can't modify the texture when you retrieve it with this function.

#### Returns
Reference to the sprite's texture

**See also**: `[setTexture](#settexture-1)`

---

{#gettexturerect-1}

### getTextureRect

`const` `nodiscard`

```cpp
[[nodiscard]] const IntRect & getTextureRect() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Sprite.hpp:163

Get the sub-rectangle of the texture displayed by the sprite.

#### Returns
[Texture](sf-Texture.md#texture-2) rectangle of the sprite

**See also**: `[setTextureRect](#settexturerect-1)`

---

{#getcolor}

### getColor

`const` `nodiscard`

```cpp
[[nodiscard]] Color getColor() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Sprite.hpp:173

Get the global color of the sprite.

#### Returns
Global color of the sprite

**See also**: `[setColor](#setcolor)`

---

{#getlocalbounds-1}

### getLocalBounds

`const` `nodiscard`

```cpp
[[nodiscard]] FloatRect getLocalBounds() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Sprite.hpp:187

Get the local bounding rectangle of the entity.

The returned rectangle is in local coordinates, which means that it ignores the transformations (translation, rotation, scale, ...) that are applied to the entity. In other words, this function returns the bounds of the entity in the entity's coordinate system.

#### Returns
Local bounding rectangle of the entity

---

{#getglobalbounds-1}

### getGlobalBounds

`const` `nodiscard`

```cpp
[[nodiscard]] FloatRect getGlobalBounds() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Sprite.hpp:201

Get the global bounding rectangle of the entity.

The returned rectangle is in global coordinates, which means that it takes into account the transformations (translation, rotation, scale, ...) that are applied to the entity. In other words, this function returns the bounds of the sprite in the global 2D world's coordinate system.

#### Returns
Global bounding rectangle of the entity

## Private Attributes

| Return | Name | Description |
|--------|------|-------------|
| std::array< [`Vertex`](sf-Vertex.md#vertex), 4 > | [`m_vertices`](#m_vertices-1)  | Vertices defining the sprite's geometry. |
| const [`Texture`](sf-Texture.md#texture-2) * | [`m_texture`](#m_texture-2)  | [Texture](sf-Texture.md#texture-2) of the sprite. |
| [`IntRect`](sf.md#intrect) | [`m_textureRect`](#m_texturerect-1)  | Rectangle defining the area of the source texture to display. |

---

{#m_vertices-1}

### m_vertices

```cpp
std::array< Vertex, 4 > m_vertices
```

Type: std::array< [`Vertex`](sf-Vertex.md#vertex), 4 >

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Sprite.hpp:222

Vertices defining the sprite's geometry.

---

{#m_texture-2}

### m_texture

```cpp
const Texture * m_texture
```

Type: const [`Texture`](sf-Texture.md#texture-2) *

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Sprite.hpp:223

[Texture](sf-Texture.md#texture-2) of the sprite.

---

{#m_texturerect-1}

### m_textureRect

```cpp
IntRect m_textureRect
```

Type: [`IntRect`](sf.md#intrect)

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Sprite.hpp:224

Rectangle defining the area of the source texture to display.

## Private Methods

| Return | Name | Description |
|--------|------|-------------|
| `void` | [`draw`](#draw-6) `virtual` `const` `override` | Draw the sprite to a render target. |
| `void` | [`updateVertices`](#updatevertices)  | Update the vertices' positions and texture coordinates. |

---

{#draw-6}

### draw

`virtual` `const` `override`

```cpp
virtual void draw(RenderTarget & target, RenderStates states) const override
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Sprite.hpp:211

Draw the sprite to a render target.

#### Reimplements

- [`draw`](sf-Drawable.md#draw)

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `target` | [`RenderTarget`](sf-RenderTarget.md#rendertarget-1) & | Render target to draw to |
| `states` | [`RenderStates`](sf-RenderStates.md#renderstates) | Current render states |

---

{#updatevertices}

### updateVertices

```cpp
void updateVertices()
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Graphics/Sprite.hpp:217

Update the vertices' positions and texture coordinates.

